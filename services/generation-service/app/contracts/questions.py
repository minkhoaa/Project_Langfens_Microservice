"""Canonical Question-Type Schemas for Langfens Loop Engine V2."""

from __future__ import annotations

from enum import Enum
from typing import Annotated, Any, Dict, List, Literal, Optional, Tuple, Type, Union
from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator
from typing_extensions import Self

from .base import CanonicalBaseModel
from .blueprint import QuestionType
from .evidence import AbsenceAssessment
from .question_type import QuestionPromptFamily


class TrueFalseAnswer(str, Enum):
    TRUE = "TRUE"
    FALSE = "FALSE"
    NOT_GIVEN = "NOT_GIVEN"


class YesNoAnswer(str, Enum):
    YES = "YES"
    NO = "NO"
    NOT_GIVEN = "NOT_GIVEN"


# ── Option representation for MCQ / Matching ───────────────────────────────────

class CandidateOption(CanonicalBaseModel):
    """Option item for candidate questions (MCQ, Matching, Box, etc.)."""

    model_config = ConfigDict(populate_by_name=True, extra="allow")
    key: str = Field(..., description="Option key, e.g. A, B, i, ii")
    text: str = Field(..., min_length=1, description="Option text")


# ── Base Candidate Schema ───────────────────────────────────────────────────────

class BaseCandidate(CanonicalBaseModel):
    """Base fields shared by candidate question models across all 19 families."""

    model_config = ConfigDict(frozen=False, populate_by_name=True, extra="allow")

    prompt: str = Field(..., min_length=3, description="Question stem or statement")
    answer: str = Field(..., min_length=1, description="Correct answer string or key")
    evidence_quote: str = Field(default="", alias="evidenceQuote", description="Direct verbatim quote from passage")
    evidence_span: Optional[Tuple[int, int]] = Field(default=None, alias="evidenceSpan")
    explanation: Optional[str] = Field(default=None, description="Detailed pedagogical explanation")
    question_number: Optional[int] = Field(default=None, alias="questionNumber", ge=1, le=40)
    slot_id: Optional[str] = Field(default=None, alias="slotId")
    candidate_id: Optional[str] = Field(default=None, alias="candidateId")
    metadata: Dict[str, Any] = Field(default_factory=dict)

    @field_validator("answer")
    @classmethod
    def validate_answer_cleanliness(cls, v: str) -> str:
        cleaned = str(v).strip()
        if not cleaned:
            raise ValueError("Answer cannot be empty")
        return cleaned


# ── 19 Candidate Schema Models ──────────────────────────────────────────────────

class TrueFalseCandidate(BaseCandidate):
    """Family 1: True / False / Not Given candidate."""

    question_type: QuestionPromptFamily = Field(
        default=QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN,
        alias="questionType",
    )
    absence_assessment: Optional[AbsenceAssessment] = Field(default=None, alias="absenceAssessment")


class YesNoCandidate(BaseCandidate):
    """Family 2: Yes / No / Not Given candidate."""

    question_type: QuestionPromptFamily = Field(
        default=QuestionPromptFamily.YES_NO_NOT_GIVEN,
        alias="questionType",
    )
    absence_assessment: Optional[AbsenceAssessment] = Field(default=None, alias="absenceAssessment")


class SentenceCompletionCandidate(BaseCandidate):
    """Family 3: Sentence Completion candidate."""

    question_type: QuestionPromptFamily = Field(
        default=QuestionPromptFamily.SENTENCE_COMPLETION,
        alias="questionType",
    )


class SummaryCompletionCandidate(BaseCandidate):
    """Family 4: Summary Completion (from passage text) candidate."""

    question_type: QuestionPromptFamily = Field(
        default=QuestionPromptFamily.SUMMARY_COMPLETION,
        alias="questionType",
    )
    summary_text: Optional[str] = Field(default=None, alias="summaryText")
    blank_index: Optional[int] = Field(default=None, alias="blankIndex")


class SummaryBoxCandidate(BaseCandidate):
    """Family 5: Summary Completion from a box of given options candidate."""

    question_type: QuestionPromptFamily = Field(
        default=QuestionPromptFamily.SUMMARY_COMPLETION_BOX,
        alias="questionType",
    )
    options: List[CandidateOption] = Field(default_factory=list, description="List of options in the box")
    summary_text: Optional[str] = Field(default=None, alias="summaryText")
    blank_index: Optional[int] = Field(default=None, alias="blankIndex")


class MultipleChoiceSingleCandidate(BaseCandidate):
    """Family 6: Multiple Choice (Single answer) candidate."""

    question_type: QuestionPromptFamily = Field(
        default=QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE,
        alias="questionType",
    )
    options: List[CandidateOption] = Field(
        default_factory=list,
        description="Candidate options (e.g., A, B, C, D)",
    )


class MultipleChoiceMultipleCandidate(BaseCandidate):
    """Family 7: Multiple Choice (Multiple answers) candidate."""

    question_type: QuestionPromptFamily = Field(
        default=QuestionPromptFamily.MULTIPLE_CHOICE_MULTIPLE,
        alias="questionType",
    )
    options: List[CandidateOption] = Field(
        default_factory=list,
        description="Candidate options (e.g., A through E)",
    )
    answers: List[str] = Field(
        default_factory=list,
        description="Multiple correct option keys, e.g. ['A', 'C']",
    )


class MatchingHeadingsCandidate(BaseCandidate):
    """Family 8: Matching Headings candidate."""

    question_type: QuestionPromptFamily = Field(
        default=QuestionPromptFamily.MATCHING_HEADING,
        alias="questionType",
    )
    paragraph_ref: Optional[str] = Field(default=None, alias="paragraphRef", description="Paragraph label, e.g. 'Paragraph A'")
    headings: List[CandidateOption] = Field(default_factory=list, description="List of roman numeral headings")


class MatchingInformationCandidate(BaseCandidate):
    """Family 9: Matching Information candidate."""

    question_type: QuestionPromptFamily = Field(
        default=QuestionPromptFamily.MATCHING_INFORMATION,
        alias="questionType",
    )
    target_paragraph: Optional[str] = Field(default=None, alias="targetParagraph", description="Paragraph letter, e.g. 'A'")


class MatchingFeaturesCandidate(BaseCandidate):
    """Family 10: Matching Features candidate."""

    question_type: QuestionPromptFamily = Field(
        default=QuestionPromptFamily.MATCHING_FEATURES,
        alias="questionType",
    )
    features: List[CandidateOption] = Field(default_factory=list, description="List of people/features, e.g. A-E")


class MatchingSentenceEndingsCandidate(BaseCandidate):
    """Family 11: Matching Sentence Endings candidate."""

    question_type: QuestionPromptFamily = Field(
        default=QuestionPromptFamily.MATCHING_ENDINGS,
        alias="questionType",
    )
    endings: List[CandidateOption] = Field(default_factory=list, description="List of sentence endings, e.g. A-G")


class TableCompletionCandidate(BaseCandidate):
    """Family 12: Table Completion candidate."""

    question_type: QuestionPromptFamily = Field(
        default=QuestionPromptFamily.TABLE_COMPLETION,
        alias="questionType",
    )
    table_context: Optional[str] = Field(default=None, alias="tableContext", description="Table structure or markdown text")
    row_header: Optional[str] = Field(default=None, alias="rowHeader")
    col_header: Optional[str] = Field(default=None, alias="colHeader")


class FlowChartCandidate(BaseCandidate):
    """Family 13: Flow Chart Completion candidate."""

    question_type: QuestionPromptFamily = Field(
        default=QuestionPromptFamily.FLOW_CHART,
        alias="questionType",
    )
    flow_steps: List[str] = Field(default_factory=list, alias="flowSteps", description="Process step descriptions")
    step_index: Optional[int] = Field(default=None, alias="stepIndex")
    svg_asset_id: Optional[str] = Field(default=None, alias="svgAssetId")


# Alias for FlowChartCompletionCandidate per spec
FlowChartCompletionCandidate = FlowChartCandidate


class DiagramLabelCandidate(BaseCandidate):
    """Family 14: Diagram Label Completion candidate."""

    question_type: QuestionPromptFamily = Field(
        default=QuestionPromptFamily.DIAGRAM_LABEL,
        alias="questionType",
    )
    callout_label: Optional[str] = Field(default=None, alias="calloutLabel")
    part_description: Optional[str] = Field(default=None, alias="partDescription")
    svg_asset_id: Optional[str] = Field(default=None, alias="svgAssetId")


class ShortAnswerCandidate(BaseCandidate):
    """Family 15: Short Answer question candidate."""

    question_type: QuestionPromptFamily = Field(
        default=QuestionPromptFamily.SHORT_ANSWER,
        alias="questionType",
    )


class NoteCompletionCandidate(BaseCandidate):
    """Family 16: Note Completion candidate."""

    question_type: QuestionPromptFamily = Field(
        default=QuestionPromptFamily.NOTE_COMPLETION,
        alias="questionType",
    )
    heading_context: Optional[str] = Field(default=None, alias="headingContext")
    bullet_prefix: Optional[str] = Field(default=None, alias="bulletPrefix")


class FormCompletionCandidate(BaseCandidate):
    """Family 17: Form Completion candidate."""

    question_type: QuestionPromptFamily = Field(
        default=QuestionPromptFamily.FORM_COMPLETION,
        alias="questionType",
    )
    field_label: Optional[str] = Field(default=None, alias="fieldLabel")


class ClassificationCandidate(BaseCandidate):
    """Family 18: Classification candidate."""

    question_type: QuestionPromptFamily = Field(
        default=QuestionPromptFamily.CLASSIFICATION,
        alias="questionType",
    )
    categories: List[CandidateOption] = Field(default_factory=list, description="Categories, e.g. A, B, C")


class ChoosingTitleCandidate(BaseCandidate):
    """Family 19: Choosing a Title candidate."""

    question_type: QuestionPromptFamily = Field(
        default=QuestionPromptFamily.CHOOSING_TITLE,
        alias="questionType",
    )
    options: List[CandidateOption] = Field(
        default_factory=list,
        description="Title options, typically A, B, C, D",
    )


# ── Registry for Candidate Schemas ──────────────────────────────────────────────

_CANDIDATE_SCHEMA_REGISTRY: Dict[QuestionPromptFamily, Type[BaseCandidate]] = {
    QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN: TrueFalseCandidate,
    QuestionPromptFamily.YES_NO_NOT_GIVEN: YesNoCandidate,
    QuestionPromptFamily.SENTENCE_COMPLETION: SentenceCompletionCandidate,
    QuestionPromptFamily.SUMMARY_COMPLETION: SummaryCompletionCandidate,
    QuestionPromptFamily.SUMMARY_COMPLETION_BOX: SummaryBoxCandidate,
    QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE: MultipleChoiceSingleCandidate,
    QuestionPromptFamily.MULTIPLE_CHOICE_MULTIPLE: MultipleChoiceMultipleCandidate,
    QuestionPromptFamily.MATCHING_HEADING: MatchingHeadingsCandidate,
    QuestionPromptFamily.MATCHING_INFORMATION: MatchingInformationCandidate,
    QuestionPromptFamily.MATCHING_FEATURES: MatchingFeaturesCandidate,
    QuestionPromptFamily.MATCHING_ENDINGS: MatchingSentenceEndingsCandidate,
    QuestionPromptFamily.TABLE_COMPLETION: TableCompletionCandidate,
    QuestionPromptFamily.FLOW_CHART: FlowChartCandidate,
    QuestionPromptFamily.DIAGRAM_LABEL: DiagramLabelCandidate,
    QuestionPromptFamily.SHORT_ANSWER: ShortAnswerCandidate,
    QuestionPromptFamily.NOTE_COMPLETION: NoteCompletionCandidate,
    QuestionPromptFamily.FORM_COMPLETION: FormCompletionCandidate,
    QuestionPromptFamily.CLASSIFICATION: ClassificationCandidate,
    QuestionPromptFamily.CHOOSING_TITLE: ChoosingTitleCandidate,
}


def get_candidate_schema(family: Union[QuestionPromptFamily, str]) -> Type[BaseCandidate]:
    """Return the Pydantic v2 candidate schema model for the given question family."""
    resolved_family = QuestionPromptFamily.from_raw(family)
    if resolved_family in _CANDIDATE_SCHEMA_REGISTRY:
        return _CANDIDATE_SCHEMA_REGISTRY[resolved_family]
    # Fallback to SentenceCompletionCandidate for generic completion or default
    return SentenceCompletionCandidate


# ── Legacy Final Paper Question Types (Retained for Paper & Section Contracts) ───

class BaseQuestion(CanonicalBaseModel):
    """Base fields shared by all question types in final papers."""

    question_number: int = Field(..., ge=1, le=40, alias="questionNumber")
    explanation: str = Field(..., min_length=10)


class TrueFalseNotGivenQuestion(BaseQuestion):
    """Question type 1: TRUE / FALSE / NOT GIVEN."""

    question_type: Literal[QuestionType.TRUE_FALSE_NOT_GIVEN] = Field(
        default=QuestionType.TRUE_FALSE_NOT_GIVEN,
        alias="questionType",
    )
    statement: str
    answer: TrueFalseAnswer
    evidence_quote: Optional[str] = Field(default=None, alias="evidenceQuote")
    absence_assessment: Optional[AbsenceAssessment] = Field(default=None, alias="absenceAssessment")

    @model_validator(mode="after")
    def validate_answer_evidence_consistency(self) -> Self:
        if self.answer == TrueFalseAnswer.NOT_GIVEN:
            if self.absence_assessment is None:
                raise ValueError("absenceAssessment is strictly required for NOT_GIVEN questions")
            if not self.absence_assessment.absence_confirmed:
                raise ValueError("absenceAssessment.absenceConfirmed must be True for NOT_GIVEN questions")
            if self.evidence_quote is not None:
                raise ValueError("evidenceQuote must not be present for NOT_GIVEN questions")
        else:
            if not self.evidence_quote or len(self.evidence_quote.strip()) < 10:
                raise ValueError(f"evidenceQuote is required for {self.answer.value} questions")
            if self.absence_assessment is not None:
                raise ValueError(f"absenceAssessment must not be present for {self.answer.value} questions")
        return self


class YesNoNotGivenQuestion(BaseQuestion):
    """Question type 5: YES / NO / NOT GIVEN."""

    question_type: Literal[QuestionType.YES_NO_NOT_GIVEN] = Field(
        default=QuestionType.YES_NO_NOT_GIVEN,
        alias="questionType",
    )
    statement: str
    answer: YesNoAnswer
    evidence_quote: Optional[str] = Field(default=None, alias="evidenceQuote")
    absence_assessment: Optional[AbsenceAssessment] = Field(default=None, alias="absenceAssessment")

    @model_validator(mode="after")
    def validate_answer_evidence_consistency(self) -> Self:
        if self.answer == YesNoAnswer.NOT_GIVEN:
            if self.absence_assessment is None:
                raise ValueError("absenceAssessment is strictly required for NOT_GIVEN questions")
            if not self.absence_assessment.absence_confirmed:
                raise ValueError("absenceAssessment.absenceConfirmed must be True for NOT_GIVEN questions")
            if self.evidence_quote is not None:
                raise ValueError("evidenceQuote must not be present for NOT_GIVEN questions")
        else:
            if not self.evidence_quote or len(self.evidence_quote.strip()) < 10:
                raise ValueError(f"evidenceQuote is required for {self.answer.value} questions")
            if self.absence_assessment is not None:
                raise ValueError(f"absenceAssessment must not be present for {self.answer.value} questions")
        return self


class MultipleChoiceSingleQuestion(BaseQuestion):
    """Question type 3: 4-Option Multiple Choice Single."""

    question_type: Literal[QuestionType.MULTIPLE_CHOICE_SINGLE] = Field(
        default=QuestionType.MULTIPLE_CHOICE_SINGLE,
        alias="questionType",
    )
    prompt: str
    options: List[str] = Field(..., min_length=4, max_length=4)
    correct_option: str = Field(..., alias="correctOption", pattern=r"^[A-D]$")
    evidence_quote: str = Field(..., min_length=10, alias="evidenceQuote")

    @field_validator("options")
    @classmethod
    def validate_distinct_options(cls, v: List[str]) -> List[str]:
        normalized = [opt.strip().lower() for opt in v]
        if len(set(normalized)) != 4:
            raise ValueError("Multiple choice question must have exactly 4 distinct options")
        return v


class SentenceCompletionQuestion(BaseQuestion):
    """Question type 2: Sentence Completion."""

    question_type: Literal[QuestionType.SENTENCE_COMPLETION] = Field(
        default=QuestionType.SENTENCE_COMPLETION,
        alias="questionType",
    )
    prompt: str
    answer: str
    evidence_quote: str = Field(..., min_length=10, alias="evidenceQuote")


class SummaryCompletionQuestion(BaseQuestion):
    """Question type 4: Summary Completion item within a group."""

    question_type: Literal[QuestionType.SUMMARY_COMPLETION] = Field(
        default=QuestionType.SUMMARY_COMPLETION,
        alias="questionType",
    )
    prompt: str
    answer: str
    evidence_quote: str = Field(..., min_length=10, alias="evidenceQuote")


class ShortAnswerQuestion(BaseQuestion):
    """Question type 6: Short Answer Question."""

    question_type: Literal[QuestionType.SHORT_ANSWER] = Field(
        default=QuestionType.SHORT_ANSWER,
        alias="questionType",
    )
    prompt: str
    answer: str
    evidence_quote: str = Field(..., min_length=10, alias="evidenceQuote")


QuestionUnion = Annotated[
    Union[
        TrueFalseNotGivenQuestion,
        SentenceCompletionQuestion,
        MultipleChoiceSingleQuestion,
        SummaryCompletionQuestion,
        YesNoNotGivenQuestion,
        ShortAnswerQuestion,
    ],
    Field(discriminator="question_type"),
]


class QuestionGroup(CanonicalBaseModel):
    """A cohesive group of questions sharing type, instructions, and optionally context."""

    group_id: str = Field(..., alias="groupId")
    question_type: QuestionType = Field(..., alias="questionType")
    instructions: str
    questions: List[QuestionUnion] = Field(default_factory=list)
    shared_context: Optional[str] = Field(default=None, alias="sharedContext")


class ReadingSection(CanonicalBaseModel):
    """A single reading section with a passage and question groups."""

    section_id: int = Field(..., ge=1, le=3, alias="sectionId")
    title: str
    passage: str
    word_count: int = Field(..., ge=0, alias="wordCount")
    groups: List[QuestionGroup] = Field(default_factory=list)


class ReadingPaper(CanonicalBaseModel):
    """Complete IELTS Reading paper with 1 to 3 sections."""

    paper_id: str = Field(..., alias="paperId")
    run_id: str = Field(..., alias="runId")
    title: str
    sections: List[ReadingSection] = Field(default_factory=list)
    total_questions: int = Field(..., ge=1, le=40, alias="totalQuestions")
    total_word_count: int = Field(..., ge=0, alias="totalWordCount")
