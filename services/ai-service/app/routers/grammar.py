from fastapi import APIRouter

from app.config import settings
from app.schemas import SearchRequest, SearchResponse
from app.services import search_service

router = APIRouter(prefix="/v1/grammar")


@router.post("/search", response_model=SearchResponse)
async def grammar_search(req: SearchRequest):
    results = await search_service.search(
        collection=settings.qdrant_collection_grammar,
        query=req.query,
        top_k=req.top_k,
        filters=req.filters,
    )
    return SearchResponse(results=results, query=req.query, collection=settings.qdrant_collection_grammar)
