#!/usr/bin/env bash
# Restarts attempt-service with the right AI_SERVICE_URL pointing at the
# currently-running ai-service container's host port.
#
# Use this when running attempt-service standalone (not via Aspire) so
# the RAG explainer can actually reach the ai-service.
set -euo pipefail

# 1. Find the live ai-service container (ignore stopped/exited ones)
AI_CID=$(docker ps --filter "ancestor=ai-service" -q | head -1)
if [[ -z "$AI_CID" ]]; then
  echo "ERROR: no running ai-service container found. Start Aspire first." >&2
  exit 1
fi

# 2. Extract the dynamically-allocated host port for container port 8080
AI_HOST_PORT=$(docker port "$AI_CID" 8080/tcp | head -1 | awk -F: '{print $NF}')
if [[ -z "$AI_HOST_PORT" ]]; then
  echo "ERROR: ai-service container has no host port for 8080" >&2
  exit 1
fi

echo "ai-service host port: $AI_HOST_PORT"

# 3. Kill the old attempt-service if running
pkill -f "attempt-service/attempt-service.csproj" 2>/dev/null || true
pkill -f "bin/Debug/net10.0/attempt-service$" 2>/dev/null || true
sleep 1

# 4. Start attempt-service with the right URL
cd "$(dirname "$0")/../services/attempt-service"
exec env \
  EXAMSERVICE__INTERNAL__API__KEY=dev-internal-key-not-for-prod \
  EXAMSERVICE__EXAM__ADDRESS=http://localhost:5433 \
  RABBITMQ__HOST=localhost RABBITMQ__USERNAME=guest RABBITMQ__PASSWORD=guest \
  RABBITMQ__VHOST=/ RABBITMQ__PORT=5672 RABBITMQ__USESSL=false \
  AI_SERVICE_URL="http://127.0.0.1:${AI_HOST_PORT}" \
  dotnet run
