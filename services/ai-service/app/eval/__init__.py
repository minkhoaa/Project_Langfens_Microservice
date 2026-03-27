# AI Evaluation Harness
#
# This module provides tools for evaluating AI grading quality using a golden dataset
# of essays with known band scores.

from app.eval.golden_dataset import GOLDEN_DATASET, GoldenEssay
from app.eval.metrics import EvalResult, compute_metrics

__all__ = [
    "GOLDEN_DATASET",
    "GoldenEssay",
    "EvalResult",
    "compute_metrics",
]
