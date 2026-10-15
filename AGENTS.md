# Langfens IELTS Preparation Platform — Engineering & Agent Guidelines

## System Overview

**Langfens** is an enterprise-grade IELTS preparation mono-repo combining full-exam simulations, AI evaluation, spaced-repetition vocabulary, and gamification.
The system uses **.NET 10** (SDK-default C#; no explicit language-version pin) for transactional services and **Python 3.12** (FastAPI container images) for inference, vector retrieval, and autonomous paper generation. Aspire packages are primarily **13.3.2**; dependency manifests, not historical documentation, govern versions.

---

## Architecture & Service Map

```text
Project_Langfens_Microservice/
├── gateway/api-gateway/          # YARP reverse proxy + JWT auth
├── AppHost/                      # Aspire 13.3.2 local orchestration
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
│   ├── generation-service/       # Python/FastAPI: Autonomous reading paper synthesis & review loop
│   ├── exam-service.Tests/       # xUnit; some integration fixtures reset PostgreSQL schemas
│   └── attempt-service.Tests/    # Deterministic question-grader tests
```

---

## Technology Stack & Core Runtimes

| Component | Technology | Role |
|---|---|---|
| **Platform Runtime** | .NET 10.0; SDK-default C# | Core microservices & gateway |
| **AI Runtime** | Python 3.12 container images | LLM evaluation, embeddings, ASR, RAG |
| **Local Orchestration** | .NET Aspire 13.3.2 (`AppHost`) | Process/container graph & Dashboard |
| **API Gateway** | YARP Reverse Proxy (.NET 10) | Edge routing, JWT validation, path transforms |
| **Database** | PostgreSQL | Dedicated database ownership per stateful service |
| **ORM & Migrations** | EF Core 10.0.x + Npgsql 10 | Service-owned code-first migrations |
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
| `csharp-reviewer` | Global ECC: C#, .NET 10, EF Core, async patterns, and nullable correctness. |
| `python-reviewer` | Deep review of Python 3.12 code, typing, async functions, and package best practices. |
| `fastapi-reviewer` | Global ECC: route definitions, Pydantic schemas, dependency injection, and OpenAPI. |
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
# Requires .NET 10 SDK, Docker, and appropriate local environment configuration
dotnet run --project AppHost/AppHost.csproj
```
Discover Dashboard, gateway, and infrastructure endpoints from the running AppHost.
Existing Compose mappings are deployment configuration, not constants to copy into new code.

### 2. Building & Testing .NET Services
```bash
# Build the complete solution
dotnet build Project_Langfens_Microservice.sln

# Run unit tests (attempt-service tests run without external dependencies)
dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj

# Full exam suite: only after isolating EVERY fixture target (see below)
dotnet test services/exam-service.Tests/exam-service.Tests.csproj
```
Some exam fixtures run `DROP SCHEMA ... CASCADE` or delete persisted test data.
**Environment overrides do not isolate the whole suite.** `Phase02DurabilityTests`
and `Phase03BudgetTests` contain hardcoded targets, and a Phase02 test overwrites
`ConnectionStrings__exam-db` internally. Inspect each selected fixture's connection
and cleanup path; prefer fixture-specific filters. Run the full suite only when
every hardcoded/overridden target is disposable and isolated from real data.
Never use a shared, populated development, or production database.

Run Python suites separately with each service as the working directory:
`python -m pytest -m "not live"` in `services/ai-service`, and
`python -m pytest` in `services/generation-service`.
Use service-local environments and `requirements-dev.txt`; AI fixtures stub missing
ML libraries, so an offline pass is not proof that real model inference works.
Live AI tests can run without `--run-live` whenever AI/Ollama endpoints are reachable.
That flag bypasses reachability skipping, not an opt-in gate. Use `-m "not live"`
to exclude them; run live inference only with explicit scope and configured services/models.
See `/skill:langfens-verify` for focused commands and prerequisites.

The current `.github/workflows/ci-cd.yaml` builds/pushes/deploys containers on
`master`; it does **not** run `dotnet test` or `pytest`. Do not treat deployment
success as a test gate.

### 3. Database Migrations
```bash
# Add a migration to a specific service
cd services/<service-name>
dotnet ef migrations add <MigrationName> --project <service-name>.csproj --output-dir Migrations

# Apply migrations locally
dotnet ef database update --project <service-name>.csproj
```

### 4. Adding a New IELTS Question Type
1. Add shared string constants in `services/_shared/Shared.PublicContracts/Contracts/Exam/Enums/QuestionType.cs` only if the wire contract changes.
2. Follow existing `Grader.cs`, `QuestionGraderRegistration.cs`, and the `Reading/` / `Listening/` helpers; do not invent a parallel grader API.
3. Implement `Grade(AttemptAnswer, QuestionKey)` and preserve all-or-nothing awarded points (`0` or `QuestionPoints`).
4. Register the concrete grader and its `IQuestionGraderRegistration` as singletons in `services/attempt-service/Program.cs`. Registrations expose `SupportedTypes` and `Create()`.
5. Write behavioral tests under `services/attempt-service.Tests/Helpers/` first. Only change exam mappings/migrations if persistent schema actually changes.

## Project-local ECC / OMP setup

- Reuse the globally installed `ecc@ecc` plugin; never vendor or edit its cached resources.
- `.omp/AGENTS.md` imports this file. `.omp/RULES.md` holds short sticky invariants;
  `.omp/rules/*.md` holds project-specific domain guidance. Read the applicable
  `rule://` entries before editing; rule globs are advisory, not an enforcement hook.
- `.omp/config.yml` filters global skills, agents, and namespaced ECC commands.
  Existing custom resources remain local; add future custom skill names to the
  include list so filtering does not hide them.
- Use `/skill:skill-library` for routing, `/skill:langfens-verify` for verification,
  and `/ecc:plan`, `/ecc:code-review`, `/ecc:python-review`, or `/ecc:fastapi-review`
  for the selected global command templates. These prompts do not themselves enforce checks.
- The frontend is a separate sibling checkout, not this repository's toolchain.
  Do not introduce npm/React/Next.js conventions here merely because a global ECC
  example uses them.
- MCP recommendations are inert in `.omp/mcp.recommended.json`; active
  `.omp/mcp.json` stays empty until explicit approval of server, access, and credentials.
- See [.omp/README.md](.omp/README.md) for the resource selection, evidence,
  compatibility limits, and discovery verification.
