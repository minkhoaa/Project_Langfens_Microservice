# Langfens — IELTS Preparation Platform

**Langfens** is a microservice-based IELTS preparation platform combining real-exam simulation, AI evaluation, spaced-repetition vocabulary, and gamification. This is a .NET 10 + Python mono-repo.

## Aspire / AppHost

AppHost (`dotnet run --project AppHost/AppHost.csproj`) is the **primary local dev workflow** — not Docker Compose. It orchestrates all services, infra containers, and databases in a single process with live rebuild support and the Aspire dashboard (http://localhost:18888).

### Helpers

**`WithComposeEnvFile(name)`** — loads `deploy/envs/<name>.env` and applies every key/value pair via `WithEnvironment`. This reuses the same env files Docker Compose uses so secrets (JWT, SMTP, AI keys) don't need to be duplicated in AppHost. It automatically skips keys that AppHost injects dynamically:

- `RABBITMQ__*` (AppHost uses `WithRabbitMqEnv` instead)
- `CONNECTIONSTRING__*` / `ConnectionStrings__*` (Aspire injects from resource graph)
- `EXAMSERVICE__EXAM__ADDRESS` / `EXAMSERVICE__INTERNAL__API__KEY`
- `AI_SERVICE_URL`, `ELASTICSEARCH__URL`, `REDIS_HOST`, `REDIS_PORT`, `QDRANT_HOST`, `QDRANT_PORT`

**`WithRabbitMqEnv()`** — pushes the discrete `RABBITMQ__HOST`, `RABBITMQ__USERNAME`, `RABBITMQ__PASSWORD`, `RABBITMQ__PORT`, `RABBITMQ__VHOST`, `RABBITMQ__USESSL` env vars that langfens services read directly. This is separate from Aspire's standard `ConnectionStrings__rabbitmq` injection.

### Resource graph

**10 PostgreSQL databases** (each on a unique host port for `psql`/`pgAdmin` parity):

| Database | Server port | Database name |
|----------|-------------|---------------|
| exam-db | 5433 | exam-db |
| gamification-db | 5444 | gamification-db |
| course-db | 5446 | course-db |
| speaking-db | 5441 | speaking-db |
| dictionary-db | 5443 | dictionary-db |
| vocabulary-db | 5987 | vocabulary-db |
| writing-db | 5440 | writing-db |
| auth-db | 5434 | auth-db |
| attempt-db | 5435 | attempt-db |

**Infrastructure containers**:

- **Redis** — shared session cache; auth-service maps it as `ConnectionStrings__auth-redis`
- **Elasticsearch** — dictionary-service full-text search; injected via `ELASTICSEARCH__URL`
- **Qdrant** — vector DB for ai-service (embedding/RAG)
- **Ollama** — local LLM (Qwen2.5) for ai-service; disabled by default (`USE_OLLAMA=false`)
- **RabbitMQ** — message broker; credentials declared as `ParameterResource` so they can be reused in both `AddRabbitMQ` and `WithRabbitMqEnv`

### Service reference patterns

- **`WithReference(resource)`** — injects `ConnectionStrings__<resource>` automatically
- **`WithEnvironment(key, value)`** — explicit env var override; `ConnectionStringExpression` for dynamic values
- **`WithHttpEndpoint(name: "grpc")`** — exposes gRPC on an Aspire-allocated port; injects `KESTREL_GRPC_PORT` env var
- **`WaitFor(resource)`** — declares startup order dependency

### Gateway YARP overrides

AppHost overrides every YARP cluster destination so the gateway uses Aspire-allocated ports instead of the compose hostnames in `appsettings.json`:

```
ReverseProxy__Clusters__<name>-cluster__Destinations__d1__Address = <service>.GetEndpoint("http")
```

Each service cluster (auth-cluster, exam-cluster, writing-cluster, etc.) gets its Aspire-assigned HTTP endpoint injected at runtime.

### Frontend

Next.js runs **outside Aspire** — start it manually:

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
NEXT_PUBLIC_GATEWAY_URL=http://localhost:5000 npm run dev
```

Set `NEXT_PUBLIC_GATEWAY_URL` to the port Aspire allocates for the gateway.

---

## Architecture Overview

```
Project_Langfens_Microservice/
├── gateway/api-gateway/        # YARP reverse proxy + JWT auth → http://localhost:5000
├── AppHost/                    # Aspire orchestration (local dev only)
├── services/
│   ├── auth-service/           # JWT identity, Redis sessions, OTP
│   ├── exam-service/           # Exam content + gRPC (answer key lookup)
│   ├── attempt-service/        # Attempt tracking, auto-graders, MassTransit consumers
│   ├── writing-service/         # Writing AI grading (Gemini/Groq via ai-service)
│   ├── speaking-service/        # Speaking AI evaluation (Whisper + AI via ai-service)
│   ├── vocabulary-service/      # Flashcards + SM2 spaced repetition
│   ├── dictionary-service/      # Elasticsearch-powered word lookup
│   ├── gamification-service/    # XP, levels, achievements, streaks
│   ├── course-service/          # Learning paths & courses
│   ├── email-service/           # Transactional emails (RabbitMQ consumer)
│   ├── ai-service/             # Python/FastAPI — LLM, embeddings, ASR, RAG
│   └── _shared/
│       ├── Shared.Bootstrap/    # LangfensBootstrapExtensions, JwtSettings
│       ├── Shared.Grpc/         # protobuf + ExamInternal gRPC client
│       ├── Shared.PublicContracts/  # Enums, DTOs (QuestionType, etc.)
│       ├── Shared.Security/     # Roles, Scopes, Claims helpers
│       └── Shared.ServiceDefaults/  # Aspire defaults (OTel, health)
└── deploy/
    └── compose.yaml             # Production Docker Compose
```

## Key Conventions

### Naming & project references
- Every .NET service references `Shared.*` projects from `services/_shared/`
- New services must reference `Shared.ServiceDefaults` and `Shared.Bootstrap`
- Proto files live in `Shared.Grpc`; regenerate there, not in individual services

### API routing pattern
- Services use minimal API (`app.Map...Endpoint()` pattern)
- Each endpoint group lives in `Features/{Feature}/{Action}Endpoint.cs`
- Register: `app.MapXxxEndpoints()` in `Program.cs`

### RabbitMQ / MassTransit
- Services read `RABBITMQ__HOST`, `RABBITMQ__USERNAME`, `RABBITMQ__PASSWORD`, `RABBITMQ__VHOST`, `RABBITMQ__PORT`, `RABBITMQ__USESSL` env vars directly (not ConnectionStrings)
- Consumers: `cfg.ReceiveEndpoint("queue-name", e => e.ConfigureConsumer<...>(ctx))`
- See `attempt-service` for consumer examples (WritingGradedConsumer, SpeakingGradedConsumer)

### gRPC
- `exam-service` exposes `ExamInternalGrpcService` (protobuf in `Shared.Grpc`)
- `attempt-service` calls it via `ExamInternalClient` at `ExamService__GrpcAddress`
- Both HTTP/2 and HTTP/1.1 multiplexed on same Kestrel; distinguish by content-type

### Database & migrations
- Each .NET service owns its PostgreSQL database (per-service schema)
- EF Core migrations run automatically on startup (`MigrateAsync`)
- CLI: `dotnet ef migrations add <Name> --project <service>.csproj --output-dir Migrations`

### Environment variables
- **Auth/JWT**: `JwtSettings__Issuer`, `JwtSettings__Audience`, `JwtSettings__SignKey`, `JwtSettings__RsaPrivateKeyPem`, `JwtSettings__KeyId`, `JwtSettings__AccessTokenLifetimeSeconds`
- **RabbitMQ**: `RABBITMQ__HOST`, `RABBITMQ__USERNAME`, `RABBITMQ__PASSWORD`, `RABBITMQ__VHOST`, `RABBITMQ__PORT`, `RABBITMQ__USESSL`
- **AI (writing/speaking)**: `AI_SERVICE_URL` (defaults to `http://ai-service:8080`)
- **Aspire**: `ConnectionStrings__<db-name>` injected automatically; don't hardcode connection strings
- **Kestrel** (compose-only): `Kestrel__HttpPort`, `Kestrel__GrpcPort`; under Aspire these are ignored

### Docker Compose vs AppHost
- **Production**: `deploy/compose.yaml` — pinned image tags, env files in `deploy/envs/`
- **Local dev**: `dotnet run --project AppHost/AppHost.csproj` — Aspire orchestrates with live rebuild
- AppHost loads env from `deploy/envs/<name>.env` via `WithComposeEnvFile()` helper
- AppHost injects Aspire-assigned ports and overrides YARP cluster destinations dynamically

### Gateway routing
- YARP routes use `/api-<service>/` prefix with `PathRemovePrefix` transform
- Direct routes exist for some paths (e.g., `/api/attempt/`, `/api/writing/`)
- Under AppHost, gateway receives all service addresses as env overrides
- 20s timeout per cluster; 60s for ai-cluster (LLM calls may be slow)

## Running Locally

### Via AppHost (recommended for development)
```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
dotnet run --project AppHost/AppHost.csproj
# Gateway → http://localhost:5000
# Dashboard → http://localhost:18888
```

### Via Docker Compose (full infra)
```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/deploy
cp envs/*.env .env  # fill in your secrets
docker compose up -d
# Gateway → http://localhost:5000
```

### Build a single service
```bash
cd services/<service-name>
dotnet build
dotnet test
```

### Run migrations on a service
```bash
cd services/<service-name>
dotnet ef migrations add <MigrationName> --project <service>.csproj --output-dir Migrations
dotnet ef database update --project <service>.csproj
```

## Cross-Service Considerations

### Adding a new question type to exam-service
1. Add enum value to `QuestionType` in `Shared.PublicContracts/Contracts/Exam/Enums/QuestionType.cs`
2. Add grader in `attempt-service/Features/Helpers/{Type}Grader.cs` + `...GraderRegistration.cs`
3. Register in `attempt-service/Program.cs` via `IQuestionGraderRegistration`

### Adding a new RabbitMQ consumer
1. Create `Features/RabbitMq/{EventName}Consumer.cs` implementing `IConsumer<T>`
2. Register: `cfg.AddConsumer<Consumer>()` + `bus.ReceiveEndpoint("queue", e => e.ConfigureConsumer<...>(ctx))`
3. Env vars: ensure `RABBITMQ__*` vars are set

### Adding a new service
1. Create in `services/<name>-service/`
2. Reference `Shared.ServiceDefaults`, `Shared.Bootstrap` in `.csproj`
3. Call `builder.AddServiceDefaults()` in `Program.cs`
4. Add `builder.Services.AddLangfensAuth(...)`, `AddLangfensCors()`, `AddLangfensSwagger(...)`
5. Wire to AppHost in `AppHost/Program.cs`
6. Add route + cluster to `gateway/api-gateway/appsettings.json`
7. Add Docker image + service + env_file to `deploy/compose.yaml`
8. Create `services/<name>-service/CLAUDE.md`

### AI service (Python)
- `ai-service` is Python/FastAPI — runs separately from .NET services
- Primary LLM: Ollama (Qwen2.5); fallback: Groq/MiniMax, Gemini
- Vector DB: Qdrant; cache: Redis; ASR: faster-whisper
- See `services/ai-service/CLAUDE.md` for detailed patterns

## Per-Service CLAUDE.md Files

Each service has its own `CLAUDE.md` with deeper context:
- `services/auth-service/CLAUDE.md` — JWT, Redis OTP, MassTransit publishing
- `services/exam-service/CLAUDE.md` — gRPC, exam delivery, seeding
- `services/attempt-service/CLAUDE.md` — auto-graders, AI consumers, gRPC client
- `services/writing-service/CLAUDE.md` — AI grading pipeline, RabbitMQ publishing
- `services/speaking-service/CLAUDE.md` — speech eval, roleplay, AI integration
- `services/vocabulary-service/CLAUDE.md` — SM2 algorithm, flashcard CRUD
- `services/dictionary-service/CLAUDE.md` — Elasticsearch integration
- `services/gamification-service/CLAUDE.md` — XP system, achievements, leaderboard
- `services/course-service/CLAUDE.md` — course/lesson management
- `services/email-service/CLAUDE.md` — RabbitMQ consumer, SMTP
- `services/ai-service/CLAUDE.md` — FastAPI, LLM routing, vector search, ASR

**Read the relevant service's CLAUDE.md before working on that service.**

## Shared Libraries

| Library | Purpose |
|---------|---------|
| `Shared.Bootstrap` | `AddLangfensAuth()`, `AddLangfensCors()`, `AddLangfensSwagger()`, `AddLangfensJson()`, `ConfigureLangfensKestrel()` |
| `Shared.ServiceDefaults` | Aspire defaults — OTel, health endpoints, resilience |
| `Shared.Grpc` | Protobuf files + generated C#; `ExamInternalClient` for attempt-service |
| `Shared.PublicContracts` | Enums (`QuestionType`), shared DTOs across services |
| `Shared.Security` | `Roles.cs` (`User`, `Admin`), `Scopes.cs`, `Claims` helpers |

## Ports Reference

| Service | Compose Port | Aspire Port | Notes |
|---------|-------------|-------------|-------|
| Gateway | 5000 | 5000 | YARP reverse proxy |
| auth-service | 8080 | dynamic | JWT + RS256 |
| exam-service | 8082 | dynamic | HTTP + gRPC |
| attempt-service | 8081 | dynamic | Auto-graders |
| vocabulary-service | 8093 | dynamic | SM2 spaced repetition |
| speaking-service | 8090 | dynamic | AI evaluation |
| writing-service | 8091 | dynamic | AI grading |
| dictionary-service | 8094 | dynamic | Elasticsearch |
| gamification-service | 8096 | dynamic | XP/achievements |
| course-service | — | dynamic | Courses |
| email-service | — | dynamic | SMTP |
| ai-service | 8092 | dynamic | Python/FastAPI |
| RabbitMQ | 15672 (mgmt) | dynamic | Management UI |
| PostgreSQL | 5432 | — | host port per service |
| Redis | 6379 | dynamic | Session cache |
| Elasticsearch | 9200 | dynamic | Full-text search |