"""Strict, versioned repair action and repair plan contracts for Langfens Loop Engine."""

from __future__ import annotations

from enum import Enum
from typing import Dict, List, Optional, Set
from pydantic import Field, field_validator

from app.contracts.base import CanonicalBaseModel
from app.contracts.issue import IssueCode


class RepairAction(str, Enum):
    """Authoritative, closed enumeration of permitted surgical repair actions for MiniMax-M3 planning."""
    REPHRASE_STEM = "REPHRASE_STEM"
    SWAP_DISTRACTOR = "SWAP_DISTRACTOR"
    REFINE_CLOZE_TARGET = "REFINE_CLOZE_TARGET"
    CLARIFY_NOT_GIVEN_BOUNDARY = "CLARIFY_NOT_GIVEN_BOUNDARY"
    REGENERATE_DISTINCT_CANDIDATE = "REGENERATE_DISTINCT_CANDIDATE"


class RepairPlanValidationError(ValueError):
    """Raised when an M3-generated repair plan breaches schema, bounds, or claim constraints."""
    pass


class RepairPlan(CanonicalBaseModel):
    """Structured diagnostic repair plan produced by reasoning planner (MiniMax-M3).

    M3 is strictly advisory and outputs this schema. It never mutates domain artifacts or claims directly.
    """
    issue_code: IssueCode = Field(..., alias="issueCode")
    target_question: int = Field(..., alias="targetQuestion", ge=1)
    repair_action: RepairAction = Field(..., alias="repairAction")
    diagnosis: str = Field(..., min_length=5)
    repair_constraints: List[str] = Field(default_factory=list, alias="repairConstraints")
    preserve_evidence_claim_ref: str = Field(..., alias="preserveEvidenceClaimRef", min_length=1)
    expected_correction: Optional[str] = Field(default=None, alias="expectedCorrection")

    @field_validator("repair_constraints")
    @classmethod
    def validate_constraints_non_empty(cls, v: List[str]) -> List[str]:
        cleaned = [c.strip() for c in v if c and str(c).strip()]
        return cleaned


# Strict compatibility matrix between detected failure IssueCode and permitted RepairAction
ALLOWED_ACTIONS_FOR_ISSUE: Dict[IssueCode, Set[RepairAction]] = {
    IssueCode.AMBIGUOUS_ANSWER: {
        RepairAction.REPHRASE_STEM,
        RepairAction.SWAP_DISTRACTOR,
        RepairAction.REFINE_CLOZE_TARGET,
        RepairAction.CLARIFY_NOT_GIVEN_BOUNDARY,
    },
    IssueCode.BAD_DISTRACTOR: {
        RepairAction.SWAP_DISTRACTOR,
        RepairAction.REPHRASE_STEM,
    },
    IssueCode.INSUFFICIENT_OPTIONS: {
        RepairAction.SWAP_DISTRACTOR,
    },
    IssueCode.DUPLICATE_PROMPT: {
        RepairAction.REGENERATE_DISTINCT_CANDIDATE,
        RepairAction.REPHRASE_STEM,
    },
    IssueCode.SCHEMA_VIOLATION: {
        RepairAction.REFINE_CLOZE_TARGET,
        RepairAction.REPHRASE_STEM,
        RepairAction.REGENERATE_DISTINCT_CANDIDATE,
    },
    IssueCode.ANSWER_LEAKAGE: {
        RepairAction.REPHRASE_STEM,
        RepairAction.REFINE_CLOZE_TARGET,
        RepairAction.REGENERATE_DISTINCT_CANDIDATE,
    },
    IssueCode.WORD_LIMIT_EXCEEDED: {
        RepairAction.REFINE_CLOZE_TARGET,
    },
}


def validate_repair_plan_compatibility(plan: RepairPlan, authoritative_claim_ref: str) -> None:
    """Enforces strict safety invariants on an M3-generated RepairPlan.

    1. Claim preservation: M3 can never alter or rotate the bound evidence claim.
    2. Action compatibility: M3 action must match the recognized failure issue.
    3. Non-empty directives: M3 must provide concrete diagnostic constraints.
    """
    if not plan.preserve_evidence_claim_ref or plan.preserve_evidence_claim_ref.strip() != authoritative_claim_ref.strip():
        raise RepairPlanValidationError(
            f"Claim preservation violated: plan references '{plan.preserve_evidence_claim_ref}', "
            f"expected authoritative '{authoritative_claim_ref}'"
        )

    if not plan.repair_constraints or len(plan.repair_constraints) == 0:
        raise RepairPlanValidationError("repairConstraints must contain at least one directive")

    if not plan.diagnosis or len(plan.diagnosis.strip()) < 5:
        raise RepairPlanValidationError("diagnosis must be a non-empty diagnostic explanation")

    allowed = ALLOWED_ACTIONS_FOR_ISSUE.get(plan.issue_code)
    if allowed is not None and plan.repair_action not in allowed:
        raise RepairPlanValidationError(
            f"Incompatible repairAction '{plan.repair_action.value}' for issueCode '{plan.issue_code.value}'; "
            f"allowed: {[a.value for a in allowed]}"
        )
