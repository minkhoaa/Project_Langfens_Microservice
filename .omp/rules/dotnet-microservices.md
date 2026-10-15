---
description: Architectural patterns, minimal APIs, EF Core PostgreSQL conventions, MassTransit RabbitMQ, gRPC, and Aspire configuration for .NET 10 microservices.
globs:
  - "**/*.cs"
  - "**/*.csproj"
  - "**/appsettings*.json"
---

# .NET 10 Microservice Engineering Rules

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
- Follow the installed .NET 10 SDK and existing project settings; do not pin C# 13 or upgrade dependencies based on generic ECC examples.

## 3. Asynchronous Programming & Cancellation
- I/O paths accept and forward cancellation tokens to EF Core, HTTP/gRPC clients, and MassTransit.
- Never block on async code (`.Result`, `.Wait()`, `.GetAwaiter().GetResult()`).
- Reuse established bootstrap and client lifetime patterns; do not add retries or library-wide conventions unrelated to the requested change.

## 4. Entity Framework Core & PostgreSQL
- Each microservice owns its `DbContext` mapping to its dedicated PostgreSQL database.
- Use explicit migrations (`dotnet ef migrations add ... --output-dir Migrations`).
- In queries, use `.AsNoTracking()` for read-only operations.
- Avoid N+1 query problems by using explicit `.Include()` / `.ThenInclude()` or projection with `.Select()`.
- Preserve existing transaction/retry semantics; do not add blanket retries to non-idempotent operations.

## 5. Event-Driven Communication (RabbitMQ & MassTransit)
- Read connection details from discrete environment variables:
  `RABBITMQ__HOST`, `RABBITMQ__PORT`, `RABBITMQ__USERNAME`, `RABBITMQ__PASSWORD`, `RABBITMQ__VHOST`, `RABBITMQ__USESSL`.
- Consumers implement `IConsumer<TMessage>` and must be idempotent.
- Follow the service's existing MassTransit endpoint/consumer registration; do not establish a second queue-naming convention.

## 6. gRPC Internal Communication
- Proto contracts reside centrally in `services/_shared/Shared.Grpc/`.
- `exam-service` serves `ExamInternalGrpcService`.
- `attempt-service` consumes it via `ExamInternalClient`.
- Preserve actual per-endpoint internal authentication and policies; never substitute network isolation for required authentication.

## 7. Aspire AppHost Integration
- Never hardcode host ports or connection strings.
- Inject database references using `builder.AddPostgres(...).AddDatabase(...)` + `.WithReference(db)`.
- Re-use `deploy/envs/<name>.env` with `WithComposeEnvFile(name)` and discrete RabbitMQ envs with `WithRabbitMqEnv()`.

## 8. Grading & Cross-Service Contracts
- `IQuestionGrader.Grade(AttemptAnswer, QuestionKey)` returns `GradeResult`.
- `IQuestionGraderRegistration` exposes `IEnumerable<string> SupportedTypes` and `Create()`; register both concrete graders and registrations as singletons in `Program.cs`.
- Question types are shared string constants, not a new enum invented by a workflow.
- Preserve all-or-nothing `AwardedPoints`: `0` or `QuestionPoints`; no partial credit.
- Trace callers before changing shared DTOs/protos; update producers, consumers, and behavioral tests together. Generate EF migrations only for actual persisted schema changes.
