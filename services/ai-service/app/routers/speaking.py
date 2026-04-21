import asyncio
import logging

from fastapi import APIRouter, HTTPException, status

from app.schemas import (
    RoleplayScenariosResponse,
    RoleplayStartRequest,
    RoleplayStartResponse,
    RoleplayTurnMessage,
    RoleplayTurnRequest,
    RoleplayTurnResponse,
    RoleplayTurnWithSpeechRequest,
    RoleplayTurnWithSpeechResponse,
)
from app.services.ollama_service import generate_roleplay_reply
from app.services.roleplay_chat_service import generate_agent_reply
from app.services.roleplay_scenario_service import get_scenario_by_slug, load_scenarios
from app.services.roleplay_session_service import append_turn, create_session, get_session
from app.services.speaking_memory_service import (
    ensure_speaking_memory_collection,
    save_speaking_memory,
    search_speaking_memory,
    summarise_memory_for_prompt,
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/v1/speaking/roleplay")


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

    agent_text = await generate_agent_reply(scenario, session["turns"], req.utterance)
    session, agent_turn = append_turn(req.session_id, "agent", agent_text)
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
    agent_text, feedback = await generate_roleplay_reply(
        utterance=req.text,
        errors=req.errors,
        score=req.score,
        scenario=scenario,
        history=session["turns"],
        memory_context=memory_context,
    )

    # --- persist agent turn ---
    session, agent_turn = append_turn(req.session_id, "agent", agent_text)
    if session is None or agent_turn is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found or expired",
        )

    # --- [MEMORY] save this turn to Qdrant after reply is ready ---
    # Fire-and-forget: run in background, never awaited for its result.
    # This means the HTTP response is returned immediately; the save
    # completes (or silently fails) in the event loop's next iteration.
    if req.errors or req.score < 0.85:
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

    return RoleplayTurnWithSpeechResponse(
        session_id=req.session_id,
        scenario_slug=scenario.slug,
        user_message=RoleplayTurnMessage.model_validate(user_turn),
        agent_message=RoleplayTurnMessage.model_validate(agent_turn),
        turn_count=len(session["turns"]),
        feedback=feedback,
        pronunciation_score=req.score,
    )
