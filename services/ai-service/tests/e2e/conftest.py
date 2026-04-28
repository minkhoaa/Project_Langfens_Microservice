"""E2E test fixtures: live HTTP client + skip guard for missing services."""
from __future__ import annotations

import os
import socket
from urllib.parse import urlparse

import httpx
import pytest


AI_SERVICE_URL = os.getenv("AI_SERVICE_URL", "http://localhost:8092")
OLLAMA_URL = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")


def _can_connect(url: str, timeout: float = 1.5) -> bool:
    """Cheap reachability check — opens a TCP socket to host:port."""
    try:
        parsed = urlparse(url)
        host = parsed.hostname or "localhost"
        port = parsed.port or (443 if parsed.scheme == "https" else 80)
        with socket.create_connection((host, port), timeout=timeout):
            return True
    except OSError:
        return False


def pytest_addoption(parser):
    parser.addoption(
        "--run-live",
        action="store_true",
        default=False,
        help="Force-run @pytest.mark.live tests even if reachability check fails",
    )


def pytest_collection_modifyitems(config, items):
    """Skip @pytest.mark.live when --run-live not passed AND stack unreachable."""
    if config.getoption("--run-live", default=False):
        return
    skip_live = pytest.mark.skip(
        reason="live tests require --run-live or healthy stack (ai-service + Ollama)"
    )
    for item in items:
        if "live" in item.keywords:
            if not (_can_connect(AI_SERVICE_URL) and _can_connect(OLLAMA_URL)):
                item.add_marker(skip_live)


@pytest.fixture
async def http_client():
    async with httpx.AsyncClient(base_url=AI_SERVICE_URL, timeout=120.0) as c:
        yield c
