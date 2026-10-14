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
    if cleaned in ("TRUE", "T"):
        return "TRUE"
    if cleaned in ("FALSE", "F"):
        return "FALSE"
    if cleaned in ("NOT GIVEN", "NOT_GIVEN", "NOTGIVEN", "NG"):
        return "NOT_GIVEN"
    return cleaned


def normalize_ynng_answer(text: str) -> str:
    cleaned = text.strip()
    cleaned = re.sub(r"[.,;:'\"`]+$", "", cleaned).strip()
    cleaned = re.sub(r"^[.,;:'\"`]+", "", cleaned).strip().upper()
    if cleaned in ("YES", "Y"):
        return "YES"
    if cleaned in ("NO", "N"):
        return "NO"
    if cleaned in ("NOT GIVEN", "NOT_GIVEN", "NOTGIVEN", "NG"):
        return "NOT_GIVEN"
    return cleaned


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

    elif "MULTIPLECHOICE" in q_type_norm or q_type_norm == "MCQ":
        norm_exp = normalize_mcq_answer(expected_answer, options)
        norm_solv = normalize_mcq_answer(solver_answer, options)
        is_match = norm_exp == norm_solv
        details["mode"] = "MCQ_OPTION_ID"

    else:
        # Sentence Completion, Summary Completion, Short Answer
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
