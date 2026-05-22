# attempt-service

Manages exam attempts, auto-scoring, and AI insight generation.

## Service Overview
- **Port**: 5435 (HTTP)
- **Stack**: ASP.NET Core 10, EF Core + Npgsql, MassTransit/RabbitMQ, gRPC client, Azure OpenAI (optional)
- **Database**: PostgreSQL via AttemptDbContext
- **Key patterns**: Auto-graders per question type, AI-assisted insights, gRPC call to exam-service, RabbitMQ consumers for AI grading results

## Key Files
```
Program.cs                           Entry point
Infrastructure/
  Configuration/BootstrapExtensions.cs  Service-local extensions
  Persistence/AttemptDbContext.cs    EF Core DbContext
Migrations/                          EF Core migrations
Features/
  Attempt/AttemptEndpoint/            Submit, retrieve, complete attempts (REST)
  Attempt/                           AttemptService, ExamGateway, UserContext
  Analytics/                         AnalyticsService, BandPredictorService, RecommendationService
  Bookmarks/                        BookmarkService
  Notes/                             NoteService
  StudyPlan/                         StudyPlanService
  Helpers/                           Grader components (SingleChoiceGrader, MultipleChoiceGrader, etc.)
  RabbitMq/                          MassTransit consumers (WritingGradedConsumer, SpeakingGradedConsumer)
```

## Grader Pattern (key architecture)
Each question type has a dedicated grader implementing `IQuestionGrader`:
- `SingleChoiceGrader`, `MultipleChoiceGrader`, `CompletionGrader`, `LabelGrader`, `MatchingHeadingGrader`, `FlowChartGrader`, `ShortAnswerGrader`
- Registration via `IQuestionGraderRegistration` (singleton per type)
- Factory: `QuestionGraderFactory` resolves correct grader by `QuestionType`
- **Adding a new question type**: Implement `IQuestionGrader`, create `{Type}Grader.cs` + `{Type}GraderRegistration.cs`, register in `Program.cs`

## Common Operations

### Adding a new attempt endpoint
1. Add to `Features/Attempt/AttemptEndpoint/` as `{Action}Endpoint.cs`
2. Use `app.MapAttemptEndpoint()` pattern — or add directly in `Program.cs` `app.Map{Action}Endpoint()`
3. Inject `IAttemptService`, `UserManager`, etc.

### Adding a new MassTransit consumer
1. Create `Features/RabbitMq/{EventName}Consumer.cs` implementing `IConsumer<TMessage>`
2. Register: `cfg.AddConsumer<WritingGradedConsumer>()` + `bus.ReceiveEndpoint("queue-name", e => e.ConfigureConsumer<...>(ctx))`
3. Current consumers:
   - `WritingGradedConsumer` → queue: `writing-graded-response`
   - `SpeakingGradedConsumer` → queue: `speaking-graded-response`

### Updating the placement workflow
- `IPlacementWorkflow` in `Features/Attempt/` — orchestrates initial placement test scoring

### DB Migrations
```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/attempt-service
dotnet ef migrations add <Name> --project attempt-service.csproj --output-dir Migrations
dotnet ef database update --project attempt-service.csproj
```

## How This Service Communicates with Others
- **gRPC client** → `exam-service` (`ExamInternalClient`) for answer key lookup
  - Env: `ExamService__GrpcAddress` (default `http://exam-service:8081`)
- **REST internal** → `exam-service` at `EXAMSERVICE__EXAM__ADDRESS` with `X-Internal-Key` header
- **RabbitMQ publisher**: Publishes grading requests → `writing-service`, `speaking-service`
- **RabbitMQ consumer**: Receives grading results from AI services
- **Azure OpenAI** (optional): AI insights on attempts via `IAiInsightsService`

## AI Integration Points
- `IAiInsightsService` — optional, activated when `AZURE_OPENAI__ENDPOINT` + `AZURE_OPENAI__APIKEY` are set
- Deployment: `AZURE_OPENAI__DEPLOYMENT` (default `gpt-4o-mini`)
- Used for: generating per-attempt insights/recommendations

## Testing Patterns
- Unit tests: Test graders independently (mock correct answer, assert score)
- Consumer tests: Publish test message to in-memory MassTransit bus → assert DB state
- `AttemptDbContext` with test connection string for integration tests

## Environment Variables
```
ExamService__GrpcAddress, EXAMSERVICE__INTERNAL__API__KEY, EXAMSERVICE__EXAM__ADDRESS,
RABBITMQ__HOST, RABBITMQ__USERNAME, RABBITMQ__PASSWORD, RABBITMQ__VHOST, RABBITMQ__PORT,
AZURE_OPENAI__ENDPOINT, AZURE_OPENAI__APIKEY, AZURE_OPENAI__DEPLOYMENT,
Aspire: attempt-db connection string
```