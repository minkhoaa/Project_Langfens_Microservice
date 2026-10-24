# Exam service
Owns exam content/delivery/publication and authoritative Reading jobs, runs, artifacts, checkpoints and accepted heads in PostgreSQL.

- `Features/Exams/`: admin/public/internal APIs and delivery; `Features/ReadingPaper/`: worker, generation client, caps, checkpoint/state transitions.
- `Infrastructure/Persistence/ExamDbContext.cs` and `Migrations/` own schema; startup migrates and seeds via `Data/ReadingSeeder.cs`.
- `ExamInternalGrpcService` serves attempt-service from the shared proto; `AllowAnonymous()` mapping does not remove internal API-key checks.
- Internal HTTP policies/keys are endpoint-specific; checkpoint/generation uses `X-Internal-Service-Key`, not the exam lookup header everywhere.
- Generation calls go through `ReadingPaperAiClient` to generation-service, not ai-service; Python cannot directly mutate authoritative exam tables.
- Preserve lease/epoch fencing, cancellation, idempotency, optimistic concurrency and EF transaction atomicity across retries/resumes.
- Acceptance needs fresh content-hash-bound evaluations and dependency closure; research outputs must remain unpublishable on every publication route.
- Admin publication and student payloads must preserve ACLs and answer/private-evidence redaction; attempts bind a published version.
- Resource caps/saved-run compatibility: read `../../docs/standards/reading-runtime-caps.md` before changing profiles or resume logic.
- Question-type changes span `Shared.PublicContracts` and attempt graders; migrate only actual persisted schema changes.
- Build from root: `dotnet build services/exam-service/exam-service.csproj`.
- Tests: first read `../exam-service.Tests/AGENTS.md`; never run the full project against development/shared databases.
