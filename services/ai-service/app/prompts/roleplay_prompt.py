"""
Prompt builder for English speaking roleplay sessions.

This module is intentionally side-effect-free: it only builds the
``messages`` list expected by ``tokenizer.apply_chat_template``.

The resulting list always follows the ChatML structure used by
Qwen2.5-Instruct:
    [
        {"role": "system", "content": "..."},
        {"role": "user",   "content": "..."},
        {"role": "assistant", "content": "..."},
        ...
        {"role": "user",   "content": "<current utterance>"},
    ]
"""

from __future__ import annotations

import re
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from app.schemas import RoleplayScenario, WordErrorItem

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

# Maximum conversation history turns injected into the context.
# Older turns are silently dropped to keep prompt length bounded.
_MAX_HISTORY_TURNS: int = 12

# Pronunciation score below which a correction tip is always suggested.
_SCORE_CORRECTION_THRESHOLD: float = 0.75


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

def _build_system_prompt(
    scenario: "RoleplayScenario",
    *,
    errors: list["WordErrorItem"] | None,
    score: float | None,
    memory_context: str,
) -> str:
    """Compose the system message that defines the model's persona and task."""

    target_vocab = ", ".join(scenario.target_vocabulary) if scenario.target_vocabulary else "none specified"
    target_grammar = ", ".join(scenario.target_grammar) if scenario.target_grammar else "none specified"

    lines: list[str] = [
        "You are an English speaking practice partner helping a learner prepare for IELTS Speaking.",
        "",
        f"## Current scenario: {scenario.title}",
        f"Context : {scenario.context}",
        f"Your role : {scenario.agent_role}",
        f"Learner's role : {scenario.user_role}",
        "",
        "## Target language",
        f"Vocabulary: {target_vocab}",
        f"Grammar focus: {target_grammar}",
        "",
        "## Rules you MUST follow",
        "1. Stay completely in character — never break the roleplay. You MUST ALWAYS act as your specified role.",
        "2. If the learner says something completely unrelated to the scenario or context, acknowledge it briefly but IMMEDIATELY steer the conversation back to the task. Do not indulge off-topic conversations.",
        "3. Reply in 1–3 natural, spoken-English sentences.",
        "4. Ask one follow-up question per turn to keep the conversation flowing.",
        "5. Gently steer the learner toward using the target vocabulary and grammar.",
        "6. Keep your language at an IELTS-appropriate level (B2–C1).",
        "7. NEVER repeat the learner's exact words back verbatim.",
        "8. You MUST respond with a valid JSON object EXACTLY matching this structure:",
        "   {",
        '     "agent_reply": "Your conversational reply here",',
        '     "feedback": {',
        '       "content": "Short feedback on relevance (state clearly if off-topic)",',
        '       "grammar": "Short grammar tip if needed, otherwise empty",',
        '       "lexical": "Short vocabulary tip if needed, otherwise empty",',
        '       "fluency": "Short fluency tip if needed, otherwise empty"',
        '     },',
        '     "content_score": 0.0,',
        '     "grammar_score": 0.0,',
        '     "fluency_score": 0.0,',
        '     "lexical_score": 0.0,',
        '     "off_topic": false',
        "   }",
        "9. Do not include any markdown formatting outside of the JSON block.",
        "",
        "## Scoring Rubric (STRICT — you must follow these rules exactly)",
        "",
        "### content_score  (0.0–1.0)  — measures RELEVANCE to the active task",
        "  - 0.0–0.2 : Response is completely unrelated to the scenario. Use this when off_topic=true.",
        "  - 0.3–0.5 : Partially related, but mostly tangential or only loosely on-topic.",
        "  - 0.6–0.8 : Mostly relevant; addresses the scenario with reasonable depth.",
        "  - 0.9–1.0 : Fully on-topic; directly answers the task with appropriate detail.",
        "  RULE: If off_topic=true, content_score MUST be ≤ 0.25. No exceptions.",
        "",
        "### grammar_score  (0.0–1.0)  — measures grammatical accuracy and range",
        "  - 0.0–0.4 : Many errors; simple or broken sentence structures.",
        "  - 0.5–0.7 : Some errors; basic but mostly correct structures.",
        "  - 0.8–1.0 : Accurate; wide range of complex grammatical structures.",
        "  NOTE: grammar_score is independent of content relevance.",
        "",
        "### fluency_score  (0.0–1.0)  — measures flow, coherence, and naturalness",
        "  - 0.0–0.4 : Very choppy; disconnected; hard to follow.",
        "  - 0.5–0.7 : Mostly fluent with some hesitation or awkward phrasing.",
        "  - 0.8–1.0 : Smooth; natural; well-connected ideas.",
        "  NOTE: fluency_score is independent of content relevance.",
        "",
        "### lexical_score  (0.0–1.0)  — measures vocabulary range and precision",
        "  - 0.0–0.4 : Very limited vocabulary; repetitive or imprecise word choices.",
        "  - 0.5–0.7 : Adequate range; some imprecision.",
        "  - 0.8–1.0 : Wide, precise vocabulary; uses topic-appropriate language.",
        "  NOTE: lexical_score is independent of content relevance.",
        "",
        "### off_topic  (true/false)",
        "  Set to true if the learner's response has NO meaningful connection to the scenario topic.",
        "  When off_topic=true, you MUST set content_score ≤ 0.25.",
        "",
        "## Calibration Note",
        "  - Scores of 1.0 should be RARE and reserved for truly exceptional, native-like responses.",
        "  - Typical IELTS B2 learners score in the 0.55–0.75 range across all criteria.",
        "  - Even fluent, clear speech from a non-native speaker rarely exceeds 0.85 in any one criterion.",
        "  - Do NOT give 1.0 just because the sentences are grammatically correct in isolation.",
        "  - The Harvard phonetically balanced sentences are grammatically fine but contextually random — score them accordingly.",
    ]

    # --- Pronunciation feedback block (only when errors / low score) ---
    needs_correction = bool(errors) or (score is not None and score < _SCORE_CORRECTION_THRESHOLD)
    if needs_correction:
        lines += [
            "",
            "## Pronunciation guidance",
            "The learner's speech evaluator detected some issues.",
        ]
        if errors:
            error_words = [e.word for e in errors]
            lines.append(f"Mispronounced or missed words: {', '.join(error_words)}")
        if score is not None:
            lines.append(f"Overall pronunciation score: {score:.0%}")
        lines += [
            "Weave ONE brief, friendly pronunciation tip into the `feedback` field of your JSON response.",
            "Keep it natural and in-character — do not lecture.",
            "Example pattern: 'By the way, that word is usually said as ...'",
            "If pronunciation was acceptable, leave the `feedback` field empty.",
        ]

    # --- Persistent memory block ---
    if memory_context.strip():
        lines += [
            "",
            "## Learner's recurring mistakes (from past sessions)",
            memory_context.strip(),
            "Use this context to personalise your coaching, but stay in character.",
        ]

    return "\n".join(lines)


def _history_to_messages(history: list[dict]) -> list[dict]:
    """
    Convert the session's ``turns`` list into ChatML message dicts.

    The session stores turns as::
        {"speaker": "user"|"agent", "text": "...", "turn_index": n, ...}

    The opening agent turn (turn_index == 1, speaker == "agent") is
    already captured in the system context, so we skip it.
    """
    messages: list[dict] = []
    # Take the last N turns (oldest first)
    recent = history[-_MAX_HISTORY_TURNS:]
    for turn in recent:
        role = "user" if turn.get("speaker") == "user" else "assistant"
        text = turn.get("text", "").strip()
        if text:
            messages.append({"role": role, "content": text})
    return messages


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

def build_roleplay_messages(
    scenario: "RoleplayScenario",
    history: list[dict],
    user_utterance: str,
    *,
    errors: list["WordErrorItem"] | None = None,
    score: float | None = None,
    memory_context: str = "",
) -> list[dict]:
    """
    Build the full ChatML messages list for the Qwen2.5-LoRA roleplay model.

    Parameters
    ----------
    scenario:
        The active roleplay scenario (title, context, roles, vocabulary, …).
    history:
        The session's ``turns`` list from ``roleplay_session_service``.
    user_utterance:
        The current (transcribed) user utterance — will become the final
        ``{"role": "user", …}`` message.
    errors:
        Optional word-level pronunciation errors from the speech evaluator.
    score:
        Optional overall pronunciation score in [0, 1].
    memory_context:
        Optional pre-formatted string of recurring mistakes from Qdrant.

    Returns
    -------
    list[dict]
        Ready to pass to ``tokenizer.apply_chat_template(messages, …)``.
    """
    system_prompt = _build_system_prompt(
        scenario,
        errors=errors,
        score=score,
        memory_context=memory_context,
    )

    messages: list[dict] = [{"role": "system", "content": system_prompt}]
    messages.extend(_history_to_messages(history))
    messages.append({"role": "user", "content": user_utterance.strip()})

    return messages


def extract_feedback_from_reply(reply: str) -> str:
    """
    Attempt to pull out a standalone pronunciation tip from the model's reply.

    Returns an empty string if no obvious tip is found.
    The caller should display this as a separate ``feedback`` field in the
    API response without stripping it from ``agent_text``.
    """
    # Common patterns the model uses when given a correction instruction
    tip_patterns = [
        r"[Bb]y the way[,\s].{10,120}[.!?]",
        r"[Tt]ry saying[^.!?]{5,120}[.!?]",
        r"[Pp]ronounced?[^.!?]{5,120}[.!?]",
        r"[Tt]hat word is.{5,120}[.!?]",
        r"[Ss]ay it (?:like|as)[^.!?]{5,100}[.!?]",
        r"[Ii]t'?s (?:pronounced?|said)[^.!?]{5,100}[.!?]",
    ]
    for pattern in tip_patterns:
        m = re.search(pattern, reply)
        if m:
            return m.group(0).strip()
    return ""
