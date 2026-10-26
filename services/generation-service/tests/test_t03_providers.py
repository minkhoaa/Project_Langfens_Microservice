"""Phase 03 tests for Provider Layer and Shared Budget Enforcement.

Covers T03-01 through T03-07 deterministic fake transport/recordings,
and T03-08 live smoke test check with credentials or explicit NOT_RUN_EXTERNAL.
"""
import asyncio
import hashlib
import os
import time
from typing import Any, Dict, List, Optional
from uuid import UUID, uuid4
import httpx
import pytest
from pydantic import BaseModel, Field
from app.config import settings

from app.persistence.client import CheckpointApiError, CheckpointClient
from app.persistence.models import (
    BudgetAllocationItem,
    OperationGrantRequest,
    OperationGrantResult,
    OperationReconcileRequest,
    OperationReconcileResult,
    OperationResumeInfo,
    ResumeStateResult,
    SetBudgetAllocationsRequest,
    SetBudgetAllocationsResult,
    UnknownOutcomeAck,
    UnknownOutcomeRequest,
)
from app.providers.adapters.groq import GroqProvider
from app.providers.adapters.minimax import MiniMaxProvider
from app.providers.adapters.openai_compatible import OpenAICompatibleProvider
from app.providers.adapters.recording import FakeTransportProvider
from app.providers.base import redact_secrets
from app.providers.errors import (
    BudgetExhaustedError,
    CancelledError,
    DeadlineExceededError,
    InvalidJsonError,
    ProviderError,
    ProviderUnavailableError,
    RateLimitedError,
    SchemaMismatchError,
    TimeoutError as ProviderTimeoutError,
    TruncatedOutputError,
    UnauthorizedError,
)
from app.providers.gateway import ProviderGateway
from app.providers.models import (
    Capability,
    ChatMessage,
    FinishReason,
    ProviderRequest,
    ProviderResponse,
    UsageAccountingType,
    UsageReport,
)
from app.providers.parser import (
    StreamingReasoningSanitizer,
    clean_reasoning_tags,
    parse_defensive_json,
)
from app.providers.registry import ProviderRegistry
from app.providers.retry import RetryPolicy


class MockCheckpointClient(CheckpointClient):
    """In-memory mock checkpoint client adhering to persistence and reservation contracts."""

    def __init__(self, run_tokens_cap: int = 150_000, run_calls_cap: int = 25, run_wall_time_cap: int = 900):
        self.run_tokens_cap = run_tokens_cap
        self.run_calls_cap = run_calls_cap
        self.run_wall_time_cap = run_wall_time_cap
        self.run_used_tokens = 0
        self.run_used_calls = 0
        self.run_used_wall_time = 0.0

        self.operations: Dict[str, Dict[str, Any]] = {}
        self.allocations: Dict[str, BudgetAllocationItem] = {}
        self.unknown_outcomes: List[UnknownOutcomeRequest] = []
        self.reconciliations: List[OperationReconcileRequest] = []
        self._lock = asyncio.Lock()

        # Seed standard section allocations
        for sec in ("section_1", "section_2", "section_3"):
            self.allocations[sec] = BudgetAllocationItem(
                scopeType="SECTION", scopeId=sec, parentScopeId=None, tokenCap=45000, callCap=8, wallTimeCapSeconds=280
            )
            self.allocations[f"passage_{sec}"] = BudgetAllocationItem(
                scopeType="ARTIFACT", scopeId=f"passage_{sec}", parentScopeId=sec, tokenCap=15000, callCap=2, wallTimeCapSeconds=90
            )
            self.allocations[f"questions_{sec}"] = BudgetAllocationItem(
                scopeType="ARTIFACT", scopeId=f"questions_{sec}", parentScopeId=sec, tokenCap=18000, callCap=3, wallTimeCapSeconds=100
            )

    async def resume_state_async(self, run_id: str) -> ResumeStateResult:
        operations = [
            OperationResumeInfo(
                operationId=op["operationId"], operationType=op.get("operationType", "PROVIDER_CALL"),
                status=op["status"], artifactId=op.get("artifactId"), sectionId=op.get("sectionId"),
                requestHash=op["requestHash"], tokenReservation=op["tokenReservation"],
                tokensUsed=op["tokensUsed"],
                wallTimeReservationSeconds=op["wallTimeReservation"],
                wallTimeUsedSeconds=op["wallTimeUsed"],
                resultRefJson=op.get("resultRefJson"), parentOperationId=op.get("parentOperationId"),
            )
            for op in self.operations.values()
            if op.get("runId", run_id) == run_id
        ]
        return ResumeStateResult(
            runId=run_id, jobId=uuid4(), epoch=1, status="RUNNING",
            engineVersion="mock", schemaVersion="1.0.0", policyVersion="v1",
            operations=operations,
        )

    async def grant_operation_async(self, request: OperationGrantRequest) -> OperationGrantResult:
        async with self._lock:
            # Check idempotency
            if request.operationId in self.operations:
                existing = self.operations[request.operationId]
                if existing["requestHash"].lower() != request.requestHash.lower():
                    raise CheckpointApiError(409, "Request hash mismatch")
                return OperationGrantResult(
                    operationId=request.operationId,
                    runId=request.runId,
                    status=existing["status"],
                    tokenReservation=existing["tokenReservation"],
                    grantedAt=existing["createdAt"],
                    isReplay=True,
                )

            # Check if covered by parent operation reservation
            has_parent = False
            if request.parentOperationId and request.parentOperationId in self.operations:
                has_parent = True

            if not has_parent:
                if self.run_used_calls + 1 > self.run_calls_cap:
                    raise CheckpointApiError(422, "Budget cap exceeded: calls")
                if self.run_used_tokens + request.tokenReservation > self.run_tokens_cap:
                    raise CheckpointApiError(422, "Budget cap exceeded: tokens")
                if self.run_used_wall_time + request.wallTimeReservationSeconds > self.run_wall_time_cap:
                    raise CheckpointApiError(422, "Budget cap exceeded: wall time")


            # Enforce section allocation if provided
            if request.sectionId:
                sec_alloc = self.allocations.get(request.sectionId)
                if not sec_alloc:
                    raise CheckpointApiError(422, f"Section budget allocation '{request.sectionId}' not found")

                sec_used = sum(
                    op["tokensUsed"] if op["status"] == "COMPLETED" else op["tokenReservation"]
                    for op in self.operations.values()
                    if op.get("sectionId") == request.sectionId
                )
                if sec_used + request.tokenReservation > sec_alloc.tokenCap:
                    raise CheckpointApiError(422, f"Section budget exhausted: {request.sectionId}")

            # Enforce artifact allocation if provided
            if request.artifactId:
                art_alloc = self.allocations.get(request.artifactId)
                if not art_alloc:
                    raise CheckpointApiError(422, f"Artifact budget allocation '{request.artifactId}' not found")
                if art_alloc.parentScopeId != request.sectionId:
                    raise CheckpointApiError(422, "Artifact parent mismatch")

                art_used = sum(
                    op["tokensUsed"] if op["status"] == "COMPLETED" else op["tokenReservation"]
                    for op in self.operations.values()
                    if op.get("artifactId") == request.artifactId
                )
                if art_used + request.tokenReservation > art_alloc.tokenCap:
                    raise CheckpointApiError(422, f"Artifact budget exhausted: {request.artifactId}")

            if not has_parent:
                self.run_used_calls += 1
                self.run_used_tokens += request.tokenReservation
                self.run_used_wall_time += request.wallTimeReservationSeconds

            self.operations[request.operationId] = {
                "runId": request.runId,
                "operationId": request.operationId,
                "operationType": request.operationType,
                "requestHash": request.requestHash,
                "status": "RESERVED",
                "tokenReservation": request.tokenReservation,
                "tokensUsed": 0,
                "wallTimeReservation": request.wallTimeReservationSeconds,
                "wallTimeUsed": 0.0,
                "sectionId": request.sectionId,
                "artifactId": request.artifactId,
                "parentOperationId": request.parentOperationId,
                "createdAt": time.time(),
            }

            return OperationGrantResult(
                operationId=request.operationId,
                runId=request.runId,
                status="RESERVED",
                tokenReservation=request.tokenReservation,
                grantedAt=time.time(),
                isReplay=False,
            )

    async def reconcile_operation_async(self, request: OperationReconcileRequest) -> OperationReconcileResult:
        async with self._lock:
            op = self.operations.get(request.operationId)
            if not op:
                raise CheckpointApiError(404, "Operation not found")

            op["status"] = "COMPLETED"
            op["tokensUsed"] = request.tokensUsed
            op["wallTimeUsed"] = request.wallTimeUsedSeconds

            # If standalone operation, adjust run counters
            if not op.get("parentOperationId"):
                self.run_used_tokens += (request.tokensUsed - op["tokenReservation"])
                self.run_used_wall_time += (request.wallTimeUsedSeconds - op["wallTimeReservation"])

            self.reconciliations.append(request)
            return OperationReconcileResult(
                operationId=request.operationId,
                status="COMPLETED",
                tokensUsed=request.tokensUsed,
                wallTimeUsedSeconds=request.wallTimeUsedSeconds,
                reconciledAt=time.time(),
            )

    async def record_unknown_outcome_async(self, request: UnknownOutcomeRequest) -> UnknownOutcomeAck:
        async with self._lock:
            op = self.operations.get(request.operationId)
            if op:
                op["status"] = "UNKNOWN_OUTCOME"
            self.unknown_outcomes.append(request)
            return UnknownOutcomeAck(
                operationId=request.operationId,
                status="UNKNOWN_OUTCOME",
                reservationPreserved=True,
                recordedAt=time.time(),
            )


async def seed_repair_parent(
    client: MockCheckpointClient,
    *,
    run_id: str,
    operation_id: str,
    artifact_id: str,
    section_id: str,
    lease_owner: UUID,
    epoch: int = 1,
) -> None:
    """Create the durable parent authority required by nested repair-provider tests."""
    client.allocations.setdefault(artifact_id, BudgetAllocationItem(
        scopeType="ARTIFACT", scopeId=artifact_id, parentScopeId=section_id,
        tokenCap=18_000, callCap=10, wallTimeCapSeconds=280,
    ))
    request = OperationGrantRequest(
        runId=run_id, epoch=epoch, leaseOwner=lease_owner, operationId=operation_id,
        operationType="REPAIR", requestHash=hashlib.sha256(operation_id.encode()).hexdigest(),
        tokenReservation=1_000, wallTimeReservationSeconds=60.0,
        sectionId=section_id, artifactId=artifact_id,
    )
    await client.grant_operation_async(request)


@pytest.mark.asyncio
async def test_rejected_scoped_grant_does_not_consume_run_budget():
    client = MockCheckpointClient()
    request = OperationGrantRequest(
        runId="run_scope_rejection", epoch=1, leaseOwner=uuid4(), operationId="op_bad_scope",
        operationType="PROVIDER_CALL", requestHash="a" * 64, tokenReservation=100,
        wallTimeReservationSeconds=5.0, sectionId="missing_section",
    )

    with pytest.raises(CheckpointApiError, match="Section budget allocation"):
        await client.grant_operation_async(request)

    assert client.run_used_calls == 0
    assert client.run_used_tokens == 0
    assert client.run_used_wall_time == 0.0
    assert "op_bad_scope" not in client.operations


# ── Test T03-01: 429 + Retry-After longer than deadline ────────────────────────

@pytest.mark.asyncio
async def test_t03_01_rate_limited_retry_after_longer_than_deadline():
    """T03-01: When 429 Retry-After is longer than deadline, fail boundedly without exceeding deadline."""
    registry = ProviderRegistry()
    mock_prov = FakeTransportProvider(name="mock_429")
    mock_prov.enqueue_fault(RateLimitedError("Rate limit reached", retry_after_seconds=60.0))

    registry.register_provider(mock_prov, keys=["key_1"])
    client = MockCheckpointClient()
    gateway = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=3), checkpoint_client=client)

    req = ProviderRequest(
        capability=Capability.GENERATE_TEXT,
        messages=[ChatMessage(role="user", content="Hello")],
        operation_id=f"op_{uuid4().hex[:12]}",
        run_id="run_t03_01",
        section_id="section_1",
        artifact_id="passage_section_1",
        timeout_seconds=2.0,  # Deadline is 2s, but Retry-After requests 60s
    )

    t0 = time.perf_counter()
    with pytest.raises(DeadlineExceededError) as exc_info:
        await gateway.execute(req, epoch=1, lease_owner=uuid4())

    elapsed = time.perf_counter() - t0
    # Must fail boundedly and immediately without sleeping for 60s
    assert elapsed < 1.0
    assert "exceed remaining deadline" in str(exc_info.value)


# ── Test T03-02: 401, timeout, 5xx error taxonomy ──────────────────────────────

@pytest.mark.asyncio
async def test_t03_02_unauthorized_never_retried():
    """T03-02: HTTP 401 Unauthorized fails closed immediately with exactly 1 attempt; no retry or rotation."""
    registry = ProviderRegistry()
    mock_prov = FakeTransportProvider(name="mock_401")
    mock_prov.enqueue_fault(UnauthorizedError("Invalid API key sk-invalid", status_code=401))

    registry.register_provider(mock_prov, keys=["key_1", "key_2"])
    client = MockCheckpointClient()
    gateway = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=3), checkpoint_client=client)

    req = ProviderRequest(
        capability=Capability.GENERATE_TEXT,
        messages=[ChatMessage(role="user", content="Prompt")],
        operation_id=f"op_{uuid4().hex[:12]}",
        run_id="run_t03_02_unauth",
        section_id="section_1",
        artifact_id="passage_section_1",
        timeout_seconds=5.0,
    )

    with pytest.raises(UnauthorizedError):
        await gateway.execute(req, epoch=1, lease_owner=uuid4())

    # Exactly 1 attempt made
    assert len(mock_prov.recorded_calls) == 1


@pytest.mark.asyncio
async def test_t03_02_ambiguous_5xx_is_not_replayed_and_reservation_is_retained():
    """T03-02: Ambiguous 5xx stops after one physical dispatch with its reservation intact."""
    registry = ProviderRegistry()
    mock_prov = FakeTransportProvider(name="mock_503")
    mock_prov.enqueue_fault(ProviderUnavailableError("Server error 503"))
    mock_prov.enqueue_fault(ProviderUnavailableError("Server error 503"))
    mock_prov.enqueue_response('{"status": "recovered"}')

    registry.register_provider(mock_prov, keys=["key_1"])
    client = MockCheckpointClient()
    gateway = ProviderGateway(
        registry=registry,
        retry_policy=RetryPolicy(max_attempts=3, base_delay_seconds=0.01),
        checkpoint_client=client,
    )

    req = ProviderRequest(
        capability=Capability.GENERATE_TEXT,
        messages=[ChatMessage(role="user", content="Prompt")],
        operation_id=f"op_{uuid4().hex[:12]}",
        run_id="run_t03_02_transient",
        section_id="section_1",
        artifact_id="passage_section_1",
        timeout_seconds=10.0,
    )

    with pytest.raises(ProviderUnavailableError):
        await gateway.execute(req, epoch=1, lease_owner=uuid4())
    assert len(mock_prov.recorded_calls) == 1
    assert len(client.unknown_outcomes) == 1
    operation = client.operations[req.operation_id]
    assert operation["status"] == "UNKNOWN_OUTCOME"
    assert operation["tokenReservation"] > 0


# ── Test T03-03: Defensive parser & schema validation ──────────────────────────

class SampleTargetModel(BaseModel):
    title: str = Field(min_length=3)
    score: int = Field(ge=0, le=100)
    status: str = Field(pattern=r"^(active|pending)$")


def test_t03_03_parser_fenced_valid():
    """T03-03: Single markdown fenced JSON object parses cleanly."""
    raw = "```json\n{\"title\": \"Valid Title\", \"score\": 95, \"status\": \"active\"}\n```"
    res = parse_defensive_json(raw, target_model=SampleTargetModel)
    assert res["title"] == "Valid Title"
    assert res["score"] == 95


def test_t03_03_parser_rejects_nan_and_infinity():
    """T03-03: Rejects NaN and Infinity in JSON."""
    raw = '{"title": "Test", "score": NaN, "status": "active"}'
    with pytest.raises(InvalidJsonError) as exc_info:
        parse_defensive_json(raw)
    assert "prohibited" in str(exc_info.value)


def test_t03_03_parser_rejects_ambiguous_multiple_objects():
    """T03-03: Rejects ambiguous multiple top-level JSON objects."""
    raw = '{"title": "Obj1", "score": 10, "status": "active"} {"title": "Obj2", "score": 20, "status": "active"}'
    with pytest.raises(InvalidJsonError) as exc_info:
        parse_defensive_json(raw)
    assert "Ambiguous" in str(exc_info.value)


def test_t03_03_parser_rejects_multiple_fenced_blocks():
    """T03-03: Rejects multiple markdown fenced blocks."""
    raw = "```json\n{\"title\": \"Part1\", \"score\": 10, \"status\": \"active\"}\n```\n```json\n{\"title\": \"Part2\"}\n```"
    with pytest.raises(InvalidJsonError) as exc_info:
        parse_defensive_json(raw)
    assert "Ambiguous multiple fenced blocks" in str(exc_info.value)


def test_t03_03_parser_rejects_trailing_prose():
    """T03-03: Rejects trailing commentary or prose after JSON."""
    raw = '{"title": "Valid", "score": 50, "status": "active"}\nHere is some trailing commentary.'
    with pytest.raises(InvalidJsonError) as exc_info:
        parse_defensive_json(raw)
    assert "trailing" in str(exc_info.value).lower()


def test_t03_03_parser_rejects_schema_mismatch():
    """T03-03: Rejects schema mismatch (wrong type or missing field)."""
    # Score is string instead of int
    raw = '{"title": "Valid", "score": "ninety-five", "status": "active"}'
    with pytest.raises(SchemaMismatchError):
        parse_defensive_json(raw, target_model=SampleTargetModel)


def test_t03_03_parser_bounded_size_rejection():
    """T03-03: Rejects responses exceeding max_response_bytes."""
    raw = '{"title": "' + "A" * 1000 + '", "score": 10, "status": "active"}'
    with pytest.raises(TruncatedOutputError):
        parse_defensive_json(raw, max_response_bytes=500)


# ── Test T03-04: Cancellation during backoff and streaming ─────────────────────

@pytest.mark.asyncio
async def test_t03_04_cancellation_during_backoff():
    """T03-04: Cancelling task during backoff wait halts immediately and raises CancelledError."""
    registry = ProviderRegistry()
    mock_prov = FakeTransportProvider(name="mock_cancel")
    # A known 429 with no provider-side result is safe to retry; cancel while the
    # bounded backoff is pending rather than retrying an ambiguous transport error.
    mock_prov.enqueue_fault(RateLimitedError("Rate limited", retry_after_seconds=None))

    registry.register_provider(mock_prov, keys=["key_1"])
    client = MockCheckpointClient()
    gateway = ProviderGateway(
        registry=registry,
        retry_policy=RetryPolicy(max_attempts=3, base_delay_seconds=10.0),  # 10s wait
        checkpoint_client=client,
    )

    req = ProviderRequest(
        capability=Capability.GENERATE_TEXT,
        messages=[ChatMessage(role="user", content="Hello")],
        operation_id=f"op_{uuid4().hex[:12]}",
        run_id="run_t03_04",
        section_id="section_1",
        artifact_id="passage_section_1",
        timeout_seconds=30.0,
    )

    task = asyncio.create_task(gateway.execute(req, epoch=1, lease_owner=uuid4()))
    await asyncio.sleep(0.05)  # Let it make attempt 1 and enter sleep
    task.cancel()

    with pytest.raises((asyncio.CancelledError, CancelledError)):
        await task


# ── Test T03-05: Concurrent requests near budget limit ─────────────────────────

@pytest.mark.asyncio
async def test_t03_05_concurrent_requests_near_budget_limit():
    """T03-05: Two candidates concurrently requesting tokens near section cap; only one granted."""
    registry = ProviderRegistry()
    mock_prov = FakeTransportProvider(name="mock_budget")
    mock_prov.enqueue_response('{"result": "cand1"}', delay_seconds=0.01)
    mock_prov.enqueue_response('{"result": "cand2"}', delay_seconds=0.01)

    registry.register_provider(mock_prov, keys=["key_1"])
    client = MockCheckpointClient(run_tokens_cap=10000)

    # Set section_1 and questions_section_1 cap to 5000 tokens
    client.allocations["section_1"] = BudgetAllocationItem(
        scopeType="SECTION", scopeId="section_1", parentScopeId=None, tokenCap=5000, callCap=10, wallTimeCapSeconds=300
    )
    client.allocations["questions_section_1"] = BudgetAllocationItem(
        scopeType="ARTIFACT", scopeId="questions_section_1", parentScopeId="section_1", tokenCap=5000, callCap=10, wallTimeCapSeconds=300
    )

    gateway = ProviderGateway(registry=registry, checkpoint_client=client)
    owner = uuid4()

    # Candidate 1 and Candidate 2 each request 3000 tokens (3000 + 3000 = 6000 > 5000)
    req1 = ProviderRequest(
        capability=Capability.GENERATE_JSON,
        messages=[ChatMessage(role="user", content="Cand 1")],
        operation_id=f"op_cand1_{uuid4().hex[:8]}",
        run_id="run_budget_race",
        section_id="section_1",
        artifact_id="questions_section_1",
        max_tokens=3000,
    )
    req2 = ProviderRequest(
        capability=Capability.GENERATE_JSON,
        messages=[ChatMessage(role="user", content="Cand 2")],
        operation_id=f"op_cand2_{uuid4().hex[:8]}",
        run_id="run_budget_race",
        section_id="section_1",
        artifact_id="questions_section_1",
        max_tokens=3000,
    )

    results = await asyncio.gather(
        gateway.execute(req1, epoch=1, lease_owner=owner),
        gateway.execute(req2, epoch=1, lease_owner=owner),
        return_exceptions=True,
    )

    successes = [r for r in results if isinstance(r, ProviderResponse)]
    failures = [r for r in results if isinstance(r, BudgetExhaustedError)]

    assert len(successes) == 1
    assert len(failures) == 1
    assert "Budget cap exceeded" in str(failures[0]) or "exhausted" in str(failures[0])


# ── Test T03-06: Provider timeout (UNKNOWN_OUTCOME) preserves reservation ──────

@pytest.mark.asyncio
async def test_t03_06_provider_timeout_preserves_reservation_no_free_retry():
    """T03-06: Provider timeout causes UNKNOWN_OUTCOME; reservation preserved without refund or free retry."""
    registry = ProviderRegistry()
    mock_prov = FakeTransportProvider(name="mock_timeout")
    # Simulate a call that delays 5s when timeout is 0.5s
    mock_prov.enqueue_response('{"data": 1}', delay_seconds=5.0)

    registry.register_provider(mock_prov, keys=["key_1"])
    client = MockCheckpointClient(run_tokens_cap=10000)
    gateway = ProviderGateway(registry=registry, checkpoint_client=client)

    owner = uuid4()
    req = ProviderRequest(
        capability=Capability.GENERATE_JSON,
        messages=[ChatMessage(role="user", content="Prompt")],
        operation_id=f"op_unk_{uuid4().hex[:8]}",
        run_id="run_unk_outcome",
        section_id="section_1",
        artifact_id="passage_section_1",
        max_tokens=4000,
        timeout_seconds=0.2,
    )

    with pytest.raises((ProviderTimeoutError, DeadlineExceededError, ProviderUnavailableError)):
        await gateway.execute(req, epoch=1, lease_owner=owner)

    # UNKNOWN_OUTCOME recorded
    assert len(client.unknown_outcomes) == 1
    assert client.unknown_outcomes[0].operationId == req.operation_id

    # The reservation was PRESERVED, not refunded, and covers the full completion
    # allowance. Commit e96f71b made the reservation an upper bound of prompt bytes
    # plus completion tokens (BaseProvider.conservative_token_reservation), so the
    # held amount is that bound rather than the bare max_tokens of 4000. Bind to the
    # provider's own formula instead of a stale literal: the guarantee under test is
    # that the reservation is neither released nor reduced after the timeout, and that
    # the preserved amount is at least the completion allowance requested.
    reserved = mock_prov.conservative_token_reservation(req)
    assert reserved >= req.max_tokens
    assert client.run_used_tokens == reserved

    # A subsequent request cannot be admitted from a refund: the preserved reservation
    # plus the next request's 7000 exceeds the 10000 run cap.
    req_next = ProviderRequest(
        capability=Capability.GENERATE_JSON,
        messages=[ChatMessage(role="user", content="Prompt 2")],
        operation_id=f"op_next_{uuid4().hex[:8]}",
        run_id="run_unk_outcome",
        section_id="section_1",
        artifact_id="passage_section_1",
        max_tokens=7000,
        timeout_seconds=5.0,
    )
    assert reserved + req_next.max_tokens > client.run_tokens_cap

    with pytest.raises(BudgetExhaustedError):
        await gateway.execute(req_next, epoch=1, lease_owner=owner)


# ── Test T03-07: Adapter recordings, zero secret/thinking leaks ────────────────

def test_t03_07_streaming_sanitizer_removes_split_thinking_tags():
    """T03-07: Sanitizer correctly buffers across chunks and suppresses thinking tokens split across boundaries."""
    sanitizer = StreamingReasoningSanitizer()

    # Split across chunk boundaries:
    # Chunk 1 has partial opening tag "<th"
    # Chunk 2 has remainder "ink> Internal thought </th"
    # Chunk 3 has remainder "ink> Actual public text"
    c1 = sanitizer.feed("<th")
    assert c1 == ""  # Held in buffer!

    c2 = sanitizer.feed("ink> Internal thought </th")
    assert c2 == ""  # Discarded as thinking!

    c3 = sanitizer.feed("ink> Actual public text")
    tail = sanitizer.flush()
    result = c3 + tail

    assert "Internal thought" not in result
    assert "<think>" not in result
    assert "</think>" not in result
    assert result == " Actual public text"


def test_t03_07_redact_secrets():
    """T03-07: Redaction helper scrubs API keys and Bearer tokens from text/logs."""
    raw = "Failed with key sk-abcdef1234567890 and Bearer gsk_999888777666."
    redacted = redact_secrets(raw)
    assert "sk-abcdef1234567890" not in redacted
    assert "gsk_999888777666" not in redacted
    assert "[REDACTED]" in redacted

@pytest.mark.asyncio
async def test_t03_reconciliation_failure_propagates_and_fails_closed():
    """Verify that when durable reconciliation fails at checkpoint client, gateway fails closed instead of swallowing."""
    registry = ProviderRegistry()
    mock_prov = FakeTransportProvider(name="mock_rec_fail")
    mock_prov.enqueue_response('{"title": "Section 1", "data": 123}')

    registry.register_provider(mock_prov, keys=["key_1"])
    client = MockCheckpointClient(run_tokens_cap=10000)

    # Monkeypatch reconcile_operation_async to simulate database or network failure
    async def failing_reconcile(req):
        raise CheckpointApiError(500, "Persistence outbox or DB connection failure during operation reconciliation")

    client.reconcile_operation_async = failing_reconcile
    gateway = ProviderGateway(registry=registry, checkpoint_client=client)

    owner = uuid4()
    req = ProviderRequest(
        capability=Capability.GENERATE_JSON,
        messages=[ChatMessage(role="user", content="Prompt")],
        operation_id=f"op_rec_fail_{uuid4().hex[:8]}",
        run_id="run_rec_fail",
        section_id="section_1",
        artifact_id="passage_section_1",
        max_tokens=1000,
    )

    with pytest.raises(ProviderError) as exc_info:
        await gateway.execute(req, epoch=1, lease_owner=owner)

    assert "Failed to persist durable operation reconciliation" in str(exc_info.value)



# ── Test T03-08: Offline adapter contract; live smoke requires explicit opt-in ──

def _t03_smoke_request():
    return ProviderRequest(
        capability=Capability.GENERATE_TEXT,
        messages=[ChatMessage(role="user", content="Reply with one word: ping")],
        operation_id=f"op_smoke_{uuid4().hex[:8]}",
        max_tokens=10,
        timeout_seconds=15.0,
    )


async def _t03_optional_live_smoke():
    # Credentials are not consent to paid/external calls. No skip masks opt-in failures.
    if os.environ.get("RUN_LIVE_PROVIDER_SMOKE") != "1":
        return "NOT_RUN_EXTERNAL"
    minimax_key = os.environ.get("MINIMAX_API_KEY") or os.environ.get("MINIMAX_API_KEYS") or settings.minimax_api_key
    groq_key = os.environ.get("GROQ_API_KEY") or os.environ.get("GROQ_API_KEYS") or settings.groq_api_key
    assert minimax_key or groq_key, "Live smoke opted in but no provider credentials configured"
    provider_name = "minimax" if minimax_key else "groq"
    registry = ProviderRegistry()
    registry.initialize_from_settings()
    provider = registry.get_provider(provider_name)
    assert provider is not None, f"Live smoke provider {provider_name} not configured"
    key_info = await registry.get_next_key(provider_name)
    assert key_info, f"Live smoke {provider_name} key not accessible"
    response = await provider.call(_t03_smoke_request(), key_info[0], deadline=time.time() + 15)
    assert response.raw_text.strip()
    assert response.usage.total_tokens > 0
    assert response.usage.accounting_type == UsageAccountingType.REPORTED
    return "PASS_LIVE"


@pytest.mark.asyncio
async def test_t03_08_live_provider_smoke_or_not_run_external(record_property):
    """MockTransport validates SDK wiring, not live availability or credentials."""
    import json

    for adapter in (MiniMaxProvider, GroqProvider):
        calls = []

        def respond(request):
            calls.append(request)
            payload = json.loads(request.content)
            assert request.url == "https://smoke.invalid/v1/chat/completions"
            assert request.headers["authorization"] == "Bearer offline-smoke-key"
            assert payload["max_tokens"] == 10
            assert payload["messages"] == [{"role": "user", "content": "Reply with one word: ping"}]
            return httpx.Response(200, json={
                "id": "offline-smoke", "object": "chat.completion", "created": 0,
                "model": payload["model"],
                "choices": [{"index": 0, "message": {"role": "assistant", "content": "ping"}, "finish_reason": "stop"}],
                "usage": {"prompt_tokens": 8, "completion_tokens": 1, "total_tokens": 9},
            })

        async with httpx.AsyncClient(transport=httpx.MockTransport(respond)) as client:
            provider = adapter(base_url="https://smoke.invalid/v1", http_client=client)
            response = await provider.call(_t03_smoke_request(), "offline-smoke-key", deadline=time.time() + 15)
        assert len(calls) == 1
        assert response.raw_text == "ping"
        assert response.finish_reason == FinishReason.STOP
        assert response.usage.total_tokens == 9
        assert response.usage.accounting_type == UsageAccountingType.REPORTED
    record_property("offline_adapter_contract", "PASS: MockTransport only")
    record_property("live_provider_smoke", await _t03_optional_live_smoke())


@pytest.mark.asyncio
@pytest.mark.parametrize("opt_in", [None, "0", "true", "yes", "1 "])
async def test_t03_08_credentials_never_imply_live_opt_in(monkeypatch, opt_in):
    from unittest.mock import Mock

    monkeypatch.setenv("MINIMAX_API_KEY", "configured-but-must-not-dispatch")
    monkeypatch.setenv("GROQ_API_KEY", "configured-but-must-not-dispatch")
    monkeypatch.delenv("RUN_LIVE_PROVIDER_SMOKE", raising=False)
    if opt_in is not None:
        monkeypatch.setenv("RUN_LIVE_PROVIDER_SMOKE", opt_in)
    initialize = Mock(side_effect=AssertionError("Offline smoke must not initialize live providers"))
    monkeypatch.setattr(ProviderRegistry, "initialize_from_settings", initialize)
    assert await _t03_optional_live_smoke() == "NOT_RUN_EXTERNAL"
    initialize.assert_not_called()


@pytest.mark.asyncio
async def test_t03_08_live_opt_in_without_credentials_fails_not_skips(monkeypatch):
    from unittest.mock import Mock

    monkeypatch.setenv("RUN_LIVE_PROVIDER_SMOKE", "1")
    for key in ("MINIMAX_API_KEY", "MINIMAX_API_KEYS", "GROQ_API_KEY", "GROQ_API_KEYS"):
        monkeypatch.delenv(key, raising=False)
    monkeypatch.setattr(settings, "minimax_api_key", "")
    monkeypatch.setattr(settings, "groq_api_key", "")
    initialize = Mock()
    monkeypatch.setattr(ProviderRegistry, "initialize_from_settings", initialize)
    with pytest.raises(AssertionError, match="no provider credentials configured"):
        await _t03_optional_live_smoke()
    initialize.assert_not_called()


@pytest.mark.asyncio
@pytest.mark.parametrize("outcome", ["success", "missing-key", "rate-limited"])
async def test_t03_08_explicit_live_opt_in_is_honest_without_live_calls(monkeypatch, outcome):
    from unittest.mock import AsyncMock, Mock

    monkeypatch.setenv("RUN_LIVE_PROVIDER_SMOKE", "1")
    monkeypatch.setenv("MINIMAX_API_KEY", "offline-test-key")
    monkeypatch.setattr(ProviderRegistry, "initialize_from_settings", lambda self: None)
    provider = Mock()
    provider.call = AsyncMock(return_value=ProviderResponse(
        operation_id="offline-test", provider_name="minimax", model_name="offline-test",
        raw_text="ping", finish_reason=FinishReason.STOP,
        usage=UsageReport(total_tokens=9, accounting_type=UsageAccountingType.REPORTED),
    ))
    monkeypatch.setattr(ProviderRegistry, "get_provider", lambda self, name: provider)
    monkeypatch.setattr(ProviderRegistry, "get_next_key", AsyncMock(
        return_value=None if outcome == "missing-key" else ("offline-test-key", 0),
    ))
    if outcome == "rate-limited":
        provider.call.side_effect = RateLimitedError("offline simulated quota failure")
        with pytest.raises(RateLimitedError):
            await _t03_optional_live_smoke()
    elif outcome == "missing-key":
        with pytest.raises(AssertionError, match="key not accessible"):
            await _t03_optional_live_smoke()
        provider.call.assert_not_awaited()
    else:
        assert await _t03_optional_live_smoke() == "PASS_LIVE"
        provider.call.assert_awaited_once()

# ── AUDIT-NESTED-RETRIES: Real SDK with Fake Transport Attempts Bounds ──────

@pytest.mark.asyncio
async def test_audit_nested_retries_client_max_retries_zero():
    """AUDIT-NESTED-RETRIES: OpenAICompatibleProvider client strictly sets max_retries=0."""
    mock_transport = httpx.MockTransport(lambda req: httpx.Response(200, json={}))
    async with httpx.AsyncClient(transport=mock_transport) as http_client:
        provider = OpenAICompatibleProvider(
            name="test_openai",
            base_url="https://api.fake.test/v1",
            models={"small": "test-model"},
            http_client=http_client,
            max_retries=0,
        )
        client = provider._get_client("fake_key_12345678")
        assert client.max_retries == 0, f"Expected SDK max_retries=0, got {client.max_retries}"


@pytest.mark.asyncio
async def test_audit_nested_retries_rate_limit_bounded_under_gateway():
    """AUDIT-NESTED-RETRIES: On 429 RateLimit, total transport requests strictly match Gateway cap."""
    transport_calls = 0

    def rate_limit_handler(request: httpx.Request) -> httpx.Response:
        nonlocal transport_calls
        transport_calls += 1
        return httpx.Response(
            status_code=429,
            headers={"retry-after": "0.01"},
            json={"error": {"message": "Rate limit reached", "type": "rate_limit_error"}},
        )

    mock_transport = httpx.MockTransport(rate_limit_handler)
    async with httpx.AsyncClient(transport=mock_transport) as http_client:
        provider = OpenAICompatibleProvider(
            name="test_ratelimit",
            base_url="https://api.fake.test/v1",
            models={"small": "test-model"},
            http_client=http_client,
            max_retries=0,
        )
        registry = ProviderRegistry()
        registry.register_provider(provider, keys=["fake_key_12345678"])

        mock_checkpoint = MockCheckpointClient()
        gateway = ProviderGateway(
            registry=registry,
            retry_policy=RetryPolicy(max_attempts=3, base_delay_seconds=0.01, max_delay_seconds=0.02),
            checkpoint_client=mock_checkpoint,
        )

        req = ProviderRequest(
            capability=Capability.GENERATE_TEXT,
            messages=[ChatMessage(role="user", content="Hello")],
            operation_id=f"op_rl_{uuid4().hex[:8]}",
            run_id="run_test",
            max_tokens=50,
            timeout_seconds=5.0,
            preferred_provider="test_ratelimit",
        )

        with pytest.raises((RateLimitedError, ProviderUnavailableError, DeadlineExceededError)):
            await gateway.execute(req, epoch=1, lease_owner=uuid4())

        # SDK retries must NOT multiply: total transport hits must equal exactly max_attempts (3), NOT 3 x 3 = 9!
        assert transport_calls == 3, f"Expected exactly 3 transport requests under gateway, got {transport_calls}"


@pytest.mark.asyncio
async def test_audit_ambiguous_server_error_stops_after_one_gateway_dispatch():
    """An HTTP 503 has an unresolved provider outcome and is never blindly replayed."""
    transport_calls = 0

    def server_error_handler(request: httpx.Request) -> httpx.Response:
        nonlocal transport_calls
        transport_calls += 1
        return httpx.Response(
            status_code=503,
            json={"error": {"message": "Service overloaded", "type": "server_error"}},
        )

    mock_transport = httpx.MockTransport(server_error_handler)
    async with httpx.AsyncClient(transport=mock_transport) as http_client:
        provider = OpenAICompatibleProvider(
            name="test_503",
            base_url="https://api.fake.test/v1",
            models={"small": "test-model"},
            http_client=http_client,
            max_retries=0,
        )
        registry = ProviderRegistry()
        registry.register_provider(provider, keys=["fake_key_12345678"])

        mock_checkpoint = MockCheckpointClient()
        gateway = ProviderGateway(
            registry=registry,
            retry_policy=RetryPolicy(max_attempts=3, base_delay_seconds=0.01, max_delay_seconds=0.02),
            checkpoint_client=mock_checkpoint,
        )

        req = ProviderRequest(
            capability=Capability.GENERATE_TEXT,
            messages=[ChatMessage(role="user", content="Hello")],
            operation_id=f"op_503_{uuid4().hex[:8]}",
            run_id="run_test",
            max_tokens=50,
            timeout_seconds=5.0,
            preferred_provider="test_503",
        )

        with pytest.raises(ProviderUnavailableError):
            await gateway.execute(req, epoch=1, lease_owner=uuid4())

        assert transport_calls == 1, f"Ambiguous 503 must not be replayed; got {transport_calls} calls"
        assert len(mock_checkpoint.unknown_outcomes) == 1
        assert len(mock_checkpoint.operations) == 1
        operation = next(iter(mock_checkpoint.operations.values()))
        assert operation["status"] == "UNKNOWN_OUTCOME"
        assert operation["tokenReservation"] > 0


@pytest.mark.asyncio
async def test_audit_nested_retries_unauthorized_never_retried():
    """AUDIT-NESTED-RETRIES: On 401 Unauthorized, never retries against policy (exactly 1 call)."""
    transport_calls = 0

    def unauth_handler(request: httpx.Request) -> httpx.Response:
        nonlocal transport_calls
        transport_calls += 1
        return httpx.Response(
            status_code=401,
            json={"error": {"message": "Invalid API key", "type": "invalid_request_error"}},
        )

    mock_transport = httpx.MockTransport(unauth_handler)
    async with httpx.AsyncClient(transport=mock_transport) as http_client:
        provider = OpenAICompatibleProvider(
            name="test_unauth",
            base_url="https://api.fake.test/v1",
            models={"small": "test-model"},
            http_client=http_client,
            max_retries=0,
        )
        registry = ProviderRegistry()
        registry.register_provider(provider, keys=["fake_key_12345678"])

        mock_checkpoint = MockCheckpointClient()
        gateway = ProviderGateway(
            registry=registry,
            retry_policy=RetryPolicy(max_attempts=3, base_delay_seconds=0.01, max_delay_seconds=0.02),
            checkpoint_client=mock_checkpoint,
        )

        req = ProviderRequest(
            capability=Capability.GENERATE_TEXT,
            messages=[ChatMessage(role="user", content="Hello")],
            operation_id=f"op_unauth_{uuid4().hex[:8]}",
            run_id="run_test",
            max_tokens=50,
            timeout_seconds=5.0,
            preferred_provider="test_unauth",
        )

        with pytest.raises(UnauthorizedError):
            await gateway.execute(req, epoch=1, lease_owner=uuid4())

        # Security violation: MUST NEVER RETRY (total transport calls must be 1)
        assert transport_calls == 1, f"Expected exactly 1 call for 401 error, got {transport_calls}"


@pytest.mark.asyncio
async def test_audit_ambiguous_500_preserves_single_unknown_attempt_reservation():
    """An ambiguous 500 records UNKNOWN_OUTCOME without refunding its token reservation."""
    mock_checkpoint = MockCheckpointClient()
    mock_transport = httpx.MockTransport(lambda req: httpx.Response(500, json={"error": "Server error"}))
    async with httpx.AsyncClient(transport=mock_transport) as http_client:
        provider = OpenAICompatibleProvider(
            name="test_unk",
            base_url="https://api.fake.test/v1",
            models={"small": "test-model"},
            http_client=http_client,
            max_retries=0,
        )
        registry = ProviderRegistry()
        registry.register_provider(provider, keys=["fake_key_12345678"])

        gateway = ProviderGateway(
            registry=registry,
            retry_policy=RetryPolicy(max_attempts=2, base_delay_seconds=0.01, max_delay_seconds=0.02),
            checkpoint_client=mock_checkpoint,
        )

        op_id = f"op_unk_{uuid4().hex[:8]}"
        req = ProviderRequest(
            capability=Capability.GENERATE_TEXT,
            messages=[ChatMessage(role="user", content="Hello")],
            operation_id=op_id,
            run_id="run_test",
            max_tokens=50,
            timeout_seconds=5.0,
            preferred_provider="test_unk",
        )

        with pytest.raises(ProviderUnavailableError):
            await gateway.execute(req, epoch=1, lease_owner=uuid4())

        reserved_ops = [op for op in mock_checkpoint.operations.values()
                        if op["status"] != "COMPLETED"]
        assert len(reserved_ops) == 1, "ambiguous transport outcome must not be replayed"
        recorded = {u.operationId for u in mock_checkpoint.unknown_outcomes}
        assert recorded == {op["operationId"] for op in reserved_ops}
        assert recorded == {op_id}
        assert all(op["tokensUsed"] == 0 for op in reserved_ops)
        assert all(op["tokenReservation"] > 0 for op in reserved_ops)
        assert mock_checkpoint.run_used_tokens == sum(
            op["tokenReservation"] for op in reserved_ops)
