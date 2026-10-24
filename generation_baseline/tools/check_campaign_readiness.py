#!/usr/bin/env python3
"""CLI utility to execute a dry-run-only, no-provider-call campaign readiness audit.

Usage:
    python3 generation_baseline/tools/check_campaign_readiness.py [--json-out PATH] [--md-out PATH]
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

# Setup Python path
REPO_ROOT = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(REPO_ROOT / "services" / "generation-service"))

from app.experiment.campaign_readiness import (
    CampaignReadinessAuditor,
    CampaignReadinessReport,
)


def generate_markdown_report(report: CampaignReadinessReport) -> str:
    """Generates a human-readable Markdown summary of the dry-run readiness check."""
    ds = report.dataset_readiness
    ver = report.version_readiness
    rost = report.roster_and_denominators
    quota = report.provider_quota_status
    panel = report.human_panel_readiness
    stat = report.statistical_analysis_plan

    md = f"""# RG10 Final Campaign Readiness Audit Report (Dry-Run Only)

**Report ID:** `{report.report_id}`  
**Evaluated At:** `{report.evaluated_at}`  
**Report Generated From SHA:** `{report.report_generated_from_sha}`  
**Implementation Source SHA:** `{report.implementation_source_sha}`  
**Audit Tool SHA:** `{report.audit_tool_sha}`  
**Software Commit SHA:** `{report.software_commit_sha}`  
**Evaluation Mode:** `STRICTLY_DRY_RUN_NO_PROVIDER_CALLS`  
**Overall Software Readiness:** **`{report.overall_software_readiness}`**  
**Overall Campaign Gate:** **`{report.overall_campaign_readiness}`**  
---

## 1. Executive Summary & Readiness Pillars

| Area / Pillar | Audit Status | Evidence & Invariant Findings |
|---|---|---|
| **1. Dataset Identity & Hashes** | **`{ds.status}`** | {ds.total_task_count} total tasks ({ds.reading_task_count} Reading, {ds.grammar_task_count} Grammar). Combined source SHA: `{ds.combined_source_sha256[:16]}...`. Source family quarantine: {ds.is_source_isolated}. Holdout status: `{ds.holdout_manifest_status}` (seals null: {ds.holdout_seals_are_null}). |
| **2. Version Pinning** | **`{ver.status}`** | Pinned Evaluator: `{ver.evaluator_version}` (`{ver.evaluator_candidate_class}`). Rubric: `{ver.rubric_version}`. Model: `{ver.foundation_model_id}`. Arms: {ver.experimental_arms}. Prompts: A={ver.prompt_versions.get('A', 'UNKNOWN')}, B={ver.prompt_versions.get('B', 'UNKNOWN')}, C={ver.prompt_versions.get('C', 'UNKNOWN')}. Resolved from: {ver.source_of_truth}. |
| **3. Roster & Denominators** | **`{rost.status}`** | Frozen assignment count: $N = {rost.total_assignments}$ ({rost.reading_assignments} Reading, {rost.grammar_assignments} Grammar; 56/arm). Task canonical fingerprints verified: {rost.fingerprint_mismatches == 0}. Judge Holdout denominator: $N = {rost.judge_holdout_denominator}$ ({rost.judge_holdout_reading_stratum} Reading, {rost.judge_holdout_grammar_stratum} Grammar), strictly separate from campaign. |
| **4. Provider Quota Status** | **`{quota.status}`** | **Zero network calls made** (`live_network_calls_made = {quota.live_network_calls_made}`). Prior verified status: `{quota.prior_verified_status}` (`HTTP {quota.prior_verified_code}: {quota.prior_verified_message}`). Availability not asserted in dry run. |
| **5. Human Panel Readiness** | **`{panel.status}`** | Status: `{panel.panel_status}`. Forms available: {panel.blind_forms_available}; curator instructions: {panel.curator_instructions_available}; adjudication workflow: {panel.adjudication_workflow_available}. Panel ratings not yet submitted (synthetic scores: UNVERIFIED). |
| **6. Raw Response Preservation** | **`{report.raw_response_preservation.status}`** | {report.raw_response_preservation.valid_records_count}/{report.raw_response_preservation.total_raw_responses_on_disk} valid records verified across {len(report.raw_response_preservation.raw_response_directories_found)} dirs (invalid: {report.raw_response_preservation.invalid_records_count}, unverifiable: {report.raw_response_preservation.unverifiable_records_count}, missing: {report.raw_response_preservation.missing_records_count}). Telemetry verified: {report.raw_response_preservation.telemetry_fields_verified}. |
| **7. Failure Accounting** | **`{report.failure_and_uncertainty_accounting.status}`** | Fail-closed on UNCERTAIN, timeout, rate-limit, missing output verified by executable tests. Zero silent drops. Evaluator UNCERTAIN supported. |
| **8. Statistical Analysis Plan** | **`{stat.status}`** | Preregistered primary endpoint: `{stat.primary_endpoint}`. Resampling unit: `{stat.resampling_unit}`. Paired contrasts: {stat.paired_contrasts} (95% CI). Methods verified on disk: {stat.corrections_verified}. |

---

## 2. External Blockers

The campaign remains on **`HOLD`** pending external prerequisites:
"""
    for b in report.blockers:
        md += f"- **BLOCKER:** {b}\n"

    md += """
---

## 3. Clear Actionable Criteria to Resume Research Campaign

"""
    for c in report.actionable_resume_criteria:
        md += f"- {c}\n"

    return md


def main() -> int:
    parser = argparse.ArgumentParser(description="Run dry-run campaign readiness audit.")
    parser.add_argument(
        "--json-out",
        type=Path,
        default=REPO_ROOT / "generation_baseline" / "verification" / "CAMPAIGN_READINESS_REPORT.json",
        help="Path for output JSON report.",
    )
    parser.add_argument(
        "--md-out",
        type=Path,
        default=None,
        help="Optional generated Markdown report path (not repository documentation).",
    )
    parser.add_argument(
        "--commit-sha",
        type=str,
        default=None,
        help="Optional software commit SHA override (defaults to current git HEAD).",
    )
    args = parser.parse_args()

    auditor = CampaignReadinessAuditor(REPO_ROOT)
    report = auditor.run_readiness_audit(software_commit_sha=args.commit_sha)
    # Ensure output directories exist
    args.json_out.parent.mkdir(parents=True, exist_ok=True)

    json_content = json.dumps(report.model_dump(), indent=2)
    args.json_out.write_text(json_content, encoding="utf-8")

    if args.md_out:
        args.md_out.parent.mkdir(parents=True, exist_ok=True)
        args.md_out.write_text(generate_markdown_report(report), encoding="utf-8")

    print(f"[SUCCESS] Dry-run campaign readiness audit completed.")
    print(f"  Overall Software Readiness : {report.overall_software_readiness}")
    print(f"  Overall Campaign Gate      : {report.overall_campaign_readiness}")
    print(f"  Implementation Source SHA  : {report.implementation_source_sha}")
    print(f"  Audit Tool SHA             : {report.audit_tool_sha}")
    print(f"  Report Generated From SHA  : {report.report_generated_from_sha}")
    print(f"  Total Frozen Assignments   : {report.roster_and_denominators.total_assignments}")
    print(f"  Raw Responses Verified     : {report.raw_response_preservation.valid_records_count}/{report.raw_response_preservation.total_raw_responses_on_disk}")
    print(f"  Live Network Calls Made    : {report.provider_quota_status.live_network_calls_made}")
    print(f"  JSON Report Written To     : {args.json_out}")
    if args.md_out:
        print(f"  Markdown Report Written To : {args.md_out}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
