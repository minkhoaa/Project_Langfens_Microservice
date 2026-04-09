from fastapi import APIRouter

from app.services.qdrant_factory import get_qdrant_client
from app.services.openai_like_service import get_llm_key_status

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


@router.get("/llm-keys-status")
async def llm_keys_status():
    """Get status of LLM API keys (for monitoring key rotation)."""
    return get_llm_key_status()
