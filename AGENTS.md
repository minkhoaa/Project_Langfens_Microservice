# Langfens
IELTS preparation: .NET 10 APIs, Python 3.12 FastAPI, PostgreSQL, RabbitMQ, Redis and Qdrant.

## Read on demand
From root, read only the affected directory's `AGENTS.md`; for `services/*.Tests`, also read its owning service's guide.
- `AppHost/`: Aspire orchestration; `gateway/api-gateway/`: YARP edge routing/auth.
- `services/{auth,email}-service/`: identity/sessions/OTP and SMTP delivery.
- `services/{exam,attempt}-service/`: exam/publication/Reading state and attempts/scoring.
- `services/{writing,speaking}-service/`: submissions, AI grading and audio.
- `services/{vocabulary,dictionary}-service/`: SM2 flashcards and PostgreSQL word lookup.
- `services/{course,gamification}-service/`: learning progress and event-driven XP/achievements.
- `services/{ai,generation}-service/`: inference/RAG/ASR and autonomous Reading generation.
- `services/_shared/`: bootstrap/security/DTOs/events/gRPC; `generation_baseline/`: research tools/contracts.

## Commands (root)
- Build: `dotnet build Project_Langfens_Microservice.sln`; individual .NET projects: `dotnet build` in their directory.
- Local stack: `dotnet run --project AppHost/AppHost.csproj` (starts containers and services with startup side effects).
- Migration: `dotnet ef migrations add <Name> --project services/<svc>/<svc>.csproj --output-dir Migrations`; apply only to an explicitly selected database.
- Tests: use affected guides; run Python suites in separate service directories/venvs (`app` packages collide). CI builds/deploys `master` without tests.

## Boundaries
- Each service owns its database; use internal HTTP/gRPC or MassTransit contracts, never cross-database access.
- Inject endpoints/credentials through Aspire/deployment configuration; RabbitMQ needs discrete `RABBITMQ__*` variables. Preserve endpoint-specific auth headers.
- Cross-service changes require both owners' guides and producer/consumer contract tests; new services also need AppHost, gateway and deployment wiring.
- **Before any exam tests, read `services/exam-service.Tests/AGENTS.md`: fixtures can destroy databases; a DSN override alone is insufficient.**
- Historical reports/offline PASS do not authorize deployment, publication, production mutations or paid provider campaigns, nor certify live quality.
