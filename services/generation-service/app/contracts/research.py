"""Canonical Research Request, Neutral Output, and Generation Result Contracts (RG05).

Implements normative C1/C2 schemas from generation_baseline/contracts/JSON_SCHEMAS.json:
- ReadingTask ($defs/ReadingTask): task_type="READING_SINGLE_PASSAGE", 1-2 requested_groups.
- NeutralOutput ($defs/NeutralOutput): context_text, question_groups, questions (answers stripped).
- GenerationResult ($defs/GenerationResult): full execution status, output availability, and metadata refs.

Invariants:
- Standalone reading research units cannot impersonate 40-question full-paper exams.
- Parseable failed output is preserved for fair external evaluation.
- UNKNOWN provider tokens are not coerced to zero.
"""

from __future__ import annotations

from enum import Enum
from typing import Any, Dict, List, Literal, Optional, Union
from typing_extensions import Self
from pydantic import BaseModel, Field, field_validator, model_validator
from app.contracts.base import CanonicalBaseModel

class StandaloneGroupType(str, Enum):
    TFNG = "TFNG"
    SENTENCE_COMPLETION = "SENTENCE_COMPLETION"
    MCQ_SINGLE = "MCQ_SINGLE"
    SUMMARY_COMPLETION = "SUMMARY_COMPLETION"
    YNNG = "YNNG"
    SHORT_ANSWER = "SHORT_ANSWER"


class GrammarQuestionType(str, Enum):
    GRAMMAR_MCQ = "GRAMMAR_MCQ"
    GRAMMAR_GAP = "GRAMMAR_GAP"
    GRAMMAR_CORRECTION = "GRAMMAR_CORRECTION"

class GrammarExerciseType(str, Enum):
    MCQ_SINGLE = "MCQ_SINGLE"
    GAP_FILL = "GAP_FILL"
    ERROR_CORRECTION = "ERROR_CORRECTION"


class SourceRef(CanonicalBaseModel):
    """Source provenance reference matching JSON_SCHEMAS.json#/$defs/SourceRef."""

    source_id: str = Field(..., min_length=1)
    source_family: str = Field(..., min_length=1)
    source_version: str = Field(..., min_length=1)
    source_sha256: str = Field(..., pattern=r"^[0-9a-f]{64}$")
    license: str = Field(..., min_length=1)
    provenance_uri: str = Field(..., min_length=1)


class GrammarRulePack(CanonicalBaseModel):
    """Grammar rule pack definition matching JSON_SCHEMAS.json#/$defs/GrammarRulePack."""

    rule_pack_id: str = Field(..., min_length=1)
    source: SourceRef
    topic: str = Field(..., min_length=1)
    level: str = Field(..., min_length=1)
    rule_ids: List[str] = Field(..., min_length=1)
    applicability: List[str] = Field(..., min_length=1)
    exceptions: List[str] = Field(default_factory=list)
    examples: List[str] = Field(..., min_length=1)


class GrammarTask(CanonicalBaseModel):
    """Grammar research exercise task matching JSON_SCHEMAS.json#/$defs/GrammarTask."""

    task_type: Literal["GRAMMAR_EXERCISE"] = "GRAMMAR_EXERCISE"
    grammar_rule_pack_ref: str = Field(..., min_length=1)
    exercise_type: GrammarExerciseType
    requested_question_count: int = Field(..., ge=1, le=40)
    difficulty: str = Field(..., min_length=1)


class ReferenceAnswerEvidence(CanonicalBaseModel):
    """Candidate-produced proposed answer evidence (not independent gold).

    Invariants:
    - Candidate-produced proposed answer with variants/context/rule ID.
    - Decisive acceptance condition: MUST NOT be called gold.
    - is_verified_gold is strictly constrained to Literal[False] = False.
    """

    question_id: str = Field(..., min_length=1)
    rule_pack_id: str = Field(..., min_length=1)
    target_rule_id: str = Field(..., min_length=1)
    context_sentence: str = Field(..., min_length=1)
    generator_proposed_answer: str = Field(..., min_length=1)
    acceptable_variants: List[str] = Field(default_factory=list)
    source_grounded_explanation: str = Field(..., min_length=1)
    is_verified_gold: Literal[False] = False

class ExecutionStatus(str, Enum):
    COMPLETED = "COMPLETED"
    FAILED_VALIDATION = "FAILED_VALIDATION"
    FAILED_RUNTIME = "FAILED_RUNTIME"
    TIMED_OUT = "TIMED_OUT"
    CANCELLED = "CANCELLED"


class OutputAvailability(str, Enum):
    NONE = "NONE"
    RAW_ONLY = "RAW_ONLY"
    PARSEABLE = "PARSEABLE"
    NORMALIZED = "NORMALIZED"


class ReadingTask(BaseModel):
    """Standalone reading research request specification matching JSON_SCHEMAS.json#/$defs/ReadingTask."""

    task_type: Literal["READING_SINGLE_PASSAGE"] = "READING_SINGLE_PASSAGE"
    requested_groups: List[StandaloneGroupType] = Field(..., min_length=1, max_length=2)
    requested_question_count: int = Field(..., ge=1, le=40)
    difficulty: str = Field(..., min_length=1)


class NeutralQuestion(BaseModel):
    """Allowlisted question schema for neutral output matching JSON_SCHEMAS.json#/$defs/Question."""

    question_id: str = Field(..., min_length=1)
    question_type: Union[StandaloneGroupType, GrammarQuestionType]
    text: str = Field(..., min_length=1)
    options: List[str] = Field(default_factory=list)
    instructions: str = Field(..., min_length=1)


class NeutralQuestionGroup(BaseModel):
    """Question group mapping in neutral output matching JSON_SCHEMAS.json#/$defs/NeutralOutput."""

    group_id: str = Field(..., min_length=1)
    question_ids: List[str] = Field(..., min_length=1)

class NeutralOutput(BaseModel):
    """Neutral generation output matching JSON_SCHEMAS.json#/$defs/NeutralOutput."""

    context_text: str = Field(..., min_length=1)
    question_groups: List[NeutralQuestionGroup]
    questions: List[NeutralQuestion]


class GenerationResult(BaseModel):
    """Canonical generation result matching JSON_SCHEMAS.json#/$defs/GenerationResult."""

    run_id: str = Field(..., min_length=1)
    dataset_item_id: str = Field(..., min_length=1)
    configuration_id: Literal["A", "B", "C"]
    task_type: Literal["READING_SINGLE_PASSAGE", "READING_FULL_PAPER", "GRAMMAR_EXERCISE"]
    execution_status: ExecutionStatus
    output_availability: OutputAvailability
    generated_content: Optional[NeutralOutput] = None
    private_answer_ref: Optional[str] = Field(default=None, min_length=1)
    trace_ref: Optional[str] = Field(default=None, min_length=1)
    usage_ref: Optional[str] = Field(default=None, min_length=1)
    failure_code: Optional[str] = Field(default=None, min_length=1)
    output_schema_version: str = Field(default="v3", min_length=1)


class StandaloneReadingRequest(BaseModel):
    """Authenticated request initiating standalone reading research generation."""

    run_id: str = Field(..., min_length=1)
    dataset_item_id: str = Field(..., min_length=1)
    configuration_id: Literal["A", "B", "C"]
    task: ReadingTask
    source_pack_id: str = Field(..., min_length=1)
    is_research_mode: bool = True

    @model_validator(mode="after")
    def validate_not_full_paper(self) -> Self:
        """Enforces that research unit cannot impersonate a 40-question full-paper exam."""
        if self.task.task_type != "READING_SINGLE_PASSAGE":
            raise ValueError(
                f"Invalid task_type '{self.task.task_type}' for standalone reading unit. Expected 'READING_SINGLE_PASSAGE'."
            )
        if len(self.task.requested_groups) > 2:
            raise ValueError(
                f"Standalone reading unit allows at most 2 groups, got {len(self.task.requested_groups)}."
            )
        return self


class StandaloneGrammarRequest(CanonicalBaseModel):
    """Authenticated request initiating standalone grammar exercise research generation."""

    run_id: str = Field(..., min_length=1)
    dataset_item_id: str = Field(..., min_length=1)
    configuration_id: Literal["A", "B", "C"]
    task: GrammarTask
    rule_pack: GrammarRulePack
    is_research_mode: bool = True

    @model_validator(mode="after")
    def validate_grammar_task(self) -> Self:
        """Enforces that grammar research unit adheres to grammar contracts."""
        if self.task.task_type != "GRAMMAR_EXERCISE":
            raise ValueError(
                f"Invalid task_type '{self.task.task_type}' for grammar unit. Expected 'GRAMMAR_EXERCISE'."
            )
        return self


class ExperimentAssignment(CanonicalBaseModel):
    """Experiment assignment mapping matching JSON_SCHEMAS.json#/$defs/ExperimentAssignment."""

    assignment_id: str = Field(..., min_length=1)
    dataset_item_id: str = Field(..., min_length=1)
    configuration_id: Literal["A", "B", "C"]
    attempt_number: int = Field(default=1, ge=1)
    run_id: Optional[str] = Field(default=None)
    result_ref: Optional[str] = Field(default=None)


class PromptVersionMap(CanonicalBaseModel):
    """Prompt versions for arms A, B, and C matching ExperimentManifest.prompt_versions."""

    A: str = Field(..., min_length=1)
    B: str = Field(..., min_length=1)
    C: str = Field(..., min_length=1)


class ExperimentManifest(CanonicalBaseModel):
    """Frozen experiment manifest matching JSON_SCHEMAS.json#/$defs/ExperimentManifest."""

    experiment_id: str = Field(..., min_length=1)
    dataset_version: str = Field(..., min_length=1)
    split: Literal["FINAL_EVAL"] = "FINAL_EVAL"
    source_sha256: str = Field(..., pattern=r"^[0-9a-f]{64}$")
    code_commit_sha: str = Field(..., min_length=1)
    foundation_model_id: str = Field(..., min_length=1)
    prompt_versions: PromptVersionMap
    rubric_version: str = Field(..., min_length=1)
    assignments: List[ExperimentAssignment] = Field(..., min_length=1)
    primary_endpoint: str = Field(..., min_length=1)
    analysis_plan_sha256: str = Field(..., pattern=r"^[0-9a-f]{64}$")


class PairedTaskFixture(CanonicalBaseModel):
    """Common task fixture paired across configurations A, B, and C."""

    dataset_item_id: str = Field(..., min_length=1)
    domain: Literal["READING", "GRAMMAR"]
    source: SourceRef
    foundation_model_id: str = Field(..., min_length=1)
    prompt_versions: PromptVersionMap
    rubric_version: str = Field(default="rubric-qgeval-v2.0", min_length=1)
    reading_task: Optional[ReadingTask] = None
    passage_text: Optional[str] = None
    grammar_task: Optional[GrammarTask] = None
    rule_pack: Optional[GrammarRulePack] = None

    @model_validator(mode="after")
    def validate_domain_payload(self) -> Self:
        if self.domain == "READING":
            if not self.reading_task:
                raise ValueError("Reading domain requires reading_task")
            if not self.passage_text or not self.passage_text.strip():
                raise ValueError("Reading domain requires non-empty passage_text")
        elif self.domain == "GRAMMAR":
            if not self.grammar_task:
                raise ValueError("Grammar domain requires grammar_task")
            if not self.rule_pack:
                raise ValueError("Grammar domain requires rule_pack")
        return self
