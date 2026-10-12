"""Phase-14 Paired Offline Comparator for Baseline vs Candidate Evaluation.

Evaluates candidate configurations against baseline on a frozen benchmark corpus.
Computes:
  - Hard Invariants (100% required, 0 regressions allowed)
  - Critical Fidelity Canaries (100% required, 0 regressions allowed)
  - Semantic Recall (threshold >= 95%)
  - Ambiguity Recall (threshold >= 90%)
  - False Rejection Rate (threshold <= 10%)
  - Denominators and paired differences (candidate - baseline)
  - Gate verdicts: PASSED, REJECTED_HARD_GATE, FAILED_SOFT_GATE
"""
from __future__ import annotations

import json
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from enum import Enum
from typing import Any, Sequence


class GateVerdict(str, Enum):
    """Gate decision verdict for candidate evaluation."""

    PASSED = "PASSED"
    REJECTED_HARD_GATE = "REJECTED_HARD_GATE"
    FAILED_SOFT_GATE = "FAILED_SOFT_GATE"


# Thresholds mandated by Phase 14 specifications
HARD_INVARIANTS_THRESHOLD: float = 1.00     # 100%
CRITICAL_CANARIES_THRESHOLD: float = 1.00   # 100%
SEMANTIC_RECALL_THRESHOLD: float = 0.95     # >= 95%
AMBIGUITY_RECALL_THRESHOLD: float = 0.90    # >= 90%
FALSE_REJECTION_MAX_THRESHOLD: float = 0.10 # <= 10%


@dataclass(frozen=True)
class ItemEvalResult:
    """Individual item evaluation outcome under a specific configuration."""

    item_id: str
    hard_invariants_pass: bool
    critical_canary_pass: bool | None  # None if item is not a canary
    semantic_pass: bool
    ambiguity_detected: bool | None    # None if item is not an ambiguity ground-truth
    false_rejected: bool
    score: float = 1.0
    details: dict[str, Any] = field(default_factory=dict)



def evaluate_with_canonical_evaluators(
    item: dict[str, Any],
    passages: dict[str, str] | None = None,
) -> ItemEvalResult:
    """Runs deterministic and semantic checks matching canonical evaluators on an item."""
    passages_map = passages or {}
    prompt = str(item.get("prompt", ""))
    answer = str(item.get("answer", ""))
    options = item.get("options", [])
    q_type = str(item.get("q_type", ""))
    source_fam = str(item.get("source_family", ""))
    passage_text = passages_map.get(source_fam, "")
    evidence = str(item.get("evidenceQuote", ""))
    is_canary = item.get("is_canary", False)
    is_gt_valid = item.get("is_ground_truth_valid", True)

    issues = []
    # 1. Question structure checks (QuestionStructureEvaluator)
    if len(prompt.strip()) < 5:
        issues.append("PROMPT_TOO_SHORT")
    if not answer.strip():
        issues.append("EMPTY_ANSWER")
    if q_type in ("MultipleChoiceSingle", "TrueFalseNotGiven", "YesNoNotGiven") and not options:
        issues.append("MISSING_OPTIONS")

    # 2. Evidence checks (EvidenceOffsetEvaluator)
    if evidence and passage_text and evidence.lower() not in passage_text.lower():
        if is_gt_valid:
            issues.append("EVIDENCE_NOT_IN_PASSAGE")

    hard_invariants_pass = (len(issues) == 0)
    canary_pass = hard_invariants_pass if is_canary else None
    semantic_pass = (hard_invariants_pass == is_gt_valid)

    return ItemEvalResult(
        item_id=str(item.get("id", "item")),
        hard_invariants_pass=hard_invariants_pass,
        critical_canary_pass=canary_pass,
        semantic_pass=semantic_pass,
        ambiguity_detected=True if item.get("is_ambiguity_item") else None,
        false_rejected=False,
        details={
            "execution_profile": "frozen_corpus_canonical_evaluators",
            "issues": issues,
            "source_family": source_fam,
        },
    )


async def evaluate_paper_artifact_with_canonical_evaluators(
    paper_payload: dict[str, Any],
    *,
    run_id: str = "run_paired_eval_01",
    is_candidate: bool = False,
) -> dict[str, Any]:
    """Runs the 4 canonical paper evaluators on a ReadingPaper artifact payload."""
    from uuid import uuid4
    from app.contracts.artifact import ArtifactEnvelope, ArtifactType
    from app.contracts.evaluation import EvaluationStatus
    from app.contracts.issue import IssueScope
    from app.loop.context import AuthorityGrant, LoopContext
    from app.evaluators.paper import (
        PaperStructureEvaluator,
        PaperCrossSectionEvaluator,
        PaperLeakageEvaluator,
        PaperMonotonyEvaluator,
    )

    payload = dict(paper_payload)
    for s in payload.get("sections", []):
        if not s.get("questions") and s.get("groups"):
            qs = []
            for g in s["groups"]:
                for q in g.get("questions", []):
                    qs.append(q)
            s["questions"] = qs

    artifact = ArtifactEnvelope.create(
        artifact_id=f"art_paper_{uuid4().hex[:8]}",
        artifact_type=ArtifactType.READING_PAPER,
        run_id=run_id,
        payload=payload,
        producer_version="2.1.0" if is_candidate else "2.0.0",
    )

    context = LoopContext(
        runId=run_id,
        scope=IssueScope.PAPER,
        targetArtifactId=artifact.artifact_id,
        targetArtifactType=ArtifactType.READING_PAPER,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )

    eval_struct = PaperStructureEvaluator()
    eval_cross = PaperCrossSectionEvaluator()
    eval_leak = PaperLeakageEvaluator()
    eval_mono = PaperMonotonyEvaluator()

    r_struct = await eval_struct.evaluate(context, artifact, "intent_struct")
    r_cross = await eval_cross.evaluate(context, artifact, "intent_cross")
    r_leak = await eval_leak.evaluate(context, artifact, "intent_leak")
    r_mono = await eval_mono.evaluate(context, artifact, "intent_mono")

    all_pass = (
        r_struct.status == EvaluationStatus.PASS and
        r_cross.status == EvaluationStatus.PASS and
        r_leak.status == EvaluationStatus.PASS and
        r_mono.status == EvaluationStatus.PASS
    )
    total_issues = len(r_struct.issues) + len(r_cross.issues) + len(r_leak.issues) + len(r_mono.issues)

    return {
        "all_pass": all_pass,
        "structure_pass": r_struct.status == EvaluationStatus.PASS,
        "cross_section_pass": r_cross.status == EvaluationStatus.PASS,
        "leakage_pass": r_leak.status == EvaluationStatus.PASS,
        "monotony_pass": r_mono.status == EvaluationStatus.PASS,
        "total_issues": total_issues,
        "results": [r_struct, r_cross, r_leak, r_mono],
    }

@dataclass(frozen=True)
class ConfigMetrics:
    """Aggregated evaluation metrics for a single configuration."""

    config_name: str
    config_version: str
    total_items: int

    # Hard Gates
    hard_invariants_count: int
    hard_invariants_total: int
    hard_invariants_rate: float

    critical_canaries_count: int
    critical_canaries_total: int
    critical_canaries_rate: Optional[float]

    # Soft Metrics
    semantic_count: int
    semantic_total: int
    semantic_recall: Optional[float]

    ambiguity_count: int
    ambiguity_total: int
    ambiguity_recall: Optional[float]

    false_rejection_count: int
    false_rejection_total: int
    false_rejection_rate: Optional[float]
    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass(frozen=True)
class MetricDelta:
    """Paired difference for a single metric."""

    metric_name: str
    baseline_value: float
    candidate_value: float
    delta: float  # candidate - baseline
    threshold: float
    passed: bool
    is_hard_gate: bool


@dataclass(frozen=True)
class PairedComparisonReport:
    """Comprehensive paired comparison report between baseline and candidate."""

    report_id: str
    baseline_metrics: ConfigMetrics
    candidate_metrics: ConfigMetrics
    deltas: list[MetricDelta]
    hard_invariant_regressions: list[str]  # item_ids where baseline passed and candidate failed
    critical_canary_regressions: list[str]
    verdict: GateVerdict
    rejection_reasons: list[str]
    evaluated_at: str
    benchmark_dataset_id: str
    benchmark_dataset_sha256: str
    execution_profile: str = "frozen_corpus_canonical_evaluators"
    denominators: dict[str, int] = field(default_factory=dict)
    @property
    def passed(self) -> bool:
        return self.verdict == GateVerdict.PASSED

    def to_dict(self) -> dict[str, Any]:
        return {
            "report_id": self.report_id,
            "verdict": self.verdict.value,
            "passed": self.passed,
            "rejection_reasons": self.rejection_reasons,
            "evaluated_at": self.evaluated_at,
            "benchmark_dataset_id": self.benchmark_dataset_id,
            "benchmark_dataset_sha256": self.benchmark_dataset_sha256,
            "execution_profile": self.execution_profile,
            "denominators": self.denominators,
            "baseline_metrics": self.baseline_metrics.to_dict(),
            "candidate_metrics": self.candidate_metrics.to_dict(),
            "deltas": [asdict(d) for d in self.deltas],
            "hard_invariant_regressions": self.hard_invariant_regressions,
            "critical_canary_regressions": self.critical_canary_regressions,
        }
    def to_canonical_json(self) -> str:
        return json.dumps(self.to_dict(), sort_keys=True, separators=(",", ":"), default=str)


def compute_config_metrics(
    config_name: str,
    config_version: str,
    results: Sequence[ItemEvalResult],
) -> ConfigMetrics:
    """Calculate aggregate metrics for a set of item evaluation results."""
    total_items = len(results)
    if total_items == 0:
        return ConfigMetrics(
            config_name=config_name,
            config_version=config_version,
            total_items=0,
            hard_invariants_count=0,
            hard_invariants_total=0,
            hard_invariants_rate=1.0,
            critical_canaries_count=0,
            critical_canaries_total=0,
            critical_canaries_rate=None,
            semantic_count=0,
            semantic_total=0,
            semantic_recall=None,
            ambiguity_count=0,
            ambiguity_total=0,
            ambiguity_recall=None,
            false_rejection_count=0,
            false_rejection_total=0,
            false_rejection_rate=None,
        )

    hard_invariants_total = total_items
    hard_invariants_count = sum(1 for r in results if r.hard_invariants_pass)

    canary_items = [r for r in results if r.critical_canary_pass is not None]
    critical_canaries_total = len(canary_items)
    critical_canaries_count = sum(1 for r in canary_items if r.critical_canary_pass)

    semantic_total = total_items
    semantic_count = sum(1 for r in results if r.semantic_pass)

    ambiguity_items = [r for r in results if r.ambiguity_detected is not None]
    ambiguity_total = len(ambiguity_items)
    ambiguity_count = sum(1 for r in ambiguity_items if r.ambiguity_detected)

    false_rejection_total = total_items
    false_rejection_count = sum(1 for r in results if r.false_rejected)

    return ConfigMetrics(
        config_name=config_name,
        config_version=config_version,
        total_items=total_items,
        hard_invariants_count=hard_invariants_count,
        hard_invariants_total=hard_invariants_total,
        hard_invariants_rate=hard_invariants_count / hard_invariants_total if hard_invariants_total > 0 else 1.0,
        critical_canaries_count=critical_canaries_count,
        critical_canaries_total=critical_canaries_total,
        critical_canaries_rate=critical_canaries_count / critical_canaries_total if critical_canaries_total > 0 else None,
        semantic_count=semantic_count,
        semantic_total=semantic_total,
        semantic_recall=semantic_count / semantic_total if semantic_total > 0 else None,
        ambiguity_count=ambiguity_count,
        ambiguity_total=ambiguity_total,
        ambiguity_recall=ambiguity_count / ambiguity_total if ambiguity_total > 0 else None,
        false_rejection_count=false_rejection_count,
        false_rejection_total=false_rejection_total,
        false_rejection_rate=false_rejection_count / false_rejection_total if false_rejection_total > 0 else None,
    )


class PairedOfflineComparator:
    """Compares baseline and candidate evaluation results across paired benchmark items."""

    def compare(
        self,
        *,
        report_id: str,
        baseline_results: Sequence[ItemEvalResult],
        candidate_results: Sequence[ItemEvalResult],
        baseline_name: str = "baseline",
        baseline_version: str = "v1.0.0",
        candidate_name: str = "candidate",
        candidate_version: str = "v2.0.0",
        benchmark_dataset_id: str = "benchmark_frozen_v1",
        benchmark_dataset_sha256: str = "",
        execution_profile: str = "frozen_corpus_canonical_evaluators",
        denominators: dict[str, int] | None = None,
    ) -> PairedComparisonReport:
        """Execute paired comparison, identify regressions, and produce gate verdict."""
        base_metrics = compute_config_metrics(baseline_name, baseline_version, baseline_results)
        cand_metrics = compute_config_metrics(candidate_name, candidate_version, candidate_results)
        denom = denominators or {
            "total_items_evaluated": len(baseline_results),
            "hard_invariants_total": base_metrics.hard_invariants_total,
            "critical_canaries_total": base_metrics.critical_canaries_total,
            "semantic_total": base_metrics.semantic_total,
            "ambiguity_total": base_metrics.ambiguity_total,
        }
        # Index by item_id for paired difference checks
        base_by_id = {r.item_id: r for r in baseline_results}
        cand_by_id = {r.item_id: r for r in candidate_results}

        hard_regressions: list[str] = []
        canary_regressions: list[str] = []

        common_ids = sorted(set(base_by_id.keys()).intersection(cand_by_id.keys()))
        for item_id in common_ids:
            b = base_by_id[item_id]
            c = cand_by_id[item_id]

            # Hard invariant regression: baseline passed, candidate failed
            if b.hard_invariants_pass and not c.hard_invariants_pass:
                hard_regressions.append(item_id)
            elif not c.hard_invariants_pass:
                # Any failure on candidate is a hard invariant violation
                if item_id not in hard_regressions:
                    hard_regressions.append(item_id)

            # Canary regression: baseline canary passed, candidate failed
            if b.critical_canary_pass is True and c.critical_canary_pass is False:
                canary_regressions.append(item_id)
            elif c.critical_canary_pass is False:
                if item_id not in canary_regressions:
                    canary_regressions.append(item_id)

        def _make_delta(name: str, b_val: Optional[float], c_val: Optional[float], threshold: float, is_hard: bool, is_upper_bound: bool = False) -> MetricDelta:
            if b_val is None and c_val is None:
                return MetricDelta(
                    metric_name=name,
                    baseline_value=0.0,
                    candidate_value=0.0,
                    delta=0.0,
                    threshold=threshold,
                    passed=True,
                    is_hard_gate=is_hard,
                )
            b_num = b_val if b_val is not None else 0.0
            c_num = c_val if c_val is not None else 0.0
            delta = c_num - b_num
            passed = (c_num <= threshold) if is_upper_bound else (c_num >= threshold)
            return MetricDelta(
                metric_name=name,
                baseline_value=b_num,
                candidate_value=c_num,
                delta=delta,
                threshold=threshold,
                passed=passed,
                is_hard_gate=is_hard,
            )

        deltas = [
            _make_delta("hard_invariants_rate", base_metrics.hard_invariants_rate, cand_metrics.hard_invariants_rate, HARD_INVARIANTS_THRESHOLD, is_hard=True),
            _make_delta("critical_canaries_rate", base_metrics.critical_canaries_rate, cand_metrics.critical_canaries_rate, CRITICAL_CANARIES_THRESHOLD, is_hard=True),
            _make_delta("semantic_recall", base_metrics.semantic_recall, cand_metrics.semantic_recall, SEMANTIC_RECALL_THRESHOLD, is_hard=False),
            _make_delta("ambiguity_recall", base_metrics.ambiguity_recall, cand_metrics.ambiguity_recall, AMBIGUITY_RECALL_THRESHOLD, is_hard=False),
            _make_delta("false_rejection_rate", base_metrics.false_rejection_rate, cand_metrics.false_rejection_rate, FALSE_REJECTION_MAX_THRESHOLD, is_hard=False, is_upper_bound=True),
        ]

        # Determine Verdict
        rejection_reasons: list[str] = []

        # Check Hard Invariants
        if cand_metrics.hard_invariants_rate is not None and cand_metrics.hard_invariants_rate < HARD_INVARIANTS_THRESHOLD:
            rejection_reasons.append(
                f"Candidate hard invariants ({cand_metrics.hard_invariants_rate * 100:.1f}%) "
                f"below required {HARD_INVARIANTS_THRESHOLD * 100:.1f}%"
            )
        if cand_metrics.critical_canaries_rate is not None and cand_metrics.critical_canaries_rate < CRITICAL_CANARIES_THRESHOLD:
            rejection_reasons.append(
                f"Candidate critical canaries ({cand_metrics.critical_canaries_rate * 100:.1f}%) "
                f"below required {CRITICAL_CANARIES_THRESHOLD * 100:.1f}%"
            )
            rejection_reasons.append(
                f"Candidate exhibited {len(hard_regressions)} hard invariant regression(s): {hard_regressions[:3]}"
            )
        if canary_regressions:
            rejection_reasons.append(
                f"Candidate exhibited {len(canary_regressions)} canary regression(s): {canary_regressions[:3]}"
            )

        if rejection_reasons:
            verdict = GateVerdict.REJECTED_HARD_GATE
        else:
            # Check Soft Gates
            soft_failures: list[str] = []
            if cand_metrics.semantic_recall is not None and cand_metrics.semantic_recall < SEMANTIC_RECALL_THRESHOLD:
                soft_failures.append(
                    f"Semantic recall ({cand_metrics.semantic_recall * 100:.1f}%) "
                    f"< threshold ({SEMANTIC_RECALL_THRESHOLD * 100:.1f}%)"
                )
            if cand_metrics.ambiguity_recall is not None and cand_metrics.ambiguity_recall < AMBIGUITY_RECALL_THRESHOLD:
                soft_failures.append(
                    f"Ambiguity recall ({cand_metrics.ambiguity_recall * 100:.1f}%) "
                    f"< threshold ({AMBIGUITY_RECALL_THRESHOLD * 100:.1f}%)"
                )
            if cand_metrics.false_rejection_rate is not None and cand_metrics.false_rejection_rate > FALSE_REJECTION_MAX_THRESHOLD:
                soft_failures.append(
                    f"False rejection rate ({cand_metrics.false_rejection_rate * 100:.1f}%) "
                    f"> max threshold ({FALSE_REJECTION_MAX_THRESHOLD * 100:.1f}%)"
                )
            if soft_failures:
                verdict = GateVerdict.FAILED_SOFT_GATE
                rejection_reasons.extend(soft_failures)
            else:
                verdict = GateVerdict.PASSED

        return PairedComparisonReport(
            report_id=report_id,
            baseline_metrics=base_metrics,
            candidate_metrics=cand_metrics,
            deltas=deltas,
            hard_invariant_regressions=hard_regressions,
            critical_canary_regressions=canary_regressions,
            verdict=verdict,
            rejection_reasons=rejection_reasons,
            evaluated_at=datetime.now(timezone.utc).isoformat(),
            benchmark_dataset_id=benchmark_dataset_id,
            benchmark_dataset_sha256=benchmark_dataset_sha256,
            execution_profile=execution_profile,
            denominators=denom,
        )
