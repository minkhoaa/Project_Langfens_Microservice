from __future__ import annotations

from typing import Dict, Optional

from app.providers.adapters.openai_compatible import OpenAICompatibleProvider


class GroqProvider(OpenAICompatibleProvider):
    """Groq fallback provider adapter with fast JSON inference and high throughput."""

    def __init__(
        self,
        base_url: str = "https://api.groq.com/openai/v1",
        models: Optional[Dict[str, str]] = None,
    ):
        default_models = {
            "xlarge": "openai/gpt-oss-120b",
            "large": "openai/gpt-oss-20b",
            "medium": "qwen-2.5-32b",
            "small": "llama-3.1-8b-instant",
        }
        super().__init__(
            name="groq",
            base_url=base_url,
            models=models or default_models,
            supports_response_format=True,
        )
