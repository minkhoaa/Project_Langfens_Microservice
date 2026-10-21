"""Canonical Answer Comparison Service (P10-05).

Invariants:
- Canonical comparison for TFNG/YNNG, option-ID MCQ, and completion/short answer.
- Strictly NO fuzzy matching (Levenshtein, embeddings, token overlap) to force a pass.
- Strictly NO dynamic loosening of alias policies after a mismatch occurs.
- The expected answer key is evaluated ONLY inside this comparison service,
  NEVER present in solver/adversary request inputs or cache keys.
"""

from __future__ import annotations

import re
from typing import Any, Dict, List, Optional

from app.contracts.solver import (
    ComparisonResult,
    StudentVisibleOption,
)


# Explicit canonical spelling aliases (UK / US variants)
CANONICAL_SPELLING_ALIASES = {
    "colour": "color",
    "flavour": "flavor",
    "honour": "honor",
    "humour": "humor",
    "labour": "labor",
    "neighbour": "neighbor",
    "centre": "center",
    "theatre": "theater",
    "metre": "meter",
    "litre": "liter",
    "fibre": "fiber",
    "analyse": "analyze",
    "paralyse": "paralyze",
    "defence": "defense",
    "licence": "license",
    "practise": "practice",
    "programme": "program",
    "travelling": "traveling",
    "modelling": "modeling",
}


def normalize_completion_string(text: str) -> str:
    """Canonical normalization for completion and short answer strings.

    Performs:
    1. Trim leading/trailing whitespace.
    2. Lowercase conversion.
    3. Strip trailing sentence punctuation (periods, commas, semicolons).
    4. Collapse internal whitespace runs to a single space.
    5. Word-by-word canonical UK/US spelling normalization.
    """
    cleaned = text.strip().lower()
    cleaned = re.sub(r"[.,;:'\"`]+$", "", cleaned).strip()
    cleaned = re.sub(r"^[.,;:'\"`]+", "", cleaned).strip()
    words = cleaned.split()
    normalized_words = [CANONICAL_SPELLING_ALIASES.get(w, w) for w in words]
    return " ".join(normalized_words)


def normalize_tfng_answer(text: str) -> str:
    cleaned = text.strip()
    cleaned = re.sub(r"[.,;:'\"`]+$", "", cleaned).strip()
    cleaned = re.sub(r"^[.,;:'\"`]+", "", cleaned).strip().upper()
    if cleaned in ("TRUE", "T", "YES", "Y"):
        return "TRUE"
    if cleaned in ("FALSE", "F", "NO", "N"):
        return "FALSE"
    if cleaned in ("NOT GIVEN", "NOT_GIVEN", "NOTGIVEN", "NG"):
        return "NOT_GIVEN"
    return cleaned


def normalize_ynng_answer(text: str) -> str:
    cleaned = text.strip()
    cleaned = re.sub(r"[.,;:'\"`]+$", "", cleaned).strip()
    cleaned = re.sub(r"^[.,;:'\"`]+", "", cleaned).strip().upper()
    if cleaned in ("YES", "Y", "TRUE", "T"):
        return "YES"
    if cleaned in ("NO", "N", "FALSE", "F"):
        return "NO"
    if cleaned in ("NOT GIVEN", "NOT_GIVEN", "NOTGIVEN", "NG"):
        return "NOT_GIVEN"
    return cleaned

def normalize_roman_numeral(text: str) -> str:
    """Normalizes Roman numerals (e.g., 'iii', 'IV.', 'Section ix') for matching headings."""
    cleaned = text.strip()
    cleaned = re.sub(r"[.,;:'\"`]+$", "", cleaned).strip()
    cleaned = re.sub(r"^[.,;:'\"`]+", "", cleaned).strip()
    # Strip leading prefixes like "Heading", "Section", "Paragraph"
    m_prefix = re.search(r"\b([ivxlcdmIVXLCDM]+)\b", cleaned)
    if m_prefix:
        return m_prefix.group(1).upper()
    return cleaned.upper()


def normalize_letter_code(
    text: str,
    options: Optional[List[StudentVisibleOption]] = None,
) -> str:
    """Normalizes single letter codes (A-Z) for matching features/info/endings and classification."""
    cleaned = text.strip()
    cleaned = re.sub(r"[.,;:'\"`]+$", "", cleaned).strip()
    cleaned = re.sub(r"^[.,;:'\"`]+", "", cleaned).strip()
    m = re.match(r"^(?:OPTION|CHOICE|PARAGRAPH|SECTION)?\s*\(?([A-Z])\)?(?:\s*[:.\-)]|\s*$)", cleaned, re.IGNORECASE)
    if m:
        return m.group(1).upper()

    if options:
        cleaned_lower = cleaned.lower()
        for opt in options:
            opt_clean = re.sub(r"[.,;:'\"`]+$", "", opt.text.strip()).strip().lower()
            if opt_clean == cleaned_lower:
                return opt.key.upper()
            opt_no_art = re.sub(r"^(?:the|a|an)\s+", "", opt_clean).strip()
            text_no_art = re.sub(r"^(?:the|a|an)\s+", "", cleaned_lower).strip()
            if opt_no_art == text_no_art:
                return opt.key.upper()
    return cleaned.upper()


def normalize_multichoice_multiple(
    text: str,
    options: Optional[List[StudentVisibleOption]] = None,
) -> str:
    """Normalizes multiple choice multiple answers (e.g., 'A, C', 'C and A', 'B, D').

    Sorts selected option letters canonically and returns comma-separated string 'A, C'.
    """
    cleaned = text.strip()
    # Find all standalone single letters A-Z or delimited letters
    letters: List[str] = []
    # First, check if input is formatted like "A, C" or "A and B"
    raw_tokens = re.split(r"[,;&/\s]+|\band\b", cleaned, flags=re.IGNORECASE)
    for tok in raw_tokens:
        t = tok.strip().upper()
        t = re.sub(r"[^A-Z]", "", t)
        if len(t) == 1 and t in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
            if t not in letters:
                letters.append(t)

    if not letters and options:
        # Match against option texts if options are provided
        for opt in options:
            opt_clean = opt.text.strip().lower()
            if opt_clean and opt_clean in cleaned.lower():
                k = opt.key.upper()
                if k not in letters:
                    letters.append(k)

    if letters:
        return ", ".join(sorted(letters))
    return cleaned.upper()


def normalize_box_completion(
    text: str,
    options: Optional[List[StudentVisibleOption]] = None,
) -> str:
    """Normalizes summary completion box answers.

    If options are provided, maps full option text to letter key, or returns canonical letter.
    """
    cleaned = text.strip()
    cleaned_no_punct = re.sub(r"[.,;:'\"`]+$", "", cleaned).strip()
    cleaned_no_punct = re.sub(r"^[.,;:'\"`]+", "", cleaned_no_punct).strip()

    # If single letter A-Z
    if len(cleaned_no_punct) == 1 and cleaned_no_punct.upper() in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
        return cleaned_no_punct.upper()

    # Check prefix like "Option B"
    m = re.match(r"^(?:OPTION|CHOICE)?\s*\(?([A-Z])\)?(?:\s*[:.\-)]|\s*$)", cleaned_no_punct, re.IGNORECASE)
    if m:
        return m.group(1).upper()

    if options:
        cl = cleaned_no_punct.lower()
        for opt in options:
            opt_clean = re.sub(r"[.,;:'\"`]+$", "", opt.text.strip()).strip().lower()
            if opt_clean == cl:
                return opt.key.upper()
            opt_no_art = re.sub(r"^(?:the|a|an)\s+", "", opt_clean).strip()
            text_no_art = re.sub(r"^(?:the|a|an)\s+", "", cl).strip()
            if opt_no_art == text_no_art:
                return opt.key.upper()
            # Also check if text matches opt.key
            if opt.key.upper() == cleaned_no_punct.upper():
                return opt.key.upper()

    return normalize_completion_string(text)


def normalize_mcq_answer(
    text: str,
    options: Optional[List[StudentVisibleOption]] = None,
) -> str:
    cleaned = text.strip().upper()
    # Match direct option letter
    m = re.match(r"^(?:OPTION|CHOICE)?\s*([A-D])(?:\s*[:.\-)]|\s*$)", cleaned)
    if m:
        return m.group(1)

    # If the model returned the full text of an option, match against option texts
    if options:
        cleaned_lower = re.sub(r"[.,;:'\"`]+$", "", text.strip()).strip().lower()
        for opt in options:
            opt_clean = re.sub(r"[.,;:'\"`]+$", "", opt.text.strip()).strip().lower()
            if opt_clean == cleaned_lower:
                return opt.key.upper()
            opt_no_art = re.sub(r"^(?:the|a|an)\s+", "", opt_clean).strip()
            text_no_art = re.sub(r"^(?:the|a|an)\s+", "", cleaned_lower).strip()
            if opt_no_art == text_no_art:
                return opt.key.upper()
    return cleaned

def compare_answers(
    expected_answer: str,
    solver_answer: str,
    question_type: str,
    question_number: int = 1,
    options: Optional[List[StudentVisibleOption]] = None,
) -> ComparisonResult:
    """Compares the solver's answer with the expected answer key.

    INVARIANT: The expected answer key is evaluated strictly here.
    No fuzzy matching is allowed.
    """
    q_type_norm = re.sub(r"[^A-Z]", "", (question_type or "").upper())
    details: Dict[str, Any] = {"questionType": question_type}

    if "TRUEFALSE" in q_type_norm or q_type_norm == "TFNG":
        norm_exp = normalize_tfng_answer(expected_answer)
        norm_solv = normalize_tfng_answer(solver_answer)
        is_match = norm_exp == norm_solv
        details["mode"] = "TFNG_CANONICAL"

    elif "YESNO" in q_type_norm or q_type_norm == "YNNG":
        norm_exp = normalize_ynng_answer(expected_answer)
        norm_solv = normalize_ynng_answer(solver_answer)
        is_match = norm_exp == norm_solv
        details["mode"] = "YNNG_CANONICAL"

    elif "HEADING" in q_type_norm:
        norm_exp = normalize_roman_numeral(expected_answer)
        norm_solv = normalize_roman_numeral(solver_answer)
        is_match = norm_exp == norm_solv
        details["mode"] = "MATCHING_HEADING_ROMAN"

    elif "MULTIPLECHOICEMULTIPLE" in q_type_norm or "MCQMULTIPLE" in q_type_norm:
        norm_exp = normalize_multichoice_multiple(expected_answer, options)
        norm_solv = normalize_multichoice_multiple(solver_answer, options)
        is_match = norm_exp == norm_solv
        details["mode"] = "MULTIPLE_CHOICE_MULTIPLE_SET"

    elif (
        "INFORMATION" in q_type_norm
        or "FEATURE" in q_type_norm
        or "ENDING" in q_type_norm
        or "CLASSIFICATION" in q_type_norm
    ):
        norm_exp = normalize_letter_code(expected_answer, options)
        norm_solv = normalize_letter_code(solver_answer, options)
        is_match = norm_exp == norm_solv
        details["mode"] = "MATCHING_LETTER_CODE"

    elif "SUMMARY" in q_type_norm and "BOX" in q_type_norm:
        norm_exp = normalize_box_completion(expected_answer, options)
        norm_solv = normalize_box_completion(solver_answer, options)
        is_match = norm_exp == norm_solv
        details["mode"] = "SUMMARY_BOX_OPTION"

    elif "MULTIPLECHOICE" in q_type_norm or "MCQ" in q_type_norm or "TITLE" in q_type_norm:
        norm_exp = normalize_mcq_answer(expected_answer, options)
        norm_solv = normalize_mcq_answer(solver_answer, options)
        is_match = norm_exp == norm_solv
        details["mode"] = "MCQ_OPTION_ID"

    else:
        # Sentence Completion, Summary Completion, Table, Flow Chart, Diagram, Short Answer, Note, Form
        norm_exp = normalize_completion_string(expected_answer)
        norm_solv = normalize_completion_string(solver_answer)
        is_match = norm_exp == norm_solv
        details["mode"] = "COMPLETION_EXACT_CANONICAL"
    return ComparisonResult(
        question_number=question_number,
        is_match=is_match,
        expected_answer=expected_answer,
        solver_answer=solver_answer,
        normalized_expected=norm_exp,
        normalized_solver=norm_solv,
        question_type=question_type,
        comparison_details=details,
    )
