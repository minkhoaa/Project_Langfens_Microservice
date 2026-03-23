from app.schemas import SearchRequest, SearchResult, SearchResponse


def test_search_request_defaults():
    req = SearchRequest(query="test essay about education")
    assert req.top_k == 5
    assert req.filters == {}


def test_search_request_with_filters():
    req = SearchRequest(query="test", top_k=3, filters={"task_type": "TASK_2"})
    assert req.top_k == 3
    assert req.filters["task_type"] == "TASK_2"


def test_search_result():
    result = SearchResult(id="abc-123", text="Essay text", score=0.95, metadata={"band_overall": 8.0})
    assert result.score == 0.95


def test_search_response():
    resp = SearchResponse(results=[], query="test", collection="writing_samples")
    assert len(resp.results) == 0
