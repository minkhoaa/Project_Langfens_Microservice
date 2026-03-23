from unittest.mock import AsyncMock, patch

from fastapi.testclient import TestClient

from app.main import app
from app.schemas import SearchResult

client = TestClient(app)


def test_writing_search_success():
    mock_results = [
        SearchResult(id="abc", text="Band 9 essay about education", score=0.92, metadata={"band_overall": 9.0, "task_type": "TASK_2"})
    ]
    with patch("app.routers.writing.search_service.search", new_callable=AsyncMock, return_value=mock_results):
        resp = client.post("/api/v1/writing/search", json={"query": "education essay", "top_k": 3})
    assert resp.status_code == 200
    data = resp.json()
    assert data["collection"] == "writing_samples"
    assert len(data["results"]) == 1


def test_writing_search_empty_query():
    resp = client.post("/api/v1/writing/search", json={"query": "", "top_k": 3})
    assert resp.status_code == 422


def test_writing_search_invalid_top_k():
    resp = client.post("/api/v1/writing/search", json={"query": "test", "top_k": 0})
    assert resp.status_code == 422
