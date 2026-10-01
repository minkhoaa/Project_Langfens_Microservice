"""Multi-provider LLM service (Groq + MiniMax) with multi-key rotation and JSON extraction.

Supports Groq as primary and MiniMax as fallback/alternative provider.
Embeddings remain on Ollama BGE-M3.
"""

import asyncio
import json
import logging
import os
import re
import threading
import time
from collections import defaultdict
from typing import Any, Callable, Literal, Optional
from langchain_core.output_parsers import JsonOutputParser
from langchain_core.prompts import PromptTemplate
from openai import APIError, OpenAI, RateLimitError

logger = logging.getLogger(__name__)

def _clean_text_content(text: str) -> str:
    text = (text or "").strip()
    # Strip <think>...</think> reasoning tags emitted by reasoning models (e.g. MiniMax M3, DeepSeek R1)
    text = re.sub(r"<think>[\s\S]*?</think>", "", text).strip()
    if "<think>" in text and "</think>" not in text:
        text = text.split("<think>")[0].strip()
    if "</think>" in text:
        text = text.split("</think>")[-1].strip()
    return text


def _extract_json(text: str) -> Any:
    text = _clean_text_content(text)
    try:
        parsed = json.loads(text)
        if isinstance(parsed, (dict, list)):
            return parsed
        return {"data": parsed}
    except json.JSONDecodeError:
        pass

    # Strip markdown code fences if present (e.g. ```json ... ```)
    if "```" in text:
        match = re.search(r"```(?:json)?\s*([\s\S]*?)\s*```", text)
        if match:
            candidate = match.group(1).strip()
            try:
                parsed = json.loads(candidate)
                if isinstance(parsed, (dict, list)):
                    return parsed
                return {"data": parsed}
            except json.JSONDecodeError:
                pass

    # Extract outermost JSON object { ... } or array [ ... ] by scanning from the end
    last_brace = text.rfind("}")
    if last_brace != -1:
        start_indices = [i for i, c in enumerate(text[:last_brace]) if c == "{"]
        for start in start_indices:
            candidate = text[start : last_brace + 1]
            try:
                parsed = json.loads(candidate)
                if isinstance(parsed, (dict, list)):
                    return parsed
                return {"data": parsed}
            except json.JSONDecodeError:
                continue

    last_bracket = text.rfind("]")
    if last_bracket != -1:
        start_indices = [i for i, c in enumerate(text[:last_bracket]) if c == "["]
        for start in start_indices:
            candidate = text[start : last_bracket + 1]
            try:
                parsed = json.loads(candidate)
                if isinstance(parsed, (dict, list)):
                    return parsed
                return {"data": parsed}
            except json.JSONDecodeError:
                continue
    raise json.JSONDecodeError("Could not parse JSON", text, 0)

class KeyManager:
    """Manages multiple Groq API keys with automatic rotation on quota exhaustion."""

    def __init__(self):
        self._lock = threading.Lock()
        self._keys: dict[str, list[dict]] = defaultdict(list)
        self._current_indices: dict[str, int] = defaultdict(int)
        self._initialized = False

    def initialize(self, providers_config: dict):
        if self._initialized:
            return
        with self._lock:
            if self._initialized:
                return
            from app.config import settings
            for provider_name, config in providers_config.items():
                keys_env = config.get("api_keys_env")
                if keys_env:
                    keys_str = os.environ.get(keys_env, "") or getattr(settings, keys_env.lower(), "")
                    if keys_str:
                        keys = [k.strip() for k in str(keys_str).split(",") if k.strip()]
                        self._keys[provider_name] = [
                            {"key": k, "index": i, "exhausted": False, "exhausted_at": None, "cooldown_seconds": 3600}
                            for i, k in enumerate(keys)
                        ]
                        logger.info(f"✅ {provider_name.upper()}: Loaded {len(keys)} API keys")
                        continue
                single_key_env = config.get("api_key_env")
                if single_key_env:
                    key = os.environ.get(single_key_env, "") or getattr(settings, single_key_env.lower(), "")
                    if key:
                        self._keys[provider_name] = [
                            {"key": str(key).strip(), "index": 0, "exhausted": False, "exhausted_at": None, "cooldown_seconds": 3600}
                        ]
                        logger.info(f"✅ {provider_name.upper()}: Loaded 1 API key (single mode)")
            self._initialized = True

    def get_next_key(self, provider: str) -> Optional[tuple[str, int]]:
        with self._lock:
            keys = self._keys.get(provider, [])
            if not keys:
                return None
            start_idx = self._current_indices.get(provider, 0)
            attempts = 0
            now = time.time()
            # Revival pass: any key whose cooldown has elapsed is re-enabled.
            for ki in keys:
                if ki["exhausted"] and ki["exhausted_at"]:
                    cooldown = ki.get("cooldown_seconds", 3600)
                    if (now - ki["exhausted_at"]) >= cooldown:
                        ki["exhausted"] = False
                        ki["exhausted_at"] = None
                        logger.info(f"🔄 {provider.upper()}: Key #{ki['index'] + 1} cooldown elapsed, re-enabled")
            while attempts < len(keys):
                idx = (start_idx + attempts) % len(keys)
                key_info = keys[idx]
                if not key_info["exhausted"]:
                    self._current_indices[provider] = (idx + 1) % len(keys)
                    return key_info["key"], idx
                attempts += 1
            return None

    def mark_exhausted(self, provider: str, key_index: int, error_msg: str = "", cooldown_seconds: int = 3600):
        with self._lock:
            keys = self._keys.get(provider, [])
            if 0 <= key_index < len(keys):
                keys[key_index]["exhausted"] = True
                keys[key_index]["exhausted_at"] = time.time()
                keys[key_index]["cooldown_seconds"] = cooldown_seconds
                logger.warning(f"🚫 {provider.upper()}: Key {keys[key_index]['key'][:8]}... EXHAUSTED ({cooldown_seconds}s) - {error_msg}")

    def mark_error(self, provider: str, key_index: int, error_msg: str = ""):
        with self._lock:
            keys = self._keys.get(provider, [])
            if 0 <= key_index < len(keys):
                logger.warning(f"⚠️ {provider.upper()}: Key {keys[key_index]['key'][:8]}... error - {error_msg}")

    def get_status(self, provider: str = None) -> dict:
        with self._lock:
            result = {}
            providers = [provider] if provider else list(self._keys.keys())
            for p in providers:
                keys = self._keys.get(p, [])
                result[p] = {
                    "total": len(keys),
                    "available": sum(1 for k in keys if not k["exhausted"]),
                    "exhausted": sum(1 for k in keys if k["exhausted"]),
                    "current_index": self._current_indices.get(p, 0),
                    "keys": [
                        {"index": k["index"], "preview": k["key"][:8] + "...", "exhausted": k["exhausted"], "exhausted_at": k["exhausted_at"]}
                        for k in keys
                    ],
                }
            return result

# Global key manager instance
key_manager = KeyManager()

def _build_groq_config() -> dict:
    """Build the groq provider config from current env vars at import time.

    `groq_base_url` and `groq_model` are added to Pydantic Settings in Task 4
    but we read os.environ here so the service works whether or not the new
    config fields are wired in yet.
    """
    from app.config import settings  # local import to avoid circulars

    base_url = getattr(settings, "groq_base_url", None) or os.environ.get("GROQ_BASE_URL", "https://api.groq.com/openai/v1")
    model = getattr(settings, "groq_model", None) or os.environ.get("GROQ_MODEL", "openai/gpt-oss-20b")
    return {
        "base_url": base_url,
        "api_key_env": "GROQ_API_KEY",
        "api_keys_env": "GROQ_API_KEYS",
        "models": {
            "xlarge": "openai/gpt-oss-120b",  # Used for pre-LLM band estimation
            "large": model,
            "medium": "qwen-2.5-32b",
            "small": "llama-3.1-8b-instant",
        },
        "error_codes": {
            429: "rate_limit_exceeded",
            401: "invalid_api_key",
            403: "forbidden",
        },
    }

def _build_minimax_config() -> dict:
    """Build the minimax provider config from current env vars or settings."""
    from app.config import settings

    base_url = getattr(settings, "minimax_base_url", None) or os.environ.get("MINIMAX_BASE_URL", "https://api.minimaxi.chat/v1")
    model = os.environ.get("MINIMAX_MODEL") or getattr(settings, "minimax_model", None)
    if not model or model == "MiniMax-M3":
        model = "MiniMax-Text-01"
    return {
        "base_url": base_url,
        "api_key_env": "MINIMAX_API_KEY",
        "api_keys_env": "MINIMAX_API_KEYS",
        "models": {
            "xlarge": model,
            "large": model,
            "medium": model,
            "small": model,
        },
        "error_codes": {
            429: "rate_limit_exceeded",
            401: "invalid_api_key",
            403: "forbidden",
        },
    }

PROVIDERS = {
    "groq": _build_groq_config(),
    "minimax": _build_minimax_config(),
}

def _get_default_provider_order() -> list[str]:
    from app.config import settings
    order_str = os.environ.get("LLM_PROVIDER_ORDER") or getattr(settings, "llm_provider_order", None)
    if order_str:
        return [p.strip().lower() for p in str(order_str).split(",") if p.strip()]
    return ["minimax", "groq"]

DEFAULT_PROVIDER_ORDER = _get_default_provider_order()

class GroqService:
    """Groq LLM service: multi-key rotation, JSON output, retry on transient errors."""

    def __init__(self, provider_order: list = None):
        self.provider_order = provider_order or DEFAULT_PROVIDER_ORDER
        self._clients: dict[str, OpenAI] = {}
        key_manager.initialize(PROVIDERS)
        status = key_manager.get_status()
        for provider, info in status.items():
            if info["total"] > 0:
                logger.info(
                    f"📊 {provider.upper()} keys: {info['available']}/{info['total']} available "
                    f"model={PROVIDERS[provider]['models']['large']} base_url={PROVIDERS[provider]['base_url']}"
                )

    def _get_client(self, provider: str, key: str) -> OpenAI:
        cache_key = f"{provider}:{key[:8]}"
        if cache_key not in self._clients:
            config = PROVIDERS[provider]
            self._clients[cache_key] = OpenAI(api_key=key, base_url=config["base_url"])
        return self._clients[cache_key]

    async def generate(
        self,
        prompt_template: str,
        variables: dict,
        model_size: Literal["xlarge", "large", "medium", "small"] = "large",
        provider: str = None,
        temperature: float = 0.3,
        max_tokens: int = 4096,
        expect_json: bool = False,
        stream_callback: Optional[Callable[[str, str], Any]] = None,
    ) -> dict:
        prompt = PromptTemplate.from_template(prompt_template)
        formatted_prompt = prompt.format(**variables)

        status = key_manager.get_status()
        configured = [p for p in self.provider_order if status.get(p, {}).get("total", 0) > 0]
        active_order = configured or self.provider_order
        if provider and provider in active_order:
            providers_to_try = [(provider, True)] + [(p, True) for p in active_order if p != provider]
        elif provider:
            providers_to_try = [(provider, True)] + [(p, True) for p in active_order]
        else:
            providers_to_try = [(p, True) for p in active_order]
        last_error = None
        for provider_name, _ in providers_to_try:
            if provider_name not in PROVIDERS:
                continue
            config = PROVIDERS[provider_name]
            model_name = config["models"].get(model_size)
            if not model_name:
                continue

            max_attempts = 6  # Reasoning models miss intermittently; keys rotate.
            attempts = 0
            empty_attempts = 0
            while attempts < max_attempts:
                key_info = key_manager.get_next_key(provider_name)
                if not key_info:
                    logger.warning(f"🚫 All {provider_name.upper()} keys exhausted")
                    break
                api_key, key_index = key_info
                client = self._get_client(provider_name, api_key)
                attempts += 1

                try:
                    no_response_format = provider_name == "minimax" or any(r in model_name.lower() for r in ("deepseek-r1", "qwq"))
                    create_kwargs = {
                        "model": model_name,
                        "messages": [{"role": "user", "content": formatted_prompt}],
                        "temperature": temperature,
                        "max_tokens": max_tokens,
                    }
                    if provider_name == "minimax":
                        create_kwargs["extra_body"] = {"reasoning_split": True, "reasoning_effort": "low"}
                        if "m3" in model_name.lower():
                            create_kwargs["max_tokens"] = max(max_tokens, 8192)
                            create_kwargs["max_completion_tokens"] = max(max_tokens, 8192)
                    if expect_json and not no_response_format:
                        create_kwargs["response_format"] = {"type": "json_object"}

                    if stream_callback is not None:
                        create_kwargs["stream"] = True

                        def _run_stream():
                            content_chunks = []
                            reasoning_chunks = []
                            resp = client.chat.completions.create(**create_kwargs)
                            if not hasattr(resp, "__iter__") and hasattr(resp, "choices"):
                                c = resp.choices[0].message.content or ""
                                r = getattr(resp.choices[0].message, "reasoning_content", None) or ""
                                finish = getattr(resp.choices[0], "finish_reason", None)
                                stream_callback("content", c)
                                return c, r, finish
                            finish = None
                            for chunk in resp:
                                if not getattr(chunk, "choices", None):
                                    continue
                                ch = chunk.choices[0]
                                delta = getattr(ch, "delta", None)
                                if not delta:
                                    continue
                                tok = getattr(delta, "content", None)
                                tok = tok if isinstance(tok, str) else ""
                                r_tok = getattr(delta, "reasoning_content", None)
                                if not isinstance(r_tok, str):
                                    r_tok = getattr(delta, "reasoning", None)
                                r_tok = r_tok if isinstance(r_tok, str) else ""
                                if getattr(ch, "finish_reason", None):
                                    finish = ch.finish_reason
                                if tok:
                                    content_chunks.append(tok)
                                    stream_callback("content", tok)
                                if r_tok:
                                    reasoning_chunks.append(r_tok)
                                    stream_callback("reasoning", r_tok)
                            return "".join(content_chunks), "".join(reasoning_chunks), finish

                        content, reasoning_str, finish_reason = await asyncio.to_thread(_run_stream)
                        reasoning = reasoning_str
                    else:
                        response = await asyncio.to_thread(client.chat.completions.create, **create_kwargs)
                        choice = response.choices[0]
                        content = choice.message.content or ""
                        finish_reason = getattr(choice, "finish_reason", None)
                        reasoning = getattr(choice.message, "reasoning_content", None) or getattr(choice.message, "reasoning", None)

                    if not content.strip():
                        logger.warning(
                            f"⚠️ {provider_name.upper()} returned empty content "
                            f"(finish_reason={finish_reason}, has_reasoning={bool(reasoning)})"
                        )
                        last_error = f"{provider_name} returned empty content"
                        empty_attempts += 1
                        if empty_attempts >= 2:
                            logger.warning(f"⚠️ {provider_name.upper()} empty content retry limit reached; falling back to next provider")
                            break
                        continue

                    if not expect_json:
                        clean_content = _clean_text_content(content)
                        if not clean_content.strip():
                            logger.warning(f"⚠️ {provider_name.upper()} content empty after stripping reasoning tags")
                            last_error = f"{provider_name} content empty after stripping reasoning"
                            empty_attempts += 1
                            if empty_attempts >= 2:
                                logger.warning(f"⚠️ {provider_name.upper()} empty content retry limit reached; falling back to next provider")
                                break
                            continue
                        try:
                            return _extract_json(clean_content)
                        except json.JSONDecodeError:
                            return {"text": clean_content, "provider": provider_name}

                    try:
                        result = _extract_json(content)
                        logger.info(f"✅ {provider_name.upper()} response OK (key #{key_index + 1})")
                        return result
                    except json.JSONDecodeError:
                        logger.warning(f"⚠️ {provider_name.upper()} response not valid JSON")
                        retry_messages = [
                            {"role": "user", "content": (
                                formatted_prompt
                                + "\n\nCRITICAL: Your previous response was not valid JSON. "
                                "Respond ONLY with a valid JSON object matching the requested schema. "
                                "No markdown code blocks, no explanations, no text before or after the JSON."
                            )},
                        ]
                        retry_kwargs = {
                            "model": model_name,
                            "messages": retry_messages,
                            "temperature": 0.1,
                            "max_tokens": max_tokens,
                        }
                        if provider_name == "minimax":
                            retry_kwargs["extra_body"] = {"reasoning_split": True, "reasoning_effort": "low"}
                            retry_kwargs["max_tokens"] = max(max_tokens, 8192)
                            retry_kwargs["max_completion_tokens"] = max(max_tokens, 8192)
                        if not no_response_format:
                            retry_kwargs["response_format"] = {"type": "json_object"}
                        try:
                            retry_resp = await asyncio.to_thread(
                                client.chat.completions.create,
                                **retry_kwargs,
                            )
                            retry_choice = retry_resp.choices[0]
                            retry_content = retry_choice.message.content or ""
                            result = _extract_json(retry_content)
                            logger.info(f"✅ {provider_name.upper()} JSON OK on retry")
                            return result
                        except (json.JSONDecodeError, Exception) as retry_exc:
                            logger.warning(f"⚠️ {provider_name.upper()} still not JSON on retry: {retry_exc}")
                        last_error = f"{provider_name} response could not be parsed as JSON on retry"
                        break

                except RateLimitError as e:
                    error_msg = str(e)
                    if "429" in error_msg or "rate limit" in error_msg.lower():
                        # Groq TPM windows reset every minute.
                        key_manager.mark_exhausted(provider_name, key_index, "rate limit", cooldown_seconds=60)
                        last_error = e
                        continue
                    key_manager.mark_error(provider_name, key_index, error_msg)
                    last_error = e
                    break

                except APIError as e:
                    error_code = getattr(e, "status_code", None)
                    error_msg = str(e)
                    if "response_format" in error_msg.lower():
                        # Provider doesn't support response_format; retry without it
                        retry_kwargs = dict(create_kwargs)
                        retry_kwargs.pop("response_format", None)
                        try:
                            resp = await asyncio.to_thread(client.chat.completions.create, **retry_kwargs)
                            c = resp.choices[0].message.content or ""
                            result = _extract_json(c)
                            logger.info(f"✅ {provider_name.upper()} response OK without response_format")
                            return result
                        except Exception:
                            pass
                    if error_code == 401:
                        key_manager.mark_exhausted(provider_name, key_index, "invalid key", cooldown_seconds=3600)
                        last_error = e
                        continue
                    if error_code == 400 and "json_validate_failed" in error_msg:
                        key_manager.mark_error(provider_name, key_index, "json_validate_failed (transient, retrying)")
                        last_error = e
                        continue
                    key_manager.mark_error(provider_name, key_index, error_msg)
                    last_error = e
                    break
                except Exception as e:
                    key_manager.mark_error(provider_name, key_index, str(e))
                    last_error = e
                    break

        raise RuntimeError(f"All LLM providers exhausted. Last error: {last_error}")

    def get_key_status(self, provider: str = None) -> dict:
        return key_manager.get_status(provider)

groq_service = GroqService()

async def groq_generate(prompt_template: str, variables: dict, **kwargs) -> dict:
    return await groq_service.generate(prompt_template, variables, **kwargs)

def get_groq_key_status() -> dict:
    return groq_service.get_key_status()
