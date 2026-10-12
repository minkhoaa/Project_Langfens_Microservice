"""Regression checks for simulation-only G08 paired-report provenance."""

import json
from pathlib import Path


REPORT_PATH = (
    Path(__file__).resolve().parents[3]
    / "artifacts"
    / "refactor"
    / "phase-08"
    / "paired-passage-benchmark-report.json"
)


def test_paired_report_preserves_raw_passes_without_claiming_authoritative_cas():
    report = json.loads(REPORT_PATH.read_text(encoding="utf-8"))
    v2_cases = [case["v2"] for case in report["cases"]]
    raw_passes = [
        case
        for case in v2_cases
        if case["decision"] == "PASS"
        and case["groundingEvaluation"]["status"] == "PASS"
    ]

    assert len(raw_passes) == 3
    assert report["aggregateMetrics"]["eligibleGenerationSuccess"]["v2AcceptedRuns"] == 3
    cas_commit = report.get("aggregateMetrics", {}).get("authoritativeCASCommit", {})
    if isinstance(cas_commit, dict) and "proven" in cas_commit:
        assert cas_commit["proven"] is False
        assert cas_commit.get("classification") == "SIMULATION_ONLY"
    else:
        assert "v2" in cas_commit or cas_commit.get("v2") is not None

    if "simulationEvidence" in report:
        assert report["simulationEvidence"].get("authoritativeCasProven") is False
        assert report["simulationEvidence"].get("classification") == "SIMULATION_ONLY"

    if "acceptanceStatus" in report:
        acc = report["acceptanceStatus"]
        if "v2AuthoritativeCASCompliant" in acc:
            assert isinstance(acc["v2AuthoritativeCASCompliant"], bool)
        assert acc.get("status") in ("PASS", "DIAGNOSTIC_ONLY")

    for case in v2_cases:
        if "persistenceEvidence" in case and case["persistenceEvidence"]:
            assert case["persistenceEvidence"].get("authoritativeCasProven") is False


def test_g08_unlimited_store_initialization(tmp_path):
    import sys
    sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "scripts/refactor"))
    from benchmark_campaign import CampaignBudgetLedger
    from run_phase08_paired_passage_benchmark import _new_campaign_store

    ledger = CampaignBudgetLedger(
        tmp_path / "test_ledger.json",
        budget_file=None,
        campaign_id="camp_g08_test_unlimited",
        corpus_hash="0" * 64,
        config_hash="0" * 64,
        is_unlimited=True,
    )
    assert ledger.is_unlimited is True

    class DummyClient:
        pass

    store = _new_campaign_store(DummyClient(), ledger)
    assert store.run_calls_cap == -1
    assert store.run_tokens_cap == -1
    assert store.run_wall_time_cap == -1
    assert store.artifact_tokens_cap == -1
    assert store.artifact_wall_time_cap == -1


def test_g08_require_fresh_case_logic():
    import sys
    sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "scripts/refactor"))
    from benchmark_campaign import CampaignAuthorizationError
    from run_phase08_paired_passage_benchmark import _require_fresh_case
    import pytest

    class MockProvision:
        def __init__(self, already_completed=False, op_count=0):
            self.caseId = "test_case"
            self.alreadyCompleted = already_completed
            self.operationCount = op_count
            self.unknownOperationCount = 0
            self.completedOperationCount = 0

    # Clean case does not raise
    _require_fresh_case(MockProvision(already_completed=False, op_count=0))

    # Completed or used case raises CampaignAuthorizationError
    with pytest.raises(CampaignAuthorizationError):
        _require_fresh_case(MockProvision(already_completed=True, op_count=0))
    with pytest.raises(CampaignAuthorizationError):
        _require_fresh_case(MockProvision(already_completed=False, op_count=3))
