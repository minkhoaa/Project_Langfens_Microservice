import logging
import requests
from app.config import settings

logger = logging.getLogger(__name__)

# nomic-embed-text outputs 768-dimensional vectors
EMBEDDING_DIM = 768
OLLAMA_EMBED_MODEL = "nomic-embed-text"


async def embed_texts(texts: list[str]) -> list[list[float]]:
    """Generate embeddings using Ollama nomic-embed-text model."""
    embeddings = []
    for text in texts:
        embedding = await embed_query(text)
        embeddings.append(embedding)
    return embeddings


async def embed_query(text: str) -> list[float]:
    """Generate embedding for a single text using Ollama nomic-embed-text."""
    try:
        resp = requests.post(
            f"{settings.ollama_base_url}/api/embeddings",
            json={"model": OLLAMA_EMBED_MODEL, "prompt": text},
            timeout=60,
        )
        resp.raise_for_status()
        data = resp.json()
        return data.get("embedding", [])
    except Exception as e:
        logger.error(f"Failed to generate embedding: {e}")
        raise
