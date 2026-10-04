# 07 — attempt-service

> Source-of-truth: `services/attempt-service/*`. Verified by direct reads.

## Role in the system

Tracks exam attempts end-to-end: start, autosave, submit (auto-grade), list, retrieve results. Houses:

- **Abstract grader factory** for IELTS question types.
- **Reading/Listening per-item RAG explainer** clients (call ai-service).
- **AI insights** (optional Azure OpenAI).
- **Band predictor + recommendation + study plan + bookmarks + notes**.
- **gRPC client** to `exam-service.ExamInternal.GetInternalExam`.
- **MassTransit publisher + consumer**: publishes grading requests, consumes writing/speaking grading responses, emits `AttemptCompletedEvent`.

## Stack

- ASP.NET Core 10, EF Core + Npgsql (`NonRetryingExecutionStrategy`).
- MassTransit + RabbitMQ.
- gRPC client (`ExamInternal.ExamInternalClient`).
- HttpClient for `ai-service` RAG explainers.
- Optional Azure OpenAI (`AZURE_OPENAI__ENDPOINT/APIKEY/DEPLOYMENT`).

## Endpoints (`/api/attempt`)

`Features/Attempt/AttemptEndpointMapping`:

| Method | Path | Scope |
|---|---|---|
| POST | `/api/attempt/attempts:start` | `AttemptScope.AttemptStart` |
| POST | `/api/attempt/attempts:status` | `AttemptScope.AttemptStart` |
| GET | `/api/attempt/{attemptId:guid}` | `AttemptScope.AttemptReadOwn` |
| POST | `/api/attempt/autosave/{attemptId:guid}` | `AttemptScope.AttemptReadOwn` |
| POST | `/api/attempt/submit/{attemptId:guid}` | `AttemptScope.AttemptSubmit` |
| GET | `/api/attempt/getresult/{attemptId:guid}` | `AttemptScope.AttemptReadOwn` |
| GET | `/api/attempt/getlistattempt` | `AttemptScope.AttemptReadOwn` |
| GET | `/api/attempt/placement` | `AttemptScope.AttemptReadOwn` |
| GET | `/api/attempt/placement/status` | `AttemptScope.AttemptReadOwn` |
| GET | `/api/admin/attempt/` | `AttemptScope.AttemptReadAny` |

Additional endpoints mounted from `Program.cs`:

- `app.MapAdminEndpoint();` — admin attempt list
- `app.MapAnalyticsEndpoints();`
- `app.MapStudyPlanEndpoints();`
- `app.MapBookmarkEndpoints();`
- `app.MapNoteEndpoints();`

## Grader architecture (key abstraction)

`Features/Helpers/QuestionGraderFactory.cs` + `Features/Helpers/QuestionGraderRegistration.cs`:

```csharp
public interface IQuestionGraderRegistration
{
    IEnumerable<string> SupportedTypes { get; }
    IQuestionGrader Create();
}

public interface IQuestionGraderFactory
{
    IQuestionGrader Resolve(string questionType);
}

public class QuestionGraderFactory : IQuestionGraderFactory
{
    private readonly IReadOnlyDictionary<string, IQuestionGraderRegistration> _map;
    public QuestionGraderFactory(IEnumerable<IQuestionGraderRegistration> registrations)
    {
        _map = registrations.SelectMany(k => k.SupportedTypes.Select(t => (Type: t, Reg: k)))
            .ToDictionary(x => x.Type, x => x.Reg, StringComparer.OrdinalIgnoreCase);
    }
    public IQuestionGrader Resolve(string questionType) =>
        _map.TryGetValue(questionType, out var g)
            ? g.Create()
            : throw new NotSupportedException($"Unsupported question type: {questionType}");
}
```

Registered graders (DI):

| Grader | Registration | Supported types |
|---|---|---|
| `SingleChoiceGrader` | `SingleChoiceGraderRegistration` | `MultipleChoiceSingle`, `MultipleChoiceSingleImage` |
| `MultipleChoiceGrader` | `MultipleChoiceGraderRegistration` | `MultipleChoiceMultiple`, `TrueFalseNotGiven`, `YesNoNotGiven` |
| `CompletionGrader` | `CompletionGraderRegistration` | `SummaryCompletion`, `TableCompletion`, `NoteCompletion`, `FormCompletion`, `SentenceCompletion` |
| `LabelGrader` | `LabelGraderRegistration` | `DiagramLabel`, `MapLabel` |
| `MatchingHeadingGrader` | `MatchingHeadingGraderRegistration` | `MatchingHeading`, `MatchingInformation`, `MatchingFeatures`, `MatchingEndings`, `Classification` |
| `FlowChartGrader` | `FlowChartGraderRegistration` | `FlowChart` |
| `ShortAnswerGrader` | `ShortAnswerGraderRegistration` | `ShortAnswer` |

Helpers:
- `IAnswerKeyBuilder`, `IBuildQuestionIdSet`, `IQuestionIndex`, `IIndexBuilder`, `IAnswerValidator` — singletons.
- `IPlacementWorkflow` — orchestrator for placement tests.
- `PlacementLevelMapper` — maps score → CEFR/band.
- `IeltsBandConverter` — number ↔ band string.
- `ExamGateway` — gRPC wrapper around `ExamInternalClient`.
- `Listening/ListeningGrader.cs` + `ListeningExplainerClient.cs` — listening-specific auto-grade + RAG explainer.
- `Reading/ReadingGrader.cs` + `ReadingExplainerClient.cs` — reading-specific auto-grade + RAG explainer.
- `RagExplainer/SkillRagExplainer.cs` + `RagFeedbackPayload.cs` — orchestrates per-skill explainer; produces `RagFeedbackEnvelope`.

## Consumers / publishers

`Features/RabbitMq/`:

- `WritingGradedConsumer : IConsumer<WritingGradeResponseMessage>` — queue `writing-graded-response` → forwards to `PlacementWorkflow.OnWritingGradedAsync` (updates `PlacementResult.WritingBand` + `WritingGradeJson`, recomputes level, may flip attempt status to `Graded`).
- `SpeakingGradedConsumer : IConsumer<SpeakingGradingResponseMessage>` — queue `speaking-graded-response` → forwards to `PlacementWorkflow.OnSpeakingGradedAsync` (analogous writing/speaking band updates).

Publishing sites:

- `PlacementWorkflow.OnPlacementSubmittedAsync` (placement path) → publishes `WritingGradeRequestMessage` AND `SpeakingGradingRequestMessage` only when the corresponding answer exists (`Flow B`, `SubmissionId = null`). **This is the only source of writing/speaking AI-grading RabbitMQ traffic.** Source: `services/attempt-service/Features/Helpers/PlacementWorkflow.cs` lines 110–146.
- `AttemptService.Submit` → publishes `AttemptCompletedEvent(UserId, AttemptId, Skill="READING", correctCount)` on **every** submission (placement or not). Source: `services/attempt-service/Features/Attempt/AttemptEndpoint/AttemptService.cs` line 690.
- `PlacementWorkflow.OnWritingGradedAsync` / `OnSpeakingGradedAsync` do **not** publish `AttemptCompletedEvent` — the XP award is tied to the always-emitted event from `AttemptService.Submit`.

## RAG explainer HTTP clients

`AddHttpClient<IReadingExplainerClient, ReadingExplainerClient>(...)` and `AddHttpClient<IListeningExplainerClient, ListeningExplainerClient>(...)` — both target `AI_SERVICE_URL/v1/{skill}/explain-item`.

`AI_SERVICE_URL` discovery logic in `Program.cs` (verbatim): explicit env → Aspire-injected → `DiscoverAiServiceUrl()` (Docker socket lookup) → fallback `http://localhost:8092`.

## Analytics / extras

`Features/Analytics/`:

- `AiInsightsService` + `AiInsightsPrompt` + `AiInsightsDto` — optional Azure OpenAI insights.
- `AnalyticsService` + `AnalyticsEndpoint` + `AnalyticsDtos` — per-user analytics.
- `BandPredictorService` — predicts next band from history.
- `RecommendationService` — recommends next action.

`Features/Bookmarks/`, `Features/Notes/`, `Features/StudyPlan/` — same pattern.

## Database / migrations

- Aspire-injected `attempt-db` (port 5435).
- `NonRetryingExecutionStrategy` (manual transactions).
- Migration assembly: same project.

## Health checks

- `attempt-db` (NpgSql)
- `rabbitmq` (URI-based AMQP probe)

## Environment variables (verified)

| Key | Purpose |
|---|---|
| `ExamService__GrpcAddress` | gRPC address (default `http://exam-service:8081`) |
| `EXAMSERVICE__EXAM__ADDRESS` | REST internal address for attempt metadata fetch |
| `EXAMSERVICE__INTERNAL__API__KEY` | required on startup |
| `RABBITMQ__HOST/PORT/USERNAME/PASSWORD/VHOST/USESSL` | broker |
| `AZURE_OPENAI__ENDPOINT`, `AZURE_OPENAI__APIKEY`, `AZURE_OPENAI__DEPLOYMENT` | optional AI insights |
| `AI_SERVICE_URL` | injected by AppHost |
| `ConnectionStrings__attempt-db` | Aspire-injected |

## Why `NonRetryingExecutionStrategy`?

`Program.cs` comment: "Disable retrying execution strategy because Submit uses explicit transactions". EF Core's retrying strategy is incompatible with user-initiated transactions.
