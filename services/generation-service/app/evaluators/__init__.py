"""Evaluator system for Langfens Loop Engine V2."""

from app.evaluators.base import (
    BaseEvaluator,
    EvaluationStage,
    EvaluatorConfigurationError,
    EvaluatorConflictError,
    EvaluatorMetadata,
    EvaluatorMissingPrerequisiteError,
)
from app.evaluators.deterministic import (
    AnswerVerbatimAndLengthEvaluator,
    DuplicateAndShingleEvaluator,
    EvidenceOffsetEvaluator,
    PaperStructureEvaluator,
    PassageWordCountEvaluator,
    PassageStyleEvaluator,
    QuestionStructureEvaluator,
    check_prompt_answer_leakage,
    matches_exact_token_bound,
    normalize_text_nfkc,
)
from app.evaluators.semantic import (
    AmbiguityAndDistractorEvaluator,
    GroundingFidelityEvaluator,
    HeuristicQualityScorer,
    NotGivenSemanticsEvaluator,
)
from app.evaluators.registry import (
    EvaluationCache,
    EvaluatorRegistry,
    compute_evaluation_cache_key,
)

__all__ = [
    "AmbiguityAndDistractorEvaluator",
    "AnswerVerbatimAndLengthEvaluator",
    "BaseEvaluator",
    "DuplicateAndShingleEvaluator",
    "EvaluationCache",
    "EvaluationStage",
    "EvaluatorConfigurationError",
    "EvaluatorConflictError",
    "EvaluatorMetadata",
    "EvaluatorMissingPrerequisiteError",
    "EvaluatorRegistry",
    "EvidenceOffsetEvaluator",
    "GroundingFidelityEvaluator",
    "HeuristicQualityScorer",
    "NotGivenSemanticsEvaluator",
    "PaperStructureEvaluator",
    "PassageWordCountEvaluator",
    "PassageStyleEvaluator",
    "QuestionStructureEvaluator",
    "check_prompt_answer_leakage",
    "compute_evaluation_cache_key",
    "matches_exact_token_bound",
    "normalize_text_nfkc",
]
