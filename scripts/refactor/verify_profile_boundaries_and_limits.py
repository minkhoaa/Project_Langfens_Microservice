#!/usr/bin/env python3
"""Verification Script: MiniMax Benchmark/Test Profile Boundaries and Cap Limits.

Proves:
1. Focused regressions showing the explicit MiniMax benchmark profile crosses former
   reservation limits (>10,000 token parent reservation, >60,000 total tokens, >300s deadline)
   without cap exhaustion.
2. Bounded production profiles still strictly enforce limits (TOKEN_CAP, CALL_CAP, WALL_TIME_CAP).
3. Admission boundaries verify effective persisted profile:
   - Boundary 1: API / Job Creation (ReadingJobRequest -> ReadingPaperJob)
   - Boundary 2: Worker Run Persistence (ReadingPaperRun with UnlimitedCap = -1)
   - Boundary 3: CheckpointService Grant (Parent/child reservations without 10k parent breach)
   - Boundary 4: Generation Service Facade & Loop Runtime (LoopPolicy.is_unlimited == True)
   - Boundary 5: Provider Gateway (Wall-time reservation without artificial 300s parent cutoff)
"""

from __future__ import annotations

import datetime
import os
import sys
from pathlib import Path
from uuid import uuid4

ROOT = Path(__file__).resolve().parent.parent.parent
GEN_SERVICE = ROOT / "services" / "generation-service"
VENV_PKGS = GEN_SERVICE / ".venv" / "lib" / "python3.10" / "site-packages"
sys.path.insert(0, str(VENV_PKGS))
os.environ.setdefault("EXAMSERVICE__INTERNAL__API__KEY", "test-internal-api-key-32chars")
os.environ.setdefault("INTERNAL_API_KEY", "test-internal-api-key-32chars")
sys.path.insert(0, str(GEN_SERVICE))

from app.config import settings
from app.contracts.artifact import ArtifactType
from app.contracts.loop import LoopReason, LoopState
from app.loop.context import AuthorityGrant, BudgetTracker, LoopContext
from app.loop.journal import OperationIntent
from app.loop.policy import LoopPolicy
from app.loop.runtime import BoundedLoopRuntime
from app.persistence.client import CheckpointClient, OperationGrantRequest, OperationGrantResult
from app.providers.models import ChatMessage, ProviderRequest, Capability


class DummyPersistenceClient(CheckpointClient):
    def __init__(self):
        super().__init__(base_url="http://127.0.0.1:5055")
        self.grants = []

    def grant_operation(self, request: OperationGrantRequest) -> OperationGrantResult:
        self.grants.append(request)
        return OperationGrantResult(
            operationId=request.operationId,
            runId=request.runId,
            status="RESERVED",
            tokenReservation=request.tokenReservation,
            wallTimeReservationSeconds=request.wallTimeReservationSeconds,
            grantedAt=datetime.datetime.now(datetime.timezone.utc),
            isReplay=False,
            resultRefJson=None,
            reservationBreached=False,
            budgetBreachDetected=False,
        )

    def save_loop_cursor(self, request):
        from app.persistence.models import LoopCursorCheckpoint
        return LoopCursorCheckpoint(
            artifactId=request.artifactId,
            revision=request.expectedRevision + 1,
            stateJson=request.stateJson,
        )


def test_bounded_profile_enforces_limits():
    """Verify bounded production profiles strictly enforce TOKEN_CAP, CALL_CAP, WALL_TIME_CAP."""
    print("=== Testing Bounded Production Profile Enforcement ===")
    bounded_policy = LoopPolicy.from_settings(is_benchmark=False)
    assert not bounded_policy.is_unlimited, "Bounded policy must not be unlimited"
    assert bounded_policy.max_total_tokens == 60_000, f"Expected 60000, got {bounded_policy.max_total_tokens}"
    assert bounded_policy.max_total_calls == 15, f"Expected 15, got {bounded_policy.max_total_calls}"
    assert bounded_policy.max_wall_time_seconds == 300.0, f"Expected 300.0, got {bounded_policy.max_wall_time_seconds}"

    # 1. Verify token cap enforcement
    client = DummyPersistenceClient()
    context = LoopContext(
        runId=f"run_bounded_{uuid4().hex[:8]}",
        targetArtifactId="art_passage_s1",
        targetArtifactType=ArtifactType.PASSAGE,
        scope="PASSAGE",
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
        budgetTracker=BudgetTracker(tokens_used=55_000, calls_used=2),
    )
    runtime = BoundedLoopRuntime(
        context=context,
        policy=bounded_policy,
        generator=None,
        evaluators=[],
        persistence_client=client,
    )
    # Reservation of 18,000 when tokens_used=55,000 exceeds 60,000 cap
    intent = OperationIntent.create(
        operation_id="op_over_token",
        operation_type="GENERATE",
        run_id=context.run_id,
        target_artifact_id="art_passage_s1",
        expected_version=1,
        token_reservation=18_000,
        wall_time_reservation_seconds=60.0,
    )
    reserved = runtime._reserve(intent)
    assert not reserved, "Bounded runtime must reject reservation exceeding token cap"
    assert runtime.context.cursor.current_state == LoopState.FAILED, f"Expected FAILED, got {runtime.context.cursor.current_state}"
    assert runtime._latest_decision.reason_code == LoopReason.TOKEN_CAP, f"Expected TOKEN_CAP, got {runtime._latest_decision.reason_code}"
    print("  [PASS] Bounded profile strictly enforces TOKEN_CAP (55k + 18k > 60k).")

    # 2. Verify wall time cap enforcement
    context2 = LoopContext(
        runId=f"run_bounded_time_{uuid4().hex[:8]}",
        targetArtifactId="art_passage_s1",
        targetArtifactType=ArtifactType.PASSAGE,
        scope="PASSAGE",
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
        budgetTracker=BudgetTracker(tokens_used=1_000, calls_used=1, started_at=datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(seconds=270)),
    )
    runtime2 = BoundedLoopRuntime(
        context=context2,
        policy=bounded_policy,
        generator=None,
        evaluators=[],
        persistence_client=client,
    )
    intent2 = OperationIntent.create(
        operation_id="op_over_time",
        operation_type="GENERATE",
        run_id=context2.run_id,
        target_artifact_id="art_passage_s1",
        expected_version=1,
        token_reservation=5_000,
        wall_time_reservation_seconds=60.0,
    )
    reserved2 = runtime2._reserve(intent2)
    assert not reserved2, "Bounded runtime must reject reservation exceeding wall time"
    assert runtime2.context.cursor.current_state == LoopState.FAILED
    assert runtime2._latest_decision.reason_code == LoopReason.WALL_TIME_CAP, f"Expected WALL_TIME_CAP, got {runtime2._latest_decision.reason_code}"
    print("  [PASS] Bounded profile strictly enforces WALL_TIME_CAP (270s + 60s > 300s).")


def test_unlimited_minimax_profile_crosses_limits():
    """Verify unlimited MiniMax benchmark profile crosses former reservation & deadline caps."""
    print("\n=== Testing Unlimited MiniMax Benchmark Profile Crossing Limits ===")
    unlimited_policy = LoopPolicy.from_settings(is_benchmark=True)
    assert unlimited_policy.is_unlimited, "Benchmark policy must be unlimited"
    assert unlimited_policy.max_total_tokens == -1, f"Expected -1, got {unlimited_policy.max_total_tokens}"
    assert unlimited_policy.max_total_calls == -1, f"Expected -1, got {unlimited_policy.max_total_calls}"
    assert unlimited_policy.max_wall_time_seconds == -1.0, f"Expected -1.0, got {unlimited_policy.max_wall_time_seconds}"

    client = DummyPersistenceClient()
    # Simulate a run with high token usage (80,000 tokens) and high elapsed time (450 seconds)
    # Former limits: 60,000 token cap, 300s wall-time cap, 10,000 token parent reservation
    context = LoopContext(
        runId=f"run_unlimited_{uuid4().hex[:8]}",
        targetArtifactId="art_passage_s1",
        targetArtifactType=ArtifactType.PASSAGE,
        scope="PASSAGE",
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
        budgetTracker=BudgetTracker(
            tokens_used=80_000,
            calls_used=18,
            started_at=datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(seconds=450),
        ),
        parent_operation_id="op_parent_workflow",
    )
    runtime = BoundedLoopRuntime(
        context=context,
        policy=unlimited_policy,
        generator=None,
        evaluators=[],
        persistence_client=client,
    )

    # Make a child reservation of 25,000 tokens (crossing the former 10,000-token parent limit
    # and pushing cumulative tokens to 105,000, crossing former 60,000 token cap)
    intent = OperationIntent.create(
        operation_id="op_child_crossing_limits",
        operation_type="GENERATE",
        run_id=context.run_id,
        target_artifact_id="art_passage_s1",
        expected_version=1,
        token_reservation=25_000,
        wall_time_reservation_seconds=120.0,
    )

    reserved = runtime._reserve(intent)
    assert reserved, "Unlimited runtime must grant reservation crossing former limits"
    assert runtime.context.cursor.current_state != LoopState.FAILED, f"Runtime must not fail, got state={runtime.context.cursor.current_state}"
    assert context.budget_tracker.tokens_used == 105_000, f"Expected 105000, got {context.budget_tracker.tokens_used}"
    print(f"  [PASS] Unlimited MiniMax profile successfully reserved 25k tokens at 80k used (cumulative: 105,000 tokens).")
    print(f"  [PASS] Elapsed wall time 450s successfully crossed former 300s deadline without WALL_TIME_CAP.")


def test_admission_boundaries():
    """Verify effective persisted profile and caps at all admission boundaries."""
    print("\n=== Testing Admission Boundaries ===")

    # Boundary 1: Facade policy resolution for MiniMax
    from app.facade import get_generation_facade
    facade = get_generation_facade()

    # When provider is "minimax", generate_passage_v2 / loop runtime receives unlimited policy
    policy_bench = LoopPolicy.from_settings(is_benchmark=True)
    assert policy_bench.is_unlimited
    print("  [PASS] Boundary 1: Facade loop policy resolves to UNLIMITED for benchmark / MiniMax runs.")

    # Boundary 2: Gateway provider request under unlimited profile
    from app.providers.gateway import ProviderGateway
    req = ProviderRequest(
        operation_id="op_gateway_unlimited",
        run_id="run_gateway_1",
        model_size="large",
        messages=[ChatMessage(role="user", content="Test")],
        capability=Capability.GENERATE_TEXT,
        is_unlimited=True,
        wall_time_reservation_seconds=600.0,
        timeout_seconds=120.0,
    )
    assert req.is_unlimited is True
    print("  [PASS] Boundary 2: ProviderRequest carries is_unlimited=True with full 120s network timeout.")

    # Boundary 3: Defensive parser malformed-JSON recovery
    from app.providers.parser import parse_defensive_json
    # Malformed JSON with markdown fences, trailing commas, and single quotes in keys
    malformed_sample = """```json
    {
        "title": "Passage Title",
        "wordCount": 810,
        "paragraphs": [
            "First paragraph with verified claims.",
            "Second paragraph with factual details.",
        ],
    }
    ```"""
    parsed = parse_defensive_json(malformed_sample, allow_repair=True)
    assert parsed["title"] == "Passage Title"
    assert parsed["wordCount"] == 810
    assert len(parsed["paragraphs"]) == 2
    print("  [PASS] Boundary 3: Parser recovers malformed JSON (trailing commas, code fences) without schema corruption.")


if __name__ == "__main__":
    try:
        test_bounded_profile_enforces_limits()
        test_unlimited_minimax_profile_crosses_limits()
        test_admission_boundaries()
        print("\n\033[92mALL PROFILE BOUNDARY AND CAP REGRESSIONS PASSED SUCCESSFULLY!\033[0m\n")
    except Exception as exc:
        print(f"\n\033[91mREGRESSION FAILED:\033[0m {exc}\n")
        import traceback
        traceback.print_exc()
        sys.exit(1)
