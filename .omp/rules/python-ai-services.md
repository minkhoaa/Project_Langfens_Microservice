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
- Follow each service's existing schema/contract modules (`app/schemas.py`, router models, and `app/contracts/`); do not force all models into a new central file.
- Validate request/response boundaries with Pydantic v2 and existing field constraints.
- Keep runtime models distinct from `generation_baseline` target specifications; planned research gates are not proof of deployed behavior.
- Keep request, update, and response schemas cleanly separated.
- Never leak sensitive credentials, internal prompt rubrics, or API keys in response models.

## 3. Vector Search & RAG (Qdrant)
- Qdrant client singleton managed through factory (`qdrant_factory.py`).
- Embedding vector size must match configured dimensions (default 1024 for BGE-M3).
- Reuse existing Redis key construction and invalidation. Do not truncate vectors to invent cache keys or add speculative caching.
- Preserve explicit failure semantics; do not turn Qdrant/LLM failures into fabricated successful results.

## 4. LLM Providers & Cost Guardrails
- Reuse `ai-service` provider services and `generation-service` adapters/facades; current providers include Groq, MiniMax, and OpenAI-compatible APIs. Ollama supplies local embedding/model capabilities.
- Preserve configured routing, key rotation, and cooldown behavior; never log provider secrets or change provider priority as incidental cleanup.
- Enforce token budgets, max completion tokens, and prompt truncation before dispatch.

## 5. Generation Service Runtime Caps (R03 / G06)
- `deploy/envs/loop-caps.env` is the authoritative versioned deployment profile; production must fail closed on missing/invalid required caps.
- Current loop and benchmark-child ceilings are 15 calls / 60,000 tokens / 300 seconds. Whole-paper, legacy, and benchmark-section budgets are separate; never apply child ceilings indiscriminately.
- Pin canonical sorted-JSON cap snapshots and SHA-256 integrity at run creation; resumes retain original caps and counters despite deployment changes.
- Preserve configured passage word bounds rather than copying illustrative defaults from generic skills.
- Passages and questions must undergo independent, adversarial review before acceptance.
