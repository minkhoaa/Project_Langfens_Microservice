"""Unit tests for RG03-S02: Neutral Post-Generation Evaluator."""

import pytest
from app.evaluators.independent import NeutralEvaluator, strip_internal_arm_metadata
from app.evaluators.rubric import EvaluationVerdict


PASSAGE_SAMPLE = (
    "The Antarctic ice sheet contains roughly 61 percent of all fresh water on Earth. "
    "Recent satellite observations indicate that portions of the West Antarctic Ice Sheet "
    "have been losing mass at an accelerated rate over the past two decades. However, "
    "East Antarctica remains relatively stable, with some high-altitude areas experiencing "
    "modest gains in snowfall that partially offset coastal losses."
)

VALID_TFNG_QUESTION = {
    "question_number": 1,
    "question_type": "TFNG",
    "prompt": "The Antarctic ice sheet holds the majority of the world's fresh water.",
    "answer": "TRUE",
    "evidence_quote": "The Antarctic ice sheet contains roughly 61 percent of all fresh water on Earth.",
}

UNGROUNDED_QUESTION = {
    "question_number": 2,
    "question_type": "TFNG",
    "prompt": "Commercial mining operations in Antarctica were banned in 1991.",
    "answer": "TRUE",
    "evidence_quote": "Mining operations were banned in 1991 by international treaty.",  # Fabricated quote not in text!
}


def test_pos_rg03_s02_config_permutation_invariance():
    """POS-RG03-S02: Config-label permutation leaves identical scoring input and result unchanged."""
    evaluator = NeutralEvaluator()

    # Score with arm A, arm B, arm C, and no arm label
    res_a = evaluator.evaluate_item(
        dataset_item_id="item-001",
        passage_text=PASSAGE_SAMPLE,
        question_data=dict(VALID_TFNG_QUESTION, configuration_id="A", arm="arm_a"),
    )
    res_b = evaluator.evaluate_item(
        dataset_item_id="item-001",
        passage_text=PASSAGE_SAMPLE,
        question_data=dict(VALID_TFNG_QUESTION, configuration_id="B", arm="arm_b"),
    )
    res_c = evaluator.evaluate_item(
        dataset_item_id="item-001",
        passage_text=PASSAGE_SAMPLE,
        question_data=dict(VALID_TFNG_QUESTION, configuration_id="C", arm="arm_c"),
    )
    res_none = evaluator.evaluate_item(
        dataset_item_id="item-001",
        passage_text=PASSAGE_SAMPLE,
        question_data=VALID_TFNG_QUESTION,
    )

    # Invariance check: verdicts and scores must be identical across all configurations
    assert res_a.verdict == res_b.verdict == res_c.verdict == res_none.verdict == EvaluationVerdict.PASS
    assert res_a.semantic_scores == res_b.semantic_scores == res_c.semantic_scores == res_none.semantic_scores
    assert res_a.hard_checks == res_b.hard_checks == res_c.hard_checks == res_none.hard_checks
    assert res_a.task_validity == res_b.task_validity == res_c.task_validity == res_none.task_validity


def test_neg_rg03_s02_in_loop_pass_shortcut_prohibited():
    """NEG-RG03-S02: No scoring shortcut from C internal accepted flag.

    Internal flags (is_accepted=True, in_loop_pass=True, generator_verdict='PASS') cannot override evaluation failure.
    """
    evaluator = NeutralEvaluator()

    # Question is ungrounded (missing quote in text), but marked with deceptive internal accept flags
    deceptive_question = dict(
        UNGROUNDED_QUESTION,
        is_accepted=True,
        in_loop_pass=True,
        generator_verdict="PASS",
        status="PASS",
        configuration_id="C",
    )

    result = evaluator.evaluate_item(
        dataset_item_id="item-002",
        passage_text=PASSAGE_SAMPLE,
        question_data=deceptive_question,
    )

    # Must fail because grounding is defective; internal PASS flag is completely ignored
    assert result.verdict == EvaluationVerdict.FAIL
    assert result.semantic_scores["grounding"] < 3.0
    assert "Cited evidence quote not found in source passage" in result.abstention_reason


def test_edge_rg03_s02_metadata_stripping_robustness():
    """EDGE-RG03-S02: Deeply nested arm metadata and execution traces are safely removed."""
    dirty_payload = {
        "question_number": 3,
        "question_type": "TFNG",
        "prompt": "Test statement",
        "metadata": {
            "configuration_id": "A",
            "trace": {"execution_trace": ["call_1", "call_2"]},
            "trial": 1,
            "seed": 42,
        },
        "nested_items": [
            {"arm": "A", "text": "item 1"},
            {"is_accepted": True, "text": "item 2"},
        ],
    }

    clean = strip_internal_arm_metadata(dirty_payload)
    assert "configuration_id" not in clean.get("metadata", {})
    assert "trace" not in clean.get("metadata", {})
    assert clean["nested_items"][0] == {"text": "item 1"}
    assert clean["nested_items"][1] == {"text": "item 2"}
