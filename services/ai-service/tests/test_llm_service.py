from unittest.mock import AsyncMock, patch

import pytest


@pytest.mark.asyncio
async def test_generate_uses_ollama_when_enabled():
    with patch("app.services.llm_service.settings.use_ollama", True), \
         patch("app.services.llm_service.settings.use_openai_like", False), \
         patch("app.services.llm_service.ollama_service.generate", new_callable=AsyncMock, return_value={"provider": "ollama"}) as mock_generate:
        from app.services.llm_service import generate

        result = await generate("Hello {name}", {"name": "Minh"})

    assert result["provider"] == "ollama"
    mock_generate.assert_awaited_once()


@pytest.mark.asyncio
async def test_generate_uses_openai_like_when_explicitly_enabled():
    with patch("app.services.llm_service.settings.use_ollama", False), \
         patch("app.services.llm_service.settings.use_openai_like", True), \
         patch("app.services.llm_service.openai_like_generate", new_callable=AsyncMock, return_value={"provider": "openai_like"}) as mock_generate:
        from app.services.llm_service import generate

        result = await generate("Hello {name}", {"name": "Khoa"})

    assert result["provider"] == "openai_like"
    mock_generate.assert_awaited_once()


@pytest.mark.asyncio
async def test_generate_falls_back_to_gemini_when_local_runtime_disabled():
    with patch("app.services.llm_service.settings.use_ollama", False), \
         patch("app.services.llm_service.settings.use_openai_like", False), \
         patch("app.services.llm_service.gemini_service.generate", new_callable=AsyncMock, return_value={"provider": "gemini"}) as mock_generate:
        from app.services.llm_service import generate

        result = await generate("Hello {name}", {"name": "Khoi"})

    assert result["provider"] == "gemini"
    mock_generate.assert_awaited_once()
