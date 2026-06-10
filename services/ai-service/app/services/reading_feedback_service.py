import json
import logging
import time

from fastapi import HTTPException

from app.prompts.reading_explain import build_reading_prompt
from app.schemas.rag_feedback import (
    CriterionScore,
    Evidence,
    RagFeedbackEnvelope,
    Suggestion as EnvelopeSuggestion,
)
from app.schemas.reading import ReadingExplainRequest
from app.services import llm_service

logger = logging.getLogger(__name__)

async def explain_item(req: ReadingExplainRequest) -> RagFeedbackEnvelope:
    t0 = time.time()
    if not req.passage_text or len(req.passage_text.strip()) < 20:
        raise HTTPException(status_code=422, detail="passage_text is required and must be >= 20 chars")

    prompt = build_reading_prompt(
        question_type=req.question_type,
        passage=req.passage_text,
        question=req.question,
        options=req.options,
        user_answer=req.user_answer,
        correct_answer=req.correct_answer,
    )

    try:
        result = await llm_service.generate(
            prompt_template="{prompt}",
            variables={"prompt": prompt},
            expect_json=True,
        )
    except Exception as exc:
        logger.warning("reading explain LLM call failed: %s", exc)
        raise HTTPException(status_code=503, detail="Reading explainer temporarily unavailable")

    t_llm = time.time()
    logger.info("reading.explain: llm took %.1fms", (t_llm - t0) * 1000)

    band = float(result.get("criterion_band", 0.0)) or 0.0
    explanation = str(result.get("explanation", "")).strip()
    quote = str(result.get("passage_quote", "")).strip()
    distractor = str(result.get("distractor_analysis", "")).strip()
    suggestions_raw = result.get("suggestions", [])
    if not isinstance(suggestions_raw, list):
        suggestions_raw = []

    # Build evidence: at minimum the passage quote. The distractor analysis is
    # preserved in the criterion comment rather than as a separate evidence item,
    # so the envelope carries exactly one passage-anchored evidence per item.
    evidence: list[Evidence] = []
    if quote:
        evidence.append(Evidence(
            id=f"passage:{req.item_id}:quote",
            text=quote[:2000],
            source="passage:inline",
            relevance=1.0,
        ))
    if distractor:
        # Inline distractor commentary stays in the LLM raw JSON for transparency.
        pass

    return RagFeedbackEnvelope(
        item_id=req.item_id,
        domain="reading",
        overall_band=band,
        criteria=[CriterionScore(
            name="comprehension",
            band=band,
            comment=explanation or "(no explanation)",
            evidence_ids=[e.id for e in evidence],
        )],
        evidence=evidence,
        suggestions=[
            EnvelopeSuggestion(text=str(s), target="comprehension")
            for s in suggestions_raw
            if isinstance(s, str) and s.strip()
        ],
        raw_llm_json=json.dumps(result),
    )
