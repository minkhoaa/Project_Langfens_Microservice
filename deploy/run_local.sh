set -euo pipefail

# One-command local runner: builds services, brings the stack up, then seeds all non-auth DBs.
# Usage (from repo root):
#   bash deploy/run_local.sh

COMPOSE_FILE="$(cd "$(dirname "$0")" && pwd)/compose.yaml"

# 1) Build and start all services
echo "[run_local] Bringing up docker-compose stack (may take a few minutes on first run)..."
docker compose -f "$COMPOSE_FILE" up -d 

# 2) Wait for DBs to be reachable on localhost (no jq required)
#    We'll try connecting using psql (local if available, otherwise via dockerized psql with --network host)
psql_cmd() {
  local host="$1" port="$2" user="$3" pass="$4" db="$5"
  if command -v psql >/dev/null 2>&1; then
    PGPASSWORD="$pass" psql -h "$host" -p "$port" -U "$user" -d "$db" -c 'SELECT 1' >/dev/null 2>&1
  else
    docker run --rm --network host -e PGPASSWORD="$pass" postgres:16-alpine \
      psql -h "$host" -p "$port" -U "$user" -d "$db" -c 'SELECT 1' >/dev/null 2>&1
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

# Mapped ports per deploy/compose.yaml
wait_db exam-db        127.0.0.1 5433 exam       exam       exam-db
wait_db attempt-db     127.0.0.1 5435 attempt    attempt    attempt-db
wait_db course-db      127.0.0.1 5436 course     course     course-db
wait_db vocabulary-db  127.0.0.1 5437 vocabulary vocabulary vocabulary-db

# 3) Seed all non-auth databases (against localhost ports)
bash "$(cd "$(dirname "$0")" && pwd)/seeds/seed_all.sh"

echo "[run_local] Done. Services are up and databases have been seeded."
echo "[run_local] Gateway:        http://localhost:5000"
echo "[run_local] Auth service:   http://localhost:8080"
echo "[run_local] Attempt service: http://localhost:8081"
echo "[run_local] Exam service:    http://localhost:8082"
echo "[run_local] Course service:  http://localhost:8083"
echo "[run_local] Vocabulary svc:  http://localhost:8087"