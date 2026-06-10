import pytest
from unittest.mock import AsyncMock, patch

from app.schemas.listening import ListeningExplainRequest

@pytest.mark.asyncio
async def test_explain_item_missing_transcript_returns_422():
    from fastapi import HTTPException
    from app.services.listening_feedback_service import explain_item

    req = ListeningExplainRequest(
        item_id="x",
        transcript="",
        question="Q",
        question_type="MCQ",
        options=["A", "B"],
        user_answer="A",
        correct_answer="B",
        section=1,
    )
    with pytest.raises(HTTPException) as exc:
        await explain_item(req)
    assert exc.value.status_code == 422

@pytest.mark.asyncio
async def test_explain_item_works_without_corpus_rag():
    req = ListeningExplainRequest(
        item_id="l1",
        transcript="Librarian: The library closes at six.",
        question="When does it close?",
        question_type="MCQ",
        options=["A) 5pm", "B) 6pm"],
        user_answer="A) 5pm",
        correct_answer="B) 6pm",
        section=1,
    )
    llm_result = {
        "criterion_band": 6.5,
        "explanation": "Speaker says 'closes at six'.",
        "transcript_quote": "The library closes at six.",
        "skill_tags": ["detail listening"],
        "suggestions": ["Listen for numbers."],
    }
    with patch(
        "app.services.listening_feedback_service.search_service.search",
        new=AsyncMock(return_value=[]),
    ), patch(
        "app.services.listening_feedback_service.llm_service.generate",
        new=AsyncMock(return_value=llm_result),
    ), patch(
        "app.services.listening_feedback_service.settings"
    ) as mock_settings:
        mock_settings.qdrant_collection_listening = "listening_samples"
        from app.services.listening_feedback_service import explain_item

        env = await explain_item(req)

    assert env.domain == "listening"
    assert env.criteria[0].name == "comprehension"
    assert env.criteria[0].band == 6.5
    assert env.evidence[0].source == "transcript:inline"

@pytest.mark.asyncio
async def test_explain_item_includes_corpus_evidence_when_present():
    req = ListeningExplainRequest(
        item_id="l2",
        transcript="Speaker: We open at ten.",
        question="Opening time?",
        question_type="MCQ",
        options=["A) 8", "B) 10"],
        user_answer="A) 8",
        correct_answer="B) 10",
        section=2,
    )
    llm_result = {
        "criterion_band": 7.0,
        "explanation": "Ten.",
        "transcript_quote": "We open at ten.",
        "skill_tags": ["detail"],
        "suggestions": [],
    }
    from app.schemas import SearchResult
    fake_corpus = [SearchResult(
        id="ls-corpus-1",
        text="Section 2 typically tests detail and matching.",
        score=0.9,
        metadata={"section": "2", "topic": "library"},
    )]
    with patch(
        "app.services.listening_feedback_service.search_service.search",
        new=AsyncMock(return_value=fake_corpus),
    ), patch(
        "app.services.listening_feedback_service.llm_service.generate",
        new=AsyncMock(return_value=llm_result),
    ), patch(
        "app.services.listening_feedback_service.settings"
    ) as mock_settings:
        mock_settings.qdrant_collection_listening = "listening_samples"
        from app.services.listening_feedback_service import explain_item

        env = await explain_item(req)

    sources = {e.source for e in env.evidence}
    assert "transcript:inline" in sources
    assert "listening_samples" in sources
