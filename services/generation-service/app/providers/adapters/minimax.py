from __future__ import annotations

from typing import Any, Dict, Optional

from app.providers.adapters.openai_compatible import OpenAICompatibleProvider
from app.providers.models import ProviderRequest


class MiniMaxProvider(OpenAICompatibleProvider):
    """MiniMax provider adapter with reasoning split and model-specific tuning."""

    def __init__(
        self,
        base_url: str = "https://api.minimaxi.chat/v1",
        models: Optional[Dict[str, str]] = None,
    ):
        default_models = {
            "large": "MiniMax-Text-01",
            "medium": "MiniMax-Text-01",
            "small": "MiniMax-Text-01",
        }
        super().__init__(
            name="minimax",
            base_url=base_url,
            models=models or default_models,
            supports_response_format=False,
        )

    def _build_create_kwargs(self, request: ProviderRequest, model_name: str) -> Dict[str, Any]:
        kwargs = super()._build_create_kwargs(request, model_name)
        kwargs["extra_body"] = {"reasoning_split": True, "reasoning_effort": "low"}
        if "m3" in model_name.lower():
            kwargs["max_tokens"] = max(request.max_tokens, 8192)
            kwargs["max_completion_tokens"] = max(request.max_tokens, 8192)
        return kwargs
