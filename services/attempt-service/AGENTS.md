# Attempt service
Owns attempts, deterministic Reading/Listening grading, placement and analytics.

- `Features/Helpers/` owns `IQuestionGrader.Grade(AttemptAnswer, QuestionKey)`; register graders and `IQuestionGraderRegistration` as singletons in `Program.cs`.
- Preserve per-grader scoring: completion/multi-blank is all-or-nothing; multi-target choice/matching has explicit partial-credit paths. Keep ordering, normalizers and manual-review semantics.
- Keys come through `ExamInternalClient` (`ExamService__GrpcAddress`); HTTP lookup uses `EXAMSERVICE__EXAM__ADDRESS` and its configured key.
- Keep response correlation and explicit queues `writing-graded-response` / `speaking-graded-response`; Azure insights (`AZURE_OPENAI__*`) are optional.
- From root: `dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj` (unit tests, no live DB/LLM).
- Grading regressions must cover malformed/missing answers, multi-blank order, partial-credit groups and repeat determinism.
