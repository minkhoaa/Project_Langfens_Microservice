"""Narrow TFNG evidence checks; topic citations are not proof of contradiction."""
from __future__ import annotations

import re


def is_meta_presence_statement(statement: str) -> bool:
    """A claim about text coverage is not a factual IELTS proposition.

    'The passage states that X' is an attribution of X, not this problematic
    coverage pattern. Do not rewrite either the proposition or its answer here.
    """
    return bool(re.match(
        r"^\s*(?:the\s+)?(?:passage|text|article)\s+"
        r"(?:discusses\b|provides\s+(?:information|details)\b|"
        r"(?:mentions|describes|explains)\s+(?:the\s+)?specific\b)",
        statement, re.I,
    ))


def alternative_has_tfng_evidence(answer: str, statement: str, spans: list[str]) -> bool:
    """Require proposition-level support, not an adversary's grounding flag.

    A FALSE/NO allegation must cite contradiction, never mere absence of detail.
    These existing bounded semantic checks do not replace independent solving or
    the author-key semantic evaluator. Unsupported alternatives are diagnostic
    rejections, not permission to accept an otherwise invalid key.
    """
    from app.evaluators.semantic import detect_contradiction_in_text, detect_entailment_in_text

    label = answer.strip().upper().replace(" ", "_")
    if label not in {"TRUE", "FALSE", "YES", "NO", "NOT_GIVEN"}:
        return False
    if label in {"FALSE", "NO"}:
        return any(detect_contradiction_in_text(statement, span) for span in spans)
    if label in {"TRUE", "YES"}:
        return any(detect_entailment_in_text(statement, span) for span in spans)
    # A NOT_GIVEN review still needs topical context. Whole-passage absence and
    # independent solving remain mandatory in the evaluator, outside this helper.
    return bool(spans)
