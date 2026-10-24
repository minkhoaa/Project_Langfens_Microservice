"""Canonical Loop Engine Decision and State Machine Contracts."""

from __future__ import annotations

from datetime import datetime, timezone
from enum import Enum
from typing import TYPE_CHECKING, Dict, Optional, Set, Tuple, Union
from pydantic import Field

from .base import CanonicalBaseModel
from .issue import IssueScope

if TYPE_CHECKING:
    from .evaluation import EvaluationResult


class DecisionType(str, Enum):
    PASS = "PASS"
    REPAIR = "REPAIR"
    REGENERATE = "REGENERATE"
    ESCALATE = "ESCALATE"
    FAIL = "FAIL"

class LoopReason(str, Enum):
    ACCEPTED = "ACCEPTED"
    REPAIRABLE_DEFECTS = "REPAIRABLE_DEFECTS"
    UNREPAIRABLE_DEFECTS = "UNREPAIRABLE_DEFECTS"
    SOURCE_INSUFFICIENT = "SOURCE_INSUFFICIENT"
    EVALUATOR_ERROR = "EVALUATOR_ERROR"
    MISSING_EVALUATOR = "MISSING_EVALUATOR"
    STALE_DEPENDENCY = "STALE_DEPENDENCY"
    UNRESOLVED_BLOCKER = "UNRESOLVED_BLOCKER"
    NO_PROGRESS = "NO_PROGRESS"
    OSCILLATION = "OSCILLATION"
    MAX_VERSIONS = "MAX_VERSIONS"
    MAX_REPAIRS = "MAX_REPAIRS"
    CALL_CAP = "CALL_CAP"
    TOKEN_CAP = "TOKEN_CAP"
    WALL_TIME_CAP = "WALL_TIME_CAP"
    CANCELLED = "CANCELLED"
    LEASE_LOST = "LEASE_LOST"
    UNKNOWN_OUTCOME = "UNKNOWN_OUTCOME"
    INVALID_OUTPUT = "INVALID_OUTPUT"
    PERSISTENCE_ERROR = "PERSISTENCE_ERROR"

class LoopState(str, Enum):
    INITIALIZED = "INITIALIZED"
    INGESTING = "INGESTING"
    EVIDENCE_EXTRACTING = "EVIDENCE_EXTRACTING"
    BLUEPRINTING = "BLUEPRINTING"
    DRAFTING = "DRAFTING"
    EVALUATING = "EVALUATING"
    REPAIRING = "REPAIRING"
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"
    ABORTED = "ABORTED"


VALID_TRANSITIONS: Dict[LoopState, Set[LoopState]] = {
    LoopState.INITIALIZED: {LoopState.INGESTING, LoopState.FAILED, LoopState.ABORTED},
    LoopState.INGESTING: {LoopState.EVIDENCE_EXTRACTING, LoopState.FAILED, LoopState.ABORTED},
    LoopState.EVIDENCE_EXTRACTING: {LoopState.BLUEPRINTING, LoopState.FAILED, LoopState.ABORTED},
    LoopState.BLUEPRINTING: {LoopState.DRAFTING, LoopState.FAILED, LoopState.ABORTED},
    LoopState.DRAFTING: {LoopState.EVALUATING, LoopState.FAILED, LoopState.ABORTED},
    LoopState.EVALUATING: {
        LoopState.COMPLETED,
        LoopState.REPAIRING,
        LoopState.DRAFTING,
        LoopState.FAILED,
        LoopState.ABORTED,
    },
    LoopState.REPAIRING: {LoopState.EVALUATING, LoopState.DRAFTING, LoopState.FAILED, LoopState.ABORTED},
    LoopState.COMPLETED: set(),
    LoopState.FAILED: set(),
    LoopState.ABORTED: set(),
}


def validate_transition(current: LoopState, next_state: LoopState) -> bool:
    """Validates whether a transition from current state to next state is legally allowed."""
    allowed = VALID_TRANSITIONS.get(current, set())
    return next_state in allowed


def validate_loop_decision(
    decision: LoopDecision,
    latest_evaluation: Optional[EvaluationResult] = None,
) -> Tuple[bool, Optional[str]]:
    """Fail-closed validator: validates decision legality against state transitions AND evaluation results.

    A decision of PASS or next_state COMPLETED is strictly inadmissible without a matching,
    passing EvaluationResult with zero open critical issues.
    """
    # 1. State machine transition check
    if not decision.is_legal_transition():
        return False, f"Illegal state transition from {decision.current_state} to {decision.next_state}"

    # 2. Fail-closed PASS / COMPLETED rules
    if decision.decision == DecisionType.PASS or decision.next_state == LoopState.COMPLETED:
        if latest_evaluation is None:
            return False, "Fail-closed rejection: decision PASS or transition to COMPLETED requires a non-null EvaluationResult"
        # Import dynamically if needed to avoid circular import at runtime
        from .evaluation import EvaluationStatus

        if latest_evaluation.status != EvaluationStatus.PASS:
            return False, f"Fail-closed rejection: evaluation status is {latest_evaluation.status.value}, cannot decide PASS"
        if not latest_evaluation.is_pass():
            return False, "Fail-closed rejection: evaluation contains open CRITICAL issues, cannot decide PASS"
        if decision.evaluation_ref != latest_evaluation.evaluation_id:
            return (
                False,
                f"Fail-closed rejection: decision evaluationRef '{decision.evaluation_ref}' does not match latest evaluationId '{latest_evaluation.evaluation_id}'",
            )

    return True, None


class LoopDecision(CanonicalBaseModel):
    """Explicit decision made by the loop controller directing the next state transition."""

    decision_id: str = Field(..., alias="decisionId")
    run_id: str = Field(..., alias="runId")
    decision: DecisionType = Field(..., alias="decision")
    decision_type: Optional[DecisionType] = Field(default=None, alias="decisionType")
    current_state: LoopState = Field(..., alias="currentState")
    next_state: LoopState = Field(..., alias="nextState")
    reason: str
    target_scope: Union[IssueScope, str] = Field(..., alias="targetScope")
    target_artifact_id: Optional[str] = Field(default=None, alias="targetArtifactId")
    reason_code: Optional[LoopReason] = Field(default=None, alias="reasonCode")
    budget_reservation_id: Optional[str] = Field(default=None, alias="budgetReservationId")
    expected_version: Optional[int] = Field(default=None, alias="expectedVersion")
    evaluation_ref: Optional[str] = Field(default=None, alias="evaluationRef")
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        alias="createdAt",
    )

    def model_post_init(self, __context: object) -> None:
        if self.decision_type is None:
            object.__setattr__(self, "decision_type", self.decision)

    def is_legal_transition(self) -> bool:
        """Validates that current_state -> next_state is valid according to the state machine."""
        return validate_transition(self.current_state, self.next_state)

    def is_admissible(self, latest_evaluation: Optional[EvaluationResult] = None) -> bool:
        """Evaluates whether this decision is admissible under fail-closed rules."""
        valid, _ = validate_loop_decision(self, latest_evaluation)
        return valid
