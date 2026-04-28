"""Writing-service flow helper: list exams, start, submit, poll comparison."""
from __future__ import annotations

import asyncio
from dataclasses import dataclass
from typing import Any

import httpx

from scripts.e2e.lib.auth import AuthSession


@dataclass
class StartedExam:
    submission_id: str
    exam_id: str
    raw: dict[str, Any]


async def list_exams(
    client: httpx.AsyncClient, gateway: str, auth: AuthSession,
) -> list[dict]:
    resp = await client.get(
        f"{gateway.rstrip('/')}/api-writing/writing/exams",
        headers=auth.auth_headers(),
    )
    resp.raise_for_status()
    body = resp.json()
    # Langfens API envelope: {"isSuccess": ..., "data": [...]}
    if isinstance(body, dict) and isinstance(body.get("data"), list):
        return body["data"]
    if isinstance(body, dict) and isinstance(body.get("exams"), list):
        return body["exams"]
    return body if isinstance(body, list) else []


async def start_exam(
    client: httpx.AsyncClient, gateway: str, auth: AuthSession, exam_id: str,
) -> StartedExam:
    resp = await client.post(
        f"{gateway.rstrip('/')}/api-writing/writing/start/{exam_id}",
        headers=auth.auth_headers(),
    )
    resp.raise_for_status()
    body = resp.json()
    # Unwrap Langfens API envelope
    payload = body.get("data") if isinstance(body, dict) and "data" in body else body
    if not isinstance(payload, dict):
        payload = body
    submission_id = (
        payload.get("submissionId")
        or payload.get("submission_id")
        or payload.get("id")
    )
    if not submission_id:
        raise RuntimeError(f"start exam: no submissionId in response keys={list(body)}")
    return StartedExam(submission_id=submission_id, exam_id=exam_id, raw=body)


async def submit_grade(
    client: httpx.AsyncClient, gateway: str, auth: AuthSession,
    exam_id: str, answer: str, time_spent: int = 1800,
) -> dict[str, Any]:
    payload = {"examId": exam_id, "answer": answer, "timeSpentSeconds": time_spent}
    resp = await client.post(
        f"{gateway.rstrip('/')}/api-writing/writing/grade",
        json=payload,
        headers=auth.auth_headers(),
    )
    resp.raise_for_status()
    return resp.json()


async def poll_comparison(
    client: httpx.AsyncClient, gateway: str, auth: AuthSession,
    submission_id: str, timeout: float = 90.0, interval: float = 2.0,
) -> dict[str, Any] | None:
    """Returns the comparison dict, or None if endpoint never produces one."""
    url = f"{gateway.rstrip('/')}/api-writing/writing/{submission_id}/comparison"
    deadline = asyncio.get_event_loop().time() + timeout
    while asyncio.get_event_loop().time() < deadline:
        resp = await client.get(url, headers=auth.auth_headers())
        if resp.status_code == 200 and resp.content:
            return resp.json()
        if resp.status_code in (204, 404):
            await asyncio.sleep(interval)
            continue
        if resp.status_code >= 500:
            raise RuntimeError(
                f"comparison endpoint 5xx: {resp.status_code} {resp.text[:200]}"
            )
        await asyncio.sleep(interval)
    return None
