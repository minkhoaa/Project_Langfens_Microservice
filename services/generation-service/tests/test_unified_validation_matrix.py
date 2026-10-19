"""Comprehensive Full 19-Type Validation Matrix and Invariant Test Suite.

Verifies:
1. Zero unregistered IELTS question types across all 19 autogen types.
2. Valid canonical example passes for every type.
3. Missing answer key produces ERR_MISSING_ANSWER_KEY.
4. Forbidden answer-family field produces ERR_FORBIDDEN_ANSWER_FIELD.
5. Invalid option reference produces ERR_OPTION_REF_INVALID / ERR_OPTIONS_INDICES_NON_SEQUENTIAL.
6. Malformed structure produces ERR_MALFORMED_STRUCTURE / ERR_PROMPT_EMPTY / ERR_IMAGE_URL_MISSING.
7. Non-English / Vietnamese text produces ERR_VIETNAMESE_TEXT.
8. Un-grounded / unsupported answer produces ERR_UNGROUNDED_ANSWER.
9. Generic non-assessable placeholder produces ERR_PLACEHOLDER_ANSWER.
10. IELTS word limit (> 3 words) produces ERR_WORD_LIMIT_EXCEEDED.
11. Scored-item granularity and grading contract compatibility.
12. Targeted MiniMax ProviderGateway semantic evaluation (layered policy).
"""
from __future__ import annotations

import copy
import json
from pathlib import Path
from typing import Any, Dict
from unittest.mock import AsyncMock, MagicMock
from uuid import uuid4

import pytest

from app.providers.models import ProviderResponse, UsageReport
from app.validation import (
    ALL_19_TYPES,
    CHOICE_TYPES,
    COMPLETION_TYPES,
    MATCHING_TYPES,
    ORDERING_TYPE,
    SHORT_ANSWER_TYPE,
    IssueCode,
    ValidationPolicy,
    ValidationResult,
    ValidationSeverity,
    ValidationStatus,
    get_validator_registry,
    validate_question,
    validate_question_async,
)
from app.validation.semantic import verify_semantics_with_minimax

CONTRACT_PATH = Path(__file__).resolve().parents[2] / "ai-service/app/prompts/autogen_contract.json"


@pytest.fixture(scope="module")
def canonical_questions() -> Dict[str, Dict[str, Any]]:
    """Load canonical question payloads from autogen_contract.json."""
    with open(CONTRACT_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)
    examples = {}
    for item in data.get("examples", []):
        q = item.get("question")
        if q and "type" in q and q["type"] not in examples:
            examples[q["type"]] = q
    assert len(examples) == 19, f"Expected 19 canonical examples, found {len(examples)}"
    return examples


SAMPLE_PASSAGE = (
    "The invention of paper is traditionally attributed to Cai Lun, an official of the Chinese Han dynasty court "
    "in 105 AD. He created sheets of paper using mulberry and other bast fibres along with fishnets, old rags, "
    "and hemp waste. Before this innovation, writing surfaces included bamboo slips and silk in China, while other "
    "ancient cultures relied on parchment made from animal skins or papyrus made from reeds along the Nile. "
    "Paper provided a lightweight, economical alternative that transformed literacy, governance, and scholarship. "
    "The manufacturing technique spread slowly along the Silk Road, reaching Samarkand in 751 AD after the Battle "
    "of Talas, and eventually arriving in Europe during the twelfth century."
)


# ==============================================================================
# 1. Authoritative Contract Registry & Completeness
# ==============================================================================

def test_all_19_types_registered():
    """Verify exactly the 19 IELTS types are registered with zero unregistered types."""
    registry = get_validator_registry()
    registered = set(registry.list_registered_types())
    assert registered == ALL_19_TYPES
    assert len(registered) == 19
    for qtype in ALL_19_TYPES:
        validator = registry.get(qtype)
        assert validator is not None
        assert validator.question_type == qtype


def test_unregistered_type_fails_cleanly():
    """Any unregistered question type must produce an immediate INVALID result."""
    registry = get_validator_registry()
    bad_q = {"type": "UNREGISTERED_INVENTED_TYPE", "promptMd": "Prompt", "skill": "READING", "difficulty": 3}
    res = registry.validate_question(bad_q)
    assert res.status == ValidationStatus.INVALID
    assert any(i.code == IssueCode.ERR_UNKNOWN_TYPE for i in res.issues)


# ==============================================================================
# 2. Canonical Valid Example (All 19 Types)
# ==============================================================================

@pytest.mark.parametrize("qtype", sorted(list(ALL_19_TYPES)))
def test_canonical_valid_example(canonical_questions, qtype):
    """Every supported type's canonical example must validate as VALID with 0 blocking issues."""
    q = copy.deepcopy(canonical_questions[qtype])
    policy = ValidationPolicy(enforce_grounding=False)
    res = validate_question(question=q, policy=policy)

    assert res.status == ValidationStatus.VALID, f"Failed for {qtype}: {res.reasons}"
    assert res.question_type == qtype
    assert not res.has_blocking_issues
    assert len(res.scored_items) >= 1
    assert all(item.is_valid for item in res.scored_items)

    # Serialization round-trip
    dumped = res.model_dump(mode="json")
    reloaded = ValidationResult.model_validate(dumped)
    assert reloaded.status == ValidationStatus.VALID


# ==============================================================================
# 3. Missing Answer Key (All 19 Types)
# ==============================================================================

@pytest.mark.parametrize("qtype", sorted(list(ALL_19_TYPES)))
def test_missing_answer_key(canonical_questions, qtype):
    """Empty or missing answer keys must produce INVALID with ERR_MISSING_ANSWER_KEY / ERR_CORRECT_COUNT_MISMATCH."""
    q = copy.deepcopy(canonical_questions[qtype])
    if qtype in CHOICE_TYPES:
        # Clear isCorrect on all options
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

    res = validate_question(question=q, policy=ValidationPolicy(enforce_grounding=False))
    assert res.status == ValidationStatus.INVALID
    assert any(
        i.code in (IssueCode.ERR_MISSING_ANSWER_KEY, IssueCode.ERR_CORRECT_COUNT_MISMATCH)
        for i in res.issues
    ), f"Expected missing answer issue for {qtype}, got: {[i.code for i in res.issues]}"


# ==============================================================================
# 4. Forbidden Answer-Family Fields (Mutually Exclusive Cross-Family Contamination)
# ==============================================================================

@pytest.mark.parametrize("qtype", sorted(list(ALL_19_TYPES)))
def test_forbidden_answer_field_contamination(canonical_questions, qtype):
    """Cross-family answer contamination must produce ERR_FORBIDDEN_ANSWER_FIELD."""
    q = copy.deepcopy(canonical_questions[qtype])
    if qtype in CHOICE_TYPES:
        q["blankAcceptTexts"] = {"1": ["rogue"]}
    elif qtype in COMPLETION_TYPES:
        q["matchPairs"] = {"1": ["A"]}
    elif qtype in MATCHING_TYPES:
        q["orderCorrects"] = ["step-one", "step-two"]
    elif qtype == ORDERING_TYPE:
        q["blankAcceptTexts"] = {"1": ["rogue"]}
    elif qtype == SHORT_ANSWER_TYPE:
        q["matchPairs"] = {"1": ["A"]}

    res = validate_question(question=q, policy=ValidationPolicy(enforce_grounding=False))
    assert res.status == ValidationStatus.INVALID
    assert any(i.code == IssueCode.ERR_FORBIDDEN_ANSWER_FIELD for i in res.issues)


# ==============================================================================
# 5. Invalid Option References
# ==============================================================================

def test_matching_invalid_option_reference(canonical_questions):
    """matchPairs referencing non-existent option key must produce ERR_OPTION_REF_INVALID."""
    for mtype in ("MATCHING_HEADING", "MATCHING_FEATURES", "MATCHING_INFORMATION", "MATCHING_ENDINGS"):
        q = copy.deepcopy(canonical_questions[mtype])
        first_key = list(q["matchPairs"].keys())[0]
        q["matchPairs"][first_key] = ["Z", "Non-existent label"]
        res = validate_question(question=q, policy=ValidationPolicy(enforce_grounding=False))
        assert res.status == ValidationStatus.INVALID
        assert any(i.code == IssueCode.ERR_OPTION_REF_INVALID for i in res.issues)


def test_mcq_non_sequential_indices(canonical_questions):
    """Options with skipped indices (1, 3, 4 instead of 1, 2, 3) must produce ERR_OPTIONS_INDICES_NON_SEQUENTIAL."""
    q = copy.deepcopy(canonical_questions["MULTIPLE_CHOICE_SINGLE"])
    q["options"][1]["idx"] = 99
    res = validate_question(question=q, policy=ValidationPolicy(enforce_grounding=False))
    assert res.status == ValidationStatus.INVALID
    assert any(i.code == IssueCode.ERR_OPTIONS_INDICES_NON_SEQUENTIAL for i in res.issues)


# ==============================================================================
# 6. Malformed Structure & Image Requirements
# ==============================================================================

def test_malformed_structure_non_dict():
    """Passing a non-dict payload must produce ERR_MALFORMED_STRUCTURE."""
    res = validate_question("This is not JSON")
    assert res.status == ValidationStatus.INVALID
    assert any(i.code == IssueCode.ERR_MALFORMED_STRUCTURE for i in res.issues)


def test_empty_prompt_rejected(canonical_questions):
    """Empty or whitespace-only promptMd must produce ERR_PROMPT_EMPTY."""
    q = copy.deepcopy(canonical_questions["MULTIPLE_CHOICE_SINGLE"])
    q["promptMd"] = "   "
    res = validate_question(question=q, policy=ValidationPolicy(enforce_grounding=False))
    assert res.status == ValidationStatus.INVALID
    assert any(i.code == IssueCode.ERR_PROMPT_EMPTY for i in res.issues)


def test_diagram_and_map_require_image_url(canonical_questions):
    """DIAGRAM_LABEL and MAP_LABEL require a non-empty imageUrl."""
    for img_type in ("DIAGRAM_LABEL", "MAP_LABEL"):
        q = copy.deepcopy(canonical_questions[img_type])
        q["imageUrl"] = ""
        res = validate_question(question=q, policy=ValidationPolicy(enforce_grounding=False))
        assert res.status == ValidationStatus.INVALID
        assert any(i.code == IssueCode.ERR_IMAGE_URL_MISSING for i in res.issues)


# ==============================================================================
# 7. Non-English / Vietnamese Language Screening (All 19 Types)
# ==============================================================================

@pytest.mark.parametrize("qtype", sorted(list(ALL_19_TYPES)))
def test_vietnamese_text_rejected_across_all_types(canonical_questions, qtype):
    """Injecting Vietnamese text into candidate prompt must produce ERR_VIETNAMESE_TEXT."""
    q = copy.deepcopy(canonical_questions[qtype])
    q["promptMd"] = q["promptMd"] + "\n\nĐoạn văn này giải thích chi tiết về lịch sử."
    res = validate_question(question=q, policy=ValidationPolicy(enforce_grounding=False))
    assert res.status == ValidationStatus.INVALID
    assert any(i.code == IssueCode.ERR_VIETNAMESE_TEXT for i in res.issues)


# ==============================================================================
# 8. Placeholder Answer Rejection (All Families)
# ==============================================================================

@pytest.mark.parametrize("placeholder", ["Item 1", "Paragraph 1", "Option A", "TBD", "N/A", "placeholder"])
def test_placeholders_rejected_in_completion_and_matching(canonical_questions, placeholder):
    """Generic non-assessable placeholders must produce ERR_PLACEHOLDER_ANSWER."""
    # 1. Completion
    q_comp = copy.deepcopy(canonical_questions["SUMMARY_COMPLETION"])
    first_b = list(q_comp["blankAcceptTexts"].keys())[0]
    q_comp["blankAcceptTexts"][first_b] = [placeholder]
    res_comp = validate_question(q_comp, policy=ValidationPolicy(enforce_grounding=False))
    assert res_comp.status == ValidationStatus.INVALID
    assert any(i.code == IssueCode.ERR_PLACEHOLDER_ANSWER for i in res_comp.issues)

    # 2. Matching
    q_match = copy.deepcopy(canonical_questions["MATCHING_HEADING"])
    first_t = list(q_match["matchPairs"].keys())[0]
    q_match["matchPairs"][first_t] = [placeholder, "Heading text"]
    res_match = validate_question(q_match, policy=ValidationPolicy(enforce_grounding=False))
    assert res_match.status == ValidationStatus.INVALID
    assert any(i.code == IssueCode.ERR_PLACEHOLDER_ANSWER for i in res_match.issues)


# ==============================================================================
# 9. Word Limit Enforcement
# ==============================================================================

def test_word_limit_exceeded_in_completion(canonical_questions):
    """Completion answers with > 3 words must produce ERR_WORD_LIMIT_EXCEEDED."""
    q = copy.deepcopy(canonical_questions["SENTENCE_COMPLETION"])
    first_b = list(q["blankAcceptTexts"].keys())[0]
    q["blankAcceptTexts"][first_b] = ["more than three words answer text here"]
    res = validate_question(q, policy=ValidationPolicy(enforce_grounding=False))
    assert res.status == ValidationStatus.INVALID
    assert any(i.code == IssueCode.ERR_WORD_LIMIT_EXCEEDED for i in res.issues)


# ==============================================================================
# 10. Passage Grounding Verification
# ==============================================================================

def test_grounded_completion_answer_passes(canonical_questions):
    """A completion question with an answer appearing verbatim in passage passes grounding."""
    q = copy.deepcopy(canonical_questions["SENTENCE_COMPLETION"])
    q["blankAcceptTexts"] = {"1": ["mulberry"]}
    q["promptMd"] = "Cai Lun used ______ to make sheets of paper. [1]"
    res = validate_question(q, passage=SAMPLE_PASSAGE, policy=ValidationPolicy(enforce_grounding=True))
    assert res.status == ValidationStatus.VALID
    assert not any(i.code == IssueCode.ERR_UNGROUNDED_ANSWER for i in res.issues)


def test_ungrounded_completion_answer_fails(canonical_questions):
    """A completion question whose answer does not appear in the passage produces ERR_UNGROUNDED_ANSWER."""
    q = copy.deepcopy(canonical_questions["SENTENCE_COMPLETION"])
    q["blankAcceptTexts"] = {"1": ["quantum computer"]}
    q["promptMd"] = "The researchers operated a ______ in China. [1]"
    res = validate_question(q, passage=SAMPLE_PASSAGE, policy=ValidationPolicy(enforce_grounding=True))
    assert res.status == ValidationStatus.INVALID
    assert any(i.code == IssueCode.ERR_UNGROUNDED_ANSWER for i in res.issues)


# ==============================================================================
# 11. Scored-Item Granularity & Grading Compatibility
# ==============================================================================

def test_matching_scored_items_granularity(canonical_questions):
    """MatchingHeading with 5 targets must yield exactly 5 individual ScoredItemValidation records."""
    q = canonical_questions["MATCHING_HEADING"]
    res = validate_question(q, policy=ValidationPolicy(enforce_grounding=False))
    assert res.status == ValidationStatus.VALID
    assert len(res.scored_items) == 5
    for idx, item in enumerate(res.scored_items, start=1):
        assert item.item_index == idx
        assert item.is_valid
        assert item.accepted_answers is not None


# ==============================================================================
# 12. Targeted MiniMax Semantic Verification (Layered Policy)
# ==============================================================================

@pytest.mark.asyncio
async def test_minimax_semantic_verification_supported(canonical_questions):
    """When MiniMax confirms answer is SUPPORTED, status remains VALID with cost receipt."""
    q = copy.deepcopy(canonical_questions["MULTIPLE_CHOICE_SINGLE"])

    mock_gateway = MagicMock()
    mock_resp = ProviderResponse(
        operation_id="op_test_1",
        provider_name="minimax",
        model_name="abab6.5s-chat",
        raw_text=json.dumps({
            "is_supported": True,
            "verdict": "SUPPORTED",
            "confidence": 0.98,
            "evidence_quote": "He created sheets of paper using mulberry...",
            "explanation": "Option A is directly confirmed by the text.",
        }),
        usage=UsageReport(prompt_tokens=250, completion_tokens=40, total_tokens=290),
    )
    mock_gateway.execute = AsyncMock(return_value=mock_resp)

    policy = ValidationPolicy(enforce_grounding=True, allow_llm_eval=True)
    res = await validate_question_async(
        question=q,
        passage=SAMPLE_PASSAGE,
        policy=policy,
        gateway=mock_gateway,
    )

    assert res.status == ValidationStatus.VALID
    assert res.cost_receipt is not None
    assert res.cost_receipt["provider"] == "minimax"
    assert res.cost_receipt["tokens_consumed"] == 290
    assert res.evidence_summary["minimax_verdict"] == "SUPPORTED"
    mock_gateway.execute.assert_called_once()


@pytest.mark.asyncio
async def test_minimax_semantic_verification_contradicted(canonical_questions):
    """When MiniMax indicates answer is CONTRADICTED, status becomes INVALID with ERR_CONTRADICTED_ANSWER."""
    q = copy.deepcopy(canonical_questions["TRUE_FALSE_NOT_GIVEN"])

    mock_gateway = MagicMock()
    mock_resp = ProviderResponse(
        operation_id="op_test_2",
        provider_name="minimax",
        model_name="abab6.5s-chat",
        raw_text=json.dumps({
            "is_supported": False,
            "verdict": "CONTRADICTED",
            "confidence": 0.95,
            "evidence_quote": "Europe received paper in the twelfth century, not the eighth.",
            "explanation": "The text contradicts the claim.",
        }),
        usage=UsageReport(prompt_tokens=260, completion_tokens=45, total_tokens=305),
    )
    mock_gateway.execute = AsyncMock(return_value=mock_resp)

    initial_res = validate_question(q, policy=ValidationPolicy(enforce_grounding=False))
    sem_res = await verify_semantics_with_minimax(
        question=q,
        passage=SAMPLE_PASSAGE,
        result=initial_res,
        policy=ValidationPolicy(),
        gateway=mock_gateway,
    )

    assert sem_res.status == ValidationStatus.INVALID
    assert any(i.code == IssueCode.ERR_CONTRADICTED_ANSWER for i in sem_res.issues)
    assert sem_res.evidence_summary["minimax_verdict"] == "CONTRADICTED"


@pytest.mark.asyncio
async def test_minimax_semantic_verification_ambiguous_yields_needs_review(canonical_questions):
    """When MiniMax indicates answer is AMBIGUOUS, status transitions to NEEDS_REVIEW."""
    q = copy.deepcopy(canonical_questions["TRUE_FALSE_NOT_GIVEN"])

    mock_gateway = MagicMock()
    mock_resp = ProviderResponse(
        operation_id="op_test_3",
        provider_name="minimax",
        model_name="abab6.5s-chat",
        raw_text=json.dumps({
            "is_supported": False,
            "verdict": "AMBIGUOUS",
            "confidence": 0.50,
            "evidence_quote": "",
            "explanation": "The passage details are insufficient to deduce writer stance unambiguously.",
        }),
        usage=UsageReport(prompt_tokens=240, completion_tokens=35, total_tokens=275),
    )
    mock_gateway.execute = AsyncMock(return_value=mock_resp)

    initial_res = validate_question(q, policy=ValidationPolicy(enforce_grounding=False))
    sem_res = await verify_semantics_with_minimax(
        question=q,
        passage=SAMPLE_PASSAGE,
        result=initial_res,
        policy=ValidationPolicy(),
        gateway=mock_gateway,
    )

    assert sem_res.status == ValidationStatus.NEEDS_REVIEW
    assert any(i.code == IssueCode.ERR_AMBIGUOUS_ANSWER for i in sem_res.issues)
