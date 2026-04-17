from unittest.mock import AsyncMock, MagicMock, patch

import pytest


def _make_point(point_id, parent_id, chunk_type, text, band, task_type, score=0.9):
    p = MagicMock()
    p.id = point_id
    p.score = score
    p.payload = {
        "text": text,
        "parent_id": parent_id,
        "chunk_type": chunk_type,
        "band_overall": band,
        "task_type": task_type,
    }
    return p


@pytest.mark.asyncio
async def test_search_returns_results():
    from app.services.search_service import search

    mock_client = MagicMock()
    mock_client.query_points.return_value.points = [
        MagicMock(id="id1", score=0.95, payload={"text": "Essay about education", "band_overall": 8.5, "task_type": "TASK_2"}),
    ]

    with patch("app.services.search_service.get_qdrant_client", return_value=mock_client), \
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

    with patch("app.services.search_service.get_qdrant_client", return_value=mock_client), \
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

    with patch("app.services.search_service.get_qdrant_client", return_value=mock_client), \
         patch("app.services.search_service.embed_query", new_callable=AsyncMock, return_value=[0.1] * 768):
        results = await search("grammar_knowledge", "tense error", top_k=5, filters={})

    assert results == []


@pytest.mark.asyncio
async def test_search_and_reassemble_groups_by_parent():
    from app.services.search_service import search_and_reassemble

    parent_a = "aaaa-1111"
    parent_b = "bbbb-2222"

    search_hits = [
        _make_point(1, parent_a, "intro", "Intro A", 7.0, "TASK_2", 0.95),
        _make_point(2, parent_b, "intro", "Intro B", 8.0, "TASK_2", 0.90),
        _make_point(3, parent_a, "body1", "Body1 A", 7.0, "TASK_2", 0.85),
    ]

    children_a = [
        _make_point(1, parent_a, "intro", "Intro A", 7.0, "TASK_2"),
        _make_point(3, parent_a, "body1", "Body1 A", 7.0, "TASK_2"),
        _make_point(4, parent_a, "conclusion", "Conclusion A", 7.0, "TASK_2"),
    ]
    children_b = [
        _make_point(2, parent_b, "intro", "Intro B", 8.0, "TASK_2"),
        _make_point(5, parent_b, "body1", "Body1 B", 8.0, "TASK_2"),
        _make_point(6, parent_b, "body2", "Body2 B", 8.0, "TASK_2"),
        _make_point(7, parent_b, "conclusion", "Conclusion B", 8.0, "TASK_2"),
    ]

    mock_client = MagicMock()
    mock_client.query_points.return_value.points = search_hits

    def scroll_side_effect(collection_name, scroll_filter, limit, with_payload, with_vectors):
        conditions = scroll_filter.must
        parent_val = conditions[0].match.value
        if parent_val == parent_a:
            return children_a, None
        elif parent_val == parent_b:
            return children_b, None
        else:
            return [], None

    mock_client.scroll.side_effect = scroll_side_effect

    with patch("app.services.search_service.get_qdrant_client", return_value=mock_client), \
         patch("app.services.search_service.embed_query", new_callable=AsyncMock, return_value=[0.1] * 1024):
        results = await search_and_reassemble(
            collection="writing_samples", query="education", top_k=5, filters={}
        )

    assert len(results) == 2
    assert results[0].parent_id == parent_a
    assert "Intro A" in results[0].text
    assert "Body1 A" in results[0].text
    assert "Conclusion A" in results[0].text
    assert results[0].metadata["band_overall"] == 7.0

    assert results[1].parent_id == parent_b
    assert "Intro B" in results[1].text
    assert "Body1 B" in results[1].text
    assert "Body2 B" in results[1].text
    assert "Conclusion B" in results[1].text


@pytest.mark.asyncio
async def test_search_and_reassemble_deduplicates_parents():
    from app.services.search_service import search_and_reassemble

    parent_a = "aaaa-1111"

    search_hits = [
        _make_point(1, parent_a, "intro", "Intro A", 7.0, "TASK_2", 0.95),
        _make_point(3, parent_a, "body1", "Body1 A", 7.0, "TASK_2", 0.80),
    ]

    children_a = [
        _make_point(1, parent_a, "intro", "Intro A", 7.0, "TASK_2"),
        _make_point(3, parent_a, "body1", "Body1 A", 7.0, "TASK_2"),
        _make_point(4, parent_a, "conclusion", "Conclusion A", 7.0, "TASK_2"),
    ]

    mock_client = MagicMock()
    mock_client.query_points.return_value.points = search_hits

    def scroll_side_effect(collection_name, scroll_filter, limit, with_payload, with_vectors):
        return children_a, None

    mock_client.scroll.side_effect = scroll_side_effect

    with patch("app.services.search_service.get_qdrant_client", return_value=mock_client), \
         patch("app.services.search_service.embed_query", new_callable=AsyncMock, return_value=[0.1] * 1024):
        results = await search_and_reassemble(
            collection="writing_samples", query="education", top_k=5, filters={}
        )

    assert len(results) == 1
    assert results[0].score == 0.95


@pytest.mark.asyncio
async def test_search_and_reassemble_empty_results():
    from app.services.search_service import search_and_reassemble

    mock_client = MagicMock()
    mock_client.query_points.return_value.points = []

    with patch("app.services.search_service.get_qdrant_client", return_value=mock_client), \
         patch("app.services.search_service.embed_query", new_callable=AsyncMock, return_value=[0.1] * 1024):
        results = await search_and_reassemble(
            collection="writing_samples", query="anything", top_k=5, filters={}
        )

    assert results == []
