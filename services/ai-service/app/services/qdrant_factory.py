from qdrant_client import QdrantClient

from app.config import settings

_client: QdrantClient | None = None


def get_qdrant_client() -> QdrantClient:
    global _client
    if _client is None:
        if settings.qdrant_endpoint:
            _client = QdrantClient(
                url=settings.qdrant_endpoint,
                api_key=settings.qdrant_api_key,
            )
        else:
            _client = QdrantClient(
                host=settings.qdrant_host,
                port=settings.qdrant_port,
            )
    return _client
