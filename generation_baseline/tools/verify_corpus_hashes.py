#!/usr/bin/env python3
"""CLI utility to verify and compute SHA-256 digests for curated corpus submissions.

Usage:
    python3 generation_baseline/tools/verify_corpus_hashes.py [--holdout-dir PATH] [--manifest PATH]
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
from pathlib import Path
from typing import Any, Dict, Optional, Tuple


def canonicalize_and_hash(file_path: Path) -> Tuple[str, int]:
    """Computes canonical SHA-256 hex digest and byte size of a JSON artifact.

    Deterministic serialization: UTF-8, sorted keys, compact separators (',', ':'),
    ensure_ascii=False.
    """
    with open(file_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    canonical_bytes = json.dumps(data, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8")
    sha256 = hashlib.sha256(canonical_bytes).hexdigest()
    return sha256, len(canonical_bytes)


def verify_holdout_submission(
    holdout_dir: Path,
    manifest_path: Optional[Path] = None,
) -> Dict[str, Any]:
    """Audits holdout submission files, computing hashes or reporting pending curation."""
    reading_path = holdout_dir / "reading_corpus.json"
    grammar_path = holdout_dir / "grammar_rule_packs.json"
    metadata_path = holdout_dir / "item_metadata.json"

    results: Dict[str, Any] = {
        "holdout_dir": str(holdout_dir),
        "reading_corpus_exists": reading_path.exists(),
        "grammar_rule_packs_exists": grammar_path.exists(),
        "item_metadata_exists": metadata_path.exists(),
        "reading_sha256": None,
        "grammar_sha256": None,
        "metadata_sha256": None,
        "status": "PENDING_EXTERNAL_CURATION",
    }

    if not reading_path.exists() or not grammar_path.exists():
        print(f"[STATUS] Holdout directory '{holdout_dir}' has pending external curation files.")
        if not reading_path.exists():
            print(f"  - Missing: {reading_path}")
        if not grammar_path.exists():
            print(f"  - Missing: {grammar_path}")
        return results

    r_hash, r_bytes = canonicalize_and_hash(reading_path)
    g_hash, g_bytes = canonicalize_and_hash(grammar_path)
    results["reading_sha256"] = r_hash
    results["grammar_sha256"] = g_hash
    results["reading_bytes"] = r_bytes
    results["grammar_bytes"] = g_bytes

    if metadata_path.exists():
        m_hash, m_bytes = canonicalize_and_hash(metadata_path)
        results["metadata_sha256"] = m_hash
        results["metadata_bytes"] = m_bytes

    results["status"] = "HASHED_READY_FOR_SEALING_VERIFICATION"
    print(f"[SUCCESS] Computed canonical SHA-256 hashes:")
    print(f"  Reading Corpus  : {r_hash} ({r_bytes} bytes)")
    print(f"  Grammar Packs   : {g_hash} ({g_bytes} bytes)")
    if results["metadata_sha256"]:
        print(f"  Item Metadata   : {results['metadata_sha256']} ({results['metadata_bytes']} bytes)")

    if manifest_path and manifest_path.exists():
        with open(manifest_path, "r", encoding="utf-8") as f:
            manifest = json.load(f)
        seals = manifest.get("cryptographic_seals", {})
        m_r_hash = seals.get("reading_corpus_sha256")
        m_g_hash = seals.get("grammar_rule_packs_sha256")
        if m_r_hash is None or m_g_hash is None:
            print(f"[MANIFEST] Manifest {manifest_path} contains uncomputed null seals (status: {seals.get('status')}).")
        else:
            match_r = (m_r_hash == r_hash)
            match_g = (m_g_hash == g_hash)
            results["manifest_matches"] = match_r and match_g
            print(f"[MANIFEST VERIFICATION] Reading match: {match_r}, Grammar match: {match_g}")

    return results


def main() -> int:
    parser = argparse.ArgumentParser(description="Verify SHA-256 hashes of curated holdout corpus.")
    parser.add_argument(
        "--holdout-dir",
        type=Path,
        default=Path("generation_baseline/holdout"),
        help="Directory containing curated holdout JSON files.",
    )
    parser.add_argument(
        "--manifest",
        type=Path,
        default=Path("generation_baseline/research/CONFIRMATORY_HOLDOUT_MANIFEST.json"),
        help="Path to confirmatory holdout manifest.",
    )
    args = parser.parse_args()

    results = verify_holdout_submission(args.holdout_dir, args.manifest)
    print(json.dumps(results, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
