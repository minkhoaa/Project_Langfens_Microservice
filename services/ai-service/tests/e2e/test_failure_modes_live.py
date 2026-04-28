"""Live failure-mode probes — health + input validation."""
from __future__ import annotations

import pytest


@pytest.mark.live
@pytest.mark.asyncio
async def test_health_reports_ok_when_stack_healthy(http_client):
    resp = await http_client.get("/api/healthz")
    assert resp.status_code == 200
    body = resp.json()
    assert body.get("status") in ("ok", "healthy")


@pytest.mark.live
@pytest.mark.asyncio
async def test_compare_with_oversize_essay_rejected(http_client):
    """essay_text > 3000 chars must 422."""
    payload = {
        "essay_text": "x" * 3500,
        "topic": "Some valid IELTS topic",
        "task_type": "TASK_2",
        "student_band": 6.0,
    }
    resp = await http_client.post("/api/v1/writing/compare", json=payload)
    assert resp.status_code == 422


@pytest.mark.live
@pytest.mark.asyncio
async def test_compare_with_short_topic_rejected(http_client):
    payload = {
        "essay_text": "x" * 100,
        "topic": "shrt",
        "task_type": "TASK_2",
        "student_band": 6.0,
    }
    resp = await http_client.post("/api/v1/writing/compare", json=payload)
    assert resp.status_code == 422
