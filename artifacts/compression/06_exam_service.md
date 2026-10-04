# 06 — exam-service

> Source-of-truth: `services/exam-service/*`. Verified by direct reads.

## Role in the system

Owns exam content (exams → sections → question groups → questions → options). Exposes:

- **Public REST** for browsing published exams (anonymous).
- **Admin REST** (scoped by `ExamScope.ExamRead/Manage` and `Roles.Admin`) for CRUD.
- **gRPC** for `attempt-service` internal consumption (answer-key lookup with optional `ShowAnswers` flag).
- **Internal REST** delivery endpoint for attempt-service.
- **Reading Paper orchestration**: durable `ReadingPaperJob` rows + worker that streams NDJSON from `generation-service` and persists section/audit/review logs.

## Stack

- ASP.NET Core 10, EF Core + Npgsql.
- gRPC (`Microsoft.AspNetCore.Grpc` + protobuf in `Shared.Grpc`).
- `NpgsqlDataSource.EnableDynamicJson()` for jsonb → CLR type mapping (`Dictionary<,>`, `List<>`).
- `HttpClient<ReadingPaperAiClient>` for `generation-service` calls.

## Persistence

`ExamDbContext` covers `Exams`, `Sections`, `Questions`, `Options`, `QuestionGroups`, and Reading-Paper tables (`ReadingPaperJob`, `ReadingPaperJobLog`, `ReadingPaperBudgetAllocation` per migrations `20260924120000_AddReadingPaperJobs`, `20260925120000_AddReadingPaperJobLogs`, `20260930120000_AddReadingPaperDurablePersistence`, `20260930130000_AddReadingPaperBudgetAllocations`).

Notable migrations: `20260907090000_NormalizeLegacyQuestionTypeAliases`, `20260908083459_AddImageUrlToOptionAndQuestion`, `20260909_RemoveFlowChartCompletionAndAudioResponse`.

Health check: `exam-db` (NpgSql).

## Kestrel & multiplexing

`AppHost/Program.cs` declares two endpoints:

```csharp
.WithHttpEndpoint(name: "http", env: "Kestrel__HttpPort")
.WithHttpEndpoint(name: "grpc", env: "Kestrel__GrpcPort")
```

`Program.cs` falls back to `ConfigureLangfensKestrel(httpPort:8080, grpcPort:8081)` when `ASPNETCORE_URLS` is empty (compose path). Under Aspire, ASPNETCORE_URLS is injected and Kestrel multiplexes HTTP/1.1 + HTTP/2 on the same port; clients distinguish by content-type.

## Endpoints (concrete)

`Program.cs` map calls:

- `app.MapGrpcService<ExamInternalGrpcService>().AllowAnonymous();` ← gRPC endpoint is **registered as anonymous** at the server side; the `ExamInternalGrpcService` implementation performs **no internal-API-key validation**. Auth-at-edge is expected (gateway / network policy).
- `app.MapPublicExamEndpoints();` — `/api/public/exam/getall`, `/api/public/exam/getby/{slug}` (anonymous)
- `app.MapAdminExamEndpoint();` — `/api/admin/exam/addexam`, `/all`, `/update/{id}`, `/delete/{id}` (Admin)
- `app.MapAdminSectionEndpoint();` — `/api/admin/section/add|update|delete|by-exam/{examId}` (`ExamScope.ExamManage`)
- `app.MapAdminQuestionEndpoint();` — `/api/admin/question/add|update|delete|by-section/{sectionId}` (Admin)
- `app.MapAdminOptionEndpoint();` — `/api/admin/option/add|update|delete|by-question/{questionId}` (Admin)
- `app.MapInternalExamEndpoint();` — `GET /api/internal/exams/{id}/delivery` (`RequireAuthorization()`)
- `app.MapQuestionBankEndpoints();` — `/api/question-bank/...`
- `app.MapReadingPaperEndpoints();` — `/api/admin/reading-paper/...` (job CRUD)
- `app.MapCheckpointEndpoints();` — durable Reading-Paper **checkpoint service surface** at `/api/internal/reading-paper/checkpoints` (gated by an endpoint filter that checks a service-auth header). The 8 operations are:
  - `POST /grant-operation` — operation grant request
  - `POST /budgets/allocate` — set budget allocations
  - `POST /operations/reconcile` — operation reconciliation
  - `POST /commit` — checkpoint commit
  - `POST /unknown-outcome` — report unknown outcome for a previously untracked op
  - `GET /resume/{runId}` — resume state lookup
  - `POST /invalidate` — invalidate a dependency
  - `POST /build-exam` — build an exam from a finalized checkpoint

  (See `services/exam-service/Features/ReadingPaper/CheckpointEndpoints.cs`. Each handler takes `[FromBody] <Request>` and uses `ExamDbContext` directly.)
- `app.MapAdminUploadEndpoint();` — `/api/admin/upload/...`
- `app.UseStaticFiles();` — serves `/uploads/images/...`

## gRPC service

`Features/Exams/InternalEndpoint/ExamInternalGrpcService.cs : ExamInternal.ExamInternalBase`:

- `GetInternalExam(GetInternalExamRequest)` — loads exam + sections + questions + options + question groups, calls `ProtoHelper.MapToProto(exam, request.ShowAnswers)` and returns `InternalDeliveryExam`.
- `GetExamList(GetExamListRequest)` — filters by category, defaults limit 50, returns `ExamListItem{Id, Title, Category, QuestionCount, DurationMin}`.

Consumed by `attempt-service` (`AddGrpcClient<ExamInternal.ExamInternalClient>` + `AppContext.SetSwitch("System.Net.Http.SocketsHttpHandler.Http2UnencryptedSupport", true)` for h2c).

## Paper-wide index normalization

`Shared.PublicContracts/Contracts/Exam/InternalExamDto/PaperWideNormalizer.cs` (shared):

- `Normalize(InternalDeliveryExam)` — renumbers `Q.idx` paper-wide 1-based; if `QuestionGroups` empty, falls back to section-level `questions[]` synthetic group (mirrors `ProtoHelper.MapToProto`).
- `NormalizeJsonElement(JsonElement)` — same logic for stored snapshots.

Two adapters live in `exam-service/Application/Common/PaperWideNormalizer.{Proto,ExamService}.cs`.

## Snapshot sanitization

`SnapshotSanitizer` (in `SharedInternalExamDto.cs`) strips `Correct`/`Accepted`/`Pairs` fields when serializing snapshots to FE.

## Seeders

- `services/exam-service/Data/ReadingSeeder.cs`
- `services/exam-service/Data/ListeningSeeder.cs`
- `services/exam-service/Data/GeneratedReadingSeeder.cs`
- `services/exam-service/Data/SeederHelpers.cs`

## Reading Paper pipeline

`Features/ReadingPaper/`:

- `ReadingPaperModels.cs` — DTOs.
- `ReadingPaperAiClient.cs` — HttpClient wrapper to `generation-service /v1/autogen/reading-paper/*`.
- `ReadingPaperWorker.cs` — `IHostedService` polling durable jobs, dispatching sections.
- `ReadingPaperEndpoints.cs` — admin endpoints to enqueue jobs.
- `CheckpointService.cs` + `CheckpointEndpoints.cs` — durable checkpoint service backing the 8 internal endpoints listed above.
- `Contracts/` — internal request/response types.

Env injection: `AI_SERVICE_URL` and `GENERATION_SERVICE_URL` are set by AppHost (`exam.GetEndpoint("http")` for both).

## Authorization (`AddExamAuthorization`)

```csharp
opts.AddPolicy(Roles.User,  p => p.RequireRole(Roles.User));
opts.AddPolicy(Roles.Admin, p => p.RequireRole(Roles.Admin));
opts.AddPolicy(ExamScope.ExamRead,   p => c.User.HasAnyScope(ExamScope.ExamRead)   || c.User.IsInRole(Roles.User));
opts.AddPolicy(ExamScope.ExamManage, p => c.User.HasAnyScope(ExamScope.ExamManage) || c.User.IsInRole(Roles.Admin));
```

No fallback policy → `/health`, `/alive`, swagger stay anonymous.

## Internal HTTP client (used by attempt-service, not exam-service)

attempt-service's `HttpClient "ExamServiceInternal"` sends requests to `EXAMSERVICE__EXAM__ADDRESS` with header `X-Internal-Key: ${EXAMSERVICE__INTERNAL__API__KEY}` (placeholder `"dev-internal-key-not-for-prod"` under AppHost). **The server side of exam-service does not read or validate this header** — `InternalExamEndpoint` is gated by `RequireAuthorization()` (JWT), and the `X-Internal-Key` header is silently ignored. The `EXAMSERVICE__INTERNAL__API__KEY` env var is **required on attempt-service startup** (it throws otherwise).

## Environment variables (verified)

| Key | Purpose |
|---|---|
| `Kestrel__HttpPort`, `Kestrel__GrpcPort` | compose-mode ports |
| `ASPNETCORE_URLS` | Aspire-injected |
| `KESTREL_GRPC_PORT` | Aspire-injected (named endpoint) |
| `AI_SERVICE_URL` | injected by AppHost |
| `GENERATION_SERVICE_URL` | injected by AppHost |
| `ConnectionStrings__exam-db` | Aspire-injected |
| `EXAMSERVICE__EXAM__ADDRESS` | NOT used inside exam-service itself (consumed by attempt-service) |
| `EXAMSERVICE__INTERNAL__API__KEY` | NOT used inside exam-service itself; required on attempt-service startup |

## What exam-service does NOT do

- No RabbitMQ consumer / publisher.
- No EF Core retry strategy (`ExecutionStrategy = NonRetryingExecutionStrategy`) — explicit transactions in attempt-service use the same pattern.
- gRPC server runs on the same Kestrel instance as HTTP/1.1 under Aspire (multiplexed).
