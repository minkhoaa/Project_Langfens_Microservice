import asyncio
import logging
from typing import Optional

from fastapi import APIRouter, File, Form, HTTPException, UploadFile, status

from app.schemas import (
    RoleplayLLMOutput,
    RoleplayTurnAudioResponse,
    RoleplayScenariosResponse,
    RoleplayStartRequest,
    RoleplayStartResponse,
    RoleplayTurnMessage,
    RoleplayTurnRequest,
    RoleplayTurnResponse,
    RoleplayTurnWithSpeechRequest,
    RoleplayTurnWithSpeechResponse,
    WordErrorItem,
)
from app.services.ollama_service import generate_roleplay_reply
from app.services.qwen_service import qwen_roleplay_generate
from app.services.roleplay_chat_service import generate_agent_reply
from app.services.roleplay_scenario_service import get_scenario_by_slug, load_scenarios
from app.services.roleplay_session_service import append_turn, create_session, get_session
from app.services.speaking_memory_service import (
    ensure_speaking_memory_collection,
    save_speaking_memory,
    search_speaking_memory,
    summarise_memory_for_prompt,
)
from app.services.heuristic_eval_service import (
    PRONUNCIATION_MODE,
    compute_heuristic_pronunciation,
    compute_overall_speaking_band,
    enforce_consistency,
)
from app.services.speech_eval_service import (
    WordError,
    compare_text,
    compute_score,
    transcribe_audio,
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/v1/speaking/roleplay")

_MAX_AUDIO_BYTES = 25 * 1024 * 1024  # 25 MB hard limit


# ---------------------------------------------------------------------------
# Heuristic scoring helper
# ---------------------------------------------------------------------------

def _compute_heuristics(
    llm: "RoleplayLLMOutput",
    acoustic_score: "Optional[float]" = None,
) -> "tuple[Optional[float], str, Optional[float]]":
    """
    Compute heuristic pronunciation score, pronunciation_mode, and overall band.

    Also enforces consistency: if off_topic, content_score is capped server-side
    regardless of what the LLM returned.

    Returns
    -------
    (heuristic_pronunciation_score, pronunciation_mode, overall_speaking_band, enforced_content_score)
    """
    # --- Server-side consistency guard ---
    enforced_content = enforce_consistency(
        content_score=llm.content_score,
        off_topic=llm.off_topic,
    )
    if acoustic_score is not None:
        # We have a real acoustic signal — use it, no heuristic needed
        pron_heuristic = None
        pron_mode = "acoustic"
        band = compute_overall_speaking_band(
            content_score=enforced_content,
            grammar_score=llm.grammar_score,
            lexical_score=llm.lexical_score,
            fluency_score=llm.fluency_score,
            heuristic_pronunciation_score=acoustic_score,
            off_topic=llm.off_topic,
        )
        llm.feedback.pronunciation = f"Acoustic pronunciation score: {acoustic_score:.2f}."
    else:
        # Free-form mode — derive heuristic pronunciation from LLM signals
        pron_heuristic = compute_heuristic_pronunciation(
            fluency_score=llm.fluency_score,
            grammar_score=llm.grammar_score,
            lexical_score=llm.lexical_score,
        )
        pron_mode = PRONUNCIATION_MODE  # "heuristic"
        band = compute_overall_speaking_band(
            content_score=enforced_content,
            grammar_score=llm.grammar_score,
            lexical_score=llm.lexical_score,
            fluency_score=llm.fluency_score,
            heuristic_pronunciation_score=pron_heuristic,
            off_topic=llm.off_topic,
        )
        llm.feedback.pronunciation = f"(Heuristic / Approximate) Based on your fluency and accuracy, your pronunciation proxy score is {pron_heuristic:.2f}. For detailed word-level acoustic feedback, please try a target-based read-aloud task."
        
    return pron_heuristic, pron_mode, band, enforced_content





# ---------------------------------------------------------------------------
# GET /scenarios
# ---------------------------------------------------------------------------

@router.get("/scenarios", response_model=RoleplayScenariosResponse)
async def list_roleplay_scenarios():
    scenarios = load_scenarios()
    return RoleplayScenariosResponse(scenarios=scenarios, total=len(scenarios))


# ---------------------------------------------------------------------------
# POST /start
# ---------------------------------------------------------------------------

@router.post("/start", response_model=RoleplayStartResponse)
async def start_roleplay_session(req: RoleplayStartRequest):
    scenario = get_scenario_by_slug(req.scenario_slug)
    if scenario is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Scenario not found")

    try:
        ensure_speaking_memory_collection()
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Speaking memory unavailable: {exc}",
        ) from exc

    session = create_session(req.user_id, scenario)
    opening_turn = RoleplayTurnMessage.model_validate(session["turns"][0])

    return RoleplayStartResponse(
        session_id=session["session_id"],
        user_id=req.user_id,
        scenario=scenario,
        agent_message=opening_turn,
    )


# ---------------------------------------------------------------------------
# POST /turn  —  Gemini-powered, text-only (UNCHANGED — backward compatible)
# ---------------------------------------------------------------------------

@router.post("/turn", response_model=RoleplayTurnResponse)
async def roleplay_turn(req: RoleplayTurnRequest):
    session = get_session(req.session_id)
    if session is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Session not found or expired")
    if session["user_id"] != req.user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Session does not belong to this user")

    scenario = get_scenario_by_slug(session["scenario_slug"])
    if scenario is None:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Scenario definition is missing")

    session, user_turn = append_turn(req.session_id, "user", req.utterance)
    if session is None or user_turn is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Session not found or expired")

    llm_output: RoleplayLLMOutput = await generate_agent_reply(scenario, session["turns"], req.utterance)
    session, agent_turn = append_turn(req.session_id, "agent", llm_output.agent_reply)
    if session is None or agent_turn is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Session not found or expired")

    return RoleplayTurnResponse(
        session_id=req.session_id,
        scenario_slug=scenario.slug,
        user_message=RoleplayTurnMessage.model_validate(user_turn),
        agent_message=RoleplayTurnMessage.model_validate(agent_turn),
        turn_count=len(session["turns"]),
    )


# ---------------------------------------------------------------------------
# POST /turn-with-speech  —  Qwen/Ollama + speaking memory
# ---------------------------------------------------------------------------

@router.post(
    "/turn-with-speech",
    response_model=RoleplayTurnWithSpeechResponse,
    summary="Roleplay turn with pronunciation feedback (Qwen/Ollama)",
    description=(
        "Accepts the transcript + pronunciation errors/score produced by "
        "POST /api/v1/speech/evaluate and generates a conversational agent "
        "reply that weaves in a gentle, in-character pronunciation correction "
        "using the local Qwen2.5 model via Ollama. "
        "Past speaking mistakes are retrieved from Qdrant to personalise the reply."
    ),
)
async def roleplay_turn_with_speech(req: RoleplayTurnWithSpeechRequest):
    # --- session guard ---
    session = get_session(req.session_id)
    if session is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found or expired",
        )
    if session["user_id"] != req.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Session does not belong to this user",
        )

    # --- scenario guard ---
    scenario = get_scenario_by_slug(session["scenario_slug"])
    if scenario is None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Scenario definition is missing",
        )

    # --- persist user turn ---
    session, user_turn = append_turn(req.session_id, "user", req.text)
    if session is None or user_turn is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found or expired",
        )

    # --- [MEMORY] retrieve relevant past mistakes before calling LLM ---
    # Failure is fully isolated: on any error, memory_context stays "".
    # The roleplay continues without personalisation rather than failing.
    memory_context = ""
    if req.errors:
        try:
            error_words = " ".join([e.word for e in req.errors])
            memory_hits = await search_speaking_memory(
                user_id=req.user_id,
                query_text=error_words,
                scenario_slug=scenario.slug,
                limit=5,
            )
            memory_context = summarise_memory_for_prompt(memory_hits)
            if memory_context:
                logger.debug(
                    "Speaking memory injected for user=%s (%d hits)", req.user_id, len(memory_hits)
                )
        except Exception as exc:
            logger.warning("Failed to retrieve speaking memory: %s", exc)

    # --- call Qwen via Ollama (memory_context is "" if retrieval failed) ---
    llm_output: RoleplayLLMOutput = await generate_roleplay_reply(
        utterance=req.text,
        errors=req.errors,
        score=req.score,
        scenario=scenario,
        history=session["turns"],
        memory_context=memory_context,
    )

    # --- persist agent turn ---
    session, agent_turn = append_turn(req.session_id, "agent", llm_output.agent_reply)
    if session is None or agent_turn is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found or expired",
        )

    # --- [MEMORY] save this turn to Qdrant after reply is ready ---
    # Fire-and-forget: run in background, never awaited for its result.
    # This means the HTTP response is returned immediately; the save
    # completes (or silently fails) in the event loop's next iteration.
    if req.errors or (req.score is not None and req.score < 0.85):
        # Only store turns that contain something worth remembering.
        # Perfect-score, error-free turns don't add useful signal.
        asyncio.ensure_future(
            save_speaking_memory(
                user_id=req.user_id,
                session_id=req.session_id,
                scenario_slug=scenario.slug,
                text=req.text,
                errors=req.errors,
                score=req.score,
            )
        )

    pron_heuristic, pron_mode, band, enforced_content = _compute_heuristics(llm_output, acoustic_score=req.score)

    return RoleplayTurnWithSpeechResponse(
        session_id=req.session_id,
        scenario_slug=scenario.slug,
        user_message=RoleplayTurnMessage.model_validate(user_turn),
        agent_message=RoleplayTurnMessage.model_validate(agent_turn),
        turn_count=len(session["turns"]),
        feedback=llm_output.feedback,
        pronunciation_score=req.score if req.score is not None else pron_heuristic,
        pronunciation_mode=pron_mode,
        content_score=enforced_content,
        grammar_score=llm_output.grammar_score,
        fluency_score=llm_output.fluency_score,
        lexical_score=llm_output.lexical_score,
        off_topic=llm_output.off_topic,
        overall_speaking_band=band,
    )


# ---------------------------------------------------------------------------
# POST /turn-local  —  native Qwen2.5-LoRA, no Ollama, optional speech
# ---------------------------------------------------------------------------

@router.post(
    "/turn-local",
    response_model=RoleplayTurnWithSpeechResponse,
    summary="Roleplay turn powered by the local fine-tuned Qwen2.5-LoRA model",
    description=(
        "Generates a conversational agent reply using the locally fine-tuned "
        "Qwen2.5-1.5B-Instruct LoRA adapter. "
        "Accepts the same request body as /turn-with-speech (transcript + optional "
        "pronunciation errors/score). "
        "Requires USE_LOCAL_LORA=true in ai.env and the adapter present at "
        "LORA_MODEL_PATH. "
        "Returns HTTP 503 when the model has not been loaded."
    ),
)
async def roleplay_turn_local(req: RoleplayTurnWithSpeechRequest):
    from app.config import settings
    from app.services import qwen_service

    # --- availability guard ---
    if not settings.use_local_lora:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Local LoRA model is disabled. Set USE_LOCAL_LORA=true in ai.env.",
        )
    if not qwen_service._model_ready:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Local LoRA model is not loaded yet. Retry in a moment.",
        )

    # --- session guard ---
    session = get_session(req.session_id)
    if session is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found or expired",
        )
    if session["user_id"] != req.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Session does not belong to this user",
        )

    # --- scenario guard ---
    scenario = get_scenario_by_slug(session["scenario_slug"])
    if scenario is None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Scenario definition is missing",
        )

    # --- persist user turn ---
    session, user_turn = append_turn(req.session_id, "user", req.text)
    if session is None or user_turn is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found or expired",
        )

    # --- [MEMORY] retrieve relevant past mistakes ---
    memory_context = ""
    if req.errors:
        try:
            error_words = " ".join([e.word for e in req.errors])
            memory_hits = await search_speaking_memory(
                user_id=req.user_id,
                query_text=error_words,
                scenario_slug=scenario.slug,
                limit=5,
            )
            memory_context = summarise_memory_for_prompt(memory_hits)
            if memory_context:
                logger.debug(
                    "Speaking memory injected for user=%s (%d hits)",
                    req.user_id,
                    len(memory_hits),
                )
        except Exception as exc:
            logger.warning("Failed to retrieve speaking memory: %s", exc)

    # --- call local Qwen2.5-LoRA model ---
    llm_output: RoleplayLLMOutput = await qwen_roleplay_generate(
        scenario=scenario,
        history=session["turns"],
        user_utterance=req.text,
        errors=req.errors if req.errors else None,
        score=req.score,
        memory_context=memory_context,
    )

    # Graceful fallback: if local model produced nothing, use simple template reply
    if not llm_output.agent_reply:
        logger.warning(
            "turn-local: qwen_roleplay_generate returned empty; using fallback reply."
        )
        topics = scenario.suggested_topics
        turn_idx = len(session["turns"])
        llm_output.agent_reply = (
            f"Thanks for that. Could you tell me more about "
            f"{topics[turn_idx % len(topics)]}?"
            if topics
            else "Thanks for sharing. Could you elaborate a bit more?"
        )

    # --- persist agent turn ---
    session, agent_turn = append_turn(req.session_id, "agent", llm_output.agent_reply)
    if session is None or agent_turn is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found or expired",
        )

    # --- [MEMORY] save noteworthy turns (fire-and-forget) ---
    if req.errors or (req.score is not None and req.score < 0.85):
        asyncio.ensure_future(
            save_speaking_memory(
                user_id=req.user_id,
                session_id=req.session_id,
                scenario_slug=scenario.slug,
                text=req.text,
                errors=req.errors,
                score=req.score,
            )
        )

    pron_heuristic, pron_mode, band, enforced_content = _compute_heuristics(llm_output, acoustic_score=req.score)

    return RoleplayTurnWithSpeechResponse(
        session_id=req.session_id,
        scenario_slug=scenario.slug,
        user_message=RoleplayTurnMessage.model_validate(user_turn),
        agent_message=RoleplayTurnMessage.model_validate(agent_turn),
        turn_count=len(session["turns"]),
        feedback=llm_output.feedback,
        pronunciation_score=req.score if req.score is not None else pron_heuristic,
        pronunciation_mode=pron_mode,
        content_score=enforced_content,
        grammar_score=llm_output.grammar_score,
        fluency_score=llm_output.fluency_score,
        lexical_score=llm_output.lexical_score,
        off_topic=llm_output.off_topic,
        overall_speaking_band=band,
    )


# ---------------------------------------------------------------------------
# POST /turn-audio  —  Full pipeline: audio → transcript → score → LoRA reply
# ---------------------------------------------------------------------------
#
# This is the single-shot endpoint that accepts raw audio and runs the entire
# pipeline server-side:
#   1. Whisper ASR  →  transcript
#   2. Word-error alignment against last agent turn  →  errors list
#   3. WER-based score  →  pronunciation_score
#   4. Qdrant memory retrieval (personalisation)
#   5. Qwen2.5-LoRA (preferred) or Ollama fallback  →  agent reply
#   6. Fire-and-forget: save this turn to Qdrant
#
# The client sends: audio file + session_id + user_id
# The client receives: transcript, word_errors, score, agent reply, feedback
# ---------------------------------------------------------------------------

@router.post(
    "/turn-audio",
    response_model=RoleplayTurnAudioResponse,
    summary="Full pipeline: audio → transcript → pronunciation score → agent reply",
    description=(
        "Accepts raw audio (WAV/MP3/OGG/etc.) and runs the complete speaking "
        "roleplay pipeline server-side in a single request:\n"
        "1. Whisper ASR transcribes the audio.\n"
        "2. Word errors are detected against the last agent turn (target).\n"
        "3. A WER-based pronunciation score is computed.\n"
        "4. Past speaking mistakes are retrieved from Qdrant for personalisation.\n"
        "5. The local Qwen2.5-LoRA model (or Ollama fallback) generates a reply.\n"
        "6. Response includes transcript, per-word errors, score, agent reply, and feedback.\n"
        "Requires an active session (call POST /start first)."
    ),
)
async def roleplay_turn_audio(
    session_id: str = Form(..., description="Active session ID from POST /start"),
    user_id: str = Form(..., description="User ID (must match the session)"),
    audio: UploadFile = File(..., description="Audio file — WAV preferred, any ffmpeg format accepted"),
    language: Optional[str] = Form(
        default="en",
        description="BCP-47 language code for Whisper (default: en)",
    ),
    target: Optional[str] = Form(
        default=None,
        description=(
            "Optional target sentence for pronunciation scoring. "
            "When provided, word errors are computed against this exact text. "
            "When omitted, free-form conversation mode: score=1.0, no word errors reported."
        ),
    ),
) -> RoleplayTurnAudioResponse:
    # --- size guard ---
    audio_bytes = await audio.read()
    if not audio_bytes:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Audio file is empty.",
        )
    if len(audio_bytes) > _MAX_AUDIO_BYTES:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail=f"Audio exceeds the 25 MB limit ({len(audio_bytes)} bytes).",
        )

    # --- session guard ---
    session = get_session(session_id)
    if session is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found or expired.",
        )
    if session["user_id"] != user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Session does not belong to this user.",
        )

    # --- scenario guard ---
    scenario = get_scenario_by_slug(session["scenario_slug"])
    if scenario is None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Scenario definition is missing.",
        )

    # ==========================================================================
    # Step 1 — Transcription (Whisper)
    # ==========================================================================
    try:
        transcript = await asyncio.to_thread(transcribe_audio, audio_bytes, language or "en")
    except Exception as exc:
        logger.exception("turn-audio: transcription failed")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Transcription failed: {exc}",
        ) from exc

    if not transcript:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Whisper produced an empty transcript. Is the audio too short or silent?",
        )

    # ==========================================================================
    # Step 2 — Pronunciation / accent evaluation
    #
    # Scoring modes:
    #   A) target provided explicitly (Form param) — compare transcript against it.
    #      Use this when the learner was asked to repeat/respond to a specific sentence.
    #   B) target = None (default, free-form conversation) — no word comparison.
    #      Score defaults to 1.0 and word_errors is empty.
    #      The LLM still receives the transcript and will give gentle coaching
    #      based on vocabulary/grammar targets in the scenario.
    # ==========================================================================
    raw_errors: Optional[list[WordError]] = None
    score: Optional[float] = None

    if target:
        try:
            raw_errors = await asyncio.to_thread(compare_text, transcript, target)
            score = await asyncio.to_thread(
                compute_score, audio_bytes, transcript, target, raw_errors
            )
        except Exception as exc:
            logger.warning("turn-audio: pronunciation scoring failed, defaulting to None: %s", exc)
            raw_errors = None
            score = None

    # Convert internal WordError dataclasses → Pydantic WordErrorItem
    word_errors: Optional[list[WordErrorItem]] = None
    if raw_errors is not None:
        word_errors = [
            WordErrorItem(word=e.word, type=e.type) for e in raw_errors
        ]

    # ==========================================================================
    # Step 3 — Persist user turn
    # ==========================================================================
    session, user_turn = append_turn(session_id, "user", transcript)
    if session is None or user_turn is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found or expired.",
        )

    # ==========================================================================
    # Step 4 — Retrieve speaking memory (Qdrant)
    # ==========================================================================
    memory_context = ""
    if word_errors:
        try:
            error_words = " ".join(e.word for e in word_errors)
            memory_hits = await search_speaking_memory(
                user_id=user_id,
                query_text=error_words,
                scenario_slug=scenario.slug,
                limit=5,
            )
            memory_context = summarise_memory_for_prompt(memory_hits)
            if memory_context:
                logger.debug(
                    "turn-audio: memory injected for user=%s (%d hits)",
                    user_id, len(memory_hits),
                )
        except Exception as exc:
            logger.warning("turn-audio: memory retrieval failed (non-fatal): %s", exc)

    # ==========================================================================
    # Step 5 — Generate agent reply
    #
    # Priority: local Qwen2.5-LoRA (if USE_LOCAL_LORA=true and loaded)
    #           → Ollama /api/chat (qwen2.5:latest at localhost:11434)
    #           → hard template fallback (only if Ollama raises)
    # ==========================================================================
    from app.config import settings as _settings
    from app.services import qwen_service as _qwen_service

    agent_text = ""
    llm_output: RoleplayLLMOutput = RoleplayLLMOutput(agent_reply="")

    if _settings.use_local_lora and _qwen_service._model_ready:
        logger.info("turn-audio: using local Qwen2.5-LoRA model")
        llm_output = await qwen_roleplay_generate(
            scenario=scenario,
            history=session["turns"],
            user_utterance=transcript,
            errors=word_errors if word_errors else None,
            score=score,
            memory_context=memory_context,
        )
        agent_text = llm_output.agent_reply
        if agent_text:
            logger.info("turn-audio: LoRA reply OK (%d chars)", len(agent_text))
        else:
            logger.warning("turn-audio: LoRA returned empty — will try Ollama")

    if not agent_text:
        logger.info(
            "turn-audio: calling Ollama  url=%s  model=%s",
            _settings.ollama_base_url,
            _settings.ollama_model,
        )
        try:
            llm_output = await generate_roleplay_reply(
                utterance=transcript,
                errors=word_errors,
                score=score,
                scenario=scenario,
                history=session["turns"],
                memory_context=memory_context,
            )
            agent_text = llm_output.agent_reply
            logger.info("turn-audio: Ollama reply OK (%d chars)", len(agent_text))
        except RuntimeError as exc:
            # Real Ollama failure — log at ERROR so it's always visible
            logger.error("turn-audio: Ollama generation FAILED: %s", exc)
            agent_text = ""

    if not agent_text:
        # Hard template fallback — only reached when both LoRA and Ollama fail
        logger.warning(
            "turn-audio: all generation paths failed — using template fallback. "
            "Check OLLAMA_BASE_URL=%s and OLLAMA_MODEL=%s",
            _settings.ollama_base_url,
            _settings.ollama_model,
        )
        topics = scenario.suggested_topics
        turn_idx = len(session["turns"])
        agent_text = (
            f"Thanks for that. Could you tell me more about "
            f"{topics[turn_idx % len(topics)]}?"
            if topics
            else "Thanks for sharing. Could you elaborate a bit more?"
        )


    # ==========================================================================
    # Step 6 — Persist agent turn
    # ==========================================================================
    session, agent_turn = append_turn(session_id, "agent", agent_text)
    if session is None or agent_turn is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found or expired.",
        )

    # ==========================================================================
    # Step 7 — Save to Qdrant memory (fire-and-forget)
    # ==========================================================================
    if word_errors or (score is not None and score < 0.85):
        asyncio.ensure_future(
            save_speaking_memory(
                user_id=user_id,
                session_id=session_id,
                scenario_slug=scenario.slug,
                text=transcript,
                errors=word_errors,
                score=score,
            )
        )

    pron_heuristic, pron_mode, band, enforced_content = _compute_heuristics(llm_output, acoustic_score=score)

    return RoleplayTurnAudioResponse(
        session_id=session_id,
        scenario_slug=scenario.slug,
        transcript=transcript,
        word_errors=word_errors,
        user_message=RoleplayTurnMessage.model_validate(user_turn),
        agent_message=RoleplayTurnMessage.model_validate(agent_turn),
        turn_count=len(session["turns"]),
        feedback=llm_output.feedback,
        pronunciation_score=score if score is not None else pron_heuristic,
        pronunciation_mode=pron_mode,
        content_score=enforced_content,
        grammar_score=llm_output.grammar_score,
        fluency_score=llm_output.fluency_score,
        lexical_score=llm_output.lexical_score,
        off_topic=llm_output.off_topic,
        overall_speaking_band=band,
    )
