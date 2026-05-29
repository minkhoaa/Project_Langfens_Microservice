import logging
import time

from fastapi import HTTPException
from langchain_core.exceptions import OutputParserException

from app.config import settings
from app.prompts.writing_compare import WRITING_COMPARE_EXEMPLAR_PROMPT, WRITING_COMPARE_PROMPT
from app.schemas import CompareRequest, CompareResponse, ReferenceEssay, SentenceComparison
from app.services import llm_service, search_service
from app.services.search_service import build_reference_excerpts

logger = logging.getLogger(__name__)

VALID_CATEGORIES = {"vocabulary", "grammar", "coherence", "structure"}
VALID_SEVERITIES = {"low", "medium", "high"}


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
        severity = str(item.get("severity", "medium")).lower()
        
        if not original or not improved or not explanation:
            continue
        if category not in VALID_CATEGORIES:
            category = "vocabulary"
        if severity not in VALID_SEVERITIES:
            severity = "medium"
        
        parsed.append(SentenceComparison(
            original=original,
            improved=improved,
            explanation=explanation,
            category=category,
            severity=severity,
        ))
    return parsed


async def _search_with_fallback(
    topic: str, band_center: float, task_type: str, top_k: int = 2
) -> list:
    """Search for essays near band_center with progressive fallback.

    Embedding/search failures (e.g. Ollama embed model missing, Qdrant down)
    degrade to an empty list so the caller returns grading-only instead of a
    500/503 — comparison is augmentation, not core grading.
    """
    async def _safe(query: str, lo: float, hi: float) -> list:
        return await search_service.search_and_reassemble(
            collection=settings.qdrant_collection_writing,
            query=query,
            top_k=top_k,
            filters={
                "band_overall": {"gte": lo, "lte": hi},
                "task_type": task_type,
            },
        )

    try:
        results = await _safe(topic, band_center - 0.5, band_center + 0.5)
        if results:
            return results
        results = await _safe(topic, band_center - 1.0, band_center + 1.0)
        if results:
            return results
        return await _safe(task_type, band_center - 1.0, band_center + 1.0)
    except Exception as e:
        logger.warning("compare: RAG search failed (degrading to no references): %s", e)
        return []


def _extract_hints(references: list) -> dict:
    """Extract compact metadata hints from RAG results — no full essay text in prompt."""
    if not references:
        return {"reference_count": 0, "band_distribution": "none", "word_count_hints": "N/A",
                "vocab_hints": "N/A", "structure_hints": "N/A",
                "reference_excerpts": "No reference essays were retrieved for grounding."}

    bands = set()
    word_counts = []
    for r in references:
        b = r.metadata.get("band_overall", 0)
        w = r.metadata.get("word_count", 0)
        if b:
            bands.add(str(b))
        if w:
            word_counts.append(w)

    avg_words = sum(word_counts) // len(word_counts) if word_counts else 0

    return {
        "reference_count": len(references),
        "band_distribution": ", ".join(sorted(bands, key=float)) if bands else "unknown",
        "word_count_hints": f"~{avg_words} words average at higher bands (your essay should aim for 250+)",
        "vocab_hints": "Higher-band essays use more precise academic vocabulary, topic-specific terminology, "
                       "and avoid repetition through synonyms and paraphrase.",
        "structure_hints": "Higher-band essays have clear intro-body-conclusion structure, use cohesive devices "
                          "(however, furthermore, consequently), and develop each point with specific examples.",
        "reference_excerpts": build_reference_excerpts(references),
    }


async def compare_essay(req: CompareRequest) -> CompareResponse:
    student_band = req.student_band
    step_up_band = min(student_band + 0.5, 9.0)
    target_band = min(student_band + 1.5, 9.0)

    # Edge case: top band → exemplar mode
    if student_band >= 8.5:
        return await _compare_exemplar(req, student_band)

    t0 = time.time()
    # Dual query — RAG finds references, but only metadata flows to prompt
    step_up_refs = await _search_with_fallback(req.topic, step_up_band, req.task_type)
    target_refs = await _search_with_fallback(req.topic, target_band, req.task_type)
    t_search = time.time()
    logger.info("compare: search took %.1fms", (t_search - t0) * 1000)

    # Deduplicate references
    seen_ids = set()
    all_refs = []
    for r in step_up_refs + target_refs:
        if r.parent_id not in seen_ids:
            seen_ids.add(r.parent_id)
            all_refs.append(r)

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
        **_extract_hints(all_refs),
    }

    try:
        result = await llm_service.generate(
            prompt_template=WRITING_COMPARE_PROMPT,
            variables=variables,
            expect_json=True,
        )
    except OutputParserException as e:
        logger.warning("LLM call failed: %s", e)
        raise HTTPException(status_code=503, detail="Comparison service temporarily unavailable")
    except Exception as e:
        logger.warning("LLM call failed: %s", e)
        raise HTTPException(status_code=503, detail="Comparison service temporarily unavailable")

    # Missing sentence_comparisons is a soft failure: local models often omit it.
    # Degrade gracefully instead of failing the whole call — otherwise the caller
    # stores nothing and the FE polls until timeout.
    try:
        validate_sentence_comparisons_response(result)
    except ValueError as e:
        logger.warning("Validation failed: %s", e)
        result["sentence_comparisons"] = []
        existing = result.get("overall_analysis", "").strip()
        result["overall_analysis"] = (
            "LLM response validation failed; sentence comparisons unavailable. " + existing
        ).strip()

    t_llm = time.time()
    logger.info("compare: llm took %.1fms, total %.1fms", (t_llm - t_search) * 1000, (t_llm - t0) * 1000)

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
                id=r.parent_id,
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
        **_extract_hints(exemplar_refs),
        "exemplar_hints": "Band 9.0 essays use sophisticated vocabulary without artificial complexity, "
                          "demonstrate flawless grammar with varied complex structures, "
                          "and develop ideas with concrete examples and nuanced reasoning.",
    }

    try:
        result = await llm_service.generate(
            prompt_template=WRITING_COMPARE_EXEMPLAR_PROMPT,
            variables=variables,
            expect_json=True,
        )
    except OutputParserException as e:
        logger.warning("LLM call failed: %s", e)
        raise HTTPException(status_code=503, detail="Comparison service temporarily unavailable")
    except Exception as e:
        logger.warning("LLM call failed: %s", e)
        raise HTTPException(status_code=503, detail="Comparison service temporarily unavailable")

    # Missing sentence_comparisons is a soft failure: local models often omit it.
    # Degrade gracefully instead of failing the whole call — otherwise the caller
    # stores nothing and the FE polls until timeout.
    try:
        validate_sentence_comparisons_response(result)
    except ValueError as e:
        logger.warning("Validation failed: %s", e)
        result["sentence_comparisons"] = []
        existing = result.get("overall_analysis", "").strip()
        result["overall_analysis"] = (
            "LLM response validation failed; sentence comparisons unavailable. " + existing
        ).strip()

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
                id=r.parent_id,
                text=r.text,
                band=r.metadata.get("band_overall", 0),
                similarity_score=r.score,
            )
            for r in exemplar_refs
        ],
    )
