---
description: FastAPI async patterns, Pydantic v2 validation, Qdrant vector retrieval, Redis caching, and generation pipeline caps for Python services.
globs:
  - "services/ai-service/**/*.py"
  - "services/generation-service/**/*.py"
  - "generation_baseline/**/*.py"
  - "**/requirements*.txt"
---

# Python AI Services & Generation Pipeline Rules

## 1. FastAPI Architecture
- Application factory or lifespan pattern in `app/main.py`.
- Endpoints organized into modular `APIRouter` instances with explicit `prefix` and `tags`.
- Every I/O operation (HTTP, Redis, Qdrant, OpenAI, Groq) must use `async def` and non-blocking clients (`httpx.AsyncClient`).
- Sync, CPU-intensive, or blocking calls (ASR `faster-whisper`, large text parsing) must run in thread pools via `asyncio.to_thread` or `ThreadPoolExecutor`.

## 2. Pydantic v2 Schemas & Data Contracts
- Define all request and response models in `app/schemas.py`.
- Enforce strict typing with field constraints:
  ```python
  class GenerateSectionRequest(BaseModel):
      topic: str = Field(..., min_length=3, max_length=120)
      word_count_target: int = Field(default=800, ge=650, le=950)
  ```
- Keep request, update, and response schemas cleanly separated.
- Never leak sensitive credentials, internal prompt rubrics, or API keys in response models.

## 3. Vector Search & RAG (Qdrant)
- Qdrant client singleton managed through factory (`qdrant_factory.py`).
- Embedding vector size must match configured dimensions (default 1024 for BGE-M3).
- Implement Redis caching on vector queries using SHA256 hashes of truncated vectors + filter criteria to minimize redundant vector calculations.
- Handle Qdrant downtime gracefully with circuit breakers or sensible fallback defaults.

## 4. LLM Providers & Cost Guardrails
- Route LLM calls through provider facades (`llm_service.py` / `groq_service.py` / `llm.py`).
- Implement key rotation (`GROQ_API_KEYS` comma-separated) and handle HTTP 429 rate limits with backoff cooldowns.
- Enforce token budgets, max completion tokens, and prompt truncation before dispatch.

## 5. Generation Service Runtime Caps (R03 / G06)
- Resource caps must be loaded from `deploy/envs/loop-caps.env` or explicit environment settings.
- Respect passage reservations (720–915 words) and question composition budget ceilings (60,000 tokens / 300s child limits).
- Maintain immutable run profiles with sorted JSON keys and SHA-256 integrity verification.
- Passages and questions must undergo independent, adversarial review before acceptance.
