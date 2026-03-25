from fastapi import APIRouter

from app.config import settings
from app.schemas import (
    GrammarBatchExplainRequest,
    GrammarBatchExplainResponse,
    GrammarExplainRequest,
    GrammarExplainResponse,
    SearchRequest,
    SearchResponse,
)
from app.services import grammar_service, search_service

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


@router.post("/explain", response_model=GrammarExplainResponse)
async def grammar_explain(req: GrammarExplainRequest):
    return await grammar_service.explain_single(req)


@router.post("/batch-explain", response_model=GrammarBatchExplainResponse)
async def grammar_batch_explain(req: GrammarBatchExplainRequest):
    return await grammar_service.explain_batch(req.errors, req.max_concurrent)
