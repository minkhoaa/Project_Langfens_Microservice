"""One-off introspection: count writing_samples by band_overall.

Reads QDRANT_ENDPOINT / QDRANT_API_KEY from deploy/envs/ai.env. Uses filtered
count() instead of a full scroll, so it answers "are there any low-band
records?" in a few seconds even on a large corpus.

Run:
    python3 scripts/inspect_qdrant_bands.py
"""
from __future__ import annotations

import os
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
ENV_FILE = REPO_ROOT / "deploy" / "envs" / "ai.env"
COLLECTION = "writing_samples"


def _load_env(path: Path) -> None:
    if not path.exists():
        print(f"warn: env file {path} not found", file=sys.stderr)
        return
    for raw in path.read_text().splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            continue
        key, _, value = line.partition("=")
        key = key.strip()
        value = value.split("#", 1)[0].strip()
        if value:
            os.environ.setdefault(key, value)


def main() -> int:
    _load_env(ENV_FILE)
    endpoint = os.environ.get("QDRANT_ENDPOINT", "").strip()
    api_key = os.environ.get("QDRANT_API_KEY", "").strip()
    if not endpoint or not api_key:
        print("error: QDRANT_ENDPOINT or QDRANT_API_KEY missing in ai.env", file=sys.stderr)
        return 1

    from qdrant_client import QdrantClient
    from qdrant_client.http import models

    client = QdrantClient(url=endpoint, api_key=api_key, timeout=30.0)

    collections = {c.name for c in client.get_collections().collections}
    if COLLECTION not in collections:
        print(f"error: collection {COLLECTION!r} not found. available: {sorted(collections)}")
        return 1

    def cnt(band_gte, band_lt=None):
        """Filtered count by band range. None = unbounded."""
        rng = {}
        if band_gte is not None:
            rng["gte"] = band_gte
        if band_lt is not None:
            rng["lt"] = band_lt
        flt = models.Filter(must=[models.FieldCondition(
            key="band_overall", range=models.Range(**rng),
        )]) if rng else None
        res = client.count(collection_name=COLLECTION, count_filter=flt, exact=True)
        return res.count

    print("=== Filtered counts (band_overall) ===")
    bands = [
        ("0.0–2.5", 0.0, 2.5),
        ("3.0–3.5", 3.0, 4.0),
        ("4.0–4.5", 4.0, 5.0),
        ("5.0–5.5", 5.0, 6.0),
        ("6.0–6.5", 6.0, 7.0),
        ("7.0–7.5", 7.0, 8.0),
        ("8.0–8.5", 8.0, 9.0),
        ("9.0",     9.0, 10.0),
    ]
    total = 0
    rows = []
    for label, lo, hi in bands:
        c = cnt(lo, hi)
        rows.append((label, c))
        total += c
    rows.append(("unknown / no band_overall", cnt(None)))
    for label, c in rows:
        pct = (c / max(total, 1)) * 100
        print(f"  Band {label:>8}: {c:>6}  ({pct:5.1f}%)")
    print(f"  {'TOTAL':>8}: {total}")

    # Pull up to 3 low-band points so we can see what the corpus has.
    print("\n=== Sample low-band points (band_overall < 5.0) ===")
    pts, _ = client.scroll(
        collection_name=COLLECTION,
        scroll_filter=models.Filter(must=[models.FieldCondition(
            key="band_overall", range=models.Range(lt=5.0)
        )]),
        limit=3,
        with_payload=["band_overall", "task_type", "text"],
        with_vectors=False,
    )
    if not pts:
        print("  (none — zero points with band_overall < 5.0)")
    else:
        for p in pts:
            payload = p.payload or {}
            text = (payload.get("text") or "").strip().replace("\n", " ")[:160]
            print(f"  id={p.id} band={payload.get('band_overall')} "
                  f"task_type={payload.get('task_type')}")
            print(f"    text: {text}...")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
