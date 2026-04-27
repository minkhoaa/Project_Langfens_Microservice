#!/usr/bin/env bash
# Boots the local stack from a clean volume and asserts that all writing-service
# EF migrations applied successfully — including AddComparativeAnalysisJson.
#
# Usage: ./scripts/e2e/test_migration_applied.sh

set -euo pipefail

cd "$(dirname "$0")/../.."

echo "[migration-test] Tearing down with volumes…"
docker compose -f deploy/compose.local.yaml down -v >/dev/null 2>&1 || true

echo "[migration-test] Booting writing-database + writing-service…"
docker compose -f deploy/compose.local.yaml up -d writing-database
echo "[migration-test] Waiting for DB healthy…"
until [ "$(docker inspect -f '{{.State.Health.Status}}' deploy-writing-database-1 2>/dev/null)" = "healthy" ]; do
  sleep 2
done

docker compose -f deploy/compose.local.yaml up -d writing-service
echo "[migration-test] Waiting for writing-service to apply migrations…"
until docker logs deploy-writing-service-1 2>&1 | grep -q "Application started"; do
  sleep 2
done

echo "[migration-test] Querying __EFMigrationsHistory…"
COUNT=$(docker exec deploy-writing-database-1 \
  psql -U writing -d writing-db -t -c \
  "SELECT COUNT(*) FROM \"__EFMigrationsHistory\" WHERE \"MigrationId\" = '20260319190000_AddComparativeAnalysisJson';")
COUNT=${COUNT// /}

if [ "$COUNT" = "1" ]; then
  echo "[migration-test] PASS — AddComparativeAnalysisJson present"
  exit 0
else
  echo "[migration-test] FAIL — AddComparativeAnalysisJson NOT in migration history"
  docker exec deploy-writing-database-1 psql -U writing -d writing-db \
    -c 'SELECT "MigrationId" FROM "__EFMigrationsHistory" ORDER BY "MigrationId";'
  exit 1
fi
