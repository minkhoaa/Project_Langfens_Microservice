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


async def embed_query(text: str) -> list[float]:
    """Generate embedding for a single text using the configured Ollama model."""
    try:
        resp = requests.post(
            f"{settings.ollama_base_url}/api/embeddings",
            json={"model": settings.ollama_embed_model, "prompt": text},
            timeout=60,
        )
        resp.raise_for_status()
        data = resp.json()
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
