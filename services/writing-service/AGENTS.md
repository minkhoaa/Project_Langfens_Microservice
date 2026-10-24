# Writing service
Owns writing submissions/evaluations; grades and compares through ai-service HTTP, with RabbitMQ orchestration.

- `Features/Service/{User,Admin}/` serves APIs; `Features/RabbitMq/WritingSubmittedConsumer.cs` is the active consumer (no `Features/Handler/` duplicate).
- Preserve its two flows: `SubmissionId` present reuses the pregraded standalone evaluation; absent creates/grades an attempt submission and publishes a correlated response.
- Attempt-origin submissions leave local `ExamId` null: the external exam ID is not a writing-db foreign key.
- Comparison is progressive/non-blocking; do not overwrite comparison already delivered or publish attempt responses for standalone submissions.
- `Features/Helper/AiWritingGrader.cs` and `AiCompareClient.cs` use `AI_SERVICE_URL`; preserve keyed `CircuitBreaker` singletons (`grader`, `compare`) and client timeouts.
- `Program.cs` wires `NpgsqlDataSource`/`WritingDbContext` explicitly; retain the `CONNECTIONSTRING__WRITING`/`writing-db` mapping when changing persistence bootstrap.
- `AddConsumer` plus `ConfigureEndpoints` controls queue naming; maintain compatibility with attempt-service message DTOs.
- Build from root: `dotnet build services/writing-service/writing-service.csproj`.
- No dedicated test project exists; isolate AI/DB/message dependencies. Manual E2E harness: `../../scripts/e2e/README.md` (requires running services).
- Cross-service flow reference: `../../docs/AI_ARCHITECTURE_AND_FLOWS.md`; confirm current routes in source before running probes.
