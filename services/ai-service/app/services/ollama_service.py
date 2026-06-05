"""
ollama_service.py
=================
Wrappers around the local Ollama HTTP API.

Public API
----------
generate(prompt_template, variables) -> dict
    Generic JSON-output generation via /api/generate (used by compare_service,
    grammar_service, …)

generate_roleplay_reply(utterance, errors, score, scenario, history, memory_context)
    -> tuple[str, str]
    Roleplay generation via /api/chat for /turn-with-speech and /turn-audio.
    Returns (agent_text, feedback).
    Raises RuntimeError on actual Ollama failure so the router can surface it.

Design notes
------------
* /api/chat  is used for roleplay — it accepts a messages list natively,
  preserves the chat format the model was trained on, and streams by default
  (we set stream=False).
* /api/generate is kept for the generic JSON path (compare/grammar services).
* All Ollama connectivity errors are logged at ERROR level and re-raised so
  they are never silently swallowed into a template fallback.
"""

from __future__ import annotations

import json
import logging
import re
from typing import TYPE_CHECKING

import httpx
from langchain_core.output_parsers import JsonOutputParser
from langchain_core.prompts import PromptTemplate
from langchain_ollama import ChatOllama

from app.config import settings
from app.prompts.roleplay_prompt import build_roleplay_messages, extract_feedback_from_reply
from app.schemas import RoleplayLLMOutput

if TYPE_CHECKING:
    from app.schemas import RoleplayScenario, WordErrorItem

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Generic generation (JSON output — unchanged public contract)
# ---------------------------------------------------------------------------

def _get_model() -> ChatOllama:
    return ChatOllama(
        model=settings.ollama_model,
        base_url=settings.ollama_base_url,
        temperature=settings.ollama_temperature,
        timeout=settings.ollama_timeout,
    )


async def generate(prompt_template: str, variables: dict) -> dict:
    """Call Ollama with a prompt template and parse JSON output."""
    prompt = PromptTemplate.from_template(prompt_template)
    model = _get_model()
    parser = JsonOutputParser()
    chain = prompt | model | parser
    result = await chain.ainvoke(variables)
    return result


async def _call_ollama_chat(messages: list[dict]) -> str:
    """
    POST /api/chat with a messages list.

    Uses the Ollama chat endpoint rather than /api/generate so the model
    receives its native ChatML format (no manual prompt string needed).

    Logs the exact URL and model at INFO level on every call.
    Raises RuntimeError (with the real Ollama error text) on any failure
    so callers can choose whether to surface or degrade.
    """
    url = f"{settings.ollama_base_url.rstrip('/')}/api/chat"
    payload = {
        "model": settings.ollama_model,
        "messages": messages,
        "stream": False,
        "format": "json",  # Enforce JSON output mode
        "options": {
            "temperature": settings.ollama_temperature,
            "num_predict": 400,
            "repeat_penalty": 1.1,
            "top_p": 0.9,
        },
    }

    logger.info(
        "ollama: POST %s  model=%s  messages=%d",
        url,
        settings.ollama_model,
        len(messages),
    )

    try:
        async with httpx.AsyncClient(timeout=settings.ollama_timeout) as client:
            resp = await client.post(url, json=payload)
            resp.raise_for_status()
    except httpx.ConnectError as exc:
        raise RuntimeError(
            f"Cannot reach Ollama at {settings.ollama_base_url} — "
            f"is it running? (ConnectError: {exc})"
        ) from exc
    except httpx.HTTPStatusError as exc:
        body = exc.response.text[:300]
        raise RuntimeError(
            f"Ollama returned HTTP {exc.response.status_code}: {body}"
        ) from exc
    except httpx.TimeoutException as exc:
        raise RuntimeError(
            f"Ollama timed out after {settings.ollama_timeout}s"
        ) from exc

    data = resp.json()

    # Ollama /api/chat response shape:
    #   {"message": {"role": "assistant", "content": "..."}, ...}
    content = (
        data.get("message", {}).get("content", "")
        or data.get("response", "")  # fallback for older Ollama builds
    ).strip()

    logger.info(
        "ollama: generation OK  model=%s  tokens=%s  reply_preview=%r",
        settings.ollama_model,
        data.get("eval_count", "?"),
        content[:80],
    )
    return content


async def generate_roleplay_reply(
    utterance: str,
    errors: list["WordErrorItem"] | None,
    score: float | None,
    scenario: "RoleplayScenario",
    history: list[dict],
    memory_context: str = "",
) -> RoleplayLLMOutput:
    """
    Generate a roleplay agent reply via Ollama's /api/chat endpoint.

    This is the backend for POST /turn-with-speech and /turn-audio.

    Parameters
    ----------
    utterance      : Transcribed user text.
    errors         : Word-level pronunciation errors (may be empty list).
    score          : Pronunciation score in [0, 1].
    scenario       : Active roleplay scenario.
    history        : Session turns list.
    memory_context : Optional Qdrant memory summary string.

    Returns
    -------
    RoleplayLLMOutput
        Structured JSON response with agent reply, feedback, and IELTS metrics.

    Raises
    ------
    RuntimeError
        Propagated from _call_ollama_chat when Ollama is unreachable or errors.
        The router decides whether to fall back or return a 503.
    """
    messages = build_roleplay_messages(
        scenario,
        history,
        utterance,
        errors=errors if errors else None,
        score=score,
        memory_context=memory_context,
    )

    # This may raise RuntimeError — let it propagate so the router can log it
    reply = await _call_ollama_chat(messages)

    if not reply:
        logger.warning(
            "ollama: /api/chat returned empty content for model=%s",
            settings.ollama_model,
        )
        return RoleplayLLMOutput(agent_reply="")

    # Extract JSON block (Ollama JSON mode should already return JSON directly)
    json_str = reply
    match = re.search(r'\{.*\}', reply, re.DOTALL)
    if match:
        json_str = match.group(0)

    try:
        data = json.loads(json_str)
        return RoleplayLLMOutput.model_validate(data)
    except Exception as exc:
        logger.error(
            "ollama: JSON parsing failed for model=%s: %s. Raw reply: %r",
            settings.ollama_model, exc, reply[:200],
        )
        # Graceful fallback: treat raw reply as the agent message
        feedback = extract_feedback_from_reply(reply)
        return RoleplayLLMOutput(agent_reply=reply, feedback=feedback)
