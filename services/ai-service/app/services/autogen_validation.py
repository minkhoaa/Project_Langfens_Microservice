"""Unified structural, semantic, and language validator for IELTS question generation.

Enforces canonical contracts for all 19 IELTS question types across:
- Choice questions: MULTIPLE_CHOICE_SINGLE, MULTIPLE_CHOICE_MULTIPLE,
  TRUE_FALSE_NOT_GIVEN, YES_NO_NOT_GIVEN, MULTIPLE_CHOICE_SINGLE_IMAGE
- Completion questions: SUMMARY_COMPLETION, TABLE_COMPLETION, NOTE_COMPLETION,
  FORM_COMPLETION, SENTENCE_COMPLETION, DIAGRAM_LABEL, MAP_LABEL
- Short answer: SHORT_ANSWER
- Ordering: FLOW_CHART
- Matching questions: MATCHING_HEADING, MATCHING_INFORMATION, MATCHING_FEATURES,
  MATCHING_ENDINGS, CLASSIFICATION
"""
from __future__ import annotations

import re
from typing import Any

from app.services.autogen_matching_validation import (
    FORBIDDEN_PLACEHOLDERS,
    MATCHING_TYPES,
    validate_matching_question,
)

ALL_SUPPORTED_TYPES: frozenset[str] = frozenset({
    "MULTIPLE_CHOICE_SINGLE",
    "MULTIPLE_CHOICE_MULTIPLE",
    "TRUE_FALSE_NOT_GIVEN",
    "YES_NO_NOT_GIVEN",
    "MULTIPLE_CHOICE_SINGLE_IMAGE",
    "SUMMARY_COMPLETION",
    "TABLE_COMPLETION",
    "NOTE_COMPLETION",
    "FORM_COMPLETION",
    "SENTENCE_COMPLETION",
    "SHORT_ANSWER",
    "DIAGRAM_LABEL",
    "MAP_LABEL",
    "MATCHING_HEADING",
    "MATCHING_INFORMATION",
    "MATCHING_FEATURES",
    "MATCHING_ENDINGS",
    "CLASSIFICATION",
    "FLOW_CHART",
})

CHOICE_TYPES: frozenset[str] = frozenset({
    "MULTIPLE_CHOICE_SINGLE",
    "MULTIPLE_CHOICE_MULTIPLE",
    "TRUE_FALSE_NOT_GIVEN",
    "YES_NO_NOT_GIVEN",
    "MULTIPLE_CHOICE_SINGLE_IMAGE",
})

COMPLETION_TYPES: frozenset[str] = frozenset({
    "SUMMARY_COMPLETION",
    "TABLE_COMPLETION",
    "NOTE_COMPLETION",
    "FORM_COMPLETION",
    "SENTENCE_COMPLETION",
    "DIAGRAM_LABEL",
    "MAP_LABEL",
})

# Vietnamese diacritics pattern for candidate-facing text screening
VIETNAMESE_DIACRITICS_RE: re.Pattern[str] = re.compile(
    r"[àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđ"
    r"ÀÁẢÃẠĂẰẮẲẴẶÂẦẤẨẪẬÈÉẺẼẸÊỀẾỂỄỆÌÍỈĨỊÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢÙÚỦŨỤƯỪỨỬỮỰỲÝỶỸỴĐ]",
    re.UNICODE,
)

# Common Vietnamese grammatical / question words
VIETNAMESE_WORDS_RE: re.Pattern[str] = re.compile(
    r"\b(câu\s+hỏi|đoạn\s+văn|chọn|đáp\s+án|đúng|sai|không\s+có|tiêu\s+đề|bài\s+đọc|"
    r"thông\s+tin|nối|điền|từ|vào\s+chỗ\s+trống|giải\s+thích|theo\s+bài|trong\s+bài)\b",
    re.IGNORECASE,
)

BRACKET_MARKER_RE: re.Pattern[str] = re.compile(r"\[(\d+)\]")
STEP_SLUG_RE: re.Pattern[str] = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")


def validate_english_text(text: str, field_name: str) -> list[str]:
    """Validate that candidate-facing text contains no Vietnamese characters or keywords."""
    issues: list[str] = []
    if not isinstance(text, str) or not text.strip():
        return issues

    diacritic_match = VIETNAMESE_DIACRITICS_RE.search(text)
    if diacritic_match:
        issues.append(
            f"{field_name} contains Vietnamese characters ('{diacritic_match.group(0)}'). All content must be in English."
        )

    word_match = VIETNAMESE_WORDS_RE.search(text)
    if word_match:
        issues.append(
            f"{field_name} contains Vietnamese phrase ('{word_match.group(0)}'). All content must be in English."
        )

    return issues


def validate_question(
    question: Any,
    expected_type: str,
    expected_skill: str = "READING",
    expected_difficulty: int = 3,
) -> list[str]:
    """Validate a single generated IELTS question against canonical schema and invariants.

    Args:
        question: Parsed question dict from LLM.
        expected_type: Requested QuestionType string.
        expected_skill: Requested skill (default "READING").
        expected_difficulty: Requested difficulty integer (1-5).

    Returns:
        List of validation failure messages (empty if valid).
    """
    issues: list[str] = []

    if not isinstance(question, dict):
        return ["question must be a JSON object"]

    # 1. Type, skill, difficulty
    qtype = question.get("type")
    if qtype != expected_type:
        issues.append(f"type must be '{expected_type}', got '{qtype}'")

    if expected_type not in ALL_SUPPORTED_TYPES:
        issues.append(f"unsupported question type '{expected_type}'")
        return issues

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

    # 3. English Language Integrity
    issues.extend(validate_english_text(prompt_md, "promptMd"))
    explanation = question.get("explanationMd")
    if isinstance(explanation, str) and explanation.strip():
        issues.extend(validate_english_text(explanation, "explanationMd"))

    # 4. Delegate MATCHING_* types
    if expected_type in MATCHING_TYPES:
        matching_issues = validate_matching_question(
            question, expected_type, expected_skill, expected_difficulty
        )
        # Check language on matching options and pairs
        options = question.get("options") or []
        if isinstance(options, list):
            for i, opt in enumerate(options):
                if isinstance(opt, dict) and isinstance(opt.get("contentMd"), str):
                    issues.extend(validate_english_text(opt["contentMd"], f"options[{i}].contentMd"))
        match_pairs = question.get("matchPairs") or {}
        if isinstance(match_pairs, dict):
            for k, val in match_pairs.items():
                if isinstance(val, (list, tuple)) and len(val) >= 2 and isinstance(val[1], str):
                    issues.extend(validate_english_text(val[1], f"matchPairs['{k}'][1]"))
        return issues + matching_issues

    # 5. Type-Family Mutually Exclusive Field Validation
    if expected_type in CHOICE_TYPES:
        for field in ("blankAcceptTexts", "blankAcceptRegex", "matchPairs", "orderCorrects", "shortAnswerAcceptTexts", "shortAnswerAcceptRegex"):
            val = question.get(field)
            if val is not None and len(val) > 0:
                issues.append(f"{expected_type}: forbidden answer-family field '{field}' must not be present or non-empty")

        options = question.get("options")
        if not isinstance(options, list) or len(options) == 0:
            issues.append(f"{expected_type}: options must be a non-empty array")
            return issues

        correct_count = 0
        seen_indices: set[int] = set()
        seen_contents: set[str] = set()
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

            content = opt.get("contentMd")
            if not isinstance(content, str) or not content.strip():
                issues.append(f"options[{i}].contentMd must be a non-empty string")
            else:
                issues.extend(validate_english_text(content, f"options[{i}].contentMd"))
                norm_c = content.strip().lower()
                if norm_c in seen_contents:
                    issues.append(f"options[{i}].contentMd is a duplicate option")
                seen_contents.add(norm_c)

            is_corr = opt.get("isCorrect")
            if type(is_corr) is not bool:
                issues.append(f"options[{i}].isCorrect must be a boolean (true/false)")
            elif is_corr:
                correct_count += 1

        if seen_indices != set(range(1, n_opts + 1)):
            issues.append(f"options idx must be sequential 1-based integers (1..{n_opts})")

        if expected_type == "MULTIPLE_CHOICE_SINGLE":
            if n_opts < 2:
                issues.append("MULTIPLE_CHOICE_SINGLE requires at least 2 options")
            if correct_count != 1:
                issues.append(f"MULTIPLE_CHOICE_SINGLE requires exactly 1 correct option, got {correct_count}")

        elif expected_type == "MULTIPLE_CHOICE_MULTIPLE":
            if n_opts < 3:
                issues.append("MULTIPLE_CHOICE_MULTIPLE requires at least 3 options")
            if correct_count < 2:
                issues.append(f"MULTIPLE_CHOICE_MULTIPLE requires at least 2 correct options, got {correct_count}")

        elif expected_type == "TRUE_FALSE_NOT_GIVEN":
            if n_opts != 3:
                issues.append(f"TRUE_FALSE_NOT_GIVEN requires exactly 3 options, got {n_opts}")
            if correct_count != 1:
                issues.append(f"TRUE_FALSE_NOT_GIVEN requires exactly 1 correct option, got {correct_count}")
            labels = {re.sub(r"^[A-Za-z0-9]+[.)\-]\s*", "", opt.get("contentMd", "")).strip().lower() for opt in options if isinstance(opt, dict)}
            if not any("true" in l for l in labels) or not any("false" in l for l in labels) or not any("not given" in l for l in labels):
                issues.append("TRUE_FALSE_NOT_GIVEN options must include True, False, and Not Given")

        elif expected_type == "YES_NO_NOT_GIVEN":
            if n_opts != 3:
                issues.append(f"YES_NO_NOT_GIVEN requires exactly 3 options, got {n_opts}")
            if correct_count != 1:
                issues.append(f"YES_NO_NOT_GIVEN requires exactly 1 correct option, got {correct_count}")
            labels = {re.sub(r"^[A-Za-z0-9]+[.)\-]\s*", "", opt.get("contentMd", "")).strip().lower() for opt in options if isinstance(opt, dict)}
            if not any("yes" in l for l in labels) or not any("no" in l for l in labels) or not any("not given" in l for l in labels):
                issues.append("YES_NO_NOT_GIVEN options must include Yes, No, and Not Given")
        elif expected_type == "MULTIPLE_CHOICE_SINGLE_IMAGE":
            if n_opts < 2:
                issues.append("MULTIPLE_CHOICE_SINGLE_IMAGE requires at least 2 options")
            if correct_count != 1:
                issues.append(f"MULTIPLE_CHOICE_SINGLE_IMAGE requires exactly 1 correct option, got {correct_count}")
            has_q_image = bool(question.get("imageUrl") and str(question.get("imageUrl")).strip())
            has_opt_images = all(bool(opt.get("imageUrl") and str(opt.get("imageUrl")).strip()) for opt in options if isinstance(opt, dict))
            if not has_q_image and not has_opt_images:
                issues.append("MULTIPLE_CHOICE_SINGLE_IMAGE requires an imageUrl on question or on all options")

    elif expected_type in COMPLETION_TYPES:
        for field in ("matchPairs", "orderCorrects", "shortAnswerAcceptTexts", "shortAnswerAcceptRegex"):
            val = question.get(field)
            if val is not None and len(val) > 0:
                issues.append(f"{expected_type}: forbidden answer-family field '{field}' must not be present or non-empty")

        options = question.get("options")
        if options is not None and len(options) > 0:
            issues.append(f"{expected_type}: options array must not be present or non-empty")

        blanks = question.get("blankAcceptTexts")
        if not isinstance(blanks, dict) or len(blanks) == 0:
            issues.append(f"{expected_type}: blankAcceptTexts must be a non-empty dictionary")
            return issues

        prompt_markers = set(BRACKET_MARKER_RE.findall(prompt_md))
        has_diagram_map_spec = expected_type in ("DIAGRAM_LABEL", "MAP_LABEL") and bool(
            re.search(r"\[(Diagram|Map):\s*[^\]]+\]", prompt_md, re.IGNORECASE)
        )
        for b_key, b_vals in blanks.items():
            if not (isinstance(b_key, str) and b_key.isdigit() and int(b_key) > 0):
                issues.append(f"blankAcceptTexts key '{b_key}' must be a positive decimal string")

            if not isinstance(b_vals, (list, tuple)) or len(b_vals) == 0:
                issues.append(f"blankAcceptTexts['{b_key}'] must be a non-empty array of strings")
                continue

            for val in b_vals:
                if not isinstance(val, str) or not val.strip():
                    issues.append(f"blankAcceptTexts['{b_key}'] contains empty string answer")
                    continue
                clean_v = val.strip().lower()
                if clean_v in FORBIDDEN_PLACEHOLDERS:
                    issues.append(f"blankAcceptTexts['{b_key}'] answer '{val}' cannot be a placeholder")
                issues.extend(validate_english_text(val, f"blankAcceptTexts['{b_key}']"))
                # IELTS word limit rule: completion items cannot exceed 3 words
                words = re.findall(r"\b[\w'-]+\b", val)
                if len(words) > 3:
                    issues.append(f"blankAcceptTexts['{b_key}'] answer '{val}' exceeds 3 words ({len(words)} words)")

            if not has_diagram_map_spec and b_key not in prompt_markers:
                issues.append(f"promptMd is missing canonical marker [{b_key}] for blank key '{b_key}'")

        if expected_type in ("DIAGRAM_LABEL", "MAP_LABEL"):
            q_img = question.get("imageUrl")
            if not isinstance(q_img, str) or not q_img.strip():
                issues.append(f"{expected_type} requires a non-empty imageUrl at question level")

    elif expected_type == "SHORT_ANSWER":
        for field in ("blankAcceptTexts", "blankAcceptRegex", "matchPairs", "orderCorrects"):
            val = question.get(field)
            if val is not None and len(val) > 0:
                issues.append(f"SHORT_ANSWER: forbidden answer-family field '{field}' must not be present or non-empty")

        options = question.get("options")
        if options is not None and len(options) > 0:
            issues.append("SHORT_ANSWER: options array must not be present or non-empty")

        texts = question.get("shortAnswerAcceptTexts")
        if not isinstance(texts, list) or len(texts) == 0:
            issues.append("SHORT_ANSWER: shortAnswerAcceptTexts must be a non-empty array of strings")
            return issues

        for i, val in enumerate(texts):
            if not isinstance(val, str) or not val.strip():
                issues.append(f"shortAnswerAcceptTexts[{i}] must be a non-empty string")
                continue
            clean_v = val.strip().lower()
            if clean_v in FORBIDDEN_PLACEHOLDERS:
                issues.append(f"shortAnswerAcceptTexts[{i}] answer '{val}' cannot be a placeholder")
            issues.extend(validate_english_text(val, f"shortAnswerAcceptTexts[{i}]"))
            words = re.findall(r"\b[\w'-]+\b", val)
            if len(words) > 3:
                issues.append(f"shortAnswerAcceptTexts[{i}] answer '{val}' exceeds 3 words ({len(words)} words)")

    elif expected_type == "FLOW_CHART":
        for field in ("blankAcceptTexts", "blankAcceptRegex", "matchPairs", "shortAnswerAcceptTexts", "shortAnswerAcceptRegex"):
            val = question.get(field)
            if val is not None and len(val) > 0:
                issues.append(f"FLOW_CHART: forbidden answer-family field '{field}' must not be present or non-empty")

        order = question.get("orderCorrects")
        if not isinstance(order, list) or len(order) < 2:
            issues.append("FLOW_CHART: orderCorrects must be an array of at least 2 step slugs")
            return issues

        for i, slug in enumerate(order):
            if not isinstance(slug, str) or not STEP_SLUG_RE.match(slug.strip()):
                issues.append(f"FLOW_CHART: orderCorrects[{i}] '{slug}' must match ^[a-z0-9]+(?:-[a-z0-9]+)*$")

        if len(order) != len(set(order)):
            issues.append("FLOW_CHART: orderCorrects step slugs must be unique")

    return issues
