"""Canonical Blind Solver and Adversary Contracts for Langfens Loop Engine V2 (Phase 10).

Work Packages:
- P10-01: Minimal canonical solver/adversary DTO (allowlist-only student-visible fields).
- P10-02: Solver/adversary versioned prompts, input/output schemas, asset hashes, redacted logs.
- P10-03: Solver output normalized answer, cited exact passage spans, and short justification.
- P10-04: Adversary output plausible alternatives, ambiguity type, and grounded evidence.
- P10-05: Comparison canonical TFNG/YNNG, option-ID MCQ, exact normalization/aliases.
- P10-06: Diversity profile with provider/model tracing and correlated-review limitations.
"""

from __future__ import annotations

import hashlib
import json
import re
from enum import Enum
from typing import Any, Dict, List, Optional, Tuple
from pydantic import ConfigDict, Field, field_validator, model_validator
from typing_extensions import Self

from app.contracts.base import CanonicalBaseModel


class SecurityLeakageError(ValueError):
    """Raised when private/answer metadata leaks into a student-visible payload."""
    pass


class AdversaryAmbiguityType(str, Enum):
    """Classification of ambiguity identified by the adversary."""
    MULTIPLE_VALID_OPTIONS = "MULTIPLE_VALID_OPTIONS"
    INTERPRETATION_SPLIT = "INTERPRETATION_SPLIT"
    UNSUPPORTED_KEY = "UNSUPPORTED_KEY"
    KEY_CONTRADICTED = "KEY_CONTRADICTED"
    VAGUE_PROMPT = "VAGUE_PROMPT"


class AdjudicationVerdict(str, Enum):
    """Final verdict reached after evaluating solver answer and adversary critique."""
    KEY_CONFIRMED = "KEY_CONFIRMED"
    AMBIGUOUS_DEFECTIVE = "AMBIGUOUS_DEFECTIVE"
    KEY_UNGROUNDED = "KEY_UNGROUNDED"
    KEY_CONTRADICTED = "KEY_CONTRADICTED"
    SOLVER_DEFECTIVE = "SOLVER_DEFECTIVE"
    ADVERSARY_REJECTED = "ADVERSARY_REJECTED"


class DisagreementSeverity(str, Enum):
    """Severity of disagreement between expected key, solver answer, and adversary critique."""
    NONE = "NONE"
    LOW = "LOW"
    HIGH = "HIGH"


class StudentVisibleOption(CanonicalBaseModel):
    """A single multiple choice option visible to students.

    Contains ONLY the letter key and the visible text. Strictly forbids correctOption,
    explanation, or distractor annotations.
    """
    key: str = Field(..., pattern=r"^[A-D]$", description="Option letter: A, B, C, or D")
    text: str = Field(..., min_length=1, description="Option text as visible to the student")


class StudentVisibleQuestion(CanonicalBaseModel):
    """Strictly minimal question projection visible to the student.

    Contains ONLY:
    - question_number: 1..40
    - question_type: canonical IELTS question type
    - prompt: student-visible question stem or sentence prompt
    - instructions: optional type-specific instructions
    - options: optional list of StudentVisibleOption (for MCQ)
    - shared_context: optional shared paragraph or diagram text (e.g. for summary completion)

    STRICTLY FORBIDS:
    - answer, correct_option, correctOption
    - evidence_quote, evidenceQuote, evidence_span, evidenceSpan
    - explanation, absence_assessment, absenceAssessment
    - internal hints, generation prompts, rejected alternatives, canary metadata
    """
    question_number: int = Field(..., ge=1, le=40, alias="questionNumber")
    question_type: str = Field(..., alias="questionType")
    prompt: str = Field(..., min_length=3)
    instructions: Optional[str] = None
    options: Optional[List[StudentVisibleOption]] = None
    shared_context: Optional[str] = Field(default=None, alias="sharedContext")


class BlindSolverInput(CanonicalBaseModel):
    """Canonical input payload for Blind Solver and Adversary evaluations.

    Contains ONLY:
    - passage_text: the approved reading passage
    - question: the minimal StudentVisibleQuestion
    - section_id: optional 1..3
    """
    passage_text: str = Field(..., min_length=50, alias="passageText")
    question: StudentVisibleQuestion
    section_id: Optional[int] = Field(default=None, ge=1, le=3, alias="sectionId")

    def to_canonical_payload(self) -> Dict[str, Any]:
        """Serializes strictly to allowlisted dictionary with zero leakage."""
        options_data = (
            [{"key": o.key, "text": o.text} for o in self.question.options]
            if self.question.options
            else None
        )
        payload: Dict[str, Any] = {
            "passageText": self.passage_text,
            "question": {
                "questionNumber": self.question.question_number,
                "questionType": self.question.question_type,
                "prompt": self.question.prompt,
                "instructions": self.question.instructions,
                "options": options_data,
                "sharedContext": self.question.shared_context,
            },
        }
        if self.section_id is not None:
            payload["sectionId"] = self.section_id

        # Hard invariant: verify no forbidden keys leaked into payload dictionary
        prohibited_keys = {
            "answer",
            "correctoption",
            "correct_option",
            "evidencequote",
            "evidence_quote",
            "evidencespan",
            "evidence_span",
            "explanation",
            "absenceassessment",
            "absence_assessment",
            "canary",
            "generationprompt",
            "generation_prompt",
            "metadata",
            "score",
            "rejected",
        }
        question_dict = payload.get("question", {})
        for k in list(payload.keys()) + (list(question_dict.keys()) if isinstance(question_dict, dict) else []):
            if k.lower() in prohibited_keys or k.lower().startswith("hidden_"):
                raise SecurityLeakageError(f"Prohibited field key '{k}' detected in BlindSolverInput payload")

        return payload

    def compute_request_hash(self) -> str:
        """Deterministic request hash invariant to answer key changes."""
        canonical_json = json.dumps(self.to_canonical_payload(), sort_keys=True)
        return hashlib.sha256(canonical_json.encode("utf-8")).hexdigest()


class SolverSpan(CanonicalBaseModel):
    """Exact verbatim quote cited from the passage as evidence."""
    span_text: str = Field(..., min_length=1, alias="spanText")
    start_char: Optional[int] = Field(default=None, ge=0, alias="startChar")
    end_char: Optional[int] = Field(default=None, ge=0, alias="endChar")


class SolverOutput(CanonicalBaseModel):
    """Normalized output produced by the blind solver.

    Invariants:
    - normalized_answer: clean normalized answer string
    - cited_spans: list of exact verbatim spans from the passage
    - justification: short justification (max 300 characters, no hidden chain-of-thought)
    - self_reported_confidence: 0.0..1.0, tracked as UNCALIBRATED
    """
    question_number: int = Field(..., ge=1, le=40, alias="questionNumber")
    normalized_answer: str = Field(..., min_length=1, alias="normalizedAnswer")
    cited_spans: List[SolverSpan] = Field(default_factory=list, alias="citedSpans")
    justification: str = Field(..., min_length=1, max_length=500)
    self_reported_confidence: float = Field(
        default=0.5,
        ge=0.0,
        le=1.0,
        alias="selfReportedConfidence",
        description="Self-reported model confidence, explicitly uncalibrated.",
    )
    is_confidence_calibrated: bool = Field(default=False, alias="isConfidenceCalibrated")
    execution_time_ms: Optional[float] = Field(default=None, alias="executionTimeMs")

    @field_validator("justification")
    @classmethod
    def validate_justification_brevity(cls, v: str) -> str:
        cleaned = v.strip()
        if len(cleaned) > 500:
            raise ValueError("Justification exceeds 500 characters; hidden chain-of-thought is prohibited")
        return cleaned


class AdversaryAlternative(CanonicalBaseModel):
    """An alternative answer identified by the adversary."""
    alternative_answer: str = Field(..., min_length=1, alias="alternativeAnswer")
    ambiguity_type: AdversaryAmbiguityType = Field(..., alias="ambiguityType")
    plausibility_score: float = Field(default=0.8, ge=0.0, le=1.0, alias="plausibilityScore")
    cited_spans: List[SolverSpan] = Field(default_factory=list, alias="citedSpans")
    reasoning: str = Field(..., min_length=5)
    is_grounded_in_passage: bool = Field(default=True, alias="isGroundedInPassage")


class AdversaryOutput(CanonicalBaseModel):
    """Normalized output produced by the adversarial verifier."""
    question_number: int = Field(..., ge=1, le=40, alias="questionNumber")
    is_ambiguous: bool = Field(..., alias="isAmbiguous")
    identified_alternatives: List[AdversaryAlternative] = Field(
        default_factory=list,
        alias="identifiedAlternatives",
    )
    adversary_summary: str = Field(..., min_length=1, alias="adversarySummary")
    execution_time_ms: Optional[float] = Field(default=None, alias="executionTimeMs")


class ComparisonResult(CanonicalBaseModel):
    """Exact comparison outcome between expected key and solver output.

    Expected key is ONLY evaluated here; never provided to solver/adversary inputs.
    """
    question_number: int = Field(..., ge=1, le=40, alias="questionNumber")
    is_match: bool = Field(..., alias="isMatch")
    expected_answer: str = Field(..., alias="expectedAnswer")
    solver_answer: str = Field(..., alias="solverAnswer")
    normalized_expected: str = Field(..., alias="normalizedExpected")
    normalized_solver: str = Field(..., alias="normalizedSolver")
    question_type: str = Field(..., alias="questionType")
    comparison_details: Dict[str, Any] = Field(default_factory=dict, alias="comparisonDetails")


class AdjudicationResult(CanonicalBaseModel):
    """Adjudication outcome synthesizing solver comparison and adversary findings."""
    question_number: int = Field(..., ge=1, le=40, alias="questionNumber")
    verdict: AdjudicationVerdict
    severity: DisagreementSeverity
    resolution_action: str = Field(..., alias="resolutionAction")
    solver_match: bool = Field(..., alias="solverMatch")
    adversary_ambiguity_found: bool = Field(..., alias="adversaryAmbiguityFound")
    details: Dict[str, Any] = Field(default_factory=dict)


class DiversityProfile(CanonicalBaseModel):
    """Model diversity profile and correlation trace (P10-06).

    Tracks actual provider and model versions. When the same model is used across roles,
    correlated_review is set to True to prevent claiming independent external review.
    """
    solver_provider: str = Field(..., alias="solverProvider")
    solver_model: str = Field(..., alias="solverModel")
    adversary_provider: str = Field(..., alias="adversaryProvider")
    adversary_model: str = Field(..., alias="adversaryModel")
    is_independent_model: bool = Field(..., alias="isIndependentModel")
    correlated_review: bool = Field(..., alias="correlatedReview")
    limitation_note: Optional[str] = Field(default=None, alias="limitationNote")
