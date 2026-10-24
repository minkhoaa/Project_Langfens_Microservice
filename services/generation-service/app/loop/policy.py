"""Loop Policy and Termination Caps for Bounded LoopRuntime."""

from __future__ import annotations

from typing import Any, ClassVar, Dict, Literal, Optional, Set, Tuple
from pydantic import Field

from app.config import cap_snapshot_sha256, settings
from app.contracts.base import CanonicalBaseModel
from app.contracts.issue import IssueCode, IssueScope

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
    max_total_calls: int = Field(default=15, description="Hard cap on external provider calls; -1 for unlimited")
    max_total_tokens: int = Field(default=60_000, description="Hard cap on cumulative tokens; -1 for unlimited")
    max_wall_time_seconds: float = Field(default=300.0, description="Hard cap on wall clock time in seconds; -1 for unlimited")
    generate_token_reservation: int = Field(default=15_000, ge=0)
    evaluate_token_reservation: int = Field(default=10_000, ge=0)
    repair_token_reservation: int = Field(default=15_000, ge=0)
    operation_wall_reservation_seconds: float = Field(default=30.0, gt=0)
    max_response_bytes: int = Field(default=500_000, ge=1)
    evaluator_semantic_timeout_seconds: float = Field(default=30.0, gt=0)
    evaluator_stage_timeout_seconds: float = Field(default=60.0, gt=0)
    evaluator_deterministic_timeout_seconds: float = Field(default=5.0, gt=0)
    repair_timeout_seconds: float = Field(default=30.0, gt=0)
    repair_max_tokens_per_attempt: int = Field(default=3000, gt=0)
    evaluator_max_tokens_per_evaluation: int = Field(default=4000, gt=0)
    cap_profile_version: str = "development-unpinned"
    cap_profile_source: str = "development defaults"
    cap_profile_sha256: str = ""
    cap_profile_snapshot: Dict[str, Any] = Field(default_factory=dict)
    policy_hash: str = Field(default="", description="Canonical hash of the underlying PinnedExecutionPolicy")
    generate_reservation_cap: Literal["generateTokenReservation", "passageGenerateTokenReservation"] = "generateTokenReservation"
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
            IssueCode.ANSWER_LEAKAGE,
            IssueCode.PASSAGE_BLUEPRINT_ALIGNMENT,
            IssueCode.TFNG_BOUNDARY_CONFLICT,
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

    scope_recoverable_escalate_codes: Dict[IssueCode, Set[IssueScope]] = Field(
        default_factory=lambda: {
            # An EVIDENCE_MISSING whose scope is a single QUESTION is a defect in
            # ONE slot's answer, not a statement about the source. It is exactly
            # the class the regeneration path already recovers, so escalating the
            # whole paper for one slot's non-verbatim answer is over-broad. The
            # same code at SOURCE/PASSAGE/SECTION/EVIDENCE scope describes the
            # source itself, which no local regeneration can repair, so it still
            # escalates.
            IssueCode.EVIDENCE_MISSING: {IssueScope.QUESTION},
        },
        description=(
            "Escalate codes that are instead regenerable when reported at one of "
            "the listed scopes. Scopes not listed still escalate."
        ),
    )

    RESOURCE_CAP_FIELDS: ClassVar[dict[str, str]] = {
        "max_versions": "loopMaxVersions",
        "max_generated_versions": "loopMaxGeneratedVersions",
        "max_repair_attempts_per_version": "loopMaxRepairAttemptsPerVersion",
        "max_total_repairs": "loopMaxTotalRepairs",
        "max_consecutive_no_progress": "loopMaxConsecutiveNoProgress",
        "max_oscillation_cycles": "loopMaxOscillationCycles",
        "max_total_calls": "loopMaxTotalCalls",
        "max_total_tokens": "loopMaxTotalTokens",
        "max_wall_time_seconds": "loopMaxWallTimeSeconds",
        "evaluate_token_reservation": "evaluateTokenReservation",
        "repair_token_reservation": "repairTokenReservation",
        "operation_wall_reservation_seconds": "loopOperationWallReservationSeconds",
        "max_response_bytes": "loopMaxResponseBytes",
    }

    OPTIONAL_CAP_FIELDS: ClassVar[dict[str, str]] = {
        "evaluator_semantic_timeout_seconds": "evaluatorSemanticTimeoutSeconds",
        "evaluator_stage_timeout_seconds": "evaluatorStageTimeoutSeconds",
        "evaluator_deterministic_timeout_seconds": "evaluatorDeterministicTimeoutSeconds",
        "repair_timeout_seconds": "repairTimeoutSeconds",
        "repair_max_tokens_per_attempt": "repairMaxTokensPerAttempt",
        "evaluator_max_tokens_per_evaluation": "evaluatorMaxTokensPerEvaluation",
    }

    @classmethod
    def from_cap_snapshot(cls, snapshot: Dict[str, Any], **overrides) -> LoopPolicy:
        overrides.pop("cap_profile_sha256", None)
        overrides.pop("capProfileSha256", None)
        overrides.pop("cap_profile_snapshot", None)
        overrides.pop("capProfileSnapshot", None)
        overrides.pop("cap_profile_version", None)
        overrides.pop("cap_profile_source", None)
        caps = snapshot.get("caps", {})
        reservation_key = overrides.get("generate_reservation_cap", "generateTokenReservation")
        fields = {**cls.RESOURCE_CAP_FIELDS, "generate_token_reservation": reservation_key}
        if any(key not in caps for key in fields.values()):
            raise ValueError("Pinned cap profile lacks required runtime caps")
        if any(type(caps[key]) is not int or not 0 < caps[key] <= 2_147_483_647
               for key in fields.values()):
            raise ValueError("Pinned runtime caps must be positive 32-bit integers")
        if not snapshot.get("profileVersion") or not snapshot.get("profileSource"):
            raise ValueError("Pinned cap profile lacks version/source")
        is_unlimited = (
            snapshot.get("benchmarkMode") == "UNLIMITED" and
            snapshot.get("benchmarkMonetaryCapMode") == "UNLIMITED"
        )
        field_values = {field: caps[key] for field, key in fields.items()}
        for field, key in cls.OPTIONAL_CAP_FIELDS.items():
            if key in caps and isinstance(caps[key], (int, float)) and caps[key] > 0:
                field_values[field] = caps[key]
        if is_unlimited:
            field_values["max_total_calls"] = -1
            field_values["max_total_tokens"] = -1
            field_values["max_wall_time_seconds"] = -1.0
        return cls(**{
            **field_values,
            "cap_profile_version": snapshot["profileVersion"],
            "cap_profile_source": snapshot["profileSource"],
            "cap_profile_sha256": cap_snapshot_sha256(snapshot),
            "cap_profile_snapshot": snapshot,
            "policy_hash": overrides.pop("policy_hash", snapshot.get("policyHash", "")),
            **overrides,
        })
    @classmethod
    def reading_section(cls, **overrides) -> LoopPolicy:
        """Standard policy for autonomous IELTS Reading section loop."""
        return cls(
            max_versions=3,
            max_generated_versions=3,
            max_repair_attempts_per_version=2,
            max_total_repairs=5,
            max_consecutive_no_progress=2,
            max_oscillation_cycles=2,
            **overrides,
        )


    @classmethod
    def from_settings(cls, s: Optional[Any] = None, is_benchmark: bool = False, **overrides) -> LoopPolicy:
        active_settings = s if s is not None else settings
        snapshot = (
            active_settings.create_unlimited_benchmark_snapshot()
            if is_benchmark
            else active_settings.loop_caps_snapshot()
        )
        return cls.from_cap_snapshot(snapshot, **{
            "min_score_threshold": active_settings.loop_min_score_threshold,
            **overrides,
        })

    @classmethod
    def from_pinned_execution_policy(
        cls,
        policy: Any,
        scope: Any = "SECTION",
        section_index: Optional[int] = None,
        **overrides: Any,
    ) -> LoopPolicy:
        """Adapts canonical PinnedExecutionPolicy into a bounded LoopPolicy.

        Strictly enforces the unified contract hard ceilings:
        - provider call <= 180s
        - section wall time <= 900s
        - paper wall time <= 2700s (900s * 3)
        - section token cap <= 100,000
        - paper token cap <= 300,000 (100,000 * 3)
        No unlimited fallback, silent budget reset, or artificial USD cap.
        Pins the cap snapshot SHA-256 as cap_profile_sha256 and preserves policy_hash.
        """
        from app.contracts.issue import IssueScope
        from app.reading_policy import (
            MAX_PROVIDER_CALL_SECONDS,
            MAX_SECTION_WALL_SECONDS,
            MAX_SECTION_TOKEN_CAP,
        )

        scope_val = scope.value if isinstance(scope, IssueScope) else str(scope).upper()
        is_paper = scope_val == "PAPER"

        max_provider_seconds = int(
            min(
                float(getattr(policy, "provider_call_seconds", MAX_PROVIDER_CALL_SECONDS)),
                float(MAX_PROVIDER_CALL_SECONDS),
            )
        )
        if is_paper:
            max_wall = int(
                min(
                    float(getattr(policy, "run_wall_seconds", MAX_SECTION_WALL_SECONDS * 3)),
                    float(MAX_SECTION_WALL_SECONDS * 3),
                )
            )
            max_tokens = int(
                min(
                    int(getattr(policy, "run_token_cap", MAX_SECTION_TOKEN_CAP * 3)),
                    MAX_SECTION_TOKEN_CAP * 3,
                )
            )
            max_calls = int(getattr(policy, "run_call_cap", 30))
        else:
            max_wall = int(
                min(
                    float(getattr(policy, "section_wall_seconds", MAX_SECTION_WALL_SECONDS)),
                    float(MAX_SECTION_WALL_SECONDS),
                )
            )
            max_tokens = int(
                min(
                    int(getattr(policy, "section_token_cap", MAX_SECTION_TOKEN_CAP)),
                    MAX_SECTION_TOKEN_CAP,
                )
            )
            max_calls = int(getattr(policy, "section_call_cap", 15))

        policy_hash = getattr(policy, "hash", "")

        snapshot = {
            "profileVersion": "pinned-execution-v2",
            "profileSource": f"PinnedExecutionPolicy ({getattr(policy, 'provider', 'pinned')})",
            "policyHash": policy_hash,
            "benchmarkMode": "LIMITED",
            "benchmarkMonetaryCapMode": "LIMITED",
            "caps": {
                "loopMaxVersions": 3,
                "loopMaxGeneratedVersions": 3,
                "loopMaxRepairAttemptsPerVersion": 2,
                "loopMaxTotalRepairs": getattr(policy, "max_repairs", 2),
                "loopMaxConsecutiveNoProgress": 2,
                "loopMaxOscillationCycles": 2,
                "loopMaxTotalCalls": max_calls,
                "loopMaxTotalTokens": max_tokens,
                "loopMaxWallTimeSeconds": max_wall,
                "generateTokenReservation": min(15_000, max_tokens),
                "passageGenerateTokenReservation": min(15_000, max_tokens),
                "evaluateTokenReservation": min(10_000, max_tokens),
                "repairTokenReservation": min(15_000, max_tokens),
                "loopOperationWallReservationSeconds": max_provider_seconds,
                "loopMaxResponseBytes": 500_000,
                "evaluatorSemanticTimeoutSeconds": 30.0,
                "evaluatorStageTimeoutSeconds": 60.0,
                "evaluatorDeterministicTimeoutSeconds": 5.0,
                "repairTimeoutSeconds": 30.0,
                "repairMaxTokensPerAttempt": 3000,
                "evaluatorMaxTokensPerEvaluation": 4000,
                "standaloneRunBudgetCapCalls": max_calls,
                "standaloneRunBudgetCapTokens": max_tokens,
                "standaloneRunBudgetCapWallTimeSeconds": max_wall,
                "passageGenerateMaxTokens": min(15_000, max_tokens),
                "benchmarkMode": "LIMITED",
                "benchmarkMonetaryCapMode": "LIMITED",
            },
        }

        expected_sha = cap_snapshot_sha256(snapshot)

        return cls(
            max_total_calls=max_calls,
            max_total_tokens=max_tokens,
            max_wall_time_seconds=max_wall,
            operation_wall_reservation_seconds=max_provider_seconds,
            generate_token_reservation=min(15_000, max_tokens),
            evaluate_token_reservation=min(10_000, max_tokens),
            repair_token_reservation=min(15_000, max_tokens),
            max_repair_attempts_per_version=getattr(policy, "max_repairs", 2),
            max_total_repairs=getattr(policy, "max_repairs", 2),
            cap_profile_version="pinned-execution-v2",
            cap_profile_source=f"PinnedExecutionPolicy ({getattr(policy, 'provider', 'pinned')})",
            cap_profile_sha256=expected_sha,
            cap_profile_snapshot=snapshot,
            policy_hash=policy_hash,
            **overrides,
        )
    @property
    def is_unlimited(self) -> bool:
        return self.max_total_calls <= 0 and self.max_total_tokens <= 0 and self.max_wall_time_seconds <= 0

    def escalates(self, code: IssueCode, scope: IssueScope) -> bool:
        """Whether this (code, scope) pair must escalate the whole artifact.

        Escalation is scope-aware: an escalate code listed in
        `scope_recoverable_escalate_codes` is instead handed to the
        regeneration path when it is reported at one of the listed scopes,
        because such a report is about one regenerable unit rather than
        about the source. Every other escalate code, and every unlisted
        scope of a demoted code, still escalates.
        """
        if code not in self.escalate_codes:
            return False
        return scope not in self.scope_recoverable_escalate_codes.get(code, frozenset())

    def validate_cap_bounds(self) -> None:
        caps = self.cap_profile_snapshot.get("caps", {})
        fields = {**self.RESOURCE_CAP_FIELDS, "generate_token_reservation": self.generate_reservation_cap}
        if self.is_unlimited:
            return
        if any(key not in caps or getattr(self, field) > caps[key] for field, key in fields.items()):
            raise ValueError("Runtime policy exceeds its pinned cap profile")
