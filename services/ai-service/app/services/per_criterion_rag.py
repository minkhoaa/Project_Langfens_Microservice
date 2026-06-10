"""Per-criterion RAG retrieval for writing grading.

Runs 4 parallel Qdrant searches (one per IELTS criterion) with
criterion-tuned query strings. Reuses the existing
search_and_reassemble primitive so the cache, index, and
failure-degradation logic are shared with the rest of the service.
"""
import asyncio
import logging
from typing import Literal

from app.config import settings
from app.schemas import ReassembledEssay
from app.services import search_service

logger = logging.getLogger(__name__)

# Query templates per criterion. The base task is appended to each.
CRITERION_QUERIES: dict[str, str] = {
    "ta": "paragraph structure introduction body conclusion task response position",
    "cc": "coherence cohesive devices however furthermore consequently linking words",
    "lr": "academic vocabulary collocations precise synonyms paraphrase topic-specific",
    "gr": "complex sentence structures subordinate clauses passive voice conditionals accuracy",
}

async def _retrieve_one(criterion: str, task: str, task_type: str) -> list[ReassembledEssay]:
    """One criterion's worth of RAG. Failures degrade to []."""
    query = f"{task} {CRITERION_QUERIES[criterion]}"
    filters = {
        "criterion": criterion,
        "task_type": task_type,
        # Inherit the existing band-range filter used by grade_writing.
        # The grade_service is expected to override inferred_band via
        # this same dict; we pass a wide default here and let the caller
        # merge its own band filter if needed.
    }
    try:
        return await search_service.search_and_reassemble(
            collection=settings.qdrant_collection_writing,
            query=query,
            top_k=3,
            filters=filters,
        )
    except Exception as exc:
        logger.warning("per_criterion_rag: %s query failed: %s", criterion, exc)
        return []

async def retrieve(task: str, task_type: str) -> dict[str, list[ReassembledEssay]]:
    """Run the 4 criterion RAG queries in parallel."""
    criteria: tuple[Literal["ta", "cc", "lr", "gr"], ...] = ("ta", "cc", "lr", "gr")
    results = await asyncio.gather(
        *(_retrieve_one(c, task, task_type) for c in criteria),
        return_exceptions=False,
    )
    return dict(zip(criteria, results))
