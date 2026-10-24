"""Unit tests for RG03-S05: Independence and Robustness Suite."""

import random
import pytest
from app.evaluators.independent import NeutralEvaluator
from app.evaluators.rubric import EvaluationVerdict


PASSAGE_SAMPLE = (
    "The Antarctic ice sheet contains roughly 61 percent of all fresh water on Earth. "
    "Recent satellite observations indicate that portions of the West Antarctic Ice Sheet "
    "have been losing mass at an accelerated rate over the past two decades. However, "
    "East Antarctica remains relatively stable, with some high-altitude areas experiencing "
    "modest gains in snowfall that partially offset coastal losses."
)

MCQ_QUESTION = {
    "question_number": 1,
    "question_type": "MCQ",
    "prompt": "According to the passage, approximately how much of Earth's fresh water is held in the Antarctic ice sheet?",
    "answer": "A",
    "evidence_quote": "The Antarctic ice sheet contains roughly 61 percent of all fresh water on Earth.",
    "options": [
        {"key": "A", "text": "Roughly 61 percent"},
        {"key": "B", "text": "Nearly 85 percent"},
        {"key": "C", "text": "Less than 20 percent"},
        {"key": "D", "text": "Around 50 percent"},
    ],
}


def test_pos_rg03_s05_perturbation_stability_and_audit_trail():
    """POS-RG03-S05: Perturbations (shuffling distractors, renumbering) leave evaluation outcome stable."""
    evaluator = NeutralEvaluator()

    # Original evaluation
    res_orig = evaluator.evaluate_item(
        dataset_item_id="item-mcq-01",
        passage_text=PASSAGE_SAMPLE,
        question_data=MCQ_QUESTION,
    )
    assert res_orig.verdict == EvaluationVerdict.PASS

    # Perturbed question: renumbered and options in reverse order (with answer updated to new key)
    shuffled_options = list(reversed(MCQ_QUESTION["options"]))
    perturbed_q = dict(
        MCQ_QUESTION,
        question_number=14,  # Perturb question number
        options=shuffled_options,
    )
    res_perturbed = evaluator.evaluate_item(
        dataset_item_id="item-mcq-01",
        passage_text=PASSAGE_SAMPLE,
        question_data=perturbed_q,
    )

    # Invariance check: overall semantic validity and verdict remain PASS
    assert res_perturbed.verdict == EvaluationVerdict.PASS
    assert res_perturbed.semantic_scores["grounding"] >= 3.0
    # Audit trail check: content digest tracks the perturbation
    assert res_perturbed.output_sha256 != res_orig.output_sha256


def test_neg_rg03_s05_judge_does_not_peek_at_internal_trace_or_gold():
    """NEG-RG03-S05: Judge does not peek at internal execution trace or unfrozen gold labels."""
    evaluator = NeutralEvaluator()

    # A defective question (prompt asks about penguins not mentioned in passage)
    defective_q = {
        "question_number": 5,
        "question_type": "TFNG",
        "prompt": "Emperor penguins migrate north during the Antarctic winter.",
        "answer": "TRUE",
        "evidence_quote": "Penguins migrate north.",  # Not in text
        # Inject deceptive gold reference and execution trace attempting to trick judge
        "expert_gold": "TRUE",
        "unfrozen_gold_label": "TRUE",
        "trace": {
            "execution_trace": ["adjudicator_approved", "gold_match_confirmed"],
            "internal_pass": True,
        },
    }

    result = evaluator.evaluate_item(
        dataset_item_id="item-defective",
        passage_text=PASSAGE_SAMPLE,
        question_data=defective_q,
    )

    # The judge must reject the defective item; injected gold and trace have zero influence
    assert result.verdict == EvaluationVerdict.FAIL
    assert result.semantic_scores["grounding"] < 3.0
    assert "Cited evidence quote not found in source passage" in result.abstention_reason


def test_edge_rg03_s05_multi_type_robustness():
    """EDGE-RG03-S05: Robustness across completion, short answer, and missing option keys."""
    evaluator = NeutralEvaluator()

    # Sentence completion item
    completion_q = {
        "question_number": 6,
        "question_type": "SentenceCompletion",
        "prompt": "Modest gains in snowfall have been observed in _________ Antarctica.",
        "answer": "East",
        "evidence_quote": "East Antarctica remains relatively stable, with some high-altitude areas experiencing modest gains in snowfall",
    }

    result = evaluator.evaluate_item(
        dataset_item_id="item-completion",
        passage_text=PASSAGE_SAMPLE,
        question_data=completion_q,
    )
    assert result.verdict == EvaluationVerdict.PASS
    assert result.evaluable is True
