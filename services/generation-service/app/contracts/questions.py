"""Canonical Question-Type Schemas for Langfens Loop Engine V2."""

from __future__ import annotations

from enum import Enum
from typing import Annotated, List, Literal, Optional, Union
from pydantic import Field, field_validator, model_validator
from typing_extensions import Self

from .base import CanonicalBaseModel
from .blueprint import QuestionType
from .evidence import AbsenceAssessment


class TrueFalseAnswer(str, Enum):
    TRUE = "TRUE"
    FALSE = "FALSE"
    NOT_GIVEN = "NOT_GIVEN"


class YesNoAnswer(str, Enum):
    YES = "YES"
    NO = "NO"
    NOT_GIVEN = "NOT_GIVEN"


class BaseQuestion(CanonicalBaseModel):
    """Base fields shared by all question types."""

    question_number: int = Field(..., ge=1, le=40, alias="questionNumber")
    explanation: str = Field(..., min_length=10)


class TrueFalseNotGivenQuestion(BaseQuestion):
    """Question type 1: TRUE / FALSE / NOT GIVEN.

    NOT GIVEN items strictly require AbsenceAssessment and must not provide a fake positive quote.
    TRUE / FALSE items strictly require evidenceQuote and must not provide AbsenceAssessment.
    """

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
