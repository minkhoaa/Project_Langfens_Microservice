from fastapi import APIRouter

from app.config import settings
from app.schemas import SearchRequest, SearchResponse, CompareRequest, CompareResponse
from app.services import search_service, compare_service

router = APIRouter(prefix="/v1/writing")


@router.post("/search", response_model=SearchResponse)
async def writing_search(req: SearchRequest):
    results = await search_service.search(
        collection=settings.qdrant_collection_writing,
        query=req.query,
        top_k=req.top_k,
        filters=req.filters,
    )
    return SearchResponse(results=results, query=req.query, collection=settings.qdrant_collection_writing)


@router.post("/compare", response_model=CompareResponse)
async def writing_compare(req: CompareRequest):
    return await compare_service.compare_essay(req)
