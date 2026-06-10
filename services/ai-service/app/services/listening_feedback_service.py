import json
import logging
import time

from fastapi import HTTPException

from app.config import settings
from app.prompts.listening_explain import build_listening_prompt
from app.schemas.rag_feedback import (
    CriterionScore,
    Evidence,
    RagFeedbackEnvelope,
    Suggestion as EnvelopeSuggestion,
)
from app.schemas.listening import ListeningExplainRequest
from app.services import llm_service, search_service

logger = logging.getLogger(__name__)

async def _corpus_hints(question: str, question_type: str, section: int) -> str:
    """1-2 retrieved listening_samples entries as inline hints. Empty on failure."""
    try:
        results = await search_service.search(
            collection=settings.qdrant_collection_listening,
            query=f"{question_type} section {section} {question}",
            top_k=2,
            filters={"section": str(section)},
        )
        if not results:
            return ""
        parts: list[str] = []
        for r in results:
            meta = r.metadata or {}
            topic = meta.get("topic", "unknown")
            parts.append(f"--- {r.id} (topic: {topic}) ---\n{(r.text or '')[:400]}")
        return "\n\n".join(parts)
    except Exception as exc:
        logger.warning("listening corpus RAG failed, continuing without hints: %s", exc)
        return ""

async def explain_item(req: ListeningExplainRequest) -> RagFeedbackEnvelope:
    t0 = time.time()
    if not req.transcript or len(req.transcript.strip()) < 20:
        raise HTTPException(status_code=422, detail="transcript is required and must be >= 20 chars")

    corpus_hints = await _corpus_hints(req.question, req.question_type, req.section)

    prompt = build_listening_prompt(
        question_type=req.question_type,
        transcript=req.transcript,
        question=req.question,
        options=req.options,
        user_answer=req.user_answer,
        correct_answer=req.correct_answer,
        section=req.section,
        corpus_hints=corpus_hints or None,
    )

    try:
        result = await llm_service.generate(
            prompt_template="{prompt}",
            variables={"prompt": prompt},
            expect_json=True,
        )
    except Exception as exc:
        logger.warning("listening explain LLM call failed: %s", exc)
        raise HTTPException(status_code=503, detail="Listening explainer temporarily unavailable")

    t_llm = time.time()
    logger.info("listening.explain: llm took %.1fms", (t_llm - t0) * 1000)

    band = float(result.get("criterion_band", 0.0)) or 0.0
    explanation = str(result.get("explanation", "")).strip()
    quote = str(result.get("transcript_quote", "")).strip()
    suggestions_raw = result.get("suggestions", [])
    if not isinstance(suggestions_raw, list):
        suggestions_raw = []

    evidence: list[Evidence] = []
    if quote:
        evidence.append(Evidence(
            id=f"transcript:{req.item_id}:quote",
            text=quote[:2000],
            source="transcript:inline",
            relevance=1.0,
        ))
    if corpus_hints:
        evidence.append(Evidence(
            id=f"listening_corpus:{req.item_id}",
            text=corpus_hints[:2000],
            source=settings.qdrant_collection_listening,
            relevance=0.6,
        ))

    return RagFeedbackEnvelope(
        item_id=req.item_id,
        domain="listening",
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
