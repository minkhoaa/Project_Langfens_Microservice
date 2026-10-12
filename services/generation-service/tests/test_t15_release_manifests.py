"""Phase 15 Release Manifests Test Suite (T15-01 / P15-01).

Validates:
1. Snapshot manifest completeness, top-level schemas, and file bindings.
2. Release manifest completeness and binding to snapshot manifest digest.
3. Cryptographic hash bindings for all tracked python source files.
4. Zero missing, null, or empty hashes across all tracked artifacts.
5. Version immutability (releaseVersion == "2.0.0").
6. Effective caps and pricing profiles presence and completeness.
"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent.parent.parent
MANIFEST_DIR = REPO_ROOT / "artifacts" / "refactor" / "phase-15"
SNAPSHOT_MANIFEST_PATH = MANIFEST_DIR / "snapshot-manifest.json"
RELEASE_MANIFEST_PATH = MANIFEST_DIR / "release-manifest.json"


def test_t15_01_manifest_files_exist():
    """T15-01: Both snapshot-manifest.json and release-manifest.json exist."""
    assert SNAPSHOT_MANIFEST_PATH.exists(), f"Missing {SNAPSHOT_MANIFEST_PATH}"
    assert RELEASE_MANIFEST_PATH.exists(), f"Missing {RELEASE_MANIFEST_PATH}"


def test_t15_01_snapshot_manifest_structure_and_completeness():
    """T15-01: snapshot-manifest.json contains all required schema keys."""
    with open(SNAPSHOT_MANIFEST_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    required_keys = [
        "timestamp",
        "releaseVersion",
        "gitSha",
        "diffHashes",
        "trackedDiffHash",
        "untrackedFilesHash",
        "combinedTreeHash",
        "totalFilesBound",
        "versions",
        "evaluatorVersions",
        "effectiveCaps",
        "pricingProfiles",
        "files",
    ]
    for key in required_keys:
        assert key in data, f"snapshot-manifest.json missing required key: '{key}'"

    assert data["totalFilesBound"] > 0
    assert len(data["files"]) == data["totalFilesBound"]
    assert data["releaseVersion"] == "2.0.0"


def test_t15_01_release_manifest_structure_and_hash_binding():
    """T15-01: release-manifest.json contains required keys and valid snapshot manifest hash."""
    with open(RELEASE_MANIFEST_PATH, "r", encoding="utf-8") as f:
        rel_data = json.load(f)

    required_keys = [
        "releaseVersion",
        "releaseName",
        "phase",
        "timestamp",
        "gitSha",
        "snapshotManifestSha256",
        "benchmarkReportSha256",
        "status",
        "validationMatrixThresholds",
        "gatePreconditions",
        "evaluatorVersions",
        "pricingAndCapsProfile",
    ]
    for key in required_keys:
        assert key in rel_data, f"release-manifest.json missing required key: '{key}'"

    # Verify snapshot manifest sha256 binding
    expected_snap_hash = hashlib.sha256(SNAPSHOT_MANIFEST_PATH.read_bytes()).hexdigest()
    assert rel_data["snapshotManifestSha256"] == expected_snap_hash, "Snapshot manifest hash mismatch in release-manifest"
    assert rel_data["releaseVersion"] == "2.0.0"
    assert rel_data["status"] in ("PROMOTED_TO_RELEASE", "BLOCKED_AT_GATE")


def test_t15_01_zero_missing_hashes_and_valid_digests():
    """T15-01: Every tracked file in snapshot-manifest has a non-empty 64-char hex sha256."""
    with open(SNAPSHOT_MANIFEST_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    for item in data["files"]:
        path = item.get("path")
        sha = item.get("sha256")
        size = item.get("sizeBytes")

        assert path, "File entry missing path"
        assert sha and len(sha) == 64, f"File {path} has invalid sha256: '{sha}'"
        assert isinstance(size, int) and size >= 0, f"File {path} has invalid sizeBytes: {size}"

        # Verify on-disk hash match if file exists
        full_path = REPO_ROOT / path
        if full_path.exists():
            computed = hashlib.sha256(full_path.read_bytes()).hexdigest()
            assert computed == sha, f"Cryptographic digest mismatch for {path}: expected {sha}, got {computed}"


def test_t15_01_evaluator_versions_immutability():
    """T15-01: Evaluator versions are declared and non-empty in release manifest."""
    with open(RELEASE_MANIFEST_PATH, "r", encoding="utf-8") as f:
        rel_data = json.load(f)

    eval_vers = rel_data.get("evaluatorVersions", {})
    assert len(eval_vers) >= 8, "Expected at least 8 registered evaluators"
    for name, ver in eval_vers.items():
        assert ver and isinstance(ver, str), f"Invalid version for evaluator '{name}': {ver}"


def test_t15_01_effective_caps_and_pricing_profiles():
    """T15-01: Production caps match ADR-001/002/004 specification."""
    with open(SNAPSHOT_MANIFEST_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    prod_caps = data["effectiveCaps"]["production"]
    assert prod_caps["loop_max_total_tokens"] == 60000
    assert prod_caps["loop_max_total_calls"] == 15
    assert prod_caps["loop_max_wall_time_seconds"] == 300.0
    assert prod_caps["evaluator_deterministic_timeout_seconds"] == 5.0
    assert prod_caps["evaluator_semantic_timeout_seconds"] == 30.0

    pricing = data["pricingProfiles"]
    assert "minimax" in pricing
    assert "groq" in pricing
