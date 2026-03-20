import json
import logging
import time
from pathlib import Path

from qdrant_client.models import Distance, PayloadSchemaType, PointStruct, VectorParams
from tqdm import tqdm

from app.config import settings
from app.services.embedding_service import _post

logger = logging.getLogger(__name__)

EMBEDDING_DIM = 768
BATCH_SIZE = 100
SLEEP_BETWEEN_BATCHES = 0.1

COLLECTIONS = {
    settings.qdrant_collection_writing: {
        "file": "writing_samples.jsonl",
        "indexes": {
            "band_overall": PayloadSchemaType.FLOAT,
            "task_type": PayloadSchemaType.KEYWORD,
            "level": PayloadSchemaType.KEYWORD,
        },
    },
    settings.qdrant_collection_grammar: {
        "file": "grammar_knowledge.jsonl",
        "indexes": {
            "source_dataset": PayloadSchemaType.KEYWORD,
            "task": PayloadSchemaType.KEYWORD,
        },
    },
}


_BASE = f"https://generativelanguage.googleapis.com/v1beta/{settings.gemini_embedding_model}"


def _embed_batch(texts: list[str]) -> list[list[float]]:
    for attempt in range(3):
        try:
            data = _post(
                f"{_BASE}:batchEmbedContents",
                {
                    "requests": [
                        {
                            "model": settings.gemini_embedding_model,
                            "content": {"parts": [{"text": t}]},
                            "taskType": "RETRIEVAL_DOCUMENT",
                            "outputDimensionality": EMBEDDING_DIM,
                        }
                        for t in texts
                    ]
                },
            )
            return [e["values"] for e in data["embeddings"]]
        except Exception as e:
            if attempt < 2:
                logger.warning(f"  embed retry {attempt+1}/3: {e}")
                time.sleep(3 * (attempt + 1))
            else:
                raise


def _needs_ingestion(client, collection: str) -> bool:
    if settings.force_reingest:
        if client.collection_exists(collection):
            logger.info(f"  FORCE_REINGEST: deleting collection {collection}")
            client.delete_collection(collection)
        return True
    if not client.collection_exists(collection):
        return True
    info = client.get_collection(collection)
    return (info.points_count or 0) == 0


def _ensure_collection(client, name: str, indexes: dict) -> None:
    if client.collection_exists(name):
        return
    client.create_collection(
        collection_name=name,
        vectors_config=VectorParams(size=EMBEDDING_DIM, distance=Distance.COSINE),
    )
    for field, schema_type in indexes.items():
        client.create_payload_index(
            collection_name=name,
            field_name=field,
            field_schema=schema_type,
        )


def _ingest_collection(client, data_dir: Path, collection: str, cfg: dict) -> int:
    jsonl_path = data_dir / cfg["file"]
    if not jsonl_path.exists():
        logger.warning(f"Data file not found: {jsonl_path} — skipping {collection}")
        return 0

    _ensure_collection(client, collection, cfg["indexes"])

    docs = []
    with open(jsonl_path) as f:
        for line in f:
            line = line.strip()
            if line:
                docs.append(json.loads(line))

    uploaded = 0
    for i in tqdm(range(0, len(docs), BATCH_SIZE), desc=collection, leave=False):
        batch = docs[i : i + BATCH_SIZE]
        vectors = _embed_batch([d["text"] for d in batch])
        points = [
            PointStruct(
                id=d["id"],
                vector=vec,
                payload={"text": d["text"], **d.get("metadata", {})},
            )
            for d, vec in zip(batch, vectors)
        ]
        for attempt in range(3):
            try:
                client.upsert(collection_name=collection, points=points)
                break
            except Exception as e:
                if attempt < 2:
                    logger.warning(f"  upsert retry {attempt+1}/3: {e}")
                    time.sleep(2 ** attempt)
                else:
                    raise
        uploaded += len(points)
        time.sleep(SLEEP_BETWEEN_BATCHES)

    return uploaded


def run_ingestion() -> None:
    """Check Qdrant collections; ingest data if empty. Called at service startup."""
    if not settings.gemini_api_key:
        logger.warning("GEMINI_API_KEY not set — skipping ingestion")
        return

    from app.services.qdrant_factory import get_qdrant_client

    data_dir = Path(settings.data_dir) / "rag"
    client = get_qdrant_client()

    needs = {name: _needs_ingestion(client, name) for name in COLLECTIONS}
    if not any(needs.values()):
        logger.info("All Qdrant collections already populated — skipping ingestion")
        return

    logger.info("Starting Qdrant ingestion...")
    start = time.time()

    for name, cfg in COLLECTIONS.items():
        if needs[name]:
            n = _ingest_collection(client, data_dir, name, cfg)
            logger.info(f"  {name}: {n:,} vectors uploaded")
        else:
            logger.info(f"  {name}: already populated, skipped")

    logger.info(f"Ingestion complete in {time.time() - start:.1f}s")
