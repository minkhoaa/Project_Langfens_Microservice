# Exam service
PostgreSQL exam/question-bank authority with admin/public HTTP APIs and internal HTTP/gRPC delivery.

- `Features/Exams/` owns delivery/admin, `Features/QuestionBank/` bank operations, `Infrastructure/Persistence/ExamDbContext.cs` schema.
- Startup migrates and invokes `Data/{ReadingSeeder,GeneratedReadingSeeder}.cs`; preserve slug idempotency and Npgsql dynamic JSON mapping.
- Public reads require `Published` status and omit answer keys; preserve admin authorization and `showAnswers` redaction in internal mappers.
- Security gap: gRPC is mapped anonymous and has no key check; internal HTTP requires JWT, not the `X-Internal-Key` attempt sends. Do not assume either is service-key-protected or expose them publicly.
- Preserve paper-wide 1-based indices/group bounds across HTTP, proto and shared DTOs; question-type changes require attempt grader checks.
- `MatchPairs` values are `[gradingKey, displayText]`; completion keys are numeric 1-based strings. Schema changes alone warrant migrations.
- Seeder/normalizer regressions live in `../attempt-service.Tests/`; no exam test project exists. Inspect isolation/cleanup before running any restored DB fixtures; legacy fixtures dropped schemas/had hardcoded targets.
