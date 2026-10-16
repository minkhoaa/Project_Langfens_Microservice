"""Genuine Live DEV Quality Verification Runner (RG11 / Evaluator v2.2).

Executes live assignments across Reading and Grammar (Arms A, B, C)
against api.minimaxi.chat/v1 using MiniMax-Text-01 on fresh, disjoint DEV fixtures.
Evaluates resulting outputs with calibrated NeutralEvaluatorV2_2 (v2.2).
Scoped repair is explicitly enabled in Configuration C (default_max_repairs=1).
Writes all results and evidence to generation_baseline/.execution/RG11_DEV_V22/.
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
from app.evaluators.independent import NeutralEvaluatorV2_2
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
    output_dir = repo_root / "generation_baseline" / ".execution" / "RG11_DEV_V22"
    output_dir.mkdir(parents=True, exist_ok=True)
    raw_responses_dir = output_dir / "raw_responses"
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

    # Fresh, disjoint DEV fixtures
    reading_dev = PairedTaskFixture(
        dataset_item_id="dev-reading-neuroplasticity-02",
        domain="READING",
        source=SourceRef(
            source_id="src-neuroscience-dev-02",
            source_family="fam-neuroscience-03",
            source_version="2026-dev",
            source_sha256="c" * 64,
            license="CC-BY-4.0",
            provenance_uri="https://neuroscience.example.com/pilot-neuroplasticity",
        ),
        foundation_model_id="minimax/MiniMax-Text-01",
        prompt_versions=PromptVersionMap(A="v2.1", B="v2.2", C="v3.0"),
        reading_task=ReadingTask(
            task_type="READING_SINGLE_PASSAGE",
            requested_groups=[StandaloneGroupType.TFNG],
            requested_question_count=2,
            difficulty="MEDIUM",
        ),
        passage_text=(
            "Neuroplasticity refers to the biological capacity of the central nervous system to dynamically modify its "
            "structural architecture and functional synaptic connections in response to experiential learning, environmental "
            "challenges, or neurological trauma. Synaptic plasticity involves long-term potentiation and long-term depression, "
            "which alter the transmission efficacy across postsynaptic dendritic spines. Axonal sprouting and dendritic remodeling "
            "further facilitate compensatory neural pathway formation following focal cortical lesions. Cognitive rehabilitation "
            "protocols strategically exploit these adaptive cellular mechanisms through repetitive task-specific motor training."
        ),
    )

    grammar_dev = PairedTaskFixture(
        dataset_item_id="dev-grammar-cleft-02",
        domain="GRAMMAR",
        source=SourceRef(
            source_id="src-linguistics-cleft-dev-02",
            source_family="fam-linguistics-cleft-03",
            source_version="2026-dev",
            source_sha256="d" * 64,
            license="CC-BY-4.0",
            provenance_uri="https://linguistics.example.com/cleft-information-packaging",
        ),
        foundation_model_id="minimax/MiniMax-Text-01",
        prompt_versions=PromptVersionMap(A="v2.1", B="v2.2", C="v3.0"),
        grammar_task=GrammarTask(
            task_type="GRAMMAR_EXERCISE",
            grammar_rule_pack_ref="pack-cleft-dev-02",
            exercise_type=GrammarExerciseType.MCQ_SINGLE,
            requested_question_count=2,
            difficulty="MEDIUM",
        ),
        rule_pack=GrammarRulePack(
            rule_pack_id="pack-cleft-dev-02",
            source=SourceRef(
                source_id="src-linguistics-cleft-dev-02",
                source_family="fam-linguistics-cleft-03",
                source_version="2026-dev",
                source_sha256="d" * 64,
                license="CC-BY-4.0",
                provenance_uri="https://linguistics.example.com/cleft-information-packaging",
            ),
            topic="Cleft Sentences and Information Packaging",
            level="B2",
            rule_ids=["rule-cleft-01"],
            applicability=[
                "When emphasizing a specific syntactic element, it-clefts use 'It is/was + [emphasized element] + that/who + [clause]'."
            ],
            exceptions=[
                "Plural noun phrases in the emphasized position still take singular 'It is/was'."
            ],
            examples=[
                "It was the cognitive rehabilitation protocol that accelerated motor recovery.",
                "It is synaptic plasticity that underpins long-term memory formation.",
            ],
        ),
    )

    print("[DEV EXPERIMENT v2.2] Starting genuine live DEV experiment against MiniMax...")
    assignment_mgr = PairedAssignmentManager()
    ledger = ExperimentReplayLedger()
    evaluator = NeutralEvaluatorV2_2()

    runner = DevPilotRunner(
        assignment_manager=assignment_mgr,
        ledger=ledger,
        evaluator=evaluator,
        runner_a=ConfigurationARunner(client=client),
        runner_b=ConfigurationBRunner(client=client),
        runner_c=ConfigurationCRunner(client=client, default_max_repairs=1),
    )

    t0 = time.time()
    summary = runner.run_pilot([(reading_dev, "DEV"), (grammar_dev, "DEV")])
    elapsed = time.time() - t0

    print(f"\n[DEV EXPERIMENT v2.2] Completed in {elapsed:.1f}s!")
    print(f"  Total assigned: {summary.total_assigned_requests}")
    print(f"  Per-config counts: {summary.per_config_counts}")
    print(f"  Per-config quality verdicts: {summary.per_config_quality_verdicts}")
    print(f"  Failure records: {summary.failure_records}")
    print(f"  Reconciled: {summary.reconciled}")

    # Inspect question-level evaluations from ledger under v2.2
    attempts = ledger.get_all_attempts()
    question_evals = []
    repair_events = []

    for att in attempts:
        out = ledger.get_output(att.attempt_id)
        if att.configuration_id == "C":
            # Check repair events in trace
            raw_att = ledger.get_attempt(att.attempt_id)
            if raw_att and raw_att.trace_ref:
                pass
        if out and out.generated_content:
            domain = "READING" if "reading" in att.assignment_id else "GRAMMAR"
            ctx_meta = {"rule_pack": grammar_dev.rule_pack} if domain == "GRAMMAR" else None
            passage_txt = reading_dev.passage_text if domain == "READING" else out.generated_content.context_text
            for q in out.generated_content.questions:
                q_dict = q.model_dump()
                ev_res = evaluator.evaluate_item(
                    dataset_item_id=out.dataset_item_id,
                    passage_text=passage_txt,
                    question_data=q_dict,
                    context_metadata=ctx_meta,
                )
                question_evals.append({
                    "attempt_id": att.attempt_id,
                    "assignment_id": att.assignment_id,
                    "domain": domain,
                    "configuration_id": att.configuration_id,
                    "question_id": q.question_id,
                    "question_type": q.question_type.value if hasattr(q.question_type, "value") else str(q.question_type),
                    "prompt": q.text,
                    "options": q_dict.get("options", []),
                    "proposed_answer": q_dict.get("proposed_answer") or q_dict.get("answer"),
                    "verdict": ev_res.verdict.value,
                    "grounding_score": ev_res.semantic_scores.get("grounding"),
                    "answerability_score": ev_res.semantic_scores.get("answerability"),
                    "abstention_reason": ev_res.abstention_reason,
                    "evidence_refs": ev_res.evidence_refs,
                    "task_validity": ev_res.task_validity,
                })

    results = {
        "campaign_id": "RG11_DEV_V22",
        "experiment_type": "GENUINE_LIVE_DEV_EXPERIMENT",
        "split": "DEV",
        "evaluator_version": evaluator.evaluator_version,
        "rubric_version": evaluator.rubric.rubric_version,
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "foundation_model_id": "minimax/MiniMax-Text-01",
        "provider_base_url": base_url,
        "elapsed_seconds": round(elapsed, 2),
        "total_dispatches": len(client.recorded_dispatches),
        "total_tokens": client.cumulative_tokens,
        "total_spent_usd": round(client.cumulative_tokens * 0.0000015, 4),
        "summary": summary.model_dump(mode="json"),
        "question_evaluations": question_evals,
    }

    out_file = output_dir / "quality_dev_results.json"
    out_file.write_text(json.dumps(results, indent=2))
    print(f"[DEV EXPERIMENT v2.2] Results successfully written to {out_file}")


if __name__ == "__main__":
    main()
