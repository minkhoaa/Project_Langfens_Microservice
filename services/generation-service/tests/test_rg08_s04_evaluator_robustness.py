"""Unit and integration test suite for RG08-S04: Evaluator robustness and resource drift.

Invariants:
- Check evaluator reproducibility, output-order bias, model usage/cost uncertainty and scoring drift.
- Drift measured and pre-final adjustments strictly confined to DEV/CALIBRATION.
- No post-hoc judge changes using sealed benchmark performance (fails closed with SealedBenchmarkPostHocTuningForbiddenError).
- Touched API/schema/authorization or strict Reading V2 regression remain intact.
"""

from __future__ import annotations

import pytest

from app.evaluators.independent import NeutralEvaluator
from app.experiment.drift import (
    EvaluatorNonReproducibleError,
    EvaluatorRobustnessAnalyzer,
    EvaluatorRobustnessMetrics,
    SealedBenchmarkPostHocTuningForbiddenError,
)


@pytest.fixture
def sample_question_data() -> dict:
    return {
        "question_id": "q-robust-01",
        "question_number": 1,
        "question_type": "TrueFalseNotGiven",
        "question_text": "Volcanic calderas are formed exclusively by gentle basaltic lava flows.",
        "correct_answer": "FALSE",
        "options": ["TRUE", "FALSE", "NOT GIVEN"],
    }


@pytest.fixture
def sample_passage_text() -> str:
    return (
        "Supervolcanoes generate immense explosive calderas through catastrophic eruptions of rhyolitic melt, "
        "contrasting sharply with the gentle shield volcanoes formed by fluid basaltic flows. "
        * 10
    )


def test_pos_rg08_s04_drift_measured_and_tuning_confined_to_dev(
    sample_passage_text: str,
    sample_question_data: dict,
) -> None:
    """POS-RG08-S04: Drift measured and pre-final adjustments confined to DEV.

    Evidence identifies input fixture/source and observed output.
    """
    evaluator = NeutralEvaluator()
    analyzer = EvaluatorRobustnessAnalyzer(evaluator=evaluator)

    # 1. Reproducibility measurement (5 runs on identical inputs)
    reproducibility = analyzer.measure_reproducibility(
        dataset_item_id="item-robust-01",
        passage_text=sample_passage_text,
        question_data=sample_question_data,
        runs=5,
    )
    assert reproducibility == 1.0  # Perfect determinism

    # 2. Permutation invariance (order permutation should not flip verdicts)
    questions = [
        sample_question_data,
        {
            **sample_question_data,
            "question_id": "q-robust-02",
            "question_number": 2,
            "question_text": "Rhyolitic melt is characteristic of supervolcano magma chambers.",
            "correct_answer": "TRUE",
        },
    ]
    perm_invariance = analyzer.measure_order_permutation_invariance(
        dataset_item_id="item-robust-01",
        passage_text=sample_passage_text,
        questions=questions,
    )
    assert perm_invariance == 1.0

    # 3. Resource drift and cost uncertainty measurement
    usage_samples = [
        {"tokens": 1200, "cost_usd": 0.012, "confidence": "EXACT"},
        {"tokens": 1250, "cost_usd": 0.0125, "confidence": "EXACT"},
        {"tokens": 1180, "cost_usd": 0.0118, "confidence": "EXACT"},
    ]
    drift_metrics = analyzer.track_resource_drift(usage_samples)
    assert drift_metrics["mean_tokens"] > 0
    assert drift_metrics["token_variance"] >= 0
    assert drift_metrics["cost_bounds"][0] <= drift_metrics["cost_bounds"][1]
    assert drift_metrics["confidence_breakdown"]["EXACT"] == 3

    # 4. Pre-final adjustments confined to DEV succeed
    tuning_applied = analyzer.apply_pre_final_calibration(
        split="DEV",
        target_thresholds={"clarity_min": 0.75, "grounding_min": 0.80},
    )
    assert tuning_applied is True


def test_neg_rg08_s04_no_post_hoc_judge_changes_using_sealed_benchmark() -> None:
    """NEG-RG08-S04: No post-hoc judge changes using sealed benchmark performance.

    Verify safe rejection/abstention/blocked outcome rather than ignored or synthetic PASS.
    """
    evaluator = NeutralEvaluator()
    analyzer = EvaluatorRobustnessAnalyzer(evaluator=evaluator)

    # Attempting to tune judge using FINAL_EVAL split must fail closed
    with pytest.raises(
        SealedBenchmarkPostHocTuningForbiddenError,
        match="SEALED_BENCHMARK_TUNING_FORBIDDEN",
    ):
        analyzer.apply_pre_final_calibration(
            split="FINAL_EVAL",
            target_thresholds={"clarity_min": 0.85},
        )

    # Attempting to tune judge using SEALED_BENCHMARK or JUDGE_HOLDOUT also fails closed
    with pytest.raises(SealedBenchmarkPostHocTuningForbiddenError):
        analyzer.apply_pre_final_calibration(
            split="SEALED_BENCHMARK",
            target_thresholds={"grounding_min": 0.90},
        )
    with pytest.raises(SealedBenchmarkPostHocTuningForbiddenError):
        analyzer.apply_pre_final_calibration(
            split="JUDGE_HOLDOUT",
            target_thresholds={"grounding_min": 0.90},
        )


def test_edge_rg08_s04_empty_usage_and_unknown_telemetry_handling() -> None:
    """EDGE-RG08-S04: Test empty usage samples and UNKNOWN telemetry tracking without division by zero."""
    evaluator = NeutralEvaluator()
    analyzer = EvaluatorRobustnessAnalyzer(evaluator=evaluator)

    # Empty usage samples handled safely
    empty_drift = analyzer.track_resource_drift([])
    assert empty_drift["mean_tokens"] == 0.0
    assert empty_drift["token_variance"] == 0.0
    assert empty_drift["cost_bounds"] == (0.0, 0.0)

    # Telemetry with UNKNOWN confidence recorded explicitly without synthetic zeroing
    mixed_samples = [
        {"tokens": 1500, "cost_usd": 0.015, "confidence": "EXACT"},
        {"tokens": 0, "cost_usd": 0.0, "confidence": "UNKNOWN"},
    ]
    mixed_drift = analyzer.track_resource_drift(mixed_samples)
    assert mixed_drift["confidence_breakdown"]["UNKNOWN"] == 1
    assert mixed_drift["confidence_breakdown"]["EXACT"] == 1


def test_reg_rg08_s04_evaluator_rubric_remains_canonical() -> None:
    """REG-RG08-S04: Canonical rubric profile and independent evaluator invariants remain unchanged."""
    evaluator = NeutralEvaluator()
    assert evaluator.rubric is not None
    assert evaluator.evaluator_version == "neutral-eval-v2.0"
