"""Passage grounding verification, span extraction, and polarity checking."""
from __future__ import annotations

import re
from typing import Any, Dict, List, Optional, Tuple

from app.validation.models import (
    IssueCode,
    Repairability,
    ValidationIssue,
    ValidationSeverity,
)


def find_verbatim_spans(needle: str, haystack: str) -> List[Tuple[int, int]]:
    """Locate all case-insensitive substring spans of needle in haystack."""
    if not needle or not haystack:
        return []

    spans: List[Tuple[int, int]] = []
    pattern = re.escape(needle.strip())
    for match in re.finditer(pattern, haystack, re.IGNORECASE):
        spans.append((match.start(), match.end()))
    return spans


def extract_context_window(haystack: str, start: int, end: int, window: int = 100) -> str:
    """Extract a bounded snippet around the matched span."""
    ctx_start = max(0, start - window)
    ctx_end = min(len(haystack), end + window)
    prefix = "..." if ctx_start > 0 else ""
    suffix = "..." if ctx_end < len(haystack) else ""
    return f"{prefix}{haystack[ctx_start:ctx_end].strip()}{suffix}"


def check_negation_contradiction(statement: str, evidence: str) -> bool:
    """Heuristic polarity screening to detect blatant contradiction between statement and evidence."""
    negation_words = {"not", "never", "no", "neither", "none", "unable", "failed", "impossible"}
    s_tokens = set(re.findall(r"\b\w+\b", statement.lower()))
    e_tokens = set(re.findall(r"\b\w+\b", evidence.lower()))

    s_has_neg = bool(s_tokens & negation_words)
    e_has_neg = bool(e_tokens & negation_words)

    # Polarity clash when token overlap is high (>50%) but negation differs
    shared_content_words = (s_tokens & e_tokens) - negation_words
    if len(shared_content_words) >= 3 and s_has_neg != e_has_neg:
        return True
    return False
