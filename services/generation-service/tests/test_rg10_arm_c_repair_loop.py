"""Arm C Multi-Agent Coordinated Pipeline and Scoped Repair Verification Suite (RG10).

Covers:
1. Immediate failure when max_repairs=0 on Reviewer rejection or Solver disagreement.
2. Exercising scoped multi-agent repair (max_repairs >= 1) when Reviewer rejects or Blind Solver disagrees.
3. Successful repair recovery: Generator -> Reviewer Reject -> Repair -> Reviewer Approve -> Solver Agree -> Validator Accept.
4. Strict non-weakening: Failed repair after max_repairs strictly terminates as FAILED_VALIDATION.
5. Canonical answer matching and strict disagreement preservation.
"""
from __future__ import annotations

import json
from typing import Any
import pytest

from app.contracts.research import (
    ExecutionStatus,
    GrammarExerciseType,
    GrammarRulePack,
    GrammarTask,
    OutputAvailability,
    ReadingTask,
    SourceRef,
    StandaloneGrammarRequest,
    StandaloneGroupType,
    StandaloneReadingRequest,
)
from app.experiment.runners import (
    ARM_C_MAX_REPAIR_CEILING,
    ARM_C_REPAIR_CONFIG_DEV_V2,
    ARM_C_REPAIR_CONFIG_HISTORICAL_V1,
    ConfigurationARunner,
    ConfigurationBRunner,
    ConfigurationCRunner,
    HiddenRepairForbiddenError,
    InternalScoreAsExternalVerdictForbiddenError,
    LLMDispatchResponse,
)


class SequentialClient:
    def __init__(self, responses: list[str]):
        self.responses = list(responses)
        self.recorded_dispatches = []

    def dispatch(self, **kwargs):
        self.recorded_dispatches.append(kwargs)
        txt = self.responses.pop(0)
        return LLMDispatchResponse(
            raw_text=txt,
            prompt_tokens=50,
            completion_tokens=25,
            total_tokens=75,
            latency_ms=10.0,
            confidence="ESTIMATED",
            cost_usd=None,
            model_id="minimax/MiniMax-Text-01",
        )

PASSAGE = (
    "Controlled environment agriculture (CEA) has become one of the fastest-growing sectors of modern "
    "horticulture. Fully enclosed indoor facilities rely exclusively on artificial lighting to optimize plant "
    "growth and maximize crop yields. Light quality refers to wavelength composition, while light intensity "
    "governs the photosynthetic rate. Recent studies demonstrate that specific blue and red spectrum ratios "
    "enhance secondary metabolite production in leafy greens and medicinal crops."
)

def _reading_req() -> StandaloneReadingRequest:
    return StandaloneReadingRequest(
        run_id="run-c-repair-01",
        dataset_item_id="item-c-repair-rd-01",
        configuration_id="C",
        task=ReadingTask(
            requested_groups=[StandaloneGroupType.TFNG],
            requested_question_count=1,
            difficulty="B2",
        ),
        source_pack_id="src-pack-01",
    )


def test_arm_c_max_repairs_zero_terminates_immediately_on_disagreement():
    """When max_repairs=0, solver disagreement terminates immediately without invoking REPAIR."""
    candidate_json = json.dumps({
        "question_groups": [{"group_id": "g1", "question_ids": ["q1"]}],
        "questions": [{
            "question_id": "q1", "question_type": "TFNG",
            "text": "CEA facilities use sunlight exclusively.",
            "instructions": "True, False, Not Given.", "options": [],
            "proposed_answer": "TRUE"
        }],
    })
    reviewer_approve = json.dumps({"status": "APPROVED", "issues": []})
    solver_disagree = json.dumps({"answers": [{"question_id": "q1", "answer": "FALSE", "ambiguous": False}]})

    client = SequentialClient([candidate_json, reviewer_approve, solver_disagree])

    runner = ConfigurationCRunner(client=client, default_max_repairs=0)
    result, trace, usage = runner.generate_reading(
        request=_reading_req(),
        passage_text=PASSAGE,
        prompt_version="v3.0",
        foundation_model_id="minimax/MiniMax-Text-01",
    )

    assert result.execution_status == ExecutionStatus.FAILED_VALIDATION
    assert result.failure_code == "ANSWER_VERIFICATION_DISAGREEMENT"
    assert usage["repair_count"] == 0
    stages = [step["stage"] for step in trace["steps"]]
    assert "REPAIR" not in stages
    assert stages == ["GENERATOR", "REVIEWER", "BLIND_SOLVER"]


def test_arm_c_scoped_repair_recovers_from_reviewer_rejection():
    """When max_repairs=1 and reviewer rejects initial draft, REPAIR is invoked and succeeds."""
    initial_candidate = json.dumps({
        "question_groups": [{"group_id": "g1", "question_ids": ["q1"]}],
        "questions": [{
            "question_id": "q1", "question_type": "TFNG",
            "text": "Facilities rely on light.",
            "instructions": "True, False, Not Given.", "options": [],
            "proposed_answer": "TRUE"
        }],
    })
    reviewer_reject = json.dumps({"status": "REJECTED", "issues": ["Prompt is too vague and lacks specific passage terms"]})

    repaired_candidate = json.dumps({
        "question_groups": [{"group_id": "g1", "question_ids": ["q1"]}],
        "questions": [{
            "question_id": "q1", "question_type": "TFNG",
            "text": "Fully enclosed indoor facilities rely exclusively on artificial lighting.",
            "instructions": "True, False, Not Given.", "options": [],
            "proposed_answer": "TRUE"
        }],
    })
    reviewer_approve = json.dumps({"status": "APPROVED", "issues": []})
    solver_agree = json.dumps({"answers": [{"question_id": "q1", "answer": "TRUE", "ambiguous": False}]})
    validator_accept = json.dumps({"accepted": True, "issues": []})

    responses = [
        initial_candidate,   # 1. GENERATOR
        reviewer_reject,     # 2. REVIEWER
        repaired_candidate,  # 3. REPAIR
        reviewer_approve,    # 4. REVIEWER (re-check)
        solver_agree,        # 5. BLIND_SOLVER
        validator_accept,    # 6. VALIDATOR
    ]

    client = SequentialClient(responses)
    runner = ConfigurationCRunner(client=client, default_max_repairs=1)

    result, trace, usage = runner.generate_reading(
        request=_reading_req(),
        passage_text=PASSAGE,
        prompt_version="v3.0",
        foundation_model_id="minimax/MiniMax-Text-01",
    )

    assert result.execution_status == ExecutionStatus.COMPLETED
    assert result.failure_code is None
    assert usage["repair_count"] == 1
    stages = [step["stage"] for step in trace["steps"]]
    assert stages == ["GENERATOR", "REVIEWER", "REPAIR", "REVIEWER", "BLIND_SOLVER", "VALIDATOR"]
    assert result.generated_content.questions[0].text == "Fully enclosed indoor facilities rely exclusively on artificial lighting."


def test_arm_c_repair_exhaustion_terminates_strictly():
    """When repair fails to resolve the issue, execution terminates strictly with FAILED_VALIDATION."""
    initial_candidate = json.dumps({
        "question_groups": [{"group_id": "g1", "question_ids": ["q1"]}],
        "questions": [{
            "question_id": "q1", "question_type": "TFNG",
            "text": "Facilities rely on light.",
            "instructions": "True, False, Not Given.", "options": [],
            "proposed_answer": "TRUE"
        }],
    })
    reviewer_reject = json.dumps({"status": "REJECTED", "issues": ["Prompt is too vague"]})

    responses = [
        initial_candidate,   # 1. GENERATOR
        reviewer_reject,     # 2. REVIEWER
        initial_candidate,   # 3. REPAIR (unfixed)
        reviewer_reject,     # 4. REVIEWER (rejects again)
    ]

    client = SequentialClient(responses)
    runner = ConfigurationCRunner(client=client, default_max_repairs=1)

    result, trace, usage = runner.generate_reading(
        request=_reading_req(),
        passage_text=PASSAGE,
        prompt_version="v3.0",
        foundation_model_id="minimax/MiniMax-Text-01",
    )

    assert result.execution_status == ExecutionStatus.FAILED_VALIDATION
    assert result.failure_code == "REVIEW_REJECTED"
    assert usage["repair_count"] == 1
    stages = [step["stage"] for step in trace["steps"]]
    assert stages == ["GENERATOR", "REVIEWER", "REPAIR", "REVIEWER"]

def test_arm_c_scoped_repair_recovers_from_blind_solver_disagreement():
    """When blind solver disagrees on round 0, REPAIR is invoked, resolved, and validated."""
    initial_candidate = json.dumps({
        "question_groups": [{"group_id": "g1", "question_ids": ["q1"]}],
        "questions": [{
            "question_id": "q1", "question_type": "TFNG",
            "text": "Facilities rely on sunlight.",
            "instructions": "True, False, Not Given.", "options": [],
            "proposed_answer": "TRUE"
        }],
    })
    reviewer_approve = json.dumps({"status": "APPROVED", "issues": []})
    solver_disagree = json.dumps({"answers": [{"question_id": "q1", "answer": "FALSE", "ambiguous": False}]})

    repaired_candidate = json.dumps({
        "question_groups": [{"group_id": "g1", "question_ids": ["q1"]}],
        "questions": [{
            "question_id": "q1", "question_type": "TFNG",
            "text": "Fully enclosed indoor facilities rely exclusively on artificial lighting.",
            "instructions": "True, False, Not Given.", "options": [],
            "proposed_answer": "TRUE"
        }],
    })
    solver_agree = json.dumps({"answers": [{"question_id": "q1", "answer": "TRUE", "ambiguous": False}]})
    validator_accept = json.dumps({"accepted": True, "issues": []})

    responses = [
        initial_candidate,   # 1. GENERATOR
        reviewer_approve,    # 2. REVIEWER (approves candidate)
        solver_disagree,     # 3. BLIND_SOLVER (disagrees: ANSWER_VERIFICATION_DISAGREEMENT)
        repaired_candidate,  # 4. REPAIR (repairing disagreement)
        reviewer_approve,    # 5. REVIEWER (re-checks repaired candidate)
        solver_agree,        # 6. BLIND_SOLVER (solves correctly, agrees with proposed answer)
        validator_accept,    # 7. VALIDATOR (accepts)
    ]

    client = SequentialClient(responses)
    runner = ConfigurationCRunner(client=client, default_max_repairs=1)

    result, trace, usage = runner.generate_reading(
        request=_reading_req(),
        passage_text=PASSAGE,
        prompt_version="v3.0",
        foundation_model_id="minimax/MiniMax-Text-01",
    )

    assert result.execution_status == ExecutionStatus.COMPLETED
    assert result.failure_code is None
    assert usage["repair_count"] == 1
    stages = [step["stage"] for step in trace["steps"]]
    assert stages == ["GENERATOR", "REVIEWER", "BLIND_SOLVER", "REPAIR", "REVIEWER", "BLIND_SOLVER", "VALIDATOR"]
    assert result.generated_content.questions[0].text == "Fully enclosed indoor facilities rely exclusively on artificial lighting."


def test_arm_c_solver_disagreement_exhaustion_preserves_semantic_failure():
    """When solver continues to disagree after repair attempt, failure code is strictly preserved."""
    initial_candidate = json.dumps({
        "question_groups": [{"group_id": "g1", "question_ids": ["q1"]}],
        "questions": [{
            "question_id": "q1", "question_type": "TFNG",
            "text": "Facilities rely on sunlight.",
            "instructions": "True, False, Not Given.", "options": [],
            "proposed_answer": "TRUE"
        }],
    })
    reviewer_approve = json.dumps({"status": "APPROVED", "issues": []})
    solver_disagree = json.dumps({"answers": [{"question_id": "q1", "answer": "FALSE", "ambiguous": False}]})

    responses = [
        initial_candidate,   # 1. GENERATOR
        reviewer_approve,    # 2. REVIEWER
        solver_disagree,     # 3. BLIND_SOLVER (disagreement)
        initial_candidate,   # 4. REPAIR (unfixed)
        reviewer_approve,    # 5. REVIEWER
        solver_disagree,     # 6. BLIND_SOLVER (disagreement persists)
    ]

    client = SequentialClient(responses)
    runner = ConfigurationCRunner(client=client, default_max_repairs=1)

    result, trace, usage = runner.generate_reading(
        request=_reading_req(),
        passage_text=PASSAGE,
        prompt_version="v3.0",
        foundation_model_id="minimax/MiniMax-Text-01",
    )

    assert result.execution_status == ExecutionStatus.FAILED_VALIDATION
    assert result.failure_code == "ANSWER_VERIFICATION_DISAGREEMENT"
    assert usage["repair_count"] == 1
    stages = [step["stage"] for step in trace["steps"]]
    assert stages == ["GENERATOR", "REVIEWER", "BLIND_SOLVER", "REPAIR", "REVIEWER", "BLIND_SOLVER"]


def test_arms_a_and_b_strictly_forbidden_from_arm_c_coordinated_repair():
    """Arms A and B are strictly bounded and do not have access to Arm C multi-agent repair."""
    req = _reading_req()
    runner_a = ConfigurationARunner()
    runner_b = ConfigurationBRunner()

    # Arm A forbids repairs
    with pytest.raises(HiddenRepairForbiddenError):
        runner_a.generate_reading(
            request=req,
            passage_text=PASSAGE,
            prompt_version="v2.1",
            foundation_model_id="minimax/MiniMax-Text-01",
            attempt_repair=True,
        )

    with pytest.raises(HiddenRepairForbiddenError):
        runner_a.generate_reading(
            request=req,
            passage_text=PASSAGE,
            prompt_version="v2.1",
            foundation_model_id="minimax/MiniMax-Text-01",
            max_repairs=1,
        )

    # Arm B forbids external certification of internal self-critique
    with pytest.raises(InternalScoreAsExternalVerdictForbiddenError):
        runner_b.certify_external_verdict(internal_verdict="APPROVED")


def test_versioned_arm_c_repair_config_profiles():
    """Explicit versioned profiles maintain historical freeze while enabling bounded repair for DEV."""
    assert ARM_C_REPAIR_CONFIG_HISTORICAL_V1 == 0
    assert ARM_C_REPAIR_CONFIG_DEV_V2 == 1
    assert ARM_C_MAX_REPAIR_CEILING == 2

    # Default construction preserves historical v1 (0 repairs)
    runner_default = ConfigurationCRunner()
    assert runner_default.default_max_repairs == 0
    assert runner_default.repair_config_version == "v1.0"

    # Version v2.0 profile sets bounded 1 repair
    runner_v2 = ConfigurationCRunner(repair_config_version="v2.0")
    assert runner_v2.default_max_repairs == 1
    assert runner_v2.repair_config_version == "v2.0"


def test_arm_c_prompt_leaks_answer_triggers_repair_and_recovers():
    """When candidate leaks proposed answer in prompt, PROMPT_LEAKS_ANSWER triggers REPAIR."""
    leaked_candidate = json.dumps({
        "context_text": PASSAGE,
        "question_groups": [{"group_id": "g1", "question_ids": ["q1"]}],
        "questions": [{
            "question_id": "q1", "question_type": "TFNG",
            "text": "The answer is TRUE that facilities rely exclusively on artificial lighting.",
            "instructions": "True, False, Not Given.", "options": [],
            "proposed_answer": "TRUE"
        }],
    })
    # Candidate with leaked substantive answer
    leaked_substantive = json.dumps({
        "context_text": PASSAGE,
        "question_groups": [{"group_id": "g1", "question_ids": ["q1"]}],
        "questions": [{
            "question_id": "q1", "question_type": "MCQ_SINGLE",
            "text": "In the sentence about artificial lighting, what is the light intensity?",
            "instructions": "Choose option.",
            "options": ["light intensity", "temperature", "humidity", "wavelength"],
            "proposed_answer": "light intensity"
        }],
    })
    repaired_candidate = json.dumps({
        "context_text": PASSAGE,
        "question_groups": [{"group_id": "g1", "question_ids": ["q1"]}],
        "questions": [{
            "question_id": "q1", "question_type": "MCQ_SINGLE",
            "text": "What physical parameter governs the photosynthetic rate?",
            "instructions": "Choose option.",
            "options": ["light intensity", "temperature", "humidity", "wavelength"],
            "proposed_answer": "light intensity"
        }],
    })
    reviewer_approve = json.dumps({"status": "APPROVED", "issues": []})
    solver_agree = json.dumps({"answers": [{"question_id": "q1", "answer": "light intensity", "ambiguous": False}]})
    validator_accept = json.dumps({"accepted": True, "issues": []})

    responses = [
        leaked_substantive,  # 1. GENERATOR (leaks "light intensity" in prompt)
        repaired_candidate,  # 2. REPAIR (prompt repaired without leaking answer)
        reviewer_approve,    # 3. REVIEWER (approves repaired candidate)
        solver_agree,        # 4. BLIND_SOLVER (solves without ambiguity)
        validator_accept,    # 5. VALIDATOR (accepts)
    ]

    req = StandaloneReadingRequest(
        run_id="run-c-repair-leak-01",
        dataset_item_id="item-c-repair-leak-01",
        configuration_id="C",
        task=ReadingTask(
            requested_groups=[StandaloneGroupType.MCQ_SINGLE],
            requested_question_count=1,
            difficulty="B2",
        ),
        source_pack_id="src-pack-01",
    )

    client = SequentialClient(responses)
    runner = ConfigurationCRunner(client=client, default_max_repairs=1)

    result, trace, usage = runner.generate_reading(
        request=req,
        passage_text=PASSAGE,
        prompt_version="v3.1",
        foundation_model_id="minimax/MiniMax-Text-01",
    )

    assert result.execution_status == ExecutionStatus.COMPLETED
    assert result.failure_code is None
    assert usage["repair_count"] == 1
    stages = [step["stage"] for step in trace["steps"]]
    assert "REPAIR" in stages
    assert result.generated_content.questions[0].text == "What physical parameter governs the photosynthetic rate?"
