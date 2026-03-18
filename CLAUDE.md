# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Langfens is an IELTS learning platform built as microservices. Phase 1 (complete) covers 4-skill IELTS training with AI grading. Phase 2 (in progress, deadline May 29, 2026) adds "Adaptive AI Tutor" — 3 RAG-powered modules using fine-tuned Gemini 2.5 Flash Lite + Qdrant vector DB.

## Quick Start

```bash
# Local development (builds from source)
cd deploy
docker compose -f compose.local.yaml up -d

# Access API Gateway at http://localhost:5000
# Qdrant dashboard at http://localhost:6333/dashboard
```

## Architecture

- **API Gateway** (YARP, port 5000): Routes `/api-{service}/*` → `{service}:8080/api/*`, JWT validation, CORS
- **13 .NET microservices** (.NET 8, Minimal APIs, EF Core + PostgreSQL per service)
- **1 Python AI service** (FastAPI, port 8092): Qdrant, Gemini embeddings, RAG
- **Messaging**: RabbitMQ + MassTransit for async events (e.g., `WritingSubmitted`)
- **Infrastructure**: PostgreSQL 16, Redis 7.4, Qdrant v1.13.6, RabbitMQ

## .NET Service Code Pattern

All .NET services follow the same structure:
```
services/{name}/
├── Application/          # Business logic, common utilities
├── Contracts/            # DTOs, request/response models
├── Domain/               # Entities, enums
├── Features/             # Feature folders with Endpoint + Handler + Service
│   └── RabbitMq/         # MassTransit consumers
├── Infrastructure/       # DbContext, external service clients
├── Migrations/           # EF Core migrations (auto-applied on startup)
└── Program.cs            # DI setup, middleware, endpoint mapping
```

**Endpoint pattern**: `MapGroup("/api/{resource}")` with `.RequireAuthorization(Scope)` policies.

**Authorization**: Scope-based via `Shared.Security` — each service defines its own scope constants, validated with `HasAnyScope()`.

## Shared Libraries (`services/_shared/`)

- **Shared.Security**: JWT claim constants, scope validation, role constants
- **Shared.PublicContracts**: Cross-service event DTOs (`WritingGradingResponse`, `UserRegisteredOtp`), domain enums
- **Shared.Grpc**: Internal service-to-service gRPC contracts

## AI Service (`services/ai-service/`)

Python 3.12 + FastAPI. Key files:
- `app/config.py` — Pydantic settings (Qdrant, Gemini, Redis, data paths)
- `app/services/embedding_service.py` — Gemini text-embedding-004 wrapper (768-dim)
- `app/services/ingestion_service.py` — Auto-ingests JSONL data into Qdrant on startup
- `app/routers/` — Health check, embedding endpoint

**Qdrant collections**: `writing_samples` (12,339 Band 7+ essays), `grammar_knowledge` (5,659 corrections)

**Data**: JSONL files in `data/rag/`, mounted read-only at `/app/data/rag/` in container.

## Key Event Flows

- `WritingSubmitted` → Writing Service grades via GPT-4o → publishes `WritingGraded`
- `SpeakingGraded` → Attempt Service records results
- `UserRegistered` → Gamification + Email services

## Environment Configuration

Per-service `.env` files in `deploy/envs/`. Key variables:
- `JwtSettings__*` — JWT signing configuration
- `CONNECTIONSTRING__*` — PostgreSQL connection strings
- `RABBITMQ__*` — RabbitMQ host/credentials
- `GEMINI_API_KEY` — For AI service embedding/inference

## Docker Compose Files

- `deploy/compose.local.yaml` — Local dev (builds from source, includes all infrastructure)
- `deploy/compose.yaml` — Production (pulls from Docker Hub)

## CI/CD

GitHub Actions on push to `master`: build → push Docker Hub (SHA tag) → SSH deploy to Azure VM.

## Service Ports

| Service | Port | Service | Port |
|---------|------|---------|------|
| Gateway | 5000 | Writing | 8091 |
| Auth | 8080 | AI | 8092 |
| Attempt | 8081 | Vocabulary | 8093 |
| Exam | 8082 | Dictionary | 8094 |
| Speaking | 8090 | Gamification | 8096 |

## Phase 2 Technical Decisions

- All 3 AI modules use **Gemini 2.5 Flash Lite fine-tuned** (no GPT-4o for Phase 2 AI)
- **Embedding**: Gemini text-embedding-004 (768-dim)
- **Vector DB**: Qdrant (single container)
- **Communication**: REST via YARP Gateway (not gRPC for AI calls)
- **Writing flow**: ADDITIVE — existing grading stays, RAG comparison added after
- **LangChain**: Used as library, not framework
- **Dataset**: `/home/khoa/dataset_ielts/` — 41,146 essays, pre-filtered and exported to JSONL
