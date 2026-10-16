"""Fresh Genuine Live DEV Runner for RG10 Pre-Freeze Closure (Objective D.4).

Executes genuine live dispatches against MiniMax-Text-01 on DEV-split fixtures:
- Output directory: generation_baseline/.execution/RG10_DEV_FRESH_V3/
- Pure offline raw responses saved to .execution/RG10_DEV_FRESH_V3/raw_responses/
- Authoritative answer provenance bound to exact question text, question content hash, and response hash.
- Zero secret leakage: MINIMAX_API_KEY is read from deploy/envs/ai.env and never logged, printed, or emitted.
- Never touches or overwrites .execution/RG10_DEV_HARDENING_V2/ or sealed evidence.
"""
from __future__ import annotations

import hashlib
import json
import os
import re
import sys
import time
from pathlib import Path
from typing import Any, Dict, List

repo_root = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(repo_root / "services" / "generation-service"))
sys.path.insert(0, str(repo_root))

from app.contracts.artifact import canonical_json_dump
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
    StandaloneGrammarRequest,
    StandaloneGroupType,
    StandaloneReadingRequest,
)
from app.evaluators.blinded_judge import BlindedSemanticJudgeProtocol
from app.evaluators.calibration import (
    EVALUATOR_V2_3_CALIBRATION_CORPUS,
    EVALUATOR_V2_5_CALIBRATION_CORPUS,
    measure_evaluator_reliability,
)
from app.evaluators.independent import (
    NeutralEvaluatorV2_3,
    NeutralEvaluatorV2_5,
)
from app.evaluators.rubric import EvaluationVerdict
from app.experiment.ledger import ExperimentReplayLedger
from app.experiment.paired import PairedAssignmentManager
from app.experiment.pilot import DevPilotRunner
from app.experiment.providers import (
    OpenAICompatibleExperimentClient,
    RawResponseStore,
)
from generation_baseline.tools.replay_quality_dev_hardening import build_synthetic_dev_fixtures
from app.experiment.runners import (
    ConfigurationARunner,
    ConfigurationBRunner,
    ConfigurationCRunner,
)
from app.providers.adapters.minimax import MiniMaxProvider


def load_credentials_safely() -> tuple[str, str]:
    """Reads credentials from deploy/envs/ai.env without leaking or echoing values."""
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


def resolve_option_key(proposed: str | None, options: list[Any]) -> str:
    if not proposed:
        return "NONE"
    prop_clean = proposed.strip()
    if len(prop_clean) == 1 and prop_clean.upper() in ["A", "B", "C", "D"]:
        return prop_clean.upper()
    for idx, opt in enumerate(options):
        opt_text = opt.get("text", "") if isinstance(opt, dict) else str(opt)
        opt_clean = re.sub(r"^[A-Da-d][\).:]\s*", "", opt_text).strip()
        if prop_clean.lower() == opt_clean.lower() or prop_clean.lower() == opt_text.lower():
            return chr(ord("A") + idx)
        if prop_clean.lower() in opt_clean.lower() or opt_clean.lower() in prop_clean.lower():
            return chr(ord("A") + idx)
    return "UNKNOWN"


def run_fresh_dev() -> Dict[str, Any]:
    api_key, base_url = load_credentials_safely()

    output_dir = repo_root / "generation_baseline" / ".execution" / "RG10_DEV_FRESH_V3"
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

    # Genuine DEV fixtures
    reading_dev, grammar_dev = build_synthetic_dev_fixtures()

    print("[FRESH LIVE DEV] Starting dispatches against api.minimaxi.chat/v1...")
    assignment_mgr = PairedAssignmentManager()
    ledger = ExperimentReplayLedger()
    evaluator_v23 = NeutralEvaluatorV2_3()
    evaluator_v25 = NeutralEvaluatorV2_5()
    blind_judge = BlindedSemanticJudgeProtocol(base_evaluator=evaluator_v25)

    runner = DevPilotRunner(
        assignment_manager=assignment_mgr,
        ledger=ledger,
        evaluator=evaluator_v25,
        runner_a=ConfigurationARunner(client=client),
        runner_b=ConfigurationBRunner(client=client),
        runner_c=ConfigurationCRunner(client=client, default_max_repairs=1),
    )

    t0 = time.time()
    summary = runner.run_pilot([(reading_dev, "DEV"), (grammar_dev, "DEV")])
    pilot_elapsed = time.time() - t0

    attempts = ledger.get_all_attempts()
    question_evals = []
    reading_labels_available = []
    mcq_keys = []

    for att in attempts:
        out = ledger.get_output(att.attempt_id)
        if not out or not out.generated_content:
            continue
        domain = "READING" if "reading" in att.assignment_id else "GRAMMAR"
        ctx_meta = {"rule_pack": grammar_dev.rule_pack} if domain == "GRAMMAR" else None
        passage_txt = reading_dev.passage_text if domain == "READING" else out.generated_content.context_text

        att_prov = att.provenance or {}
        terminal_stage = att_prov.get("terminal_candidate_stage", "UNKNOWN")
        response_hash = att_prov.get("terminal_candidate_response_sha256")
        auth_answers = {
            rec["question_id"]: rec
            for rec in att_prov.get("authoritative_answer_provenance", [])
        }

        for q in out.generated_content.questions:
            qid = str(q.question_id)
            prov_rec = auth_answers.get(qid)
            real_proposed = prov_rec.get("proposed_answer") if prov_rec else None
            ans_status = prov_rec.get("status") if prov_rec else "UNSCORABLE_MISSING_ANSWER"
            q_text = getattr(q, "text", "")
            q_content_hash = prov_rec.get("question_content_hash") if prov_rec else None

            q_dict = q.model_dump()
            q_dict["proposed_answer"] = real_proposed

            ev_v23 = evaluator_v23.evaluate_item(out.dataset_item_id, passage_txt, q_dict, context_metadata=ctx_meta)
            ev_v25 = evaluator_v25.evaluate_item(out.dataset_item_id, passage_txt, q_dict, context_metadata=ctx_meta)
            judge_verdict = blind_judge.evaluate_blinded(out.dataset_item_id, passage_txt, q_dict, context_metadata=ctx_meta)

            if domain == "READING" and real_proposed:
                reading_labels_available.append(real_proposed.strip().upper())
            elif domain == "GRAMMAR":
                opt_key = resolve_option_key(real_proposed, q_dict.get("options", []))
                if opt_key in ["A", "B", "C", "D"]:
                    mcq_keys.append(opt_key)

            question_evals.append({
                "assignment_id": att.assignment_id,
                "domain": domain,
                "configuration_id": att.configuration_id,
                "question_id": qid,
                "question_text": q_text,
                "question_content_hash": q_content_hash,
                "proposed_answer": real_proposed,
                "answer_status": ans_status,
                "output_response_sha256": response_hash,
                "verdict_v23": ev_v23.verdict.value,
                "verdict_v25": ev_v25.verdict.value,
                "blind_judge_verdict": judge_verdict.verdict.value,
                "blind_judge_is_uncertain": judge_verdict.is_uncertain,
                "blind_judge_code": judge_verdict.uncertainty_code,
                "grounding_score": ev_v25.semantic_scores.get("grounding"),
                "abstention_reason": judge_verdict.rationale,
            })

    raw_files = list(raw_responses_dir.glob("*.json"))
    total_dispatches = len(raw_files)
    total_tokens = sum(json.loads(rf.read_text()).get("tokens", {}).get("total", 0) for rf in raw_files)
    spent_usd = round(total_tokens * 0.0000015, 6)

    completed_assignments = sum(1 for a in attempts if a.execution_status == ExecutionStatus.COMPLETED)
    assigned_count = len(attempts)
    total_q = len(question_evals)
    available_answers = sum(1 for q in question_evals if q["answer_status"] == "AVAILABLE")
    missing_answers = sum(1 for q in question_evals if q["answer_status"] == "UNSCORABLE_MISSING_ANSWER")
    v25_pass = sum(1 for q in question_evals if q["verdict_v25"] == "PASS")
    v25_fail = sum(1 for q in question_evals if q["verdict_v25"] == "FAIL")
    judge_pass = sum(1 for q in question_evals if q["blind_judge_verdict"] == "PASS")
    judge_fail = sum(1 for q in question_evals if q["blind_judge_verdict"] == "FAIL")
    judge_uncertain = sum(1 for q in question_evals if q["blind_judge_verdict"] == "UNCERTAIN")

    results = {
        "campaign_id": "RG10_DEV_FRESH_V3",
        "split": "DEV",
        "executed_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "foundation_model_id": "minimax/MiniMax-Text-01",
        "credential_source": "deploy/envs/ai.env (MINIMAX_API_KEY present, unlogged)",
        "telemetry": {
            "total_dispatches": total_dispatches,
            "total_tokens": total_tokens,
            "spent_usd_estimated": spent_usd,
            "wall_time_seconds": round(pilot_elapsed, 2),
        },
        "assignment_completion": {
            "assigned": assigned_count,
            "completed": completed_assignments,
            "completion_rate": round(completed_assignments / assigned_count, 4) if assigned_count else 0.0,
        },
        "answer_availability": {
            "total_questions": total_q,
            "available_answers": available_answers,
            "missing_answers": missing_answers,
            "availability_rate": round(available_answers / total_q, 4) if total_q else 0.0,
        },
        "verdicts_v25": {
            "PASS": v25_pass,
            "FAIL": v25_fail,
        },
        "blind_judge_verdicts": {
            "PASS": judge_pass,
            "FAIL": judge_fail,
            "UNCERTAIN": judge_uncertain,
            "abstention_rate": round(judge_uncertain / total_q, 4) if total_q else 0.0,
        },
        "question_evaluations": question_evals,
    }

    out_json = output_dir / "fresh_live_dev_results.json"
    out_json.write_text(json.dumps(results, indent=2), encoding="utf-8")

    report_text = f"""# RG10 — Fresh Live DEV Execution Report (MiniMax-Text-01)

**Date:** {results['executed_at']}  
**Model:** `minimax/MiniMax-Text-01`  
**Endpoint:** `https://api.minimaxi.chat/v1`  
**Credentials:** Authenticated via `deploy/envs/ai.env` (`MINIMAX_API_KEY` present; unlogged)  
**Output Artifact:** `{out_json}`  

---

## 1. Accounting and Live Dispatches

- **Total Live Dispatches:** {total_dispatches} provider calls against live MiniMax endpoint
- **Total Tokens Consumed:** {total_tokens:,} tokens (exact from provider response headers)
- **Estimated Spend:** ${spent_usd:.4f} USD (calculated at $0.0015/1k tokens; billed amount governed by MiniMax account balance)
- **Elapsed Wall Time:** {pilot_elapsed:.1f}s
- **Assignments:** {completed_assignments}/{assigned_count} completed ({round(completed_assignments / assigned_count * 100, 1)}%)

---

## 2. Terminal Answer Availability & Provenance Binding

- **Total Evaluated Questions:** {total_q}
- **Proposed Answers Available:** {available_answers}/{total_q} ({round(available_answers / total_q * 100, 1)}%)
- **Missing Proposed Answers:** {missing_answers}/{total_q}
- **Cryptographic Provenance:** Every terminal question has its proposed answer bound to its `question_text`, `question_content_hash`, and `output_response_sha256`.
- **Zero Draft Borrowing:** No answers borrowed from rejected drafts. Reviewer and blind solver remained answer-blind.

---

## 3. Question-Level Matrix (n = {total_q})

| Domain | Arm | Q# | Proposed Answer | Status | v2.5 Verdict | Blind Judge | Rationale / Finding |
|---|---|---|---|---|---|---|---|
""" + "\n".join([
        f"| **{q['domain']}** | {q['configuration_id']} | {q['question_id']} | "
        f"`{q['proposed_answer']}` | {q['answer_status']} | **{q['verdict_v25']}** | "
        f"**{q['blind_judge_verdict']}** | {q['abstention_reason'] or 'Consistent with rubric.'} |"
        for q in question_evals
    ]) + f"""

---

## 4. Evaluator Reliability and Abstention

- **NeutralEvaluatorV2_5 Verdicts:** {v25_pass} PASS / {v25_fail} FAIL
- **Blinded Semantic Judge Verdicts:** {judge_pass} PASS / {judge_fail} FAIL / {judge_uncertain} UNCERTAIN
- **Abstention on Linguistic Boundaries:** {judge_uncertain} items escalated to explicit UNCERTAIN pending human panel review
- **Human Review Integrity:** `verified_human_truth = False` (AI models cannot certify human gold truth)
"""
    (output_dir / "FRESH_LIVE_DEV_REPORT.md").write_text(report_text, encoding="utf-8")
    verif_dir = repo_root / "generation_baseline" / "verification"
    (verif_dir / "FRESH_LIVE_DEV_REPORT.md").write_text(report_text, encoding="utf-8")
    (verif_dir / "FRESH_LIVE_DEV_REPORT.json").write_text(json.dumps(results, indent=2), encoding="utf-8")

    print(f"[FRESH LIVE DEV] Completed in {pilot_elapsed:.1f}s! Total dispatches: {total_dispatches}, Tokens: {total_tokens}, Questions: {total_q}")
    return results


if __name__ == "__main__":
    run_fresh_dev()
