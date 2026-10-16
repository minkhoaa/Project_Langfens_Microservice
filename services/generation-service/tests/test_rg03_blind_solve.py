"""Unit tests for RG03-S03: Blind Solve and Answer Verification."""

import pytest
from pydantic import ValidationError
from app.contracts.solver import (
    AnswerVerificationView,
    BlindSolverResult,
    GoldReferenceView,
    SecurityLeakageError,
    SolverView,
)
from app.evaluators.independent import NeutralEvaluator
from app.evaluators.rubric import EvaluationVerdict
from app.solvers.serializer import (
    project_to_answer_verification_view,
    project_to_gold_reference_view,
    project_to_solver_view,
)


PASSAGE_SAMPLE = (
    "The Antarctic ice sheet contains roughly 61 percent of all fresh water on Earth. "
    "Recent satellite observations indicate that portions of the West Antarctic Ice Sheet "
    "have not been gaining mass, but rather have been losing mass at an accelerated rate."
)

CONTRADICTING_QUESTION = {
    "question_number": 1,
    "question_type": "TFNG",
    "prompt": "Portions of the West Antarctic Ice Sheet have been gaining mass.",
    "answer": "TRUE",  # Contradicts the passage which says "have not been gaining mass"!
    "evidence_quote": "Recent satellite observations indicate that portions of the West Antarctic Ice Sheet have not been gaining mass",
}


def test_pos_rg03_s03_contradiction_and_leakage_detected():
    """POS-RG03-S03: Leakage canaries and TFNG/NOT GIVEN contradictions detected."""
    evaluator = NeutralEvaluator()

    # Case 1: Proposed TRUE contradicts explicit negative passage text
    result_contra = evaluator.evaluate_item(
        dataset_item_id="item-contradiction",
        passage_text=PASSAGE_SAMPLE,
        question_data=CONTRADICTING_QUESTION,
    )
    assert result_contra.verdict == EvaluationVerdict.FAIL
    assert result_contra.task_validity["no_contradiction"] is False
    assert "contradiction" in result_contra.abstention_reason.lower()

    # Case 2: Proposed NOT GIVEN when passage explicitly entails the statement
    not_given_contradiction = {
        "question_number": 2,
        "question_type": "TFNG",
        "prompt": "The Antarctic ice sheet contains roughly 61 percent of all fresh water on Earth.",
        "answer": "NOT GIVEN",  # Contradicts the passage which explicitly gives this!
        "evidence_quote": "The Antarctic ice sheet contains roughly 61 percent of all fresh water on Earth.",
    }
    result_ng = evaluator.evaluate_item(
        dataset_item_id="item-not-given-contra",
        passage_text=PASSAGE_SAMPLE,
        question_data=not_given_contradiction,
    )
    assert result_ng.verdict == EvaluationVerdict.FAIL
    assert result_ng.task_validity["no_contradiction"] is False
    assert "not given contradiction" in result_ng.abstention_reason.lower()

def test_neg_rg03_s03_proposed_answer_canary_rejected_in_solver_view():
    """NEG-RG03-S03: Gold/proposed answer never enters SolverView through options or metadata."""
    # Attempt to inject answer canary or forbidden property into context or question text
    leaky_question = {
        "question_number": 1,
        "question_type": "TFNG",
        "text": "Normal statement text",
        "options": [
            {"key": "A", "text": "TRUE"},
            {"key": "B", "text": "FALSE"},
            {"key": "C", "text": "CANARY_SECRET_LEAK"},  # Canary in option text!
        ],
    }
    with pytest.raises((SecurityLeakageError, ValidationError)) as exc_info:
        project_to_solver_view(
            context_text="Normal passage context with no secrets",
            question_data=leaky_question,
        )
    assert "canary" in str(exc_info.value).lower()

def test_edge_rg03_s03_blind_result_and_gold_isolation():
    """EDGE-RG03-S03: Separate answer-free solve, then verify; GoldReferenceView is kept separate."""
    # 1. Blind solver produces solution without knowing generator proposed answer
    blind_res = BlindSolverResult(
        question_id="q1",
        proposed_solution="TRUE",
        reasoning_evidence="The text states roughly 61 percent of fresh water is in the ice sheet.",
        confidence=0.95,
    )

    # 2. AnswerVerificationView is constructed strictly after blind solve completes
    verification_view = project_to_answer_verification_view(
        blind_result=blind_res,
        generator_proposed_answer="TRUE",
        source_evidence_ref="The Antarctic ice sheet contains roughly 61 percent...",
        acceptable_variants=["true", "T"],
    )
    assert verification_view.generator_proposed_answer == "TRUE"
    assert verification_view.blind_result.proposed_solution == "TRUE"

    # 3. GoldReferenceView is constructed independently for research comparison only
    gold_view = project_to_gold_reference_view(
        item_id="item-q1",
        expert_label="TRUE",
        label_version="expert-v1",
        adjudicator_id="adj-42",
    )
    assert gold_view.expert_label == "TRUE"
    # Verify gold view is never mixed into verification view
    assert not hasattr(verification_view, "expert_label")
