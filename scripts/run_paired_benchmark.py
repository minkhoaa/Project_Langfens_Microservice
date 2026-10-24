#!/usr/bin/env python3
"""LANGFENS — Paired MiniMax-Text vs MiniMax-M3 Live Benchmark Runner.

Executes sequential, isolated paired runs for:
- Arm A: MiniMax-Text-01 (via deploy/compose.benchmark-text.yaml)
- Arm B: MiniMax-M3 (via deploy/compose.benchmark-m3.yaml)
"""

from __future__ import annotations

import argparse
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
from typing import Any, Dict, List, Optional, Tuple

import psycopg2

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AI_ENV_PATH = os.path.join(REPO_ROOT, "deploy", "envs", "ai.env")
REPORTS_DIR = os.path.join(REPO_ROOT, "reports", "benchmark")
os.makedirs(REPORTS_DIR, exist_ok=True)

# Admin JWT generator
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

# Benchmark Source Sets
SOURCE_SETS = {
    1: {
        "name": "Europe PMC",
        "topic": "Technological Advances in Metallurgy Energy and Agriculture",
        "type": "pmcid",
        "pmcids": ["PMC13654891", "PMC13667678", "PMC13621526"],
    },
    2: {
        "name": "HTTPS URL",
        "topic": "Climate Dynamics Cognitive Systems and Educational Interventions",
        "type": "url",
        "items": [
            {
                "url": "https://earthobservatory.nasa.gov/features/GISSTemperature",
                "license": "Public Domain",
                "title": "Earths Temperature Tracker - NASA Science",
            },
            {
                "url": "https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0298000",
                "license": "CC-BY",
                "title": "Intervention and assessment of executive function in children",
            },
            {
                "url": "https://plato.stanford.edu/entries/cognitive-science/",
                "license": "fair use / educational",
                "title": "Cognitive Science",
            },
        ],
    },
    3: {
        "name": "HTML",
        "topic": "Atmospheric Science Climate History and Cognitive Philosophy",
        "type": "html",
        "fixtures": ["PMC13654891.txt", "PMC13667678.txt", "PMC13621526.txt"],
    },
    4: {
        "name": "Markdown",
        "topic": "Principles of Modern Research Data Management and Ethics",
        "type": "markdown",
        "fixtures": ["PMC13407692.txt", "PMC13517498.txt", "PMC13604763.txt"],
    },
    5: {
        "name": "Plain Text",
        "topic": "Foundational Texts in Physics Economics and Evolutionary Biology",
        "type": "text",
        "fixtures": ["PMC13654891.txt", "PMC13665993.txt", "PMC13621526.txt"],
    },
    6: {
        "name": "Mixed Sources",
        "topic": "Cross-Discipline Perspectives on Metallurgy Climate and Data Management",
        "type": "mixed",
        "pmcids": ["PMC13654891"],
        "urls": ["https://earthobservatory.nasa.gov/features/GISSTemperature"],
        "fixtures": ["PMC13407692.txt"],
    },
}

def start_topology(arm: str) -> None:
    compose_file = os.path.join(REPO_ROOT, "deploy", f"compose.benchmark-{arm}.yaml")
    print(f"\n==================================================", flush=True)
    print(f"Starting isolated topology for Arm '{arm.upper()}'...", flush=True)
    print(f"Compose file: {compose_file}", flush=True)
    subprocess.run(["docker", "compose", "-f", compose_file, "up", "-d"], check=True)

    # Wait for health
    print("Waiting for exam-service (8087) and generation-service (8086) to be healthy...", flush=True)
    deadline = time.time() + 60
    exam_ready = False
    gen_ready = False
    while time.time() < deadline:
        if not gen_ready:
            try:
                with urllib.request.urlopen("http://127.0.0.1:8086/healthz", timeout=2) as r:
                    if r.status == 200: gen_ready = True
            except Exception: pass
        if not exam_ready:
            try:
                with urllib.request.urlopen("http://127.0.0.1:8087/healthz", timeout=2) as r:
                    if r.status == 200: exam_ready = True
            except Exception: pass
        if exam_ready and gen_ready:
            break
        time.sleep(2)

    if not (exam_ready and gen_ready):
        raise RuntimeError(f"Topology failed health checks: exam_ready={exam_ready}, gen_ready={gen_ready}")
    print("Topology is HEALTHY.", flush=True)

def stop_topology(arm: str, keep_volume: bool = False) -> None:
    compose_file = os.path.join(REPO_ROOT, "deploy", f"compose.benchmark-{arm}.yaml")
    print(f"Stopping topology for Arm '{arm.upper()}'...", flush=True)
    cmd = ["docker", "compose", "-f", compose_file, "down"]
    if not keep_volume:
        cmd.append("-v")
    subprocess.run(cmd, check=True)

def ingest_source_document(base_url: str, payload: str, source_type: str, title: str, url: str, license_str: str = "https://creativecommons.org/licenses/by/4.0") -> dict:
    req_body = {
        "payload": payload,
        "type": source_type,
        "title": title,
        "url": url,
        "license": license_str,
    }
    req = urllib.request.Request(
        f"{base_url}/api/admin/reading-paper/sources/ingest",
        data=json.dumps(req_body).encode("utf-8"),
        headers=get_auth_headers(),
        method="POST"
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.loads(r.read().decode())

def prepare_job_payload(base_url: str, pair_id: int) -> dict:
    spec = SOURCE_SETS[pair_id]
    topic = spec["topic"]
    stype = spec["type"]

    if stype == "pmcid":
        return {
            "topic": topic,
            "pmcids": spec["pmcids"],
            "provider": "minimax"
        }

    sources = []
    fixtures_dir = os.path.join(REPO_ROOT, "services", "generation-service", "tests", "fixtures", "corpus", "sources_v2")

    if stype == "url":
        for item in spec["items"]:
            u = item["url"]
            lic = item["license"]
            print(f"Ingesting URL source: {u} (license: {lic})...", flush=True)
            ingest_req = urllib.request.Request(
                f"{base_url}/api/admin/reading-paper/sources/ingest",
                data=json.dumps({"payload": u, "type": "url", "license": lic, "strictLicense": False}).encode("utf-8"),
                headers=get_auth_headers(),
                method="POST"
            )
            with urllib.request.urlopen(ingest_req, timeout=60) as r:
                src = json.loads(r.read().decode())
                sources.append(src)
        return {"topic": topic, "sources": sources, "provider": "minimax"}

    elif stype in ("html", "markdown", "text"):
        for idx, f_name in enumerate(spec["fixtures"]):
            f_path = os.path.join(fixtures_dir, f_name)
            with open(f_path, "r", encoding="utf-8") as f:
                content = f.read()[:15000] # ~2500 words
            print(f"Ingesting fixture {f_name} as {stype}...", flush=True)
            doc_title = f"{spec['name']} Document {idx+1}: {f_name.split('.')[0]}"
            doc_payload = content
            if stype == "html":
                doc_payload = f"<html><head><title>{doc_title}</title></head><body><h1>{doc_title}</h1><p>{content}</p></body></html>"
            elif stype == "markdown":
                doc_payload = f"# {doc_title}\n\n{content}"
            doc_url = f"https://europepmc.org/articles/{f_name.split('.')[0]}"
            src = ingest_source_document(base_url, doc_payload, stype, doc_title, doc_url)
            sources.append(src)
        return {"topic": topic, "sources": sources, "provider": "minimax"}

    elif stype == "mixed":
        # PMC
        pmc_src_req = urllib.request.Request(
            f"{base_url}/api/admin/reading-paper/sources/ingest",
            data=json.dumps({"payload": spec["urls"][0], "type": "url", "license": "Public Domain"}).encode("utf-8"),
            headers=get_auth_headers(),
            method="POST"
        )
        with urllib.request.urlopen(pmc_src_req, timeout=60) as r:
            url_src = json.loads(r.read().decode())

        f_path = os.path.join(fixtures_dir, spec["fixtures"][0])
        with open(f_path, "r", encoding="utf-8") as f:
            md_content = f"# Alan Turing FAIR\n\n" + f.read()[:12000]
        md_src = ingest_source_document(
            base_url,
            md_content,
            "markdown",
            "Turing Research Data Management",
            "https://the-turing-way.netlify.app/reproducible-research/rdm.html"
        )

        # Third is PMCID fetched via admin endpoints
        fetch_pmc_req = urllib.request.Request(
            f"http://127.0.0.1:8086/v1/autogen/reading-paper/source",
            data=json.dumps({"pmcid": spec["pmcids"][0]}).encode("utf-8"),
            headers={"X-Internal-Service-Key": "dev-internal-key-not-for-prod", "Content-Type": "application/json"},
            method="POST"
        )
        with urllib.request.urlopen(fetch_pmc_req, timeout=30) as r:
            pmc_src = json.loads(r.read().decode())

        sources = [pmc_src, url_src, md_src]
        return {"topic": topic, "sources": sources, "provider": "minimax"}

    raise ValueError(f"Unknown source type: {stype}")

def run_arm_job(arm: str, pair_id: int) -> dict:
    base_url = "http://127.0.0.1:8087"
    db_port = 5448
    spec = SOURCE_SETS[pair_id]

    print(f"\n=======================================================", flush=True)
    print(f"RUNNING PAIR {pair_id} ({spec['name']}) — ARM {arm.upper()}", flush=True)
    print(f"Topic: {spec['topic']}", flush=True)
    print(f"=======================================================", flush=True)

    job_payload = prepare_job_payload(base_url, pair_id)

    # Submit job
    submit_req = urllib.request.Request(
        f"{base_url}/api/admin/reading-paper/jobs",
        data=json.dumps(job_payload).encode("utf-8"),
        headers=get_auth_headers(),
        method="POST"
    )

    t_submit = time.time()
    try:
        with urllib.request.urlopen(submit_req, timeout=60) as resp:
            data = json.loads(resp.read().decode())
            job_id = data["id"]
            print(f"Job successfully created: ID = {job_id}", flush=True)
    except urllib.error.HTTPError as e:
        err_msg = e.read().decode()
        print(f"FATAL: Job submission failed (HTTP {e.code}): {err_msg}", flush=True)
        return {
            "arm": arm,
            "pair_id": pair_id,
            "pair_name": spec["name"],
            "status": "Failed",
            "error": f"HTTP {e.code}: {err_msg}",
            "wall_time": time.time() - t_submit,
        }

    # Monitor read-only
    seen_logs = 0
    terminal_statuses = {"Completed", "Failed", "Aborted", "Cancelled", "NeedsSources"}
    poll_interval = 15

    while True:
        try:
            req = urllib.request.Request(f"{base_url}/api/admin/reading-paper/jobs/{job_id}", headers=get_auth_headers())
            with urllib.request.urlopen(req, timeout=20) as r:
                job_data = json.loads(r.read().decode())
                status = job_data.get("status")
                completed_sec = job_data.get("completedSections", 0)
                logs = job_data.get("logs") or []

                if len(logs) > seen_logs:
                    for l in logs[seen_logs:]:
                        ts = l.get("timestamp", "")
                        lvl = l.get("level", "")
                        msg = l.get("message", "")
                        print(f"[{ts}] [{lvl}] {msg}", flush=True)
                    seen_logs = len(logs)

                if status in terminal_statuses:
                    t_end = time.time()
                    print(f"\nJob {job_id} reached terminal status: {status} in {t_end - t_submit:.1f}s", flush=True)
                    break
        except Exception as e:
            print(f"Warning: polling exception: {e}", flush=True)

        time.sleep(poll_interval)

    # Collect authoritative PostgreSQL metrics
    metrics = collect_postgres_metrics(db_port, job_id)
    metrics["arm"] = arm
    metrics["model"] = "MiniMax-Text-01" if arm == "text" else "MiniMax-M3"
    metrics["pair_id"] = pair_id
    metrics["pair_name"] = spec["name"]
    metrics["job_id"] = job_id
    metrics["status"] = status
    metrics["wall_time_seconds"] = round(t_end - t_submit, 2)
    metrics["completed_sections"] = completed_sec
    metrics["error"] = job_data.get("error")

    # Pricing calculation
    pricing = {
        "text": {"prompt": 0.001 / 1000, "completion": 0.001 / 1000},
        "m3": {"prompt": 0.0008 / 1000, "completion": 0.002 / 1000},
    }[arm]

    p_tokens = metrics.get("prompt_tokens_used", 0)
    c_tokens = metrics.get("completion_tokens_used", 0)
    billable_cost = round((p_tokens * pricing["prompt"]) + (c_tokens * pricing["completion"]), 5)
    metrics["billable_cost_usd"] = billable_cost

    # Save to file
    out_path = os.path.join(REPORTS_DIR, f"result_{arm}_pair{pair_id}_{int(time.time())}.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(metrics, f, indent=2)
    print(f"Metrics saved to {out_path}", flush=True)

    return metrics

def collect_postgres_metrics(db_port: int, job_id: str) -> dict:
    conn = psycopg2.connect(f"host=127.0.0.1 port={db_port} dbname=exam-db user=exam password=exam")
    cur = conn.cursor()

    # 1. Runs
    cur.execute('SELECT "RunId", "Status", "BudgetUsedCalls", "BudgetUsedTokens", "BudgetUsedWallTimeSeconds" FROM reading_paper_runs WHERE "JobId" = %s;', (job_id,))
    run_row = cur.fetchone()
    run_id = run_row[0] if run_row else None

    # 2. Operations
    cur.execute("""
        SELECT 
            COUNT(*),
            COALESCE(SUM("TokensUsed"), 0),
            COALESCE(SUM("PromptTokensUsed"), 0),
            COALESCE(SUM("CompletionTokensUsed"), 0),
            COALESCE(SUM("ReasoningTokensUsed"), 0),
            COALESCE(AVG("WallTimeUsedSeconds"), 0)
        FROM reading_paper_operations
        WHERE "RunId" = %s AND "OperationType" = 'PROVIDER_CALL' AND "Status" = 'COMPLETED';
    """, (run_id,))
    op_row = cur.fetchone()

    # 3. Operations details
    cur.execute("""
        SELECT "OperationId", "Model_Name" FROM (
            SELECT "OperationId", "ResultRefJson"::json->>'model_name' as "Model_Name"
            FROM reading_paper_operations
            WHERE "RunId" = %s AND "OperationType" = 'PROVIDER_CALL'
        ) t LIMIT 1;
    """, (run_id,))
    sample_model = cur.fetchone()
    observed_model = sample_model[1] if sample_model else None

    # 4. Evaluations
    cur.execute("""
        SELECT "EvaluatorId", "Status", COUNT(*)
        FROM reading_paper_evaluations
        WHERE "RunId" = %s
        GROUP BY "EvaluatorId", "Status";
    """, (run_id,))
    eval_breakdown = {}
    for eval_id, eval_status, cnt in cur.fetchall():
        eval_breakdown.setdefault(eval_id, {})[eval_status] = cnt

    # 5. Exam Check
    cur.execute('SELECT "ExamId" FROM reading_paper_jobs WHERE "Id" = %s;', (job_id,))
    exam_row = cur.fetchone()
    exam_id = str(exam_row[0]) if (exam_row and exam_row[0]) else None

    total_questions = 0
    if exam_id:
        cur.execute('SELECT COUNT(*) FROM questions WHERE "ExamId" = %s;', (exam_id,))
        total_questions = cur.fetchone()[0]

    conn.close()

    return {
        "run_id": run_id,
        "observed_model": observed_model,
        "completed_calls": op_row[0] if op_row else 0,
        "total_tokens_used": int(op_row[1]) if op_row else 0,
        "prompt_tokens_used": int(op_row[2]) if op_row else 0,
        "completion_tokens_used": int(op_row[3]) if op_row else 0,
        "reasoning_tokens_used": int(op_row[4]) if op_row else 0,
        "avg_call_latency_seconds": round(float(op_row[5]), 3) if op_row else 0.0,
        "evaluations_summary": eval_breakdown,
        "exam_id": exam_id,
        "persisted_questions": total_questions,
    }

def main():
    parser = argparse.ArgumentParser(description="LANGFENS Paired MiniMax Benchmark Runner")
    parser.add_argument("--pair", type=int, default=1, choices=range(1, 7), help="Source pair to execute (1..6)")
    parser.add_argument("--arm", choices=["text", "m3", "both"], default="both", help="Execution arm")
    args = parser.parse_args()

    arms = ["text", "m3"] if args.arm == "both" else [args.arm]

    for arm in arms:
        start_topology(arm)
        try:
            res = run_arm_job(arm, args.pair)
            print(f"\nArm {arm.upper()} Result Summary: status={res['status']}, cost=${res.get('billable_cost_usd', 0)}, tokens={res.get('total_tokens_used', 0)}")
        finally:
            stop_topology(arm, keep_volume=False)

if __name__ == "__main__":
    main()
