# AppHost — Aspire Orchestration

AppHost (`AppHost/AppHost.csproj`) is the Aspire orchestrator for the Langfens IELTS platform. It coordinates all .NET services, Python ai-service, infrastructure containers (PostgreSQL, Redis, Elasticsearch, Qdrant, Ollama, RabbitMQ), and the YARP API gateway in a single local dev experience.

## Resource Graph

```
.NET Services (10)
├── auth-service          → auth-db (PostgreSQL 5434), redis, rabbitmq
├── exam-service          → exam-db (PostgreSQL 5433); gRPC endpoint
├── attempt-service       → attempt-db (PostgreSQL 5435), rabbitmq
├── writing-service       → writing-db (PostgreSQL 5440), rabbitmq, ai-service
├── speaking-service      → speaking-db (PostgreSQL 5441), rabbitmq, ai-service
├── vocabulary-service    → vocabulary-db (PostgreSQL 5987), rabbitmq
├── dictionary-service    → dictionary-db (PostgreSQL 5443), elasticsearch
├── gamification-service  → gamification-db (PostgreSQL 5444), rabbitmq
├── course-service        → course-db (PostgreSQL 5446), rabbitmq
└── email-service         → rabbitmq

Infrastructure
├── rabbitmq              → RabbitMQ with management plugin
├── redis                 → shared Redis (auth-service session cache)
├── elasticsearch         → container (Elasticsearch 8.19.0)
├── qdrant                → container (Qdrant latest)
└── ollama                → container (Ollama latest, disabled by default)

Python Service
└── ai-service            → Dockerfile at services/ai-service/Dockerfile; redis, qdrant, ollama

Gateway
└── api-gateway            → YARP reverse proxy on port 5000; all downstream services
```

## Key Files

| File | Purpose |
|------|---------|
| `Program.cs` | AppHost resource graph and orchestration |
| `AppHostExtensions.cs` (in `Program.cs`) | `WithComposeEnvFile()` and `WithRabbitMqEnv()` helpers |
| `deploy/envs/*.env` | Per-service secret files (JWT, SMTP, AI keys) |

## How AppHost Works

1. **Parameters** — RabbitMQ and PostgreSQL credentials are declared as `ParameterResource` so they can be reused across multiple resource declarations (e.g., `AddRabbitMQ` needs them, and `WithRabbitMqEnv` pushes them as discrete env vars).
2. **Infrastructure containers** — Redis, Elasticsearch, Qdrant, Ollama are added with `AddContainer` / `AddRedis`.
3. **PostgreSQL databases** — each service gets its own `AddPostgres(...).AddDatabase(...)` with a unique host port for dev `psql` parity.
4. **Services** — `AddProject` or `AddDockerfile` with `WithReference`, `WithComposeEnvFile`, and `WithRabbitMqEnv`.
5. **Gateway overrides** — `WithEnvironment("ReverseProxy__Clusters__<name>__Destinations__d1__Address", service.GetEndpoint("http"))` so YARP uses Aspire-assigned ports.
6. **Frontend** — runs outside Aspire; point `NEXT_PUBLIC_GATEWAY_URL` at gateway's Aspire-allocated port.

## Adding a New Service

```csharp
// 1. Add database parameter + server + database (if service owns data)
var dbUser = builder.AddParameter("new-db-user", "newdb");
var dbPass = builder.AddParameter("new-db-pass", "newdb", secret: true);
var dbServer = builder.AddPostgres("new-db-server", userName: dbUser, password: dbPass, port: 5XXX)
    .WithDataVolume()
    .WithLifetime(ContainerLifetime.Persistent);
var db = dbServer.AddDatabase("new-db");

// 2. Add the project
var newSvc = builder.AddProject("new-service", "../services/new-service/new-service.csproj")
    .WithReference(db)                           // ConnectionStrings__new-db injected
    .WithReference(rabbitmq)                     // ConnectionStrings__rabbitmq injected
    .WithComposeEnvFile("new")                   // secrets from deploy/envs/new.env
    .WithRabbitMqEnv(rabbitmq, rabbitUser, rabbitPass)  // RABBITMQ__* env vars
    .WaitFor(db)
    .WaitFor(rabbitmq);

// 3. Wire ai-service URL if needed
// newSvc.WithEnvironment("AI_SERVICE_URL", aiService.GetEndpoint("http"));

// 4. Add gateway override
gateway.WithEnvironment(
    "ReverseProxy__Clusters__new-cluster__Destinations__d1__Address",
    newSvc.GetEndpoint("http"));
```

## How Aspire Injects Connection Strings

`WithReference(resource)` injects `ConnectionStrings__<resource-name>` automatically. For example:

- `WithReference(examDb)` → `ConnectionStrings__exam-db` (set by Aspire to the full connection string)
- `WithReference(redis)` → `ConnectionStrings__redis`

Services that need the connection string under a different key use explicit `WithEnvironment`:

```csharp
.WithEnvironment("ConnectionStrings__auth-redis", redis.Resource.ConnectionStringExpression)
.WithEnvironment("CONNECTIONSTRING__WRITING", writingDb.Resource.ConnectionStringExpression)
```

## Custom Extension Methods

### `WithComposeEnvFile(name)`

Located in `AppHost/Program.cs` inside `AppHostExtensions`. Reads `deploy/envs/<name>.env` and applies all key/value pairs via `WithEnvironment`. **Skips** the following keys because AppHost injects them dynamically from the live resource graph:

- `RABBITMQ__*` — use `WithRabbitMqEnv` instead
- `CONNECTIONSTRING__*` / `ConnectionStrings__*` — injected by `WithReference`
- `EXAMSERVICE__EXAM__ADDRESS` / `EXAMSERVICE__INTERNAL__API__KEY`
- `AI_SERVICE_URL`
- `ELASTICSEARCH__URL`
- `REDIS_HOST` / `REDIS_PORT` / `QDRANT_HOST` / `QDRANT_PORT`

### `WithRabbitMqEnv(rabbitmq, userName, password)`

Pushes discrete RabbitMQ env vars that langfens services read directly:

- `RABBITMQ__HOST` — from `rabbitmq.Resource.PrimaryEndpoint.Host`
- `RABBITMQ__PORT` — from `rabbitmq.Resource.PrimaryEndpoint.Port`
- `RABBITMQ__USERNAME` — from `ParameterResource`
- `RABBITMQ__PASSWORD` — from `ParameterResource`
- `RABBITMQ__VHOST` — always `/`
- `RABBITMQ__USESSL` — always `false`

Services do NOT read `ConnectionStrings__rabbitmq` — they use the discrete `RABBITMQ__*` vars.

## ParameterResource for Secrets

Credentials are declared as parameters so they can be used in two places:

```csharp
// Declare once
var rabbitUser = builder.AddParameter("rabbitmq-user", "guest");
var rabbitPass = builder.AddParameter("rabbitmq-password", "guest", secret: true);

// Reuse in AddRabbitMQ
var rabbitmq = builder.AddRabbitMQ("rabbitmq", userName: rabbitUser, password: rabbitPass)
    .WithManagementPlugin();

// Reuse again in WithRabbitMqEnv (needs the ParameterResource builders, not the resolved values)
service.WithRabbitMqEnv(rabbitmq, rabbitUser, rabbitPass);
```

## ContainerLifetime

- **Persistent** (`WithLifetime(ContainerLifetime.Persistent)`) — PostgreSQL, Redis, Elasticsearch, Qdrant, Ollama. Data volumes survive restarts.
- **Session** (default) — short-lived containers for task-based work.

## Dashboard

Aspire Dashboard: **http://localhost:18888**

- View all resources, their endpoints, environment variables, health checks
- See stdout/stderr logs for each service
- Inspect connection strings and secrets (if secret: false on the parameter)

## Adding a New Infrastructure Container

```csharp
// AddContainer pattern (like elasticsearch, qdrant, ollama)
var myContainer = builder.AddContainer("my-container", "image:name", "tag")
    .WithHttpEndpoint(targetPort: XXXX, name: "http")
    .WithEnvironment("KEY", "value")
    .WithDataVolume()                    // persistent storage
    .WithLifetime(ContainerLifetime.Persistent);

// Then reference it from services
service.WithEnvironment("MYCONTAINER_URL", myContainer.GetEndpoint("http"));
```

## Adding a New PostgreSQL Database

```csharp
var dbUser = builder.AddParameter("<service>-db-user", "<service>");
var dbPass = builder.AddParameter("<service>-db-pass", "<service>", secret: true);
var dbServer = builder.AddPostgres("<service>-db-server", userName: dbUser, password: dbPass, port: YYYY)
    .WithDataVolume()
    .WithLifetime(ContainerLifetime.Persistent);
var db = dbServer.AddDatabase("<service>-db");

// In the service's AddProject:
.WithReference(db)   // ConnectionStrings__<service>-db injected automatically
```

## Service Discovery vs Hardcoded Ports

**Never hardcode ports** in service-to-service communication. Always use:
- `serviceA.GetEndpoint("http")` for HTTP addresses
- `serviceA.GetEndpoint("grpc")` for gRPC addresses (with `.WithHttpEndpoint(name: "grpc")` on the service)
- `WithEnvironment("KEY", resource.Resource.ConnectionStringExpression)` for connection strings

Aspire allocates ports dynamically. The gateway YARP cluster overrides use these dynamic endpoints.

## Exam Service gRPC

Exam service exposes two endpoints:

- HTTP (default) — REST API
- gRPC (named "grpc") — `WithHttpEndpoint(name: "grpc", env: "KESTREL_GRPC_PORT")`

attempt-service calls it via:

```csharp
.WithEnvironment("ExamService__GrpcAddress", exam.GetEndpoint("grpc"))
.WithEnvironment("EXAMSERVICE__EXAM__ADDRESS", exam.GetEndpoint("http"))
```
