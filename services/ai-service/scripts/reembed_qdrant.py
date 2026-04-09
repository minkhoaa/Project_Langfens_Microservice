#!/usr/bin/env python3
"""
Re-embed all essays from writing_samples_3072 to writing_samples using bge-m3.
"""

import os
import gc
import json
import logging
import time
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct
from sentence_transformers import SentenceTransformer

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)

QDRANT_ENDPOINT = os.getenv("QDRANT_ENDPOINT", "")
QDRANT_API_KEY = os.getenv("QDRANT_API_KEY", "")
SRC_COLLECTION = "writing_samples_3072"
DST_COLLECTION = "writing_samples"
BATCH_SIZE = 1000
EMBED_BATCH_SIZE = 1000


def get_qdrant() -> QdrantClient:
    return QdrantClient(url=QDRANT_ENDPOINT, api_key=QDRANT_API_KEY, timeout=180)


def get_embedding_model():
    logger.info("Loading bge-m3 model...")
    return SentenceTransformer("BAAI/bge-m3")


def main():
    logger.info(f"Re-embed: {SRC_COLLECTION} → {DST_COLLECTION}")
    
    qdrant = get_qdrant()
    
    # Get source count
    src_info = qdrant.get_collection(SRC_COLLECTION)
    total = src_info.points_count
    logger.info(f"Source: {total} essays")
    
    # Get destination count
    try:
        dst_info = qdrant.get_collection(DST_COLLECTION)
        done_count = dst_info.points_count
    except:
        qdrant.create_collection(
            collection_name=DST_COLLECTION,
            vectors_config=VectorParams(size=1024, distance=Distance.COSINE),
        )
        done_count = 0
    
    logger.info(f"Destination: {done_count} points already")
    
    if done_count >= total:
        logger.info("Already done!")
        return
    
    # Load model
    model = get_embedding_model()
    
    # Calculate how many to skip
    skip = done_count
    logger.info(f"Skipping first {skip} essays...")
    
    # Scroll to the offset we need
    offset = None
    for _ in range(skip // BATCH_SIZE):
        _, offset = qdrant.scroll(SRC_COLLECTION, limit=BATCH_SIZE, offset=offset, with_vectors=False)
        if offset is None:
            break
    
    logger.info("🎯 Starting embed + upsert...")
    
    processed = skip
    batch_num = 0
    
    while True:
        results, offset = qdrant.scroll(
            collection_name=SRC_COLLECTION,
            limit=BATCH_SIZE,
            offset=offset,
            with_vectors=False,
        )
        
        if not results:
            break
        
        # Prepare texts
        texts = []
        valid_results = []
        for point in results:
            text = point.payload.get("text", "") or point.payload.get("content", "")
            if not text:
                text = "[empty]"
            if len(text) > 8000:
                text = text[:8000]
            texts.append(text)
            valid_results.append(point)
        
        # Generate embeddings
        embeddings = model.encode(texts, batch_size=EMBED_BATCH_SIZE, show_progress_bar=False)
        
        # Upsert
        points = []
        for point, emb in zip(valid_results, embeddings):
            points.append(PointStruct(
                id=point.id,
                vector=emb.tolist(),
                payload=point.payload,
            ))
        
        qdrant.upsert(collection_name=DST_COLLECTION, points=points)
        
        processed += len(results)
        batch_num += 1
        logger.info(f"📊 {processed}/{total} essays")
        
        del embeddings, texts
        gc.collect()
        
        if offset is None:
            break
        
        time.sleep(0.2)
    
    logger.info(f"✅ Complete! Total: {processed} essays")


if __name__ == "__main__":
    main()
