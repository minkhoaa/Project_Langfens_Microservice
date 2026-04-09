#!/usr/bin/env python3
"""
Ingest writing_samples from local JSONL into Qdrant using bge-m3 via Ollama API.
GPU-accelerated via Ollama.
"""

import os
import json
import logging
import time
from pathlib import Path
import requests
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct
from tqdm import tqdm

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s"
)
logger = logging.getLogger(__name__)

QDRANT_ENDPOINT = os.getenv("QDRANT_ENDPOINT", "")
QDRANT_API_KEY = os.getenv("QDRANT_API_KEY", "")
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434")
OLLAMA_MODEL = "nomic-embed-text"
COLLECTION_NAME = "grammar_knowledge"
DATA_FILE = "/home/khoa/dataset_ielts/export/rag/grammar_knowledge.jsonl"
BATCH_SIZE = 100
EMBEDDING_DIM = 768
MAX_WORKERS = 10  # Parallel GPU requests


def get_embedding(text: str) -> list[float]:
    """Get embedding from Ollama nomic-embed-text."""
    for attempt in range(3):
        try:
            resp = requests.post(
                f"{OLLAMA_URL}/api/embeddings",
                json={"model": OLLAMA_MODEL, "prompt": text},
                timeout=120,
            )
            resp.raise_for_status()
            return resp.json().get("embedding", [])
        except Exception as e:
            if attempt < 2:
                time.sleep(2)
            else:
                logger.error(f"Embedding failed: {e}")
                return [0.0] * EMBEDDING_DIM


def embed_batch(texts: list[str], max_workers: int = 5) -> list[list[float]]:
    """Embed texts in parallel using thread pool."""
    from concurrent.futures import ThreadPoolExecutor, as_completed

    results = [None] * len(texts)

    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        future_to_idx = {
            executor.submit(get_embedding, text): i for i, text in enumerate(texts)
        }

        for future in as_completed(future_to_idx):
            idx = future_to_idx[future]
            try:
                results[idx] = future.result()
            except Exception as e:
                logger.error(f"Failed at index {idx}: {e}")
                results[idx] = [0.0] * EMBEDDING_DIM

    return results


def get_qdrant() -> QdrantClient:
    return QdrantClient(url=QDRANT_ENDPOINT, api_key=QDRANT_API_KEY, timeout=120)


def create_collection(qdrant: QdrantClient):
    try:
        qdrant.delete_collection(collection_name=COLLECTION_NAME)
        logger.info(f"Deleted existing collection: {COLLECTION_NAME}")
    except Exception as e:
        logger.warning(f"Collection delete failed: {e}")

    qdrant.create_collection(
        collection_name=COLLECTION_NAME,
        vectors_config=VectorParams(size=EMBEDDING_DIM, distance=Distance.COSINE),
    )
    logger.info(
        f"Created collection: {COLLECTION_NAME} with {EMBEDDING_DIM}-dim vectors"
    )

    qdrant.create_payload_index(
        collection_name=COLLECTION_NAME,
        field_name="source_dataset",
        field_schema="keyword",
    )
    qdrant.create_payload_index(
        collection_name=COLLECTION_NAME,
        field_name="task",
        field_schema="keyword",
    )
    logger.info("Created payload indexes")


def load_jsonl(file_path: str) -> list[dict]:
    docs = []
    with open(file_path) as f:
        for line in f:
            line = line.strip()
            if line:
                docs.append(json.loads(line))
    return docs


def main():
    logger.info(f"Starting Ollama {OLLAMA_MODEL} ingestion from {DATA_FILE}...")

    qdrant = get_qdrant()
    docs = load_jsonl(DATA_FILE)
    logger.info(f"Loaded {len(docs):,} essays from JSONL")

    if not docs:
        logger.error("No documents found!")
        return

    create_collection(qdrant)

    total = len(docs)
    start_time = time.time()

    for i in tqdm(range(0, total, BATCH_SIZE), desc="Embedding & upserting"):
        batch = docs[i : i + BATCH_SIZE]

        texts = []
        for d in batch:
            text = d.get("text", "") or d.get("content", "")
            if not text:
                text = "[empty]"
            if len(text) > 500:
                text = text[:500]
            texts.append(text)

        embeddings = embed_batch(texts, max_workers=MAX_WORKERS)

        points = []
        for d, emb in zip(batch, embeddings):
            payload = {"text": d.get("text", ""), **d.get("metadata", {})}
            point = PointStruct(
                id=d["id"],
                vector=emb,
                payload=payload,
            )
            points.append(point)

        qdrant.upsert(collection_name=COLLECTION_NAME, points=points)

        progress = min(i + BATCH_SIZE, total)
        elapsed = time.time() - start_time
        rate = (i + BATCH_SIZE) / elapsed if elapsed > 0 else 0
        eta = (total - progress) / rate if rate > 0 else 0

        logger.info(
            f"Upserted {progress:,}/{total:,} essays ({rate:.1f}/s, ETA: {eta / 60:.1f}min)"
        )

    info = qdrant.get_collection(COLLECTION_NAME)
    total_time = time.time() - start_time
    logger.info(
        f"✅ Ingestion complete in {total_time / 60:.1f}min! Collection has {info.points_count:,} points"
    )


if __name__ == "__main__":
    main()
