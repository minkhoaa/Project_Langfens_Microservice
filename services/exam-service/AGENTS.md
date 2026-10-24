# Exam service
PostgreSQL authority for exams/publication and Reading jobs, runs, artifacts, operations, checkpoints and accepted heads.

- `Features/Exams/` owns APIs/delivery; `Features/ReadingPaper/` owns worker/state; `Infrastructure/Persistence/ExamDbContext.cs` and `Migrations/` own schema.
- Startup migrates and runs `Data/ReadingSeeder.cs`; service startup is not a side-effect-free check.
- `ExamInternalGrpcService` requires its internal API key despite anonymous route mapping. HTTP checkpoint/generation uses `X-Internal-Service-Key`, not the lookup header universally.
- `ReadingPaperAiClient` calls generation-service, not ai-service; preserve transactional lease/epoch fences, CAS, cancellation and idempotent retries/lost-ACK recovery.
- Acceptance requires fresh hash-bound evaluations and reference closure; strict-paper persistence is atomic, never a partial exam graph.
- Every publication route rejects research output; authorized admin approval creates immutable published snapshots. Learner ACLs/version binding and answer/private-evidence redaction must hold.
- `ReadingPaperCapsProfile.cs` validates shared `loop-caps.env`: production requires explicit profile/source/version and positive 32-bit integers with consistent parent/child allocations.
- New runs persist full canonical sorted-key UTF-8 profile JSON/SHA-256 and ceilings. Resume keeps original policy/cumulative counters; corrupt/missing snapshots require pause/migration.
- Cap changes also require `../generation-service/AGENTS.md` and both runtimes' cap tests; never substitute child budgets for paper budgets.
- Question types/1-based paper indices span shared DTOs and attempt graders; only persisted schema changes warrant migrations.
- Before `dotnet test`, read `../exam-service.Tests/AGENTS.md`; use build-only verification when database isolation is unproven.
