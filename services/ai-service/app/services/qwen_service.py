"""
Local Qwen2.5-LoRA model service.

Loads the fine-tuned adapter once at startup and exposes an async
``qwen_roleplay_generate`` function that the speaking router can call
in place of the Ollama / Gemini paths.

Design principles
-----------------
* **Singleton** — the base model + LoRA adapter are loaded once into a
  module-level pair; subsequent calls reuse them.
* **Lazy + thread-safe** — an ``asyncio.Lock`` prevents concurrent loads on
  the first request when the lifespan hook is not used.
* **Non-blocking** — ``model.generate()`` is a blocking call; it is always
  dispatched to a thread-pool executor so the event loop is never stalled.
* **Graceful degradation** — any exception during load or generation returns
  ``("", "")`` so the caller can fall back to Ollama/Gemini.
"""

from __future__ import annotations

import asyncio
import logging
import re
from functools import partial
from typing import TYPE_CHECKING

import torch

from app.config import settings
from app.prompts.roleplay_prompt import build_roleplay_messages, extract_feedback_from_reply

if TYPE_CHECKING:
    from app.schemas import RoleplayScenario, WordErrorItem
from app.schemas import RoleplayLLMOutput

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Module-level singletons
# ---------------------------------------------------------------------------

_tokenizer = None
_model = None
_load_lock: asyncio.Lock | None = None   # created lazily (event-loop aware)
_model_ready: bool = False


def _get_lock() -> asyncio.Lock:
    """Return the module-level lock, creating it if necessary."""
    global _load_lock
    if _load_lock is None:
        _load_lock = asyncio.Lock()
    return _load_lock


# ---------------------------------------------------------------------------
# Model loading (blocking — runs in executor)
# ---------------------------------------------------------------------------

def _resolve_device(requested: str) -> str:
    """
    Validate the requested device string, falling back to CPU gracefully.
    """
    if requested == "cuda":
        if torch.cuda.is_available():
            return "cuda"
        logger.warning(
            "qwen_service: CUDA requested but not available — falling back to CPU. "
            "Set LORA_DEVICE=cpu in ai.env to suppress this warning."
        )
        return "cpu"
    if requested == "mps":
        if torch.backends.mps.is_available():  # type: ignore[attr-defined]
            return "mps"
        logger.warning("qwen_service: MPS requested but not available — falling back to CPU.")
        return "cpu"
    return "cpu"


def _load_model_blocking() -> None:
    """
    Load base model + LoRA adapter into module-level singletons.

    Called once from an executor thread; never call directly from an async
    context.
    """
    global _tokenizer, _model, _model_ready

    # Deferred imports — only pay the cost when the feature is enabled
    from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig
    from peft import PeftModel

    device = _resolve_device(settings.lora_device)
    model_path = settings.lora_model_path
    base_model_id = settings.lora_base_model

    logger.info(
        "qwen_service: Loading tokenizer from %s …", model_path
    )
    tok = AutoTokenizer.from_pretrained(
        model_path,
        trust_remote_code=True,
        padding_side="left",
    )

    logger.info(
        "qwen_service: Loading base model %s (device=%s, 4bit=%s) …",
        base_model_id,
        device,
        settings.lora_load_in_4bit,
    )

    load_kwargs: dict = {
        "trust_remote_code": True,
        "torch_dtype": torch.float16 if device != "cpu" else torch.float32,
    }

    if settings.lora_load_in_4bit:
        try:
            bnb_config = BitsAndBytesConfig(
                load_in_4bit=True,
                bnb_4bit_use_double_quant=True,
                bnb_4bit_quant_type="nf4",
                bnb_4bit_compute_dtype=torch.bfloat16,
            )
            load_kwargs["quantization_config"] = bnb_config
            load_kwargs["device_map"] = "auto"
        except Exception as exc:
            logger.warning(
                "qwen_service: bitsandbytes 4-bit config failed (%s); "
                "loading in full precision instead.",
                exc,
            )
    else:
        if device != "cpu":
            load_kwargs["device_map"] = device

    base = AutoModelForCausalLM.from_pretrained(base_model_id, **load_kwargs)

    logger.info("qwen_service: Attaching LoRA adapter from %s …", model_path)
    model = PeftModel.from_pretrained(base, model_path, is_trainable=False)
    model.eval()

    # Move to device only when device_map was not used
    if "device_map" not in load_kwargs and device != "cpu":
        model = model.to(device)

    _tokenizer = tok
    _model = model
    _model_ready = True
    logger.info("qwen_service: Model ready on device '%s'.", device)


# ---------------------------------------------------------------------------
# Public lifecycle
# ---------------------------------------------------------------------------

async def load_qwen_model() -> None:
    """
    Pre-warm the model.

    Safe to call multiple times; subsequent calls are no-ops.
    Intended for the FastAPI lifespan hook.
    """
    if _model_ready:
        return

    lock = _get_lock()
    async with lock:
        if _model_ready:
            return
        loop = asyncio.get_event_loop()
        try:
            await loop.run_in_executor(None, _load_model_blocking)
        except Exception as exc:
            logger.error("qwen_service: Model load failed: %s", exc, exc_info=True)
            raise


# ---------------------------------------------------------------------------
# Inference (blocking — runs in executor)
# ---------------------------------------------------------------------------

def _generate_blocking(
    messages: list[dict],
    max_new_tokens: int,
    temperature: float,
    top_p: float,
    repetition_penalty: float,
) -> str:
    """
    Tokenize, generate, decode.  Runs in a thread-pool executor.
    """
    assert _tokenizer is not None and _model is not None, "Model not loaded"

    # Resolve the actual device the model lives on
    try:
        device = next(_model.parameters()).device
    except StopIteration:
        device = torch.device("cpu")

    # Build the prompt string via the tokenizer's chat template
    prompt_str: str = _tokenizer.apply_chat_template(
        messages,
        tokenize=False,
        add_generation_prompt=True,
    )

    inputs = _tokenizer(
        prompt_str,
        return_tensors="pt",
        truncation=True,
        max_length=2048,
    ).to(device)

    input_len = inputs["input_ids"].shape[1]

    with torch.no_grad():
        output_ids = _model.generate(
            **inputs,
            max_new_tokens=max_new_tokens,
            do_sample=True,
            temperature=temperature,
            top_p=top_p,
            repetition_penalty=repetition_penalty,
            pad_token_id=_tokenizer.eos_token_id,
        )

    # Decode only the newly generated tokens (skip the prompt)
    new_ids = output_ids[0][input_len:]
    reply = _tokenizer.decode(new_ids, skip_special_tokens=True).strip()
    return reply


# ---------------------------------------------------------------------------
# Public async API
# ---------------------------------------------------------------------------

async def qwen_roleplay_generate(
    scenario: "RoleplayScenario",
    history: list[dict],
    user_utterance: str,
    *,
    errors: list["WordErrorItem"] | None = None,
    score: float | None = None,
    memory_context: str = "",
) -> RoleplayLLMOutput:
    """
    Generate an agent reply using the local Qwen2.5-LoRA model.

    Parameters
    ----------
    scenario:
        The active roleplay scenario.
    history:
        Session turns list (from ``roleplay_session_service``).
    user_utterance:
        Current (transcribed) user text.
    errors:
        Optional pronunciation errors from the speech evaluator.
    score:
        Optional pronunciation score in [0, 1].
    memory_context:
        Optional pre-formatted recurring-mistakes string from Qdrant.

    Returns
    -------
    RoleplayLLMOutput
        Structured JSON response containing the agent reply, feedback, and IELTS metrics.
        Returns a default empty object on failure.

    Notes
    -----
    * Falls back to ``("", "")`` on any exception so the caller can degrade
      gracefully to Ollama or Gemini.
    * If the model is not yet loaded, triggers a lazy load first.
    """
    # Lazy load if not pre-warmed by lifespan
    if not _model_ready:
        try:
            await load_qwen_model()
        except Exception as exc:
            logger.error("qwen_service: lazy load failed: %s", exc)
            return RoleplayLLMOutput(agent_reply="")

    messages = build_roleplay_messages(
        scenario,
        history,
        user_utterance,
        errors=errors,
        score=score,
        memory_context=memory_context,
    )

    loop = asyncio.get_event_loop()
    fn = partial(
        _generate_blocking,
        messages,
        settings.lora_max_new_tokens,
        settings.lora_temperature,
        settings.lora_top_p,
        settings.lora_repetition_penalty,
    )

    try:
        reply = await loop.run_in_executor(None, fn)
    except Exception as exc:
        logger.error("qwen_service: generation failed: %s", exc, exc_info=True)
        return RoleplayLLMOutput(agent_reply="")

    if not reply:
        return RoleplayLLMOutput(agent_reply="")

    # Extract JSON block
    import json
    json_str = reply
    match = re.search(r'\{.*\}', reply, re.DOTALL)
    if match:
        json_str = match.group(0)
    
    try:
        data = json.loads(json_str)
        return RoleplayLLMOutput.model_validate(data)
    except Exception as exc:
        logger.error("qwen_service: JSON parsing failed: %s", exc)
        # Fallback to plain text if JSON extraction failed completely
        feedback = extract_feedback_from_reply(reply)
        return RoleplayLLMOutput(agent_reply=reply, feedback=feedback)

async def qwen_generate(
    prompt: str,
    max_tokens: int = 800,
    expect_json: bool = False,
) -> dict:
    """Generate generic response using Qwen LoRA."""
    if not _model_ready:
        try:
            await load_qwen_model()
        except Exception as exc:
            logger.error("qwen_service: lazy load failed: %s", exc)
            raise RuntimeError("Model not loaded")

    messages = [{"role": "user", "content": prompt}]

    loop = asyncio.get_event_loop()
    fn = partial(
        _generate_blocking,
        messages,
        max_tokens,
        settings.lora_temperature,
        settings.lora_top_p,
        settings.lora_repetition_penalty,
    )
    
    try:
        reply = await loop.run_in_executor(None, fn)
    except Exception as exc:
        logger.error("qwen_service: generation failed: %s", exc, exc_info=True)
        return {}

    if not reply:
        return {}

    if expect_json:
        import json
        json_str = reply
        match = re.search(r'\{.*\}', reply, re.DOTALL)
        if match:
            json_str = match.group(0)
        try:
            return json.loads(json_str)
        except Exception as exc:
            logger.error("qwen_service: JSON parsing failed: %s", exc)
            return {}
            
    return {"text": reply}
