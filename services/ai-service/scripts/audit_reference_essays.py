#!/usr/bin/env python3
"""
Phase 2: Audit Reference Essays in Qdrant Cloud

Uses Gemini 2.5 Pro to re-grade all essays with band_overall >= 7.0
and flags mislabeled essays.

Features:
  - Incremental CSV writes (crash-safe — no data loss on interruption)
  - Checkpoint/resume support via --resume flag
  - Progress summaries every 100 essays
  - Graceful shutdown on SIGINT/SIGTERM

Usage:
    # Set environment variables first
    export GEMINI_API_KEY="AIza..."
    export QDRANT_ENDPOINT="https://..."
    export QDRANT_API_KEY="..."

    # Run audit (dry run by default)
    python scripts/audit_reference_essays.py

    # Resume interrupted audit
    python scripts/audit_reference_essays.py --resume

    # Run with auto-downgrade for essays >1.0 band below stored
    python scripts/audit_reference_essays.py --apply-downgrades

    # Analyze existing CSV without re-running
    python scripts/audit_reference_essays.py --analyze-only docs/superpowers/reports/essay_audit_XYZ.csv
"""

import argparse
import csv
import json
import logging
import os
import signal
import sys
import time
from datetime import datetime
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
from threading import Lock

from google import genai
from google.genai import types
from qdrant_client import QdrantClient
from qdrant_client.models import FieldCondition, Filter, Range

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
logger = logging.getLogger(__name__)

# --- Configuration ---
GEMINI_MODEL = "gemini-2.5-pro"  # Use Gemini 2.5 Pro for highest quality regrading
QDRANT_COLLECTION = "writing_samples"
MIN_BAND_TO_AUDIT = 7.0
BATCH_SIZE = 20  # Scroll batch size from Qdrant
SLEEP_BETWEEN_CALLS = 0.0  # Disabled for parallel processing
MAX_RETRIES = 3
PROGRESS_INTERVAL = 100  # Print summary every N essays
MAX_WORKERS = 20  # Parallel API calls (Gemini supports ~15-20 concurrent)

# Report directory (relative to this script's location)
REPORT_DIR = Path(__file__).parent.parent.parent.parent / "docs" / "superpowers" / "reports"

AUDIT_PROMPT = """You are a senior IELTS Writing examiner with 20+ years of experience. You are strict, accurate, and apply official IELTS band descriptors precisely.

Grade the following essay on each of the 4 IELTS Writing criteria. Be STRICT — a Band 8.0 essay must have near-zero grammar errors and demonstrate sophisticated, natural vocabulary.

<essay>
{essay_text}
</essay>

Provide your assessment as a JSON object with these exact keys:

{{
  "task_response_band": <float, 0.5 increments from 1.0 to 9.0>,
  "coherence_cohesion_band": <float>,
  "lexical_resource_band": <float>,
  "grammatical_range_accuracy_band": <float>,
  "overall_band": <float, calculated as average of 4 criteria rounded to nearest 0.5>,
  "grammar_errors": [
    {{"error": "exact text with error", "correction": "corrected version", "severity": "minor|major|critical"}}
  ],
  "vocabulary_issues": [
    {{"issue": "description of vocabulary problem", "example": "the problematic phrase", "severity": "minor|major|critical"}}
  ],
  "verdict": "accurate|overrated|underrated",
  "confidence": <float 0.0-1.0, how confident you are in your assessment>,
  "notes": "Brief explanation of your overall assessment"
}}

Rules:
- Be STRICT. A real Band 8.0 essay should have virtually no grammar errors.
- Missing auxiliary verbs (e.g., "I deeply convinced" instead of "I am deeply convinced") are CRITICAL errors that cap grammar at Band 6.0 maximum.
- Word confusion (e.g., "homework" instead of "working from home") is a CRITICAL vocabulary error.
- Unidiomatic expressions (e.g., "choose work in a distance") are MAJOR errors.
- An essay with 3+ critical errors cannot be above Band 6.5 regardless of other qualities.
- Return ONLY valid JSON. No markdown, no code blocks."""

# CSV field names for the audit report
CSV_FIELDNAMES = [
    "id", "stored_band", "ai_band", "action", "verdict", "confidence",
    "ai_task_response", "ai_coherence", "ai_lexical", "ai_grammar",
    "grammar_errors_count", "critical_errors_count",
    "task_type", "notes", "grammar_errors_detail", "vocab_issues_detail",
]

# --- Graceful shutdown ---
_shutdown_requested = False


def _signal_handler(signum, frame):
    global _shutdown_requested
    logger.warning(f"Received signal {signum}. Finishing current essay then stopping...")
    _shutdown_requested = True


signal.signal(signal.SIGINT, _signal_handler)
signal.signal(signal.SIGTERM, _signal_handler)


def get_qdrant_client() -> QdrantClient:
    """Initialize Qdrant Cloud client."""
    endpoint = os.environ.get("QDRANT_ENDPOINT")
    api_key = os.environ.get("QDRANT_API_KEY")
    if not endpoint or not api_key:
        logger.error("QDRANT_ENDPOINT and QDRANT_API_KEY must be set")
        sys.exit(1)
    return QdrantClient(url=endpoint, api_key=api_key, timeout=60)


def get_gemini_client() -> genai.Client:
    """Initialize Gemini client."""
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        logger.error("GEMINI_API_KEY must be set")
        sys.exit(1)
    return genai.Client(api_key=api_key)


def fetch_high_band_essays(qdrant: QdrantClient) -> list[dict]:
    """Fetch all essays with band >= MIN_BAND_TO_AUDIT from Qdrant."""
    essays = []
    offset = None

    while True:
        result = qdrant.scroll(
            collection_name=QDRANT_COLLECTION,
            scroll_filter=Filter(
                must=[
                    FieldCondition(
                        key="band_overall",
                        range=Range(gte=MIN_BAND_TO_AUDIT),
                    )
                ]
            ),
            limit=BATCH_SIZE,
            offset=offset,
            with_payload=True,
            with_vectors=False,
        )

        points, next_offset = result
        for point in points:
            payload = point.payload or {}
            essays.append({
                "id": str(point.id),
                "text": payload.get("text", ""),
                "stored_band": payload.get("band_overall", 0.0),
                "task_type": payload.get("task_type", "unknown"),
            })

        if next_offset is None:
            break
        offset = next_offset

    return essays


def grade_essay(gemini: genai.Client, essay_text: str, essay_id: str = "") -> dict | None:
    """Use Gemini 2.5 Pro to grade a single essay."""
    prompt = AUDIT_PROMPT.format(essay_text=essay_text)

    for attempt in range(MAX_RETRIES):
        try:
            response = gemini.models.generate_content(
                model=GEMINI_MODEL,
                contents=prompt,
                config=types.GenerateContentConfig(
                    temperature=0.1,  # Low temperature for consistent grading
                    max_output_tokens=4096,
                    response_mime_type="application/json",
                ),
            )

            text = response.text.strip()
            # Clean potential markdown code blocks
            if text.startswith("```"):
                text = text.split("\n", 1)[1]
            if text.endswith("```"):
                text = text.rsplit("\n", 1)[0]

            return json.loads(text)

        except json.JSONDecodeError as e:
            logger.warning(f"  JSON parse error (attempt {attempt + 1}): {e}")
            if attempt < MAX_RETRIES - 1:
                time.sleep(0.5)
        except Exception as e:
            logger.warning(f"  Gemini API error (attempt {attempt + 1}): {e}")
            if attempt < MAX_RETRIES - 1:
                time.sleep(0.5 * (attempt + 1))

    return None


def classify_result(stored_band: float, ai_band: float) -> str:
    """Classify the difference between stored and AI-assessed band."""
    diff = stored_band - ai_band
    if abs(diff) <= 0.5:
        return "KEEP"       # Within acceptable range
    elif diff > 1.0:
        return "OVERRATED"  # Stored band is too high
    elif diff > 0.5:
        return "FLAG_REVIEW" # Needs human review
    elif diff < -0.5:
        return "UNDERRATED" # Stored band might be too low
    return "KEEP"


def load_checkpoint(csv_path: Path) -> tuple[set[str], dict]:
    """Load already-processed (successful) essay IDs from existing CSV.
    
    Returns:
        tuple: (processed_ids set, band_counts dict by stored_band)
    """
    processed = set()
    band_counts = {}
    
    if csv_path.exists():
        try:
            with open(csv_path, "r") as f:
                reader = csv.DictReader(f)
                for row in reader:
                    # Only count successful grades (not ERROR)
                    if "id" in row and row["id"] and row.get("action") != "ERROR":
                        processed.add(row["id"])
                        
                        # Track counts by band
                        band = row.get("stored_band", "unknown")
                        band_counts[band] = band_counts.get(band, 0) + 1
            
            logger.info(f"Checkpoint: loaded {len(processed)} successfully-processed essays")
            if band_counts:
                logger.info(f"  Band distribution: {dict(sorted(band_counts.items()))}")
        except Exception as e:
            logger.warning(f"Could not read checkpoint file: {e}")
    
    return processed, band_counts


def find_latest_csv() -> Path | None:
    """Find the most recent audit CSV file."""
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    csvs = sorted(REPORT_DIR.glob("essay_audit_*.csv"), reverse=True)
    return csvs[0] if csvs else None


def print_progress_summary(results: list[dict], processed_count: int, total: int, start_time: float):
    """Print a progress summary."""
    elapsed = time.time() - start_time
    rate = processed_count / elapsed if elapsed > 0 else 0
    remaining = (total - processed_count) / rate if rate > 0 else float("inf")

    keep = sum(1 for r in results if r["action"] == "KEEP")
    overrated = sum(1 for r in results if r["action"] == "OVERRATED")
    flagged = sum(1 for r in results if r["action"] == "FLAG_REVIEW")
    underrated = sum(1 for r in results if r["action"] == "UNDERRATED")
    errors = sum(1 for r in results if r["action"] == "ERROR")

    # Band distribution
    from collections import Counter
    band_dist = Counter(r.get("stored_band") for r in results if r.get("stored_band"))
    band_str = ", ".join(f"Band {k}:{v}" for k, v in sorted(band_dist.items(), key=lambda x: float(x[0]) if str(x[0]).replace(".", "", 1).isdigit() else 0, reverse=True))

    logger.info("")
    logger.info("─" * 50)
    logger.info(f"📊 PROGRESS: {processed_count}/{total} ({processed_count/total*100:.1f}%)")
    logger.info(f"   KEEP: {keep} | OVERRATED: {overrated} | FLAG: {flagged} | UNDERRATED: {underrated} | ERROR: {errors}")
    logger.info(f"   Band distribution: {band_str}")
    if overrated + keep + flagged + underrated > 0:
        overrated_pct = overrated / (overrated + keep + flagged + underrated) * 100
        logger.info(f"   Overrated rate: {overrated_pct:.1f}%")
    logger.info(f"   Rate: {rate:.2f} essays/sec | ETA: {remaining/3600:.1f}h remaining")
    logger.info("─" * 50)
    logger.info("")


def analyze_csv(csv_path: str | Path) -> dict:
    """Analyze an existing audit CSV and return statistics."""
    csv_path = Path(csv_path)
    if not csv_path.exists():
        logger.error(f"CSV file not found: {csv_path}")
        sys.exit(1)

    results = []
    with open(csv_path, "r") as f:
        reader = csv.DictReader(f)
        for row in reader:
            results.append(row)

    total = len(results)
    if total == 0:
        logger.info("No results to analyze.")
        return {}

    keep = sum(1 for r in results if r.get("action") == "KEEP")
    overrated = sum(1 for r in results if r.get("action") == "OVERRATED")
    flagged = sum(1 for r in results if r.get("action") == "FLAG_REVIEW")
    underrated = sum(1 for r in results if r.get("action") == "UNDERRATED")
    errors = sum(1 for r in results if r.get("action") == "ERROR")

    non_error = total - errors
    overrated_pct = (overrated / non_error * 100) if non_error > 0 else 0
    flagged_pct = (flagged / non_error * 100) if non_error > 0 else 0
    keep_pct = (keep / non_error * 100) if non_error > 0 else 0
    underrated_pct = (underrated / non_error * 100) if non_error > 0 else 0

    # Band distribution analysis
    band_diffs = []
    by_stored_band = {}
    for r in results:
        if r.get("action") == "ERROR":
            continue
        stored = float(r.get("stored_band", 0))
        ai = float(r.get("ai_band", 0))
        diff = stored - ai
        band_diffs.append(diff)

        band_key = str(stored)
        if band_key not in by_stored_band:
            by_stored_band[band_key] = {"total": 0, "overrated": 0, "keep": 0, "flagged": 0, "underrated": 0}
        by_stored_band[band_key]["total"] += 1
        action = r.get("action", "")
        if action in by_stored_band[band_key]:
            by_stored_band[band_key][action.lower()] += 1

    avg_diff = sum(band_diffs) / len(band_diffs) if band_diffs else 0
    max_diff = max(band_diffs) if band_diffs else 0

    stats = {
        "total": total,
        "keep": keep,
        "overrated": overrated,
        "flagged": flagged,
        "underrated": underrated,
        "errors": errors,
        "keep_pct": keep_pct,
        "overrated_pct": overrated_pct,
        "flagged_pct": flagged_pct,
        "underrated_pct": underrated_pct,
        "avg_band_diff": avg_diff,
        "max_band_diff": max_diff,
        "by_stored_band": by_stored_band,
    }

    logger.info("")
    logger.info("=" * 60)
    logger.info("AUDIT ANALYSIS RESULTS")
    logger.info("=" * 60)
    logger.info(f"Total essays analyzed:   {total}")
    logger.info(f"KEEP (within ±0.5):      {keep} ({keep_pct:.1f}%)")
    logger.info(f"FLAG_REVIEW (0.5-1.0):   {flagged} ({flagged_pct:.1f}%)")
    logger.info(f"OVERRATED (>1.0):        {overrated} ({overrated_pct:.1f}%)")
    logger.info(f"UNDERRATED:              {underrated} ({underrated_pct:.1f}%)")
    logger.info(f"ERRORS:                  {errors}")
    logger.info(f"")
    logger.info(f"Avg band difference:     {avg_diff:+.2f}")
    logger.info(f"Max band difference:     {max_diff:+.2f}")
    logger.info(f"")
    logger.info("By stored band:")
    for band in sorted(by_stored_band.keys(), key=float):
        b = by_stored_band[band]
        pct = b["overrated"] / b["total"] * 100 if b["total"] > 0 else 0
        logger.info(f"  Band {band}: {b['total']} essays, {b['overrated']} overrated ({pct:.0f}%)")
    logger.info("=" * 60)

    if overrated_pct > 20:
        logger.warning(f"⚠️  {overrated_pct:.1f}% overrated — RECOMMEND running with --apply-downgrades")

    return stats


def run_audit(apply_downgrades: bool = False, resume: bool = False):
    """Main audit logic with parallel processing and checkpoint/resume support."""
    global _shutdown_requested

    logger.info("=" * 60)
    logger.info("Phase 2: Reference Essay Quality Audit (PARALLEL MODE)")
    logger.info(f"Model: {GEMINI_MODEL}")
    logger.info(f"Min band to audit: {MIN_BAND_TO_AUDIT}")
    logger.info(f"Apply downgrades: {apply_downgrades}")
    logger.info(f"Resume mode: {resume}")
    logger.info(f"Max workers: {MAX_WORKERS}")
    logger.info("=" * 60)

    qdrant = get_qdrant_client()
    gemini = get_gemini_client()

    # Step 1: Fetch essays
    logger.info("Fetching high-band essays from Qdrant...")
    essays = fetch_high_band_essays(qdrant)
    logger.info(f"Found {len(essays)} essays with band >= {MIN_BAND_TO_AUDIT}")

    if not essays:
        logger.info("No essays to audit. Exiting.")
        return

    # Step 2: Set up CSV with checkpoint support
    REPORT_DIR.mkdir(parents=True, exist_ok=True)

    if resume:
        existing_csv = find_latest_csv()
        if existing_csv:
            csv_path = existing_csv
            logger.info(f"Resuming from: {csv_path}")
        else:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            csv_path = REPORT_DIR / f"essay_audit_{timestamp}.csv"
            logger.info(f"No existing CSV found. Starting fresh: {csv_path}")
    else:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        csv_path = REPORT_DIR / f"essay_audit_{timestamp}.csv"

    # Load checkpoint
    processed_ids, band_counts = load_checkpoint(csv_path) if resume else (set(), {})
    
    # Log checkpoint stats
    if resume and processed_ids:
        logger.info(f"Resuming with {len(processed_ids)} already processed essays")
        if band_counts:
            logger.info(f"  Already processed by band: {dict(sorted(band_counts.items()))}")

    # Initialize CSV file with header if new
    if not csv_path.exists():
        with open(csv_path, "w", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=CSV_FIELDNAMES, extrasaction="ignore")
            writer.writeheader()
        logger.info(f"Created new CSV: {csv_path}")

    # Track results for progress reporting
    existing_results = []
    if processed_ids:
        with open(csv_path, "r") as f:
            reader = csv.DictReader(f)
            existing_results = list(reader)

    all_results = list(existing_results)
    session_count = 0
    start_time = time.time()

    # CSV write lock for thread safety
    csv_lock = Lock()

    # Filter out already-processed essays
    pending_essays = [e for e in essays if e["id"] not in processed_ids]
    total_to_process = len(pending_essays)

    logger.info(f"Already processed: {len(processed_ids)} essays")
    logger.info(f"Pending: {total_to_process} essays")
    logger.info(f"Starting parallel grading with {MAX_WORKERS} workers...")
    logger.info("")

    def grade_single_essay(essay: dict) -> dict:
        """Thread-safe grading function."""
        essay_id = essay["id"]
        # Create new gemini client per thread to avoid sharing issues
        thread_gemini = get_gemini_client()

        try:
            ai_result = grade_essay(thread_gemini, essay["text"], essay_id)

            if ai_result is None:
                return {
                    **essay,
                    "ai_band": None,
                    "action": "ERROR",
                    "grammar_errors_count": 0,
                    "critical_errors_count": 0,
                    "notes": "Failed to grade",
                    "verdict": "",
                    "confidence": 0,
                    "ai_task_response": None,
                    "ai_coherence": None,
                    "ai_lexical": None,
                    "ai_grammar": None,
                    "grammar_errors_detail": "[]",
                    "vocab_issues_detail": "[]",
                }

            ai_band = ai_result.get("overall_band", 0.0)
            grammar_errors = ai_result.get("grammar_errors", [])
            vocab_issues = ai_result.get("vocabulary_issues", [])
            critical_errors = [e for e in grammar_errors if e.get("severity") == "critical"]
            critical_vocab = [v for v in vocab_issues if v.get("severity") == "critical"]

            action = classify_result(essay["stored_band"], ai_band)

            band_diff = essay["stored_band"] - ai_band
            logger.info(f"  [{action}] {essay_id[:8]}: {essay['stored_band']} → {ai_band} (diff: {band_diff:+.1f})")

            return {
                **essay,
                "ai_band": ai_band,
                "ai_task_response": ai_result.get("task_response_band"),
                "ai_coherence": ai_result.get("coherence_cohesion_band"),
                "ai_lexical": ai_result.get("lexical_resource_band"),
                "ai_grammar": ai_result.get("grammatical_range_accuracy_band"),
                "action": action,
                "grammar_errors_count": len(grammar_errors),
                "critical_errors_count": len(critical_errors) + len(critical_vocab),
                "verdict": ai_result.get("verdict", ""),
                "confidence": ai_result.get("confidence", 0),
                "notes": ai_result.get("notes", ""),
                "grammar_errors_detail": json.dumps(grammar_errors[:5]),
                "vocab_issues_detail": json.dumps(vocab_issues[:3]),
            }
        except Exception as e:
            logger.error(f"  ERROR grading {essay_id[:8]}: {e}")
            return {
                **essay,
                "ai_band": None,
                "action": "ERROR",
                "notes": f"Exception: {str(e)}",
            }

    # Process essays in parallel batches
    batch_size = 100  # Process and write in batches for efficiency

    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        for batch_start in range(0, total_to_process, batch_size):
            if _shutdown_requested:
                logger.info("Graceful shutdown requested. Saving progress...")
                break

            batch_end = min(batch_start + batch_size, total_to_process)
            batch_essays = pending_essays[batch_start:batch_end]

            logger.info(f"Processing batch {batch_start//batch_size + 1}: essays {batch_start + 1}-{batch_end}")

            # Submit all essays in this batch
            futures = {executor.submit(grade_single_essay, essay): essay for essay in batch_essays}

            # Collect results as they complete
            batch_results = []
            for future in as_completed(futures):
                result = future.result()
                batch_results.append(result)

                # Write immediately to CSV (thread-safe)
                with csv_lock:
                    with open(csv_path, "a", newline="") as f:
                        writer = csv.DictWriter(f, fieldnames=CSV_FIELDNAMES, extrasaction="ignore")
                        writer.writerow(result)

                processed_ids.add(result["id"])
                all_results.append(result)

            session_count += len(batch_results)

            # Progress summary
            elapsed = time.time() - start_time
            rate = session_count / elapsed if elapsed > 0 else 0
            remaining = (total_to_process - session_count) / rate if rate > 0 else 0
            logger.info(f"  Batch done: {session_count}/{total_to_process} | {rate:.1f}/sec | ETA: {remaining/60:.1f} min")
            logger.info("")

    # Step 4: Final Summary
    total_processed = len(processed_ids)
    keep_count = sum(1 for r in all_results if r.get("action") == "KEEP")
    overrated_count = sum(1 for r in all_results if r.get("action") == "OVERRATED")
    flagged_count = sum(1 for r in all_results if r.get("action") == "FLAG_REVIEW")
    underrated_count = sum(1 for r in all_results if r.get("action") == "UNDERRATED")
    error_count = sum(1 for r in all_results if r.get("action") == "ERROR")

    logger.info("")
    logger.info("=" * 60)
    logger.info("AUDIT SUMMARY")
    logger.info("=" * 60)
    logger.info(f"Total essays in scope:   {len(essays)}")
    logger.info(f"Total processed:         {total_processed}")
    logger.info(f"This session:            {session_count}")
    logger.info(f"KEEP (within ±0.5):      {keep_count}")
    logger.info(f"FLAG_REVIEW (0.5-1.0):   {flagged_count}")
    logger.info(f"OVERRATED (>1.0):        {overrated_count}")
    logger.info(f"UNDERRATED:              {underrated_count}")
    logger.info(f"ERRORS:                  {error_count}")
    logger.info(f"")
    logger.info(f"Report saved to: {csv_path}")

    if total_processed < len(essays):
        logger.info(f"")
        logger.info(f"ℹ️  Audit incomplete ({total_processed}/{len(essays)}). "
                     f"Run with --resume to continue.")

    # Step 5: Optionally apply downgrades
    if apply_downgrades and overrated_count > 0:
        logger.info("")
        logger.info("Applying downgrades to OVERRATED essays...")
        downgraded = 0
        for r in all_results:
            if r.get("action") == "OVERRATED" and r.get("ai_band") is not None:
                try:
                    ai_band_val = float(r["ai_band"])
                    stored_band_val = float(r["stored_band"])
                    qdrant.set_payload(
                        collection_name=QDRANT_COLLECTION,
                        payload={
                            "band_overall": ai_band_val,
                            "original_band": stored_band_val,
                            "audit_date": datetime.now().isoformat(),
                            "audit_model": GEMINI_MODEL,
                        },
                        points=[r["id"]],
                    )
                    downgraded += 1
                    logger.info(f"  Downgraded {r['id'][:8]}: {stored_band_val} → {ai_band_val}")
                except Exception as e:
                    logger.error(f"  Failed to downgrade {r['id'][:8]}: {e}")
        logger.info(f"Downgraded {downgraded}/{overrated_count} essays")
    elif overrated_count > 0:
        logger.info("")
        logger.info(f"⚠️  {overrated_count} essays are overrated. Run with --apply-downgrades to fix.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Audit IELTS reference essays in Qdrant")
    parser.add_argument(
        "--apply-downgrades",
        action="store_true",
        help="Actually apply band score downgrades to Qdrant (default: dry run)",
    )
    parser.add_argument(
        "--resume",
        action="store_true",
        help="Resume from the latest checkpoint CSV instead of starting fresh",
    )
    parser.add_argument(
        "--analyze-only",
        type=str,
        default=None,
        metavar="CSV_PATH",
        help="Analyze an existing CSV report without re-running the audit",
    )
    args = parser.parse_args()

    if args.analyze_only:
        analyze_csv(args.analyze_only)
    else:
        run_audit(apply_downgrades=args.apply_downgrades, resume=args.resume)
