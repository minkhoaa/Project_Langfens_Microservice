"""Unit tests for RG04-S03: Calibrate Judge on Allowed Data."""

import pytest
from app.evaluators.calibration import (
    CALIBRATION_CORPUS,
    JUDGE_HOLDOUT_CORPUS,
    CalibrationAccessController,
    HoldoutAccessViolationError,
    measure_evaluator_reliability,
)
from app.evaluators.independent import NeutralEvaluator
from app.evaluators.rubric import RubricProfile


def test_pos_rg04_s03_fit_thresholds_on_calibration():
    """POS-RG04-S03: Frozen candidate chosen with documented error tradeoffs on CALIBRATION split."""
    rubric = RubricProfile(
        rubric_version="R1-2026.1",
        min_average_score=3.5,
        min_grounding_score=3.0,
        min_dimension_score=2.0,
    )
    evaluator = NeutralEvaluator(rubric=rubric)

    metrics = measure_evaluator_reliability(
        evaluator=evaluator,
        dataset=CALIBRATION_CORPUS,
        dataset_name="CALIBRATION",
    )

    # Invariants on calibration set:
    assert metrics.total_count == len(CALIBRATION_CORPUS)
    assert metrics.evaluable_count > 0
    assert metrics.coverage == 1.0
    # No false accept (FAR == 0.0)
    assert metrics.false_positive_count == 0
    assert metrics.far == 0.0


def test_neg_rg04_s03_tuning_cannot_read_holdout_data():
    """NEG-RG04-S03: No iterative tuning based on FINAL_EVAL or holdout outcomes."""
    controller = CalibrationAccessController(JUDGE_HOLDOUT_CORPUS)

    # Simulated tuning loop attempting to iterate over all candidate IDs
    candidate_ids = ["calib-tfng-01", "calib-mcq-01", "holdout-tfng-01"]
    read_attempts = []
    blocked_attempts = []

    for cid in candidate_ids:
        try:
            controller.assert_can_access_for_calibration(cid)
            read_attempts.append(cid)
        except HoldoutAccessViolationError:
            blocked_attempts.append(cid)

    assert read_attempts == ["calib-tfng-01", "calib-mcq-01"]
    assert blocked_attempts == ["holdout-tfng-01"]


def test_edge_rg04_s03_overly_strict_threshold_tradeoff():
    """EDGE-RG04-S03: Overly strict threshold increases false rejection rate (FRR)."""
    # Overly strict rubric (min_average=4.8) rejects valid items
    strict_rubric = RubricProfile(
        rubric_version="R1-strict",
        min_average_score=4.8,
        min_grounding_score=4.5,
        min_dimension_score=4.0,
    )
    strict_evaluator = NeutralEvaluator(rubric=strict_rubric)

    metrics_strict = measure_evaluator_reliability(
        evaluator=strict_evaluator,
        dataset=CALIBRATION_CORPUS,
        dataset_name="CALIBRATION_STRICT",
    )

    # Documented tradeoff: strict threshold produces false rejections
    assert metrics_strict.false_negative_count >= 1
    assert metrics_strict.frr > 0.0
