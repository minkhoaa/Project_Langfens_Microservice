"""Narrow TFNG evidence checks; topic citations are not proof of contradiction."""
from __future__ import annotations

import re
from enum import Enum


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


class TFNGEvidenceRelation(str, Enum):
    SUPPORTED = "SUPPORTED"
    UNSUPPORTED = "UNSUPPORTED"
    UNRESOLVED = "UNRESOLVED"


def tfng_alternative_relation(
    answer: str, statement: str, spans: list[str], passage_text: str = "",
) -> TFNGEvidenceRelation:
    """Separate invalid evidence from an incomplete deterministic assessment.

    Lexical checks are not a complete semantic decision procedure. Failure to
    recognize a paraphrase or negation must retain an independent adversary's
    blocker, never become clean key confirmation. Coverage-framed statements
    remain invalid under the mandatory question semantic evaluator.
    """
    from app.evaluators.semantic import detect_contradiction_in_text, detect_entailment_in_text

    label = answer.strip().upper().replace(" ", "_")
    if label not in {"TRUE", "FALSE", "YES", "NO", "NOT_GIVEN"} or not spans:
        return TFNGEvidenceRelation.UNSUPPORTED
    if is_meta_presence_statement(statement):
        # These are not factual TFNG propositions; topic citations cannot repair
        # their invalid answer boundary. The semantic evaluator blocks the item.
        return TFNGEvidenceRelation.UNSUPPORTED
    if label in {"FALSE", "NO"}:
        if any(detect_contradiction_in_text(statement, span) for span in spans):
            return TFNGEvidenceRelation.SUPPORTED
        return TFNGEvidenceRelation.UNRESOLVED
    if label in {"TRUE", "YES"}:
        if any(detect_entailment_in_text(statement, span) for span in spans):
            return TFNGEvidenceRelation.SUPPORTED
        return TFNGEvidenceRelation.UNRESOLVED
    # A topical quote alone does not establish absence. Only literal presence
    # can refute NG here: approximate overlap can mistake 'uses wood' for 'uses
    # charcoal'. Nonliteral entailment/contradiction needs independent review.
    normalize = lambda text: re.sub(r"\s+", " ", text).strip(" .!?").casefold()
    if passage_text and normalize(statement) in {
        normalize(sentence) for sentence in re.split(r"(?<=[.!?])\s+", passage_text)
    }:
        return TFNGEvidenceRelation.UNSUPPORTED
    return TFNGEvidenceRelation.UNRESOLVED


def alternative_has_tfng_evidence(
    answer: str, statement: str, spans: list[str], passage_text: str = "",
) -> bool:
    """Compatibility predicate: unresolved evidence must remain blocking."""
    return tfng_alternative_relation(answer, statement, spans, passage_text) != TFNGEvidenceRelation.UNSUPPORTED
