"""Regression guard for settings fields consumed by out-of-scope speaking code.

After the AI Provider Cleanup, the LLM-judge path uses only Groq. But
out-of-scope speaking code (routers/speaking.py, ollama_service.py,
roleplay_chat_service.py) still reads these legacy fields. If they are removed
from Settings, the first real call to a speaking endpoint will raise
AttributeError. This test asserts the fields remain present so the regression
is caught at unit-test time.
"""
from __future__ import annotations


def test_speaking_only_settings_fields_are_present():
    from app.config import Settings

    fields = Settings.model_fields
    expected = {
        "ollama_model",
        "ollama_temperature",
        "gemini_api_key",
        "gemini_chat_model",
        "gemini_chat_temperature",
        "gemini_chat_max_tokens",
        "gemini_chat_timeout",
    }
    missing = expected - set(fields.keys())
    assert not missing, (
        f"Settings is missing legacy speaking-only fields: {sorted(missing)}. "
        f"These are read by routers/speaking.py, ollama_service.py, and "
        f"roleplay_chat_service.py (out of scope for the AI Provider Cleanup)."
    )
