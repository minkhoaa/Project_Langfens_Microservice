"""Versioned Three-Tier Evaluation Rubric for IELTS Reading Generation (RG03-S01).

Implements normative research rubric definitions from generation_baseline/research/RUBRIC.md:
- Tier 1: Deterministic hard checks (schema, cardinality, boundaries, duplicate IDs).
- Tier 2: QGEval-inspired dimensions (clarity, fluency, relevance, grounding, answerability) with 1-5 anchors.
- Tier 3: Type-specific task validity (TFNG entailment/contradiction/absence, MCQ single-answer, verbatim checks).

Core Invariant:
High fluency cannot compensate for low grounding. Fluent but wrong or ungrounded content MUST FAIL.
"""

from __future__ import annotations

from enum import Enum
import hashlib
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field, field_validator


class EvaluationVerdict(str, Enum):
    PASS = "PASS"
    FAIL = "FAIL"
    UNCERTAIN = "UNCERTAIN"
    NOT_RUN = "NOT_RUN"


class RubricDimension(str, Enum):
    CLARITY = "clarity"
    FLUENCY = "fluency"
    RELEVANCE = "relevance"
    GROUNDING = "grounding"
    ANSWERABILITY = "answerability"


DIMENSION_ANCHORS: Dict[RubricDimension, Dict[int, str]] = {
    RubricDimension.CLARITY: {
        1: "Vague referents, incomprehensible phrasing, or contradictory syntax",
        2: "Noticeably awkward structure requiring rereading to decipher intent",
        3: "Understandable with minor syntactic roughness or ambiguous modifiers",
        4: "Clear, natural, and unambiguous statement or question",
        5: "Flawlessly precise, elegant, and standard IELTS phrasing",
    },
    RubricDimension.FLUENCY: {
        1: "Severe grammatical errors, broken grammar, or non-English fragments",
        2: "Multiple noticeable grammatical or colocation errors",
        3: "Minor grammatical flaws that do not impede comprehension",
        4: "Natural, idiomatic, and grammatically correct English",
        5: "Publication-grade, authentic, and polished IELTS academic prose",
    },
    RubricDimension.RELEVANCE: {
        1: "Off-topic, unrelated to the passage, or wrong question format entirely",
        2: "Weak connection to central passage themes or misaligned task prompt",
        3: "Tangentially relevant with some peripheral focus",
        4: "Directly assesses key passage information appropriate to the task",
        5: "Exemplary IELTS question targeting core cognitive reading skills",
    },
    RubricDimension.GROUNDING: {
        1: "Entirely ungrounded, hallucinated, or contradicts passage facts",
        2: "Unsupported inferences, speculative leaps, or fabricated details",
        3: "Mostly grounded but requires tenuous inference not directly stated",
        4: "Directly verifiable against passage text and explicitly supported",
        5: "Rock-solid textual grounding with exact span alignment",
    },
    RubricDimension.ANSWERABILITY: {
        1: "Impossible to answer from the passage, or multiple conflicting answers",
        2: "Extremely difficult or unfair due to missing context or misleading cues",
        3: "Answerable but requires subjective judgment or borderline assumptions",
        4: "Answerable with high confidence solely from the provided text",
        5: "Unambiguously and uniquely answerable with strict IELTS rigor",
    },
}


class RubricProfile(BaseModel):
    """Frozen evaluation rubric profile thresholds and weights."""

    rubric_version: str = "R1-2026.1"
    min_average_score: float = 3.5
    min_dimension_score: float = 2.0
    min_grounding_score: float = 3.0  # Grounding cannot be compromised by fluency

    def evaluate_semantic_scores(
        self, scores: Dict[str, float]
    ) -> tuple[bool, Optional[str]]:
        """Evaluates whether dimension scores meet the rubric acceptance threshold.

        Returns (is_acceptable, rejection_reason).
        Rule: High fluency CANNOT compensate for low grounding (grounding <= 2 fails unconditionally).
        """
        for dim in RubricDimension:
            val = scores.get(dim.value)
            if val is None:
                return False, f"Missing required dimension: {dim.value}"
            if val < 1.0 or val > 5.0:
                return False, f"Dimension {dim.value} out of range [1, 5]: {val}"

        grounding = scores[RubricDimension.GROUNDING.value]
        if grounding < self.min_grounding_score:
            return (
                False,
                f"Grounding score {grounding} is below threshold {self.min_grounding_score}. Beautiful but ungrounded content cannot PASS.",
            )

        for dim_name, val in scores.items():
            if val < self.min_dimension_score:
                return (
                    False,
                    f"Dimension {dim_name} score {val} is below minimum {self.min_dimension_score}",
                )

        avg_score = sum(scores.values()) / len(scores)
        if avg_score < self.min_average_score:
            return (
                False,
                f"Average score {avg_score:.2f} is below required threshold {self.min_average_score}",
            )

        return True, None


class GrammarRubricProfile(RubricProfile):
    """Rubric profile tailored for grammar evaluation without polluting frozen reading profile."""

    rubric_version: str = "RG06-grammar-v1.0"


class CanonicalEvaluationResult(BaseModel):
    """Typed evaluation result strictly complying with JSON_SCHEMAS.json#/$defs/EvaluationResult."""

    evaluation_id: str = Field(..., min_length=1)
    dataset_item_id: str = Field(..., min_length=1)
    output_sha256: str = Field(..., pattern=r"^[0-9a-f]{64}$")
    rubric_version: str = Field(..., min_length=1)
    evaluator_version: str = Field(..., min_length=1)
    evaluable: bool
    hard_checks: Dict[str, Any]
    semantic_scores: Dict[str, Any]
    task_validity: Dict[str, Any]
    verdict: EvaluationVerdict
    abstention_reason: Optional[str] = None
    evidence_refs: List[str] = Field(default_factory=list)

    @field_validator("verdict", mode="before")
    @classmethod
    def _coerce_verdict(cls, v: Any) -> EvaluationVerdict:
        if isinstance(v, str):
            return EvaluationVerdict(v)
        return v


def compute_output_sha256(content: str) -> str:
    """Computes standard sha256 hex digest for content tracking."""
    return hashlib.sha256(content.strip().encode("utf-8")).hexdigest()
