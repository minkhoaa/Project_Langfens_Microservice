"""Base validator interface and authoritative question validator registry."""
from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Any, Dict, List, Optional, Tuple

from app.services.validation.common import (
    ALL_19_TYPES,
    check_forbidden_fields,
    validate_english_text,
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


class BaseQuestionValidator(ABC):
    @property
    @abstractmethod
    def question_type(self) -> str:
        ...

    @property
    @abstractmethod
    def allowed_answer_fields(self) -> set[str]:
        ...

    def validate_structure(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
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
        ...

    @abstractmethod
    def validate_type_specific(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
        ...

    def validate_grounding(
        self,
        question: Dict[str, Any],
        passage: Optional[str],
        scored_items: List[ScoredItemValidation],
        policy: ValidationPolicy,
    ) -> List[ValidationIssue]:
        return []

    def validate(
        self,
        question: Any,
        passage: Optional[str] = None,
        context: Optional[Dict[str, Any]] = None,
        policy: Optional[ValidationPolicy] = None,
    ) -> ValidationResult:
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

        structural_issues: List[ValidationIssue] = []

        # A. Structural schema
        structural_issues.extend(self.validate_structure(question, pol))

        # E. Language policy
        structural_issues.extend(self.validate_language(question, pol))

        # B & F. Answer key & scored items
        key_issues, scored_items = self.validate_answer_key(question, pol)
        structural_issues.extend(key_issues)

        # C. Type-specific semantic rules
        structural_issues.extend(self.validate_type_specific(question, pol))

        # Ensure every scored item has a valid canonical answer key
        if not scored_items:
            structural_issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_MISSING_ANSWER_KEY,
                    message=f"{self.question_type}: Every question must yield at least one scored item",
                    severity=ValidationSeverity.CRITICAL,
                    is_blocking=True,
                )
            )
        else:
            for item in scored_items:
                if not item.accepted_answers or all(not str(a).strip() for a in item.accepted_answers):
                    item.is_valid = False
                    structural_issues.append(
                        ValidationIssue(
                            code=IssueCode.ERR_MISSING_ANSWER_KEY,
                            message=f"{self.question_type}: Scored item [{item.item_key}] must have a non-empty canonical answer key",
                            severity=ValidationSeverity.ERROR,
                            is_blocking=True,
                            scored_item_index=item.item_index,
                        )
                    )

        structural_blocking = any(i.is_blocking or i.severity == ValidationSeverity.CRITICAL for i in structural_issues)
        structural_valid = not structural_blocking

        all_issues = list(structural_issues)
        grounding_verified = False
        semantic_valid: Optional[bool] = None

        # D. Grounding verification
        has_passage = bool(passage and isinstance(passage, str) and passage.strip())
        if has_passage:
            grounding_issues = self.validate_grounding(question, passage, scored_items, pol)
            all_issues.extend(grounding_issues)
            has_grounding_blockers = any(i.is_blocking or i.severity == ValidationSeverity.CRITICAL for i in grounding_issues)
            if has_grounding_blockers:
                grounding_verified = False
                semantic_valid = False
            else:
                grounding_verified = True
                semantic_valid = True
        else:
            # Invariant 1: No source passage must NOT silently imply successful grounding verification
            grounding_verified = False
            semantic_valid = None
            if pol.enforce_grounding:
                all_issues.append(
                    ValidationIssue(
                        code=IssueCode.ERR_EVALUATION_INCONCLUSIVE,
                        message="No source passage provided; grounding and semantic correctness remain unverified",
                        severity=ValidationSeverity.WARNING,
                        is_blocking=False,
                    )
                )

        # Determine status
        has_blocking = any(issue.is_blocking for issue in all_issues)
        has_critical = any(issue.severity == ValidationSeverity.CRITICAL for issue in all_issues)
        has_review = any(issue.code == IssueCode.ERR_EVALUATION_INCONCLUSIVE for issue in all_issues)

        if has_critical or has_blocking:
            status = ValidationStatus.INVALID
        elif pol.enforce_grounding and not has_passage:
            status = ValidationStatus.NEEDS_REVIEW
        elif has_review:
            status = ValidationStatus.NEEDS_REVIEW
        else:
            status = ValidationStatus.VALID

        is_repairable = bool(
            all_issues
            and all(issue.repairability != Repairability.IRREPARABLE for issue in all_issues)
        )

        reasons = [issue.message for issue in all_issues if issue.is_blocking]
        if status == ValidationStatus.NEEDS_REVIEW and not reasons:
            reasons = [issue.message for issue in all_issues if issue.code == IssueCode.ERR_EVALUATION_INCONCLUSIVE]

        return ValidationResult(
            status=status,
            question_type=self.question_type,
            schema_version=pol.schema_version,
            structural_valid=structural_valid,
            semantic_valid=semantic_valid,
            grounding_verified=grounding_verified,
            issues=all_issues,
            scored_items=scored_items,
            is_repairable=is_repairable,
            reasons=reasons,
        )


class QuestionValidatorRegistry:
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
        from app.services.validation.validators import register_all_validators
        _REGISTRY = QuestionValidatorRegistry()
        register_all_validators(_REGISTRY)
    return _REGISTRY
