from fastapi import APIRouter
from qdrant_client import QdrantClient
from app.config import settings

router = APIRouter()


@router.get("/healthz")
async def healthz():
    try:
        client = QdrantClient(host=settings.qdrant_host, port=settings.qdrant_port, timeout=2)
        client.get_collections()
        qdrant_status = "ok"
    except Exception:
        qdrant_status = "unavailable"
    return {"status": "ok", "qdrant": qdrant_status}
