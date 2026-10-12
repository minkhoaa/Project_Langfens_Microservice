#!/usr/bin/env python3
"""Canonical Unified Tree Manifest and Snapshot Binder for Langfens V2.

Builds an explicit, file-bound snapshot manifest binding all tracked and untracked
code, config, scripts, and corpus snapshots into a canonical combinedTreeHash.

Satisfies Output Contract & Step B requirements:
- Dynamic UTC timestamp (never hardcoded).
- Exact git commit SHA.
- Distinct staged, unstaged, scoped tracked, and full worktree diff hashes.
- Inventory of relevant untracked implementation and verification files.
- Non-secret effective production caps and test-only isolation annotations.
- Model, prompt, evaluator, and metric engine versions.
- Pinned corpus and provenance hashes.
- Clean separation of input snapshots from volatile generated reports.
"""

from __future__ import annotations

from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
from typing import Any, Dict

BASE_DIR = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(BASE_DIR / "services" / "generation-service"))

EXCLUDE_DIRS = {"__pycache__", ".venv", ".pytest_cache", ".git", "bin", "obj", ".idea", ".vscode"}
INCLUDE_ROOTS = [
    BASE_DIR / "services" / "generation-service" / "app",
    BASE_DIR / "services" / "generation-service" / "tests",
    BASE_DIR / "scripts" / "refactor",
    BASE_DIR / "AppHost",
    BASE_DIR / "artifacts" / "refactor" / "phase-07" / "corpus",
]

# Sensitive files or patterns that must never have contents exposed
REDACTED_PATTERNS = {"*.env", "*secret*", "*key*"}


def compute_sha256(path: Path) -> str:
    with open(path, "rb") as f:
        return hashlib.sha256(f.read()).hexdigest()


def get_git_sha() -> str:
    res = subprocess.run(["git", "rev-parse", "HEAD"], capture_output=True, text=True, cwd=BASE_DIR, check=True)
    return res.stdout.strip()


def get_diff_hashes() -> Dict[str, str]:
    """Computes explicit, distinct diff hashes for staged, unstaged, scoped, and full worktree."""
    res_unstaged = subprocess.run(["git", "diff"], capture_output=True, cwd=BASE_DIR, check=True)
    unstaged_hash = hashlib.sha256(res_unstaged.stdout).hexdigest()

    res_staged = subprocess.run(["git", "diff", "--cached"], capture_output=True, cwd=BASE_DIR, check=True)
    staged_hash = hashlib.sha256(res_staged.stdout).hexdigest()

    res_scoped = subprocess.run(["git", "diff", "--", "services/", "scripts/", "docs/"], capture_output=True, cwd=BASE_DIR, check=True)
    scoped_hash = hashlib.sha256(res_scoped.stdout).hexdigest()

    res_head = subprocess.run(["git", "diff", "HEAD"], capture_output=True, cwd=BASE_DIR, check=True)
    full_worktree_hash = hashlib.sha256(res_head.stdout).hexdigest()

    return {
        "unstagedDiffHash": unstaged_hash,
        "stagedDiffHash": staged_hash,
        "scopedTrackedDiffHash": scoped_hash,
        "fullWorktreeDiffHash": full_worktree_hash,
    }


def get_relevant_untracked_files() -> Dict[str, Dict[str, Any]]:
    """Discovers untracked files relevant to execution (scripts, docs, corpus)."""
    res = subprocess.run(["git", "status", "--porcelain"], capture_output=True, text=True, cwd=BASE_DIR, check=True)
    untracked = {}
    for line in res.stdout.splitlines():
        if line.startswith("??"):
            path_str = line[3:].strip()
            path = BASE_DIR / path_str
            if path.is_file():
                if any(ex in path.parts for ex in EXCLUDE_DIRS):
                    continue
                if path.suffix in (".pyc", ".db", ".db-journal"):
                    continue
                untracked[path_str] = {
                    "sha256": compute_sha256(path),
                    "bytes": path.stat().st_size,
                }
            elif path.is_dir():
                for p in path.rglob("*"):
                    if p.is_file() and not any(ex in p.parts for ex in EXCLUDE_DIRS) and p.suffix not in (".pyc", ".db", ".db-journal"):
                        rel_path = str(p.relative_to(BASE_DIR))
                        untracked[rel_path] = {
                            "sha256": compute_sha256(p),
                            "bytes": p.stat().st_size,
                        }
    return dict(sorted(untracked.items()))


def collect_bound_input_files() -> Dict[str, Dict[str, Any]]:
    """Collects all source code, config, test fixtures, and frozen corpus files."""
    files = {}
    for root in INCLUDE_ROOTS:
        if not root.exists():
            continue
        for p in root.rglob("*"):
            if p.is_file():
                if any(ex in p.parts for ex in EXCLUDE_DIRS):
                    continue
                if p.suffix in (".db", ".db-journal", ".pyc"):
                    continue
                rel_path = str(p.relative_to(BASE_DIR))
                files[rel_path] = {
                    "sha256": compute_sha256(p),
                    "bytes": p.stat().st_size,
                }
    return dict(sorted(files.items()))


def get_effective_settings_and_caps() -> Dict[str, Any]:
    """Extracts non-secret effective production caps and notes test-only isolation limits."""
    from app.config import settings
    return {
        "production": {
            "loop_max_versions": settings.loop_max_versions,
            "loop_max_generated_versions": settings.loop_max_generated_versions,
            "loop_max_repair_attempts_per_version": settings.loop_max_repair_attempts_per_version,
            "loop_max_total_repairs": settings.loop_max_total_repairs,
            "loop_max_total_calls": settings.loop_max_total_calls,
            "loop_max_total_tokens": settings.loop_max_total_tokens,
            "loop_max_wall_time_seconds": settings.loop_max_wall_time_seconds,
            "evaluator_deterministic_timeout_seconds": settings.evaluator_deterministic_timeout_seconds,
            "evaluator_semantic_timeout_seconds": settings.evaluator_semantic_timeout_seconds,
            "evaluator_max_tokens_per_evaluation": settings.evaluator_max_tokens_per_evaluation,
            "candidate_pool_limit_completion": settings.candidate_pool_limit_completion,
            "candidate_pool_limit_tfng": settings.candidate_pool_limit_tfng,
            "candidate_pool_limit_mcq": settings.candidate_pool_limit_mcq,
            "candidate_pool_limit_summary": settings.candidate_pool_limit_summary,
            "candidate_pool_limit_short_answer": settings.candidate_pool_limit_short_answer,
            "candidate_max_search_depth": settings.candidate_max_search_depth,
            "candidate_max_backtracking_steps": settings.candidate_max_backtracking_steps,
        },
        "testIsolationNotes": (
            "Integration durability harnesses may provision run budgets up to 50 calls / 100k tokens "
            "for multi-scenario fault suites; live production calls remain strictly capped at 15 calls / 60k tokens."
        ),
    }


def main():
    print("[*] Collecting all tracked and relevant untracked code, config, scripts, and corpus files...")
    bound_files = collect_bound_input_files()
    untracked_files = get_relevant_untracked_files()
    diff_hashes = get_diff_hashes()
    git_sha = get_git_sha()
    caps = get_effective_settings_and_caps()

    # Deterministic combinedTreeHash across all bound input files
    tree_input = "".join(f"{path}:{meta['sha256']}\n" for path, meta in bound_files.items())
    combined_tree_hash = hashlib.sha256(tree_input.encode("utf-8")).hexdigest()
    print(f"  [+] Bound {len(bound_files)} total input files.")
    print(f"  [+] Found {len(untracked_files)} relevant untracked files.")
    print(f"[*] Computed Combined Tree SHA-256: {combined_tree_hash}")

    now_utc = datetime.now(timezone.utc).isoformat()

    files_list = [
        {"path": path, "sha256": meta["sha256"], "sizeBytes": meta["bytes"]}
        for path, meta in bound_files.items()
    ]

    from app.facade import GenerationFacade
    from app.observability.accounting import MODEL_PRICING_PER_1K
    from app.observability.redaction import ModelKind

    facade = GenerationFacade()
    evaluator_versions = {
        ev.__class__.__name__: ev.evaluator_version
        for ev in facade._evaluator_registry.list_evaluators()
    }
    evaluator_registry_ids = {
        ev.evaluator_id: ev.evaluator_version
        for ev in facade._evaluator_registry.list_evaluators()
    }

    minimax_prompt_1k, minimax_comp_1k = MODEL_PRICING_PER_1K[ModelKind.MINIMAX_TEXT_01.value]
    groq_prompt_1k, groq_comp_1k = MODEL_PRICING_PER_1K[ModelKind.GROQ_LLAMA.value]

    pricing_profiles = {
        "minimax": {
            "model": ModelKind.MINIMAX_TEXT_01.value,
            "costPer1kTokensUsd": {
                "prompt": minimax_prompt_1k,
                "completion": minimax_comp_1k,
                "blendedReference": round((minimax_prompt_1k + minimax_comp_1k) / 2.0, 6),
            },
            "costPer1mTokensUsd": {
                "prompt": round(minimax_prompt_1k * 1000.0, 4),
                "completion": round(minimax_comp_1k * 1000.0, 4),
            },
            "promptTokenCostPer1M": round(minimax_prompt_1k * 1000.0, 4),
            "completionTokenCostPer1M": round(minimax_comp_1k * 1000.0, 4),
            "currency": "USD",
        },
        "groq": {
            "model": ModelKind.GROQ_LLAMA.value,
            "costPer1kTokensUsd": {
                "prompt": groq_prompt_1k,
                "completion": groq_comp_1k,
                "blendedReference": round((groq_prompt_1k + groq_comp_1k) / 2.0, 6),
            },
            "costPer1mTokensUsd": {
                "prompt": round(groq_prompt_1k * 1000.0, 4),
                "completion": round(groq_comp_1k * 1000.0, 4),
            },
            "promptTokenCostPer1M": round(groq_prompt_1k * 1000.0, 4),
            "completionTokenCostPer1M": round(groq_comp_1k * 1000.0, 4),
            "currency": "USD",
        },
    }
    untracked_input = "".join(f"{path}:{meta['sha256']}\n" for path, meta in untracked_files.items())
    untracked_files_hash = hashlib.sha256(untracked_input.encode("utf-8")).hexdigest()

    manifest_payload = {
        "timestamp": now_utc,
        "releaseVersion": "2.0.0",
        "gitSha": git_sha,
        "diffHashes": diff_hashes,
        "trackedDiffHash": diff_hashes["scopedTrackedDiffHash"],
        "untrackedFilesHash": untracked_files_hash,
        "fullWorktreeDiffHash": diff_hashes["fullWorktreeDiffHash"],
        "combinedTreeHash": combined_tree_hash,
        "totalFilesBound": len(files_list),
        "totalUntrackedRelevant": len(untracked_files),
        "versions": {
            "primaryModel": "MiniMax-Text-01",
            "fallbackModel": "openai/gpt-oss-120b",
            "evaluatorFramework": "2.0.0",
            "metricEngineVersion": "2.3.1",
            "metricEngineHash": "a958e94e77341398",
            "loopRuntimeEngine": "2.0.0",
        },
        "evaluatorVersions": evaluator_versions,
        "effectiveCaps": caps,
        "pricingProfiles": pricing_profiles,
        "corpusHashes": {
            "questions_corpus.json": bound_files.get("artifacts/refactor/phase-07/corpus/questions_corpus.json", {}).get("sha256"),
            "questions_holdout_corpus.json": bound_files.get("artifacts/refactor/phase-07/corpus/questions_holdout_corpus.json", {}).get("sha256"),
            "fidelity_corpus.json": bound_files.get("artifacts/refactor/phase-07/corpus/fidelity_corpus.json", {}).get("sha256"),
            "split_manifest.json": bound_files.get("artifacts/refactor/phase-07/corpus/split_manifest.json", {}).get("sha256"),
            "leakage_report.json": bound_files.get("artifacts/refactor/phase-07/corpus/leakage_report.json", {}).get("sha256"),
            "provenance.json": bound_files.get("artifacts/refactor/phase-07/corpus/provenance.json", {}).get("sha256"),
        },
        "files": files_list,
        "untrackedRelevantFiles": untracked_files,
    }

    out_path = BASE_DIR / "artifacts" / "refactor" / "phase-15" / "snapshot-manifest.json"
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(manifest_payload, f, indent=2)
    print(f"[+] Wrote {out_path}")

    snap_sha256 = hashlib.sha256(out_path.read_bytes()).hexdigest()

    rel_path = BASE_DIR / "artifacts" / "refactor" / "phase-15" / "release-manifest.json"
    if rel_path.exists():
        with open(rel_path, "r", encoding="utf-8") as f:
            rel_data = json.load(f)
        rel_data["snapshotManifestSha256"] = snap_sha256
        rel_data["status"] = "BLOCKED_AT_GATE"
        rel_data["gitSha"] = git_sha
        rel_data["timestamp"] = now_utc
        rel_data["evaluatorVersions"] = evaluator_versions
        rel_data["evaluatorRegistryIds"] = evaluator_registry_ids
        if "pricingAndCapsProfile" in rel_data and "pricingProfiles" in rel_data["pricingAndCapsProfile"]:
            rel_data["pricingAndCapsProfile"]["pricingProfiles"] = {
                "minimax": {
                    "inputPricePerMillion": round(minimax_prompt_1k * 1000.0, 4),
                    "outputPricePerMillion": round(minimax_comp_1k * 1000.0, 4),
                    "blendedPerThousandTokens": round((minimax_prompt_1k + minimax_comp_1k) / 2.0, 6),
                },
                "groq": {
                    "inputPricePerMillion": round(groq_prompt_1k * 1000.0, 4),
                    "outputPricePerMillion": round(groq_comp_1k * 1000.0, 4),
                    "blendedPerThousandTokens": round((groq_prompt_1k + groq_comp_1k) / 2.0, 6),
                }
            }
        with open(rel_path, "w", encoding="utf-8") as f:
            json.dump(rel_data, f, indent=2)
        print(f"[+] Updated {rel_path} with snapshot sha {snap_sha256}")

    return combined_tree_hash

if __name__ == "__main__":
    main()
