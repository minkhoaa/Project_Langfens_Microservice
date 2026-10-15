# Langfens IELTS Preparation Platform — Engineering & Agent Guidelines

## System Overview

**Langfens** is an enterprise-grade IELTS preparation mono-repo combining full-exam simulations, AI evaluation, spaced-repetition vocabulary, and gamification.
The system is built on a distributed microservice architecture utilizing **.NET 10 (C# 13)** for transactional and domain services, and **Python 3.12 (FastAPI)** for AI inference, vector search, and autonomous paper generation.

---

## Architecture & Service Map

```text
Project_Langfens_Microservice/
├── gateway/api-gateway/          # YARP reverse proxy + JWT auth (port 5000)
├── AppHost/                      # .NET Aspire 9/10 orchestrator (local dev primary)
├── deploy/                       # Production compose.yaml & env configs
├── services/
│   ├── _shared/
│   │   ├── Shared.Bootstrap/     # AddLangfensAuth, AddLangfensCors, Kestrel config
│   │   ├── Shared.Grpc/          # Protobuf contracts & generated C# gRPC client/server
│   │   ├── Shared.PublicContracts/ # Shared Enums (QuestionType), DTOs across services
│   │   ├── Shared.Security/      # Roles, Scopes, Claims constants and helpers
│   │   └── Shared.ServiceDefaults/ # Aspire telemetry (OTel), health checks, resilience
│   ├── auth-service/             # Identity, JWT RS256, Redis sessions, OTP, MassTransit
│   ├── exam-service/             # Exam content, REST CRUD, ExamInternal gRPC server
│   ├── attempt-service/          # Exam attempts, IQuestionGrader engine, gRPC client, MT consumers
│   ├── writing-service/          # Writing assessment coordination, AI service client
│   ├── speaking-service/         # Speaking assessment coordination, ASR/AI client
│   ├── vocabulary-service/       # Flashcards, SM2 spaced repetition algorithm
│   ├── dictionary-service/       # Elasticsearch 8.19 word lookup & dictionary
│   ├── gamification-service/     # XP, user levels, achievements, daily streaks
│   ├── course-service/           # Structured courses, study plans, learning paths
│   ├── email-service/            # Transactional email delivery via MailKit/SMTP
│   ├── ai-service/               # Python/FastAPI: Groq/Ollama LLM, Qdrant RAG, faster-whisper ASR
│   └── generation-service/       # Python/FastAPI: Autonomous reading paper synthesis & review loop
└── tests/
    ├── services/exam-service.Tests/    # Exam integration & budget tests (xUnit)
    └── services/attempt-service.Tests/ # Question auto-grader invariant unit tests (xUnit)
```

---

## Technology Stack & Core Runtimes

| Component | Technology | Role |
|---|---|---|
| **Platform Runtime** | .NET 10.0 (C# 13) | Core microservices & gateway |
| **AI Runtime** | Python 3.12+ (FastAPI) | LLM evaluation, embeddings, ASR, RAG |
| **Local Orchestration** | .NET Aspire 9/10 (`AppHost`) | Process & container orchestration + Dashboard |
| **API Gateway** | YARP Reverse Proxy (.NET 10) | Edge routing, JWT validation, path transforms |
| **Database** | PostgreSQL (10 databases) | Isolated database per microservice schema |
| **ORM & Migrations** | EF Core 10 + Npgsql | Code-first migrations (`MigrateAsync` on startup) |
| **Message Broker** | RabbitMQ + MassTransit | Asynchronous event-driven messaging |
| **RPC / Internal** | gRPC (HTTP/2 protobuf) | High-speed answer-key lookups (attempt → exam) |
| **Vector Database** | Qdrant | RAG embeddings for writing & grammar criteria |
| **Search Engine** | Elasticsearch 8.19.0 | Dictionary lexical & full-text search |
| **Distributed Cache** | Redis | Auth session store & vector embedding cache |
| **Testing** | xUnit, AwesomeAssertions, Moq, pytest | Unit and integration verification suites |

---

## Core Engineering Rules & Invariants

### 1. Immutability & Modern Language Idioms
- **C#**: Prefer `sealed record` or `readonly record struct` for DTOs and contracts. Use `init` accessors. Never mutate domain models in-place. Use pattern matching and explicit nullable reference types (`string?`).
- **Python**: Use immutable Pydantic v2 schemas (`frozen=True` where appropriate). Prefer pure functions and explicit typing.

### 2. Microservice Boundaries & Database Isolation
- Each service strictly owns its database schema. Never cross-query another service's database directly.
- Communication across services must follow either:
  1. **gRPC** via `Shared.Grpc` (synchronous internal lookups, e.g., `attempt-service` calling `exam-service`).
  2. **MassTransit / RabbitMQ** (asynchronous event publication/consumption).
  3. **YARP Gateway / HTTP** with internal authorization policies (`[Authorize(Policy = InternalPolicy)]`).

### 3. Aspire Service Discovery & Dynamic Ports
- **NEVER hardcode host ports or connection strings.**
- Aspire assigns dynamic ports in local development. Use `.GetEndpoint("http")` and `.GetEndpoint("grpc")`.
- Services read RabbitMQ configuration via discrete environment variables:
  `RABBITMQ__HOST`, `RABBITMQ__PORT`, `RABBITMQ__USERNAME`, `RABBITMQ__PASSWORD`, `RABBITMQ__VHOST`, `RABBITMQ__USESSL`.
- AppHost injects configuration through `WithComposeEnvFile()` and `WithRabbitMqEnv()`.

### 4. API Design Pattern
- .NET services use the **Minimal API** pattern organized by feature: `Features/{Feature}/{Action}Endpoint.cs`.
- Registration: Extension methods like `app.MapXxxEndpoints()` in `Program.cs`.
- Consistent response envelopes with appropriate HTTP status codes (200, 201, 400, 404, 409, 422).

### 5. Grader Architecture (`attempt-service`)
- All question grading follows the Strategy pattern:
  - Implement `IQuestionGrader` in `attempt-service/Features/Helpers/{Type}Grader.cs`.
  - Register via `IQuestionGraderRegistration` singleton in `{Type}GraderRegistration.cs`.
  - Resolved dynamically by `QuestionGraderFactory`.
  - Graders must remain purely deterministic, idempotent, and free of side-effects.

### 6. AI & Generation Services (`ai-service` & `generation-service`)
- Use async FastAPI endpoints (`async def`) for all I/O operations.
- Heavy CPU operations (Whisper transcription, text parsing) must run in thread pools.
- Respect runtime caps and budget ceilings (`deploy/envs/loop-caps.env`, R03/G06 invariants).
- Adhere to Pydantic validation at system boundaries.

---

## Specialized Agent Roster

Use these specialized agents for targeted engineering tasks:

| Agent | Scope & Purpose |
|---|---|
| `csharp-reviewer` | Deep review of C# 13, .NET 10, EF Core queries, async patterns, and nullable correctness. |
| `python-reviewer` | Deep review of Python 3.12 code, typing, async functions, and package best practices. |
| `fastapi-reviewer` | Review of FastAPI route definitions, Pydantic schemas, dependency injection, and OpenAPI. |
| `database-reviewer` | PostgreSQL schema design, EF Core migration safety, index efficiency, and query tuning. |
| `aspire-architect` | Project-local agent for Aspire `AppHost`, YARP route clusters, container topology, and env wiring. |
| `grader-specialist` | Project-local agent for IELTS question scoring algorithms, invariants, and `IQuestionGrader` additions. |
| `generation-loop-expert` | Project-local agent for reading paper synthesis loops, adversarial review, and runtime budget caps. |
| `security-reviewer` | OWASP Top 10, JWT RS256 validation, secret leaks, SSRF, and internal API key enforcement. |
| `tdd-guide` | Enforces test-first development (xUnit / pytest) ensuring 80%+ behavioral coverage. |
| `pr-test-analyzer` | Audits test suites for real bug prevention, boundary cases, and flaky async tests. |
| `performance-optimizer` | Bottleneck analysis in async pipelines, streaming NDJSON, vector search, and EF Core N+1 queries. |

---

## Development Workflows

### 1. Local Development via Aspire
```bash
# Start Aspire AppHost (Gateway on http://localhost:5000, Dashboard on http://localhost:18888)
dotnet run --project AppHost/AppHost.csproj
```

### 2. Building & Testing .NET Services
```bash
# Build the complete solution
dotnet build Project_Langfens_Microservice.sln

# Run unit tests (attempt-service tests run without external dependencies)
dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj

# Run exam tests (requires PostgreSQL container on port 5433 via Aspire or Compose)
dotnet test services/exam-service.Tests/exam-service.Tests.csproj
```

### 3. Database Migrations
```bash
# Add a migration to a specific service
cd services/<service-name>
dotnet ef migrations add <MigrationName> --project <service-name>.csproj --output-dir Migrations

# Apply migrations locally
dotnet ef database update --project <service-name>.csproj
```

### 4. Adding a New IELTS Question Type
1. Add enum to `Shared.PublicContracts/Contracts/Exam/Enums/QuestionType.cs`.
2. Update `ExamDbContext.cs` in `services/exam-service/` and generate migration.
3. Implement `IQuestionGrader` in `services/attempt-service/Features/Helpers/{Type}Grader.cs`.
4. Register grader in `services/attempt-service/Program.cs` via `IQuestionGraderRegistration`.
5. Add unit tests in `services/attempt-service.Tests/Helpers/`.
