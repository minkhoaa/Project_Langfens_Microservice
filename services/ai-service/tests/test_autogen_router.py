"""Tests for /api/v1/autogen/questions router with mocked Groq."""
from __future__ import annotations

from unittest.mock import AsyncMock, patch

import pytest
from httpx import ASGITransport, AsyncClient

from app.main import app


@pytest.mark.asyncio
async def test_autogen_questions_returns_list_of_dicts():
    """Happy path: Groq returns list of questions, router passes through."""
    mock_questions = [
        {"type": "MULTIPLE_CHOICE_SINGLE", "difficulty": 3, "options": []},
        {"type": "MULTIPLE_CHOICE_SINGLE", "difficulty": 4, "options": []},
    ]
    with patch("app.routers.autogen.groq_generate", new_callable=AsyncMock) as mock_gen:
        mock_gen.return_value = {"questions": mock_questions}
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            resp = await ac.post(
                "/api/v1/autogen/questions",
                json={
                    "type": "MULTIPLE_CHOICE_SINGLE",
                    "skill": "READING",
                    "passage": "test passage",
                    "count": 2,
                    "difficulty": 3,
                },
            )
        assert resp.status_code == 200
        body = resp.json()
        assert "questions" in body
        assert len(body["questions"]) == 2
        assert body["questions"][0]["type"] == "MULTIPLE_CHOICE_SINGLE"
        mock_gen.assert_called_once()
        _, kwargs = mock_gen.call_args
        assert "{system}" in kwargs["prompt_template"]
        assert "system" in kwargs["variables"]
        assert "user" in kwargs["variables"]


@pytest.mark.asyncio
async def test_autogen_questions_400_for_unknown_type():
    """Invalid type returns 400, never reaches Groq."""
    with patch("app.routers.autogen.groq_generate", new_callable=AsyncMock) as mock_gen:
        mock_gen.return_value = {}
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            resp = await ac.post(
                "/api/v1/autogen/questions",
                json={
                    "type": "NONEXISTENT_TYPE",
                    "skill": "READING",
                    "passage": "test",
                    "count": 1,
                    "difficulty": 3,
                },
            )
        assert resp.status_code == 400
        assert "Unknown question type" in resp.json()["detail"]


@pytest.mark.asyncio
async def test_autogen_questions_502_when_llm_returns_non_list():
    """If Groq returns dict instead of list, router returns 502."""
    with patch("app.routers.autogen.groq_generate", new_callable=AsyncMock) as mock_gen:
        mock_gen.return_value = {"questions": "not a list"}
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            resp = await ac.post(
                "/api/v1/autogen/questions",
                json={
                    "type": "MULTIPLE_CHOICE_SINGLE",
                    "skill": "READING",
                    "passage": "test",
                    "count": 1,
                    "difficulty": 3,
                },
            )
        assert resp.status_code == 502
        assert "not a list" in resp.json()["detail"]


@pytest.mark.asyncio
async def test_autogen_cors_preflight():
    """Verify OPTIONS preflight request gets 200 with CORS headers."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        resp = await ac.options(
            "/api/v1/autogen/questions",
            headers={
                "Origin": "http://localhost:3000",
                "Access-Control-Request-Method": "POST",
                "Access-Control-Request-Headers": "content-type",
            },
        )
    assert resp.status_code == 200
    assert resp.headers.get("access-control-allow-origin") == "*"
    assert "POST" in resp.headers.get("access-control-allow-methods", "")
