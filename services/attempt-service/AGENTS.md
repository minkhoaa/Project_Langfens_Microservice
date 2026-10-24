# Attempt service
Owns attempts, deterministic Reading/Listening scoring, placement and analytics; consumes AI grading responses.

- `Features/Attempt/`: workflow, exam gateway and user context; `Features/Helpers/`: grader factory/registrations, with Reading/Listening strategies.
- `IQuestionGrader.Grade(AttemptAnswer, QuestionKey)` returns `GradeResult`; reuse this contract and existing normalizers.
- Register concrete graders and `IQuestionGraderRegistration` as singletons in `Program.cs`; registrations expose `SupportedTypes` and `Create()`.
- Scoring is all-or-nothing: `AwardedPoints` is `0` or `QuestionPoints`, including multi-blank answers. Preserve manual-review/error semantics and answer ordering.
- Question types are shared strings; do not broaden accepted variants or scoring policy as incidental cleanup.
- Fetch answer keys through `ExamInternalClient` (`ExamService__GrpcAddress`); internal HTTP uses `EXAMSERVICE__EXAM__ADDRESS` plus its configured key.
- `Features/RabbitMq/` receives writing/speaking results on explicit response queues; preserve message correlation and existing queue names.
- `Infrastructure/Persistence/AttemptDbContext.cs` owns attempt data; Azure OpenAI insights are optional (`AZURE_OPENAI__*`).
- From root: `dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj` (unit tests; no live DB/LLM required).
- Cover exact/incorrect/malformed/missing input, multi-blank ordering and deterministic repeat grading; contract changes also require exam verification.
