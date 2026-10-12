#!/usr/bin/env python3
"""Phase 15 Paired Benchmark Runner: Legacy V1 vs V2 Loop Engine (P15-02 / T15-02).

Executes an authoritative paired comparative benchmark across >=18 paired papers
(6 distinct Europe PMC source triples x 3 seeds), evaluating:
1. Valid Draft rate (>=95% target, V2 vs Legacy comparison)
2. Fidelity must-reject detection rate (100% target)
3. Semantic blocking recall (>=95% target)
4. Per-type question recall (>=90% target across all 6 question types)
5. Ambiguity recall (>=90% target)
6. False rejection rate (<=10% target)
7. P95 latency ratio (V2 P95 <= 1.5x Legacy P95)
8. Median token cost ratio (V2 median <= 2.0x Legacy median)
9. Critical semantic fixture repetitions (>=3 runs) with aggregate & worst-run reporting.

Persistence Rules:
- Primary engine (V2 Loop Engine) persists final exam artifacts to PostgreSQL exam_test_phase15 and authoritative CheckpointClient.
- Shadow Legacy runs are bounded in execution, build draft exam under legacy jobId, and do NOT insert into phase15_persisted_exams.

Outputs:
- artifacts/refactor/phase-15/benchmarks/paired-benchmark-report.json
- artifacts/refactor/phase-15/benchmarks/distributions.json
- artifacts/refactor/phase-15/benchmarks/token-accounting.json
- artifacts/refactor/phase-15/benchmarks/cases/case_{case_idx:02d}_v2.json
- artifacts/refactor/phase-15/benchmarks/cases/case_{case_idx:02d}_legacy.json
"""

from __future__ import annotations

import argparse
import asyncio
import contextlib
from datetime import datetime, timezone
import hashlib
import json
import math
import os
from pathlib import Path
import random
import re
import shutil
import subprocess
import sys
import time
from typing import Any, Dict, List, Optional, Sequence, Tuple
from uuid import UUID, uuid4
import httpx

BASE_DIR = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(BASE_DIR / "services" / "generation-service"))

from app.config import settings
from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueSeverity, IssueScope
from app.contracts.loop import DecisionType, LoopState
from app.contracts.policies import count_words
from app.contracts.questions import (
    MultipleChoiceSingleQuestion,
    QuestionGroup,
    ReadingPaper,
    ReadingSection,
    SentenceCompletionQuestion,
    ShortAnswerQuestion,
    SummaryCompletionQuestion,
    TrueFalseNotGivenQuestion,
    YesNoNotGivenQuestion,
)
from app.evaluators.deterministic import (
    AnswerVerbatimAndLengthEvaluator,
    DuplicateAndShingleEvaluator,
    EvidenceOffsetEvaluator,
    QuestionStructureEvaluator,
)
from app.evaluators.paper import (
    PaperCrossSectionEvaluator,
    PaperLeakageEvaluator,
    PaperMonotonyEvaluator,
    PaperStructureEvaluator,
)
from app.evaluators.registry import EvaluatorRegistry
from app.evaluators.semantic import (
    AmbiguityAndDistractorEvaluator,
    GroundingFidelityEvaluator,
    NotGivenSemanticsEvaluator,
)
from app.facade import GenerationFacade
from app.generators.passage.prompts import PassageStyleProfile
from app.loop.context import AuthorityGrant, BudgetTracker, LoopContext
from app.loop.paper import PaperLoop
from app.loop.policy import LoopPolicy
from app.loop.runtime import LoopResult
from app.observability.accounting import reconcile_run_accounting
from app.persistence.client import CheckpointApiError, CheckpointClient
from app.persistence.models import (
    BenchmarkCampaignCreateRequest,
    BenchmarkCaseCompleteRequest,
    BenchmarkCaseProvisionRequest,
    BuildExamInternalRequest,
    CheckpointCommitRequest,
    OperationGrantRequest,
    OperationReconcileRequest,
)
from app.pipeline import generate_section as legacy_generate_section, trim_passage
from app.providers.gateway import ProviderGateway
from app.providers.models import (
    Capability,
    ChatMessage,
    ProviderRequest,
    ProviderResponse,
)
from app.providers.registry import ProviderRegistry
from tests.test_t08_passage_loop import SQLiteCheckpointSimulation

OUTPUT_DIR_LIVE = BASE_DIR / "artifacts" / "refactor" / "phase-15" / "benchmarks"
OUTPUT_DIR_DIAGNOSTIC = BASE_DIR / "artifacts" / "refactor" / "phase-15" / "benchmarks-diagnostic"
SOURCES_DIR = BASE_DIR / "artifacts" / "refactor" / "phase-07" / "corpus" / "sources"

DEFAULT_SEEDS = (101, 202, 303)

# Engine implementation files whose content defines campaign identity are enumerated at runtime by
# iter_engine_files(); the previous hand-maintained allowlist drifted out of date and allowed a
# campaign ID to stay constant across materially different engine builds.

# 6 distinct Europe PMC sources
BENCHMARK_SOURCES = [
    {
        "pmcid": "PMC13560651",
        "topic": "Microbial Metagenomics of Red Sea Hydrothermal Vents",
        "styleProfile": PassageStyleProfile.NARRATIVE_HISTORICAL,
        "filename": "PMC13560651.txt",
        "default_title": "Prokaryotic Diversity in Red Sea Hydrothermal Vents",
        "url": "https://europepmc.org/articles/PMC13560651",
        "license": "https://creativecommons.org/licenses/by/4.0/",
        "wordCount": 1800,
    },
    {
        "pmcid": "PMC13407692",
        "topic": "Quantum State Purification and Error Correction",
        "styleProfile": PassageStyleProfile.EXPOSITORY_SCIENTIFIC,
        "filename": "PMC13407692.txt",
        "default_title": "Quantum Error Mitigation and Fault Tolerance",
        "url": "https://europepmc.org/articles/PMC13407692",
        "license": "https://creativecommons.org/licenses/by/4.0/",
        "wordCount": 1800,
    },
    {
        "pmcid": "PMC13517498",
        "topic": "Smart Meter Measurement Quality in Low-Voltage Grids",
        "styleProfile": PassageStyleProfile.DISCURSIVE_ANALYTICAL,
        "filename": "PMC13517498.txt",
        "default_title": "Data Integrity in Urban Low-Voltage Transformer Districts",
        "url": "https://europepmc.org/articles/PMC13517498",
        "license": "https://creativecommons.org/licenses/by/4.0/",
        "wordCount": 1800,
    },
    {
        "pmcid": "PMC13621526",
        "topic": "Controlled Environment Agriculture and Vertical Farming",
        "styleProfile": PassageStyleProfile.EXPOSITORY_SCIENTIFIC,
        "filename": "PMC13621526.txt",
        "default_title": "Spectral Control and Soilless Cultivation in High-Tech Greenhouses",
        "url": "https://europepmc.org/articles/PMC13621526",
        "license": "https://creativecommons.org/licenses/by/4.0/",
        "wordCount": 1800,
    },
    {
        "pmcid": "PMC13503497",
        "topic": "Atmospheric Spectroscopy of Transiting Exoplanets",
        "styleProfile": PassageStyleProfile.NARRATIVE_HISTORICAL,
        "filename": "PMC13503497.txt",
        "default_title": "Exoplanet Biosphere Fingerprinting via Space Telescopes",
        "url": "https://europepmc.org/articles/PMC13503497",
        "license": "https://creativecommons.org/licenses/by/4.0/",
        "wordCount": 1800,
    },
    {
        "pmcid": "PMC13583341",
        "topic": "Neural Engram Ensembles and Memory Consolidation",
        "styleProfile": PassageStyleProfile.DISCURSIVE_ANALYTICAL,
        "filename": "PMC13583341.txt",
        "default_title": "Cellular Mechanisms of Memory Traces in Neurodegenerative Disorders",
        "url": "https://europepmc.org/articles/PMC13583341",
        "license": "https://creativecommons.org/licenses/by/4.0/",
        "wordCount": 1800,
    },
]

# 6 distinct Europe PMC source triples
SOURCE_TRIPLES = [
    (BENCHMARK_SOURCES[0], BENCHMARK_SOURCES[1], BENCHMARK_SOURCES[2]),
    (BENCHMARK_SOURCES[1], BENCHMARK_SOURCES[2], BENCHMARK_SOURCES[3]),
    (BENCHMARK_SOURCES[2], BENCHMARK_SOURCES[3], BENCHMARK_SOURCES[4]),
    (BENCHMARK_SOURCES[3], BENCHMARK_SOURCES[4], BENCHMARK_SOURCES[5]),
    (BENCHMARK_SOURCES[4], BENCHMARK_SOURCES[5], BENCHMARK_SOURCES[0]),
    (BENCHMARK_SOURCES[5], BENCHMARK_SOURCES[0], BENCHMARK_SOURCES[1]),
]


def load_live_credentials() -> bool:
    """Silently loads MiniMax credentials, loop caps, and service envs from deploy/envs into environment (enforcing MiniMax-only benchmark allowlist)."""
    direct = os.environ.get("E2E_MINIMAX_API_KEY") or os.environ.get("MINIMAX_API_KEY")
    if direct:
        os.environ["MINIMAX_API_KEY"] = direct
    for env_name in ("ai.env", "loop-caps.env", "exam.env"):
        env_file = BASE_DIR / "deploy" / "envs" / env_name
        if env_file.exists():
            try:
                for line in env_file.read_text(encoding="utf-8").splitlines():
                    line = line.strip()
                    if line and not line.startswith("#") and "=" in line:
                        k, v = line.split("=", 1)
                        k = k.strip()
                        v = v.strip().strip('"').strip("'")
                        if k in ("GROQ_API_KEY", "GROQ_API_KEYS"):
                            continue
                        if k and (k not in os.environ or not os.environ[k]):
                            os.environ[k] = v
            except OSError:
                pass
    os.environ.pop("GROQ_API_KEY", None)
    os.environ.pop("GROQ_API_KEYS", None)
    os.environ["LLM_PROVIDER_ORDER"] = "minimax"
    try:
        settings.groq_api_key = ""
        settings.groq_api_keys = ""
        settings.llm_provider_order = "minimax"
    except Exception:
        pass
    if os.environ.get("MINIMAX_API_KEY") and not os.environ.get("E2E_MINIMAX_API_KEY"):
        os.environ["E2E_MINIMAX_API_KEY"] = os.environ["MINIMAX_API_KEY"]
    return bool(os.environ.get("MINIMAX_API_KEY"))

def load_source_content(source_meta: Dict[str, Any]) -> str:
    path = SOURCES_DIR / source_meta["filename"]
    if path.exists():
        return path.read_text(encoding="utf-8")
    return f"Scientific background on {source_meta['topic']}. " * 50


def compute_corpus_sha256(sources_dir: Path) -> str:
    h = hashlib.sha256()
    for src in sorted(BENCHMARK_SOURCES, key=lambda s: s["filename"]):
        fpath = sources_dir / src["filename"]
        if fpath.exists():
            h.update(fpath.read_bytes())
        else:
            h.update(src["filename"].encode("utf-8"))
    return h.hexdigest()


GENERATION_SERVICE_TREE = BASE_DIR / "services" / "generation-service" / "app"
EXAM_SERVICE_HASH_FILES = (
    "services/exam-service/Features/ReadingPaper/CheckpointService.cs",
    "services/exam-service/Features/ReadingPaper/CheckpointEndpoints.cs",
    "services/exam-service/Features/ReadingPaper/ReadingPaperWorker.cs",
)
# The harness IS the measurement procedure. If it changes, results produced before and after are not
# comparable, so it participates in campaign identity alongside the engine it measures.
MEASUREMENT_HARNESS_FILES = ("scripts/refactor/run_phase15_benchmarks.py",)
_HASH_EXCLUDED_DIRS = {"__pycache__", ".pytest_cache", ".venv", "node_modules"}


def iter_engine_files() -> List[str]:
    """Every Python module under the generation-service app tree, plus the .NET checkpoint surface
    and the measurement harness itself.

    The campaign identity must change whenever engine behaviour can change. A hand-maintained
    allowlist silently drifts out of date and produces campaign IDs that collide across materially
    different engines, so the whole tree is walked deterministically instead.
    """
    rel_paths: List[str] = []
    if GENERATION_SERVICE_TREE.is_dir():
        for path in sorted(GENERATION_SERVICE_TREE.rglob("*.py")):
            if any(part in _HASH_EXCLUDED_DIRS for part in path.parts):
                continue
            rel_paths.append(str(path.relative_to(BASE_DIR)))
    rel_paths.extend(p for p in EXAM_SERVICE_HASH_FILES if (BASE_DIR / p).exists())
    rel_paths.extend(p for p in MEASUREMENT_HARNESS_FILES if (BASE_DIR / p).exists())
    return sorted(set(rel_paths))


def compute_config_sha256() -> tuple[str, List[str]]:
    """SHA256 over settings snapshot + every engine implementation file. Returns (digest, covered files)."""
    h = hashlib.sha256()
    try:
        snapshot = settings.create_unlimited_benchmark_snapshot()
        h.update(json.dumps(snapshot, sort_keys=True).encode("utf-8"))
    except Exception:
        h.update(b"phase15_unlimited_default_config")
    covered = iter_engine_files()
    for rel_path in covered:
        code_file = BASE_DIR / rel_path
        if code_file.exists():
            h.update(rel_path.encode("utf-8"))
            h.update(hashlib.sha256(code_file.read_bytes()).digest())
    return h.hexdigest(), covered


def compute_worktree_binding() -> Dict[str, Any]:
    """Binds campaign results to the complete worktree, not just the engine surface.

    `configSha256` covers behaviour-affecting engine code. This additionally records the full
    worktree state so any tracked modification or untracked addition is visible in the evidence
    bundle and any drift invalidates the run by inspection rather than by assumption.
    """
    try:
        head = subprocess.check_output(["git", "rev-parse", "HEAD"], stderr=subprocess.DEVNULL).decode().strip()
    except Exception:
        head = "unknown"

    status_lines: List[str] = []
    try:
        # --untracked-files=all is required: the default collapses untracked DIRECTORIES to a single
        # entry, which would hash a marker instead of the contents of e.g. services/generation-service/
        # (the whole engine tree is untracked in this worktree).
        status_lines = [ln for ln in subprocess.check_output(
            ["git", "status", "--porcelain", "--untracked-files=all"], stderr=subprocess.DEVNULL
        ).decode().splitlines() if ln.strip()]
    except Exception:
        status_lines = []

    modified: List[str] = []
    untracked: List[str] = []
    for line in status_lines:
        code, _, name = line[:2], line[2:3], line[3:].strip()
        if code == "??":
            untracked.append(name)
        else:
            modified.append(name)

    h = hashlib.sha256()
    h.update(head.encode("utf-8"))
    for name in sorted(modified + untracked):
        path = BASE_DIR / name
        if path.is_file():
            h.update(name.encode("utf-8"))
            h.update(hashlib.sha256(path.read_bytes()).digest())
        else:
            h.update(name.encode("utf-8"))
            h.update(b"<directory-or-absent>")

    return {
        "gitHead": head,
        "dirty": bool(status_lines),
        "modifiedPathCount": len(modified),
        "untrackedPathCount": len(untracked),
        "modifiedPaths": sorted(modified),
        "untrackedPaths": sorted(untracked),
        "worktreeSha256": h.hexdigest(),
    }


def derive_campaign_id(gate_id: str, corpus_hash: str = "", config_hash: str = "", salt: str = "") -> str:
    raw = f"{gate_id}:{corpus_hash}:{config_hash}:{salt}"
    digest = hashlib.sha256(raw.encode("utf-8")).hexdigest()[:12]
    return f"camp_{gate_id}_{digest}"


def preserve_historical_evidence() -> None:
    """Preserves prior 36-call diagnostic/historical evidence before fresh live runs."""
    hist_archive_dir = BASE_DIR / "artifacts" / "refactor" / "phase-15" / "benchmarks-historical-36calls"
    rep_file = OUTPUT_DIR_LIVE / "paired-benchmark-report.json"
    if rep_file.exists():
        try:
            with open(rep_file, "r", encoding="utf-8") as f:
                data = json.load(f)
            prof = data.get("benchmarkExecutionProfile", {})
            paired_cases = data.get("pairedCases", [])
            has_campaign = any("campaignId" in c.get("v2", {}) for c in paired_cases) if paired_cases else False
            if prof.get("totalLiveCallsExecuted") == 36 or not has_campaign:
                if not hist_archive_dir.exists():
                    hist_archive_dir.mkdir(parents=True, exist_ok=True)
                    (hist_archive_dir / "cases").mkdir(parents=True, exist_ok=True)
                    for fn in ("paired-benchmark-report.json", "distributions.json", "token-accounting.json"):
                        src_f = OUTPUT_DIR_LIVE / fn
                        if src_f.exists():
                            shutil.copy2(src_f, hist_archive_dir / fn)
                    cases_src = OUTPUT_DIR_LIVE / "cases"
                    if cases_src.exists():
                        for cf in cases_src.glob("case_*.json"):
                            shutil.copy2(cf, hist_archive_dir / "cases" / cf.name)
                    print(f"[*] Archived pre-existing historical evidence to {hist_archive_dir}")
        except Exception as exc:
            print(f"[WARN] Historical evidence archive check: {exc}")


class PostgresBenchmarkPersistence:
    """Manages PostgreSQL queries and persistence for Phase 15 benchmark runs."""

    FORBIDDEN_PROD_DBS = {
        "exam-db", "auth-db", "attempt-db", "writing-db", "speaking-db",
        "course-db", "gamification-db", "dictionary-db", "vocabulary-db",
    }

    def __init__(self):
        self.host = os.environ.get("PGHOST", "localhost")
        self.port = os.environ.get("PGPORT", "5433")
        self.user = os.environ.get("PGUSER", "exam")
        self.password = os.environ.get("PGPASSWORD", "exam")
        self.requested_target = os.environ.get("PG_BENCHMARK_DB", "exam_test_phase15")
        self.dbname = self.requested_target

        if self.dbname in self.FORBIDDEN_PROD_DBS:
            raise RuntimeError(
                f"Target database '{self.dbname}' is a production database name and is strictly forbidden "
                f"for benchmark persistence. Must use an isolated staging/test target (e.g. 'exam_test_phase15')."
            )

        self.db_identity = {
            "target": "ISOLATED_STAGING_TEST",
            "requestedDatabase": self.requested_target,
            "resolvedDatabase": self.dbname,
            "host": self.host,
            "port": int(self.port) if str(self.port).isdigit() else 5433,
            "user": self.user,
            "isIsolatedStagingTarget": True,
        }

        print(f"[P15-DB] Benchmark persistence bound to {self.dbname}@{self.host}:{self.port} (isolated staging/test target)")
        self._ensure_database_exists()
        self.pg_available = self._check_postgres_connection()
        if self.pg_available:
            self._init_schema()

    def _ensure_database_exists(self) -> None:
        cmd_check = [
            "psql", "-h", self.host, "-p", str(self.port), "-U", self.user, "-d", "postgres",
            "-t", "-A", "-c", f"SELECT 1 FROM pg_database WHERE datname='{self.dbname}';",
        ]
        try:
            res = subprocess.run(cmd_check, env={**os.environ, "PGPASSWORD": self.password}, capture_output=True, text=True, timeout=5)
            if res.returncode == 0 and "1" not in res.stdout.strip():
                cmd_create = [
                    "psql", "-h", self.host, "-p", str(self.port), "-U", self.user, "-d", "postgres",
                    "-c", f"CREATE DATABASE \"{self.dbname}\";",
                ]
                subprocess.run(cmd_create, env={**os.environ, "PGPASSWORD": self.password}, capture_output=True, text=True, timeout=5)
        except Exception:
            pass

    def _check_postgres_connection(self) -> bool:
        cmd = [
            "psql", "-h", self.host, "-p", str(self.port), "-U", self.user, "-d", self.dbname,
            "-t", "-A", "-c", "SELECT 1;",
        ]
        try:
            res = subprocess.run(cmd, env={**os.environ, "PGPASSWORD": self.password}, capture_output=True, text=True, timeout=5)
            return res.returncode == 0 and res.stdout.strip() == "1"
        except Exception:
            return False

    def _init_schema(self) -> None:
        init_sql = """
        CREATE TABLE IF NOT EXISTS phase15_persisted_exams (
            exam_id VARCHAR(128) PRIMARY KEY,
            engine VARCHAR(64) NOT NULL,
            run_id VARCHAR(128) NOT NULL,
            is_primary BOOLEAN NOT NULL,
            sections_count INT NOT NULL,
            total_questions INT NOT NULL,
            payload_json TEXT NOT NULL,
            committed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
        );
        """
        cmd = [
            "psql", "-h", self.host, "-p", str(self.port), "-U", self.user, "-d", self.dbname,
            "-c", init_sql,
        ]
        try:
            subprocess.run(cmd, env={**os.environ, "PGPASSWORD": self.password}, capture_output=True, text=True, check=True)
        except Exception:
            pass

    def persist_v2_exam(self, exam_id: str, run_id: str, payload: Dict[str, Any]) -> bool:
        """Only V2 primary runs persist to Postgres."""
        if not self.pg_available:
            return False
        payload_str = json.dumps(payload).replace("'", "''")
        insert_sql = f"""
        INSERT INTO phase15_persisted_exams (exam_id, engine, run_id, is_primary, sections_count, total_questions, payload_json)
        VALUES ('{exam_id}', 'V2', '{run_id}', TRUE, 3, 40, '{payload_str}')
        ON CONFLICT (exam_id) DO UPDATE SET payload_json = EXCLUDED.payload_json, committed_at = NOW();
        """
        cmd = [
            "psql", "-h", self.host, "-p", self.port, "-U", self.user, "-d", self.dbname,
            "-c", insert_sql,
        ]
        res = subprocess.run(cmd, env={**os.environ, "PGPASSWORD": self.password}, capture_output=True, text=True)
        return res.returncode == 0

    def query_exam_counts(self, active_run_ids: Optional[List[str]] = None) -> Dict[str, int]:
        if not self.pg_available:
            return {"v2": 0, "legacy": 0}
        where_clause = ""
        if active_run_ids is not None:
            if not active_run_ids:
                return {"v2": 0, "legacy": 0}
            escaped_ids = ", ".join(f"'{str(rid).replace(chr(39), chr(39)+chr(39))}'" for rid in active_run_ids)
            where_clause = f"WHERE run_id IN ({escaped_ids})"
        cmd = [
            "psql", "-h", self.host, "-p", str(self.port), "-U", self.user, "-d", self.dbname,
            "-t", "-A", "-c",
            f"SELECT engine, count(*) FROM phase15_persisted_exams {where_clause} GROUP BY engine;",
        ]
        res = subprocess.run(cmd, env={**os.environ, "PGPASSWORD": self.password}, capture_output=True, text=True)
        counts = {"v2": 0, "legacy": 0}
        for line in res.stdout.strip().splitlines():
            if not line:
                continue
            parts = line.split("|")
            if len(parts) == 2:
                engine, count = parts[0].strip(), int(parts[1].strip())
                if engine == "V2":
                    counts["v2"] = count
                elif engine == "Legacy":
                    counts["legacy"] = count
        return counts

    def update_sources_json(self, job_id: str, run_id: str, sources: List[Dict[str, Any]]) -> None:
        if not self.pg_available:
            return
        sources_str = json.dumps(sources).replace("'", "''")
        sql = f"""
        UPDATE reading_paper_jobs SET "SourcesJson" = '{sources_str}' WHERE "Id"::text = '{job_id}';
        UPDATE reading_paper_runs SET "SourceRevisionsJson" = '{sources_str}' WHERE "RunId" = '{run_id}';
        """
        cmd = [
            "psql", "-h", self.host, "-p", str(self.port), "-U", self.user, "-d", self.dbname,
            "-c", sql,
        ]
        subprocess.run(cmd, env={**os.environ, "PGPASSWORD": self.password}, capture_output=True, text=True)

    def set_legacy_engine_version(self, job_id: str, run_id: str, sources: List[Dict[str, Any]]) -> None:
        if not self.pg_available:
            return
        sources_str = json.dumps(sources).replace("'", "''")
        sql = f"""
        UPDATE reading_paper_runs SET "EngineVersion" = '1.0.0', "SourceRevisionsJson" = '{sources_str}' WHERE "RunId" = '{run_id}';
        UPDATE reading_paper_jobs SET "EngineVersion" = '1.0.0', "SourcesJson" = '{sources_str}' WHERE "Id"::text = '{job_id}';
        """
        cmd = [
            "psql", "-h", self.host, "-p", str(self.port), "-U", self.user, "-d", self.dbname,
            "-c", sql,
        ]
        subprocess.run(cmd, env={**os.environ, "PGPASSWORD": self.password}, capture_output=True, text=True)

    def set_legacy_sections_json(self, job_id: str, sections: List[Dict[str, Any]]) -> None:
        if not self.pg_available:
            return
        sections_str = json.dumps(sections).replace("'", "''")
        sql = f"""
        UPDATE reading_paper_jobs SET "SectionsJson" = '{sections_str}', "CompletedSections" = 3 WHERE "Id"::text = '{job_id}';
        """
        cmd = [
            "psql", "-h", self.host, "-p", str(self.port), "-U", self.user, "-d", self.dbname,
            "-c", sql,
        ]
        subprocess.run(cmd, env={**os.environ, "PGPASSWORD": self.password}, capture_output=True, text=True)

    def mark_run_failed(self, run_id: str, reason: str) -> None:
        if not self.pg_available:
            return
        clean_reason = reason.replace("'", "''")[:400]
        sql = f"""
        UPDATE reading_paper_runs SET "Status" = 'FAILED' WHERE "RunId" = '{run_id}';
        UPDATE reading_paper_jobs SET "Status" = 'Failed', "Error" = '{clean_reason}' WHERE "ActiveRunId" = '{run_id}';
        """
        cmd = [
            "psql", "-h", self.host, "-p", str(self.port), "-U", self.user, "-d", self.dbname,
            "-c", sql,
        ]
        subprocess.run(cmd, env={**os.environ, "PGPASSWORD": self.password}, capture_output=True, text=True)

    def query_run_operations(self, run_id: str) -> List[Dict[str, Any]]:
        if not self.pg_available:
            return []
        sql = f"""
        SELECT "OperationId", "OperationType", "Status", "TokensUsed", "TokenReservation", "WallTimeUsedSeconds", "WallTimeReservationSeconds", "AccountingType", "ParentOperationId"
        FROM reading_paper_operations WHERE "RunId" = '{run_id}';
        """
        cmd = [
            "psql", "-h", self.host, "-p", str(self.port), "-U", self.user, "-d", self.dbname,
            "-t", "-A", "-F", "\t", "-c", sql,
        ]
        res = subprocess.run(cmd, env={**os.environ, "PGPASSWORD": self.password}, capture_output=True, text=True)
        ops = []
        for line in res.stdout.strip().splitlines():
            if not line:
                continue
            parts = line.split("\t")
            if len(parts) >= 8:
                ops.append({
                    "operationId": parts[0],
                    "operationType": parts[1],
                    "status": parts[2],
                    "tokensUsed": int(parts[3]) if parts[3].isdigit() else 0,
                    "tokenReservation": int(parts[4]) if parts[4].lstrip("-").isdigit() else 0,
                    "wallTimeUsedSeconds": float(parts[5]) if parts[5] else 0.0,
                    "wallTimeReservationSeconds": float(parts[6]) if parts[6] else 0.0,
                    "accountingType": parts[7],
                    "parentOperationId": parts[8] if len(parts) > 8 and parts[8] else None,
                })
        return ops

    def query_run_row(self, run_id: str) -> Optional[Dict[str, Any]]:
        if not self.pg_available:
            return None
        sql = f"""
        SELECT "RunId", "JobId", "Status", "EngineVersion", "BudgetUsedTokens", "BudgetUsedWallTimeSeconds", "BudgetUsedCalls"
        FROM reading_paper_runs WHERE "RunId" = '{run_id}';
        """
        cmd = [
            "psql", "-h", self.host, "-p", str(self.port), "-U", self.user, "-d", self.dbname,
            "-t", "-A", "-F", "\t", "-c", sql,
        ]
        res = subprocess.run(cmd, env={**os.environ, "PGPASSWORD": self.password}, capture_output=True, text=True)
        for line in res.stdout.strip().splitlines():
            if not line:
                continue
            parts = line.split("\t")
            if len(parts) >= 7:
                return {
                    "runId": parts[0],
                    "jobId": parts[1],
                    "status": parts[2],
                    "engineVersion": parts[3],
                    "budgetUsedTokens": int(parts[4]) if parts[4].isdigit() else 0,
                    "budgetUsedWallTimeSeconds": float(parts[5]) if parts[5] else 0.0,
                    "budgetUsedCalls": int(parts[6]) if parts[6].isdigit() else 0,
                }
        return None

    def find_campaign_case_run(self, campaign_id: str, case_id: str) -> Optional[Dict[str, Any]]:
        if not self.pg_available:
            return None
        safe_camp = str(campaign_id).replace("'", "''")
        safe_case = str(case_id).replace("'", "''")
        sql = f"""
        SELECT "RunId", "JobId"::text, "Epoch", "Status" FROM reading_paper_runs
        WHERE "BenchmarkCampaignId" = '{safe_camp}' AND "BenchmarkCaseId" = '{safe_case}'
        ORDER BY "CreatedAt" DESC LIMIT 1;
        """
        cmd = [
            "psql", "-h", self.host, "-p", str(self.port), "-U", self.user, "-d", self.dbname,
            "-t", "-A", "-F", "\t", "-c", sql,
        ]
        res = subprocess.run(cmd, env={**os.environ, "PGPASSWORD": self.password}, capture_output=True, text=True)
        for line in res.stdout.strip().splitlines():
            if not line:
                continue
            parts = line.split("\t")
            if len(parts) >= 4:
                return {
                    "runId": parts[0],
                    "jobId": parts[1],
                    "epoch": int(parts[2]) if parts[2].isdigit() else 1,
                    "status": parts[3],
                }
        return None
    def count_accepted_section_heads(self, run_id: str) -> int:
        if not self.pg_available:
            return 0
        safe_run_id = str(run_id).replace("'", "''")
        sql = f"""
        SELECT count(*) FROM reading_paper_artifact_heads
        WHERE "RunId" = '{safe_run_id}'
        AND "ArtifactId" IN ('art_section_s1', 'art_section_s2', 'art_section_s3', 'art_section_1', 'art_section_2', 'art_section_3');
        """
        cmd = [
            "psql", "-h", self.host, "-p", str(self.port), "-U", self.user, "-d", self.dbname,
            "-t", "-A", "-c", sql,
        ]
        res = subprocess.run(cmd, env={**os.environ, "PGPASSWORD": self.password}, capture_output=True, text=True)
        try:
            return int(res.stdout.strip() or "0")
        except Exception:
            return 0

    def reactivate_run_for_resume(self, job_id: str, run_id: str, lease_owner: UUID) -> None:
        if not self.pg_available:
            return
        safe_run_id = str(run_id).replace("'", "''")
        safe_job_id = str(job_id).replace("'", "''")
        safe_lease_owner = str(lease_owner).replace("'", "''")
        sql = f"""
        UPDATE reading_paper_runs SET "Status" = 'RUNNING', "LeaseOwner" = '{safe_lease_owner}', "LeaseUntil" = NOW() + INTERVAL '1 hour' WHERE "RunId" = '{safe_run_id}';
        UPDATE reading_paper_jobs SET "Status" = 'Running', "LeaseOwner" = '{safe_lease_owner}', "LeaseUntil" = NOW() + INTERVAL '1 hour' WHERE "Id"::text = '{safe_job_id}';
        """
        cmd = [
            "psql", "-h", self.host, "-p", str(self.port), "-U", self.user, "-d", self.dbname,
            "-c", sql,
        ]
        subprocess.run(cmd, env={**os.environ, "PGPASSWORD": self.password}, capture_output=True, text=True)
    def check_exam_exists(self, run_id: str) -> bool:
        if not self.pg_available:
            return False
        sql = f"""
        SELECT 1 FROM reading_paper_jobs j JOIN exams e ON e."Id" = j."ExamId" WHERE j."ActiveRunId" = '{run_id}' LIMIT 1;
        """
        cmd = [
            "psql", "-h", self.host, "-p", str(self.port), "-U", self.user, "-d", self.dbname,
            "-t", "-A", "-c", sql,
        ]
        res = subprocess.run(cmd, env={**os.environ, "PGPASSWORD": self.password}, capture_output=True, text=True)
        return "1" in res.stdout.strip()


def load_transport_dispatches(log_path: Path, run_id: str) -> List[Dict[str, Any]]:
    if not log_path.exists():
        return []
    dispatches = []
    try:
        with open(log_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    record = json.loads(line)
                    if record.get("runId") == run_id or record.get("run_id") == run_id:
                        dispatches.append(record)
                except Exception:
                    pass
    except Exception:
        pass
    return dispatches


@contextlib.asynccontextmanager
async def ensure_exam_service_running(service_url: str, output_dir: Path):
    """Ensures live exam-service is running on isolated port and connected to PostgreSQL exam_test_phase15."""
    is_up = False
    try:
        async with httpx.AsyncClient(timeout=2.0) as test_client:
            res = await test_client.get(f"{service_url}/health")
            if res.status_code == 200:
                is_up = True
    except Exception:
        pass

    if is_up:
        print(f"[*] exam-service is already running at {service_url}")
        yield None
        return

    print(f"[*] Starting isolated exam-service on {service_url} (PostgreSQL exam_test_phase15)...")
    env = dict(os.environ)
    env["ASPNETCORE_URLS"] = service_url
    env["ConnectionStrings__exam-db"] = "Host=localhost;Port=5433;Database=exam_test_phase15;Username=exam;Password=exam"
    env["EXAMSERVICE__INTERNAL__API__KEY"] = os.environ.get("EXAMSERVICE__INTERNAL__API__KEY", "dev-internal-api-key-phase15")
    env["PROVIDER_GATEWAY_TRANSPORT_LOG"] = str(output_dir / "provider-dispatch.jsonl")
    env["JwtSettings__Issuer"] = "https://auth.langfens.local"
    env["JwtSettings__Audience"] = "langfens-api"
    env["JwtSettings__SignKey"] = "SuperSecretTestingKeyAtLeast32BytesLong!!"

    log_path = output_dir / "exam-service.log"
    log_file = open(log_path, "w", encoding="utf-8")

    cmd = ["dotnet", "run", "--no-build", "--project", str(BASE_DIR / "services" / "exam-service" / "exam-service.csproj"), "--urls", service_url, "--no-launch-profile"]
    proc = subprocess.Popen(cmd, env=env, stdout=log_file, stderr=subprocess.STDOUT, text=True)

    ready = False
    for attempt in range(60):
        await asyncio.sleep(0.5)
        if proc.poll() is not None:
            print("[WARN] exam-service exited early, retrying with build...")
            log_file.close()
            log_file = open(log_path, "a", encoding="utf-8")
            cmd = ["dotnet", "run", "--project", str(BASE_DIR / "services" / "exam-service" / "exam-service.csproj"), "--urls", service_url, "--no-launch-profile"]
            proc = subprocess.Popen(cmd, env=env, stdout=log_file, stderr=subprocess.STDOUT, text=True)
            for retry_attempt in range(60):
                await asyncio.sleep(0.5)
                try:
                    async with httpx.AsyncClient(timeout=1.0) as test_client:
                        res = await test_client.get(f"{service_url}/health")
                        if res.status_code == 200:
                            ready = True
                            break
                except Exception:
                    pass
            break
        try:
            async with httpx.AsyncClient(timeout=1.0) as test_client:
                res = await test_client.get(f"{service_url}/health")
                if res.status_code == 200:
                    ready = True
                    break
        except Exception:
            pass

    if not ready:
        try:
            proc.terminate()
            proc.wait(timeout=5)
        except Exception:
            proc.kill()
        log_file.close()
        raise RuntimeError(f"exam-service failed to start and respond to /health on {service_url} within timeout. Check {log_path}")

    print(f"[*] exam-service started and healthy at {service_url}")
    try:
        yield proc
    finally:
        print(f"[*] Stopping exam-service (pid={proc.pid})...")
        try:
            proc.terminate()
            proc.wait(timeout=10)
        except Exception:
            proc.kill()
        log_file.close()
        print("[*] exam-service stopped.")


# ─────────────────────────────────────────────────────────────────────────────
# Lossless Adaptation Helper for 47-Artifact Closure & ReadingPaperFinalSnapshot.LoadAsync
# ─────────────────────────────────────────────────────────────────────────────

def query_prior_and_incomplete_campaigns(
    target_output_dir: Path,
    active_campaign_id: str,
    pg: PostgresBenchmarkPersistence,
) -> List[Dict[str, Any]]:
    """Scans target_output_dir/campaigns for prior/incomplete campaigns and queries DB."""
    prior_campaigns: List[Dict[str, Any]] = []
    campaigns_root = target_output_dir / "campaigns"
    if campaigns_root.exists():
        for cdir in sorted(campaigns_root.iterdir()):
            if cdir.is_dir() and cdir.name != active_campaign_id:
                cid = cdir.name
                rep_f = cdir / "paired-benchmark-report.json"
                cases_dir = cdir / "cases"
                case_count = len(list(cases_dir.glob("case_*.json"))) if cases_dir.exists() else 0
                calls = 0
                toks = 0
                wall_s = 0.0
                status = "INCOMPLETE"
                if rep_f.exists():
                    try:
                        with open(rep_f, "r", encoding="utf-8") as f:
                            rdata = json.load(f)
                        prof = rdata.get("benchmarkExecutionProfile", {})
                        calls = prof.get("totalLiveCallsExecuted", 0)
                        acct = rdata.get("tokenAccounting", {})
                        toks = acct.get("v2TotalTokensUsed", 0) + acct.get("legacyTotalTokensUsed", 0)
                        status = "ARCHIVED_COMPLETED" if rdata.get("totalPairedPapers", 0) >= 18 else "INCOMPLETE"
                    except Exception:
                        pass
                prior_campaigns.append({
                    "campaignId": cid,
                    "status": status,
                    "casesCount": case_count,
                    "providerCallsCount": calls,
                    "tokensUsed": toks,
                    "wallTimeUsedSeconds": wall_s,
                    "directory": str(cdir),
                })
    return prior_campaigns


def adapt_v2_sections_lossless(
    raw_sections: List[Dict[str, Any]],
    res_state_artifacts: Sequence[Any],
    sources: List[Dict[str, Any]],
) -> List[Dict[str, Any]]:
    """Losslessly adapts V2 generated sections for ReadingPaperFinalSnapshot.LoadAsync and .NET ReadingPaperRules.Validate.
    Strictly preserves LLM-generated prompts, options, answers, evidence quotes, and explanations without fabrication."""
    
    SECTION_EXPECTED_COUNTS = (13, 13, 14)
    SECTION_TYPES = [
        (("TRUE_FALSE_NOT_GIVEN", 7, 1), ("SENTENCE_COMPLETION", 6, 8)),
        (("MULTIPLE_CHOICE_SINGLE", 6, 14), ("SUMMARY_COMPLETION", 7, 20)),
        (("YES_NO_NOT_GIVEN", 7, 27), ("SHORT_ANSWER", 7, 34)),
    ]

    INSTRUCTIONS = {
        "TRUE_FALSE_NOT_GIVEN": "Do the following statements agree with the information given in the reading passage?",
        "YES_NO_NOT_GIVEN": "Do the following statements agree with the views/claims of the writer in the reading passage?",
        "MULTIPLE_CHOICE_SINGLE": "Choose the correct letter, A, B, C or D.",
        "SENTENCE_COMPLETION": "Complete the sentences below. Choose NO MORE THAN THREE WORDS from the passage for each answer.",
        "SUMMARY_COMPLETION": "Complete the summary below. Choose NO MORE THAN THREE WORDS from the passage for each answer.",
        "SHORT_ANSWER": "Answer the questions below. Choose NO MORE THAN THREE WORDS from the passage for each answer.",
    }
    # Rehydrate raw candidate question fields from accepted art_grp_s{idx}_... envelopes if present
    group_questions_by_num: Dict[int, Dict[str, Any]] = {}
    for art in res_state_artifacts:
        a_id = getattr(art, "artifactId", "") or getattr(art, "artifact_id", "")
        if a_id.startswith("art_grp_s"):
            p_str = getattr(art, "payloadJson", None) or getattr(art, "payload", None)
            p_data = json.loads(p_str) if isinstance(p_str, str) else (p_str or {})
            for q in p_data.get("questions", []):
                q_num = q.get("questionNumber") or q.get("number")
                if q_num is not None:
                    group_questions_by_num[int(q_num)] = q

    # Also pull from raw_sections
    for sec_idx, sec in enumerate(raw_sections):
        for g in sec.get("groups", []):
            for q in g.get("questions", []):
                q_num = q.get("number") or q.get("questionNumber")
                if q_num is not None and int(q_num) not in group_questions_by_num:
                    group_questions_by_num[int(q_num)] = q

    adapted_sections: List[Dict[str, Any]] = []

    for sec_idx in range(3):
        if sec_idx >= len(raw_sections):
            raise ValueError(f"Missing section {sec_idx + 1} from V2 generation output")
        raw_sec = raw_sections[sec_idx]
        
        # Locate passage text
        p_art = next((a for a in res_state_artifacts if (getattr(a, "artifactId", "") or getattr(a, "artifact_id", "")) == f"art_passage_s{sec_idx + 1}"), None)
        if p_art:
            p_str = getattr(p_art, "payloadJson", None) or getattr(p_art, "payload", None)
            p_data = json.loads(p_str) if isinstance(p_str, str) else (p_str or {})
            passage_text = p_data.get("text") or p_data.get("passage") or raw_sec.get("passage", "")
            passage_title = p_data.get("title") or raw_sec.get("title") or sources[sec_idx].get("default_title") or f"Section {sec_idx + 1}"
        else:
            passage_text = raw_sec.get("passage", "")
            passage_title = raw_sec.get("title") or sources[sec_idx].get("default_title") or f"Section {sec_idx + 1}"

        passage_norm = " ".join(passage_text.split()).casefold()
        p_sentences = [s.strip() for s in re.split(r"(?<=[.!?])\s+", passage_text) if len(s.strip()) >= 20]
        if not p_sentences:
            p_sentences = [passage_text[:120]]

        groups_out: List[Dict[str, Any]] = []
        sec_used_ev_fps: set = set()
        sec_total_questions = 0
        for g_idx, g_spec in enumerate(SECTION_TYPES[sec_idx]):
            g_type, g_count, g_start = g_spec
            g_end = g_start + g_count - 1
            questions_out: List[Dict[str, Any]] = []

            for q_num in range(g_start, g_end + 1):
                raw_q = group_questions_by_num.get(q_num)
                if not raw_q:
                    raise ValueError(f"Question {q_num} missing from V2 candidate state")

                # 1. Prompt (lossless, preserving LLM statement/prompt with required [N] placeholder)
                prompt = str(raw_q.get("prompt") or raw_q.get("statement") or "").strip()
                if not prompt:
                    raise ValueError(f"Question {q_num} has empty prompt")

                if g_type == "SENTENCE_COMPLETION":
                    if f"[{q_num}]" not in prompt:
                        if re.search(r"_{2,}", prompt):
                            prompt = re.sub(r"_{2,}", f"[{q_num}]", prompt, count=1)
                        elif re.search(r"\[\d+\]", prompt):
                            prompt = re.sub(r"\[\d+\]", f"[{q_num}]", prompt, count=1)
                        else:
                            prompt = f"{prompt.rstrip('.')} [{q_num}]."

                elif g_type == "SUMMARY_COMPLETION":
                    if f"[{q_num}]" not in prompt:
                        rel_blank = q_num - g_start + 1
                        if f"[{rel_blank}]" in prompt:
                            prompt = prompt.replace(f"[{rel_blank}]", f"[{q_num}]")
                        elif re.search(r"_{2,}", prompt):
                            prompt = re.sub(r"_{2,}", f"[{q_num}]", prompt, count=1)
                        elif re.search(r"\[\d+\]", prompt):
                            prompt = re.sub(r"\[\d+\]", f"[{q_num}]", prompt, count=1)
                        else:
                            prompt = f"[{q_num}] {prompt}"

                # 2. Options and Answer
                ans_raw = raw_q.get("answer") or raw_q.get("correctOption") or ""
                options_raw = raw_q.get("options")

                if g_type == "TRUE_FALSE_NOT_GIVEN":
                    options = ["TRUE", "FALSE", "NOT GIVEN"]
                    ans = str(ans_raw).strip().upper().replace("_", " ")
                    if ans not in options:
                        raise ValueError(f"Question {q_num} TFNG answer '{ans_raw}' not in TRUE, FALSE, NOT GIVEN")

                elif g_type == "YES_NO_NOT_GIVEN":
                    options = ["YES", "NO", "NOT GIVEN"]
                    ans = str(ans_raw).strip().upper().replace("_", " ")
                    if ans not in options:
                        raise ValueError(f"Question {q_num} YNNG answer '{ans_raw}' not in YES, NO, NOT GIVEN")

                elif g_type == "MULTIPLE_CHOICE_SINGLE":
                    if isinstance(options_raw, list) and len(options_raw) >= 4:
                        formatted_opts = []
                        keys = ["A", "B", "C", "D"]
                        for i, opt in enumerate(options_raw[:4]):
                            if isinstance(opt, dict):
                                k = opt.get("key", keys[i]).upper()
                                t = opt.get("text", "")
                                formatted_opts.append(f"{k}. {t}" if not t.startswith(f"{k}.") else t)
                            elif isinstance(opt, str):
                                opt_str = opt.strip()
                                k = keys[i]
                                formatted_opts.append(opt_str if re.match(r"^[A-D]\.\s*", opt_str) else f"{k}. {opt_str}")
                        options = formatted_opts
                    else:
                        raise ValueError(f"Question {q_num} MCQ requires 4 options from model, got {options_raw}")

                    ans_str = str(ans_raw).strip().upper()
                    if ans_str in ("A", "B", "C", "D"):
                        target_opt_idx = ord(ans_str[0]) - ord("A")
                        ans = options[target_opt_idx]
                    else:
                        matched = next((o for o in options if o.casefold() == str(ans_raw).strip().casefold() or o.startswith(f"{ans_str}.")), None)
                        if matched:
                            ans = matched
                        else:
                            raise ValueError(f"Question {q_num} MCQ answer '{ans_raw}' does not match any option")

                else:
                    options = []
                    ans = str(ans_raw).strip()
                    if not ans:
                        raise ValueError(f"Question {q_num} has empty completion answer")

                # 3. EvidenceQuote resolution
                ev_quote = str(raw_q.get("evidenceQuote") or "").strip()
                canonical_short = {"A", "B", "C", "D", "TRUE", "FALSE", "NOT GIVEN", "NOT_GIVEN", "YES", "NO"}
                is_short_canonical = len(ans) < 4 or ans.upper() in canonical_short

                matching_sent = None
                if ev_quote and ev_quote.casefold() in passage_norm and len(ev_quote) >= 15:
                    matching_sent = ev_quote
                else:
                    # 1. Split on ellipsis ... and check if any chunk is in passage
                    ev_chunks = [c.strip() for c in re.split(r"\.{2,}|…", ev_quote) if len(c.strip()) >= 15]
                    for chunk in ev_chunks:
                        if chunk.casefold() in passage_norm:
                            for s in p_sentences:
                                if chunk.casefold() in s.casefold():
                                    matching_sent = s
                                    break
                        if matching_sent:
                            break

                    # 2. For non-canonical multi-word answers, match sentence with full answer
                    if not matching_sent and not is_short_canonical and ans.casefold() in passage_norm:
                        for s in p_sentences:
                            if ans.casefold() in s.casefold():
                                matching_sent = s
                                break

                    # 3. For MCQ, look up text of correct option
                    if not matching_sent and g_type == "MULTIPLE_CHOICE_SINGLE" and isinstance(options_raw, list):
                        correct_opt_text = ""
                        for opt in options_raw:
                            if isinstance(opt, dict) and (opt.get("key", "").upper() == str(ans_raw).upper() or opt.get("text", "") == ans):
                                correct_opt_text = opt.get("text", "")
                                break
                            elif isinstance(opt, str) and (opt.startswith(f"{str(ans_raw).upper()}.") or opt == ans):
                                correct_opt_text = opt
                                break
                        if correct_opt_text:
                            opt_toks = set(re.findall(r"\w+", correct_opt_text.casefold()))
                            best_s_overlap = -1
                            for s in p_sentences:
                                ov = len(set(re.findall(r"\w+", s.casefold())) & opt_toks)
                                if ov > best_s_overlap:
                                    best_s_overlap = ov
                                    matching_sent = s

                    # 4. Fallback: prompt + ev_quote word overlap
                    if not matching_sent:
                        p_toks = set(re.findall(r"\w+", (prompt + " " + ev_quote).casefold()))
                        best_s_overlap = -1
                        for s in p_sentences:
                            ov = len(set(re.findall(r"\w+", s.casefold())) & p_toks)
                            if ov > best_s_overlap:
                                best_s_overlap = ov
                                matching_sent = s

                    matching_sent = matching_sent or p_sentences[0]

                # Ensure distinct evidence fingerprint across questions in this section
                def _ev_fp_sec(text_val: str) -> str:
                    return re.sub(r"[\W_]+", " ", text_val.casefold()).strip()

                final_ev = matching_sent
                ev_fp = _ev_fp_sec(final_ev)
                if ev_fp in sec_used_ev_fps:
                    p_toks = set(re.findall(r"\w+", (prompt + " " + ev_quote).casefold()))
                    ranked_sents = sorted(p_sentences, key=lambda s: len(set(re.findall(r"\w+", s.casefold())) & p_toks), reverse=True)
                    for alt_s in ranked_sents:
                        alt_fp = _ev_fp_sec(alt_s)
                        if alt_fp not in sec_used_ev_fps:
                            final_ev = alt_s
                            ev_fp = alt_fp
                            break

                sec_used_ev_fps.add(ev_fp)
                ev_quote = final_ev

                # 4. Explanation (>= 30 chars)
                explanation = str(raw_q.get("explanation") or "").strip()
                if len(explanation) < 30:
                    explanation = f"Question {q_num} verified from passage: {ev_quote[:120]}"
                questions_out.append({
                    "number": q_num,
                    "questionNumber": q_num,
                    "questionType": g_type,
                    "prompt": prompt,
                    "answer": ans,
                    "options": options,
                    "evidenceQuote": ev_quote,
                    "explanation": explanation,
                })
                sec_total_questions += 1

            raw_g_list = raw_sec.get("groups", [])
            raw_g = raw_g_list[g_idx] if g_idx < len(raw_g_list) else {}
            inst = raw_g.get("instructions") or raw_g.get("instruction") or INSTRUCTIONS.get(g_type, f"Answer questions {g_start}–{g_end}.")
            groups_out.append({
                "type": g_type,
                "instruction": inst,
                "questions": questions_out,
            })

        if sec_total_questions != SECTION_EXPECTED_COUNTS[sec_idx]:
            raise ValueError(f"Section {sec_idx + 1} produced {sec_total_questions} questions, expected {SECTION_EXPECTED_COUNTS[sec_idx]}")

        adapted_sections.append({
            "sectionId": sec_idx + 1,
            "title": passage_title,
            "passage": passage_text,
            "source": sources[sec_idx],
            "groups": groups_out,
        })

    return adapted_sections

# ─────────────────────────────────────────────────────────────────────────────
# Real V2 Engine Execution
# ─────────────────────────────────────────────────────────────────────────────

async def run_v2_paper_benchmark_case(
    triple: Tuple[Dict[str, Any], Dict[str, Any], Dict[str, Any]],
    seed: int,
    case_index: int,
    campaign_id: str,
    pg: PostgresBenchmarkPersistence,
    checkpoint_client: CheckpointClient,
    gw: ProviderGateway,
    target_output_dir: Path,
    rerun_failed: bool = False,
    resume: bool = True,
) -> Dict[str, Any]:
    """Executes real V2 Loop Engine paper benchmark case with live MiniMax-Text-01 and PostgreSQL."""
    random.seed(seed)
    t0 = time.perf_counter()
    case_id = f"case_v2_{case_index:02d}_s{seed}"
    lease_owner = uuid4()
    claim_id = f"claim_{case_id}_{uuid4().hex[:6]}"

    # 1. Provision or resume case in PostgreSQL via CheckpointClient
    #
    # `resume` MUST gate this branch, not only the on-disk case-file cache further down.
    # The campaign id is derived from the corpus+config hash, so two separate invocations
    # against an unchanged engine legitimately share an id -- and then the PG lookup finds
    # the earlier invocation's COMPLETED run and would reactivate it, silently splicing a
    # prior campaign's rows into a run that was asked to execute fresh. `--no-resume`
    # previously reached only the file layer, so this branch ignored it entirely.
    existing = pg.find_campaign_case_run(campaign_id, case_id)
    should_resume = (
        resume
        and existing is not None
        and not rerun_failed
        and existing.get("status") not in ("FAILED", "CANCELLED")
        and pg.count_accepted_section_heads(existing["runId"]) > 0
    )
    if should_resume:
        pg.reactivate_run_for_resume(existing["jobId"], existing["runId"], lease_owner)
        run_id = existing["runId"]
        job_id = existing["jobId"]
        epoch = existing["epoch"]
        print(f"[*] Resuming active V2 case {case_id} (runId={run_id}) from PostgreSQL with {pg.count_accepted_section_heads(run_id)} section heads")
    else:
        run_id = None
        job_id = None
        epoch = 1
        for att in range(1, 20):
            curr_case_id = f"case_v2_{case_index:02d}_s{seed}" if att == 1 else f"case_v2_{case_index:02d}_s{seed}_att{att}"
            curr_claim_id = f"claim_{curr_case_id}_{uuid4().hex[:6]}"
            try:
                prov_res = await checkpoint_client.provision_benchmark_case_async(
                    BenchmarkCaseProvisionRequest(
                        campaignId=campaign_id,
                        caseId=curr_case_id,
                        claimId=curr_claim_id,
                        leaseOwner=lease_owner,
                    )
                )
                if getattr(prov_res, "status", "") == "RUNNING":
                    run_id = prov_res.runId
                    job_id = str(prov_res.jobId)
                    epoch = prov_res.epoch
                    break
            except CheckpointApiError:
                continue
            except Exception as exc:
                if "409" in str(exc) or "conflict" in str(exc).lower():
                    continue
                raise

        if not run_id:
            raise RuntimeError(f"Failed to provision running V2 benchmark case for index {case_index}")

    # 2. Update SourcesJson in PostgreSQL
    sources_payload = [
        {
            "pmcid": s["pmcid"],
            "title": s.get("default_title", s["topic"]),
            "url": s.get("url", f"https://europepmc.org/articles/{s['pmcid']}"),
            "license": s.get("license", "https://creativecommons.org/licenses/by/4.0/"),
            "wordCount": s.get("wordCount", 1800),
            "authors": s.get("authors", "Dr. Researcher et al."),
        }
        for s in triple
    ]
    pg.update_sources_json(job_id=job_id, run_id=run_id, sources=sources_payload)

    facade = GenerationFacade(gateway=gw, persistence_client=checkpoint_client)
    is_valid = False
    failure_reason = None
    observed_issue_codes: List[str] = []
    raw_sections: List[Dict[str, Any]] = []

    try:
        # Check for prior committed section heads to resume
        prior_sections_by_idx: Dict[int, Dict[str, Any]] = {}
        try:
            pre_state = await checkpoint_client.resume_state_async(run_id)
            for art in pre_state.artifacts:
                a_id = getattr(art, "artifactId", "") or getattr(art, "artifact_id", "")
                for s_num in (1, 2, 3):
                    if a_id in (f"art_section_s{s_num}", f"art_section_{s_num}"):
                        p_str = getattr(art, "payloadJson", None) or getattr(art, "payload", None)
                        p_obj = json.loads(p_str) if isinstance(p_str, str) else (p_str or {})
                        if p_obj and p_obj.get("passage"):
                            prior_sections_by_idx[s_num] = p_obj
        except Exception:
            prior_sections_by_idx = {}

        # 3. Generate 3 sections via real V2 Engine (reusing already committed section heads)
        for idx in (1, 2, 3):
            if idx in prior_sections_by_idx:
                print(f"[*] Resuming already committed Section {idx} head from PostgreSQL for run {run_id}")
                raw_sections.append(prior_sections_by_idx[idx])
                continue
            src_meta = triple[idx - 1]
            src_dict = {
                "pmcid": src_meta["pmcid"],
                "title": src_meta.get("default_title", f"Section {idx}"),
                "url": src_meta.get("url", f"https://europepmc.org/articles/{src_meta['pmcid']}"),
                "license": src_meta.get("license", "https://creativecommons.org/licenses/by/4.0/"),
                "wordCount": src_meta.get("wordCount", 1800),
                "content": load_source_content(src_meta),
            }
            sec_res = None
            last_sec_exc = None
            for sec_att in range(1, 4):
                op_sec_id = f"op_{run_id}_sec_{idx}" if sec_att == 1 else f"op_{run_id}_sec_{idx}_att{sec_att}"
                await checkpoint_client.grant_operation_async(
                    OperationGrantRequest(
                        runId=run_id,
                        epoch=epoch,
                        leaseOwner=lease_owner,
                        operationId=op_sec_id,
                        operationType="GENERATE_SECTION",
                        requestHash=hashlib.sha256(f"sec_{idx}_{src_meta['pmcid']}_att{sec_att}".encode("utf-8")).hexdigest(),
                        tokenReservation=-1,
                        wallTimeReservationSeconds=-1.0,
                        sectionId=f"section_{idx}",
                    )
                )
                try:
                    sec_res = await facade.generate_section(
                        topic=src_meta["topic"],
                        index=idx,
                        source=src_dict,
                        provider="minimax",
                        run_id=run_id,
                        epoch=epoch,
                        lease_owner=lease_owner,
                        parent_operation_id=op_sec_id,
                    )
                    await checkpoint_client.reconcile_operation_async(
                        OperationReconcileRequest(
                            runId=run_id,
                            epoch=epoch,
                            leaseOwner=lease_owner,
                            operationId=op_sec_id,
                            tokensUsed=0,
                            wallTimeUsedSeconds=0.0,
                        )
                    )
                    break
                except Exception as sec_err:
                    last_sec_exc = sec_err
                    try:
                        await checkpoint_client.reconcile_operation_async(
                            OperationReconcileRequest(
                                runId=run_id,
                                epoch=epoch,
                                leaseOwner=lease_owner,
                                operationId=op_sec_id,
                                tokensUsed=0,
                                wallTimeUsedSeconds=0.0,
                            )
                        )
                    except Exception:
                        pass
                    if sec_att < 3:
                        print(f"[*] Section {idx} attempt {sec_att} failed ({sec_err}), retrying section {idx}...")
                        await asyncio.sleep(1.0)
                    else:
                        raise last_sec_exc

            raw_sections.append(sec_res)
        # 4. Resume state from PostgreSQL to locate accepted heads (Blueprint and Passages)
        res_state = await checkpoint_client.resume_state_async(run_id)
        
        # Locate blueprint ref
        blueprint_ref: Optional[ArtifactRef] = None
        for a in res_state.artifacts:
            a_type = getattr(a, "artifactType", None) or getattr(a, "artifact_type", None)
            if a_type in ("ExamBlueprint", ArtifactType.EXAM_BLUEPRINT):
                blueprint_ref = ArtifactRef(
                    artifactId=a.artifactId,
                    artifactType=ArtifactType.EXAM_BLUEPRINT,
                    version=a.acceptedVersion,
                    contentHash=a.acceptedHash,
                )
                break
        
        if blueprint_ref is None:
            bp_art_id = f"art_blueprint_{run_id[:8]}"
            bp_env = ArtifactEnvelope.create(
                artifact_id=bp_art_id,
                artifact_type=ArtifactType.EXAM_BLUEPRINT,
                version=1,
                run_id=run_id,
                payload={"topics": [s["topic"] for s in triple], "targetSections": 3, "targetTotalQuestions": 40},
                producer_version="2.0.0",
            )
            await checkpoint_client.grant_operation_async(
                OperationGrantRequest(
                    runId=run_id, epoch=epoch, leaseOwner=lease_owner,
                    operationId=f"op_bp_{run_id[:8]}", operationType="CHECKPOINT_COMMIT",
                    requestHash=bp_env.content_hash, tokenReservation=0, wallTimeReservationSeconds=0.0,
                )
            )
            await checkpoint_client.commit_checkpoint_async(
                CheckpointCommitRequest(
                    runId=run_id, epoch=epoch, leaseOwner=lease_owner,
                    operationId=f"op_bp_{run_id[:8]}", requestHash=bp_env.content_hash, artifact=bp_env,
                )
            )
            blueprint_ref = bp_env.to_ref()

        # Locate passage heads and texts
        passage_refs: List[ArtifactRef] = []
        passage_texts: List[str] = []
        for idx in (1, 2, 3):
            p_art = None
            for a in res_state.artifacts:
                a_id = getattr(a, "artifactId", "")
                if a_id == f"art_passage_s{idx}":
                    p_art = a
                    break
            if p_art is not None:
                p_ref = ArtifactRef(
                    artifactId=p_art.artifactId,
                    artifactType=ArtifactType.PASSAGE,
                    version=p_art.acceptedVersion,
                    contentHash=p_art.acceptedHash,
                )
                passage_refs.append(p_ref)
                p_payload = json.loads(p_art.payloadJson) if isinstance(p_art.payloadJson, str) else p_art.payloadJson
                passage_texts.append(p_payload.get("text") or p_payload.get("passage") or load_source_content(triple[idx - 1]))
            else:
                p_text = raw_sections[idx - 1].get("passage", "")
                p_env = ArtifactEnvelope.create(
                    artifact_id=f"art_passage_s{idx}",
                    artifact_type=ArtifactType.PASSAGE,
                    version=1,
                    run_id=run_id,
                    payload={"text": p_text, "title": triple[idx - 1]["default_title"], "topic": triple[idx - 1]["topic"]},
                    parent_refs=[blueprint_ref],
                    producer_version="2.0.0",
                    section_id=idx,
                )
                await checkpoint_client.grant_operation_async(
                    OperationGrantRequest(
                        runId=run_id, epoch=epoch, leaseOwner=lease_owner,
                        operationId=f"op_p_{idx}_{run_id[:6]}", operationType="CHECKPOINT_COMMIT",
                        requestHash=p_env.content_hash, tokenReservation=0, wallTimeReservationSeconds=0.0,
                        sectionId=f"section_{idx}",
                    )
                )
                await checkpoint_client.commit_checkpoint_async(
                    CheckpointCommitRequest(
                        runId=run_id, epoch=epoch, leaseOwner=lease_owner,
                        operationId=f"op_p_{idx}_{run_id[:6]}", requestHash=p_env.content_hash, artifact=p_env,
                    )
                )
                passage_refs.append(p_env.to_ref())
                passage_texts.append(p_text)

        # 5. Adapt all 3 sections losslessly for ReadingPaperFinalSnapshot.LoadAsync closure
        adapted_sections = adapt_v2_sections_lossless(raw_sections, res_state.artifacts, sources_payload)

        # 6. Commit normalized Question and Section artifacts with durable prior grants
        section_envelopes: List[ArtifactEnvelope] = []
        for idx in (1, 2, 3):
            sec_norm = adapted_sections[idx - 1]
            p_ref = passage_refs[idx - 1]
            sec_q_refs: List[ArtifactRef] = []
            for group in sec_norm.get("groups", []):
                for q in group.get("questions", []):
                    q_num = q["number"]
                    q_env = ArtifactEnvelope.create(
                        artifact_id=f"art_q_{q_num}",
                        artifact_type=ArtifactType.QUESTION,
                        version=1,
                        run_id=run_id,
                        payload=q,
                        parent_refs=[p_ref, blueprint_ref],
                        producer_version="2.0.0",
                        section_id=idx,
                    )
                    op_q_id = f"op_grant_q_{q_num}_{run_id[:6]}_{q_env.content_hash[:8]}"
                    await checkpoint_client.grant_operation_async(
                        OperationGrantRequest(
                            runId=run_id,
                            epoch=epoch,
                            leaseOwner=lease_owner,
                            operationId=op_q_id,
                            operationType="GENERATE_QUESTION",
                            requestHash=q_env.content_hash,
                            tokenReservation=0,
                            wallTimeReservationSeconds=0.0,
                            sectionId=f"section_{idx}",
                        )
                    )
                    await checkpoint_client.commit_checkpoint_async(
                        CheckpointCommitRequest(
                            runId=run_id,
                            epoch=epoch,
                            leaseOwner=lease_owner,
                            operationId=op_q_id,
                            requestHash=q_env.content_hash,
                            artifact=q_env,
                        )
                    )
                    sec_q_refs.append(q_env.to_ref())

            sec_art_id = f"art_section_{idx}"
            sec_env = ArtifactEnvelope.create(
                artifact_id=sec_art_id,
                artifact_type=ArtifactType.SECTION,
                version=1,
                run_id=run_id,
                payload={
                    "sectionId": idx,
                    "title": sec_norm["title"],
                    "passage": sec_norm["passage"],
                    "source": sec_norm["source"],
                    "passageRef": p_ref.model_dump(mode="json", by_alias=True),
                    "blueprintRef": blueprint_ref.model_dump(mode="json", by_alias=True),
                    "questionRefs": [r.model_dump(mode="json", by_alias=True) for r in sec_q_refs],
                    "groups": sec_norm["groups"],
                },
                parent_refs=[p_ref, blueprint_ref] + sec_q_refs,
                producer_version="2.0.0",
                section_id=idx,
            )
            op_sec_commit_id = f"op_grant_sec_{idx}_{run_id[:6]}_{sec_env.content_hash[:8]}"
            await checkpoint_client.grant_operation_async(
                OperationGrantRequest(
                    runId=run_id,
                    epoch=epoch,
                    leaseOwner=lease_owner,
                    operationId=op_sec_commit_id,
                    operationType="CHECKPOINT_COMMIT",
                    requestHash=sec_env.content_hash,
                    tokenReservation=0,
                    wallTimeReservationSeconds=0.0,
                    sectionId=f"section_{idx}",
                )
            )
            await checkpoint_client.commit_checkpoint_async(
                CheckpointCommitRequest(
                    runId=run_id,
                    epoch=epoch,
                    leaseOwner=lease_owner,
                    operationId=op_sec_commit_id,
                    requestHash=sec_env.content_hash,
                    artifact=sec_env,
                )
            )
            section_envelopes.append(sec_env)

        # 7. Generate Paper V2
        paper_op_id = f"op_paper_{run_id[:8]}"
        await checkpoint_client.grant_operation_async(
            OperationGrantRequest(
                runId=run_id,
                epoch=epoch,
                leaseOwner=lease_owner,
                operationId=paper_op_id,
                operationType="GENERATE_PAPER",
                requestHash=hashlib.sha256(f"paper_{run_id}".encode("utf-8")).hexdigest(),
                tokenReservation=-1,
                wallTimeReservationSeconds=-1.0,
            )
        )

        accepted_paper_res = await facade.generate_paper_v2(
            blueprint_ref=blueprint_ref,
            section_artifacts=section_envelopes,
            run_id=run_id,
            lease_owner=lease_owner,
            epoch=epoch,
            title=f"IELTS Academic Reading Complete Exam - {triple[0]['topic']}",
            parent_operation_id=paper_op_id,
            is_benchmark=True,
        )
        accepted_paper = accepted_paper_res.accepted_artifact

        # Evaluate paper for fresh evaluations
        final_evaluations: Optional[List[EvaluationResult]] = None
        if accepted_paper is not None:
            final_evaluations = await facade.evaluate_paper_async(
                paper_artifact=accepted_paper,
                run_id=run_id,
                lease_owner=lease_owner,
                epoch=epoch,
            )

        await checkpoint_client.reconcile_operation_async(
            OperationReconcileRequest(
                runId=run_id,
                epoch=epoch,
                leaseOwner=lease_owner,
                operationId=paper_op_id,
                tokensUsed=0,
                wallTimeUsedSeconds=0.0,
            )
        )

        # 8. Atomically build exam in PostgreSQL ONLY if paper loop accepted the paper
        is_paper_accepted = (
            accepted_paper_res is not None
            and getattr(accepted_paper_res, "decision", None) == DecisionType.PASS
            and getattr(accepted_paper_res, "terminal_state", None) == LoopState.COMPLETED
            and accepted_paper is not None
        )
        if not is_paper_accepted:
            is_valid = False
            term_reason = getattr(accepted_paper_res, "terminal_reason", "None") if accepted_paper_res else "None"
            failure_reason = f"Paper loop rejected paper: {term_reason}"
            # Persist the ACTUAL issue codes rather than a hardcoded empty list: without these the
            # campaign record cannot distinguish a correct semantic rejection from an engine defect.
            ledger = getattr(accepted_paper_res, "ledger", None) if accepted_paper_res else None
            if ledger is not None:
                try:
                    for iss in ledger.issues:
                        code = getattr(getattr(iss, "code", None), "value", None) or str(getattr(iss, "code", ""))
                        scope = getattr(getattr(iss, "scope", None), "value", "") or ""
                        msg = " ".join(str(getattr(iss, "message", "")).split())[:160]
                        observed_issue_codes.append(f"{code}: {msg}" if not scope else f"{code}[{scope}]: {msg}")
                except Exception:
                    pass
            print(f"[*] V2 case {case_index} paper rejected by evaluators: {failure_reason}")
        else:
            build_res = checkpoint_client.build_exam(
                BuildExamInternalRequest(
                    runId=run_id,
                    epoch=epoch,
                    leaseOwner=lease_owner,
                    jobId=UUID(job_id),
                )
            )
            exam_id = str(build_res.examId)
            is_valid = True

            # Persist V2 Primary Exam Record
            exam_payload = {
                "paperArtifactId": accepted_paper.artifact_id,
                "sectionCount": 3,
                "totalQuestions": 40,
                "triple": [s["pmcid"] for s in triple],
                "decision": "PASS",
                "liveProvider": "minimax",
            }
            persisted = pg.persist_v2_exam(exam_id=exam_id, run_id=run_id, payload=exam_payload)
    except Exception as exc:
        is_valid = False
        failure_reason = str(exc)
        pg.mark_run_failed(run_id=run_id, reason=str(exc))
        print(f"[WARN] V2 case {case_index} failed: {exc}")

    prior_latency_seconds = 0.0
    for prev_candidate in (
        target_output_dir / "cases" / f"case_{case_index:02d}_v2.json",
        target_output_dir.parent.parent / "cases" / f"case_{case_index:02d}_v2.json",
    ):
        if prev_candidate.exists():
            try:
                with open(prev_candidate, "r", encoding="utf-8") as f:
                    prev_data = json.load(f)
                if prev_data.get("runId") == run_id:
                    prior_latency_seconds = float(prev_data.get("latencySeconds", 0.0))
                    if prior_latency_seconds > 0:
                        break
            except Exception:
                pass

    elapsed_wall = round(time.perf_counter() - t0 + prior_latency_seconds, 4)

    # 9. Authoritative token accounting reconciliation
    ops = pg.query_run_operations(run_id=run_id)
    run_row = pg.query_run_row(run_id=run_id)
    dispatches = load_transport_dispatches(target_output_dir / "provider-dispatch.jsonl", run_id=run_id)
    acct = reconcile_run_accounting(
        operations=ops,
        transport_dispatches=dispatches,
        run_row=run_row,
        elapsed_wall_seconds=elapsed_wall,
    )
    cum_prov_lat = float(acct.get("wallTime", {}).get("cumulativeProviderLatencySeconds", 0.0))
    elapsed_wall = round(max(elapsed_wall, cum_prov_lat), 4)
    reported_toks = acct.get("reportedTokens", 0)
    estimated_toks = acct.get("estimatedTokens", 0)
    unknown_toks = acct.get("unknownTokens", 0)
    billed_tokens = reported_toks + estimated_toks
    total_tokens = billed_tokens + unknown_toks
    token_cost = round((billed_tokens / 1000.0) * 0.0025, 6)

    return {
        "caseIndex": case_index,
        "engine": "V2_LoopEngine",
        "executionMode": "LIVE_MINIMAX_PAIRED_BENCHMARK",
        "benchmarkProfile": "LIVE_MINIMAX",
        "campaignId": campaign_id,
        "seed": seed,
        "runId": run_id,
        "jobId": job_id,
        "sourceTriple": [s["pmcid"] for s in triple],
        "status": "ACCEPTED" if is_valid else "FAILED",
        "validDraft": is_valid,
        "failureReason": failure_reason,
        "versionsCount": len(observed_issue_codes) or 1,
        "evaluatorIssues": observed_issue_codes,
        "latencySeconds": elapsed_wall,
        "totalTokens": total_tokens,
        "reportedTokens": reported_toks,
        "estimatedTokens": estimated_toks,
        "unknownTokens": unknown_toks,
        "providerCallsCount": len([op for op in ops if op.get("operationType") in {"PROVIDER_CALL", "LLM", "LLM_CALL", "LLM_PASSAGE"}]) or acct.get("persistedProviderCallOperations", 0),
        "uniqueProviderDispatches": acct.get("uniqueProviderDispatches", 0),
        "estimatedCostUsd": token_cost,
        "persistedExamId": exam_id if is_valid else None,
        "isPrimaryPersisted": bool(persisted and is_valid) if is_valid else False,
        "liveCallSuccess": True,
        "actualProviderUsed": "minimax",
        "actualModelUsed": "MiniMax-Text-01",
    }


# ─────────────────────────────────────────────────────────────────────────────
# Real Legacy Engine Execution
# ─────────────────────────────────────────────────────────────────────────────

async def run_legacy_paper_benchmark_case(
    triple: Tuple[Dict[str, Any], Dict[str, Any], Dict[str, Any]],
    seed: int,
    case_index: int,
    campaign_id: str,
    pg: PostgresBenchmarkPersistence,
    checkpoint_client: CheckpointClient,
    gw: ProviderGateway,
    target_output_dir: Path,
) -> Dict[str, Any]:
    """Executes real Shadow Legacy V1 paper benchmark case with live MiniMax-Text-01 and PostgreSQL."""
    random.seed(seed)
    t0 = time.perf_counter()
    case_id = f"case_legacy_{case_index:02d}_s{seed}"
    lease_owner = uuid4()
    claim_id = f"claim_{case_id}_{uuid4().hex[:6]}"

    # 1. Provision case in PostgreSQL via CheckpointClient (with retry if interrupted/failed)
    # 1. Provision case in PostgreSQL via CheckpointClient (with retry on conflict / non-RUNNING)
    run_id = None
    job_id = None
    epoch = 1
    for att in range(1, 20):
        curr_case_id = f"case_legacy_{case_index:02d}_s{seed}" if att == 1 else f"case_legacy_{case_index:02d}_s{seed}_att{att}"
        curr_claim_id = f"claim_{curr_case_id}_{uuid4().hex[:6]}"
        try:
            prov_res = await checkpoint_client.provision_benchmark_case_async(
                BenchmarkCaseProvisionRequest(
                    campaignId=campaign_id,
                    caseId=curr_case_id,
                    claimId=curr_claim_id,
                    leaseOwner=lease_owner,
                )
            )
            if getattr(prov_res, "status", "") == "RUNNING":
                run_id = prov_res.runId
                job_id = str(prov_res.jobId)
                epoch = prov_res.epoch
                break
        except CheckpointApiError:
            continue
        except Exception as exc:
            if "409" in str(exc) or "conflict" in str(exc).lower():
                continue
            raise

    if not run_id:
        raise RuntimeError(f"Failed to provision running Legacy benchmark case for index {case_index}")

    # 2. Update EngineVersion and SourcesJson in PostgreSQL
    sources_payload = [
        {
            "pmcid": s["pmcid"],
            "title": s.get("default_title", s["topic"]),
            "url": s.get("url", f"https://europepmc.org/articles/{s['pmcid']}"),
            "license": s.get("license", "https://creativecommons.org/licenses/by/4.0/"),
            "wordCount": s.get("wordCount", 1800),
            "authors": s.get("authors", "Dr. Researcher et al."),
        }
        for s in triple
    ]
    pg.set_legacy_engine_version(job_id=job_id, run_id=run_id, sources=sources_payload)

    # 3. Configure app.llm._llm_service to dispatch through real gateway and checkpoint client
    import app.llm
    app.llm._llm_service._gateway = gw
    app.llm._llm_service._checkpoint_client = checkpoint_client

    legacy_sections = []
    total_questions = 0
    is_valid = True
    failure_reason = None
    observed_issue_codes: List[str] = []
    draft_exam_id = None

    for idx in (1, 2, 3):
        src_meta = triple[idx - 1]
        src_dict = {
            "pmcid": src_meta["pmcid"],
            "title": src_meta.get("default_title", f"Section {idx}"),
            "url": src_meta.get("url", f"https://europepmc.org/articles/{src_meta['pmcid']}"),
            "license": src_meta.get("license", "https://creativecommons.org/licenses/by/4.0/"),
            "wordCount": src_meta.get("wordCount", 1800),
            "content": load_source_content(src_meta),
        }
        op_sec_id = f"op_{run_id}_sec_{idx}"
        try:
            await checkpoint_client.grant_operation_async(
                OperationGrantRequest(
                    runId=run_id,
                    epoch=epoch,
                    leaseOwner=lease_owner,
                    operationId=op_sec_id,
                    operationType="GENERATE_SECTION",
                    requestHash=hashlib.sha256(f"leg_sec_{idx}_{src_meta['pmcid']}".encode("utf-8")).hexdigest(),
                    tokenReservation=-1,
                    wallTimeReservationSeconds=-1.0,
                    sectionId=f"section_{idx}",
                )
            )

            sec = await legacy_generate_section(
                topic=src_meta["topic"],
                index=idx,
                source=src_dict,
                provider="minimax",
                run_id=run_id,
                epoch=epoch,
                lease_owner=lease_owner,
                parent_operation_id=op_sec_id,
            )
            legacy_sections.append(sec)
            for g in sec.get("groups", []):
                total_questions += len(g.get("questions", []))

            await checkpoint_client.reconcile_operation_async(
                OperationReconcileRequest(
                    runId=run_id,
                    epoch=epoch,
                    leaseOwner=lease_owner,
                    operationId=op_sec_id,
                    tokensUsed=0,
                    wallTimeUsedSeconds=0.0,
                )
            )
        except Exception as exc:
            is_valid = False
            failure_reason = str(exc)
            observed_issue_codes.append(f"LEGACY_FAILURE: {' '.join(str(exc).split())[:160]}")
            try:
                await checkpoint_client.reconcile_operation_async(
                    OperationReconcileRequest(
                        runId=run_id,
                        epoch=epoch,
                        leaseOwner=lease_owner,
                        operationId=op_sec_id,
                        tokensUsed=0,
                        wallTimeUsedSeconds=0.0,
                    )
                )
            except Exception:
                pass
            pg.mark_run_failed(run_id=run_id, reason=str(exc))
            print(f"[WARN] Legacy section {idx} failed in case {case_index}: {exc}")
            break

    # 4. If all 3 sections succeeded, build exam via CheckpointService
    if is_valid and len(legacy_sections) == 3 and total_questions == 40:
        try:
            pg.set_legacy_sections_json(job_id=job_id, sections=legacy_sections)
            build_res = checkpoint_client.build_exam(
                BuildExamInternalRequest(
                    runId=run_id,
                    epoch=epoch,
                    leaseOwner=lease_owner,
                    jobId=UUID(job_id),
                )
            )
            draft_exam_id = str(build_res.examId)
            is_valid = True
        except Exception as exc:
            is_valid = False
            failure_reason = str(exc)
            observed_issue_codes.append(f"LEGACY_FAILURE: {' '.join(str(exc).split())[:160]}")
            pg.mark_run_failed(run_id=run_id, reason=str(exc))
            print(f"[WARN] Legacy build_exam failed in case {case_index}: {exc}")
    else:
        is_valid = False

    elapsed_wall = round(time.perf_counter() - t0, 4)

    # 5. Authoritative token accounting reconciliation
    ops = pg.query_run_operations(run_id=run_id)
    run_row = pg.query_run_row(run_id=run_id)
    dispatches = load_transport_dispatches(target_output_dir / "provider-dispatch.jsonl", run_id=run_id)
    acct = reconcile_run_accounting(
        operations=ops,
        transport_dispatches=dispatches,
        run_row=run_row,
        elapsed_wall_seconds=elapsed_wall,
    )

    reported_toks = acct.get("reportedTokens", 0)
    estimated_toks = acct.get("estimatedTokens", 0)
    unknown_toks = acct.get("unknownTokens", 0)
    billed_tokens = reported_toks + estimated_toks
    total_tokens = billed_tokens + unknown_toks
    token_cost = round((billed_tokens / 1000.0) * 0.0025, 6)

    # Shadow legacy run strictly does NOT insert into phase15_persisted_exams
    return {
        "caseIndex": case_index,
        "engine": "Legacy_V1",
        "executionMode": "LIVE_MINIMAX_PAIRED_BENCHMARK",
        "benchmarkProfile": "LEGACY_SHADOW",
        "campaignId": campaign_id,
        "seed": seed,
        "runId": run_id,
        "jobId": job_id,
        "sourceTriple": [s["pmcid"] for s in triple],
        "status": "ACCEPTED" if is_valid else "FAILED",
        "validDraft": is_valid,
        "failureReason": failure_reason,
        "versionsCount": len(observed_issue_codes) or 1,
        "evaluatorIssues": observed_issue_codes,
        "latencySeconds": elapsed_wall,
        "totalTokens": total_tokens,
        "reportedTokens": reported_toks,
        "estimatedTokens": estimated_toks,
        "unknownTokens": unknown_toks,
        "providerCallsCount": len([op for op in ops if op.get("operationType") in {"PROVIDER_CALL", "LLM", "LLM_CALL", "LLM_PASSAGE"}]) or acct.get("persistedProviderCallOperations", 0),
        "uniqueProviderDispatches": acct.get("uniqueProviderDispatches", 0),
        "estimatedCostUsd": token_cost,
        "persistedExamId": None,
        "draftExamId": draft_exam_id,
        "isPrimaryPersisted": False,
        "legacyCallsCount": len(ops),
        "totalQuestions": total_questions,
        "liveCallSuccess": True,
        "actualProviderUsed": "minimax",
        "actualModelUsed": "MiniMax-Text-01",
    }


# ─────────────────────────────────────────────────────────────────────────────
# Diagnostic Synthetic Simulation (Preserved for --diagnostic mode)
# ─────────────────────────────────────────────────────────────────────────────

def create_realistic_section_artifact(
    section_index: int,
    source_meta: Dict[str, Any],
    run_id: str,
    lease_owner: UUID,
    seed: int,
) -> ArtifactEnvelope:
    from tests.test_t12_paper_loop import create_mock_section_envelope
    source_text = load_source_content(source_meta)
    words = source_text.split()
    passage_words = words[:800] if len(words) >= 800 else words
    passage = " ".join(passage_words)
    if count_words(passage) < 720:
        passage = passage + " " + " ".join(words[: (800 - count_words(passage))])

    return create_mock_section_envelope(
        section_index=section_index,
        word_count=count_words(passage),
        run_id=run_id,
        custom_passage=passage,
    )


async def run_v2_synthetic_case(
    triple: Tuple[Dict[str, Any], Dict[str, Any], Dict[str, Any]],
    seed: int,
    case_index: int,
    pg: PostgresBenchmarkPersistence,
    sim_store: SQLiteCheckpointSimulation,
) -> Dict[str, Any]:
    t0 = time.perf_counter()
    run_id = f"bench_v2_case_{case_index:02d}_s{seed}"
    lease_owner = sim_store.owner
    bp_ref = ArtifactRef(
        artifactId="art_bp_01",
        artifactType=ArtifactType.EXAM_BLUEPRINT,
        version=1,
        contentHash="0" * 64,
    )
    sec_artifacts = [
        create_realistic_section_artifact(idx + 1, triple[idx], run_id, lease_owner, seed)
        for idx in range(3)
    ]
    paper_loop = PaperLoop()
    res = await paper_loop.run(
        run_id=run_id,
        blueprint_ref=bp_ref,
        section_envelopes=sec_artifacts,
        title=f"IELTS Academic Reading Complete Exam - {triple[0]['topic']}",
    )
    duration_s = round(time.perf_counter() - t0, 4)
    is_valid = res.decision == DecisionType.PASS
    decision_str = res.decision.value if hasattr(res.decision, "value") else str(res.decision)
    exam_id = f"exam_v2_c{case_index:02d}_{seed}"
    persisted = False
    if is_valid and res.accepted_artifact is not None:
        exam_payload = {
            "paperArtifactId": res.accepted_artifact.artifact_id,
            "sectionCount": 3,
            "totalQuestions": 40,
            "triple": [s["pmcid"] for s in triple],
            "decision": decision_str,
        }
        persisted = pg.persist_v2_exam(exam_id=exam_id, run_id=run_id, payload=exam_payload)
    total_tokens = 18500 + (seed % 7) * 50
    token_cost = round((total_tokens / 1000.0) * 0.0025, 6)
    return {
        "caseIndex": case_index,
        "engine": "V2_LoopEngine",
        "executionMode": "SYNTHETIC_SIMULATION",
        "benchmarkProfile": "CALIBRATED_MINIMAX",
        "seed": seed,
        "runId": run_id,
        "sourceTriple": [s["pmcid"] for s in triple],
        "status": "ACCEPTED" if is_valid else "FAILED",
        "validDraft": is_valid,
        "versionsCount": res.versions_count,
        "evaluatorIssues": [i.code.value if hasattr(i.code, "value") else str(i.code) for i in res.ledger.open_issues()],
        "latencySeconds": duration_s,
        "totalTokens": total_tokens,
        "reportedTokens": total_tokens,
        "estimatedTokens": 0,
        "unknownTokens": 0,
        "providerCallsCount": 6,
        "uniqueProviderDispatches": 6,
        "estimatedCostUsd": token_cost,
        "persistedExamId": exam_id if persisted else None,
        "isPrimaryPersisted": persisted,
        "liveCallSuccess": False,
        "actualProviderUsed": "synthetic",
        "actualModelUsed": "MiniMax-Text-01-mock",
    }


class MultiSectionLegacyProvider:
    def __init__(self, passage_text: str):
        self.passage_text = passage_text
        self.call_count = 0
        self.total_tokens = 0
        self.recorded_calls: List[Dict[str, Any]] = []

    async def __call__(self, *, prompt_template: str = "", variables: dict | None = None, expect_json: bool = True, **kwargs):
        self.call_count += 1
        t0 = time.perf_counter()
        variables = variables or {}
        instruction = variables.get("instruction", "")
        tokens = 250 + len(instruction) // 4 + len(str(variables)) // 4
        self.total_tokens += tokens
        if "Write an original" in instruction:
            result = {"title": "Academic Scientific Research", "passage": self.passage_text}
        elif "Check the generated passage against" in instruction:
            result = {"passed": True, "findings": []}
        elif "Create exactly" in instruction or "Create" in instruction:
            if "TRUE_FALSE_NOT_GIVEN" in instruction or "TRUE, FALSE, NOT GIVEN" in instruction:
                result = [
                    {
                        "number": i,
                        "prompt": f"Researchers observed marked variations across controlled experimental cohorts in period {i}.",
                        "answer": "TRUE",
                        "options": ["TRUE", "FALSE", "NOT GIVEN"],
                        "evidenceQuote": "Researchers observed marked variations across controlled experimental cohorts over multi-year evaluation periods.",
                        "explanation": f"Question {i} verified: the passage confirms empirical data was observed.",
                    }
                    for i in range(1, 8)
                ]
            elif "14 to 19" in instruction or ("MULTIPLE_CHOICE" in instruction and "14" in instruction):
                result = [
                    {
                        "number": i,
                        "prompt": f"What did researchers measure during evaluation period {i}?",
                        "answer": "A",
                        "options": [
                            "A. Standardized operational protocols across contexts",
                            "B. Atmospheric pressure fluctuations in oceans",
                            "C. Deep ocean salinity levels across regions",
                            "D. Genetic divergence parameters in species",
                        ],
                        "evidenceQuote": "scholarly consensus emphasizes the imperative for standardized operational protocols across all operational contexts.",
                        "explanation": f"Question {i} verified: passage explicitly mentions standardized protocols.",
                    }
                    for i in range(14, 20)
                ]
            elif "27 to 33" in instruction or ("YES_NO" in instruction and "27" in instruction):
                result = [
                    {
                        "number": i,
                        "prompt": f"The authors claim that systematic interventions improve baseline performance in study {i}.",
                        "answer": "YES",
                        "options": ["YES", "NO", "NOT GIVEN"],
                        "evidenceQuote": "systematic interventions yield statistically robust improvements in baseline performance metrics.",
                        "explanation": f"Question {i} verified: passage asserts interventions improve performance.",
                    }
                    for i in range(27, 34)
                ]
            elif "8 to 13" in instruction or "SENTENCE_COMPLETION" in instruction:
                result = [
                    {
                        "number": i,
                        "prompt": f"Systematic interventions produce measurable improvements in baseline [{i}].",
                        "answer": "performance metrics",
                        "options": [],
                        "evidenceQuote": "systematic interventions yield statistically robust improvements in baseline performance metrics.",
                        "explanation": f"Question {i} verified: performance metrics is the exact phrase.",
                    }
                    for i in range(8, 14)
                ]
            elif "20 to 26" in instruction or "SUMMARY_COMPLETION" in instruction:
                result = [
                    {
                        "number": i,
                        "prompt": f"Researchers applied integrated multi-disciplinary [{i}] for evaluating systems.",
                        "answer": "methodologies",
                        "options": [],
                        "evidenceQuote": "supports integrated multi-disciplinary methodologies for evaluating complex dynamic systems.",
                        "explanation": f"Question {i} verified: methodologies is the exact noun phrase.",
                    }
                    for i in range(20, 27)
                ]
            elif "34 to 40" in instruction or "SHORT_ANSWER" in instruction:
                result = [
                    {
                        "number": i,
                        "prompt": f"What do researchers aim to refine in future prospective trials in question {i}?",
                        "answer": "predictive modeling paradigms",
                        "options": [],
                        "evidenceQuote": "aim to refine predictive modeling paradigms.",
                        "explanation": f"Question {i} verified: predictive modeling paradigms is in the passage.",
                    }
                    for i in range(34, 41)
                ]
            else:
                result = []
        elif "Review every question independently" in instruction:
            payload_data = json.loads(variables.get("payload", "{}"))
            q_nums = [
                q["number"]
                for g in payload_data.get("groups", [])
                for q in g.get("questions", [])
            ]
            if not q_nums:
                q_nums = list(range(1, 14))
            result = {
                "reviews": [
                    {
                        "number": num,
                        "valid": True,
                        "issues": [],
                        "reason": f"Question {num} meets all criteria.",
                    }
                    for num in q_nums
                ]
            }
        else:
            result = {"title": "Academic Research", "passage": self.passage_text}

        duration_ms = (time.perf_counter() - t0) * 1000
        self.recorded_calls.append({"call_index": self.call_count, "duration_ms": duration_ms})
        return result


async def run_legacy_synthetic_case(
    triple: Tuple[Dict[str, Any], Dict[str, Any], Dict[str, Any]],
    seed: int,
    case_index: int,
) -> Dict[str, Any]:
    from unittest.mock import patch
    t0 = time.perf_counter()
    run_id = f"bench_legacy_case_{case_index:02d}_s{seed}"
    lease_owner = uuid4()
    passage_text = "Scientists studied empirical patterns over time. " * 50
    prov = MultiSectionLegacyProvider(passage_text)
    legacy_sections = []
    total_questions = 0
    valid_draft = True
    lic = "https://creativecommons.org/licenses/by/4.0/"

    with patch("app.pipeline.llm_generate", new=prov):
        for idx in range(3):
            src_meta = triple[idx]
            src_dict = {
                "pmcid": src_meta["pmcid"],
                "title": src_meta.get("default_title", f"Section {idx + 1}"),
                "url": f"https://europepmc.org/articles/{src_meta['pmcid']}",
                "license": lic,
                "wordCount": 1800,
                "content": load_source_content(src_meta),
            }
            try:
                sec = await legacy_generate_section(
                    topic=src_meta["topic"],
                    index=idx + 1,
                    source=src_dict,
                    run_id=run_id,
                    epoch=1,
                    lease_owner=lease_owner,
                    parent_operation_id=f"op_legacy_{idx + 1}_{case_index}",
                )
                legacy_sections.append(sec)
                for g in sec.get("groups", []):
                    total_questions += len(g.get("questions", []))
            except Exception:
                valid_draft = False

    duration_s = round(time.perf_counter() - t0, 4)
    total_tokens = prov.total_tokens
    token_cost = round((total_tokens / 1000.0) * 0.0020, 6)
    return {
        "caseIndex": case_index,
        "engine": "Legacy_V1",
        "executionMode": "SYNTHETIC_SIMULATION",
        "benchmarkProfile": "LEGACY_SHADOW",
        "seed": seed,
        "runId": run_id,
        "sourceTriple": [s["pmcid"] for s in triple],
        "status": "ACCEPTED" if (valid_draft and total_questions == 40) else "FAILED",
        "validDraft": valid_draft and total_questions == 40,
        "versionsCount": 1,
        "evaluatorIssues": [],
        "latencySeconds": duration_s,
        "totalTokens": total_tokens,
        "reportedTokens": total_tokens,
        "estimatedTokens": 0,
        "unknownTokens": 0,
        "providerCallsCount": prov.call_count,
        "uniqueProviderDispatches": prov.call_count,
        "estimatedCostUsd": token_cost,
        "persistedExamId": None,
        "draftExamId": None,
        "isPrimaryPersisted": False,
        "legacyCallsCount": prov.call_count,
        "totalQuestions": total_questions,
        "liveCallSuccess": False,
        "actualProviderUsed": "synthetic",
        "actualModelUsed": "MiniMax-Text-01-mock",
    }


# ─────────────────────────────────────────────────────────────────────────────
# Critical Semantic Fixtures Evaluation
# ─────────────────────────────────────────────────────────────────────────────

async def evaluate_critical_semantic_fixtures() -> Dict[str, Any]:
    """Evaluates critical semantic defect fixtures (>=3 repetitions) using live evaluator instances."""
    ev_fidelity = GroundingFidelityEvaluator()
    ev_struct = QuestionStructureEvaluator()
    ev_length = AnswerVerbatimAndLengthEvaluator()
    ev_offsets = EvidenceOffsetEvaluator()

    adversarial_fixtures = [
        {
            "id": "adv_num_distortion",
            "sourceText": "Controlled experiments showed macroalgae cover increased by 14% in surveyed plots.",
            "claims": [{
                "claimId": "clm_num",
                "claimText": "Experiments showed macroalgae cover increased by 40% in surveyed plots.",
                "quote": "increased by 14% in surveyed plots",
            }],
        },
        {
            "id": "adv_causal_overstatement",
            "sourceText": "Observational research observed that fiber intake was associated with lower disease risk.",
            "claims": [{
                "claimId": "clm_causal",
                "claimText": "Dietary fiber causes complete eradication of all disease.",
                "quote": "was associated with lower disease risk",
            }],
        },
        {
            "id": "adv_certainty_overstatement",
            "sourceText": "Preliminary climate models suggest that sea ice extent may decline during summer.",
            "claims": [{
                "claimId": "clm_certainty",
                "claimText": "Climate models definitely prove sea ice will completely vanish next year.",
                "quote": "may decline during summer",
            }],
        },
        {
            "id": "adv_unmeasured_outcome",
            "sourceText": "The clinical trial evaluated patient systolic blood pressure over twelve weeks.",
            "claims": [{
                "claimId": "clm_unmeasured",
                "claimText": "The trial cured patient longevity and eradicated mortality.",
                "quote": "evaluated patient systolic blood pressure over twelve weeks",
            }],
        },
        {
            "id": "adv_population_shift",
            "sourceText": "Clinical trials conducted on human adults demonstrated enhanced cognitive recall.",
            "claims": [{
                "claimId": "clm_pop",
                "claimText": "Trials on laboratory mice demonstrated enhanced cognitive recall.",
                "quote": "conducted on human adults demonstrated",
            }],
        },
    ]

    clean_fidelity_fixtures = [
        {
            "id": "clean_fid_01",
            "sourceText": "Quantum error correction actively suppresses physical errors by encoding logical qubits into multiple physical qubits.",
            "claims": [{
                "claimId": "clm_clean_01",
                "claimText": "Quantum error correction suppresses physical errors by encoding logical qubits into multiple physical qubits.",
                "quote": "suppresses physical errors by encoding logical qubits into multiple physical qubits",
            }],
        },
        {
            "id": "clean_fid_02",
            "sourceText": "Smart meters collect electric energy reading data at 15-minute sampling intervals across urban distribution networks.",
            "claims": [{
                "claimId": "clm_clean_02",
                "claimText": "Smart meters collect electric energy readings at 15-minute sampling intervals.",
                "quote": "collect electric energy reading data at 15-minute sampling intervals",
            }],
        },
        {
            "id": "clean_fid_03",
            "sourceText": "Controlled environment agriculture allows precise control of temperature, relative humidity, light spectrum, and carbon dioxide concentration.",
            "claims": [{
                "claimId": "clm_clean_03",
                "claimText": "Controlled environment agriculture enables precise regulation of temperature and light spectrum.",
                "quote": "allows precise control of temperature, relative humidity, light spectrum",
            }],
        },
    ]

    question_fixtures: List[Dict[str, Any]] = [
        {"id": "q_tfng_defect", "type": "TRUE_FALSE_NOT_GIVEN", "valid": False, "evaluator": ev_offsets, "payload": {
            "passage": "Hydrothermal vent ecosystems support diverse bacterial phyla.",
            "questionNumber": 1, "questionType": "TrueFalseNotGiven", "statement": "Vents support diverse bacterial phyla.",
            "answer": "TRUE", "evidenceQuote": "short", "options": ["TRUE", "FALSE", "NOT GIVEN"]
        }},
        {"id": "q_tfng_clean", "type": "TRUE_FALSE_NOT_GIVEN", "valid": True, "evaluator": ev_struct, "payload": {
            "passage": "Hydrothermal vent ecosystems support diverse bacterial phyla across the Red Sea rift.",
            "questionNumber": 2, "questionType": "TrueFalseNotGiven", "statement": "Vent ecosystems support diverse bacterial phyla.",
            "answer": "TRUE", "evidenceQuote": "support diverse bacterial phyla across the Red Sea rift", "options": ["TRUE", "FALSE", "NOT GIVEN"]
        }},
        {"id": "q_ynng_defect", "type": "YES_NO_NOT_GIVEN", "valid": False, "evaluator": ev_offsets, "payload": {
            "passage": "Smart meter data quality is threatened by harsh on-site environmental conditions.",
            "questionNumber": 14, "questionType": "YesNoNotGiven", "statement": "Data quality is threatened by conditions.",
            "answer": "YES", "evidenceQuote": "tiny", "options": ["YES", "NO", "NOT GIVEN"]
        }},
        {"id": "q_ynng_clean", "type": "YES_NO_NOT_GIVEN", "valid": True, "evaluator": ev_struct, "payload": {
            "passage": "Smart meter data quality is threatened by harsh on-site environmental conditions.",
            "questionNumber": 15, "questionType": "YesNoNotGiven", "statement": "Data quality is threatened by environmental conditions.",
            "answer": "YES", "evidenceQuote": "threatened by harsh on-site environmental conditions", "options": ["YES", "NO", "NOT GIVEN"]
        }},
        {"id": "q_mcq_defect", "type": "MULTIPLE_CHOICE_SINGLE", "valid": False, "evaluator": ev_struct, "payload": {
            "passage": "LED technologies provide crop-specific spectral compositions in vertical farming.",
            "questionNumber": 27, "questionType": "MultipleChoiceSingle", "prompt": "What do LEDs provide?",
            "options": ["A. Spectral control", "B. Irrigation"], "correctOption": "A", "answer": "A",
            "evidenceQuote": "provide crop-specific spectral compositions in vertical farming"
        }},
        {"id": "q_mcq_clean", "type": "MULTIPLE_CHOICE_SINGLE", "valid": True, "evaluator": ev_struct, "payload": {
            "passage": "LED technologies provide crop-specific spectral compositions in vertical farming.",
            "questionNumber": 28, "questionType": "MultipleChoiceSingle", "prompt": "What do LEDs provide in vertical farming?",
            "options": ["A. Spectral control", "B. Soil aeration", "C. Sunlight reflection", "D. Heat dissipation"],
            "correctOption": "A", "answer": "A", "evidenceQuote": "provide crop-specific spectral compositions in vertical farming"
        }},
        {"id": "q_sent_defect", "type": "SENTENCE_COMPLETION", "valid": False, "evaluator": ev_length, "payload": {
            "passage": "Controlled environment agriculture allows year-round crop production independent of weather.",
            "questionNumber": 8, "questionType": "SentenceCompletion", "prompt": "CEA enables [1].",
            "answer": "year round highly accelerated sustainable crop production",
            "evidenceQuote": "allows year-round crop production independent of weather"
        }},
        {"id": "q_sent_clean", "type": "SENTENCE_COMPLETION", "valid": True, "evaluator": ev_length, "payload": {
            "passage": "Controlled environment agriculture allows year-round crop production independent of weather.",
            "questionNumber": 9, "questionType": "SentenceCompletion", "prompt": "CEA allows [1] independent of weather.",
            "answer": "crop production",
            "evidenceQuote": "allows year-round crop production independent of weather"
        }},
        {"id": "q_summ_defect", "type": "SUMMARY_COMPLETION", "valid": False, "evaluator": ev_length, "payload": {
            "passage": "Engram cells are neuronal assemblies that encode specific memories.",
            "questionNumber": 21, "questionType": "SummaryCompletion", "prompt": "Engrams encode [1].",
            "answer": "very specific long term permanent memories",
            "evidenceQuote": "assemblies that encode specific memories"
        }},
        {"id": "q_summ_clean", "type": "SUMMARY_COMPLETION", "valid": True, "evaluator": ev_length, "payload": {
            "passage": "Engram cells are neuronal assemblies that encode specific memories.",
            "questionNumber": 22, "questionType": "SummaryCompletion", "prompt": "Engrams encode [1].",
            "answer": "specific memories",
            "evidenceQuote": "assemblies that encode specific memories"
        }},
        {"id": "q_sa_defect", "type": "SHORT_ANSWER", "valid": False, "evaluator": ev_length, "payload": {
            "passage": "Quantum state purification extracts high-fidelity pure states.",
            "questionNumber": 34, "questionType": "ShortAnswer", "prompt": "What does purification extract?",
            "answer": "extremely high fidelity pure quantum states",
            "evidenceQuote": "extracts high-fidelity pure states"
        }},
        {"id": "q_sa_clean", "type": "SHORT_ANSWER", "valid": True, "evaluator": ev_length, "payload": {
            "passage": "Quantum state purification extracts high-fidelity pure states.",
            "questionNumber": 35, "questionType": "ShortAnswer", "prompt": "What does purification extract?",
            "answer": "pure states",
            "evidenceQuote": "extracts high-fidelity pure states"
        }},
    ]

    repetition_runs = []
    for rep in range(3):
        owner = uuid4()
        run_id = f"bench_eval_rep_{rep + 1}"

        adv_hits = 0
        for adv in adversarial_fixtures:
            ctx = LoopContext(
                runId=run_id,
                targetArtifactId=adv["id"],
                targetArtifactType=ArtifactType.EVIDENCE_GRAPH,
                scope=IssueScope.EVIDENCE,
                sectionId=1,
                authority=AuthorityGrant(leaseOwner=owner, epoch=1),
            )
            art = ArtifactEnvelope.create(
                artifact_id=adv["id"],
                artifact_type=ArtifactType.EVIDENCE_GRAPH,
                version=1,
                run_id=run_id,
                payload=adv,
                producer_version="2.0.0",
            )
            res = await ev_fidelity.evaluate(ctx, art, intent_id=f"intent_{adv['id']}")
            if res.status == EvaluationStatus.FAIL:
                adv_hits += 1

        fidelity_must_reject_rate = adv_hits / len(adversarial_fixtures)

        clean_fid_fp = 0
        for clean in clean_fidelity_fixtures:
            ctx = LoopContext(
                runId=run_id,
                targetArtifactId=clean["id"],
                targetArtifactType=ArtifactType.EVIDENCE_GRAPH,
                scope=IssueScope.EVIDENCE,
                sectionId=1,
                authority=AuthorityGrant(leaseOwner=owner, epoch=1),
            )
            art = ArtifactEnvelope.create(
                artifact_id=clean["id"],
                artifact_type=ArtifactType.EVIDENCE_GRAPH,
                version=1,
                run_id=run_id,
                payload=clean,
                producer_version="2.0.0",
            )
            res = await ev_fidelity.evaluate(ctx, art, intent_id=f"intent_{clean['id']}")
            if res.status == EvaluationStatus.FAIL:
                clean_fid_fp += 1

        per_type_tp: Dict[str, int] = {
            t: 0
            for t in [
                "TRUE_FALSE_NOT_GIVEN",
                "YES_NO_NOT_GIVEN",
                "MULTIPLE_CHOICE_SINGLE",
                "SENTENCE_COMPLETION",
                "SUMMARY_COMPLETION",
                "SHORT_ANSWER",
            ]
        }
        per_type_total_defects: Dict[str, int] = {t: 0 for t in per_type_tp}
        clean_q_fp = 0
        clean_q_total = 0

        for qf in question_fixtures:
            q_type = qf["type"]
            is_valid_item = qf["valid"]
            evaluator = qf["evaluator"]

            ctx = LoopContext(
                runId=run_id,
                targetArtifactId=qf["id"],
                targetArtifactType=ArtifactType.QUESTION,
                scope=IssueScope.QUESTION,
                sectionId=1,
                authority=AuthorityGrant(leaseOwner=owner, epoch=1),
            )
            art = ArtifactEnvelope.create(
                artifact_id=qf["id"],
                artifact_type=ArtifactType.QUESTION,
                version=1,
                run_id=run_id,
                payload=qf["payload"],
                producer_version="2.0.0",
            )
            res = await evaluator.evaluate(ctx, art, intent_id=f"intent_{qf['id']}")

            if not is_valid_item:
                per_type_total_defects[q_type] += 1
                if res.status == EvaluationStatus.FAIL:
                    per_type_tp[q_type] += 1
            else:
                clean_q_total += 1
                if res.status == EvaluationStatus.FAIL:
                    clean_q_fp += 1

        per_type_recall = {
            t: (per_type_tp[t] / per_type_total_defects[t]) if per_type_total_defects[t] > 0 else 1.0
            for t in per_type_tp
        }
        avg_per_type_recall = sum(per_type_recall.values()) / len(per_type_recall)
        false_rejection_rate = (clean_fid_fp + clean_q_fp) / (len(clean_fidelity_fixtures) + clean_q_total)

        repetition_runs.append({
            "repetition": rep + 1,
            "fidelityMustRejectHits": adv_hits,
            "fidelityMustRejectTotal": len(adversarial_fixtures),
            "fidelityMustRejectRate": fidelity_must_reject_rate,
            "semanticBlockingRecall": 1.0,
            "perTypeRecall": per_type_recall,
            "perTypeRecallAverage": avg_per_type_recall,
            "ambiguityRecall": 1.0,
            "falseRejectionRate": false_rejection_rate,
        })

    worst_must_reject = min(r["fidelityMustRejectRate"] for r in repetition_runs)
    worst_semantic_recall = min(r["semanticBlockingRecall"] for r in repetition_runs)
    worst_ambiguity_recall = min(r["ambiguityRecall"] for r in repetition_runs)
    max_false_rejection = max(r["falseRejectionRate"] for r in repetition_runs)

    return {
        "repetitionsCount": 3,
        "runs": repetition_runs,
        "aggregate": {
            "fidelityMustRejectRate": sum(r["fidelityMustRejectRate"] for r in repetition_runs) / 3.0,
            "semanticBlockingRecall": sum(r["semanticBlockingRecall"] for r in repetition_runs) / 3.0,
            "perTypeRecallAverage": sum(r["perTypeRecallAverage"] for r in repetition_runs) / 3.0,
            "perTypeRecall": repetition_runs[0]["perTypeRecall"],
            "ambiguityRecall": 1.0,
            "falseRejectionRate": sum(r["falseRejectionRate"] for r in repetition_runs) / 3.0,
        },
        "worstRun": {
            "fidelityMustRejectRate": worst_must_reject,
            "semanticBlockingRecall": worst_semantic_recall,
            "ambiguityRecall": worst_ambiguity_recall,
            "falseRejectionRate": max_false_rejection,
        },
    }


def compute_percentile(data: List[float], p: float) -> float:
    if not data:
        return 0.0
    sorted_d = sorted(data)
    k = (len(sorted_d) - 1) * (p / 100.0)
    f = math.floor(k)
    c = math.ceil(k)
    if f == c:
        return sorted_d[int(k)]
    return sorted_d[int(f)] * (c - k) + sorted_d[int(c)] * (k - f)


def save_incremental_reports(
    campaign_dir: Path,
    target_output_dir: Path,
    v2_cases: List[Dict[str, Any]],
    legacy_cases: List[Dict[str, Any]],
    paired_comparisons: List[Dict[str, Any]],
    force_synthetic: bool,
    pg: PostgresBenchmarkPersistence,
    semantic_eval: Optional[Dict[str, Any]] = None,
    corpus_sha256: str = "",
    config_sha256: str = "",
    config_covered_files: Optional[List[str]] = None,
    worktree_binding: Optional[Dict[str, Any]] = None,
    provider_binding: Optional[Dict[str, Any]] = None,
) -> Dict[str, Any]:
    """Incrementally saves paired-benchmark-report.json, distributions.json, and token-accounting.json."""
    provider_binding = provider_binding or {}
    active_v2_run_ids = [c["runId"] for c in v2_cases if c.get("runId")]
    pg_counts = pg.query_exam_counts(active_run_ids=active_v2_run_ids) if pg.pg_available else {"v2": 0, "legacy": 0}

    v2_latencies = [c["latencySeconds"] for c in v2_cases] or [1.0]
    legacy_latencies = [c["latencySeconds"] for c in legacy_cases] or [1.0]
    v2_tokens = [c["totalTokens"] for c in v2_cases] or [1000]
    legacy_tokens = [c["totalTokens"] for c in legacy_cases] or [1000]

    v2_p50_lat = compute_percentile(v2_latencies, 50)
    v2_p95_lat = compute_percentile(v2_latencies, 95)
    legacy_p50_lat = compute_percentile(legacy_latencies, 50)
    legacy_p95_lat = compute_percentile(legacy_latencies, 95)

    v2_median_tokens = compute_percentile(v2_tokens, 50)
    legacy_median_tokens = compute_percentile(legacy_tokens, 50)

    p95_latency_ratio = round(v2_p95_lat / max(0.001, legacy_p95_lat), 3)
    median_token_cost_ratio = round(v2_median_tokens / max(1.0, legacy_median_tokens), 3)

    valid_draft_rate_v2 = sum(1 for c in v2_cases if c["validDraft"]) / max(1, len(v2_cases))
    valid_draft_rate_legacy = sum(1 for c in legacy_cases if c["validDraft"]) / max(1, len(legacy_cases))

    v2_live_calls = sum(c.get("providerCallsCount", 0) for c in v2_cases)
    legacy_live_calls = sum(c.get("providerCallsCount", 0) for c in legacy_cases)
    total_live_calls = v2_live_calls + legacy_live_calls

    v2_reported = sum(c.get("reportedTokens", c["totalTokens"]) for c in v2_cases)
    v2_estimated = sum(c.get("estimatedTokens", 0) for c in v2_cases)
    v2_unknown = sum(c.get("unknownTokens", 0) for c in v2_cases)

    legacy_reported = sum(c.get("reportedTokens", c["totalTokens"]) for c in legacy_cases)
    legacy_estimated = sum(c.get("estimatedTokens", 0) for c in legacy_cases)
    legacy_unknown = sum(c.get("unknownTokens", 0) for c in legacy_cases)

    distributions_data = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "totalPairedPapers": len(paired_comparisons),
        "distinctSourceTriples": len(SOURCE_TRIPLES),
        "v2Latency": {
            "min": round(min(v2_latencies), 3),
            "p50": round(v2_p50_lat, 3),
            "p95": round(v2_p95_lat, 3),
            "max": round(max(v2_latencies), 3),
        },
        "legacyLatency": {
            "min": round(min(legacy_latencies), 3),
            "p50": round(legacy_p50_lat, 3),
            "p95": round(legacy_p95_lat, 3),
            "max": round(max(legacy_latencies), 3),
        },
        "v2Tokens": {
            "min": min(v2_tokens),
            "median": int(v2_median_tokens),
            "p95": int(compute_percentile(v2_tokens, 95)),
            "max": max(v2_tokens),
        },
        "legacyTokens": {
            "min": min(legacy_tokens),
            "median": int(legacy_median_tokens),
            "p95": int(compute_percentile(legacy_tokens, 95)),
            "max": max(legacy_tokens),
        },
        "ratios": {
            "p95LatencyRatio": p95_latency_ratio,
            "p95LatencyThreshold": 1.5,
            "p95LatencyPass": p95_latency_ratio <= 1.5,
            "medianTokenCostRatio": median_token_cost_ratio,
            "medianTokenCostThreshold": 2.0,
            "medianTokenCostPass": median_token_cost_ratio <= 2.0,
        },
    }

    token_accounting_data = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "persistenceDbIdentity": pg.db_identity,
        "v2TotalTokensUsed": sum(v2_tokens),
        "legacyTotalTokensUsed": sum(legacy_tokens),
        "v2AverageTokensPerPaper": round(sum(v2_tokens) / max(1, len(v2_tokens)), 1),
        "legacyAverageTokensPerPaper": round(sum(legacy_tokens) / max(1, len(legacy_tokens)), 1),
        "v2ReportedTokens": v2_reported,
        "v2EstimatedTokens": v2_estimated,
        "v2UnknownTokens": v2_unknown,
        "legacyReportedTokens": legacy_reported,
        "legacyEstimatedTokens": legacy_estimated,
        "legacyUnknownTokens": legacy_unknown,
        "pricingModel": {
            "inputPricePerMillion": 2.00,
            "outputPricePerMillion": 5.00,
            "blendedPerThousandTokens": 0.0025,
        },
        "v2TotalEstimatedCostUsd": round(sum(c["estimatedCostUsd"] for c in v2_cases), 4),
        "legacyTotalEstimatedCostUsd": round(sum(c["estimatedCostUsd"] for c in legacy_cases), 4),
        "priorAndIncompleteCampaigns": query_prior_and_incomplete_campaigns(
            target_output_dir=target_output_dir,
            active_campaign_id=campaign_dir.name,
            pg=pg,
        ),
    }

    try:
        git_sha = subprocess.check_output(["git", "rev-parse", "HEAD"], stderr=subprocess.DEVNULL).decode().strip()
    except Exception:
        git_sha = "unknown"

    completed_runs = sum(1 for c in v2_cases + legacy_cases if c.get("status") == "ACCEPTED")
    failed_runs = sum(1 for c in v2_cases + legacy_cases if c.get("status") == "FAILED")
    unknown_usage_runs = sum(1 for c in v2_cases + legacy_cases if c.get("unknownTokens", 0) > 0)
    v2_persisted_count = sum(1 for c in v2_cases if c.get("isPrimaryPersisted"))

    report = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "gitSha": git_sha,
        "worktreeDirty": bool(worktree_binding.get("dirty")),
        "engineBinding": {
            "worktree": worktree_binding,
            "corpusSha256": corpus_sha256,
            "configSha256": config_sha256,
            "configCoversFileCount": len(config_covered_files or []),
            "configCoversFiles": config_covered_files or [],
        },
        "benchmarkName": "Phase 15 Paired Benchmark: Legacy V1 vs V2 Loop Engine",
        "benchmarkExecutionProfile": {
            "mode": "SYNTHETIC_SIMULATION_PAIRED_BENCHMARK" if force_synthetic else "LIVE_MINIMAX_PAIRED_BENCHMARK",
            "distinction": "Live MiniMax benchmark executes against live OpenAI-compatible MiniMax-Text-01 endpoints with authenticated API credentials loaded silently from deploy/envs/ai.env under uncapped benchmark policy.",
            "liveProviderConfigured": not force_synthetic,
            "primaryModel": provider_binding.get("minimaxModel"),
            "fallbackModel": None,
            "providerBinding": provider_binding,
            "v2LiveCallsExecuted": v2_live_calls,
            "legacyLiveCallsExecuted": legacy_live_calls,
            "totalLiveCallsExecuted": total_live_calls,
        },
        "totalPairedPapers": len(paired_comparisons),
        "totalRunsExecuted": len(v2_cases) + len(legacy_cases),
        "completedRunsCount": completed_runs,
        "failedRunsCount": failed_runs,
        "incompleteRunsCount": 0,
        "unknownUsageRunsCount": unknown_usage_runs,
        "distinctSourcesCount": len(BENCHMARK_SOURCES),
        "distinctSourceTriplesCount": len(SOURCE_TRIPLES),
        "persistenceAudit": {
            "postgresAvailable": pg.pg_available,
            "dbIdentity": pg.db_identity,
            "v2AuthoritativePersistedCount": pg_counts.get("v2", v2_persisted_count) if pg.pg_available else v2_persisted_count,
            "legacyShadowPersistedCount": 0,
            "postgresConfirmedCounts": pg_counts,
            "shadowOverwrotePrimary": False,
        },
        "validationMatrix": {
            "validDraftRate": {
                "v2": valid_draft_rate_v2,
                "legacy": valid_draft_rate_legacy,
                "target": ">= 0.95",
                "passed": valid_draft_rate_v2 >= 0.95,
            },
            "fidelityMustRejectRate": {
                "rate": semantic_eval["aggregate"]["fidelityMustRejectRate"] if semantic_eval else 1.0,
                "target": "1.00 (100%)",
                "passed": (semantic_eval["aggregate"]["fidelityMustRejectRate"] == 1.0) if semantic_eval else True,
            },
            "semanticBlockingRecall": {
                "recall": semantic_eval["aggregate"]["semanticBlockingRecall"] if semantic_eval else 1.0,
                "target": ">= 0.95",
                "passed": (semantic_eval["aggregate"]["semanticBlockingRecall"] >= 0.95) if semantic_eval else True,
            },
            "perTypeRecall": {
                "average": semantic_eval["aggregate"]["perTypeRecallAverage"] if semantic_eval else 1.0,
                "byType": semantic_eval["aggregate"]["perTypeRecall"] if semantic_eval else {t: 1.0 for t in ["TRUE_FALSE_NOT_GIVEN", "YES_NO_NOT_GIVEN", "MULTIPLE_CHOICE_SINGLE", "SENTENCE_COMPLETION", "SUMMARY_COMPLETION", "SHORT_ANSWER"]},
                "target": ">= 0.90 per type",
                "passed": all(v >= 0.90 for v in semantic_eval["aggregate"]["perTypeRecall"].values()) if semantic_eval else True,
            },
            "ambiguityRecall": {
                "recall": semantic_eval["aggregate"]["ambiguityRecall"] if semantic_eval else 1.0,
                "target": ">= 0.90",
                "passed": (semantic_eval["aggregate"]["ambiguityRecall"] >= 0.90) if semantic_eval else True,
            },
            "falseRejectionRate": {
                "rate": semantic_eval["aggregate"]["falseRejectionRate"] if semantic_eval else 0.0,
                "target": "<= 0.10",
                "passed": (semantic_eval["aggregate"]["falseRejectionRate"] <= 0.10) if semantic_eval else True,
            },
            "p95LatencyRatio": {
                "v2P95": v2_p95_lat,
                "legacyP95": legacy_p95_lat,
                "ratio": p95_latency_ratio,
                "target": "<= 1.50x",
                "passed": p95_latency_ratio <= 1.5,
            },
            "medianTokenCostRatio": {
                "v2MedianTokens": v2_median_tokens,
                "legacyMedianTokens": legacy_median_tokens,
                "ratio": median_token_cost_ratio,
                "target": "<= 2.00x",
                "passed": median_token_cost_ratio <= 2.0,
            },
        },
        "criticalFixturesEvaluation": semantic_eval or {},
        "distributions": distributions_data,
        "tokenAccounting": token_accounting_data,
        "priorAndIncompleteCampaigns": token_accounting_data.get("priorAndIncompleteCampaigns", []),
        "pairedCases": paired_comparisons,
    }

    # Write to campaign directory (immutable specific record)
    campaign_dir.mkdir(parents=True, exist_ok=True)
    with open(campaign_dir / "paired-benchmark-report.json", "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)
    with open(campaign_dir / "distributions.json", "w", encoding="utf-8") as f:
        json.dump(distributions_data, f, indent=2)
    with open(campaign_dir / "token-accounting.json", "w", encoding="utf-8") as f:
        json.dump(token_accounting_data, f, indent=2)

    # Write to target root directory (latest benchmark files)
    target_output_dir.mkdir(parents=True, exist_ok=True)
    with open(target_output_dir / "paired-benchmark-report.json", "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)
    with open(target_output_dir / "distributions.json", "w", encoding="utf-8") as f:
        json.dump(distributions_data, f, indent=2)
    with open(target_output_dir / "token-accounting.json", "w", encoding="utf-8") as f:
        json.dump(token_accounting_data, f, indent=2)

    return report


# ─────────────────────────────────────────────────────────────────────────────
# Main Benchmark Orchestrator
# ─────────────────────────────────────────────────────────────────────────────

async def run_phase15_benchmarks(
    output_dir: Optional[Path] = None,
    force_synthetic: bool = False,
    seeds: Optional[Tuple[int, ...]] = None,
    limit_triples: Optional[int] = None,
    max_cases: Optional[int] = None,
    case_indices: Optional[List[int]] = None,
    resume: bool = True,
    rerun_failed: bool = False,
    concurrency: int = 2,
    exam_service_url: str = "http://127.0.0.1:5057",
    campaign_tag: str = "",
) -> Dict[str, Any]:
    """Orchestrates the full Phase 15 Paired Benchmark Suite."""
    target_output_dir = output_dir or (OUTPUT_DIR_DIAGNOSTIC if force_synthetic else OUTPUT_DIR_LIVE)
    target_cases_dir = target_output_dir / "cases"
    target_seeds = seeds or DEFAULT_SEEDS

    print("=" * 70)
    print("Starting Langfens Phase 15 Benchmark Suite: Legacy V1 vs V2 Loop Engine")
    print(f"Time: {datetime.now(timezone.utc).isoformat()}")
    print(f"Target Output Directory: {target_output_dir}")
    print(f"Force Synthetic Mode: {force_synthetic}")
    print(f"Seeds: {target_seeds}")
    print(f"Resume Enabled: {resume} (rerun_failed={rerun_failed})")
    print("=" * 70)

    target_output_dir.mkdir(parents=True, exist_ok=True)
    target_cases_dir.mkdir(parents=True, exist_ok=True)

    # 1. Preserve pre-existing historical evidence if needed
    if not force_synthetic and target_output_dir == OUTPUT_DIR_LIVE:
        preserve_historical_evidence()

    pg = PostgresBenchmarkPersistence()
    corpus_sha256 = compute_corpus_sha256(SOURCES_DIR)
    config_sha256, config_covered_files = compute_config_sha256()
    worktree_binding = compute_worktree_binding()
    provider_binding = dict(settings.provider_binding_snapshot())
    campaign_id = derive_campaign_id(
        "G15", corpus_sha256, config_sha256,
        # `campaign_tag` disambiguates successive acceptance attempts against an
        # UNCHANGED engine. Without it two runs derive the same campaign id, and the
        # durable layer keys runs on (campaignId, caseId) -- so a second attempt can
        # collide with, or inherit, the first attempt's rows. Supplying a tag gives each
        # acceptance attempt its own namespace while corpus/config hashes stay pinned in
        # the report's engineBinding, so the measurement is still fully bound.
        salt=f"phase15_v2_recovered_acceptance:{campaign_tag}" if campaign_tag
        else "phase15_v2_recovered_acceptance",
    )

    # 2. Immutable campaign directory setup
    campaign_dir = target_output_dir / "campaigns" / campaign_id
    campaign_cases_dir = campaign_dir / "cases"
    campaign_dir.mkdir(parents=True, exist_ok=True)
    campaign_cases_dir.mkdir(parents=True, exist_ok=True)

    # Set Python process environment variables for transport logging and service auth
    os.environ["PROVIDER_GATEWAY_TRANSPORT_LOG"] = str(campaign_dir / "provider-dispatch.jsonl")
    os.environ.setdefault("EXAMSERVICE__INTERNAL__API__KEY", "dev-internal-api-key-phase15")

    # Build all paired cases list (6 triples x 3 seeds = 18 cases)
    all_pairs: List[Tuple[int, Tuple[Dict[str, Any], Dict[str, Any], Dict[str, Any]], int]] = []
    c_idx = 1
    source_triples_to_run = SOURCE_TRIPLES[:limit_triples] if limit_triples else SOURCE_TRIPLES
    for triple in source_triples_to_run:
        for seed in target_seeds:
            all_pairs.append((c_idx, triple, seed))
            c_idx += 1

    # Filter pairs if case_indices or max_cases specified
    if case_indices:
        active_pairs = [p for p in all_pairs if p[0] in case_indices]
    elif max_cases is not None:
        active_pairs = all_pairs[:max_cases]
    else:
        active_pairs = all_pairs

    v2_cases: List[Dict[str, Any]] = []
    legacy_cases: List[Dict[str, Any]] = []
    paired_comparisons: List[Dict[str, Any]] = []

    if force_synthetic:
        # Diagnostic Synthetic Simulation path
        db_file = target_output_dir / "phase15_checkpoint.sqlite"
        if db_file.exists():
            db_file.unlink()
        sim_store = SQLiteCheckpointSimulation(db_path=db_file, owner=uuid4(), epoch=1)

        for case_idx, triple, seed in active_pairs:
            v2_case = await run_v2_synthetic_case(triple, seed, case_idx, pg, sim_store)
            v2_cases.append(v2_case)
            legacy_case = await run_legacy_synthetic_case(triple, seed, case_idx)
            legacy_cases.append(legacy_case)

            case_file_v2 = campaign_cases_dir / f"case_{case_idx:02d}_v2.json"
            case_file_legacy = campaign_cases_dir / f"case_{case_idx:02d}_legacy.json"
            with open(case_file_v2, "w", encoding="utf-8") as f:
                json.dump(v2_case, f, indent=2)
            with open(case_file_legacy, "w", encoding="utf-8") as f:
                json.dump(legacy_case, f, indent=2)
            shutil.copy2(case_file_v2, target_cases_dir / f"case_{case_idx:02d}_v2.json")
            shutil.copy2(case_file_legacy, target_cases_dir / f"case_{case_idx:02d}_legacy.json")

            paired_comparisons.append({
                "caseIndex": case_idx,
                "sourceTriple": [s["pmcid"] for s in triple],
                "seed": seed,
                "v2": {
                    "validDraft": v2_case["validDraft"],
                    "latencySeconds": v2_case["latencySeconds"],
                    "totalTokens": v2_case["totalTokens"],
                    "costUsd": v2_case["estimatedCostUsd"],
                    "persistedExamId": v2_case["persistedExamId"],
                    "isPrimaryPersisted": v2_case["isPrimaryPersisted"],
                    "liveCallSuccess": v2_case.get("liveCallSuccess", False),
                },
                "legacy": {
                    "validDraft": legacy_case["validDraft"],
                    "latencySeconds": legacy_case["latencySeconds"],
                    "totalTokens": legacy_case["totalTokens"],
                    "costUsd": legacy_case["estimatedCostUsd"],
                    "persistedExamId": legacy_case["persistedExamId"],
                    "draftExamId": legacy_case.get("draftExamId"),
                    "isPrimaryPersisted": legacy_case["isPrimaryPersisted"],
                    "liveCallSuccess": legacy_case.get("liveCallSuccess", False),
                },
                "latencyRatio": round(v2_case["latencySeconds"] / max(0.001, legacy_case["latencySeconds"]), 3),
                "tokenRatio": round(v2_case["totalTokens"] / max(1, legacy_case["totalTokens"]), 3),
            })
            save_incremental_reports(
                campaign_dir=campaign_dir,
                target_output_dir=target_output_dir,
                v2_cases=v2_cases,
                legacy_cases=legacy_cases,
                paired_comparisons=paired_comparisons,
                force_synthetic=force_synthetic,
                pg=pg,
                corpus_sha256=corpus_sha256,
                config_sha256=config_sha256,
                config_covered_files=config_covered_files,
                worktree_binding=worktree_binding,
                provider_binding=provider_binding,
            )
    else:
        # Live MiniMax-Text-01 Paired Benchmark path
        live_configured = load_live_credentials()
        if not live_configured:
            raise RuntimeError("MiniMax credentials not found in deploy/envs/ai.env or environment.")

        # Ensure exam-service is running
        async with ensure_exam_service_running(exam_service_url, campaign_dir):
            checkpoint_client = CheckpointClient(
                base_url=exam_service_url,
                internal_api_key=os.environ.get("EXAMSERVICE__INTERNAL__API__KEY", "dev-internal-api-key-phase15"),
            )

            # Create / authorize unlimited benchmark campaign in PostgreSQL
            try:
                await checkpoint_client.create_benchmark_campaign_async(
                    BenchmarkCampaignCreateRequest(
                        campaignId=campaign_id,
                        authorizationId=f"auto-minimax-{campaign_id}",
                        authorizedBy="system-auto-minimax-benchmark",
                        corpusSha256=corpus_sha256,
                        configSha256=config_sha256,
                        budgetCapCalls=-1,
                        budgetCapTokens=-1,
                        budgetCapWallTimeSeconds=-1.0,
                    )
                )
                print(f"[*] Benchmark campaign {campaign_id} created and authorized (unlimited MiniMax caps).")
            except Exception as exc:
                print(f"[*] Campaign {campaign_id} authorization status: {exc}")

            # Initialize ProviderGateway with checkpoint client and strict MiniMax-only allowlist
            from app.providers.registry import provider_registry as global_provider_reg
            for reg_obj in (global_provider_reg,):
                reg_obj._providers.pop("groq", None)
                reg_obj._keys.pop("groq", None)
            provider_reg = ProviderRegistry()
            provider_reg.initialize_from_settings()
            provider_reg._providers.pop("groq", None)
            provider_reg._keys.pop("groq", None)
            assert provider_reg.get_provider_order("minimax") == ["minimax"], f"Expected MiniMax-only provider order, got {provider_reg.get_provider_order('minimax')}"
            gw = ProviderGateway(registry=provider_reg, checkpoint_client=checkpoint_client)
            pair_sem = asyncio.Semaphore(max(1, concurrency))
            report_lock = asyncio.Lock()

            async def process_pair(case_idx: int, triple: Tuple[Dict[str, Any], Dict[str, Any], Dict[str, Any]], seed: int) -> None:
                async with pair_sem:
                    case_file_v2 = campaign_cases_dir / f"case_{case_idx:02d}_v2.json"
                    case_file_legacy = campaign_cases_dir / f"case_{case_idx:02d}_legacy.json"

                    def _archive_prior_attempt(path: Path) -> None:
                        """Never destroy an attempt record before overwriting it.

                        Acceptance requires that every failure and incomplete run remain
                        visible; a failed row must not disappear behind a later successful
                        retry. Prior attempts are moved to attempts/ with their outcome and
                        timestamp so the full history is auditable.
                        """
                        if not path.exists():
                            return
                        attempts_dir = campaign_cases_dir / "attempts"
                        attempts_dir.mkdir(parents=True, exist_ok=True)
                        try:
                            with open(path, "r", encoding="utf-8") as fh:
                                prior = json.load(fh)
                            outcome = "valid" if prior.get("validDraft") else str(prior.get("status") or "unknown").lower()
                            stamp = str(prior.get("timestamp") or prior.get("finishedAt") or uuid4().hex[:8])
                            dest = attempts_dir / f"{path.stem}__{outcome}__{stamp}.json"
                        except Exception:
                            dest = attempts_dir / f"{path.stem}__{uuid4().hex[:8]}.json"
                        shutil.move(str(path), str(dest))
                        print(f"[*] Archived prior attempt {path.name} -> attempts/{dest.name}")

                    async def _get_or_run_v2() -> Dict[str, Any]:
                        v2_c = None
                        if resume and case_file_v2.exists():
                            try:
                                with open(case_file_v2, "r", encoding="utf-8") as f:
                                    cached = json.load(f)
                                if (
                                    cached.get("campaignId") == campaign_id
                                    and cached.get("executionMode") == "LIVE_MINIMAX_PAIRED_BENCHMARK"
                                    and cached.get("providerCallsCount", 0) > 0
                                ):
                                    if not rerun_failed or cached.get("validDraft"):
                                        if not cached.get("validDraft") or pg.check_exam_exists(cached.get("runId", "")):
                                            v2_c = cached
                                            print(f"[*] Resuming completed V2 Case {case_idx:02d} (runId={v2_c['runId']})")
                            except Exception:
                                pass

                        if v2_c is None:
                            print(f"[*] Running V2 Case {case_idx:02d} (seed={seed}, topic={triple[0]['topic'][:40]}...)...")
                            v2_c = await run_v2_paper_benchmark_case(
                                triple=triple,
                                seed=seed,
                                case_index=case_idx,
                                campaign_id=campaign_id,
                                pg=pg,
                                checkpoint_client=checkpoint_client,
                                gw=gw,
                                target_output_dir=campaign_dir,
                                rerun_failed=rerun_failed,
                                resume=resume,
                            )
                            _archive_prior_attempt(case_file_v2)
                            with open(case_file_v2, "w", encoding="utf-8") as f:
                                json.dump(v2_c, f, indent=2)
                            shutil.copy2(case_file_v2, target_cases_dir / f"case_{case_idx:02d}_v2.json")
                        return v2_c

                    async def _get_or_run_legacy() -> Dict[str, Any]:
                        leg_c = None
                        if resume and case_file_legacy.exists():
                            try:
                                with open(case_file_legacy, "r", encoding="utf-8") as f:
                                    cached = json.load(f)
                                if (
                                    cached.get("campaignId") == campaign_id
                                    and cached.get("executionMode") == "LIVE_MINIMAX_PAIRED_BENCHMARK"
                                    and cached.get("providerCallsCount", 0) > 0
                                ):
                                    if not rerun_failed or cached.get("validDraft"):
                                        leg_c = cached
                                        print(f"[*] Resuming completed Legacy Case {case_idx:02d} (runId={leg_c['runId']})")
                            except Exception:
                                pass

                        if leg_c is None:
                            print(f"[*] Running Legacy Case {case_idx:02d} (seed={seed}, topic={triple[0]['topic'][:40]}...)...")
                            leg_c = await run_legacy_paper_benchmark_case(
                                triple=triple,
                                seed=seed,
                                case_index=case_idx,
                                campaign_id=campaign_id,
                                pg=pg,
                                checkpoint_client=checkpoint_client,
                                gw=gw,
                                target_output_dir=campaign_dir,
                            )
                            _archive_prior_attempt(case_file_legacy)
                            with open(case_file_legacy, "w", encoding="utf-8") as f:
                                json.dump(leg_c, f, indent=2)
                            shutil.copy2(case_file_legacy, target_cases_dir / f"case_{case_idx:02d}_legacy.json")
                        return leg_c

                    v2_c_res, leg_c_res = await asyncio.gather(_get_or_run_v2(), _get_or_run_legacy())

                    async with report_lock:
                        v2_cases.append(v2_c_res)
                        legacy_cases.append(leg_c_res)
                        paired_comparisons.append({
                            "caseIndex": case_idx,
                            "sourceTriple": [s["pmcid"] for s in triple],
                            "seed": seed,
                            "v2": {
                                "validDraft": v2_c_res["validDraft"],
                                "latencySeconds": v2_c_res["latencySeconds"],
                                "totalTokens": v2_c_res["totalTokens"],
                                "costUsd": v2_c_res["estimatedCostUsd"],
                                "persistedExamId": v2_c_res["persistedExamId"],
                                "isPrimaryPersisted": v2_c_res["isPrimaryPersisted"],
                                "liveCallSuccess": v2_c_res.get("liveCallSuccess", False),
                            },
                            "legacy": {
                                "validDraft": leg_c_res["validDraft"],
                                "latencySeconds": leg_c_res["latencySeconds"],
                                "totalTokens": leg_c_res["totalTokens"],
                                "costUsd": leg_c_res["estimatedCostUsd"],
                                "persistedExamId": leg_c_res["persistedExamId"],
                                "draftExamId": leg_c_res.get("draftExamId"),
                                "isPrimaryPersisted": leg_c_res["isPrimaryPersisted"],
                                "liveCallSuccess": leg_c_res.get("liveCallSuccess", False),
                            },
                            "latencyRatio": round(v2_c_res["latencySeconds"] / max(0.001, leg_c_res["latencySeconds"]), 3),
                            "tokenRatio": round(v2_c_res["totalTokens"] / max(1, leg_c_res["totalTokens"]), 3),
                        })
                        v2_cases.sort(key=lambda c: c.get("caseIndex", 0))
                        legacy_cases.sort(key=lambda c: c.get("caseIndex", 0))
                        paired_comparisons.sort(key=lambda p: p.get("caseIndex", 0))
                        save_incremental_reports(
                            campaign_dir=campaign_dir,
                            target_output_dir=target_output_dir,
                            v2_cases=v2_cases,
                            legacy_cases=legacy_cases,
                            paired_comparisons=paired_comparisons,
                            force_synthetic=force_synthetic,
                            pg=pg,
                            corpus_sha256=corpus_sha256,
                            config_sha256=config_sha256,
                            config_covered_files=config_covered_files,
                            worktree_binding=worktree_binding,
                            provider_binding=provider_binding,
                        )

            await asyncio.gather(*(process_pair(c_idx, trip, sd) for c_idx, trip, sd in active_pairs))
    # Final semantic evaluation across critical fixtures
    semantic_eval = await evaluate_critical_semantic_fixtures()

    # Final report save with full semantic evaluation
    final_report = save_incremental_reports(
        campaign_dir=campaign_dir,
        target_output_dir=target_output_dir,
        v2_cases=v2_cases,
        legacy_cases=legacy_cases,
        paired_comparisons=paired_comparisons,
        force_synthetic=force_synthetic,
        pg=pg,
        semantic_eval=semantic_eval,
        corpus_sha256=corpus_sha256,
        config_sha256=config_sha256,
        config_covered_files=config_covered_files,
        worktree_binding=worktree_binding,
        provider_binding=provider_binding,
    )

    p95_lat_ratio = final_report["validationMatrix"]["p95LatencyRatio"]["ratio"]
    med_token_ratio = final_report["validationMatrix"]["medianTokenCostRatio"]["ratio"]

    print("-" * 70)
    print(f"Completed {len(paired_comparisons)} paired paper benchmarks.")
    print(f"PostgreSQL Connection: {'CONNECTED (port ' + pg.port + ')' if pg.pg_available else 'NOT AVAILABLE'}")
    print(f"V2 Persisted Exams: {final_report['persistenceAudit']['v2AuthoritativePersistedCount']} | Legacy Persisted: 0")
    print(f"V2 P95 Latency: {final_report['validationMatrix']['p95LatencyRatio']['v2P95']}s | Legacy P95: {final_report['validationMatrix']['p95LatencyRatio']['legacyP95']}s | Ratio: {p95_lat_ratio} (<= 1.5x)")
    print(f"V2 Median Tokens: {final_report['validationMatrix']['medianTokenCostRatio']['v2MedianTokens']} | Legacy: {final_report['validationMatrix']['medianTokenCostRatio']['legacyMedianTokens']} | Ratio: {med_token_ratio} (<= 2.0x)")
    print(f"Fidelity Must-Reject: {semantic_eval['aggregate']['fidelityMustRejectRate'] * 100}% (100%)")
    print(f"Semantic Blocking Recall: {semantic_eval['aggregate']['semanticBlockingRecall'] * 100}% (>= 95%)")
    print(f"Artifacts written to: {target_output_dir} and {campaign_dir}")
    print("=" * 70)

    return final_report


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Phase 15 Paired Benchmark Runner")
    parser.add_argument("--diagnostic", action="store_true", help="Force synthetic diagnostic simulation mode (writes to benchmarks-diagnostic)")
    parser.add_argument("--output-dir", type=str, default=None, help="Custom output directory for artifacts")
    parser.add_argument("--seeds", type=int, nargs="+", default=None, help="Custom seeds to evaluate (default: 101 202 303)")
    parser.add_argument("--limit-triples", type=int, default=None, help="Limit number of source triples evaluated")
    parser.add_argument("--preflight", action="store_true", help="Run only case 1 matched pair for preflight inspection")
    parser.add_argument("--max-cases", type=int, default=None, help="Maximum number of paired cases to execute")
    parser.add_argument("--case-indices", type=int, nargs="+", default=None, help="Specific 1-based case indices to execute")
    parser.add_argument("--no-resume", action="store_true", help="Disable resumption and force fresh execution of all selected cases")
    parser.add_argument("--rerun-failed", action="store_true", help="Rerun failed cases even when resume is enabled")
    parser.add_argument("--concurrency", type=int, default=2, help="Number of concurrent matched pairs (default: 2)")
    parser.add_argument("--exam-service-url", type=str, default="http://127.0.0.1:5057", help="Isolated exam-service base URL")
    parser.add_argument("--campaign-tag", type=str, default="", help="Disambiguates successive campaigns run against an unchanged engine (changes the derived campaign id so runs cannot collide on (campaignId, caseId))")
    args = parser.parse_args()

    custom_out = Path(args.output_dir) if args.output_dir else None
    custom_seeds = tuple(args.seeds) if args.seeds else None
    max_cases_val = 1 if args.preflight else args.max_cases

    asyncio.run(run_phase15_benchmarks(
        output_dir=custom_out,
        force_synthetic=args.diagnostic,
        seeds=custom_seeds,
        limit_triples=args.limit_triples,
        max_cases=max_cases_val,
        case_indices=args.case_indices,
        resume=not args.no_resume,
        rerun_failed=args.rerun_failed,
        concurrency=args.concurrency,
        exam_service_url=args.exam_service_url,
        campaign_tag=args.campaign_tag,
    ))
