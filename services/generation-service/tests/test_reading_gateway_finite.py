"""No-network behavioral coverage of the real finite ProviderGateway."""
import asyncio
import time
from datetime import datetime, timezone
from types import SimpleNamespace
from uuid import uuid4

import pytest
from pydantic import ValidationError

from app.persistence.models import OperationGrantRequest
from app.providers.base import BaseProvider
from app.providers.errors import DeadlineExceededError, ProviderError, ProviderUnavailableError, RateLimitedError
from app.providers.gateway import ProviderGateway
from app.providers.models import Capability, ChatMessage, ProviderRequest, ProviderResponse, UsageReport, UsageAccountingType
from app.providers.registry import ProviderRegistry
from app.providers.retry import RetryPolicy


class Authority:
    def __init__(self):
        self.operations = {}
        self.grants = []
        self.reconciles = []
        self.unknown = []

    async def grant_operation_async(self, request):
        self.grants.append(request)
        prior = self.operations.get(request.operationId)
        if prior:
            return SimpleNamespace(**prior, isReplay=True)
        row = dict(status="RESERVED", resultRefJson=None, reservationBreached=False, budgetBreachDetected=False,
                   parentOperationId=request.parentOperationId,
                   wallTimeReservationSeconds=request.wallTimeReservationSeconds, wallTimeUsedSeconds=0.0)
        self.operations[request.operationId] = row
        return SimpleNamespace(**row, isReplay=False)

    async def reconcile_operation_async(self, request):
        self.reconciles.append(request)
        self.operations[request.operationId].update(status="COMPLETED", resultRefJson=request.resultRefJson,
            wallTimeUsedSeconds=request.wallTimeUsedSeconds)
        return SimpleNamespace(reservationBreached=False, budgetBreachDetected=False)

    async def record_unknown_outcome_async(self, request):
        self.unknown.append(request)
        self.operations[request.operationId] = dict(status="UNKNOWN_OUTCOME", resultRefJson=None,
            reservationBreached=False, budgetBreachDetected=False)

    async def resume_state_async(self, run_id):
        return SimpleNamespace(operations=[SimpleNamespace(operationId=key, **value)
                                          for key, value in self.operations.items()])


class Transport(BaseProvider):
    def __init__(self, name="mock", outcomes=()):
        super().__init__(name, "https://not-called.test", {"large": "fixture"})
        self.outcomes = list(outcomes)
        self.calls = []

    async def call(self, request, api_key, deadline):
        self.calls.append((request, deadline))
        if self.outcomes:
            outcome = self.outcomes.pop(0)
            if isinstance(outcome, BaseException):
                raise outcome
            await asyncio.sleep(outcome)
        return ProviderResponse(operation_id=request.operation_id, provider_name=self.name, model_name="fixture",
            raw_text='{"ok":true}', usage=UsageReport(total_tokens=7, prompt_tokens=3, completion_tokens=4,
            accounting_type=UsageAccountingType.REPORTED))

    async def check_health(self, api_key=None):
        return True


def setup(outcomes=(), attempts=3):
    provider = Transport(outcomes=outcomes)
    registry = ProviderRegistry()
    registry.register_provider(provider, keys=["fixture-key-not-live"])
    authority = Authority()
    gateway = ProviderGateway(registry, RetryPolicy(max_attempts=attempts, base_delay_seconds=0, max_delay_seconds=0), authority)
    return gateway, provider, authority, registry


def request(**changes):
    values = dict(capability=Capability.GENERATE_TEXT, messages=[ChatMessage(role="user", content="fixture")],
                  operation_id="operation", run_id="run", pinned_provider="mock", timeout_seconds=1,
                  wall_time_reservation_seconds=1)
    return ProviderRequest(**{**values, **changes})


@pytest.mark.asyncio
async def test_completed_replay_has_no_dispatch_or_reconciliation_charge():
    gateway, provider, authority, _ = setup()
    owner = uuid4()
    # A parent reference must identify a granted operation, never an invented ID.
    await authority.grant_operation_async(OperationGrantRequest(runId="run", epoch=1, leaseOwner=owner,
        operationId="parent", operationType="GENERATE", requestHash="a" * 64,
        tokenReservation=10000, wallTimeReservationSeconds=1))
    first = await gateway.execute(request(parent_operation_id="parent"), lease_owner=owner)
    second = await gateway.execute(request(parent_operation_id="parent"), lease_owner=owner)
    assert first == second
    assert len(provider.calls) == len(authority.reconciles) == 1
    assert authority.grants[1].parentOperationId == "parent"
    assert authority.grants[1].tokenReservation > authority.reconciles[0].tokensUsed == 7
    assert all(item.operationId != "parent" for item in authority.reconciles)


@pytest.mark.parametrize("status", ["RESERVED", "UNKNOWN_OUTCOME"])
@pytest.mark.asyncio
async def test_ambiguous_replay_never_advances_to_a_new_attempt(status):
    gateway, provider, authority, _ = setup()
    authority.operations["operation"] = dict(status=status, resultRefJson=None,
        reservationBreached=False, budgetBreachDetected=False)
    with pytest.raises(ProviderError, match="reconcil"):
        await gateway.execute(request(), lease_owner=uuid4())
    assert not provider.calls
    assert [item.operationId for item in authority.grants] == ["operation"]
    assert not authority.reconciles


@pytest.mark.asyncio
async def test_timeout_marks_unknown_and_does_not_retry():
    gateway, provider, authority, _ = setup(outcomes=(0.2,))
    with pytest.raises(ProviderError):
        await gateway.execute(request(timeout_seconds=0.02), lease_owner=uuid4())
    assert len(provider.calls) == len(authority.unknown) == 1
    assert not authority.reconciles
    assert len(authority.grants) == 1


@pytest.mark.asyncio
async def test_unknown_transport_failure_does_not_retry_or_switch_provider():
    gateway, provider, authority, registry = setup(outcomes=(ProviderUnavailableError("lost response"),))
    alternate = Transport("alternate")
    registry.register_provider(alternate, keys=["fixture-alternate"])
    with pytest.raises(ProviderError):
        await gateway.execute(request(), lease_owner=uuid4())
    assert len(provider.calls) == 1
    assert not alternate.calls
    assert len(authority.unknown) == 1


@pytest.mark.parametrize("waiting_for", ["limiter", "semaphore"])
@pytest.mark.asyncio
async def test_queue_wait_is_inside_the_finite_deadline(waiting_for):
    gateway, provider, authority, registry = setup()
    if waiting_for == "limiter":
        class NeverReady:
            async def acquire(self):
                await asyncio.sleep(10)
        registry._rate_limiters["mock"] = NeverReady()
    else:
        registry._semaphores["mock"] = asyncio.Semaphore(0)
    started = time.monotonic()
    with pytest.raises(DeadlineExceededError):
        await gateway.execute(request(timeout_seconds=0.02), lease_owner=uuid4())
    assert time.monotonic() - started < 0.5
    assert not provider.calls
    assert authority.reconciles[0].tokensUsed == 0


@pytest.mark.asyncio
async def test_ancestor_deadline_and_token_remaining_are_enforced():
    gateway, provider, authority, _ = setup()
    with pytest.raises(ProviderError):
        await gateway.execute(request(remaining_tokens=1), lease_owner=uuid4())
    assert not authority.grants and not provider.calls
    with pytest.raises(DeadlineExceededError):
        await gateway.execute(request(deadline_unix_seconds=time.time() - 1), lease_owner=uuid4())
    assert not provider.calls


@pytest.mark.asyncio
async def test_rate_limit_is_reconciled_before_bounded_same_provider_retry():
    gateway, provider, authority, _ = setup(outcomes=(RateLimitedError("quota", retry_after_seconds=0.001),))
    await gateway.execute(request(), lease_owner=uuid4())
    assert len(provider.calls) == 2
    assert [item.tokensUsed for item in authority.reconciles] == [0, 7]
    assert [item.operationId for item in authority.grants] == ["operation", "operation:attempt:2"]
    assert not authority.unknown


@pytest.mark.asyncio
async def test_legacy_research_grammar_flags_are_finite_and_provider_agnostic():
    gateway, provider, _, _ = setup()
    await gateway.execute(request(pinned_provider=None, preferred_provider="mock", allowed_providers=["mock"],
                                  allow_fallback=False, allow_repair=False), lease_owner=uuid4())
    assert len(provider.calls) == 1
    assert 0 < provider.calls[0][1] - time.time() <= 1


@pytest.mark.parametrize("change", [{"is_unlimited": True}, {"timeout_seconds": float("inf")},
    {"timeout_seconds": 181}, {"wall_time_reservation_seconds": 0}, {"allow_fallback": True}])
def test_request_cannot_express_unlimited_or_alternate_engine(change):
    with pytest.raises(ValidationError):
        request(**change)
