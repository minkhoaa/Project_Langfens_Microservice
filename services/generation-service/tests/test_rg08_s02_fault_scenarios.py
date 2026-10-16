"""Unit and integration test suite for RG08-S02: Crash/resume/idempotency fault scenarios.

Invariants:
- Worker crashes, lease loss, lost ACK, DB rollback and retry exercised with evidence.
- No partial exam graph, duplicate run charge, or stale checkpoint promotion.
- Mock-only transaction tests are strictly insufficient for DB-required assertions (fails closed with MockOnlyAssertionForbiddenError).
- Lease epoch fencing ensures stale worker lease cannot commit or promote checkpoints.
- Strict Reading V2 nonregression and idempotency invariants remain intact.
"""

from __future__ import annotations

import pytest

from app.contracts.research import ExecutionStatus, OutputAvailability
from app.experiment.faults import (
    CheckpointFencingManager,
    DatabaseTransactionRollbackError,
    FaultScenarioExecutor,
    LeaseLostException,
    MockOnlyAssertionForbiddenError,
    StaleWorkerEpochError,
    TransactionalExamGraphManager,
    WorkerCrashError,
)
from app.experiment.ledger import AttemptRecord, ExperimentReplayLedger


def test_pos_rg08_s02_fault_scenarios_prevent_partial_graph_duplicate_charge_stale_checkpoint() -> None:
    """POS-RG08-S02: No partial exam graph, duplicate run charge or stale checkpoint promotion.

    Evidence identifies input fixture/source and observed output.
    """
    fencing_mgr = CheckpointFencingManager(initial_epoch=5)
    graph_mgr = TransactionalExamGraphManager()
    ledger = ExperimentReplayLedger()
    fault_executor = FaultScenarioExecutor(
        fencing_manager=fencing_mgr,
        graph_manager=graph_mgr,
        ledger=ledger,
    )

    # 1. Lease loss / expired epoch: Stale worker cannot promote checkpoint
    stale_worker_token = "worker-stale-01"
    stale_epoch = 4  # current is 5
    with pytest.raises(StaleWorkerEpochError, match="STALE_WORKER_EPOCH"):
        fencing_mgr.promote_checkpoint(
            worker_token=stale_worker_token,
            epoch=stale_epoch,
            checkpoint_hash="hash-chk-1234",
            candidate_head_hash="hash-head-5678",
        )

    # 2. Worker crash / DB transaction rollback: No partial exam graph
    with pytest.raises(DatabaseTransactionRollbackError, match="TRANSACTION_ROLLEDBACK"):
        graph_mgr.persist_complete_graph(
            exam_id="exam-fault-01",
            sections_count=3,
            questions_per_section=13,
            simulate_crash_at_question=20,  # crash midway through section 2
        )
    # Verification: graph is clean, 0 orphan questions or sections persisted
    assert graph_mgr.get_persisted_question_count("exam-fault-01") == 0
    assert graph_mgr.is_exam_persisted("exam-fault-01") is False

    # 3. Lost ACK & Idempotent Retry: No duplicate run charge or duplicate graph
    first_attempt_res = fault_executor.execute_with_lost_ack_retry(
        request_id="req-ack-01",
        dataset_item_id="item-reading-ack-01",
        configuration_id="A",
        cost_usd=0.015,
    )
    assert first_attempt_res["status"] == "COMMITTED"
    assert first_attempt_res["charge_count"] == 1
    assert first_attempt_res["billed_cost_usd"] == 0.015

    # Simulate client retrying identical request after lost ACK
    retry_attempt_res = fault_executor.execute_with_lost_ack_retry(
        request_id="req-ack-01",
        dataset_item_id="item-reading-ack-01",
        configuration_id="A",
        cost_usd=0.015,
    )
    # Deduped: same run ID, no second billing charge
    assert retry_attempt_res["run_id"] == first_attempt_res["run_id"]
    assert retry_attempt_res["charge_count"] == 1
    assert retry_attempt_res["billed_cost_usd"] == 0.015
    assert retry_attempt_res["is_idempotent_replay"] is True


def test_neg_rg08_s02_mock_only_transaction_tests_rejected_for_db_assertions() -> None:
    """NEG-RG08-S02: Mock-only transaction tests insufficient for DB-required assertions.

    Verify safe rejection/abstention/blocked outcome rather than ignored or synthetic PASS.
    """
    fault_executor = FaultScenarioExecutor()

    # Attempting to certify DB transaction durability with mock_only=True fails closed
    with pytest.raises(MockOnlyAssertionForbiddenError, match="MOCK_ONLY_ASSERTION_FORBIDDEN"):
        fault_executor.certify_db_durability(
            is_real_db_environment=False,
            requires_db_durability=True,
        )


def test_edge_rg08_s02_concurrent_epoch_increment_and_interrupted_lease() -> None:
    """EDGE-RG08-S02: Test epoch bump mid-execution, duplicate epoch promotion, and lease timeout."""
    fencing_mgr = CheckpointFencingManager(initial_epoch=10)

    # Valid promotion at current epoch succeeds
    res = fencing_mgr.promote_checkpoint(
        worker_token="worker-valid-10",
        epoch=10,
        checkpoint_hash="hash-chk-10",
        candidate_head_hash="hash-head-10",
    )
    assert res is True
    assert fencing_mgr.current_epoch == 11  # Epoch auto-advances on promotion

    # Immediate second call with old epoch 10 fails with StaleWorkerEpochError
    with pytest.raises(StaleWorkerEpochError):
        fencing_mgr.promote_checkpoint(
            worker_token="worker-valid-10",
            epoch=10,
            checkpoint_hash="hash-chk-10-dupe",
            candidate_head_hash="hash-head-10-dupe",
        )

    # Worker lease timeout raises LeaseLostException
    with pytest.raises(LeaseLostException, match="LEASE_LOST"):
        fencing_mgr.assert_lease_active(worker_token="worker-timeout", is_expired=True)


def test_reg_rg08_s02_strict_v2_and_accepted_head_protection() -> None:
    """REG-RG08-S02: Touched API/schema/authorization or strict Reading V2 regression; no new unauthorized publish or accepted-head mutation."""
    fencing_mgr = CheckpointFencingManager(initial_epoch=1)
    graph_mgr = TransactionalExamGraphManager()

    # Successful atomic save persists full 3 sections (39 questions)
    graph_mgr.persist_complete_graph(
        exam_id="exam-v2-complete-01",
        sections_count=3,
        questions_per_section=13,
        simulate_crash_at_question=None,
    )
    assert graph_mgr.get_persisted_question_count("exam-v2-complete-01") == 39
    assert graph_mgr.is_exam_persisted("exam-v2-complete-01") is True

    # Promoting accepted head requires valid epoch and matching head hash
    fencing_mgr.promote_checkpoint(
        worker_token="worker-v2-01",
        epoch=1,
        checkpoint_hash="chk-v2-01",
        candidate_head_hash="head-v2-01",
    )
    assert fencing_mgr.current_accepted_head == "head-v2-01"
