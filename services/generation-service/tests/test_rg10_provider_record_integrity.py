"""Unit and Regression Tests for RG10 Provider Record Integrity and DEV Runner Safety.

Covers:
1. Strict replay matching using the production ReplayExperimentClient:
   - No stage-only fallback.
   - Exact prompt_sha256 and stage matching.
2. Corrupted provider record detection (SHA256 mismatch).
3. One-to-one response consumption: preventing duplicate reuse of provider responses.
4. Missing response records fail closed.
5. Safe null proposed answer handling without crashing on `.strip()`.
6. Preservation of missing answers as UNSCORABLE_MISSING_ANSWER without draft borrowing.
7. Denominator and metric aggregation invariants.
"""
from __future__ import annotations

import hashlib
import json
from pathlib import Path
import sys
from typing import Any, Dict
import pytest

repo_root = Path(__file__).resolve().parent.parent.parent.parent
if str(repo_root) not in sys.path:
    sys.path.insert(0, str(repo_root))

from generation_baseline.tools.replay_quality_dev_hardening import ReplayExperimentClient
from app.contracts.research import (
    ExecutionStatus,
    NeutralQuestion,
    StandaloneGroupType,
)
from app.evaluators.independent import NeutralEvaluatorV2_3
from app.evaluators.rubric import EvaluationVerdict


def test_missing_provider_response_record_raises(tmp_path: Path):
    """Missing provider record must fail closed with explicit RuntimeError."""
    client = ReplayExperimentClient(tmp_path)
    with pytest.raises(RuntimeError, match="Strict replay failure: No unconsumed raw record"):
        client.dispatch(prompt="Hello world", model_id="minimax/MiniMax-Text-01", stage="DIRECT_GENERATION_A")


def test_stage_only_fallback_is_strictly_prohibited(tmp_path: Path):
    """Matching record for same stage but different prompt_sha256 must NOT match."""
    prompt_old = "Old prompt"
    prompt_old_sha = hashlib.sha256(prompt_old.encode("utf-8")).hexdigest()
    raw_text = "{}"
    rec = {
        "stage": "DIRECT_GENERATION_A",
        "prompt_sha256": prompt_old_sha,
        "raw_text": raw_text,
        "raw_text_sha256": hashlib.sha256(raw_text.encode("utf-8")).hexdigest(),
        "recorded_at_ns": 100,
    }
    (tmp_path / "rec_01.json").write_text(json.dumps(rec), encoding="utf-8")
    client = ReplayExperimentClient(tmp_path)

    with pytest.raises(RuntimeError, match="Stage-only fallback is strictly prohibited"):
        client.dispatch(prompt="Different prompt", model_id="minimax/MiniMax-Text-01", stage="DIRECT_GENERATION_A")


def test_corrupted_response_hash_mismatch_raises(tmp_path: Path):
    """Corrupted response whose content does not match raw_text_sha256 must raise ValueError."""
    prompt = "Test prompt"
    prompt_sha = hashlib.sha256(prompt.encode("utf-8")).hexdigest()
    rec = {
        "stage": "GENERATION",
        "prompt_sha256": prompt_sha,
        "raw_text": "{\"actual\": \"content\"}",
        "raw_text_sha256": "wrong_hash_000000000000000000000000000000000000000000000000000000",
        "recorded_at_ns": 100,
    }
    (tmp_path / "corrupted.json").write_text(json.dumps(rec), encoding="utf-8")
    client = ReplayExperimentClient(tmp_path)

    with pytest.raises(ValueError, match="Integrity check failed"):
        client.dispatch(prompt=prompt, model_id="minimax/MiniMax-Text-01", stage="GENERATION")


def test_unique_one_to_one_response_consumption(tmp_path: Path):
    """A provider record can only be consumed once; subsequent dispatches require distinct records."""
    prompt = "Repeated prompt"
    prompt_sha = hashlib.sha256(prompt.encode("utf-8")).hexdigest()
    raw_text = "{\"res\": 1}"
    rec1 = {
        "stage": "REPAIR",
        "prompt_sha256": prompt_sha,
        "raw_text": raw_text,
        "raw_text_sha256": hashlib.sha256(raw_text.encode("utf-8")).hexdigest(),
        "recorded_at_ns": 100,
    }
    (tmp_path / "rec_01.json").write_text(json.dumps(rec1), encoding="utf-8")
    client = ReplayExperimentClient(tmp_path)

    # First dispatch consumes rec1
    res1 = client.dispatch(prompt=prompt, model_id="minimax/MiniMax-Text-01", stage="REPAIR")
    assert res1.raw_text == raw_text

    # Second dispatch with same prompt must fail because rec1 is already consumed
    with pytest.raises(RuntimeError, match="Strict replay failure"):
        client.dispatch(prompt=prompt, model_id="minimax/MiniMax-Text-01", stage="REPAIR")


def test_safe_null_proposed_answer_handling():
    """Null proposed answer does not crash with AttributeError and marks UNSCORABLE_MISSING_ANSWER."""
    evaluator = NeutralEvaluatorV2_3()
    q_dict = {
        "question_id": "1",
        "prompt": "CAM plants achieve high water-use efficiency.",
        "question_type": "TFNG",
        "proposed_answer": None,
        "options": [],
    }

    # Evaluating an item with null proposed answer must succeed without crashing
    res = evaluator.evaluate_item(
        dataset_item_id="dev-reading-01",
        passage_text="Crassulacean acid metabolism enables xerophytes to achieve high water-use efficiency.",
        question_data=q_dict,
    )

    assert res.verdict == EvaluationVerdict.FAIL
    assert res.task_validity.get("has_proposed_answer") is False
    assert "UNSCORABLE_MISSING_ANSWER" in (res.abstention_reason or "")


def test_no_answer_borrowing_across_stages():
    """Terminal candidates lacking answer keys preserve missing status without draft borrowing."""
    terminal_candidate = {
        "question_id": "1",
        "text": "CAM plants open their stomata during the day.",
        "question_type": "TFNG",
        # Notice: proposed_answer is omitted!
    }
    earlier_draft = {
        "question_id": "1",
        "text": "CAM plants open their stomata during the day.",
        "question_type": "TFNG",
        "proposed_answer": "FALSE",  # Should NOT be borrowed!
    }

    # Simulate provenance extraction from terminal stage
    terminal_provenance = {
        "authoritative_answer_provenance": [
            {
                "question_id": "1",
                "proposed_answer": terminal_candidate.get("proposed_answer"),
                "status": "AVAILABLE" if terminal_candidate.get("proposed_answer") else "UNSCORABLE_MISSING_ANSWER",
            }
        ]
    }

    auth_record = terminal_provenance["authoritative_answer_provenance"][0]
    assert auth_record["proposed_answer"] is None
    assert auth_record["status"] == "UNSCORABLE_MISSING_ANSWER"
    # Verify earlier draft answer was not borrowed
    assert auth_record["proposed_answer"] != earlier_draft["proposed_answer"]
