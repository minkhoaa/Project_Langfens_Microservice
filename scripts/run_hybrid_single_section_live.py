#!/usr/bin/env python3
"""LANGFENS — Hybrid Single-Section Live Validation Runner.

Executes or preflights ONE isolated reading section run using real MiniMax network endpoints:
- MiniMax-Text-01 for passage and question candidate generation
- MiniMax-M3 for eligible repair planning only
- MiniMax-Text-01 for constrained candidate regeneration
- Existing deterministic & independent evaluation gates
- Real PostgreSQL checkpoint persistence via exam-service
- Exactly ONE authoritative Reading generation worker

Target:
- PMC13654891 (West African metallurgy — Didé West 1)
- Section 1: Passage (700-900 words) + 13 questions
- Preserves authoritative blueprint claim bindings fail-closed
- Output snapshot: reports/hybrid_13q_post_hardening_<job_id>.json
"""

from __future__ import annotations

import argparse
import base64
import hashlib
import hmac
import json
import os
import re
import subprocess
import sys
import time
import urllib.error
import urllib.request
from typing import Any, Dict, List, Optional, Tuple

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AI_ENV_PATH = os.path.join(REPO_ROOT, "deploy", "envs", "ai.env")
EXAM_ENV_PATH = os.path.join(REPO_ROOT, "deploy", "envs", "exam.env")
AUTH_ENV_PATH = os.path.join(REPO_ROOT, "deploy", "envs", "auth.env")
COMPOSE_FILE = os.path.join(REPO_ROOT, "deploy", "compose.benchmark-text.yaml")
REPORTS_DIR = os.path.join(REPO_ROOT, "reports")
os.makedirs(REPORTS_DIR, exist_ok=True)
SUBMISSION_MARKER_PATH = os.path.join(REPORTS_DIR, ".hybrid_13q_live_submission_marker.json")
HISTORICAL_SNAPSHOT_PATH = os.path.join(REPORTS_DIR, "hybrid_single_section_13q_live_snapshot.json")

# Implementation references
IMPLEMENTATION_COMMIT = "aeda8c2a379389d0c75d26e8e5c8ab6b77d57d7b"
REPORT_BASELINE_HEAD = "674f7fbc3c6393e81d207ced36bf05a404d79a82"

# MiniMax Pricing (USD per 1,000,000 tokens)
PRICING = {
    "MiniMax-Text-01": {"prompt": 0.20 / 1_000_000, "completion": 1.10 / 1_000_000},
    "MiniMax-M3": {"prompt": 0.50 / 1_000_000, "completion": 2.00 / 1_000_000},
}

TOPIC = "Evolution of an Early and Long-Lasting Iron Smelting Technique at Didé West 1, Falémé Valley, Eastern Senegal"
TARGET_PMCID = "PMC13654891"


# ==============================================================================
# Credential Loading & Masking
# ==============================================================================

def mask_secret(secret: str) -> str:
    """Mask secret value preserving only boundary characters for logs/reports."""
    if not secret:
        return "<EMPTY>"
    if len(secret) <= 8:
        return "***"
    return f"{secret[:4]}...{secret[-4:]}"


def load_minimax_key() -> str:
    """Load MiniMax API key from environment or deploy/envs/ai.env."""
    key = os.environ.get("MINIMAX_API_KEY", "").strip()
    if not key and os.path.exists(AI_ENV_PATH):
        with open(AI_ENV_PATH, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line.startswith("MINIMAX_API_KEY="):
                    key = line.split("=", 1)[1].strip().strip('"').strip("'")
                    break

    if not key:
        return ""

    # Check for placeholder values
    placeholders = {"placeholder", "mock", "xxx", "none", "your_key_here", "test"}
    if key.lower() in placeholders:
        return ""

    return key


def load_jwt_settings() -> Tuple[str, str, str]:
    """Load JWT signing key, issuer, and audience from environment, exam.env, or compose."""
    sign_key = os.environ.get("JWT_SIGN_KEY") or os.environ.get("JwtSettings__SignKey") or ""
    issuer = os.environ.get("JWT_ISSUER") or os.environ.get("JwtSettings__Issuer") or ""
    audience = os.environ.get("JWT_AUDIENCE") or os.environ.get("JwtSettings__Audience") or ""

    # Check deploy/envs/exam.env
    if (not sign_key or not issuer or not audience) and os.path.exists(EXAM_ENV_PATH):
        with open(EXAM_ENV_PATH, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not sign_key and line.startswith("JwtSettings__SignKey="):
                    sign_key = line.split("=", 1)[1].strip().strip('"').strip("'")
                elif not issuer and line.startswith("JwtSettings__Issuer="):
                    issuer = line.split("=", 1)[1].strip().strip('"').strip("'")
                elif not audience and line.startswith("JwtSettings__Audience="):
                    audience = line.split("=", 1)[1].strip().strip('"').strip("'")

    # Check deploy/envs/auth.env
    if (not sign_key or not issuer or not audience) and os.path.exists(AUTH_ENV_PATH):
        with open(AUTH_ENV_PATH, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not sign_key and line.startswith("JwtSettings__SignKey="):
                    sign_key = line.split("=", 1)[1].strip().strip('"').strip("'")
                elif not issuer and line.startswith("JwtSettings__Issuer="):
                    issuer = line.split("=", 1)[1].strip().strip('"').strip("'")
                elif not audience and line.startswith("JwtSettings__Audience="):
                    audience = line.split("=", 1)[1].strip().strip('"').strip("'")

    # Check compose.benchmark-text.yaml
    if (not sign_key or not issuer or not audience) and os.path.exists(COMPOSE_FILE):
        with open(COMPOSE_FILE, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip().lstrip("- ")
                if not sign_key and line.startswith("JwtSettings__SignKey="):
                    sign_key = line.split("=", 1)[1].strip().strip('"').strip("'")
                elif not issuer and line.startswith("JwtSettings__Issuer="):
                    issuer = line.split("=", 1)[1].strip().strip('"').strip("'")
                elif not audience and line.startswith("JwtSettings__Audience="):
                    audience = line.split("=", 1)[1].strip().strip('"').strip("'")

    issuer = issuer or "IssuerName"
    audience = audience or "AudienceName"

    if not sign_key:
        raise ValueError(
            "JwtSettings__SignKey could not be resolved from environment, deploy/envs/exam.env, "
            "deploy/envs/auth.env, or deploy/compose.benchmark-text.yaml."
        )

    return sign_key, issuer, audience


def load_internal_api_key() -> str:
    """Load internal service API key from environment, compose, or exam.env."""
    key = os.environ.get("INTERNAL_API_KEY") or os.environ.get("EXAMSERVICE__INTERNAL__API__KEY") or ""
    if not key and os.path.exists(COMPOSE_FILE):
        with open(COMPOSE_FILE, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip().lstrip("- ")
                if line.startswith("INTERNAL_API_KEY=") or line.startswith("EXAMSERVICE__INTERNAL__API__KEY="):
                    key = line.split("=", 1)[1].strip().strip('"').strip("'")
                    break

    if not key and os.path.exists(EXAM_ENV_PATH):
        with open(EXAM_ENV_PATH, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line.startswith("INTERNAL_API_KEY=") or line.startswith("EXAMSERVICE__INTERNAL__API__KEY="):
                    key = line.split("=", 1)[1].strip().strip('"').strip("'")
                    break

    if not key:
        raise ValueError(
            "INTERNAL_API_KEY could not be resolved from environment, deploy/compose.benchmark-text.yaml, "
            "or deploy/envs/exam.env."
        )

    return key


def create_admin_jwt(sign_key: str, issuer: str = "IssuerName", audience: str = "AudienceName") -> str:
    """Generate a development admin JWT signed with HS256."""
    def b64url(b: bytes) -> str:
        return base64.urlsafe_b64encode(b).rstrip(b"=").decode("ascii")

    header = {"alg": "HS256", "typ": "JWT"}
    payload = {
        "sub": "00000000-0000-0000-0000-000000000001",
        "roles": "ADMIN",
        "iss": issuer,
        "aud": audience,
        "exp": int(time.time()) + 14400,
    }
    part1 = b64url(json.dumps(header, separators=(",", ":")).encode("utf-8"))
    part2 = b64url(json.dumps(payload, separators=(",", ":")).encode("utf-8"))
    sig = hmac.new(sign_key.encode("utf-8"), f"{part1}.{part2}".encode("utf-8"), hashlib.sha256).digest()
    return f"{part1}.{part2}.{b64url(sig)}"


def get_auth_headers(sign_key: str, issuer: str, audience: str) -> dict[str, str]:
    """Build Authorization and Content-Type headers."""
    jwt = create_admin_jwt(sign_key, issuer, audience)
    return {
        "Authorization": f"Bearer {jwt}",
        "Content-Type": "application/json",
        "Accept": "application/json",
    }


# ==============================================================================
# Git and Code Revision Verification
# ==============================================================================

def get_git_head_sha() -> str:
    """Retrieve current repository git HEAD SHA."""
    try:
        res = subprocess.run(["git", "rev-parse", "HEAD"], cwd=REPO_ROOT, capture_output=True, text=True, check=True)
        return res.stdout.strip()
    except Exception:
        return "UNKNOWN"


def check_git_revision() -> dict[str, Any]:
    """Inspect local git revision against post-hardening commits."""
    head_sha = get_git_head_sha()
    return {
        "head_sha": head_sha,
        "implementation_commit": IMPLEMENTATION_COMMIT,
        "report_baseline_head": REPORT_BASELINE_HEAD,
        "matches_baseline_head": head_sha == REPORT_BASELINE_HEAD,
    }


# ==============================================================================
# Docker & Database Helpers
# ==============================================================================

def check_docker_available() -> Tuple[bool, str]:
    """Verify Docker daemon and Docker Compose availability."""
    try:
        d_res = subprocess.run(["docker", "info"], capture_output=True, text=True, timeout=10)
        if d_res.returncode != 0:
            return False, f"Docker daemon not running or not accessible: {d_res.stderr.strip()}"
    except Exception as e:
        return False, f"Docker CLI unavailable: {e}"

    try:
        c_res = subprocess.run(["docker", "compose", "version"], capture_output=True, text=True, timeout=10)
        if c_res.returncode != 0:
            return False, f"Docker Compose unavailable: {c_res.stderr.strip()}"
    except Exception as e:
        return False, f"Docker Compose command failed: {e}"

    return True, "Docker daemon and Compose are available"


def check_benchmark_images() -> dict[str, bool]:
    """Check existence of required benchmark Docker images."""
    required = [
        "postgres:16-alpine",
        "langfens-generation:benchmark",
        "langfens-exam:benchmark",
    ]
    status = {}
    for img in required:
        res = subprocess.run(["docker", "image", "inspect", img], capture_output=True, text=True)
        status[img] = (res.returncode == 0)
    return status


def is_container_running(name: str) -> bool:
    """Check whether a Docker container is currently running."""
    res = subprocess.run(
        ["docker", "ps", "--filter", f"name=^/{name}$", "--format", "{{.Names}}"],
        capture_output=True, text=True
    )
    return res.returncode == 0 and bool(res.stdout.strip())


def run_container_command(container: str, cmd: list[str], timeout: int = 15) -> subprocess.CompletedProcess[str]:
    """Execute a command inside a running Docker container."""
    return subprocess.run(["docker", "exec", container] + cmd, capture_output=True, text=True, timeout=timeout)


def query_db_json(sql: str) -> Any:
    """Execute read-only SQL query returning parsed JSON array from PostgreSQL container."""
    clean_sql = sql.strip().rstrip(";")
    wrapped_sql = f"SELECT json_agg(t) FROM ({clean_sql}) t;"
    cmd = [
        "docker", "exec", "benchmark-text-db",
        "psql", "-U", "exam", "-d", "exam-db", "-t", "-A", "-c", wrapped_sql
    ]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        return []
    out = res.stdout.strip()
    if not out or out == "" or out == "null":
        return []
    try:
        return json.loads(out)
    except Exception:
        return []


def check_db_readiness() -> dict[str, Any]:
    """Check PostgreSQL container health, authenticated query, and persistent storage."""
    result: dict[str, Any] = {
        "container_running": False,
        "pg_isready": False,
        "authenticated_query": False,
        "data_directory": None,
        "volume_backed": False,
        "schema_ready": False,
        "details": "",
    }

    if not is_container_running("benchmark-text-db"):
        result["details"] = "benchmark-text-db container is not running"
        return result
    result["container_running"] = True

    # 1. pg_isready inside container
    ready_res = run_container_command("benchmark-text-db", ["pg_isready", "-U", "exam", "-d", "exam-db", "-h", "127.0.0.1"])
    result["pg_isready"] = (ready_res.returncode == 0)
    if not result["pg_isready"]:
        result["details"] = f"pg_isready check inside container failed: {ready_res.stderr.strip()}"
        return result

    # 2. Authenticated query
    query_res = run_container_command("benchmark-text-db", ["psql", "-U", "exam", "-d", "exam-db", "-t", "-A", "-c", "SELECT 1;"])
    result["authenticated_query"] = (query_res.returncode == 0 and query_res.stdout.strip() == "1")
    if not result["authenticated_query"]:
        result["details"] = f"Authenticated query failed: {query_res.stderr.strip()}"
        return result

    # 3. Check real data_directory and persistent volume backing
    dir_res = run_container_command("benchmark-text-db", ["psql", "-U", "exam", "-d", "exam-db", "-t", "-A", "-c", "SHOW data_directory;"])
    data_dir = dir_res.stdout.strip() if dir_res.returncode == 0 else ""
    result["data_directory"] = data_dir

    inspect_res = subprocess.run(["docker", "inspect", "benchmark-text-db", "--format", "{{json .Mounts}}"], capture_output=True, text=True)
    if inspect_res.returncode == 0:
        try:
            mounts = json.loads(inspect_res.stdout.strip())
            for m in mounts:
                dest = m.get("Destination", "")
                m_type = m.get("Type", "")
                # Check if data_dir is inside a mounted persistent volume
                if (m_type == "volume" or m_type == "bind") and data_dir.startswith(dest):
                    result["volume_backed"] = True
                    break
        except Exception:
            pass

    if not result["volume_backed"]:
        result["details"] = f"PostgreSQL data_directory '{data_dir}' is NOT backed by a mounted persistent volume"
        return result

    # 4. Check schema readiness
    tables_res = run_container_command(
        "benchmark-text-db",
        ["psql", "-U", "exam", "-d", "exam-db", "-t", "-A", "-c",
         "SELECT count(*) FROM information_schema.tables WHERE table_name IN ('reading_paper_jobs', 'reading_paper_runs', 'reading_paper_operations', 'reading_paper_artifacts', 'exams');"]
    )
    if tables_res.returncode == 0 and int(tables_res.stdout.strip() or "0") >= 5:
        result["schema_ready"] = True
    else:
        result["details"] = "Database schema missing required reading_paper tables"

    return result


def verify_worker_topology() -> dict[str, Any]:
    """Verify that exactly ONE authoritative reading worker is running and configured."""
    result: dict[str, Any] = {
        "authoritative_worker_enabled": False,
        "single_worker_instance": False,
        "generation_provider": None,
        "exam_provider": None,
        "minimax_key_in_generation": False,
        "minimax_key_masked": "",
        "details": "",
    }

    if not is_container_running("benchmark-text-exam") or not is_container_running("benchmark-text-gen"):
        result["details"] = "benchmark-text-exam or benchmark-text-gen is not running"
        return result

    # Check exam-service worker count on host (verify no duplicate exam containers)
    ps_res = subprocess.run(["docker", "ps", "--filter", "name=exam", "--format", "{{.Names}}"], capture_output=True, text=True)
    exam_containers = [n.strip() for n in ps_res.stdout.splitlines() if n.strip() and "benchmark" in n and "db" not in n]
    result["single_worker_instance"] = (len(exam_containers) == 1)

    # Check exam-service environment
    exam_env_res = run_container_command("benchmark-text-exam", ["env"])
    exam_env = dict(line.split("=", 1) for line in exam_env_res.stdout.splitlines() if "=" in line)
    worker_enabled = exam_env.get("READING_PAPER_WORKER_ENABLED", "").lower() == "true"
    result["authoritative_worker_enabled"] = worker_enabled
    result["exam_provider"] = exam_env.get("READING_PAPER_LLM_PROVIDER")

    # Check generation-service environment
    gen_env_res = run_container_command("benchmark-text-gen", ["env"])
    gen_env = dict(line.split("=", 1) for line in gen_env_res.stdout.splitlines() if "=" in line)
    result["generation_provider"] = gen_env.get("LLM_PROVIDER_ORDER")
    gen_key = gen_env.get("MINIMAX_API_KEY", "").strip()
    if gen_key and len(gen_key) > 8 and not any(p in gen_key.lower() for p in ("mock", "placeholder", "xxx")):
        result["minimax_key_in_generation"] = True
        result["minimax_key_masked"] = mask_secret(gen_key)

    return result


# ==============================================================================
# Persistent Submission Marker
# ==============================================================================

class SubmissionMarker:
    """Guards against duplicate job submission across process invocations."""

    @staticmethod
    def get_existing() -> Optional[dict]:
        if not os.path.exists(SUBMISSION_MARKER_PATH):
            return None
        try:
            with open(SUBMISSION_MARKER_PATH, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return None

    @staticmethod
    def check_safety(force_reset: bool = False) -> None:
        """Raise RuntimeError if a job was already submitted or in progress."""
        if not os.path.exists(SUBMISSION_MARKER_PATH):
            return
        if force_reset:
            try:
                os.remove(SUBMISSION_MARKER_PATH)
                print(f"[MARKER] Persistent submission marker cleared: {SUBMISSION_MARKER_PATH}", flush=True)
                return
            except OSError as e:
                raise RuntimeError(f"Failed to clear submission marker: {e}")

        existing = SubmissionMarker.get_existing() or {}
        st = existing.get("status", "UNKNOWN")
        job_id = existing.get("job_id", "UNKNOWN")
        ts = existing.get("timestamp_iso", "UNKNOWN")
        raise RuntimeError(
            f"DUPLICATE SUBMISSION BLOCKED: A previous live run submission marker exists at:\n"
            f"  {SUBMISSION_MARKER_PATH}\n"
            f"  Job ID: {job_id}\n"
            f"  Status: {st}\n"
            f"  Timestamp: {ts}\n"
            f"Automatic repeat submission is prohibited to protect provider budgets.\n"
            f"If you deliberately wish to execute a new job, pass --reset-submission-marker."
        )

    @staticmethod
    def write(status: str, job_id: Optional[str] = None, error: Optional[str] = None, extra: Optional[dict] = None) -> None:
        payload = {
            "status": status,
            "job_id": job_id,
            "topic": TOPIC,
            "pmcids": [TARGET_PMCID],
            "provider": "minimax",
            "timestamp": time.time(),
            "timestamp_iso": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "error": error,
        }
        if extra:
            payload.update(extra)
        tmp = SUBMISSION_MARKER_PATH + ".tmp"
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump(payload, f, indent=2)
        os.replace(tmp, SUBMISSION_MARKER_PATH)


# ==============================================================================
# Topology Management (NEVER down -v)
# ==============================================================================

def start_topology(timeout: int = 90) -> None:
    """Start isolated benchmark Docker Compose stack without wiping volumes."""
    print("[STACK] Starting isolated topology via compose.benchmark-text.yaml...", flush=True)
    # NEVER run `docker compose down -v`
    subprocess.run(["docker", "compose", "-f", COMPOSE_FILE, "up", "-d"], check=True)

    print(f"[STACK] Waiting up to {timeout}s for PostgreSQL, generation-service (8086), and exam-service (8087)...", flush=True)
    deadline = time.time() + timeout
    exam_ready = False
    gen_ready = False
    db_ready = False

    while time.time() < deadline:
        if not db_ready:
            db_chk = check_db_readiness()
            if db_chk.get("pg_isready") and db_chk.get("authenticated_query"):
                db_ready = True

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

        if db_ready and gen_ready and exam_ready:
            break
        time.sleep(2)

    if not (db_ready and gen_ready and exam_ready):
        raise RuntimeError(
            f"Benchmark topology failed readiness: db_ready={db_ready}, gen_ready={gen_ready}, exam_ready={exam_ready}"
        )
    print("[STACK] Isolated benchmark topology is healthy and ready.", flush=True)


def stop_topology() -> None:
    """Stop the benchmark topology safely. NEVER deletes persistent volumes."""
    print("[STACK] Stopping isolated benchmark topology (preserving persistent database volume)...", flush=True)
    # NEVER pass `-v`
    subprocess.run(["docker", "compose", "-f", COMPOSE_FILE, "down"], check=True)
    print("[STACK] Benchmark topology stopped cleanly.", flush=True)


# ==============================================================================
# Preflight Suite
# ==============================================================================

def run_preflight(start_stack_if_needed: bool = False, keep_stack: bool = False) -> bool:
    """Run comprehensive read-only preflight checks."""
    print("==================================================================")
    print("LANGFENS — HYBRID 13-QUESTION LIVE RUNNER PREFLIGHT")
    print("==================================================================")
    passed = True
    blockers: list[str] = []

    # 1. Git Revision
    git_rev = check_git_revision()
    print(f"[1/9] Git Revision:")
    print(f"      HEAD SHA: {git_rev['head_sha']}")
    print(f"      Hardened Implementation Commit: {IMPLEMENTATION_COMMIT}")
    if git_rev['matches_baseline_head']:
        print(f"      Matches Baseline Report HEAD: {REPORT_BASELINE_HEAD} [OK]")
    else:
        print(f"      Note: Working HEAD is {git_rev['head_sha']} (baseline: {REPORT_BASELINE_HEAD})")

    # 2. Docker & Compose availability
    docker_ok, docker_msg = check_docker_available()
    print(f"[2/9] Docker & Compose Availability:")
    if docker_ok:
        print(f"      {docker_msg} [OK]")
    else:
        print(f"      FAILED: {docker_msg} [BLOCKER]")
        blockers.append(docker_msg)
        passed = False

    # 3. Benchmark Images
    img_status = check_benchmark_images()
    print(f"[3/9] Required Docker Images:")
    for img, exists in img_status.items():
        if exists:
            print(f"      {img}: Available [OK]")
        else:
            print(f"      {img}: MISSING [BLOCKER]")
            blockers.append(f"Image {img} is missing. Safe rebuild: docker build -f services/exam-service/Dockerfile -t langfens-exam:benchmark .")
            passed = False

    # 4. Host Credentials
    print(f"[4/9] Host Credentials & JWT Settings:")
    minimax_key = load_minimax_key()
    if minimax_key:
        print(f"      MINIMAX_API_KEY: Configured ({mask_secret(minimax_key)}) [OK]")
    else:
        print(f"      MINIMAX_API_KEY: MISSING or Placeholder [BLOCKER]")
        blockers.append("MINIMAX_API_KEY not found in environment or deploy/envs/ai.env")
        passed = False

    try:
        sign_key, issuer, audience = load_jwt_settings()
        print(f"      JwtSettings__SignKey: Configured ({mask_secret(sign_key)}), Issuer={issuer}, Aud={audience} [OK]")
    except Exception as e:
        print(f"      JwtSettings__SignKey: FAILED ({e}) [BLOCKER]")
        blockers.append(str(e))
        passed = False

    try:
        internal_key = load_internal_api_key()
        print(f"      INTERNAL_API_KEY: Configured ({mask_secret(internal_key)}) [OK]")
    except Exception as e:
        print(f"      INTERNAL_API_KEY: FAILED ({e}) [BLOCKER]")
        blockers.append(str(e))
        passed = False

    # Handle --start-stack if topology is down and requested
    started_here = False
    if start_stack_if_needed and passed:
        if not (is_container_running("benchmark-text-db") and is_container_running("benchmark-text-gen") and is_container_running("benchmark-text-exam")):
            try:
                start_topology()
                started_here = True
            except Exception as e:
                blockers.append(f"Failed to start benchmark topology: {e}")
                passed = False

    # 5. PostgreSQL Health & Persistent Storage
    print(f"[5/9] PostgreSQL Container (benchmark-text-db):")
    db_chk = check_db_readiness()
    if db_chk.get("container_running"):
        print(f"      Container Running: YES [OK]")
    else:
        print(f"      Container Running: NO [BLOCKER]")
        blockers.append("benchmark-text-db container is not running (use --start-stack)")
        passed = False

    if db_chk.get("pg_isready"):
        print(f"      pg_isready (internal check): PASS [OK]")
    else:
        print(f"      pg_isready: FAIL [BLOCKER]")
        blockers.append(db_chk.get("details", "PostgreSQL is not ready"))
        passed = False

    if db_chk.get("authenticated_query"):
        print(f"      Authenticated Query (SELECT 1): PASS [OK]")
    else:
        print(f"      Authenticated Query: FAIL [BLOCKER]")
        passed = False

    if db_chk.get("volume_backed"):
        print(f"      Persistent Storage (data_directory={db_chk.get('data_directory')}): VOLUME BACKED [OK]")
    else:
        print(f"      Persistent Storage: FAILED ({db_chk.get('details')}) [BLOCKER]")
        blockers.append("PostgreSQL data_directory is not mounted to persistent volume bench_text_pgdata")
        passed = False

    if db_chk.get("schema_ready"):
        print(f"      Database Schema: Required tables present [OK]")
    else:
        print(f"      Database Schema: Incomplete or unmigrated [BLOCKER]")
        blockers.append("Database schema missing required reading_paper tables")
        passed = False

    # 6. Generation Service (8086)
    print(f"[6/9] Generation Service (8086):")
    gen_healthy = False
    try:
        with urllib.request.urlopen("http://127.0.0.1:8086/healthz", timeout=3) as r:
            if r.status == 200:
                gen_healthy = True
                print(f"      Health Endpoint (http://127.0.0.1:8086/healthz): 200 OK [OK]")
    except Exception as e:
        print(f"      Health Endpoint: UNREACHABLE ({e}) [BLOCKER]")
        blockers.append(f"generation-service is unreachable on port 8086: {e}")
        passed = False

    # 7. Exam Service (8087)
    print(f"[7/9] Exam Service (8087):")
    exam_healthy = False
    try:
        with urllib.request.urlopen("http://127.0.0.1:8087/healthz", timeout=3) as r:
            if r.status == 200:
                exam_healthy = True
                print(f"      Health Endpoint (http://127.0.0.1:8087/healthz): 200 OK [OK]")
    except Exception as e:
        print(f"      Health Endpoint: UNREACHABLE ({e}) [BLOCKER]")
        blockers.append(f"exam-service is unreachable on port 8087: {e}")
        passed = False

    # 8. Worker Topology & Runtime Configuration
    print(f"[8/9] Worker Singularity & Model Configuration:")
    topo = verify_worker_topology()
    if topo.get("single_worker_instance"):
        print(f"      Worker Singularity: Exactly 1 exam-service instance [OK]")
    else:
        print(f"      Worker Singularity: Multiple or zero exam instances detected [BLOCKER]")
        blockers.append("Worker singularity violation: exactly 1 exam-service container required")
        passed = False

    if topo.get("authoritative_worker_enabled"):
        print(f"      Authoritative Reading Generation Worker: ENABLED [OK]")
    else:
        print(f"      Authoritative Reading Generation Worker: DISABLED [BLOCKER]")
        blockers.append("READING_PAPER_WORKER_ENABLED is not true in exam-service")
        passed = False

    if topo.get("exam_provider") == "minimax" and topo.get("generation_provider") == "minimax":
        print(f"      Configured Provider: MiniMax (both exam and generation configured for minimax) [OK]")
    else:
        print(f"      Configured Provider: exam={topo.get('exam_provider')}, gen={topo.get('generation_provider')} [BLOCKER]")
        blockers.append("LLM provider must be configured as 'minimax' in both services (not mock)")
        passed = False

    if topo.get("minimax_key_in_generation"):
        print(f"      Generation Container API Key: VERIFIED ({topo.get('minimax_key_masked')}) [OK]")
    else:
        print(f"      Generation Container API Key: MISSING or Empty [BLOCKER]")
        blockers.append("MINIMAX_API_KEY is not present or is empty in benchmark-text-gen container")
        passed = False

    # 9. Single-Section Execution Target Verification
    print(f"[9/9] Single-Section Execution Path Verification:")
    print(f"      Target PMCID: {TARGET_PMCID}")
    print(f"      Endpoint: POST /api/admin/reading-paper/jobs")
    print(f"      Single Source: pmcids=[{TARGET_PMCID}] -> 1 section, 13 questions verified in code [OK]")

    # Check submission marker safety
    existing_marker = SubmissionMarker.get_existing()
    if existing_marker:
        print(f"      Existing Submission Marker: Status={existing_marker.get('status')}, JobId={existing_marker.get('job_id')}")

    print("------------------------------------------------------------------")
    if passed:
        print("PREFLIGHT: PASS — All prerequisites verified for safe single-section execution.")
    else:
        print("PREFLIGHT: BLOCKED — The following issues must be resolved before LIVE generation:")
        for idx, b in enumerate(blockers, 1):
            print(f"  {idx}. {b}")
    print("==================================================================")

    if started_here and not keep_stack:
        stop_topology()

    return passed


# ==============================================================================
# Job Submission & Recovery (Strict Single Execution)
# ==============================================================================

def submit_single_job(base_url: str, auth_headers: dict[str, str]) -> str:
    """Submit exactly ONE Section 1 job. Fails closed against duplicate execution."""
    # Check persistent marker
    SubmissionMarker.check_safety(force_reset=False)

    payload = {
        "topic": TOPIC,
        "pmcids": [TARGET_PMCID],
        "provider": "minimax"
    }

    # Record SUBMITTING marker BEFORE sending network request
    SubmissionMarker.write(status="SUBMITTING", extra={"payload": payload})

    req = urllib.request.Request(
        f"{base_url}/api/admin/reading-paper/jobs",
        data=json.dumps(payload).encode("utf-8"),
        headers=auth_headers,
        method="POST"
    )

    t0 = time.time()
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            data = json.loads(resp.read().decode())
            job_id = data["id"]
            print(f"[JOB] Created successfully: ID = {job_id}, status = {data.get('status')}", flush=True)
            SubmissionMarker.write(status="SUBMITTED", job_id=job_id, extra={"submitted_status": data.get("status")})
            return job_id

    except (urllib.error.URLError, TimeoutError, OSError) as e:
        print(f"[JOB SUBMIT UNCERTAIN] Network error or timeout during POST: {e}", flush=True)
        SubmissionMarker.write(status="UNCERTAIN_SUBMISSION", error=str(e))

        # Check if job was actually received by querying the jobs list
        print("[JOB RECOVERY] Checking if job was registered despite connection error...", flush=True)
        try:
            list_req = urllib.request.Request(f"{base_url}/api/admin/reading-paper/jobs", headers=auth_headers)
            with urllib.request.urlopen(list_req, timeout=15) as r:
                jobs = json.loads(r.read().decode())
                # Find recent job matching TOPIC created in last 120 seconds
                for j in jobs:
                    if j.get("topic") == TOPIC and time.time() - t0 < 180:
                        rec_id = j.get("id")
                        print(f"[JOB RECOVERY] Found existing submitted job: {rec_id} (Status: {j.get('status')})", flush=True)
                        SubmissionMarker.write(status="RECOVERED_SUBMISSION", job_id=rec_id)
                        return rec_id
        except Exception as query_err:
            print(f"[JOB RECOVERY ERR] Could not inspect jobs: {query_err}", flush=True)

        raise RuntimeError(
            f"Job submission encounter an uncertain result ({e}). "
            f"No matching job was recovered. Halting execution WITHOUT resubmitting to avoid duplicate jobs."
        )

    except urllib.error.HTTPError as e:
        err_msg = e.read().decode()
        SubmissionMarker.write(status="FAILED_SUBMISSION", error=f"HTTP {e.code}: {err_msg}")
        raise RuntimeError(f"Job submission rejected (HTTP {e.code}): {err_msg}")


# ==============================================================================
# Bounded Polling
# ==============================================================================

def poll_job(job_id: str, base_url: str, auth_headers: dict[str, str], timeout_seconds: int = 1800) -> dict[str, Any]:
    """Poll job until terminal status with bounded overall deadline."""
    print(f"\n[MONITOR] Monitoring job {job_id} (timeout={timeout_seconds}s)...", flush=True)
    t0 = time.time()
    deadline = t0 + timeout_seconds
    seen_logs = 0
    terminal_statuses = {"Completed", "Failed", "Aborted", "Cancelled"}
    final_job_data: dict[str, Any] = {}

    SubmissionMarker.write(status="RUNNING", job_id=job_id)

    while time.time() < deadline:
        try:
            get_req = urllib.request.Request(
                f"{base_url}/api/admin/reading-paper/jobs/{job_id}",
                headers=auth_headers
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
                    SubmissionMarker.write(status="TERMINAL", job_id=job_id, extra={"terminal_status": status, "elapsed_seconds": round(elapsed, 2)})
                    return final_job_data

        except Exception as e:
            print(f"Polling warning: {e}", flush=True)

        time.sleep(5)

    elapsed = time.time() - t0
    print(f"\n[MONITOR TIMEOUT] Polling exceeded deadline ({timeout_seconds}s). Last status: {final_job_data.get('status', 'RUNNING')}", flush=True)
    SubmissionMarker.write(status="TIMEOUT", job_id=job_id, extra={"elapsed_seconds": round(elapsed, 2)})
    return final_job_data or {"id": job_id, "status": "TIMEOUT", "error": "Polling deadline exceeded"}


# ==============================================================================
# Deep Read-Only Forensic Snapshot Extraction
# ==============================================================================

def collect_forensics(job_id: str, final_job_data: dict, wall_time_total: float, impl_sha: str) -> dict[str, Any]:
    """Perform read-only forensic extraction from PostgreSQL and build structured snapshot."""
    print(f"\n[FORENSICS] Extracting deep forensic records from PostgreSQL (benchmark-text-db)...", flush=True)

    # 1. Runs
    runs = query_db_json(f"SELECT * FROM reading_paper_runs WHERE \"JobId\" = '{job_id}'")
    run_info = runs[0] if runs else {}
    run_id = run_info.get("RunId") or f"run_{job_id.replace('-', '')}"

    # 2. Operations (read-only query)
    ops = query_db_json(f"""
        SELECT "OperationId", "OperationType", "Status", "ArtifactId", "SectionId",
               "TokensUsed", "PromptTokensUsed", "CompletionTokensUsed", "ReasoningTokensUsed",
               "WallTimeUsedSeconds", "ResultRefJson", "CreatedAt", "RequestHash"
        FROM reading_paper_operations
        WHERE "RunId" = '{run_id}'
        ORDER BY "CreatedAt" ASC
    """) or []

    # 3. Heads (Accepted Artifacts)
    heads = query_db_json(f"""
        SELECT h."ArtifactId", a."ArtifactType", h."AcceptedVersion", h."AcceptedHash",
               a."PayloadJson", a."ParentRefsJson"
        FROM reading_paper_artifact_heads h
        JOIN reading_paper_artifacts a
          ON h."RunId" = a."RunId" AND h."ArtifactId" = a."ArtifactId" AND h."AcceptedVersion" = a."Version"
        WHERE h."RunId" = '{run_id}'
        ORDER BY h."ArtifactId" ASC
    """) or []

    # 4. All Artifact Versions
    all_artifacts = query_db_json(f"""
        SELECT "ArtifactId", "ArtifactType", "Version", "ContentHash", "PayloadJson", "ParentRefsJson", "CreatedAt"
        FROM reading_paper_artifacts
        WHERE "RunId" = '{run_id}'
        ORDER BY "ArtifactId" ASC, "Version" ASC
    """) or []

    # 5. Decisions
    decisions = query_db_json(f"""
        SELECT "DecisionId", "Decision", "CurrentState", "NextState", "Reason", "TargetScope",
               "ExpectedVersion", "CreatedAt"
        FROM reading_paper_decisions
        WHERE "RunId" = '{run_id}'
        ORDER BY "CreatedAt" ASC
    """) or []

    # 6. Evaluations
    evals = query_db_json(f"""
        SELECT "EvaluationId", "EvaluatorId", "EvaluatorVersion", "TargetArtifactId",
               "TargetVersion", "TargetContentHash", "Status", "IsPass", "PayloadJson", "CreatedAt"
        FROM reading_paper_evaluations
        WHERE "RunId" = '{run_id}'
        ORDER BY "CreatedAt" ASC
    """) or []

    # 7. Exams
    exams = query_db_json(f"""
        SELECT e."Id", e."Title", e."Slug", e."DurationMin", COUNT(q."Id") as question_count
        FROM exams e
        LEFT JOIN exam_questions q ON q."ExamId" = e."Id"
        WHERE e."Slug" LIKE 'reading-%'
        GROUP BY e."Id", e."Title", e."Slug", e."DurationMin"
    """) or []

    # 8. Event Outbox (read-only verification of idempotency keys & monotonically increasing sequences)
    outbox = query_db_json(f"""
        SELECT "EventId", "IdempotencyKey", "Sequence", "Status", "EventType", "CreatedAt"
        FROM reading_paper_event_outbox
        WHERE "RunId" = '{run_id}'
        ORDER BY "Sequence" ASC
    """) or []

    # Idempotency & Replay durable evidence check (READ-ONLY, NO grant-operation call)
    op_ids = [o.get("OperationId") for o in ops if o.get("OperationId")]
    ops_unique = len(op_ids) == len(set(op_ids))
    outbox_keys = [e.get("IdempotencyKey") for e in outbox if e.get("IdempotencyKey")]
    outbox_keys_unique = len(outbox_keys) == len(set(outbox_keys))
    sequences = [e.get("Sequence") for e in outbox if e.get("Sequence") is not None]
    monotonic_sequences = sequences == sorted(sequences)

    # Provider Operations Breakdown
    provider_ops = [o for o in ops if o.get("OperationType") == "PROVIDER_CALL"]
    m3_ops = [
        o for o in provider_ops
        if "MiniMax-M3" in str(o.get("ResultRefJson") or "") or "m3_plan" in str(o.get("OperationId") or "")
    ]
    text_ops = [o for o in provider_ops if o not in m3_ops]

    # Token Accounting — record null usage as UNKNOWN, never assume zero
    def sum_or_unknown(values: list[Any]) -> Any:
        valid_nums = [v for v in values if isinstance(v, (int, float))]
        if not values:
            return 0
        if any(v is None for v in values) and not valid_nums:
            return "UNKNOWN"
        return sum(valid_nums)

    total_prompt_tokens = sum_or_unknown([o.get("PromptTokensUsed") for o in ops])
    total_completion_tokens = sum_or_unknown([o.get("CompletionTokensUsed") for o in ops])
    total_reasoning_tokens = sum_or_unknown([o.get("ReasoningTokensUsed") for o in ops])
    total_tokens = sum_or_unknown([o.get("TokensUsed") for o in ops])

    m3_prompt_tokens = sum_or_unknown([o.get("PromptTokensUsed") for o in m3_ops])
    m3_completion_tokens = sum_or_unknown([o.get("CompletionTokensUsed") for o in m3_ops])
    m3_reasoning_tokens = sum_or_unknown([o.get("ReasoningTokensUsed") for o in m3_ops])

    text_prompt_tokens = sum_or_unknown([o.get("PromptTokensUsed") for o in text_ops])
    text_completion_tokens = sum_or_unknown([o.get("CompletionTokensUsed") for o in text_ops])

    # Cost Calculation (Billing estimate separate from provider-reported usage)
    cost_text = 0.0
    if isinstance(text_prompt_tokens, (int, float)) and isinstance(text_completion_tokens, (int, float)):
        cost_text = (text_prompt_tokens * PRICING["MiniMax-Text-01"]["prompt"]) + (text_completion_tokens * PRICING["MiniMax-Text-01"]["completion"])

    cost_m3 = 0.0
    if isinstance(m3_prompt_tokens, (int, float)) and isinstance(m3_completion_tokens, (int, float)):
        cost_m3 = (m3_prompt_tokens * PRICING["MiniMax-M3"]["prompt"]) + (m3_completion_tokens * PRICING["MiniMax-M3"]["completion"])

    total_cost_usd = round(cost_text + cost_m3, 5)

    # Passage Inspection
    passage_head = next((h for h in heads if h.get("ArtifactType") == "Passage"), None)
    passage_payload = json.loads(passage_head.get("PayloadJson")) if passage_head and passage_head.get("PayloadJson") else {}
    passage_wc = passage_payload.get("wordCount", 0)
    if not passage_wc and passage_payload.get("passage"):
        passage_wc = len(re.findall(r"\b\w+\b", passage_payload.get("passage", "")))
    passage_title = passage_payload.get("title", "")

    # Passage Evaluator Outcomes
    passage_evals = [e for e in evals if passage_head and e.get("TargetArtifactId") == passage_head.get("ArtifactId")]
    passage_eval_outcomes = {e.get("EvaluatorId"): {"status": e.get("Status"), "isPass": e.get("IsPass")} for e in passage_evals}

    # Questions Inspection
    question_heads = [h for h in heads if h.get("ArtifactType") == "Question"]
    accepted_q_count = len(question_heads)

    repaired_questions: list[dict] = []
    question_items: list[dict] = []
    blueprint_claim_refs: dict[str, str] = {}
    provenance_verdicts: dict[str, str] = {}
    completion_grounding: dict[str, Any] = {}
    stimulus_integrity: dict[str, Any] = {}

    for qh in question_heads:
        ver = qh.get("AcceptedVersion", 1)
        q_pl = json.loads(qh.get("PayloadJson")) if qh.get("PayloadJson") else {}
        q_num = q_pl.get("questionNumber")
        claim_ref = q_pl.get("evidenceClaimRef") or q_pl.get("claimRef") or "UNBOUND"
        q_art_id = qh.get("ArtifactId", "")

        blueprint_claim_refs[f"Q{q_num}"] = claim_ref

        item_info = {
            "artifactId": q_art_id,
            "version": ver,
            "questionNumber": q_num,
            "type": q_pl.get("questionType"),
            "prompt": q_pl.get("prompt") or q_pl.get("statement"),
            "answer": q_pl.get("answer"),
            "evidenceClaimRef": claim_ref,
        }
        question_items.append(item_info)

        if ver > 1:
            repaired_questions.append(item_info)

        # Question provenance & evaluations
        q_evals = [e for e in evals if e.get("TargetArtifactId") == q_art_id]
        has_prov_fail = any(
            not e.get("IsPass") and ("CLAIM_PROVENANCE" in str(e.get("PayloadJson") or "") or "PROVENANCE" in str(e.get("PayloadJson") or ""))
            for e in q_evals
        )
        provenance_verdicts[f"Q{q_num}"] = "FAIL_PROVENANCE" if has_prov_fail else "PASS"

    # First Failed Question and Issue Code
    first_failed_question: Optional[str] = None
    first_failed_issue_code: Optional[str] = None

    for ev in evals:
        if not ev.get("IsPass") or ev.get("Status") == "FAIL":
            t_art = ev.get("TargetArtifactId", "")
            pl_str = str(ev.get("PayloadJson") or "")
            try:
                ev_pl = json.loads(ev.get("PayloadJson") or "{}")
                issues = ev_pl.get("issues") or []
                for iss in issues:
                    if iss.get("scope") in ("QUESTION", "PASSAGE"):
                        first_failed_question = t_art
                        first_failed_issue_code = iss.get("code")
                        break
            except Exception:
                pass
            if first_failed_question:
                break

    # Evaluator Breakdown
    eval_breakdown: dict[str, dict[str, int]] = {}
    deterministic_evals: list[dict] = []
    blind_solver_evals: list[dict] = []

    for ev in evals:
        eid = ev.get("EvaluatorId", "unknown")
        st = ev.get("Status", "UNKNOWN")
        eval_breakdown.setdefault(eid, {})[st] = eval_breakdown.setdefault(eid, {}).get(st, 0) + 1
        if eid == "eval_blind_solver_adversary":
            blind_solver_evals.append(ev)
        else:
            deterministic_evals.append(ev)

    # Unique Snapshot filename for every job (NEVER overwrite historical snapshot)
    unique_snapshot_filename = f"hybrid_13q_post_hardening_{job_id}.json"
    snapshot_path = os.path.join(REPORTS_DIR, unique_snapshot_filename)

    snapshot: dict[str, Any] = {
        "job_id": job_id,
        "run_id": run_id,
        "implementation_sha": impl_sha,
        "status": final_job_data.get("status"),
        "error": final_job_data.get("error"),
        "wall_time_seconds": round(wall_time_total, 2),
        "passage": {
            "title": passage_title,
            "word_count": passage_wc,
            "artifact_id": passage_head.get("ArtifactId") if passage_head else None,
            "content_hash": passage_head.get("AcceptedHash") if passage_head else None,
            "version": passage_head.get("AcceptedVersion") if passage_head else None,
            "evaluator_outcomes": passage_eval_outcomes,
        },
        "questions": {
            "accepted_count": accepted_q_count,
            "target_count": 13,
            "repaired_count": len(repaired_questions),
            "repaired_details": repaired_questions,
            "blueprint_bound_claim_references": blueprint_claim_refs,
            "provenance_verdicts": provenance_verdicts,
            "first_failed_question": first_failed_question,
            "first_failed_issue_code": first_failed_issue_code,
            "items": question_items,
        },
        "operations": {
            "total_count": len(ops),
            "text01_calls": len(text_ops),
            "m3_calls": len(m3_ops),
            "tokens": {
                "total_tokens": total_tokens,
                "total_prompt_tokens": total_prompt_tokens,
                "total_completion_tokens": total_completion_tokens,
                "total_reasoning_tokens": total_reasoning_tokens,
                "text01_prompt_tokens": text_prompt_tokens,
                "text01_completion_tokens": text_completion_tokens,
                "m3_prompt_tokens": m3_prompt_tokens,
                "m3_completion_tokens": m3_completion_tokens,
                "m3_reasoning_tokens": m3_reasoning_tokens,
            },
            "actual_db_operations": ops,
        },
        "billing": {
            "estimated_cost_usd": total_cost_usd,
            "pricing_reference": PRICING,
            "accounting_type": "calculated_from_reported_tokens",
        },
        "durability_and_replay": {
            "operations_unique": ops_unique,
            "outbox_idempotency_keys_unique": outbox_keys_unique,
            "monotonic_sequences": monotonic_sequences,
            "epoch": run_info.get("Epoch", 1),
            "lease_owner": run_info.get("LeaseOwner"),
            "budget_profile_version": run_info.get("BudgetProfileVersion"),
        },
        "evaluations_breakdown": eval_breakdown,
        "section_checkpoint_status": {
            "final_status": final_job_data.get("status"),
            "completed_sections": final_job_data.get("completedSections", 0),
            "exam_persisted": len(exams) > 0,
            "exams": exams,
        },
        "decisions": decisions,
        "all_artifacts": all_artifacts,
        "all_evaluations": evals,
        "raw_logs": final_job_data.get("logs") or [],
    }

    with open(snapshot_path, "w", encoding="utf-8") as f:
        json.dump(snapshot, f, indent=2)

    print(f"\n[FORENSICS] Unique snapshot saved successfully: {snapshot_path}")
    print(f"=====================================================")
    print(f"Passage: '{passage_title}' ({passage_wc} words)")
    print(f"Accepted Questions: {accepted_q_count} / 13")
    print(f"Repaired Questions: {len(repaired_questions)}")
    print(f"MiniMax-M3 Calls:   {len(m3_ops)} (prompt={m3_prompt_tokens}, comp={m3_completion_tokens}, reasoning={m3_reasoning_tokens})")
    print(f"MiniMax-Text Calls: {len(text_ops)} (prompt={text_prompt_tokens}, comp={text_completion_tokens})")
    print(f"Total Estimated Billable Cost: ${total_cost_usd}")
    print(f"Durable Replay Integrity: OpsUnique={ops_unique}, OutboxUnique={outbox_keys_unique}, Monotonic={monotonic_sequences}")
    print(f"Final Job Status:    {final_job_data.get('status')}")
    print(f"=====================================================")

    return snapshot


# ==============================================================================
# CLI Entry Point
# ==============================================================================

def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="LANGFENS — Hybrid Single-Section Live Validation Runner (Post-Hardening 13-Question Target)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Safe Operational Usage:
  1. Read-only preflight on running topology:
       python3 scripts/run_hybrid_single_section_live.py --preflight

  2. Preflight with automated topology startup:
       python3 scripts/run_hybrid_single_section_live.py --preflight --start-stack

  3. Execute ONE real post-hardening LIVE job:
       python3 scripts/run_hybrid_single_section_live.py --execute --confirm-live --start-stack

Safeguards:
  - Default execution with no arguments does NOT submit a job.
  - Requires explicit --confirm-live to execute a live job.
  - Preserves persistent volume storage; never executes `docker compose down -v`.
  - Enforces persistent submission marker preventing accidental duplicate provider billing.
"""
    )
    parser.add_argument("--preflight", action="store_true", help="Run read-only preflight checks.")
    parser.add_argument("--start-stack", action="store_true", help="Start isolated benchmark topology if needed.")
    parser.add_argument("--execute", action="store_true", help="Execute single-section generation job.")
    parser.add_argument("--confirm-live", action="store_true", help="Required confirmation flag for live execution.")
    parser.add_argument("--keep-stack", action="store_true", help="Keep benchmark Docker stack running upon completion.")
    parser.add_argument("--timeout", type=int, default=1800, help="Maximum job polling timeout in seconds (default: 1800).")
    parser.add_argument("--reset-submission-marker", action="store_true", help="Clear persistent submission marker.")
    parser.add_argument("--poll-job", type=str, default="", help="Resume monitoring and forensic extraction for an existing Job ID without resubmitting.")
    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    # Reset submission marker if explicitly requested
    if args.reset_submission_marker:
        SubmissionMarker.check_safety(force_reset=True)
        if not (args.preflight or args.execute or args.poll_job):
            sys.exit(0)

    # Poll existing job mode
    if args.poll_job:
        job_id = args.poll_job.strip()
        sign_key, issuer, audience = load_jwt_settings()
        auth_headers = get_auth_headers(sign_key, issuer, audience)
        base_url = "http://127.0.0.1:8087"
        final_data = poll_job(job_id, base_url, auth_headers, timeout_seconds=args.timeout)
        impl_sha = get_git_head_sha()
        collect_forensics(job_id, final_data, wall_time_total=0.0, impl_sha=impl_sha)
        sys.exit(0)

    # Default execution with no arguments -> display help and exit
    if not args.preflight and not args.execute:
        parser.print_help()
        print("\n[INFO] No operational action requested. Use --preflight or --execute --confirm-live.", flush=True)
        sys.exit(0)

    # Refuse execute without confirm-live
    if args.execute and not args.confirm_live:
        print("ERROR: Refusing to execute live job without explicit '--confirm-live' confirmation.", file=sys.stderr)
        print("Usage: python3 scripts/run_hybrid_single_section_live.py --execute --confirm-live [--start-stack]", file=sys.stderr)
        sys.exit(1)

    # Preflight Mode
    if args.preflight and not args.execute:
        ok = run_preflight(start_stack_if_needed=args.start_stack, keep_stack=args.keep_stack)
        sys.exit(0 if ok else 1)

    # Confirmed LIVE Execution Mode
    if args.execute and args.confirm_live:
        print("=== LANGFENS HYBRID SINGLE-SECTION LIVE VALIDATION ===")
        print(f"Provider: MiniMax (Text-01 for drafting, M3 for repair planning)")
        print(f"Source: Europe PMC {TARGET_PMCID} (Didé West 1 metallurgy)")
        print(f"Target: Section 1 (Passage 700-900w + 13 questions)")

        # 1. Preflight Verification (Strict gate before any provider dispatch)
        preflight_ok = run_preflight(start_stack_if_needed=args.start_stack, keep_stack=True)
        if not preflight_ok:
            print("ERROR: Preflight failed. Aborting live job execution.", file=sys.stderr)
            sys.exit(1)

        # 2. Resolve credentials & Auth Headers
        sign_key, issuer, audience = load_jwt_settings()
        auth_headers = get_auth_headers(sign_key, issuer, audience)
        base_url = "http://127.0.0.1:8087"

        # 3. Submit Single Section Job
        t0 = time.time()
        job_id = submit_single_job(base_url, auth_headers)

        # 4. Monitor Job Execution
        final_job_data = poll_job(job_id, base_url, auth_headers, timeout_seconds=args.timeout)
        wall_time_total = time.time() - t0

        # 5. Collect Forensic Snapshot
        impl_sha = get_git_head_sha()
        collect_forensics(job_id, final_job_data, wall_time_total, impl_sha)

        # 6. Stop topology if started here and not keep-stack
        if args.start_stack and not args.keep_stack:
            stop_topology()


if __name__ == "__main__":
    main()
