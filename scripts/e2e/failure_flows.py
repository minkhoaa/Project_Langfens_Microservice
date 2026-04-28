"""Manual failure-mode driver. Operator stops a service externally,
then runs this to assert graceful behavior.

Usage:
    docker stop ai-service
    python -m scripts.e2e.failure_flows ai-down
    docker start ai-service

    docker stop ollama   # or kill -9 the host ollama process
    python -m scripts.e2e.failure_flows ollama-down
"""
from __future__ import annotations

import argparse
import asyncio
import sys
from pathlib import Path

import httpx

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "services" / "ai-service" / "tests" / "e2e"))
from fixtures.essays import WC_B_BAND6  # noqa: E402

from scripts.e2e.lib.auth import login  # noqa: E402
from scripts.e2e.lib.writing_client import (  # noqa: E402
    list_exams, poll_comparison, submit_grade,
)
from scripts.e2e.seed_user import EMAIL, PASSWORD  # noqa: E402


async def ai_down(gateway: str) -> int:
    """Submit while ai-service is stopped. Grading must still succeed
    and comparison endpoint must return 204 / null."""
    async with httpx.AsyncClient(timeout=60.0) as client:
        auth = await login(client, gateway, EMAIL, PASSWORD)
        exams = await list_exams(client, gateway, auth)
        exam_id = exams[0].get("id") or exams[0].get("examId")
        grade = await submit_grade(client, gateway, auth, exam_id, WC_B_BAND6.text)
        sub_id = grade.get("submissionId") or grade.get("id")
        if not sub_id:
            print(f"[ai-down] no submission id: {list(grade)}", file=sys.stderr)
            return 1
        print(f"[ai-down] grading completed, submission_id={sub_id}")

        # Comparison must NOT appear (poll for 30s — circuit breaker fast-fails)
        comp = await poll_comparison(client, gateway, auth, sub_id, timeout=30.0)
        if comp is not None:
            print(
                f"[ai-down] FAIL — comparison appeared despite ai-service down: {comp}",
                file=sys.stderr,
            )
            return 2
        print("[ai-down] OK — comparison absent as expected")
        return 0


async def ollama_down(gateway: str) -> int:
    """Submit while Ollama is stopped (ai-service up). Embedding fails fast,
    AI service returns 5xx, writing-service consumer logs error, comparison
    never persists. Observable behavior identical to ai-down from the FE side."""
    return await ai_down(gateway)


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("scenario", choices=["ai-down", "ollama-down"])
    p.add_argument("--gateway", default="http://localhost:5000")
    args = p.parse_args()
    fn = ai_down if args.scenario == "ai-down" else ollama_down
    sys.exit(asyncio.run(fn(args.gateway)))


if __name__ == "__main__":
    main()
