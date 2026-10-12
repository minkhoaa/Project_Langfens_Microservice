"""Phase-14 Offline Evaluation Runner for Paired Benchmark Execution.

Dispatches benchmark runs across frozen datasets without manual authorization blocks.
Supports:
  - Deterministic simulated benchmark evaluation
  - Live ProviderGateway invocation (e.g. MiniMax / Qwen / Mock)
  - Producing canonical PairedComparisonReport and writing artifacts
"""
from __future__ import annotations

import json
import logging
import os
import uuid
from pathlib import Path
from typing import Any, Callable, Sequence

from app.offline_eval.comparison import (
    ItemEvalResult,
    PairedComparisonReport,
    PairedOfflineComparator,
)

logger = logging.getLogger(__name__)


class OfflineEvalRunner:
    """Orchestrates paired evaluation between baseline and candidate configurations."""

    def __init__(
        self,
        comparator: PairedOfflineComparator | None = None,
        artifact_dir: str | Path | None = None,
    ) -> None:
        self.comparator = comparator or PairedOfflineComparator()
        self.artifact_dir = Path(artifact_dir) if artifact_dir else Path("artifacts/offline_eval")
        self._reports: dict[str, PairedComparisonReport] = {}
    def run_paired_evaluation(
        self,
        *,
        benchmark_items: Sequence[dict[str, Any]],
        baseline_evaluator_fn: Callable[[dict[str, Any]], ItemEvalResult],
        candidate_evaluator_fn: Callable[[dict[str, Any]], ItemEvalResult],
        baseline_name: str = "baseline_v1",
        baseline_version: str = "v1.0.0",
        candidate_name: str = "candidate_v2",
        candidate_version: str = "v2.0.0",
        benchmark_dataset_id: str = "benchmark_phase14_frozen",
        benchmark_dataset_sha256: str = "",
        execution_profile: str = "frozen_corpus_canonical_evaluators",
        denominators: dict[str, int] | None = None,
        save_report: bool = True,
    ) -> PairedComparisonReport:
        report_id = f"eval_report_{uuid.uuid4().hex[:12]}"

        baseline_results: list[ItemEvalResult] = []
        candidate_results: list[ItemEvalResult] = []

        for item in benchmark_items:
            # Baseline execution
            b_res = baseline_evaluator_fn(item)
            baseline_results.append(b_res)

            # Candidate execution
            c_res = candidate_evaluator_fn(item)
            candidate_results.append(c_res)

        report = self.comparator.compare(
            report_id=report_id,
            baseline_results=baseline_results,
            candidate_results=candidate_results,
            baseline_name=baseline_name,
            baseline_version=baseline_version,
            candidate_name=candidate_name,
            candidate_version=candidate_version,
            benchmark_dataset_id=benchmark_dataset_id,
            benchmark_dataset_sha256=benchmark_dataset_sha256,
            execution_profile=execution_profile,
            denominators=denominators,
        )
        self._reports[report.report_id] = report
        if save_report:
            self._save_report(report)

        return report
    def _save_report(self, report: PairedComparisonReport) -> Path:
        self.artifact_dir.mkdir(parents=True, exist_ok=True)
        report_file = self.artifact_dir / f"{report.report_id}.json"
        with open(report_file, "w", encoding="utf-8") as f:
            f.write(report.to_canonical_json())
        logger.info("Saved paired comparison report to %s", report_file)
        return report_file

    def store_report(self, report: PairedComparisonReport) -> str:
        self._reports[report.report_id] = report
        return report.report_id

    def get_report(self, report_id: str) -> PairedComparisonReport | None:
        return self._reports.get(report_id)


def create_mock_evaluator(
    *,
    hard_pass_rate: float = 1.0,
    canary_pass_rate: float = 1.0,
    semantic_pass_rate: float = 0.98,
    ambiguity_pass_rate: float = 0.95,
    false_rejection_rate: float = 0.02,
) -> Callable[[dict[str, Any]], ItemEvalResult]:
    """Helper creating deterministic evaluators for testing comparison logic."""

    def _eval(item: dict[str, Any]) -> ItemEvalResult:
        item_id = str(item.get("id") or item.get("feedback_id") or "item")
        # Use item hash for deterministic pseudo-random evaluation
        item_hash = int(abs(hash(item_id))) % 1000 / 1000.0

        hard_pass = item_hash < hard_pass_rate
        is_canary = item.get("is_canary", False)
        canary_pass = (item_hash < canary_pass_rate) if is_canary else None

        semantic_pass = item_hash < semantic_pass_rate
        is_ambiguity_item = item.get("is_ambiguity_item", False)
        ambiguity_detected = (item_hash < ambiguity_pass_rate) if is_ambiguity_item else None

        false_rejected = item_hash < false_rejection_rate

        return ItemEvalResult(
            item_id=item_id,
            hard_invariants_pass=hard_pass,
            critical_canary_pass=canary_pass,
            semantic_pass=semantic_pass,
            ambiguity_detected=ambiguity_detected,
            false_rejected=false_rejected,
            score=0.95 if hard_pass else 0.40,
            details={"item_hash": item_hash},
        )

    return _eval
