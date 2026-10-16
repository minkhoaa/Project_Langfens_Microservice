"""Evaluation, Human Review Export, Accounting Reconciliation, and Sealing Runner for RG10."""
from __future__ import annotations
import hashlib
import json
import os
import subprocess
import sys
import time
from pathlib import Path
repo_root = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(repo_root / "services" / "generation-service"))

from app.contracts.artifact import canonical_json_dump
from app.contracts.research import (
    ExecutionStatus,
    ExperimentAssignment,
    ExperimentManifest,
    PromptVersionMap,
)
from app.experiment.blind_review import BlindReviewManager
from app.experiment.campaign_manifest import CampaignManifestBuilder
from app.experiment.campaign_runner import (
    CampaignReconciliationManager,
    FinalResearchSnapshotSealer,
    IndependentCampaignScorer,
    SealedResearchSnapshot,
)
from app.experiment.final_dataset import FinalDatasetRegistry
from app.experiment.ledger import ExperimentReplayLedger
from app.experiment.paired import PairedAssignmentManager
from app.experiment.preregistration import PreregisteredAnalysisPlan


def get_git_commit_sha() -> str:
    try:
        res = subprocess.run(["git", "rev-parse", "HEAD"], capture_output=True, text=True, check=True)
        return res.stdout.strip()
    except Exception:
        return "UNKNOWN"


def get_git_worktree_dirty() -> bool:
    try:
        res = subprocess.run(["git", "status", "--porcelain"], capture_output=True, text=True, check=True)
        return bool(res.stdout.strip())
    except Exception:
        return True


def run_evaluation_and_sealing():
    campaign_dir = repo_root / "generation_baseline" / ".execution" / "RG10"
    ledger_path = campaign_dir / "campaign_ledger.json"
    if not ledger_path.exists():
        raise FileNotFoundError(f"Campaign ledger not found at: {ledger_path}")

    # 1. Setup registry & manifest
    sources_dir = repo_root / "services" / "generation-service" / "tests" / "fixtures" / "corpus" / "sources"
    policies_dir = repo_root / "services" / "generation-service" / "tests" / "fixtures" / "policies"
    registry = FinalDatasetRegistry(corpus_sources_dir=sources_dir, policies_dir=policies_dir)
    reading_tasks = registry.build_reading_final_tasks()
    grammar_tasks = registry.build_grammar_final_tasks()
    registry.generate_paired_assignments(attempt_number=1)

    plan = PreregisteredAnalysisPlan()
    builder = CampaignManifestBuilder()
    pv = PromptVersionMap(A="v2.1", B="v2.2", C="v3.0")
    manifest = builder.build_manifest(registry=registry, analysis_plan=plan, prompt_versions=pv)
    manifest_root_hash = builder.compute_manifest_root_hash(manifest)
    manifest_with_root = manifest.model_copy(update={"manifest_root_sha256": manifest_root_hash})
    print(f"[EVAL & SEAL] Manifest root hash: {manifest_root_hash}")

    ledger = ExperimentReplayLedger(checkpoint_path=ledger_path)
    print(f"[EVAL & SEAL] Total attempts in ledger: {len(ledger.get_all_attempts())}")

    # 2. Independent Evaluation across all eligible outputs
    print("\n[EVAL & SEAL] Running Independent Evaluator on all 168 assignments...")
    scorer = IndependentCampaignScorer()
    evaluations_ledger = {}
    scored_count = 0
    evaluable_count = 0

    for asg in manifest.assignments:
        lineage = ledger.get_attempt_lineage(asg.assignment_id)
        if not lineage:
            continue
        terminal_att = lineage[-1]
        output = ledger.get_output(terminal_att.attempt_id)
        if output is not None:
            existing_eval = ledger.get_evaluation(terminal_att.attempt_id)
            if existing_eval is not None:
                eval_dict = existing_eval
            else:
                eval_res = scorer.score_generation_result(
                    result=output,
                    assignment=asg,
                    rubric_version="rubric-qgeval-v2.0",
                )
                eval_dict = eval_res.model_dump(mode="json")
                ledger.record_evaluation(terminal_att.attempt_id, eval_res)
            evaluations_ledger[asg.assignment_id] = {
                "attempt_id": terminal_att.attempt_id,
                "dataset_item_id": asg.dataset_item_id,
                "configuration_id": asg.configuration_id,
                "execution_status": terminal_att.execution_status.value,
                "evaluation": eval_dict,
            }
            scored_count += 1
            if eval_dict.get("evaluable"):
                evaluable_count += 1
    print(f"[EVAL & SEAL] Scored {scored_count} outputs (evaluable: {evaluable_count})")

    evaluations_path = campaign_dir / "evaluations_ledger.json"
    evaluations_json = json.dumps(evaluations_ledger, sort_keys=True, separators=(",", ":"))
    evaluations_path.write_text(json.dumps(evaluations_ledger, indent=2))
    evaluations_ledger_sha256 = hashlib.sha256(evaluations_json.encode("utf-8")).hexdigest()
    print(f"[EVAL & SEAL] Evaluations ledger SHA256: {evaluations_ledger_sha256}")

    # 3. Campaign Completeness Reconciliation
    print("\n[EVAL & SEAL] Reconciling campaign completeness...")
    reconciler = CampaignReconciliationManager()
    completeness_report = reconciler.reconcile_campaign_completeness(ledger)
    reconciler.assert_no_unattempted_assignments(completeness_report)

    completeness_path = campaign_dir / "campaign_completeness_report.json"
    completeness_path.write_text(completeness_report.model_dump_json(indent=2))
    print(f"[EVAL & SEAL] Total frozen: {completeness_report.total_frozen_assignments}")
    # 4. Human Blind Review Subset Export
    print("\n[EVAL & SEAL] Exporting blinded human review subset...")
    blind_manager = BlindReviewManager()
    blind_items = []

    # Select stratified sample of evaluable outputs (up to 30 items across Reading and Grammar, Arms A/B/C)
    sampled_assignments = []
    for domain_tag in ("reading", "grammar"):
        domain_asgs = [a for a in manifest.assignments if domain_tag in a.assignment_id]
        for arm in ("A", "B", "C"):
            arm_asgs = [a for a in domain_asgs if a.configuration_id == arm]
            # Pick first 5 per arm per domain = 5 * 3 * 2 = 30
            sampled_assignments.extend(arm_asgs[:5])

    for asg in sampled_assignments:
        lineage = ledger.get_attempt_lineage(asg.assignment_id)
        if lineage:
            output = ledger.get_output(lineage[-1].attempt_id)
            if output is not None and output.generated_content is not None:
                domain = "READING" if "reading" in asg.assignment_id else "GRAMMAR"
                try:
                    item = blind_manager.export_blind_review_item(
                        assignment=asg,
                        generation_result=output,
                        domain=domain,
                        gold_answers={},  # Generator proposed answers are NOT gold; honest empty reference
                    )
                    blind_items.append(item.model_dump(mode="json"))
                except Exception as e:
                    print(f"  [WARN] Could not export {asg.assignment_id}: {e}")

    vault_hash = blind_manager.vault.seal_vault()

    blind_package = {
        "state": "BLIND_HUMAN_REVIEW_PACKAGE",
        "dataset_version": manifest.dataset_version,
        "total_sampled_items": len(blind_items),
        "blind_items": blind_items,
        "sealed_vault_hash": vault_hash,
        "human_adjudication_status": "PENDING_EXTERNAL",
        "human_adjudication_notes": (
            "Qualified external human reviewer panel not present in local workspace environment per AGENT_PIPELINE.md:41. "
            "Generated questions have no expert gold labels. Sealed vault isolates true arm identities."
        ),
    }

    blind_package_path = campaign_dir / "blind_human_review_package.json"
    blind_json = canonical_json_dump(blind_package)
    blind_package_path.write_text(json.dumps(blind_package, indent=2))
    human_review_ledger_sha256 = hashlib.sha256(blind_json.encode("utf-8")).hexdigest()
    print(f"[EVAL & SEAL] Exported {len(blind_items)} blinded items. Vault hash: {vault_hash[:16]}...")
    print(f"[EVAL & SEAL] Human review ledger SHA256: {human_review_ledger_sha256}")
    import subprocess
    porcelain_output = subprocess.check_output(["git", "status", "--porcelain", "-uall"], text=True)
    dirty_files = [line.strip().split(maxsplit=1)[-1] for line in porcelain_output.splitlines() if line.strip()]
    dirty_state_str = ", ".join(dirty_files)

    sealer = FinalResearchSnapshotSealer()
    worktree_hashes = {}
    for tf in dirty_files:
        full_path = repo_root / tf
        if full_path.is_file():
            worktree_hashes[tf] = sealer.compute_file_sha256(full_path)

    reproducibility_metadata = {
        "environment": "live_api_campaign",
        "python_version": sys.version,
        "foundation_model_id": "minimax/MiniMax-Text-01",
        "provider_base_url": "https://api.minimaxi.chat/v1",
        "prompt_versions_dispatched": {"A": "v2.1", "B": "v2.2", "C": "v3.0"},
        "standing_methodological_caveats": {
            "pipeline_architecture_vs_prompt_template": (
                "Arms A/B/C share the identical initial generation system prompt _GENERATION_SYSTEM. "
                "The prompt_version tags label distinct pipeline structures: A is direct single-shot, "
                "B includes self-critique and bounded revision, and C includes independent review, "
                "blind solving, and answer validation. Observed differences represent pipeline architectural "
                "effects rather than different base prompt template wording."
            ),
            "reading_verbatim_floor": (
                "Reading completion rate (19/84 = 22.6%) reflects the strict character-for-character "
                "verbatim passage matching invariant in parsing.py, where 65 of 84 Reading assignments failed on "
                "CONTEXT_MISMATCH; the surviving Reading subset is conditioned on the model echoing the PMC source "
                "passage without drift (selection effect)."
            ),
            "evaluator_profile": (
                "Evaluated by deterministic rule-based NeutralEvaluator (rubric-qgeval-v2.0) performing zero "
                "model inference. Because NeutralQuestion has no separate evidence_quote field, grounding and "
                "answerability default to the rule-based floor (<=2.0), resulting in zero questions reaching overall "
                "verdict PASS across any arm."
            ),
        },
        "sealing_policy": "FINAL_BATCH_RULES.md",
        "campaign_total_assignments": len(manifest.assignments),
        "campaign_total_attempts": len(ledger.get_all_attempts()),
        "campaign_total_calls": sum(a.usage_call_count or 0 for a in ledger.get_all_attempts()),
        "campaign_total_tokens": sum(a.usage_total_tokens or 0 for a in ledger.get_all_attempts()),
        "campaign_total_cost_usd": round(sum(a.usage_total_tokens or 0 for a in ledger.get_all_attempts()) * 0.0000015, 4),
        "superseded_snapshot_ids": [
            "snap-rq2-exp-ielts-rq2-final-2026-202b0a68",
            "snap-rq2-exp-ielts-rq2-final-2026-25f31cfd",
        ],
    }

    snapshot = sealer.seal_snapshot(
        manifest=manifest_with_root,
        ledger=ledger,
        evaluations_ledger_sha256=evaluations_ledger_sha256,
        human_review_ledger_sha256=human_review_ledger_sha256,
        code_commit_sha=get_git_commit_sha(),
        worktree_dirty=get_git_worktree_dirty(),
        dirty_state=dirty_state_str,
        worktree_content_hashes=worktree_hashes,
        reproducibility_metadata=reproducibility_metadata,
    )

    # Verify sealed snapshot integrity
    sealer.verify_snapshot_integrity(snapshot, snapshot.snapshot_root_sha256)
    print(f"[EVAL & SEAL] Snapshot sealed successfully!")
    print(f"[EVAL & SEAL] Snapshot Root SHA256: {snapshot.snapshot_root_sha256}")
    print(f"[EVAL & SEAL] Results Ledger SHA256: {snapshot.results_ledger_sha256}")

    snapshot_path = campaign_dir / "SEALED_RESEARCH_SNAPSHOT.json"
    snapshot_path.write_text(snapshot.model_dump_json(indent=2))

    ledger.close()
    return snapshot


if __name__ == "__main__":
    run_evaluation_and_sealing()
