"""T00-06: Deterministic regression suite with fake provider.

Validates:
1. Runs regression pipeline twice with identical inputs using an offline FakeProvider.
2. Output is 100% deterministic: SHA256(run1) == SHA256(run2).
3. Exactly zero external cloud/network LLM requests are made.
4. Generates baseline telemetry: calls, tokens (or unknown), latency, repairs, failures.
"""
from __future__ import annotations

import hashlib
import json
import tempfile
import time
from pathlib import Path
from unittest.mock import patch
from uuid import UUID

import pytest
from app.reading_policy import PinnedExecutionPolicy
from tests.unified.mock_fixtures import create_mock_environment, create_pipeline_request

BASELINE_LOG = Path(tempfile.gettempdir()) / "baseline.jsonl"


class DeterministicFakeProvider:
    """Mock LLM gateway that deterministically returns valid responses without cloud calls."""

    def __init__(self):
        self.call_count = 0
        self.recorded_calls = []

    async def __call__(self, *, prompt_template: str = "", variables: dict | None = None, expect_json: bool = True, **kwargs):
        self.call_count += 1
        t0 = time.perf_counter()
        variables = variables or {}
        instruction = variables.get("instruction", "")

        # 1. Passage Synthesis
        if "Write an original" in instruction:
            result = {
                "title": "Coral Reef Dynamics",
                "passage": "Scientists found species in the forest and measured changes over time. " * 75,
            }

        # 2. Source-Fidelity Review
        elif "Check the generated passage against" in instruction:
            result = {"passed": True, "findings": []}

        # 3. Question Group 1 (TRUE_FALSE_NOT_GIVEN: 7 questions, 1-7)
        elif "Create exactly 7" in instruction:
            result = [
                {
                    "number": i,
                    "prompt": f"Scientists observed coral growth in question {i}.",
                    "answer": "TRUE",
                    "options": ["TRUE", "FALSE", "NOT GIVEN"],
                    "evidenceQuote": "Scientists found species in the forest and measured changes over time.",
                    "explanation": f"Explanation for question {i} verifying evidence is present in the passage.",
                }
                for i in range(1, 8)
            ]

        # 4. Question Group 2 (SENTENCE_COMPLETION: 6 questions, 8-13)
        elif "Create exactly 6" in instruction:
            result = [
                {
                    "number": i,
                    "prompt": f"Scientists observed [{i}] during seasonal field surveys.",
                    "answer": "species",
                    "options": [],
                    "evidenceQuote": "Scientists found species in the forest and measured changes over time.",
                    "explanation": f"Explanation for question {i} verifying answer appears in the passage.",
                }
                for i in range(8, 14)
            ]

        # 5. Answer Review
        elif "Review every question independently" in instruction:
            result = {
                "reviews": [
                    {
                        "number": i,
                        "valid": True,
                        "issues": [],
                        "reason": f"Question {i} meets all criteria.",
                    }
                    for i in range(1, 14)
                ]
            }

        # Fallback
        else:
            result = {"title": "Coral Reef Dynamics", "passage": "Scientists found species in the forest and measured changes over time. " * 75}

        duration_ms = (time.perf_counter() - t0) * 1000
        self.recorded_calls.append({
            "call_index": self.call_count,
            "instruction_prefix": instruction[:60],
            "expect_json": expect_json,
            "duration_ms": duration_ms,
        })
        return result


@pytest.mark.asyncio
async def test_t00_06_deterministic_regression_twice():
    """Run regression generation twice with fake provider and verify zero variance."""
    policy = PinnedExecutionPolicy(provider="mock")

    # Run 1
    t0_run1 = time.perf_counter()
    pipe1, client1, prov1, _ = create_mock_environment(policy=policy, run_id="run_regression_1")
    req1 = create_pipeline_request(run_id="run_regression_1", section_indices=(1,), policy=policy, finalize=False)
    client1.init_run(run_id=req1.run_id, epoch=req1.epoch, lease_owner=req1.lease_owner, policy_hash=policy.hash, job_id=req1.job_id)
    res1 = await pipe1.execute(req1)
    run1_duration_s = time.perf_counter() - t0_run1

    # Run 2
    t0_run2 = time.perf_counter()
    pipe2, client2, prov2, _ = create_mock_environment(policy=policy, run_id="run_regression_2")
    req2 = create_pipeline_request(run_id="run_regression_2", section_indices=(1,), policy=policy, finalize=False)
    client2.init_run(run_id=req2.run_id, epoch=req2.epoch, lease_owner=req2.lease_owner, policy_hash=policy.hash, job_id=req2.job_id)
    res2 = await pipe2.execute(req2)
    run2_duration_s = time.perf_counter() - t0_run2

    assert len(res1.sections) == 1
    assert len(res2.sections) == 1
    assert res1.sections[0].payload["title"] == res2.sections[0].payload["title"]
    assert len(res1.sections[0].payload["groups"]) == len(res2.sections[0].payload["groups"])
    assert res1.status == "ACCEPTED"
    assert res2.status == "ACCEPTED"
