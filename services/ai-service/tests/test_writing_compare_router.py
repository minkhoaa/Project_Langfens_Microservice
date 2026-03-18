import warnings
warnings.filterwarnings("ignore")

from unittest.mock import AsyncMock, patch
from fastapi.testclient import TestClient
from app.main import app
from app.schemas import CompareResponse, ReferenceEssay

client = TestClient(app)

MOCK_RESPONSE = CompareResponse(
    overall_analysis="Good essay with room for improvement.",
    vocabulary_feedback="Needs more academic vocab.",
    coherence_feedback="Good structure.",
    grammar_feedback="Minor errors.",
    task_response_feedback="Addresses prompt well.",
    sentence_comparisons=[],
    references=[ReferenceEssay(id="r1", text="Reference...", band=9.0, similarity_score=0.92)],
)


def test_writing_compare_success():
    with patch("app.routers.writing.compare_service.compare_essay", new_callable=AsyncMock, return_value=MOCK_RESPONSE):
        resp = client.post("/api/v1/writing/compare", json={
            "essay_text": "A" * 100,
            "topic": "Discuss the advantages of technology in education",
        })
    assert resp.status_code == 200
    data = resp.json()
    assert "overall_analysis" in data
    assert len(data["references"]) == 1


def test_writing_compare_short_essay():
    resp = client.post("/api/v1/writing/compare", json={
        "essay_text": "too short",
        "topic": "A valid topic here",
    })
    assert resp.status_code == 422


def test_writing_compare_invalid_task_type():
    resp = client.post("/api/v1/writing/compare", json={
        "essay_text": "A" * 100,
        "topic": "A valid topic",
        "task_type": "TASK_3",
    })
    assert resp.status_code == 422


def test_writing_compare_missing_topic():
    resp = client.post("/api/v1/writing/compare", json={
        "essay_text": "A" * 100,
    })
    assert resp.status_code == 422
