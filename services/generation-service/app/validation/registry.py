"""Base validator interface and authoritative question validator registry."""
from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Any, Dict, List, Optional, Tuple

from app.validation.common import (
    ALL_19_TYPES,
    check_forbidden_fields,
    validate_english_text,
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


class BaseQuestionValidator(ABC):
    """Abstract base class for IELTS question validators.

    Separates 6 validation responsibilities:
    A. Structural schema correctness
    B. Answer-key integrity and option references
    C. Type-specific semantic correctness
    D. Passage grounding and answer evidence
    E. English-language consistency
    F. Scored-item granularity and grading compatibility
    """

    @property
    @abstractmethod
    def question_type(self) -> str:
        """The canonical QuestionType string."""
        ...

    @property
    @abstractmethod
    def allowed_answer_fields(self) -> set[str]:
        """Fields allowed for this question's answer family."""
        ...

    def validate_structure(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
        """Verify structural fields, type, skill, difficulty, promptMd."""
        issues: List[ValidationIssue] = []

        qtype = question.get("type")
        if qtype != self.question_type:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_UNKNOWN_TYPE,
                    message=f"type must be '{self.question_type}', got '{qtype}'",
                    field_path="type",
                    repairability=Repairability.REPAIRABLE_AUTOMATIC,
                )
            )

        skill = question.get("skill")
        if not skill or skill != "READING":
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_SKILL_MISMATCH,
                    message=f"skill must be 'READING', got '{skill}'",
                    field_path="skill",
                    repairability=Repairability.REPAIRABLE_AUTOMATIC,
                )
            )

        diff = question.get("difficulty")
        if type(diff) is not int or isinstance(diff, bool) or not (1 <= diff <= 5):
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_DIFFICULTY_OUT_OF_RANGE,
                    message=f"difficulty must be an integer in range [1, 5], got {diff}",
                    field_path="difficulty",
                    repairability=Repairability.REPAIRABLE_AUTOMATIC,
                )
            )

        prompt_md = question.get("promptMd")
        if not isinstance(prompt_md, str) or not prompt_md.strip():
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_PROMPT_EMPTY,
                    message="promptMd must be a non-empty string",
                    field_path="promptMd",
                    repairability=Repairability.IRREPARABLE,
                )
            )

        issues.extend(
            check_forbidden_fields(question, self.allowed_answer_fields, self.question_type)
        )
        return issues

    def validate_language(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
        """Verify English-only policy for candidate-facing text."""
        issues: List[ValidationIssue] = []
        if not policy.enforce_language:
            return issues

        prompt_md = question.get("promptMd")
        if isinstance(prompt_md, str):
            issues.extend(validate_english_text(prompt_md, "promptMd"))

        explanation = question.get("explanationMd")
        if isinstance(explanation, str):
            issues.extend(validate_english_text(explanation, "explanationMd"))

        return issues

    @abstractmethod
    def validate_answer_key(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> Tuple[List[ValidationIssue], List[ScoredItemValidation]]:
        """Validate answer key integrity, option references, and map scored items."""
        ...

    @abstractmethod
    def validate_type_specific(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
        """Type-specific rules (cardinality, markers, word limits, etc.)."""
        ...

    def validate_grounding(
        self,
        question: Dict[str, Any],
        passage: Optional[str],
        scored_items: List[ScoredItemValidation],
        policy: ValidationPolicy,
    ) -> List[ValidationIssue]:
        """Verify grounding against passage. Default implementation checks evidence/options."""
        return []

    def validate(
        self,
        question: Any,
        passage: Optional[str] = None,
        context: Optional[Dict[str, Any]] = None,
        policy: Optional[ValidationPolicy] = None,
    ) -> ValidationResult:
        """Run all 6 validation responsibilities and return unified ValidationResult."""
        pol = policy or ValidationPolicy()

        if not isinstance(question, dict):
            return ValidationResult(
                status=ValidationStatus.INVALID,
                question_type=self.question_type,
                schema_version=pol.schema_version,
                issues=[
                    ValidationIssue(
                        code=IssueCode.ERR_MALFORMED_STRUCTURE,
                        message="question must be a JSON object",
                        severity=ValidationSeverity.CRITICAL,
                        is_blocking=True,
                        field_path="",
                        repairability=Repairability.IRREPARABLE,
                    )
                ],
                reasons=["Payload is not a dictionary"],
            )

        all_issues: List[ValidationIssue] = []

        # A. Structural schema
        all_issues.extend(self.validate_structure(question, pol))

        # E. Language policy
        all_issues.extend(self.validate_language(question, pol))

        # B & F. Answer key & scored items
        key_issues, scored_items = self.validate_answer_key(question, pol)
        all_issues.extend(key_issues)

        # C. Type-specific semantic rules
        all_issues.extend(self.validate_type_specific(question, pol))

        # D. Grounding
        if pol.enforce_grounding and passage:
            grounding_issues = self.validate_grounding(question, passage, scored_items, pol)
            all_issues.extend(grounding_issues)

        # Determine status
        has_blocking = any(issue.is_blocking for issue in all_issues)
        has_critical = any(issue.severity == ValidationSeverity.CRITICAL for issue in all_issues)
        has_review = any(issue.code == IssueCode.ERR_EVALUATION_INCONCLUSIVE for issue in all_issues)

        if has_critical or has_blocking:
            status = ValidationStatus.INVALID
        elif has_review:
            status = ValidationStatus.NEEDS_REVIEW
        else:
            status = ValidationStatus.VALID

        is_repairable = bool(
            all_issues
            and all(issue.repairability != Repairability.IRREPARABLE for issue in all_issues)
        )

        reasons = [issue.message for issue in all_issues if issue.is_blocking]

        return ValidationResult(
            status=status,
            question_type=self.question_type,
            schema_version=pol.schema_version,
            issues=all_issues,
            scored_items=scored_items,
            is_repairable=is_repairable,
            reasons=reasons,
        )


class QuestionValidatorRegistry:
    """Authoritative registry for all 19 IELTS question validators."""

    def __init__(self) -> None:
        self._validators: Dict[str, BaseQuestionValidator] = {}

    def register(self, validator: BaseQuestionValidator) -> None:
        qtype = validator.question_type
        if qtype not in ALL_19_TYPES:
            raise ValueError(f"Cannot register unknown IELTS question type: {qtype}")
        self._validators[qtype] = validator

    def get(self, question_type: str) -> Optional[BaseQuestionValidator]:
        return self._validators.get(question_type)

    def list_registered_types(self) -> List[str]:
        return sorted(self._validators.keys())

    def validate_question(
        self,
        question: Any,
        passage: Optional[str] = None,
        context: Optional[Dict[str, Any]] = None,
        policy: Optional[ValidationPolicy] = None,
    ) -> ValidationResult:
        if not isinstance(question, dict):
            return ValidationResult(
                status=ValidationStatus.INVALID,
                question_type="UNKNOWN",
                issues=[
                    ValidationIssue(
                        code=IssueCode.ERR_MALFORMED_STRUCTURE,
                        message="question must be a JSON object",
                        severity=ValidationSeverity.CRITICAL,
                        is_blocking=True,
                    )
                ],
                reasons=["Payload is not a dictionary"],
            )

        qtype = question.get("type", "UNKNOWN")
        validator = self._validators.get(qtype)
        if not validator:
            return ValidationResult(
                status=ValidationStatus.INVALID,
                question_type=qtype,
                issues=[
                    ValidationIssue(
                        code=IssueCode.ERR_UNKNOWN_TYPE,
                        message=f"No registered validator for question type '{qtype}'",
                        severity=ValidationSeverity.CRITICAL,
                        is_blocking=True,
                        field_path="type",
                        repairability=Repairability.IRREPARABLE,
                    )
                ],
                reasons=[f"Unregistered question type: {qtype}"],
            )

        return validator.validate(question, passage=passage, context=context, policy=policy)


_REGISTRY: Optional[QuestionValidatorRegistry] = None


def get_validator_registry() -> QuestionValidatorRegistry:
    global _REGISTRY
    if _REGISTRY is None:
        from app.validation.validators import register_all_validators
        _REGISTRY = QuestionValidatorRegistry()
        register_all_validators(_REGISTRY)
    return _REGISTRY
