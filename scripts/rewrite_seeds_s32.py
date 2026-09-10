#!/usr/bin/env python3
"""S32 Phase 3 — Rewrite ALL historical seed SQL files to standardize the
[N] placeholder format for blank-style questions.

Key semantic
------------
For every SQL string literal that contains a blank-placeholder run (≥7
underscores, optionally with adjacent runs joined by whitespace), the run is
replaced with sequential ``[1]``, ``[2]``, …, ``[N]`` brackets.

For the corresponding ``BlankAcceptTexts`` jsonb literal in the same
``INSERT INTO exam_questions`` row, every JSON object key is **renumbered
by ordinal position** (``"1"``, ``"2"``, …, ``"N"``) — *not* by stripping
the legacy question-index suffix. The grader (``CompletionGrader``)
looks up ``BlankAcceptTexts[blankId]`` using the parsed ``[N]`` from the
prompt, so the JSON key MUST equal the blank's ordinal within the prompt.

In the legacy convention, ``"blank-q<qIdx>"`` named each key by the question
index in the section (e.g. ``"blank-q6"`` for the 6th question of section 1).
The grader will eventually be queried with the new blank ordinal (e.g.
``"1"`` because the prompt contains ``[1]``); keeping the question-index
key would cause every blank to miss.

Implementation
--------------
A SQL-aware tokenizer splits the source into string-literal chunks and
``other`` (whitespace, comments, SQL keywords) chunks. The literals are
mutated in-place:

* Pattern 1 — runs of ≥7 underscores, with adjacent runs separated only
  by whitespace collapsed to a single blank group, are rewritten to
  ``[1]``…``[N]`` in occurrence order **within the literal**.
* Pattern 2 — for jsonb literals (``'…'::jsonb``), the existing keys
  (whether ``"blank-q<N>"`` or any other prefix) are renumbered to
  ``"1"``…``"N"`` where ``N`` is the number of keys currently present
  in that literal.

Idempotency
-----------
If a file already contains only ``[N]`` placeholders (no `_______` runs)
and only numeric keys in jsonb literals (no `blank-q` prefix), the file
is left untouched. Re-running the script on a converted file is a no-op.

Usage
-----
    python3 scripts/rewrite_seeds_s32.py [--dry-run] [--seeds-dir <path>]
"""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

# --------------------------------------------------------------------------- #
# Target file selection
# --------------------------------------------------------------------------- #

# Files we DO NOT touch (per S32 Phase 3 spec).
SKIP_FILE_PREFIXES = (
    "seed_deck-",
    "seed_achievements",
    "seed_speaking_exams",
    "seed_writing_exams",
)

ALWAYS_INCLUDE = {
    "placement.sql",
    "fix-matching-features.sql",
    "fix-matching-features-attempts.sql",
    "seed_exam_image_urls.sql",
}


def is_target(path: Path) -> bool:
    name = path.name
    if name in ALWAYS_INCLUDE:
        return True
    if name.startswith(SKIP_FILE_PREFIXES):
        return False
    return name.startswith(("seed_exam_", "fix-"))


# --------------------------------------------------------------------------- #
# Tokenizer — split SQL into literal tokens + non-literal chunks
# --------------------------------------------------------------------------- #

# A string literal: optional E prefix, then a single quote, body, closing
# quote. Body matches GREEDILY (NOT ``*?``) so the engine consumes
# ``''`` (Postgres-escaped single quote) pairs and only stops when it
# cannot extend the body any further without consuming the closing
# unescaped ``'``. Using non-greedy would let the engine terminate at
# the first ``'`` even when followed by another ``'`` (an escape).
STRING_LITERAL = re.compile(
    r"""(?P<prefix>E)?
        '
        (?P<body>(?:
            ''                       # Postgres escaped single quote
          | \\['"\\nrt0abfnv]        # backslash escape (E'…')
          | \\x[0-9A-Fa-f]{1,2}      # hex escape inside E'…'
          | [^']                     # anything else (incl. newlines)
        )*)
        '
    """,
    re.VERBOSE | re.DOTALL,
)

JSONB_CAST = re.compile(r"\s*::\s*jsonb\b")


@dataclass
class Token:
    kind: str            # "literal" | "other"
    start: int
    end: int             # exclusive
    prefix: str          # "" | "E" (literal only)
    body: str            # literal only
    is_jsonb: bool       # True if literal followed by ::jsonb


def tokenize(source: str) -> list[Token]:
    tokens: list[Token] = []
    pos = 0
    n = len(source)
    while pos < n:
        m = STRING_LITERAL.search(source, pos)
        if not m:
            tokens.append(Token("other", pos, n, "", "", False))
            break
        if m.start() > pos:
            tokens.append(Token("other", pos, m.start(), "", "", False))
        prefix = m.group("prefix") or ""
        body = m.group("body")
        end = m.end()
        jsonb_match = JSONB_CAST.match(source, end)
        is_jsonb = bool(jsonb_match)
        if is_jsonb:
            end = jsonb_match.end()
        tokens.append(Token("literal", m.start(), end, prefix, body, is_jsonb))
        pos = end
    return tokens


# --------------------------------------------------------------------------- #
# Pattern 1 — underscore blank groups → [N]
# --------------------------------------------------------------------------- #

# A blank group = one or more underscore-runs (≥6 underscores) joined by
# whitespace only. Two runs separated by a single space = ONE blank slot
# (IELTS visual convention for a wide blank).
#
# Threshold is ≥6 (not ≥7) because the self-drive-tours seed uses exactly
# 6 underscores (`______`) as its placeholder convention. Any run of 6+
# underscores inside a SQL string literal is unambiguously a blank.
BLANK_GROUP = re.compile(r"_{6,}(?:\s+_{6,})*")
# Standalone underscore-run for diagnostics / dry-run counting.
UNDERSCORE_RUN = re.compile(r"_{6,}")


def rewrite_underscores(body: str) -> tuple[str, int]:
    counter = {"i": 0}

    def _sub(match: re.Match[str]) -> str:
        counter["i"] += 1
        return f"[{counter['i']}]"

    new_body = BLANK_GROUP.sub(_sub, body)
    return new_body, counter["i"]

# --------------------------------------------------------------------------- #
# Pattern 2 — renumber JSON object keys to ordinals 1..N
# --------------------------------------------------------------------------- #

# Match any JSON object key inside a string literal. We don't restrict to
# ``"blank-q\d+"`` because (a) some legacy keys use the bare question number
# as the digit, and (b) the rule is "renumber by ordinal position" — so
# regardless of the current key name, we replace it with ``"1"``, ``"2"``, …
# according to its position in the JSON object.
#
# We rely on jsonb literals being short enough that a linear rewrite is
# reliable. Keys are written as ``"key"`` — quoted with double quotes,
# followed by ``:``. We anchor on ``":`` to ensure we match keys (not
# values which might contain numbers).
JSON_KEY = re.compile(r'"([^"\\]|\\.)*"\s*:')


def rewrite_jsonb_keys(body: str) -> tuple[str, int]:
    """Renumber every JSON object key in ``body`` to ``"1"``, ``"2"``, ….

    Returns ``(new_body, count_replaced)``.
    """
    counter = {"i": 0}
    parts: list[str] = []
    last = 0
    for m in JSON_KEY.finditer(body):
        parts.append(body[last:m.start()])
        counter["i"] += 1
        # Preserve the trailing colon and any whitespace immediately before it
        # (the regex's ``\s*:`` consumes trailing whitespace before the colon).
        parts.append(f'"{counter["i"]}":')
        last = m.end()
    parts.append(body[last:])
    new_body = "".join(parts)
    return new_body, counter["i"]


# --------------------------------------------------------------------------- #
# Per-file rewrite
# --------------------------------------------------------------------------- #

@dataclass
class FileStats:
    name: str
    literals_scanned: int = 0
    blank_groups_replaced: int = 0
    jsonb_literals_scanned: int = 0
    jsonb_keys_renumbered: int = 0
    changed: bool = False
    errors: list[str] = field(default_factory=list)


def rewrite_file(path: Path) -> FileStats:
    stats = FileStats(name=path.name)
    original = path.read_text(encoding="utf-8")

    # Fast-path idempotency check.
    if "______" not in original and "blank-q" not in original:
        return stats

    tokens = tokenize(original)
    out_parts: list[str] = []
    cursor = 0
    for tok in tokens:
        if tok.kind == "literal":
            stats.literals_scanned += 1
            body = tok.body
            new_body, n_groups = rewrite_underscores(body)
            if tok.is_jsonb:
                stats.jsonb_literals_scanned += 1
                new_body, n_keys = rewrite_jsonb_keys(new_body)
                stats.jsonb_keys_renumbered += n_keys
            stats.blank_groups_replaced += n_groups
            if new_body != body:
                stats.changed = True
                prefix = tok.prefix
                literal_text = f"{prefix}'{new_body}'"
                # Preserve any tail (e.g. ``::jsonb`` cast) verbatim.
                tail = original[tok.start + len(prefix) + 1 + len(body) + 1 : tok.end]
                out_parts.append(literal_text + tail)
            else:
                out_parts.append(original[tok.start : tok.end])
        else:
            out_parts.append(original[tok.start : tok.end])
        cursor = tok.end

    if cursor < len(original):
        out_parts.append(original[cursor:])

    if not stats.changed:
        return stats

    new_text = "".join(out_parts)

    # Round-trip integrity: same number of string literals (didn't drop quotes).
    if len(STRING_LITERAL.findall(original)) != len(STRING_LITERAL.findall(new_text)):
        stats.errors.append(
            "string-literal count mismatch after rewrite; refusing to write"
        )
        return stats

    path.write_text(new_text, encoding="utf-8")
    return stats


# --------------------------------------------------------------------------- #
# Driver
# --------------------------------------------------------------------------- #


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--seeds-dir",
        default="deploy/seeds",
        help="Path to the seeds directory (default: deploy/seeds)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Scan and report, but do not write any files",
    )
    args = parser.parse_args(argv)

    seeds_dir = Path(args.seeds_dir)
    if not seeds_dir.is_dir():
        print(f"ERROR: seeds directory not found: {seeds_dir}", file=sys.stderr)
        return 2

    candidates = sorted(
        p for p in seeds_dir.iterdir()
        if p.is_file() and p.suffix == ".sql" and is_target(p)
    )

    print(f"# scanning {len(candidates)} target seed files in {seeds_dir}")
    grand_changed = 0
    grand_groups = 0
    grand_keys = 0
    error_count = 0

    for path in candidates:
        if args.dry_run:
            original = path.read_text(encoding="utf-8")
            if "______" not in original and "blank-q" not in original:
                continue
            tokens = tokenize(original)
            groups = sum(
                len(BLANK_GROUP.findall(tok.body)) for tok in tokens
            )
            keys = sum(
                len(JSON_KEY.findall(tok.body))
                for tok in tokens
                if tok.is_jsonb
            )
            if groups or keys:
                print(
                    f"[dry-run] {path.name}: {groups} blank groups, {keys} keys"
                )
                grand_groups += groups
                grand_keys += keys
            continue

        stats = rewrite_file(path)
        if stats.errors:
            for err in stats.errors:
                print(f"  ERROR {path.name}: {err}", file=sys.stderr)
            error_count += 1
            continue
        if stats.changed:
            grand_changed += 1
            grand_groups += stats.blank_groups_replaced
            grand_keys += stats.jsonb_keys_renumbered
            print(
                f"{path.name}: {stats.blank_groups_replaced} blank groups -> [{stats.blank_groups_replaced} placeholders], "
                f"{stats.jsonb_keys_renumbered} jsonb keys renumbered"
            )

    print()
    print(f"TOTAL: {grand_changed} files updated, {error_count} errors")
    print(f"       {grand_groups} blank placeholders rewritten")
    print(f"       {grand_keys} jsonb keys renumbered (1..N ordinal)")
    if args.dry_run:
        print("(dry-run mode — no files written)")

    return 0 if error_count == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())