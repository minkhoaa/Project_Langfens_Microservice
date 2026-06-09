"""Thin facade over the Groq LLM service.

The service previously routed to Ollama / OpenAI-Like / Gemini based on
settings flags. After the provider cleanup, only Groq is supported. Embeddings
remain on Ollama BGE-M3 (see app/services/embedding_service.py) and speaking
roleplay still uses Ollama (see app/services/ollama_service.py).
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
    key_status = get_groq_key_status()
    return {
        "provider": "groq",
        "available": any(info["available"] > 0 for info in key_status.values()),
        "keys": key_status,
    }
