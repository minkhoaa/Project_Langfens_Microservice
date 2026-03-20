from fastapi import APIRouter

from app.services.qdrant_factory import get_qdrant_client

router = APIRouter()


@router.get("/healthz")
async def healthz():
    try:
        client = get_qdrant_client()
        client.get_collections()
        qdrant_status = "ok"
    except Exception:
        qdrant_status = "unavailable"
    return {"status": "ok", "qdrant": qdrant_status}
