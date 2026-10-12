"""Canonical Metric Engine and Aggregator for Phase 07 Semantic Benchmarks.

Provides deterministic, auditable calculation of semantic evaluation metrics
according to the Langfens Output and Gate Contract:
- Strict allowlist of domain semantic issue codes vs operational/evaluator errors.
- Evaluator ERROR / UNAVAILABLE / TIMEOUT / CANCELLED are NEVER counted as semantic detection TP.
- Ambiguity recall requires valid evaluator detection matching gold ambiguity family.
- Denominators are strictly frozen from the dataset manifest; missing cases count as FN.
- Zero denominator produces INCOMPLETE / NOT_APPLICABLE, never falling back to 100%.
- Generates detailed contribution breakdown (TP/FN/TN/FP case IDs, per-type, operational errors).
"""

from __future__ import annotations

from dataclasses import dataclass, field
import hashlib
from typing import Any, Dict, List, Optional, Set, Tuple

from app.contracts.issue import IssueCode

# Implementation version hash for auditability
METRIC_ENGINE_VERSION = "2.3.1"
METRIC_ENGINE_HASH = hashlib.sha256(f"LangfensMetricEngine:{METRIC_ENGINE_VERSION}".encode()).hexdigest()[:16]

# 1. Canonical Domain Semantic Issue Codes (Valid detections)
CANONICAL_SEMANTIC_ISSUE_CODES: Set[str] = {
    # Five source fidelity hard errors
    IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM.value,
    IssueCode.CAUSAL_OVERSTATEMENT.value,
    IssueCode.OVERSTATED_CERTAINTY.value,
    IssueCode.UNMEASURED_OUTCOME.value,
    # Construction & contract violations
    IssueCode.EVIDENCE_MISSING.value,
    IssueCode.AMBIGUOUS_ANSWER.value,
    IssueCode.ANSWER_LEAKAGE.value,
    IssueCode.BAD_DISTRACTOR.value,
    IssueCode.WORD_LIMIT_EXCEEDED.value,
    IssueCode.DUPLICATE_CONTENT.value,
    IssueCode.SCHEMA_VIOLATION.value,
    IssueCode.INSUFFICIENT_OPTIONS.value,
    IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS.value,
    IssueCode.QUESTION_NUMBERING_INVALID.value,
    IssueCode.QUESTION_COUNT_MISMATCH.value,
}

# 2. Operational / System Failure Codes (MUST NEVER be counted as semantic detection TP)
OPERATIONAL_ERROR_CODES: Set[str] = {
    IssueCode.EVALUATOR_UNAVAILABLE.value,
    IssueCode.STALE_DEPENDENCY.value,
    IssueCode.BUDGET_EXHAUSTED.value,
    IssueCode.SOURCE_INSUFFICIENT.value,
    "EVALUATION_ERROR",
    "TIMEOUT",
    "CANCELLED",
    "UNKNOWN_OUTCOME",
    "MISSING_PREREQUISITE",
    "INTERNAL_ERROR",
}

# 3. Gold Issue Family Mappings (for strict defect family matching)
GOLD_ISSUE_FAMILIES: Dict[str, Set[str]] = {
    # Ambiguity / Multiple Answers / Distractor defect
    IssueCode.AMBIGUOUS_ANSWER.value: {
        IssueCode.AMBIGUOUS_ANSWER.value,
        IssueCode.BAD_DISTRACTOR.value,
    },
    IssueCode.BAD_DISTRACTOR.value: {
        IssueCode.AMBIGUOUS_ANSWER.value,
        IssueCode.BAD_DISTRACTOR.value,
    },
    # Factual grounding / contradiction / overstatement defect
    IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM.value: {
        IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM.value,
        IssueCode.CAUSAL_OVERSTATEMENT.value,
        IssueCode.OVERSTATED_CERTAINTY.value,
        IssueCode.UNMEASURED_OUTCOME.value,
    },
    IssueCode.CAUSAL_OVERSTATEMENT.value: {
        IssueCode.CAUSAL_OVERSTATEMENT.value,
        IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM.value,
    },
    IssueCode.OVERSTATED_CERTAINTY.value: {
        IssueCode.OVERSTATED_CERTAINTY.value,
        IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM.value,
    },
    IssueCode.UNMEASURED_OUTCOME.value: {
        IssueCode.UNMEASURED_OUTCOME.value,
        IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM.value,
    },
    # Evidence missing
    IssueCode.EVIDENCE_MISSING.value: {
        IssueCode.EVIDENCE_MISSING.value,
    },
    # Word limit
    IssueCode.WORD_LIMIT_EXCEEDED.value: {
        IssueCode.WORD_LIMIT_EXCEEDED.value,
    },
    # Answer leakage
    IssueCode.ANSWER_LEAKAGE.value: {
        IssueCode.ANSWER_LEAKAGE.value,
    },
    # Schema / Insufficient options
    IssueCode.SCHEMA_VIOLATION.value: {
        IssueCode.SCHEMA_VIOLATION.value,
        IssueCode.INSUFFICIENT_OPTIONS.value,
    },
    IssueCode.INSUFFICIENT_OPTIONS.value: {
        IssueCode.INSUFFICIENT_OPTIONS.value,
        IssueCode.SCHEMA_VIOLATION.value,
    },
    IssueCode.DUPLICATE_CONTENT.value: {
        IssueCode.DUPLICATE_CONTENT.value,
        IssueCode.BAD_DISTRACTOR.value,
    },
}

AMBIGUITY_GOLD_CODES: Set[str] = {
    IssueCode.AMBIGUOUS_ANSWER.value,
    IssueCode.BAD_DISTRACTOR.value,
}


@dataclass
class ConfusionMatrix:
    total: int = 0
    valid_total: int = 0
    invalid_total: int = 0
    tp: int = 0
    fn: int = 0
    tn: int = 0
    fp: int = 0
    operational_failures: int = 0
    wrong_family_failures: int = 0
    tp_cases: List[str] = field(default_factory=list)
    fn_cases: List[str] = field(default_factory=list)
    tn_cases: List[str] = field(default_factory=list)
    fp_cases: List[str] = field(default_factory=list)
    operational_error_cases: List[str] = field(default_factory=list)
    wrong_family_cases: List[str] = field(default_factory=list)
    @property
    def recall(self) -> float:
        return self.tp / self.invalid_total if self.invalid_total > 0 else 0.0

    @property
    def false_rejection_rate(self) -> float:
        return self.fp / self.valid_total if self.valid_total > 0 else 0.0


@dataclass
class AmbiguityMetrics:
    total: int = 0
    detected: int = 0
    missed: int = 0
    detected_cases: List[str] = field(default_factory=list)
    missed_cases: List[str] = field(default_factory=list)

    @property
    def recall(self) -> Optional[float]:
        if self.total == 0:
            return None  # Incomplete / Not Applicable; NEVER fallback to 1.0!
        return self.detected / self.total


@dataclass
class CanaryMetrics:
    total_canaries: int = 0
    repetitions: int = 0
    run_rates: List[float] = field(default_factory=list)
    aggregate_rate: float = 0.0
    worst_run_rate: float = 0.0
    failed_canaries: List[str] = field(default_factory=list)


@dataclass
class MetricCalculationResult:
    campaign_id: str
    partition: str
    metric_engine_version: str
    metric_engine_hash: str
    overall: ConfusionMatrix
    per_type: Dict[str, ConfusionMatrix]
    ambiguity: AmbiguityMetrics
    canaries: Optional[CanaryMetrics]
    rates: Dict[str, Any]
    acceptance: Dict[str, bool]
    unknown_codes_encountered: List[str] = field(default_factory=list)

    def to_canonical_summary(
        self,
        started_at: Optional[str] = None,
        finished_at: Optional[str] = None,
        duration_seconds: Optional[float] = None,
        provider: Optional[str] = None,
        model: Optional[str] = None,
        quarantined_notice: Optional[str] = None,
        fidelity_results: Optional[List[Dict[str, Any]]] = None,
    ) -> Dict[str, Any]:
        """Serializes calculation results to canonical, auditable dictionary."""
        fidelity_cm = {
            "total": 0,
            "truePositives": 0,
            "falseNegatives": 0,
            "trueNegatives": 0,
            "falsePositives": 0,
        }
        if fidelity_results:
            fidelity_cm["total"] = len(fidelity_results)
            for r in fidelity_results:
                gt_valid = bool(r.get("groundTruthValid", False))
                is_blocking = bool(r.get("isBlocking", False))
                if gt_valid:
                    if is_blocking:
                        fidelity_cm["falsePositives"] += 1
                    else:
                        fidelity_cm["trueNegatives"] += 1
                else:
                    if is_blocking:
                        fidelity_cm["truePositives"] += 1
                    else:
                        fidelity_cm["falseNegatives"] += 1

        canary_dict: Dict[str, Any] = {}
        if self.canaries:
            canary_dict = {
                "totalCanaries": self.canaries.total_canaries,
                "repetitions": self.canaries.repetitions,
                "runRates": self.canaries.run_rates,
                "aggregateRate": self.canaries.aggregate_rate,
                "worstRunRate": self.canaries.worst_run_rate,
                "failedCanaries": self.canaries.failed_canaries,
            }

        sem_fp_count = len(self.overall.fp_cases)
        # Only operational failures on valid questions count as valid rejections.
        op_rej_count = self.overall.valid_total - self.overall.tn - sem_fp_count
        total_valid_rej = sem_fp_count + op_rej_count

        metadata = {
            "campaignId": self.campaign_id,
            "partition": self.partition,
            "startedAt": started_at,
            "finishedAt": finished_at,
            "durationSeconds": round(duration_seconds, 3) if duration_seconds is not None else None,
            "providerUsed": provider,
            "modelUsed": model,
            "metricEngineVersion": self.metric_engine_version,
            "metricEngineHash": self.metric_engine_hash,
            "totalQuestionsEvaluated": self.overall.total,
            "validQuestions": self.overall.valid_total,
            "invalidQuestions": self.overall.invalid_total,
            "operationalFailures": self.overall.operational_failures,
            "semanticFalsePositives": sem_fp_count,
            "operationalRejectionsOfValid": op_rej_count,
            "totalValidRejected": total_valid_rej,
            "quarantinedNotice": quarantined_notice,
            "totalFidelityCasesEvaluated": fidelity_cm["total"],
            "totalCanariesEvaluated": self.canaries.total_canaries if self.canaries else 0,
            "canaryRepetitions": self.canaries.repetitions if self.canaries else 0,
        }

        cm_structure = {
            "questions": {
                "total": self.overall.total,
                "validTotal": self.overall.valid_total,
                "invalidTotal": self.overall.invalid_total,
                "truePositives": self.overall.tp,
                "falseNegatives": self.overall.fn,
                "trueNegatives": self.overall.tn,
                "falsePositives": self.overall.fp,
                "operationalFailures": self.overall.operational_failures,
                "recall": self.overall.recall,
                "falseRejectionRate": self.overall.false_rejection_rate,
            },
            "perType": {
                qt: {
                    "total": cm.total,
                    "validTotal": cm.valid_total,
                    "invalidTotal": cm.invalid_total,
                    "tp": cm.tp,
                    "fn": cm.fn,
                    "tn": cm.tn,
                    "fp": cm.fp,
                    "operationalFailures": cm.operational_failures,
                    "recall": cm.recall,
                    "falseRejectionRate": cm.false_rejection_rate,
                }
                for qt, cm in self.per_type.items()
            },
            "ambiguity": {
                "total": self.ambiguity.total,
                "detected": self.ambiguity.detected,
                "missed": self.ambiguity.missed,
                "recall": self.ambiguity.recall,
                "detectedCases": self.ambiguity.detected_cases,
                "missedCases": self.ambiguity.missed_cases,
            },
            "fidelity": fidelity_cm,
            "criticalCanaries": canary_dict,
        }

        summary = {
            "metadata": metadata,
            "rates": self.rates,
            "acceptanceStatus": self.acceptance,
            "confusionMatrices": cm_structure,
            "confusionMatrix": cm_structure,  # compatibility alias
            "caseContributions": {
                "truePositives": self.overall.tp_cases,
                "falseNegatives": self.overall.fn_cases,
                "trueNegatives": self.overall.tn_cases,
                "falsePositives": self.overall.fp_cases,
                "operationalErrorCases": self.overall.operational_error_cases,
                "wrongFamilyCases": self.overall.wrong_family_cases,
            },
            "unknownCodesEncountered": self.unknown_codes_encountered,
        }
        return summary


def extract_semantic_and_operational_codes(issue_codes: List[str]) -> Tuple[List[str], List[str], List[str]]:
    """Splits raw issue codes into (semantic_valid, operational_errors, unknown_codes)."""
    semantic = []
    operational = []
    unknown = []
    for code in issue_codes:
        normalized = str(code).strip()
        if normalized in CANONICAL_SEMANTIC_ISSUE_CODES:
            semantic.append(normalized)
        elif (
            normalized in OPERATIONAL_ERROR_CODES
            or "ERROR" in normalized.upper()
            or "TIMEOUT" in normalized.upper()
            or "UNAVAILABLE" in normalized.upper()
            or "CANCELLED" in normalized.upper()
        ):
            operational.append(normalized)
        else:
            unknown.append(normalized)
    return semantic, operational, unknown


def calculate_semantic_benchmark_metrics(
    records: Dict[str, Dict[str, Any]],
    campaign_id: str = "unknown",
    partition: str = "unknown",
    frozen_manifest: Optional[Dict[str, Any]] = None,
    canary_records: Optional[List[Dict[str, Any]]] = None,
    canary_repetitions: int = 3,
) -> MetricCalculationResult:
    """Calculates canonical metrics from completed case records with strict validation.

    Args:
        records: Dict of case_id -> case record from checkpoint.
        campaign_id: Campaign identifier.
        partition: Corpus partition name (e.g. 'dev', 'holdout').
        frozen_manifest: Optional dict of frozen gold case IDs and their metadata.
                         If provided, missing cases from `records` will be counted as FN.
        canary_records: Optional list of canary test evaluation records.
        canary_repetitions: Number of canary repetition passes.
    """
    overall = ConfusionMatrix()
    per_type: Dict[str, ConfusionMatrix] = {}
    ambiguity = AmbiguityMetrics()
    all_unknown_codes: List[str] = []

    # If frozen manifest provided, ensure all frozen cases are accounted for
    all_case_ids: Set[str] = set(records.keys())
    if frozen_manifest and "expected_cases" in frozen_manifest:
        for exp_id in frozen_manifest["expected_cases"]:
            if exp_id not in records:
                all_case_ids.add(exp_id)

    # Process all question items
    for case_id in sorted(all_case_ids):
        if not (case_id.startswith("q_") or "question" in case_id.lower()):
            continue  # Skip fidelity/canary items handled separately

        record = records.get(case_id)
        if record is None:
            # Missing case from frozen gold manifest: count as missing / operational FN
            exp_meta = (frozen_manifest or {}).get("expected_cases", {}).get(case_id, {})
            q_type = exp_meta.get("questionType", "Unknown")
            is_valid = exp_meta.get("groundTruthValid", False)
            if q_type not in per_type:
                per_type[q_type] = ConfusionMatrix()

            if is_valid:
                overall.valid_total += 1
                overall.operational_failures += 1
                overall.operational_error_cases.append(case_id)
                per_type[q_type].valid_total += 1
                per_type[q_type].operational_failures += 1
            else:
                overall.invalid_total += 1
                overall.fn += 1
                overall.fn_cases.append(case_id)
                per_type[q_type].invalid_total += 1
                per_type[q_type].fn += 1
            expected_issue_code = exp_meta.get("expectedIssueCode", "")
            if expected_issue_code in AMBIGUITY_GOLD_CODES:
                ambiguity.total += 1
                ambiguity.missed += 1
                ambiguity.missed_cases.append(case_id)
            continue

        q_type = record.get("questionType", "Unknown")
        if q_type not in per_type:
            per_type[q_type] = ConfusionMatrix()

        gt_valid = bool(record.get("groundTruthValid", False))
        is_blocking = bool(record.get("isBlocking", False))
        raw_issue_codes = record.get("issueCodes", [])
        exp_code = record.get("expectedIssueCode", "")

        semantic_codes, op_codes, unk_codes = extract_semantic_and_operational_codes(raw_issue_codes)
        if unk_codes:
            all_unknown_codes.extend(unk_codes)

        # Strict Gold Family Matching:
        if exp_code:
            allowed_family = GOLD_ISSUE_FAMILIES.get(exp_code, {exp_code})
            matches_gold_family = any(c in allowed_family for c in semantic_codes)
        else:
            matches_gold_family = len(semantic_codes) > 0

        has_operational_error = len(op_codes) > 0 or len(unk_codes) > 0
        if has_operational_error:
            overall.operational_failures += 1
            overall.operational_error_cases.append(case_id)
            per_type[q_type].operational_failures += 1
            per_type[q_type].operational_error_cases.append(case_id)

        has_semantic_detection = (
            not has_operational_error
            and is_blocking
            and len(semantic_codes) > 0
            and matches_gold_family
        )
        is_wrong_family_only = (
            not has_operational_error
            and is_blocking
            and len(semantic_codes) > 0
            and not matches_gold_family
        )

        if gt_valid:
            overall.valid_total += 1
            per_type[q_type].valid_total += 1
            if is_blocking and len(semantic_codes) > 0 and not has_operational_error:
                # Valid question rejected due to domain semantic issue -> False Positive
                overall.fp += 1
                overall.fp_cases.append(case_id)
                per_type[q_type].fp += 1
                per_type[q_type].fp_cases.append(case_id)
            elif has_operational_error:
                # Valid question tainted/blocked by operational error -> already counted in operational_failures, NOT TN!
                pass
            else:
                # Clean valid question passed cleanly -> True Negative
                overall.tn += 1
                overall.tn_cases.append(case_id)
                per_type[q_type].tn += 1
                per_type[q_type].tn_cases.append(case_id)
        else:
            overall.invalid_total += 1
            per_type[q_type].invalid_total += 1
            if has_semantic_detection:
                # Clean invalid question detected with valid domain semantic code matching gold family -> True Positive
                overall.tp += 1
                overall.tp_cases.append(case_id)
                per_type[q_type].tp += 1
                per_type[q_type].tp_cases.append(case_id)
            else:
                # Invalid question NOT cleanly detected with matching gold family -> False Negative
                overall.fn += 1
                overall.fn_cases.append(case_id)
                per_type[q_type].fn += 1
                per_type[q_type].fn_cases.append(case_id)
                if is_wrong_family_only:
                    overall.wrong_family_failures += 1
                    overall.wrong_family_cases.append(case_id)
                    per_type[q_type].wrong_family_failures += 1
                    per_type[q_type].wrong_family_cases.append(case_id)

        # Ambiguity Evaluation
        if exp_code in AMBIGUITY_GOLD_CODES:
            ambiguity.total += 1
            # Ambiguity detected only if clean semantic detection includes matching ambiguity family code
            if not has_operational_error and any(c in AMBIGUITY_GOLD_CODES for c in semantic_codes):
                ambiguity.detected += 1
                ambiguity.detected_cases.append(case_id)
            else:
                ambiguity.missed += 1
                ambiguity.missed_cases.append(case_id)
    overall.total = overall.valid_total + overall.invalid_total
    for cm in per_type.values():
        cm.total = cm.valid_total + cm.invalid_total

    # Canary metrics calculation
    canaries: Optional[CanaryMetrics] = None
    if canary_records:
        canary_runs: Dict[int, List[bool]] = {r: [] for r in range(canary_repetitions)}
        failed_canaries = []
        for c in canary_records:
            rep = c.get("repetition", 0)
            is_blocked = bool(c.get("isBlocking", False))
            if rep in canary_runs:
                canary_runs[rep].append(is_blocked)
            if not is_blocked:
                failed_canaries.append(c.get("caseId", "unknown"))

        run_rates = [
            sum(runs) / len(runs) if len(runs) > 0 else 0.0
            for runs in canary_runs.values()
        ]
        total_canaries = sum(len(r) for r in canary_runs.values())
        agg_rate = sum(sum(r) for r in canary_runs.values()) / total_canaries if total_canaries > 0 else 0.0
        worst_rate = min(run_rates) if run_rates else 0.0

        canaries = CanaryMetrics(
            total_canaries=total_canaries,
            repetitions=canary_repetitions,
            run_rates=run_rates,
            aggregate_rate=agg_rate,
            worst_run_rate=worst_rate,
            failed_canaries=failed_canaries,
        )

    # Acceptance threshold checks
    overall_recall = overall.recall
    per_type_pass = all(cm.recall >= 0.90 for cm in per_type.values()) if per_type else False
    ambiguity_recall = ambiguity.recall
    ambiguity_pass = (ambiguity_recall is not None) and (ambiguity_recall >= 0.90)
    frr_pass = overall.false_rejection_rate <= 0.10
    canary_pass = (canaries.worst_run_rate == 1.0) if canaries else True

    acceptance = {
        "overallRecallMeetsThreshold": overall_recall >= 0.95,
        "perTypeRecallMeetsThreshold": per_type_pass,
        "ambiguityRecallMeetsThreshold": ambiguity_pass,
        "falseRejectionMeetsThreshold": frr_pass,
        "criticalCanariesMeetsThreshold": canary_pass,
        "operationalErrorsZero": overall.operational_failures == 0,
        "status": (
            overall_recall >= 0.95
            and per_type_pass
            and ambiguity_pass
            and frr_pass
            and canary_pass
            and overall.operational_failures == 0
        ),
    }

    sem_fp_count = len(overall.fp_cases)
    # Invalid-question operational failures are failures, not valid-item rejections.
    op_rej_count = overall.valid_total - overall.tn - sem_fp_count
    total_valid_rejected = sem_fp_count + op_rej_count
    total_valid_rejected_rate = total_valid_rejected / overall.valid_total if overall.valid_total > 0 else 0.0

    rates = {
        "overallBlockingRecall": overall_recall,
        "falseRejectionRate": overall.false_rejection_rate,
        "semanticFalsePositivesCount": sem_fp_count,
        "semanticFalsePositivesRate": overall.false_rejection_rate,
        "operationalRejectionsOfValidCount": op_rej_count,
        "totalValidRejectedCount": total_valid_rejected,
        "totalValidRejectedRate": total_valid_rejected_rate,
        "ambiguityRecall": ambiguity_recall,
        "ambiguityRecallFormatted": f"{ambiguity_recall*100:.1f}%" if ambiguity_recall is not None else "N/A (Denominator 0)",
        "perTypeRecall": {qt: cm.recall for qt, cm in per_type.items()},
        "operationalFailureRate": overall.operational_failures / overall.total if overall.total > 0 else 0.0,
    }
    if canaries:
        rates["canaryAggregateRate"] = canaries.aggregate_rate
        rates["canaryWorstRunRate"] = canaries.worst_run_rate

    return MetricCalculationResult(
        campaign_id=campaign_id,
        partition=partition,
        metric_engine_version=METRIC_ENGINE_VERSION,
        metric_engine_hash=METRIC_ENGINE_HASH,
        overall=overall,
        per_type=per_type,
        ambiguity=ambiguity,
        canaries=canaries,
        rates=rates,
        acceptance=acceptance,
        unknown_codes_encountered=list(set(all_unknown_codes)),
    )
