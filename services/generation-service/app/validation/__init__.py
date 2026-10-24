"""Unified Question Validation Engine for All 19 IELTS Types."""
from __future__ import annotations

from app.validation.common import (
    ALL_19_TYPES,
    CHOICE_TYPES,
    COMPLETION_TYPES,
    MATCHING_TYPES,
    ORDERING_TYPE,
    SHORT_ANSWER_TYPE,
)
from app.validation.models import (
    IssueCode,
    Repairability,
    ScoredItemValidation,
    ValidationIssue,
    ValidationPolicy,
    ValidationResult,
    ValidationSeverity,
    ValidationStatus,
)
from app.validation.pipeline import (
    validate_question,
    validate_question_async,
    validate_question_batch,
)
from app.validation.registry import (
    BaseQuestionValidator,
    QuestionValidatorRegistry,
    get_validator_registry,
)

__all__ = [
    "ALL_19_TYPES",
    "CHOICE_TYPES",
    "COMPLETION_TYPES",
    "MATCHING_TYPES",
    "ORDERING_TYPE",
    "SHORT_ANSWER_TYPE",
    "IssueCode",
    "Repairability",
    "ScoredItemValidation",
    "ValidationIssue",
    "ValidationPolicy",
    "ValidationResult",
    "ValidationSeverity",
    "ValidationStatus",
    "validate_question",
    "validate_question_async",
    "validate_question_batch",
    "BaseQuestionValidator",
    "QuestionValidatorRegistry",
    "get_validator_registry",
]
