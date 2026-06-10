import json as json_lib
import logging
import time

from fastapi import HTTPException

from app.config import settings
from app.core import get_guardrails
from app.prompts.writing_grade import build_grade_prompt
from app.prompts.speaking_grade import build_speaking_prompt
from app.schemas import CriterionItem, ReassembledEssay, WritingGradeRequest, WritingGradeResponse
from app.schemas import SpeakingGradeRequest, SpeakingGradeResponse as SpeakingGradeResponseSchema, SpeakingCriterionResult
from app.services import llm_service, search_service, qwen_service

logger = logging.getLogger(__name__)


def _extract_grade_hints(references: list[ReassembledEssay], task_type: str = "TASK_2") -> dict:
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
    min_words = "150" if task_type == "TASK_1" else "250"

    if task_type == "TASK_1":
        structure_hints = (
            "Higher-band Task 1 responses have a clear overview paragraph identifying main trends/features, "
            "use cohesive devices for comparisons (in contrast, similarly, by comparison), "
            "and group data logically with accurate reporting of key figures."
        )
    else:
        structure_hints = (
            "Higher-band essays have a clear introduction-body-conclusion structure, "
            "use cohesive devices (however, furthermore, consequently), "
            "and develop each point with specific examples and well-developed reasoning."
        )

    return {
        "reference_count": len(references),
        "band_distribution": ", ".join(sorted(bands, key=float)) if bands else "unknown",
        "word_count_hints": (
            f"~{avg_words} words average in reference essays at similar bands "
            f"(IELTS {task_type.replace('_', ' ')} requires min {min_words} words)"
        ),
        "vocab_hints": (
            "Higher-band essays use precise academic vocabulary, topic-specific terminology, "
            "and avoid repetition through synonyms and effective paraphrase."
        ),
        "structure_hints": structure_hints,
    }


def _estimate_band_from_word_count(word_count: int, task_type: str = "TASK_2") -> float:
    """
    Rough band estimate from word count alone (used only for RAG filter).
    Task 1 min = 150 words, Task 2 min = 250 words.
    Returns the centre of the expected range.
    """
    if task_type == "TASK_1":
        if word_count < 100:
            return 4.5
        elif word_count < 150:
            return 5.5
        elif word_count < 200:
            return 6.0
        else:
            return 7.0
    else:
        if word_count < 150:
            return 4.5
        elif word_count < 250:
            return 5.5
        elif word_count < 350:
            return 6.0
        else:
            return 7.0


async def grade_writing(req: WritingGradeRequest) -> WritingGradeResponse:
    """Grade an IELTS writing submission using per-criterion RAG + LLM.

    Step 1: Per-criterion RAG (4 parallel searches: ta, cc, lr, gr).
    Step 2: Build the grading prompt with per-criterion evidence block.
    Step 3: Call LLM to produce band scores + evidence_ids + feedback.
    Step 4: Parse into WritingGradeResponse with both flat fields and envelope.
    """
    t0 = time.time()
    # Step 1: Per-criterion RAG
    from app.services import per_criterion_rag
    try:
        rag_by_criterion = await per_criterion_rag.retrieve(req.task, req.task_type)
    except Exception as exc:
        logger.warning("per_criterion_rag failed, proceeding without evidence: %s", exc)
        rag_by_criterion = {"ta": [], "cc": [], "lr": [], "gr": []}

    t_search = time.time()
    logger.info("grade: per-criterion search took %.1fms", (t_search - t0) * 1000)

    # Step 2: Build prompt
    from app.prompts.writing_grade_criterion import build_grade_prompt_criterion
    prompt = build_grade_prompt_criterion(
        task=req.task,
        essay=req.answer,
        word_count=req.word_count,
        rag_by_criterion=rag_by_criterion,
        task_type=req.task_type,
        chart_description=req.chart_description,
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

    try:
        estimated_tokens = len(prompt) // 4 + 500
        get_guardrails().record_api_call(
            provider="llm",
            model="grade",
            tokens_used=estimated_tokens,
            cost=estimated_tokens * 0.000002,
        )
    except Exception:
        pass

    # Step 4: Parse response into WritingGradeResponse
    if not result:
        raise HTTPException(status_code=503, detail="LLM grading temporarily unavailable, please retry")

    ob = float(result.get("ob", 0.0)) or 0.0
    ta_data = result.get("ta", {})
    cc_data = result.get("cc", {})
    lr_data = result.get("lr", {})
    gr_data = result.get("gr", {})
    suggestions = result.get("s", [])
    improved_para = result.get("p", "")

    # Build the shared envelope from the same data.
    from app.schemas.rag_feedback import (
        CriterionScore,
        Evidence,
        RagFeedbackEnvelope,
        Suggestion as EnvelopeSuggestion,
    )

    def _crit(name: str, data: dict) -> CriterionScore:
        if not isinstance(data, dict):
            data = {}
        raw_ids = data.get("evidence_ids", [])
        if not isinstance(raw_ids, list):
            raw_ids = []
        return CriterionScore(
            name=name,
            band=float(data.get("b", 0.0)) or 0.0,
            comment=str(data.get("c", "")).strip(),
            evidence_ids=[str(i) for i in raw_ids if isinstance(i, (str, int))],
        )

    envelope = RagFeedbackEnvelope(
        item_id=f"writing-{req.task_type}",
        domain="writing",
        overall_band=ob,
        criteria=[
            _crit("task_response", ta_data),
            _crit("coherence", cc_data),
            _crit("lexical_resource", lr_data),
            _crit("grammatical_range", gr_data),
        ],
        evidence=[],  # refs live in Qdrant; we don't dump full text into the envelope
        suggestions=[
            EnvelopeSuggestion(text=str(s), target="writing")
            for s in (suggestions if isinstance(suggestions, list) else [])
        ],
        raw_llm_json=json_lib.dumps(result),
    )

    return WritingGradeResponse(
        ob=ob,
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
        envelope=envelope,
    )


async def grade_speaking(req: SpeakingGradeRequest) -> SpeakingGradeResponseSchema:
    """Grade an IELTS speaking submission using LLM (no RAG)."""
    import json as json_lib_inner

    t0 = time.time()

    # Build prompt
    prompt = build_speaking_prompt(req.task, req.transcript)

    # Call local LoRA (qwen2.5-lora)
    try:
        result = await qwen_service.qwen_generate(
            prompt=prompt,
            expect_json=True,
        )
    except Exception as exc:
        logger.error("LLM speaking grading failed: %s", exc)
        raise HTTPException(status_code=503, detail="LLM grading temporarily unavailable, please retry")

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
        raise HTTPException(status_code=502, detail="Failed to parse LLM response")