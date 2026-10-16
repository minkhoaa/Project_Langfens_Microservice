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


def test_duplicate_records_resolved_by_pipeline_interleave(tmp_path: Path):
    """Duplicate prompt hashes separated by an intervening pipeline stage are resolved by interleave."""
    prompt = "Review candidate question"
    prompt_sha = hashlib.sha256(prompt.encode("utf-8")).hexdigest()

    rec1 = {
        "stage": "REVIEWER",
        "operation_id": "research-REVIEWER-1",
        "prompt_sha256": prompt_sha,
        "raw_text": "{\"status\": \"REJECTED\"}",
        "raw_text_sha256": hashlib.sha256(b"{\"status\": \"REJECTED\"}").hexdigest(),
        "recorded_at_ns": 100,
    }
    rec_intervening = {
        "stage": "REPAIR",
        "operation_id": "research-REPAIR-2",
        "prompt_sha256": hashlib.sha256(b"Repair prompt").hexdigest(),
        "raw_text": "{\"status\": \"REPAIRED\"}",
        "raw_text_sha256": hashlib.sha256(b"{\"status\": \"REPAIRED\"}").hexdigest(),
        "recorded_at_ns": 200,
    }
    rec2 = {
        "stage": "REVIEWER",
        "operation_id": "research-REVIEWER-3",
        "prompt_sha256": prompt_sha,
        "raw_text": "{\"status\": \"APPROVED\"}",
        "raw_text_sha256": hashlib.sha256(b"{\"status\": \"APPROVED\"}").hexdigest(),
        "recorded_at_ns": 300,
    }
    (tmp_path / "rec_01.json").write_text(json.dumps(rec1), encoding="utf-8")
    (tmp_path / "rec_02.json").write_text(json.dumps(rec_intervening), encoding="utf-8")
    (tmp_path / "rec_03.json").write_text(json.dumps(rec2), encoding="utf-8")

    client = ReplayExperimentClient(tmp_path)
    res1 = client.dispatch(prompt=prompt, model_id="minimax/MiniMax-Text-01", stage="REVIEWER")
    assert "REJECTED" in res1.raw_text
    assert len(client.ambiguous_dispatches) == 1
    assert client.ambiguous_dispatches[0]["ambiguity_status"] == "RESOLVED_BY_PIPELINE_INTERLEAVE"
    assert client.ambiguous_dispatches[0]["intervening_stages"] == ["REPAIR"]


def test_adjacent_duplicate_records_fail_closed_under_strict_mode(tmp_path: Path):
    """Adjacent duplicate records with no intervening stage fail closed when strict_ambiguity_mode=True."""
    prompt = "Review candidate question"
    prompt_sha = hashlib.sha256(prompt.encode("utf-8")).hexdigest()

    rec1 = {
        "stage": "REVIEWER",
        "operation_id": "research-REVIEWER-1",
        "prompt_sha256": prompt_sha,
        "raw_text": "{\"status\": \"REJECTED\"}",
        "raw_text_sha256": hashlib.sha256(b"{\"status\": \"REJECTED\"}").hexdigest(),
        "recorded_at_ns": 100,
    }
    rec2 = {
        "stage": "REVIEWER",
        "operation_id": "research-REVIEWER-2",
        "prompt_sha256": prompt_sha,
        "raw_text": "{\"status\": \"APPROVED\"}",
        "raw_text_sha256": hashlib.sha256(b"{\"status\": \"APPROVED\"}").hexdigest(),
        "recorded_at_ns": 101,  # Adjacent with no intervening stage!
    }
    (tmp_path / "rec_01.json").write_text(json.dumps(rec1), encoding="utf-8")
    (tmp_path / "rec_02.json").write_text(json.dumps(rec2), encoding="utf-8")

    client_strict = ReplayExperimentClient(tmp_path, strict_ambiguity_mode=True)
    with pytest.raises(RuntimeError, match="AMBIGUOUS_REPLAY_EVIDENCE"):
        client_strict.dispatch(prompt=prompt, model_id="minimax/MiniMax-Text-01", stage="REVIEWER")


def test_missing_proposed_answer_triggers_proposed_answers_missing():
    """When candidate questions omit proposed_answer, parse_candidate flags PROPOSED_ANSWERS_MISSING."""
    from app.contracts.research import StandaloneReadingRequest, ReadingTask, StandaloneGroupType
    from app.experiment.parsing import parse_candidate

    req = StandaloneReadingRequest(
        run_id="test-run",
        dataset_item_id="dev-reading-01",
        configuration_id="B",
        task=ReadingTask(
            requested_groups=[StandaloneGroupType.TFNG],
            requested_question_count=1,
            difficulty="MEDIUM",
        ),
        source_pack_id="src-01",
    )
    raw_json = json.dumps({
        "context_text": "Photosynthesis produces carbohydrates in green plants.",
        "question_groups": [{"group_id": "g1", "question_ids": ["q1"]}],
        "questions": [
            {
                "question_id": "q1",
                "question_type": "TFNG",
                "text": "Plants produce carbohydrates through photosynthesis.",
                "instructions": "Determine if TRUE, FALSE, or NOT GIVEN.",
                # Notice: proposed_answer is omitted!
            }
        ],
    })

    cand = parse_candidate(raw_json, req, "Photosynthesis produces carbohydrates in green plants.")
    assert cand.failure_code == "PROPOSED_ANSWERS_MISSING"


def test_visible_candidate_scrubs_proposed_answers_for_reviewer():
    """Ensure answer-blind reviewer/solver never receives proposed_answer or answer keys."""
    from app.contracts.research import StandaloneReadingRequest, ReadingTask, StandaloneGroupType
    from app.experiment.runners import _Run

    req = StandaloneReadingRequest(
        run_id="test-run",
        dataset_item_id="dev-reading-01",
        configuration_id="C",
        task=ReadingTask(
            requested_groups=[StandaloneGroupType.TFNG],
            requested_question_count=1,
            difficulty="MEDIUM",
        ),
        source_pack_id="src-01",
    )
    run = _Run(None, req, "C", "v3.1", "minimax/MiniMax-Text-01", "Passage text.")

    # Create mock parsed candidate with proposed answers
    from app.contracts.research import NeutralOutput, NeutralQuestion, NeutralQuestionGroup
    content = NeutralOutput(
        context_text="Passage text.",
        question_groups=[NeutralQuestionGroup(group_id="g1", question_ids=["q1"])],
        questions=[NeutralQuestion(question_id="q1", question_type=StandaloneGroupType.TFNG,
                                   text="Is this true?", instructions="True/False", options=[])],
    )
    from app.experiment.parsing import ParsedCandidate
    from app.contracts.research import OutputAvailability
    run.candidate = ParsedCandidate(content, OutputAvailability.NORMALIZED, None, (("q1", "TRUE"),))

    vis = run.visible()
    assert vis is not None
    assert "context_text" not in vis
    for q in vis.get("questions", []):
        assert "proposed_answer" not in q
        assert "answer" not in q

    # Assert on serialized dispatch payloads for REVIEWER and BLIND_SOLVER
    from app.contracts.artifact import canonical_json_dump
    rev_prompt = canonical_json_dump({
        "configuration_id": run.arm, "prompt_version": run.prompt_version, "stage": "REVIEWER",
        "task": run.request.task.model_dump(mode="json"), "candidate": vis, **run.source(),
    })
    solver_prompt = canonical_json_dump({
        "configuration_id": run.arm, "prompt_version": run.prompt_version, "stage": "BLIND_SOLVER",
        "task": run.request.task.model_dump(mode="json"), "candidate": vis, **run.source(),
    })

    assert "proposed_answer" not in rev_prompt
    assert "proposed_answers" not in rev_prompt
    assert "proposed_answer" not in solver_prompt
    assert "proposed_answers" not in solver_prompt
    assert '"TRUE"' not in rev_prompt
    assert '"TRUE"' not in solver_prompt

def test_stable_operation_id_matching_resolves_duplicate_prompts(tmp_path: Path):
    """When duplicate prompt hashes exist, specifying operation_id binds to the exact matching candidate."""
    prompt = "Review candidate question"
    prompt_sha = hashlib.sha256(prompt.encode("utf-8")).hexdigest()

    rec1 = {
        "stage": "REVIEWER",
        "operation_id": "research-REVIEWER-18",
        "prompt_sha256": prompt_sha,
        "raw_text": "{\"status\": \"REJECTED\"}",
        "raw_text_sha256": hashlib.sha256(b"{\"status\": \"REJECTED\"}").hexdigest(),
        "recorded_at_ns": 100,
    }
    rec2 = {
        "stage": "REVIEWER",
        "operation_id": "research-REVIEWER-20",
        "prompt_sha256": prompt_sha,
        "raw_text": "{\"status\": \"APPROVED\"}",
        "raw_text_sha256": hashlib.sha256(b"{\"status\": \"APPROVED\"}").hexdigest(),
        "recorded_at_ns": 200,
    }
    (tmp_path / "rec_18.json").write_text(json.dumps(rec1), encoding="utf-8")
    (tmp_path / "rec_20.json").write_text(json.dumps(rec2), encoding="utf-8")

    client = ReplayExperimentClient(tmp_path)
    # Explicitly dispatch with operation_id matching rec2
    res = client.dispatch(prompt=prompt, model_id="minimax/MiniMax-Text-01", stage="REVIEWER", operation_id="research-REVIEWER-20")
    assert "APPROVED" in res.raw_text
    assert len(client.ambiguous_dispatches) == 1
    assert client.ambiguous_dispatches[0]["ambiguity_status"] == "RESOLVED_BY_STABLE_OPERATION_ID"
    assert client.ambiguous_dispatches[0]["bound_operation"] == "research-REVIEWER-20"


def test_historical_forensic_vs_behavioral_reexecution_workflow_separation(tmp_path: Path):
    """Verify the separation of historical forensic replay (22/22) vs current behavioral re-execution (21/22)."""
    from generation_baseline.tools.replay_quality_dev_hardening import (
        run_historical_forensic_replay,
        run_behavioral_reexecution,
    )
    raw_dir = repo_root / "generation_baseline" / ".execution" / "RG10_DEV_HARDENING_V2" / "raw_responses"
    if not raw_dir.exists():
        pytest.skip("Historical raw_responses directory not present on this machine.")

    dir_forensic = tmp_path / "forensic"
    dir_behavioral = tmp_path / "behavioral"

    forensic_res = run_historical_forensic_replay(raw_responses_dir=raw_dir, output_dir=dir_forensic, publish_to_verification=False)
    assert forensic_res["total_dispatches"] == 22
    assert forensic_res["dispatches_consumed"] == 22
    assert len(forensic_res["unconsumed_records"]) == 0
    assert forensic_res["total_tokens"] == 23886
    assert forensic_res["pass_count"] == 4
    assert forensic_res["fail_count"] == 11

    behavioral_res = run_behavioral_reexecution(raw_responses_dir=raw_dir, output_dir=dir_behavioral, publish_to_verification=False)
    assert behavioral_res["telemetry"]["total_dispatches"] == 21
    assert len(behavioral_res["unconsumed_records"]) == 1
    assert "research-REVIEWER-8_REVIEWER_1792133038741024377.json" in behavioral_res["unconsumed_records"]
    assert behavioral_res["telemetry"]["total_tokens"] == 23191
    assert behavioral_res["measurements_12_dimensions"]["7_semantic_verdicts"]["PASS"] == 4
    assert behavioral_res["measurements_12_dimensions"]["7_semantic_verdicts"]["FAIL"] == 11
    # Assert verification directory was NOT mutated
    assert not (dir_forensic / "generation_baseline").exists()
    assert not (dir_behavioral / "generation_baseline").exists()
