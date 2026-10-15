---
name: langfens-aspire
description: Operate, diagnose, and expand the .NET Aspire orchestration environment, container graph, dynamic port mapping, and YARP gateway overrides for Langfens.
---

# Langfens Aspire Orchestration Workflow

Use this skill when running, troubleshooting, or modifying the Aspire `AppHost` orchestration layer in Langfens.

## 1. Running Aspire Locally

Aspire is the primary local development workflow:
```bash
# Launch AppHost with all microservices and infra containers
dotnet run --project AppHost/AppHost.csproj
```
- **Aspire Dashboard**: `http://localhost:18888` (inspect live logs, environment variables, health metrics)
- **API Gateway**: `http://localhost:5000` (YARP reverse proxy routing to all downstream services)

## 2. Infrastructure Container Map

| Resource | Image / Mode | Host Port | Injected Env / Reference |
|---|---|---|---|
| `exam-db` | PostgreSQL 16 | 5433 | `WithReference(examDb)` |
| `auth-db` | PostgreSQL 16 | 5434 | `WithReference(authDb)` |
| `attempt-db` | PostgreSQL 16 | 5435 | `WithReference(attemptDb)` |
| `writing-db` | PostgreSQL 16 | 5440 | `WithReference(writingDb)` |
| `speaking-db` | PostgreSQL 16 | 5441 | `WithReference(speakingDb)` |
| `dictionary-db` | PostgreSQL 16 | 5443 | `WithReference(dictionaryDb)` |
| `gamification-db` | PostgreSQL 16 | 5444 | `WithReference(gamificationDb)` |
| `course-db` | PostgreSQL 16 | 5446 | `WithReference(courseDb)` |
| `vocabulary-db` | PostgreSQL 16 | 5987 | `WithReference(vocabularyDb)` |
| `redis` | Redis Alpine | Dynamic | `WithReference(redis)` / `ConnectionStrings__auth-redis` |
| `elasticsearch` | Elasticsearch 8.19.0 | Dynamic | `ELASTICSEARCH__URL` |
| `qdrant` | Qdrant latest | Dynamic | `QDRANT_HOST`, `QDRANT_PORT` |
| `rabbitmq` | RabbitMQ 3 Management | 15672 | `WithRabbitMqEnv(...)` (`RABBITMQ__*`) |

## 3. Adding a Microservice to AppHost

Edit `AppHost/Program.cs`:
```csharp
// 1. Add dedicated database (if applicable)
var dbUser = builder.AddParameter("mysvc-db-user", "mysvc");
var dbPass = builder.AddParameter("mysvc-db-pass", "mysvc", secret: true);
var dbServer = builder.AddPostgres("mysvc-db-server", userName: dbUser, password: dbPass, port: 5450)
    .WithDataVolume()
    .WithLifetime(ContainerLifetime.Persistent);
var db = dbServer.AddDatabase("mysvc-db");

// 2. Add service project
var mySvc = builder.AddProject("mysvc-service", "../services/mysvc-service/mysvc-service.csproj")
    .WithReference(db)
    .WithReference(rabbitmq)
    .WithComposeEnvFile("mysvc")
    .WithRabbitMqEnv(rabbitmq, rabbitUser, rabbitPass)
    .WaitFor(db)
    .WaitFor(rabbitmq);

// 3. Register gateway route override
gateway.WithEnvironment(
    "ReverseProxy__Clusters__mysvc-cluster__Destinations__d1__Address",
    mySvc.GetEndpoint("http"));
```

## 4. Key Troubleshooting Rules
- **Connection Refused in Tests**: Unit tests must not depend on Aspire containers. Integration tests require the target DB container running on its dedicated port.
- **Port Conflicts**: Ensure each PostgreSQL database uses its unique assigned host port.
- **RabbitMQ Credentials**: Never read `ConnectionStrings__rabbitmq`. Services use the discrete `RABBITMQ__*` env vars supplied by `WithRabbitMqEnv()`.
