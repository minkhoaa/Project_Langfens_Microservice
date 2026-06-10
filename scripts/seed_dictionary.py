#!/usr/bin/env python3
"""
Seed the dictionary-db (PostgreSQL) with ~100k most-common modern English words
sourced from Kaikki.org (Wiktionary JSONL).

Stdlib only. Streams the 2.8GB JSONL line-by-line, keeps entries whose `word`
is in the curated modern English set and `pos` is not archaic/obsolete/historical.
Bulk-loads via psql's `\\copy ... FROM STDIN` pipe for speed.

Usage:
    python3 scripts/seed_dictionary.py            # default 100K
    python3 scripts/seed_dictionary.py --limit N  # cap rows for a dry run
    python3 scripts/seed_dictionary.py --no-download
"""
import argparse
import gzip
import json
import os
import subprocess
import sys
import time
import urllib.request
from pathlib import Path

DSN_ENV = os.getenv(
    "DICT_DSN",
    "host=localhost port=5443 dbname=dictionary-db user=dictionary password=dictionary",
)
DATA_DIR = Path(os.getenv("DATA_DIR", "data"))
KAIKKI_PATH = DATA_DIR / "kaikki.org-dictionary-English.jsonl"
WORDS_PATH = DATA_DIR / "english-100k.txt"
PSQL = os.getenv("PSQL", "psql")

KAIKKI_URL = "https://kaikki.org/dictionary/English/kaikki.org-dictionary-English.jsonl"

WORDLIST_URLS = [
    "https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt",
    "https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/content/2018/en/en_50k.txt",
]

SKIP_POS = {
    "archaic", "archaic-third-person-singular",
    "obsolete", "historical", "dated", "euphemism",
}

BATCH = 5_000


def log(msg: str) -> None:
    print(f"[seed] {msg}", flush=True)


def load_wordlist(path: Path) -> set[str]:
    if not path.exists():
        path.parent.mkdir(parents=True, exist_ok=True)
        merged: set[str] = set()
        for url in WORDLIST_URLS:
            log(f"  fetching {url}")
            try:
                with urllib.request.urlopen(url, timeout=60) as r:
                    text = r.read().decode("utf-8", errors="ignore")
            except Exception as e:
                log(f"  warn: {e}")
                continue
            for line in text.splitlines():
                w = line.strip().split()[0].lower() if line.strip() else ""
                if w and w.isalpha() and 2 <= len(w) <= 25:
                    merged.add(w)
        path.write_text("\n".join(sorted(merged)), encoding="utf-8")
        log(f"Wrote {len(merged):,} words to {path}")
    words = set()
    for line in path.read_text(encoding="utf-8").splitlines():
        w = line.strip().lower()
        if w and w.isalpha() and 2 <= len(w) <= 25:
            words.add(w)
    log(f"Loaded {len(words):,} modern English words")
    return words


def download_kaikki(path: Path) -> None:
    if path.exists() and path.stat().st_size > 1_000_000_000:
        log(f"Kaikki file present: {path} ({path.stat().st_size/1e9:.2f} GB)")
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    log(f"Downloading Kaikki (~2.8GB) -> {path}")
    with urllib.request.urlopen(KAIKKI_URL, timeout=300) as r, path.open("wb") as f:
        total = int(r.headers.get("Content-Length", 0))
        got = 0
        last = time.time()
        while True:
            chunk = r.read(1 << 20)
            if not chunk:
                break
            f.write(chunk)
            got += len(chunk)
            now = time.time()
            if now - last > 5:
                pct = (got / total * 100) if total else 0
                log(f"  {got/1e9:.2f} / {total/1e9:.2f} GB ({pct:.1f}%)")
                last = now
    log("Download complete")


def escape_text(v: str) -> str:
    # text-format COPY: backslash, newline, CR, tab
    return (
        v.replace("\\", "\\\\")
        .replace("\n", "\\n")
        .replace("\r", "\\r")
        .replace("\t", "\\t")
    )


def stream_and_insert(kaikki: Path, words: set[str], limit: int, skip_truncate: bool = False) -> int:
    if skip_truncate:
        log("Skipping TRUNCATE (--skip-truncate); will append/upsert into existing rows.")
    else:
        log("Truncating dictionary table...")
        subprocess.run(
            [PSQL, DSN_ENV, "-c", "TRUNCATE TABLE dictionary RESTART IDENTITY;"],
            check=True,
        )
    log("Enabling pg_trgm + GIN index (idempotent)...")
    subprocess.run(
        [PSQL, DSN_ENV, "-c",
         "CREATE EXTENSION IF NOT EXISTS pg_trgm; "
         "CREATE INDEX IF NOT EXISTS ix_dictionary_wordnorm_trgm "
         'ON dictionary USING GIN ("WordNorm" gin_trgm_ops);'],
        check=True,
    )

    log("Streaming Kaikki JSONL, filtering, and bulk-loading via \\copy...")
    open_fn = gzip.open if str(kaikki).endswith(".gz") else open
    kept = 0
    skipped_pos = 0
    skipped_word = 0
    parse_err = 0
    t0 = time.time()
    last_log = t0

    proc = subprocess.Popen(
        [PSQL, DSN_ENV, "-c",
         "\\copy dictionary (\"Word\", \"WordNorm\", \"Pos\", \"Data\", \"ImportedAt\") FROM STDIN"],
        stdin=subprocess.PIPE, text=True,
    )
    try:
        with open_fn(kaikki, "rt", encoding="utf-8", errors="ignore") as f:
            for line in f:
                if limit and kept >= limit:
                    break
                line = line.strip()
                if not line:
                    continue
                try:
                    obj = json.loads(line)
                except json.JSONDecodeError:
                    parse_err += 1
                    continue
                word = obj.get("word") or ""
                wn = word.strip().lower()
                if not wn or wn not in words:
                    skipped_word += 1
                    continue
                pos = (obj.get("pos") or "unknown").lower()
                if pos in SKIP_POS:
                    skipped_pos += 1
                    continue
                data_json = json.dumps(obj, ensure_ascii=False, separators=(",", ":"))
                row = "\t".join([
                    escape_text(word),
                    escape_text(wn),
                    escape_text(pos),
                    escape_text(data_json),
                    "2026-01-01 00:00:00+00",
                ]) + "\n"
                proc.stdin.write(row)
                kept += 1
                if kept % BATCH == 0:
                    proc.stdin.flush()
                    now = time.time()
                    if now - last_log > 5:
                        log(f"  queued {kept:,} | skip_word={skipped_word:,} skip_pos={skipped_pos:,}")
                        last_log = now
    finally:
        if proc.stdin:
            proc.stdin.close()
        rc = proc.wait()
        if rc != 0:
            raise RuntimeError(f"psql \\copy exited with {rc}")

    dt = time.time() - t0
    log(f"Done. inserted={kept:,} in {dt/60:.1f} min")
    log(f"  skipped_word={skipped_word:,}  skipped_pos={skipped_pos:,}  parse_err={parse_err:,}")

    # ANALYZE for the planner
    log("Running ANALYZE dictionary...")
    subprocess.run([PSQL, DSN_ENV, "-c", "ANALYZE dictionary;"], check=True)
    return kept


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--limit", type=int, default=int(os.getenv("LIMIT", "0")))
    ap.add_argument("--no-download", action="store_true")
    ap.add_argument(
        "--skip-truncate",
        action="store_true",
        help="Don't TRUNCATE before bulk-loading. Use to resume an interrupted run "
             "without wiping rows that were already inserted.",
    )
    args = ap.parse_args()

    words = load_wordlist(WORDS_PATH)
    if not args.no_download:
        download_kaikki(KAIKKI_PATH)
    if not KAIKKI_PATH.exists():
        log(f"Missing: {KAIKKI_PATH}. Run without --no-download.")
        return 1
    n = stream_and_insert(KAIKKI_PATH, words, args.limit, skip_truncate=args.skip_truncate)
    log(f"Inserted {n:,} rows")
    return 0


if __name__ == "__main__":
    sys.exit(main())
