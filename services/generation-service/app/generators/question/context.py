"""Data Contracts and Validation Models for Question Candidates (Phase 09 / P09-02).

Implements canonical schemas for:
- QuestionCandidate: validated single-question candidate with strict invariants.
- QuestionCandidatePool: bounded pool of candidates per question slot.
- QuestionGroupContext: shared context for cohesive question blocks (e.g. summaries).
- CandidateSelectionCriteria: ranking and joint constraint parameters.
"""

from __future__ import annotations

import re
from typing import Any, Dict, List, Optional, Set, Tuple
from uuid import uuid4
from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator

from app.contracts.artifact import ArtifactRef
from app.contracts.base import CanonicalBaseModel
from app.contracts.policies import count_words
from app.generators.question.prompts import QuestionPromptFamily


class OptionItem(CanonicalBaseModel):
    key: str = Field(..., description="Option letter: A, B, C, or D")
    text: str = Field(..., min_length=1, description="Option text")


class QuestionCandidate(CanonicalBaseModel):
    """Canonical representation of an individual generated question candidate."""

    model_config = ConfigDict(frozen=False, populate_by_name=True, extra="forbid")

    candidate_id: str = Field(..., alias="candidateId")
    slot_id: str = Field(..., alias="slotId")
    passage_ref: ArtifactRef = Field(..., alias="passageRef")
    blueprint_ref: ArtifactRef = Field(..., alias="blueprintRef")
    group_id: Optional[str] = Field(default=None, alias="groupId")
    evidence_claim_ref: Optional[str] = Field(default=None, alias="evidenceClaimRef")
    question_number: int = Field(..., alias="questionNumber", ge=1, le=40)
    question_type: str = Field(..., alias="questionType")
    prompt: str = Field(..., min_length=5)
    answer: str = Field(..., min_length=1)
    options: Optional[List[OptionItem]] = None
    evidence_quote: str = Field(default="", alias="evidenceQuote")
    evidence_span: Optional[Tuple[int, int]] = Field(default=None, alias="evidenceSpan")
    explanation: Optional[str] = None
    score: float = 1.0
    rejected: bool = False
    rejection_reasons: List[str] = Field(default_factory=list, alias="rejectionReasons")
    evaluation_ids: List[str] = Field(default_factory=list, alias="evaluationIds")
    metadata: Dict[str, Any] = Field(default_factory=dict)

    @field_validator("answer")
    @classmethod
    def validate_answer_cleanliness(cls, v: str) -> str:
        cleaned = v.strip()
        if not cleaned:
            raise ValueError("Answer cannot be empty")
        return cleaned

    @model_validator(mode="after")
    def validate_type_specific_invariants(self) -> QuestionCandidate:
        from app.validation.common import is_placeholder, validate_english_text
        family = QuestionPromptFamily.from_raw(self.question_type)
        ans = self.answer.strip()

        if is_placeholder(ans):
            self.rejected = True
            self.rejection_reasons.append(f"Answer '{ans}' cannot be a placeholder")

        lang_issues = validate_english_text(self.prompt, "prompt") + validate_english_text(ans, "answer")
        if lang_issues:
            self.rejected = True
            for li in lang_issues:
                self.rejection_reasons.append(li.message)
        if family == QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN:
            norm = ans.upper().replace("_", " ")
            if norm not in ("TRUE", "FALSE", "NOT GIVEN"):
                self.rejected = True
                self.rejection_reasons.append(f"Invalid TFNG answer '{ans}'; must be TRUE, FALSE, or NOT GIVEN")

        # 2. YesNoNotGiven invariants
        elif family == QuestionPromptFamily.YES_NO_NOT_GIVEN:
            norm = ans.upper().replace("_", " ")
            if norm not in ("YES", "NO", "NOT GIVEN"):
                self.rejected = True
                self.rejection_reasons.append(f"Invalid YNNG answer '{ans}'; must be YES, NO, or NOT GIVEN")

        # 3. SentenceCompletion, SummaryCompletion & ShortAnswer invariants: <= 3 words
        elif family in (
            QuestionPromptFamily.SENTENCE_COMPLETION,
            QuestionPromptFamily.SUMMARY_COMPLETION,
            QuestionPromptFamily.SHORT_ANSWER,
        ):
            w_count = count_words(ans)
            if w_count > 3:
                self.rejected = True
                self.rejection_reasons.append(
                    f"Answer exceeds maximum of 3 words: '{ans}' ({w_count} words)"
                )
            from app.evaluators.deterministic import check_prompt_answer_leakage
            if check_prompt_answer_leakage(self.prompt, ans):
                self.rejected = True
                self.rejection_reasons.append(
                    f"Answer '{ans}' leaks verbatim inside question prompt"
                )
            if family == QuestionPromptFamily.SENTENCE_COMPLETION:
                if "______" not in self.prompt and "[blank]" not in self.prompt.lower():
                    self.rejected = True
                    self.rejection_reasons.append("Sentence completion prompt missing blank marker '______'")
            elif family == QuestionPromptFamily.SHORT_ANSWER:
                if " and " in ans.lower() and re.match(r"^(what|which|where|when|who)\b", self.prompt.lower()):
                    self.rejected = True
                    self.rejection_reasons.append(f"Conjoined answer '{ans}' for singular question prompt")
        # 4. MultipleChoiceSingle invariants: exactly 4 options A-D, answer in options, no duplicate texts
        elif family == QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE:
            if not self.options or len(self.options) != 4:
                self.rejected = True
                self.rejection_reasons.append(
                    f"MCQ must have exactly 4 options, found {len(self.options) if self.options else 0}"
                )
            else:
                keys = [o.key.upper() for o in self.options]
                if keys != ["A", "B", "C", "D"]:
                    self.rejected = True
                    self.rejection_reasons.append(f"MCQ options keys must be ['A', 'B', 'C', 'D'], found {keys}")
                ans_key = ans.upper()
                if ans_key not in ("A", "B", "C", "D"):
                    self.rejected = True
                    self.rejection_reasons.append(f"MCQ answer key must be A, B, C, or D; found '{ans}'")

                # Check duplicate option texts
                seen_texts: Set[str] = set()
                for o in self.options:
                    t_norm = o.text.strip().lower()
                    if t_norm in seen_texts:
                        self.rejected = True
                        self.rejection_reasons.append(f"Duplicate option text '{o.text}'")
                    seen_texts.add(t_norm)

        return self

    def is_eligible(self) -> bool:
        return not self.rejected and len(self.rejection_reasons) == 0


class QuestionCandidatePool(CanonicalBaseModel):
    """Bounded pool of candidates generated for a specific question slot."""

    model_config = ConfigDict(frozen=False, populate_by_name=True, extra="forbid")

    slot_id: str = Field(..., alias="slotId")
    question_number: int = Field(..., alias="questionNumber")
    question_type: str = Field(..., alias="questionType")
    pool_limit: int = Field(default=3, alias="poolLimit")
    tokens_used: int = Field(default=0, alias="tokensUsed")
    wall_time_used_seconds: float = Field(default=0.0, alias="wallTimeUsedSeconds")
    candidates: List[QuestionCandidate] = Field(default_factory=list)
    selected_candidate_id: Optional[str] = Field(default=None, alias="selectedCandidateId")
    dropped_blank_reasons: Dict[int, str] = Field(default_factory=dict, alias="droppedBlankReasons")
    attempted_blank_count: int = Field(default=0, alias="attemptedBlankCount")

    def get_eligible_candidates(self) -> List[QuestionCandidate]:
        return [c for c in self.candidates if c.is_eligible()]

    def add_candidate(self, candidate: QuestionCandidate) -> bool:
        """Adds a candidate if bounded pool limit has not been reached."""
        if len(self.candidates) >= self.pool_limit:
            return False
        self.candidates.append(candidate)
        return True


class QuestionGroupContext(CanonicalBaseModel):
    """Context for a cohesive group of questions sharing common instructions or summary."""

    model_config = ConfigDict(frozen=False, populate_by_name=True, extra="forbid")

    group_id: str = Field(..., alias="groupId")
    section_index: int = Field(..., alias="sectionIndex")
    question_type: str = Field(..., alias="questionType")
    start_number: int = Field(..., alias="startNumber")
    end_number: int = Field(..., alias="endNumber")
    instructions: str
    summary_title: Optional[str] = Field(default=None, alias="summaryTitle")
    summary_text: Optional[str] = Field(default=None, alias="summaryText")
    passage_ref: ArtifactRef = Field(..., alias="passageRef")
    blueprint_ref: ArtifactRef = Field(..., alias="blueprintRef")
    group_version: int = Field(default=1, alias="groupVersion")


class CandidateSelectionCriteria(CanonicalBaseModel):
    """Parameters and weights for candidate scoring and selection."""

    grounding_weight: float = 0.40
    distractor_quality_weight: float = 0.25
    lexical_diversity_weight: float = 0.20
    length_compliance_weight: float = 0.15
    max_search_depth: int = 50
    max_backtracking_steps: int = 5000
    allow_redundant_evidence_spans: bool = False
