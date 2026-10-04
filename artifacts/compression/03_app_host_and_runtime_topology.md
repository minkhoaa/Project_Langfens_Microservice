# 03 — AppHost & Runtime Topology

> Source-of-truth: `AppHost/Program.cs`, `AppHost/CLAUDE.md`.

## What AppHost does

`AppHost/AppHost.csproj` is an Aspire distributed application (`DistributedApplication.CreateBuilder(args)`). It:

1. Declares RabbitMQ + Postgres credentials as **`ParameterResource`** so the same secret is reused for `AddRabbitMQ` and `WithRabbitMqEnv`.
2. Adds Redis (shared), Qdrant container, Ollama container (with persistent `ollama-data` volume + `OLLAMA_KEEP_ALIVE=5m`, `NUM_PARALLEL=1`).
3. Adds **a one-shot `ollama-init` container** that runs `ollama pull bge-m3` so embeddings are always available before `ai-service` starts.
4. Builds `ai-service` and `generation-service` from Dockerfiles (mounted app dirs for hot reload).
5. Adds 9 persistent PostgreSQL servers (one per service that owns a DB) — host ports locked to compose equivalents for `psql`/`pgAdmin` parity.
6. Adds the 9 .NET services via `AddProject(...)`, wiring each to its DB, RabbitMQ, AI service URLs, env files, and `WaitFor` chains.
7. Adds the `api-gateway` project on **port 5000**, with `WithReference` for every downstream + explicit `ReverseProxy__Clusters__<name>__Destinations__d1__Address = service.GetEndpoint("http")` overrides so YARP uses Aspire-allocated ports (instead of compose hostnames baked into `gateway/api-gateway/appsettings.json`).

## Aspire timeouts (heavy images)

```csharp
builder.Configuration["Dcp:ContainerRuntimeInitializationTimeout"] = "02:00:00";
builder.Configuration["Dcp:ServiceStartupWatchTimeout"]           = "02:00:00";
builder.Configuration["Dcp:DependencyCheckTimeout"]               = "7200";
```
Justification in code: ai-service PyTorch download is slow.

## Infra containers

| Resource | Source | Lifetime |
|---|---|---|
| `rabbitmq` (`rabbitmq:3-management`) | `AddRabbitMQ("rabbitmq", userName: rabbitUser, password: rabbitPass).WithManagementPlugin()` | Persistent |
| `redis` | `AddRedis("redis")` | Persistent |
| `qdrant` | `AddContainer("qdrant", "qdrant/qdrant", "latest").WithHttpEndpoint(targetPort: 6333, name: "http")` | Persistent (vol) |
| `ollama` | `AddContainer("ollama", "ollama/ollama", "latest").WithHttpEndpoint(targetPort: 11434, name: "http").WithVolume("ollama-data", "/root/.ollama").WithLifetime(Persistent)` | Persistent |
| `ollama-init` | one-shot `ollama pull bge-m3` | Session |
| `ai-service` | `AddDockerfile("ai-service", "../", "services/ai-service/Dockerfile").WithHttpEndpoint(targetPort: 8080, name: "http")` + bind-mounts of `services/ai-service/app` and `models/qwen25-lora` (RO) | Session |
| `generation-service` | `AddDockerfile("generation-service", "../", "services/generation-service/Dockerfile").WithHttpEndpoint(targetPort: 8080, name: "http")` + bind-mount of `services/generation-service/app` | Session |

## PostgreSQL servers (host ports verified)

| Resource | Server host port | DB name | Server user/pass |
|---|---|---|---|
| `exam-db-server` | **5433** | `exam-db` | exam/exam |
| `auth-db-server` | **5434** | `auth-db` | auth/auth |
| `attempt-db-server` | **5435** | `attempt-db` | attempt/attempt |
| `writing-db-server` | **5440** | `writing-db` | writing/writing |
| `speaking-db-server` | **5441** | `speaking-db` | speaking/speaking |
| `dictionary-db-server` | **5443** | `dictionary-db` | dictionary/dictionary |
| `gamification-db-server` | **5444** | `gamification-db` | gamification/gamification |
| `course-db-server` | **5446** | `course-db` | course/course |
| `vocabulary-db-server` | **5987** | `vocabulary-db` | vocabulary/vocabulary |

All `.WithDataVolume().WithLifetime(ContainerLifetime.Persistent)`.

## Service wiring (verbatim from `Program.cs`)

Each .NET service is wired like this (representative — `writing-service`):

```csharp
var writing = builder.AddProject("writing-service", "../services/writing-service/writing-service.csproj")
    .WithReference(writingDb)
    .WithEnvironment("CONNECTIONSTRING__WRITING", writingDb.Resource.ConnectionStringExpression)  // legacy bridge
    .WithReference(rabbitmq)
    .WithComposeEnvFile("writing")
    .WithRabbitMqEnv(rabbitmq, rabbitUser, rabbitPass)
    .WaitFor(writingDb)
    .WaitFor(rabbitmq);

// AI URL injection
writing.WithEnvironment("AI_SERVICE_URL", aiService.GetEndpoint("http"));
```

`auth-service` additionally remaps the shared Redis resource to its `auth-redis` key:

```csharp
auth.WithEnvironment("ConnectionStrings__auth-redis", redis.Resource.ConnectionStringExpression)
```

`exam-service` is the only one with two Kestrel endpoints (`http` + `grpc`):

```csharp
var exam = builder.AddProject("exam-service", "../services/exam-service/exam-service.csproj")
    .WithReference(examDb)
    .WithHttpEndpoint(name: "http", env: "Kestrel__HttpPort")
    .WithHttpEndpoint(name: "grpc", env: "Kestrel__GrpcPort")
    .WithComposeEnvFile("exam")
    .WaitFor(examDb);

exam.WithEnvironment("AI_SERVICE_URL", aiService.GetEndpoint("http"));
exam.WithEnvironment("GENERATION_SERVICE_URL", generationService.GetEndpoint("http"));
exam.WaitFor(generationService);
```

`attempt-service` receives all three cross-cutting endpoints + a dev-only internal key:

```csharp
attempt
    .WithEnvironment("EXAMSERVICE__EXAM__ADDRESS", exam.GetEndpoint("http"))
    .WithEnvironment("ExamService__GrpcAddress", exam.GetEndpoint("grpc"))
    .WithEnvironment("EXAMSERVICE__INTERNAL__API__KEY", "dev-internal-key-not-for-prod")
    .WithEnvironment("AI_SERVICE_URL", aiService.GetEndpoint("http"))
    .WaitFor(aiService)
    .WaitFor(attemptDb)
    .WaitFor(rabbitmq)
    .WaitFor(exam);
```

## Gateway wiring (verified)

```csharp
var gateway = builder.AddProject("api-gateway", "../gateway/api-gateway/api-gateway.csproj")
    .WithHttpEndpoint(port: 5000, name: "http", env: "ASPNETCORE_HTTP_PORTS")
    .WithReference(exam).WithReference(gamification).WithReference(speaking)
    .WithReference(dictionary).WithReference(vocabulary).WithReference(writing)
    .WithReference(auth).WithReference(attempt).WithReference(course).WithReference(email)
    .WithComposeEnvFile("gateway")
    // Override each YARP cluster destination with Aspire-allocated endpoint
    .WithEnvironment("ReverseProxy__Clusters__<svc>-cluster__Destinations__d1__Address", <svc>.GetEndpoint("http"))
    // …
    .WaitFor(/* every downstream */);
```

12 cluster overrides: auth, exam, attempt, vocabulary, course, speaking, writing, email, dictionary, gamification, **ai, generation**.

## Helper: `WithComposeEnvFile(name)`

Path: `AppHost/Program.cs` `internal static class AppHostExtensions`. Reads `deploy/envs/<name>.env` and applies every `KEY=VALUE` pair as `WithEnvironment`. **Skips** keys that AppHost injects dynamically:

- `RABBITMQ__*`
- `CONNECTIONSTRING__*` / `ConnectionStrings__*`
- `EXAMSERVICE__EXAM__ADDRESS`, `EXAMSERVICE__INTERNAL__API__KEY`
- `AI_SERVICE_URL`, `GENERATION_SERVICE_URL`
- `REDIS_HOST`, `REDIS_PORT`, `QDRANT_HOST`, `QDRANT_PORT`

Env values are unquoted/un-escaped (`\\n` → `\n`).

## Helper: `WithRabbitMqEnv(rabbitmq, userName, password)`

Pushes the discrete env vars that langfens services read (NOT `ConnectionStrings__rabbitmq`):

```csharp
service
    .WithEnvironment("RABBITMQ__HOST",     rabbitmq.PrimaryEndpoint.Property(EndpointProperty.Host))
    .WithEnvironment("RABBITMQ__PORT",     rabbitmq.PrimaryEndpoint.Property(EndpointProperty.Port))
    .WithEnvironment("RABBITMQ__USERNAME", userName)
    .WithEnvironment("RABBITMQ__PASSWORD", password)
    .WithEnvironment("RABBITMQ__VHOST",    "/")
    .WithEnvironment("RABBITMQ__USESSL",   "false");
```

## Frontend (Next.js)

Runs **outside** Aspire. Start it manually:

```bash
cd ../langfens-fe-app
NEXT_PUBLIC_GATEWAY_URL=http://localhost:5000 npm run dev
```

The gateway is pinned to host port **5000** in AppHost (`WithHttpEndpoint(port: 5000, ...)`), so `NEXT_PUBLIC_GATEWAY_URL=http://localhost:5000` works.

## Aspire dashboard

`http://localhost:18888` — resources, endpoints, env vars, logs.

## Compose fallback (production)

`deploy/compose.yaml` runs the same services as pinned image tags, host ports published to the host, and `env_file:` directives pointing to `deploy/envs/*.env`. Compose-only detail: RabbitMQ user is **`appuser`/`apppassword`** (different from Aspire's `guest`).
