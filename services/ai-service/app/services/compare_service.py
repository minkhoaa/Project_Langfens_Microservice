import logging

from fastapi import HTTPException
from langchain_core.exceptions import OutputParserException

from app.config import settings
from app.prompts.writing_compare import WRITING_COMPARE_PROMPT
from app.schemas import CompareRequest, CompareResponse, ReferenceEssay, SentenceComparison
from app.services import gemini_service, search_service

logger = logging.getLogger(__name__)


def _format_references(references) -> str:
    parts = []
    for i, ref in enumerate(references, 1):
        band = ref.metadata.get("band_overall", "?")
        parts.append(f"--- Reference Essay {i} (Band {band}) ---\n{ref.text}")
    return "\n\n".join(parts)


async def compare_essay(req: CompareRequest) -> CompareResponse:
    # 1. Search by topic (not full essay — better for RETRIEVAL_QUERY embedding)
    references = await search_service.search(
        collection=settings.qdrant_collection_writing,
        query=req.topic,
        top_k=3,
        filters={"band_overall": req.band_filter, "task_type": req.task_type},
    )

    if not references:
        raise HTTPException(
            status_code=422,
            detail=f"No reference essays found for {req.task_type} with band≥{req.band_filter}",
        )

    # 2. Build prompt variables
    variables = {
        "student_essay": req.essay_text,
        "topic": req.topic,
        "reference_essays": _format_references(references),
    }

    # 3. Call Gemini via LangChain
    try:
        result = await gemini_service.generate(
            prompt_template=WRITING_COMPARE_PROMPT,
            variables=variables,
        )
    except (OutputParserException, Exception) as e:
        logger.warning(f"LLM call failed: {e}")
        result = {"overall_analysis": f"LLM returned unparseable response. Raw error: {e}"}

    # 4. Parse sentence comparisons safely
    raw_comparisons = result.get("sentence_comparisons", [])
    comparisons = []
    for sc in raw_comparisons:
        try:
            comparisons.append(SentenceComparison(**sc))
        except Exception:
            continue

    # 5. Build response
    return CompareResponse(
        overall_analysis=result.get("overall_analysis", ""),
        vocabulary_feedback=result.get("vocabulary_feedback", ""),
        coherence_feedback=result.get("coherence_feedback", ""),
        grammar_feedback=result.get("grammar_feedback", ""),
        task_response_feedback=result.get("task_response_feedback", ""),
        sentence_comparisons=comparisons,
        references=[
            ReferenceEssay(
                id=r.id,
                text=r.text[:300],
                band=r.metadata.get("band_overall", 0),
                similarity_score=r.score,
            )
            for r in references
        ],
    )
