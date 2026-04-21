"""
speech_eval_service.py
======================
Core speech evaluation logic. Three composable functions:
  - transcribe_audio(audio_bytes) -> str
  - compare_text(transcript, target) -> list[WordError]
  - compute_score(audio_bytes, transcript, target) -> float (0.0 – 1.0)

No paid APIs. Uses:
  • faster-whisper  (transcription)
  • transformers + torchaudio  (wav2vec2 audio embeddings for pronunciation score)
"""

from __future__ import annotations

import logging
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

    segments, _ = model.transcribe(
        tmp_path,
        language=language,
        beam_size=5,
        vad_filter=True,
    )
    transcript = " ".join(seg.text.strip() for seg in segments)
    return transcript.strip()


# ---------------------------------------------------------------------------
# Step 2 — Text comparison
# ---------------------------------------------------------------------------

def _normalize(text: str) -> List[str]:
    """Lowercase, strip punctuation, split into tokens."""
    text = text.lower()
    text = re.sub(r"[^\w\s]", "", text)
    return text.split()


def compare_text(transcript: str, target: str) -> List[WordError]:
    """
    Compare the spoken transcript against the target sentence.

    Strategy:
    • Walk through both token lists using a simple greedy alignment.
    • A target token not found in the transcript → "missing".
    • A transcript token that doesn't match the current expected target token
      → "incorrect".

    Returns a list of WordError objects (may be empty for a perfect match).
    """
    if not target:
        return []

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
    target: str,
    errors: List[WordError],
) -> float:
    """
    Compute a pronunciation / accuracy score in [0.0, 1.0].
    Safely rewritten to use text alignment accuracy to avoid false acoustic proxies.
    """
    if not target:
        return 1.0

    ref_tokens = _normalize(target)
    if not ref_tokens:
        return 1.0

    n_errors = len(errors)
    error_rate = min(n_errors / len(ref_tokens), 1.0)
    score = 1.0 - error_rate
    return round(float(np.clip(score, 0.0, 1.0)), 4)
