#!/usr/bin/env python3
"""LANGFENS — Hybrid Single-Section Live Validation Runner.

Executes ONE isolated reading section run using real MiniMax network endpoints:
- MiniMax-Text-01 for passage and question candidate generation
- MiniMax-M3 for eligible repair planning only
- MiniMax-Text-01 for constrained candidate regeneration
- Existing deterministic & independent evaluation gates
- Real PostgreSQL checkpoint persistence via exam-service
- Exactly ONE worker

Target:
- PMC13654891 (West African metallurgy)
- Section 1: Passage (700-900 words) + 13 questions
- Preserves authoritative blueprint claim bindings fail-closed
"""

from __future__ import annotations

import base64
import hashlib
import hmac
import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.request
from typing import Any, Dict, List, Optional

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AI_ENV_PATH = os.path.join(REPO_ROOT, "deploy", "envs", "ai.env")
COMPOSE_FILE = os.path.join(REPO_ROOT, "deploy", "compose.benchmark-text.yaml")
REPORTS_DIR = os.path.join(REPO_ROOT, "reports")
os.makedirs(REPORTS_DIR, exist_ok=True)
SNAPSHOT_PATH = os.path.join(REPORTS_DIR, "hybrid_single_section_live_rerun_snapshot.json")

# MiniMax Pricing (USD per 1,000,000 tokens)
PRICING = {
    "MiniMax-Text-01": {"prompt": 0.20 / 1_000_000, "completion": 1.10 / 1_000_000},
    "MiniMax-M3": {"prompt": 0.50 / 1_000_000, "completion": 2.00 / 1_000_000},
}


def load_minimax_key() -> str:
    if os.path.exists(AI_ENV_PATH):
        with open(AI_ENV_PATH, "r", encoding="utf-8") as f:
            for line in f:
                if line.startswith("MINIMAX_API_KEY="):
                    return line.strip().split("=", 1)[1].strip()
    return os.environ.get("MINIMAX_API_KEY", "")


def create_admin_jwt(secret: str = "bTNGPmniBGyINHPdsmONct16TIqqb1bZ") -> str:
    def b64url(b: bytes) -> str:
        return base64.urlsafe_b64encode(b).rstrip(b"=").decode("ascii")

    header = {"alg": "HS256", "typ": "JWT"}
    payload = {
        "sub": "00000000-0000-0000-0000-000000000001",
        "roles": "ADMIN",
        "iss": "IssuerName",
        "aud": "AudienceName",
        "exp": int(time.time()) + 14400,
    }
    part1 = b64url(json.dumps(header, separators=(",", ":")).encode("utf-8"))
    part2 = b64url(json.dumps(payload, separators=(",", ":")).encode("utf-8"))
    sig = hmac.new(secret.encode("utf-8"), f"{part1}.{part2}".encode("utf-8"), hashlib.sha256).digest()
    return f"{part1}.{part2}.{b64url(sig)}"


def get_auth_headers() -> dict[str, str]:
    return {
        "Authorization": f"Bearer {create_admin_jwt()}",
        "Content-Type": "application/json",
        "Accept": "application/json",
    }


def query_db_json(sql: str) -> Any:
    cmd = [
        "docker", "exec", "benchmark-text-db",
        "psql", "-U", "exam", "-d", "exam-db", "-t", "-A", "-c",
        f"SELECT json_agg(t) FROM ({sql}) t;"
    ]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        print(f"[DB ERR] {res.stderr.strip()}", flush=True)
        return []
    out = res.stdout.strip()
    if not out or out == "":
        return []
    try:
        return json.loads(out)
    except Exception as e:
        print(f"[DB PARSE ERR] {e}: {out[:200]}", flush=True)
        return []


def start_topology() -> None:
    print("[1/5] Starting isolated clean topology via compose.benchmark-text.yaml...", flush=True)
    subprocess.run(["docker", "compose", "-f", COMPOSE_FILE, "down", "-v"], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    subprocess.run(["docker", "compose", "-f", COMPOSE_FILE, "up", "-d"], check=True)

    print("Waiting for exam-service (8087) and generation-service (8086) to be healthy...", flush=True)
    deadline = time.time() + 90
    exam_ready = False
    gen_ready = False
    while time.time() < deadline:
        if not gen_ready:
            try:
                with urllib.request.urlopen("http://127.0.0.1:8086/healthz", timeout=2) as r:
                    if r.status == 200:
                        gen_ready = True
            except Exception:
                pass
        if not exam_ready:
            try:
                with urllib.request.urlopen("http://127.0.0.1:8087/healthz", timeout=2) as r:
                    if r.status == 200:
                        exam_ready = True
            except Exception:
                pass
        if exam_ready and gen_ready:
            break
        time.sleep(2)

    if not (exam_ready and gen_ready):
        raise RuntimeError(f"Topology failed health checks: exam_ready={exam_ready}, gen_ready={gen_ready}")
    print("[1/5] Topology is live, healthy, and isolated.", flush=True)


def stop_topology(keep_volume: bool = True) -> None:
    print("\n[5/5] Stopping topology...", flush=True)
    cmd = ["docker", "compose", "-f", COMPOSE_FILE, "down"]
    if not keep_volume:
        cmd.append("-v")
    subprocess.run(cmd, check=True)


def main():
    api_key = load_minimax_key()
    if not api_key:
        print("ERROR: MINIMAX_API_KEY not found in deploy/envs/ai.env", file=sys.stderr)
        sys.exit(1)

    print(f"=== LANGFENS HYBRID SINGLE-SECTION LIVE VALIDATION ===")
    print(f"Provider: MiniMax (Text-01 for drafting, M3 for repair planning)")
    print(f"Source: Europe PMC PMC13654891 (Didé West 1 metallurgy)")
    print(f"Target: Section 1 (Passage 700-900w + 13 questions)")

    # 1. Start Topology
    start_topology()

    base_url = "http://127.0.0.1:8087"

    # 2. Submit Single Section Job
    print("\n[2/5] Submitting 1-section job to /api/admin/reading-paper/jobs...", flush=True)
    topic = "Evolution of an Early and Long-Lasting Iron Smelting Technique at Didé West 1, Falémé Valley, Eastern Senegal"
    payload = {
        "topic": topic,
        "pmcids": ["PMC13654891"],
        "provider": "minimax"
    }

    t0 = time.time()
    req = urllib.request.Request(
        f"{base_url}/api/admin/reading-paper/jobs",
        data=json.dumps(payload).encode("utf-8"),
        headers=get_auth_headers(),
        method="POST"
    )

    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            data = json.loads(resp.read().decode())
            job_id = data["id"]
            print(f"Job created successfully: ID = {job_id}, status = {data.get('status')}", flush=True)
    except urllib.error.HTTPError as e:
        print(f"ERROR: Job submission failed (HTTP {e.code}): {e.read().decode()}", flush=True)
        stop_topology(keep_volume=False)
        sys.exit(1)

    # 3. Monitor Job Execution
    print(f"\n[3/5] Monitoring job {job_id} until terminal state...", flush=True)
    seen_logs = 0
    terminal_statuses = {"Completed", "Failed", "Aborted", "Cancelled"}
    final_job_data = {}

    while True:
        try:
            get_req = urllib.request.Request(
                f"{base_url}/api/admin/reading-paper/jobs/{job_id}",
                headers=get_auth_headers()
            )
            with urllib.request.urlopen(get_req, timeout=15) as r:
                job_state = json.loads(r.read().decode())
                status = job_state.get("status")
                completed_sec = job_state.get("completedSections", 0)
                logs = job_state.get("logs") or []

                if len(logs) > seen_logs:
                    for entry in logs[seen_logs:]:
                        ts = entry.get("timestamp", "")
                        lvl = entry.get("level", "")
                        msg = entry.get("message", "")
                        print(f"[{ts}] [{lvl}] {msg}", flush=True)
                    seen_logs = len(logs)

                if status in terminal_statuses:
                    elapsed = time.time() - t0
                    print(f"\n---> Terminal status reached: {status} in {elapsed:.1f}s (Sections completed: {completed_sec})", flush=True)
                    final_job_data = job_state
                    break
        except Exception as e:
            print(f"Polling warning: {e}", flush=True)

        time.sleep(5)

    wall_time_total = time.time() - t0

    # 4. Deep Forensic PostgreSQL Collection
    print(f"\n[4/5] Extracting deep forensic records from PostgreSQL (benchmark-text-db)...", flush=True)

    # Runs
    runs = query_db_json(f'SELECT * FROM reading_paper_runs WHERE "JobId" = \'{job_id}\'')
    run_info = runs[0] if runs else {}
    run_id = run_info.get("RunId")

    # Operations
    ops = query_db_json(f"""
        SELECT "OperationId", "OperationType", "Status", "ArtifactId", "SectionId",
               "TokensUsed", "PromptTokensUsed", "CompletionTokensUsed", "ReasoningTokensUsed",
               "WallTimeUsedSeconds", "ResultRefJson"
        FROM reading_paper_operations
        WHERE "RunId" = '{run_id}'
        ORDER BY "CreatedAt" ASC
    """) or []

    # Heads (Accepted Artifacts)
    heads = query_db_json(f"""
        SELECT h."ArtifactId", a."ArtifactType", h."AcceptedVersion", h."AcceptedHash",
               a."PayloadJson", a."ParentRefsJson"
        FROM reading_paper_artifact_heads h
        JOIN reading_paper_artifacts a
          ON h."RunId" = a."RunId" AND h."ArtifactId" = a."ArtifactId" AND h."AcceptedVersion" = a."Version"
        WHERE h."RunId" = '{run_id}'
        ORDER BY h."ArtifactId" ASC
    """) or []

    # All Artifact Versions (Drafts + Accepted)
    all_artifacts = query_db_json(f"""
        SELECT "ArtifactId", "ArtifactType", "Version", "ContentHash", "PayloadJson", "ParentRefsJson"
        FROM reading_paper_artifacts
        WHERE "RunId" = '{run_id}'
        ORDER BY "ArtifactId" ASC, "Version" ASC
    """) or []

    # Decisions
    decisions = query_db_json(f"""
        SELECT "DecisionId", "Decision", "CurrentState", "NextState", "Reason", "TargetScope",
               "ExpectedVersion"
        FROM reading_paper_decisions
        WHERE "RunId" = '{run_id}'
        ORDER BY "CreatedAt" ASC
    """) or []

    # Evaluations
    evals = query_db_json(f"""
        SELECT "EvaluationId", "EvaluatorId", "EvaluatorVersion", "TargetArtifactId",
               "TargetVersion", "TargetContentHash", "Status", "IsPass", "PayloadJson"
        FROM reading_paper_evaluations
        WHERE "RunId" = '{run_id}'
        ORDER BY "CreatedAt" ASC
    """) or []

    # Exams
    exams = query_db_json(f"""
        SELECT e."Id", e."Title", e."Slug", e."DurationMin", COUNT(q."Id") as question_count
        FROM exams e
        LEFT JOIN exam_questions q ON q."ExamId" = e."Id"
        WHERE e."Slug" LIKE 'reading-%'
        GROUP BY e."Id", e."Title", e."Slug", e."DurationMin"
    """) or []

    # Compute Token & Cost Metrics (PROVIDER_CALL operations only)
    provider_ops = [o for o in ops if o.get("OperationType") == "PROVIDER_CALL"]
    m3_ops = [o for o in provider_ops if "MiniMax-M3" in str(o.get("ResultRefJson") or "") or "m3_plan" in str(o.get("OperationId") or "")]
    text_ops = [o for o in provider_ops if o not in m3_ops]

    total_prompt_tokens = sum(o.get("PromptTokensUsed") or 0 for o in ops)
    total_completion_tokens = sum(o.get("CompletionTokensUsed") or 0 for o in ops)
    total_reasoning_tokens = sum(o.get("ReasoningTokensUsed") or 0 for o in ops)
    total_tokens = sum(o.get("TokensUsed") or 0 for o in ops)

    m3_prompt_tokens = sum(o.get("PromptTokensUsed") or 0 for o in m3_ops)
    m3_completion_tokens = sum(o.get("CompletionTokensUsed") or 0 for o in m3_ops)
    m3_reasoning_tokens = sum(o.get("ReasoningTokensUsed") or 0 for o in m3_ops)

    text_prompt_tokens = sum(o.get("PromptTokensUsed") or 0 for o in text_ops)
    text_completion_tokens = sum(o.get("CompletionTokensUsed") or 0 for o in text_ops)

    # Cost calculation
    cost_text = (text_prompt_tokens * PRICING["MiniMax-Text-01"]["prompt"]) + (text_completion_tokens * PRICING["MiniMax-Text-01"]["completion"])
    cost_m3 = (m3_prompt_tokens * PRICING["MiniMax-M3"]["prompt"]) + (m3_completion_tokens * PRICING["MiniMax-M3"]["completion"])
    total_cost_usd = round(cost_text + cost_m3, 5)

    # Passage Inspection
    passage_head = next((h for h in heads if h.get("ArtifactType") == "Passage"), None)
    passage_payload = json.loads(passage_head.get("PayloadJson")) if passage_head and passage_head.get("PayloadJson") else {}
    passage_wc = passage_payload.get("wordCount", 0)
    passage_title = passage_payload.get("title", "")

    # Questions Inspection
    question_heads = [h for h in heads if h.get("ArtifactType") == "Question"]
    accepted_q_count = len(question_heads)

    repaired_questions = []
    for qh in question_heads:
        ver = qh.get("AcceptedVersion", 1)
        if ver > 1:
            q_pl = json.loads(qh.get("PayloadJson")) if qh.get("PayloadJson") else {}
            repaired_questions.append({
                "artifactId": qh.get("ArtifactId"),
                "version": ver,
                "questionNumber": q_pl.get("questionNumber"),
                "prompt": q_pl.get("prompt"),
                "answer": q_pl.get("answer"),
                "evidenceClaimRef": q_pl.get("evidenceClaimRef") or q_pl.get("claimRef"),
            })

    # Evaluator Breakdown
    eval_breakdown = {}
    for ev in evals:
        eid = ev.get("EvaluatorId")
        st = ev.get("Status")
        eval_breakdown.setdefault(eid, {})[st] = eval_breakdown.setdefault(eid, {}).get(st, 0) + 1

    # Check for Operation Replay
    replay_prevents_duplicate = False
    if ops:
        sample_op = ops[0]
        grant_req = urllib.request.Request(
            f"{base_url}/api/internal/reading-paper/checkpoints/grant-operation",
            data=json.dumps({
                "runId": run_id,
                "epoch": run_info.get("Epoch", 1),
                "leaseOwner": run_info.get("LeaseOwner") or "00000000-0000-0000-0000-000000000001",
                "operationId": sample_op["OperationId"],
                "operationType": sample_op["OperationType"],
                "requestHash": sample_op.get("RequestHash") or "test_replay_hash",
                "tokenReservation": sample_op.get("TokenReservation") or 1000,
                "wallTimeReservationSeconds": 30.0,
            }).encode("utf-8"),
            headers={"X-Internal-Service-Key": "dev-internal-key-not-for-prod", "Content-Type": "application/json"},
            method="POST"
        )
        try:
            with urllib.request.urlopen(grant_req, timeout=10) as r:
                g_res = json.loads(r.read().decode())
                replay_prevents_duplicate = g_res.get("isReplay", False)
        except Exception as ex:
            print(f"Replay check warning: {ex}", flush=True)

    # Build Structured Snapshot
    snapshot = {
        "job_id": job_id,
        "run_id": run_id,
        "status": final_job_data.get("status"),
        "error": final_job_data.get("error"),
        "wall_time_seconds": round(wall_time_total, 2),
        "passage": {
            "title": passage_title,
            "word_count": passage_wc,
            "artifact_id": passage_head.get("ArtifactId") if passage_head else None,
            "content_hash": passage_head.get("AcceptedHash") if passage_head else None,
            "version": passage_head.get("AcceptedVersion") if passage_head else None,
        },
        "questions": {
            "accepted_count": accepted_q_count,
            "target_count": 13,
            "repaired_count": len(repaired_questions),
            "repaired_details": repaired_questions,
        },
        "operations": {
            "total_count": len(ops),
            "text01_calls": len(text_ops),
            "m3_calls": len(m3_ops),
            "total_tokens": total_tokens,
            "total_prompt_tokens": total_prompt_tokens,
            "total_completion_tokens": total_completion_tokens,
            "total_reasoning_tokens": total_reasoning_tokens,
            "m3_prompt_tokens": m3_prompt_tokens,
            "m3_completion_tokens": m3_completion_tokens,
            "m3_reasoning_tokens": m3_reasoning_tokens,
            "billable_cost_usd": total_cost_usd,
        },
        "evaluations_breakdown": eval_breakdown,
        "operation_replay_prevents_duplicates": replay_prevents_duplicate,
        "exam_persisted": len(exams) > 0,
        "exams": exams,
        "all_operations": ops,
        "all_evaluations": evals,
        "all_artifacts": all_artifacts,
        "decisions": decisions,
        "raw_logs": logs,
    }

    with open(SNAPSHOT_PATH, "w", encoding="utf-8") as f:
        json.dump(snapshot, f, indent=2)

    print(f"\nSnapshot successfully saved to {SNAPSHOT_PATH}")
    print(f"=====================================================")
    print(f"Passage: '{passage_title}' ({passage_wc} words)")
    print(f"Accepted Questions: {accepted_q_count} / 13")
    print(f"Repaired Questions: {len(repaired_questions)}")
    print(f"MiniMax-M3 Calls:   {len(m3_ops)} (prompt={m3_prompt_tokens}, comp={m3_completion_tokens}, reasoning={m3_reasoning_tokens})")
    print(f"MiniMax-Text Calls: {len(text_ops)} (prompt={text_prompt_tokens}, comp={text_completion_tokens})")
    print(f"Total Billable Cost: ${total_cost_usd}")
    print(f"Replay Verified:     {replay_prevents_duplicate}")
    print(f"Final Job Status:    {final_job_data.get('status')}")
    print(f"=====================================================")

    # Stop topology
    stop_topology(keep_volume=True)


if __name__ == "__main__":
    main()
