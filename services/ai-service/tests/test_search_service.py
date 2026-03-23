from unittest.mock import AsyncMock, MagicMock, patch

import pytest


@pytest.mark.asyncio
async def test_search_returns_results():
    from app.services.search_service import search

    mock_client = MagicMock()
    mock_client.query_points.return_value.points = [
        MagicMock(id="id1", score=0.95, payload={"text": "Essay about education", "band_overall": 8.5, "task_type": "TASK_2"}),
    ]

    with patch("app.services.search_service._get_client", return_value=mock_client), \
         patch("app.services.search_service.embed_query", new_callable=AsyncMock, return_value=[0.1] * 768):
        results = await search("writing_samples", "education essay", top_k=3, filters={})

    assert len(results) == 1
    assert results[0].id == "id1"
    assert results[0].score == 0.95
    assert "education" in results[0].text


@pytest.mark.asyncio
async def test_search_with_filters():
    from app.services.search_service import search

    mock_client = MagicMock()
    mock_client.query_points.return_value.points = []

    with patch("app.services.search_service._get_client", return_value=mock_client), \
         patch("app.services.search_service.embed_query", new_callable=AsyncMock, return_value=[0.1] * 768):
        results = await search("writing_samples", "test", top_k=5, filters={"task_type": "TASK_1"})

    assert len(results) == 0
    call_kwargs = mock_client.query_points.call_args
    assert call_kwargs.kwargs.get("query_filter") is not None


@pytest.mark.asyncio
async def test_search_empty_collection():
    from app.services.search_service import search

    mock_client = MagicMock()
    mock_client.query_points.return_value.points = []

    with patch("app.services.search_service._get_client", return_value=mock_client), \
         patch("app.services.search_service.embed_query", new_callable=AsyncMock, return_value=[0.1] * 768):
        results = await search("grammar_knowledge", "tense error", top_k=5, filters={})

    assert results == []
