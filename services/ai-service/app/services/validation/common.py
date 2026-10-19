"""Common reusable validation rules, constants, and utilities for IELTS question validation."""
from __future__ import annotations

import re
from typing import Any, Dict, FrozenSet, List, Optional, Set, Tuple

from app.services.validation.models import (
    IssueCode,
    Repairability,
    ValidationIssue,
    ValidationSeverity,
)

ALL_19_TYPES: FrozenSet[str] = frozenset({
    # Choice types (5)
    "MULTIPLE_CHOICE_SINGLE",
    "MULTIPLE_CHOICE_MULTIPLE",
    "TRUE_FALSE_NOT_GIVEN",
    "YES_NO_NOT_GIVEN",
    "MULTIPLE_CHOICE_SINGLE_IMAGE",
    # Completion types (7)
    "SUMMARY_COMPLETION",
    "TABLE_COMPLETION",
    "NOTE_COMPLETION",
    "FORM_COMPLETION",
    "SENTENCE_COMPLETION",
    "DIAGRAM_LABEL",
    "MAP_LABEL",
    # Short Answer (1)
    "SHORT_ANSWER",
    # Matching types (5)
    "MATCHING_HEADING",
    "MATCHING_INFORMATION",
    "MATCHING_FEATURES",
    "MATCHING_ENDINGS",
    "CLASSIFICATION",
    # Ordering (1)
    "FLOW_CHART",
})

CHOICE_TYPES: FrozenSet[str] = frozenset({
    "MULTIPLE_CHOICE_SINGLE",
    "MULTIPLE_CHOICE_MULTIPLE",
    "TRUE_FALSE_NOT_GIVEN",
    "YES_NO_NOT_GIVEN",
    "MULTIPLE_CHOICE_SINGLE_IMAGE",
})

COMPLETION_TYPES: FrozenSet[str] = frozenset({
    "SUMMARY_COMPLETION",
    "TABLE_COMPLETION",
    "NOTE_COMPLETION",
    "FORM_COMPLETION",
    "SENTENCE_COMPLETION",
    "DIAGRAM_LABEL",
    "MAP_LABEL",
})

MATCHING_TYPES: FrozenSet[str] = frozenset({
    "MATCHING_HEADING",
    "MATCHING_INFORMATION",
    "MATCHING_FEATURES",
    "MATCHING_ENDINGS",
    "CLASSIFICATION",
})

SHORT_ANSWER_TYPE: str = "SHORT_ANSWER"
ORDERING_TYPE: str = "FLOW_CHART"

ALL_ANSWER_FIELDS: Tuple[str, ...] = (
    "options",
    "blankAcceptTexts",
    "blankAcceptRegex",
    "matchPairs",
    "orderCorrects",
    "shortAnswerAcceptTexts",
    "shortAnswerAcceptRegex",
)

VIETNAMESE_DIACRITICS_RE: re.Pattern[str] = re.compile(
    r"[àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđ"
    r"ÀÁẢÃẠĂẰẮẲẴẶÂẦẤẨẪẬÈÉẺẼẸÊỀẾỂỄỆÌÍỈĨỊÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢÙÚỦŨỤƯỪỨỬỮỰỲÝỶỸỴĐ]",
    re.UNICODE,
)

VIETNAMESE_WORDS_RE: re.Pattern[str] = re.compile(
    r"\b(câu\s+hỏi|đoạn\s+văn|chọn|đáp\s+án|đúng|sai|không\s+có|tiêu\s+đề|bài\s+đọc|"
    r"thông\s+tin|nối|điền|từ|vào\s+chỗ\s+trống|giải\s+thích|theo\s+bài|trong\s+bài)\b",
    re.IGNORECASE,
)

FORBIDDEN_PLACEHOLDERS: FrozenSet[str] = frozenset({
    "item 1", "item 2", "paragraph 1", "paragraph 2", "tbd", "n/a", "none",
    "null", "undefined", "option a", "option b", "placeholder", "unknown",
    "answer 1", "answer 2", "blank 1", "blank 2", "to be determined",
})

BRACKET_MARKER_RE: re.Pattern[str] = re.compile(r"\[(\d+)\]")
STEP_SLUG_RE: re.Pattern[str] = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
HEADING_OPTION_PATTERN: re.Pattern[str] = re.compile(r"^([ivxlcdm]+)\.\s+(.+)$", re.IGNORECASE)
LETTER_OPTION_PATTERN: re.Pattern[str] = re.compile(r"^([A-Z])\.\s+(.+)$")
TARGET_LINE_PATTERN: re.Pattern[str] = re.compile(r"^\s*(\d+)[.)]\s+(.+)$")


def validate_english_text(
    text: Any,
    field_name: str,
    scored_item_index: Optional[int] = None,
) -> List[ValidationIssue]:
    issues: List[ValidationIssue] = []
    if not isinstance(text, str) or not text.strip():
        return issues

    diacritic_match = VIETNAMESE_DIACRITICS_RE.search(text)
    if diacritic_match:
        issues.append(
            ValidationIssue(
                code=IssueCode.ERR_VIETNAMESE_TEXT,
                message=(
                    f"{field_name} contains Vietnamese characters ('{diacritic_match.group(0)}'). "
                    f"All candidate-facing content must be in English."
                ),
                severity=ValidationSeverity.ERROR,
                is_blocking=True,
                field_path=field_name,
                scored_item_index=scored_item_index,
                repairability=Repairability.REPAIRABLE_MANUAL,
            )
        )

    word_match = VIETNAMESE_WORDS_RE.search(text)
    if word_match:
        issues.append(
            ValidationIssue(
                code=IssueCode.ERR_VIETNAMESE_TEXT,
                message=(
                    f"{field_name} contains Vietnamese phrase ('{word_match.group(0)}'). "
                    f"All candidate-facing content must be in English."
                ),
                severity=ValidationSeverity.ERROR,
                is_blocking=True,
                field_path=field_name,
                scored_item_index=scored_item_index,
                repairability=Repairability.REPAIRABLE_MANUAL,
            )
        )

    return issues


def count_ielts_words(s: str) -> int:
    words = re.findall(r"\b[\w'-]+\b", s)
    return len(words)


def is_placeholder(val: str) -> bool:
    clean = " ".join(val.strip().lower().split())
    return clean in FORBIDDEN_PLACEHOLDERS


def check_forbidden_fields(
    question: Dict[str, Any],
    allowed_fields: Set[str],
    qtype: str,
) -> List[ValidationIssue]:
    issues: List[ValidationIssue] = []
    for field in ALL_ANSWER_FIELDS:
        if field not in allowed_fields:
            val = question.get(field)
            if val is not None and (
                (isinstance(val, (list, dict, set, tuple)) and len(val) > 0)
                or (isinstance(val, str) and val.strip())
            ):
                issues.append(
                    ValidationIssue(
                        code=IssueCode.ERR_FORBIDDEN_ANSWER_FIELD,
                        message=f"{qtype}: forbidden answer-family field '{field}' must not be present or non-empty",
                        severity=ValidationSeverity.ERROR,
                        is_blocking=True,
                        field_path=field,
                        repairability=Repairability.REPAIRABLE_AUTOMATIC,
                    )
                )
    return issues
