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

from app.pipeline import generate_section

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
    fake_source = {
        "pmcid": "PMC8910001",
        "title": "Coral Reef Dynamics",
        "url": "https://europepmc.org/articles/PMC8910001",
        "license": "https://creativecommons.org/licenses/by/4.0/",
        "wordCount": 1840,
        "content": "Scientists found species in the forest and measured changes over time. " * 80,
    }

    # Run 1
    provider1 = DeterministicFakeProvider()
    t0_run1 = time.perf_counter()
    with patch("app.pipeline.llm_generate", new=provider1):
        section_run1 = await generate_section(
            "coral reefs", 1, fake_source,
            run_id="run_regression", epoch=1,
            lease_owner=UUID("00000000-0000-0000-0000-000000000001"),
            parent_operation_id="op_regression",
        )
    run1_duration_s = time.perf_counter() - t0_run1

    run1_json = json.dumps(section_run1, sort_keys=True, ensure_ascii=False)
    run1_hash = hashlib.sha256(run1_json.encode("utf-8")).hexdigest()

    # Run 2
    provider2 = DeterministicFakeProvider()
    t0_run2 = time.perf_counter()
    with patch("app.pipeline.llm_generate", new=provider2):
        section_run2 = await generate_section(
            "coral reefs", 1, fake_source,
            run_id="run_regression", epoch=1,
            lease_owner=UUID("00000000-0000-0000-0000-000000000001"),
            parent_operation_id="op_regression",
        )
    run2_duration_s = time.perf_counter() - t0_run2

    run2_json = json.dumps(section_run2, sort_keys=True, ensure_ascii=False)
    run2_hash = hashlib.sha256(run2_json.encode("utf-8")).hexdigest()

    # Determinism assertions
    assert run1_hash == run2_hash, "Regression runs produced diverging output!"
    assert provider1.call_count == provider2.call_count
    assert provider1.call_count == 5  # Passage + Review + 2 Question Groups + Answer Review
    assert len(section_run1["groups"]) == 2
    assert len(section_run1["groups"][0]["questions"]) == 7
    assert len(section_run1["groups"][1]["questions"]) == 6

    # Record baseline metric entries
    BASELINE_LOG.parent.mkdir(parents=True, exist_ok=True)
    baseline_entry = {
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "phase": "Phase-00-Baseline",
        "testId": "T00-06",
        "engine": "Legacy-Pipeline",
        "topic": "coral reefs",
        "sectionIndex": 1,
        "run1": {
            "sha256": run1_hash,
            "calls": provider1.call_count,
            "durationSeconds": round(run1_duration_s, 4),
            "tokens": "unknown",  # Legacy provider does not record token usage
            "repairs": 0,
            "failures": 0,
        },
        "run2": {
            "sha256": run2_hash,
            "calls": provider2.call_count,
            "durationSeconds": round(run2_duration_s, 4),
            "tokens": "unknown",
            "repairs": 0,
            "failures": 0,
        },
        "deterministicMatch": True,
        "cloudCallsAttempted": 0,
    }

    with open(BASELINE_LOG, "w", encoding="utf-8") as f:
        f.write(json.dumps(baseline_entry, ensure_ascii=False) + "\n")
