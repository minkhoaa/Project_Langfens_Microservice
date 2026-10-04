# Langfens — Architecture Compression (Source-of-Truth Index)

> Folder: `artifacts/compression/` — every file in this folder is a distillation of what is **actually implemented** in `Project_Langfens_Microservice` (root). No architecture, technique, or runtime detail is invented; everything is anchored to a concrete file/folder under the repository and verified by direct read.
>
> Use these as on-ramps and review checklists. For implementation specifics, always cross-reference the linked source files.

## Folder layout

| File | Subject | Key sources cross-referenced |
|---|---|---|
| `01_system_overview.md` | Repo top-down: 12 services, 1 gateway, 1 Python AI, 1 Python generation, AppHost, compose, shared libs | `Project_Langfens_Microservice.sln`, `AppHost/Program.cs`, `deploy/compose.yaml`, `services/_shared/*`, `gateway/api-gateway/*` |
| `02_solution_structure_and_shared_libs.md` | Solution layout, Shared.* library responsibilities, exact packages used | `*.csproj`, `Shared.Bootstrap/`, `Shared.Grpc/`, `Shared.PublicContracts/`, `Shared.Security/`, `Shared.ServiceDefaults/` |
| `03_app_host_and_runtime_topology.md` | AppHost resource graph, container lifetimes, gateway cluster overrides, env injection, Aspire wiring | `AppHost/Program.cs`, `AppHost/CLAUDE.md`, `deploy/compose.yaml` |
| `04_api_gateway_routing.md` | YARP routes/clusters, JWT validation, CORS, cluster timeouts | `gateway/api-gateway/Program.cs`, `gateway/api-gateway/BootstrapExtensions.cs`, `gateway/api-gateway/appsettings.json` |
| `05_auth_service.md` | Identity, sessions, OTP, Google OAuth, JWT issuance, RabbitMQ events | `services/auth-service/*` |
| `06_exam_service.md` | Exam content CRUD, gRPC, seeding, internal delivery, Reading Paper orchestration | `services/exam-service/*` |
| `07_attempt_service.md` | Attempt workflow, abstract grader factory, gRPC client, AI consumers | `services/attempt-service/*` |
| `08_writing_service.md` | Writing grading via ai-service, circuit breaker, RabbitMQ | `services/writing-service/*` |
| `09_speaking_service.md` | Whisper STT, Cloudinary, RabbitMQ, WebSocket endpoint | `services/speaking-service/*` |
| `10_vocabulary_service.md` | Decks/cards, SM2 spaced repetition, AI enrichment, RabbitMQ | `services/vocabulary-service/*` |
| `11_dictionary_service.md` | Word lookup, PostgreSQL pg_trgm, large-file import | `services/dictionary-service/*` |
| `12_gamification_service.md` | XP/levels/streaks/achievements/notifications via RabbitMQ consumers | `services/gamification-service/*` |
| `13_course_service.md` | Course/lesson CRUD, enrollment, lesson-completion events | `services/course-service/*` |
| `14_email_service.md` | SMTP dispatch via MailKit, RabbitMQ consumers, test endpoints | `services/email-service/*` |
| `15_ai_service_python.md` | FastAPI service: LLM facade, Qdrant RAG, embeddings, roleplay, speech eval, Qwen2.5-LoRA, ingestion | `services/ai-service/*` |
| `16_generation_service.md` | Python microservice: 4-phase IELTS reading paper generation pipeline | `services/generation-service/*` |
| `17_shared_contracts_and_messages.md` | Public DTOs/events, gRPC proto, security claims, scopes, role mappings | `services/_shared/Shared.PublicContracts/*`, `services/_shared/Shared.Grpc/*`, `services/_shared/Shared.Security/*` |
| `18_runtime_infra_and_ports.md` | Postgres, Redis, RabbitMQ, Qdrant, Ollama, port map, deployment modes | `deploy/compose.yaml`, `AppHost/Program.cs`, gateway `appsettings.json` |
| `19_cross_service_event_flow.md` | End-to-end event/message routes (auth→email→user-created→gamification, attempt→writing→grading→back, etc.) | MassTransit consumers across services + `Shared.PublicContracts/Events/*` |
| `20_data_models_and_grading.md` | EF Core entities, SM2 algorithm, abstract grader registry, IELTS question types, AI grading pipelines | `Shared.PublicContracts/Contracts/Exam/Enums/QuestionType.cs`, attempt graders, ai `grade_service.py` |

## How to use

- Start at `01_system_overview.md` for the 1-page map.
- Drill down by service or by cross-cutting concern (auth flow, AI grading, generation pipeline).
- For any modification, ALWAYS cross-check the linked source path before editing — these docs are a compression, not a replacement for source-of-truth code.

## Source-of-truth guarantees

- Every claim in any file is grounded in either:
  - a directly-read file path under the repo (file path is cited), or
  - a concrete `grep`/`glob` confirmation in this workspace.
- No fictitious ports, frameworks, libraries, or services. If something is *not* present in the codebase, it is *not* described here.
- Outdated/aspirational references in CLAUDE.md files that contradict actual code (e.g. dictionary-service CLAUDE.md mentions Elasticsearch, but `dictionary-service.csproj` no longer references Elastic and `Features/DictionaryDoc.cs` is in-memory; the actual stack is PostgreSQL + pg_trgm) are corrected in the per-service files with explicit notes.

## Revision log (corrections after first cut)

These were caught in a post-publish review and have been corrected in-place; check git history for diffs:

| File(s) | Correction |
|---|---|
| `05_auth_service.md` | `GET /all` → `GET /api/auth/users`; auth requirement is **`Roles.Admin` only** (not `UserScope.UserReadAny`). |
| `01`, `07`, `08`, `09`, `19` | Speaking RabbitMQ flow direction **reversed**: `attempt-service/PlacementWorkflow` publishes `SpeakingGradingRequestMessage`; `speaking-service/SpeakingGradingConsumer` consumes it, runs Whisper + AI grading, then publishes `SpeakingGradingResponseMessage`. |
| `01`, `07`, `08`, `09`, `19`, `20` | Writing RabbitMQ flow split into two paths: (a) **direct user submission** is synchronous (`POST /api/writing/grade` → HTTP ai-service) then publishes a Flow A message for async comparison; (b) **placement flow** is the only cross-service RabbitMQ path. |
| `07`, `19` | AI-grading RabbitMQ flow is **placement-only** (`ExamCategory.PLACEMENT`); normal skill tests do not flow through writing/speaking services. |
| `05_auth_service.md` | `TestPingConsumer.cs` exists in `services/auth-service/Features/RabbitMq/` as a stub but is **not registered** in `Program.cs`. |
| `01`, `15`, `19` | `exam-service/ReadingPaperAiClient` calls **generation-service**, not ai-service. The `/api/v1/autogen/questions` endpoint in ai-service is **not** invoked by any .NET service (auth dep commented out as TODO). |

## Revision log (second pass)

| File(s) | Correction |
|---|---|
| `06_exam_service.md` | gRPC endpoint is registered with `MapGrpcService<ExamInternalGrpcService>().AllowAnonymous()`; the gRPC service implementation performs **no internal-API-key validation**. The `X-Internal-Key` header sent by attempt-service is silently ignored by exam-service; auth-at-edge is expected instead. |
| `08_writing_service.md`, `09_speaking_service.md` | Removed invented kebab-case queue name claims. `writing-service/Program.cs` and `speaking-service/Program.cs` use `bus.ConfigureEndpoints(ctx)` with **no explicit `ReceiveEndpoint`** and **no `KebabCaseEndpointNameFormatter`** (only `auth-service` configures a kebab formatter). Default MassTransit formatter names the receive queue by the consumer class name (PascalCase): `WritingSubmitted` and `SpeakingGrading`. The strings `writing-graded-response` / `speaking-graded-response` are explicit queue names **only** in `attempt-service/Program.cs` for the response-side consumers. |
| `19_cross_service_event_flow.md` | RAG per-item explainer call is **POST** (`_http.PostAsJsonAsync("/api/v1/{reading,listening}/explain-item", payload, ct)`), not GET. |
| `16_generation_service.md`, `19_cross_service_event_flow.md`, `01_system_overview.md` | The IELTS Reading paper pipeline has **four phases** per the module docstring (`pipeline.py:1-6`): 1) Passage Synthesis (720–915 words) with bounded extension; 2) Source-Fidelity Audit & Targeted Revision (fail-closed); 3) Question Group Generation (defensive extraction); 4) Independent Answer Review & Surgical Replacement. Earlier docs listed five steps (treating audit and revision as separate phases); corrected to match the source. |
| `19_cross_service_event_flow.md` | ai-service `/api/v1/autogen/questions` is **not** invoked by any .NET service, but the YARP gateway route `ai-autogen-admin` (`/api-ai/v1/autogen/{**catch-all}`, Admin-only) **does** exist. Previous wording "currently unrouted" was wrong; accurate phrasing is "route mapped in gateway, unused." |

## Revision log (third pass)

| File(s) | Correction |
|---|---|
| `19_cross_service_event_flow.md` | `UserCreatedEvent` receive queue is `UserCreated` (default MassTransit formatter, PascalCase of the consumer class name). `gamification-service/Program.cs:50,59` uses `AddConsumer<UserCreatedConsumer>() + ConfigureEndpoints(ctx)` with **no** `KebabCaseEndpointNameFormatter`. The kebab-case formatter is **process-local to auth-service**; MassTransit endpoint naming is per-bus and does NOT cross service boundaries. |
| `19_cross_service_event_flow.md`, `15_ai_service_python.md` | `/api/v1/autogen/questions` **is** called by the Next.js admin panel — verified at `langfens-fe-app/src/app/admin/_lib/aiConfig.ts:57-58` (`${base}/v1/autogen/questions` and `${base}/api/v1/autogen/questions`). Earlier wording "currently receives no upstream callers" was wrong because only .NET callers were checked; admin FE traffic via YARP route `ai-autogen-admin` is live. Admin gating is at the gateway (`AuthorizationPolicy=Admin`); the `Depends(get_current_user)` inside ai-service is commented out (`TODO: wire JWT auth in Phase 5 follow-up`). |
| `19_cross_service_event_flow.md`, `15_ai_service_python.md` | `ReadingPaperAiClient` BaseAddress fallback chain (`services/exam-service/Program.cs:51-55`): `GENERATION_SERVICE_URL ?? AI_SERVICE_URL ?? "http://generation-service:8080"`. AppHost sets `GENERATION_SERVICE_URL` explicitly → generation-service in normal Aspire run. The `AI_SERVICE_URL` fallback would 404 (ai-service does not implement `/api/v1/autogen/reading-paper/section`); the literal `http://generation-service:8080` fallback only matches compose hostname. Qualified accordingly. |
| `06_exam_service.md` | `CheckpointEndpoints` exposes **8** internal operations at `/api/internal/reading-paper/checkpoints` (gated by a service-auth header filter): `grant-operation`, `budgets/allocate`, `operations/reconcile`, `commit`, `unknown-outcome`, `resume/{runId}` (GET), `invalidate`, `build-exam`. Earlier docs called it "checkpoint listing," which was an understatement. |

## Revision log (fourth pass)

| File(s) | Correction |
|---|---|
| `08_writing_service.md`, `09_speaking_service.md`, `19_cross_service_event_flow.md` | MassTransit's default `DefaultEndpointNameFormatter` strips the trailing `Consumer` suffix from the class name (e.g., `WritingSubmittedConsumer` → `WritingSubmitted`, `SpeakingGradingConsumer` → `SpeakingGrading`). The actual queue names in earlier revisions were correct; the wording "PascalCase of the consumer class name" was imprecise — corrected to "PascalCase **with the trailing `Consumer` suffix stripped**." |
| `15_ai_service_python.md`, `19_cross_service_event_flow.md` | The autogen questions route `ai-autogen-admin` is the **default-config** YARP path, but **not** a guarantee of live traffic. `langfens-fe-app/src/app/admin/_lib/aiConfig.ts:42-49` resolves `endpoint = NEXT_PUBLIC_AI_SERVICE_URL \|\| NEXT_PUBLIC_AI_ENDPOINT \|\| NEXT_PUBLIC_GATEWAY_URL + "/api-ai"` — **JavaScript logical OR**, not TypeScript `??` (empty-string env var also falls through). Either of the first two env vars **overrides the default base**; `cfg.endpoint` is treated as an arbitrary base URL by `callAi` (`aiConfig.ts:55-58`), so the override's *value* determines the actual target (ai-service, a different proxy, etc.) — not a guaranteed bypass to ai-service. Earlier wording implied the gateway is the actual traffic path and that the FE "bypasses" to ai-service specifically; corrected. |

## Revision log (fifth pass)

| File(s) | Correction |
|---|---|
| `15_ai_service_python.md`, `19_cross_service_event_flow.md`, `00_INDEX.md` | Tightened the autogen endpoint wording. The previous pass said "the FE bypasses the gateway and calls ai-service directly" when `NEXT_PUBLIC_AI_SERVICE_URL` is set — `cfg.endpoint` is in fact an **arbitrary** base URL (`callAi` at `aiConfig.ts:55-58` builds `${base}/v1/autogen/questions`), and the override's *value* determines the target (ai-service, a different proxy, anything). Removed the line "the FE itself is responsible for not exposing the endpoint": the FE source is a browser `fetch` and ai-service's `Depends(get_current_user)` is commented out — there is no server-side access control in the override path; FE code is **not** access control. Replaced with the observation that the FE only attaches `Authorization: Bearer <token>` opportunistically when `getToken()` returns a value, and admin gating is enforced **only** when traffic goes through the YARP route. |

## Revision log (sixth pass)

| File(s) | Correction |
|---|---|
| `15_ai_service_python.md`, `19_cross_service_event_flow.md`, `00_INDEX.md` | The autogen FE code uses **JavaScript logical OR** (`\|\|`), not TypeScript `??` (nullish coalescing). Verified at `langfens-fe-app/src/app/admin/_lib/aiConfig.ts:42-49`. Previously-rendered `??` in the docs was wrong — empty-string env vars now also fall through. Replaced `??` with `\|\|` in the three call sites that quote the FE expression. (The C# `??` references in `ReadingPaperAiClient` BaseAddress fallback are correct as-is — `services/exam-service/Program.cs:51-55` actually uses `??`.) |
| `19_cross_service_event_flow.md` | Autogen row's `Source` and `Target` columns previously read `ai-service`, contradicting the caveat that the override's value determines the actual target. Changed to **`configured endpoint (default: ai-service via YARP)`** so the row matches the prose. |

## Revision log (seventh pass)

| File(s) | Correction |
|---|---|
| `15_ai_service_python.md`, `19_cross_service_event_flow.md`, `00_INDEX.md` | GitHub-flavored Markdown table parser does **not** respect inline code spans — every unescaped pipe character inside a table cell is a column separator regardless of backticks. The previous fix used bare `\|` `\|` only inside the JS code span, which left the surrounding inline-code emphasis markers split by the parser. Re-validated by simulating GitHub's split (split on the regex "pipe character not preceded by backslash"); row 233 of `19` initially had 11 unescaped pipes (yielding 12 phantom cells). All occurrences inside table rows / cells have been escaped; the bare "double-pipe" emphasis markers have been replaced with the spelled-out phrase "JavaScript logical OR" so even renderers that don't honor the escape show the correct content. Validated again: `19` row 233 now has exactly 5 unescaped pipe characters (the 4-column delimiter count) plus 4 escaped `\|` pairs inside the code span; `00_INDEX` rows 83 and 95 have exactly 3 unescaped pipe characters each (the 2-column delimiter count). |
