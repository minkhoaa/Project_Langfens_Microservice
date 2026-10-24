# Exam tests: destructive fixtures
xUnit/WebApplicationFactory publication and durable Reading tests; read `../exam-service/AGENTS.md` for service invariants.

- **Never run the full project against shared/dev/production data.** Fixtures drop `public CASCADE` or delete rows; inspect each selected fixture's setup/cleanup/connection resolution first.
- `READING_TEST_POSTGRES` is not universal; `ConnectionStrings__exam-db`, `ConnectionStrings__exam_db` and hardcoded fallbacks coexist.
- Phase02/03 target localhost:5433 / `exam_test_phase02`; Phase02 overwrites the connection environment. A DSN override alone does not isolate these tests.
- Isolate every selected target, including hardcoded ones, on disposable databases/servers; preserve serialized `DatabaseTests` collection execution.
- Only after isolation, from root: `dotnet test services/exam-service.Tests/exam-service.Tests.csproj --filter <inspected-tests>`.
- Safe build-only command: `dotnet build services/exam-service.Tests/exam-service.Tests.csproj`.
- Optional DB tests can return without assertions; report actual gates/filters/isolation, not just green exit status. Provider mocks certify workflow, not model quality.
