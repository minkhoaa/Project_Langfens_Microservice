"""Loop Policy and Termination Caps for Bounded LoopRuntime."""

from __future__ import annotations

from typing import Any, Optional, Set, Tuple
from pydantic import Field

from app.config import settings
from app.contracts.base import CanonicalBaseModel
from app.contracts.issue import IssueCode

class LoopPolicy(CanonicalBaseModel):
    """Execution policy setting bounded caps, termination rules, and repair eligibility."""

    # Version and repair limits
    max_versions: int = Field(default=3, ge=1, description="Maximum immutable versions per artifact, including repairs")
    max_generated_versions: int = Field(default=3, ge=1)
    max_repair_attempts_per_version: int = Field(
        default=2, ge=0, description="Maximum repairs between generations"
    )
    max_total_repairs: int = Field(default=5, ge=0, description="Global maximum repair attempts")

    # Stagnation and oscillation limits
    max_consecutive_no_progress: int = Field(
        default=2, ge=1, description="Max consecutive identical/non-progressing repairs"
    )
    max_oscillation_cycles: int = Field(
        default=2, ge=1, description="Max repeating cycle patterns before termination"
    )

    # Resource caps
    max_total_calls: int = Field(default=15, ge=1, description="Hard cap on external provider calls")
    max_total_tokens: int = Field(default=60_000, ge=1, description="Hard cap on cumulative tokens")
    max_wall_time_seconds: float = Field(default=300.0, gt=0.0, description="Hard cap on wall clock time in seconds")
    generate_token_reservation: int = Field(default=2500, ge=0)
    evaluate_token_reservation: int = Field(default=1000, ge=0)
    repair_token_reservation: int = Field(default=1500, ge=0)
    operation_wall_reservation_seconds: float = Field(default=30.0, gt=0)
    # Evaluator requirements
    required_evaluator_ids: Tuple[str, ...] = Field(
        default_factory=tuple,
        description="Evaluators that MUST run and return PASS for a PASS decision",
    )

    # Score threshold
    min_score_threshold: float = Field(
        default=0.8, ge=0.0, le=1.0, description="Minimum score threshold; note: CRITICAL issue always blocks PASS regardless"
    )

    # Eligibility categories
    allow_repair_codes: Set[IssueCode] = Field(
        default_factory=lambda: {
            IssueCode.WORD_LIMIT_EXCEEDED,
            IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS,
            IssueCode.AMBIGUOUS_ANSWER,
            IssueCode.BAD_DISTRACTOR,
            IssueCode.INSUFFICIENT_OPTIONS,
            IssueCode.QUESTION_NUMBERING_INVALID,
            IssueCode.QUESTION_COUNT_MISMATCH,
            IssueCode.OVERSTATED_CERTAINTY,
            IssueCode.CAUSAL_OVERSTATEMENT,
            IssueCode.UNMEASURED_OUTCOME,
        },
        description="Issue codes that can be targeted for surgical repair",
    )

    regenerate_codes: Set[IssueCode] = Field(
        default_factory=lambda: {
            IssueCode.SCHEMA_VIOLATION,
            IssueCode.DUPLICATE_CONTENT,
            IssueCode.ANSWER_LEAKAGE,
            IssueCode.STALE_DEPENDENCY,
        },
        description="Issue codes that require full artifact regeneration",
    )

    escalate_codes: Set[IssueCode] = Field(
        default_factory=lambda: {
            IssueCode.SOURCE_INSUFFICIENT,
            IssueCode.EVIDENCE_MISSING,
        },
        description="Issue codes that immediately trigger escalation",
    )

    @classmethod
    def from_settings(cls, s: Optional[Any] = None, **overrides) -> LoopPolicy:
        """Constructs LoopPolicy directly from runtime Settings (G06 caps hotfix & Phase 07)."""
        active_settings = s if s is not None else settings
        init_args = {
            "max_versions": active_settings.loop_max_versions,
            "max_generated_versions": active_settings.loop_max_generated_versions,
            "max_repair_attempts_per_version": active_settings.loop_max_repair_attempts_per_version,
            "max_total_repairs": active_settings.loop_max_total_repairs,
            "max_consecutive_no_progress": active_settings.loop_max_consecutive_no_progress,
            "max_oscillation_cycles": active_settings.loop_max_oscillation_cycles,
            "max_total_calls": active_settings.loop_max_total_calls,
            "max_total_tokens": active_settings.loop_max_total_tokens,
            "max_wall_time_seconds": active_settings.loop_max_wall_time_seconds,
            "generate_token_reservation": active_settings.loop_generate_token_reservation,
            "evaluate_token_reservation": active_settings.loop_evaluate_token_reservation,
            "repair_token_reservation": active_settings.loop_repair_token_reservation,
            "operation_wall_reservation_seconds": active_settings.loop_operation_wall_reservation_seconds,
            "min_score_threshold": active_settings.loop_min_score_threshold,
        }
        init_args.update(overrides)
        return cls(**init_args)
