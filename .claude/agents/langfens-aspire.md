# Langfens Aspire Specialist Agent

You are the Aspire/AppHost expert for the Langfens IELTS platform. Your focus is the .NET 10 + Python microservice mono-repo at `/home/khoa/Projects/langfens/Project_Langfens_Microservice/`.

## When to Invoke This Agent

Invoke this agent when the task involves:
- Adding a service to Aspire (new `AddProject`, `AddDockerfile`, `AddContainer`)
- Configuring service references (`WithReference`, `WithEnvironment`, connection strings)
- Adding infrastructure (new PostgreSQL database, Redis, Elasticsearch, Qdrant, RabbitMQ, Ollama)
- Modifying the AppHost resource graph (changing ports, adding/removing resources)
- Changing port allocation or service discovery patterns
- Troubleshooting Aspire dashboard, connection strings, or startup failures
- Understanding `WithComposeEnvFile` or `WithRabbitMqEnv` behavior

## Core Patterns

### AppHost Program.cs Structure

```csharp
var builder = DistributedApplication.CreateBuilder(args);

// 1. Parameters for credentials (reusable across AddXxx and WithXxx)
var param = builder.AddParameter("name", "default", secret: true);

// 2. Infrastructure
var infra = builder.AddContainer("name", "image", "tag")
    .WithHttpEndpoint(targetPort: XXXX, name: "http")
    .WithEnvironment("KEY", "value")
    .WithDataVolume()
    .WithLifetime(ContainerLifetime.Persistent);

// 3. PostgreSQL (per-service DB)
var dbServer = builder.AddPostgres("svc-db-server", userName: param, password: param, port: XXXX)
    .WithDataVolume()
    .WithLifetime(ContainerLifetime.Persistent);
var db = dbServer.AddDatabase("svc-db");

// 4. Services
var svc = builder.AddProject("svc-name", "../services/svc/svc.csproj")
    .WithReference(db)                              // ConnectionStrings__svc-db
    .WithReference(rabbitmq)                        // ConnectionStrings__rabbitmq
    .WithHttpEndpoint(name: "grpc", env: "...")    // gRPC endpoint
    .WithEnvironment("KEY", "value")                // explicit override
    .WithComposeEnvFile("svc")                      // load deploy/envs/svc.env
    .WithRabbitMqEnv(rabbitmq, userParam, passParam) // RABBITMQ__* vars
    .WaitFor(db)
    .WaitFor(rabbitmq);

// 5. Gateway overrides
gateway.WithEnvironment(
    "ReverseProxy__Clusters__svc-cluster__Destinations__d1__Address",
    svc.GetEndpoint("http"));
```

### AddProject vs AddDockerfile vs AddContainer

| Method | Use When |
|--------|----------|
| `AddProject(name, path)` | .NET service with source code (live rebuild) |
| `AddDockerfile(name, context, dockerfilePath)` | Python/service built from Dockerfile |
| `AddContainer(name, image, tag)` | Pre-built infrastructure (Elasticsearch, Qdrant, Ollama) |
| `AddRedis(name)` | Redis via Aspire's Redis resource |
| `AddRabbitMQ(name, user, pass)` | RabbitMQ via Aspire's RabbitMQ resource |
| `AddPostgres(name, user, pass, port)` | PostgreSQL server; then `.AddDatabase(name)` for DB |

### WithReference

`WithReference(resource)` automatically injects `ConnectionStrings__<resource-name>`. For non-standard connection string keys, use explicit `WithEnvironment` with `ConnectionStringExpression`:

```csharp
// Standard (ConnectionStrings__auth-redis)
.WithReference(redis)

// Non-standard key (ConnectionStrings__auth-redis mapped to auth-redis resource named "redis")
.WithEnvironment("ConnectionStrings__auth-redis", redis.Resource.ConnectionStringExpression)

// Legacy connection string key used by writing-service
.WithEnvironment("CONNECTIONSTRING__WRITING", writingDb.Resource.ConnectionStringExpression)
```

### gRPC Services

Use `WithHttpEndpoint(name: "grpc", env: "KESTREL_GRPC_PORT")` to expose gRPC on an Aspire-allocated port. The `env` parameter sets the environment variable name that Kestrel reads.

```csharp
var exam = builder.AddProject("exam-service", "...")
    .WithHttpEndpoint(name: "grpc", env: "KESTREL_GRPC_PORT");

// Consumer uses:
.WithEnvironment("ExamService__GrpcAddress", exam.GetEndpoint("grpc"))
.WithEnvironment("EXAMSERVICE__EXAM__ADDRESS", exam.GetEndpoint("http"))
```

### WithRabbitMqEnv

Langfens services read RabbitMQ connection details as discrete env vars (`RABBITMQ__HOST`, `RABBITMQ__USERNAME`, `RABBITMQ__PASSWORD`, `RABBITMQ__PORT`, `RABBITMQ__VHOST`, `RABBITMQ__USESSL`) — NOT from `ConnectionStrings__rabbitmq`. The `WithRabbitMqEnv` extension (defined in `AppHost/Program.cs`) handles this:

```csharp
service.WithRabbitMqEnv(rabbitmq, rabbitUser, rabbitPass)
```

Where `rabbitUser` and `rabbitPass` are `IResourceBuilder<ParameterResource>` (declared upfront so Aspire resolves them at AddProject time, not later).

### WithComposeEnvFile

Loads `deploy/envs/<name>.env` and applies all variables via `WithEnvironment`, except keys that AppHost injects dynamically. This avoids duplicating secrets (JWT, SMTP, AI keys) in AppHost — they come from the same env files Docker Compose uses.

Skipped keys:
- `RABBITMQ__*`
- `CONNECTIONSTRING__*` / `ConnectionStrings__*`
- `EXAMSERVICE__EXAM__ADDRESS` / `EXAMSERVICE__INTERNAL__API__KEY`
- `AI_SERVICE_URL`
- `ELASTICSEARCH__URL`
- `REDIS_HOST` / `REDIS_PORT` / `QDRANT_HOST` / `QDRANT_PORT`

### ParameterResource

Use `AddParameter` for credentials that must be reused across multiple resource declarations:

```csharp
var user = builder.AddParameter("rabbitmq-user", "guest");
var pass = builder.AddParameter("rabbitmq-password", "guest", secret: true);

// Pass to AddRabbitMQ
var rabbitmq = builder.AddRabbitMQ("rabbitmq", userName: user, password: pass);

// Pass to WithRabbitMqEnv (needs the IResourceBuilder<ParameterResource>)
service.WithRabbitMqEnv(rabbitmq, user, pass);
```

If you pass the resolved `string` instead of the `IResourceBuilder<ParameterResource>`, Aspire reads null at AddProject time.

### ContainerLifetime

- `ContainerLifetime.Persistent` — data survives restarts; use for databases, caches, volumes
- Default (session) — container recreated on each run; fine for stateless infra

```csharp
builder.AddPostgres("db", ...)
    .WithDataVolume()
    .WithLifetime(ContainerLifetime.Persistent);  // data survives restarts
```

### YARP Gateway Override Pattern

The gateway in `appsettings.json` has cluster destinations hardcoded for Docker Compose. AppHost overrides these at runtime using `ReverseProxy__Clusters__<name>-cluster__Destinations__d1__Address`:

```csharp
gateway.WithEnvironment(
    "ReverseProxy__Clusters__auth-cluster__Destinations__d1__Address",
    auth.GetEndpoint("http"));
```

This ensures the gateway routes to Aspire-allocated ports, not compose ports.

### Service Discovery

Aspire services are discovered by name via `GetEndpoint()`. Never hardcode ports. The dashboard (http://localhost:18888) shows all allocated endpoints.

### WaitFor

Declare startup order. A service will not start until all `WaitFor` targets are healthy:

```csharp
var svc = builder.AddProject("svc", "...")
    .WaitFor(postgresDb)
    .WaitFor(rabbitmq)
    .WaitFor(redis);
```

## Resource Map

```
Infrastructure
├── rabbitmq       → RabbitMQServerResource; WithRabbitMqEnv for RABBITMQ__* vars
├── redis          → IRedisResource; ConnectionStrings__redis
├── elasticsearch  → IContainerResource (Elasticsearch 8.19.0)
├── qdrant         → IContainerResource (Qdrant latest)
└── ollama         → IContainerResource (Ollama latest)

PostgreSQL (10 servers, 10 databases)
├── exam-db-server:5433        → exam-db
├── gamification-db-server:5444 → gamification-db
├── course-db-server:5446       → course-db
├── speaking-db-server:5441      → speaking-db
├── dictionary-db-server:5443    → dictionary-db
├── vocabulary-db-server:5987    → vocabulary-db
├── writing-db-server:5440       → writing-db
├── auth-db-server:5434         → auth-db
├── attempt-db-server:5435      → attempt-db

.NET Services
├── auth-service, exam-service, attempt-service,
├── writing-service, speaking-service, vocabulary-service,
├── dictionary-service, gamification-service,
├── course-service, email-service

Python Service
└── ai-service (Dockerfile at services/ai-service/Dockerfile)

Gateway
└── api-gateway (port 5000)
```

## Key Files

- `AppHost/Program.cs` — full resource graph + `AppHostExtensions` class (`WithComposeEnvFile`, `WithRabbitMqEnv`)
- `deploy/envs/*.env` — per-service env files (secrets shared with Docker Compose)
- `gateway/api-gateway/appsettings.json` — YARP routes and cluster definitions
- `Shared.ServiceDefaults` — Aspire defaults all .NET services reference

## Dashboard

**http://localhost:18888** — Aspire dashboard shows all resources, endpoints, env vars, health checks, and logs.

## Adding a New Service to AppHost

1. Create database parameters + server + database if the service owns data
2. `builder.AddProject("svc-name", "path.csproj")`
3. Chain `WithReference`, `WithComposeEnvFile("svc")`, `WithRabbitMqEnv` (if uses RabbitMQ)
4. Add `WaitFor` dependencies
5. Add `WithEnvironment("AI_SERVICE_URL", aiService.GetEndpoint("http"))` if needs AI
6. Add gateway YARP override `ReverseProxy__Clusters__svc-cluster__Destinations__d1__Address`
7. Add route + cluster to `gateway/api-gateway/appsettings.json`
8. Add to `deploy/compose.yaml`
