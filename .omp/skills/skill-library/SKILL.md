---
name: skill-library
description: Quick-reference router mapping daily stack skills vs searchable ECC library skills for Langfens.
---

# Langfens Skill Library & Router

This router maps daily active engineering skills vs searchable ECC reference skills for the Langfens repository.

## 1. Daily Core Skills (Always Applicable)

Use these skills directly during everyday development:

- `dotnet-patterns`: .NET 10, C# 13, Minimal APIs, EF Core, async/await idioms.
- `csharp-testing`: xUnit, AwesomeAssertions, Moq, WebApplicationFactory integration testing.
- `fastapi-patterns`: Python 3.12, FastAPI async routers, Pydantic v2 schemas, dependencies.
- `python-testing`: pytest, pytest-asyncio, mocking async generators and I/O.
- `postgres-patterns`: PostgreSQL schema design, indexing, connection pooling, EF Core Npgsql.
- `database-migrations`: EF Core safe migrations, forward-only schema transitions.
- `redis-patterns`: Distributed caching, key expiration, session stores.
- `docker-patterns`: Multi-stage Dockerfiles, Docker Compose optimization.
- `backend-patterns`: Microservice communication, gRPC, event-driven architecture with MassTransit.
- `security-review`: OWASP Top 10, JWT RS256 validation, secret protection, SSRF prevention.
- `tdd-workflow`: Test-driven development loop (Red -> Green -> Refactor).
- `verification-loop`: Pre-yield validation (build, lint, tests, verification).

## 2. Project-Specific Skills

Custom workflows designed specifically for this repository:

- `langfens-aspire`: Running and extending Aspire AppHost orchestration and YARP gateway.
- `langfens-grader`: Building and testing IELTS question auto-graders in attempt-service.
- `langfens-service-setup`: 7-step guide to scaffolding and wiring a new microservice.
- `langfens-generation`: Autonomous reading paper generation loop and runtime cap invariants.

## 3. Searchable Library Skills (On-Demand)

Reachable when specialized domain needs arise:

- `cost-aware-llm-pipeline`: Managing LLM token usage and fallback provider cooldowns.
- `prompt-caching-strategy`: Prompt caching optimization for LLM evaluators.
- `eval-harness`: Offline capability and regression evals for AI models.
- `latency-critical-systems`: Sub-second streaming audio and NDJSON pipeline tuning.
- `architecture-decision-records`: Numbered ADRs in `docs/adr/`.
- `conventional-commit-review`: Conventional commit message formatting.
- `git-workflow`: Branch hygiene and PR preparation.
