from __future__ import annotations

import asyncio
import logging
import os
import time
from typing import Any, Dict, List, Optional, Tuple

from app.config import settings
from app.providers.adapters.groq import GroqProvider
from app.providers.adapters.minimax import MiniMaxProvider
from app.providers.base import BaseProvider, redact_secrets

logger = logging.getLogger(__name__)


class KeyInfo:
    def __init__(self, key: str, index: int, cooldown_seconds: float = 65.0):
        self.key = key
        self.index = index
        self.exhausted = False
        self.exhausted_at: Optional[float] = None
        self.cooldown_seconds = cooldown_seconds
        self.last_dispatched_at: float = 0.0


class TokenBucket:
    """Token bucket rate limiter for provider calls."""

    def __init__(self, rate_per_second: float = 10.0, capacity: float = 20.0):
        self.rate = rate_per_second
        self.capacity = capacity
        self.tokens = capacity
        self.last_update = time.time()
        self._lock = asyncio.Lock()

    async def acquire(self) -> None:
        async with self._lock:
            now = time.time()
            elapsed = now - self.last_update
            self.last_update = now
            self.tokens = min(self.capacity, self.tokens + elapsed * self.rate)
            if self.tokens < 1.0:
                wait_time = (1.0 - self.tokens) / self.rate
                await asyncio.sleep(wait_time)
                self.tokens = 0.0
                self.last_update = time.time()
            else:
                self.tokens -= 1.0


class ProviderRegistry:
    """Central registry and routing controller for LLM providers, key rotation,

    concurrency limits, and rate buckets.
    """

    def __init__(self) -> None:
        self._providers: Dict[str, BaseProvider] = {}
        self._keys: Dict[str, List[KeyInfo]] = {}
        self._current_indices: Dict[str, int] = {}
        self._semaphores: Dict[str, asyncio.Semaphore] = {}
        self._rate_limiters: Dict[str, TokenBucket] = {}
        self._lock = asyncio.Lock()
        self._initialized = False

    def register_provider(
        self,
        provider: BaseProvider,
        keys: Optional[List[str]] = None,
        max_concurrency: int = 5,
        rate_per_second: float = 10.0,
    ) -> None:
        name = provider.name.lower()
        self._providers[name] = provider
        self._semaphores[name] = asyncio.Semaphore(max_concurrency)
        self._rate_limiters[name] = TokenBucket(rate_per_second=rate_per_second, capacity=max_concurrency * 2)

        key_list = keys or []
        self._keys[name] = [KeyInfo(key=k.strip(), index=i) for i, k in enumerate(key_list) if k.strip()]
        self._current_indices[name] = 0

    def get_provider(self, name: str) -> Optional[BaseProvider]:
        if not self._providers and not self._initialized:
            self.initialize_from_settings()
        return self._providers.get(name.lower())

    def get_provider_order(self, preferred: Optional[str] = None) -> List[str]:
        if not self._providers and not self._initialized:
            self.initialize_from_settings()
        configured_order = [p.strip().lower() for p in settings.llm_provider_order.split(",") if p.strip()]
        if not configured_order:
            configured_order = ["minimax", "groq"]

        # Only consider registered providers
        active = [p for p in configured_order if p in self._providers and len(self._keys.get(p, [])) > 0]
        for p in self._providers:
            if p not in active and len(self._keys.get(p, [])) > 0:
                active.append(p)
        if preferred and preferred.lower() in self._providers and len(self._keys.get(preferred.lower(), [])) > 0:
            pref = preferred.lower()
            return [pref] + [p for p in active if p != pref]

        return active

    async def get_next_key(self, provider_name: str) -> Optional[Tuple[str, int]]:
        name = provider_name.lower()
        async with self._lock:
            keys = self._keys.get(name, [])
            if not keys:
                return None

            now = time.time()
            # Cooldown recovery check
            for k in keys:
                if k.exhausted and k.exhausted_at:
                    if (now - k.exhausted_at) >= k.cooldown_seconds:
                        k.exhausted = False
                        k.exhausted_at = None
                        logger.info("Provider %s key #%d cooldown elapsed; re-enabled", name.upper(), k.index + 1)

            min_key_interval = 60.0 if name == "groq" else 0.0
            start_idx = self._current_indices.get(name, 0)
            attempts = 0
            while attempts < len(keys):
                idx = (start_idx + attempts) % len(keys)
                k_info = keys[idx]
                if not k_info.exhausted and (now - k_info.last_dispatched_at >= min_key_interval):
                    self._current_indices[name] = (idx + 1) % len(keys)
                    k_info.last_dispatched_at = now
                    return k_info.key, idx
                attempts += 1

            if min_key_interval > 0:
                # Find available non-exhausted keys
                avail_keys = [k for k in keys if not k.exhausted]
                if avail_keys:
                    # Select the key that was dispatched furthest in the past
                    oldest_k = min(avail_keys, key=lambda k: k.last_dispatched_at)
                    wait_time = max(0.0, min_key_interval - (now - oldest_k.last_dispatched_at))
                    if wait_time > 0 and wait_time <= 900.0:
                        logger.info("Pacing %s: waiting %.2fs for next key TPM window", name.upper(), wait_time + 1.0)
                        await asyncio.sleep(wait_time + 1.0)
                    now = time.time()
                    oldest_k.last_dispatched_at = now
                    self._current_indices[name] = (oldest_k.index + 1) % len(keys)
                    return oldest_k.key, oldest_k.index

            return None

    async def mark_key_exhausted(
        self,
        provider_name: str,
        key_index: int,
        cooldown_seconds: float = 65.0,
        reason: str = "",
    ) -> None:
        name = provider_name.lower()
        async with self._lock:
            keys = self._keys.get(name, [])
            if 0 <= key_index < len(keys):
                keys[key_index].exhausted = True
                keys[key_index].exhausted_at = time.time()
                keys[key_index].cooldown_seconds = cooldown_seconds
                logger.warning(
                    "Provider %s key #%d marked EXHAUSTED (cooldown %.1fs): %s",
                    name.upper(),
                    key_index + 1,
                    cooldown_seconds,
                    redact_secrets(reason),
                )

    def get_semaphore(self, provider_name: str) -> asyncio.Semaphore:
        name = provider_name.lower()
        if name not in self._semaphores:
            self._semaphores[name] = asyncio.Semaphore(5)
        return self._semaphores[name]

    def get_rate_limiter(self, provider_name: str) -> TokenBucket:
        name = provider_name.lower()
        if name not in self._rate_limiters:
            self._rate_limiters[name] = TokenBucket()
        return self._rate_limiters[name]

    def get_status(self) -> Dict[str, Any]:
        result = {}
        for name, provider in self._providers.items():
            keys = self._keys.get(name, [])
            result[name] = {
                "base_url": provider.base_url,
                "total_keys": len(keys),
                "available_keys": sum(1 for k in keys if not k.exhausted),
                "exhausted_keys": sum(1 for k in keys if k.exhausted),
            }
        return result

    def initialize_from_settings(self) -> None:
        if self._initialized:
            return

        # MiniMax registration
        minimax_keys_str = (
            os.environ.get("MINIMAX_API_KEYS")
            or settings.minimax_api_keys
            or os.environ.get("MINIMAX_API_KEY")
            or settings.minimax_api_key
            or ""
        )
        minimax_keys = [k.strip() for k in minimax_keys_str.split(",") if k.strip()]
        minimax_provider = MiniMaxProvider(
            base_url=settings.minimax_base_url or "https://api.minimaxi.chat/v1",
            models={"large": settings.minimax_model, "medium": settings.minimax_model, "small": settings.minimax_model},
        )
        self.register_provider(minimax_provider, keys=minimax_keys, max_concurrency=4, rate_per_second=5.0)

        # Groq registration
        groq_keys_str = (
            os.environ.get("GROQ_API_KEYS")
            or settings.groq_api_keys
            or os.environ.get("GROQ_API_KEY")
            or settings.groq_api_key
            or ""
        )
        groq_keys = [k.strip() for k in groq_keys_str.split(",") if k.strip()]
        groq_provider = GroqProvider(
            base_url=settings.groq_base_url or "https://api.groq.com/openai/v1",
            models={
                "xlarge": "openai/gpt-oss-120b",
                "large": settings.groq_model,
                "medium": "qwen-2.5-32b",
                "small": "openai/gpt-oss-20b",
            },
        )
        groq_rate = 1.0 / 15.0
        self.register_provider(groq_provider, keys=groq_keys, max_concurrency=1, rate_per_second=groq_rate)
        if "groq" in self._rate_limiters:
            self._rate_limiters["groq"].capacity = 1.0
            self._rate_limiters["groq"].tokens = 1.0

        self._initialized = True
        logger.info("ProviderRegistry initialized: %s", self.get_status())


provider_registry = ProviderRegistry()
provider_registry.initialize_from_settings()
