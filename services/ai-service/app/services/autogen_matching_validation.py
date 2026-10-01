"""Validation service for AI-generated IELTS matching questions.

Enforces strict structural and semantic parity with the canonical IELTS
standard exam (11111111-1111-1111-1111-111111111111 / ReadingSeeder):
- MATCHING_HEADING
- MATCHING_INFORMATION
- MATCHING_FEATURES
- MATCHING_ENDINGS
"""
from __future__ import annotations

import re
from typing import Any

MATCHING_TYPES: frozenset[str] = frozenset({
    "MATCHING_HEADING",
    "MATCHING_INFORMATION",
    "MATCHING_FEATURES",
    "MATCHING_ENDINGS",
})

FORBIDDEN_ANSWER_FIELDS: tuple[str, ...] = (
    "blankAcceptTexts",
    "blankAcceptRegex",
    "orderCorrects",
    "shortAnswerAcceptTexts",
    "shortAnswerAcceptRegex",
)

HEADING_OPTION_PATTERN: re.Pattern[str] = re.compile(r"^([ivxlcdm]+)\.\s+(.+)$", re.IGNORECASE)
LETTER_OPTION_PATTERN: re.Pattern[str] = re.compile(r"^([A-Z])\.\s+(.+)$")
TARGET_LINE_PATTERN: re.Pattern[str] = re.compile(r"^\s*(\d+)[.)]\s+(.+)$")


def _collapse_ws(s: str) -> str:
    """Normalize whitespace for text comparisons."""
    return " ".join(s.strip().split())


def validate_matching_question(
    question: Any,
    expected_type: str,
    expected_skill: str,
    expected_difficulty: int,
) -> list[str]:
    """Validate a single generated matching question against canonical schema.

    Args:
        question: The parsed question dict from LLM output.
        expected_type: Expected QuestionType enum string.
        expected_skill: Expected skill string (e.g. 'READING').
        expected_difficulty: Expected integer difficulty (1-5).

    Returns:
        List of validation failure messages (empty if valid).
    """
    issues: list[str] = []

    if not isinstance(question, dict):
        return ["question must be a JSON object"]

    # 1. Exact requested type, skill, difficulty
    qtype = question.get("type")
    if qtype != expected_type:
        issues.append(f"type must be '{expected_type}', got '{qtype}'")

    qskill = question.get("skill")
    if qskill != expected_skill:
        issues.append(f"skill must be '{expected_skill}', got '{qskill}'")

    diff = question.get("difficulty")
    if type(diff) is not int or isinstance(diff, bool):
        issues.append(f"difficulty must be an integer, got {type(diff).__name__}")
    else:
        if diff != expected_difficulty:
            issues.append(f"difficulty must be {expected_difficulty}, got {diff}")
        if not (1 <= diff <= 5):
            issues.append(f"difficulty must be in range [1, 5], got {diff}")

    # 2. promptMd
    prompt_md = question.get("promptMd")
    if not isinstance(prompt_md, str) or not prompt_md.strip():
        issues.append("promptMd must be a non-empty string")
        prompt_md = ""

    # 3. Forbidden answer-family fields
    for field in FORBIDDEN_ANSWER_FIELDS:
        val = question.get(field)
        if val is not None and len(val) > 0:
            issues.append(
                f"forbidden answer-family field '{field}' must not be present or non-empty"
            )

    # 4. options pool
    options = question.get("options")
    if not isinstance(options, list) or len(options) == 0:
        issues.append("options must be a non-empty array")
        options = []

    is_heading = expected_type == "MATCHING_HEADING"
    option_keys: list[str] = []
    option_texts: dict[str, str] = {}
    seen_indices: set[int] = set()
    n_opts = len(options)

    for i, opt in enumerate(options):
        if not isinstance(opt, dict):
            issues.append(f"options[{i}] must be a JSON object")
            continue

        idx = opt.get("idx")
        if type(idx) is not int or isinstance(idx, bool):
            issues.append(f"options[{i}].idx must be an integer")
        else:
            seen_indices.add(idx)

        is_corr = opt.get("isCorrect")
        if is_corr is not False:
            issues.append(f"options[{i}].isCorrect must be false")

        content = opt.get("contentMd")
        if not isinstance(content, str) or not content.strip():
            issues.append(f"options[{i}].contentMd must be a non-empty string")
            continue

        content_clean = content.strip()
        if is_heading:
            m = HEADING_OPTION_PATTERN.match(content_clean)
            if not m:
                issues.append(
                    f"options[{i}].contentMd '{content_clean}' must match Roman numeral label format (e.g. 'i. Heading text')"
                )
            else:
                key = m.group(1).lower()
                text = m.group(2).strip()
                option_keys.append(key)
                option_texts[key] = text
        else:
            m = LETTER_OPTION_PATTERN.match(content_clean)
            if not m:
                issues.append(
                    f"options[{i}].contentMd '{content_clean}' must match letter label format (e.g. 'A. Feature text')"
                )
            else:
                key = m.group(1)
                text = m.group(2).strip()
                option_keys.append(key)
                option_texts[key] = text
                if expected_type == "MATCHING_INFORMATION":
                    if content_clean != f"{key}. Paragraph {key}":
                        issues.append(
                            f"options[{i}].contentMd must be '{key}. Paragraph {key}', got '{content_clean}'"
                        )

    if options and seen_indices != set(range(1, n_opts + 1)):
        issues.append(f"options idx must be sequential 1-based integers (1..{n_opts})")

    if len(option_keys) != len(set(option_keys)):
        issues.append("options must have unique label keys")

    # 5. Parse targets from promptMd (only first line of each target item: ^\s*(\d+)[.)]\s+(.+)$)
    targets: dict[str, str] = {}
    for line in prompt_md.splitlines():
        m = TARGET_LINE_PATTERN.match(line)
        if m:
            t_num = m.group(1)
            t_text = m.group(2).strip()
            if t_num in targets:
                issues.append(f"duplicate target number '{t_num}' in promptMd")
            targets[t_num] = t_text

    if len(targets) < 2:
        issues.append(
            f"promptMd must contain at least 2 numbered targets matching 'N. ...', found {len(targets)}"
        )

    # 6. matchPairs validation
    match_pairs = question.get("matchPairs")
    if not isinstance(match_pairs, dict):
        issues.append("matchPairs must be a JSON object")
        match_pairs = {}
    elif len(match_pairs) < 2:
        issues.append(
            f"matchPairs must contain at least 2 pairs, found {len(match_pairs)}"
        )

    for k in match_pairs.keys():
        if not (isinstance(k, str) and k.isdigit() and int(k) > 0):
            issues.append(f"matchPairs key '{k}' must be a positive decimal string")

    if set(match_pairs.keys()) != set(targets.keys()):
        issues.append(
            f"matchPairs keys {sorted(match_pairs.keys())} do not match promptMd targets {sorted(targets.keys())}"
        )

    used_grading_keys: list[str] = []
    for t_key, val in match_pairs.items():
        if not isinstance(val, (list, tuple)) or len(val) != 2:
            issues.append(
                f"matchPairs['{t_key}'] must be a [gradingKey, displayLabel] pair of exactly 2 items"
            )
            continue

        g_key, d_label = val
        if not isinstance(g_key, str) or not g_key.strip():
            issues.append(f"matchPairs['{t_key}'][0] gradingKey must be a non-empty string")
            continue
        if not isinstance(d_label, str) or not d_label.strip():
            issues.append(f"matchPairs['{t_key}'][1] displayLabel must be a non-empty string")
            continue

        g_key_norm = g_key.strip().lower() if is_heading else g_key.strip()
        if g_key_norm not in option_keys:
            issues.append(
                f"matchPairs['{t_key}'] gradingKey '{g_key}' does not exist in options choice pool"
            )
        used_grading_keys.append(g_key_norm)

        # displayLabel alignment
        if is_heading:
            expected_heading_text = option_texts.get(g_key_norm, "")
            if _collapse_ws(d_label) != _collapse_ws(expected_heading_text):
                issues.append(
                    f"matchPairs['{t_key}'] displayLabel '{d_label}' does not match correct heading text '{expected_heading_text}'"
                )
        else:
            expected_target_text = targets.get(t_key, "")
            if _collapse_ws(d_label) != _collapse_ws(expected_target_text):
                issues.append(
                    f"matchPairs['{t_key}'] displayLabel '{d_label}' does not match target text '{expected_target_text}'"
                )

    # 7. Distractor rule: at least one option must not be used in matchPairs
    unused_keys = set(option_keys) - set(used_grading_keys)
    if option_keys and len(unused_keys) < 1:
        issues.append("options pool must contain at least one unused distractor option")

    # 8. Distinct gradingKey rules: HEADING and ENDINGS must not reuse keys; INFORMATION/FEATURES may
    if expected_type in ("MATCHING_HEADING", "MATCHING_ENDINGS"):
        if len(used_grading_keys) != len(set(used_grading_keys)):
            issues.append(f"{expected_type} grading keys must be distinct across targets")

    # 9. HEADING prompt must include all Roman option headings
    if is_heading:
        prompt_collapsed = _collapse_ws(prompt_md).lower()
        for k in option_keys:
            opt_text = option_texts.get(k, "")
            if _collapse_ws(opt_text).lower() not in prompt_collapsed:
                issues.append(
                    f"MATCHING_HEADING promptMd must include heading text for option '{k}': '{opt_text}'"
                )

    return issues
