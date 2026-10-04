#!/usr/bin/env python3
"""Canonical Metrics Recalculator for Phase 07 Semantic Benchmarks.

Applies the canonical SemanticBenchmarkMetricCalculator (v2.1.0) to raw checkpoints
without making live provider calls:
- Freezes denominators from corpus manifests.
- Excludes operational errors (EVALUATOR_UNAVAILABLE, TIMEOUT) from semantic TP.
- Computes overall blocking recall, per-type recall, ambiguity recall, and false rejection rate.
- Outputs detailed contribution lists (TP, FN, TN, FP, operational error case IDs).
"""

from __future__ import annotations

from datetime import datetime
import json
from pathlib import Path
import sys

BASE_DIR = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(BASE_DIR / "services" / "generation-service"))

from app.evaluators.metrics import (
    calculate_semantic_benchmark_metrics,
    METRIC_ENGINE_VERSION,
    METRIC_ENGINE_HASH,
)

PHASE07_DIR = BASE_DIR / "artifacts" / "refactor" / "phase-07"
CORPUS_DIR = PHASE07_DIR / "corpus"


def load_checkpoint(cp_path: Path) -> dict:
    with open(cp_path, "r", encoding="utf-8") as f:
        return json.load(f)


def recalculate_for_checkpoint(cp_file: Path, output_file: Path | None = None) -> dict:
    cp_data = load_checkpoint(cp_file)
    campaign_id = cp_data.get("campaignId", "unknown")
    partition = cp_data.get("partition", "unknown")
    cases = cp_data.get("cases", {})

    # Extract question cases, canary cases, and fidelity cases
    q_records = {k: v for k, v in cases.items() if k.startswith("q_")}
    canary_records = [v for k, v in cases.items() if "canary" in k]
    fidelity_records = [v for k, v in cases.items() if k.startswith("fid_") or "fidelity" in k.lower()]

    result = calculate_semantic_benchmark_metrics(
        records=q_records,
        campaign_id=campaign_id,
        partition=partition,
        canary_records=canary_records,
    )

    ts_list = [c["timestamp"] for c in cases.values() if "timestamp" in c]
    started_time = min(ts_list) if ts_list else None
    finished_time = max(ts_list) if ts_list else None
    duration_sec = None
    if started_time and finished_time:
        try:
            duration_sec = max(0.1, (datetime.fromisoformat(finished_time) - datetime.fromisoformat(started_time)).total_seconds())
        except Exception:
            pass

    provider = next((c.get("providerUsed") for c in cases.values() if c.get("providerUsed")), None)
    model = next((c.get("modelUsed") for c in cases.values() if c.get("modelUsed")), None)
    quarantined_notice = (
        "QUARANTINED_RERUN: Evaluated on holdout partition after observing failure modes."
        if "holdout" in partition.lower() and "28203b" in campaign_id
        else None
    )

    summary = result.to_canonical_summary(
        started_at=started_time,
        finished_at=finished_time,
        duration_seconds=duration_sec,
        provider=provider,
        model=model,
        quarantined_notice=quarantined_notice,
        fidelity_results=fidelity_records if fidelity_records else None,
    )

    if output_file:
        with open(output_file, "w", encoding="utf-8") as f:
            json.dump(summary, f, indent=2)
        print(f"[+] Wrote recalculated metrics to {output_file}")

    return summary


def main():
    parser = argparse.ArgumentParser(description="Recalculate Phase 07 benchmark metrics from raw checkpoints")
    parser.add_argument("--checkpoint", type=str, default=None, help="Path to checkpoint JSON file")
    parser.add_argument("--output", type=str, default=None, help="Path to output JSON file")
    args = parser.parse_args()

    if args.checkpoint:
        cp_path = Path(args.checkpoint)
        out_path = Path(args.output) if args.output else None
        res = recalculate_for_checkpoint(cp_path, out_path)
        if not out_path:
            print(json.dumps(res, indent=2))
        return

    dev_cp = PHASE07_DIR / "campaign_checkpoint_dev.json"
    holdout_cp = PHASE07_DIR / "campaign_checkpoint_holdout.json"

    print(f"[*] Recalculating Dev Campaign from {dev_cp}...")
    dev_res = recalculate_for_checkpoint(dev_cp, PHASE07_DIR / "dev-metrics-recalculated.json")
    print(f"  Dev Overall Recall: {dev_res['rates']['overallBlockingRecall']*100:.2f}%")
    print(f"  Dev Ambiguity Recall: {dev_res['rates']['ambiguityRecallFormatted']}")
    print(f"  Dev Operational Failures: {dev_res['metadata']['operationalFailures']}")

    print(f"\n[*] Recalculating Quarantined Holdout Campaign from {holdout_cp}...")
    holdout_res = recalculate_for_checkpoint(holdout_cp, PHASE07_DIR / "holdout-metrics-recalculated.json")
    print(f"  Holdout Overall Recall: {holdout_res['rates']['overallBlockingRecall']*100:.2f}%")
    print(f"  Holdout Ambiguity Recall: {holdout_res['rates']['ambiguityRecallFormatted']}")
    print(f"  Holdout Operational Failures: {holdout_res['metadata']['operationalFailures']}")


if __name__ == "__main__":
    main()
