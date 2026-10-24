from __future__ import annotations

import json
from unittest.mock import AsyncMock, MagicMock
from uuid import uuid4
import pytest

from app.persistence.models import OperationGrantRequest, OperationReconcileRequest
from app.providers.adapters.minimax import MiniMaxProvider
from app.providers.adapters.openai_compatible import OpenAICompatibleProvider
from app.providers.base import BaseProvider
from app.providers.errors import TruncatedOutputError
from app.providers.gateway import ProviderGateway, RetryPolicy
from app.providers.models import (
    Capability,
    ChatMessage,
    FinishReason,
    ProviderRequest,
    ProviderResponse,
    UsageAccountingType,
    UsageReport,
)
from app.providers.registry import ProviderRegistry
from tests.test_t03_providers import MockCheckpointClient


class MockOpenAITransportProvider(OpenAICompatibleProvider):
    def __init__(self, name: str = "minimax", models: dict | None = None):
        super().__init__(
            name=name,
            base_url="https://api.test",
            models=models or {"large": "MiniMax-Text-01", "medium": "MiniMax-Text-01", "small": "MiniMax-Text-01"},
            supports_response_format=False,
        )
        self.dispatched_kwargs = []
        self.fault_to_raise = None

    async def check_health(self, api_key: str | None = None) -> bool:
        return True

    async def call(self, request: ProviderRequest, api_key: str, deadline: float) -> ProviderResponse:
        model_name = request.pinned_model or self.get_model_name(request.model_size)
        kwargs = self._build_create_kwargs(request, model_name)
        self.dispatched_kwargs.append({"model_name": model_name, "kwargs": kwargs})

        if self.fault_to_raise:
            raise self.fault_to_raise

        return ProviderResponse(
            operation_id=request.operation_id,
            provider_name=self.name,
            model_name=model_name,
            raw_text='{"result": "ok"}',
            parsed_payload={"result": "ok"},
            finish_reason=FinishReason.STOP,
            usage=UsageReport(
                prompt_tokens=150,
                completion_tokens=50,
                total_tokens=200,
                reasoning_tokens=30,
                accounting_type=UsageAccountingType.REPORTED,
            ),
        )


@pytest.mark.asyncio
async def test_pinned_model_overrides_default_model_in_call_and_hash():
    """Ensure pinned_model dispatches exact model to transport and differentiates attempt hash."""
    registry = ProviderRegistry()
    provider = MockOpenAITransportProvider(name="minimax")
    registry.register_provider(provider, keys=["key_1"])

    client = MockCheckpointClient()
    gateway = ProviderGateway(
        registry=registry,
        retry_policy=RetryPolicy(max_attempts=1),
        checkpoint_client=client,
    )

    req_default = ProviderRequest(
        capability=Capability.GENERATE_JSON,
        messages=[ChatMessage(role="user", content="Hello")],
        operation_id="op_default_model",
        run_id="run_test",
        section_id="section_1",
        artifact_id="questions_section_1",
        preferred_provider="minimax",
        timeout_seconds=5.0,
    )

    resp_default = await gateway.execute(req_default, epoch=1, lease_owner=uuid4())
    assert resp_default.model_name == "MiniMax-Text-01"
    assert provider.dispatched_kwargs[-1]["model_name"] == "MiniMax-Text-01"

    req_pinned = ProviderRequest(
        capability=Capability.PLAN_REPAIR,
        messages=[ChatMessage(role="user", content="Plan repair")],
        operation_id="op_pinned_model",
        run_id="run_test",
        section_id="section_1",
        artifact_id="questions_section_1",
        preferred_provider="minimax",
        pinned_model="MiniMax-M3",
        timeout_seconds=5.0,
    )

    resp_pinned = await gateway.execute(req_pinned, epoch=1, lease_owner=uuid4())
    assert resp_pinned.model_name == "MiniMax-M3"
    assert provider.dispatched_kwargs[-1]["model_name"] == "MiniMax-M3"

    # Compare grant request hashes from client operations
    assert "op_default_model" in client.operations
    assert "op_pinned_model" in client.operations
    hash_default = client.operations["op_default_model"]["requestHash"]
    hash_pinned = client.operations["op_pinned_model"]["requestHash"]
    assert hash_default != hash_pinned


@pytest.mark.asyncio
async def test_truncation_preserves_reported_and_reasoning_tokens():
    """When a provider cuts off output (finish_reason=length), reported reasoning tokens are reconciled."""
    registry = ProviderRegistry()
    provider = MockOpenAITransportProvider(name="minimax")
    registry.register_provider(provider, keys=["key_1"])

    trunc_error = TruncatedOutputError(
        "Provider cut off output (finish_reason=length)",
        raw_text='{"partial": true',
        provider_name="minimax",
        operation_id="op_trunc",
    )
    trunc_error.usage = UsageReport(
        prompt_tokens=250,
        completion_tokens=100,
        total_tokens=350,
        reasoning_tokens=85,
        accounting_type=UsageAccountingType.REPORTED,
    )
    provider.fault_to_raise = trunc_error

    client = MockCheckpointClient()
    gateway = ProviderGateway(
        registry=registry,
        retry_policy=RetryPolicy(max_attempts=1),
        checkpoint_client=client,
    )

    req = ProviderRequest(
        capability=Capability.PLAN_REPAIR,
        messages=[ChatMessage(role="user", content="Diagnose failure")],
        operation_id="op_trunc",
        run_id="run_test",
        section_id="section_1",
        artifact_id="questions_section_1",
        preferred_provider="minimax",
        pinned_model="MiniMax-M3",
        timeout_seconds=5.0,
    )

    with pytest.raises(TruncatedOutputError):
        await gateway.execute(req, epoch=1, lease_owner=uuid4())

    assert len(client.reconciliations) >= 1
    rec = client.reconciliations[-1]
    assert rec.operationId == "op_trunc"
    assert rec.tokensUsed == 350
    assert rec.promptTokensUsed == 250
    assert rec.completionTokensUsed == 100
    assert rec.reasoningTokensUsed == 85
    assert rec.accountingType == UsageAccountingType.REPORTED.value


def test_minimax_adapter_respects_request_max_tokens_for_m3():
    """MiniMaxProvider must respect explicit request.max_tokens without forcing 8192 for small repair tasks."""
    provider = MiniMaxProvider()
    req = ProviderRequest(
        capability=Capability.PLAN_REPAIR,
        messages=[ChatMessage(role="user", content="Test")],
        operation_id="op_tokens",
        run_id="run_test",
        section_id="section_1",
        artifact_id="questions_section_1",
        pinned_model="MiniMax-M3",
        max_tokens=2048,
        timeout_seconds=5.0,
    )
    limit = provider.completion_token_limit(req)
    assert limit == 2048, f"Expected 2048, got {limit}"
    reservation = provider.conservative_token_reservation(req)
    assert reservation < 3000, f"Reservation {reservation} unexpectedly large for 2048 max_tokens"


def test_capability_plan_repair_exists():
    assert Capability.PLAN_REPAIR == "plan_repair"
