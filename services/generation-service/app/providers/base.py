from __future__ import annotations

from abc import ABC, abstractmethod
import json
import logging
import re
from typing import Any, Dict, Optional

from app.providers.models import ProviderRequest, ProviderResponse

logger = logging.getLogger(__name__)

# Pattern to redact API keys and bearer tokens from logs
REDACT_PATTERNS = [
    (re.compile(r"(Bearer\s+)[A-Za-z0-9_\-\.]{8,}", re.IGNORECASE), r"\1[REDACTED]"),
    (re.compile(r"(api[-_]?key['\":\s=]+)[A-Za-z0-9_\-\.]{8,}", re.IGNORECASE), r"\1[REDACTED]"),
    (re.compile(r"sk-[A-Za-z0-9_\-]{8,}", re.IGNORECASE), "[REDACTED]"),
    (re.compile(r"gsk_[A-Za-z0-9_\-]{8,}", re.IGNORECASE), "[REDACTED]"),
]


def redact_secrets(text: str) -> str:
    """Sanitizes text to prevent API keys or bearer tokens from appearing in logs or error messages."""
    if not text:
        return ""
    result = text
    for pattern, replacement in REDACT_PATTERNS:
        result = pattern.sub(replacement, result)
    return result


class BaseProvider(ABC):
    """Abstract base class for all LLM provider adapters in Loop Engine V2."""

    def __init__(self, name: str, base_url: str, models: Dict[str, str]):
        self.name = name
        self.base_url = base_url
        self.models = models

    @abstractmethod
    async def call(self, request: ProviderRequest, api_key: str, deadline: float) -> ProviderResponse:
        """Executes a single provider request with timeout and returns a typed ProviderResponse."""
        pass

    @abstractmethod
    async def check_health(self, api_key: Optional[str] = None) -> bool:
        """Checks provider reachability and credentials."""
        pass

    def get_model_name(self, model_size: str) -> str:
        """Resolves model size alias to provider model name."""
        return self.models.get(model_size, self.models.get("large", next(iter(self.models.values()))))

    def estimate_tokens(self, text: str) -> int:
        """Heuristic estimator for diagnostics only; never used for budget admission."""
        if not text:
            return 0
        return max(1, len(text) // 4)

    def completion_token_limit(self, request: ProviderRequest) -> int:
        """Maximum visible-plus-reasoning completion tokens allowed by this adapter."""
        return request.max_tokens

    def conservative_token_reservation(self, request: ProviderRequest) -> int:
        """Upper-bound prompt bytes plus the adapter's full completion allowance."""
        prompt = {
            "model": self.get_model_name(request.model_size),
            "messages": [{"role": m.role, "content": m.content} for m in request.messages],
            "response_schema": request.response_schema,
        }
        prompt_bytes = len(json.dumps(prompt, ensure_ascii=True, sort_keys=True, separators=(",", ":")).encode("ascii"))
        prompt_bound = (prompt_bytes + 2) // 3 + 128 + 64 * len(request.messages)
        completion_bound = max(request.max_tokens, self.completion_token_limit(request))
        return prompt_bound + completion_bound
