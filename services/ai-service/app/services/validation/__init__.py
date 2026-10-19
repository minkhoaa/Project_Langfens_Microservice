"""Unified Question Validation Engine for All 19 IELTS Types."""
from __future__ import annotations

from app.services.validation.common import (
    ALL_19_TYPES,
    CHOICE_TYPES,
    COMPLETION_TYPES,
    MATCHING_TYPES,
    ORDERING_TYPE,
    SHORT_ANSWER_TYPE,
)
from app.services.validation.models import (
    IssueCode,
    Repairability,
    ScoredItemValidation,
    ValidationIssue,
    ValidationPolicy,
    ValidationResult,
    ValidationSeverity,
    ValidationStatus,
)
from app.services.validation.registry import (
    BaseQuestionValidator,
    QuestionValidatorRegistry,
    get_validator_registry,
)


def validate_question(
    question: any,
    passage: str | None = None,
    context: dict | None = None,
    policy: ValidationPolicy | None = None,
) -> ValidationResult:
    registry = get_validator_registry()
    return registry.validate_question(
        question=question,
        passage=passage,
        context=context,
        policy=policy,
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
    "BaseQuestionValidator",
    "QuestionValidatorRegistry",
    "get_validator_registry",
]
