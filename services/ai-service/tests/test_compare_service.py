import warnings
warnings.filterwarnings("ignore")

import pytest
from unittest.mock import AsyncMock, patch
from app.schemas import CompareRequest, SearchResult


MOCK_SEARCH_RESULTS = [
    SearchResult(id="r1", text="Band 9 essay about education...", score=0.92, metadata={"band_overall": 9.0, "task_type": "TASK_2", "word_count": 280}),
    SearchResult(id="r2", text="Another Band 8.5 essay...", score=0.88, metadata={"band_overall": 8.5, "task_type": "TASK_2", "word_count": 300}),
    SearchResult(id="r3", text="Third reference essay...", score=0.85, metadata={"band_overall": 8.0, "task_type": "TASK_2", "word_count": 260}),
]

MOCK_LLM_RESULT = {
    "overall_analysis": "The student essay shows good structure but lacks vocabulary range.",
    "vocabulary_feedback": "Limited range of academic vocabulary.",
    "coherence_feedback": "Good paragraph structure.",
    "grammar_feedback": "Some tense errors detected.",
    "task_response_feedback": "Addresses the prompt adequately.",
    "sentence_comparisons": [
        {"original": "I think education is important.", "improved": "Education plays a pivotal role.", "explanation": "More sophisticated vocabulary.", "category": "vocabulary"}
    ],
}


@pytest.mark.asyncio
async def test_compare_essay_success():
    from app.services.compare_service import compare_essay
    req = CompareRequest(essay_text="A" * 100, topic="Discuss education", task_type="TASK_2")

    with patch("app.services.compare_service.search_service.search", new_callable=AsyncMock, return_value=MOCK_SEARCH_RESULTS), \
         patch("app.services.compare_service.gemini_service.generate", new_callable=AsyncMock, return_value=MOCK_LLM_RESULT):
        result = await compare_essay(req)

    assert result.overall_analysis == MOCK_LLM_RESULT["overall_analysis"]
    assert len(result.references) == 3
    assert result.references[0].band == 9.0
    assert len(result.sentence_comparisons) == 1


@pytest.mark.asyncio
async def test_compare_essay_no_references():
    from app.services.compare_service import compare_essay
    from fastapi import HTTPException
    req = CompareRequest(essay_text="A" * 100, topic="Rare topic", task_type="TASK_1")

    with patch("app.services.compare_service.search_service.search", new_callable=AsyncMock, return_value=[]):
        with pytest.raises(HTTPException) as exc:
            await compare_essay(req)
        assert exc.value.status_code == 422


@pytest.mark.asyncio
async def test_compare_essay_llm_parse_failure():
    from app.services.compare_service import compare_essay
    from langchain_core.exceptions import OutputParserException
    req = CompareRequest(essay_text="A" * 100, topic="Education topic", task_type="TASK_2")

    with patch("app.services.compare_service.search_service.search", new_callable=AsyncMock, return_value=MOCK_SEARCH_RESULTS), \
         patch("app.services.compare_service.gemini_service.generate", new_callable=AsyncMock, side_effect=OutputParserException("bad json")):
        result = await compare_essay(req)

    assert "LLM returned unparseable response" in result.overall_analysis
    assert result.sentence_comparisons == []
    assert len(result.references) == 3
