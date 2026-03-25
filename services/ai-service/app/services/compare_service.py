import logging

from fastapi import HTTPException
from langchain_core.exceptions import OutputParserException

from app.config import settings
from app.prompts.writing_compare import WRITING_COMPARE_EXEMPLAR_PROMPT, WRITING_COMPARE_PROMPT
from app.schemas import CompareRequest, CompareResponse, ReferenceEssay, SentenceComparison
from app.services import gemini_service, search_service

logger = logging.getLogger(__name__)

VALID_CATEGORIES = {"vocabulary", "grammar", "coherence", "structure"}


def validate_sentence_comparisons_response(result: dict) -> dict:
    """
    Validate that the LLM response contains the required sentence_comparisons field.
    
    Returns the result unchanged if sentence_comparisons key exists (even if empty list).
    Raises ValueError if the key is completely missing from the response.
    """
    if "sentence_comparisons" not in result:
        logger.warning("LLM response missing required field: sentence_comparisons")
        raise ValueError("LLM response missing required field: sentence_comparisons")
    return result


def _parse_sentence_comparisons(raw_comparisons: list, max_items: int = 5) -> list[SentenceComparison]:
    """Parse and validate sentence comparisons from LLM response."""
    if not raw_comparisons:
        return []
    
    parsed = []
    for item in raw_comparisons[:max_items]:
        if not isinstance(item, dict):
            continue
        original = item.get("original", "").strip()
        improved = item.get("improved", "").strip()
        explanation = item.get("explanation", "").strip()
        category = item.get("category", "vocabulary").lower()
        
        if not original or not improved or not explanation:
            continue
        if category not in VALID_CATEGORIES:
            category = "vocabulary"
        
        parsed.append(SentenceComparison(
            original=original,
            improved=improved,
            explanation=explanation,
            category=category,
        ))
    return parsed


async def _search_with_fallback(
    topic: str, band_center: float, task_type: str, top_k: int = 2
) -> list:
    """Search for essays near band_center with progressive fallback."""
    # Attempt 1: topic + band ±0.5
    results = await search_service.search(
        collection=settings.qdrant_collection_writing,
        query=topic,
        top_k=top_k,
        filters={
            "band_overall": {"gte": band_center - 0.5, "lte": band_center + 0.5},
            "task_type": task_type,
        },
    )
    if results:
        return results

    # Attempt 2: topic + band ±1.0
    results = await search_service.search(
        collection=settings.qdrant_collection_writing,
        query=topic,
        top_k=top_k,
        filters={
            "band_overall": {"gte": band_center - 1.0, "lte": band_center + 1.0},
            "task_type": task_type,
        },
    )
    if results:
        return results

    # Attempt 3: same task_type + band only (no topic similarity)
    results = await search_service.search(
        collection=settings.qdrant_collection_writing,
        query=task_type,
        top_k=top_k,
        filters={
            "band_overall": {"gte": band_center - 1.0, "lte": band_center + 1.0},
            "task_type": task_type,
        },
    )
    return results


def _format_references(references: list, label: str) -> str:
    if not references:
        return f"(No {label} references available)"
    parts = []
    for i, ref in enumerate(references, 1):
        band = ref.metadata.get("band_overall", "?")
        parts.append(f"--- {label} Essay {i} (Band {band}) ---\n{ref.text}")
    return "\n\n".join(parts)


async def compare_essay(req: CompareRequest) -> CompareResponse:
    student_band = req.student_band
    step_up_band = min(student_band + 1.0, 9.0)
    target_band = min(student_band + 2.0, 9.0)

    # Edge case: top band → exemplar mode
    if student_band >= 8.5:
        return await _compare_exemplar(req, student_band)

    # Dual query
    step_up_refs = await _search_with_fallback(req.topic, step_up_band, req.task_type)
    target_refs = await _search_with_fallback(req.topic, target_band, req.task_type)

    all_refs = step_up_refs + target_refs
    if not all_refs:
        return CompareResponse(
            overall_analysis="No reference essays found for comparison at this band level and topic.",
            step_up_band=step_up_band,
            target_band=target_band,
            no_references_found=True,
        )

    variables = {
        "student_essay": req.essay_text,
        "topic": req.topic,
        "student_band": str(student_band),
        "step_up_band": str(step_up_band),
        "target_band": str(target_band),
        "step_up_references": _format_references(step_up_refs, "Step-up"),
        "target_references": _format_references(target_refs, "Target"),
    }

    try:
        result = await gemini_service.generate(
            prompt_template=WRITING_COMPARE_PROMPT,
            variables=variables,
        )
        validate_sentence_comparisons_response(result)
    except ValueError as e:
        logger.warning(f"Validation failed: {e}")
        result = {"overall_analysis": f"LLM response validation failed. Raw error: {e}"}
    except (OutputParserException, Exception) as e:
        logger.warning(f"LLM call failed: {e}")
        result = {"overall_analysis": f"LLM returned unparseable response. Raw error: {e}"}

    return CompareResponse(
        overall_analysis=result.get("overall_analysis", ""),
        vocabulary_feedback=result.get("vocabulary_feedback", ""),
        coherence_feedback=result.get("coherence_feedback", ""),
        grammar_feedback=result.get("grammar_feedback", ""),
        task_response_feedback=result.get("task_response_feedback", ""),
        step_up_band=step_up_band,
        target_band=target_band,
        step_up_analysis=result.get("step_up_analysis", ""),
        target_analysis=result.get("target_analysis", ""),
        key_improvements=result.get("key_improvements", []),
        sentence_comparisons=_parse_sentence_comparisons(result.get("sentence_comparisons", [])),
        references=[
            ReferenceEssay(
                id=r.id,
                text=r.text,
                band=r.metadata.get("band_overall", 0),
                similarity_score=r.score,
            )
            for r in all_refs
        ],
    )


async def _compare_exemplar(req: CompareRequest, student_band: float) -> CompareResponse:
    """Exemplar mode for Band 8.5-9.0 students."""
    exemplar_refs = await _search_with_fallback(req.topic, 9.0, req.task_type)

    if not exemplar_refs:
        return CompareResponse(
            overall_analysis="No Band 9.0 exemplar essays found for this topic.",
            step_up_band=9.0,
            target_band=9.0,
            no_references_found=True,
        )

    variables = {
        "student_essay": req.essay_text,
        "topic": req.topic,
        "student_band": str(student_band),
        "exemplar_references": _format_references(exemplar_refs, "Exemplar"),
    }

    try:
        result = await gemini_service.generate(
            prompt_template=WRITING_COMPARE_EXEMPLAR_PROMPT,
            variables=variables,
        )
        validate_sentence_comparisons_response(result)
    except ValueError as e:
        logger.warning(f"Validation failed: {e}")
        result = {"overall_analysis": f"LLM response validation failed. Raw error: {e}"}
    except (OutputParserException, Exception) as e:
        logger.warning(f"LLM call failed: {e}")
        result = {"overall_analysis": f"LLM returned unparseable response. Raw error: {e}"}

    return CompareResponse(
        overall_analysis=result.get("overall_analysis", ""),
        vocabulary_feedback=result.get("vocabulary_feedback", ""),
        coherence_feedback=result.get("coherence_feedback", ""),
        grammar_feedback=result.get("grammar_feedback", ""),
        task_response_feedback=result.get("task_response_feedback", ""),
        step_up_band=9.0,
        target_band=9.0,
        step_up_analysis=result.get("step_up_analysis", ""),
        target_analysis="",
        key_improvements=result.get("key_improvements", []),
        sentence_comparisons=_parse_sentence_comparisons(result.get("sentence_comparisons", [])),
        references=[
            ReferenceEssay(
                id=r.id,
                text=r.text,
                band=r.metadata.get("band_overall", 0),
                similarity_score=r.score,
            )
            for r in exemplar_refs
        ],
    )
