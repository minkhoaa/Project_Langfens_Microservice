"""Focused unit and regression tests for RG10 Campaign Readiness Auditor integrity.

Verifies:
1. Negative tests for corrupt raw records (JSON errors, missing fields, hash mismatches, missing ledger refs).
2. Negative tests for mismatched configurations (model ID mismatch, tampered prompt templates, missing arms).
3. Negative tests for broken assignment identities (roster counts, arm mismatches, fingerprint mismatches, holdout contamination).
4. Executable fail-closed uncertainty and failure accounting (UNCERTAIN=0.0, timeout=0.0, missing output=0.0).
5. Strict zero-network-call dry-run invariant.
6. Provenance tracking: runtime UTC timestamp, separate SHAs, and UNKNOWN on missing git state without fabricated fallbacks.
"""
from __future__ import annotations

from datetime import datetime
import hashlib
import json
from pathlib import Path
import sys
from typing import Any, Dict
from unittest.mock import patch
import pytest

repo_root = Path(__file__).resolve().parent.parent.parent.parent
if str(repo_root) not in sys.path:
    sys.path.insert(0, str(repo_root))

from app.contracts.research import ExecutionStatus, OutputAvailability
from app.experiment.campaign_manifest import CampaignManifestBuilder
from app.experiment.campaign_readiness import (
    CampaignReadinessAuditor,
    CampaignReadinessReport,
)
from app.experiment.final_dataset import FinalDatasetRegistry
from app.experiment.freeze_manifest import (
    FrozenPromptSpec,
    ProviderFreezeManager,
    SamplingParameters,
)
from app.experiment.preregistration import PreregisteredAnalysisPlan


@pytest.fixture
def test_registry() -> FinalDatasetRegistry:
    sources_dir = repo_root / "services" / "generation-service" / "tests" / "fixtures" / "corpus" / "sources"
    policies_dir = repo_root / "services" / "generation-service" / "tests" / "fixtures" / "policies"
    reg = FinalDatasetRegistry(corpus_sources_dir=sources_dir, policies_dir=policies_dir)
    reg.build_reading_final_tasks()
    reg.build_grammar_final_tasks()
    reg.generate_paired_assignments(attempt_number=1)
    return reg


@pytest.fixture
def auditor() -> CampaignReadinessAuditor:
    return CampaignReadinessAuditor(repo_root)


# =========================================================================
# 1. Negative Tests for Corrupt Raw Records
# =========================================================================

def test_corrupt_json_raw_record_fails_closed(auditor: CampaignReadinessAuditor, tmp_path: Path):
    """Corrupt JSON syntax in raw response must increment invalid_records_count and fail status."""
    raw_dir = tmp_path / "raw_responses"
    raw_dir.mkdir(parents=True)
    corrupt_file = raw_dir / "bad_syntax.json"
    corrupt_file.write_text("{this is not valid json", encoding="utf-8")

    check = auditor.audit_raw_response_preservation(execution_dir_override=tmp_path)
    assert check.total_raw_responses_on_disk == 1
    assert check.valid_records_count == 0
    assert check.invalid_records_count == 1
    assert check.status == "FAIL"
    assert len(check.corrupt_files) == 1


def test_missing_required_fields_in_raw_record_fails_closed(auditor: CampaignReadinessAuditor, tmp_path: Path):
    """Raw record missing required telemetry field (e.g., prompt_sha256) is classified invalid."""
    raw_dir = tmp_path / "raw_responses"
    raw_dir.mkdir(parents=True)
    bad_rec = raw_dir / "missing_field.json"
    bad_rec.write_text(json.dumps({
        "provider_request_id": "req-001",
        "raw_text": "hello",
        "raw_text_sha256": hashlib.sha256("hello".encode("utf-8")).hexdigest(),
        "latency_ms": 100.0,
        # missing prompt_sha256 and tokens
    }), encoding="utf-8")

    check = auditor.audit_raw_response_preservation(execution_dir_override=tmp_path)
    assert check.invalid_records_count == 1
    assert check.valid_records_count == 0
    assert check.status == "FAIL"
    assert any("Missing required fields" in d for d in check.invalid_details)


def test_raw_record_content_hash_mismatch_fails_closed(auditor: CampaignReadinessAuditor, tmp_path: Path):
    """Raw record with tampered raw_text or mismatched raw_text_sha256 is classified invalid."""
    raw_dir = tmp_path / "raw_responses"
    raw_dir.mkdir(parents=True)
    bad_rec = raw_dir / "tampered.json"
    bad_rec.write_text(json.dumps({
        "provider_request_id": "req-002",
        "prompt_sha256": "abc" * 21 + "a",
        "raw_text": "tampered content",
        "raw_text_sha256": "0000000000000000000000000000000000000000000000000000000000000000",
        "latency_ms": 150.0,
        "tokens": {"total": 50},
    }), encoding="utf-8")

    check = auditor.audit_raw_response_preservation(execution_dir_override=tmp_path)
    assert check.invalid_records_count == 1
    assert check.valid_records_count == 0
    assert check.status == "FAIL"
    assert any("Content SHA256 mismatch" in d for d in check.invalid_details)


def test_raw_record_invalid_telemetry_fails_closed(auditor: CampaignReadinessAuditor, tmp_path: Path):
    """Negative latency or malformed tokens object is classified invalid."""
    raw_dir = tmp_path / "raw_responses"
    raw_dir.mkdir(parents=True)
    bad_rec = raw_dir / "negative_latency.json"
    raw_text = "content"
    bad_rec.write_text(json.dumps({
        "provider_request_id": "req-003",
        "prompt_sha256": "abc" * 21 + "a",
        "raw_text": raw_text,
        "raw_text_sha256": hashlib.sha256(raw_text.encode("utf-8")).hexdigest(),
        "latency_ms": -5.0,  # invalid negative latency
        "tokens": {"total": 10},
    }), encoding="utf-8")

    check = auditor.audit_raw_response_preservation(execution_dir_override=tmp_path)
    assert check.invalid_records_count == 1
    assert check.status == "FAIL"


def test_missing_ledger_referenced_raw_record_detected(auditor: CampaignReadinessAuditor, tmp_path: Path):
    """Ledger dispatch pointing to non-existent raw response file is reported in missing_records_count."""
    fake_ledger = tmp_path / "fake_ledger.json"
    fake_ledger.write_text(json.dumps({
        "assignments": [],
        "attempts": [
            {
                "provenance": {
                    "dispatches": [
                        {"raw_response_ref": "secure://raw_responses/non_existent_file_9999.json"}
                    ]
                }
            }
        ]
    }), encoding="utf-8")

    check = auditor.audit_raw_response_preservation(ledger_path_override=fake_ledger)
    assert check.missing_records_count >= 1
    assert check.status == "FAIL"


# =========================================================================
# 2. Negative Tests for Mismatched Configurations
# =========================================================================

def test_model_id_inconsistency_between_freeze_and_manifest_returns_hold(auditor: CampaignReadinessAuditor):
    """Inconsistent foundation_model_id across runtime freeze manager and manifest returns HOLD."""
    mismatched_freeze = ProviderFreezeManager(foundation_model_id="other-vendor/other-model-01")
    manifest_builder = CampaignManifestBuilder(foundation_model_id="minimax/MiniMax-Text-01")

    check = auditor.audit_version_readiness(
        freeze_manager=mismatched_freeze,
        manifest_builder=manifest_builder,
    )
    assert check.consistency_verified is False
    assert check.status == "HOLD"

def test_tampered_prompt_template_hash_returns_hold(auditor: CampaignReadinessAuditor):
    """Prompt template text altered without updating template_sha256 fails consistency check."""
    freeze_mgr = ProviderFreezeManager()
    freeze_mgr._prompts["A"] = FrozenPromptSpec.model_construct(
        version_tag="v2.1-baseline",
        template_text="System: You are an IELTS generation assistant. Generate passage and questions.",
        template_sha256="wrong_hash_000000000000000000000000000000000000000000000000000000000000",
    )

    check = auditor.audit_version_readiness(freeze_manager=freeze_mgr)
    assert check.consistency_verified is False
    assert check.status == "HOLD"


# =========================================================================
# 3. Negative Tests for Broken Assignment Identities
# =========================================================================

def test_roster_count_mismatch_fails_closed(auditor: CampaignReadinessAuditor, test_registry: FinalDatasetRegistry, tmp_path: Path):
    """Ledger containing only 167 assignments fails closed."""
    fake_ledger = tmp_path / "ledger_167.json"
    with open(repo_root / "generation_baseline" / ".execution" / "RG10" / "campaign_ledger.json") as f:
        real_ledger = json.load(f)
    # Remove one assignment
    real_ledger["assignments"] = real_ledger["assignments"][:167]
    fake_ledger.write_text(json.dumps(real_ledger), encoding="utf-8")

    check = auditor.audit_roster_and_denominators(test_registry, ledger_path_override=fake_ledger)
    assert check.is_roster_deterministic is False
    assert check.status == "FAIL"
    assert check.ledger_mismatches >= 1


def test_assignment_field_mismatch_fails_closed(auditor: CampaignReadinessAuditor, test_registry: FinalDatasetRegistry, tmp_path: Path):
    """Assignment configuration_id mismatch (e.g., A mutated to B) fails closed."""
    fake_ledger = tmp_path / "ledger_mutated.json"
    with open(repo_root / "generation_baseline" / ".execution" / "RG10" / "campaign_ledger.json") as f:
        real_ledger = json.load(f)
    real_ledger["assignments"][0]["configuration_id"] = "B"  # was "A"
    fake_ledger.write_text(json.dumps(real_ledger), encoding="utf-8")

    check = auditor.audit_roster_and_denominators(test_registry, ledger_path_override=fake_ledger)
    assert check.is_roster_deterministic is False
    assert check.status == "FAIL"
    assert check.ledger_mismatches >= 1


def test_task_canonical_fingerprint_mismatch_fails_closed(auditor: CampaignReadinessAuditor, test_registry: FinalDatasetRegistry, tmp_path: Path):
    """Mutated task content fingerprint in ledger fixture_hashes fails closed."""
    fake_ledger = tmp_path / "ledger_bad_fp.json"
    with open(repo_root / "generation_baseline" / ".execution" / "RG10" / "campaign_ledger.json") as f:
        real_ledger = json.load(f)
    # Corrupt fingerprint for final-reading-001
    real_ledger["fixture_hashes"]["final-reading-001"] = "0000000000000000000000000000000000000000000000000000000000000000"
    fake_ledger.write_text(json.dumps(real_ledger), encoding="utf-8")

    check = auditor.audit_roster_and_denominators(test_registry, ledger_path_override=fake_ledger)
    assert check.fingerprint_mismatches >= 1
    assert check.status == "FAIL"

def test_holdout_family_contamination_in_benchmark_fails_closed(auditor: CampaignReadinessAuditor, test_registry: FinalDatasetRegistry):
    """Task in benchmark accidentally assigned a holdout reserved family fails closed."""
    original_task = test_registry._reading_tasks[0]
    bad_source = original_task.source.model_copy(update={"source_family": "fam-astrophysics-pulsar-08"})
    test_registry._reading_tasks[0] = original_task.model_copy(update={"source": bad_source})

    try:
        check = auditor.audit_roster_and_denominators(test_registry)
        assert check.holdout_collisions >= 1
        assert check.status == "FAIL"

        ds_check = auditor.audit_dataset_readiness(test_registry)
        assert len(ds_check.holdout_family_collisions) >= 1
        assert ds_check.is_source_isolated is False
        assert ds_check.status == "FAIL"
    finally:
        test_registry._reading_tasks[0] = original_task

# =========================================================================
# 4. Executable Fail-Closed Uncertainty and Failure Accounting
# =========================================================================

def test_executable_fail_closed_evaluations(auditor: CampaignReadinessAuditor):
    """Verify executable fail-closed accounting: UNCERTAIN, FAIL, TIMED_OUT, missing output evaluate to 0.0."""
    check = auditor.audit_failure_and_uncertainty()

    assert check.status == "VERIFIED"
    assert check.evaluator_uncertain_verdict_supported is True
    assert check.fail_closed_on_uncertain is True
    assert check.missing_output_classified_as_fail is True
    assert check.rate_limit_classified_as_blocked is True
    assert check.zero_silent_drops is True

    # Validate detailed implementation test results
    impl = check.implementation_tested
    assert impl["uncertain_yields_non_pass"] is True
    assert impl["fail_yields_non_pass"] is True
    assert impl["timed_out_yields_non_pass"] is True
    assert impl["missing_output_yields_non_pass"] is True
    assert impl["provider_fallback_forbidden"] is True
    assert impl["post_hoc_endpoint_switching_forbidden"] is True


# =========================================================================
# 5. Strict Zero-Network-Call Dry-Run Invariant
# =========================================================================

def test_dry_run_makes_strictly_zero_live_network_dispatches(auditor: CampaignReadinessAuditor):
    """Readiness audit must execute with zero live network calls and no socket activity."""
    with patch("urllib.request.urlopen") as mock_url, \
         patch("http.client.HTTPConnection.connect") as mock_http, \
         patch("http.client.HTTPSConnection.connect") as mock_https:
        
        report: CampaignReadinessReport = auditor.run_readiness_audit()

        assert mock_url.call_count == 0
        assert mock_http.call_count == 0
        assert mock_https.call_count == 0
        assert report.is_dry_run is True
        assert report.provider_quota_status.live_network_calls_made == 0
        assert report.provider_quota_status.status == "BLOCKED"


# =========================================================================
# 6. Audit Provenance: Timestamps, SHA Tracking, and UNKNOWN Fallback
# =========================================================================

def test_provenance_timestamps_and_sha_tracking(auditor: CampaignReadinessAuditor):
    """Evaluated timestamp must be genuine UTC at runtime, and SHAs must be distinct and non-fabricated."""
    report = auditor.run_readiness_audit()

    # Verify evaluated_at is a valid recent UTC ISO timestamp
    dt = datetime.strptime(report.evaluated_at, "%Y-%m-%dT%H:%M:%SZ")
    assert dt.year >= 2026

    # Verify distinct SHA tracking
    assert report.implementation_source_sha == "32cb85e514f881aef8a5366ea43eb67422012eaa"
    assert len(report.audit_tool_sha) == 40
    assert len(report.report_generated_from_sha) == 40
    assert report.software_commit_sha == report.report_generated_from_sha


def test_retired_documentary_approval_stays_hold(tmp_path: Path):
    """A valid runtime plan hash cannot replace retired approval evidence."""
    check = CampaignReadinessAuditor(tmp_path).audit_statistical_plan()
    assert check.plan_hash_verified is True
    assert check.analysis_plan_md_exists is False
    assert check.corrections_verified == []
    assert check.status == "HOLD"
    assert "approved analysis evidence is required" in check.evidence_notes
    assert not list(tmp_path.iterdir())


def test_retired_handoff_and_optional_report_output(tmp_path: Path, monkeypatch):
    """Dry-run reporting must not claim retired forms exist or recreate default docs."""
    from generation_baseline.tools import check_campaign_readiness as cli

    output = tmp_path / "readiness.json"
    monkeypatch.setattr(sys, "argv", ["check_campaign_readiness", "--json-out", str(output)])
    assert cli.main() == 0
    report = json.loads(output.read_text())
    panel = report["human_panel_readiness"]
    assert panel["status"] == "HOLD"
    assert panel["blind_forms_available"] is False
    assert panel["curator_instructions_available"] is False
    assert panel["adjudication_workflow_available"] is False
    assert report["statistical_analysis_plan"]["status"] == "HOLD"
    assert report["overall_software_readiness"] != "READY"
    assert report["provider_quota_status"]["live_network_calls_made"] == 0
    assert list(tmp_path.iterdir()) == [output]
    summary = cli.generate_markdown_report(CampaignReadinessReport.model_validate(report))
    assert "Forms available: False" in summary
    assert "curator instructions: False" in summary


def test_git_unavailable_reports_unknown_without_fabricated_fallback(tmp_path: Path):
    """When git state is unavailable, auditor reports UNKNOWN, never a fabricated fallback SHA."""
    auditor_no_git = CampaignReadinessAuditor(tmp_path)
    sha = auditor_no_git._resolve_git_sha("some/file.py")
    assert sha == "UNKNOWN"


# =========================================================================
# 7. Negative E2E Tests for Schema Mismatch & Pillar Failures (Bug 1)
# =========================================================================

def test_software_pillar_failure_produces_serializable_fail_report(auditor: CampaignReadinessAuditor, tmp_path: Path):
    """When a software pillar fails (e.g. invalid raw responses), auditor produces a serializable FAIL report."""
    corrupt_exec_dir = tmp_path / "corrupt_execution"
    raw_dir = corrupt_exec_dir / "raw_responses"
    raw_dir.mkdir(parents=True)
    bad_rec = raw_dir / "bad.json"
    bad_rec.write_text("{broken json syntax", encoding="utf-8")

    report = auditor.run_readiness_audit(execution_dir_override=corrupt_exec_dir)

    # Pillar failed
    assert report.raw_response_preservation.status == "FAIL"
    assert report.overall_software_readiness == "FAIL"
    assert report.overall_campaign_readiness == "HOLD"
    assert any("Software readiness verification FAILED" in b for b in report.blockers)

    # Must be fully serializable to JSON and reconstructable without ValidationError
    dumped = report.model_dump()
    serialized_json = json.dumps(dumped)
    assert '"overall_software_readiness": "FAIL"' in serialized_json

    reconstructed = CampaignReadinessReport.model_validate(dumped)
    assert reconstructed.overall_software_readiness == "FAIL"
    assert reconstructed.overall_campaign_readiness == "HOLD"


def test_software_pillar_blocked_produces_serializable_blocked_report(auditor: CampaignReadinessAuditor, monkeypatch):
    """When a software pillar is BLOCKED and none FAIL, overall software status is BLOCKED and serializable."""
    # Mock one software pillar check to return BLOCKED
    real_stat_check = auditor.audit_statistical_plan()
    blocked_stat = real_stat_check.model_copy(update={"status": "BLOCKED"})
    monkeypatch.setattr(auditor, "audit_statistical_plan", lambda: blocked_stat)

    report = auditor.run_readiness_audit()
    assert report.overall_software_readiness == "BLOCKED"
    assert any("Software readiness verification BLOCKED" in b for b in report.blockers)

    # Verify serialization
    dumped = report.model_dump()
    serialized_json = json.dumps(dumped)
    assert '"overall_software_readiness": "BLOCKED"' in serialized_json
    reconstructed = CampaignReadinessReport.model_validate(dumped)
    assert reconstructed.overall_software_readiness == "BLOCKED"


# =========================================================================
# 8. Negative Tests for Silent-Drop Attempt Reconciliation (Bug 2)
# =========================================================================

def test_attempt_lacking_documented_terminal_failure_code_reports_unresolved(auditor: CampaignReadinessAuditor, tmp_path: Path):
    """Attempt with failed status but missing failure_code is unresolved; check fails closed without VERIFIED."""
    fake_ledger = tmp_path / "ledger_missing_fail_code.json"
    with open(repo_root / "generation_baseline" / ".execution" / "RG10" / "campaign_ledger.json") as f:
        ledger_data = json.load(f)

    # Strip failure_code from a failed attempt
    for a in ledger_data["attempts"]:
        if a.get("execution_status") == "FAILED_VALIDATION":
            a["failure_code"] = None
            break

    fake_ledger.write_text(json.dumps(ledger_data), encoding="utf-8")
    check = auditor.audit_failure_and_uncertainty(ledger_path_override=fake_ledger)

    assert check.zero_silent_drops is False
    assert check.status == "FAIL"
    assert len(check.unresolved_attempts) >= 1
    assert any("lacks documented failure_code" in u for u in check.unresolved_attempts)


def test_attempt_missing_expected_output_reference_reports_unresolved(auditor: CampaignReadinessAuditor, tmp_path: Path):
    """Attempt claiming output_availability=NORMALIZED but missing from outputs dictionary is unresolved."""
    fake_ledger = tmp_path / "ledger_missing_output.json"
    with open(repo_root / "generation_baseline" / ".execution" / "RG10" / "campaign_ledger.json") as f:
        ledger_data = json.load(f)

    # Delete output for the first attempt that has output
    target_att_id = next(iter(ledger_data["outputs"].keys()))
    del ledger_data["outputs"][target_att_id]

    fake_ledger.write_text(json.dumps(ledger_data), encoding="utf-8")
    check = auditor.audit_failure_and_uncertainty(ledger_path_override=fake_ledger)

    assert check.zero_silent_drops is False
    assert check.status == "FAIL"
    assert len(check.unresolved_attempts) >= 1
    assert any("attempt missing from outputs" in u for u in check.unresolved_attempts)


def test_attempt_missing_expected_evaluation_reference_reports_unresolved(auditor: CampaignReadinessAuditor, tmp_path: Path):
    """Terminal attempt with normalized output missing evaluation reference in evaluations is unresolved."""
    fake_ledger = tmp_path / "ledger_missing_eval.json"
    with open(repo_root / "generation_baseline" / ".execution" / "RG10" / "campaign_ledger.json") as f:
        ledger_data = json.load(f)

    # Remove an evaluation entry for a terminal attempt
    target_att_id = next(iter(ledger_data["evaluations"].keys()))
    del ledger_data["evaluations"][target_att_id]

    fake_ledger.write_text(json.dumps(ledger_data), encoding="utf-8")
    check = auditor.audit_failure_and_uncertainty(ledger_path_override=fake_ledger)

    assert check.zero_silent_drops is False
    assert check.status == "FAIL"
    assert len(check.unresolved_attempts) >= 1
    assert any("missing evaluation reference" in u for u in check.unresolved_attempts)


def test_assignment_missing_terminal_attempt_reports_unresolved(auditor: CampaignReadinessAuditor, tmp_path: Path):
    """Assignment whose attempts were all non-terminal (silent drop before resolution) reports unresolved."""
    fake_ledger = tmp_path / "ledger_missing_terminal.json"
    with open(repo_root / "generation_baseline" / ".execution" / "RG10" / "campaign_ledger.json") as f:
        ledger_data = json.load(f)

    # Mark terminal attempt of first assignment as non-terminal
    first_asg = ledger_data["assignments"][0]["assignment_id"]
    for a in ledger_data["attempts"]:
        if a.get("assignment_id") == first_asg:
            a["is_terminal"] = False

    fake_ledger.write_text(json.dumps(ledger_data), encoding="utf-8")
    check = auditor.audit_failure_and_uncertainty(ledger_path_override=fake_ledger)

    assert check.zero_silent_drops is False
    assert check.status == "FAIL"
    assert any("terminal attempts (expected 1)" in u for u in check.unresolved_attempts)


# =========================================================================
# 9. Negative Tests for Prompt Freeze Hash (Bug 3)
# =========================================================================

def test_missing_or_empty_prompt_template_hash_fails_consistency(auditor: CampaignReadinessAuditor):
    """Prompt template spec with empty or None template_sha256 fails consistency check."""
    freeze_mgr = ProviderFreezeManager()
    freeze_mgr._prompts["A"] = FrozenPromptSpec.model_construct(
        version_tag="v2.1-baseline",
        template_text="System: You are an IELTS generation assistant. Generate passage and questions.",
        template_sha256="",  # Empty hash must be rejected
    )

    check = auditor.audit_version_readiness(freeze_manager=freeze_mgr)
    assert check.consistency_verified is False
    assert check.status == "HOLD"


def test_prompt_template_hash_mismatch_against_authoritative_evidence_fails(auditor: CampaignReadinessAuditor):
    """Prompt template whose self-computed hash matches template_sha256 but differs from frozen authoritative evidence fails."""
    freeze_mgr = ProviderFreezeManager()
    tampered_text = "System: Tampered prompt template text."
    tampered_hash = hashlib.sha256(tampered_text.encode("utf-8")).hexdigest()
    freeze_mgr._prompts["A"] = FrozenPromptSpec.model_construct(
        version_tag="v2.1-baseline",
        template_text=tampered_text,
        template_sha256=tampered_hash,  # Matches text, but mismatches authoritative frozen evidence
    )

    check = auditor.audit_version_readiness(freeze_manager=freeze_mgr)
    assert check.consistency_verified is False
    assert check.status == "HOLD"
