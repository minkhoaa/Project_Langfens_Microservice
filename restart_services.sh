#!/bin/bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Restarting generation-service on port 8085..."
if command -v systemctl >/dev/null 2>&1 && sudo systemctl is-enabled langfens-generation.service >/dev/null 2>&1; then
  sudo systemctl restart langfens-generation.service
else
  pkill -f "uvicorn app.main:app.*8085" || true
  sleep 1
  cd "$REPO_ROOT/services/generation-service"
  nohup env \
    $(grep -v '^#' "$REPO_ROOT/deploy/envs/loop-caps.env" | xargs) \
    MINIMAX_MODEL="MiniMax-Text-01" \
    EXAMSERVICE__EXAM__ADDRESS="${EXAM_SERVICE_URL:-http://127.0.0.1:5080}" \
    LOOP_OPERATION_WALL_RESERVATION_SECONDS="180" \
    EXAM_SERVICE_URL="${EXAM_SERVICE_URL:-http://127.0.0.1:5080}" \
    LLM_PROVIDER_ORDER="minimax" \
    EXAMSERVICE_URL="${EXAM_SERVICE_URL:-http://127.0.0.1:5080}" \
    MINIMAX_BASE_URL="https://api.minimaxi.chat/v1" \
    INTERNAL_API_KEY="${INTERNAL_API_KEY:-${EXAMSERVICE__INTERNAL__API__KEY:-internal-get-exam-snapshot}}" \
    EXAMSERVICE__INTERNAL__API__KEY="${INTERNAL_API_KEY:-${EXAMSERVICE__INTERNAL__API__KEY:-internal-get-exam-snapshot}}" \
    MINIMAX_API_KEY="$(grep -E '^MINIMAX_API_KEY=' "$REPO_ROOT/deploy/envs/ai.env" | cut -d= -f2-)" \
    python3 -m uvicorn app.main:app --host 127.0.0.1 --port 8085 > /tmp/generation_service.log 2>&1 &
fi

if curl -sf http://127.0.0.1:5080/health > /dev/null; then
  echo "Exam-service is already healthy under Aspire on port 5080."
else
  echo "Exam-service not responding on port 5080, checking standalone launch..."
  pkill -f "exam-service" || true
  sleep 1
  cd "$REPO_ROOT/services/exam-service"
  nohup env \
    $(grep -v '^#' "$REPO_ROOT/deploy/envs/loop-caps.env" | xargs) \
    ConnectionStrings__exam-db="${ConnectionStrings__exam_db:-${ConnectionStrings__exam-db:-Host=127.0.0.1;Port=5432;Database=exam-db;Username=langfens;Password=langfens}}" \
    ASPNETCORE_URLS="http://0.0.0.0:34947;http://127.0.0.1:42933;http://127.0.0.1:5080" \
    Kestrel__HttpPort="34947" \
    GENERATION_SERVICE_URL="http://127.0.0.1:8085" \
    READING_PAPER_ENGINE="v2" \
    CANARY_PERCENTAGE="100" \
    INTERNAL_API_KEY="${INTERNAL_API_KEY:-${EXAMSERVICE__INTERNAL__API__KEY:?INTERNAL_API_KEY required}}" \
    EXAMSERVICE__INTERNAL__API__KEY="${INTERNAL_API_KEY:-${EXAMSERVICE__INTERNAL__API__KEY:?INTERNAL_API_KEY required}}" \
    ExamService__Exam_Internal_Api_Key="${INTERNAL_API_KEY:-${EXAMSERVICE__INTERNAL__API__KEY:?INTERNAL_API_KEY required}}" \
    JwtSettings__Issuer="${JwtSettings__Issuer:-IssuerName}" \
    JwtSettings__Audience="${JwtSettings__Audience:-AudienceName}" \
    JwtSettings__SignKey="${JWT_SIGNING_KEY:-${JwtSettings__SignKey:?JwtSettings__SignKey or JWT_SIGNING_KEY required}}" \
    LOOP_CAPS_PROFILE_SOURCE="deploy/envs/loop-caps.env" \
    LOOP_CAPS_PROFILE_VERSION="phase13-production-v1" \
    dotnet bin/Release/net10.0/exam-service.dll > /tmp/exam_service.log 2>&1 &
fi

echo "Waiting for services to become healthy..."
sleep 4
