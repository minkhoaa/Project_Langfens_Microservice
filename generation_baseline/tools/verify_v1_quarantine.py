#!/usr/bin/env python3
"""Verification tool for V1 Quarantine Manifest and historical file immutability."""

import json
import hashlib
import subprocess
import sys
from pathlib import Path


def get_file_sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def verify_quarantine_manifest(base_dir: Path) -> bool:
    manifest_path = base_dir / "generation_baseline" / "verification" / "V1_QUARANTINE_MANIFEST.json"
    if not manifest_path.exists():
        print(f"FAIL: Quarantine manifest not found at {manifest_path}")
        return False

    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except Exception as exc:
        print(f"FAIL: Manifest is not valid JSON: {exc}")
        return False

    if manifest.get("quarantine_status") != "QUARANTINED_PROVENANCE_DEFECT":
        print(f"FAIL: Unexpected quarantine status: {manifest.get('quarantine_status')}")
        return False

    defects = manifest.get("defect_registry", {})
    expected_defects = ["DEF-DAT-01", "DEF-DAT-02", "DEF-DAT-03", "DEF-DAT-04", "DEF-DAT-05", "DEF-DAT-06"]
    for d_id in expected_defects:
        if d_id not in defects:
            print(f"FAIL: Missing defect record: {d_id}")
            return False

    inventories = manifest.get("inventories", {})
    all_files = []
    all_files.extend(inventories.get("source_code", []))
    all_files.extend(inventories.get("fixtures", []))
    all_files.extend(inventories.get("manifests_and_evaluations", []))
    all_files.extend(inventories.get("audit_reports", []))
    all_files.extend(inventories.get("execution_ledgers_and_state", []))
    all_files.extend(inventories.get("batch_states", {}).get("files", []))
    all_files.extend(inventories.get("raw_responses", {}).get("files", []))
    all_files.extend(inventories.get("smoke_test", {}).get("files", []))

    if len(all_files) != 594:
        print(f"FAIL: Expected 594 files in inventory, found {len(all_files)}")
        return False

    mismatches = []
    missing = []
    tracked_mismatches = []

    for entry in all_files:
        rel_path = entry["relative_path"]
        p = base_dir / rel_path
        if not p.exists():
            missing.append(rel_path)
            continue

        actual_hash = get_file_sha256(p)
        if actual_hash != entry["sha256"]:
            mismatches.append((rel_path, entry["sha256"], actual_hash))

        res = subprocess.run(["git", "ls-files", "--error-unmatch", rel_path],
                             cwd=str(base_dir), capture_output=True, text=True)
        is_tracked = (res.returncode == 0)
        if is_tracked != entry.get("git_tracked"):
            tracked_mismatches.append((rel_path, entry.get("git_tracked"), is_tracked))

    if missing:
        print(f"FAIL: Missing files: {missing}")
        return False

    if mismatches:
        print(f"FAIL: Historical file mutations detected: {mismatches}")
        return False

    if tracked_mismatches:
        print(f"FAIL: Git tracking discrepancies: {tracked_mismatches}")
        return False

    # Check RQ2_V2 version artifact
    v2_version = base_dir / "generation_baseline" / ".execution" / "RQ2_V2" / "EXPERIMENT_VERSION.json"
    if not v2_version.exists():
        print(f"FAIL: RQ2_V2 version artifact not found at {v2_version}")
        return False

    v2_data = json.loads(v2_version.read_text(encoding="utf-8"))
    if v2_data.get("campaign_id") != "RQ2_V2" or v2_data.get("status") != "INITIALIZED_V1_QUARANTINED":
        print(f"FAIL: Invalid RQ2_V2 version data: {v2_data}")
        return False

    print(f"PASS: V1 Quarantine Manifest verified intact ({len(all_files)} files checked, 0 mutations).")
    return True


if __name__ == "__main__":
    base_dir = Path(__file__).resolve().parent.parent.parent
    success = verify_quarantine_manifest(base_dir)
    sys.exit(0 if success else 1)
