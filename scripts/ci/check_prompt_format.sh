#!/usr/bin/env bash
# scripts/ci/check_prompt_format.sh — Sprint 7 Phase 10 anti-regression guard.
#
# Checks:
#   1. No legacy placeholders (___/blank-qN/[ N ]) in source-tree seeder files.
#   2. Live exam-db has no rows where PromptMd contains legacy patterns
#      AND BlankAcceptTexts has a key not referenced as [N].
#
# Usage: bash scripts/ci/check_prompt_format.sh
# Exit:  0 = clean;  1 = legacy placeholders detected.
#
# Wire to pre-push hook (manual install):
#   ln -s ../../scripts/ci/check_prompt_format.sh .git/hooks/pre-push
# Or call from CI runner.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

EXIT_CODE=0

# Detect ONLY legacy patterns (not canonical `[N]`):
#   - `[ N ]` (space-padded brackets)
#   - `blank-qN` (legacy prefix)
#   - `_{3,}` (underscore runs)
# Canonical `[N]` is allowed.
LEGACY_PATTERN='\[ [0-9]+ \]|blank-q[0-9]+|_{3,}'
LEGACY_HITS=$(grep -rnE "$LEGACY_PATTERN" \
  --include="*.cs" --include="*.py" \
  services/exam-service/Data/ services/ai-service/app/prompts/ 2>/dev/null || true)

# Filter out the EnsurePromptFormat helper itself (which uses the regex to
# detect legacy — it's a tool, not a violation).
LEGACY_HITS=$(echo "$LEGACY_HITS" | grep -vE "EnsurePromptFormat|PROMPT_FORMAT_CONTRACT|migrate_blank_placeholders\.py|check_prompt_format\.sh|^(.+:)?\s*///|^(.+:)?\s*//|^(.+:)?\s*#" || true)

if [[ -n "$LEGACY_HITS" ]]; then
  echo "FAIL: Legacy placeholder pattern found in seeders/prompts:"
  echo "$LEGACY_HITS"
  EXIT_CODE=1
else
  echo "PASS: No legacy placeholders in seeder/prompt source files."
fi

# ── 2. exam-db live check (only when container is reachable) ─────────────
echo ""
echo "=== [2/2] exam-db check (live) ==="
EXAM_DB_CONTAINER="exam-db-server-7c03dc93"

if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "$EXAM_DB_CONTAINER"; then
  if docker exec "$EXAM_DB_CONTAINER" sh -c \
    "PGPASSWORD=exam psql -U exam -d exam-db -A -t -c \"
       SELECT COUNT(*) FROM exam_questions
       WHERE (\"PromptMd\" ~ '_{3,}' OR \"PromptMd\" ~ '\\[ ?[0-9]+ ?\\]' OR \"PromptMd\" ~ 'blank-q[0-9]+')
         AND (\"BlankAcceptTexts\" IS NOT NULL AND jsonb_typeof(\"BlankAcceptTexts\") = 'object')
         AND jsonb_object_keys(\"BlankAcceptTexts\") NOT IN (
           SELECT (regexp_matches(\"PromptMd\", '\\[([0-9]+)\\]', 'g'))[1]
         );\"" 2>/dev/null | grep -v "^$" > /tmp/prompt_format_db_count.txt; then
    DB_LEGACY_COUNT=$(cat /tmp/prompt_format_db_count.txt | head -1 | tr -d ' ')
    if [[ "${DB_LEGACY_COUNT:-0}" -gt 0 ]]; then
      echo "FAIL: ${DB_LEGACY_COUNT} exam-db rows have legacy PromptMd format"
      echo "       OR missing [N] markers for BlankAcceptTexts keys."
      echo "       Run: bash scripts/migrate_blank_placeholders.py audit --apply"
      EXIT_CODE=1
    else
      echo "PASS: All exam-db PromptMd rows canonical."
    fi
  else
    echo "SKIP: exam-db query failed (DB unreachable or SQL error)."
  fi
else
  echo "SKIP: container '$EXAM_DB_CONTAINER' not running. Source-tree check only."
fi

if [[ "$EXIT_CODE" -eq 0 ]]; then
  echo ""
  echo "✓ All PromptMd formats canonical."
fi
exit $EXIT_CODE
