"""Facade over the multi-provider LLM service (Groq + MiniMax).

Supports multi-key rotation and multi-provider failover for JSON extraction
and general LLM generation. Embeddings remain on Ollama BGE-M3.
"""

import logging

from app.services.groq_service import get_groq_key_status, groq_generate

logger = logging.getLogger(__name__)


async def generate(
    prompt_template: str,
    variables: dict,
    expect_json: bool = False,
    **kwargs,
) -> dict:
    """Call the Groq LLM with the given prompt template + variables.

    The expect_json kwarg is forwarded to groq_generate so the OpenAI-compatible
    client uses response_format={"type": "json_object"}.
    """
    return await groq_generate(
        prompt_template,
        variables,
        expect_json=expect_json,
        **kwargs,
    )


def get_runtime_status() -> dict:
    """Return runtime health for the /api/llm-status endpoint."""
    from app.services.groq_service import DEFAULT_PROVIDER_ORDER
    key_status = get_groq_key_status()
    available_providers = [p for p in DEFAULT_PROVIDER_ORDER if key_status.get(p, {}).get("available", 0) > 0]
    for p, info in key_status.items():
        if info.get("available", 0) > 0 and p not in available_providers:
            available_providers.append(p)
    primary = available_providers[0] if available_providers else (DEFAULT_PROVIDER_ORDER[0] if DEFAULT_PROVIDER_ORDER else "minimax")
    if len(key_status) == 1 and list(key_status.keys())[0] not in available_providers:
        primary = list(key_status.keys())[0]
    return {
        "provider": primary,
        "providers": list(key_status.keys()),
        "active_providers": available_providers,
        "available": any(info.get("available", 0) > 0 for info in key_status.values()),
        "keys": key_status,
    }
