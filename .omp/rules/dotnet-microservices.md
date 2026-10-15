---
description: Architectural patterns, minimal APIs, EF Core PostgreSQL conventions, MassTransit RabbitMQ, gRPC, and Aspire configuration for .NET 10 microservices.
globs:
  - "**/*.cs"
  - "**/*.csproj"
  - "**/appsettings*.json"
---

# .NET 10 Microservices & C# 13 Engineering Rules

## 1. Minimal API Architecture
- Organize endpoints under `Features/{Feature}/{Action}Endpoint.cs`.
- Create endpoint groups using `app.MapGroup(...)` with appropriate route tags and authorization policies.
- Register endpoints in `Program.cs` via clean extension methods (e.g., `app.MapExamEndpoints()`).
- Always validate incoming DTOs before executing domain logic.

## 2. Immutability & Type Design
- Use `sealed record` for DTOs, messages, and immutable query models:
  ```csharp
  public sealed record ExamSubmissionDto(Guid ExamId, IReadOnlyList<AnswerDto> Answers);
  ```
- Use `init` property accessors rather than mutable `set`.
- Enable and strictly enforce nullable reference types (`#nullable enable`). Avoid null-forgiving operator `!` unless guaranteed by a preceding framework invariant.
- Leverage C# 13 features: primary constructors, collection expressions (`[...]`), and pattern matching.

## 3. Asynchronous Programming & Cancellation
- Async methods must accept a `CancellationToken cancellationToken = default` parameter.
- Forward cancellation tokens down to EF Core, HTTP clients, and MassTransit publishers.
- NEVER block on async code (`.Result`, `.Wait()`, `.GetAwaiter().GetResult()`).
- Use `ConfigureAwait(false)` in non-UI class libraries where appropriate.

## 4. Entity Framework Core & PostgreSQL
- Each microservice owns its `DbContext` mapping to its dedicated PostgreSQL database.
- Use explicit migrations (`dotnet ef migrations add ... --output-dir Migrations`).
- In queries, use `.AsNoTracking()` for read-only operations.
- Avoid N+1 query problems by using explicit `.Include()` / `.ThenInclude()` or projection with `.Select()`.
- Use execution strategies (`EnableRetryOnFailure`) for resilient database connections.

## 5. Event-Driven Communication (RabbitMQ & MassTransit)
- Read connection details from discrete environment variables:
  `RABBITMQ__HOST`, `RABBITMQ__PORT`, `RABBITMQ__USERNAME`, `RABBITMQ__PASSWORD`, `RABBITMQ__VHOST`, `RABBITMQ__USESSL`.
- Consumers implement `IConsumer<TMessage>` and must be idempotent.
- Configure queues explicitly: `cfg.ReceiveEndpoint("queue-name", e => e.ConfigureConsumer<MyConsumer>(ctx))`.

## 6. gRPC Internal Communication
- Proto contracts reside centrally in `services/_shared/Shared.Grpc/`.
- `exam-service` serves `ExamInternalGrpcService`.
- `attempt-service` consumes it via `ExamInternalClient`.
- Protect internal gRPC endpoints with internal API key authentication or network isolation.

## 7. Aspire AppHost Integration
- Never hardcode host ports or connection strings.
- Inject database references using `builder.AddPostgres(...).AddDatabase(...)` + `.WithReference(db)`.
- Re-use `deploy/envs/<name>.env` with `WithComposeEnvFile(name)` and discrete RabbitMQ envs with `WithRabbitMqEnv()`.
