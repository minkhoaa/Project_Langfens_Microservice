"""
speech_eval router  —  POST /api/v1/speech/evaluate
=====================================================
Accepts a WAV/any audio file + optional target sentence.
Returns transcript, per-word errors, and a pronunciation score.
"""

from __future__ import annotations

import asyncio
import logging
from typing import List, Literal, Optional

from fastapi import APIRouter, File, Form, HTTPException, UploadFile, status
from pydantic import BaseModel, Field

from app.services.speech_eval_service import (
    WordError,
    compare_text,
    compute_score,
    transcribe_audio,
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/v1/speech", tags=["Speech Evaluation"])


# ---------------------------------------------------------------------------
# Response schema
# ---------------------------------------------------------------------------

class WordErrorOut(BaseModel):
    word: str
    type: Literal["missing", "incorrect"]


class EvaluateResponse(BaseModel):
    transcript: str = Field(..., description="What the model heard in the audio")
    errors: List[WordErrorOut] = Field(
        default_factory=list,
        description="Words that are missing or incorrect relative to the target",
    )
    score: float = Field(
        ...,
        ge=0.0,
        le=1.0,
        description="Pronunciation / accuracy score in [0.0, 1.0]",
    )


# ---------------------------------------------------------------------------
# Endpoint
# ---------------------------------------------------------------------------

_MAX_AUDIO_BYTES = 25 * 1024 * 1024  # 25 MB hard limit


@router.post(
    "/evaluate",
    response_model=EvaluateResponse,
    summary="Evaluate spoken audio",
    description=(
        "Upload a WAV (or any ffmpeg-compatible) audio file plus an optional "
        "target sentence. Returns a transcript, per-word error list, and a "
        "pronunciation score between 0.0 and 1.0."
    ),
)
async def evaluate_speech(
    audio: UploadFile = File(..., description="Audio file (WAV preferred, any format accepted)"),
    target: Optional[str] = Form(
        default=None,
        description="Target sentence the speaker was trying to say (optional)",
    ),
) -> EvaluateResponse:
    # --- size guard ---
    audio_bytes = await audio.read()
    if len(audio_bytes) > _MAX_AUDIO_BYTES:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail=f"Audio file exceeds the 25 MB limit ({len(audio_bytes)} bytes received).",
        )
    if len(audio_bytes) == 0:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Audio file is empty.",
        )

    # --- step 1: transcribe ---
    try:
        transcript = await asyncio.to_thread(transcribe_audio, audio_bytes)
    except Exception as exc:
        logger.exception("Transcription failed")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Transcription error: {exc}",
        ) from exc

    # --- step 2: compare text ---
    errors: List[WordError] = []
    if target:
        try:
            errors = await asyncio.to_thread(compare_text, transcript, target)
        except Exception as exc:
            logger.exception("Text comparison failed")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Text comparison error: {exc}",
            ) from exc

    # --- step 3: score ---
    try:
        score = await asyncio.to_thread(compute_score, audio_bytes, transcript, target or "", errors)
    except Exception as exc:
        logger.exception("Scoring failed")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Scoring error: {exc}",
        ) from exc

    return EvaluateResponse(
        transcript=transcript,
        errors=[WordErrorOut(word=e.word, type=e.type) for e in errors],
        score=score,
    )
