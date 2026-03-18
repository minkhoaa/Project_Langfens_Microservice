import requests
from app.config import settings

EMBEDDING_DIM = 768
_BASE = f"https://generativelanguage.googleapis.com/v1beta/{settings.gemini_embedding_model}"


def _post(url: str, payload: dict) -> dict:
    resp = requests.post(url, json=payload, params={"key": settings.gemini_api_key}, timeout=60)
    resp.raise_for_status()
    return resp.json()


async def embed_texts(texts: list[str]) -> list[list[float]]:
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


async def embed_query(text: str) -> list[float]:
    data = _post(
        f"{_BASE}:embedContent",
        {
            "model": settings.gemini_embedding_model,
            "content": {"parts": [{"text": text}]},
            "taskType": "RETRIEVAL_QUERY",
            "outputDimensionality": EMBEDDING_DIM,
        },
    )
    return data["embedding"]["values"]
