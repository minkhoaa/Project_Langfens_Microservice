from __future__ import annotations

import httpx
from typing import Any, Dict, Optional

from app.providers.adapters.openai_compatible import OpenAICompatibleProvider
from app.providers.models import ProviderRequest


class MiniMaxProvider(OpenAICompatibleProvider):
    """MiniMax provider adapter with reasoning split and model-specific tuning."""

    def __init__(
        self,
        base_url: str = "https://api.minimaxi.chat/v1",
        models: Optional[Dict[str, str]] = None,
        http_client: Optional[httpx.AsyncClient] = None,
        max_retries: int = 0,
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
            http_client=http_client,
            max_retries=max_retries,
        )

    def _build_create_kwargs(self, request: ProviderRequest, model_name: str) -> Dict[str, Any]:
        kwargs = super()._build_create_kwargs(request, model_name)
        kwargs["extra_body"] = {"reasoning_split": True, "reasoning_effort": "low"}
        effective_max = request.max_tokens if request.max_tokens > 0 else 4096
        kwargs["max_tokens"] = effective_max
        kwargs["max_completion_tokens"] = effective_max
        return kwargs
