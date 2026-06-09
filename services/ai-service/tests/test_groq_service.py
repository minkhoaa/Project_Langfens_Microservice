"""Tests for the new Groq-only LLM service."""
from __future__ import annotations

import pytest


def test_providers_dict_has_only_groq():
    """After cleanup, PROVIDERS must contain only the groq key."""
    from app.services.groq_service import PROVIDERS

    assert set(PROVIDERS.keys()) == {"groq"}, (
        f"PROVIDERS should only contain 'groq', got {list(PROVIDERS.keys())}"
    )


def test_default_provider_order_is_groq_only():
    """The default provider order list must have exactly one entry: groq."""
    from app.services.groq_service import DEFAULT_PROVIDER_ORDER

    assert DEFAULT_PROVIDER_ORDER == ["groq"]


def test_groq_provider_config_uses_groq_env_vars():
    """The groq provider config must reference the GROQ_* env var names."""
    from app.services.groq_service import PROVIDERS

    groq = PROVIDERS["groq"]
    assert groq["api_key_env"] == "GROQ_API_KEY"
    assert groq["api_keys_env"] == "GROQ_API_KEYS"
    assert "base_url" in groq
    assert "models" in groq
    assert "large" in groq["models"]


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
