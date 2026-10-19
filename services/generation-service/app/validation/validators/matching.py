"""Validators for IELTS matching-family question types.

Covers:
- MATCHING_HEADING
- MATCHING_INFORMATION
- MATCHING_FEATURES
- MATCHING_ENDINGS
- CLASSIFICATION
"""
from __future__ import annotations

import re
from typing import Any, Dict, List, Optional, Set, Tuple

from app.validation.common import (
    HEADING_OPTION_PATTERN,
    LETTER_OPTION_PATTERN,
    TARGET_LINE_PATTERN,
    is_placeholder,
    validate_english_text,
)
from app.validation.models import (
    IssueCode,
    Repairability,
    ScoredItemValidation,
    ValidationIssue,
    ValidationPolicy,
    ValidationSeverity,
)
from app.validation.registry import BaseQuestionValidator


class _BaseMatchingValidator(BaseQuestionValidator):
    """Base validator for matching and classification question types."""

    @property
    def allowed_answer_fields(self) -> Set[str]:
        return {"options", "matchPairs"}

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
                    message=f"{self.question_type}: options choice pool must be present and non-empty",
                    severity=ValidationSeverity.CRITICAL,
                    field_path="options",
                    repairability=Repairability.IRREPARABLE,
                )
            )
            return issues, scored_items

        match_pairs = question.get("matchPairs")
        if not isinstance(match_pairs, dict) or len(match_pairs) == 0:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_MISSING_ANSWER_KEY,
                    message=f"{self.question_type}: matchPairs must be a non-empty dictionary",
                    severity=ValidationSeverity.CRITICAL,
                    field_path="matchPairs",
                    repairability=Repairability.IRREPARABLE,
                )
            )
            return issues, scored_items

        # 1. Validate options choice pool
        option_keys: List[str] = []
        option_texts: Dict[str, str] = {}
        seen_indices: Set[int] = set()
        n_opts = len(options)

        is_heading = self.question_type == "MATCHING_HEADING"

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

            is_corr = opt.get("isCorrect")
            if is_corr is not False:
                issues.append(
                    ValidationIssue(
                        code=IssueCode.ERR_MALFORMED_STRUCTURE,
                        message=f"options[{i}].isCorrect must be false in matching choice pools",
                        field_path=f"options[{i}].isCorrect",
                        repairability=Repairability.REPAIRABLE_AUTOMATIC,
                    )
                )

            content = opt.get("contentMd")
            if not isinstance(content, str) or not content.strip():
                issues.append(
                    ValidationIssue(
                        code=IssueCode.ERR_OPTION_EMPTY_CONTENT,
                        message=f"options[{i}].contentMd must be a non-empty string",
                        field_path=f"options[{i}].contentMd",
                    )
                )
                continue

            if policy.enforce_language:
                issues.extend(validate_english_text(content, f"options[{i}].contentMd"))

            raw_c = content.strip()
            if is_heading:
                m = HEADING_OPTION_PATTERN.match(raw_c)
                if not m:
                    issues.append(
                        ValidationIssue(
                            code=IssueCode.ERR_MALFORMED_STRUCTURE,
                            message=f"options[{i}].contentMd '{content}' must start with Roman numeral prefix (e.g. 'i. Heading')",
                            field_path=f"options[{i}].contentMd",
                        )
                    )
                    continue
                k = m.group(1).lower()
                text = m.group(2).strip()
            else:
                m = LETTER_OPTION_PATTERN.match(raw_c)
                if not m:
                    issues.append(
                        ValidationIssue(
                            code=IssueCode.ERR_MALFORMED_STRUCTURE,
                            message=f"options[{i}].contentMd '{content}' must start with letter prefix (e.g. 'A. Feature')",
                            field_path=f"options[{i}].contentMd",
                        )
                    )
                    continue
                k = m.group(1).upper()
                text = m.group(2).strip()

            if is_placeholder(text):
                issues.append(
                    ValidationIssue(
                        code=IssueCode.ERR_PLACEHOLDER_ANSWER,
                        message=f"options[{i}].contentMd text cannot be a placeholder ('{text}')",
                        field_path=f"options[{i}].contentMd",
                    )
                )

            if k in option_keys:
                issues.append(
                    ValidationIssue(
                        code=IssueCode.ERR_OPTIONS_DUPLICATE_CONTENT,
                        message=f"Duplicate option key '{k}' in options pool",
                        field_path=f"options[{i}].contentMd",
                    )
                )
            option_keys.append(k)
            option_texts[k] = text

        if seen_indices != set(range(1, n_opts + 1)):
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_OPTIONS_INDICES_NON_SEQUENTIAL,
                    message=f"options idx must be sequential 1-based integers (1..{n_opts})",
                    field_path="options",
                    repairability=Repairability.REPAIRABLE_AUTOMATIC,
                )
            )

        # 2. Validate matchPairs
        valid_option_keys = set(option_keys)
        seen_grading_keys: List[str] = []

        prompt_md = str(question.get("promptMd", ""))
        target_lines: Dict[str, str] = {}
        for line in prompt_md.split("\n"):
            line = line.strip()
            m = TARGET_LINE_PATTERN.match(line)
            if m:
                target_lines[m.group(1)] = m.group(2).strip()

        for item_idx, (p_key, pair_val) in enumerate(
            sorted(match_pairs.items(), key=lambda kv: (int(kv[0]) if kv[0].isdigit() else 999, kv[0])),
            start=1,
        ):
            item_issues: List[ValidationIssue] = []

            if not (isinstance(p_key, str) and p_key.isdigit() and int(p_key) > 0):
                iss = ValidationIssue(
                    code=IssueCode.ERR_BLANK_KEY_INVALID,
                    message=f"matchPairs key '{p_key}' must be a positive decimal string",
                    field_path=f"matchPairs['{p_key}']",
                    scored_item_index=item_idx,
                )
                issues.append(iss)
                item_issues.append(iss)

            if not isinstance(pair_val, (list, tuple)) or len(pair_val) < 1:
                iss = ValidationIssue(
                    code=IssueCode.ERR_MISSING_ANSWER_KEY,
                    message=f"matchPairs['{p_key}'] must be a non-empty array",
                    field_path=f"matchPairs['{p_key}']",
                    scored_item_index=item_idx,
                )
                issues.append(iss)
                item_issues.append(iss)
                scored_items.append(
                    ScoredItemValidation(
                        item_index=item_idx,
                        item_key=p_key,
                        is_valid=False,
                        accepted_answers=[],
                        issues=item_issues,
                    )
                )
                continue

            raw_k = str(pair_val[0]).strip()
            lookup_k = raw_k.lower() if is_heading else raw_k.upper()

            if is_placeholder(raw_k):
                iss = ValidationIssue(
                    code=IssueCode.ERR_PLACEHOLDER_ANSWER,
                    message=f"matchPairs['{p_key}'][0] grading key '{raw_k}' cannot be a placeholder",
                    field_path=f"matchPairs['{p_key}'][0]",
                    scored_item_index=item_idx,
                )
                issues.append(iss)
                item_issues.append(iss)

            if lookup_k not in valid_option_keys:
                iss = ValidationIssue(
                    code=IssueCode.ERR_OPTION_REF_INVALID,
                    message=f"matchPairs['{p_key}'][0] grading key '{raw_k}' does not exist in options choice pool",
                    field_path=f"matchPairs['{p_key}'][0]",
                    scored_item_index=item_idx,
                )
                issues.append(iss)
                item_issues.append(iss)

            seen_grading_keys.append(lookup_k)

            # Check display label
            display_label: Optional[str] = None
            if len(pair_val) >= 2 and isinstance(pair_val[1], str) and pair_val[1].strip():
                display_label = pair_val[1].strip()
                if policy.enforce_language:
                    lang_issues = validate_english_text(display_label, f"matchPairs['{p_key}'][1]", scored_item_index=item_idx)
                    issues.extend(lang_issues)
                    item_issues.extend(lang_issues)
                if is_placeholder(display_label):
                    iss = ValidationIssue(
                        code=IssueCode.ERR_PLACEHOLDER_ANSWER,
                        message=f"matchPairs['{p_key}'][1] display label cannot be a placeholder ('{display_label}')",
                        field_path=f"matchPairs['{p_key}'][1]",
                        scored_item_index=item_idx,
                    )
                    issues.append(iss)
                    item_issues.append(iss)

            scored_items.append(
                ScoredItemValidation(
                    item_index=item_idx,
                    item_key=p_key,
                    is_valid=len(item_issues) == 0,
                    accepted_answers=[lookup_k],
                    evidence_span=display_label,
                    issues=item_issues,
                )
            )

        # Distractor check
        if len(options) <= len(match_pairs):
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_DISTRACTOR_MISSING,
                    message=f"{self.question_type} options pool must include at least one unused distractor (options={len(options)}, matchPairs={len(match_pairs)})",
                    field_path="options",
                )
            )

        return issues, scored_items


class MatchingHeadingValidator(_BaseMatchingValidator):
    @property
    def question_type(self) -> str:
        return "MATCHING_HEADING"

    def validate_type_specific(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
        issues: List[ValidationIssue] = []
        match_pairs = question.get("matchPairs")
        if not isinstance(match_pairs, dict):
            return issues

        if len(match_pairs) < 2:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_MALFORMED_STRUCTURE,
                    message="MATCHING_HEADING requires at least 2 paragraph targets in matchPairs",
                    field_path="matchPairs",
                )
            )

        # Heading uniqueness invariant: each heading matches at most one paragraph
        used_keys = [
            str(v[0]).strip().lower()
            for v in match_pairs.values()
            if isinstance(v, (list, tuple)) and len(v) > 0 and str(v[0]).strip()
        ]
        if len(used_keys) != len(set(used_keys)):
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_DUPLICATE_MATCHING_KEY,
                    message="MATCHING_HEADING: each heading option matches at most one paragraph; duplicate grading keys found",
                    field_path="matchPairs",
                )
            )
        return issues


class MatchingEndingsValidator(_BaseMatchingValidator):
    @property
    def question_type(self) -> str:
        return "MATCHING_ENDINGS"

    def validate_type_specific(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
        issues: List[ValidationIssue] = []
        match_pairs = question.get("matchPairs")
        if not isinstance(match_pairs, dict):
            return issues

        if len(match_pairs) < 2:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_MALFORMED_STRUCTURE,
                    message="MATCHING_ENDINGS requires at least 2 sentence beginnings in matchPairs",
                    field_path="matchPairs",
                )
            )

        # Endings uniqueness invariant: each ending matches at most one sentence beginning
        used_keys = [
            str(v[0]).strip().upper()
            for v in match_pairs.values()
            if isinstance(v, (list, tuple)) and len(v) > 0 and str(v[0]).strip()
        ]
        if len(used_keys) != len(set(used_keys)):
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_DUPLICATE_MATCHING_KEY,
                    message="MATCHING_ENDINGS: each ending option matches at most one sentence beginning; duplicate grading keys found",
                    field_path="matchPairs",
                )
            )
        return issues


class MatchingInformationValidator(_BaseMatchingValidator):
    @property
    def question_type(self) -> str:
        return "MATCHING_INFORMATION"

    def validate_type_specific(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
        issues: List[ValidationIssue] = []
        match_pairs = question.get("matchPairs")
        if not isinstance(match_pairs, dict):
            return issues

        if len(match_pairs) < 2:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_MALFORMED_STRUCTURE,
                    message="MATCHING_INFORMATION requires at least 2 information items in matchPairs",
                    field_path="matchPairs",
                )
            )
        return issues


class MatchingFeaturesValidator(_BaseMatchingValidator):
    @property
    def question_type(self) -> str:
        return "MATCHING_FEATURES"

    def validate_type_specific(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
        issues: List[ValidationIssue] = []
        match_pairs = question.get("matchPairs")
        if not isinstance(match_pairs, dict):
            return issues

        if len(match_pairs) < 2:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_MALFORMED_STRUCTURE,
                    message="MATCHING_FEATURES requires at least 2 feature items in matchPairs",
                    field_path="matchPairs",
                )
            )
        return issues


class ClassificationValidator(_BaseMatchingValidator):
    @property
    def question_type(self) -> str:
        return "CLASSIFICATION"

    def validate_type_specific(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
        issues: List[ValidationIssue] = []
        match_pairs = question.get("matchPairs")
        if not isinstance(match_pairs, dict):
            return issues

        if len(match_pairs) < 2:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_MALFORMED_STRUCTURE,
                    message="CLASSIFICATION requires at least 2 classification items in matchPairs",
                    field_path="matchPairs",
                )
            )
        return issues
