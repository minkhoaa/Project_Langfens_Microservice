#!/bin/bash
set -e

echo "Stopping old generation-service..."
pkill -f "uvicorn app.main:app.*8085" || true
sleep 1

echo "Stopping any running exam-service..."
pkill -f "exam-service" || true
sleep 1

echo "Starting updated generation-service on port 8085..."
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/generation-service
nohup env \
  $(grep -v '^#' /home/khoa/Projects/langfens/Project_Langfens_Microservice/deploy/envs/loop-caps.env | xargs) \
  MINIMAX_MODEL="MiniMax-Text-01" \
  EXAMSERVICE__EXAM__ADDRESS="http://127.0.0.1:42933" \
  LOOP_OPERATION_WALL_RESERVATION_SECONDS="120" \
  EXAM_SERVICE_URL="http://127.0.0.1:42933" \
  LLM_PROVIDER_ORDER="minimax" \
  EXAMSERVICE_URL="http://127.0.0.1:42933" \
  MINIMAX_BASE_URL="https://api.minimaxi.chat/v1" \
  INTERNAL_API_KEY="internal-get-exam-snapshot" \
  EXAMSERVICE__INTERNAL__API__KEY="internal-get-exam-snapshot" \
  MINIMAX_API_KEY="$(grep -E '^MINIMAX_API_KEY=' /home/khoa/Projects/langfens/Project_Langfens_Microservice/deploy/envs/ai.env | cut -d= -f2-)" \
  .venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8085 > /tmp/generation_service.log 2>&1 &

echo "Starting updated exam-service on ports 34947 and 42933..."
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/exam-service
nohup env \
  $(grep -v '^#' /home/khoa/Projects/langfens/Project_Langfens_Microservice/deploy/envs/loop-caps.env | xargs) \
  ConnectionStrings__exam-db="Host=127.0.0.1;Port=5433;Database=exam-db;Username=exam;Password=exam" \
  ASPNETCORE_URLS="http://0.0.0.0:34947;http://127.0.0.1:42933" \
  Kestrel__HttpPort="34947" \
  GENERATION_SERVICE_URL="http://127.0.0.1:8085" \
  READING_PAPER_ENGINE="v2" \
  CANARY_PERCENTAGE="100" \
  INTERNAL_API_KEY="internal-get-exam-snapshot" \
  EXAMSERVICE__INTERNAL__API__KEY="internal-get-exam-snapshot" \
  ExamService__Exam_Internal_Api_Key="internal-get-exam-snapshot" \
  JwtSettings__Issuer="IssuerName" \
  JwtSettings__Audience="AudienceName" \
  JwtSettings__SignKey="bTNGPmniBGyINHPdsmONct16TIqqb1bZ" \
  LOOP_CAPS_PROFILE_SOURCE="deploy/envs/loop-caps.env" \
  LOOP_CAPS_PROFILE_VERSION="phase13-production-v1" \
  dotnet bin/Debug/net10.0/exam-service.dll > /tmp/exam_service.log 2>&1 &
echo "Waiting for services to become healthy..."
sleep 4
