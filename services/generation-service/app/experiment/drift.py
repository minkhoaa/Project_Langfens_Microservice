"""Evaluator robustness, order-permutation invariance, and resource drift tracking (RG08-S04).

Invariants:
- Check evaluator reproducibility, output-order bias, model usage/cost uncertainty, and scoring drift.
- Drift measured and pre-final adjustments strictly confined to DEV or CALIBRATION splits.
- No post-hoc judge changes using sealed benchmark performance (fails closed with SealedBenchmarkPostHocTuningForbiddenError).
- Evaluator determinism and canonical rubric invariants remain preserved.
"""

from __future__ import annotations

import statistics
from typing import Any, Dict, List, Literal, Optional, Tuple

from pydantic import Field

from app.contracts.base import CanonicalBaseModel
from app.evaluators.independent import NeutralEvaluator


class SealedBenchmarkPostHocTuningForbiddenError(RuntimeError):
    """Raised when an attempt is made to calibrate or adjust evaluator parameters using sealed benchmark data."""


class EvaluatorNonReproducibleError(RuntimeError):
    """Raised when repeated evaluation runs produce non-deterministic or divergent verdicts."""


FORBIDDEN_TUNING_SPLITS = {"FINAL_EVAL", "SEALED_BENCHMARK", "FINAL", "SEALED", "JUDGE_HOLDOUT"}
ALLOWED_TUNING_SPLITS = {"DEV", "CALIBRATION"}


class EvaluatorRobustnessMetrics(CanonicalBaseModel):
    """Metrics tracking evaluator robustness, determinism, and resource uncertainty."""

    reproducibility: float = Field(default=1.0, ge=0.0, le=1.0)
    order_permutation_invariance: float = Field(default=1.0, ge=0.0, le=1.0)
    mean_tokens: float = Field(default=0.0, ge=0.0)
    token_variance: float = Field(default=0.0, ge=0.0)
    cost_bounds: Tuple[float, float] = (0.0, 0.0)
    confidence_breakdown: Dict[str, int] = Field(default_factory=dict)


class EvaluatorRobustnessAnalyzer:
    """Measures evaluator reproducibility, permutation bias, resource uncertainty, and enforces tuning boundaries."""

    def __init__(self, evaluator: Optional[NeutralEvaluator] = None) -> None:
        self.evaluator = evaluator or NeutralEvaluator()
        self._calibrated_thresholds: Dict[str, float] = {}

    def measure_reproducibility(
        self,
        dataset_item_id: str,
        passage_text: str,
        question_data: Dict[str, Any],
        runs: int = 5,
    ) -> float:
        """Evaluates identical question payload multiple times to verify 100% determinism.

        Fails closed with EvaluatorNonReproducibleError if verdicts diverge across identical runs.
        """
        if runs < 2:
            return 1.0

        verdicts: List[str] = []
        for _ in range(runs):
            eval_res = self.evaluator.evaluate_item(
                dataset_item_id=dataset_item_id,
                passage_text=passage_text,
                question_data=question_data,
            )
            verdict_val = (
                eval_res.verdict.value
                if hasattr(eval_res.verdict, "value")
                else str(eval_res.verdict)
            )
            verdicts.append(verdict_val)

        if len(set(verdicts)) > 1:
            raise EvaluatorNonReproducibleError(
                f"EVALUATOR_NON_REPRODUCIBLE: Divergent verdicts observed across {runs} identical runs: {verdicts}"
            )

        return 1.0

    def measure_order_permutation_invariance(
        self,
        dataset_item_id: str,
        passage_text: str,
        questions: List[Dict[str, Any]],
    ) -> float:
        """Evaluates items in original order versus permuted (reversed) order to check for order bias."""
        if not questions:
            return 1.0

        # Evaluate in original order
        original_verdicts: List[str] = []
        for q in questions:
            res = self.evaluator.evaluate_item(
                dataset_item_id=dataset_item_id,
                passage_text=passage_text,
                question_data=q,
            )
            verdict_val = (
                res.verdict.value if hasattr(res.verdict, "value") else str(res.verdict)
            )
            original_verdicts.append(verdict_val)

        # Evaluate in reversed order
        reversed_questions = list(reversed(questions))
        reversed_verdicts: List[str] = []
        for q in reversed_questions:
            res = self.evaluator.evaluate_item(
                dataset_item_id=dataset_item_id,
                passage_text=passage_text,
                question_data=q,
            )
            verdict_val = (
                res.verdict.value if hasattr(res.verdict, "value") else str(res.verdict)
            )
            reversed_verdicts.append(verdict_val)

        # Check that reversing order does not flip individual item verdicts
        expected_reversed = list(reversed(original_verdicts))
        matching_count = sum(
            1 for o, r in zip(expected_reversed, reversed_verdicts) if o == r
        )
        return matching_count / len(questions)

    def track_resource_drift(
        self, usage_samples: List[Dict[str, Any]]
    ) -> Dict[str, Any]:
        """Calculates token usage variance, cost uncertainty bounds, and confidence tiers across runs."""
        if not usage_samples:
            return {
                "mean_tokens": 0.0,
                "token_variance": 0.0,
                "cost_bounds": (0.0, 0.0),
                "confidence_breakdown": {},
            }

        tokens = [float(s.get("tokens", 0)) for s in usage_samples]
        costs = [float(s.get("cost_usd", 0.0)) for s in usage_samples]
        mean_tokens = statistics.mean(tokens)
        token_variance = statistics.variance(tokens) if len(tokens) > 1 else 0.0
        cost_bounds = (min(costs), max(costs))

        confidence_breakdown: Dict[str, int] = {}
        for s in usage_samples:
            conf = str(s.get("confidence", "EXACT"))
            confidence_breakdown[conf] = confidence_breakdown.get(conf, 0) + 1

        return {
            "mean_tokens": round(mean_tokens, 2),
            "token_variance": round(token_variance, 4),
            "cost_bounds": cost_bounds,
            "confidence_breakdown": confidence_breakdown,
        }

    def apply_pre_final_calibration(
        self, split: str, target_thresholds: Dict[str, float]
    ) -> bool:
        """Applies calibration adjustments to thresholds, strictly enforcing that they are confined to DEV/CALIBRATION.

        Fails closed with SealedBenchmarkPostHocTuningForbiddenError if final benchmark or holdout data is referenced.
        """
        normalized_split = split.upper().strip()
        if (
            normalized_split in FORBIDDEN_TUNING_SPLITS
            or "FINAL" in normalized_split
            or "SEALED" in normalized_split
            or "HOLDOUT" in normalized_split
        ):
            raise SealedBenchmarkPostHocTuningForbiddenError(
                f"SEALED_BENCHMARK_TUNING_FORBIDDEN: Evaluator tuning or threshold adjustments strictly forbidden "
                f"using sealed benchmark or holdout data (requested split: {split}). "
                "Pre-final adjustments must be confined to DEV or CALIBRATION splits."
            )

        if normalized_split not in ALLOWED_TUNING_SPLITS:
            raise ValueError(
                f"Invalid split for calibration: {split}. Allowed: {sorted(ALLOWED_TUNING_SPLITS)}"
            )

        self._calibrated_thresholds.update(target_thresholds)
        return True
