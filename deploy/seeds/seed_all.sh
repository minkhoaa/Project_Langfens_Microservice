#!/usr/bin/env bash
set -e

SEEDS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SEEDS_DIR/../.." && pwd)"

echo "Applying: seed_achievements.sql"
docker run --rm --network backend -e PGPASSWORD=gamification \
  -v "$PROJECT_ROOT/deploy/seeds:/seeds:ro" postgres:16-alpine \
  psql -h gamification-database -p 5432 -U gamification -d gamification-db -v ON_ERROR_STOP=1 -f /seeds/seed_achievements.sql

for sql_file in $(ls "$SEEDS_DIR"/seed_exam_*.sql | sort); do
  filename="$(basename "$sql_file")"
  echo "Applying: $filename"
  docker run --rm --network backend -e PGPASSWORD=exam \
    -v "$PROJECT_ROOT/deploy/seeds:/seeds:ro" postgres:16-alpine \
    psql -h exam-database -p 5432 -U exam -d exam-db -v ON_ERROR_STOP=1 -f "/seeds/$filename"
done

echo "Applying: placement.sql"
docker run --rm --network backend -e PGPASSWORD=exam \
  -v "$PROJECT_ROOT/deploy/seeds:/seeds:ro" postgres:16-alpine \
  psql -h exam-database -p 5432 -U exam -d exam-db -v ON_ERROR_STOP=1 -f /seeds/placement.sql

echo "All seeds applied successfully."
