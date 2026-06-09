"""Groq LLM service with multi-key rotation.

Replaces the previous openai_like_service.py that supported Groq + MiniMax.
Only Groq is supported going forward. Embeddings remain on Ollama BGE-M3.
"""

import asyncio
import json
import logging
import os
import threading
import time
from collections import defaultdict
from typing import Literal, Optional

from langchain_core.output_parsers import JsonOutputParser
from langchain_core.prompts import PromptTemplate
from openai import APIError, OpenAI, RateLimitError

logger = logging.getLogger(__name__)

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
            for provider_name, config in providers_config.items():
                keys_env = config.get("api_keys_env")
                if keys_env:
                    keys_str = os.environ.get(keys_env, "")
                    if keys_str:
                        keys = [k.strip() for k in keys_str.split(",") if k.strip()]
                        self._keys[provider_name] = [
                            {"key": k, "index": i, "exhausted": False, "exhausted_at": None, "cooldown_seconds": 3600}
                            for i, k in enumerate(keys)
                        ]
                        logger.info(f"✅ {provider_name.upper()}: Loaded {len(keys)} API keys")
                        continue
                single_key_env = config.get("api_key_env")
                if single_key_env:
                    key = os.environ.get(single_key_env)
                    if key:
                        self._keys[provider_name] = [
                            {"key": key, "index": 0, "exhausted": False, "exhausted_at": None, "cooldown_seconds": 3600}
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

PROVIDERS = {
    "groq": _build_groq_config(),
}

# Single-provider mode: only one entry. The loop is kept for code symmetry with
# the historical multi-provider path, but it never iterates more than once.
DEFAULT_PROVIDER_ORDER = ["groq"]

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
        model_size: Literal["large", "medium", "small"] = "large",
        provider: str = None,
        temperature: float = 0.3,
        max_tokens: int = 4096,
        expect_json: bool = False,
    ) -> dict:
        prompt = PromptTemplate.from_template(prompt_template)
        formatted_prompt = prompt.format(**variables)

        if provider:
            providers_to_try = [(provider, True)]
        else:
            providers_to_try = [(p, True) for p in self.provider_order]

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
            while attempts < max_attempts:
                key_info = key_manager.get_next_key(provider_name)
                if not key_info:
                    logger.warning(f"🚫 All {provider_name.upper()} keys exhausted")
                    break
                api_key, key_index = key_info
                client = self._get_client(provider_name, api_key)
                attempts += 1

                try:
                    create_kwargs = {
                        "model": model_name,
                        "messages": [{"role": "user", "content": formatted_prompt}],
                        "temperature": temperature,
                        "max_tokens": max_tokens,
                    }
                    if expect_json:
                        create_kwargs["response_format"] = {"type": "json_object"}

                    response = await asyncio.to_thread(client.chat.completions.create, **create_kwargs)
                    content = response.choices[0].message.content

                    try:
                        result = json.loads(content)
                        logger.info(f"✅ {provider_name.upper()} response OK (key #{key_index + 1})")
                        return result
                    except json.JSONDecodeError:
                        logger.warning(f"⚠️ {provider_name.upper()} response not valid JSON")
                        if expect_json:
                            retry_messages = [
                                {"role": "system", "content": (
                                    "Your previous response was not valid JSON. "
                                    "Respond ONLY with a JSON object matching the requested schema. "
                                    "No markdown, no commentary."
                                )},
                                {"role": "user", "content": formatted_prompt},
                            ]
                            try:
                                retry_resp = await asyncio.to_thread(
                                    client.chat.completions.create,
                                    model=model_name,
                                    messages=retry_messages,
                                    temperature=0.1,
                                    max_tokens=max_tokens,
                                    response_format={"type": "json_object"},
                                )
                                retry_content = retry_resp.choices[0].message.content
                                result = json.loads(retry_content)
                                logger.info(f"✅ {provider_name.upper()} JSON OK on retry")
                                return result
                            except (json.JSONDecodeError, Exception) as retry_exc:
                                logger.warning(f"⚠️ {provider_name.upper()} still not JSON on retry: {retry_exc}")
                        return {"text": content, "provider": provider_name}

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
