"""Genuine Live DEV Experiment Runner for RG10 Remediation.

Runs 6 genuine live assignments across Reading and Grammar (Arms A, B, C)
against api.minimaxi.chat/v1 using MiniMax-Text-01 on DEV-split fixtures.
Evaluates resulting outputs with NeutralEvaluatorV2 (v2.1).
Writes all results and evidence to generation_baseline/.execution/RG10_REMEDIATION/.
"""
from __future__ import annotations

import json
import os
import sys
import time
from pathlib import Path

repo_root = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(repo_root / "services" / "generation-service"))

from app.contracts.research import (
    ExecutionStatus,
    GrammarExerciseType,
    GrammarRulePack,
    GrammarTask,
    OutputAvailability,
    PairedTaskFixture,
    PromptVersionMap,
    ReadingTask,
    SourceRef,
    StandaloneGroupType,
)
from app.evaluators.independent import NeutralEvaluatorV2
from app.experiment.ledger import ExperimentReplayLedger
from app.experiment.paired import PairedAssignmentManager
from app.experiment.pilot import DevPilotRunner
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


def main():
    api_key, base_url = load_credentials()
    remediation_dir = repo_root / "generation_baseline" / ".execution" / "RG10_REMEDIATION"
    remediation_dir.mkdir(parents=True, exist_ok=True)
    raw_responses_dir = remediation_dir / "raw_responses"
    raw_responses_dir.mkdir(parents=True, exist_ok=True)

    raw_store = RawResponseStore(raw_responses_dir)
    provider = MiniMaxProvider(base_url=base_url)
    client = OpenAICompatibleExperimentClient(
        provider=provider,
        api_key=api_key,
        max_tokens=4000,
        timeout_seconds=60.0,
        raw_response_store=raw_store,
    )

    reading_dev = PairedTaskFixture(
        dataset_item_id="dev-reading-volcano-01",
        domain="READING",
        source=SourceRef(source_id="src-natgeo-dev-01", source_family="national_geographic",
                         source_version="2024-dev", source_sha256="a" * 64,
                         license="CC-BY-4.0", provenance_uri="https://natgeo.example.com/pilot-volcanoes"),
        foundation_model_id="minimax/MiniMax-Text-01",
        prompt_versions=PromptVersionMap(A="v2.1", B="v2.2", C="v3.0"),
        reading_task=ReadingTask(
            task_type="READING_SINGLE_PASSAGE",
            requested_groups=[StandaloneGroupType.TFNG],
            requested_question_count=2,
            difficulty="MEDIUM",
        ),
        passage_text=(
            "Supervolcanoes represent volcanic centers that have experienced eruptions producing at least 1,000 "
            "cubic kilometers of ejecta. These catastrophic explosive events generate enormous calderas rather than "
            "single volcanic cones. The Yellowstone caldera in North America and Lake Toba in Sumatra are primary "
            "examples of such systems. Magma chambers underlying supervolcanoes contain highly viscous rhyolitic melt "
            "enriched in dissolved volatile species. Geological surveys confirm that continental crustal thickness "
            "substantially influences the magma accumulation rate prior to catastrophic decompression."
        ),
    )

    grammar_dev = PairedTaskFixture(
        dataset_item_id="dev-grammar-inversion-01",
        domain="GRAMMAR",
        source=SourceRef(source_id="src-grammar-dev-01", source_family="academic_grammar_corpus",
                         source_version="2024-dev", source_sha256="b" * 64,
                         license="CC-BY-4.0", provenance_uri="https://grammar.example.com/inversion-rules"),
        foundation_model_id="minimax/MiniMax-Text-01",
        prompt_versions=PromptVersionMap(A="v2.1", B="v2.2", C="v3.0"),
        grammar_task=GrammarTask(
            task_type="GRAMMAR_EXERCISE",
            grammar_rule_pack_ref="pack-inversion-dev-01",
            exercise_type=GrammarExerciseType.MCQ_SINGLE,
            requested_question_count=2,
            difficulty="MEDIUM",
        ),
        rule_pack=GrammarRulePack(
            rule_pack_id="pack-inversion-dev-01",
            source=SourceRef(source_id="src-grammar-dev-01", source_family="academic_grammar_corpus",
                             source_version="2024-dev", source_sha256="b" * 64,
                             license="CC-BY-4.0", provenance_uri="https://grammar.example.com/inversion-rules"),
            topic="Negative and Limiting Inversion",
            level="B2",
            rule_ids=["rule-inv-01"],
            applicability=["When negative adverbials initiate a sentence, auxiliary inversion is required."],
            exceptions=["Only in initial position."],
            examples=["Seldom had they encountered such seismic intensity.", "Under no circumstances should samples be discarded."],
        ),
    )

    print("[DEV EXPERIMENT] Starting genuine live DEV experiment against MiniMax...")
    assignment_mgr = PairedAssignmentManager()
    ledger = ExperimentReplayLedger()
    evaluator = NeutralEvaluatorV2()

    runner = DevPilotRunner(
        assignment_manager=assignment_mgr,
        ledger=ledger,
        evaluator=evaluator,
        runner_a=ConfigurationARunner(client=client),
        runner_b=ConfigurationBRunner(client=client),
        runner_c=ConfigurationCRunner(client=client),
    )

    t0 = time.time()
    summary = runner.run_pilot([(reading_dev, "DEV"), (grammar_dev, "DEV")])
    elapsed = time.time() - t0

    print(f"\n[DEV EXPERIMENT] Completed in {elapsed:.1f}s!")
    print(f"  Total assigned: {summary.total_assigned_requests}")
    print(f"  Per-config counts: {summary.per_config_counts}")
    print(f"  Per-config costs: {summary.per_config_costs}")
    print(f"  Per-config quality verdicts: {summary.per_config_quality_verdicts}")
    print(f"  Failure records: {summary.failure_records}")
    print(f"  Reconciled: {summary.reconciled}")

    # Inspect question-level evaluations from ledger
    attempts = ledger.get_all_attempts()
    question_evals = []
    for att in attempts:
        out = ledger.get_output(att.attempt_id)
        if out and out.generated_content:
            domain = "READING" if "reading" in att.assignment_id else "GRAMMAR"
            ctx_meta = {"rule_pack": grammar_dev.rule_pack} if domain == "GRAMMAR" else None
            for q in out.generated_content.questions:
                ev_res = evaluator.evaluate_item(
                    dataset_item_id=out.dataset_item_id,
                    passage_text=out.generated_content.context_text,
                    question_data=q.model_dump(),
                    context_metadata=ctx_meta,
                )
                question_evals.append({
                    "attempt_id": att.attempt_id,
                    "assignment_id": att.assignment_id,
                    "domain": domain,
                    "configuration_id": att.configuration_id,
                    "question_id": q.question_id,
                    "verdict": ev_res.verdict.value,
                    "grounding_score": ev_res.semantic_scores.get("grounding"),
                    "answerability_score": ev_res.semantic_scores.get("answerability"),
                    "evidence_refs": ev_res.evidence_refs,
                })

    results = {
        "experiment_type": "GENUINE_LIVE_DEV_EXPERIMENT",
        "split": "DEV",
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "foundation_model_id": "minimax/MiniMax-Text-01",
        "provider_base_url": base_url,
        "elapsed_seconds": round(elapsed, 2),
        "total_dispatches": len(client.recorded_dispatches),
        "total_tokens": client.cumulative_tokens,
        "total_spent_usd": round(client.cumulative_spent_usd, 4),
        "summary": summary.model_dump(mode="json"),
        "question_evaluations_sample": question_evals,
    }

    out_file = remediation_dir / "dev_experiment_results.json"
    out_file.write_text(json.dumps(results, indent=2))
    print(f"[DEV EXPERIMENT] Results successfully written to {out_file}")


if __name__ == "__main__":
    main()
