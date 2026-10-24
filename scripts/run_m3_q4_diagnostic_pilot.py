#!/usr/bin/env python3
"""LANGFENS — Focused MiniMax-M3 Diagnostic Repair Planning Micro-Pilot (Phase 5).

Executes exactly ONE bounded real MiniMax-M3 repair-planning request against
the historically recorded Question 4 TRUE/FALSE/NOT GIVEN semantic failure.
"""

from __future__ import annotations

import asyncio
import json
import os
from pathlib import Path
import sys
import time
from uuid import uuid4

# Ensure generation-service is in sys.path
repo_root = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(repo_root / "services" / "generation-service"))

from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from app.providers.adapters.minimax import MiniMaxProvider
from app.providers.gateway import ProviderGateway, RetryPolicy
from app.providers.registry import ProviderRegistry
from app.repair.contracts import (
    ALLOWED_ACTIONS_FOR_ISSUE,
    RepairPlan,
    validate_repair_plan_compatibility,
)
from app.repair.diagnostic_planner import RepairPlanningCapability
from tests.test_t03_providers import MockCheckpointClient


SNAPSHOT_PATH = repo_root / "reports" / "hybrid_single_section_answer_grounding_rerun_snapshot.json"
RESULT_PATH = repo_root / "reports" / "m3_q4_diagnostic_pilot_snapshot.json"


def load_minimax_key() -> str:
    env_file = repo_root / "deploy" / "envs" / "ai.env"
    if env_file.exists():
        with open(env_file, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line.startswith("MINIMAX_API_KEY="):
                    return line.split("=", 1)[1].strip().strip('"').strip("'")
    return os.environ.get("MINIMAX_API_KEY", "")


async def run_pilot() -> None:
    api_key = load_minimax_key()
    if not api_key:
        print("ERROR: MINIMAX_API_KEY not found in deploy/envs/ai.env or environment", file=sys.stderr)
        sys.exit(1)

    print(f"Loaded MINIMAX_API_KEY (len={len(api_key)})")

    # 1. Load authentic historical artifacts from snapshot
    if not SNAPSHOT_PATH.exists():
        print(f"ERROR: Snapshot not found at {SNAPSHOT_PATH}", file=sys.stderr)
        sys.exit(1)

    with open(SNAPSHOT_PATH, "r", encoding="utf-8") as f:
        snapshot = json.load(f)

    # Extract passage
    passage_art = next(a for a in snapshot["all_artifacts"] if a.get("ArtifactType") == "Passage")
    passage_payload = json.loads(passage_art["PayloadJson"])
    passage_text = passage_payload["passage"]
    passage_word_count = passage_payload.get("wordCount", len(passage_text.split()))

    # Extract historical Q4 V1
    q4_art = next(
        a for a in snapshot["all_artifacts"]
        if a.get("ArtifactId", "").endswith(":4") and a.get("Version") == 1
    )
    q4_payload = json.loads(q4_art["PayloadJson"])
    q4_stmt = q4_payload.get("prompt") or q4_payload.get("statement")
    q4_ans = q4_payload.get("answer")
    q4_claim = q4_payload.get("evidenceClaimRef") or "claim:run_6fc3be9e30fc46c28a4bd49e23b236a7:1:9"

    print("=== HISTORICAL Q4 FORENSIC CONTEXT ===")
    print(f"Passage word count: {passage_word_count} words")
    print(f"Bound claim ID:     {q4_claim}")
    print(f"Question prompt:    {q4_stmt}")
    print(f"Question answer:    {q4_ans}")

    # 2. Authentic issue diagnostics
    issue = Issue.create(
        issue_id="iss_pilot_q4_conflict",
        code=IssueCode.TFNG_BOUNDARY_CONFLICT,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message=(
            "TFNG boundary conflict: passage contradicts NOT GIVEN statement: "
            "Statement asserts non-existence of 'early smelting sites' which is affirmed in source text"
        ),
        evaluator_id="eval_question_semantic",
    )

    # 3. Setup real isolated MiniMax provider transport
    registry = ProviderRegistry()
    real_minimax = MiniMaxProvider(
        base_url="https://api.minimaxi.chat/v1",
        models={"large": "MiniMax-M3", "medium": "MiniMax-M3", "small": "MiniMax-M3"},
    )
    registry.register_provider(real_minimax, keys=[api_key], max_concurrency=1, rate_per_second=2.0)

    # Isolated mock checkpoint client to track token reservations & operations safely
    client = MockCheckpointClient(run_tokens_cap=50000)
    gateway = ProviderGateway(
        registry=registry,
        retry_policy=RetryPolicy(max_attempts=1, base_delay_seconds=1.0),
        checkpoint_client=client,
    )

    planner = RepairPlanningCapability(gateway=gateway, model_id="MiniMax-M3")

    run_id = f"run_pilot_m3_{uuid4().hex[:8]}"
    lease_owner = uuid4()
    epoch = 1

    print("\n=== DISPATCHING EXACTLY ONE REAL MINIMAX-M3 REQUEST ===")
    t0 = time.perf_counter()

    try:
        plan = await planner.plan_repair(
            question_payload=q4_payload,
            passage_text=passage_text,
            authoritative_claim_ref=q4_claim,
            issues=[issue],
            run_id=run_id,
            section_id="section_1",
            artifact_id="questions_section_1",
            lease_owner=lease_owner,
            epoch=epoch,
            parent_operation_id=f"op:{run_id}:root",
            timeout_seconds=60.0,
        )
        elapsed = time.perf_counter() - t0
        print(f"MiniMax-M3 responded in {elapsed:.2f} seconds!")
    except Exception as exc:
        print(f"MiniMax-M3 invocation failed: {exc}", file=sys.stderr)
        raise

    # 4. Validate returned RepairPlan
    print("\n=== VALIDATING RETURNED REPAIR PLAN ===")
    validate_repair_plan_compatibility(
        plan=plan,
        authoritative_claim_ref=q4_claim,
        target_question=4,
        eligible_issues=[issue],
    )
    print("PASS: RepairPlan strictly satisfies all contract and bound-claim invariants!")

    # 5. Extract operational accounting from client / gateway
    plan_dict = plan.model_dump(mode="json", by_alias=True)
    print("\n=== MINIMAX-M3 REPAIR PLAN PAYLOAD ===")
    print(json.dumps(plan_dict, indent=2))

    last_rec = client.reconciliations[-1] if client.reconciliations else None
    if last_rec:
        prompt_tokens = last_rec.promptTokensUsed or 0
        completion_tokens = last_rec.completionTokensUsed or 0
        reasoning_tokens = last_rec.reasoningTokensUsed or 0
        total_tokens = last_rec.tokensUsed or (prompt_tokens + completion_tokens)
        cost_usd = last_rec.costUsedUsd or ((prompt_tokens / 1_000_000 * 0.50) + (completion_tokens / 1_000_000 * 2.00))
    elif gateway.last_response and gateway.last_response.usage:
        u = gateway.last_response.usage
        prompt_tokens = u.prompt_tokens
        completion_tokens = u.completion_tokens
        reasoning_tokens = u.reasoning_tokens or 0
        total_tokens = u.total_tokens
        cost_usd = u.estimated_cost_usd or ((prompt_tokens / 1_000_000 * 0.50) + (completion_tokens / 1_000_000 * 2.00))
    else:
        prompt_tokens = 0
        completion_tokens = 0
        reasoning_tokens = 0
        total_tokens = 0
        cost_usd = 0.0

    pilot_result = {
        "status": "SUCCESS",
        "model": "MiniMax-M3",
        "runId": run_id,
        "elapsedSeconds": round(elapsed, 3),
        "targetQuestion": 4,
        "authoritativeClaimRef": q4_claim,
        "diagnosedIssue": {
            "code": issue.code.value,
            "message": issue.message,
        },
        "repairPlan": plan_dict,
        "usage": {
            "promptTokens": prompt_tokens,
            "completionTokens": completion_tokens,
            "reasoningTokens": reasoning_tokens,
            "totalTokens": prompt_tokens + completion_tokens,
            "costUsd": round(cost_usd, 6),
        },
        "planValidity": "PASS",
    }

    with open(RESULT_PATH, "w", encoding="utf-8") as f:
        json.dump(pilot_result, f, indent=2)

    print(f"\nSaved pilot result to {RESULT_PATH}")
    print(f"Total tokens: {prompt_tokens + completion_tokens} (prompt: {prompt_tokens}, completion: {completion_tokens}, reasoning: {reasoning_tokens})")
    print(f"Estimated billable cost: ${cost_usd:.6f} USD")


if __name__ == "__main__":
    asyncio.run(run_pilot())
