"""Validators for IELTS choice-family question types."""
from __future__ import annotations

import re
from typing import Any, Dict, List, Optional, Set, Tuple

from app.services.validation.common import is_placeholder, validate_english_text
from app.services.validation.models import (
    IssueCode,
    Repairability,
    ScoredItemValidation,
    ValidationIssue,
    ValidationPolicy,
    ValidationSeverity,
)
from app.services.validation.registry import BaseQuestionValidator


class _BaseChoiceValidator(BaseQuestionValidator):
    @property
    def allowed_answer_fields(self) -> Set[str]:
        return {"options"}

    def validate_answer_key(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> Tuple[List[ValidationIssue], List[ScoredItemValidation]]:
        issues: List[ValidationIssue] = []
        scored_items: List[ScoredItemValidation] = []

        options = question.get("options")
        if not isinstance(options, list) or len(options) == 0:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_OPTIONS_MISSING,
                    message=f"{self.question_type}: options array must be present and non-empty",
                    severity=ValidationSeverity.CRITICAL,
                    field_path="options",
                    repairability=Repairability.IRREPARABLE,
                )
            )
            return issues, scored_items

        seen_indices: Set[int] = set()
        seen_contents: Set[str] = set()
        correct_indices: List[int] = []
        correct_contents: List[str] = []
        n_opts = len(options)

        for i, opt in enumerate(options):
            if not isinstance(opt, dict):
                issues.append(
                    ValidationIssue(
                        code=IssueCode.ERR_MALFORMED_STRUCTURE,
                        message=f"options[{i}] must be a JSON object",
                        field_path=f"options[{i}]",
                    )
                )
                continue

            idx = opt.get("idx")
            if type(idx) is not int or isinstance(idx, bool):
                issues.append(
                    ValidationIssue(
                        code=IssueCode.ERR_OPTIONS_INDICES_NON_SEQUENTIAL,
                        message=f"options[{i}].idx must be an integer",
                        field_path=f"options[{i}].idx",
                        repairability=Repairability.REPAIRABLE_AUTOMATIC,
                    )
                )
            else:
                seen_indices.add(idx)

            content = opt.get("contentMd")
            if not isinstance(content, str) or not content.strip():
                issues.append(
                    ValidationIssue(
                        code=IssueCode.ERR_OPTION_EMPTY_CONTENT,
                        message=f"options[{i}].contentMd must be a non-empty string",
                        field_path=f"options[{i}].contentMd",
                    )
                )
            else:
                if policy.enforce_language:
                    issues.extend(validate_english_text(content, f"options[{i}].contentMd", scored_item_index=i))
                norm_c = " ".join(content.strip().lower().split())
                if is_placeholder(norm_c):
                    issues.append(
                        ValidationIssue(
                            code=IssueCode.ERR_PLACEHOLDER_ANSWER,
                            message=f"options[{i}].contentMd cannot be a placeholder ('{content}')",
                            field_path=f"options[{i}].contentMd",
                        )
                    )
                if norm_c in seen_contents:
                    issues.append(
                        ValidationIssue(
                            code=IssueCode.ERR_OPTIONS_DUPLICATE_CONTENT,
                            message=f"options[{i}].contentMd is a duplicate of another option",
                            field_path=f"options[{i}].contentMd",
                        )
                    )
                seen_contents.add(norm_c)

            is_corr = opt.get("isCorrect")
            if type(is_corr) is not bool:
                issues.append(
                    ValidationIssue(
                        code=IssueCode.ERR_MALFORMED_STRUCTURE,
                        message=f"options[{i}].isCorrect must be a boolean",
                        field_path=f"options[{i}].isCorrect",
                        repairability=Repairability.REPAIRABLE_AUTOMATIC,
                    )
                )
            elif is_corr:
                correct_indices.append(idx if isinstance(idx, int) else i + 1)
                if isinstance(content, str):
                    correct_contents.append(content.strip())

        expected_indices = set(range(1, n_opts + 1))
        if seen_indices != expected_indices:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_OPTIONS_INDICES_NON_SEQUENTIAL,
                    message=f"options idx must be sequential 1-based integers (1..{n_opts})",
                    field_path="options",
                    repairability=Repairability.REPAIRABLE_AUTOMATIC,
                )
            )

        scored_item = ScoredItemValidation(
            item_index=1,
            item_key="1",
            is_valid=len(correct_indices) > 0,
            accepted_answers=correct_contents,
        )
        scored_items.append(scored_item)

        return issues, scored_items


class MultipleChoiceSingleValidator(_BaseChoiceValidator):
    @property
    def question_type(self) -> str:
        return "MULTIPLE_CHOICE_SINGLE"

    def validate_type_specific(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
        issues: List[ValidationIssue] = []
        options = question.get("options")
        if not isinstance(options, list):
            return issues

        if len(options) < 2:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_OPTIONS_CARDINALITY,
                    message="MULTIPLE_CHOICE_SINGLE requires at least 2 options",
                    field_path="options",
                )
            )

        correct_count = sum(1 for o in options if isinstance(o, dict) and o.get("isCorrect") is True)
        if correct_count != 1:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_CORRECT_COUNT_MISMATCH,
                    message=f"MULTIPLE_CHOICE_SINGLE requires exactly 1 correct option, got {correct_count}",
                    field_path="options",
                )
            )
        return issues


class MultipleChoiceMultipleValidator(_BaseChoiceValidator):
    @property
    def question_type(self) -> str:
        return "MULTIPLE_CHOICE_MULTIPLE"

    def validate_type_specific(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
        issues: List[ValidationIssue] = []
        options = question.get("options")
        if not isinstance(options, list):
            return issues

        if len(options) < 3:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_OPTIONS_CARDINALITY,
                    message="MULTIPLE_CHOICE_MULTIPLE requires at least 3 options",
                    field_path="options",
                )
            )

        correct_count = sum(1 for o in options if isinstance(o, dict) and o.get("isCorrect") is True)
        if correct_count < 2:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_CORRECT_COUNT_MISMATCH,
                    message=f"MULTIPLE_CHOICE_MULTIPLE requires at least 2 correct options, got {correct_count}",
                    field_path="options",
                )
            )
        return issues


class MultipleChoiceSingleImageValidator(_BaseChoiceValidator):
    @property
    def question_type(self) -> str:
        return "MULTIPLE_CHOICE_SINGLE_IMAGE"

    def validate_type_specific(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
        issues: List[ValidationIssue] = []
        options = question.get("options")
        if not isinstance(options, list):
            return issues

        if len(options) < 2:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_OPTIONS_CARDINALITY,
                    message="MULTIPLE_CHOICE_SINGLE_IMAGE requires at least 2 options",
                    field_path="options",
                )
            )

        correct_count = sum(1 for o in options if isinstance(o, dict) and o.get("isCorrect") is True)
        if correct_count != 1:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_CORRECT_COUNT_MISMATCH,
                    message=f"MULTIPLE_CHOICE_SINGLE_IMAGE requires exactly 1 correct option, got {correct_count}",
                    field_path="options",
                )
            )

        has_q_image = bool(question.get("imageUrl") and str(question.get("imageUrl")).strip())
        has_opt_images = all(
            bool(opt.get("imageUrl") and str(opt.get("imageUrl")).strip())
            for opt in options
            if isinstance(opt, dict)
        )
        if not has_q_image and not has_opt_images:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_IMAGE_URL_MISSING,
                    message="MULTIPLE_CHOICE_SINGLE_IMAGE requires an imageUrl on question or on all options",
                    field_path="imageUrl",
                )
            )
        return issues


class TrueFalseNotGivenValidator(_BaseChoiceValidator):
    @property
    def question_type(self) -> str:
        return "TRUE_FALSE_NOT_GIVEN"

    def validate_type_specific(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
        issues: List[ValidationIssue] = []
        options = question.get("options")
        if not isinstance(options, list):
            return issues

        if len(options) != 3:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_OPTIONS_CARDINALITY,
                    message=f"TRUE_FALSE_NOT_GIVEN requires exactly 3 options, got {len(options)}",
                    field_path="options",
                )
            )

        correct_count = sum(1 for o in options if isinstance(o, dict) and o.get("isCorrect") is True)
        if correct_count != 1:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_CORRECT_COUNT_MISMATCH,
                    message=f"TRUE_FALSE_NOT_GIVEN requires exactly 1 correct option, got {correct_count}",
                    field_path="options",
                )
            )

        clean_labels = [
            re.sub(r"^[A-Za-z0-9]+[.)\-]\s*", "", opt.get("contentMd", "")).strip().lower()
            for opt in options
            if isinstance(opt, dict) and isinstance(opt.get("contentMd"), str)
        ]
        has_true = any("true" in l for l in clean_labels)
        has_false = any("false" in l for l in clean_labels)
        has_not_given = any("not given" in l for l in clean_labels)

        if not (has_true and has_false and has_not_given):
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_TFNG_LABEL_MISMATCH,
                    message="TRUE_FALSE_NOT_GIVEN options must include True, False, and Not Given",
                    field_path="options",
                )
            )
        return issues


class YesNoNotGivenValidator(_BaseChoiceValidator):
    @property
    def question_type(self) -> str:
        return "YES_NO_NOT_GIVEN"

    def validate_type_specific(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
        issues: List[ValidationIssue] = []
        options = question.get("options")
        if not isinstance(options, list):
            return issues

        if len(options) != 3:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_OPTIONS_CARDINALITY,
                    message=f"YES_NO_NOT_GIVEN requires exactly 3 options, got {len(options)}",
                    field_path="options",
                )
            )

        correct_count = sum(1 for o in options if isinstance(o, dict) and o.get("isCorrect") is True)
        if correct_count != 1:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_CORRECT_COUNT_MISMATCH,
                    message=f"YES_NO_NOT_GIVEN requires exactly 1 correct option, got {correct_count}",
                    field_path="options",
                )
            )

        clean_labels = [
            re.sub(r"^[A-Za-z0-9]+[.)\-]\s*", "", opt.get("contentMd", "")).strip().lower()
            for opt in options
            if isinstance(opt, dict) and isinstance(opt.get("contentMd"), str)
        ]
        has_yes = any("yes" in l for l in clean_labels)
        has_no = any("no" in l for l in clean_labels)
        has_not_given = any("not given" in l for l in clean_labels)

        if not (has_yes and has_no and has_not_given):
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_YNNG_LABEL_MISMATCH,
                    message="YES_NO_NOT_GIVEN options must include Yes, No, and Not Given",
                    field_path="options",
                )
            )
        return issues
