"""Unit and Regression Tests for RG10 Terminal Answer Preservation (Blocker B).

Verifies:
1. Every terminal candidate contains a complete proposed-answer mapping bound to its exact
   final question text, question content hash, and output response hash.
2. Revised questions receive newly validated answers without borrowing from rejected drafts.
3. Reviewer and blind solver remain strictly answer-blind across all revision and repair dispatches.
4. Missing answers cause explicit failure (PROPOSED_ANSWERS_MISSING) or authorized scoped repair.
5. Unsuccessful repairs are preserved without fake PASS.
6. Arms A, B, and C strictly retain their registered architectural differences.
"""
from __future__ import annotations

import hashlib
import json
from pathlib import Path
from typing import Any
import pytest

from app.contracts.artifact import canonical_json_dump
from app.contracts.research import (
    ExecutionStatus,
    GrammarExerciseType,
    GrammarRulePack,
    GrammarTask,
    OutputAvailability,
    PairedTaskFixture,
    PromptVersionMap,
    ReadingTask,
    SourceRef,
    StandaloneGrammarRequest,
    StandaloneGroupType,
    StandaloneReadingRequest,
)
from app.experiment.runners import (
    ConfigurationARunner,
    ConfigurationBRunner,
    ConfigurationCRunner,
    LLMDispatchResponse,
)

PASSAGE = (
    "Mangrove ecosystems sequester carbon in anaerobic substrate at four times the rate of terrestrial forests. "
    "Obligate CAM species nocturnally assimilate atmospheric carbon dioxide via phosphoenolpyruvate carboxylase. "
    "The resulting four-carbon dicarboxylic acid, predominantly malate, is sequestered inside central vacuoles until daybreak."
)


class MockSequentialClient:
    def __init__(self, responses: list[dict[str, Any]]):
        self.responses = list(responses)
        self.recorded_dispatches: list[dict[str, Any]] = []

    def dispatch(self, **kwargs: Any) -> LLMDispatchResponse:
        self.recorded_dispatches.append(kwargs)
        resp_data = self.responses.pop(0)
        raw_text = json.dumps(resp_data.get("body", resp_data))
        raw_sha = hashlib.sha256(raw_text.encode("utf-8")).hexdigest()
        return LLMDispatchResponse(
            raw_text=raw_text,
            prompt_tokens=100,
            completion_tokens=50,
            total_tokens=150,
            latency_ms=15.0,
            confidence="EXACT",
            model_id="minimax/MiniMax-Text-01",
            raw_response_ref=f"secure://raw_responses/{raw_sha[:16]}.json",
        )


def _reading_req(arm: str = "B", run_id: str = "test-rd-preservation") -> StandaloneReadingRequest:
    return StandaloneReadingRequest(
        run_id=run_id,
        dataset_item_id="dev-reading-01",
        configuration_id=arm,
        task=ReadingTask(
            requested_groups=[StandaloneGroupType.TFNG],
            requested_question_count=1,
            difficulty="MEDIUM",
        ),
        source_pack_id="src-preservation-01",
    )


def test_arm_b_revision_receives_newly_validated_answers_without_draft_borrowing():
    """Revised questions receive newly validated answers bound to revised text, never borrowed from draft."""
    draft_response = {
        "question_groups": [{"group_id": "g1", "question_ids": ["q1"]}],
        "questions": [{
            "question_id": "q1",
            "question_type": "TFNG",
            "text": "Initial draft question.",
            "instructions": "True/False/Not Given",
            "options": [],
            "proposed_answer": "FALSE",  # Initial draft answer
        }],
    }
    critique_response = {
        "verdict": "REVISION_NEEDED",
        "score": 0.5,
        "issues": ["Revise text to specify nocturnal assimilation."],
    }
    revised_response = {
        "question_groups": [{"group_id": "g1", "question_ids": ["q1"]}],
        "questions": [{
            "question_id": "q1",
            "question_type": "TFNG",
            "text": "Obligate CAM species nocturnally assimilate atmospheric carbon dioxide.",
            "instructions": "True/False/Not Given",
            "options": [],
            "proposed_answer": "TRUE",  # Newly validated answer on revised text!
        }],
    }

    client = MockSequentialClient([draft_response, critique_response, revised_response])
    runner = ConfigurationBRunner(client=client)

    result, trace, usage = runner.generate_reading(
        request=_reading_req("B"),
        passage_text=PASSAGE,
        prompt_version="v3.1",
        foundation_model_id="minimax/MiniMax-Text-01",
    )

    assert result.execution_status == ExecutionStatus.COMPLETED
    assert result.failure_code is None

    # Check authoritative answer provenance
    prov = trace["authoritative_answer_provenance"]
    assert len(prov) == 1
    q_prov = prov[0]
    assert q_prov["question_id"] == "q1"
    assert q_prov["stage"] == "BOUNDED_REVISION"
    assert q_prov["proposed_answer"] == "TRUE"  # Matches revised answer, NOT draft "FALSE"
    assert q_prov["status"] == "AVAILABLE"
    expected_text = "Obligate CAM species nocturnally assimilate atmospheric carbon dioxide."
    assert q_prov["question_text"] == expected_text
    assert q_prov["question_text_sha256"] == hashlib.sha256(expected_text.encode("utf-8")).hexdigest()
    expected_content_hash = hashlib.sha256(canonical_json_dump({
        "text": expected_text,
        "options": [],
        "instructions": "True/False/Not Given",
    }).encode("utf-8")).hexdigest()
    assert q_prov["question_content_hash"] == expected_content_hash


def test_arm_b_missing_answers_in_revision_causes_explicit_failure_without_borrowing():
    """If bounded revision omits proposed_answer, it terminates FAILED_VALIDATION without borrowing draft key."""
    draft_response = {
        "question_groups": [{"group_id": "g1", "question_ids": ["q1"]}],
        "questions": [{
            "question_id": "q1",
            "question_type": "TFNG",
            "text": "Initial draft question.",
            "instructions": "True/False/Not Given",
            "options": [],
            "proposed_answer": "FALSE",
        }],
    }
    critique_response = {
        "verdict": "REVISION_NEEDED",
        "score": 0.5,
        "issues": ["Revise phrasing."],
    }
    # Revision omits proposed_answer!
    revised_missing = {
        "question_groups": [{"group_id": "g1", "question_ids": ["q1"]}],
        "questions": [{
            "question_id": "q1",
            "question_type": "TFNG",
            "text": "Revised question lacking proposed answer key.",
            "instructions": "True/False/Not Given",
            "options": [],
        }],
    }

    client = MockSequentialClient([draft_response, critique_response, revised_missing])
    runner = ConfigurationBRunner(client=client)

    result, trace, usage = runner.generate_reading(
        request=_reading_req("B"),
        passage_text=PASSAGE,
        prompt_version="v3.1",
        foundation_model_id="minimax/MiniMax-Text-01",
    )

    assert result.execution_status == ExecutionStatus.FAILED_VALIDATION
    assert result.failure_code == "PROPOSED_ANSWERS_MISSING"

    prov = trace["authoritative_answer_provenance"]
    assert len(prov) == 1
    q_prov = prov[0]
    assert q_prov["proposed_answer"] is None  # Never borrowed from draft!
    assert q_prov["status"] == "UNSCORABLE_MISSING_ANSWER"
    assert q_prov["question_text"] == "Revised question lacking proposed answer key."


def test_arm_c_scoped_repair_recovers_missing_answers_with_answer_blind_review():
    """Arm C allows scoped repair when proposed answers are missing, keeping reviewer answer-blind."""
    initial_candidate = {
        "question_groups": [{"group_id": "g1", "question_ids": ["q1"]}],
        "questions": [{
            "question_id": "q1",
            "question_type": "TFNG",
            "text": "Initial candidate missing answer.",
            "instructions": "True/False/Not Given",
            "options": [],
            # proposed_answer omitted -> triggers PROPOSED_ANSWERS_MISSING
        }],
    }
    repaired_candidate = {
        "question_groups": [{"group_id": "g1", "question_ids": ["q1"]}],
        "questions": [{
            "question_id": "q1",
            "question_type": "TFNG",
            "text": "Obligate CAM species nocturnally assimilate atmospheric carbon dioxide.",
            "instructions": "True/False/Not Given",
            "options": [],
            "proposed_answer": "TRUE",
        }],
    }
    reviewer_approve = {"status": "APPROVED", "issues": []}
    solver_agree = {"answers": [{"question_id": "q1", "answer": "TRUE", "ambiguous": False}]}
    validator_accept = {"accepted": True, "issues": []}

    client = MockSequentialClient([
        initial_candidate,   # 1. GENERATOR (missing answer)
        repaired_candidate,  # 2. REPAIR (scoped repair invoked)
        reviewer_approve,    # 3. REVIEWER (answer-blind)
        solver_agree,        # 4. BLIND_SOLVER (answer-blind)
        validator_accept,    # 5. VALIDATOR
    ])

    runner = ConfigurationCRunner(client=client, default_max_repairs=1)
    result, trace, usage = runner.generate_reading(
        request=_reading_req("C"),
        passage_text=PASSAGE,
        prompt_version="v3.1",
        foundation_model_id="minimax/MiniMax-Text-01",
    )

    assert result.execution_status == ExecutionStatus.COMPLETED
    assert result.failure_code is None
    assert usage["repair_count"] == 1

    # Verify that reviewer and solver never received proposed answers
    rev_dispatch = client.recorded_dispatches[2]
    assert rev_dispatch["stage"] == "REVIEWER"
    rev_payload = json.loads(rev_dispatch["prompt"])
    for q in rev_payload["candidate"]["questions"]:
        assert "proposed_answer" not in q
        assert "answer" not in q

    solver_dispatch = client.recorded_dispatches[3]
    assert solver_dispatch["stage"] == "BLIND_SOLVER"
    solver_payload = json.loads(solver_dispatch["prompt"])
    for q in solver_payload["candidate"]["questions"]:
        assert "proposed_answer" not in q
        assert "answer" not in q

    # Final candidate has complete proposed-answer mapping bound to exact text and content hash
    prov = trace["authoritative_answer_provenance"]
    assert len(prov) == 1
    assert prov[0]["proposed_answer"] == "TRUE"
    assert prov[0]["status"] == "AVAILABLE"
    expected_c_text = "Obligate CAM species nocturnally assimilate atmospheric carbon dioxide."
    assert prov[0]["question_text"] == expected_c_text
    assert prov[0]["question_text_sha256"] == hashlib.sha256(expected_c_text.encode("utf-8")).hexdigest()
    expected_c_content_hash = hashlib.sha256(canonical_json_dump({
        "text": expected_c_text,
        "options": [],
        "instructions": "True/False/Not Given",
    }).encode("utf-8")).hexdigest()
    assert prov[0]["question_content_hash"] == expected_c_content_hash


def test_arm_c_unsuccessful_repairs_are_preserved_without_fake_pass():
    """When Arm C repair attempts fail, the terminal failure is preserved honestly without fake pass."""
    initial_candidate = {
        "question_groups": [{"group_id": "g1", "question_ids": ["q1"]}],
        "questions": [{
            "question_id": "q1",
            "question_type": "TFNG",
            "text": "Initial candidate.",
            "instructions": "True/False",
            "options": [],
            "proposed_answer": "TRUE",
        }],
    }
    reviewer_reject = {"status": "REJECTED", "issues": ["Grounding contradiction"]}
    # Repair also fails with reviewer rejection
    repaired_candidate = {
        "question_groups": [{"group_id": "g1", "question_ids": ["q1"]}],
        "questions": [{
            "question_id": "q1",
            "question_type": "TFNG",
            "text": "Unfixed candidate.",
            "instructions": "True/False",
            "options": [],
            "proposed_answer": "TRUE",
        }],
    }
    reviewer_reject_again = {"status": "REJECTED", "issues": ["Still contradicts passage"]}

    client = MockSequentialClient([
        initial_candidate,      # 1. GENERATOR
        reviewer_reject,        # 2. REVIEWER
        repaired_candidate,     # 3. REPAIR
        reviewer_reject_again,  # 4. REVIEWER (rejects repair)
    ])

    runner = ConfigurationCRunner(client=client, default_max_repairs=1)
    result, trace, usage = runner.generate_reading(
        request=_reading_req("C"),
        passage_text=PASSAGE,
        prompt_version="v3.1",
        foundation_model_id="minimax/MiniMax-Text-01",
    )

    assert result.execution_status == ExecutionStatus.FAILED_VALIDATION
    assert result.failure_code == "REVIEW_REJECTED"
    assert usage["repair_count"] == 1
    assert trace.get("internal_accepted_head") is False


def test_arms_retain_registered_architectural_differences():
    """Ensure Arms A, B, and C strictly retain their registered architectural pipeline topologies."""
    from app.experiment.runners import (
        HiddenRepairForbiddenError,
        InternalScoreAsExternalVerdictForbiddenError,
    )

    runner_a = ConfigurationARunner()
    runner_b = ConfigurationBRunner()
    runner_c = ConfigurationCRunner()
    # Arm A allows zero repairs or revisions
    with pytest.raises(HiddenRepairForbiddenError):
        runner_a.generate_reading(_reading_req("A"), PASSAGE, "v3.1", "model", max_repairs=1)

    # Arm B forbids external certification of internal self-score
    with pytest.raises(InternalScoreAsExternalVerdictForbiddenError):
        runner_b.certify_external_verdict(internal_score=0.9)

    # Arm C is multi-agent coordinated with external reviewer, solver, and scoped repair
    assert runner_c.default_max_repairs == 0
    runner_c_dev = ConfigurationCRunner(default_max_repairs=1)
    assert runner_c_dev.default_max_repairs == 1
