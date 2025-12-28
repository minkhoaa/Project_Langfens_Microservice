#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
COMPOSE_FILE="${REPO_ROOT}/deploy/compose.yaml"
SEED_FILE="${REPO_ROOT}/deploy/seeds/seed_achievements.sql"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required to run this script." >&2
  exit 1
fi

if [[ ! -f "${SEED_FILE}" ]]; then
  echo "Missing seed file: ${SEED_FILE}" >&2
  exit 1
fi

echo "Seeding achievements into gamification database..."
echo "  - Source: $(basename "${SEED_FILE}")"
echo ""

# Apply SQL file using docker exec
docker compose -f "${COMPOSE_FILE}" exec -T gamification-database \
  psql -U gamification -d gamification-db <"${SEED_FILE}" 2>&1 \
  | grep -E "^(BEGIN|COMMIT|DELETE|INSERT|ERROR|psql:)" || true

echo ""
echo "✓ Achievements seed completed!"
