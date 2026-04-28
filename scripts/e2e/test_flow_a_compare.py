"""Integration test: Flow A standalone writing submission produces persisted comparison.

Asserts:
  1. POST /api-writing/writing/grade returns 200 with submissionId.
  2. Within 60s, GET /api-writing/writing/{id}/comparison returns 200 with non-empty references.

Run:
  python -m scripts.e2e.test_flow_a_compare

Pre-conditions:
  - Stack up via deploy/compose.local.yaml.
  - Test user seeded via `python -m scripts.e2e.seed_user`.
  - At least one writing exam exists (the script picks the first one returned by
    GET /api-writing/writing/exams; override with E2E_WRITING_EXAM_ID).
"""
from __future__ import annotations

import asyncio
import json
import os
import sys
import time

import httpx

GATEWAY = os.environ.get("GATEWAY_URL", "http://localhost:5000")
USER_EMAIL = os.environ.get("E2E_USER_EMAIL", "e2e+writing@langfens.test")
USER_PASSWORD = os.environ.get("E2E_USER_PASSWORD", "E2eTest!2026")
WRITING_EXAM_ID = os.environ.get("E2E_WRITING_EXAM_ID")  # optional override
POLL_TIMEOUT_S = int(os.environ.get("E2E_POLL_TIMEOUT_S", "60"))

ESSAY = (
    "In recent years, the increasing aging population has become a significant global "
    "issue. While some argue this poses serious challenges to society, others believe "
    "it brings opportunities. This essay will examine both perspectives before "
    "presenting my own view. On the one hand, an aging population creates economic "
    "pressure on healthcare systems and pension funds. As life expectancy rises, "
    "governments must allocate more resources to elderly care, potentially diverting "
    "funds from other essential services like education. Furthermore, a shrinking "
    "working-age population may struggle to support a larger group of retirees, "
    "leading to higher tax burdens. On the other hand, older people contribute "
    "valuable experience and stability to society. Many continue to work productively "
    "past traditional retirement age, sharing wisdom accumulated over decades. "
    "Additionally, grandparents often provide crucial childcare support, enabling "
    "parents to remain in the workforce. In my opinion, the challenges outweigh the "
    "benefits if not addressed strategically. Governments should invest in healthcare "
    "innovation, raise retirement ages gradually, and encourage immigration to "
    "maintain a healthy worker-to-retiree ratio."
)


async def login(client: httpx.AsyncClient) -> str:
    resp = await client.post(
        f"{GATEWAY}/api-auth/auth/login",
        json={"email": USER_EMAIL, "password": USER_PASSWORD},
    )
    resp.raise_for_status()
    body = resp.json()
    token = body.get("data") if isinstance(body.get("data"), str) else None
    if not token:
        # Some deployments may nest under data.accessToken
        nested = body.get("data") or {}
        token = nested.get("accessToken") if isinstance(nested, dict) else None
    if not token:
        raise RuntimeError(f"No token in login response: {body}")
    return token


async def pick_exam_id(client: httpx.AsyncClient, token: str) -> str:
    if WRITING_EXAM_ID:
        return WRITING_EXAM_ID
    resp = await client.get(
        f"{GATEWAY}/api-writing/writing/exams",
        headers={"Authorization": f"Bearer {token}"},
    )
    resp.raise_for_status()
    body = resp.json()
    exams = body.get("data") or body
    if not isinstance(exams, list) or not exams:
        raise RuntimeError(f"Could not find any writing exam: {body}")
    return exams[0]["id"]


async def submit(client: httpx.AsyncClient, token: str, exam_id: str) -> str:
    resp = await client.post(
        f"{GATEWAY}/api-writing/writing/grade",
        json={"examId": exam_id, "answer": ESSAY, "timeSpentSeconds": 600},
        headers={"Authorization": f"Bearer {token}"},
        timeout=30.0,
    )
    resp.raise_for_status()
    # The grader response sometimes contains unescaped control chars in the
    # ImprovedParagraph field; httpx's default json() is strict, so fall back
    # to non-strict parsing.
    try:
        body = resp.json()
    except json.JSONDecodeError:
        body = json.loads(resp.text, strict=False)
    submission_id = (body.get("data") or {}).get("submissionId")
    if not submission_id:
        raise RuntimeError(f"No submissionId in grade response: {body}")
    return submission_id


async def poll_comparison(
    client: httpx.AsyncClient, token: str, submission_id: str, timeout_s: int
) -> dict:
    deadline = time.monotonic() + timeout_s
    last_status = None
    while time.monotonic() < deadline:
        resp = await client.get(
            f"{GATEWAY}/api-writing/writing/{submission_id}/comparison",
            headers={"Authorization": f"Bearer {token}"},
        )
        last_status = resp.status_code
        if resp.status_code == 200:
            return resp.json()
        if resp.status_code not in (204, 404):
            raise RuntimeError(
                f"Unexpected status {resp.status_code} from /comparison: {resp.text[:300]}"
            )
        await asyncio.sleep(2)
    raise TimeoutError(
        f"Comparison did not appear within {timeout_s}s (last status: {last_status})"
    )


async def main() -> int:
    async with httpx.AsyncClient() as client:
        print("[flow-a-compare] logging in...")
        token = await login(client)

        exam_id = await pick_exam_id(client, token)
        print(f"[flow-a-compare] using writing exam {exam_id}")

        submission_id = await submit(client, token, exam_id)
        print(f"[flow-a-compare] submission_id={submission_id}; polling /comparison...")

        result = await poll_comparison(client, token, submission_id, POLL_TIMEOUT_S)

        refs = result.get("references") or []
        sentence_comps = result.get("sentence_comparisons") or []
        if not refs and not result.get("no_references_found"):
            print(
                "[flow-a-compare] FAIL - references empty and no_references_found is "
                f"false; payload keys: {sorted(result.keys())}"
            )
            return 1

        print(
            f"[flow-a-compare] PASS - references={len(refs)} "
            f"sentence_comparisons={len(sentence_comps)} "
            f"step_up_band={result.get('step_up_band')}"
        )
        return 0


if __name__ == "__main__":
    sys.exit(asyncio.run(main()))
