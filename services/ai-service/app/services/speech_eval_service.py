"""
speech_eval_service.py
======================
Core speech evaluation logic. Three composable functions:
  - transcribe_audio(audio_bytes) -> str
  - compare_text(transcript, target) -> list[WordError]
  - compute_score(audio_bytes, transcript, target) -> float (0.0 – 1.0)

No paid APIs. Uses:
  • faster-whisper  (transcription)
  • Word Error Rate (WER) based on text alignment (for pronunciation accuracy score)
"""

from __future__ import annotations

import logging
import os
import re
import tempfile
from dataclasses import dataclass
from typing import List, Literal, Optional

import numpy as np
from faster_whisper import WhisperModel

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Lazy singletons — models are loaded once on first call
# ---------------------------------------------------------------------------

_whisper_model: Optional[WhisperModel] = None

_WHISPER_MODEL_SIZE = "base"          # tiny | base | small | medium | large-v3


def _get_whisper() -> WhisperModel:
    global _whisper_model
    if _whisper_model is None:
        logger.info("Loading faster-whisper model: %s", _WHISPER_MODEL_SIZE)
        _whisper_model = WhisperModel(
            _WHISPER_MODEL_SIZE,
            device="cpu",
            compute_type="int8",
        )
    return _whisper_model


# ---------------------------------------------------------------------------
# Data types
# ---------------------------------------------------------------------------

@dataclass
class WordError:
    word: str
    type: Literal["missing", "incorrect"]


# ---------------------------------------------------------------------------
# Step 1 — Transcription
# ---------------------------------------------------------------------------

def transcribe_audio(audio_bytes: bytes, language: str = "en") -> str:
    """
    Transcribe raw audio bytes (any format supported by ffmpeg / soundfile)
    using faster-whisper.

    Returns the plain-text transcript as a single string.
    """
    model = _get_whisper()

    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
        tmp.write(audio_bytes)
        tmp_path = tmp.name

    try:
        segments, _ = model.transcribe(
            tmp_path,
            language=language,
            beam_size=5,
            vad_filter=True,
        )
        transcript = " ".join(seg.text.strip() for seg in segments)
        return transcript.strip()
    finally:
        os.unlink(tmp_path)


# ---------------------------------------------------------------------------
# Step 2 — Text comparison
# ---------------------------------------------------------------------------

def _normalize(text: str) -> List[str]:
    """Lowercase, strip punctuation, split into tokens."""
    text = text.lower()
    text = re.sub(r"[^\w\s]", "", text)
    return text.split()


def compare_text(transcript: str, target: Optional[str]) -> Optional[List[WordError]]:
    """
    Compare the spoken transcript against the target sentence.

    Strategy:
    • Walk through both token lists using a simple greedy alignment.
    • A target token not found in the transcript → "missing".
    • A transcript token that doesn't match the current expected target token
      → "incorrect".

    Returns a list of WordError objects, or None if no target is provided.
    """
    if not target:
        return None

    ref_tokens = _normalize(target)
    hyp_tokens = _normalize(transcript)

    errors: List[WordError] = []
    ref_idx = 0
    hyp_idx = 0

    while ref_idx < len(ref_tokens) and hyp_idx < len(hyp_tokens):
        ref_word = ref_tokens[ref_idx]
        hyp_word = hyp_tokens[hyp_idx]

        if ref_word == hyp_word:
            ref_idx += 1
            hyp_idx += 1
        else:
            # Look-ahead: check if hyp_word appears anywhere ahead in ref
            future_ref = ref_tokens[ref_idx + 1:]
            if hyp_word in future_ref:
                # Current ref word was skipped (missing)
                errors.append(WordError(word=ref_word, type="missing"))
                ref_idx += 1
            else:
                # Current hyp word doesn't match — mark as incorrect
                errors.append(WordError(word=hyp_word, type="incorrect"))
                ref_idx += 1
                hyp_idx += 1

    # Any remaining reference tokens were not spoken
    while ref_idx < len(ref_tokens):
        errors.append(WordError(word=ref_tokens[ref_idx], type="missing"))
        ref_idx += 1

    return errors


# ---------------------------------------------------------------------------
# Step 3 — Pronunciation scoring
# ---------------------------------------------------------------------------

def compute_score(
    audio_bytes: bytes,
    transcript: str,
    target: Optional[str] = None,
    errors: Optional[List[WordError]] = None,
    force_acoustic: bool = False,
) -> Optional[float]:
    """
    Compute a pronunciation / accuracy score in [0.0, 1.0].
    Uses the fine-tuned acoustic Wav2Vec2 model if available.
    If target is provided, scales the acoustic score by the text alignment accuracy (WER).
    Returns the acoustic score directly if no target is provided.
    """
    if not target and not force_acoustic:
        return None
    # 1. Compute acoustic score from model
    try:
        from app.services.pronunciation_scorer import evaluate_acoustic_pronunciation
        acoustic_scores = evaluate_acoustic_pronunciation(audio_bytes)
        acoustic_score = acoustic_scores["overall"]
    except Exception as exc:
        logger.warning(
            "Could not run acoustic pronunciation scorer, falling back to text-only evaluation: %s",
            exc
        )
        acoustic_score = 1.0

    # 2. Combine with text-alignment accuracy (WER) if target is provided
    if target:
        ref_tokens = _normalize(target)
        if not ref_tokens:
            return None

        if errors is None:
            errors = []

        n_errors = len(errors)
        error_rate = min(n_errors / len(ref_tokens), 1.0)
        alignment_acc = 1.0 - error_rate
        
        # Combine score (e.g. alignment_acc acts as a gate / weight)
        final_score = alignment_acc * acoustic_score
    else:
        # Free-form mode: score is solely acoustic pronunciation quality
        final_score = acoustic_score

    return round(float(np.clip(final_score, 0.0, 1.0)), 4)
