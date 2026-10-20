"""Tests verifying Phase 3 Semantic Layer Hardening.

Covers:
1. Dynamic provider & model identity extraction from actual gateway receipts.
2. Strict separation of mocked receipts vs real API receipts.
3. Verification of returned evidence quotes against the source passage.
4. Strict validation of verdict schema and boolean types.
5. Passage truncation detection and disclosure.
6. Fail-closed to NEEDS_REVIEW on low confidence (< 0.75) or ambiguous model verdict.
7. Explicit record that model judgment is machine-only, never certified human gold.
"""
import copy
import json
from unittest.mock import AsyncMock, MagicMock
import pytest

from app.providers.models import ProviderResponse, UsageReport
from app.validation.models import (
    IssueCode,
    ValidationPolicy,
    ValidationResult,
    ValidationStatus,
)
from app.validation.semantic import verify_semantics_with_minimax

SAMPLE_PASSAGE = (
    "The invention of paper is traditionally attributed to Cai Lun, an official of the Chinese Han dynasty court "
    "in 105 AD. He created sheets of paper using mulberry and other bast fibres along with fishnets, old rags, "
    "and hemp waste. Before this innovation, writing surfaces included bamboo slips and silk in China, while other "
    "ancient cultures relied on parchment made from animal skins or papyrus made from reeds along the Nile. "
    "Paper provided a lightweight, economical alternative that transformed literacy, governance, and scholarship. "
    "The manufacturing technique spread slowly along the Silk Road, reaching Samarkand in 751 AD after the Battle "
    "of Talas, and eventually arriving in Europe during the twelfth century."
)

SAMPLE_QUESTION = {
    "type": "MULTIPLE_CHOICE_SINGLE",
    "skill": "READING",
    "difficulty": 3,
    "promptMd": "What raw material did Cai Lun use in paper manufacturing?",
    "options": [
        {"idx": 1, "contentMd": "A. Mulberry and bast fibres", "isCorrect": True},
        {"idx": 2, "contentMd": "B. Animal parchment", "isCorrect": False},
        {"idx": 3, "contentMd": "C. Synthetic nylon", "isCorrect": False},
        {"idx": 4, "contentMd": "D. Reeds along the Nile", "isCorrect": False},
    ],
}


@pytest.mark.asyncio
async def test_receipt_identities_dynamically_extracted_from_gateway():
    """Receipt provider and model must come directly from gateway response, not hardcoded."""
    mock_gateway = MagicMock()
    mock_resp = ProviderResponse(
        operation_id="op_dynamic_test",
        provider_name="minimax-cluster-east",
        model_name="MiniMax-Text-01-v2",
        raw_text=json.dumps({
            "is_supported": True,
            "verdict": "SUPPORTED",
            "confidence": 0.96,
            "evidence_quote": "He created sheets of paper using mulberry and other bast fibres",
            "explanation": "Directly confirmed by the passage.",
        }),
        usage=UsageReport(prompt_tokens=300, completion_tokens=50, total_tokens=350),
    )
    mock_gateway.execute = AsyncMock(return_value=mock_resp)

    initial_res = ValidationResult(status=ValidationStatus.VALID, question_type="MULTIPLE_CHOICE_SINGLE", structural_valid=True)
    res = await verify_semantics_with_minimax(
        question=SAMPLE_QUESTION,
        passage=SAMPLE_PASSAGE,
        result=initial_res,
        policy=ValidationPolicy(),
        gateway=mock_gateway,
    )

    assert res.cost_receipt is not None
    assert res.cost_receipt["provider"] == "minimax-cluster-east"
    assert res.cost_receipt["model"] == "MiniMax-Text-01-v2"
    assert res.cost_receipt["tokens_consumed"] == 350
    assert res.cost_receipt["is_mock"] is True
    assert res.cost_receipt["receipt_kind"] == "MOCKED_TEST"
    assert res.cost_receipt["human_certified"] is False


@pytest.mark.asyncio
async def test_hallucinated_evidence_quote_fails_closed_to_needs_review():
    """When the model returns an evidence quote that does not appear in the passage, return NEEDS_REVIEW."""
    mock_gateway = MagicMock()
    mock_resp = ProviderResponse(
        operation_id="op_quote_test",
        provider_name="minimax",
        model_name="MiniMax-Text-01",
        raw_text=json.dumps({
            "is_supported": True,
            "verdict": "SUPPORTED",
            "confidence": 0.99,
            "evidence_quote": "Cai Lun manufactured paper using quantum silicon processors in Silicon Valley.",
            "explanation": "Supported according to my hallucinated memory.",
        }),
        usage=UsageReport(prompt_tokens=200, completion_tokens=40, total_tokens=240),
    )
    mock_gateway.execute = AsyncMock(return_value=mock_resp)

    initial_res = ValidationResult(status=ValidationStatus.VALID, question_type="MULTIPLE_CHOICE_SINGLE", structural_valid=True)
    res = await verify_semantics_with_minimax(
        question=SAMPLE_QUESTION,
        passage=SAMPLE_PASSAGE,
        result=initial_res,
        policy=ValidationPolicy(),
        gateway=mock_gateway,
    )

    assert res.status == ValidationStatus.NEEDS_REVIEW
    assert res.evidence_summary.get("quote_grounding_verified") is False
    assert any(i.code == IssueCode.ERR_UNGROUNDED_ANSWER for i in res.issues)


@pytest.mark.asyncio
async def test_strict_boolean_type_validation_rejects_string_boolean():
    """String 'true' or 'false' for is_supported must be rejected as invalid schema, returning NEEDS_REVIEW."""
    mock_gateway = MagicMock()
    mock_resp = ProviderResponse(
        operation_id="op_bool_test",
        provider_name="minimax",
        model_name="MiniMax-Text-01",
        raw_text=json.dumps({
            "is_supported": "false",  # String instead of boolean!
            "verdict": "SUPPORTED",
            "confidence": 0.90,
            "evidence_quote": "He created sheets of paper using mulberry",
            "explanation": "Invalid boolean wire format.",
        }),
        usage=UsageReport(prompt_tokens=200, completion_tokens=30, total_tokens=230),
    )
    mock_gateway.execute = AsyncMock(return_value=mock_resp)

    initial_res = ValidationResult(status=ValidationStatus.VALID, question_type="MULTIPLE_CHOICE_SINGLE", structural_valid=True)
    res = await verify_semantics_with_minimax(
        question=SAMPLE_QUESTION,
        passage=SAMPLE_PASSAGE,
        result=initial_res,
        policy=ValidationPolicy(),
        gateway=mock_gateway,
    )

    assert res.status == ValidationStatus.NEEDS_REVIEW
    assert any("non-boolean is_supported" in r for r in res.reasons)


@pytest.mark.asyncio
async def test_low_confidence_fails_closed_to_needs_review():
    """Model confidence < 0.75 must fail closed to NEEDS_REVIEW rather than confirming VALID."""
    mock_gateway = MagicMock()
    mock_resp = ProviderResponse(
        operation_id="op_conf_test",
        provider_name="minimax",
        model_name="MiniMax-Text-01",
        raw_text=json.dumps({
            "is_supported": True,
            "verdict": "SUPPORTED",
            "confidence": 0.60,  # Below 0.75 threshold
            "evidence_quote": "He created sheets of paper using mulberry and other bast fibres",
            "explanation": "Weak confidence in writer stance.",
        }),
        usage=UsageReport(prompt_tokens=200, completion_tokens=30, total_tokens=230),
    )
    mock_gateway.execute = AsyncMock(return_value=mock_resp)

    initial_res = ValidationResult(status=ValidationStatus.VALID, question_type="MULTIPLE_CHOICE_SINGLE", structural_valid=True)
    res = await verify_semantics_with_minimax(
        question=SAMPLE_QUESTION,
        passage=SAMPLE_PASSAGE,
        result=initial_res,
        policy=ValidationPolicy(),
        gateway=mock_gateway,
    )

    assert res.status == ValidationStatus.NEEDS_REVIEW
    assert any(i.code == IssueCode.ERR_AMBIGUOUS_ANSWER for i in res.issues)


@pytest.mark.asyncio
async def test_truncation_disclosure_on_long_passage():
    """Passages exceeding MAX_PASSAGE_WINDOW_CHARS must disclose truncation explicitly in evidence_summary."""
    long_passage = SAMPLE_PASSAGE * 30  # ~18,000 characters
    assert len(long_passage) > 10_000

    mock_gateway = MagicMock()
    mock_resp = ProviderResponse(
        operation_id="op_trunc_test",
        provider_name="minimax",
        model_name="MiniMax-Text-01",
        raw_text=json.dumps({
            "is_supported": True,
            "verdict": "SUPPORTED",
            "confidence": 0.95,
            "evidence_quote": "The invention of paper is traditionally attributed to Cai Lun",
            "explanation": "Confirmed in first section.",
        }),
        usage=UsageReport(prompt_tokens=1500, completion_tokens=40, total_tokens=1540),
    )
    mock_gateway.execute = AsyncMock(return_value=mock_resp)

    initial_res = ValidationResult(status=ValidationStatus.VALID, question_type="MULTIPLE_CHOICE_SINGLE", structural_valid=True)
    res = await verify_semantics_with_minimax(
        question=SAMPLE_QUESTION,
        passage=long_passage,
        result=initial_res,
        policy=ValidationPolicy(),
        gateway=mock_gateway,
    )

    assert res.evidence_summary.get("passage_truncated") is True
    assert res.evidence_summary.get("passage_original_chars") == len(long_passage)
    assert res.evidence_summary.get("passage_evaluated_chars") == 10_000
    assert any("truncated" in i.message.lower() for i in res.issues)
