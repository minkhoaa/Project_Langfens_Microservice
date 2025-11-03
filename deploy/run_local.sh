#!/usr/bin/env bash
set -euo pipefail

# Paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/compose.yaml"

echo "[run_local] Bringing up docker-compose stack (may take a few minutes on first run)..."
docker compose -f "$COMPOSE_FILE" up -d

# psql checker: host psql if available; else dockerized psql
psql_cmd() {
  local host="$1" port="$2" user="$3" pass="$4" db="$5"
  if command -v psql >/dev/null 2>&1; then
    PGPASSWORD="$pass" psql -h "$host" -p "$port" -U "$user" -d "$db" -c 'SELECT 1' >/dev/null 2>&1
  else
    # Linux: cần --network host để container thấy cổng publish 127.0.0.1:PORT của host
    if [[ "$OSTYPE" == linux* ]]; then
      docker run --rm --network host -e PGPASSWORD="$pass" postgres:16-alpine \
        psql -h "$host" -p "$port" -U "$user" -d "$db" -c 'SELECT 1' >/dev/null 2>&1
    else
      # Windows/macOS: dùng host.docker.internal
      local docker_host="$host"
      if [[ "${OS:-}" == "Windows_NT" || "$OSTYPE" == msys* || "$OSTYPE" == cygwin* || "$OSTYPE" == darwin* ]]; then
        docker_host="host.docker.internal"
      fi
      docker run --rm -i -e PGPASSWORD="$pass" postgres:16-alpine \
        psql -h "$docker_host" -p "$port" -U "$user" -d "$db" -c 'SELECT 1' >/dev/null 2>&1
    fi
  fi
}


wait_db() {
  local name="$1" host="$2" port="$3" user="$4" pass="$5" db="$6"
  echo "[run_local] Waiting for $name at $host:$port ..."
  for i in {1..60}; do
    if psql_cmd "$host" "$port" "$user" "$pass" "$db"; then
      echo "[run_local] $name is reachable."
      return 0
    fi
    sleep 2
  done
  echo "[run_local] Warning: $name not reachable after waiting. Continuing..."
}

# Mapped ports per compose.yaml
wait_db exam-db        127.0.0.1 5433 exam       exam       exam-db
wait_db attempt-db     127.0.0.1 5435 attempt    attempt    attempt-db
wait_db course-db      127.0.0.1 5436 course     course     course-db
wait_db vocabulary-db  127.0.0.1 5437 vocabulary vocabulary vocabulary-db

# Seed with absolute path; pass REPO_ROOT if seed script cần
bash "$SCRIPT_DIR/seeds/seed_all.sh" "$REPO_ROOT"

echo "[run_local] Done. Services are up and databases have been seeded."
echo "[run_local] Gateway:         http://localhost:5000"
echo "[run_local] Auth service:    http://localhost:8080"
echo "[run_local] Attempt service: http://localhost:8081"
echo "[run_local] Exam service:    http://localhost:8082"
echo "[run_local] Course service:  http://localhost:8083"
echo "[run_local] Vocabulary svc:  http://localhost:8087"
