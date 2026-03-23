from unittest.mock import AsyncMock, patch

from fastapi.testclient import TestClient

from app.main import app
from app.schemas import SearchResult

client = TestClient(app)


def test_grammar_search_success():
    mock_results = [
        SearchResult(id="def", text="Grammar Error Example: tense usage", score=0.88, metadata={"source_dataset": "grammarly/coedit", "task": "gec"})
    ]
    with patch("app.routers.grammar.search_service.search", new_callable=AsyncMock, return_value=mock_results):
        resp = client.post("/api/v1/grammar/search", json={"query": "present perfect tense error"})
    assert resp.status_code == 200
    data = resp.json()
    assert data["collection"] == "grammar_knowledge"


def test_grammar_search_with_filter():
    with patch("app.routers.grammar.search_service.search", new_callable=AsyncMock, return_value=[]):
        resp = client.post("/api/v1/grammar/search", json={"query": "article error", "filters": {"task": "gec"}})
    assert resp.status_code == 200
