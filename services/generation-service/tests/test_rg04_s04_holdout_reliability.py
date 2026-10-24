"""Unit tests for RG04-S04: One-Time Holdout Reliability Measurement."""

import pytest
from app.evaluators.calibration import (
    BenchmarkStratum,
    CalibrationItem,
    JUDGE_HOLDOUT_CORPUS,
    measure_evaluator_reliability,
)
from app.evaluators.independent import NeutralEvaluator
from app.evaluators.rubric import EvaluationVerdict, RubricProfile


def test_pos_rg04_s04_holdout_reliability_measurement():
    """POS-RG04-S04: Measure decided FAR/FRR, abstention/coverage, confusion by type, intervals and raw counts."""
    evaluator = NeutralEvaluator(rubric=RubricProfile())

    metrics = measure_evaluator_reliability(
        evaluator=evaluator,
        dataset=JUDGE_HOLDOUT_CORPUS,
        dataset_name="JUDGE_HOLDOUT",
    )
    assert metrics.total_count == len(JUDGE_HOLDOUT_CORPUS)
    assert metrics.evaluable_count == 5
    assert metrics.coverage == 1.0
    # Transparent error accounting: 1 false accept (holdout-tfng-02) observed -> FAR = 0.5
    assert metrics.false_positive_count == 1
    assert metrics.far == 0.5
    assert metrics.false_negative_count == 0
    assert metrics.frr == 0.0
    assert metrics.accuracy_on_decided == 0.8

    # Verify confusion by question type is tracked with raw counts
    assert "TFNG" in metrics.confusion_by_type
    assert "MCQ" in metrics.confusion_by_type
    assert "SentenceCompletion" in metrics.confusion_by_type

    tfng_stats = metrics.confusion_by_type["TFNG"]
    assert tfng_stats["TP"] == 1
    assert tfng_stats["FP"] == 1
    assert tfng_stats["TN"] == 0
    assert tfng_stats["FN"] == 0


def test_neg_rg04_s04_uncertain_not_counted_as_correct():
    """NEG-RG04-S04: UNCERTAIN not silently counted as correct or discarded."""
    evaluator = NeutralEvaluator()

    # Synthetic item where passage is empty/missing causing evaluability failure
    dataset_with_uncertain = [
        CalibrationItem(
            item_id="holdout-missing-data",
            source_family_id="fam-missing",
            domain="reading",
            question_type="TFNG",
            stratum=BenchmarkStratum.AMBIGUITY,
            passage_text="Short text but valid length for model instantiation here.",
            question_data={"prompt": "", "answer": "TRUE"},  # Missing prompt triggers failure
            reference_verdict=EvaluationVerdict.FAIL,
            reference_rationale="Unparseable prompt",
        )
    ]

    metrics = measure_evaluator_reliability(evaluator, dataset_with_uncertain)

    # UNCERTAIN or un-evaluable item must NOT increment true_positive_count!
    assert metrics.true_positive_count == 0
    assert metrics.abstention_count >= 1


def test_edge_rg04_s04_zero_division_guard():
    """EDGE-RG04-S04: Empty dataset handled gracefully with zero division protection."""
    evaluator = NeutralEvaluator()
    empty_metrics = measure_evaluator_reliability(evaluator, [], dataset_name="EMPTY")
    assert empty_metrics.total_count == 0
    assert empty_metrics.far == 0.0
    assert empty_metrics.frr == 0.0
    assert empty_metrics.coverage == 0.0
