import logging
from datetime import datetime, timezone
from uuid import uuid4

from qdrant_client.models import (
    Distance,
    FieldCondition,
    Filter,
    MatchValue,
    PayloadSchemaType,
    PointStruct,
    VectorParams,
)

from app.config import settings
from app.services.qdrant_factory import get_qdrant_client

logger = logging.getLogger(__name__)

_collection_ready = False


# ---------------------------------------------------------------------------
# Collection setup (unchanged)
# ---------------------------------------------------------------------------

def ensure_speaking_memory_collection() -> None:
    global _collection_ready
    if _collection_ready:
        return

    client = get_qdrant_client()
    collection_name = settings.qdrant_collection_speaking_memory

    if not client.collection_exists(collection_name):
        client.create_collection(
            collection_name=collection_name,
            vectors_config=VectorParams(size=settings.ollama_embed_dimensions, distance=Distance.COSINE),
        )

    for field_name in ("user_id", "session_id", "scenario_slug"):
        try:
            client.create_payload_index(
                collection_name=collection_name,
                field_name=field_name,
                field_schema=PayloadSchemaType.KEYWORD,
            )
        except Exception as exc:
            logger.debug("Skipping payload index %s on %s: %s", field_name, collection_name, exc)

    _collection_ready = True


# ---------------------------------------------------------------------------
# WRITE — save one speaking turn into Qdrant
# ---------------------------------------------------------------------------

async def save_speaking_memory(
    user_id: str,
    session_id: str,
    scenario_slug: str,
    text: str,
    errors: list,          # list[WordErrorItem] or plain dicts — serialised to payload
    score: float,
) -> None:
    """
    Embed the spoken utterance and upsert a single point into the
    speaking_memory collection.

    One point per turn (not per error) keeps retrieval clean: a single
    similarity search returns the most relevant past utterances, and the
    full error list is stored in the payload for prompt injection.

    Failures are swallowed — the caller must NOT break on memory errors.
    """
    # Import here to avoid circular import at module level
    from app.services.embedding_service import embed_query

    try:
        vector = await embed_query(text)
    except Exception as exc:
        logger.warning("Speaking memory: embedding failed, skipping save. %s", exc)
        return

    # Serialise errors: accept both WordErrorItem objects and plain dicts
    errors_payload = []
    for e in errors:
        if hasattr(e, "model_dump"):
            errors_payload.append(e.model_dump())
        elif isinstance(e, dict):
            errors_payload.append(e)
        else:
            errors_payload.append({"word": str(e), "type": "incorrect"})

    payload = {
        "text": text,
        "user_id": user_id,
        "session_id": session_id,
        "scenario_slug": scenario_slug,
        "errors": errors_payload,
        "score": score,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }

    point = PointStruct(
        id=str(uuid4()),
        vector=vector,
        payload=payload,
    )

    try:
        client = get_qdrant_client()
        client.upsert(
            collection_name=settings.qdrant_collection_speaking_memory,
            points=[point],
        )
        logger.debug(
            "Speaking memory saved: user=%s session=%s score=%.2f errors=%d",
            user_id, session_id, score, len(errors_payload),
        )
    except Exception as exc:
        logger.warning("Speaking memory: Qdrant upsert failed, skipping. %s", exc)


# ---------------------------------------------------------------------------
# READ — search relevant past speaking memory for prompt injection
# ---------------------------------------------------------------------------

async def search_speaking_memory(
    user_id: str,
    query_text: str,
    scenario_slug: str | None = None,
    limit: int = 5,
) -> list[dict]:
    """
    Search the speaking_memory collection for past turns similar to
    query_text, filtered by user_id (required) and optionally scenario_slug.

    Returns a list of compact dicts:
        [{"text": ..., "errors": [...], "score": float}, ...]

    Failures return an empty list — the caller must NOT break on memory errors.
    """
    from app.services.embedding_service import embed_query

    try:
        vector = await embed_query(query_text)
    except Exception as exc:
        logger.warning("Speaking memory: embedding failed for search, returning empty. %s", exc)
        return []

    # Build filter: user_id is always required; scenario_slug is optional
    must_conditions = [
        FieldCondition(key="user_id", match=MatchValue(value=user_id)),
    ]
    if scenario_slug:
        must_conditions.append(
            FieldCondition(key="scenario_slug", match=MatchValue(value=scenario_slug))
        )

    try:
        client = get_qdrant_client()
        hits = client.query_points(
            collection_name=settings.qdrant_collection_speaking_memory,
            query=vector,
            limit=limit,
            query_filter=Filter(must=must_conditions),
            with_payload=True,
        )
    except Exception as exc:
        logger.warning("Speaking memory: Qdrant search failed, returning empty. %s", exc)
        return []

    results = []
    for point in hits.points:
        payload = point.payload or {}
        results.append({
            "text": payload.get("text", ""),
            "errors": payload.get("errors", []),
            "score": payload.get("score", 0.0),
        })

    return results


# ---------------------------------------------------------------------------
# SUMMARISE — convert raw memory hits into a short prompt-injection string
# ---------------------------------------------------------------------------

def summarise_memory_for_prompt(memory_hits: list[dict]) -> str:
    """
    Collapse a list of past memory hits into 1–3 bullet points for prompt
    injection. Returns an empty string when there is nothing useful to inject.

    Design constraints:
    - Never dump raw records into the prompt
    - Keep it to ≤3 lines
    - Use natural language, not technical labels
    """
    if not memory_hits:
        return ""

    # Collect all error words that appeared in recent low-score turns
    problem_words: list[str] = []
    seen: set[str] = set()
    low_score_count = 0

    for hit in memory_hits:
        if hit.get("score", 1.0) < 0.70:
            low_score_count += 1
        for err in hit.get("errors", []):
            word = err.get("word", "").strip().lower()
            if word and word not in seen:
                problem_words.append(err.get("word", word))  # preserve original casing
                seen.add(word)

    if not problem_words and low_score_count == 0:
        return ""

    lines: list[str] = []

    if problem_words:
        # Cap at 3 words to avoid bloating the prompt
        sample = problem_words[:3]
        words_str = ", ".join(f'"{w}"' for w in sample)
        lines.append(f"• This learner has previously struggled with: {words_str}.")

    if low_score_count >= 2:
        lines.append("• They've had several unclear deliveries — keep your sentences short and well-paced.")

    return "\n".join(lines)
