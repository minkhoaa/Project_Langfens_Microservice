import json
import logging
from datetime import datetime, timezone
from uuid import uuid4

from cachetools import TTLCache

from app.schemas import RoleplayScenario
from app.config import settings

logger = logging.getLogger(__name__)

SESSION_TTL_SECONDS = 60 * 60 * 2
_REDIS_KEY_PREFIX = "roleplay:session:"

try:
    import redis
except Exception:
    redis = None


_redis_client = None
_redis_disabled = False
_memory_sessions = TTLCache(maxsize=10000, ttl=SESSION_TTL_SECONDS)


def _utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def _session_key(session_id: str) -> str:
    return f"{_REDIS_KEY_PREFIX}{session_id}"


def _connect_redis():
    global _redis_client
    global _redis_disabled

    if _redis_disabled:
        return None
    if redis is None:
        _redis_disabled = True
        logger.warning("redis package not available, using in-memory session store")
        return None
    if _redis_client is not None:
        return _redis_client

    try:
        _redis_client = redis.Redis(
            host=settings.redis_host,
            port=settings.redis_port,
            decode_responses=True,
            socket_timeout=1,
            socket_connect_timeout=1,
        )
        _redis_client.ping()
        return _redis_client
    except Exception as exc:
        logger.warning("Cannot connect to Redis at %s:%s, using in-memory session store: %s", settings.redis_host, settings.redis_port, exc)
        _redis_disabled = True
        _redis_client = None
        return None


def _persist_session(session: dict) -> None:
    redis_client = _connect_redis()
    if redis_client is not None:
        redis_client.setex(_session_key(session["session_id"]), SESSION_TTL_SECONDS, json.dumps(session))
        return

    _memory_sessions[session["session_id"]] = session


def create_session(user_id: str, scenario: RoleplayScenario) -> dict:
    session_id = str(uuid4())
    started_at = _utc_now_iso()
    opening_turn = {
        "speaker": "agent",
        "text": scenario.opening_prompt,
        "turn_index": 1,
        "timestamp": started_at,
    }

    session = {
        "session_id": session_id,
        "user_id": user_id,
        "scenario_slug": scenario.slug,
        "started_at": started_at,
        "updated_at": started_at,
        "turns": [opening_turn],
    }
    _persist_session(session)
    return session


def get_session(session_id: str) -> dict | None:
    redis_client = _connect_redis()
    if redis_client is not None:
        payload = redis_client.get(_session_key(session_id))
        if payload is None:
            return None
        redis_client.expire(_session_key(session_id), SESSION_TTL_SECONDS)
        return json.loads(payload)

    return _memory_sessions.get(session_id)


def append_turn(session_id: str, speaker: str, text: str) -> tuple[dict | None, dict | None]:
    session = get_session(session_id)
    if session is None:
        return None, None

    turn = {
        "speaker": speaker,
        "text": text,
        "turn_index": len(session["turns"]) + 1,
        "timestamp": _utc_now_iso(),
    }
    session["turns"].append(turn)
    session["updated_at"] = turn["timestamp"]
    _persist_session(session)
    return session, turn
