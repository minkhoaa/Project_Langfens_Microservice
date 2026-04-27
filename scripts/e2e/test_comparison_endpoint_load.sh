#!/usr/bin/env bash
# Hits GET /api-writing/writing/{submissionId}/comparison 100 times sequentially
# and asserts zero 500 responses. Catches regressions of the EF
# ManyServiceProvidersCreatedWarning bug (Defect #4).
#
# Usage: ./scripts/e2e/test_comparison_endpoint_load.sh

set -euo pipefail

GATEWAY=${GATEWAY:-http://localhost:5000}
EMAIL=${EMAIL:-e2e+writing@langfens.test}
PASSWORD=${PASSWORD:-E2eTest!2026}
N=${N:-100}

TOKEN=$(curl -s -X POST "${GATEWAY}/api-auth/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${EMAIL}\",\"password\":\"${PASSWORD}\"}" \
  | python3 -c "import sys,json;print(json.load(sys.stdin)['data'])")

# Use a deterministic UUID — the endpoint must return 204 (not 500) for unknown ids.
SUB_ID="00000000-0000-0000-0000-000000000001"

fail=0
for i in $(seq 1 "$N"); do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    "${GATEWAY}/api-writing/writing/${SUB_ID}/comparison" \
    -H "Authorization: Bearer ${TOKEN}")
  if [ "$CODE" -ge 500 ]; then
    echo "[load-test] FAIL request $i: HTTP $CODE"
    fail=$((fail+1))
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "[load-test] PASS — $N/$N requests returned <500"
  exit 0
else
  echo "[load-test] FAIL — $fail/$N requests returned 5xx"
  exit 1
fi
