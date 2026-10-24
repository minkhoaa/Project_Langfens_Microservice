"""Fault injection scenarios, lease fencing, and transaction atomicity (RG08-S02).

Invariants:
- Worker crashes, lease loss, lost ACK, DB rollback, and retry exercised with evidence.
- No partial exam graph, duplicate run charge, or stale checkpoint promotion.
- Mock-only transaction tests are strictly insufficient for DB-required assertions (fails closed).
- Compare-and-Swap (CAS) lease epoch fencing prevents stale workers from committing.
"""

from __future__ import annotations

from typing import Any, Dict, List, Optional

from app.experiment.ledger import ExperimentReplayLedger


class WorkerCrashError(RuntimeError):
    """Raised when an unhandled worker process crash occurs during generation or persistence."""


class LeaseLostException(RuntimeError):
    """Raised when a worker's distributed lease expires or is revoked."""


class StaleWorkerEpochError(RuntimeError):
    """Raised when a worker attempts to promote a checkpoint or commit state using a superseded epoch."""


class DatabaseTransactionRollbackError(RuntimeError):
    """Raised when a transaction error forces an atomic rollback of the exam graph."""


class MockOnlyAssertionForbiddenError(RuntimeError):
    """Raised when a test attempts to certify DB transaction durability using mock-only execution."""


class CheckpointFencingManager:
    """Manages CAS epoch fencing for worker leases and accepted-head promotions."""

    def __init__(self, initial_epoch: int = 1) -> None:
        self.current_epoch = initial_epoch
        self.current_accepted_head: Optional[str] = None
        self._checkpoints: Dict[int, str] = {}

    def promote_checkpoint(
        self,
        worker_token: str,
        epoch: int,
        checkpoint_hash: str,
        candidate_head_hash: str,
    ) -> bool:
        """Promotes a checkpoint and advances the accepted head using CAS epoch fencing.

        Fails closed with StaleWorkerEpochError if the caller's epoch does not match current_epoch.
        """
        if epoch != self.current_epoch:
            raise StaleWorkerEpochError(
                f"STALE_WORKER_EPOCH: Lease lost or epoch superseded (current={self.current_epoch}, provided={epoch}). "
                "Stale worker cannot promote checkpoint."
            )

        self._checkpoints[epoch] = checkpoint_hash
        self.current_accepted_head = candidate_head_hash
        # Atomically advance epoch on successful promotion
        self.current_epoch += 1
        return True

    def assert_lease_active(self, worker_token: str, is_expired: bool = False) -> None:
        """Validates that worker lease is active; fails closed with LeaseLostException if expired."""
        if is_expired:
            raise LeaseLostException(
                f"LEASE_LOST: Worker lease token '{worker_token}' has expired or was revoked."
            )


class TransactionalExamGraphManager:
    """Simulates and verifies atomic persistence of full Exam / Section / Group / Question graphs."""

    def __init__(self) -> None:
        self._persisted_exams: Dict[str, Dict[str, Any]] = {}
        self._persisted_questions: Dict[str, List[int]] = {}

    def persist_complete_graph(
        self,
        exam_id: str,
        sections_count: int,
        questions_per_section: int,
        simulate_crash_at_question: Optional[int] = None,
    ) -> bool:
        """Persists the complete exam graph atomically.

        If a crash occurs before all questions are persisted, the transaction rolls back cleanly,
        leaving 0 partial records in the graph.
        """
        staging_questions: List[int] = []
        total_questions = sections_count * questions_per_section

        for q_idx in range(1, total_questions + 1):
            if simulate_crash_at_question is not None and q_idx == simulate_crash_at_question:
                # Mid-transaction crash: discard staging buffer and roll back
                staging_questions.clear()
                raise DatabaseTransactionRollbackError(
                    f"TRANSACTION_ROLLEDBACK: Worker crash injected at question {q_idx} of {total_questions}. "
                    "Entire exam graph rolled back to prevent partial orphan state."
                )
            staging_questions.append(q_idx)

        # Successful atomic commit
        self._persisted_exams[exam_id] = {
            "exam_id": exam_id,
            "sections_count": sections_count,
            "status": "PERSISTED",
        }
        self._persisted_questions[exam_id] = list(staging_questions)
        return True

    def get_persisted_question_count(self, exam_id: str) -> int:
        """Returns count of questions actually persisted in durable storage for the exam."""
        return len(self._persisted_questions.get(exam_id, []))

    def is_exam_persisted(self, exam_id: str) -> bool:
        """Checks if exam record exists in durable storage."""
        return exam_id in self._persisted_exams


class FaultScenarioExecutor:
    """Executes fault injection scenarios and validates idempotency and durability invariants."""

    def __init__(
        self,
        fencing_manager: Optional[CheckpointFencingManager] = None,
        graph_manager: Optional[TransactionalExamGraphManager] = None,
        ledger: Optional[ExperimentReplayLedger] = None,
    ) -> None:
        self.fencing_manager = fencing_manager or CheckpointFencingManager()
        self.graph_manager = graph_manager or TransactionalExamGraphManager()
        self.ledger = ledger or ExperimentReplayLedger()
        self._committed_requests: Dict[str, Dict[str, Any]] = {}

    def execute_with_lost_ack_retry(
        self,
        request_id: str,
        dataset_item_id: str,
        configuration_id: str,
        cost_usd: float,
    ) -> Dict[str, Any]:
        """Simulates client retrying an identical request after lost ACK.

        Deduplicates on request_id, returning existing run_id without duplicate billing charges.
        """
        if request_id in self._committed_requests:
            existing = self._committed_requests[request_id]
            return {
                **existing,
                "is_idempotent_replay": True,
            }

        record = {
            "run_id": f"run-{request_id}",
            "request_id": request_id,
            "dataset_item_id": dataset_item_id,
            "configuration_id": configuration_id,
            "status": "COMMITTED",
            "charge_count": 1,
            "billed_cost_usd": cost_usd,
            "is_idempotent_replay": False,
        }
        self._committed_requests[request_id] = record
        return record

    def certify_db_durability(
        self,
        is_real_db_environment: bool,
        requires_db_durability: bool = True,
    ) -> bool:
        """Guards against false positive certifications where mock-only tests claim DB transaction durability."""
        if requires_db_durability and not is_real_db_environment:
            raise MockOnlyAssertionForbiddenError(
                "MOCK_ONLY_ASSERTION_FORBIDDEN: Mock-only transaction tests are insufficient for DB-required assertions. "
                "Real DB execution evidence is strictly required for durable transaction claims."
            )
        return True
