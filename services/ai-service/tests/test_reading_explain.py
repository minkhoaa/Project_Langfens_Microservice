import pytest
from unittest.mock import AsyncMock, patch

from app.schemas.reading import ReadingExplainRequest

@pytest.mark.asyncio
async def test_explain_item_missing_passage_returns_422():
    from fastapi import HTTPException
    from app.services.reading_feedback_service import explain_item

    req = ReadingExplainRequest(
        item_id="x",
        passage_text="",
        question="Q",
        question_type="MCQ",
        options=["A", "B"],
        user_answer="A",
        correct_answer="B",
    )
    with pytest.raises(HTTPException) as exc:
        await explain_item(req)
    assert exc.value.status_code == 422

@pytest.mark.asyncio
async def test_explain_item_mcq_builds_envelope():
    req = ReadingExplainRequest(
        item_id="r1",
        passage_text="The library opens at nine.",
        question="When does it open?",
        question_type="MCQ",
        options=["A) 7am", "B) 9am"],
        user_answer="A) 7am",
        correct_answer="B) 9am",
    )
    llm_result = {
        "criterion_band": 6.0,
        "explanation": "The passage says the library opens at nine.",
        "passage_quote": "The library opens at nine.",
        "distractor_analysis": "A) 7am is wrong: the passage says nine.",
        "suggestions": ["Re-read the first sentence of paragraph 1."],
    }
    with patch(
        "app.services.reading_feedback_service.llm_service.generate",
        new=AsyncMock(return_value=llm_result),
    ):
        from app.services.reading_feedback_service import explain_item

        env = await explain_item(req)

    assert env.domain == "reading"
    assert env.item_id == "r1"
    assert env.criteria[0].name == "comprehension"
    assert env.criteria[0].band == 6.0
    assert len(env.evidence) == 1
    assert env.evidence[0].source == "passage:inline"
    assert "library opens at nine" in env.evidence[0].text
    assert len(env.suggestions) == 1

@pytest.mark.asyncio
async def test_explain_item_short_answer_handles_no_options():
    req = ReadingExplainRequest(
        item_id="r2",
        passage_text="Membership was launched in 2010.",
        question="When was membership launched?",
        question_type="SHORT_ANSWER",
        options=[],
        user_answer="2020",
        correct_answer="2010",
    )
    llm_result = {
        "criterion_band": 5.0,
        "explanation": "The user misread the year.",
        "passage_quote": "Membership was launched in 2010.",
        "distractor_analysis": "",
        "suggestions": ["Read numbers carefully."],
    }
    with patch(
        "app.services.reading_feedback_service.llm_service.generate",
        new=AsyncMock(return_value=llm_result),
    ):
        from app.services.reading_feedback_service import explain_item

        env = await explain_item(req)

    assert env.domain == "reading"
    assert env.criteria[0].band == 5.0
