"""Validators for IELTS completion-family question types."""
from __future__ import annotations

import re
from typing import Any, Dict, List, Optional, Set, Tuple

from app.services.validation.common import (
    BRACKET_MARKER_RE,
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


class _BaseCompletionValidator(BaseQuestionValidator):
    @property
    def allowed_answer_fields(self) -> Set[str]:
        return {"blankAcceptTexts", "blankAcceptRegex"}

    def validate_answer_key(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> Tuple[List[ValidationIssue], List[ScoredItemValidation]]:
        issues: List[ValidationIssue] = []
        scored_items: List[ScoredItemValidation] = []

        blanks = question.get("blankAcceptTexts")
        if not isinstance(blanks, dict) or len(blanks) == 0:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_MISSING_ANSWER_KEY,
                    message=f"{self.question_type}: blankAcceptTexts must be a non-empty dictionary",
                    severity=ValidationSeverity.CRITICAL,
                    field_path="blankAcceptTexts",
                    repairability=Repairability.IRREPARABLE,
                )
            )
            return issues, scored_items

        prompt_md = str(question.get("promptMd", ""))
        prompt_markers = set(BRACKET_MARKER_RE.findall(prompt_md))
        has_diagram_map_spec = self.question_type in ("DIAGRAM_LABEL", "MAP_LABEL") and bool(
            re.search(r"\[(Diagram|Map):\s*[^\]]+\]", prompt_md, re.IGNORECASE)
        )

        for item_idx, (b_key, b_vals) in enumerate(sorted(blanks.items(), key=lambda kv: (int(kv[0]) if kv[0].isdigit() else 999, kv[0])), start=1):
            item_issues: List[ValidationIssue] = []

            if not (isinstance(b_key, str) and b_key.isdigit() and int(b_key) > 0):
                iss = ValidationIssue(
                    code=IssueCode.ERR_BLANK_KEY_INVALID,
                    message=f"blankAcceptTexts key '{b_key}' must be a positive decimal string",
                    field_path=f"blankAcceptTexts['{b_key}']",
                    scored_item_index=item_idx,
                )
                issues.append(iss)
                item_issues.append(iss)

            if not isinstance(b_vals, (list, tuple)) or len(b_vals) == 0:
                iss = ValidationIssue(
                    code=IssueCode.ERR_MISSING_ANSWER_KEY,
                    message=f"blankAcceptTexts['{b_key}'] must be a non-empty array of strings",
                    field_path=f"blankAcceptTexts['{b_key}']",
                    scored_item_index=item_idx,
                )
                issues.append(iss)
                item_issues.append(iss)
                scored_items.append(
                    ScoredItemValidation(
                        item_index=item_idx,
                        item_key=b_key,
                        is_valid=False,
                        accepted_answers=[],
                        issues=item_issues,
                    )
                )
                continue

            valid_variants: List[str] = []
            for v_idx, val in enumerate(b_vals):
                if not isinstance(val, str) or not val.strip():
                    iss = ValidationIssue(
                        code=IssueCode.ERR_EMPTY_ANSWER_VARIANT,
                        message=f"blankAcceptTexts['{b_key}'][{v_idx}] is an empty string",
                        field_path=f"blankAcceptTexts['{b_key}'][{v_idx}]",
                        scored_item_index=item_idx,
                    )
                    issues.append(iss)
                    item_issues.append(iss)
                    continue

                clean_v = val.strip()
                if policy.enforce_language:
                    lang_issues = validate_english_text(clean_v, f"blankAcceptTexts['{b_key}']", scored_item_index=item_idx)
                    issues.extend(lang_issues)
                    item_issues.extend(lang_issues)

                if is_placeholder(clean_v):
                    iss = ValidationIssue(
                        code=IssueCode.ERR_PLACEHOLDER_ANSWER,
                        message=f"blankAcceptTexts['{b_key}'] answer '{val}' cannot be a placeholder",
                        field_path=f"blankAcceptTexts['{b_key}']",
                        scored_item_index=item_idx,
                    )
                    issues.append(iss)
                    item_issues.append(iss)

                if policy.enforce_word_limits:
                    w_count = count_ielts_words(clean_v)
                    if w_count > policy.max_word_limit:
                        iss = ValidationIssue(
                            code=IssueCode.ERR_WORD_LIMIT_EXCEEDED,
                            message=(
                                f"blankAcceptTexts['{b_key}'] answer '{val}' exceeds "
                                f"{policy.max_word_limit} words ({w_count} words)"
                            ),
                            field_path=f"blankAcceptTexts['{b_key}']",
                            scored_item_index=item_idx,
                        )
                        issues.append(iss)
                        item_issues.append(iss)

                valid_variants.append(clean_v)

            if not has_diagram_map_spec and b_key not in prompt_markers:
                iss = ValidationIssue(
                    code=IssueCode.ERR_PROMPT_MARKER_MISSING,
                    message=f"promptMd is missing canonical marker [{b_key}] for blank key '{b_key}'",
                    field_path="promptMd",
                    scored_item_index=item_idx,
                    repairability=Repairability.REPAIRABLE_AUTOMATIC,
                )
                issues.append(iss)
                item_issues.append(iss)

            scored_items.append(
                ScoredItemValidation(
                    item_index=item_idx,
                    item_key=b_key,
                    is_valid=len(item_issues) == 0,
                    accepted_answers=valid_variants,
                    issues=item_issues,
                )
            )

        return issues, scored_items

    def validate_grounding(
        self,
        question: Dict[str, Any],
        passage: Optional[str],
        scored_items: List[ScoredItemValidation],
        policy: ValidationPolicy,
    ) -> List[ValidationIssue]:
        issues: List[ValidationIssue] = []
        if not passage:
            return issues

        p_norm = " ".join(passage.lower().split())
        for item in scored_items:
            if not item.accepted_answers:
                continue
            found = False
            for ans in item.accepted_answers:
                ans_norm = " ".join(ans.lower().split())
                if ans_norm in p_norm:
                    found = True
                    break

            if not found:
                issues.append(
                    ValidationIssue(
                        code=IssueCode.ERR_UNGROUNDED_ANSWER,
                        message=(
                            f"None of the accepted answers {item.accepted_answers} for blank "
                            f"[{item.item_key}] occur verbatim in the source passage"
                        ),
                        severity=ValidationSeverity.ERROR,
                        is_blocking=True,
                        field_path=f"blankAcceptTexts['{item.item_key}']",
                        scored_item_index=item.item_index,
                        repairability=Repairability.REPAIRABLE_MANUAL,
                    )
                )
        return issues


class SummaryCompletionValidator(_BaseCompletionValidator):
    @property
    def question_type(self) -> str:
        return "SUMMARY_COMPLETION"

    def validate_type_specific(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
        return []


class TableCompletionValidator(_BaseCompletionValidator):
    @property
    def question_type(self) -> str:
        return "TABLE_COMPLETION"

    def validate_type_specific(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
        issues: List[ValidationIssue] = []
        prompt_md = str(question.get("promptMd", ""))
        if "|" not in prompt_md:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_MALFORMED_STRUCTURE,
                    message="TABLE_COMPLETION promptMd must contain a markdown table structure ('|')",
                    field_path="promptMd",
                    severity=ValidationSeverity.WARNING,
                    is_blocking=False,
                )
            )
        return issues


class NoteCompletionValidator(_BaseCompletionValidator):
    @property
    def question_type(self) -> str:
        return "NOTE_COMPLETION"

    def validate_type_specific(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
        return []


class FormCompletionValidator(_BaseCompletionValidator):
    @property
    def question_type(self) -> str:
        return "FORM_COMPLETION"

    def validate_type_specific(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
        return []


class SentenceCompletionValidator(_BaseCompletionValidator):
    @property
    def question_type(self) -> str:
        return "SENTENCE_COMPLETION"

    def validate_type_specific(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
        return []


class DiagramLabelValidator(_BaseCompletionValidator):
    @property
    def question_type(self) -> str:
        return "DIAGRAM_LABEL"

    def validate_type_specific(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
        issues: List[ValidationIssue] = []
        img_url = question.get("imageUrl")
        if not isinstance(img_url, str) or not img_url.strip():
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_IMAGE_URL_MISSING,
                    message="DIAGRAM_LABEL requires a non-empty imageUrl at question level",
                    field_path="imageUrl",
                    severity=ValidationSeverity.CRITICAL,
                    is_blocking=True,
                )
            )
        return issues


class MapLabelValidator(_BaseCompletionValidator):
    @property
    def question_type(self) -> str:
        return "MAP_LABEL"

    def validate_type_specific(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
        issues: List[ValidationIssue] = []
        img_url = question.get("imageUrl")
        if not isinstance(img_url, str) or not img_url.strip():
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_IMAGE_URL_MISSING,
                    message="MAP_LABEL requires a non-empty imageUrl at question level",
                    field_path="imageUrl",
                    severity=ValidationSeverity.CRITICAL,
                    is_blocking=True,
                )
            )
        return issues
