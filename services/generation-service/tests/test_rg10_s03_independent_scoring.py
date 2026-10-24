"""Unit tests for RG10-S03: Independent scoring and blinded human subset.

Objective: External frozen evaluator, qualified human blind subset and adjudication without config labels.
Decisive acceptance condition: Evaluations bound to identical final content hashes and rubric version; gold isolated.
"""

from __future__ import annotations

import pytest

from app.contracts.research import (
    ExecutionStatus,
    ExperimentAssignment,
    GenerationResult,
    NeutralOutput,
    NeutralQuestion,
    NeutralQuestionGroup,
    OutputAvailability,
    StandaloneGroupType,
)
from app.evaluators.independent import NeutralEvaluator
from app.evaluators.rubric import EvaluationVerdict
from app.experiment.blind_review import (
    BlindReviewManager,
    GoldSmugglingForbiddenError,
    ReviewerVerdictSubmission,
    SealedGoldAccessForbiddenError,
    SealedGoldVault,
)
from app.experiment.campaign_runner import IndependentCampaignScorer
from app.persistence.grammar_store import ResearchPublicationForbiddenError


def _make_dummy_neutral_output(text: str = "Sample question text?") -> NeutralOutput:
    q = NeutralQuestion(
        question_id="q-001",
        question_type=StandaloneGroupType.MCQ_SINGLE,
        text=text,
        options=["Option A", "Option B", "Option C", "Option D"],
        instructions="Choose the correct letter.",
    )
    g = NeutralQuestionGroup(
        group_id="grp-001",
        question_ids=["q-001"],
    )
    return NeutralOutput(
        context_text="This is a test passage about science and engineering for independent evaluation.",
        question_groups=[g],
        questions=[q],
    )


def test_pos_rg10_s03_independent_scoring_bound_to_content_hash_and_rubric():
    """POS-RG10-S03: Evaluations bound to identical final content hashes and frozen rubric version."""
    scorer = IndependentCampaignScorer()

    assignment = ExperimentAssignment(
        assignment_id="asg-test-read-01",
        dataset_item_id="item-read-01",
        configuration_id="A",
        attempt_number=1,
    )

    output = _make_dummy_neutral_output()
    result = GenerationResult(
        run_id="run-asg-test-read-01",
        dataset_item_id="item-read-01",
        configuration_id="A",
        task_type="READING_SINGLE_PASSAGE",
        execution_status=ExecutionStatus.COMPLETED,
        output_availability=OutputAvailability.NORMALIZED,
        generated_content=output,
    )

    eval_result = scorer.score_generation_result(
        result=result,
        assignment=assignment,
        rubric_version="rubric-qgeval-v2.0",
    )

    # Invariants: bound to rubric version and exact output hash
    assert eval_result.rubric_version == "rubric-qgeval-v2.0"
    assert len(eval_result.output_sha256) == 64
    assert eval_result.verdict in (EvaluationVerdict.PASS, EvaluationVerdict.FAIL, EvaluationVerdict.UNCERTAIN)
    assert "neutral-eval-v2.0" in eval_result.evaluator_version


def test_neg_rg10_s03_gold_smuggling_and_missing_score_remains_missing():
    """NEG-RG10-S03: Gold cannot reach blind solve; missing score remains missing (never fake PASS)."""
    scorer = IndependentCampaignScorer()

    assignment = ExperimentAssignment(
        assignment_id="asg-test-read-02",
        dataset_item_id="item-read-02",
        configuration_id="B",
        attempt_number=1,
    )

    # 1. Missing output cannot receive an invented score
    missing_result = GenerationResult(
        run_id="run-asg-test-read-02",
        dataset_item_id="item-read-02",
        configuration_id="B",
        task_type="READING_SINGLE_PASSAGE",
        execution_status=ExecutionStatus.TIMED_OUT,
        output_availability=OutputAvailability.NONE,
        generated_content=None,
        failure_code="PROVIDER_TIMEOUT",
    )

    eval_result = scorer.score_generation_result(
        result=missing_result,
        assignment=assignment,
    )
    assert eval_result.verdict == EvaluationVerdict.NOT_RUN
    assert eval_result.evaluable is False
    assert eval_result.semantic_scores == {}

    # 2. Gold smuggling into blind solve fails closed with GoldSmugglingForbiddenError
    payload_with_gold = {
        "text": "Some reading text",
        "gold_answer": "Forbidden answer A",
    }
    with pytest.raises(GoldSmugglingForbiddenError) as exc_info:
        scorer.assert_no_gold_leak(payload_with_gold)
    assert "forbidden gold key" in str(exc_info.value)


def test_edge_rg10_s03_blind_human_subset_adjudication_and_unauthorized_gold():
    """EDGE-RG10-S03: Multi-reviewer blind subset adjudication and unauthorized gold unblinding blocked."""
    vault = SealedGoldVault()
    manager = BlindReviewManager(vault=vault)
    scorer = IndependentCampaignScorer(blind_manager=manager)

    assignment = ExperimentAssignment(
        assignment_id="asg-test-blind-01",
        dataset_item_id="item-blind-01",
        configuration_id="C",
        attempt_number=1,
    )
    result = GenerationResult(
        run_id="run-blind-01",
        dataset_item_id="item-blind-01",
        configuration_id="C",
        task_type="READING_SINGLE_PASSAGE",
        execution_status=ExecutionStatus.COMPLETED,
        output_availability=OutputAvailability.NORMALIZED,
        generated_content=_make_dummy_neutral_output(),
    )

    # Export blinded item (strips arm C and run_id)
    blind_item = manager.export_blind_review_item(
        assignment=assignment,
        generation_result=result,
        domain="READING",
        gold_answers={"q-001": "Option A"},
    )
    assert blind_item.blind_item_id.startswith("rev-blind-")
    assert "C" not in blind_item.blind_item_id
    assert "run-blind-01" not in blind_item.blind_item_id

    # Reviewer submissions and consensus adjudication
    manager.submit_review(
        ReviewerVerdictSubmission(
            blind_item_id=blind_item.blind_item_id,
            reviewer_id="reviewer-alpha",
            verdict="PASS",
            confidence=0.95,
        )
    )
    manager.submit_review(
        ReviewerVerdictSubmission(
            blind_item_id=blind_item.blind_item_id,
            reviewer_id="reviewer-beta",
            verdict="PASS",
            confidence=0.90,
        )
    )
    outcome = manager.adjudicate_item(blind_item.blind_item_id)
    assert outcome.unanimous is True
    assert outcome.final_verdict == "PASS"

    # Unauthorized role cannot unblind sealed gold
    with pytest.raises(SealedGoldAccessForbiddenError) as exc_info:
        vault.get_mapping(blind_item.blind_item_id, actor_role="BLIND_REVIEWER")
    assert "Only 'EXPERIMENT_AUDITOR' is permitted" in str(exc_info.value)


def test_reg_rg10_s03_research_isolation():
    """REG-RG10-S03: Evaluation results remain isolated from production publishing."""
    scorer = IndependentCampaignScorer()
    with pytest.raises(ResearchPublicationForbiddenError) as exc_info:
        scorer.publish_evaluation_to_production("eval-run-001", admin_user_id="fake-admin")
    assert "RESEARCH_PUBLICATION_FORBIDDEN" in str(exc_info.value)
