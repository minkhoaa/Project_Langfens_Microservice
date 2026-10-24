"""Research assignment, dispatch, output and independent-evaluation accounting.

Assignments are the denominator; retries and question evaluations are observations.
Unknown telemetry is nullable and never priced using implicit provider rates.
"""
from __future__ import annotations

import hashlib
import copy
import fcntl
import os
from pathlib import Path
import tempfile
from typing import Any, Dict, List, Literal, Optional

from pydantic import Field

from app.contracts.base import CanonicalBaseModel
from app.contracts.research import ExecutionStatus, ExperimentAssignment, GenerationResult, OutputAvailability
from app.persistence.grammar_store import ResearchPublicationForbiddenError
from app.contracts.artifact import canonical_json_dump


class DuplicateAttemptError(RuntimeError):
    """An immutable assignment or attempt would be overwritten."""


class OrphanRetryError(ValueError):
    """A retry does not extend the same assignment's latest attempt."""


class ZeroBilledMissingTelemetryError(RuntimeError):
    """Missing failed-call telemetry was presented as exact zero usage."""


class AttemptRecord(CanonicalBaseModel):
    """Finished attempt; is_terminal closes the assignment's retry policy."""

    attempt_id: str = Field(..., min_length=1)
    assignment_id: str = Field(..., min_length=1)
    dataset_item_id: str = Field(..., min_length=1)
    configuration_id: Literal["A", "B", "C"]
    attempt_number: int = Field(default=1, ge=1)
    parent_attempt_id: Optional[str] = None
    execution_status: ExecutionStatus
    output_availability: OutputAvailability
    failure_code: Optional[str] = None
    usage_call_count: int = Field(default=1, ge=0)
    usage_prompt_tokens: Optional[int] = Field(default=None, ge=0)
    usage_completion_tokens: Optional[int] = Field(default=None, ge=0)
    usage_total_tokens: Optional[int] = Field(default=None, ge=0)
    usage_confidence: Literal["EXACT", "ESTIMATED", "UNKNOWN"] = "UNKNOWN"
    token_source: str = "UNKNOWN"
    cost_usd: Optional[float] = Field(default=None, ge=0, allow_inf_nan=False)
    cost_source: str = "UNKNOWN"
    estimated_cost_usd: Optional[float] = Field(default=None, ge=0, allow_inf_nan=False)
    confirmed_billing_usd: Optional[float] = Field(default=None, ge=0, allow_inf_nan=False)
    latency_ms: Optional[float] = Field(default=None, ge=0, allow_inf_nan=False)
    provenance: Dict[str, Any] = Field(default_factory=dict)
    is_terminal: bool = True


class StartedAttempt(CanonicalBaseModel):
    """Recorded before dispatch so interruption cannot erase a started request."""

    attempt_id: str
    assignment_id: str
    dataset_item_id: str
    configuration_id: Literal["A", "B", "C"]
    attempt_number: int
    parent_attempt_id: Optional[str] = None


class CampaignReconciliationSummary(CanonicalBaseModel):
    total_frozen_assignments: int
    total_attempts: int
    total_reconciled: int
    is_fully_reconciled: bool
    arm_denominators: Dict[str, int]
    by_arm: Dict[str, Dict[str, int]]


class LedgerCheckpoint(CanonicalBaseModel):
    schema_version: Literal["research-ledger-v1"] = "research-ledger-v1"
    assignments: List[ExperimentAssignment]
    fixture_hashes: Dict[str, str]
    started: List[StartedAttempt]
    attempts: List[AttemptRecord]
    outputs: Dict[str, GenerationResult]
    evaluations: Dict[str, Dict[str, Any]]


def content_hash(result: GenerationResult) -> Optional[str]:
    if result.generated_content is None:
        return None
    serialized = canonical_json_dump(result.generated_content.model_dump(mode="json"))
    return hashlib.sha256(serialized.encode()).hexdigest()


def output_is_evaluable(result: GenerationResult) -> bool:
    content = result.generated_content
    return bool(content and content.context_text.strip() and content.questions
                and result.output_availability in (OutputAvailability.PARSEABLE, OutputAvailability.NORMALIZED))


class ExperimentReplayLedger:
    """Append-only logical ledger with explicit dispatch and retry lineage."""

    def __init__(self, checkpoint_path: Optional[str | Path] = None) -> None:
        self._frozen_assignments: Dict[str, ExperimentAssignment] = {}
        self._attempts_by_id: Dict[str, AttemptRecord] = {}
        self._attempts_by_assignment: Dict[str, List[AttemptRecord]] = {}
        self._started: Dict[str, StartedAttempt] = {}
        self._results: Dict[str, GenerationResult] = {}
        self._evaluations: Dict[str, Dict[str, Any]] = {}
        self._fixture_hashes: Dict[str, str] = {}
        self._checkpoint_path = Path(checkpoint_path) if checkpoint_path is not None else None
        self._lock = None
        self._restoring = False
        if self._checkpoint_path is not None:
            self._checkpoint_path.parent.mkdir(parents=True, exist_ok=True)
            self._lock = self._checkpoint_path.with_suffix(".lock").open("a")
            try:
                fcntl.flock(self._lock.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
                if self._checkpoint_path.exists():
                    self._restore_checkpoint(LedgerCheckpoint.model_validate_json(self._checkpoint_path.read_text()))
            except BaseException:
                self.close()
                raise

    @property
    def is_durable(self) -> bool:
        return self._checkpoint_path is not None and self._lock is not None and not self._lock.closed

    def close(self) -> None:
        if self._lock is not None:
            self._lock.close()

    def _checkpoint(self) -> None:
        if self._checkpoint_path is None or self._restoring:
            return
        if not self.is_durable:
            raise RuntimeError("Research ledger is closed")
        payload = canonical_json_dump(self.snapshot_payload())
        descriptor, temporary = tempfile.mkstemp(dir=self._checkpoint_path.parent, prefix=".research-ledger-")
        try:
            with os.fdopen(descriptor, "w") as stream:
                stream.write(payload)
                stream.flush()
                os.fsync(stream.fileno())
            os.replace(temporary, self._checkpoint_path)
            directory = os.open(self._checkpoint_path.parent, os.O_DIRECTORY)
            try:
                os.fsync(directory)
            finally:
                os.close(directory)
        finally:
            if os.path.exists(temporary):
                os.unlink(temporary)

    def _restore_checkpoint(self, checkpoint: LedgerCheckpoint) -> None:
        self._restoring = True
        try:
            self.freeze_assignments(checkpoint.assignments)
            for item, digest in checkpoint.fixture_hashes.items():
                self.bind_fixture(item, digest)
            for att in sorted(checkpoint.attempts, key=lambda a: (a.assignment_id, a.attempt_number)):
                self.record_attempt(att)
            for started in checkpoint.started:
                if started.attempt_id not in self._attempts_by_id:
                    self.start_attempt(started)
                elif self._started[started.attempt_id] != started:
                    raise ValueError("Checkpoint dispatch does not match completed attempt")
            for attempt_id, output in checkpoint.outputs.items():
                self.record_output(attempt_id, output)
            for attempt_id, evaluation in checkpoint.evaluations.items():
                self._record_evaluation_payload(attempt_id, evaluation)
        finally:
            self._restoring = False

    def freeze_assignments(self, assignments: List[ExperimentAssignment]) -> None:
        for asg in assignments:
            existing = self._frozen_assignments.get(asg.assignment_id)
            if existing is not None and existing != asg:
                raise DuplicateAttemptError(f"Cannot overwrite frozen assignment '{asg.assignment_id}' with conflicting configuration.")
            self._frozen_assignments[asg.assignment_id] = asg.model_copy(deep=True)
            self._attempts_by_assignment.setdefault(asg.assignment_id, [])
        self._checkpoint()

    def bind_fixture(self, item_id: str, digest: str) -> None:
        if item_id in self._fixture_hashes and self._fixture_hashes[item_id] != digest:
            raise ValueError("Frozen source/task/prompt/model fixture changed on resume")
        self._fixture_hashes[item_id] = digest
        self._checkpoint()

    def get_frozen_assignments(self) -> List[ExperimentAssignment]:
        return [self._frozen_assignments[k].model_copy(deep=True) for k in sorted(self._frozen_assignments)]

    def _validate_identity(self, attempt: Any) -> None:
        asg = self._frozen_assignments.get(attempt.assignment_id)
        if asg is None or (asg.dataset_item_id, asg.configuration_id) != (attempt.dataset_item_id, attempt.configuration_id):
            raise ValueError("Attempt does not match a frozen assignment")

    def _validate_lineage(self, attempt: Any) -> None:
        lineage = self._attempts_by_assignment.get(attempt.assignment_id, [])
        if attempt.attempt_number == 1:
            if attempt.parent_attempt_id or lineage:
                raise OrphanRetryError("First attempt cannot have a parent or overwrite an existing lineage")
            return
        parent = self._attempts_by_id.get(attempt.parent_attempt_id)
        if parent is None:
            raise OrphanRetryError(f"Parent attempt '{attempt.parent_attempt_id}' not found for retry attempt '{attempt.attempt_id}'.")
        if (not lineage or parent != lineage[-1] or parent.assignment_id != attempt.assignment_id
                or parent.attempt_number + 1 != attempt.attempt_number or parent.is_terminal):
            raise OrphanRetryError("Retry must extend the same assignment's latest nonterminal attempt")

    def start_attempt(self, started: StartedAttempt) -> None:
        self._validate_identity(started)
        self._validate_lineage(started)
        if started.attempt_id in self._started or started.attempt_id in self._attempts_by_id:
            raise DuplicateAttemptError(f"Duplicate attempt '{started.attempt_id}' already registered.")
        if any(s.assignment_id == started.assignment_id and s.attempt_id not in self._attempts_by_id
               for s in self._started.values()):
            raise ValueError("Assignment already has an unresolved dispatch; reconcile it before retrying")
        self._started[started.attempt_id] = started
        self._checkpoint()

    def record_attempt(self, attempt: AttemptRecord) -> None:
        if attempt.attempt_id in self._attempts_by_id:
            raise DuplicateAttemptError(f"Duplicate attempt '{attempt.attempt_id}' already registered.")
        self._validate_identity(attempt)
        self._validate_lineage(attempt)
        started = StartedAttempt(**{name: getattr(attempt, name) for name in StartedAttempt.model_fields})
        if attempt.attempt_id in self._started and self._started[attempt.attempt_id] != started:
            raise ValueError("Finished attempt differs from its recorded dispatch")
        if (attempt.execution_status != ExecutionStatus.COMPLETED and attempt.usage_total_tokens == 0
                and attempt.usage_confidence == "EXACT" and attempt.usage_call_count > 0):
            raise ZeroBilledMissingTelemetryError("Failed output cannot be billed as zero tokens with EXACT confidence when telemetry is missing.")
        self._started.setdefault(attempt.attempt_id, started)
        self._attempts_by_id[attempt.attempt_id] = attempt.model_copy(deep=True)
        self._attempts_by_assignment[attempt.assignment_id].append(attempt.model_copy(deep=True))
        self._checkpoint()

    def record_output(self, attempt_id: str, result: GenerationResult) -> None:
        att = self._attempts_by_id[attempt_id]
        if (result.dataset_item_id, result.configuration_id, result.execution_status, result.output_availability) != (
                att.dataset_item_id, att.configuration_id, att.execution_status, att.output_availability):
            raise ValueError("Output identity/state differs from its attempt")
        if attempt_id in self._results:
            raise DuplicateAttemptError("Output already recorded")
        self._results[attempt_id] = result.model_copy(deep=True)
        self._checkpoint()

    def record_evaluation(self, attempt_id: str, evaluation: Any) -> None:
        self._record_evaluation_payload(attempt_id, evaluation.model_dump(mode="json"))

    def _record_evaluation_payload(self, attempt_id: str, payload: Dict[str, Any]) -> None:
        result = self._results[attempt_id]
        if not output_is_evaluable(result):
            raise ValueError("No evaluable output for this attempt")
        if payload.get("dataset_item_id") != result.dataset_item_id or payload.get("output_sha256") != content_hash(result):
            raise ValueError("Evaluation is not bound to this output")
        count = payload.get("evaluated_question_count")
        if not isinstance(count, int) or isinstance(count, bool) or not 0 < count <= len(result.generated_content.questions):
            raise ValueError("Evaluation must retain a positive actual assessed-question count")
        if attempt_id in self._evaluations:
            raise DuplicateAttemptError("Independent evaluation already recorded; silent rescore forbidden")
        self._evaluations[attempt_id] = copy.deepcopy(payload)
        self._checkpoint()
    def get_evaluation(self, attempt_id: str) -> Optional[Dict[str, Any]]:
        ev = self._evaluations.get(attempt_id)
        return copy.deepcopy(ev) if ev else None

    def get_attempt(self, attempt_id: str) -> Optional[AttemptRecord]:
        att = self._attempts_by_id.get(attempt_id)
        return att.model_copy(deep=True) if att else None

    def get_attempt_lineage(self, assignment_id: str) -> List[AttemptRecord]:
        return [a.model_copy(deep=True) for a in self._attempts_by_assignment.get(assignment_id, [])]

    def get_all_attempts(self) -> List[AttemptRecord]:
        return [a.model_copy(deep=True) for a in self._attempts_by_id.values()]

    def get_started_attempts(self) -> List[StartedAttempt]:
        return list(self._started.values())

    def get_output(self, attempt_id: str) -> Optional[GenerationResult]:
        result = self._results.get(attempt_id)
        return result.model_copy(deep=True) if result else None

    def snapshot_payload(self) -> Dict[str, Any]:
        return {
            "schema_version": "research-ledger-v1",
            "assignments": [a.model_dump(mode="json") for a in self.get_frozen_assignments()],
            "fixture_hashes": dict(self._fixture_hashes),
            "started": [self._started[k].model_dump(mode="json") for k in sorted(self._started)],
            "attempts": [self._attempts_by_id[k].model_dump(mode="json") for k in sorted(self._attempts_by_id)],
            "outputs": {k: v.model_dump(mode="json") for k, v in self._results.items()},
            "evaluations": copy.deepcopy(self._evaluations),
        }

    def get_reconciled_denominators(self) -> Dict[str, Any]:
        status_map = {s: s.value.lower() for s in ExecutionStatus}
        categories = [*status_map.values(), "unattempted", "in_progress"]
        by_arm = {arm: dict.fromkeys(["assigned", "started", "attempts", "retried", "generated", "evaluable", "evaluated", *categories], 0)
                  for arm in ("A", "B", "C")}
        for asg in self._frozen_assignments.values():
            counts = by_arm[asg.configuration_id]
            counts["assigned"] += 1
            starts = [s for s in self._started.values() if s.assignment_id == asg.assignment_id]
            lineage = self._attempts_by_assignment[asg.assignment_id]
            counts["started"] += bool(starts)
            counts["attempts"] += len(starts)
            counts["retried"] += max(0, len(starts) - 1)
            if not starts:
                counts["unattempted"] += 1
                continue
            latest = lineage[-1] if lineage else None
            unresolved = any(s.attempt_id not in self._attempts_by_id for s in starts)
            counts["in_progress" if unresolved or not latest or not latest.is_terminal else status_map[latest.execution_status]] += 1
            if latest:
                result = self._results.get(latest.attempt_id)
                counts["generated"] += bool(result and result.generated_content is not None)
                counts["evaluable"] += bool(result and output_is_evaluable(result))
                evaluation = self._evaluations.get(latest.attempt_id)
                counts["evaluated"] += bool(evaluation and evaluation.get("evaluated_question_count", 0) > 0)
        total = len(self._frozen_assignments)
        reconciled = sum(counts[k] for counts in by_arm.values() for k in categories)
        if total != reconciled:
            raise ValueError("Campaign denominator reconciliation failed")
        return {"total_frozen_assignments": total, "total_unattempted": sum(c["unattempted"] for c in by_arm.values()),
                "total_reconciled": reconciled, "is_fully_reconciled": total == reconciled,
                "arm_denominators": {arm: c["assigned"] for arm, c in by_arm.items()}, "by_arm": by_arm}

    def reconcile_campaign(self) -> CampaignReconciliationSummary:
        res = self.get_reconciled_denominators()
        return CampaignReconciliationSummary(**{k: res[k] for k in CampaignReconciliationSummary.model_fields if k != "total_attempts"},
                                             total_attempts=len(self._started))

    def publish_to_production(self, attempt_id: str, admin_user_id: str) -> None:
        raise ResearchPublicationForbiddenError(
            f"RESEARCH_PUBLICATION_FORBIDDEN: Attempt {attempt_id} is in research mode and cannot be published to production exams.")
