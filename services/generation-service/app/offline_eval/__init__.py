"""Offline evaluation package for Phase 14 paired benchmarking and regression detection."""

from app.offline_eval.comparison import (
    AMBIGUITY_RECALL_THRESHOLD,
    CRITICAL_CANARIES_THRESHOLD,
    FALSE_REJECTION_MAX_THRESHOLD,
    HARD_INVARIANTS_THRESHOLD,
    SEMANTIC_RECALL_THRESHOLD,
    ConfigMetrics,
    GateVerdict,
    ItemEvalResult,
    MetricDelta,
    PairedComparisonReport,
    PairedOfflineComparator,
    compute_config_metrics,
)
from app.offline_eval.runner import OfflineEvalRunner, create_mock_evaluator

__all__ = [
    "AMBIGUITY_RECALL_THRESHOLD",
    "CRITICAL_CANARIES_THRESHOLD",
    "FALSE_REJECTION_MAX_THRESHOLD",
    "HARD_INVARIANTS_THRESHOLD",
    "SEMANTIC_RECALL_THRESHOLD",
    "ConfigMetrics",
    "GateVerdict",
    "ItemEvalResult",
    "MetricDelta",
    "PairedComparisonReport",
    "PairedOfflineComparator",
    "compute_config_metrics",
    "OfflineEvalRunner",
    "create_mock_evaluator",
]
