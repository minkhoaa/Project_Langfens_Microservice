from qdrant_client.models import FieldCondition, Filter, MatchValue, Range

from app.schemas import SearchResult
from app.services.embedding_service import embed_query
from app.services.qdrant_factory import get_qdrant_client


def _build_filter(filters: dict) -> Filter | None:
    if not filters:
        return None
    conditions = []
    for key, value in filters.items():
        if isinstance(value, dict):
            conditions.append(FieldCondition(
                key=key,
                range=Range(gte=value.get("gte"), lte=value.get("lte")),
            ))
        elif isinstance(value, (int, float)):
            conditions.append(FieldCondition(key=key, range=Range(gte=value)))
        else:
            conditions.append(FieldCondition(key=key, match=MatchValue(value=value)))
    return Filter(must=conditions)


async def search(collection: str, query: str, top_k: int = 5, filters: dict | None = None) -> list[SearchResult]:
    vector = await embed_query(query)
    client = get_qdrant_client()

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
