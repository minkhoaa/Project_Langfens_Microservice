"""Validator for IELTS Short Answer question type."""
from __future__ import annotations

import re
from typing import Any, Dict, List, Optional, Set, Tuple

from app.services.validation.common import (
    count_ielts_words,
    is_placeholder,
    validate_english_text,
)
from app.services.validation.models import (
    IssueCode,
    Repairability,
    ScoredItemValidation,
    ValidationIssue,
    ValidationPolicy,
    ValidationSeverity,
)
from app.services.validation.registry import BaseQuestionValidator


class ShortAnswerValidator(BaseQuestionValidator):
    @property
    def question_type(self) -> str:
        return "SHORT_ANSWER"

    @property
    def allowed_answer_fields(self) -> Set[str]:
        return {"shortAnswerAcceptTexts", "shortAnswerAcceptRegex"}

    def validate_answer_key(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> Tuple[List[ValidationIssue], List[ScoredItemValidation]]:
        issues: List[ValidationIssue] = []
        scored_items: List[ScoredItemValidation] = []

        texts = question.get("shortAnswerAcceptTexts")
        if not isinstance(texts, list) or len(texts) == 0:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_MISSING_ANSWER_KEY,
                    message="SHORT_ANSWER: shortAnswerAcceptTexts must be a non-empty array of strings",
                    severity=ValidationSeverity.CRITICAL,
                    field_path="shortAnswerAcceptTexts",
                    repairability=Repairability.IRREPARABLE,
                )
            )
            return issues, scored_items

        valid_answers: List[str] = []
        for i, val in enumerate(texts):
            if not isinstance(val, str) or not val.strip():
                issues.append(
                    ValidationIssue(
                        code=IssueCode.ERR_EMPTY_ANSWER_VARIANT,
                        message=f"shortAnswerAcceptTexts[{i}] must be a non-empty string",
                        field_path=f"shortAnswerAcceptTexts[{i}]",
                    )
                )
                continue

            clean_v = val.strip()
            if policy.enforce_language:
                issues.extend(validate_english_text(clean_v, f"shortAnswerAcceptTexts[{i}]"))

            if is_placeholder(clean_v):
                issues.append(
                    ValidationIssue(
                        code=IssueCode.ERR_PLACEHOLDER_ANSWER,
                        message=f"shortAnswerAcceptTexts[{i}] answer '{val}' cannot be a placeholder",
                        field_path=f"shortAnswerAcceptTexts[{i}]",
                    )
                )

            if policy.enforce_word_limits:
                w_count = count_ielts_words(clean_v)
                if w_count > policy.max_word_limit:
                    issues.append(
                        ValidationIssue(
                            code=IssueCode.ERR_WORD_LIMIT_EXCEEDED,
                            message=f"shortAnswerAcceptTexts[{i}] answer '{val}' exceeds {policy.max_word_limit} words ({w_count} words)",
                            field_path=f"shortAnswerAcceptTexts[{i}]",
                        )
                    )

            prompt_md = str(question.get("promptMd", "")).lower()
            if " and " in clean_v.lower() and re.match(r"^(what|which|where|when|who)\b", prompt_md):
                issues.append(
                    ValidationIssue(
                        code=IssueCode.ERR_CONJOINED_SHORT_ANSWER,
                        message=f"shortAnswerAcceptTexts[{i}] conjoined answer '{val}' for singular question prompt",
                        field_path=f"shortAnswerAcceptTexts[{i}]",
                        severity=ValidationSeverity.WARNING,
                        is_blocking=False,
                    )
                )

            valid_answers.append(clean_v)

        scored_items.append(
            ScoredItemValidation(
                item_index=1,
                item_key="1",
                is_valid=len(issues) == 0,
                accepted_answers=valid_answers,
            )
        )
        return issues, scored_items

    def validate_type_specific(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
        return []
