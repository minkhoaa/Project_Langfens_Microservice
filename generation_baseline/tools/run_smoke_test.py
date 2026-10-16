"""Live smoke test runner for RG10 (1 Reading + 1 Grammar task across A/B/C)."""
from __future__ import annotations

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
    ExperimentManifest,
    PromptVersionMap,
)
from app.experiment.campaign_runner import CampaignBatchExecutor, IndependentCampaignScorer
from app.experiment.final_dataset import FinalDatasetRegistry
from app.experiment.ledger import ExperimentReplayLedger
from app.experiment.paired import PairedAssignmentManager
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


def run_smoke_test() -> dict:
    api_key, base_url = load_credentials()
    smoke_dir = repo_root / "generation_baseline" / ".execution" / "RG10" / "smoke_test"
    smoke_dir.mkdir(parents=True, exist_ok=True)
    raw_responses_dir = smoke_dir / "raw_responses"
    raw_responses_dir.mkdir(parents=True, exist_ok=True)

    sources_dir = repo_root / "services" / "generation-service" / "tests" / "fixtures" / "corpus" / "sources"
    policies_dir = repo_root / "services" / "generation-service" / "tests" / "fixtures" / "policies"
    registry = FinalDatasetRegistry(corpus_sources_dir=sources_dir, policies_dir=policies_dir)
    reading_tasks = registry.build_reading_final_tasks()
    grammar_tasks = registry.build_grammar_final_tasks()

    # Pick 1 Reading task and 1 Grammar task for smoke test
    reading_fixture = reading_tasks[0]
    grammar_fixture = grammar_tasks[0]
    smoke_fixtures = [reading_fixture, grammar_fixture]

    assignment_manager = PairedAssignmentManager()
    smoke_assignments = [
        asg for f in smoke_fixtures for asg in assignment_manager.create_paired_assignments(f)
    ]
    print(f"[SMOKE] Smoke assignments count: {len(smoke_assignments)}")
    for asg in smoke_assignments:
        print(f"  - {asg.assignment_id} ({asg.dataset_item_id}, Arm {asg.configuration_id})")

    smoke_manifest = ExperimentManifest(
        experiment_id="exp-smoke-test-rg10",
        dataset_version="v1.0.0-smoke",
        split="FINAL_EVAL",
        source_sha256=hashlib.sha256(b"smoke_source").hexdigest(),
        code_commit_sha="9e81cda156e950d7e705df9effe23e685cc89de5",
        foundation_model_id="minimax/MiniMax-Text-01",
        prompt_versions=PromptVersionMap(A="v2.1", B="v2.2", C="v3.0"),
        rubric_version="rubric-qgeval-v2.0",
        assignments=smoke_assignments,
        primary_endpoint="independent_pass_under_frozen_rubric",
        analysis_plan_sha256=hashlib.sha256(b"smoke_analysis_plan").hexdigest(),
    )

    ledger_path = smoke_dir / "smoke_ledger.json"
    if ledger_path.exists():
        ledger_path.unlink()
    lock_path = smoke_dir / "smoke_ledger.lock"
    if lock_path.exists():
        lock_path.unlink()

    ledger = ExperimentReplayLedger(checkpoint_path=ledger_path)
    raw_store = RawResponseStore(storage_dir=raw_responses_dir)

    provider = MiniMaxProvider(base_url=base_url)
    client = OpenAICompatibleExperimentClient(
        provider=provider,
        api_key=api_key,
        max_tokens=4000,
        timeout_seconds=60.0,
        raw_response_store=raw_store,
    )

    runner_a = ConfigurationARunner(client=client)
    runner_b = ConfigurationBRunner(client=client)
    runner_c = ConfigurationCRunner(client=client)

    executor = CampaignBatchExecutor(
        assignment_manager=assignment_manager,
        ledger=ledger,
        client=client,
        runner_a=runner_a,
        runner_b=runner_b,
        runner_c=runner_c,
        manifest=smoke_manifest,
        raw_response_store=raw_store,
    )

    started_at = time.time()

    # 1. Execute Reading Smoke Batch (1 item x 3 arms)
    print("\n[SMOKE] Executing Reading Smoke Batch (Arm A, B, C)...")
    reading_state = executor.execute_reading_batch([reading_fixture], batch_index=1, allow_retries=False)
    print(f"[SMOKE] Reading batch status: {reading_state.status}")
    print(f"[SMOKE] Reading batch usage: {reading_state.usage_summary}")

    # 2. Execute Grammar Smoke Batch (1 item x 3 arms)
    print("\n[SMOKE] Executing Grammar Smoke Batch (Arm A, B, C)...")
    grammar_state = executor.execute_grammar_batch([grammar_fixture], batch_index=1, allow_retries=False)
    print(f"[SMOKE] Grammar batch status: {grammar_state.status}")
    print(f"[SMOKE] Grammar batch usage: {grammar_state.usage_summary}")

    elapsed_total = time.time() - started_at

    # 3. Independent Scoring of all outputs
    print("\n[SMOKE] Running Independent Evaluator on all generated outputs...")
    scorer = IndependentCampaignScorer()
    evaluations = {}
    for asg in smoke_assignments:
        res = ledger.get_output(f"att-{asg.assignment_id}-1")
        if res is not None:
            eval_res = scorer.score_generation_result(
                result=res,
                assignment=asg,
                rubric_version="rubric-qgeval-v2.0",
            )
            evaluations[asg.assignment_id] = {
                "evaluable": eval_res.evaluable,
                "verdict": eval_res.verdict.value,
                "evaluable_questions": eval_res.evaluable_question_count,
                "evaluated_questions": eval_res.evaluated_question_count,
                "scores": eval_res.semantic_scores,
                "output_sha256": eval_res.output_sha256,
            }
            print(f"  - {asg.assignment_id}: evaluable={eval_res.evaluable}, verdict={eval_res.verdict.value}, scores={eval_res.semantic_scores}")

    # 4. Check raw response files
    raw_files = list(raw_responses_dir.glob("*.json"))
    print(f"\n[SMOKE] Persisted raw responses count: {len(raw_files)}")
    assert len(raw_files) > 0, "No raw responses persisted to disk!"

    # 5. Check attempts and telemetry
    attempts = ledger.get_all_attempts()
    print(f"[SMOKE] Total recorded attempts: {len(attempts)}")
    total_tokens = sum(a.usage_total_tokens or 0 for a in attempts)
    total_calls = sum(a.usage_call_count for a in attempts)
    all_provider_tokens = all(a.token_source == "PROVIDER" and a.usage_confidence == "EXACT" for a in attempts)
    all_exact_model = all(a.provenance.get("dispatches", [{}])[0].get("actual_model_id") == "minimax/MiniMax-Text-01" for a in attempts)

    print(f"[SMOKE] Total calls across smoke test: {total_calls}")
    print(f"[SMOKE] Total provider tokens: {total_tokens}")
    print(f"[SMOKE] All attempts have EXACT provider token source: {all_provider_tokens}")
    print(f"[SMOKE] All dispatches match minimax/MiniMax-Text-01: {all_exact_model}")
    print(f"[SMOKE] Total duration: {elapsed_total:.1f}s")
    # Mandatory smoke test verification gates
    if not all_provider_tokens:
        raise RuntimeError("SMOKE TEST GATE FAILED: Some attempts did not report exact provider tokens!")
    if not all_exact_model:
        raise RuntimeError("SMOKE TEST GATE FAILED: Some dispatches did not use exact pinned model minimax/MiniMax-Text-01!")
    if len(raw_files) < total_calls:
        raise RuntimeError(f"SMOKE TEST GATE FAILED: Raw response files count ({len(raw_files)}) < total calls ({total_calls})!")
    if len(evaluations) != len(smoke_assignments):
        raise RuntimeError(f"SMOKE TEST GATE FAILED: Evaluated count ({len(evaluations)}) != assignments ({len(smoke_assignments)})!")
    if any(res is None for res in [ledger.get_output(f"att-{a.assignment_id}-1") for a in smoke_assignments]):
        raise RuntimeError("SMOKE TEST GATE FAILED: Ledger output missing for one or more smoke assignments!")
    if not all(ev.get("evaluable") for ev in evaluations.values()):
        raise RuntimeError(f"SMOKE TEST GATE FAILED: Unevaluable questions found in smoke test: {evaluations}!")

    client.close()
    ledger.close()

    batches_settled = reading_state.status in ("COMPLETED", "PARTIAL", "FAILED") and grammar_state.status in ("COMPLETED", "PARTIAL", "FAILED")
    mandatory_criteria_met = (
        batches_settled
        and all_provider_tokens
        and all_exact_model
        and len(raw_files) >= total_calls
        and len(evaluations) == len(smoke_assignments)
        and all(ev.get("evaluable") for ev in evaluations.values())
        and len(attempts) == len(smoke_assignments)
    )
    overall_status = "PASS" if mandatory_criteria_met else "FAILED"
    if overall_status != "PASS":
        raise RuntimeError(f"SMOKE TEST MANDATORY CRITERIA FAILED: settled={batches_settled}, tokens={all_provider_tokens}, model={all_exact_model}")


    report = {
        "status": overall_status,
        "reading_item_id": reading_fixture.dataset_item_id,
        "grammar_item_id": grammar_fixture.dataset_item_id,
        "total_assignments": len(smoke_assignments),
        "total_attempts": len(attempts),
        "total_calls": total_calls,
        "total_tokens": total_tokens,
        "raw_response_files_count": len(raw_files),
        "all_provider_tokens": all_provider_tokens,
        "all_exact_model": all_exact_model,
        "evaluations": evaluations,
        "reading_batch_status": reading_state.status,
        "grammar_batch_status": grammar_state.status,
        "elapsed_seconds": elapsed_total,
    }

    report_path = smoke_dir / "SMOKE_TEST_REPORT.json"
    report_path.write_text(json.dumps(report, indent=2))
    print(f"\n[SMOKE] Smoke test completed successfully. Report saved to: {report_path}")
    return report


if __name__ == "__main__":
    run_smoke_test()
