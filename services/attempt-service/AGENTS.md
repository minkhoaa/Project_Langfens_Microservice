# Attempt service
Attempts, deterministic Reading/Listening grading, placement and analytics.

- `Features/Helpers/Grader.cs` defines `IQuestionGrader.Grade(AttemptAnswer, QuestionKey)`; register graders and `IQuestionGraderRegistration` as singletons in `Program.cs`.
- Current graders award zero or full question points, including multi-blank/multi-choice/matching; preserve numeric blank ordering, normalizers and manual-review semantics.
- Keys use `ExamInternalClient` with `ExamService__GrpcAddress`; HTTP lookup uses `EXAMSERVICE__EXAM__ADDRESS`. Both send the required `EXAMSERVICE__INTERNAL__API__KEY` as `X-Internal-Key` metadata/header.
- Preserve attempt/question correlation and queues `writing-graded-response` / `speaking-graded-response`; Azure insights (`AZURE_OPENAI__*`) are optional.
- Root unit-test command covers grading, normalization, exam auth/redaction and restart-safe seeders using isolated InMemory/TestServer fixtures without live DB/LLM; cover malformed/missing answers, multi-blank order and repeat determinism.
