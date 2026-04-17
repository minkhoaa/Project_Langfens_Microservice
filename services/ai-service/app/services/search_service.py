import logging

from qdrant_client.models import FieldCondition, Filter, MatchValue, Range

from app.schemas import ReassembledEssay, SearchResult
from app.services.embedding_service import embed_query
from app.services.qdrant_factory import get_qdrant_client

logger = logging.getLogger(__name__)

CHUNK_ORDER = ["intro", "body1", "body2", "body3", "body4", "conclusion"]


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


def _fetch_children(client, collection: str, parent_id: str) -> list:
    points, _ = client.scroll(
        collection_name=collection,
        scroll_filter=Filter(
            must=[FieldCondition(key="parent_id", match=MatchValue(value=parent_id))]
        ),
        limit=10,
        with_payload=True,
        with_vectors=False,
    )
    return points


def _reassemble_text(children: list) -> str:
    by_type = {}
    for child in children:
        ct = (child.payload or {}).get("chunk_type", "")
        text = (child.payload or {}).get("text", "")
        if ct and text:
            by_type[ct] = text
    parts = [by_type[ct] for ct in CHUNK_ORDER if ct in by_type]
    return "\n\n".join(parts)


async def search_and_reassemble(
    collection: str, query: str, top_k: int = 5, filters: dict | None = None
) -> list[ReassembledEssay]:
    vector = await embed_query(query)
    client = get_qdrant_client()

    hits = client.query_points(
        collection_name=collection,
        query=vector,
        limit=top_k * 3,
        query_filter=_build_filter(filters or {}),
        with_payload=True,
    )

    seen_parents: dict[str, float] = {}
    chunk_scores: dict[str, dict[str, float]] = {}

    for point in hits.points:
        payload = point.payload or {}
        parent_id = payload.get("parent_id", "")
        chunk_type = payload.get("chunk_type", "")
        if not parent_id:
            continue
        if parent_id not in seen_parents or point.score > seen_parents[parent_id]:
            seen_parents[parent_id] = point.score
        chunk_scores.setdefault(parent_id, {})[chunk_type] = point.score

    sorted_parents = sorted(seen_parents.items(), key=lambda x: x[1], reverse=True)[:top_k]

    results = []
    for parent_id, best_score in sorted_parents:
        children = _fetch_children(client, collection, parent_id)
        if not children:
            continue
        text = _reassemble_text(children)
        if not text:
            continue
        first_payload = children[0].payload or {}
        metadata = {
            k: v for k, v in first_payload.items()
            if k not in ("text", "chunk_id", "chunk_type", "parent_id")
        }
        results.append(ReassembledEssay(
            parent_id=parent_id,
            text=text,
            score=best_score,
            metadata=metadata,
            chunk_scores=chunk_scores.get(parent_id, {}),
        ))

    return results
