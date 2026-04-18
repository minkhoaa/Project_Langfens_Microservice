from fastapi import APIRouter

from app.services import llm_service
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
    return {
        "status": "ok",
        "qdrant": qdrant_status,
        "llm": llm_service.get_runtime_status(),
    }


@router.get("/llm-keys-status")
async def llm_keys_status():
    """Backward-compatible runtime status endpoint."""
    return llm_service.get_runtime_status()


@router.get("/llm-status")
async def llm_status():
    """Get the active LLM runtime status."""
    return llm_service.get_runtime_status()
