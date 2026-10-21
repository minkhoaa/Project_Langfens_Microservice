"""Canonical Blueprint Contracts for Langfens Loop Engine V2."""

from __future__ import annotations

from datetime import datetime, timezone
from enum import Enum
from typing import Any, List, Optional
from pydantic import Field

from .base import CanonicalBaseModel


class QuestionType(str, Enum):
    TRUE_FALSE_NOT_GIVEN = "TRUE_FALSE_NOT_GIVEN"
    YES_NO_NOT_GIVEN = "YES_NO_NOT_GIVEN"
    SENTENCE_COMPLETION = "SENTENCE_COMPLETION"
    SUMMARY_COMPLETION = "SUMMARY_COMPLETION"
    SUMMARY_COMPLETION_BOX = "SUMMARY_COMPLETION_BOX"
    MULTIPLE_CHOICE_SINGLE = "MULTIPLE_CHOICE_SINGLE"
    MULTIPLE_CHOICE_MULTIPLE = "MULTIPLE_CHOICE_MULTIPLE"
    MATCHING_HEADING = "MATCHING_HEADING"
    MATCHING_INFORMATION = "MATCHING_INFORMATION"
    MATCHING_FEATURES = "MATCHING_FEATURES"
    MATCHING_ENDINGS = "MATCHING_ENDINGS"
    TABLE_COMPLETION = "TABLE_COMPLETION"
    FLOW_CHART = "FLOW_CHART"
    DIAGRAM_LABEL = "DIAGRAM_LABEL"
    SHORT_ANSWER = "SHORT_ANSWER"
    NOTE_COMPLETION = "NOTE_COMPLETION"
    FORM_COMPLETION = "FORM_COMPLETION"
    CLASSIFICATION = "CLASSIFICATION"
    CHOOSING_TITLE = "CHOOSING_TITLE"
    MULTIPLE_CHOICE_SINGLE_IMAGE = "MULTIPLE_CHOICE_SINGLE_IMAGE"
    MAP_LABEL = "MAP_LABEL"
class DifficultyLevel(str, Enum):
    FOUNDATION = "FOUNDATION"
    MODERATE = "MODERATE"
    ADVANCED = "ADVANCED"


class EvidenceGraphRef(CanonicalBaseModel):
    """Reference to an exact accepted EvidenceGraph."""

    graph_id: str = Field(..., alias="graphId")
    source_pack_id: str = Field(..., alias="sourcePackId")
    version: str = Field(default="v1.0.0")
    content_hash: str = Field(..., alias="contentHash")
    status: str = Field(default="ACCEPTED")
    claim_count: int = Field(default=0, alias="claimCount")


class TargetDifficulty(CanonicalBaseModel):
    """Heuristic/editorial difficulty target with rationale (NOT calibrated IELTS band)."""

    level: DifficultyLevel = Field(...)
    rationale: str = Field(...)
    is_calibrated: bool = Field(default=False, alias="isCalibrated")


class QuestionSlot(CanonicalBaseModel):
    """Detailed slot for a single question (1-40)."""

    question_number: int = Field(..., ge=1, le=40, alias="questionNumber")
    section_id: int = Field(..., ge=1, le=3, alias="sectionId")
    group_index: int = Field(..., ge=0, le=10, alias="groupIndex")
    question_type: QuestionType = Field(..., alias="questionType")
    target_skill: str = Field(..., alias="targetSkill")
    target_difficulty: TargetDifficulty = Field(..., alias="targetDifficulty")
    claim_ref_ids: List[str] = Field(default_factory=list, alias="claimRefIds")
    is_not_given_target: bool = Field(default=False, alias="isNotGivenTarget")
    max_concentration_per_paragraph: int = Field(default=2, alias="maxConcentrationPerParagraph")


class PassageObjective(CanonicalBaseModel):
    """Passage generation objective mapped from verified claims."""

    objective_id: str = Field(..., alias="objectiveId")
    description: str = Field(...)
    mapped_claim_ids: List[str] = Field(default_factory=list, alias="mappedClaimIds")
    role: str = Field(default="factual_foundation")


class BudgetAllocation(CanonicalBaseModel):
    """Resource and candidate allocation under parent budget cap."""

    max_candidates_per_slot: int = Field(default=1, ge=1, alias="maxCandidatesPerSlot")
    repair_headroom_calls: int = Field(default=2, ge=0, alias="repairHeadroomCalls")
    max_tokens_allocated: int = Field(default=15000, ge=1, alias="maxTokensAllocated")
    cost_cap_usd: Optional[float] = Field(default=None, alias="costCapUsd")
    parent_reservation_id: Optional[str] = Field(default=None, alias="parentReservationId")


class QuestionTypeAllocation(CanonicalBaseModel):
    """Allocation of question types within a section."""

    question_type: QuestionType = Field(..., alias="questionType")
    count: int = Field(..., ge=1)
    start_question_number: int = Field(..., ge=1, le=40, alias="startQuestionNumber")
    end_question_number: int = Field(..., ge=1, le=40, alias="endQuestionNumber")


class SectionBlueprint(CanonicalBaseModel):
    """Blueprint for a single reading section/passage."""

    section_id: int = Field(..., ge=1, le=3, alias="sectionId")
    topic: str
    target_word_count: int = Field(default=800, ge=720, le=915, alias="targetWordCount")
    evidence_graph_ref: Optional[EvidenceGraphRef] = Field(default=None, alias="evidenceGraphRef")
    passage_objectives: List[PassageObjective] = Field(
        default_factory=list,
        alias="passageObjectives",
    )
    question_allocations: List[QuestionTypeAllocation] = Field(
        default_factory=list,
        alias="questionAllocations",
    )
    question_slots: List[QuestionSlot] = Field(
        default_factory=list,
        alias="questionSlots",
    )
    budget_allocation: Optional[BudgetAllocation] = Field(
        default=None,
        alias="budgetAllocation",
    )
    total_questions: int = Field(..., ge=1, le=14, alias="totalQuestions")


class ExamBlueprint(CanonicalBaseModel):
    """Full reading paper blueprint specifying topics, types, and sequence."""

    blueprint_id: str = Field(..., alias="blueprintId")
    run_id: str = Field(..., alias="runId")
    policy_version: str = Field(default="v2.0.0", alias="policyVersion")
    schema_version: str = Field(default="v2.0.0", alias="schemaVersion")
    sections: List[SectionBlueprint] = Field(default_factory=list)
    total_questions: int = Field(default=40, ge=1, le=40, alias="totalQuestions")
    target_word_count_min: int = Field(default=2150, alias="targetWordCountMin")
    target_word_count_max: int = Field(default=2750, alias="targetWordCountMax")
    parent_budget_cap_tokens: Optional[int] = Field(
        default=None,
        alias="parentBudgetCapTokens",
    )
    content_hash: Optional[str] = Field(default=None, alias="contentHash")
    invalidated_descendants: bool = Field(default=False, alias="invalidatedDescendants")
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        alias="createdAt",
    )
    metadata: Optional[dict] = Field(default_factory=dict)
