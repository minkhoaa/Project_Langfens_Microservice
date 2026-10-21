"""Context validation engine and candidate slot validation for 19 IELTS Question Families."""

from __future__ import annotations

import re
from typing import Any, Dict, List, Optional, Set, Tuple, Union

from app.contracts.policies import count_words
from app.contracts.question_type import QuestionPromptFamily
from app.validation.common import is_placeholder, validate_english_text


class ContextValidationIssue:
    """Represents a specific defect or validation failure for a question candidate slot."""

    def __init__(self, code: str, message: str, field_path: str = "") -> None:
        self.code = code
        self.message = message
        self.field_path = field_path

    def __str__(self) -> str:
        return f"[{self.code}] {self.message}" + (f" (at {self.field_path})" if self.field_path else "")

    def __repr__(self) -> str:
        return f"ContextValidationIssue(code='{self.code}', message='{self.message}', field_path='{self.field_path}')"


def _extract_field(candidate: Any, *field_names: str, default: Any = None) -> Any:
    """Helper to extract field value from candidate dict or Pydantic model by multiple name variations."""
    for name in field_names:
        if isinstance(candidate, dict):
            if name in candidate:
                return candidate[name]
        elif hasattr(candidate, name):
            val = getattr(candidate, name)
            if val is not None:
                return val
    return default


def validate_candidate_slot(
    candidate: Any,
    family: Union[QuestionPromptFamily, str],
) -> List[ContextValidationIssue]:
    """Validates a question candidate slot against type-specific invariants for all 19 IELTS families.

    Validates:
    - prompt and answer existence and English text
    - options count, distinctness, sequential keys
    - blank markers ('______' or '[blank]') for completion questions
    - answer word counts (<= 3 words for completion and short answer)
    - absence assessments for NOT GIVEN answers in TFNG and YNNG
    - process steps for FLOW_CHART
    - callout label / part description for DIAGRAM_LABEL
    """
    resolved_family = QuestionPromptFamily.from_raw(family)
    issues: List[ContextValidationIssue] = []

    prompt = str(_extract_field(candidate, "prompt", "text", "stem", default="") or "").strip()
    answer = str(_extract_field(candidate, "answer", "correct_answer", default="") or "").strip()
    options_raw = _extract_field(candidate, "options", "headings", "features", "endings", "categories", default=None)
    absence_raw = _extract_field(candidate, "absence_assessment", "absenceAssessment", default=None)

    # 1. Basic field presence
    if not prompt:
        issues.append(ContextValidationIssue("ERR_PROMPT_EMPTY", "Question prompt cannot be empty", "prompt"))
    if not answer:
        issues.append(ContextValidationIssue("ERR_ANSWER_EMPTY", "Question answer cannot be empty", "answer"))
        return issues

    # 2. Placeholder check
    if is_placeholder(answer):
        issues.append(
            ContextValidationIssue("ERR_PLACEHOLDER_ANSWER", f"Answer '{answer}' cannot be a placeholder", "answer")
        )

    # 3. English language checks
    for li in validate_english_text(prompt, "prompt"):
        issues.append(ContextValidationIssue("ERR_VIETNAMESE_TEXT", li.message, "prompt"))
    for li in validate_english_text(answer, "answer"):
        issues.append(ContextValidationIssue("ERR_VIETNAMESE_TEXT", li.message, "answer"))

    norm_ans = answer.upper().replace("_", " ").strip()

    # 4. Family-specific validation
    if resolved_family == QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN:
        if norm_ans not in ("TRUE", "FALSE", "NOT GIVEN"):
            issues.append(
                ContextValidationIssue(
                    "ERR_INVALID_TFNG_ANSWER",
                    f"Invalid TFNG answer '{answer}'; must be TRUE, FALSE, or NOT GIVEN",
                    "answer",
                )
            )
        elif norm_ans == "NOT GIVEN":
            if not absence_raw or not isinstance(absence_raw, (dict, object)) or (isinstance(absence_raw, dict) and not absence_raw.get("is_absent", False)):
                issues.append(
                    ContextValidationIssue(
                        "ERR_NOT_GIVEN_ABSENCE_MISSING",
                        "NOT GIVEN candidate must provide a valid absence assessment confirming omission from passage",
                        "absence_assessment",
                    )
                )

    elif resolved_family == QuestionPromptFamily.YES_NO_NOT_GIVEN:
        if norm_ans not in ("YES", "NO", "NOT GIVEN"):
            issues.append(
                ContextValidationIssue(
                    "ERR_INVALID_YNNG_ANSWER",
                    f"Invalid YNNG answer '{answer}'; must be YES, NO, or NOT GIVEN",
                    "answer",
                )
            )
        elif norm_ans == "NOT GIVEN":
            if not absence_raw or not isinstance(absence_raw, (dict, object)) or (isinstance(absence_raw, dict) and not absence_raw.get("is_absent", False)):
                issues.append(
                    ContextValidationIssue(
                        "ERR_NOT_GIVEN_ABSENCE_MISSING",
                        "NOT GIVEN candidate must provide a valid absence assessment confirming omission from passage",
                        "absence_assessment",
                    )
                )

    # Completion types requiring <= 3 words and blank marker
    elif resolved_family in (
        QuestionPromptFamily.SENTENCE_COMPLETION,
        QuestionPromptFamily.SUMMARY_COMPLETION,
        QuestionPromptFamily.TABLE_COMPLETION,
        QuestionPromptFamily.NOTE_COMPLETION,
        QuestionPromptFamily.FORM_COMPLETION,
    ):
        w_count = count_words(answer)
        if w_count > 3:
            issues.append(
                ContextValidationIssue(
                    "ERR_WORD_LIMIT_EXCEEDED",
                    f"Answer exceeds maximum of 3 words: '{answer}' ({w_count} words)",
                    "answer",
                )
            )
        if resolved_family == QuestionPromptFamily.SENTENCE_COMPLETION:
            if "______" not in prompt and "[blank]" not in prompt.lower() and "[1]" not in prompt:
                issues.append(
                    ContextValidationIssue(
                        "ERR_BLANK_MARKER_MISSING",
                        "Sentence completion prompt missing blank marker '______'",
                        "prompt",
                    )
                )

    elif resolved_family == QuestionPromptFamily.SHORT_ANSWER:
        w_count = count_words(answer)
        if w_count > 3:
            issues.append(
                ContextValidationIssue(
                    "ERR_WORD_LIMIT_EXCEEDED",
                    f"Answer exceeds maximum of 3 words: '{answer}' ({w_count} words)",
                    "answer",
                )
            )
        if " and " in answer.lower() and re.match(r"^(what|which|where|when|who)\b", prompt.lower()):
            issues.append(
                ContextValidationIssue(
                    "ERR_CONJOINED_SHORT_ANSWER",
                    f"Conjoined answer '{answer}' for singular question prompt",
                    "answer",
                )
            )

    # Multiple Choice (Single) & Choosing Title
    elif resolved_family in (
        QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE,
        QuestionPromptFamily.CHOOSING_TITLE,
    ):
        opts = options_raw or []
        if len(opts) != 4:
            issues.append(
                ContextValidationIssue(
                    "ERR_OPTIONS_CARDINALITY",
                    f"{resolved_family.value} requires exactly 4 options (A-D), found {len(opts)}",
                    "options",
                )
            )
        else:
            opt_keys = []
            seen_texts: Set[str] = set()
            for o in opts:
                k = str(o.get("key") if isinstance(o, dict) else getattr(o, "key", "")).strip().upper()
                t = str(o.get("text") if isinstance(o, dict) else getattr(o, "text", "")).strip().lower()
                opt_keys.append(k)
                if t in seen_texts:
                    issues.append(
                        ContextValidationIssue("ERR_DUPLICATE_OPTION", f"Duplicate option text '{t}'", "options")
                    )
                seen_texts.add(t)

            expected_keys = ["A", "B", "C", "D"]
            if opt_keys != expected_keys:
                issues.append(
                    ContextValidationIssue(
                        "ERR_OPTION_KEYS_INVALID",
                        f"Option keys must be {expected_keys}, found {opt_keys}",
                        "options",
                    )
                )

    # Multiple Choice (Multiple answers)
    elif resolved_family == QuestionPromptFamily.MULTIPLE_CHOICE_MULTIPLE:
        opts = options_raw or []
        if len(opts) < 4:
            issues.append(
                ContextValidationIssue(
                    "ERR_OPTIONS_CARDINALITY",
                    f"Multiple Choice Multiple requires at least 4 options, found {len(opts)}",
                    "options",
                )
            )

    # Summary Completion Box
    elif resolved_family == QuestionPromptFamily.SUMMARY_COMPLETION_BOX:
        opts = options_raw or []
        if len(opts) < 3:
            issues.append(
                ContextValidationIssue(
                    "ERR_BOX_OPTIONS_INSUFFICIENT",
                    f"Summary Box requires at least 3 options in box, found {len(opts)}",
                    "options",
                )
            )

    # Matching Headings
    elif resolved_family == QuestionPromptFamily.MATCHING_HEADING:
        opts = options_raw or []
        if len(opts) < 3:
            issues.append(
                ContextValidationIssue(
                    "ERR_HEADINGS_INSUFFICIENT",
                    f"Matching Headings requires at least 3 headings, found {len(opts)}",
                    "headings",
                )
            )

    # Matching Features, Endings, Classification
    elif resolved_family in (
        QuestionPromptFamily.MATCHING_FEATURES,
        QuestionPromptFamily.MATCHING_ENDINGS,
        QuestionPromptFamily.CLASSIFICATION,
    ):
        opts = options_raw or []
        if len(opts) < 2:
            issues.append(
                ContextValidationIssue(
                    "ERR_OPTIONS_INSUFFICIENT",
                    f"{resolved_family.value} requires at least 2 options/categories, found {len(opts)}",
                    "options",
                )
            )

    # Flow Chart
    elif resolved_family == QuestionPromptFamily.FLOW_CHART:
        flow_steps = _extract_field(candidate, "flow_steps", "flowSteps", default=None)
        if not flow_steps or not isinstance(flow_steps, list) or len(flow_steps) < 2:
            issues.append(
                ContextValidationIssue(
                    "ERR_FLOW_STEPS_MISSING",
                    "FLOW_CHART requires at least 2 flow_steps representing sequential stages",
                    "flow_steps",
                )
            )
        w_count = count_words(answer)
        if w_count > 3:
            issues.append(
                ContextValidationIssue(
                    "ERR_WORD_LIMIT_EXCEEDED",
                    f"Answer exceeds maximum of 3 words: '{answer}' ({w_count} words)",
                    "answer",
                )
            )

    # Diagram Label
    elif resolved_family == QuestionPromptFamily.DIAGRAM_LABEL:
        callout = _extract_field(candidate, "callout_label", "calloutLabel", default=None)
        part_desc = _extract_field(candidate, "part_description", "partDescription", default=None)
        if not callout and not part_desc:
            issues.append(
                ContextValidationIssue(
                    "ERR_DIAGRAM_LABEL_MISSING",
                    "DIAGRAM_LABEL requires callout_label or part_description for layout clarity",
                    "callout_label",
                )
            )
        w_count = count_words(answer)
        if w_count > 3:
            issues.append(
                ContextValidationIssue(
                    "ERR_WORD_LIMIT_EXCEEDED",
                    f"Answer exceeds maximum of 3 words: '{answer}' ({w_count} words)",
                    "answer",
                )
            )

    return issues
