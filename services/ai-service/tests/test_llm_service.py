"""Tests for the Groq-only llm_service facade."""
from __future__ import annotations

from unittest.mock import AsyncMock, patch

import pytest


@pytest.mark.asyncio
async def test_generate_delegates_to_groq_generate():
    """llm_service.generate must call groq_generate exactly once."""
    with patch("app.services.llm_service.groq_generate", new_callable=AsyncMock, return_value={"provider": "groq"}) as mock_generate:
        from app.services.llm_service import generate

        result = await generate("Hello {name}", {"name": "Khoa"})

    assert result["provider"] == "groq"
    mock_generate.assert_awaited_once()


@pytest.mark.asyncio
async def test_generate_passes_expect_json_through():
    """The expect_json kwarg must be forwarded to groq_generate."""
    with patch("app.services.llm_service.groq_generate", new_callable=AsyncMock, return_value={}) as mock_generate:
        from app.services.llm_service import generate

        await generate("p", {}, expect_json=True)

    args, kwargs = mock_generate.call_args
    assert kwargs.get("expect_json") is True


def test_get_runtime_status_returns_groq_keys():
    """The runtime status dict must report provider=groq and key counts."""
    with patch("app.services.llm_service.get_groq_key_status", return_value={"groq": {"total": 1, "available": 1, "exhausted": 0, "current_index": 0, "keys": []}}) as mock_status:
        from app.services.llm_service import get_runtime_status

        status = get_runtime_status()

    assert status["provider"] == "groq"
    assert status["available"] is True
    assert "keys" in status
    mock_status.assert_called_once()


def test_get_runtime_status_reports_unavailable_when_no_keys():
    with patch("app.services.llm_service.get_groq_key_status", return_value={"groq": {"total": 0, "available": 0, "exhausted": 0, "current_index": 0, "keys": []}}):
        from app.services.llm_service import get_runtime_status

        status = get_runtime_status()

    assert status["provider"] == "groq"
    assert status["available"] is False
