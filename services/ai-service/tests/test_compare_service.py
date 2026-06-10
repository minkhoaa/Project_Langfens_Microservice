import warnings
warnings.filterwarnings("ignore")

import pytest
from unittest.mock import AsyncMock, patch
from app.schemas import CompareRequest, ReassembledEssay


MOCK_REASSEMBLED_RESULTS = [
    ReassembledEssay(
        parent_id="parent-1",
        text="Band 9 essay about education...",
        score=0.92,
        metadata={"band_overall": 9.0, "task_type": "TASK_2", "word_count": 280},
        chunk_scores={"intro": 0.92, "body1": 0.90},
    ),
    ReassembledEssay(
        parent_id="parent-2",
        text="Another Band 8.5 essay...",
        score=0.88,
        metadata={"band_overall": 8.5, "task_type": "TASK_2", "word_count": 300},
        chunk_scores={"intro": 0.88, "body1": 0.85},
    ),
    ReassembledEssay(
        parent_id="parent-3",
        text="Third reference essay...",
        score=0.85,
        metadata={"band_overall": 8.0, "task_type": "TASK_2", "word_count": 260},
        chunk_scores={"intro": 0.85, "body1": 0.82},
    ),
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
async def test_search_with_fallback_uses_reassemble():
    from app.services.compare_service import _search_with_fallback

    mock_essays = [
        ReassembledEssay(
            parent_id="parent-1",
            text="Full reassembled essay about education...",
            score=0.9,
            metadata={"band_overall": 7.5, "task_type": "TASK_2"},
            chunk_scores={"intro": 0.9, "body1": 0.85},
        )
    ]

    with patch("app.services.compare_service.search_service.search_and_reassemble",
               new_callable=AsyncMock, return_value=mock_essays) as mock_search:
        results = await _search_with_fallback("education", 7.5, "TASK_2")

    assert len(results) == 1
    assert results[0].parent_id == "parent-1"
    assert "reassembled essay" in results[0].text
    mock_search.assert_called_once()


@pytest.mark.asyncio
async def test_compare_essay_success():
    from app.services.compare_service import compare_essay
    req = CompareRequest(
        essay_text="A" * 100,
        topic="Discuss education",
        task_type="TASK_2",
        student_band=6.5,
    )

    with patch("app.services.compare_service.search_service.search_and_reassemble", new_callable=AsyncMock, return_value=MOCK_REASSEMBLED_RESULTS), \
         patch("app.services.compare_service.llm_service.generate", new_callable=AsyncMock, return_value=MOCK_LLM_RESULT):
        result = await compare_essay(req)

    assert result.overall_analysis == MOCK_LLM_RESULT["overall_analysis"]
    assert len(result.references) == 3
    assert result.references[0].band == 9.0
    assert result.references[0].id == "parent-1"
    assert len(result.sentence_comparisons) == 1


@pytest.mark.asyncio
async def test_compare_essay_no_references():
    from app.services.compare_service import compare_essay
    req = CompareRequest(
        essay_text="A" * 100,
        topic="Rare topic",
        task_type="TASK_1",
        student_band=5.0,
    )

    with patch("app.services.compare_service.search_service.search_and_reassemble", new_callable=AsyncMock, return_value=[]):
        result = await compare_essay(req)
    assert result.no_references_found is True
    assert "No reference essays found" in result.overall_analysis


@pytest.mark.asyncio
async def test_compare_essay_llm_parse_failure():
    from app.services.compare_service import compare_essay
    from fastapi import HTTPException
    from langchain_core.exceptions import OutputParserException
    req = CompareRequest(
        essay_text="A" * 100,
        topic="Education topic",
        task_type="TASK_2",
        student_band=6.0,
    )

    with patch("app.services.compare_service.search_service.search_and_reassemble", new_callable=AsyncMock, return_value=MOCK_REASSEMBLED_RESULTS), \
         patch("app.services.compare_service.llm_service.generate", new_callable=AsyncMock, side_effect=OutputParserException("bad json")):
        with pytest.raises(HTTPException) as exc_info:
            await compare_essay(req)

    assert exc_info.value.status_code == 503
    assert "temporarily unavailable" in exc_info.value.detail


@pytest.mark.asyncio
async def test_compare_essay_missing_sentence_comparisons_does_not_pollute_overall_analysis():
    """Regression: the previous soft-fail path prepended a dev/debug string
    ('LLM response validation failed; sentence comparisons unavailable. ')
    to `overall_analysis`. That field is the student's feedback, so the
    internal noise leaked to the UI. The fix: silently set an empty
    `sentence_comparisons` list and expose the issue via
    `validation_warnings` (operator-facing), leaving `overall_analysis`
    exactly as the LLM returned it.
    """
    from app.services.compare_service import compare_essay
    req = CompareRequest(
        essay_text="A" * 100,
        topic="Education topic",
        task_type="TASK_2",
        student_band=6.0,
    )
    # LLM returns everything EXCEPT sentence_comparisons
    llm_response_no_comparisons = {
        "overall_analysis": "Your essay shows good structure but limited vocabulary range.",
        "vocabulary_feedback": "Use more academic terms.",
        "coherence_feedback": "Good paragraphing.",
        "grammar_feedback": "Watch subject-verb agreement.",
        "task_response_feedback": "Address all parts of the prompt.",
        "key_improvements": ["Enrich vocabulary", "Vary sentence structures"],
        # sentence_comparisons is intentionally absent
    }

    with patch("app.services.compare_service.search_service.search_and_reassemble", new_callable=AsyncMock, return_value=MOCK_REASSEMBLED_RESULTS), \
         patch("app.services.compare_service.llm_service.generate", new_callable=AsyncMock, return_value=llm_response_no_comparisons):
        result = await compare_essay(req)

    # overall_analysis is exactly what the LLM returned — no dev prefix
    assert result.overall_analysis == "Your essay shows good structure but limited vocabulary range.", (
        f"overall_analysis was polluted: {result.overall_analysis[:120]!r}"
    )
    # sentence_comparisons is empty (the soft-fail default)
    assert result.sentence_comparisons == []
    # The warning is exposed via the operator-facing field
    assert any("sentence_comparisons" in w for w in result.validation_warnings)
