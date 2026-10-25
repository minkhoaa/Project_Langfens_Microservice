"""Gateway dispatch against an operation ledger with the PostgreSQL parent predicates.

The double is not PostgreSQL certification; the .NET contracts exercise that separately.
"""
import asyncio
import json
import time
from uuid import uuid4

import pytest

from app.persistence.client import CheckpointApiError
from app.persistence.models import OperationGrantRequest
from app.providers.errors import BudgetExhaustedError, ProviderError
from app.providers.gateway import ProviderGateway
from app.providers.models import Capability, ChatMessage, ProviderRequest, ProviderResponse, UsageReport
from app.providers.registry import ProviderRegistry
from tests.test_hybrid_production_integration import FencedTestCheckpointClient, RecordingHybridIntegrationProvider


class ParentLedger(FencedTestCheckpointClient):
    def grant_operation(self, req):
        if req.operationId not in self.operations and req.parentOperationId:
            parent = self.operations.get(req.parentOperationId)
            if not parent or parent.status != "RESERVED":
                raise CheckpointApiError(422, "Parent must be RESERVED")
            if parent.sectionId != req.sectionId:
                raise CheckpointApiError(422, "Parent section mismatch")
            children = [o for o in self.operations.values() if o.parentOperationId == parent.operationId]
            tokens = sum(o.tokensUsed if o.status == "COMPLETED" and o.accountingType in ("REPORTED", "RECONCILED")
                         else max(o.tokensUsed, o.tokenReservation) for o in children)
            wall = sum(o.wallTimeUsedSeconds if o.status == "COMPLETED" else o.wallTimeReservationSeconds for o in children)
            if tokens + req.tokenReservation > parent.tokenReservation:
                raise CheckpointApiError(422, "Parent token reservation exceeded")
            if wall + req.wallTimeReservationSeconds > parent.wallTimeReservationSeconds:
                raise CheckpointApiError(422, "Parent wall reservation exceeded")
        ack = super().grant_operation(req)
        if not ack.isReplay:
            self.operations[req.operationId] = self.operations[req.operationId].model_copy(update={
                "parentOperationId": req.parentOperationId, "sectionId": req.sectionId})
        return ack

    def reconcile_operation(self, req):
        ack = super().reconcile_operation(req)
        self.operations[req.operationId] = self.operations[req.operationId].model_copy(update={"accountingType": req.accountingType.upper()})
        return ack


class HistoricalProvider(RecordingHybridIntegrationProvider):
    def conservative_token_reservation(self, req):
        return 7369 if req.operation_id.endswith("solve") else 7504

    async def call(self, req, api_key, deadline):
        self.dispatched_requests.append(req)
        self.last_deadline = deadline
        used = 1923 if req.operation_id.endswith("solve") else 2259
        return ProviderResponse(operation_id=req.operation_id, provider_name=self.name, model_name="MiniMax-Text-01",
            raw_text="{}", parsed_payload={}, usage=UsageReport(total_tokens=used, prompt_tokens=used-100, completion_tokens=100, accounting_type="reported"),
            latency_seconds=5)


def setup_parent(tokens=10000):
    owner = uuid4()
    ledger = ParentLedger("run_parent_10k", 1, owner)
    ledger.grant_operation(OperationGrantRequest(runId=ledger.run_id, epoch=1, leaseOwner=owner,
        operationId="evaluate", operationType="EVALUATE", requestHash="a"*64, tokenReservation=tokens,
        wallTimeReservationSeconds=60, sectionId="1", artifactId=f"question:{ledger.run_id}:5"))
    provider = HistoricalProvider()
    registry = ProviderRegistry()
    registry.register_provider(provider, keys=["offline-only"])
    gateway = ProviderGateway(registry=registry, checkpoint_client=ledger)
    def request(suffix):
        return ProviderRequest(operation_id=f"evaluate:{suffix}", run_id=ledger.run_id, section_id="1",
            artifact_id=f"question:{ledger.run_id}:5", parent_operation_id="evaluate", capability=Capability.SOLVE_ITEM,
            messages=[ChatMessage(role="user", content="Blind question, no key")], preferred_provider="minimax",
            timeout_seconds=60, wall_time_reservation_seconds=60)
    return ledger, provider, gateway, request


@pytest.mark.asyncio
async def test_10k_parent_admits_sequential_historical_solver_and_adversary_with_refund():
    ledger, provider, gateway, request = setup_parent()
    await gateway.execute(request("solve"), lease_owner=ledger.active_lease_owner)
    assert ledger.operations["evaluate:solve"].tokensUsed == 1923
    assert ledger.operations["evaluate:solve"].tokenReservation == 7369
    before = time.time()
    await gateway.execute(request("adv"), lease_owner=ledger.active_lease_owner)
    child = next(g for g in ledger.grants if g.operationId == "evaluate:adv")
    assert 0 < child.wallTimeReservationSeconds <= 55
    assert provider.last_deadline <= before + 55.1
    assert sum(o.tokensUsed for o in ledger.operations.values()) == 4182
    assert len(provider.dispatched_requests) == 2
    # Replay must reuse the persisted response without another physical transport.
    await gateway.execute(request("adv"), lease_owner=ledger.active_lease_owner)
    assert len(provider.dispatched_requests) == 2


@pytest.mark.asyncio
async def test_4k_parent_rejects_7369_before_transport_without_cap_expansion():
    ledger, provider, gateway, request = setup_parent(4000)
    with pytest.raises(BudgetExhaustedError):
        await gateway.execute(request("solve"), lease_owner=ledger.active_lease_owner)
    assert provider.dispatched_requests == []
    assert ledger.operations["evaluate"].tokenReservation == 4000


@pytest.mark.asyncio
@pytest.mark.parametrize("accounting", ["ESTIMATED", "UNKNOWN"])
async def test_uncertain_usage_does_not_refund_tokens_for_second_child(accounting):
    ledger, provider, gateway, request = setup_parent()
    await gateway.execute(request("solve"), lease_owner=ledger.active_lease_owner)
    ledger.operations["evaluate:solve"] = ledger.operations["evaluate:solve"].model_copy(update={"accountingType": accounting})
    with pytest.raises(BudgetExhaustedError):
        await gateway.execute(request("adv"), lease_owner=ledger.active_lease_owner)
    assert len(provider.dispatched_requests) == 1


@pytest.mark.asyncio
async def test_transport_deadline_never_exceeds_its_granted_wall():
    ledger, provider, gateway, request = setup_parent()
    before = time.time()
    await gateway.execute(request("solve").model_copy(update={"wall_time_reservation_seconds": 2}), lease_owner=ledger.active_lease_owner)
    assert provider.last_deadline <= before + 2.1


@pytest.mark.asyncio
async def test_child_transport_timeout_keeps_unknown_reservation_and_never_redispatches():
    ledger, provider, gateway, request = setup_parent()
    async def lose_response(req, api_key, deadline):
        provider.dispatched_requests.append(req)
        await asyncio.sleep(1)
    provider.call = lose_response
    timed_request = request("solve").model_copy(update={"timeout_seconds": 0.01})
    with pytest.raises(ProviderError):
        await gateway.execute(timed_request, lease_owner=ledger.active_lease_owner)
    assert ledger.operations["evaluate:solve"].status == "UNKNOWN_OUTCOME"
    assert ledger.operations["evaluate:solve"].tokenReservation == 7369
    with pytest.raises(ProviderError, match="reconciliation"):
        await gateway.execute(timed_request, lease_owner=ledger.active_lease_owner)
    with pytest.raises(BudgetExhaustedError):
        await gateway.execute(request("adv"), lease_owner=ledger.active_lease_owner)
    assert len(provider.dispatched_requests) == 1
    assert ledger.operations["evaluate"].status == "RESERVED"


@pytest.mark.asyncio
async def test_known_format_failure_can_retry_inside_short_granted_wall_without_resetting_clock():
    from app.providers.errors import InvalidJsonError
    from app.providers.retry import RetryPolicy
    ledger, provider, gateway, request = setup_parent()
    original_call = provider.call
    attempts = []
    async def known_format_error_then_success(req, api_key, deadline):
        attempts.append(req.operation_id)
        if len(attempts) == 1:
            raise InvalidJsonError("Known invalid JSON response", usage=UsageReport(total_tokens=1000, accounting_type="reported"))
        response = await original_call(req, api_key, deadline)
        return response.model_copy(update={"latency_seconds": 0.01})
    provider.call = known_format_error_then_success
    before = time.time()
    await gateway.execute(request("solve").model_copy(update={"wall_time_reservation_seconds": 2}),
        lease_owner=ledger.active_lease_owner, retry_policy=RetryPolicy(max_attempts=2, base_delay_seconds=0, max_delay_seconds=0))
    assert attempts == ["evaluate:solve", "evaluate:solve:attempt:2"]
    assert provider.last_deadline <= before + 2.1
    assert all(ledger.operations[oid].status == "COMPLETED" for oid in attempts)


def test_reconstruction_counts_physical_descendants_once_including_shared_summary_owner():
    from app.loop.runtime import BoundedLoopRuntime
    from app.loop.context import LoopContext, AuthorityGrant
    from app.loop.policy import LoopPolicy
    from app.contracts.artifact import ArtifactType
    from app.contracts.issue import IssueScope
    from app.persistence.models import OperationResumeInfo
    ledger, _, _, _ = setup_parent()
    artifact_id = f"question:{ledger.run_id}:5"
    for operation_id, artifact in [("summary", "summary_group:run_parent_10k:0"), ("solver", artifact_id)]:
        ledger.operations[operation_id] = OperationResumeInfo(operationId=operation_id, operationType="PROVIDER_CALL",
            parentOperationId="evaluate", artifactId=artifact, requestHash=operation_id,
            status="COMPLETED", tokenReservation=7500, tokensUsed=2000, accountingType="REPORTED",
            wallTimeReservationSeconds=20, wallTimeUsedSeconds=5)
    ledger.operations["evaluate"] = ledger.operations["evaluate"].model_copy(update={"status": "COMPLETED", "tokensUsed": 0, "accountingType": "REPORTED"})
    context = LoopContext(runId=ledger.run_id, targetArtifactId=artifact_id, targetArtifactType=ArtifactType.QUESTION,
        scope=IssueScope.QUESTION, authority=AuthorityGrant(leaseOwner=ledger.active_lease_owner, epoch=1))
    context.budget_tracker.calls_used = 7  # stale wrapper count is not transport count
    runtime = BoundedLoopRuntime(context=context, policy=LoopPolicy(), generator=None, evaluators=[], persistence_client=ledger)
    runtime._refresh_provider_token_accounting()
    assert context.budget_tracker.calls_used == 2
    assert context.budget_tracker.tokens_used == 4000
    assert context.budget_tracker.wall_time_used_seconds == 10
    runtime._refresh_provider_token_accounting()
    assert context.budget_tracker.calls_used == 2
