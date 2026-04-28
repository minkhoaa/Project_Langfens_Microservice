"""
OpenAI-compatible LLM service for Groq and Cerebras with multi-key rotation.
Can be used as a drop-in replacement for Gemini/Ollama in compare_service.py

Usage:
    from app.services.openai_like_service import openai_like_generate
    
    result = await openai_like_generate(
        prompt_template=WRITING_COMPARE_PROMPT,
        variables={"student_essay": "...", ...}
    )

Environment Variables:
    # Single key (backward compatible)
    GROQ_API_KEY=xxx
    CEREBRAS_API_KEY=xxx
    
    # Multiple keys (comma-separated, rotated automatically)
    GROQ_API_KEYS=key1,key2,key3
    CEREBRAS_API_KEYS=key1,key2,key3
"""

import os
import json
import logging
import threading
import time
from typing import Literal, Optional
from collections import defaultdict
from openai import OpenAI, APIError, RateLimitError
from langchain_core.output_parsers import JsonOutputParser
from langchain_core.prompts import PromptTemplate

logger = logging.getLogger(__name__)


class KeyManager:
    """
    Manages multiple API keys with automatic rotation when quota is exhausted.
    Thread-safe implementation.
    """
    
    def __init__(self):
        self._lock = threading.Lock()
        # Structure: {provider: {key: {"index": idx, "exhausted": False, "exhausted_at": None}}}
        self._keys: dict[str, list[dict]] = defaultdict(list)
        self._current_indices: dict[str, int] = defaultdict(int)
        self._exhausted_keys: dict[str, set[str]] = defaultdict(set)
        self._initialized = False
    
    def initialize(self, providers_config: dict):
        """Initialize keys from environment variables."""
        if self._initialized:
            return
        
        with self._lock:
            if self._initialized:
                return
                
            for provider_name, config in providers_config.items():
                # Try multiple keys first (comma-separated)
                keys_env = config.get("api_keys_env")
                if keys_env:
                    keys_str = os.environ.get(keys_env, "")
                    if keys_str:
                        keys = [k.strip() for k in keys_str.split(",") if k.strip()]
                        self._keys[provider_name] = [
                            {"key": k, "index": i, "exhausted": False, "exhausted_at": None}
                            for i, k in enumerate(keys)
                        ]
                        logger.info(f"✅ {provider_name.upper()}: Loaded {len(keys)} API keys")
                        continue
                
                # Fallback to single key (backward compatible)
                single_key_env = config.get("api_key_env")
                if single_key_env:
                    key = os.environ.get(single_key_env)
                    if key:
                        self._keys[provider_name] = [
                            {"key": key, "index": 0, "exhausted": False, "exhausted_at": None}
                        ]
                        logger.info(f"✅ {provider_name.upper()}: Loaded 1 API key (single mode)")
            
            self._initialized = True
    
    def get_next_key(self, provider: str) -> Optional[tuple[str, int]]:
        """
        Get the next available key for a provider.
        Returns (api_key, key_index) or None if all keys exhausted.
        """
        with self._lock:
            keys = self._keys.get(provider, [])
            if not keys:
                return None
            
            # Find next non-exhausted key starting from current index
            start_idx = self._current_indices.get(provider, 0)
            attempts = 0
            
            now = time.time()
            # First pass: revive any per-key cooldowns that have elapsed.
            for ki in keys:
                if ki["exhausted"] and ki["exhausted_at"]:
                    cooldown = ki.get("cooldown_seconds", 3600)
                    if (now - ki["exhausted_at"]) >= cooldown:
                        ki["exhausted"] = False
                        ki["exhausted_at"] = None
                        logger.info(
                            f"🔄 {provider.upper()}: Key #{ki['index'] + 1} cooldown elapsed ({cooldown}s), re-enabled"
                        )

            while attempts < len(keys):
                idx = (start_idx + attempts) % len(keys)
                key_info = keys[idx]

                if not key_info["exhausted"]:
                    # Move current index to next key after this one
                    self._current_indices[provider] = (idx + 1) % len(keys)
                    return key_info["key"], idx

                attempts += 1

            # All keys still exhausted after revival pass — give up for this attempt.
            return None

    def mark_exhausted(
        self, provider: str, key_index: int, error_msg: str = "", cooldown_seconds: int = 3600
    ):
        """Mark a key as exhausted.

        cooldown_seconds: how long until the key may be retried. Default 1h
        (treats unknown failures as long cooldown). Pass 60 for rate-limit (429)
        since GROQ TPM windows reset every minute — a 1-hour lockout for a
        transient 429 effectively disables the key for the entire session.
        """
        with self._lock:
            keys = self._keys.get(provider, [])
            if 0 <= key_index < len(keys):
                keys[key_index]["exhausted"] = True
                keys[key_index]["exhausted_at"] = time.time()
                keys[key_index]["cooldown_seconds"] = cooldown_seconds
                key_preview = keys[key_index]["key"][:8] + "..."
                logger.warning(
                    f"🚫 {provider.upper()}: Key {key_preview} marked EXHAUSTED ({cooldown_seconds}s cooldown) - {error_msg}"
                )
    
    def mark_error(self, provider: str, key_index: int, error_msg: str = ""):
        """Mark a key as having an error (non-rate-limit)."""
        with self._lock:
            keys = self._keys.get(provider, [])
            if 0 <= key_index < len(keys):
                key_preview = keys[key_index]["key"][:8] + "..."
                logger.warning(f"⚠️ {provider.upper()}: Key {key_preview} error - {error_msg}")
    
    def get_status(self, provider: str = None) -> dict:
        """Get status of keys for monitoring."""
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
                        {
                            "index": k["index"],
                            "preview": k["key"][:8] + "...",
                            "exhausted": k["exhausted"],
                            "exhausted_at": k["exhausted_at"],
                        }
                        for k in keys
                    ]
                }
            return result


# Global key manager instance
key_manager = KeyManager()


# Provider configurations
PROVIDERS = {
    "groq": {
        "base_url": "https://api.groq.com/openai/v1",
        "api_key_env": "GROQ_API_KEY",      # Single key (backward compatible)
        "api_keys_env": "GROQ_API_KEYS",     # Multiple keys (comma-separated)
        "models": {
            "large": "llama-3.3-70b-versatile",      # Best for IELTS grading (128K context)
            "medium": "meta-llama/llama-4-scout-17b-16e-instruct",  # 328K context
            "small": "llama-3.1-8b-instant",         # Fast, 500K TPD
        },
        "error_codes": {
            429: "rate_limit_exceeded",
            401: "invalid_api_key",
            403: "forbidden",
        }
    },
    "cerebras": {
        "base_url": "https://api.cerebras.ai/v1",  # NOTE: NOT /openai/v1
        "api_key_env": "CEREBRAS_API_KEY",
        "api_keys_env": "CEREBRAS_API_KEYS",
        "models": {
            "large": "qwen-3-235b-a22b-instruct-2507",  # 235B params
            "small": "llama3.1-8b",                       # 8B params
        },
        "error_codes": {
            429: "rate_limit_exceeded",
            401: "invalid_api_key",
        }
    },
}

# Default provider order (tried in sequence until one works)
DEFAULT_PROVIDER_ORDER = ["groq", "cerebras"]


class OpenAILikeService:
    """
    OpenAI-compatible LLM service with:
    - Multiple API key support per provider
    - Automatic key rotation on quota exhaustion
    - Automatic fallback to next available provider
    """
    
    def __init__(self, provider_order: list = None):
        self.provider_order = provider_order or DEFAULT_PROVIDER_ORDER
        self._clients: dict[str, OpenAI] = {}  # Cache clients by provider
        
        # Initialize key manager
        key_manager.initialize(PROVIDERS)
        
        # Log key status
        status = key_manager.get_status()
        for provider, info in status.items():
            if info["total"] > 0:
                logger.info(f"📊 {provider.upper()} keys: {info['available']}/{info['total']} available")
    
    def _get_client(self, provider: str, key: str) -> OpenAI:
        """Get or create a client for the provider with the given key."""
        cache_key = f"{provider}:{key[:8]}"  # Use key prefix for cache
        if cache_key not in self._clients:
            config = PROVIDERS[provider]
            self._clients[cache_key] = OpenAI(
                api_key=key,
                base_url=config["base_url"]
            )
        return self._clients[cache_key]
    
    async def generate(
        self,
        prompt_template: str,
        variables: dict,
        model_size: Literal["large", "medium", "small"] = "large",
        provider: str = None,
        temperature: float = 0.3,
        max_tokens: int = 2048,
        expect_json: bool = False,
    ) -> dict:
        """
        Generate response from LLM using prompt template with automatic key rotation.
        
        Args:
            prompt_template: Jinja2 template string
            variables: Dict of variables to fill template
            model_size: "large", "medium", or "small" (determines which model to use)
            provider: Specific provider to use, or None for auto-fallback
            temperature: Sampling temperature (0-1)
            max_tokens: Maximum tokens in response
            
        Returns:
            Dict parsed from JSON response
            
        Raises:
            RuntimeError: If all providers and all keys are exhausted
        """
        prompt = PromptTemplate.from_template(prompt_template)
        formatted_prompt = prompt.format(**variables)
        
        # Determine which providers to try
        if provider:
            providers_to_try = [(provider, True)]  # (provider_name, allow_rotate)
        else:
            providers_to_try = [(p, True) for p in self.provider_order]
        
        last_error = None
        
        for provider_name, allow_rotate in providers_to_try:
            if provider_name not in PROVIDERS:
                continue
            
            config = PROVIDERS[provider_name]
            model_name = config["models"].get(model_size)
            if not model_name:
                continue
            
            # Try keys for this provider (with rotation)
            max_attempts = 3  # Max keys to try per provider
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
                    logger.debug(f"Calling {provider_name} with model {model_name} (key #{key_index + 1})")

                    create_kwargs = {
                        "model": model_name,
                        "messages": [{"role": "user", "content": formatted_prompt}],
                        "temperature": temperature,
                        "max_tokens": max_tokens,
                    }
                    if expect_json:
                        create_kwargs["response_format"] = {"type": "json_object"}

                    response = client.chat.completions.create(**create_kwargs)
                    content = response.choices[0].message.content

                    # Success - try to parse as JSON
                    try:
                        result = json.loads(content)
                        logger.info(f"✅ {provider_name.upper()} response OK (key #{key_index + 1})")
                        return result
                    except json.JSONDecodeError:
                        logger.warning(f"⚠️ {provider_name.upper()} response not valid JSON")
                        if expect_json:
                            # 1-retry: re-prompt with stricter system instruction
                            retry_messages = [
                                {"role": "system", "content": (
                                    "Your previous response was not valid JSON. "
                                    "Respond ONLY with a JSON object matching the requested schema. "
                                    "No markdown, no commentary."
                                )},
                                {"role": "user", "content": formatted_prompt},
                            ]
                            try:
                                retry_resp = client.chat.completions.create(
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
                                logger.warning(
                                    f"⚠️ {provider_name.upper()} still not JSON on retry: {retry_exc}"
                                )
                        return {"text": content, "provider": provider_name}
                
                except RateLimitError as e:
                    error_msg = str(e)
                    if "429" in error_msg or "rate limit" in error_msg.lower():
                        # GROQ TPM windows reset every minute; a long cooldown
                        # would disable a key that's actually fine in 60s.
                        key_manager.mark_exhausted(
                            provider_name, key_index, "rate limit", cooldown_seconds=60
                        )
                        continue  # Try next key
                    else:
                        key_manager.mark_error(provider_name, key_index, error_msg)
                        last_error = e
                        break  # Non-retryable error

                except APIError as e:
                    error_code = getattr(e, "status_code", None)
                    error_msg = str(e)

                    if error_code == 401:
                        # Invalid key - long cooldown (won't recover for this run)
                        key_manager.mark_exhausted(
                            provider_name, key_index, "invalid key", cooldown_seconds=3600
                        )
                        continue
                    
                    key_manager.mark_error(provider_name, key_index, error_msg)
                    last_error = e
                    break
                
                except Exception as e:
                    key_manager.mark_error(provider_name, key_index, str(e))
                    last_error = e
                    break
            
            # If we exhausted all keys for this provider, try next provider
            continue
        
        # All providers and keys exhausted
        raise RuntimeError(f"All LLM providers exhausted. Last error: {last_error}")
    
    def get_key_status(self, provider: str = None) -> dict:
        """Get status of API keys for monitoring/debugging."""
        return key_manager.get_status(provider)


# Global instance
openai_like_service = OpenAILikeService()


async def openai_like_generate(prompt_template: str, variables: dict, **kwargs) -> dict:
    """Convenience function for generate()."""
    return await openai_like_service.generate(prompt_template, variables, **kwargs)


def get_llm_key_status() -> dict:
    """Get LLM key status for monitoring endpoint."""
    return openai_like_service.get_key_status()
