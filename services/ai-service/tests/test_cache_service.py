from unittest.mock import MagicMock, patch
from app.services.cache_service import _cache_key, get_cached, set_cached


def test_cache_key_deterministic():
    vec = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8]
    k1 = _cache_key("test", vec, 5, {"task_type": "TASK_2"})
    k2 = _cache_key("test", vec, 5, {"task_type": "TASK_2"})
    assert k1 == k2


def test_cache_key_varies_with_filters():
    vec = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8]
    k1 = _cache_key("test", vec, 5, {"task_type": "TASK_1"})
    k2 = _cache_key("test", vec, 5, {"task_type": "TASK_2"})
    assert k1 != k2


def test_get_cached_returns_none_when_redis_unavailable():
    with patch("app.services.cache_service._get_redis", return_value=None):
        result = get_cached("test", [0.1] * 8, 5, {})
    assert result is None


def test_set_cached_noop_when_redis_unavailable():
    with patch("app.services.cache_service._get_redis", return_value=None):
        set_cached("test", [0.1] * 8, 5, {}, '{"data": true}')
