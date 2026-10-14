"""Tests for the multi-provider (Groq + MiniMax) LLM service."""
from __future__ import annotations
from unittest.mock import MagicMock, patch
import pytest


def test_providers_dict_has_groq_and_minimax():
    """PROVIDERS must contain groq and minimax keys."""
    from app.services.groq_service import PROVIDERS

    assert set(PROVIDERS.keys()) == {"groq", "minimax"}, (
        f"PROVIDERS should contain 'groq' and 'minimax', got {list(PROVIDERS.keys())}"
    )


def test_default_provider_order():
    """The default provider order list must prioritize minimax then groq."""
    from app.services.groq_service import DEFAULT_PROVIDER_ORDER

    assert DEFAULT_PROVIDER_ORDER == ["minimax", "groq"]
def test_groq_provider_config_uses_groq_env_vars():
    """The groq provider config must reference the GROQ_* env var names."""
    from app.services.groq_service import PROVIDERS

    groq = PROVIDERS["groq"]
    assert groq["api_key_env"] == "GROQ_API_KEY"
    assert groq["api_keys_env"] == "GROQ_API_KEYS"
    assert "base_url" in groq
    assert "models" in groq
    assert "large" in groq["models"]


def test_minimax_provider_config_uses_minimax_env_vars():
    """The minimax provider config must reference the MINIMAX_* env var names."""
    from app.services.groq_service import PROVIDERS

    minimax = PROVIDERS["minimax"]
    assert minimax["api_key_env"] == "MINIMAX_API_KEY"
    assert minimax["api_keys_env"] == "MINIMAX_API_KEYS"
    assert "base_url" in minimax
    assert "models" in minimax
    assert "large" in minimax["models"]

def test_no_minimax_helper_remains():
    """_clean_mm_response was a MiniMax-specific helper; it must be gone."""
    from app.services import groq_service

    assert not hasattr(groq_service, "_clean_mm_response"), (
        "_clean_mm_response was MiniMax-specific and must be removed"
    )


def test_settings_exposes_groq_base_url_and_model():
    """The Pydantic Settings must expose groq_base_url and groq_model fields."""
    from app.config import settings

    assert hasattr(settings, "groq_base_url"), "settings.groq_base_url is required"
    assert hasattr(settings, "groq_model"), "settings.groq_model is required"
    assert settings.groq_base_url.startswith("https://") or settings.groq_base_url.startswith("http://")
    assert settings.groq_model  # non-empty



def test_settings_exposes_minimax_settings():
    """The Pydantic Settings must expose minimax_base_url and minimax_model fields."""
    from app.config import settings

    assert hasattr(settings, "minimax_base_url"), "settings.minimax_base_url is required"
    assert hasattr(settings, "minimax_model"), "settings.minimax_model is required"
    assert hasattr(settings, "minimax_api_key")
    assert hasattr(settings, "minimax_api_keys")
    assert settings.minimax_base_url.startswith("https://") or settings.minimax_base_url.startswith("http://")
    assert settings.minimax_model


@pytest.mark.asyncio
async def test_generate_json_with_minimax():
    """MiniMax provider successfully extracts and parses JSON."""
    from app.services.groq_service import GroqService

    service = GroqService(provider_order=["minimax"])
    mock_client = MagicMock()
    mock_resp = MagicMock()
    mock_resp.choices = [MagicMock()]
    mock_resp.choices[0].message.content = '```json\n{"status": "success", "score": 9.0}\n```'
    mock_client.chat.completions.create.return_value = mock_resp

    with patch.object(service, "_get_client", return_value=mock_client), \
         patch("app.services.groq_service.key_manager.get_next_key", return_value=("fake_minimax_key", 0)):
        result = await service.generate("Extract JSON: {text}", {"text": "sample text"}, expect_json=True, provider="minimax")
        assert result == {"status": "success", "score": 9.0}
        call_kwargs = mock_client.chat.completions.create.call_args.kwargs
        assert "response_format" not in call_kwargs
        assert call_kwargs.get("extra_body") == {"reasoning_split": True, "reasoning_effort": "low"}
def test_extract_json_strips_think_tags():
    """Reasoning models (like MiniMax M3) emit <think>...</think> before JSON."""
    from app.services.groq_service import _extract_json

    raw = '<think>I should output JSON with key score</think>\n```json\n{"score": 8.5}\n```'
    assert _extract_json(raw) == {"score": 8.5}



@pytest.mark.asyncio
async def test_generate_falls_back_to_minimax_when_groq_fails():
    """When Groq fails with RateLimitError, generate falls back to MiniMax."""
    from openai import RateLimitError
    from app.services.groq_service import GroqService

    service = GroqService(provider_order=["groq", "minimax"])
    mock_groq_client = MagicMock()
    mock_groq_client.chat.completions.create.side_effect = RateLimitError(
        message="Rate limit reached", response=MagicMock(status_code=429), body=None
    )
    mock_mm_client = MagicMock()
    mock_mm_resp = MagicMock()
    mock_mm_resp.choices = [MagicMock()]
    mock_mm_resp.choices[0].message.content = '{"fallback": true, "provider": "minimax"}'
    mock_mm_client.chat.completions.create.return_value = mock_mm_resp

    groq_called = [False]
    def get_client(provider, key):
        return mock_groq_client if provider == "groq" else mock_mm_client

    def get_key(provider):
        if provider == "groq" and not groq_called[0]:
            groq_called[0] = True
            return ("groq_key", 0)
        if provider == "minimax":
            return ("mm_key", 0)
        return None

    with patch.object(service, "_get_client", side_effect=get_client), \
         patch("app.services.groq_service.key_manager.get_status", return_value={"groq": {"total": 1}, "minimax": {"total": 1}}), \
         patch("app.services.groq_service.key_manager.get_next_key", side_effect=get_key):
        result = await service.generate("Extract: {text}", {"text": "test"}, expect_json=True)
        assert result == {"fallback": True, "provider": "minimax"}
        assert groq_called[0] is True


@pytest.mark.asyncio
async def test_generate_falls_back_to_groq_when_minimax_fails():
    """When MiniMax fails with RateLimitError, generate falls back to Groq."""
    from openai import RateLimitError
    from app.services.groq_service import GroqService

    service = GroqService(provider_order=["minimax", "groq"])
    mock_mm_client = MagicMock()
    mock_mm_client.chat.completions.create.side_effect = RateLimitError(
        message="MiniMax Rate limit reached", response=MagicMock(status_code=429), body=None
    )
    mock_groq_client = MagicMock()
    mock_groq_resp = MagicMock()
    mock_groq_resp.choices = [MagicMock()]
    mock_groq_resp.choices[0].message.content = '{"fallback": true, "provider": "groq"}'
    mock_groq_client.chat.completions.create.return_value = mock_groq_resp

    mm_called = [False]
    def get_client(provider, key):
        return mock_mm_client if provider == "minimax" else mock_groq_client

    def get_key(provider):
        if provider == "minimax" and not mm_called[0]:
            mm_called[0] = True
            return ("mm_key", 0)
        if provider == "groq":
            return ("groq_key", 0)
        return None

    with patch.object(service, "_get_client", side_effect=get_client), \
         patch("app.services.groq_service.key_manager.get_status", return_value={"groq": {"total": 1}, "minimax": {"total": 1}}), \
         patch("app.services.groq_service.key_manager.get_next_key", side_effect=get_key):
        result = await service.generate("Extract: {text}", {"text": "test"}, expect_json=True)
        assert result == {"fallback": True, "provider": "groq"}
        assert mm_called[0] is True


@pytest.mark.asyncio
async def test_generate_strips_think_tags_on_plain_text():
    """Non-JSON generation must strip <think>...</think> tags from model output."""
    from app.services.groq_service import GroqService

    service = GroqService(provider_order=["minimax"])
    mock_client = MagicMock()
    mock_resp = MagicMock()
    mock_resp.choices = [MagicMock()]
    mock_resp.choices[0].message.content = "<think>Drafting reading passage</think># Title\n\nBody paragraph."
    mock_client.chat.completions.create.return_value = mock_resp

    with patch.object(service, "_get_client", return_value=mock_client), \
         patch("app.services.groq_service.key_manager.get_next_key", return_value=("fake_key", 0)):
        result = await service.generate("Write passage: {topic}", {"topic": "AI"}, expect_json=False, provider="minimax")
        assert result["text"] == "# Title\n\nBody paragraph."
        assert "<think>" not in result["text"]


@pytest.mark.asyncio
async def test_generate_retries_on_empty_content():
    """When a model returns empty content, generate must retry with next attempt/key."""
    from app.services.groq_service import GroqService

    service = GroqService(provider_order=["minimax"])
    mock_client = MagicMock()

    empty_resp = MagicMock()
    empty_resp.choices = [MagicMock()]
    empty_resp.choices[0].message.content = ""
    empty_resp.choices[0].finish_reason = "length"

    valid_resp = MagicMock()
    valid_resp.choices = [MagicMock()]
    valid_resp.choices[0].message.content = '{"valid": true}'

    mock_client.chat.completions.create.side_effect = [empty_resp, valid_resp]

    with patch.object(service, "_get_client", return_value=mock_client), \
         patch("app.services.groq_service.key_manager.get_next_key", return_value=("fake_key", 0)):
        result = await service.generate("Test: {text}", {"text": "hello"}, expect_json=True, provider="minimax")
        assert result == {"valid": True}
        assert mock_client.chat.completions.create.call_count == 2

@pytest.mark.asyncio
async def test_generate_falls_back_on_repeated_empty_content():
    """When a provider repeatedly returns empty content, generate falls back after 2 attempts."""
    from app.services.groq_service import GroqService

    service = GroqService(provider_order=["minimax", "groq"])
    mock_mm_client = MagicMock()
    empty_resp = MagicMock()
    empty_resp.choices = [MagicMock()]
    empty_resp.choices[0].message.content = ""
    empty_resp.choices[0].finish_reason = "length"
    mock_mm_client.chat.completions.create.return_value = empty_resp

    mock_groq_client = MagicMock()
    mock_groq_resp = MagicMock()
    mock_groq_resp.choices = [MagicMock()]
    mock_groq_resp.choices[0].message.content = '{"fallback": true, "provider": "groq"}'
    mock_groq_client.chat.completions.create.return_value = mock_groq_resp

    def get_client(provider, key):
        return mock_mm_client if provider == "minimax" else mock_groq_client

    with patch.object(service, "_get_client", side_effect=get_client), \
         patch("app.services.groq_service.key_manager.get_status", return_value={"groq": {"total": 1}, "minimax": {"total": 1}}), \
         patch("app.services.groq_service.key_manager.get_next_key", return_value=("key", 0)):
        result = await service.generate("Test", {}, expect_json=True)
        assert result == {"fallback": True, "provider": "groq"}
        # MiniMax must be capped at 2 attempts before falling back to Groq
        assert mock_mm_client.chat.completions.create.call_count == 2
        assert mock_groq_client.chat.completions.create.call_count == 1

def test_settings_drops_use_ollama_and_use_openai_like_flags():
    """After cleanup, the LLM-judge routing flags must be removed from Settings.

    Note: `gemini_api_key` and `gemini_chat_model` are NOT in this list. They
    remain on Settings because out-of-scope speaking code
    (roleplay_chat_service.py) reads them as an LLM fallback. They are slated
    for removal in a separate "speaking provider cleanup" task. The narrow
    regression guard for those fields lives in
    tests/test_config_speaking_fields.py.
    """
    from app.config import Settings

    fields = Settings.model_fields
    for legacy in ("use_ollama", "use_openai_like"):
        assert legacy not in fields, (
            f"Settings must drop legacy routing flag '{legacy}' after provider cleanup"
        )


@pytest.mark.asyncio
async def test_generate_supports_streaming_chunks_and_callback():
    """When stream_callback is provided, generate streams tokens and invokes the callback."""
    from app.services.groq_service import GroqService

    service = GroqService(provider_order=["minimax"])
    mock_client = MagicMock()

    class Chunk:
        def __init__(self, content="", reasoning=""):
            self.choices = [MagicMock()]
            self.choices[0].delta = MagicMock()
            self.choices[0].delta.content = content
            self.choices[0].delta.reasoning_content = reasoning
            self.choices[0].finish_reason = None

    chunks = [
        Chunk(reasoning="Thinking... "),
        Chunk(content="Title: Test\n\n"),
        Chunk(content="First paragraph."),
    ]
    mock_client.chat.completions.create.return_value = iter(chunks)

    streamed_events = []
    def on_chunk(kind, token):
        streamed_events.append((kind, token))

    with patch.object(service, "_get_client", return_value=mock_client), \
         patch("app.services.groq_service.key_manager.get_next_key", return_value=("fake_key", 0)):
        result = await service.generate(
            "Write: {topic}",
            {"topic": "Education"},
            expect_json=False,
            provider="minimax",
            stream_callback=on_chunk,
        )

    assert result["text"] == "Title: Test\n\nFirst paragraph."
    assert ("reasoning", "Thinking... ") in streamed_events
    assert ("content", "Title: Test\n\n") in streamed_events
    assert ("content", "First paragraph.") in streamed_events
