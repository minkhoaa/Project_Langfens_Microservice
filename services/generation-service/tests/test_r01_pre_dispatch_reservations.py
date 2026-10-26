"""R01 admission through the SDK transport and authoritative checkpoint boundary.

PostgreSQL cases use the existing local exam-service test database; all provider
HTTP is intercepted, so these tests cannot start a paid campaign.
"""
from __future__ import annotations

import asyncio
import hashlib
from uuid import uuid4

import httpx
import pytest

from app.config import settings
from app.persistence.client import CheckpointClient
from app.persistence.models import (
    BenchmarkCampaignCreateRequest,
    BenchmarkCaseProvisionRequest,
    BudgetAllocationItem,
    OperationGrantRequest,
    SetBudgetAllocationsRequest,
    UnknownOutcomeRequest,
)
from app.providers.adapters.minimax import MiniMaxProvider
from app.providers.adapters.openai_compatible import OpenAICompatibleProvider
from app.providers.errors import BudgetExhaustedError, ProviderError, ProviderUnavailableError
from app.providers.gateway import ProviderGateway
from app.providers.models import Capability, ChatMessage, ProviderRequest
from app.providers.registry import ProviderRegistry
from app.providers.retry import RetryPolicy
from tests.test_t03_providers import MockCheckpointClient
from tests.test_t09_real_postgres_durability import (
    REAL_API_KEY,
    REAL_SERVICE_URL,
    ensure_exam_test_database,
    get_exam_db_container,
    is_docker_postgres_available,
    is_service_available,
)


@pytest.fixture(scope="module", autouse=True)
def _ensure_test_database():
    if is_docker_postgres_available():
        ensure_exam_test_database()

def _request(run_id="r01_memory", **updates):
    return ProviderRequest(
        capability=Capability.GENERATE_TEXT,
        messages=[ChatMessage(role="user", content="Budget café 漢字 " * 20)],
        response_schema={"type": "object", "properties": {"answer": {"type": "string"}}},
        operation_id="r01_attempt",
        run_id=run_id,
        max_tokens=128,
        timeout_seconds=20,
        wall_time_reservation_seconds=5,
    ).model_copy(update=updates)


def _provider(http_client, reasoning=False):
    if reasoning:
        return MiniMaxProvider(models={"large": "MiniMax-M3"}, http_client=http_client)
    return OpenAICompatibleProvider(
        name="r01", base_url="https://r01.invalid/v1",
        models={"large": "r01-model"}, http_client=http_client,
    )


def _gateway(provider, checkpoint, attempts=3):
    registry = ProviderRegistry()
    registry.register_provider(provider, keys=["test-only-r01-key"])
    return ProviderGateway(
        registry=registry, checkpoint_client=checkpoint,
        retry_policy=RetryPolicy(max_attempts=attempts, base_delay_seconds=0.001, max_delay_seconds=0.002),
    )


async def _authority(authority, token_cap):
    owner = uuid4()
    if authority == "memory":
        return MockCheckpointClient(run_tokens_cap=token_cap), "r01_memory", owner, None
    if not is_service_available():
        pytest.skip("exam-service live process not reachable on port 5099")
    if not is_docker_postgres_available():
        pytest.skip("docker exam-database not running")
    get_exam_db_container()
    client = CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)
    campaign_id = f"r01_local_{uuid4().hex}"
    await client.create_benchmark_campaign_async(BenchmarkCampaignCreateRequest(
        campaignId=campaign_id, authorizationId="r01-local-test-only", authorizedBy="pytest-no-paid-transport",
        corpusSha256=hashlib.sha256(b"r01-local-fixture").hexdigest(),
        configSha256=hashlib.sha256(b"r01-local-config").hexdigest(),
        budgetCapCalls=15, budgetCapTokens=token_cap, budgetCapWallTimeSeconds=300,
    ))
    case = await client.provision_benchmark_case_async(BenchmarkCaseProvisionRequest(
        campaignId=campaign_id, caseId="case-a", claimId="r01-local-claim", leaseOwner=owner,
    ))
    return client, case.runId, owner, campaign_id


async def _operations(client, run_id):
    if isinstance(client, MockCheckpointClient):
        return {key: (op["status"], op["tokenReservation"]) for key, op in client.operations.items()}
    state = await client.resume_state_async(run_id)
    return {op.operationId: (op.status, op.tokenReservation) for op in state.operations or []}


@pytest.mark.asyncio
@pytest.mark.parametrize("authority", ["memory", "postgres"])
@pytest.mark.parametrize("scenario", ["prompt", "retry", "three-attempts", "reasoning"])
async def test_r01_prompt_retry_admission_and_unknown_replay(authority, scenario):
    """Headroom is admitted before dispatch; unknown outcomes retain one grant without retries."""
    calls = []
    async def route(wire_request):
        return await transport(wire_request)

    async with httpx.AsyncClient(transport=httpx.MockTransport(route)) as http_client:
        provider = _provider(http_client, reasoning=scenario == "reasoning")
        request = _request()
        bound = provider.conservative_token_reservation(request)
        cap = {"prompt": request.max_tokens, "reasoning": bound - 1,
               "retry": 2 * bound - 1, "three-attempts": 3 * bound}[scenario]
        client, run_id, owner, campaign_id = await _authority(authority, cap)
        request = request.model_copy(update={"run_id": run_id})
        # A 503 cannot prove the provider did not execute the request. Neither
        # spare budget nor a three-attempt policy authorizes another paid call.
        expected_calls = {"prompt": 0, "reasoning": 0, "retry": 1, "three-attempts": 1}[scenario]

        async def transport(wire_request):
            attempt = len(calls) + 1
            operation_id = request.operation_id if attempt == 1 else f"{request.operation_id}:attempt:{attempt}"
            persisted = await _operations(client, run_id)
            assert persisted[operation_id] == ("RESERVED", bound)
            assert bound >= len(request.messages[0].content.encode("utf-8")) + request.max_tokens
            calls.append(wire_request)
            return httpx.Response(503, json={"error": {"message": "local transport failure"}})


        gateway = _gateway(provider, client)
        error = ProviderUnavailableError if expected_calls else BudgetExhaustedError
        with pytest.raises(error):
            await gateway.execute(request, epoch=1, lease_owner=owner)
        assert len(calls) == expected_calls
        persisted = await _operations(client, run_id)
        assert persisted == {
            request.operation_id if n == 1 else f"{request.operation_id}:attempt:{n}": ("UNKNOWN_OUTCOME", bound)
            for n in range(1, expected_calls + 1)
        }
        # A new gateway/client must not charge or redispatch retained attempts.
        replay_client = client if authority == "memory" else CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)
        replay_error = ProviderError if expected_calls else BudgetExhaustedError
        replay_message = "UNKNOWN_OUTCOME.*requires reconciliation" if expected_calls else "Budget cap exceeded"
        with pytest.raises(replay_error, match=replay_message):
            await _gateway(provider, replay_client).execute(request, epoch=1, lease_owner=owner)
        assert len(calls) == expected_calls
        assert await _operations(replay_client, run_id) == persisted
        if campaign_id:
            campaign = await replay_client.get_benchmark_campaign_async(campaign_id)
            state = await replay_client.resume_state_async(run_id)
            assert campaign.budgetUsedTokens == state.tokensUsed == expected_calls * bound
            assert campaign.budgetUsedCalls == state.callsUsed == expected_calls
        else:
            assert client.run_used_tokens == expected_calls * bound
            assert client.run_used_calls == expected_calls


@pytest.mark.asyncio
@pytest.mark.skipif(not is_service_available(), reason="exam-service live process not reachable on port 5099")
@pytest.mark.skipif(not is_docker_postgres_available(), reason="docker exam-database not running")
@pytest.mark.parametrize("scope", ["campaign", "run", "parent", "section", "artifact"])
async def test_r01_real_postgres_concurrent_near_cap_admission(scope):
    """Two contenders race for less than two full reservations: only one may dispatch."""
    calls = []
    async def route(wire_request):
        return await transport(wire_request)

    async with httpx.AsyncClient(transport=httpx.MockTransport(route)) as http_client:
        provider = _provider(http_client)
        bound = provider.conservative_token_reservation(_request())
        near_cap = 2 * bound - 1
        client, run_id, owner, campaign_id = await _authority("postgres", near_cap if scope == "campaign" else settings.benchmark_child_run_max_tokens)
        requests = [_request(run_id, operation_id=f"r01_race_{n}") for n in (1, 2)]
        owners = [owner, owner]
        if scope == "campaign":
            owners[1] = uuid4()
            other = await client.provision_benchmark_case_async(BenchmarkCaseProvisionRequest(
                campaignId=campaign_id, caseId="case-b", claimId="r01-local-claim", leaseOwner=owners[1],
            ))
            requests[1] = requests[1].model_copy(update={"run_id": other.runId})
        elif scope in ("run", "parent"):
            state = await client.resume_state_async(run_id)
            await client.grant_operation_async(OperationGrantRequest(
                runId=run_id, epoch=1, leaseOwner=owner, operationId="r01_seed",
                operationType="PROVIDER_CALL" if scope == "run" else "EVALUATION",
                requestHash=hashlib.sha256(scope.encode()).hexdigest(),
                tokenReservation=state.budgetCapTokens - near_cap if scope == "run" else near_cap,
                wallTimeReservationSeconds=20,
            ))
            if scope == "run":
                await client.record_unknown_outcome_async(UnknownOutcomeRequest(
                    runId=run_id, epoch=1, leaseOwner=owner, operationId="r01_seed", errorMessage="retained earlier attempt",
                ))
            else:
                requests = [request.model_copy(update={"parent_operation_id": "r01_seed"}) for request in requests]
        else:
            await client.set_budget_allocations_async(SetBudgetAllocationsRequest(
                runId=run_id, epoch=1, leaseOwner=owner,
                allocations=[BudgetAllocationItem(scopeType="SECTION", scopeId="r01_section", tokenCap=2 * near_cap if scope == "artifact" else near_cap, callCap=5, wallTimeCapSeconds=100)] + (
                    [BudgetAllocationItem(scopeType="ARTIFACT", scopeId="r01_artifact", parentScopeId="r01_section", tokenCap=near_cap, callCap=5, wallTimeCapSeconds=100)]
                    if scope == "artifact" else []
                ),
            ))
            requests = [request.model_copy(update={"section_id": "r01_section", "artifact_id": "r01_artifact" if scope == "artifact" else None}) for request in requests]

        async def transport(wire_request):
            snapshots = [await _operations(client, request.run_id) for request in requests]
            granted = [request.operation_id for request, snapshot in zip(requests, snapshots) if snapshot.get(request.operation_id) == ("RESERVED", bound)]
            assert len(granted) == 1
            calls.append(wire_request)
            return httpx.Response(503, json={"error": {"message": "retained local failure"}})


        results = await asyncio.gather(*[
            _gateway(provider, client, attempts=1).execute(request, epoch=1, lease_owner=request_owner)
            for request, request_owner in zip(requests, owners)
        ], return_exceptions=True)
        assert sum(isinstance(result, BudgetExhaustedError) for result in results) == 1, results
        assert sum(isinstance(result, ProviderUnavailableError) for result in results) == 1, results
        assert len(calls) == 1
        persisted = [(await _operations(client, request.run_id)).get(request.operation_id) for request in requests]
        assert sorted(item for item in persisted if item is not None) == [("UNKNOWN_OUTCOME", bound)]
        campaign = await client.get_benchmark_campaign_async(campaign_id)
        expected_tokens = settings.benchmark_child_run_max_tokens - near_cap + bound if scope == "run" else bound
        assert campaign.budgetUsedTokens == expected_tokens
        assert campaign.budgetUsedCalls == (2 if scope == "run" else 1)
        assert campaign.budgetUsedTokens <= campaign.budgetCapTokens


@pytest.mark.asyncio
@pytest.mark.skipif(not is_service_available(), reason="exam-service live process not reachable on port 5099")
@pytest.mark.skipif(not is_docker_postgres_available(), reason="docker exam-database not running")
async def test_r01_real_postgres_completed_attempt_replay():
    """A successful attempt returns its persisted response without another reservation or wire call."""
    calls = []

    def transport(request):
        calls.append(request)
        return httpx.Response(200, json={
            "id": "r01-local-completion", "model": "r01-model", "object": "chat.completion", "created": 1,
            "choices": [{"index": 0, "finish_reason": "stop", "message": {"role": "assistant", "content": '{"answer":"local result"}'}}],
            "usage": {"prompt_tokens": 30, "completion_tokens": 10, "total_tokens": 40},
        })

    async with httpx.AsyncClient(transport=httpx.MockTransport(transport)) as http_client:
        provider = _provider(http_client)
        client, run_id, owner, campaign_id = await _authority("postgres", settings.benchmark_child_run_max_tokens)
        request = _request(run_id)
        response = await _gateway(provider, client).execute(request, epoch=1, lease_owner=owner)
        restarted = CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)
        replay = await _gateway(provider, restarted).execute(request, epoch=1, lease_owner=owner)
        assert replay == response
        assert replay.parsed_payload == {"answer": "local result"}
        assert replay.usage.total_tokens == 40
        assert len(calls) == 1
        campaign = await restarted.get_benchmark_campaign_async(campaign_id)
        assert campaign.budgetUsedTokens == 40
        assert campaign.budgetUsedCalls == 1
        assert await _operations(restarted, run_id) == {request.operation_id: ("COMPLETED", provider.conservative_token_reservation(request))}
