# Exam tests — destructive database fixtures
xUnit/WebApplicationFactory suites cover publication, durable Reading workflows and cross-service grading.

- Read `../exam-service/AGENTS.md` when editing these tests.
- **Do not run the whole project until every selected fixture's database target is isolated and disposable.** Some execute `DROP SCHEMA public CASCADE` or delete persisted rows.
- `READING_TEST_POSTGRES` is honored by some fixtures, not all. `ConnectionStrings__exam-db`/`ConnectionStrings__exam_db` and fallbacks also appear.
- `Phase02DurabilityTests` and `Phase03BudgetTests` hardcode localhost:5433 / `exam_test_phase02`; Phase02 overwrites `ConnectionStrings__exam-db`. An environment override alone does not isolate them.
- Inspect each selected fixture's connection resolution/setup/cleanup before execution. Use an isolated database/server (including hardcoded targets), never shared, dev or production data.
- Preserve the `DatabaseTests` collection's serialization and cleanup behavior; do not parallelize schema-reset fixtures.
- Command from root, **only after isolation**: `dotnet test services/exam-service.Tests/exam-service.Tests.csproj`; use `--filter` for an inspected subset.
- Some optional integration tests return without assertions when DB configuration is absent; a green process is not proof that PostgreSQL gates ran.
- Build-only validation: `dotnet build services/exam-service.Tests/exam-service.Tests.csproj`.
- Mocked provider fixtures certify workflow behavior, not live model quality; report the exact filters, database isolation and gates actually executed.
