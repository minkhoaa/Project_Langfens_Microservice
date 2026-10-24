"""Unit tests for RG09-S02: Sealed gold and blind review export.

Objective: Verified grammar rules and item references, secure gold mapping, random reviewer IDs and adjudication policy.
Decisive acceptance condition: Reviewers cannot infer A/B/C from IDs or metadata; gold cannot be embedded in Generator or Solver input.
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
from app.experiment.blind_review import (
    AdjudicationOutcome,
    BlindReviewItem,
    BlindReviewManager,
    BlindReviewValidationError,
    GoldSmugglingForbiddenError,
    ReviewerVerdictSubmission,
    SealedGoldAccessForbiddenError,
    SealedGoldVault,
)


def _make_sample_generation_result(arm: str = "A") -> Tuple[ExperimentAssignment, GenerationResult]:
    assignment = ExperimentAssignment(
        assignment_id=f"item-101__arm_{arm}__att1",
        dataset_item_id="item-101",
        configuration_id=arm,  # type: ignore[arg-type]
        attempt_number=1,
    )

    neutral = NeutralOutput(
        context_text="Plant photoperiods regulate circadian rhythm and biomass accumulation in controlled facilities.",
        question_groups=[
            NeutralQuestionGroup(group_id="grp-1", question_ids=["q-1", "q-2"])
        ],
        questions=[
            NeutralQuestion(
                question_id="q-1",
                question_type=StandaloneGroupType.TFNG,
                text="Circadian rhythms modulate plant biomass under LED arrays.",
                options=["TRUE", "FALSE", "NOT GIVEN"],
                instructions="Choose TRUE, FALSE, or NOT GIVEN.",
            ),
            NeutralQuestion(
                question_id="q-2",
                question_type=StandaloneGroupType.TFNG,
                text="Facilities never monitor photoperiod duration.",
                options=["TRUE", "FALSE", "NOT GIVEN"],
                instructions="Choose TRUE, FALSE, or NOT GIVEN.",
            ),
        ],
    )

    result = GenerationResult(
        run_id=f"run-{arm}-9999",
        dataset_item_id="item-101",
        configuration_id=arm,  # type: ignore[arg-type]
        task_type="READING_SINGLE_PASSAGE",
        execution_status=ExecutionStatus.COMPLETED,
        output_availability=OutputAvailability.NORMALIZED,
        generated_content=neutral,
        private_answer_ref="secret-answers-ref",
        trace_ref="trace-ref-internal",
    )

    return assignment, result


def test_pos_rg09_s02_blind_export_and_secrecy():
    """POS-RG09-S02: Blind review export completely strips arm/model/verdict traces; sealed vault stores key."""
    manager = BlindReviewManager()
    assignment, result = _make_sample_generation_result(arm="C")

    gold_answers = {"q-1": "TRUE", "q-2": "FALSE"}
    blind_item = manager.export_blind_review_item(
        assignment=assignment,
        generation_result=result,
        domain="READING",
        gold_answers=gold_answers,
    )

    # 1. Blind item has randomized ID with no trace of arm C or run_id
    assert blind_item.blind_item_id.startswith("rev-blind-")
    assert "arm_C" not in blind_item.blind_item_id
    assert "run-C" not in blind_item.blind_item_id
    assert blind_item.domain == "READING"
    assert len(blind_item.questions) == 2

    # 2. Questions are stripped of answer references
    for q in blind_item.questions:
        assert not hasattr(q, "answer")
        assert not hasattr(q, "gold")
        assert not hasattr(q, "reference_answer")

    # 3. Sealed gold vault stores mapping under HMAC-integrity protection
    vault = manager.vault
    root_hash = vault.seal_vault()
    assert len(root_hash) == 64

    # 4. Authorized auditor can unblind mapping
    mapping = vault.get_mapping(blind_item.blind_item_id, actor_role="EXPERIMENT_AUDITOR")
    assert mapping.actual_configuration_id == "C"
    assert mapping.actual_assignment_id == assignment.assignment_id
    assert mapping.gold_answer_key == gold_answers


def test_neg_rg09_s02_gold_smuggling_and_unauthorized_vault_access():
    """NEG-RG09-S02: Embedded gold in input raises GoldSmugglingForbiddenError; non-auditor cannot unblind."""
    manager = BlindReviewManager()

    # 1. Attempt gold smuggling into generator input
    smuggled_input = {
        "prompt": "Generate a reading passage and questions.",
        "task": {"domain": "reading"},
        "metadata": {
            "_gold_answer": "TRUE",  # FORBIDDEN EMBEDDED GOLD!
        },
    }

    with pytest.raises(GoldSmugglingForbiddenError) as exc_info:
        manager.assert_no_gold_in_input(smuggled_input, context_label="GeneratorInput")
    assert "_gold_answer" in str(exc_info.value)

    # Nested solver smuggling attempt
    solver_input = {
        "context": "Sample passage...",
        "questions": [{"id": "q1", "reference_answer": "Option A"}],  # FORBIDDEN!
    }
    with pytest.raises(GoldSmugglingForbiddenError):
        manager.assert_no_gold_in_input(solver_input, context_label="SolverInput")

    # 2. Attempt unauthorized unblinding by blind reviewer or student
    assignment, result = _make_sample_generation_result(arm="A")
    blind_item = manager.export_blind_review_item(
        assignment=assignment,
        generation_result=result,
        domain="READING",
        gold_answers={"q-1": "TRUE"},
    )

    with pytest.raises(SealedGoldAccessForbiddenError):
        manager.vault.get_mapping(blind_item.blind_item_id, actor_role="BLIND_REVIEWER")

    with pytest.raises(SealedGoldAccessForbiddenError):
        manager.vault.get_mapping(blind_item.blind_item_id, actor_role="RESEARCHER")


def test_edge_rg09_s02_adjudication_rules_and_duplicate_reviews():
    """EDGE-RG09-S02: Multi-reviewer consensus, split decision escalation, and duplicate review rejections."""
    manager = BlindReviewManager()
    assignment, result = _make_sample_generation_result(arm="B")
    blind_item = manager.export_blind_review_item(
        assignment=assignment,
        generation_result=result,
        domain="READING",
        gold_answers={"q-1": "TRUE"},
    )
    b_id = blind_item.blind_item_id

    # 1. Duplicate review from same reviewer rejected
    manager.submit_review(
        ReviewerVerdictSubmission(
            blind_item_id=b_id,
            reviewer_id="rev-01",
            verdict="PASS",
            confidence=0.95,
        )
    )

    with pytest.raises(BlindReviewValidationError):
        manager.submit_review(
            ReviewerVerdictSubmission(
                blind_item_id=b_id,
                reviewer_id="rev-01",  # DUPLICATE!
                verdict="FAIL",
                confidence=0.90,
            )
        )

    # 2. Unanimous consensus when second reviewer agrees
    manager.submit_review(
        ReviewerVerdictSubmission(
            blind_item_id=b_id,
            reviewer_id="rev-02",
            verdict="PASS",
            confidence=0.90,
        )
    )
    outcome_unanimous = manager.adjudicate_item(b_id)
    assert outcome_unanimous.unanimous is True
    assert outcome_unanimous.final_verdict == "PASS"

    # 3. Split decision between 2 reviewers requires escalation to adjudicator
    blind_item_split = manager.export_blind_review_item(
        assignment=assignment,
        generation_result=result,
        domain="READING",
        gold_answers={"q-1": "TRUE"},
    )
    s_id = blind_item_split.blind_item_id

    manager.submit_review(
        ReviewerVerdictSubmission(blind_item_id=s_id, reviewer_id="rev-01", verdict="PASS", confidence=0.85)
    )
    manager.submit_review(
        ReviewerVerdictSubmission(blind_item_id=s_id, reviewer_id="rev-02", verdict="FAIL", confidence=0.80)
    )

    outcome_split = manager.adjudicate_item(s_id)
    assert outcome_split.unanimous is False
    assert outcome_split.final_verdict == "ADJUDICATION_REQUIRED"

    # Adding third tie-breaking review produces majority outcome
    manager.submit_review(
        ReviewerVerdictSubmission(blind_item_id=s_id, reviewer_id="rev-03-expert", verdict="PASS", confidence=0.95)
    )
    outcome_majority = manager.adjudicate_item(s_id)
    assert outcome_majority.final_verdict == "PASS"
    assert "Majority PASS (2/3)" in outcome_majority.adjudicator_notes


def test_reg_rg09_s02_missing_content_and_tampered_mapping():
    """REG-RG09-S02: Missing generated content rejected and sealed vault prevents modifications."""
    manager = BlindReviewManager()
    assignment = ExperimentAssignment(
        assignment_id="item-fail__arm_A__att1",
        dataset_item_id="item-fail",
        configuration_id="A",
        attempt_number=1,
    )
    result_empty = GenerationResult(
        run_id="run-empty",
        dataset_item_id="item-fail",
        configuration_id="A",
        task_type="READING_SINGLE_PASSAGE",
        execution_status=ExecutionStatus.FAILED_RUNTIME,
        output_availability=OutputAvailability.NONE,
        generated_content=None,  # No content!
    )

    with pytest.raises(BlindReviewValidationError):
        manager.export_blind_review_item(
            assignment=assignment,
            generation_result=result_empty,
            domain="READING",
            gold_answers={},
        )

    # Sealed vault modification forbidden
    vault = SealedGoldVault()
    vault.seal_vault()
    with pytest.raises(RuntimeError):
        vault.store_mapping(
            blind_item_id="rev-1",
            assignment_id="asg-1",
            configuration_id="A",
            dataset_item_id="it-1",
            domain="READING",
            gold_answer_key={},
        )
