"""Full A/B/C Campaign Executor for RG10 (Reading & Grammar 168 assignments).

Executes frozen paired tasks in bounded batches of at most 5 items per batch.
Records all attempts, raw provider responses, token telemetry, and atomic checkpoints.
Arbitrary self-imposed spending ceilings removed per RG10 remediation policy while
preserving provider constraints, rate bounds, request timeouts, and infinite loop guards.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
import time
from pathlib import Path

repo_root = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(repo_root / "services" / "generation-service"))

from app.contracts.research import (
    ExecutionStatus,
    ExperimentAssignment,
    ExperimentManifest,
    PromptVersionMap,
)
from app.experiment.campaign_manifest import CampaignManifestBuilder
from app.experiment.campaign_runner import (
    BatchExecutionState,
    CampaignBatchExecutor,
    CampaignReconciliationManager,
    FinalResearchSnapshotSealer,
    IndependentCampaignScorer,
)
from app.experiment.final_dataset import FinalDatasetRegistry
from app.experiment.ledger import ExperimentReplayLedger
from app.experiment.paired import PairedAssignmentManager
from app.experiment.preregistration import PreregisteredAnalysisPlan
from app.experiment.providers import OpenAICompatibleExperimentClient, RawResponseStore
from app.experiment.runners import (
    ConfigurationARunner,
    ConfigurationBRunner,
    ConfigurationCRunner,
)
from app.providers.adapters.minimax import MiniMaxProvider


def load_credentials() -> tuple[str, str]:
    ai_env = repo_root / "deploy" / "envs" / "ai.env"
    env_vars = {}
    for line in ai_env.read_text().splitlines():
        if "=" in line and not line.strip().startswith("#"):
            k, v = line.split("=", 1)
            env_vars[k.strip()] = v.strip()
    api_key = env_vars.get("MINIMAX_API_KEY", "")
    base_url = env_vars.get("MINIMAX_BASE_URL", "https://api.minimaxi.chat/v1")
    if not api_key:
        raise ValueError("MINIMAX_API_KEY missing from deploy/envs/ai.env")
    return api_key, base_url


def setup_campaign(domain_filter: str = "ALL"):
    api_key, base_url = load_credentials()
    campaign_dir = repo_root / "generation_baseline" / ".execution" / "RG10"
    campaign_dir.mkdir(parents=True, exist_ok=True)
    raw_responses_dir = campaign_dir / "raw_responses"
    raw_responses_dir.mkdir(parents=True, exist_ok=True)
    batch_states_dir = campaign_dir / "batch_states"
    batch_states_dir.mkdir(parents=True, exist_ok=True)

    sources_dir = repo_root / "services" / "generation-service" / "tests" / "fixtures" / "corpus" / "sources"
    policies_dir = repo_root / "services" / "generation-service" / "tests" / "fixtures" / "policies"

    registry = FinalDatasetRegistry(corpus_sources_dir=sources_dir, policies_dir=policies_dir)
    reading_tasks = registry.build_reading_final_tasks()
    grammar_tasks = registry.build_grammar_final_tasks()
    registry.generate_paired_assignments(attempt_number=1)

    print(f"[CAMPAIGN] Total frozen reading tasks: {len(reading_tasks)}")
    print(f"[CAMPAIGN] Total frozen grammar tasks: {len(grammar_tasks)}")
    print(f"[CAMPAIGN] Total frozen assignments: {len(registry.assignments)}")

    plan = PreregisteredAnalysisPlan()
    builder = CampaignManifestBuilder()
    pv = PromptVersionMap(A="v2.1", B="v2.2", C="v3.0")
    manifest = builder.build_manifest(registry=registry, analysis_plan=plan, prompt_versions=pv)
    manifest_root_hash = builder.compute_manifest_root_hash(manifest)
    print(f"[CAMPAIGN] Manifest root hash: {manifest_root_hash}")

    ledger_path = campaign_dir / "campaign_ledger.json"
    ledger = ExperimentReplayLedger(checkpoint_path=ledger_path)
    raw_store = RawResponseStore(storage_dir=raw_responses_dir)

    prior_attempts = ledger.get_all_attempts()
    prior_tokens = sum(a.usage_total_tokens or 0 for a in prior_attempts)
    prior_cost = prior_tokens * 0.0000015
    print(f"[CAMPAIGN] Authoritative prior usage from ledger: {len(prior_attempts)} attempts, {prior_tokens} tokens, ${prior_cost:.4f} USD")

    provider = MiniMaxProvider(base_url=base_url)
    client = OpenAICompatibleExperimentClient(
        provider=provider,
        api_key=api_key,
        max_tokens=4000,
        timeout_seconds=60.0,
        raw_response_store=raw_store,
    )
    client.cumulative_tokens = prior_tokens
    client.cumulative_spent_usd = prior_cost
    # Arbitrary resource ceiling removed per RG10 remediation policy (defaults to None)
    runner_a = ConfigurationARunner(client=client)
    runner_b = ConfigurationBRunner(client=client)
    runner_c = ConfigurationCRunner(client=client)

    assignment_manager = PairedAssignmentManager()
    for asg in manifest.assignments:
        assignment_manager.register_assignment(asg)

    executor = CampaignBatchExecutor(
        assignment_manager=assignment_manager,
        ledger=ledger,
        client=client,
        runner_a=runner_a,
        runner_b=runner_b,
        runner_c=runner_c,
        manifest=manifest,
        raw_response_store=raw_store,
    )

    return {
        "manifest": manifest,
        "manifest_root_hash": manifest_root_hash,
        "registry": registry,
        "reading_tasks": reading_tasks,
        "grammar_tasks": grammar_tasks,
        "executor": executor,
        "ledger": ledger,
        "client": client,
        "raw_store": raw_store,
        "campaign_dir": campaign_dir,
        "batch_states_dir": batch_states_dir,
    }


def execute_domain(ctx, domain: str, max_retries: int = 1, specific_batch: int | None = None):
    executor = ctx["executor"]
    ledger = ctx["ledger"]
    client = ctx["client"]
    batch_states_dir = ctx["batch_states_dir"]

    fixtures = ctx["reading_tasks"] if domain == "READING" else ctx["grammar_tasks"]
    batches = executor.partition_batches(fixtures, max_items_per_batch=5)
    print(f"\n[CAMPAIGN] === Executing {domain} Campaign: {len(fixtures)} items across {len(batches)} batches ===")

    batch_states = []
    for idx, batch_fixtures in enumerate(batches, start=1):
        if specific_batch is not None and idx != specific_batch:
            continue
        batch_file = batch_states_dir / f"batch_{domain.lower()}_{idx:02d}.json"
        resume_state = None
        if batch_file.exists():
            try:
                resume_state = BatchExecutionState.model_validate_json(batch_file.read_text())
                print(f"[CAMPAIGN] Found existing batch state for {domain} batch {idx}: {resume_state.status}")
            except Exception as e:
                print(f"[CAMPAIGN] Warning reading existing batch state: {e}")

        t0 = time.time()
        print(f"[CAMPAIGN] Running {domain} Batch {idx}/{len(batches)} ({len(batch_fixtures)} items)...")
        if domain == "READING":
            state = executor.execute_reading_batch(
                batch_fixtures, batch_index=idx, resume_state=resume_state,
                allow_retries=True, max_retries=max_retries,
            )
        else:
            state = executor.execute_grammar_batch(
                batch_fixtures, batch_index=idx, resume_state=resume_state,
                allow_retries=True, max_retries=max_retries,
            )
        elapsed = time.time() - t0

        batch_file.write_text(state.model_dump_json(indent=2))
        batch_states.append(state)
        print(f"[CAMPAIGN] Batch {idx} finished in {elapsed:.1f}s — Status: {state.status}, Tokens: {state.usage_summary.get('total_tokens')}, Cumulative spent: ${client.cumulative_spent_usd:.4f}")

    return batch_states


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--domain", choices=["READING", "GRAMMAR", "ALL"], default="ALL")
    parser.add_argument("--batch", type=int, default=None, help="Specific batch index (1-6)")
    parser.add_argument("--retries", type=int, default=1)
    args = parser.parse_args()

    ctx = setup_campaign()
    client = ctx["client"]
    ledger = ctx["ledger"]

    started_time = time.time()
    try:
        if args.domain in ("READING", "ALL"):
            execute_domain(ctx, "READING", max_retries=args.retries, specific_batch=args.batch)

        if args.domain in ("GRAMMAR", "ALL"):
            execute_domain(ctx, "GRAMMAR", max_retries=args.retries, specific_batch=args.batch)
    finally:
        total_time = time.time() - started_time
        print(f"\n[CAMPAIGN] Campaign run loop ended in {total_time:.1f}s.")
        print(f"[CAMPAIGN] Final Cumulative Provider Tokens: {client.cumulative_tokens}")
        print(f"[CAMPAIGN] Final Cumulative Spent USD: ${client.cumulative_spent_usd:.4f}")
        client.close()
        ledger.close()


if __name__ == "__main__":
    main()
