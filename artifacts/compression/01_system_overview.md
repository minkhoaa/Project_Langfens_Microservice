# 01 — System Overview (1-page distillation)

> Source-of-truth: `Project_Langfens_Microservice.sln`, `AppHost/Program.cs`, `deploy/compose.yaml`, `services/*/Program.cs`, `gateway/api-gateway/appsettings.json`.

## What this system is

Langfens is an **IELTS preparation platform**. It exposes a single YARP gateway on port **5000** in front of:

- **10 .NET 10 microservices** (auth, exam, attempt, writing, speaking, vocabulary, dictionary, gamification, course, email)
- **1 .NET 10 YARP gateway**
- **1 Python FastAPI `ai-service`** (LLM judge + embeddings + Qdrant RAG + roleplay + speech eval + Qwen2.5-LoRA grader)
- **1 Python FastAPI `generation-service`** (autonomous IELTS Reading paper generation)
- **AppHost** (Aspire local-dev orchestrator) plus **`deploy/compose.yaml`** (production Docker Compose)

`AppHost/Program.cs` orchestrates all of the above as one distributed application, with the Aspire dashboard at **http://localhost:18888**.

## What it does (capabilities)

| Capability | Where |
|---|---|
| Identity (email + password + Google OAuth) + JWT issuance + Redis session + OTP | `services/auth-service` |
| Exam content (sections/questions/options), admin CRUD + public listing + gRPC internal delivery + seeders | `services/exam-service` |
| Attempt start/autosave/submit, paper-wide index normalizer, abstract grader factory, AI insights, RAG explainers | `services/attempt-service` |
| Writing grading via ai-service with circuit breaker + RabbitMQ response queue | `services/writing-service` |
| Speaking: Whisper STT, Cloudinary audio upload, AI grading, WebSocket transcript | `services/speaking-service` |
| Flashcards: decks/cards, SM2 spaced-repetition, AI enrichment + extraction | `services/vocabulary-service` |
| Word lookup + large file import, PostgreSQL pg_trgm index | `services/dictionary-service` |
| XP, levels, streaks, achievements, leaderboard, notifications (event-driven) | `services/gamification-service` |
| Courses + lessons + enrollments + progress + completion events | `services/course-service` |
| Email OTP dispatch via MailKit SMTP, RabbitMQ-driven | `services/email-service` |
| Single YARP gateway: JWT validation, CORS, per-cluster timeouts | `gateway/api-gateway` |
| LLM judge (Groq + MiniMax failover), embeddings (Ollama BGE-M3), Qdrant RAG (writing/grammar/reading/listening), roleplay, Qwen2.5-LoRA speaking grader, faster-whisper STT | `services/ai-service` |
| Autonomous IELTS Reading paper: source ingestion → passage synthesis → audit → revision → questions → adversarial review; NDJSON streaming | `services/generation-service` |

## Runtime topology (verified from `AppHost/Program.cs`)

```
NEXT.JS FE  ─▶  api-gateway :5000 (YARP + JWT)
                       │
   ┌───────────────────┼───────────────────────────────┬─────────────────────┐
   ▼                   ▼                               ▼                     ▼
auth-service       exam-service                attempt-service        generation-service
  :5434 auth-db     :5433 exam-db (HTTP+gRPC)     :5435 attempt-db       :8095 (FastAPI; standalone
  + redis           + AI/GEN URLs injected        + gRPC client to        Python service — NOT
  + rabbitmq        (AI_SERVICE_URL for            exam-service          called by any other service
                      autogen server-side;       + MassTransit          except exam-service's
                      GENERATION_SERVICE_URL      (publisher+consumer)   ReadingPaperWorker; not
                      for ReadingPaperWorker)                              the AI service)
  ▼                   ▼                               ▼                     ▼
email-service      writing-service              speaking-service
  rabbitmq only      :5440 writing-db             :5441 speaking-db
                      + ai-service                   + ai-service
                      + rabbitmq                      + rabbitmq
                      + circuit breaker               + cloudinary
                                                       + Whisper
                                                       + WebSocket /ws/speaking

vocabulary-service :5987  ◀──publishes── CardReviewedEvent ──▶ gamification :5444
dictionary-service :5443                                                 ▲
course-service     :5446  ◀──publishes── LessonCompletedEvent ──────────┘
                                    (AttemptCompletedEvent + UserCreatedEvent also flow here)
ai-service (Python) :8092 → ai-cluster: Qwen LoRA + Groq + MiniMax + Ollama BGE-M3 + Qdrant + Redis
generation-service  :8095 → generation-cluster: 4-phase pipeline; NDJSON stream
```

**PostgreSQL**: one DB per service (`exam-db`, `auth-db`, `attempt-db`, `vocabulary-db`, `dictionary-db`, `speaking-db`, `writing-db`, `course-db`, `gamification-db`). Compose-only: `email-service` has no DB. Aspire runs them on **unique host ports** for `psql` parity: 5433/5434/5435/5987/5443/5441/5440/5444/5446.

**Infra containers**:
- **RabbitMQ** (`rabbitmq:3-management`) — user `appuser` (compose) / `guest` (Aspire default).
- **Redis** (`redis:7.4-alpine`) — auth-service session/OTP cache; ai-service response cache; keyed by `auth-redis`.
- **Qdrant** — used only by `ai-service` for RAG collections (`writing_samples`, `grammar_knowledge`, `reading_samples`, `listening_samples`, `speaking_memory`).
- **Ollama** — embeddings (BGE-M3, 1024 dim) used by ai-service. Roleplay chat and a local Qwen2.5-LoRA live alongside Groq for speaking grading.

## Cross-cutting flows (sketch)

1. **Sign-up → OTP**: `auth-service.RegisterAsync` → publish `UserRegisteredSendOtp` (RabbitMQ) → `email-service.UserRegisteredSendOtpConsumer` → MailKit SMTP. `auth-service` Redis stores OTP hash + cooldown. After email confirmation, `auth-service.ConfirmEmail` publishes `UserCreatedEvent` → `gamification-service.UserCreatedConsumer` creates the initial `UserStats`.
2. **Direct user submission (writing / speaking skill test)**: `POST /api/writing/grade` → `writing-service.WritingService.WritingSubmit` runs **synchronous** `_grader.GradeAsync` (HTTP `ai-service /v1/writing/grade` with circuit breaker) → user gets band scores immediately, plus the service publishes a `WritingGradeRequestMessage` with `SubmissionId` (Flow A) for async comparison. `POST /api/speaking/grade` → `speaking-service.SpeakingService.SpeakingSubmit` runs **synchronous** Whisper transcription + `_grader.GradeAsync` (HTTP `ai-service /v1/speaking/grade`) → user gets scores immediately; no RabbitMQ in this path.
3. **Placement test (the only path that uses RabbitMQ for AI grading)**: `attempt-service.Submit` (exam category = `PLACEMENT`) → `PlacementWorkflow.OnPlacementSubmittedAsync` publishes `WritingGradeRequestMessage` (no `SubmissionId` = Flow B) AND `SpeakingGradingRequestMessage` (with Cloudinary `AudioUrl`). `writing-service.WritingSubmittedConsumer` and `speaking-service.SpeakingGradingConsumer` consume → run their respective `AiWritingGrader` / `AiSpeakingGrader` (HTTP to `ai-service`) → publish `WritingGradeResponseMessage` / `SpeakingGradingResponseMessage` on the response queues → `attempt-service.WritingGradedConsumer` / `SpeakingGradedConsumer` invoke `PlacementWorkflow.OnWritingGradedAsync` / `OnSpeakingGradedAsync` to update `PlacementResult` and flip attempt status to `Graded` when both writing + speaking are in.
4. **Every submit → XP**: `attempt-service.AttemptService.Submit` runs the abstract grader factory (`SingleChoiceGrader`, `MultipleChoiceGrader`, `CompletionGrader`, `LabelGrader`, `MatchingHeadingGrader`, `FlowChartGrader`, `ShortAnswerGrader`) for objective items, then publishes `AttemptCompletedEvent` with `Skill="READING"` (currently hardcoded). `gamification-service.AttemptCompletedConsumer` awards XP by skill, updates level + streak, evaluates achievements, fires notifications.
5. **RAG explainer (per-item)**: `attempt-service` issues per-reading/per-listening-item HTTP **POST** calls to `ai-service /api/v1/reading/explain-item` and `/api/v1/listening/explain-item` (`ReadingExplainerClient` / `ListeningExplainerClient` use `_http.PostAsJsonAsync(...)`), each returning a `RagFeedbackEnvelope`. The result is persisted on `AttemptAnswer.RagFeedbackJson` (3s per-item timeout).
6. **Reading paper generation**: `exam-service` admin enqueues a `ReadingPaperJob` → `ReadingPaperWorker` (hosted service) calls `generation-service /api/v1/autogen/reading-paper/section` with NDJSON streaming → pipeline runs the **four** phases (per `services/generation-service/app/pipeline.py:1-6` docstring): (1) Passage Synthesis, (2) Source-Fidelity Audit & Targeted Revision, (3) Question Group Generation, (4) Independent Answer Review & Surgical Replacement; progress + final section persisted to `ReadingPaperJobLog`.
7. **Flashcard review → XP**: `POST /api/users/{userId}/flashcard/{cardId}/review` → `vocabulary-service.UserService.ReviewCard` applies SM2 → publishes `CardReviewedEvent` → `gamification-service.CardReviewedConsumer`.
8. **Lesson completion → XP**: `POST /api/{userId}/{lessonId}:complete` → `course-service` updates progress → publishes `LessonCompletedEvent` → `gamification-service.LessonCompletedConsumer`.

## Public contracts (cross-service)

- `Shared.PublicContracts/Contracts/Exam/Enums/QuestionType.cs` — 19 question types.
- `Shared.PublicContracts/Contracts/Exam/Enums/QuestionSkill.cs` — `READING/LISTENING/WRITING/SPEAKING`.
- `Shared.PublicContracts/Events/*` — `AttemptCompletedEvent`, `CardReviewedEvent`, `LessonCompletedEvent`, `UserCreatedEvent`.
- `Shared.PublicContracts/Contracts/Writing/*` — `WritingGradeRequestMessage`, `WritingGradeResponseMessage`.
- `Shared.PublicContracts/Contracts/Speaking/*` — `SpeakingGradingRequestMessage`, `SpeakingGradingResponseMessage`.
- `Shared.PublicContracts/Contracts/Ai/RagFeedbackContracts.cs` — `RagFeedbackEnvelope` + criteria/evidence/suggestion.
- `Shared.PublicContracts/Contracts/Auth_Email/*` — `UserRegisteredSendOtp`, `UserRegisteredConfirmOtp`, `TestPing`.
- `Shared.PublicContracts/Contracts/Exam/InternalExamDto/SharedInternalExamDto.cs` — shared internal DTO (init-property records).
- `Shared.PublicContracts/Contracts/Exam/InternalExamDto/PaperWideNormalizer.cs` — renumbers `Q.idx` to paper-wide 1-based; two adapters live in `exam-service`.
- `Shared.Grpc/Contracts/exam_internal.proto` — `ExamInternal.GetInternalExam`, `GetExamList` consumed by `attempt-service`.

## Security & scopes

- JWT HS256 (SignKey env) — verified in gateway; reused as HS256 across services (Bootstrap `AddLangfensAuth`).
- Roles: `USER`, `ADMIN` (`Shared.Security/Roles/Roles.cs`).
- Scopes: `course.*`, `exam.*`, `attempt.*`, `vocab.*`, `writing.*`, `speaking.*`, `user.*`, `email.*` (`Shared.Security/Scopes/*`).
- `RoleBasedScopeProvider.CustomRoleOptions` maps roles → scopes (`ADMIN` gets every scope, `USER` gets restricted set).
- Claim names: `sub`, `scope` (space-separated), `roles` (`Shared.Security/Claims/CustomClaims.cs`).

## Deployment modes

| Mode | Command | Notes |
|---|---|---|
| AppHost (recommended dev) | `dotnet run --project AppHost/AppHost.csproj` | Aspire; live rebuild; dynamic ports; dashboard http://localhost:18888 |
| Docker Compose | `cd deploy && cp envs/*.env .env && docker compose up -d` | Production-like; pinned host ports; env files in `deploy/envs/*.env` |
| Standalone service | `dotnet run --project services/<name>-service` | Hits `localhost:6379`, default ports; needs `.env` via `DotNetEnv.Env.Load()` (writing, speaking, attempt) |

## Compose host port map (verified)

| Service | Host port (compose) |
|---|---|
| gateway | 5000 |
| auth-service | 8080 |
| exam-service | 8082 (HTTP), exposed 8081 (gRPC) |
| attempt-service | 8081 |
| writing-service | 8091 |
| speaking-service | 8090 |
| vocabulary-service | 8093 |
| dictionary-service | 8094 |
| gamification-service | 8096 |
| course-service | 8080 internal |
| email-service | internal |
| ai-service | 8092 |
| generation-service | 8095 |
| Postgres | 5433 exam / 5434 auth / 5435 attempt / 5440 writing / 5441 speaking / 5443 dictionary / 5444 gamification / 5446 course / 5987 vocabulary |
| Redis | 6379 |
| Ollama | 11434 |
| RabbitMQ mgmt UI | 15672 |
