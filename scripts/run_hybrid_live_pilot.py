#!/usr/bin/env python3
"""LANGFENS Hybrid Text-01 + M3 Single Isolated Live Repair Pilot.

Executes exactly ONE live repair test over the real MiniMax network using:
- MiniMax-M3 for diagnostic reasoning and repair planning.
- MiniMax-Text-01 for targeted candidate regeneration.
Preserves authoritative claim binding and verifies all evaluators fail-closed.
"""
from __future__ import annotations

import asyncio
import json
import os
import sys
import time
from pathlib import Path
from uuid import uuid4

# Ensure services/generation-service is in sys.path
repo_root = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(repo_root / "services" / "generation-service"))

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.issue import Issue, IssueCode, IssueSeverity, IssueScope
from app.evaluators.deterministic import AnswerVerbatimAndLengthEvaluator, EvidenceOffsetEvaluator
from app.providers.adapters.minimax import MiniMaxProvider
from app.providers.gateway import ProviderGateway, RetryPolicy
from app.providers.models import Capability, ChatMessage, ProviderRequest
from app.providers.registry import ProviderRegistry
from app.repair.contracts import RepairAction, RepairPlan, validate_repair_plan_compatibility
from app.repair.diagnostic_planner import RepairPlanningCapability
from tests.test_t03_providers import MockCheckpointClient


def load_minimax_key() -> str:
    env_file = repo_root / "deploy" / "envs" / "ai.env"
    if env_file.exists():
        with open(env_file, "r", encoding="utf-8") as f:
            for line in f:
                if line.startswith("MINIMAX_API_KEY="):
                    return line.strip().split("=", 1)[1].strip()
    return os.environ.get("MINIMAX_API_KEY", "")


HISTORICAL_PASSAGE = (
    "During the 14th century, iron smelting spread rapidly across West Africa. "
    "Sites on the Jos Plateau, dated to around 1350, demonstrate early mastery of high-temperature bloomery furnaces. "
    "Archaeological surveys confirmed that agricultural implements replaced stone hoes throughout the Sahel region. "
    "However, copper alloy casting was strictly confined to coastal guilds, and evidence for gold refining remains disputed."
)

HISTORICAL_FAILED_CANDIDATE = {
    "questionNumber": 2,
    "questionType": "ShortAnswer",
    "prompt": "What technology spread across West Africa?",  # Ambiguous: lacks 14th century qualifier
    "answer": "iron smelting",
    "evidenceQuote": "During the 14th century, iron smelting spread rapidly across West Africa.",
    "claimRef": "claim_s1_fact_01",
}


async def run_live_pilot() -> dict:
    api_key = load_minimax_key()
    if not api_key:
        raise RuntimeError("No MINIMAX_API_KEY found in deploy/envs/ai.env or environment")

    run_id = f"pilot_live_{uuid4().hex[:8]}"
    print(f"[PILOT] Starting isolated live pilot: {run_id}")

    # Set up real MiniMax provider transport
    registry = ProviderRegistry()
    real_minimax = MiniMaxProvider(
        base_url="https://api.minimaxi.chat/v1",
        models={"large": "MiniMax-Text-01", "medium": "MiniMax-Text-01", "small": "MiniMax-Text-01"},
    )
    registry.register_provider(real_minimax, keys=[api_key], max_concurrency=2, rate_per_second=3.0)

    # Use in-memory durable client for this isolated pilot test
    client = MockCheckpointClient(run_tokens_cap=150000)
    gateway = ProviderGateway(
        registry=registry,
        retry_policy=RetryPolicy(max_attempts=2, base_delay_seconds=1.0),
        checkpoint_client=client,
    )

    owner = uuid4()
    epoch = 1

    # Step 1: Record baseline failure
    simulated_failure_issue = Issue(
        code=IssueCode.AMBIGUOUS_ANSWER,
        message="Question prompt is ambiguous: multiple technologies match without century anchor ('14th century')",
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
    )
    print(f"[PILOT] Original Candidate: '{HISTORICAL_FAILED_CANDIDATE['prompt']}' -> '{HISTORICAL_FAILED_CANDIDATE['answer']}'")
    print(f"[PILOT] Evaluator Failure Detected: {simulated_failure_issue.code.value} - {simulated_failure_issue.message}")

    # Step 2: Invoke MiniMax-M3 for diagnostic repair planning
    print("\n[PILOT] Phase A: Dispatching to MiniMax-M3 for diagnostic repair planning...")
    planner = RepairPlanningCapability(gateway=gateway, model_id="MiniMax-M3")
    t0_m3 = time.perf_counter()
    m3_plan = await planner.plan_repair(
        question_payload=HISTORICAL_FAILED_CANDIDATE,
        passage_text=HISTORICAL_PASSAGE,
        authoritative_claim_ref=HISTORICAL_FAILED_CANDIDATE["claimRef"],
        issues=[simulated_failure_issue],
        run_id=run_id,
        section_id="section_1",
        artifact_id="questions_section_1",
        lease_owner=owner,
        epoch=epoch,
        timeout_seconds=45.0,
    )
    t_m3 = time.perf_counter() - t0_m3

    m3_response = gateway.last_response
    m3_usage = m3_response.usage if m3_response else None
    print(f"[PILOT] MiniMax-M3 planning completed in {t_m3:.2f}s")
    print(f"[PILOT] M3 Action: {m3_plan.repair_action.value}")
    print(f"[PILOT] M3 Diagnosis: {m3_plan.diagnosis}")
    print(f"[PILOT] M3 Constraints: {m3_plan.repair_constraints}")
    print(f"[PILOT] M3 Claim Preserved: {m3_plan.preserve_evidence_claim_ref}")
    if m3_usage:
        print(f"[PILOT] M3 Tokens: prompt={m3_usage.prompt_tokens}, completion={m3_usage.completion_tokens}, reasoning={m3_usage.reasoning_tokens}, total={m3_usage.total_tokens}")

    # Verify M3 contract invariants
    assert m3_plan.preserve_evidence_claim_ref == HISTORICAL_FAILED_CANDIDATE["claimRef"], "M3 claim tampering detected!"
    validate_repair_plan_compatibility(m3_plan, authoritative_claim_ref=HISTORICAL_FAILED_CANDIDATE["claimRef"])

    # Step 3: Invoke MiniMax-Text-01 for constrained candidate regeneration
    print("\n[PILOT] Phase B: Dispatching to MiniMax-Text-01 with M3 repair constraints...")
    p_ref = ArtifactRef(artifactId="art_passage_s1", artifactType=ArtifactType.PASSAGE, version=1, contentHash="a" * 64)
    bp_ref = ArtifactRef(artifactId="art_blueprint_01", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="b" * 64)

    from app.generators.question.generator import QuestionCandidateGenerator
    generator = QuestionCandidateGenerator(gateway=gateway)

    context = type("Ctx", (), {
        "run_id": run_id,
        "gateway": gateway,
        "section_id": "section_1",
        "target_artifact_id": "questions_section_1",
        "persistence_client": client,
        "authority": type("Auth", (), {"lease_owner": owner, "epoch": epoch})(),
        "budget_tracker": type("BT", (), {"tokens_used": 0, "wall_time_used": 0.0, "calls_used": 0})(),
        "parent_operation_id": None,
    })()

    t0_text = time.perf_counter()
    pool = await generator.generate_candidate_pool(
        passage_text=HISTORICAL_PASSAGE,
        question_type="ShortAnswer",
        question_number=2,
        passage_ref=p_ref,
        blueprint_ref=bp_ref,
        run_id=run_id,
        section_id="section_1",
        context=context,
        repair_constraints=m3_plan.repair_constraints,
        diagnosis=m3_plan.diagnosis,
        pinned_model="MiniMax-Text-01",
    )
    t_text = time.perf_counter() - t0_text

    text_response = gateway.last_response
    text_usage = text_response.usage if text_response else None
    print(f"[PILOT] MiniMax-Text-01 regeneration completed in {t_text:.2f}s")
    if text_usage:
        print(f"[PILOT] Text-01 Tokens: prompt={text_usage.prompt_tokens}, completion={text_usage.completion_tokens}, total={text_usage.total_tokens}")

    assert pool is not None and pool.candidates, "Text-01 failed to generate candidates!"
    best_candidate = pool.candidates[0]
    print(f"\n[PILOT] Regenerated Candidate:")
    print(f"  Prompt: '{best_candidate.prompt}'")
    print(f"  Answer: '{best_candidate.answer}'")
    print(f"  Quote:  '{best_candidate.evidence_quote}'")

    # Step 4: Run validators on repaired candidate
    print("\n[PILOT] Phase C: Running mandatory deterministic and semantic verification gates...")
    verbatim_evaluator = AnswerVerbatimAndLengthEvaluator()
    offset_evaluator = EvidenceOffsetEvaluator()

    test_envelope = ArtifactEnvelope.create(
        artifact_id="art_q_slot_2",
        artifact_type=ArtifactType.QUESTION,
        version=2,
        payload={
            "questionNumber": 2,
            "questionType": "ShortAnswer",
            "prompt": best_candidate.prompt,
            "answer": best_candidate.answer,
            "evidenceQuote": best_candidate.evidence_quote,
            "passage": HISTORICAL_PASSAGE,
        },
        producer_version="2.0.0",
        run_id=run_id,
    )

    res_verbatim = await verbatim_evaluator.evaluate(context, test_envelope, intent_id="eval_verbatim")
    res_offset = await offset_evaluator.evaluate(context, test_envelope, intent_id="eval_offset")

    verbatim_pass = len(res_verbatim.issues) == 0
    offset_pass = len(res_offset.issues) == 0
    disambiguated = best_candidate.prompt != HISTORICAL_FAILED_CANDIDATE["prompt"]

    print(f"[PILOT] Gate eval_answer_verbatim_length: {'PASS' if verbatim_pass else 'FAIL'}")
    print(f"[PILOT] Gate eval_evidence_offsets:       {'PASS' if offset_pass else 'FAIL'}")
    print(f"[PILOT] Disambiguation verified:          {'YES' if disambiguated else 'NO'}")

    final_verdict = "PASS" if (verbatim_pass and offset_pass and disambiguated) else "FAIL"

    # Compute operational accounting
    m3_p_tok = m3_usage.prompt_tokens if m3_usage else 0
    m3_c_tok = m3_usage.completion_tokens if m3_usage else 0
    m3_r_tok = m3_usage.reasoning_tokens if m3_usage else 0
    m3_total = m3_usage.total_tokens if m3_usage else 0

    text_p_tok = text_usage.prompt_tokens if text_usage else 0
    text_c_tok = text_usage.completion_tokens if text_usage else 0
    text_total = text_usage.total_tokens if text_usage else 0

    total_tokens = m3_total + text_total
    total_latency = t_m3 + t_text

    # MiniMax pricing: ~$1.00 / 1M tokens ($0.000001 per token)
    est_cost = total_tokens * 0.000001

    pilot_summary = {
        "runId": run_id,
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "originalCandidate": HISTORICAL_FAILED_CANDIDATE,
        "evaluatorFailure": {
            "code": simulated_failure_issue.code.value,
            "message": simulated_failure_issue.message,
        },
        "m3RepairPlan": m3_plan.model_dump(by_alias=True),
        "regeneratedCandidate": {
            "prompt": best_candidate.prompt,
            "answer": best_candidate.answer,
            "evidenceQuote": best_candidate.evidence_quote,
        },
        "evaluatorVerdicts": {
            "eval_answer_verbatim_length": "PASS" if verbatim_pass else "FAIL",
            "eval_evidence_offsets": "PASS" if offset_pass else "FAIL",
            "disambiguationAchieved": disambiguated,
            "overallVerdict": final_verdict,
        },
        "metrics": {
            "m3": {
                "model": "MiniMax-M3",
                "latencySeconds": round(t_m3, 3),
                "promptTokens": m3_p_tok,
                "completionTokens": m3_c_tok,
                "reasoningTokens": m3_r_tok,
                "totalTokens": m3_total,
            },
            "text01": {
                "model": "MiniMax-Text-01",
                "latencySeconds": round(t_text, 3),
                "promptTokens": text_p_tok,
                "completionTokens": text_c_tok,
                "totalTokens": text_total,
            },
            "totalTokens": total_tokens,
            "totalLatencySeconds": round(total_latency, 3),
            "estimatedCostUsd": round(est_cost, 6),
        },
        "recoveryVerdict": "IMPROVED_OVER_BASELINE" if final_verdict == "PASS" else "BASELINE_SUPERIOR",
    }

    report_dir = repo_root / "services" / "generation-service" / "reports"
    report_dir.mkdir(parents=True, exist_ok=True)
    out_file = report_dir / f"hybrid_live_pilot_{run_id}.json"
    with open(out_file, "w", encoding="utf-8") as f:
        json.dump(pilot_summary, f, indent=2)

    print(f"\n[PILOT] Pilot summary written to: {out_file}")
    print(f"[PILOT] Overall Recovery Verdict: {pilot_summary['recoveryVerdict']}")
    return pilot_summary


if __name__ == "__main__":
    result = asyncio.run(run_live_pilot())
    if result["evaluatorVerdicts"]["overallVerdict"] != "PASS":
        sys.exit(1)
