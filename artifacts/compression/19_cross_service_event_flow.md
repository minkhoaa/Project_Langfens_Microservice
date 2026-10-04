# 19 — Cross-Service Event & RPC Flows

> Source-of-truth: actual code paths across services. Verified by reading `AuthService.cs`, `WritingSubmittedConsumer.cs`, `SpeakingGradingConsumer.cs`, `WritingGradedConsumer.cs`, `SpeakingGradedConsumer.cs`, `AttemptCompletedConsumer.cs`, `CardReviewedConsumer.cs`, `LessonCompletedConsumer.cs`, `UserCreatedConsumer.cs`, `ExamInternalGrpcService.cs`, `EmailSender.cs`, `UserRegisteredSendOtpConsumer.cs`.

## Flow 1 — Sign-up → email verification

```
[FE] POST /api/auth/register
   └─▶ auth-service.AuthService.RegisterAsync
        ├─ Create User, add role USER
        ├─ OTP = OtpGenerator.Generate()
        ├─ RedisOtpStore.PutOtp(email, otp, TtlSeconds=180)
        ├─ RedisOtpStore.TouchResendCooldown(email, 30s)
        └─ IPublishEndpoint.Publish(new UserRegisteredSendOtp(email, otp, 60))
              └─▶ RabbitMQ exchange → queue "user-registered-send-otp"
                     └─▶ email-service.UserRegisteredSendOtpConsumer.Consume
                            └─▶ IEmailSender.SendOtpAsync(email, otp, ttl)
                                  └─▶ MailKit SMTP → user inbox
```

User later hits `GET /api/auth/verify?email=&otp=` → `AuthService.ConfirmEmail` → `RedisOtpStore.Verify(...)` (PBKDF2 compare, tries++, block at 5). After successful confirmation, `AuthService` publishes `UserCreatedEvent(UserId, Email, CreatedAt)` at line 274 of `AuthService.cs`, consumed by `gamification-service.UserCreatedConsumer` to create the initial `UserStats` row.

## Flow 2 — Login → JWT + Redis session

```
[FE] POST /api/auth/login  body {email, password}
   └─▶ LoginEndpoint.LoginAsync
        ├─ AuthService.PasswordLoginAsync
        │    ├─ UserManager.FindByEmail/CheckPasswordSignInAsync
        │    ├─ generate new SessionRecord (sid)
        │    ├─ RedisOtpStore → not used here; session storage only
        │    ├─ SessionStore.StoreSessionAsync (TTL 30 days)
        │    ├─ SessionStore.SetDeviceSessionAsync
        │    ├─ SessionStore.EnsureSessionLimitAsync (max 5 per user)
        │    └─ JwtTokenFactory.CreateTokenAsync(user, roles, scopes, sid)
        │         └─ HS256 token with claims {sub, scope, sid, roles, iat, nbf, jti}
        └─ CookieService sets HTTP-only cookie "sid=<sid>"
   └─▶ FE keeps token; passes Authorization: Bearer <jwt> on subsequent calls
```

## Flow 3 — Start attempt → submit → auto-grade (objective items)

```
[FE] POST /api/attempt/attempts:start  body {examId}
   └─▶ AttemptHandler.AttemptStartHandler
        ├─ ExamGateway.GetInternalExam(examId)  ──gRPC──▶ exam-service.ExamInternalGrpcService.GetInternalExam
        ├─ Normalize via PaperWideNormalizer
        └─ persist new Attempt + initial PaperJson snapshot

… user fills answers …

[FE] POST /api/attempt/submit/{attemptId}
   └─▶ AttemptHandler.AttemptSubmit (AttemptService.Submit)
        ├─ For each question: QuestionGraderFactory.Resolve(questionType).Create()
        │   ├─ SingleChoiceGrader, MultipleChoiceGrader, CompletionGrader, LabelGrader,
        │   │  MatchingHeadingGrader, FlowChartGrader, ShortAnswerGrader
        │   └─ uses AnswerKeyBuilder / BuildQuestionIdSet / QuestionIndex
        ├─ For Reading items: persist attemptAnswer.RagFeedbackJson via
        │   SkillRagExplainer → POST ai-service /v1/reading/explain-item
        │   (ReadingExplainerClient uses `_http.PostAsJsonAsync("/api/v1/reading/explain-item", payload, ct)`;
        │    3s per-item timeout)
        ├─ For Listening items: persist attemptAnswer.RagFeedbackJson via
        │   SkillRagExplainer → POST ai-service /v1/listening/explain-item
        │   (ListeningExplainerClient uses `_http.PostAsJsonAsync("/api/v1/listening/explain-item", payload, ct)`)
        ├─ Persist answers, evaluation rows; set Attempt.Status=Graded (or Submitted if any manual)
        ├─ Save changes + commit explicit transaction
        ├─ If exam.Category == "PLACEMENT":
        │   └─▶ PlacementWorkflow.OnPlacementSubmittedAsync
        │        ├─ Creates/updates PlacementResult (Reading/Listening totals)
        │        ├─ if writingAnswer present:
        │        │     └─ IPublishEndpoint.Publish(WritingGradeRequestMessage {SubmissionId=null, "Flow B"})
        │        │           └─▶ RabbitMQ → writing-service queue (default formatter names it `WritingSubmitted`; writing-service does not pin a `ReceiveEndpoint`)
        │        │                  └─▶ writing-service.WritingSubmittedConsumer
        │        │                        ├─ Flow B: persist WritingEvaluation row
        │        │                        ├─ AiWritingGrader.GradeAsync
        │        │                        │    └─ POST ai-service /api/v1/writing/grade (90s timeout)
        │        │                        ├─ AiCompareClient.CompareAsync (best-effort)
        │        │                        └─ IPublishEndpoint.Publish(WritingGradeResponseMessage)
        │        │                              └─▶ RabbitMQ → attempt-service queue `writing-graded-response` (explicit `ReceiveEndpoint("writing-graded-response", …)` in `services/attempt-service/Program.cs:129`)
        │        │                                     └─▶ attempt-service.WritingGradedConsumer
        │        │                                           └─▶ PlacementWorkflow.OnWritingGradedAsync
        │        │                                                 ├─ placement.WritingBand = response.OverallBand
        │        │                                                 ├─ placement.WritingGradeJson = JSON
        │        │                                                 └─ recompute PlacementLevelMapper.Map(...)
        │        └─ if speakingAnswerJson (Cloudinary AudioUrl) present:
        │              └─ IPublishEndpoint.Publish(SpeakingGradingRequestMessage)
        │                    └─▶ RabbitMQ → speaking-service queue (default formatter names it `SpeakingGrading`; speaking-service does not pin a `ReceiveEndpoint`)
        │                           └─▶ speaking-service.SpeakingGradingConsumer
        │                                 ├─ IAudioDownloader.GetAudioStreamAsync(AudioUrl)  // from Cloudinary
        │                                 ├─ IWhisperService.Transcript(audioStream)
        │                                 ├─ AiSpeakingGrader.GradeAsync
        │                                 │    └─ POST ai-service /api/v1/speaking/grade
        │                                 └─ IPublishEndpoint.Publish(SpeakingGradingResponseMessage)
        │                                       └─▶ RabbitMQ → attempt-service queue `speaking-graded-response` (explicit `ReceiveEndpoint("speaking-graded-response", …)` in `services/attempt-service/Program.cs:130`)
        │                                              └─▶ attempt-service.SpeakingGradedConsumer
        │                                                     └─▶ PlacementWorkflow.OnSpeakingGradedAsync
        │                                                           ├─ placement.SpeakingBand = response.OverallBand
        │                                                    ├─ placement.SpeakingGradeJson = JSON
        │                                                    └─ recompute PlacementLevelMapper.Map(...)
        └─ ALWAYS: IPublishEndpoint.Publish(AttemptCompletedEvent(UserId, AttemptId, "READING", correctCount))
              └─▶ gamification-service.AttemptCompletedConsumer
                    ├─ XP by skill switch
                    ├─ Level = UserStats.CalculateLevel(TotalXp)
                    ├─ Update streak
                    ├─ Achievement checks
                    └─ Notification (TestCompleted / LevelUp / Achievement / StreakMilestone)
```

**Important nuances:**

- For non-placement attempts (skill tests under categories `IELTS`, `TOEIC`, `VSTEP`, `EXERCISE`, `GRAMMAR`), `PlacementWorkflow.OnPlacementSubmittedAsync` is **not** called — only the abstract grader factory runs and `AttemptCompletedEvent` is published. There is no RabbitMQ trip to writing-service or speaking-service from a normal `AttemptService.Submit`.
- The **direct user submission path** for writing or speaking (e.g., `POST /api/writing/grade` or `POST /api/speaking/grade` to the dedicated skill services) is **synchronous** in those services: they call `AiWritingGrader.GradeAsync` / `AiSpeakingGrader.GradeAsync` directly via HTTP and persist the evaluation. Only `writing-service` then publishes an *additional* `WritingGradeRequestMessage` with `SubmissionId` populated (Flow A) to fetch an asynchronous `ComparativeAnalysisJson` — the FE reads that result via `GET /api/writing/{submissionId:guid}/comparison`. `speaking-service` does **not** republish.

## Flow 4 — RAG per-item explainer (reading/listening)

```
[FE] GET attempt result → triggers per-item explain call (or pre-fetched during Submit)
   └─▶ attempt-service.SkillRagExplainer.ExplainItem
        ├─ for Reading items: HttpClient POST ai-service /api/v1/reading/explain-item
        │                     body ReadingExplainRequest
        │                ◀── RagFeedbackEnvelope (criteria + evidence + suggestions)
        │   (ReadingExplainerClient.ExplainAsync uses `_http.PostAsJsonAsync(...)`)
        └─ for Listening items: HttpClient POST ai-service /api/v1/listening/explain-item
                                  body ListeningExplainRequest
                             ◀── RagFeedbackEnvelope
                             (ListeningExplainerClient mirrors the same call shape)
```

The result is composed into the per-question UI payload returned by `getresult/{attemptId}` and also persisted on `AttemptAnswer.RagFeedbackJson` during submit (3s per-item timeout).

## Flow 5 — Flashcard review → XP

```
[FE] POST /api/users/{userId}/flashcard/{cardId}/review  body {quality}
   └─▶ vocabulary-service.UserHandler.ReviewFlashcardHandler
        ├─ UserService.ReviewCard — applies SM2 (EF, repetitions, interval, NextReviewDate)
        ├─ persist updated FlashCard
        └─ publish CardReviewedEvent(UserId, CardId, Grade, IsCorrect)
              └─▶ gamification-service.CardReviewedConsumer
                    └─ awards XP (no notification side-effects; updates UserStats)
```

## Flow 6 — Lesson completion → XP

```
[FE] POST /api/{userId}/{lessonId}:complete
   └─▶ course-service.UserEndpointHandler.CompeteCourseHandler
        ├─ Update enrollment progress
        └─ publish LessonCompletedEvent(UserId, LessonId, CourseId)
              └─▶ gamification-service.LessonCompletedConsumer
                    └─ awards XP, updates streak
```

## Flow 7 — Forgot password

```
[FE] POST /api/auth/forgot-password?email=
   └─▶ AuthService.ForgotPasswordRequestAsync
        ├─ RedisOtpStore.PutOtp(pwreset::{email}, otp, PwResetTtl=10min)
        ├─ RedisOtpStore.TouchResendCooldown(pwreset::{email}, 30s)
        └─ publish UserRegisteredSendOtp(email, otp, ttlSeconds=600)
              └─▶ email-service → SMTP
[FE] POST /api/auth/confirm-otp-reset-password  body {email, otp, newPassword}
   └─▶ AuthService.ConfirmResetPasswordAsync
        ├─ RedisOtpStore.Verify(...) → UserManager.ChangePasswordAsync
        └─ Clear pwreset keys
```

## Flow 8 — Reading Paper generation

```
[Admin FE] POST /api/admin/reading-paper/jobs
   └─▶ exam-service.ReadingPaperEndpoints
        ├─ persist ReadingPaperJob row (status=Pending)
        └─ ReadingPaperWorker (IHostedService) picks up
              └─▶ POST generation-service /api/v1/autogen/reading-paper/section
                    (Accept: application/x-ndjson for streaming)
                    ├─ Phase 1: Passage Synthesis (720–915 words) with bounded extension
                    ├─ Phase 2: Source-Fidelity Audit & Targeted Revision (fail-closed)
                    ├─ Phase 3: Question Group Generation (6 canonical types: MCQ, TFNG, YNNG, Sentence Completion, Summary Completion, Short Answer)
                    └─ Phase 4: Independent Answer Review & Surgical Replacement
                    ◀── NDJSON progress + final section JSON
              └─ persist ReadingPaperJobLog + final section
```

Authorization at gateway: `generation-api` requires **Admin** role.

## Flow 9 — Daily check-in

```
[FE] POST /api/gamification/daily-checkin
   └─▶ GamificationService.DailyCheckin(userId)
        ├─ if already checked in today → idempotent fail
        └─ else: update streak, write XpTransaction, return result
```

No external side-effects.

## Flow 10 — Auth-gateway cross-validation

```
[FE] GET /api/gamification/me   Authorization: Bearer <jwt>
   └─▶ api-gateway
        ├─ YARP JwtBearer validates HS256 (SignKey from appsettings.json's ${JwtSettings__SignKey})
        ├─ NameClaimType=Sub, RoleClaimType=Roles
        ├─ YARP forwards to gamification-cluster
        └─▶ gamification-service authorizes with the same JWT validation
```

All other routes (except `/health`, `/alive`, swagger, public reads) follow the same pattern.

## Summary table

Queue names below come from explicit `ReceiveEndpoint(...)` calls where present, and from the **default MassTransit formatter** (PascalCase **with the trailing `Consumer` suffix stripped** from the class name — i.e., `WritingSubmittedConsumer` → `WritingSubmitted`) where `bus.ConfigureEndpoints(ctx)` is used without a `ReceiveEndpoint` and without a `KebabCaseEndpointNameFormatter`. Only `auth-service` configures a kebab-case formatter (`KebabCaseEndpointNameFormatter("user-registered", includeNamespace: false)` at `services/auth-service/Program.cs:148`); no other service does.

| Trigger | Source | Target | Channel |
|---|---|---|---|
| Register / resend-otp / forgot-password | auth-service | email-service | `UserRegisteredSendOtp` (queue `user-registered-send-otp`, kebab-case — set in `email-service/Program.cs` ReceiveEndpoint) |
| Email verification succeeded | auth-service | gamification-service | `UserCreatedEvent`. The receive queue is the **default MassTransit formatter** (PascalCase **with `Consumer` suffix stripped**) applied to `UserCreatedConsumer` → **`UserCreated`** (because `gamification-service/Program.cs:50,59` does `AddConsumer<UserCreatedConsumer>()` + `ConfigureEndpoints(ctx)` without a `KebabCaseEndpointNameFormatter`). The auth-side kebab-case formatter is **process-local to auth-service's bus** and does NOT cross service boundaries — MassTransit endpoint naming is per-bus. |
| Attempt submitted (always) | attempt-service | gamification-service | `AttemptCompletedEvent` |
| Card reviewed | vocabulary-service | gamification-service | `CardReviewedEvent` |
| Lesson completed | course-service | gamification-service | `LessonCompletedEvent` |
| Placement test submitted — writing | attempt-service (`PlacementWorkflow`) | writing-service | `WritingGradeRequestMessage` (Flow B, `SubmissionId=null`); consumer queue auto-named `WritingSubmitted` by default formatter |
| Placement test submitted — speaking | attempt-service (`PlacementWorkflow`) | speaking-service | `SpeakingGradingRequestMessage` (with Cloudinary `AudioUrl`); consumer queue auto-named `SpeakingGrading` by default formatter |
| Writing grading response | writing-service | attempt-service | `WritingGradeResponseMessage` (consumed by attempt-service queue `writing-graded-response`, explicit `ReceiveEndpoint`) |
| Speaking grading response | speaking-service | attempt-service | `SpeakingGradingResponseMessage` (consumed by attempt-service queue `speaking-graded-response`, explicit `ReceiveEndpoint`) |
| Async writing comparison (Flow A) | writing-service | writing-service | `WritingGradeRequestMessage` with `SubmissionId` set — consumed by **same** `WritingSubmittedConsumer` (intra-service, NOT attempted→writing) |
| gRPC exam fetch | attempt-service | exam-service | `ExamInternal.GetInternalExam/GetExamList` (gRPC server registered with `MapGrpcService<…>().AllowAnonymous()` — no internal-API-key validation on the server) |
| AI grading (writing, sync) | writing-service (direct user submit) OR `WritingSubmittedConsumer` (placement) | ai-service | HTTP `POST /api/v1/writing/grade` (90s) |
| AI grading (speaking, sync) | speaking-service (direct user submit) OR `SpeakingGradingConsumer` (placement) | ai-service | HTTP `POST /api/v1/speaking/grade` |
| AI essay comparison | `WritingSubmittedConsumer` | ai-service | HTTP `POST /api/v1/writing/compare` |
| RAG per-item | attempt-service | ai-service | HTTP **`POST`** `/api/v1/{reading,listening}/explain-item` (3s per-item timeout; uses `_http.PostAsJsonAsync(...)`) |
| Autogen questions | langfens-fe-app admin panel → configured endpoint (default: ai-service via YARP) | configured endpoint (default: ai-service via YARP) | HTTP `POST /api/v1/autogen/questions`. The YARP route `ai-autogen-admin` (`/api-ai/v1/autogen/{**catch-all}`, `AuthorizationPolicy=Admin`) is the **default-config** path: `langfens-fe-app/src/app/admin/_lib/aiConfig.ts:42-49` builds `endpoint = process.env.NEXT_PUBLIC_AI_SERVICE_URL \|\| process.env.NEXT_PUBLIC_AI_ENDPOINT \|\| (NEXT_PUBLIC_GATEWAY_URL ? `${NEXT_PUBLIC_GATEWAY_URL}/api-ai` : "http://localhost:5000/api-ai")` — note **JavaScript logical OR**, not TypeScript `??`, so an empty-string env var also falls through. **Either of the first two env vars overrides the default base**; `cfg.endpoint` is then used as an arbitrary base URL by `callAi` (`aiConfig.ts:55-58`) to construct `${base}/v1/autogen/questions` or `${base}/api/v1/autogen/questions`. The override's *value* determines the actual target — it could be ai-service, a different proxy, anything — not just ai-service. **No .NET service** in this repo calls the endpoint. The `Depends(get_current_user)` dep inside the router is commented out (`// TODO: wire JWT auth in Phase 5 follow-up`). When traffic flows through YARP, admin gating is enforced by the route's `AuthorizationPolicy=Admin`; the FE only attaches an `Authorization: Bearer <token>` header opportunistically (`aiConfig.ts:60-64`) when `getToken()` returns a value — this is **not** server-side access control. Rate-limit middleware caps this route at 5 req/min. |
| Reading paper generation | exam-service (`ReadingPaperWorker`) | **generation-service** in normal AppHost/Compose paths | HTTP `/api/v1/autogen/reading-paper/section` (NDJSON). `ReadingPaperAiClient` BaseAddress resolution (verbatim from `services/exam-service/Program.cs:51-55`): `GENERATION_SERVICE_URL ?? AI_SERVICE_URL ?? "http://generation-service:8080"`. AppHost sets `GENERATION_SERVICE_URL` to the generation-service Aspire endpoint (`AppHost/Program.cs` `.WithEnvironment("GENERATION_SERVICE_URL", generationService.GetEndpoint("http"))` on the exam project), so under Aspire the worker talks to generation-service. If `GENERATION_SERVICE_URL` is unset and `AI_SERVICE_URL` is set instead, it would fall back to ai-service (which does not implement this route and would 404); the final literal fallback `http://generation-service:8080` only applies in compose where the hostname matches. |

**Self-publish caveat:** writing-service publishes `WritingGradeRequestMessage` with `SubmissionId` set (Flow A) for asynchronous comparison after the synchronous grade. The consumer is `WritingSubmittedConsumer` *inside writing-service itself*; this is intra-service, not cross-service. The cross-service Writing RabbitMQ flow is exclusively the placement path.

**Queue-naming caveat:** Because `writing-service` and `speaking-service` do not pin their consumer queues (no explicit `ReceiveEndpoint`, no kebab-case formatter), the queue name is the **default MassTransit formatter applied to the consumer class name** — i.e., PascalCase **with the trailing `Consumer` suffix stripped** — yielding `WritingSubmitted` (from `WritingSubmittedConsumer`) and `SpeakingGrading` (from `SpeakingGradingConsumer`). The strings `writing-graded-response` / `speaking-graded-response` only exist on the attempt-service side (explicit `ReceiveEndpoint(...)` calls). Treat any queue-name assertion across services with care and re-verify against the source.
