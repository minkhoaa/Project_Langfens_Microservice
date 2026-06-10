import json as json_lib
import logging
import re
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

# Rule-shape hint -> category label. Used when a Qdrant rule's metadata
# lacks a `category` field (older ingestion, or external collection).
# Match order: most specific phrase wins. Lower-cased inputs.
_CATEGORY_HINTS: list[tuple[str, str]] = [
    (r"subject[-\s]?verb|sv\s+agreement|subject\s+and\s+verb", "subject-verb"),
    (r"\barticle(s)?\b|a\s*/\s*an\s*/\s*the", "article"),
    (r"\btense(s)?\b|\bpresent simple\b|\bpresent perfect\b|\bpast simple\b", "tense"),
    (r"\bconditional(s)?\b|\bif[- ]clause\b", "conditional"),
    (r"\bpreposition(s)?\b|\bprepositional\b", "preposition"),
    (r"\bpronoun(s)?\b|\breflexive\b", "pronoun"),
    (r"\bword order\b|\binversion\b", "word-order"),
    (r"\bpunctuation\b|\bcomma(s)?\b|\bapostrophe\b", "punctuation"),
    (r"\bcollocation(s)?\b|\bphrasal verb\b", "collocation"),
    (r"\bparallel(ism)?\b|\bparallel structure\b", "parallelism"),
    (r"\bpassive voice\b|\bactive voice\b", "passive-voice"),
    (r"\brelative clause\b|\bsubordinate clause\b|\bsubordination\b", "subordination"),
    (r"\bplural(s)?\b|\bsingular\b|\bcountable\b|\buncountable\b", "plural"),
]

def _derive_grammar_category(rule) -> str:
    """Best-effort category for a grammar rule, used to label the FE pill.

    Priority: explicit metadata.category (set by the built-in fallback set)
    > rule id prefix (e.g. 'fallback-sv' -> 'subject-verb')
    > first matching phrase in the rule text
    > generic 'grammar'.
    """
    meta = getattr(rule, "metadata", None) or {}
    cat = meta.get("category")
    if cat:
        return str(cat)

    rid = str(getattr(rule, "id", "") or "").lower()
    if rid.startswith("fallback-"):
        short = rid[len("fallback-"):]
        aliases = {"sv": "subject-verb", "prep": "preposition"}
        return aliases.get(short, short)

    text = (getattr(rule, "text", "") or "").lower()
    if not text:
        return "grammar"
    for pattern, label in _CATEGORY_HINTS:
        if re.search(pattern, text):
            return label
    return "grammar"


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

    Note: this function returns the LENGTH-CEILING estimate. Very short
    essays (<60 words) cannot score above Band 2 regardless of grammar
    quality, because there is not enough text to demonstrate task
    response at any band ≥ 3. The official IELTS Band 3+ descriptor
    requires "some relevant ideas" with "some detail" — impossible in
    9 words. Callers that need a length FLOOR (i.e. "this short essay
    cannot be Band 4+") should apply the per-bucket caps below
    rather than using the raw return value.
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

# Length-based band FLOOR (not ceiling). A 10-word essay cannot score
# Band 4+ regardless of how clean it is, because IELTS task response
# at Band 4+ requires "addresses the task" with "some relevant detail"
# — not possible in 10 words. Used by the regex fallback to override
# the length-CEILING estimate from _estimate_band_from_word_count.
def _length_floor(word_count: int) -> float:
    if word_count < 30:
        return 1.0
    if word_count < 60:
        return 2.0
    if word_count < 100:
        return 3.0
    return 0.0  # no floor above 100 words; estimator handles normally

# Lightweight regex-based grammar/error density check. Used as a FALLBACK
# for the band estimator when the LLM call is unavailable. NOT a substitute
# for the LLM's per-criterion grammar judgment — it only catches the most
# common ESL patterns that appear at Band 3-4. Returns a count of
# suspicious patterns.
_ERROR_PATTERNS = [
    (r"\b(is|are|was|were)\s+(very|many|much|more|most)\b", "verb + degree-word"),
    (r"\b(many|most|some|all)\s+(is|was|has)\b", "plural-subject + singular-verb"),
    (r"\bI\s+am\s+(agree|think|believe|sure)\b", "I am + bare-verb"),
    (r"\b(he|she|it|child|people|they)\s+(go|do|have|make|take|come)\b", "3sg-subject + bare-verb"),
    (r"\b(is|are|was|were)\s+(go|do|have|make|take|come|say|see)\b", "copula + bare-verb"),
    (r"\bvery\s+(very|so|much)\b", "stacked intensifier"),
    (r"\b(in|on|at)\s+future\b", "wrong-preposition: future"),
    (r"\bpeople\s+is\b", "people is"),
    (r"\bchild(ren)?\s+(use|play|go|want|not)\b", "child + bare-verb"),
    (r"^\s*[A-Z][^.!?]*\.\s+[a-z]", "sentence-start after period not capitalised"),
    (r"\b(a)\s+[aeiouAEIOU]", "a + vowel (missing 'an')"),
    (r"\b(an)\s+[^aeiouAEIOU\s]", "an + consonant (missing 'a')"),
]

def _grammar_error_density(essay: str) -> float:
    """Return error-pattern hits per 100 words. Capped at 10.0 to avoid blowup."""
    if not essay:
        return 0.0
    words = max(1, len(essay.split()))
    import re as _re
    hits = 0
    for pat, _name in _ERROR_PATTERNS:
        hits += len(_re.findall(pat, essay, flags=_re.IGNORECASE | _re.MULTILINE))
    return min(10.0, (hits / words) * 100.0)

async def _estimate_band_with_llm(req: "WritingGradeRequest") -> tuple[float, dict]:
    """LLM-derived band estimate using a large model (gpt-oss-120b).

    The estimator is called BEFORE the full grading LLM. Its output is used
    to scope the RAG band filter and to clamp the full grader's return —
    so a Band 3 essay cannot be inflated to Band 6 via RAG anchoring.

    Falls back to a regex-density estimator if the LLM call fails (network,
    rate limit, malformed response). Returns (band_estimate, debug_info).
    """
    from app.prompts.band_estimate import build_band_estimate_prompt

    prompt = build_band_estimate_prompt(req.task, req.answer)
    debug: dict = {
        "estimator": "llm:gpt-oss-120b",
        "word_count": req.word_count or 0,
    }
    try:
        result = await llm_service.generate(
            prompt_template="{prompt}",
            variables={"prompt": prompt},
            expect_json=True,
            model_size="xlarge",  # gpt-oss-120b
            max_tokens=128,
            temperature=0.1,
        )
        if not isinstance(result, dict):
            raise ValueError(f"estimator returned non-dict: {type(result).__name__}")
        raw = result.get("band")
        if raw is None:
            raise ValueError("estimator returned no 'band' key")
        raw = float(raw)
        # Snap to 0.5 grid
        snapped = round(raw * 2) / 2
        snapped = max(0.0, min(9.0, snapped))
        debug["raw_band"] = raw
        debug["snapped_band"] = snapped
        debug["reason"] = str(result.get("reason", ""))[:200]
        return snapped, debug
    except Exception as exc:
        logger.warning("band_estimate LLM call failed (%s); falling back to regex density", exc)
        # Fallback: word-count + regex-density heuristic, floored by length.
        # The length floor mirrors the official IELTS Band 0-2 descriptors
        # for responses that are "largely irrelevant" or show "no
        # communication of message" — these cannot be Band 3+ regardless
        # of how clean the (very short) text is.
        wc = req.word_count or 0
        length_floor = _length_floor(wc)
        if length_floor > 0.0:
            # Short essay: the length floor dominates. The word-count
            # ceiling is meaningless when the essay is too short to
            # demonstrate task response. We still apply the regex penalty
            # to flag particularly bad short essays, but capped at 0
            # (penalty cannot push the score below the length floor).
            estimate = length_floor
        else:
            wc_estimate = _estimate_band_from_word_count(wc, req.task_type)
            density = _grammar_error_density(req.answer or "")
            penalty = min(2.0, max(0.0, density * 0.7))
            estimate = max(length_floor, wc_estimate - penalty)
        debug["estimator"] = "fallback:word_count+regex"
        debug["wc_estimate"] = _estimate_band_from_word_count(wc, req.task_type)
        debug["length_floor"] = length_floor
        debug["grammar_density_per_100w"] = round(_grammar_error_density(req.answer or ""), 2)
        debug["final_estimate"] = round(estimate, 1)
        return round(estimate * 2) / 2, debug


async def grade_writing(req: WritingGradeRequest) -> WritingGradeResponse:
    """Grade an IELTS writing submission using per-criterion RAG + LLM.

    Step 1: Per-criterion RAG (4 parallel searches: ta, cc, lr, gr).
    Step 2: Build the grading prompt with per-criterion evidence block.
    Step 3: Call LLM to produce band scores + evidence_ids + feedback.
    Step 4: Parse into WritingGradeResponse with both flat fields and envelope.
    """
    t0 = time.time()
    # Step 0: LLM-derived band estimate using a large model (gpt-oss-120b).
    # The estimator sees ONLY the essay text — no RAG, no rubric, no
    # references — so it cannot anchor to high-band exemplars. Its output
    # is the floor the full grader's LLM cannot exceed by more than +1.0.
    band_estimate, estimate_debug = await _estimate_band_with_llm(req)
    logger.info("grade: LLM band estimate=%s (debug=%s)", band_estimate, estimate_debug)

    # Step 1: Per-criterion RAG. Pass band_estimate so the RAG band_overall
    # filter is scoped to the student's actual level, not the corpus top.
    from app.services import per_criterion_rag
    try:
        rag_by_criterion = await per_criterion_rag.retrieve(
            req.task, req.task_type, req.answer, band_estimate=band_estimate,
        )
    except Exception as exc:
        logger.warning("per_criterion_rag failed, proceeding without evidence: %s", exc)
        rag_by_criterion = {"ta": [], "cc": [], "lr": [], "gr": [], "grammar_rules": []}

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

    # Clamp each per-criterion band to the deterministic estimator + 1.0,
    # then recompute `ob` as the mean of the clamped criteria. This keeps
    # the overall band and the per-criterion bands consistent: IELTS
    # specifies that the overall band is the average of the four criteria
    # (rounded). Without this step, clamping only `ob` produces the bug
    # where overall=5.0 sits next to criteria=[6.0, 6.0, 6.5, 6.0] (mean
    # 6.1). The LLM can be slightly more generous than the estimator
    # (within +1.0 bands) but cannot inflate a low-band essay to Band 6+
    # via RAG anchoring.
    ceil = band_estimate + 1.0
    def _clamp_band(raw) -> float:
        try:
            v = float(raw)
        except (TypeError, ValueError):
            return 0.0
        if v > ceil:
            return round(ceil * 2) / 2  # snap to 0.5
        return round(v * 2) / 2

    ta_b = _clamp_band(ta_data.get("b", 0.0) if isinstance(ta_data, dict) else 0.0)
    cc_b = _clamp_band(cc_data.get("b", 0.0) if isinstance(cc_data, dict) else 0.0)
    lr_b = _clamp_band(lr_data.get("b", 0.0) if isinstance(lr_data, dict) else 0.0)
    gr_b = _clamp_band(gr_data.get("b", 0.0) if isinstance(gr_data, dict) else 0.0)

    clamped_any = any(
        float(d.get("b", 0.0) or 0.0) > ceil
        for d in (ta_data, cc_data, lr_data, gr_data)
        if isinstance(d, dict)
    )
    if clamped_any:
        logger.info(
            "grade: per-criterion bands clamped to ceil=%.1f (estimator=%s, raw ob=%.1f)",
            ceil, estimate_debug, ob,
        )

    # Recompute ob from the clamped criteria so it always equals their mean.
    ob = round(((ta_b + cc_b + lr_b + gr_b) / 4.0) * 2) / 2
    # And write the clamped bands back into the per-criterion dicts so the
    # response is internally consistent end-to-end.
    if isinstance(ta_data, dict):
        ta_data["b"] = ta_b
    if isinstance(cc_data, dict):
        cc_data["b"] = cc_b
    if isinstance(lr_data, dict):
        lr_data["b"] = lr_b
    if isinstance(gr_data, dict):
        gr_data["b"] = gr_b

    # User-essay-specific grammar issues the grader spotted. Each item must
    # have a `quote` that is a substring of the essay, a `fix`, a `reason`,
    # and (optionally) a `category` from the same taxonomy as the grammar
    # explainer so the FE can show it next to the existing per-issue cards.
    raw_errors = result.get("errors", []) if isinstance(result, dict) else []
    grammar_errors: list[dict] = []
    if isinstance(raw_errors, list):
        for e in raw_errors:
            if not isinstance(e, dict):
                continue
            quote = str(e.get("quote", "")).strip()
            fix = str(e.get("fix", "")).strip()
            reason = str(e.get("reason", "")).strip()
            if not quote or not fix:
                continue
            category = str(e.get("category", "")).strip() or "grammar"
            # Only keep items whose `quote` is actually a substring of the
            # essay — guards against the LLM hallucinating "the user's essay
            # contained 'foo'" when it didn't.
            if quote not in req.answer:
                continue
            grammar_errors.append({
                "quote": quote,
                "fix": fix,
                "reason": reason,
                "category": category,
            })

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
        grammar_rules=[
            {
                "id": str(getattr(r, "id", i)),
                "text": (getattr(r, "text", "") or "")[:400].strip(),
                "category": _derive_grammar_category(r),
            }
            for i, r in enumerate(rag_by_criterion.get("grammar_rules") or [])
            if (getattr(r, "text", "") or "").strip()
        ],
        grammar_errors=grammar_errors,
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