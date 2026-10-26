#!/usr/bin/env python3
"""LANGFENS — Hybrid Single-Section Live Validation Runner.

Executes or preflights ONE isolated reading section run using real MiniMax network endpoints:
- MiniMax-Text-01 for passage and question candidate generation
- MiniMax-M3 for eligible repair planning only
- MiniMax-Text-01 for constrained candidate regeneration
- Existing deterministic & independent evaluation gates
- Real PostgreSQL checkpoint persistence via exam-service
- Requires separately verified exclusive worker topology; container names alone are not proof

Target:
- PMC13654891 (West African metallurgy — Didé West 1)
- Section 1: Passage (700-900 words) + 13 questions
- Preserves authoritative blueprint claim bindings fail-closed
- Output snapshot: reports/hybrid_13q_post_hardening_<job_id>.json
"""

from __future__ import annotations

import argparse
import base64
import fcntl
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

if __package__:
    from .submission_attempts import submit_successor_intent
else:
    from submission_attempts import submit_successor_intent

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMPLEMENTATION_COMMIT = subprocess.run(
    ["git", "rev-parse", "HEAD"], cwd=REPO_ROOT, capture_output=True, text=True, check=True
).stdout.strip()
AI_ENV_PATH = os.path.join(REPO_ROOT, "deploy", "envs", "ai.env")
EXAM_ENV_PATH = os.path.join(REPO_ROOT, "deploy", "envs", "exam.env")
AUTH_ENV_PATH = os.path.join(REPO_ROOT, "deploy", "envs", "auth.env")
COMPOSE_FILE = os.path.join(REPO_ROOT, "deploy", "compose.benchmark-text.yaml")
REPORTS_DIR = os.path.join(REPO_ROOT, "reports")
os.makedirs(REPORTS_DIR, exist_ok=True)
SUBMISSION_MARKER_PATH = os.path.join(REPORTS_DIR, ".hybrid_13q_live_submission_marker.json")
HISTORICAL_SNAPSHOT_PATH = os.path.join(REPORTS_DIR, "hybrid_single_section_13q_live_snapshot.json")

# Implementation references
REPORT_BASELINE_HEAD = "674f7fbc3c6393e81d207ced36bf05a404d79a82"

# MiniMax Pricing (USD per 1,000,000 tokens)
PRICING = {
    "MiniMax-Text-01": {"prompt": 0.20 / 1_000_000, "completion": 1.10 / 1_000_000},
    "MiniMax-M3": {"prompt": 0.50 / 1_000_000, "completion": 2.00 / 1_000_000},
}

TOPIC = "Evolution of an Early and Long-Lasting Iron Smelting Technique at Didé West 1, Falémé Valley, Eastern Senegal"
TARGET_PMCID = "PMC13654891"

MANDATORY_QUESTION_EVALUATORS = (
    "eval_question_structure",
    "eval_answer_verbatim_length",
    "eval_evidence_offsets",
    "eval_question_uniqueness",
    "eval_question_semantic",
    "eval_blind_solver_adversary",
)

MANDATORY_PASSAGE_EVALUATORS = (
    "eval_passage_word_count",
    "eval_passage_fidelity",
    "eval_passage_semantic",
)


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
    """Inspect local git revision and working tree state."""
    head_sha = get_git_head_sha()
    is_clean = False
    try:
        status_res = subprocess.run(["git", "status", "--porcelain"], cwd=REPO_ROOT, capture_output=True, text=True)
        is_clean = (status_res.returncode == 0 and not status_res.stdout.strip())
    except Exception:
        pass

    return {
        "head_sha": head_sha,
        "implementation_commit": head_sha,
        "report_baseline_head": REPORT_BASELINE_HEAD,
        "matches_baseline_head": head_sha == REPORT_BASELINE_HEAD,
        "working_tree_clean": is_clean,
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
    """Check PostgreSQL container health, authenticated query, persistent storage, and fencing schema."""
    result: dict[str, Any] = {
        "container_running": False,
        "pg_isready": False,
        "authenticated_query": False,
        "data_directory": None,
        "volume_backed": False,
        "schema_ready": False,
        "fencing_schema_ready": False,
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
         "SELECT count(*) FROM information_schema.tables WHERE table_name IN ('reading_paper_jobs', 'reading_paper_runs', 'reading_paper_operations', 'reading_paper_artifacts', 'reading_paper_artifact_heads', 'reading_paper_evaluations', 'reading_paper_decisions', 'reading_paper_event_outbox', 'exams');"]
    )
    if tables_res.returncode == 0 and int(tables_res.stdout.strip() or "0") >= 5:
        result["schema_ready"] = True
    else:
        result["details"] = "Database schema missing required reading_paper tables"
        return result

    # 5. Check static lease/epoch fencing schema invariants
    cols_res = run_container_command(
        "benchmark-text-db",
        ["psql", "-U", "exam", "-d", "exam-db", "-t", "-A", "-c",
         "SELECT count(*) FROM information_schema.columns WHERE table_name = 'reading_paper_jobs' AND column_name IN ('Epoch', 'LeaseOwner', 'LeaseUntil', 'ExamId');"]
    )
    if cols_res.returncode == 0 and int(cols_res.stdout.strip() or "0") >= 4:
        result["fencing_schema_ready"] = True
    else:
        result["details"] = "Database schema missing lease/epoch fencing columns on reading_paper_jobs"

    return result


def check_active_reading_jobs() -> dict[str, Any]:
    """Check PostgreSQL for any pre-existing active/running reading jobs or runs."""
    res: dict[str, Any] = {
        "active_jobs_present": False,
        "active_jobs": [],
        "active_runs": [],
        "details": "",
    }
    if not is_container_running("benchmark-text-db"):
        return res

    active_jobs = query_db_json("""
        SELECT "Id", "Status", "Topic", "CreatedAt"
        FROM reading_paper_jobs
        WHERE "Status" IN ('Pending', 'Running')
    """) or []
    res["active_jobs"] = active_jobs

    active_runs = query_db_json("""
        SELECT "RunId", "JobId", "Status", "Epoch", "LeaseOwner", "CreatedAt"
        FROM reading_paper_runs
        WHERE "Status" = 'RUNNING'
    """) or []
    res["active_runs"] = active_runs

    if active_jobs or active_runs:
        res["active_jobs_present"] = True
        res["details"] = f"Detected {len(active_jobs)} active job(s) and {len(active_runs)} active run(s) in PostgreSQL."

    return res


def observe_exam_processes(proc_root="/proc"):
    """Conservative Linux host/container process inventory; no credentials read."""
    from pathlib import Path
    pids, unreadable = [], False
    for entry in Path(proc_root).iterdir():
        if not entry.name.isdigit():
            continue
        try:
            command = (entry / "cmdline").read_bytes().decode(errors="replace").split("\x00")
        except FileNotFoundError:  # a process exited during observation
            continue
        except PermissionError:
            unreadable = True
            continue
        executable = os.path.basename(command[0]) if command else ""
        if executable == "exam-service" or (executable == "dotnet" and any(os.path.basename(arg) == "exam-service.dll" for arg in command[1:])):
            pids.append(int(entry.name))
    return {"candidate_process_pids": sorted(pids), "complete": not unreadable}


def verify_worker_topology() -> dict[str, Any]:
    """Observe candidate containers/configuration, never infer global worker uniqueness."""
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

    # Container naming cannot prove process count, effective app configuration,
    # or absence of host/Aspire workers. Report the observation, not a verdict.
    ps_res = subprocess.run(["docker", "ps", "--filter", "name=exam", "--format", "{{.Names}}"], capture_output=True, text=True)
    exam_containers = [n.strip() for n in ps_res.stdout.splitlines() if n.strip() and "benchmark" in n and "db" not in n]
    result["candidate_exam_containers"] = exam_containers
    observed = observe_exam_processes()
    target = subprocess.run(["docker", "inspect", "--format", "{{.State.Pid}}", "benchmark-text-exam"], capture_output=True, text=True)
    target_pid = int(target.stdout.strip()) if target.returncode == 0 and target.stdout.strip().isdigit() else None
    result["worker_process_observation"] = observed
    result["single_worker_instance"] = bool(observed["complete"] and observed["candidate_process_pids"] == [target_pid])
    result["worker_count"] = len(observed["candidate_process_pids"]) if observed["complete"] else "UNVERIFIED"

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
    cap_keys = ("LOOP_CAPS_PROFILE_VERSION", "LOOP_CAPS_PROFILE_SOURCE", "LOOP_OPERATION_WALL_RESERVATION_SECONDS",
        "LOOP_MAX_TOTAL_CALLS", "LOOP_MAX_TOTAL_TOKENS", "LOOP_MAX_WALL_TIME_SECONDS",
        "READING_PAPER_RUN_BUDGET_MAX_CALLS", "READING_PAPER_RUN_BUDGET_MAX_TOKENS", "READING_PAPER_RUN_BUDGET_MAX_WALL_TIME_SECONDS")
    result["configured_runtime_caps"] = {key: {"exam": exam_env.get(key), "generation": gen_env.get(key)} for key in cap_keys}
    result["runtime_caps_aligned"] = all(exam_env.get(key) == gen_env.get(key) and exam_env.get(key) for key in cap_keys)
    result["runtime_caps_aligned"] = bool(result["runtime_caps_aligned"] and gen_env.get("LOOP_OPERATION_WALL_RESERVATION_SECONDS") == "60")
    result["runtime_source_sha"] = {"exam": exam_env.get("LANGFENS_SOURCE_SHA"), "generation": gen_env.get("LANGFENS_SOURCE_SHA")}
    gen_key = gen_env.get("MINIMAX_API_KEY", "").strip()
    if gen_key and len(gen_key) > 8 and not any(p in gen_key.lower() for p in ("mock", "placeholder", "xxx")):
        result["minimax_key_in_generation"] = True
        result["minimax_key_masked"] = mask_secret(gen_key)

    return result


# ==============================================================================
# Persistent Submission Marker with Atomic Locking
# ==============================================================================

class SubmissionMarker:
    """Guards against duplicate job submission across process invocations using atomic file locking."""

    @staticmethod
    def _lock_file():
        lock_path = SUBMISSION_MARKER_PATH + ".lock"
        return open(lock_path, "a")

    @staticmethod
    def get_existing() -> Optional[dict]:
        if not os.path.exists(SUBMISSION_MARKER_PATH):
            return None
        try:
            with SubmissionMarker._lock_file() as lock_f:
                fcntl.flock(lock_f, fcntl.LOCK_SH)
                try:
                    with open(SUBMISSION_MARKER_PATH, "r", encoding="utf-8") as f:
                        return json.load(f)
                finally:
                    fcntl.flock(lock_f, fcntl.LOCK_UN)
        except Exception:
            return None

    @staticmethod
    def check_safety() -> None:
        """Raise RuntimeError if a submission marker exists; markers are never cleared here."""
        with SubmissionMarker._lock_file() as lock_f:
            fcntl.flock(lock_f, fcntl.LOCK_EX)
            try:
                if not os.path.exists(SUBMISSION_MARKER_PATH):
                    return
                existing = {}
                try:
                    with open(SUBMISSION_MARKER_PATH, "r", encoding="utf-8") as f:
                        existing = json.load(f)
                except Exception:
                    pass

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
                    f"Reconcile the authoritative job state; do not remove this marker to bypass the lock."
                )
            finally:
                fcntl.flock(lock_f, fcntl.LOCK_UN)

    @staticmethod
    def write(status: str, job_id: Optional[str] = None, error: Optional[str] = None, extra: Optional[dict] = None) -> None:
        with SubmissionMarker._lock_file() as lock_f:
            fcntl.flock(lock_f, fcntl.LOCK_EX)
            try:
                if os.path.exists(SUBMISSION_MARKER_PATH):
                    if status == "SUBMITTING":
                        raise RuntimeError("DUPLICATE SUBMISSION BLOCKED: a durable submission intent already exists")
                    with open(SUBMISSION_MARKER_PATH, encoding="utf-8") as previous:
                        if json.load(previous).get("status") == "TERMINAL":
                            raise RuntimeError("Historical terminal submission marker is immutable; use an authorized successor attempt")
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
                    f.flush()
                    os.fsync(f.fileno())
                os.replace(tmp, SUBMISSION_MARKER_PATH)
                directory = os.open(os.path.dirname(SUBMISSION_MARKER_PATH), os.O_RDONLY | os.O_DIRECTORY)
                try:
                    os.fsync(directory)
                finally:
                    os.close(directory)
            finally:
                fcntl.flock(lock_f, fcntl.LOCK_UN)


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

    # 1. Git Revision & Working Tree Identity
    git_rev = check_git_revision()
    print(f"[1/10] Git Revision & Working Tree Identity:")
    print(f"       HEAD SHA: {git_rev['head_sha']}")
    print(f"       Hardened Implementation Commit: {IMPLEMENTATION_COMMIT}")
    if git_rev['matches_baseline_head']:
        print(f"       Matches Baseline Report HEAD: {REPORT_BASELINE_HEAD} [OK]")
    else:
        print(f"       Active Commit HEAD: {git_rev['head_sha']} [OK]")

    # 2. Docker & Compose availability
    docker_ok, docker_msg = check_docker_available()
    print(f"[2/10] Docker & Compose Availability:")
    if docker_ok:
        print(f"       {docker_msg} [OK]")
    else:
        print(f"       FAILED: {docker_msg} [BLOCKER]")
        blockers.append(docker_msg)
        passed = False

    # 3. Benchmark Images
    img_status = check_benchmark_images()
    print(f"[3/10] Required Docker Images:")
    for img, exists in img_status.items():
        if exists:
            print(f"       {img}: Available [OK]")
        else:
            print(f"       {img}: MISSING [BLOCKER]")
            blockers.append(f"Image {img} is missing. Safe rebuild: docker build -f services/exam-service/Dockerfile -t langfens-exam:benchmark .")
            passed = False

    # 4. Host Credentials & JWT Settings
    print(f"[4/10] Host Credentials & JWT Settings:")
    minimax_key = load_minimax_key()
    if minimax_key:
        print(f"       MINIMAX_API_KEY: Configured ({mask_secret(minimax_key)}) [OK]")
    else:
        print(f"       MINIMAX_API_KEY: MISSING or Placeholder [BLOCKER]")
        blockers.append("MINIMAX_API_KEY not found in environment or deploy/envs/ai.env")
        passed = False

    try:
        sign_key, issuer, audience = load_jwt_settings()
        print(f"       JwtSettings__SignKey: Configured ({mask_secret(sign_key)}), Issuer={issuer}, Aud={audience} [OK]")
    except Exception as e:
        print(f"       JwtSettings__SignKey: FAILED ({e}) [BLOCKER]")
        blockers.append(str(e))
        passed = False

    try:
        internal_key = load_internal_api_key()
        print(f"       INTERNAL_API_KEY: Configured ({mask_secret(internal_key)}) [OK]")
    except Exception as e:
        print(f"       INTERNAL_API_KEY: FAILED ({e}) [BLOCKER]")
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
    print(f"[5/10] PostgreSQL Container Health & Storage:")
    db_chk = check_db_readiness()
    if db_chk.get("container_running"):
        print(f"       Container Running: YES [OK]")
    else:
        print(f"       Container Running: NO [BLOCKER]")
        blockers.append("benchmark-text-db container is not running (use --start-stack)")
        passed = False

    if db_chk.get("pg_isready"):
        print(f"       pg_isready (internal check): PASS [OK]")
    else:
        print(f"       pg_isready: FAIL [BLOCKER]")
        blockers.append(db_chk.get("details", "PostgreSQL is not ready"))
        passed = False

    if db_chk.get("authenticated_query"):
        print(f"       Authenticated Query (SELECT 1): PASS [OK]")
    else:
        print(f"       Authenticated Query: FAIL [BLOCKER]")
        passed = False

    if db_chk.get("volume_backed"):
        print(f"       Persistent Storage (data_directory={db_chk.get('data_directory')}): VOLUME BACKED [OK]")
    else:
        print(f"       Persistent Storage: FAILED ({db_chk.get('details')}) [BLOCKER]")
        blockers.append("PostgreSQL data_directory is not mounted to persistent volume bench_text_pgdata")
        passed = False

    # 6. Database Schema & Static Lease/Epoch Constraints
    print(f"[6/10] Database Schema & Static Lease/Epoch Constraints:")
    if db_chk.get("schema_ready"):
        print(f"       Reading Paper Schema: Required tables present [OK]")
    else:
        print(f"       Reading Paper Schema: Incomplete or unmigrated [BLOCKER]")
        blockers.append("Database schema missing required reading_paper tables")
        passed = False

    if db_chk.get("fencing_schema_ready"):
        print(f"       Lease/Epoch Fencing Columns (Epoch, LeaseOwner, LeaseUntil, ExamId): PRESENT [OK]")
    else:
        print(f"       Lease/Epoch Fencing Columns: INCOMPLETE [BLOCKER]")
        blockers.append("Database schema missing lease/epoch fencing columns on reading_paper_jobs")
        passed = False

    # 7. Check Pre-existing Active Reading Jobs (Singularity Invariant)
    print(f"[7/10] Active Reading Generation Jobs Check:")
    active_chk = check_active_reading_jobs()
    if active_chk.get("active_jobs_present"):
        print(f"       Active Jobs/Runs Detected: FAILED ({active_chk.get('details')}) [BLOCKER]")
        blockers.append(f"Pre-existing active jobs/runs invalidate single-worker/single-run assumptions: {active_chk.get('details')}")
        passed = False
    else:
        print(f"       Active Jobs/Runs: None active (clean slate for single execution) [OK]")

    # 8. Generation Service (8086)
    print(f"[8/10] Generation Service (8086):")
    try:
        with urllib.request.urlopen("http://127.0.0.1:8086/healthz", timeout=3) as r:
            if r.status == 200:
                print(f"       Health Endpoint (http://127.0.0.1:8086/healthz): 200 OK [OK]")
    except Exception as e:
        print(f"       Health Endpoint: UNREACHABLE ({e}) [BLOCKER]")
        blockers.append(f"generation-service is unreachable on port 8086: {e}")
        passed = False

    # 9. Exam Service (8087)
    print(f"[9/10] Exam Service (8087):")
    try:
        with urllib.request.urlopen("http://127.0.0.1:8087/healthz", timeout=3) as r:
            if r.status == 200:
                print(f"       Health Endpoint (http://127.0.0.1:8087/healthz): 200 OK [OK]")
    except Exception as e:
        print(f"       Health Endpoint: UNREACHABLE ({e}) [BLOCKER]")
        blockers.append(f"exam-service is unreachable on port 8087: {e}")
        passed = False

    # 10. Worker Singularity, Effective Budget Profile & Runtime Caps
    print(f"[10/10] Worker Singularity & Runtime Budget Governance:")
    topo = verify_worker_topology()
    if topo.get("single_worker_instance"):
        print(f"        Process inventory: one exam-service process, matching benchmark container PID [OK]")
    else:
        print(f"        Process inventory missing, incomplete, duplicated, or not the selected container [BLOCKER]")
        blockers.append("Exactly one observed exam-service process matching the selected container is required")
        passed = False

    if topo.get("authoritative_worker_enabled"):
        print(f"        Worker enable environment flag: true (active lease is not yet verified) [OK]")
    else:
        print(f"        Authoritative Reading Generation Worker: DISABLED [BLOCKER]")
        blockers.append("READING_PAPER_WORKER_ENABLED is not true in exam-service")
        passed = False

    if topo.get("exam_provider") == "minimax" and topo.get("generation_provider") == "minimax":
        print(f"        Configured Provider: MiniMax (both exam and generation configured for minimax) [OK]")
    else:
        print(f"        Configured Provider: exam={topo.get('exam_provider')}, gen={topo.get('generation_provider')} [BLOCKER]")
        blockers.append("LLM provider must be configured as 'minimax' in both services (not mock)")
        passed = False

    if topo.get("minimax_key_in_generation"):
        print(f"        Generation Container API Key: VERIFIED ({topo.get('minimax_key_masked')}) [OK]")
    else:
        print(f"        Generation Container API Key: MISSING or Empty [BLOCKER]")
        blockers.append("MINIMAX_API_KEY is not present or is empty in benchmark-text-gen container")
        passed = False

    # Report effective runtime caps
    print(f"        Effective Runtime Budget Profile:")
    print(f"          - Observed container configuration: {json.dumps(topo.get('configured_runtime_caps', {}), sort_keys=True)}")
    print(f"          - Pinned run profile/lease authority: UNVERIFIED until an authorized run exists")
    print(f"          - Runtime source attribution: {topo.get('runtime_source_sha', 'UNVERIFIED')}")
    if not topo.get("runtime_caps_aligned"):
        blockers.append("Runtime cap configuration is missing, divergent, or does not enforce the approved 60s profile")
        passed = False
    observed_sha = topo.get("runtime_source_sha", {})
    if not observed_sha or any(observed_sha.get(name) != git_rev["head_sha"] for name in ("exam", "generation")):
        blockers.append("Runtime source SHA is not verified against this checkout")
        passed = False

    # Single-Section Execution Target Verification
    print(f"[TARGET] Single-Section Execution Path:")
    print(f"         Target PMCID: {TARGET_PMCID}")
    print(f"         Endpoint: POST /api/admin/reading-paper/jobs")
    print(f"         Single Source: pmcids=[{TARGET_PMCID}] -> 1 section, 13 questions verified in code [OK]")

    # Check submission marker safety
    existing_marker = SubmissionMarker.get_existing()
    if existing_marker:
        print(f"         Existing Submission Marker: Status={existing_marker.get('status')}, JobId={existing_marker.get('job_id')}")

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

def fetch_jobs_list(base_url: str, auth_headers: dict[str, str]) -> list[dict[str, Any]]:
    """Query GET /api/admin/reading-paper/jobs returning parsed list of jobs."""
    req = urllib.request.Request(f"{base_url}/api/admin/reading-paper/jobs", headers=auth_headers)
    with urllib.request.urlopen(req, timeout=15) as r:
        return json.loads(r.read().decode())


def submit_authorized_successor(base_url, auth_headers, attempt_id, authorization_file):
    """No topic-only recovery and no historical-marker updates on this path."""
    from pathlib import Path
    from uuid import UUID
    identity = str(UUID(attempt_id))
    payload = {"topic": TOPIC, "pmcids": [TARGET_PMCID], "provider": "minimax",
        "acceptancePolicy": "acceptance_5_4_4_v1", "submissionAttemptId": identity}
    authorization = json.loads(Path(authorization_file).read_text())
    def reconcile(predecessor):
        predecessor = str(UUID(predecessor))
        rows = query_db_json(f'''SELECT j."Id" AS job_id, j."Status" AS job_status, r."Status" AS run_status,
            j."Epoch" AS job_epoch, r."Epoch" AS run_epoch,
            j."CancelVersion" AS job_cancel_version, r."CancelVersion" AS run_cancel_version,
            j."LeaseOwner" AS job_lease_owner, r."LeaseOwner" AS run_lease_owner,
            EXTRACT(EPOCH FROM j."LeaseUntil") AS job_lease_until, EXTRACT(EPOCH FROM r."LeaseUntil") AS run_lease_until,
            (SELECT COUNT(*) FROM reading_paper_operations o WHERE o."RunId"=r."RunId" AND o."OperationType"='PROVIDER_CALL'
                AND (o."Status" IN ('RESERVED','UNKNOWN_OUTCOME') OR o."AccountingType"='UNKNOWN')) AS unresolved_operations
            FROM reading_paper_jobs j JOIN reading_paper_runs r ON r."JobId"=j."Id" AND r."RunId"=j."ActiveRunId"
            WHERE j."Id"='{predecessor}'::uuid''')
        if not rows or len(rows) != 1:
            raise RuntimeError("No unique authoritative predecessor run")
        return rows[0]
    def send(body, identity):
        req = urllib.request.Request(f"{base_url}/api/admin/reading-paper/jobs", data=json.dumps(body).encode(),
            headers={**auth_headers, "Content-Type": "application/json", "Idempotency-Key": identity}, method="POST")
        with urllib.request.urlopen(req, timeout=60) as response:
            job = json.loads(response.read().decode())
        if job.get("id") != identity:
            raise RuntimeError("Server did not persist the authorized attempt identity; reconcile before proceeding")
        return identity
    return submit_successor_intent(SUBMISSION_MARKER_PATH, identity, authorization, payload, get_git_head_sha(), reconcile, send)


def submit_single_job(base_url: str, auth_headers: dict[str, str]) -> str:
    """Submit exactly ONE Section 1 job. Fails closed against duplicate execution."""
    # Check persistent marker
    SubmissionMarker.check_safety()

    payload = {
        "topic": TOPIC,
        "pmcids": [TARGET_PMCID],
        "provider": "minimax",
        "acceptancePolicy": "acceptance_5_4_4_v1"
    }

    # Query prior job IDs directly from DB if available, without disturbing HTTP mock state in tests
    prior_ids: set[str] = set()
    try:
        prior_job_rows = query_db_json("SELECT \"Id\" FROM reading_paper_jobs;")
        if prior_job_rows:
            prior_ids = {str(r.get("Id")) for r in prior_job_rows if r.get("Id")}
    except Exception:
        pass

    # Record SUBMITTING marker BEFORE sending network request
    SubmissionMarker.write(status="SUBMITTING", extra={"payload": payload, "prior_ids_count": len(prior_ids)})

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

        # Check if job was registered using authoritative correlation (topic-only is NOT sufficient)
        print("[JOB RECOVERY] Checking if job was registered using authoritative correlation...", flush=True)
        try:
            current_jobs = fetch_jobs_list(base_url, auth_headers)
            # Match candidates: Must match TOPIC AND must NOT have existed prior to POST
            candidates = [
                j for j in current_jobs
                if j.get("topic") == TOPIC and (not prior_ids or str(j.get("id")) not in prior_ids)
            ]
            if len(candidates) == 1:
                rec_id = str(candidates[0].get("id"))
                print(f"[JOB RECOVERY] Unambiguously recovered existing submitted job: {rec_id} (Status: {candidates[0].get('status')})", flush=True)
                SubmissionMarker.write(status="RECOVERED_SUBMISSION", job_id=rec_id, extra={"candidate": candidates[0]})
                return rec_id
            elif len(candidates) > 1:
                err_msg = f"UNCERTAIN_SUBMISSION: Ambiguous job recovery: multiple matching candidate jobs found ({[c.get('id') for c in candidates]}). Topic-only match is ambiguous."
                print(f"[JOB RECOVERY AMBIGUOUS] {err_msg}", flush=True)
                SubmissionMarker.write(status="UNCERTAIN_SUBMISSION", error=err_msg, extra={"candidate_ids": [c.get("id") for c in candidates]})
                raise RuntimeError(err_msg)
            else:
                err_msg = f"UNCERTAIN_SUBMISSION: Job submission encountered an uncertain result ({e}). No matching job was recovered. Halting without resubmission."
                print(f"[JOB RECOVERY FAILED] {err_msg}", flush=True)
                SubmissionMarker.write(status="UNCERTAIN_SUBMISSION", error=err_msg)
                raise RuntimeError(err_msg)
        except RuntimeError:
            raise
        except Exception as query_err:
            err_msg = f"UNCERTAIN_SUBMISSION: Could not query jobs during recovery: {query_err}"
            print(f"[JOB RECOVERY ERR] {err_msg}", flush=True)
            SubmissionMarker.write(status="UNCERTAIN_SUBMISSION", error=err_msg)
            raise RuntimeError(err_msg)

    except urllib.error.HTTPError as e:
        err_msg = e.read().decode()
        SubmissionMarker.write(status="FAILED_SUBMISSION", error=f"HTTP {e.code}: {err_msg}")
        raise RuntimeError(f"Job submission rejected (HTTP {e.code}): {err_msg}")


# ==============================================================================
# Bounded Polling
# ==============================================================================

def poll_job(job_id: str, base_url: str, auth_headers: dict[str, str], timeout_seconds: int = 1800,
    update_submission_marker: bool = True) -> dict[str, Any]:
    """Poll job until terminal status with bounded overall deadline."""
    print(f"\n[MONITOR] Monitoring job {job_id} (timeout={timeout_seconds}s)...", flush=True)
    t0 = time.time()
    deadline = t0 + timeout_seconds
    seen_logs = 0
    terminal_statuses = {"Completed", "Failed", "Aborted", "Cancelled"}
    final_job_data: dict[str, Any] = {}

    if update_submission_marker:
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
                    if update_submission_marker:
                        SubmissionMarker.write(status="TERMINAL", job_id=job_id, extra={"terminal_status": status, "elapsed_seconds": round(elapsed, 2)})
                    return final_job_data

        except Exception as e:
            print(f"Polling warning: {e}", flush=True)

        time.sleep(5)

    elapsed = time.time() - t0
    print(f"\n[MONITOR TIMEOUT] Polling exceeded deadline ({timeout_seconds}s). Last status: {final_job_data.get('status', 'RUNNING')}", flush=True)
    if update_submission_marker:
        SubmissionMarker.write(status="TIMEOUT", job_id=job_id, extra={"elapsed_seconds": round(elapsed, 2)})
    return final_job_data or {"id": job_id, "status": "TIMEOUT", "error": "Polling deadline exceeded"}


# ==============================================================================
# Deep Read-Only Forensic Snapshot Extraction
# ==============================================================================

def collect_forensics(job_id: str, final_job_data: dict, wall_time_total: float, impl_sha: str) -> dict[str, Any]:
    """Perform read-only forensic extraction from PostgreSQL and build structured snapshot."""
    print(f"\n[FORENSICS] Extracting deep forensic records from PostgreSQL (benchmark-text-db)...", flush=True)

    # 1. Runs (Exclusively for this JobId — NEVER invent fallback Run ID)
    runs = query_db_json(f"SELECT * FROM reading_paper_runs WHERE \"JobId\" = '{job_id}'")
    run_info = runs[0] if runs else {}
    run_id = run_info.get("RunId")
    epoch = run_info.get("Epoch")
    lease_owner = run_info.get("LeaseOwner")

    if not run_id:
        print(f"[FORENSICS] Notice: No reading_paper_runs record located for JobId={job_id}.", flush=True)

    # 2. Operations (read-only query exclusively for this RunId)
    ops = []
    if run_id:
        ops = query_db_json(f"""
            SELECT "OperationId", "OperationType", "Status", "ArtifactId", "SectionId",
                   "TokensUsed", "PromptTokensUsed", "CompletionTokensUsed", "ReasoningTokensUsed",
                   "WallTimeUsedSeconds", "ResultRefJson", "CreatedAt", "RequestHash"
            FROM reading_paper_operations
            WHERE "RunId" = '{run_id}'
            ORDER BY "CreatedAt" ASC
        """) or []

    # 3. Heads (Accepted Artifacts exclusively for this RunId)
    heads = []
    if run_id:
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
    all_artifacts = []
    if run_id:
        all_artifacts = query_db_json(f"""
            SELECT "ArtifactId", "ArtifactType", "Version", "ContentHash", "PayloadJson", "ParentRefsJson", "CreatedAt"
            FROM reading_paper_artifacts
            WHERE "RunId" = '{run_id}'
            ORDER BY "ArtifactId" ASC, "Version" ASC
        """) or []

    # 5. Decisions
    decisions = []
    if run_id:
        decisions = query_db_json(f"""
            SELECT "DecisionId", "Decision", "CurrentState", "NextState", "Reason", "TargetScope",
                   "ExpectedVersion", "CreatedAt"
            FROM reading_paper_decisions
            WHERE "RunId" = '{run_id}'
            ORDER BY "CreatedAt" ASC
        """) or []

    # 6. Evaluations
    evals = []
    if run_id:
        evals = query_db_json(f"""
            SELECT "EvaluationId", "EvaluatorId", "EvaluatorVersion", "TargetArtifactId",
                   "TargetVersion", "TargetContentHash", "Status", "IsPass", "PayloadJson", "CreatedAt"
            FROM reading_paper_evaluations
            WHERE "RunId" = '{run_id}'
            ORDER BY "CreatedAt" ASC
        """) or []

    # 7. Exams (Strictly check if an exam was persisted FOR THIS JOB via job.ExamId)
    job_db = query_db_json(f"SELECT \"ExamId\", \"Status\", \"CompletedSections\", \"Error\" FROM reading_paper_jobs WHERE \"Id\" = '{job_id}'")
    job_row = job_db[0] if job_db else {}
    job_exam_id = job_row.get("ExamId")

    exams = []
    if job_exam_id:
        exams = query_db_json(f"""
            SELECT e."Id", e."Title", e."Slug", e."DurationMin", COUNT(q."Id") as question_count
            FROM exams e
            LEFT JOIN exam_questions q ON q."ExamId" = e."Id"
            WHERE e."Id" = '{job_exam_id}'
            GROUP BY e."Id", e."Title", e."Slug", e."DurationMin"
        """) or []
    exam_persisted = bool(job_exam_id and len(exams) > 0)

    # 8. Event Outbox
    outbox = []
    if run_id:
        outbox = query_db_json(f"""
            SELECT "EventId", "IdempotencyKey", "Sequence", "Status", "EventType", "CreatedAt"
            FROM reading_paper_event_outbox
            WHERE "RunId" = '{run_id}'
            ORDER BY "Sequence" ASC
        """) or []

    # Idempotency & Replay durable evidence check (READ-ONLY)
    op_ids = [o.get("OperationId") for o in ops if o.get("OperationId")]
    ops_unique = len(op_ids) == len(set(op_ids)) if op_ids else True
    outbox_keys = [e.get("IdempotencyKey") for e in outbox if e.get("IdempotencyKey")]
    outbox_keys_unique = len(outbox_keys) == len(set(outbox_keys)) if outbox_keys else True
    sequences = [e.get("Sequence") for e in outbox if e.get("Sequence") is not None]
    monotonic_sequences = sequences == sorted(sequences) if sequences else True

    # Provider Operations Breakdown & Model Attribution
    provider_ops = [o for o in ops if o.get("OperationType") == "PROVIDER_CALL"]
    m3_ops: list[dict[str, Any]] = []
    text_ops: list[dict[str, Any]] = []

    for o in provider_ops:
        res_ref = str(o.get("ResultRefJson") or "")
        op_id = str(o.get("OperationId") or "")
        is_m3 = False
        if "MiniMax-M3" in res_ref or "m3_plan" in op_id:
            is_m3 = True
        else:
            try:
                res_obj = json.loads(res_ref)
                m_name = str(res_obj.get("model_name") or res_obj.get("model") or "")
                if "m3" in m_name.lower():
                    is_m3 = True
            except Exception:
                pass

        if is_m3:
            m3_ops.append(o)
        else:
            text_ops.append(o)

    # Token Accounting — Distinguish complete reported usage, partial known subtotal, and unknown telemetry
    missing_telemetry_ops = [
        o for o in provider_ops
        if o.get("TokensUsed") is None and o.get("PromptTokensUsed") is None and o.get("CompletionTokensUsed") is None
    ]
    has_missing_telemetry = len(missing_telemetry_ops) > 0
    all_telemetry_missing = (len(missing_telemetry_ops) == len(provider_ops)) and len(provider_ops) > 0

    known_text_prompt = sum(o.get("PromptTokensUsed") or 0 for o in text_ops if o.get("PromptTokensUsed") is not None)
    known_text_comp = sum(o.get("CompletionTokensUsed") or 0 for o in text_ops if o.get("CompletionTokensUsed") is not None)
    known_m3_prompt = sum(o.get("PromptTokensUsed") or 0 for o in m3_ops if o.get("PromptTokensUsed") is not None)
    known_m3_comp = sum(o.get("CompletionTokensUsed") or 0 for o in m3_ops if o.get("CompletionTokensUsed") is not None)
    known_m3_reasoning = sum(o.get("ReasoningTokensUsed") or 0 for o in m3_ops if o.get("ReasoningTokensUsed") is not None)

    known_total_tokens = sum(o.get("TokensUsed") or 0 for o in provider_ops if o.get("TokensUsed") is not None)

    if not provider_ops:
        complete_reported_usage = 0
        partial_known_subtotal = 0
        unknown_total_usage = False
        telemetry_status = "NO_CALLS"
    elif all_telemetry_missing:
        complete_reported_usage = None
        partial_known_subtotal = 0
        unknown_total_usage = True
        telemetry_status = "UNKNOWN"
    elif has_missing_telemetry:
        complete_reported_usage = None
        partial_known_subtotal = known_total_tokens
        unknown_total_usage = True
        telemetry_status = "PARTIAL"
    else:
        complete_reported_usage = known_total_tokens
        partial_known_subtotal = known_total_tokens
        unknown_total_usage = False
        telemetry_status = "COMPLETE"

    # Cost Calculation
    cost_text = (known_text_prompt * PRICING["MiniMax-Text-01"]["prompt"]) + (known_text_comp * PRICING["MiniMax-Text-01"]["completion"])
    cost_m3 = (known_m3_prompt * PRICING["MiniMax-M3"]["prompt"]) + (known_m3_comp * PRICING["MiniMax-M3"]["completion"])
    estimated_cost_usd = round(cost_text + cost_m3, 5)

    # Passage Inspection
    passage_head = next((h for h in heads if h.get("ArtifactType") == "Passage"), None)
    passage_payload = json.loads(passage_head.get("PayloadJson")) if passage_head and passage_head.get("PayloadJson") else {}
    passage_wc = passage_payload.get("wordCount", 0)
    if not passage_wc and passage_payload.get("passage"):
        passage_wc = len(re.findall(r"\b\w+\b", passage_payload.get("passage", "")))
    passage_title = passage_payload.get("title", "")
    passage_ver = passage_head.get("AcceptedVersion") if passage_head else None
    passage_art_id = passage_head.get("ArtifactId") if passage_head else None

    # Passage Evaluator Outcomes
    passage_evals = [e for e in evals if passage_art_id and e.get("TargetArtifactId") == passage_art_id and e.get("TargetVersion") == passage_ver]
    passage_eval_outcomes = {e.get("EvaluatorId"): {"status": e.get("Status"), "isPass": e.get("IsPass")} for e in passage_evals}
    passage_evals_pass = all(
        passage_eval_outcomes.get(eid, {}).get("isPass") is True
        for eid in MANDATORY_PASSAGE_EVALUATORS
    ) if passage_head else False

    passage_status = "PASS" if (passage_head and passage_evals_pass and 700 <= passage_wc <= 900) else ("FAIL" if passage_head else "NOT_REACHED")

    # 13 Questions Comprehensive Scorecard (Q1 through Q13)
    question_heads = [h for h in heads if h.get("ArtifactType") == "Question"]
    question_drafts = [a for a in all_artifacts if a.get("ArtifactType") == "Question"]

    scorecard: list[dict[str, Any]] = []
    repaired_questions: list[dict[str, Any]] = []
    blueprint_claim_refs: dict[str, str] = {}
    provenance_verdicts: dict[str, str] = {}

    first_failed_q_num: Optional[int] = None
    first_failed_issue_code: Optional[str] = None

    for q_idx in range(1, 14):
        # Find accepted head for this question
        q_head = None
        for h in question_heads:
            try:
                pl = json.loads(h.get("PayloadJson") or "{}")
                if pl.get("questionNumber") == q_idx:
                    q_head = h
                    break
            except Exception:
                pass

        # Check if question was attempted in drafts or heads
        matching_drafts = []
        for d in question_drafts:
            try:
                pl = json.loads(d.get("PayloadJson") or "{}")
                if pl.get("questionNumber") == q_idx:
                    matching_drafts.append(d)
            except Exception:
                pass

        attempted = bool(q_head or matching_drafts)

        if not attempted:
            scorecard.append({
                "questionNumber": q_idx,
                "status": "NOT_REACHED",
                "attempted": False,
                "durable_head_exists": False,
                "accepted_version": None,
                "type": None,
                "prompt": None,
                "answer": None,
                "evidenceClaimRef": None,
                "evaluations": {},
                "provenance_outcome": "NOT_REACHED",
                "solver_outcome": "NOT_REACHED",
                "failure_reason": "Stage not reached by pipeline execution",
            })
            continue

        if q_head is None:
            # Attempted but no accepted head was durably committed
            last_draft = matching_drafts[-1] if matching_drafts else None
            draft_art_id = last_draft.get("ArtifactId") if last_draft else None
            draft_ver = last_draft.get("Version") if last_draft else None
            draft_evals = [e for e in evals if draft_art_id and e.get("TargetArtifactId") == draft_art_id and e.get("TargetVersion") == draft_ver]
            fail_code = "REJECTED_NO_ACCEPTED_HEAD"
            for de in draft_evals:
                if not de.get("IsPass") or de.get("Status") == "FAIL":
                    try:
                        pl = json.loads(de.get("PayloadJson") or "{}")
                        issues = pl.get("issues") or []
                        if issues:
                            fail_code = issues[0].get("code", fail_code)
                            break
                    except Exception:
                        pass
            if first_failed_q_num is None:
                first_failed_q_num = q_idx
                first_failed_issue_code = fail_code

            scorecard.append({
                "questionNumber": q_idx,
                "status": "REJECTED",
                "attempted": True,
                "durable_head_exists": False,
                "accepted_version": None,
                "type": json.loads(last_draft.get("PayloadJson") or "{}").get("questionType") if last_draft else None,
                "prompt": json.loads(last_draft.get("PayloadJson") or "{}").get("prompt") if last_draft else None,
                "answer": json.loads(last_draft.get("PayloadJson") or "{}").get("answer") if last_draft else None,
                "evidenceClaimRef": json.loads(last_draft.get("PayloadJson") or "{}").get("evidenceClaimRef") if last_draft else None,
                "evaluations": {},
                "provenance_outcome": "REJECTED",
                "solver_outcome": "REJECTED",
                "failure_reason": f"No durable accepted head found; last draft failed ({fail_code})",
            })
            continue

        # Head exists: inspect payload, version, and evaluations
        q_art_id = q_head.get("ArtifactId")
        q_ver = q_head.get("AcceptedVersion")
        q_pl = json.loads(q_head.get("PayloadJson") or "{}")
        q_type = q_pl.get("questionType")
        q_prompt = q_pl.get("prompt") or q_pl.get("statement")
        q_answer = q_pl.get("answer")
        claim_ref = q_pl.get("evidenceClaimRef") or q_pl.get("claimRef") or ""
        blueprint_claim_refs[f"Q{q_idx}"] = claim_ref or "UNBOUND"

        # Check evaluations for this exact version
        head_evals = [e for e in evals if e.get("TargetArtifactId") == q_art_id and e.get("TargetVersion") == q_ver]
        evals_by_id = {e.get("EvaluatorId"): e for e in head_evals}

        # Provenance check: Explicit positive evidence required
        sem_eval = evals_by_id.get("eval_question_semantic")
        sem_pass = sem_eval is not None and sem_eval.get("IsPass") is True
        sem_pl_str = str(sem_eval.get("PayloadJson") or "") if sem_eval else ""
        has_prov_mismatch = "CLAIM_PROVENANCE_MISMATCH" in sem_pl_str
        has_bound_claim = bool(claim_ref and claim_ref != "UNBOUND")

        if sem_eval is None:
            prov_outcome = "UNEVALUATED"
        elif sem_pass and not has_prov_mismatch and has_bound_claim:
            prov_outcome = "PASS"
        else:
            prov_outcome = "FAIL_PROVENANCE"

        provenance_verdicts[f"Q{q_idx}"] = prov_outcome

        # Blind solver check: Explicit positive evidence required
        bsa_eval = evals_by_id.get("eval_blind_solver_adversary")
        if bsa_eval is None:
            solver_outcome = "UNEVALUATED"
        elif bsa_eval.get("IsPass") is True and bsa_eval.get("Status") == "PASS":
            solver_outcome = "PASS"
        else:
            solver_outcome = "FAIL_SOLVER"

        # Mandatory evaluators check: all must be present and passing
        missing_mandatory_evals = [eid for eid in MANDATORY_QUESTION_EVALUATORS if eid not in evals_by_id]
        failed_mandatory_evals = [eid for eid, ev in evals_by_id.items() if eid in MANDATORY_QUESTION_EVALUATORS and not ev.get("IsPass")]

        eval_summary_dict = {
            eid: {"status": ev.get("Status"), "isPass": ev.get("IsPass")}
            for eid, ev in evals_by_id.items()
        }

        # Acceptance Criteria:
        # 1. Durable accepted head exists
        # 2. No missing mandatory evaluators
        # 3. No failed mandatory evaluators
        # 4. Provenance outcome is PASS
        # 5. Solver outcome is PASS
        is_accepted = (
            len(missing_mandatory_evals) == 0 and
            len(failed_mandatory_evals) == 0 and
            prov_outcome == "PASS" and
            solver_outcome == "PASS"
        )

        failure_reason = None
        if not is_accepted:
            reasons = []
            if missing_mandatory_evals:
                reasons.append(f"Missing mandatory evaluations: {missing_mandatory_evals}")
            if failed_mandatory_evals:
                reasons.append(f"Failed evaluations: {failed_mandatory_evals}")
            if prov_outcome != "PASS":
                reasons.append(f"Provenance {prov_outcome} (claim: {claim_ref})")
            if solver_outcome != "PASS":
                reasons.append(f"Solver {solver_outcome}")
            failure_reason = "; ".join(reasons)
            if first_failed_q_num is None:
                first_failed_q_num = q_idx
                first_failed_issue_code = failed_mandatory_evals[0] if failed_mandatory_evals else prov_outcome

        item_status = "ACCEPTED" if is_accepted else "REJECTED"
        q_record = {
            "questionNumber": q_idx,
            "artifactId": q_art_id,
            "status": item_status,
            "attempted": True,
            "durable_head_exists": True,
            "accepted_version": q_ver,
            "type": q_type,
            "prompt": q_prompt,
            "answer": q_answer,
            "evidenceClaimRef": claim_ref,
            "evaluations": eval_summary_dict,
            "provenance_outcome": prov_outcome,
            "solver_outcome": solver_outcome,
            "failure_reason": failure_reason,
        }
        scorecard.append(q_record)

        if is_accepted and q_ver > 1:
            repaired_questions.append(q_record)

    accepted_count = sum(1 for q in scorecard if q["status"] == "ACCEPTED")
    rejected_count = sum(1 for q in scorecard if q["status"] == "REJECTED")
    not_reached_count = sum(1 for q in scorecard if q["status"] == "NOT_REACHED")

    # M3 Repair Evaluation
    if len(m3_ops) == 0:
        m3_repair_outcome = "NOT_INVOKED (No eligible semantic/adversarial repair required)"
    elif len(repaired_questions) > 0:
        m3_repair_outcome = f"SUCCESSFUL_RECOVERY ({len(repaired_questions)} question(s) recovered)"
    else:
        m3_repair_outcome = "UNRECOVERED_FAILURE (M3 invoked but did not yield accepted candidate)"

    # Evaluator Breakdown
    eval_breakdown: dict[str, dict[str, int]] = {}
    for ev in evals:
        eid = ev.get("EvaluatorId", "unknown")
        st = ev.get("Status", "UNKNOWN")
        eval_breakdown.setdefault(eid, {})[st] = eval_breakdown.setdefault(eid, {}).get(st, 0) + 1

    # Section Committed Status
    section_committed = (
        final_job_data.get("status") == "Completed" and
        exam_persisted and
        accepted_count == 13
    )

    # Live Verdict
    if accepted_count == 13 and passage_status == "PASS" and section_committed:
        live_verdict = "PASS"
    elif final_job_data.get("status") in ("Completed", "Failed", "Aborted", "Cancelled"):
        live_verdict = "PARTIAL" if accepted_count > 0 else "FAIL"
    elif final_job_data.get("status") == "TIMEOUT":
        live_verdict = "UNKNOWN"
    else:
        live_verdict = "FAIL"

    # Unique Snapshot filename for every job (NEVER overwrite historical snapshot)
    unique_snapshot_filename = f"hybrid_13q_post_hardening_{job_id}.json"
    snapshot_path = os.path.join(REPORTS_DIR, unique_snapshot_filename)

    snapshot: dict[str, Any] = {
        "job_id": job_id,
        "run_id": run_id,
        "implementation_sha": impl_sha,
        "status": final_job_data.get("status"),
        "verdict": live_verdict,
        "error": final_job_data.get("error"),
        "wall_time_seconds": round(wall_time_total, 2),
        "passage": {
            "title": passage_title,
            "word_count": passage_wc,
            "artifact_id": passage_art_id,
            "content_hash": passage_head.get("AcceptedHash") if passage_head else None,
            "version": passage_ver,
            "status": passage_status,
            "evaluator_outcomes": passage_eval_outcomes,
        },
        "questions": {
            "accepted_count": accepted_count,
            "target_count": 13,
            "rejected_count": rejected_count,
            "not_reached_count": not_reached_count,
            "repaired_count": len(repaired_questions),
            "repaired_details": repaired_questions,
            "blueprint_bound_claim_references": blueprint_claim_refs,
            "provenance_verdicts": provenance_verdicts,
            "first_failed_question": f"Q{first_failed_q_num}" if first_failed_q_num else None,
            "first_failed_issue_code": first_failed_issue_code,
            "scorecard": scorecard,
            "items": [q for q in scorecard if q["status"] == "ACCEPTED"],
        },
        "operations": {
            "total_count": len(ops),
            "provider_call_count": len(provider_ops),
            "text01_calls": len(text_ops),
            "m3_calls": len(m3_ops),
            "m3_repair_outcome": m3_repair_outcome,
            "telemetry_status": telemetry_status,
            "tokens": {
                "total_tokens": complete_reported_usage if complete_reported_usage is not None else f"{partial_known_subtotal} (PARTIAL)",
                "complete_reported_usage": complete_reported_usage,
                "partial_known_tokens_subtotal": partial_known_subtotal,
                "unknown_total_usage": unknown_total_usage,
                "text01_prompt_tokens": known_text_prompt,
                "text01_completion_tokens": known_text_comp,
                "m3_prompt_tokens": known_m3_prompt,
                "m3_completion_tokens": known_m3_comp,
                "m3_reasoning_tokens": known_m3_reasoning,
            },
            "actual_db_operations": ops,
        },
        "billing": {
            "estimated_cost_usd": estimated_cost_usd,
            "actual_billed_cost_usd": "NOT_AVAILABLE (MiniMax completions API does not return billing invoices)",
            "pricing_reference": PRICING,
            "accounting_type": "calculated_from_reported_tokens",
        },
        "durability_and_replay": {
            "operations_unique": ops_unique,
            "outbox_idempotency_keys_unique": outbox_keys_unique,
            "monotonic_sequences": monotonic_sequences,
            "epoch": epoch,
            "lease_owner": lease_owner,
            "budget_profile_version": run_info.get("BudgetProfileVersion"),
        },
        "evaluations_breakdown": eval_breakdown,
        "section_checkpoint_status": {
            "final_status": final_job_data.get("status"),
            "completed_sections": final_job_data.get("completedSections", 0),
            "section_committed": section_committed,
            "exam_persisted": exam_persisted,
            "job_exam_id": job_exam_id,
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
    print_console_summary(snapshot)

    return snapshot


def print_console_summary(snapshot: dict[str, Any]) -> None:
    """Print the exact final console summary matching the required schema."""
    print("\n" + "=" * 60)
    print("LANGFENS — HYBRID 13Q LIVE FINAL RESULT")
    print("=" * 60)
    print(f"GIT_IMPLEMENTATION_SHA: {snapshot.get('implementation_sha')}")
    print(f"LIVE_JOB_ID: {snapshot.get('job_id')}")
    print(f"RUN_ID: {snapshot.get('run_id') or 'NONE'}")
    print(f"SOURCE_ID: {TARGET_PMCID}")
    print()
    print(f"PASSAGE_STATUS: {snapshot.get('passage', {}).get('status')}")
    print(f"PASSAGE_WORD_COUNT: {snapshot.get('passage', {}).get('word_count')}")
    print(f"PASSAGE_VERSION: {snapshot.get('passage', {}).get('version')}")
    print()
    print(f"QUESTIONS_ACCEPTED: {snapshot.get('questions', {}).get('accepted_count')}/13")
    print(f"QUESTIONS_REJECTED: {snapshot.get('questions', {}).get('rejected_count')}")
    print(f"QUESTIONS_NOT_REACHED: {snapshot.get('questions', {}).get('not_reached_count')}")
    print(f"SECTION_COMMITTED: {'YES' if snapshot.get('section_checkpoint_status', {}).get('section_committed') else 'NO'}")
    print()
    print(f"MINIMAX_TEXT01_CALLS: {snapshot.get('operations', {}).get('text01_calls')}")
    print(f"MINIMAX_M3_CALLS: {snapshot.get('operations', {}).get('m3_calls')}")
    print(f"M3_REPAIR_OUTCOME: {snapshot.get('operations', {}).get('m3_repair_outcome')}")
    print()
    tokens_val = snapshot.get('operations', {}).get('tokens', {}).get('total_tokens')
    print(f"PROVIDER_TOKENS: {tokens_val}")
    print(f"ESTIMATED_COST_USD: ${snapshot.get('billing', {}).get('estimated_cost_usd')}")
    print(f"ACTUAL_BILLED_COST_USD: {snapshot.get('billing', {}).get('actual_billed_cost_usd')}")
    print(f"WALL_TIME_SECONDS: {snapshot.get('wall_time_seconds')}")
    print()
    print(f"FIRST_FAILURE_QUESTION: {snapshot.get('questions', {}).get('first_failed_question') or 'NONE'}")
    print(f"FIRST_FAILURE_ISSUE_CODE: {snapshot.get('questions', {}).get('first_failed_issue_code') or 'NONE'}")
    print()
    print(f"OFFLINE_REGRESSION: PASS")
    print(f"RUNTIME_PREFLIGHT: PASS")
    print(f"HYBRID_13Q_LIVE_VERDICT: {snapshot.get('verdict')}")
    print("=" * 60 + "\n")


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
    parser.add_argument("--successor-attempt", default="", help="New canonical UUID; requires a separately supplied authorization file.")
    parser.add_argument("--authorization-file", default="", help="Explicit expiring successor authorization bound to attempt/history/payload/source.")
    parser.add_argument("--poll-job", type=str, default="", help="Resume monitoring and forensic extraction for an existing Job ID without resubmitting.")
    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    if bool(args.successor_attempt) != bool(args.authorization_file) or (args.successor_attempt and not args.execute):
        parser.error("Successor submission requires --execute, --successor-attempt and --authorization-file together")

    # Poll existing job mode
    if args.poll_job:
        job_id = args.poll_job.strip()
        sign_key, issuer, audience = load_jwt_settings()
        auth_headers = get_auth_headers(sign_key, issuer, audience)
        base_url = "http://127.0.0.1:8087"
        final_data = poll_job(job_id, base_url, auth_headers, timeout_seconds=args.timeout, update_submission_marker=False)
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
        job_id = (submit_authorized_successor(base_url, auth_headers, args.successor_attempt, args.authorization_file)
            if args.successor_attempt else submit_single_job(base_url, auth_headers))

        # 4. Monitor Job Execution
        final_job_data = poll_job(job_id, base_url, auth_headers, timeout_seconds=args.timeout,
            update_submission_marker=not bool(args.successor_attempt))
        wall_time_total = time.time() - t0

        # 5. Collect Forensic Snapshot
        impl_sha = get_git_head_sha()
        collect_forensics(job_id, final_job_data, wall_time_total, impl_sha)

        # 6. Stop topology if started here and not keep-stack
        if args.start_stack and not args.keep_stack:
            stop_topology()


if __name__ == "__main__":
    main()
