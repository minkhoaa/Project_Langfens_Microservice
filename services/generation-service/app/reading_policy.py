"""Pinned execution policy for the unified Reading generation pipeline.

The policy is immutable, pinned by exam-service at Stage 0, and shared with .NET
verbatim as camelCase JSON. Every execution budget is finite: there is no
unlimited representation and no validation-bypass field, and the demo IELTS
allocation is *configuration* (``SectionConfig`` data), never validation logic.

Two rules define this module:

* One canonical serialization. The policy hash is SHA-256 over
  ``canonical_json_dump`` of the camelCase wire form, so .NET can recompute it
  byte-for-byte (``sort_keys``, ``separators=(",", ":")``, ``ensure_ascii=False``,
  UTF-8).
* Reuse, don't re-declare. ``QuestionType``/``DifficultyLevel`` come from the
  existing typed contracts; the canonical JSON helper is the one already used
  for artifact content hashes.
"""

from __future__ import annotations

import hashlib
from typing import Literal, Tuple

from pydantic import ConfigDict, Field, field_validator, model_validator

from app.contracts.artifact import canonical_json_dump
from app.contracts.base import CanonicalBaseModel
from app.contracts.blueprint import DifficultyLevel, QuestionType

# Hard ceilings from the pinned execution contract. A policy may ask for less;
# it may never ask for more.
MAX_PROVIDER_CALL_SECONDS = 180
MAX_SECTION_WALL_SECONDS = 900
MAX_SECTION_TOKEN_CAP = 100_000

# Question numbering domain shared with the .NET blueprint and paper contracts.
MIN_QUESTION_NUMBER = 1
MAX_QUESTION_NUMBER = 40
MIN_SECTION_INDEX = 1
MAX_SECTION_INDEX = 3

# Bounds that keep the demo finite even though the fields are not named in the
# wire contract: an "evaluation/repair/dependency/recovery" knob that is not
# bounded is exactly the unlimited mode this rebuild removes.
MAX_CANDIDATES_CEILING = 20
MAX_REPAIRS_CEILING = 10
MAX_EVALUATIONS_CEILING = 32
MAX_RECOVERY_CEILING = 10
MAX_DEPENDENCY_DEPTH_CEILING = 8


class GroupConfig(CanonicalBaseModel):
    """One question-type group inside a section, sized by count only."""

    question_type: QuestionType = Field(..., alias="questionType")
    count: int = Field(..., ge=1, le=MAX_QUESTION_NUMBER)

    @property
    def question_count(self) -> int:
        return self.count


class SectionConfig(CanonicalBaseModel):
    """Configurable allocation for one reading section.

    Numbering is *derived*: ``start_number`` plus the contiguous group counts.
    Nothing here assumes the demo IELTS distribution.
    """

    index: int = Field(..., ge=MIN_SECTION_INDEX, le=MAX_SECTION_INDEX)
    start_number: int = Field(..., ge=MIN_QUESTION_NUMBER, le=MAX_QUESTION_NUMBER, alias="startNumber")
    groups: Tuple[GroupConfig, ...] = Field(..., min_length=1)
    min_words: int = Field(default=720, ge=1, alias="minWords")
    max_words: int = Field(default=915, ge=1, alias="maxWords")
    difficulty: DifficultyLevel
    editorial_objective: str = Field(..., min_length=1, alias="editorialObjective")

    @model_validator(mode="after")
    def _validate_allocation(self) -> "SectionConfig":
        if self.min_words > self.max_words:
            raise ValueError(
                f"section {self.index}: minWords ({self.min_words}) exceeds maxWords ({self.max_words})"
            )
        last_number = self.start_number + self.question_count - 1
        if last_number > MAX_QUESTION_NUMBER:
            raise ValueError(
                f"section {self.index}: questions {self.start_number}..{last_number} exceed "
                f"the numbering domain 1..{MAX_QUESTION_NUMBER}"
            )
        return self

    @property
    def question_count(self) -> int:
        return sum(group.count for group in self.groups)

    @property
    def end_number(self) -> int:
        return self.start_number + self.question_count - 1

    def question_numbers(self) -> Tuple[int, ...]:
        """Contiguous question numbers for this section, derived from groups."""
        numbers: list[int] = []
        cursor = self.start_number
        for group in self.groups:
            numbers.extend(range(cursor, cursor + group.count))
            cursor += group.count
        return tuple(numbers)

    def group_numbers(self, group_index: int) -> Tuple[int, ...]:
        """Question numbers owned by one group, derived from the same cursor."""
        cursor = self.start_number
        for index, group in enumerate(self.groups):
            if index == group_index:
                return tuple(range(cursor, cursor + group.count))
            cursor += group.count
        raise IndexError(f"section {self.index} has no group {group_index}")


class RemainingBudget(CanonicalBaseModel):
    """Nested remaining budget for one section call, derived from the pinned caps.

    ``provider_call_seconds_available`` is the single value a caller may use for
    its own deadline: it is the provider call cap already clamped by what is left
    of the section wall clock and the run wall clock, so no caller can spend time
    the ancestors cannot afford.
    """

    section_index: int
    section_token_cap: int = Field(..., alias="sectionTokenCap")
    section_tokens_remaining: int = Field(..., ge=0, alias="sectionTokensRemaining")
    section_wall_seconds_remaining: float = Field(..., ge=0.0, alias="sectionWallSecondsRemaining")
    run_tokens_remaining: int = Field(..., ge=0, alias="runTokensRemaining")
    run_wall_seconds_remaining: float = Field(..., ge=0.0, alias="runWallSecondsRemaining")
    provider_call_seconds_available: float = Field(..., ge=0.0, alias="providerCallSecondsAvailable")
    max_candidates_remaining: int = Field(..., ge=0, alias="maxCandidatesRemaining")
    max_repairs_remaining: int = Field(..., ge=0, alias="maxRepairsRemaining")

    @property
    def tokens_available(self) -> int:
        """Tokens a single call may reserve: never more than section or run allows."""
        return min(self.section_tokens_remaining, self.run_tokens_remaining)

    @property
    def can_dispatch(self) -> bool:
        return self.tokens_available > 0 and self.provider_call_seconds_available > 0.0


def demo_sections() -> Tuple[SectionConfig, ...]:
    """The demo allocation (13/13/14) as data, not as validation logic.

    1: 7 TRUE_FALSE_NOT_GIVEN + 6 SENTENCE_COMPLETION, numbering from 1.
    2: 6 MULTIPLE_CHOICE_SINGLE + 7 SUMMARY_COMPLETION, numbering from 14.
    3: 7 YES_NO_NOT_GIVEN + 7 SHORT_ANSWER, numbering from 27.
    """
    return (
        SectionConfig(
            index=1,
            start_number=1,
            groups=(
                GroupConfig(question_type=QuestionType.TRUE_FALSE_NOT_GIVEN, count=7),
                GroupConfig(question_type=QuestionType.SENTENCE_COMPLETION, count=6),
            ),
            difficulty=DifficultyLevel.FOUNDATION,
            editorial_objective="Establish a factual baseline the later sections may safely build on.",
        ),
        SectionConfig(
            index=2,
            start_number=14,
            groups=(
                GroupConfig(question_type=QuestionType.MULTIPLE_CHOICE_SINGLE, count=6),
                GroupConfig(question_type=QuestionType.SUMMARY_COMPLETION, count=7),
            ),
            difficulty=DifficultyLevel.MODERATE,
            editorial_objective="Test paraphrase and distribution of explicitly stated scientific detail.",
        ),
        SectionConfig(
            index=3,
            start_number=27,
            groups=(
                GroupConfig(question_type=QuestionType.YES_NO_NOT_GIVEN, count=7),
                GroupConfig(question_type=QuestionType.SHORT_ANSWER, count=7),
            ),
            difficulty=DifficultyLevel.ADVANCED,
            editorial_objective="Require inference strictly licensed by the passage and claim evidence.",
        ),
    )


class PinnedExecutionPolicy(CanonicalBaseModel):
    """Immutable, finite execution policy shared by the Python pipeline and .NET.

    Configured allocations (``sections``) are caller data; the fields below are
    the bounded budgets a run may spend. There is deliberately no field that can
    express "unlimited" or "skip validation": such a policy does not exist.
    """

    model_config = ConfigDict(frozen=True, populate_by_name=True, extra="forbid", allow_inf_nan=False)

    provider: str = Field(..., min_length=1)
    provider_call_seconds: float = Field(
        default=float(MAX_PROVIDER_CALL_SECONDS),
        gt=0.0,
        le=MAX_PROVIDER_CALL_SECONDS,
        alias="providerCallSeconds",
    )
    section_wall_seconds: float = Field(
        default=float(MAX_SECTION_WALL_SECONDS),
        gt=0.0,
        le=MAX_SECTION_WALL_SECONDS,
        alias="sectionWallSeconds",
    )
    section_token_cap: int = Field(
        default=MAX_SECTION_TOKEN_CAP,
        gt=0,
        le=MAX_SECTION_TOKEN_CAP,
        alias="sectionTokenCap",
    )
    run_token_cap: int = Field(default=MAX_SECTION_TOKEN_CAP * MAX_SECTION_INDEX, gt=0, alias="runTokenCap")
    run_wall_seconds: float = Field(
        default=float(MAX_SECTION_WALL_SECONDS * MAX_SECTION_INDEX),
        gt=0.0,
        alias="runWallSeconds",
    )

    # Evaluation, repair, dependency and recovery limits.
    max_candidates: int = Field(default=3, gt=0, le=MAX_CANDIDATES_CEILING, alias="maxCandidates")
    max_repairs: int = Field(default=2, ge=0, le=MAX_REPAIRS_CEILING, alias="maxRepairs")
    max_evaluations_per_artifact: int = Field(
        default=8,
        gt=0,
        le=MAX_EVALUATIONS_CEILING,
        alias="maxEvaluationsPerArtifact",
    )
    max_dependency_depth: int = Field(
        default=3,
        gt=0,
        le=MAX_DEPENDENCY_DEPTH_CEILING,
        alias="maxDependencyDepth",
    )
    max_recovery_attempts: int = Field(
        default=2,
        ge=0,
        le=MAX_RECOVERY_CEILING,
        alias="maxRecoveryAttempts",
    )

    # Content thresholds.
    source_min_words: int = Field(default=600, gt=0, alias="sourceMinWords")
    min_verified_claims: int = Field(default=3, gt=0, alias="minVerifiedClaims")
    paper_min_words: int = Field(default=2150, gt=0, alias="paperMinWords")
    paper_max_words: int = Field(default=2750, gt=0, alias="paperMaxWords")
    require_blind_solver: Literal[True] = Field(default=True, alias="requireBlindSolver")

    sections: Tuple[SectionConfig, ...] = Field(default_factory=demo_sections, min_length=1)

    @field_validator("provider")
    @classmethod
    def _provider_name(cls, value: str) -> str:
        normalized = value.strip().lower()
        if not normalized:
            raise ValueError("provider must be non-empty")
        return normalized

    @model_validator(mode="after")
    def _validate_sections(self) -> "PinnedExecutionPolicy":
        if self.paper_min_words > self.paper_max_words:
            raise ValueError(
                f"paperMinWords ({self.paper_min_words}) exceeds paperMaxWords ({self.paper_max_words})"
            )
        ordered = sorted(self.sections, key=lambda section: section.index)
        if [section.index for section in ordered] != list(range(
            ordered[0].index,
            ordered[0].index + len(ordered),
        )):
            raise ValueError("section indices must be unique and contiguous")
        expected_start: int | None = None
        for section in ordered:
            if expected_start is not None and section.start_number != expected_start:
                raise ValueError(
                    f"section {section.index} starts at {section.start_number}; "
                    f"contiguous numbering requires {expected_start}"
                )
            expected_start = section.start_number + section.question_count
        return self

    # ── Canonical wire form ────────────────────────────────────────────────
    def to_wire_dict(self) -> dict:
        """The exact camelCase dict .NET persists and hashes."""
        return self.model_dump(mode="json", by_alias=True)

    @property
    def canonical_json(self) -> str:
        return canonical_json_dump(self.to_wire_dict())

    @property
    def hash(self) -> str:
        """Stable canonical SHA-256 of the camelCase wire form."""
        return hashlib.sha256(self.canonical_json.encode("utf-8")).hexdigest()

    # ── Derived, finite budgets ────────────────────────────────────────────
    @property
    def question_count(self) -> int:
        return sum(section.question_count for section in self.sections)

    def section(self, section_index: int) -> SectionConfig:
        for section in self.sections:
            if section.index == section_index:
                return section
        raise KeyError(f"policy has no section {section_index}")

    @property
    def section_indices(self) -> Tuple[int, ...]:
        return tuple(section.index for section in sorted(self.sections, key=lambda s: s.index))

    @property
    def section_call_cap(self) -> int:
        """Provider calls one section may make, derived from the bounded knobs."""
        return (
            1  # one passage draft
            + self.max_candidates  # bounded candidate pools
            + self.max_evaluations_per_artifact  # mandatory evaluation calls
            + self.max_repairs  # bounded repairs
            + self.max_recovery_attempts  # bounded recovery
        )

    @property
    def run_call_cap(self) -> int:
        return self.section_call_cap * len(self.sections)

    def provider_call_wall_seconds(self, section_index: int) -> float:
        """Wall time a single provider call may reserve inside one section."""
        self.section(section_index)
        return float(min(self.provider_call_seconds, self.section_wall_seconds))

    def remaining_budget(
        self,
        section_index: int,
        *,
        section_tokens_used: int = 0,
        section_wall_seconds_used: float = 0.0,
        run_tokens_used: int = 0,
        run_wall_seconds_used: float = 0.0,
        candidates_used: int = 0,
        repairs_used: int = 0,
    ) -> RemainingBudget:
        """Nested remaining budget for one call: section caps clamped by run caps."""
        if section_index not in self.section_indices:
            raise KeyError(f"policy has no section {section_index}")
        section_tokens_remaining = max(0, self.section_token_cap - max(0, section_tokens_used))
        run_tokens_remaining = max(0, self.run_token_cap - max(0, run_tokens_used))
        section_wall_remaining = max(0.0, self.section_wall_seconds - max(0.0, section_wall_seconds_used))
        run_wall_remaining = max(0.0, self.run_wall_seconds - max(0.0, run_wall_seconds_used))
        return RemainingBudget(
            section_index=section_index,
            section_token_cap=self.section_token_cap,
            section_tokens_remaining=section_tokens_remaining,
            section_wall_seconds_remaining=section_wall_remaining,
            run_tokens_remaining=run_tokens_remaining,
            run_wall_seconds_remaining=run_wall_remaining,
            provider_call_seconds_available=min(self.provider_call_seconds, section_wall_remaining, run_wall_remaining),
            max_candidates_remaining=max(0, self.max_candidates - max(0, candidates_used)),
            max_repairs_remaining=max(0, self.max_repairs - max(0, repairs_used)),
        )

    def to_loop_policy(
        self,
        scope: Any = "SECTION",
        section_index: Optional[int] = None,
        **overrides: Any,
    ) -> Any:
        """Converts this canonical finite policy into a compatible LoopPolicy."""
        from app.loop.policy import LoopPolicy
        return LoopPolicy.from_pinned_execution_policy(
            self, scope=scope, section_index=section_index, **overrides
        )