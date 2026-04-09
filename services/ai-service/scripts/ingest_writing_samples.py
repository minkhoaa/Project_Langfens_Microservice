#!/usr/bin/env python3
"""
Ingest writing_samples from local JSONL file into Qdrant using bge-m3 via sentence-transformers.
"""

import os
import gc
import json
import logging
import time
from pathlib import Path
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct
from sentence_transformers import SentenceTransformer
from tqdm import tqdm

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s"
)
logger = logging.getLogger(__name__)

QDRANT_ENDPOINT = os.getenv("QDRANT_ENDPOINT", "")
QDRANT_API_KEY = os.getenv("QDRANT_API_KEY", "")
COLLECTION_NAME = "writing_samples"
DATA_FILE = "/home/khoa/dataset_ielts/export/rag/writing_samples.jsonl"
BATCH_SIZE = 200
EMBED_BATCH_SIZE = 100


def get_qdrant() -> QdrantClient:
    return QdrantClient(url=QDRANT_ENDPOINT, api_key=QDRANT_API_KEY, timeout=120)


def get_embedding_model():
    logger.info("Loading bge-m3 model...")
    return SentenceTransformer("BAAI/bge-m3")


def create_collection(qdrant: QdrantClient, vector_size: int = 1024):
    try:
        qdrant.delete_collection(collection_name=COLLECTION_NAME)
        logger.info(f"Deleted existing collection: {COLLECTION_NAME}")
    except Exception as e:
        logger.warning(f"Collection delete failed (may not exist): {e}")

    qdrant.create_collection(
        collection_name=COLLECTION_NAME,
        vectors_config=VectorParams(size=vector_size, distance=Distance.COSINE),
    )
    logger.info(f"Created collection: {COLLECTION_NAME} with {vector_size}-dim vectors")

    qdrant.create_payload_index(
        collection_name=COLLECTION_NAME,
        field_name="band_overall",
        field_schema="float",
    )
    qdrant.create_payload_index(
        collection_name=COLLECTION_NAME,
        field_name="task_type",
        field_schema="keyword",
    )
    logger.info("Created payload indexes for band_overall and task_type")


def load_jsonl(file_path: str) -> list[dict]:
    docs = []
    with open(file_path) as f:
        for line in f:
            line = line.strip()
            if line:
                docs.append(json.loads(line))
    return docs


def main():
    logger.info(f"Starting ingestion from {DATA_FILE}...")

    qdrant = get_qdrant()

    docs = load_jsonl(DATA_FILE)
    logger.info(f"Loaded {len(docs):,} essays from JSONL")

    if not docs:
        logger.error("No documents found!")
        return

    create_collection(qdrant, vector_size=1024)

    model = get_embedding_model()

    total = len(docs)
    for i in tqdm(range(0, total, BATCH_SIZE), desc="Embedding & upserting"):
        batch = docs[i : i + BATCH_SIZE]

        texts = []
        for d in batch:
            text = d.get("text", "") or d.get("content", "")
            if not text:
                text = "[empty]"
            if len(text) > 8000:
                text = text[:8000]
            texts.append(text)

        embeddings = model.encode(
            texts, batch_size=EMBED_BATCH_SIZE, show_progress_bar=False
        )

        points = []
        for d, emb in zip(batch, embeddings):
            payload = {"text": d.get("text", ""), **d.get("metadata", {})}
            point = PointStruct(
                id=d["id"],
                vector=emb.tolist(),
                payload=payload,
            )
            points.append(point)

        qdrant.upsert(collection_name=COLLECTION_NAME, points=points)

        progress = min(i + BATCH_SIZE, total)
        logger.info(f"Upserted {progress:,}/{total:,} essays")

        del embeddings
        del texts
        gc.collect()

    info = qdrant.get_collection(COLLECTION_NAME)
    logger.info(
        f"✅ Ingestion complete! Collection has {info.points_count:,} points, {info.config.params.vectors.size}-dim vectors"
    )


if __name__ == "__main__":
    main()
