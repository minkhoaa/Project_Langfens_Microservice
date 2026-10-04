# 02 — Solution Structure & Shared Libraries

> Source-of-truth: `Project_Langfens_Microservice.sln`, `services/_shared/*/*.csproj`, `services/_shared/*/*`.

## Solution layout (from `.sln`)

Solution groups:

- `gateway/` → `api-gateway`
- `services/` → all 10 .NET services + `services/_shared/`
- `_shared/` (also nested) → `Shared.*` projects

Solution Items: `deploy/compose.yaml`.

Projects in solution (17):

1. `AppHost/AppHost.csproj` — Aspire orchestrator
2. `gateway/api-gateway/api-gateway.csproj` — YARP
3. `services/auth-service`
4. `services/exam-service`
5. `services/attempt-service`
6. `services/course-service`
7. `services/email-service`
8. `services/vocabulary-service`
9. `services/writing-service`
10. `services/speaking-service`
11. `services/dictionary-service`
12. `services/gamification-service`
13. `services/_shared/Shared.Bootstrap`
14. `services/_shared/Shared.Grpc`
15. `services/_shared/Shared.PublicContracts`
16. `services/_shared/Shared.Security`
17. `services/_shared/Shared.ServiceDefaults`
18. `services/exam-service.Tests` — only test project present

## Shared library: `Shared.Bootstrap`

Path: `services/_shared/Shared.Bootstrap/`

| File | What it does |
|---|---|
| `JwtSettings.cs` | POCO with `Issuer`, `Audience`, `SignKey`, `AccessTokenLifetimeSeconds=15` default. (auth-service also adds RSA-specific fields in its own copy `auth_service.Application.Common.JwtSettings`.) |
| `RabbitMqConfig.cs` | `record RabbitMqConfig { Host; Port=5672; VirtualHost="/"; Username; Password; UseSsl=false }` |
| `LangfensBootstrapExtensions.cs` | Service-registration helpers used by every .NET service |

Extensions (concrete signatures verified):

- `IServiceCollection AddLangfensAuth(this IServiceCollection, Func<string,string?> getEnv, bool saveToken=true, bool mapInboundClaims=false)` — reads `JwtSettings__Issuer/Audience/SignKey/AccessTokenLifetimeSeconds` (env-driven; **`SignKey` is the only HS256 secret required for verification**); adds `JwtBearer` with `ValidateIssuer/Audience/IssuerSigningKey/Lifetime=true`, `ClockSkew=TimeSpan.Zero`, `NameClaimType=CustomClaims.Sub`, `RoleClaimType=CustomClaims.Roles`.
- `IServiceCollection AddLangfensCors(this IServiceCollection, string[]? defaultOrigins=null)` — reads `CORS_ALLOWED_ORIGINS` or defaults `http://localhost:3000,http://127.0.0.1:3000`. CORS policy `"FE"` with `AllowAnyHeader/Method` + `AllowCredentials`.
- `IServiceCollection AddLangfensSwagger(this IServiceCollection, string title)` — `OpenApiInfo { Title, Version=v1 }`, Bearer security definition.
- `RabbitMqConfig BuildRabbitMqConfig(Func<string,string?> getEnv)` — required `RABBITMQ__USERNAME`/`PASSWORD`, optional `HOST`/`VHOST`/`PORT`/`USESSL`.
- `void ConfigureRabbitMqHost(this IRabbitMqBusFactoryConfigurator, RabbitMqConfig)` — sets host, port, vhost, username, password; TLS 1.2 if `UseSsl`.

**Auth issuance** (`auth-service/Application/Common/JwtTokenFactory.cs`):
- HS256 with `SymmetricSecurityKey(Encoding.UTF8.GetBytes(SignKey))`.
- Claims: `sub` (=user.Id), `scope` (space-joined), `sid` (session id), `roles` (one per role), `iat/nbf/jti`.
- Lifetime: `DateTime.UtcNow.AddSeconds(AccessTokenLifetimeSeconds)` (default 15s in shared lib; auth-service overrides to 3600 in its own `JwtSettings` copy).
- Note: `JwtSettings__RsaPrivateKeyPem` and `JwtSettings__KeyId` are loaded into the auth-service local settings, but **`JwtTokenFactory` uses HS256 (SymmetricSecurityKey)** — RSA fields exist for forward compatibility, not for current signing.

## Shared library: `Shared.Grpc`

Path: `services/_shared/Shared.Grpc/`

- `Contracts/exam_internal.proto` (`csharp_namespace = "Shared.Grpc.ExamInternal"`)
  - `service ExamInternal { rpc GetInternalExam(GetInternalExamRequest) returns (InternalDeliveryExam); rpc GetExamList(GetExamListRequest) returns (GetExamListResponse); }`
  - Messages: `InternalDeliveryExam`, `InternalDeliverySection`, `InternalDeliveryQuestionGroup`, `InternalDeliveryQuestion`, `InternalDeliveryOption`, `InternalCompletionAccept`, `InternalMatchPair`, `FlowChartNode`, `GetInternalExamRequest`, `GetExamListRequest`, `GetExamListResponse`, `ExamListItem`.
- `Shared.Grpc.csproj` is referenced by `attempt-service` (only consumer; `ExamInternalClient` injected via `AddGrpcClient<ExamInternal.ExamInternalClient>` with `ExamService__GrpcAddress` env).

## Shared library: `Shared.PublicContracts`

Path: `services/_shared/Shared.PublicContracts/`

| Folder | Purpose |
|---|---|
| `Contracts/Ai/RagFeedbackContracts.cs` | `RagFeedbackEnvelope`, `CriterionScore`, `Evidence`, `Suggestion` — single envelope returned by `/v1/reading/explain-item`, `/v1/listening/explain-item` |
| `Contracts/Auth_Email/UserRegisterdOtp.cs` | `record UserRegisteredSendOtp(Email, Otp, TtlSeconds)`, `record UserRegisteredConfirmOtp(Email, Otp)` |
| `Contracts/Auth_Email/TestPing.cs` | `record TestPing(Text, At)` |
| `Contracts/Course/Enums/*` | `CourseCategories` (22 categories, validates via `IsValid`), `CourseLevel` (A1-C2), `CourseStatus` (DRAFT/PUBLISHED), `EnrollmentStatus` (ACTIVE/CANCELLED/COMPLETED) |
| `Contracts/Deck/DeckCategory.cs` | TOEIC/IELTS/VSTEP; `IsValid` |
| `Contracts/Deck/DeckStatus.cs` | DRAFT/PUBLISHED |
| `Contracts/Exam/Enums/QuestionSkill.cs` | READING/LISTENING/WRITING/SPEAKING |
| `Contracts/Exam/Enums/QuestionType.cs` | **19 question types** (see `20_data_models_and_grading.md`) |
| `Contracts/Exam/Enums/ExamCategory.cs` | IELTS/TOEIC/VSTEP/PLACEMENT/EXERCISE/GRAMMAR |
| `Contracts/Exam/Enums/ExamLevel.cs` | A1-C2 |
| `Contracts/Exam/Enums/ExamStatus.cs` | DRAFT/PUBLISHED/ARCHIVED |
| `Contracts/Exam/InternalExamDto/SharedInternalExamDto.cs` | `InternalDeliveryExam`, `InternalDeliverySection`, `InternalDeliveryQuestionGroup`, `InternalDeliveryQuestion`, `InternalFlowChartNode`, `InternalDeliveryOption` records with `[JsonPropertyName]` + `SnapshotSanitizer` (strips `Correct`/`Accepted`/`Pairs`). |
| `Contracts/Exam/InternalExamDto/PaperWideNormalizer.cs` | Static `Normalize(InternalDeliveryExam)` + `NormalizeJsonElement(JsonElement)` renumbers `Q.idx` to paper-wide 1-based; falls back to section-level `questions[]` synthetic group when `QuestionGroups` empty. Adapters in `exam-service/Application/Common/PaperWideNormalizer.{Proto,ExamService}.cs`. |
| `Contracts/FlashCard/FlashCardStatus.cs` | DRAFT/PUBLISHED |
| `Contracts/FlashCard/UserDeckStatus.cs` | ACTIVE/INACTIVE |
| `Contracts/GlobalResponse.cs` | `record ApiResultDto(bool isSuccess, string message, object data)` |
| `Contracts/Speaking/SpeakingGradingRequest.cs` | `SpeakingGradingRequestMessage(AttemptId, UserId, QuestionId?, Skill, Prompt?, AudioUrl, Format?, Duration?, Bytes?, PublicId?)` |
| `Contracts/Speaking/SpeakingGradingResponse.cs` | `SpeakingGradingResponseMessage` with `TranscriptRaw`, `TranscriptNormalized`, `WordCount`, `OverallBand`, four `CriterionScore` (Fluency/Lexical/Grammar/Pronunciation), `Suggestions`, `ImprovedAnswer` |
| `Contracts/Speaking/SpeakingAudioMeta.cs` | `AudioUrl`, `Format?`, `DurationSec?`, `Bytes?`, `PublicId?` |
| `Contracts/Writing/WritingGradingRequest.cs` | `WritingGradeRequestMessage(AttemptId, UserId, QuestionId?, Type, TaskText?, AnswerText, TaskType="TASK_2", SubmissionId?)` |
| `Contracts/Writing/WritingGradingResponse.cs` | `WritingGradeResponseMessage` with `EssayRaw/normalized`, `WordCount`, `OverallBand`, four `CriterionScore` (TaskResponse/Coherence/Lexical/Grammar), `Suggestions`, `ImprovedParagraph`, `ComparativeAnalysisJson?` |
| `Events/GamificationEvents.cs` | `AttemptCompletedEvent(UserId, AttemptId, Skill?, Score)`, `CardReviewedEvent(UserId, CardId, Grade, IsCorrect)`, `LessonCompletedEvent(UserId, LessonId, CourseId)` |
| `Events/UserEvents.cs` | `UserCreatedEvent(UserId, Email, CreatedAt)` |

## Shared library: `Shared.Security`

Path: `services/_shared/Shared.Security/`

| File | What |
|---|---|
| `Roles/Roles.cs` | `public const string Admin = "ADMIN"; public const string User = "USER";` |
| `Scopes/*` | One file per domain — see `Shared.Security.Scopes.{CourseScope,ExamScope,AttemptScope,VocabScope,WritingScope,SpeakingScope,UserScope,EmailScope}` |
| `Scopes/RoleBasedScopeProvider.cs` | `CustomRoleOptions` dictionary: `ADMIN` → all scopes; `USER` → restricted set |
| `Claims/CustomClaims.cs` | `Sub`, `Scope`, `Roles` constant strings |
| `Helper/AuthExtension.cs` | `ClaimsPrincipal.HasAnyScope(params string[] scopes)` splits the `scope` claim by space |

## Shared library: `Shared.ServiceDefaults`

Path: `services/_shared/Shared.ServiceDefaults/Extensions.cs`

- `IHostApplicationBuilder.AddServiceDefaults<TBuilder>()` — wires OTel (logs/metrics/traces), default health checks, service discovery, HTTP client defaults with standard resilience handlers (retry + circuit breaker + timeout).
- `WebApplication.MapDefaultEndpoints()` — maps `/health` (live + ready JSON) and `/alive` (liveness only).

## Shared library: `Shared.ServiceDefaults/Extensions.cs` (concrete features)

| Concern | Implementation |
|---|---|
| Service discovery | `AddServiceDiscovery()` — used by `WithReference` for Aspire dynamic endpoints |
| OpenTelemetry | `ConfigureOpenTelemetry()` adds ASP.NET Core, HttpClient, runtime instrumentation; OTLP exporter conditional on `OTEL_EXPORTER_OTLP_ENDPOINT` |
| HTTP resilience | `ConfigureHttpClientDefaults` adds standard resilience (retry, circuit breaker, timeout) |
| Health checks | `AddDefaultHealthChecks` adds a self-check `self` |
| Endpoints | `MapDefaultEndpoints` exposes `/health` (with all checks) and `/alive` (liveness only) |

## Service Bootstrap pattern (concrete)

Every .NET service's `Program.cs` follows this shape:

```csharp
var builder = WebApplication.CreateBuilder(args);
builder.AddServiceDefaults();                              // Shared.ServiceDefaults
builder.Services.AddLangfensAuth(env => Environment.GetEnvironmentVariable(env));
builder.Services.Add<X>Authorization();                    // service-specific (e.g. AddExamAuthorization)
builder.Services.AddLangfensCors();
builder.Services.AddLangfensSwagger("<Service>");

// Database
builder.AddNpgsqlDbContext<<Service>DbContext>("<svc>-db", o => o.UseNpgsql(npgsql => npgsql.ExecutionStrategy(deps => new NonRetryingExecutionStrategy(deps))));

// RabbitMQ + MassTransit (where applicable)
builder.Services.AddMassTransit(cfg => { ... cfg.UsingRabbitMq(...) });

// Service-specific DI (singletons/scoped)

var app = builder.Build();
app.UseSwagger(); app.UseSwaggerUI();
app.UseCors("FE");
app.UseAuthentication(); app.UseAuthorization();
app.MapHealthChecks("/health", ...);
app.MapDefaultEndpoints();
app.Map<X>Endpoint();
app.Run();
```

Auth-service diverges with `AddIdentityCore<User>` + roles + `AddDefaultTokenProviders`. Email-service uses SMTP config and only `AddMassTransit` consumers. Dictionary-service does **not** call `AddLangfensAuth` (it has no auth — `AddLangfensSwagger` only). Writing-service uses `AddNpgsqlDataSource` + manual `DbContext` instead of `AddNpgsqlDbContext` (legacy bridge for `CONNECTIONSTRING__WRITING`).
