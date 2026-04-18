from unittest.mock import AsyncMock, patch

import pytest
from app.schemas import SearchResult


@pytest.mark.asyncio
async def test_writing_search_success():
    from app.routers.writing import writing_search
    from app.schemas import SearchRequest

    mock_results = [
        SearchResult(id="abc", text="Band 9 essay about education", score=0.92, metadata={"band_overall": 9.0, "task_type": "TASK_2"})
    ]
    with patch("app.routers.writing.search_service.search", new_callable=AsyncMock, return_value=mock_results):
        response = await writing_search(SearchRequest(query="education essay", top_k=3))
    assert response.collection == "writing_samples"
    assert len(response.results) == 1


def test_writing_search_empty_query():
    from app.schemas import SearchRequest

    with pytest.raises(Exception):
        SearchRequest(query="", top_k=3)


def test_writing_search_invalid_top_k():
    from app.schemas import SearchRequest

    with pytest.raises(Exception):
        SearchRequest(query="test", top_k=0)
