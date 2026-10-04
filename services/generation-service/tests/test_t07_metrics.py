"""Unit and Regression Tests for Canonical Semantic Metric Engine (Step A / Phase 07).

Validates:
- Valid semantic detection counted as TP.
- Wrong issue code family does not satisfy targeted ambiguity recall.
- Operational error-only (EVALUATOR_UNAVAILABLE, TIMEOUT, etc.) NEVER counted as semantic TP.
- Mixed error + domain issue correctly counts domain detection if valid.
- Missing/cancelled/stale dependencies do not count as semantic TP.
- Unknown issue codes flagged as operational/validation issues.
- Valid case rejected due to domain issue correctly recorded as FP.
- Valid case blocked solely by operational error recorded as operational failure, NOT TN or FP.
- Missing case from frozen gold manifest counted as FN.
- Zero ambiguity denominator returns None / N/A, NEVER falling back to 1.0 (100%).
- Determinism and reconciliation: sum of per-type TP/FP/TN/FN equals overall TP/FP/TN/FN.
"""

from __future__ import annotations

import pytest

from app.evaluators.metrics import (
    calculate_semantic_benchmark_metrics,
    CANONICAL_SEMANTIC_ISSUE_CODES,
    OPERATIONAL_ERROR_CODES,
)


def test_metric_valid_semantic_detection():
    """Valid invalid question detected with canonical domain code is TP."""
    records = {
        "q_invalid_1": {
            "questionType": "TrueFalseNotGiven",
            "groundTruthValid": False,
            "expectedIssueCode": "UNSUPPORTED_OR_CONTRADICTED_CLAIM",
            "isBlocking": True,
            "issueCodes": ["UNSUPPORTED_OR_CONTRADICTED_CLAIM"],
        },
        "q_valid_1": {
            "questionType": "TrueFalseNotGiven",
            "groundTruthValid": True,
            "isBlocking": False,
            "issueCodes": [],
        },
    }
    result = calculate_semantic_benchmark_metrics(records)
    assert result.overall.tp == 1
    assert result.overall.fn == 0
    assert result.overall.tn == 1
    assert result.overall.fp == 0
    assert result.overall.recall == 1.0
    assert result.overall.false_rejection_rate == 0.0


def test_metric_error_only_never_counted_as_tp():
    """Evaluator error/unavailable alone MUST NOT count as semantic TP; must be FN + operational error."""
    records = {
        "q_invalid_err": {
            "questionType": "YesNoNotGiven",
            "groundTruthValid": False,
            "expectedIssueCode": "AMBIGUOUS_ANSWER",
            "isBlocking": True,
            "issueCodes": ["EVALUATOR_UNAVAILABLE"],  # solely error code
        },
    }
    result = calculate_semantic_benchmark_metrics(records)
    assert result.overall.tp == 0, "Error-only was incorrectly counted as True Positive!"
    assert result.overall.fn == 1
    assert result.overall.operational_failures == 1
    assert result.overall.recall == 0.0


def test_metric_timeout_cancelled_stale_never_counted_as_tp():
    """Timeout, Cancelled, Stale Dependency, and Source Insufficient are operational, not semantic detection."""
    records = {
        "q_invalid_timeout": {
            "questionType": "MultipleChoiceSingle",
            "groundTruthValid": False,
            "expectedIssueCode": "BAD_DISTRACTOR",
            "isBlocking": True,
            "issueCodes": ["TIMEOUT", "CANCELLED", "SOURCE_INSUFFICIENT", "STALE_DEPENDENCY"],
        },
    }
    result = calculate_semantic_benchmark_metrics(records)
    assert result.overall.tp == 0
    assert result.overall.fn == 1
    assert result.overall.operational_failures == 1


def test_metric_mixed_error_and_valid_domain_issue_never_tp():
    """If an evaluator threw an operational error, the case is tainted and MUST NOT count as clean semantic TP."""
    records = {
        "q_invalid_mixed": {
            "questionType": "MultipleChoiceSingle",
            "groundTruthValid": False,
            "expectedIssueCode": "BAD_DISTRACTOR",
            "isBlocking": True,
            "issueCodes": ["EVALUATOR_UNAVAILABLE", "BAD_DISTRACTOR"],
        },
    }
    result = calculate_semantic_benchmark_metrics(records)
    assert result.overall.tp == 0
    assert result.overall.fn == 1
    assert result.overall.operational_failures == 1
    assert "q_invalid_mixed" in result.overall.operational_error_cases
    assert result.acceptance["operationalErrorsZero"] is False
    assert result.acceptance["status"] is False
    assert result.ambiguity.total == 1
    assert result.ambiguity.detected == 0
    assert result.ambiguity.missed == 1

def test_metric_wrong_issue_family_does_not_satisfy_ambiguity():
    """Detecting an unrelated issue (e.g. SCHEMA_VIOLATION) on an ambiguity case is wrong-family (FN)."""
    records = {
        "q_invalid_ambiguity": {
            "questionType": "MultipleChoiceSingle",
            "groundTruthValid": False,
            "expectedIssueCode": "AMBIGUOUS_ANSWER",
            "isBlocking": True,
            "issueCodes": ["SCHEMA_VIOLATION"],  # valid domain issue, but NOT ambiguity family
        },
    }
    result = calculate_semantic_benchmark_metrics(records)
    # Strict family matching: wrong gold family defect does NOT count as TP in overall recall
    assert result.overall.tp == 0
    assert result.overall.fn == 1
    assert "q_invalid_ambiguity" in result.overall.wrong_family_cases
    assert result.ambiguity.total == 1
    assert result.ambiguity.detected == 0
    assert result.ambiguity.recall == 0.0


def test_metric_wrong_gold_family_evidence_missing_on_distractor_is_fn():
    """Detecting EVIDENCE_MISSING when gold defect is BAD_DISTRACTOR is a wrong-family detection (FN)."""
    records = {
        "q_invalid_mcq_4": {
            "questionType": "MultipleChoiceSingle",
            "groundTruthValid": False,
            "expectedIssueCode": "BAD_DISTRACTOR",
            "isBlocking": True,
            "issueCodes": ["EVIDENCE_MISSING"],
        },
    }
    result = calculate_semantic_benchmark_metrics(records)
    assert result.overall.tp == 0
    assert result.overall.fn == 1
    assert "q_invalid_mcq_4" in result.overall.wrong_family_cases
    assert result.per_type["MultipleChoiceSingle"].fn == 1
    assert result.per_type["MultipleChoiceSingle"].recall == 0.0

def test_metric_unknown_issue_code_flagged():
    """Unknown issue codes not in canonical registry are flagged."""
    records = {
        "q_invalid_unk": {
            "questionType": "ShortAnswer",
            "groundTruthValid": False,
            "isBlocking": True,
            "issueCodes": ["CUSTOM_NON_EXISTENT_CODE_123"],
        },
    }
    result = calculate_semantic_benchmark_metrics(records)
    assert "CUSTOM_NON_EXISTENT_CODE_123" in result.unknown_codes_encountered
    assert result.overall.tp == 0
    assert result.overall.fn == 1
    assert result.overall.operational_failures == 1
    assert "q_invalid_unk" in result.overall.operational_error_cases

def test_metric_valid_case_rejected_is_fp():
    """Valid question rejected due to domain issue is False Positive."""
    records = {
        "q_valid_fp": {
            "questionType": "SentenceCompletion",
            "groundTruthValid": True,
            "isBlocking": True,
            "issueCodes": ["UNSUPPORTED_OR_CONTRADICTED_CLAIM"],
        },
    }
    result = calculate_semantic_benchmark_metrics(records)
    assert result.overall.fp == 1
    assert result.overall.tn == 0
    assert result.overall.false_rejection_rate == 1.0


def test_metric_valid_case_operational_error_not_tn():
    """Valid question experiencing an evaluator crash is NOT counted as clean TN."""
    records = {
        "q_valid_err": {
            "questionType": "SentenceCompletion",
            "groundTruthValid": True,
            "isBlocking": True,
            "issueCodes": ["EVALUATOR_UNAVAILABLE"],
        },
    }
    result = calculate_semantic_benchmark_metrics(records)
    assert result.overall.tn == 0
    assert result.overall.fp == 0
    assert result.overall.operational_failures == 1


def test_metric_frozen_manifest_missing_case_counts_as_fn():
    """Missing case from frozen manifest must not decrease denominator; counts as FN."""
    frozen_manifest = {
        "expected_cases": {
            "q_invalid_1": {"questionType": "ShortAnswer", "groundTruthValid": False},
            "q_invalid_2": {"questionType": "ShortAnswer", "groundTruthValid": False},
        }
    }
    # Evaluator only returned q_invalid_1, dropped q_invalid_2
    records = {
        "q_invalid_1": {
            "questionType": "ShortAnswer",
            "groundTruthValid": False,
            "isBlocking": True,
            "issueCodes": ["WORD_LIMIT_EXCEEDED"],
        }
    }
    result = calculate_semantic_benchmark_metrics(records, frozen_manifest=frozen_manifest)
    assert result.overall.invalid_total == 2, "Missing case dropped the denominator!"
    assert result.overall.tp == 1
    assert result.overall.fn == 1
    assert result.overall.recall == 0.5


def test_metric_zero_ambiguity_denominator_never_falls_back_to_one():
    """When ambiguity gold denominator is 0, recall is None / N/A, NEVER 1.0."""
    records = {
        "q_invalid_1": {
            "questionType": "SentenceCompletion",
            "groundTruthValid": False,
            "expectedIssueCode": "SCHEMA_VIOLATION",  # not ambiguity
            "isBlocking": True,
            "issueCodes": ["SCHEMA_VIOLATION"],
        }
    }
    result = calculate_semantic_benchmark_metrics(records)
    assert result.ambiguity.total == 0
    assert result.ambiguity.recall is None
    assert result.acceptance["ambiguityRecallMeetsThreshold"] is False


def test_metric_deterministic_and_reconciles():
    """Per-type totals must perfectly reconcile with overall totals."""
    records = {
        f"q_inv_{i}": {
            "questionType": "TrueFalseNotGiven" if i % 2 == 0 else "MultipleChoiceSingle",
            "groundTruthValid": False,
            "expectedIssueCode": "AMBIGUOUS_ANSWER" if i == 0 else "SCHEMA_VIOLATION",
            "isBlocking": i != 3,
            "issueCodes": ["AMBIGUOUS_ANSWER"] if i == 0 else (["SCHEMA_VIOLATION"] if i != 3 else []),
        }
        for i in range(10)
    }
    result1 = calculate_semantic_benchmark_metrics(records)
    result2 = calculate_semantic_benchmark_metrics(records)
    # Determinism
    assert result1.overall.recall == result2.overall.recall
    assert result1.rates == result2.rates

    # Reconciliation
    sum_tp = sum(cm.tp for cm in result1.per_type.values())
    sum_fn = sum(cm.fn for cm in result1.per_type.values())
    assert sum_tp == result1.overall.tp
    assert sum_fn == result1.overall.fn
    assert result1.overall.tp + result1.overall.fn == result1.overall.invalid_total

def test_metric_to_canonical_summary_consistency_between_live_and_offline():
    """Live runner and offline recalculator produce identical canonical summaries."""
    records = {
        "q_1": {
            "questionType": "SentenceCompletion",
            "groundTruthValid": False,
            "expectedIssueCode": "WORD_LIMIT_EXCEEDED",
            "isBlocking": True,
            "issueCodes": ["WORD_LIMIT_EXCEEDED"],
            "timestamp": "2026-10-04T10:00:00+00:00",
        },
        "q_2": {
            "questionType": "SentenceCompletion",
            "groundTruthValid": True,
            "isBlocking": False,
            "issueCodes": [],
            "timestamp": "2026-10-04T10:01:00+00:00",
        },
    }
    res1 = calculate_semantic_benchmark_metrics(records, campaign_id="camp_test", partition="dev")
    res2 = calculate_semantic_benchmark_metrics(records, campaign_id="camp_test", partition="dev")

    sum1 = res1.to_canonical_summary(started_at="2026-10-04T10:00:00+00:00", finished_at="2026-10-04T10:01:00+00:00", duration_seconds=60.0)
    sum2 = res2.to_canonical_summary(started_at="2026-10-04T10:00:00+00:00", finished_at="2026-10-04T10:01:00+00:00", duration_seconds=60.0)

    assert sum1 == sum2
    assert sum1["metadata"]["metricEngineVersion"] == "2.3.0"
    assert sum1["metadata"]["metricEngineHash"] == res1.metric_engine_hash
    assert sum1["confusionMatrices"]["questions"]["truePositives"] == 1
    assert sum1["confusionMatrices"]["questions"]["trueNegatives"] == 1


def test_metric_separate_reporting_of_semantic_fp_and_total_valid_rejected():
    """Semantic false positives and total valid items rejected by operational errors are reported distinctly."""
    records = {
        "q_valid_clean": {
            "questionType": "ShortAnswer",
            "groundTruthValid": True,
            "isBlocking": False,
            "issueCodes": [],
        },
        "q_valid_semantic_fp": {
            "questionType": "ShortAnswer",
            "groundTruthValid": True,
            "isBlocking": True,
            "issueCodes": ["UNSUPPORTED_OR_CONTRADICTED_CLAIM"],
        },
        "q_valid_operational_fail": {
            "questionType": "ShortAnswer",
            "groundTruthValid": True,
            "isBlocking": True,
            "issueCodes": ["EVALUATOR_UNAVAILABLE"],
        },
    }
    res = calculate_semantic_benchmark_metrics(records)
    summary = res.to_canonical_summary()

    assert summary["metadata"]["validQuestions"] == 3
    assert summary["metadata"]["semanticFalsePositives"] == 1
    assert summary["metadata"]["operationalRejectionsOfValid"] == 1
    assert summary["metadata"]["totalValidRejected"] == 2

    assert summary["rates"]["falseRejectionRate"] == pytest.approx(1 / 3)
    assert summary["rates"]["semanticFalsePositivesCount"] == 1
    assert summary["rates"]["totalValidRejectedCount"] == 2
    assert summary["rates"]["totalValidRejectedRate"] == pytest.approx(2 / 3)

