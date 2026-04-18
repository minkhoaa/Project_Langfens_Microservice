from unittest.mock import AsyncMock, patch

import pytest
from app.schemas import SearchResult


@pytest.mark.asyncio
async def test_grammar_search_success():
    from app.routers.grammar import grammar_search
    from app.schemas import SearchRequest

    mock_results = [
        SearchResult(id="def", text="Grammar Error Example: tense usage", score=0.88, metadata={"source_dataset": "grammarly/coedit", "task": "gec"})
    ]
    with patch("app.routers.grammar.search_service.search", new_callable=AsyncMock, return_value=mock_results):
        response = await grammar_search(SearchRequest(query="present perfect tense error"))
    assert response.collection == "grammar_knowledge"


@pytest.mark.asyncio
async def test_grammar_search_with_filter():
    from app.routers.grammar import grammar_search
    from app.schemas import SearchRequest

    with patch("app.routers.grammar.search_service.search", new_callable=AsyncMock, return_value=[]):
        response = await grammar_search(SearchRequest(query="article error", filters={"task": "gec"}))
    assert response.results == []
