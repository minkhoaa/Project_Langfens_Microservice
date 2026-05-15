import json as json_lib
import logging
import time

from app.config import settings
from app.prompts.writing_grade import build_grade_prompt
from app.prompts.speaking_grade import build_speaking_prompt
from app.schemas import CriterionItem, ReassembledEssay, WritingGradeRequest, WritingGradeResponse
from app.schemas import SpeakingGradeRequest, SpeakingGradeResponse as SpeakingGradeResponseSchema, SpeakingCriterionResult
from app.services import llm_service, search_service

logger = logging.getLogger(__name__)


def _extract_grade_hints(references: list[ReassembledEssay]) -> dict:
    """Extract compact metadata hints from RAG results for the grading prompt."""
    if not references:
        return {
            "reference_count": 0,
            "band_distribution": "none",
            "word_count_hints": "N/A",
            "vocab_hints": "N/A",
            "structure_hints": "N/A",
        }

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
        "word_count_hints": (
            f"~{avg_words} words average in reference essays at similar bands "
            "(IELTS Task 2 requires min 250 words)"
        ),
        "vocab_hints": (
            "Higher-band essays use precise academic vocabulary, topic-specific terminology, "
            "and avoid repetition through synonyms and effective paraphrase."
        ),
        "structure_hints": (
            "Higher-band essays have a clear introduction-body-conclusion structure, "
            "use cohesive devices (however, furthermore, consequently), "
            "and develop each point with specific examples and well-developed reasoning."
        ),
    }


def _estimate_band_from_word_count(word_count: int) -> float:
    """
    Rough band estimate from word count alone (used only for RAG filter).
    Under 150 words → likely band 4-5.
    150-249 words → likely band 5-6 (below minimum, penalised).
    250-349 words → likely band 5.5-6.5.
    350+ words → likely band 6.5-7.5.
    Returns the centre of the expected range.
    """
    if word_count < 150:
        return 4.5
    elif word_count < 250:
        return 5.5
    elif word_count < 350:
        return 6.0
    else:
        return 7.0


async def grade_writing(req: WritingGradeRequest) -> WritingGradeResponse:
    """
    Grade an IELTS writing submission using RAG + LLM.

    Step 1: RAG lookup — search for reference essays at similar band level.
    Step 2: Build the grading prompt with RAG context.
    Step 3: Call LLM to produce band scores + feedback.
    Step 4: Parse and return WritingGradeResponse.
    """
    inferred_band = _estimate_band_from_word_count(req.word_count)

    # Step 1: RAG lookup
    t0 = time.time()
    try:
        refs = await search_service.search_and_reassemble(
            collection=settings.qdrant_collection_writing,
            query=req.task,
            top_k=3,
            filters={
                "band_overall": {"gte": inferred_band - 1.0, "lte": inferred_band + 1.0},
                "task_type": "TASK_2",
            },
        )
        rag_hints = _extract_grade_hints(refs)
    except Exception as exc:
        logger.warning("RAG lookup failed, proceeding without reference hints: %s", exc)
        rag_hints = _extract_grade_hints([])

    t_search = time.time()
    logger.info("grade: search took %.1fms", (t_search - t0) * 1000)

    # Step 2: Build prompt
    prompt = build_grade_prompt(
        task=req.task,
        essay=req.answer,
        word_count=req.word_count,
        rag_hints=rag_hints,
    )

    # Step 3: Call LLM
    try:
        result = await llm_service.generate(
            prompt_template="{prompt}",
            variables={"prompt": prompt},
            expect_json=True,
        )
    except Exception as exc:
        logger.warning("LLM call failed: %s", exc)
        result = {}

    t_llm = time.time()
    logger.info("grade: llm took %.1fms, total %.1fms", (t_llm - t_search) * 1000, (t_llm - t0) * 1000)

    # Step 4: Parse response into WritingGradeResponse
    if not result:
        return WritingGradeResponse(
            ob=0.0,
            ta=CriterionItem(b=0.0, c="LLM call failed. Please retry."),
            cc=CriterionItem(b=0.0, c=""),
            lr=CriterionItem(b=0.0, c=""),
            gr=CriterionItem(b=0.0, c=""),
            s=[],
            p="",
            raw_llm_json=json_lib.dumps({"error": "LLM call returned empty response"}),
        )

    # Safely extract values with defaults
    ob = result.get("ob", 0.0)
    ta_data = result.get("ta", {})
    cc_data = result.get("cc", {})
    lr_data = result.get("lr", {})
    gr_data = result.get("gr", {})
    suggestions = result.get("s", [])
    improved_para = result.get("p", "")

    return WritingGradeResponse(
        ob=float(ob) if ob else 0.0,
        ta=CriterionItem(
            b=float(ta_data.get("b", 0.0)) if ta_data.get("b") else 0.0,
            c=ta_data.get("c", "") if isinstance(ta_data, dict) else "",
        ),
        cc=CriterionItem(
            b=float(cc_data.get("b", 0.0)) if cc_data.get("b") else 0.0,
            c=cc_data.get("c", "") if isinstance(cc_data, dict) else "",
        ),
        lr=CriterionItem(
            b=float(lr_data.get("b", 0.0)) if lr_data.get("b") else 0.0,
            c=lr_data.get("c", "") if isinstance(lr_data, dict) else "",
        ),
        gr=CriterionItem(
            b=float(gr_data.get("b", 0.0)) if gr_data.get("b") else 0.0,
            c=gr_data.get("c", "") if isinstance(gr_data, dict) else "",
        ),
        s=suggestions if isinstance(suggestions, list) else [],
        p=str(improved_para) if improved_para else "",
        raw_llm_json=json_lib.dumps(result),
    )


async def grade_speaking(req: SpeakingGradeRequest) -> SpeakingGradeResponseSchema:
    """Grade an IELTS speaking submission using LLM (no RAG)."""
    import json as json_lib_inner

    t0 = time.time()

    # Build prompt
    prompt = build_speaking_prompt(req.task, req.transcript)

    # Call LLM via openai_like (groq/minimax with KeyManager)
    try:
        result = await llm_service.generate(
            prompt_template="{prompt}",
            variables={"prompt": prompt},
            expect_json=True,
        )
    except Exception as exc:
        logger.error("LLM speaking grading failed: %s", exc)
        raise

    t_llm = time.time()
    logger.info("grade_speaking: llm took %.1fms", (t_llm - t0) * 1000)

    # Parse response
    try:
        ob = float(result.get("ob", 6.0))
        return SpeakingGradeResponseSchema(
            ob=ob,
            fc=SpeakingCriterionResult(
                b=float(result.get("fc", {}).get("b", ob)),
                c=str(result.get("fc", {}).get("c", ""))),
            lr=SpeakingCriterionResult(
                b=float(result.get("lr", {}).get("b", ob)),
                c=str(result.get("lr", {}).get("c", ""))),
            gr=SpeakingCriterionResult(
                b=float(result.get("gr", {}).get("b", ob)),
                c=str(result.get("gr", {}).get("c", ""))),
            pr=SpeakingCriterionResult(
                b=float(result.get("pr", {}).get("b", ob)),
                c=str(result.get("pr", {}).get("c", ""))),
            s=result.get("s", []),
            p=str(result.get("p", "")),
            raw_llm_json=json_lib_inner.dumps(result),
        )
    except (ValueError, TypeError) as exc:
        logger.error("Failed to parse LLM speaking response: %s — raw: %s", exc, result)
        raise ValueError(f"Invalid LLM response format: {exc}")