# Writing service
Submission/evaluation persistence, ai-service HTTP grading/comparison and RabbitMQ orchestration.

- `Features/RabbitMq/WritingSubmittedConsumer.cs`: `SubmissionId` present reuses standalone scores; absent creates/grades an attempt submission and publishes its correlated response.
- Attempt-origin `ExamId` stays null (external exam IDs are not writing-db foreign keys); standalone grading must not emit attempt responses.
- Comparison is progressive/non-blocking; never overwrite a delivered comparison.
- Preserve `AI_SERVICE_URL`, keyed singleton circuit breakers `grader`/`compare`, timeouts and `ConfigureEndpoints` queues.
- Keep explicit `NpgsqlDataSource`/`WritingDbContext` wiring and `CONNECTIONSTRING__WRITING` → `writing-db` mapping.
- Isolate AI/DB/broker; manual root command `python -m scripts.e2e.full_writing_flow` mutates a running stack and may call paid AI. Historical `../../scripts/e2e/README.md` prerequisites need source verification.
