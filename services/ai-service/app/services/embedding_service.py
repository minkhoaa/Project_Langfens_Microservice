import logging

import requests

from app.config import settings

logger = logging.getLogger(__name__)

EMBEDDING_DIM = settings.ollama_embed_dimensions


async def embed_texts(texts: list[str]) -> list[list[float]]:
    """Generate embeddings using the configured Ollama embedding model."""
    embeddings = []
    for text in texts:
        embedding = await embed_query(text)
        embeddings.append(embedding)
    return embeddings


_MAX_EMBED_CHARS = 4000  # bge-m3 native context is 8K tokens; cap chars defensively


async def embed_query(text: str) -> list[float]:
    """Generate embedding for a single text using the configured Ollama model.

    Forces CPU mode (num_gpu=0) to avoid an Ollama bge-m3 bug on CUDA where
    certain inputs produce NaN values that fail JSON encoding
    ('failed to encode response: json: unsupported value: NaN'). bge-m3 is
    small enough that CPU latency is acceptable for query-time embedding.
    """
    safe_text = text[:_MAX_EMBED_CHARS]
    try:
        resp = requests.post(
            f"{settings.ollama_base_url}/api/embeddings",
            json={
                "model": settings.ollama_embed_model,
                "prompt": safe_text,
                "options": {"num_gpu": 0},
            },
            timeout=60,
        )
        resp.raise_for_status()
        data = resp.json()
        if "error" in data and "embedding" not in data:
            raise RuntimeError(f"Ollama embed error: {data['error']}")
        embedding = data.get("embedding", [])
        if embedding and len(embedding) != EMBEDDING_DIM:
            logger.warning(
                "Embedding dimension mismatch: expected %s, got %s",
                EMBEDDING_DIM,
                len(embedding),
            )
        return embedding
    except Exception as e:
        logger.error(f"Failed to generate embedding: {e}")
        raise
