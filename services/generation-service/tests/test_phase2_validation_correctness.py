"""Tests verifying Phase 2 Validation Correctness across all 19 IELTS Question Types.

Invariants:
1. No source passage must not silently imply successful grounding verification.
2. Structural VALID must be distinguished from semantic VALID.
3. Unverified semantic correctness must return NEEDS_REVIEW where evidence is required.
4. Missing, ambiguous or unsupported answer keys must fail closed.
5. Every scored item must have a valid canonical answer key.
6. Type-specific semantic rules are preserved across all 19 types.
"""
import copy
import json
from pathlib import Path
import pytest

from app.validation import (
    ALL_19_TYPES,
    CHOICE_TYPES,
    COMPLETION_TYPES,
    MATCHING_TYPES,
    ORDERING_TYPE,
    SHORT_ANSWER_TYPE,
    IssueCode,
    ValidationPolicy,
    ValidationStatus,
    get_validator_registry,
    validate_question,
)

CONTRACT_PATH = Path(__file__).resolve().parents[2] / "ai-service/app/prompts/autogen_contract.json"

SAMPLE_PASSAGE = (
    "The invention of paper is traditionally attributed to Cai Lun, an official of the Chinese Han dynasty court "
    "in 105 AD. He created sheets of paper using mulberry and other bast fibres along with fishnets, old rags, "
    "and hemp waste. Before this innovation, writing surfaces included bamboo slips and silk in China, while other "
    "ancient cultures relied on parchment made from animal skins or papyrus made from reeds along the Nile. "
    "Paper provided a lightweight, economical alternative that transformed literacy, governance, and scholarship. "
    "The manufacturing technique spread slowly along the Silk Road, reaching Samarkand in 751 AD after the Battle "
    "of Talas, and eventually arriving in Europe during the twelfth century."
)


@pytest.fixture(scope="module")
def canonical_questions():
    with open(CONTRACT_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)
    examples = {}
    for item in data.get("examples", []):
        q = item.get("question")
        if q and "type" in q and q["type"] not in examples:
            examples[q["type"]] = q
    assert len(examples) == 19
    return examples


def test_no_passage_does_not_silently_imply_grounding_verified(canonical_questions):
    """When no passage is supplied and grounding is enforced, grounding_verified must be False and status NEEDS_REVIEW."""
    q = copy.deepcopy(canonical_questions["MULTIPLE_CHOICE_SINGLE"])
    # Default policy has enforce_grounding = True
    policy = ValidationPolicy(enforce_grounding=True)
    res = validate_question(q, passage=None, policy=policy)

    assert res.grounding_verified is False, "No passage must not imply grounding_verified=True"
    assert res.structural_valid is True, "Structural schema is valid"
    assert res.semantic_valid is None, "Semantic correctness is unverified without passage"
    assert res.status == ValidationStatus.NEEDS_REVIEW, "Unverified semantic correctness must return NEEDS_REVIEW"
    assert any("passage" in r.lower() for r in res.reasons)


def test_structural_valid_distinguished_from_semantic_valid(canonical_questions):
    """Structural validity and semantic validity must be explicitly separated in ValidationResult."""
    q = copy.deepcopy(canonical_questions["SENTENCE_COMPLETION"])
    # 1. Structural check only (enforce_grounding=False)
    struct_res = validate_question(q, policy=ValidationPolicy(enforce_grounding=False))
    assert struct_res.structural_valid is True
    assert struct_res.semantic_valid is None
    assert struct_res.grounding_verified is False
    assert struct_res.status == ValidationStatus.VALID

    # 2. Complete check with passage and grounded answer
    q["blankAcceptTexts"] = {"1": ["mulberry"]}
    q["promptMd"] = "Cai Lun used sheets of paper using [1] and other fibres."
    sem_res = validate_question(q, passage=SAMPLE_PASSAGE, policy=ValidationPolicy(enforce_grounding=True))
    assert sem_res.structural_valid is True
    assert sem_res.semantic_valid is True
    assert sem_res.grounding_verified is True
    assert sem_res.status == ValidationStatus.VALID


def test_unverified_semantic_correctness_returns_needs_review(canonical_questions):
    """Missing passage when evidence is required must return NEEDS_REVIEW across reading question types."""
    for qtype in ["TRUE_FALSE_NOT_GIVEN", "SUMMARY_COMPLETION", "SHORT_ANSWER", "MATCHING_HEADING"]:
        q = copy.deepcopy(canonical_questions[qtype])
        res = validate_question(q, passage=None, policy=ValidationPolicy(enforce_grounding=True))
        assert res.status == ValidationStatus.NEEDS_REVIEW, f"Expected NEEDS_REVIEW for {qtype} without passage, got {res.status}"
        assert res.structural_valid is True
        assert res.grounding_verified is False


def test_missing_or_empty_answer_keys_fail_closed(canonical_questions):
    """Missing, empty, or placeholder answer keys must fail closed with INVALID across all 19 types."""
    for qtype in ALL_19_TYPES:
        q = copy.deepcopy(canonical_questions[qtype])
        if qtype in CHOICE_TYPES:
            for opt in q["options"]:
                opt["isCorrect"] = False
        elif qtype in COMPLETION_TYPES:
            q["blankAcceptTexts"] = {}
        elif qtype in MATCHING_TYPES:
            q["matchPairs"] = {}
        elif qtype == ORDERING_TYPE:
            q["orderCorrects"] = []
        elif qtype == SHORT_ANSWER_TYPE:
            q["shortAnswerAcceptTexts"] = []

        res = validate_question(q, policy=ValidationPolicy(enforce_grounding=False))
        assert res.status == ValidationStatus.INVALID, f"Expected INVALID for {qtype} with empty answer key"
        assert res.has_blocking_issues
        assert res.structural_valid is False


def test_every_scored_item_must_have_valid_canonical_key(canonical_questions):
    """Every supported type's canonical example must produce non-empty valid scored items with canonical keys."""
    for qtype in ALL_19_TYPES:
        q = copy.deepcopy(canonical_questions[qtype])
        res = validate_question(q, policy=ValidationPolicy(enforce_grounding=False))
        assert len(res.scored_items) >= 1, f"{qtype} must yield at least one scored item"
        for item in res.scored_items:
            assert item.is_valid, f"Scored item {item.item_key} in {qtype} should be valid"
            assert item.accepted_answers, f"Scored item {item.item_key} in {qtype} must have accepted_answers"
            assert all(isinstance(a, str) and a.strip() for a in item.accepted_answers)


def test_placeholder_answer_keys_fail_closed(canonical_questions):
    """Placeholder keys such as 'TBD', 'Option A', 'Item 1' must fail closed with ERR_PLACEHOLDER_ANSWER."""
    # Choice type placeholder
    q_mcq = copy.deepcopy(canonical_questions["MULTIPLE_CHOICE_SINGLE"])
    for opt in q_mcq["options"]:
        if opt["isCorrect"]:
            opt["contentMd"] = "TBD"
    res_mcq = validate_question(q_mcq, policy=ValidationPolicy(enforce_grounding=False))
    assert res_mcq.status == ValidationStatus.INVALID
    assert any(i.code == IssueCode.ERR_PLACEHOLDER_ANSWER for i in res_mcq.issues)

    # Completion placeholder
    q_comp = copy.deepcopy(canonical_questions["SUMMARY_COMPLETION"])
    first_key = list(q_comp["blankAcceptTexts"].keys())[0]
    q_comp["blankAcceptTexts"][first_key] = ["Item 1"]
    res_comp = validate_question(q_comp, policy=ValidationPolicy(enforce_grounding=False))
    assert res_comp.status == ValidationStatus.INVALID
    assert any(i.code == IssueCode.ERR_PLACEHOLDER_ANSWER for i in res_comp.issues)
