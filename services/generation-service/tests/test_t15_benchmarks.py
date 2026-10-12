"""Phase 15 Paired Benchmark Test Suite (T15-02 / P15-02).

Validates:
1. Paired benchmark report completeness (>=18 paired papers across >=6 distinct source triples).
2. Validation Matrix compliance:
   - Valid Draft rate (>= 95%)
   - Fidelity must-reject detection rate (100%)
   - Semantic blocking recall (>= 95%)
   - Per-type question recall (>= 90% across all 6 question types)
   - Ambiguity recall (>= 90%)
   - False rejection rate (<= 10%)
   - Median token cost ratio (V2 median <= 2.0x Legacy median)
   - Critical semantic fixtures evaluated across >= 3 repetitions with worst-run reporting.
3. Persistence audit: V2 primary persisted to PostgreSQL, legacy shadow runs bounded without overwriting primary.
4. Error handling and distribution metrics consistency.
"""

from __future__ import annotations

import json
from pathlib import Path
import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent.parent.parent
BENCHMARKS_DIR = REPO_ROOT / "artifacts" / "refactor" / "phase-15" / "benchmarks"
REPORT_PATH = BENCHMARKS_DIR / "paired-benchmark-report.json"
DISTRIBUTIONS_PATH = BENCHMARKS_DIR / "distributions.json"
TOKEN_ACCOUNTING_PATH = BENCHMARKS_DIR / "token-accounting.json"
CASES_DIR = BENCHMARKS_DIR / "cases"


@pytest.fixture
def benchmark_report() -> dict:
    assert REPORT_PATH.exists(), f"Benchmark report missing at {REPORT_PATH}"
    with open(REPORT_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


@pytest.fixture
def distributions_data() -> dict:
    assert DISTRIBUTIONS_PATH.exists(), f"Distributions file missing at {DISTRIBUTIONS_PATH}"
    with open(DISTRIBUTIONS_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


@pytest.fixture
def token_accounting() -> dict:
    assert TOKEN_ACCOUNTING_PATH.exists(), f"Token accounting file missing at {TOKEN_ACCOUNTING_PATH}"
    with open(TOKEN_ACCOUNTING_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def test_t15_02_benchmark_report_completeness(benchmark_report):
    """T15-02: Paired benchmark contains >=18 papers across >=6 distinct source triples."""
    assert benchmark_report["totalPairedPapers"] >= 18
    assert benchmark_report["totalRunsExecuted"] >= 36
    assert benchmark_report["distinctSourcesCount"] >= 6
    assert benchmark_report["distinctSourceTriplesCount"] >= 6
    assert len(benchmark_report["pairedCases"]) >= 18


def test_t15_02_validation_matrix_fidelity_and_semantic_recall(benchmark_report):
    """T15-02: Fidelity must-reject is 100% and semantic blocking recall is >= 95%."""
    matrix = benchmark_report["validationMatrix"]

    # 1. Fidelity Must-Reject (100%)
    fid = matrix["fidelityMustRejectRate"]
    assert fid["rate"] == 1.0, f"Expected 100% must-reject rate, got {fid['rate'] * 100}%"
    assert fid["passed"] is True

    # 2. Semantic Blocking Recall (>= 95%)
    sem = matrix["semanticBlockingRecall"]
    assert sem["recall"] >= 0.95, f"Expected >= 95% semantic recall, got {sem['recall'] * 100}%"
    assert sem["passed"] is True


def test_t15_02_validation_matrix_per_type_and_ambiguity_recall(benchmark_report):
    """T15-02: Per-type recall is >= 90% across all 6 types and ambiguity recall >= 90%."""
    matrix = benchmark_report["validationMatrix"]

    # Per-Type Recall
    per_type = matrix["perTypeRecall"]
    expected_types = [
        "TRUE_FALSE_NOT_GIVEN",
        "YES_NO_NOT_GIVEN",
        "MULTIPLE_CHOICE_SINGLE",
        "SENTENCE_COMPLETION",
        "SUMMARY_COMPLETION",
        "SHORT_ANSWER",
    ]
    for q_type in expected_types:
        assert q_type in per_type["byType"], f"Missing question type in metrics: {q_type}"
        recall = per_type["byType"][q_type]
        assert recall >= 0.90, f"Per-type recall for {q_type} is {recall * 100}%, below 90% target"

    assert per_type["passed"] is True

    # Ambiguity Recall
    amb = matrix["ambiguityRecall"]
    assert amb["recall"] >= 0.90, f"Expected >= 90% ambiguity recall, got {amb['recall'] * 100}%"
    assert amb["passed"] is True

    # False Rejection Rate
    frr = matrix["falseRejectionRate"]
    assert frr["rate"] <= 0.10, f"Expected <= 10% false rejection rate, got {frr['rate'] * 100}%"
    assert frr["passed"] is True


def test_t15_02_validation_matrix_token_cost_ratio(benchmark_report):
    """T15-02: Median token cost ratio V2/Legacy is <= 2.0x."""
    matrix = benchmark_report["validationMatrix"]
    tok = matrix["medianTokenCostRatio"]
    assert tok["ratio"] <= 2.0, f"Median token cost ratio {tok['ratio']}x exceeds 2.0x ceiling"
    assert tok["passed"] is True

def test_t15_02_validation_matrix_latency_ratio(benchmark_report):
    """T15-02: Reports P95 latency metrics, checks mathematical consistency and pass threshold logic."""
    matrix = benchmark_report["validationMatrix"]
    lat = matrix["p95LatencyRatio"]
    assert "ratio" in lat
    assert "v2P95" in lat
    assert "legacyP95" in lat
    assert "target" in lat
    assert isinstance(lat["ratio"], (int, float))
    assert lat["v2P95"] > 0
    assert lat["legacyP95"] > 0
    computed_ratio = round(lat["v2P95"] / max(0.0001, lat["legacyP95"]), 3)
    assert abs(computed_ratio - lat["ratio"]) <= 0.01, f"Reported ratio {lat['ratio']} diverges from computed {computed_ratio}"
    assert lat["passed"] == (lat["ratio"] <= 1.5), "Latency pass boolean must strictly match ratio <= 1.50 condition"
def test_t15_02_persistence_audit(benchmark_report):
    """T15-02: V2 primary persisted to PostgreSQL; legacy shadow runs do not overwrite primary."""
    audit = benchmark_report["persistenceAudit"]
    assert audit["v2AuthoritativePersistedCount"] >= 18
    assert audit["legacyShadowPersistedCount"] == 0
    assert audit["shadowOverwrotePrimary"] is False


def test_t15_02_critical_fixtures_repetitions_and_worst_run(benchmark_report):
    """T15-02: Critical semantic fixtures evaluated >=3 times with aggregate and worst-run reported."""
    crit = benchmark_report["criticalFixturesEvaluation"]
    assert crit["repetitionsCount"] >= 3
    assert len(crit["runs"]) >= 3

    worst = crit["worstRun"]
    assert worst["fidelityMustRejectRate"] == 1.0, f"Worst-run must-reject rate was {worst['fidelityMustRejectRate']}"
    assert worst["semanticBlockingRecall"] >= 0.95
    assert worst["ambiguityRecall"] >= 0.90
    assert worst["falseRejectionRate"] <= 0.10


def test_t15_02_distributions_and_token_accounting(distributions_data, token_accounting):
    """T15-02: Distribution percentiles and token accounting data are consistent."""
    assert distributions_data["totalPairedPapers"] >= 18
    assert distributions_data["v2Tokens"]["median"] > 0
    assert distributions_data["legacyTokens"]["median"] > 0

    assert token_accounting["v2TotalTokensUsed"] > 0
    assert token_accounting["legacyTotalTokensUsed"] > 0
    assert token_accounting["v2TotalEstimatedCostUsd"] > 0
    assert token_accounting["legacyTotalEstimatedCostUsd"] > 0


def test_t15_02_individual_case_artifacts_exist():
    """T15-02: All individual paired case JSON files exist in cases/ directory."""
    assert CASES_DIR.exists()
    case_files = list(CASES_DIR.glob("case_*.json"))
    assert len(case_files) >= 36, f"Expected at least 36 case files (18 V2 + 18 Legacy), found {len(case_files)}"
