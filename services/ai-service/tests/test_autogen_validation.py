"""Comprehensive automated test suite for unified autogen_validation service.

Verifies canonical schema compliance, answer-key integrity, option cardinality,
word limits, placeholder rejection, and English language screening across all
19 supported IELTS question types.
"""
from __future__ import annotations

import copy
import json
from pathlib import Path
from typing import Any
from unittest.mock import AsyncMock, patch

import pytest
from httpx import ASGITransport, AsyncClient
from fastapi import FastAPI
from app.routers.autogen import router as autogen_router

app = FastAPI()
app.include_router(autogen_router, prefix="/api")
from app.prompts.autogen_data import JSON_SHAPES

from app.services.autogen_validation import (
    ALL_SUPPORTED_TYPES,
    validate_english_text,
    validate_question,
)



@pytest.fixture
def canonical_examples() -> dict[str, dict[str, Any]]:
    """Load canonical question shape examples for each supported type."""
    return {
        qtype: json.loads(JSON_SHAPES[qtype])
        for qtype in ALL_SUPPORTED_TYPES
        if qtype in JSON_SHAPES
    }


# ==============================================================================
# 1. Valid Canonical Examples Test
# ==============================================================================

def test_all_canonical_examples_pass_validation(canonical_examples):
    """Every canonical example from autogen_data.JSON_SHAPES must pass validation."""
    for qtype, example in canonical_examples.items():
        q = copy.deepcopy(example)
        skill = q.get("skill", "READING")
        difficulty = q.get("difficulty", 3)
        issues = validate_question(q, expected_type=qtype, expected_skill=skill, expected_difficulty=difficulty)
        assert issues == [], f"Canonical example for {qtype} failed validation: {issues}"


# ==============================================================================
# 2. English Language Integrity Tests
# ==============================================================================

@pytest.mark.parametrize(
    "vn_text,field",
    [
        ("Đọc đoạn văn sau và trả lời câu hỏi", "promptMd"),
        ("Giải thích chi tiết cho đáp án đúng", "explanationMd"),
        ("A. Không có thông tin trong bài", "options[0].contentMd"),
        ("Đoạn văn 1", "matchPairs['1'][1]"),
    ],
)
def test_vietnamese_text_is_rejected(vn_text, field):
    """Any Vietnamese diacritic or phrasing in candidate text must produce validation error."""
    issues = validate_english_text(vn_text, field)
    assert len(issues) > 0
    assert any("Vietnamese" in issue for issue in issues)


def test_mcq_with_vietnamese_content_is_rejected(canonical_examples):
    q = copy.deepcopy(canonical_examples["MULTIPLE_CHOICE_SINGLE"])
    q["promptMd"] = "Theo bài đọc, Cai Lun đã phát minh ra giấy khi nào?"
    issues = validate_question(q, expected_type="MULTIPLE_CHOICE_SINGLE", expected_skill="READING", expected_difficulty=q["difficulty"])
    assert any("Vietnamese" in issue for issue in issues)


def test_completion_with_vietnamese_explanation_is_rejected(canonical_examples):
    q = copy.deepcopy(canonical_examples["SUMMARY_COMPLETION"])
    q["explanationMd"] = "Đáp án đúng là plant fibres vì đoạn 2 có nhắc đến."
    issues = validate_question(q, expected_type="SUMMARY_COMPLETION", expected_skill="READING", expected_difficulty=q["difficulty"])
    assert any("Vietnamese" in issue for issue in issues)


# ==============================================================================
# 3. Answer Key Integrity & Placeholder Rejection Tests
# ==============================================================================

@pytest.mark.parametrize("placeholder", ["Item 1", "Paragraph 1", "Option A", "TBD", "N/A", "placeholder"])
def test_matching_heading_rejects_placeholder_answers(canonical_examples, placeholder):
    q = copy.deepcopy(canonical_examples["MATCHING_HEADING"])
    first_key = list(q["matchPairs"].keys())[0]
    q["matchPairs"][first_key] = [placeholder, "Heading text"]
    issues = validate_question(q, expected_type="MATCHING_HEADING", expected_skill="READING", expected_difficulty=q["difficulty"])
    assert any("placeholder" in issue.lower() or "not exist in options" in issue.lower() for issue in issues)


@pytest.mark.parametrize("placeholder", ["Item 1", "TBD", "N/A", "placeholder"])
def test_completion_rejects_placeholder_answers(canonical_examples, placeholder):
    q = copy.deepcopy(canonical_examples["SUMMARY_COMPLETION"])
    first_blank = list(q["blankAcceptTexts"].keys())[0]
    q["blankAcceptTexts"][first_blank] = [placeholder]
    issues = validate_question(q, expected_type="SUMMARY_COMPLETION", expected_skill="READING", expected_difficulty=q["difficulty"])
    assert any("placeholder" in issue.lower() for issue in issues)


@pytest.mark.parametrize("placeholder", ["Item 1", "TBD", "N/A", "placeholder"])
def test_short_answer_rejects_placeholder_answers(canonical_examples, placeholder):
    q = copy.deepcopy(canonical_examples["SHORT_ANSWER"])
    q["shortAnswerAcceptTexts"] = [placeholder]
    issues = validate_question(q, expected_type="SHORT_ANSWER", expected_skill="READING", expected_difficulty=q["difficulty"])
    assert any("placeholder" in issue.lower() for issue in issues)


# ==============================================================================
# 4. Mutually Exclusive Answer Family Tests
# ==============================================================================

def test_mcq_with_blanks_is_rejected(canonical_examples):
    q = copy.deepcopy(canonical_examples["MULTIPLE_CHOICE_SINGLE"])
    q["blankAcceptTexts"] = {"1": ["text"]}
    issues = validate_question(q, expected_type="MULTIPLE_CHOICE_SINGLE", expected_skill="READING", expected_difficulty=q["difficulty"])
    assert any("forbidden answer-family field 'blankAcceptTexts'" in issue for issue in issues)


def test_completion_with_options_is_rejected(canonical_examples):
    q = copy.deepcopy(canonical_examples["SUMMARY_COMPLETION"])
    q["options"] = [{"idx": 1, "contentMd": "Option A", "isCorrect": True}]
    issues = validate_question(q, expected_type="SUMMARY_COMPLETION", expected_skill="READING", expected_difficulty=q["difficulty"])
    assert any("options array must not be present" in issue for issue in issues)


def test_matching_with_order_corrects_is_rejected(canonical_examples):
    q = copy.deepcopy(canonical_examples["MATCHING_HEADING"])
    q["orderCorrects"] = ["step-a", "step-b"]
    issues = validate_question(q, expected_type="MATCHING_HEADING", expected_skill="READING", expected_difficulty=q["difficulty"])
    assert any("forbidden answer-family field 'orderCorrects'" in issue for issue in issues)


# ==============================================================================
# 5. Choice Cardinality Tests
# ==============================================================================

def test_single_choice_with_multiple_correct_is_rejected(canonical_examples):
    q = copy.deepcopy(canonical_examples["MULTIPLE_CHOICE_SINGLE"])
    q["options"][0]["isCorrect"] = True
    q["options"][1]["isCorrect"] = True
    issues = validate_question(q, expected_type="MULTIPLE_CHOICE_SINGLE", expected_skill="READING", expected_difficulty=q["difficulty"])
    assert any("requires exactly 1 correct option" in issue for issue in issues)


def test_single_choice_with_zero_correct_is_rejected(canonical_examples):
    q = copy.deepcopy(canonical_examples["MULTIPLE_CHOICE_SINGLE"])
    for opt in q["options"]:
        opt["isCorrect"] = False
    issues = validate_question(q, expected_type="MULTIPLE_CHOICE_SINGLE", expected_skill="READING", expected_difficulty=q["difficulty"])
    assert any("requires exactly 1 correct option, got 0" in issue for issue in issues)


def test_multi_choice_with_only_one_correct_is_rejected(canonical_examples):
    q = copy.deepcopy(canonical_examples["MULTIPLE_CHOICE_MULTIPLE"])
    true_count = 0
    for opt in q["options"]:
        if true_count >= 1:
            opt["isCorrect"] = False
        elif opt["isCorrect"]:
            true_count += 1
    issues = validate_question(q, expected_type="MULTIPLE_CHOICE_MULTIPLE", expected_skill="READING", expected_difficulty=q["difficulty"])
    assert any("requires at least 2 correct options" in issue for issue in issues)


def test_tfng_with_wrong_option_count_is_rejected(canonical_examples):
    q = copy.deepcopy(canonical_examples["TRUE_FALSE_NOT_GIVEN"])
    q["options"] = q["options"][:2]
    issues = validate_question(q, expected_type="TRUE_FALSE_NOT_GIVEN", expected_skill="READING", expected_difficulty=q["difficulty"])
    assert any("requires exactly 3 options" in issue for issue in issues)


# ==============================================================================
# 6. Word Limit Tests (IELTS 3-Word Rule)
# ==============================================================================

def test_completion_rejects_answer_exceeding_three_words(canonical_examples):
    q = copy.deepcopy(canonical_examples["SUMMARY_COMPLETION"])
    first_blank = list(q["blankAcceptTexts"].keys())[0]
    q["blankAcceptTexts"][first_blank] = ["this is way too many words for ielts completion"]
    issues = validate_question(q, expected_type="SUMMARY_COMPLETION", expected_skill="READING", expected_difficulty=q["difficulty"])
    assert any("exceeds 3 words" in issue for issue in issues)


def test_short_answer_rejects_answer_exceeding_three_words(canonical_examples):
    q = copy.deepcopy(canonical_examples["SHORT_ANSWER"])
    q["shortAnswerAcceptTexts"] = ["more than three words answer here"]
    issues = validate_question(q, expected_type="SHORT_ANSWER", expected_skill="READING", expected_difficulty=q["difficulty"])
    assert any("exceeds 3 words" in issue for issue in issues)


def test_completion_missing_bracket_marker_is_rejected(canonical_examples):
    q = copy.deepcopy(canonical_examples["SUMMARY_COMPLETION"])
    first_blank = list(q["blankAcceptTexts"].keys())[0]
    q["promptMd"] = q["promptMd"].replace(f"[{first_blank}]", "")
    issues = validate_question(q, expected_type="SUMMARY_COMPLETION", expected_skill="READING", expected_difficulty=q["difficulty"])
    assert any(f"missing canonical marker [{first_blank}]" in issue for issue in issues)


# ==============================================================================
# 7. Router Boundary Validation Gate Tests
# ==============================================================================

@pytest.mark.asyncio
async def test_autogen_router_returns_422_when_validation_fails():
    invalid_q = {
        "type": "MULTIPLE_CHOICE_SINGLE",
        "skill": "READING",
        "difficulty": 3,
        "promptMd": "Where was paper invented?",
        "options": [
            {"idx": 1, "contentMd": "A. China", "isCorrect": False},
            {"idx": 2, "contentMd": "B. Egypt", "isCorrect": False},
        ],
    }
    with patch("app.routers.autogen.groq_generate", new_callable=AsyncMock) as mock_gen:
        mock_gen.return_value = {"questions": [invalid_q]}
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
            resp = await client.post(
                "/api/v1/autogen/questions",
                json={
                    "type": "MULTIPLE_CHOICE_SINGLE",
                    "skill": "READING",
                    "passage": "Paper was invented in China.",
                    "count": 1,
                    "difficulty": 3,
                },
            )
        assert resp.status_code == 422
        data = resp.json()
        assert "validation_errors" in str(data) or "failures" in str(data)


@pytest.mark.asyncio
async def test_autogen_router_returns_200_when_validation_passes(canonical_examples):
    valid_q = copy.deepcopy(canonical_examples["MULTIPLE_CHOICE_SINGLE"])
    with patch("app.routers.autogen.groq_generate", new_callable=AsyncMock) as mock_gen:
        mock_gen.return_value = {"questions": [valid_q]}
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
            resp = await client.post(
                "/api/v1/autogen/questions",
                json={
                    "type": "MULTIPLE_CHOICE_SINGLE",
                    "skill": "READING",
                    "passage": "Paper was invented in China using plant fibres.",
                    "count": 1,
                    "difficulty": valid_q["difficulty"],
                },
            )
        assert resp.status_code == 200
        data = resp.json()
        assert len(data["questions"]) == 1
        assert data["questions"][0]["type"] == "MULTIPLE_CHOICE_SINGLE"
