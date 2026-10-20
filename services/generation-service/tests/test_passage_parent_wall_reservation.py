"""Tests for passage parent GENERATE wall-time reservation sizing and cap enforcement.

Invariants:
1. Passage GENERATE parent operation must be sized for at most 3 bounded calls (180.0s)
   to allow sequential provider calls (initial draft + quantity guard + word-count guard).
2. EVALUATE and REPAIR reservations must remain completely unchanged (min(wall_res, 60.0)).
3. Non-passage GENERATE reservations must remain completely unchanged.
4. Passage GENERATE reservations must respect existing finite artifact, section, and run caps.
5. Two sequential provider calls under one GENERATE must fit when permitted by caps.
6. Requests exceeding parent or artifact caps must still be rejected fail-closed (422).
"""

from __future__ import annotations

import json
from uuid import uuid4
import pytest

from app.contracts.artifact import ArtifactType
from app.contracts.issue import IssueScope
from app.contracts.loop import LoopState
from app.loop.context import AuthorityGrant, BudgetTracker, LoopContext, ResumeCursor
from app.loop.policy import LoopPolicy
from app.loop.runtime import BoundedLoopRuntime
from app.persistence.client import CheckpointApiError, CheckpointClient
from app.persistence.models import OperationGrantRequest, OperationGrantResult


class MockDurableStore(CheckpointClient):
    """Mock store implementing hierarchical parent and artifact budget enforcement."""

    def __init__(self, run_id: str, artifact_wall_cap: float = 200.0, section_wall_cap: float = 800.0):
        super().__init__(base_url="http://mock-checkpoint", internal_api_key="test-key", timeout=5.0)
        self.run_id = run_id
        self.artifact_wall_cap = artifact_wall_cap
        self.section_wall_cap = section_wall_cap
        self.operations: dict[str, dict] = {}

    def grant_operation(self, request: OperationGrantRequest) -> OperationGrantResult:
        # 1. Parent reservation check
        if request.parentOperationId:
            parent = self.operations.get(request.parentOperationId)
            if not parent:
                raise CheckpointApiError(422, f"Parent operation '{request.parentOperationId}' not found")

            # Token reservation check against parent
            current_child_tokens = sum(
                op["tokensUsed"] if op["status"] == "COMPLETED" else op["tokenReservation"]
                for op in self.operations.values()
                if op.get("parentOperationId") == request.parentOperationId
            )
            if parent.get("tokenReservation", 0) > 0 and current_child_tokens + request.tokenReservation > parent["tokenReservation"]:
                raise CheckpointApiError(
                    422,
                    f"Parent operation reservation exceeded: parent '{parent['operationId']}' token reservation "
                    f"({parent['tokenReservation']}) would be exceeded by child reservation "
                    f"{request.tokenReservation} (current child allocated: {current_child_tokens})",
                )

            # Sum of completed wall time used + reserved wall time under this parent
            current_child_wall = sum(
                op["wallTimeUsedSeconds"] if op["status"] == "COMPLETED" else op["wallTimeReservationSeconds"]
                for op in self.operations.values()
                if op.get("parentOperationId") == request.parentOperationId
            )
            if parent.get("wallTimeReservationSeconds", 0) > 0 and current_child_wall + request.wallTimeReservationSeconds > parent["wallTimeReservationSeconds"]:
                raise CheckpointApiError(
                    422,
                    f"Parent operation reservation exceeded: parent '{parent['operationId']}' wall-time reservation "
                    f"({parent['wallTimeReservationSeconds']}s) would be exceeded by child reservation "
                    f"{request.wallTimeReservationSeconds}s (current child allocated: {current_child_wall:.1f}s)",
                )
        # 2. Artifact cap check for provider calls
        if request.operationType in ("PROVIDER_CALL", "LLM", "LLM_CALL", "LLM_PASSAGE") and request.artifactId:
            current_artifact_wall = sum(
                op["wallTimeUsedSeconds"] if op["status"] == "COMPLETED" else op["wallTimeReservationSeconds"]
                for op in self.operations.values()
                if op.get("artifactId") == request.artifactId
                and op.get("operationType") in ("PROVIDER_CALL", "LLM", "LLM_CALL", "LLM_PASSAGE")
            )
            if current_artifact_wall + request.wallTimeReservationSeconds > self.artifact_wall_cap:
                raise CheckpointApiError(
                    422,
                    f"Artifact budget exhausted: artifact '{request.artifactId}' wall-time cap "
                    f"({self.artifact_wall_cap}s) would be exceeded by reservation {request.wallTimeReservationSeconds}s "
                    f"(current allocated: {current_artifact_wall:.1f}s)",
                )

        # Record operation
        self.operations[request.operationId] = {
            "operationId": request.operationId,
            "operationType": request.operationType,
            "parentOperationId": request.parentOperationId,
            "artifactId": request.artifactId,
            "sectionId": request.sectionId,
            "status": "RESERVED",
            "tokenReservation": request.tokenReservation,
            "tokensUsed": 0,
            "wallTimeReservationSeconds": request.wallTimeReservationSeconds,
            "wallTimeUsedSeconds": 0.0,
        }
        from datetime import datetime, timezone
        return OperationGrantResult(
            operationId=request.operationId,
            runId=request.runId,
            status="RESERVED",
            tokenReservation=request.tokenReservation,
            wallTimeReservationSeconds=request.wallTimeReservationSeconds,
            grantedAt=datetime.now(timezone.utc),
            isReplay=False,
            resultRefJson=None,
            reservationBreached=False,
            budgetBreachDetected=False,
        )

    def reconcile_operation(self, operation_id: str, wall_time_used: float, tokens_used: int = 0):
        if operation_id in self.operations:
            self.operations[operation_id]["status"] = "COMPLETED"
            self.operations[operation_id]["wallTimeUsedSeconds"] = wall_time_used
            self.operations[operation_id]["tokensUsed"] = tokens_used


def _make_passage_runtime(policy: LoopPolicy | None = None, store: CheckpointClient | None = None) -> BoundedLoopRuntime:
    owner = uuid4()
    context = LoopContext(
        runId="run_test_passage_wall",
        targetArtifactId="art_passage_s2",
        targetArtifactType=ArtifactType.PASSAGE,
        scope=IssueScope.SECTION,
        authority=AuthorityGrant(leaseOwner=owner, epoch=1),
        budgetTracker=BudgetTracker(),
    )
    effective_policy = policy or LoopPolicy.from_settings()
    effective_store = store or MockDurableStore("run_test_passage_wall")
    dummy_gen = type("DummyGen", (), {"name": "PassageGen", "version": "2.0.0"})()
    return BoundedLoopRuntime(
        context=context,
        policy=effective_policy,
        generator=dummy_gen,
        evaluators=[],
        persistence_client=effective_store,
    )


def test_passage_generate_parent_reservation_sized_for_up_to_three_calls():
    """Passage GENERATE parent reservation must account for at most 3 bounded calls (3 * 180s = 540s)."""
    runtime = _make_passage_runtime()
    intent = runtime._intent("GENERATE", version=1, tokens=40000, identity="2.0.0", extra={})
    assert intent.wall_time_reservation_seconds == 540.0
    assert intent.operation_type == "GENERATE"

def test_evaluate_and_repair_reservations_remain_unchanged():
    """EVALUATE and REPAIR reservations must remain completely unchanged (min(wall_res, 60.0))."""
    policy = LoopPolicy.from_settings()
    runtime = _make_passage_runtime(policy=policy)

    eval_intent = runtime._intent("EVALUATE", version=1, tokens=10000, identity="eval_word_count:1.0", extra={})
    expected_eval = min(policy.operation_wall_reservation_seconds, 60.0)
    assert eval_intent.wall_time_reservation_seconds == expected_eval

    repair_intent = runtime._intent("REPAIR", version=1, tokens=15000, identity="repair_sentence:1.0", extra={})
    expected_repair = min(policy.operation_wall_reservation_seconds, 60.0)
    assert repair_intent.wall_time_reservation_seconds == expected_repair


def test_question_generate_parent_reservation_sized_for_candidate_loop():
    """Question GENERATE reservations (e.g. question candidate loop) must be sized to 120.0s to match child."""
    owner = uuid4()
    context = LoopContext(
        runId="run_test_q_wall",
        targetArtifactId="art_q_slot_14",
        targetArtifactType=ArtifactType.QUESTION,
        scope=IssueScope.QUESTION,
        authority=AuthorityGrant(leaseOwner=owner, epoch=1),
        budgetTracker=BudgetTracker(),
    )
    policy = LoopPolicy.from_settings()
    dummy_gen = type("DummyGen", (), {"name": "QGen", "version": "2.0.0"})()
    runtime = BoundedLoopRuntime(
        context=context,
        policy=policy,
        generator=dummy_gen,
        evaluators=[],
        persistence_client=MockDurableStore("run_test_q_wall"),
    )
    # 1. Under nominal production settings (policy wall res = 180.0s), parent is capped to 120.0s
    q_intent = runtime._intent("GENERATE", version=1, tokens=5000, identity="1.0.0", extra={})
    assert q_intent.wall_time_reservation_seconds == 120.0

    # 2. When policy is configured for 60.0s, parent mirrors child at 60.0s
    policy_60 = policy.model_copy(update={"operation_wall_reservation_seconds": 60.0})
    rt_60 = BoundedLoopRuntime(
        context=context,
        policy=policy_60,
        generator=dummy_gen,
        evaluators=[],
        persistence_client=MockDurableStore("run_test_q_wall"),
    )
    q_intent_60 = rt_60._intent("GENERATE", version=1, tokens=5000, identity="1.0.0", extra={})
    assert q_intent_60.wall_time_reservation_seconds == 60.0

    # 3. Finite run cap clamped: when max_wall_time_seconds = 45.0, clamped to 45.0s
    tight_policy = policy.model_copy(update={"max_wall_time_seconds": 45.0})
    tight_runtime = BoundedLoopRuntime(
        context=context,
        policy=tight_policy,
        generator=dummy_gen,
        evaluators=[],
        persistence_client=MockDurableStore("run_test_q_wall"),
    )
    tight_intent = tight_runtime._intent("GENERATE", version=1, tokens=5000, identity="1.0.0", extra={})
    assert tight_intent.wall_time_reservation_seconds == 45.0

def test_non_passage_non_question_generate_reservation_remains_unchanged():
    """Non-passage, non-question GENERATE reservations (e.g. blueprint) must remain min(wall_res, 60.0)."""
    owner = uuid4()
    context = LoopContext(
        runId="run_test_bp_wall",
        targetArtifactId="art_blueprint_01",
        targetArtifactType=ArtifactType.EXAM_BLUEPRINT,
        scope=IssueScope.SECTION,
        authority=AuthorityGrant(leaseOwner=owner, epoch=1),
        budgetTracker=BudgetTracker(),
    )
    policy = LoopPolicy.from_settings()
    dummy_gen = type("DummyGen", (), {"name": "BPGen", "version": "2.0.0"})()
    runtime = BoundedLoopRuntime(
        context=context,
        policy=policy,
        generator=dummy_gen,
        evaluators=[],
        persistence_client=MockDurableStore("run_test_bp_wall"),
    )
    bp_intent = runtime._intent("GENERATE", version=1, tokens=5000, identity="1.0.0", extra={})
    assert bp_intent.wall_time_reservation_seconds == min(policy.operation_wall_reservation_seconds, 60.0)

def test_passage_generate_reservation_respects_finite_caps():
    """Passage GENERATE reservation must respect finite loop deadline / run cap if configured."""
    # 1. Finite run cap (max_wall_time_seconds = 100.0) -> clamped to 100.0s
    policy_tight_run = LoopPolicy.from_settings().model_copy(update={"max_wall_time_seconds": 100.0})
    runtime_tight_run = _make_passage_runtime(policy=policy_tight_run)
    intent_tight = runtime_tight_run._intent("GENERATE", version=1, tokens=40000, identity="2.0.0", extra={})
    assert intent_tight.wall_time_reservation_seconds == 100.0

    # 2. Finite run cap (max_wall_time_seconds = 45.0) -> clamped to 45.0s
    policy_very_tight = LoopPolicy.from_settings().model_copy(update={"max_wall_time_seconds": 45.0})
    runtime_very_tight = _make_passage_runtime(policy=policy_very_tight)
    intent_very_tight = runtime_very_tight._intent("GENERATE", version=1, tokens=40000, identity="2.0.0", extra={})
    assert intent_very_tight.wall_time_reservation_seconds == 45.0

    # 3. Unlimited run mode (max_wall_time_seconds = -1.0) -> nominal 540.0s
    policy_unlimited = LoopPolicy.from_settings().model_copy(update={
        "max_wall_time_seconds": -1.0,
        "max_total_calls": -1,
        "max_total_tokens": -1,
    })
    runtime_unlimited = _make_passage_runtime(policy=policy_unlimited)
    intent_unlimited = runtime_unlimited._intent("GENERATE", version=1, tokens=40000, identity="2.0.0", extra={})
    assert intent_unlimited.wall_time_reservation_seconds == 540.0

def test_two_sequential_provider_calls_fit_inside_generate_when_permitted_by_caps():
    """Two sequential provider calls inside one GENERATE must fit when parent reservation is sized for 3 calls at 180s."""
    store = MockDurableStore("run_demo", artifact_wall_cap=600.0, section_wall_cap=900.0)
    runtime = _make_passage_runtime(store=store)

    # 1. Parent GENERATE is granted with 540s reservation
    parent_intent = runtime._intent("GENERATE", version=1, tokens=40000, identity="2.0.0", extra={})
    parent_grant = store.grant_operation(OperationGrantRequest(
        runId="run_demo", epoch=1, leaseOwner=uuid4(),
        operationId=parent_intent.operation_id, operationType="GENERATE",
        requestHash="hash_parent", tokenReservation=parent_intent.token_reservation,
        wallTimeReservationSeconds=parent_intent.wall_time_reservation_seconds,
        artifactId="art_passage_s2",
    ))
    assert parent_grant.wallTimeReservationSeconds == 540.0

    # 2. Child 1 (initial generation): reserves 180s
    ch1 = store.grant_operation(OperationGrantRequest(
        runId="run_demo", epoch=1, leaseOwner=uuid4(),
        operationId="op_ch1", operationType="PROVIDER_CALL",
        requestHash="hash_ch1", tokenReservation=15000,
        wallTimeReservationSeconds=180.0,
        artifactId="art_passage_s2",
        parentOperationId=parent_intent.operation_id,
    ))
    assert ch1.wallTimeReservationSeconds == 180.0

    # Child 1 completes and reconciles, using 72.0s
    store.reconcile_operation("op_ch1", wall_time_used=72.0, tokens_used=8285)

    # 3. Child 2 (word-count guard re-ask): reserves 180s under the same parent GENERATE
    # With parent reservation = 540s, child allocated is 72.0s + 180.0s = 252.0s <= 540.0s -> MUST FIT!
    ch2 = store.grant_operation(OperationGrantRequest(
        runId="run_demo", epoch=1, leaseOwner=uuid4(),
        operationId="op_ch2", operationType="PROVIDER_CALL",
        requestHash="hash_ch2", tokenReservation=15000,
        wallTimeReservationSeconds=180.0,
        artifactId="art_passage_s2",
        parentOperationId=parent_intent.operation_id,
    ))
    assert ch2.wallTimeReservationSeconds == 180.0

    # Child 2 completes and reconciles using 68.0s
    store.reconcile_operation("op_ch2", wall_time_used=68.0, tokens_used=8500)
    # Two sequential calls completed successfully within parent GENERATE's wall time and token reservations.
    assert len(store.operations) == 3  # parent + ch1 + ch2
def test_provider_call_exceeding_parent_cap_rejected():
    """A child reservation exceeding the parent reservation must be rejected with 422."""
    store = MockDurableStore("run_demo", artifact_wall_cap=200.0)

    # Simulate the OLD bug: parent was granted with only 60.0s
    parent_id = "op_old_parent"
    store.grant_operation(OperationGrantRequest(
        runId="run_demo", epoch=1, leaseOwner=uuid4(),
        operationId=parent_id, operationType="GENERATE",
        requestHash="hash_old", tokenReservation=40000,
        wallTimeReservationSeconds=60.0,  # Old under-sized reservation
        artifactId="art_passage_s2",
    ))

    # Child 1 runs and uses 32.6s
    store.grant_operation(OperationGrantRequest(
        runId="run_demo", epoch=1, leaseOwner=uuid4(),
        operationId="op_c1", operationType="PROVIDER_CALL",
        requestHash="hash_c1", tokenReservation=15000,
        wallTimeReservationSeconds=60.0,
        artifactId="art_passage_s2",
        parentOperationId=parent_id,
    ))
    store.reconcile_operation("op_c1", wall_time_used=32.6, tokens_used=8285)

    # Child 2 asks for 60.0s (32.6s + 60.0s = 92.6s > 60.0s) -> MUST FAIL CLOSED with 422
    with pytest.raises(CheckpointApiError) as exc_info:
        store.grant_operation(OperationGrantRequest(
            runId="run_demo", epoch=1, leaseOwner=uuid4(),
            operationId="op_c2", operationType="PROVIDER_CALL",
            requestHash="hash_c2", tokenReservation=15000,
            wallTimeReservationSeconds=60.0,
            artifactId="art_passage_s2",
            parentOperationId=parent_id,
        ))
    assert exc_info.value.status_code == 422
    assert "Parent operation reservation exceeded" in exc_info.value.message


def test_provider_call_exceeding_artifact_cap_rejected():
    """A child reservation exceeding the artifact cap must be rejected with 422."""
    # Artifact wall cap is 80.0s, parent is 180.0s
    store = MockDurableStore("run_demo", artifact_wall_cap=80.0)
    parent_id = "op_parent_cap"
    store.grant_operation(OperationGrantRequest(
        runId="run_demo", epoch=1, leaseOwner=uuid4(),
        operationId=parent_id, operationType="GENERATE",
        requestHash="hash_p", tokenReservation=40000,
        wallTimeReservationSeconds=180.0,
        artifactId="art_passage_s2",
    ))

    # Child 1 uses 32.6s
    store.grant_operation(OperationGrantRequest(
        runId="run_demo", epoch=1, leaseOwner=uuid4(),
        operationId="op_c1", operationType="PROVIDER_CALL",
        requestHash="hash_c1", tokenReservation=15000,
        wallTimeReservationSeconds=60.0,
        artifactId="art_passage_s2",
        parentOperationId=parent_id,
    ))
    store.reconcile_operation("op_c1", wall_time_used=32.6, tokens_used=8285)

    # Child 2 asks for 60.0s (32.6s + 60.0s = 92.6s > 80.0s artifact cap) -> MUST FAIL with 422
    with pytest.raises(CheckpointApiError) as exc_info:
        store.grant_operation(OperationGrantRequest(
            runId="run_demo", epoch=1, leaseOwner=uuid4(),
            operationId="op_c2", operationType="PROVIDER_CALL",
            requestHash="hash_c2", tokenReservation=15000,
            wallTimeReservationSeconds=60.0,
            artifactId="art_passage_s2",
            parentOperationId=parent_id,
        ))
    assert exc_info.value.status_code == 422
    assert "Artifact budget exhausted" in exc_info.value.message

def test_question_candidate_child_call_fits_inside_parent_reservation():
    """Question candidate child call (120s) must fit inside the 120s parent GENERATE reservation without budget error."""
    store = MockDurableStore("run_q_demo", artifact_wall_cap=300.0, section_wall_cap=900.0)
    owner = uuid4()
    context = LoopContext(
        runId="run_q_demo",
        targetArtifactId="art_q_slot_14",
        targetArtifactType=ArtifactType.QUESTION,
        scope=IssueScope.QUESTION,
        authority=AuthorityGrant(leaseOwner=owner, epoch=1),
        budgetTracker=BudgetTracker(),
    )
    policy = LoopPolicy.from_settings()
    runtime = BoundedLoopRuntime(
        context=context,
        policy=policy,
        generator=type("DummyGen", (), {"name": "QGen", "version": "2.0.0"})(),
        evaluators=[],
        persistence_client=store,
    )

    # 1. Parent GENERATE is granted with 120s reservation
    parent_intent = runtime._intent("GENERATE", version=1, tokens=15000, identity="2.0.0", extra={})
    assert parent_intent.wall_time_reservation_seconds == 120.0
    parent_grant = store.grant_operation(OperationGrantRequest(
        runId="run_q_demo", epoch=1, leaseOwner=owner,
        operationId=parent_intent.operation_id, operationType="GENERATE",
        requestHash="hash_q_parent", tokenReservation=parent_intent.token_reservation,
        wallTimeReservationSeconds=parent_intent.wall_time_reservation_seconds,
        artifactId="art_q_slot_14",
    ))
    assert parent_grant.wallTimeReservationSeconds == 120.0

    # 2. Child candidate pool provider call requests 120.0s (e.g. pool_limit > 3)
    ch_grant = store.grant_operation(OperationGrantRequest(
        runId="run_q_demo", epoch=1, leaseOwner=owner,
        operationId="op_q_cand_pool", operationType="PROVIDER_CALL",
        requestHash="hash_q_cand_pool", tokenReservation=8000,
        wallTimeReservationSeconds=120.0,
        artifactId="art_q_slot_14",
        parentOperationId=parent_intent.operation_id,
    ))
    assert ch_grant.wallTimeReservationSeconds == 120.0

    # 3. Verify that under the OLD 60s parent reservation, the 120s child was rejected
    old_parent_id = "op_old_q_parent_60s"
    store.grant_operation(OperationGrantRequest(
        runId="run_q_demo", epoch=1, leaseOwner=owner,
        operationId=old_parent_id, operationType="GENERATE",
        requestHash="hash_old_q", tokenReservation=15000,
        wallTimeReservationSeconds=60.0,  # Old under-sized 60s reservation
        artifactId="art_q_slot_15",
    ))
    with pytest.raises(CheckpointApiError) as exc_info:
        store.grant_operation(OperationGrantRequest(
            runId="run_q_demo", epoch=1, leaseOwner=owner,
            operationId="op_old_child_120s", operationType="PROVIDER_CALL",
            requestHash="hash_old_child", tokenReservation=8000,
            wallTimeReservationSeconds=120.0,
            artifactId="art_q_slot_15",
            parentOperationId=old_parent_id,
        ))
    assert exc_info.value.status_code == 422
    assert "Parent operation reservation exceeded" in exc_info.value.message
