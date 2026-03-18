from qdrant_client import QdrantClient
from qdrant_client.models import FieldCondition, Filter, MatchValue, Range

from app.config import settings
from app.schemas import SearchResult
from app.services.embedding_service import embed_query

_client: QdrantClient | None = None


def _get_client() -> QdrantClient:
    global _client
    if _client is None:
        _client = QdrantClient(host=settings.qdrant_host, port=settings.qdrant_port)
    return _client


def _build_filter(filters: dict) -> Filter | None:
    if not filters:
        return None
    conditions = []
    for key, value in filters.items():
        if isinstance(value, (int, float)):
            conditions.append(FieldCondition(key=key, range=Range(gte=value)))
        else:
            conditions.append(FieldCondition(key=key, match=MatchValue(value=value)))
    return Filter(must=conditions)


async def search(collection: str, query: str, top_k: int = 5, filters: dict | None = None) -> list[SearchResult]:
    vector = await embed_query(query)
    client = _get_client()

    hits = client.query_points(
        collection_name=collection,
        query=vector,
        limit=top_k,
        query_filter=_build_filter(filters or {}),
        with_payload=True,
    )

    results = []
    for point in hits.points:
        payload = point.payload or {}
        text = payload.pop("text", "")
        results.append(SearchResult(
            id=str(point.id),
            text=text,
            score=point.score,
            metadata=payload,
        ))
    return results
