"""End-to-end backend flow:
   login → list exams → start → submit → poll comparison → validate.

Usage:
    python -m scripts.e2e.full_writing_flow [--gateway http://localhost:5000]

Exit codes:
    0 success
    1 stack-not-ready / login failed
    2 grading endpoint failed
    3 comparison never produced within timeout
    4 comparison schema invalid
"""
from __future__ import annotations

import argparse
import asyncio
import json
import sys
from pathlib import Path

import httpx

# Make ai-service schemas importable for round-trip validation.
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "services" / "ai-service"))
from app.schemas import CompareResponse  # noqa: E402

from scripts.e2e.lib.auth import login  # noqa: E402
from scripts.e2e.lib.writing_client import (  # noqa: E402
    list_exams,
    poll_comparison,
    start_exam,
    submit_grade,
)
from scripts.e2e.seed_user import EMAIL, PASSWORD  # noqa: E402

# Re-use the band-6 fixture from Layer 1 so behavior is consistent.
sys.path.insert(0, str(ROOT / "services" / "ai-service" / "tests" / "e2e"))
from fixtures.essays import WC_B_BAND6  # noqa: E402


async def run(gateway: str) -> int:
    async with httpx.AsyncClient(timeout=120.0) as client:
        # 1. Login
        try:
            auth = await login(client, gateway, EMAIL, PASSWORD)
        except Exception as exc:
            print(f"[e2e] login failed: {exc}", file=sys.stderr)
            return 1
        print(f"[e2e] logged in as {EMAIL}")

        # 2. List exams + pick one
        exams = await list_exams(client, gateway, auth)
        if not exams:
            print("[e2e] no exams available — seed exams first", file=sys.stderr)
            return 1
        exam_id = exams[0].get("id") or exams[0].get("examId")
        print(f"[e2e] picked exam_id={exam_id}")

        # 3. Start exam (best-effort — some flows accept submit without start)
        try:
            started = await start_exam(client, gateway, auth, exam_id)
            print(f"[e2e] started, submission_id={started.submission_id}")
        except Exception as exc:
            print(
                f"[e2e] start_exam soft-failed ({exc}); falling back to direct submit",
                file=sys.stderr,
            )

        # 4. Submit essay for grading
        try:
            grade_resp = await submit_grade(
                client, gateway, auth, exam_id, WC_B_BAND6.text, time_spent=1800,
            )
        except httpx.HTTPStatusError as exc:
            print(
                f"[e2e] submit failed: {exc.response.status_code} {exc.response.text[:300]}",
                file=sys.stderr,
            )
            return 2
        # Unwrap Langfens API envelope
        payload = grade_resp.get("data") if isinstance(grade_resp.get("data"), dict) else grade_resp
        submission_id = (
            payload.get("submissionId")
            or payload.get("submission_id")
            or payload.get("id")
        )
        if not submission_id:
            print(
                f"[e2e] grade response missing submissionId: keys={list(grade_resp)} data_keys={list(payload) if isinstance(payload, dict) else None}",
                file=sys.stderr,
            )
            return 2
        print(
            f"[e2e] submitted, submission_id={submission_id}, "
            f"band={payload.get('overallBand') or payload.get('band')}"
        )

        # 5. Poll for comparison
        comparison = await poll_comparison(
            client, gateway, auth, submission_id, timeout=90.0,
        )
        if comparison is None:
            print("[e2e] comparison never appeared within 90s", file=sys.stderr)
            return 3

        # 6. Validate against schema
        try:
            parsed = CompareResponse.model_validate(comparison)
        except Exception as exc:
            print(f"[e2e] comparison schema invalid: {exc}", file=sys.stderr)
            print(json.dumps(comparison, indent=2)[:1000], file=sys.stderr)
            return 4

        print(
            f"[e2e] OK — references={len(parsed.references)} "
            f"sentence_comparisons={len(parsed.sentence_comparisons)} "
            f"step_up_band={parsed.step_up_band}"
        )
        return 0


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("--gateway", default="http://localhost:5000")
    args = p.parse_args()
    sys.exit(asyncio.run(run(args.gateway)))


if __name__ == "__main__":
    main()
