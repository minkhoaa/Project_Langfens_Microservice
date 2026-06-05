"""
heuristic_eval_service.py
=========================
Computes demo-quality IELTS speaking metrics when true acoustic
pronunciation scoring is not available.

All scores produced here are clearly labelled as HEURISTIC / APPROXIMATE.
They are NOT based on a real phoneme-level acoustic model.

Public API
----------
compute_heuristic_pronunciation(transcript, fluency_score, grammar_score, lexical_score) -> float
    Returns a heuristic pronunciation score in [0.0, 1.0] derived from
    practical language-quality proxies.

compute_overall_speaking_band(content, grammar, lexical, fluency, pronunciation, off_topic) -> float
    Returns an estimated IELTS-style speaking band on the 0.0–9.0 scale
    using a documented weighted formula.

PRONUNCIATION_MODE
    A constant string that should be included in every API response to signal
    to callers that the pronunciation score is approximate.

Design notes
------------
* The heuristic pronunciation score correlates with how clearly and
  fluently a speaker *appears* to speak, as judged by the LLM:
  - Fluency is the primary proxy (60 % weight)  — halting, disfluent speech
    usually correlates with pronunciation difficulties.
  - Grammar accuracy (20 %) — speakers with strong grammar command tend
    to articulate more clearly.
  - Lexical resource (20 %) — wider vocabulary usually accompanies clearer
    articulation.

* The overall speaking band uses IELTS-aligned criteria weights:
  - Fluency & Coherence   25 %
  - Lexical Resource       25 %
  - Grammatical Range      25 %
  - Pronunciation          25 %
  (Content relevance is an additional cap: if off_topic the band is reduced.)

* Band output is rounded to the nearest 0.5 (standard IELTS band increments).
"""

from __future__ import annotations

# -----------------------------------------------------------------------
# Public constant — embed in every API response that uses heuristic scoring
# -----------------------------------------------------------------------
PRONUNCIATION_MODE: str = "heuristic"

# -----------------------------------------------------------------------
# Weights for the heuristic pronunciation proxy
# -----------------------------------------------------------------------
_PRON_W_FLUENCY = 0.60
_PRON_W_GRAMMAR = 0.20
_PRON_W_LEXICAL = 0.20

# -----------------------------------------------------------------------
# Weights for the overall speaking band (maps onto IELTS criteria)
# -----------------------------------------------------------------------
_BAND_W_FLUENCY      = 0.25   # Fluency & Coherence
_BAND_W_LEXICAL      = 0.25   # Lexical Resource
_BAND_W_GRAMMAR      = 0.25   # Grammatical Range & Accuracy
_BAND_W_PRON         = 0.25   # Pronunciation (heuristic)

# IELTS full-band range
_BAND_MAX = 9.0

# Hard ceiling for content_score when off_topic=True
# Any LLM output above this is silently clamped server-side.
OFF_TOPIC_CONTENT_MAX: float = 0.25

# Content-relevance penalty applied in band calculation when off_topic=True
_OFF_TOPIC_CONTENT_CAP = 0.25   # content is treated as at most 25 % when off-topic


def enforce_consistency(
    *,
    content_score: float | None,
    off_topic: bool,
) -> float | None:
    """
    Server-side guard: if the learner was off-topic, cap content_score ≤ 0.25.

    This prevents the LLM from awarding high content scores to answers that
    it simultaneously flags as off-topic — a logical contradiction we must
    never expose in the API response.
    """
    if content_score is None:
        return content_score
    if off_topic and content_score > OFF_TOPIC_CONTENT_MAX:
        return OFF_TOPIC_CONTENT_MAX
    return content_score



def compute_heuristic_pronunciation(
    *,
    fluency_score: float | None,
    grammar_score: float | None,
    lexical_score: float | None,
) -> float:
    """
    Return a heuristic pronunciation score in [0.0, 1.0].

    Formula
    -------
    heuristic_pron = 0.60 * fluency + 0.20 * grammar + 0.20 * lexical

    Rationale: fluency is the strongest surface-level cue for pronunciation
    clarity; grammar and lexical precision add secondary signal.

    Any None input is replaced by a conservative default of 0.5.
    """
    f = fluency_score if fluency_score is not None else 0.5
    g = grammar_score if grammar_score is not None else 0.5
    l = lexical_score if lexical_score is not None else 0.5  # noqa: E741

    raw = _PRON_W_FLUENCY * f + _PRON_W_GRAMMAR * g + _PRON_W_LEXICAL * l
    return round(min(max(raw, 0.0), 1.0), 3)


def compute_overall_speaking_band(
    *,
    content_score: float | None,
    grammar_score: float | None,
    lexical_score: float | None,
    fluency_score: float | None,
    heuristic_pronunciation_score: float | None,
    off_topic: bool = False,
) -> float:
    """
    Return an estimated IELTS Speaking Band in [0.0, 9.0] (0.5 increments).

    Formula
    -------
    weighted_avg = 0.25*fluency + 0.25*lexical + 0.25*grammar + 0.25*pron
    band_raw     = weighted_avg * 9.0
    band         = round(band_raw * 2) / 2            (nearest 0.5)

    Content relevance is applied as an additional cap:
    - If off_topic=True, content is treated as at most 0.35,
      which reduces the final band by up to 0.5 points.
    - More precisely: if effective_content < content_score,
      a proportional penalty is subtracted from the final band.

    Returns the band clamped to [1.0, 9.0] (below 1 = Band 0, shown as 1).
    """
    f = fluency_score             if fluency_score             is not None else 0.5
    g = grammar_score             if grammar_score             is not None else 0.5
    l = lexical_score             if lexical_score             is not None else 0.5  # noqa: E741
    p = heuristic_pronunciation_score if heuristic_pronunciation_score is not None else 0.5
    c = content_score             if content_score             is not None else 0.5

    # Apply off-topic content cap
    effective_content = min(c, _OFF_TOPIC_CONTENT_CAP) if off_topic else c

    # IELTS four-criterion weighted average (language quality only)
    language_avg = _BAND_W_FLUENCY * f + _BAND_W_LEXICAL * l + _BAND_W_GRAMMAR * g + _BAND_W_PRON * p

    # Content penalty: difference between real and effective content, scaled
    content_penalty = max(0.0, c - effective_content) * 0.5   # soft penalty

    # Final band
    band_raw = (language_avg - content_penalty) * _BAND_MAX
    band_clamped = min(max(band_raw, 1.0), 9.0)

    # Hard ceiling: off-topic answers can never achieve a high band,
    # regardless of how well the LLM rates the language quality.
    # An IELTS examiner would never award a top band for a completely
    # irrelevant answer, even if individual sentences are grammatical.
    if off_topic:
        band_clamped = min(band_clamped, 5.0)

    # Round to nearest 0.5
    return round(band_clamped * 2) / 2

