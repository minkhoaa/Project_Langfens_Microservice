"""Pytest wrapper around full_writing_flow — asserts exit code 0."""
from __future__ import annotations

import asyncio
import os
import socket

import pytest

from scripts.e2e.full_writing_flow import run

GATEWAY = os.getenv("GATEWAY_URL", "http://localhost:5000")


def _gateway_up() -> bool:
    try:
        with socket.create_connection(("localhost", 5000), timeout=1.5):
            return True
    except OSError:
        return False


@pytest.mark.skipif(not _gateway_up(), reason="gateway :5000 not reachable")
def test_full_writing_flow_succeeds():
    rc = asyncio.run(run(GATEWAY))
    assert rc == 0, f"full_writing_flow returned exit code {rc}"
