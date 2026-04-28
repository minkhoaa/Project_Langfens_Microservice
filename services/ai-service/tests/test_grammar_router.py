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


@pytest.mark.asyncio
async def test_post_detect_returns_200_with_valid_payload():
    from app.routers.grammar import grammar_detect
    from app.schemas import GrammarDetectRequest, GrammarDetectResponse, GrammarErrorItem

    fake_response = GrammarDetectResponse(
        errors=[
            GrammarErrorItem(
                error_text="He go",
                context="He go to school.",
                correct_form="He went",
            )
        ]
    )

    with patch(
        "app.routers.grammar.grammar_service.detect",
        new_callable=AsyncMock,
        return_value=fake_response,
    ) as mock_detect:
        result = await grammar_detect(
            GrammarDetectRequest(essay="He go to school.", max_errors=20)
        )

    assert isinstance(result, GrammarDetectResponse)
    assert len(result.errors) == 1
    assert result.errors[0].correct_form == "He went"
    mock_detect.assert_awaited_once()


def test_post_detect_returns_422_on_empty_essay():
    from fastapi.testclient import TestClient
    from app.main import app

    client = TestClient(app)
    response = client.post("/api/v1/grammar/detect", json={"essay": ""})
    assert response.status_code == 422


def test_post_detect_rate_limited_after_10_requests():
    """Hammer the endpoint and verify the 11th request returns 429."""
    from fastapi.testclient import TestClient
    from unittest.mock import AsyncMock, patch

    from app.main import app
    from app.middleware.rate_limit import RateLimitMiddleware
    from app.schemas import GrammarDetectResponse

    # The RateLimitMiddleware uses an in-process dict that persists across
    # TestClient calls AND across pytest tests within the same process. Reset
    # the bucket for our IP+path so prior test runs don't poison this one.
    for mw in app.user_middleware:
        if mw.cls is RateLimitMiddleware:
            # Starlette stores instantiated middleware in app.middleware_stack;
            # easier to just reach into the wrapped instance via app.build_middleware_stack
            pass
    # Build the middleware stack so the singleton instance exists, then clear it.
    app.build_middleware_stack()
    # Walk the stack to find our middleware instance.
    stack = app.middleware_stack
    while stack is not None:
        if isinstance(stack, RateLimitMiddleware):
            stack._requests.clear()
            break
        stack = getattr(stack, "app", None)

    client = TestClient(app)
    payload = {"essay": "He go to school yesterday."}

    with patch(
        "app.routers.grammar.grammar_service.detect",
        new_callable=AsyncMock,
        return_value=GrammarDetectResponse(errors=[]),
    ):
        statuses = [
            client.post("/api/v1/grammar/detect", json=payload).status_code
            for _ in range(11)
        ]

    assert statuses[-1] == 429
    assert all(s == 200 for s in statuses[:10])
