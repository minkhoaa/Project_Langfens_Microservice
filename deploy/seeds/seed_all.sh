#!/usr/bin/env bash
set -euo pipefail

# This script seeds all databases except auth using localhost-mapped ports.
# It prefers local psql; if not available, it will run dockerized psql with --network host (Linux).
# Usage:
#   bash deploy/seeds/seed_all.sh

DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE="postgres:16-alpine"

have_psql=0
if command -v psql >/dev/null 2>&1; then
  have_psql=1
fi

run_psql() {
  local host="$1" port="$2" user="$3" pass="$4" db="$5" file="$6"
  echo "Seeding $db on $host:$port from $(basename "$file")"
  if [[ $have_psql -eq 1 ]]; then
    PGPASSWORD="$pass" psql -h "$host" -p "$port" -U "$user" -d "$db" -v ON_ERROR_STOP=1 -f "$file"
  else
    # Requires Docker; --network host works on Linux. On macOS/Windows, install psql locally.
    docker run --rm --network host -e PGPASSWORD="$pass" \
      -v "$DIR:/seeds:ro" "$IMAGE" \
      psql -h "$host" -p "$port" -U "$user" -d "$db" -v ON_ERROR_STOP=1 -f "/seeds/$(basename "$file")"
  fi
}

# Use localhost and ports mapped in deploy/compose.yaml
run_psql 127.0.0.1 5433 exam       exam       exam-db       "$DIR/seed_exam.sql"
run_psql 127.0.0.1 5436 course     course     course-db     "$DIR/seed_course.sql"
run_psql 127.0.0.1 5437 vocabulary vocabulary vocabulary-db "$DIR/seed_vocabulary.sql"
run_psql 127.0.0.1 5435 attempt    attempt    attempt-db    "$DIR/seed_attempt.sql"

echo "All seeds applied successfully."