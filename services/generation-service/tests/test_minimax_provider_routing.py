"""Tests verifying strict MiniMax-only provider routing and zero Groq fallback.

Ensures:
1. Groq dispatch is impossible for MiniMax-only generation requests.
2. Transport allowlist strictly enforced at ProviderGateway boundary.
3. MiniMax key exhaustion or errors fail closed without rotating to Groq.
4. Selecting MiniMax never enables unlimited budgets.
"""
import time
from uuid import uuid4
import pytest

from app.providers.base import BaseProvider
from app.providers.errors import (
    DeadlineExceededError,
    ProviderError,
    ProviderUnavailableError,
    RateLimitedError,
)
from app.providers.gateway import ProviderGateway, RetryPolicy
from app.providers.models import (
    Capability,
    ChatMessage,
    FinishReason,
    ProviderRequest,
    ProviderResponse,
    UsageReport,
)
from app.providers.registry import ProviderRegistry
from tests.test_t03_providers import MockCheckpointClient


class RecordingTransportProvider(BaseProvider):
    def __init__(self, name: str):
        super().__init__(name=name, base_url=f"https://{name}.api", models={"large": f"{name}-model"})
        self.recorded_calls = []
        self._faults = []
    async def check_health(self, api_key: str | None = None) -> bool:
        return True


    def enqueue_fault(self, exc: Exception):
        self._faults.append(exc)

    def conservative_token_reservation(self, request: ProviderRequest) -> int:
        return 1000

    async def call(self, request: ProviderRequest, api_key: str, deadline: float) -> ProviderResponse:
        self.recorded_calls.append({"operation_id": request.operation_id, "api_key": api_key})
        if self._faults:
            fault = self._faults.pop(0)
            raise fault
        return ProviderResponse(
            operation_id=request.operation_id,
            provider_name=self.name,
            model_name=self.models["large"],
            raw_text='{"status": "ok", "questions": []}',
            parsed_payload={"status": "ok", "questions": []},
            finish_reason=FinishReason.STOP,
            usage=UsageReport(prompt_tokens=100, completion_tokens=50, total_tokens=150),
        )


@pytest.mark.asyncio
async def test_minimax_only_request_blocks_groq_when_minimax_fails_429():
    """Prove that when MiniMax fails with HTTP 429, Groq is NEVER dispatched."""
    registry = ProviderRegistry()
    minimax_prov = RecordingTransportProvider(name="minimax")
    groq_prov = RecordingTransportProvider(name="groq")

    # Enqueue 429 errors on MiniMax
    minimax_prov.enqueue_fault(RateLimitedError("MiniMax 429", retry_after_seconds=60.0))

    registry.register_provider(minimax_prov, keys=["mm_key_1"])
    registry.register_provider(groq_prov, keys=["groq_key_1"])

    client = MockCheckpointClient()
    gateway = ProviderGateway(
        registry=registry,
        retry_policy=RetryPolicy(max_attempts=2, base_delay_seconds=0.01),
        checkpoint_client=client,
    )

    req = ProviderRequest(
        capability=Capability.GENERATE_JSON,
        messages=[ChatMessage(role="user", content="Generate IELTS Reading Questions")],
        operation_id="op_minimax_429_test",
        run_id="run_minimax_test",
        preferred_provider="minimax",
        allowed_providers=["minimax"],
        allow_fallback=False,
        timeout_seconds=5.0,
    )

    with pytest.raises((RateLimitedError, ProviderUnavailableError, DeadlineExceededError)):
        await gateway.execute(req, epoch=1, lease_owner=uuid4())

    # MiniMax was attempted
    assert len(minimax_prov.recorded_calls) >= 1
    # Groq MUST NEVER be called
    assert len(groq_prov.recorded_calls) == 0, "Groq was dispatched despite MiniMax-only allowlist!"


@pytest.mark.asyncio
async def test_minimax_only_request_blocks_groq_when_minimax_key_exhausted():
    """Prove that when MiniMax keys are exhausted, ProviderUnavailableError is raised without Groq dispatch."""
    registry = ProviderRegistry()
    minimax_prov = RecordingTransportProvider(name="minimax")
    groq_prov = RecordingTransportProvider(name="groq")

    # Register MiniMax with NO keys (or exhausted)
    registry.register_provider(minimax_prov, keys=[])
    registry.register_provider(groq_prov, keys=["groq_key_1"])

    client = MockCheckpointClient()
    gateway = ProviderGateway(
        registry=registry,
        retry_policy=RetryPolicy(max_attempts=2),
        checkpoint_client=client,
    )

    req = ProviderRequest(
        capability=Capability.GENERATE_JSON,
        messages=[ChatMessage(role="user", content="Generate Questions")],
        operation_id="op_minimax_exhausted_test",
        run_id="run_exhausted_test",
        preferred_provider="minimax",
        allowed_providers=["minimax"],
        allow_fallback=False,
        timeout_seconds=5.0,
    )

    with pytest.raises(ProviderUnavailableError) as exc_info:
        await gateway.execute(req, epoch=1, lease_owner=uuid4())

    assert "matching allowlist" in str(exc_info.value) or "exhausted" in str(exc_info.value)
    # Groq must not have received any call
    assert len(groq_prov.recorded_calls) == 0


@pytest.mark.asyncio
async def test_minimax_only_request_blocks_groq_without_replaying_ambiguous_503():
    """An ambiguous MiniMax 503 is reserved once and never falls back to Groq."""
    registry = ProviderRegistry()
    minimax_prov = RecordingTransportProvider(name="minimax")
    groq_prov = RecordingTransportProvider(name="groq")

    minimax_prov.enqueue_fault(ProviderUnavailableError("MiniMax 503"))
    minimax_prov.enqueue_fault(ProviderUnavailableError("MiniMax 503"))

    registry.register_provider(minimax_prov, keys=["mm_key_1"])
    registry.register_provider(groq_prov, keys=["groq_key_1"])

    client = MockCheckpointClient()
    gateway = ProviderGateway(
        registry=registry,
        retry_policy=RetryPolicy(max_attempts=2, base_delay_seconds=0.01),
        checkpoint_client=client,
    )

    req = ProviderRequest(
        capability=Capability.GENERATE_JSON,
        messages=[ChatMessage(role="user", content="Generate Questions")],
        operation_id="op_minimax_503_test",
        run_id="run_503_test",
        preferred_provider="minimax",
        allowed_providers=["minimax"],
        allow_fallback=False,
        timeout_seconds=5.0,
    )

    with pytest.raises((ProviderUnavailableError, ProviderError)):
        await gateway.execute(req, epoch=1, lease_owner=uuid4())

    # A 503 may follow provider-side work, so its reservation remains unresolved
    # and the request must not be replayed under a fresh physical-attempt ID.
    assert len(minimax_prov.recorded_calls) == 1
    assert len(client.unknown_outcomes) == 1
    assert client.operations[req.operation_id]["status"] == "UNKNOWN_OUTCOME"
    # Groq MUST NOT be called.
    assert len(groq_prov.recorded_calls) == 0


@pytest.mark.asyncio
async def test_implicit_minimax_preferred_enforces_allowlist_without_groq_fallback():
    """Requests with preferred_provider='minimax' and allow_fallback=False automatically enforce MiniMax allowlist."""
    registry = ProviderRegistry()
    minimax_prov = RecordingTransportProvider(name="minimax")
    groq_prov = RecordingTransportProvider(name="groq")

    minimax_prov.enqueue_fault(ProviderUnavailableError("MiniMax 500"))

    registry.register_provider(minimax_prov, keys=["mm_key_1"])
    registry.register_provider(groq_prov, keys=["groq_key_1"])

    client = MockCheckpointClient()
    gateway = ProviderGateway(
        registry=registry,
        retry_policy=RetryPolicy(max_attempts=1),
        checkpoint_client=client,
    )

    req = ProviderRequest(
        capability=Capability.GENERATE_JSON,
        messages=[ChatMessage(role="user", content="Generate Questions")],
        operation_id="op_implicit_mm_test",
        run_id="run_implicit_test",
        preferred_provider="minimax",
        allow_fallback=False,
        timeout_seconds=5.0,
    )

    with pytest.raises(ProviderUnavailableError):
        await gateway.execute(req, epoch=1, lease_owner=uuid4())

    assert len(minimax_prov.recorded_calls) == 1
    assert len(groq_prov.recorded_calls) == 0


@pytest.mark.asyncio
async def test_selecting_minimax_never_enables_unlimited_budget():
    """Selecting MiniMax must never enable unlimited budget; finite wall time and timeouts are strictly enforced."""
    registry = ProviderRegistry()
    minimax_prov = RecordingTransportProvider(name="minimax")
    registry.register_provider(minimax_prov, keys=["mm_key_1"])

    client = MockCheckpointClient()
    gateway = ProviderGateway(
        registry=registry,
        retry_policy=RetryPolicy(max_attempts=1),
        checkpoint_client=client,
    )

    # A finite positive wall reservation is mandatory even for a preferred provider.
    req = ProviderRequest(
        capability=Capability.GENERATE_JSON,
        messages=[ChatMessage(role="user", content="Generate Questions")],
        operation_id="op_budget_cap_test",
        run_id="run_budget_cap_test",
        preferred_provider="minimax",
        allowed_providers=["minimax"],
        wall_time_reservation_seconds=10.0,
        timeout_seconds=10.0,
    )

    resp = await gateway.execute(req, epoch=1, lease_owner=uuid4())
    assert resp.provider_name == "minimax"
    # Verify the durable attempt remained bounded by the finite caller reservation.
    assert len(minimax_prov.recorded_calls) == 1
    attempt = client.operations["op_budget_cap_test"]
    assert 0 < attempt["wallTimeReservation"] <= req.wall_time_reservation_seconds
