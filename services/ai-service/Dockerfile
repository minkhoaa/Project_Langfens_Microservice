# Multi-stage Dockerfile for Langfens AI service.
# For rapid local dev and Aspire orchestration, derive directly from the local base image
# (langfens-ai-base:latest) which contains PyTorch CPU, transformers, faster-whisper, etc.
# This prevents 10-minute download timeouts when Aspire recalculates the context hash.
# To regenerate or build the base image from scratch:
#   docker build -t langfens-ai-base:latest -f services/ai-service/Dockerfile.base .
ARG BASE_IMAGE=langfens-ai-base:latest

FROM ${BASE_IMAGE} AS runtime
WORKDIR /app
COPY services/ai-service/app ./app
EXPOSE 8080
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
