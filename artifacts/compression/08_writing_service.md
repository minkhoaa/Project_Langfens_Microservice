# 08 — writing-service

> Source-of-truth: `services/writing-service/*`. Verified by direct reads.

## Role in the system

IELTS Writing grading. **Two distinct request paths converge on the same evaluator**:

1. **Direct user submission** (`POST /api/writing/grade`):
   - `WritingService.WritingSubmit` synchronously calls `_grader.GradeAsync` → HTTP `ai-service /api/v1/writing/grade` (with circuit breaker).
   - Persists `WritingSubmission` + `WritingEvaluation`, returns bands to the FE.
   - Then publishes `WritingGradeRequestMessage` with **`SubmissionId` populated (Flow A)** for an asynchronous progressive comparison (the user's evaluation row already exists; the consumer's job is to attach a `ComparativeAnalysisJson`).
2. **Placement flow** (triggered by `attempt-service/PlacementWorkflow` for `ExamCategory.PLACEMENT` attempts):
   - `attempt-service` publishes `WritingGradeRequestMessage` with `SubmissionId = null` (**Flow B**).
   - `WritingSubmittedConsumer` (queue `writing-submitted`) consumes it, runs `AiWritingGrader` + `AiCompareClient`, persists the evaluation, publishes `WritingGradeResponseMessage` on queue `writing-graded-response`.
   - `attempt-service.WritingGradedConsumer` invokes `PlacementWorkflow.OnWritingGradedAsync` → updates `PlacementResult.WritingBand` + `WritingGradeJson`, recomputes `PlacementLevelMapper.Map(...)`, and flips attempt status to `Graded` when both writing + speaking are in.

The two flows are disambiguated by the `SubmissionId` field on `WritingGradeRequestMessage`.

## Stack

- ASP.NET Core 10, EF Core + Npgsql.
- MassTransit (consumer + publisher).
- HttpClient to `ai-service` with keyed circuit breaker.

## Persistence — legacy bridge

`Program.cs` uses `AddNpgsqlDataSource` + manual `DbContext` instead of `AddNpgsqlDbContext`. Reason: writing-service reads `CONNECTIONSTRING__WRITING` (legacy env) and Aspire injects both that key and the standard `ConnectionStrings__writing-db`:

```csharp
var writingDbConnString = EnvOrDefault("CONNECTIONSTRING__WRITING",
    "Host=writing-database;Port=5432;Database=writing-db;Username=writing;Password=writing");
builder.Configuration.GetSection("ConnectionStrings")["writing-db"] = writingDbConnString;

builder.AddNpgsqlDataSource("writing-db");
var npgsqlDataSource = new Npgsql.NpgsqlDataSourceBuilder(writingDbConnString).Build();
builder.Services.AddSingleton(npgsqlDataSource);
builder.Services.AddDbContext<WritingDbContext>(o => o.UseNpgsql(npgsqlDataSource, npg =>
    npg.MigrationsAssembly(typeof(WritingDbContext).Assembly.GetName().Name)));
```

AppHost sets `CONNECTIONSTRING__WRITING = writingDb.Resource.ConnectionStringExpression` to satisfy this legacy path.

## Endpoints

`Features/WritingEndpoint.cs`:

| Method | Path | Auth |
|---|---|---|
| POST | `/api/writing/grade` | `Roles.User` |
| GET | `/api/writing/exams` | anonymous |
| POST | `/api/writing/start/{examId}` | (anonymous) |
| GET | `/api/writing/exams/{examId:guid}` | (anonymous) |
| GET | `/api/writing/history` | `Roles.User` |
| GET | `/api/writing/history/{submissionId:guid}` | `Roles.User` |
| GET | `/api/writing/{submissionId:guid}/comparison` | `Roles.User` |

Admin endpoints:

| Method | Path | Auth |
|---|---|---|
| GET | `/api/admin/writing/exams` | `Roles.Admin` |
| POST | `/api/admin/writing/create` | `Roles.Admin` |
| POST | `/api/admin/writing/exams` | `Roles.Admin` |
| PUT | `/api/admin/writing/exams/{examId:guid}` | `Roles.Admin` |
| DELETE | `/api/admin/writing/exams/{examId:guid}` | `Roles.Admin` |

## AI integration

- `IWritingGrader` → `AiWritingGrader` POSTs `ai-service /api/v1/writing/grade` with 90s timeout.
- `IAiCompareClient` → `AiCompareClient` POSTs `ai-service /api/v1/writing/compare`.
- AI URL: `AI_SERVICE_URL` env (default `http://localhost:8092`). Aspire overrides to `http://ai-service:8080` internally.

## Circuit breaker

`Features/Helper/CircuitBreaker.cs`:

- States: `Closed`, `Open`, `HalfOpen`.
- Thresholds: `FailureThreshold=5`, `SuccessThreshold=3`, `TimeoutSeconds=30`, `WindowSeconds=10`.
- Registered as **keyed singletons**:
  - `"grader"` for `IWritingGrader`
  - `"compare"` for `IAiCompareClient`
- `IsOpen` => request short-circuits; `CanExecute` permits `HalfOpen` probes; failures advance through `WindowSeconds` rolling window.

## Consumer pattern

`Features/RabbitMq/WritingSubmittedConsumer.cs` is a MassTransit `IConsumer<WritingGradeRequestMessage>`. `Program.cs` calls `bus.ConfigureEndpoints(ctx)` with **no** explicit `ReceiveEndpoint(...)` and **no** `KebabCaseEndpointNameFormatter` (verified at `services/writing-service/Program.cs:102`); MassTransit's default `DefaultEndpointNameFormatter` applies PascalCase **with the trailing `Consumer` suffix stripped** to the class name — i.e., `WritingSubmittedConsumer` → receive queue **`WritingSubmitted`**. (Note: `auth-service` is the only service in the repo that configures a `KebabCaseEndpointNameFormatter`, so do not assume kebab-case naming elsewhere.)

The consumer branches on `request.SubmissionId.HasValue` (Flow A vs. Flow B); for Flow B it also publishes `WritingGradeResponseMessage` back to attempt-service. For Flow A it does **not** publish a response — the FE reads the comparison via `GET /api/writing/{submissionId:guid}/comparison`.

`Features/Handler/WritingHandler.cs` — endpoint handlers (no MassTransit dependency; thin).

## Health checks

- `writing-db` (NpgSql)
- RabbitMQ not explicitly probed (MassTransit handles its own retries).

## Environment variables (verified)

| Key | Purpose |
|---|---|
| `CONNECTIONSTRING__WRITING` | legacy PG conn string (Aspire sets it) |
| `ConnectionStrings__writing-db` | Aspire-injected |
| `AI_SERVICE_URL` | ai-service base |
| `RABBITMQ__HOST/PORT/USERNAME/PASSWORD/VHOST/USESSL` | broker |
| `JwtSettings__*` | shared bootstrap |

## Authorization

`AddWritingAuthorization()` (service-local):

- `Roles.User` → `RequireRole(Roles.User)`
- `Roles.Admin` → `RequireRole(Roles.Admin)`
- `WritingScope.WritingStart`, `WritingScope.WritingCreate`, `WritingScope.WritingViewOwn`, `WritingScope.WritingViewAny` (via `HasAnyScope`).
