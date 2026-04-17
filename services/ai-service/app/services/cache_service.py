import hashlib
import json
import logging

import redis

from app.config import settings

logger = logging.getLogger(__name__)

_redis_client: redis.Redis | None = None


def _get_redis() -> redis.Redis | None:
    global _redis_client
    if _redis_client is None:
        try:
            _redis_client = redis.Redis(
                host=settings.redis_host,
                port=settings.redis_port,
                decode_responses=True,
                socket_connect_timeout=2,
            )
            _redis_client.ping()
        except Exception as e:
            logger.warning("Redis unavailable, caching disabled: %s", e)
            _redis_client = None
    return _redis_client


def _cache_key(prefix: str, query_vector: list[float], top_k: int, filters: dict) -> str:
    raw = json.dumps({"q": query_vector[:32], "k": top_k, "f": filters}, sort_keys=True)
    digest = hashlib.sha256(raw.encode()).hexdigest()[:16]
    return f"{prefix}:{digest}"


def get_cached(prefix: str, query_vector: list[float], top_k: int, filters: dict) -> str | None:
    client = _get_redis()
    if not client:
        return None
    key = _cache_key(prefix, query_vector, top_k, filters)
    try:
        return client.get(key)
    except Exception:
        return None


def set_cached(
    prefix: str,
    query_vector: list[float],
    top_k: int,
    filters: dict,
    data: str,
    ttl_seconds: int = 3600,
) -> None:
    client = _get_redis()
    if not client:
        return
    key = _cache_key(prefix, query_vector, top_k, filters)
    try:
        client.setex(key, ttl_seconds, data)
    except Exception as e:
        logger.warning("Failed to cache: %s", e)
