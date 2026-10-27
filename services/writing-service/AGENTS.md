# Writing service
Submission/evaluation persistence, ai-service HTTP grading/comparison and RabbitMQ orchestration.

- `Features/RabbitMq/WritingSubmittedConsumer.cs`: `SubmissionId` present reuses standalone grading; absent creates/grades an attempt submission and publishes its correlated response.
- Attempt-origin `ExamId` stays null: external exam IDs are not writing-db foreign keys; standalone submissions must not emit attempt responses.
- Comparison is progressive/non-blocking; never overwrite a delivered comparison.
- `AI_SERVICE_URL` configures clients; preserve keyed singleton circuit breakers `grader`/`compare` and timeouts.
- Keep explicit `NpgsqlDataSource`/`WritingDbContext` wiring and `CONNECTIONSTRING__WRITING` → `writing-db` mapping; `ConfigureEndpoints` controls queues.
- No dedicated tests; isolate AI/DB/broker. Manual stack-dependent harness: `../../scripts/e2e/README.md`.
