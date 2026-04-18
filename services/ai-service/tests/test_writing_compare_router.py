import warnings
warnings.filterwarnings("ignore")

from unittest.mock import AsyncMock, patch
import pytest

from app.main import app
from app.schemas import CompareRequest, CompareResponse, ReferenceEssay

MOCK_RESPONSE = CompareResponse(
    overall_analysis="Good essay with room for improvement.",
    vocabulary_feedback="Needs more academic vocab.",
    coherence_feedback="Good structure.",
    grammar_feedback="Minor errors.",
    task_response_feedback="Addresses prompt well.",
    sentence_comparisons=[],
    references=[ReferenceEssay(id="r1", text="Reference...", band=9.0, similarity_score=0.92)],
)


@pytest.mark.asyncio
async def test_writing_compare_success():
    from app.routers.writing import writing_compare

    with patch("app.routers.writing.compare_service.compare_essay", new_callable=AsyncMock, return_value=MOCK_RESPONSE):
        response = await writing_compare(CompareRequest(
            essay_text="A" * 100,
            topic="Discuss the advantages of technology in education",
            student_band=6.0,
        ))
    assert "overall_analysis" in response.model_dump()
    assert len(response.references) == 1


def test_writing_compare_short_essay():
    with pytest.raises(Exception):
        CompareRequest(
            essay_text="too short",
            topic="A valid topic here",
            student_band=6.0,
        )


def test_writing_compare_invalid_task_type():
    with pytest.raises(Exception):
        CompareRequest(
            essay_text="A" * 100,
            topic="A valid topic",
            task_type="TASK_3",
            student_band=6.0,
        )


def test_writing_compare_missing_topic():
    with pytest.raises(Exception):
        CompareRequest(
            essay_text="A" * 100,
            student_band=6.0,
        )
