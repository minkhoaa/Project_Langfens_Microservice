# Test Automation Report

## Discovery Snapshot
Service | Base route | Endpoints (main) | Config keys observed | Auth scheme
--- | --- | --- | --- | ---
auth-service | `/api/auth` | register, login, login-google, refresh, logout, me, verify, resend-otp, forgot-password, resend-otp-reset-password, confirm-otp-reset-password | `CONNECTIONSTRING__AUTH`, `CONNECTIONSTRING__REDIS`, `JwtSettings__Issuer`, `JwtSettings__Audience`, `JwtSettings__SignKey`, `JwtSettings__RsaPrivateKeyPem`, `JwtSettings__KeyId`, `JwtSettings__AccessTokenLifetimeSeconds`, `RABBITMQ__HOST/PORT/VHOST/USERNAME/PASSWORD/USESSL`, `OAuth:PUBLIC_GOOGLE_CLIENT_ID` | JWT Bearer + cookies for session id
course-service | `/api/course`, `/api/lesson`, `/api/admin/course` | getpublishedcourse, getbyslug/{slug}, getlessonbyslug/{slug}; enroll endpoints; lesson complete/progress; admin create/update/delete course and lessons | `CONNECTIONSTRING__COURSE`, `JwtSettings__Issuer`, `JwtSettings__Audience`, `JwtSettings__SignKey` | JWT Bearer, policies via roles/scopes
vocabulary-service | `/api/decks`, `/api/users` | list decks, deck by slug, cards by slug/id; user subscribe/decks/own/due/review/progress; admin deck/card CRUD & publish | `CONNECTIONSTRING__VOCABULARY`, `JwtSettings__Issuer`, `JwtSettings__Audience`, `JwtSettings__SignKey` | JWT Bearer, user/admin roles
exam-service | `/api/public/exam`, `/api/admin/exam`, `/api/admin/section`, `/api/admin/question`, `/api/admin/option`, `/api/internal` | public list/get by slug; admin add/list/update/delete exam, section add/update/delete, question add/update/delete, option add/update/delete; internal `/exams/{id}/delivery?showAnswers` | `CONNECTIONSTRING__EXAM`, `JwtSettings__Issuer`, `JwtSettings__Audience`, `JwtSettings__SignKey` | JWT Bearer with scopes/roles; internal endpoint allows anonymous
attempt-service | `/api/attempt`, `/api/admin/attempt` | start, get by id, autosave, submit, get result, list attempts, placement latest/status; admin list attempts | `CONNECTIONSTRING__ATTEMPT`, `JwtSettings__Issuer`, `JwtSettings__Audience`, `JwtSettings__SignKey`, `RABBITMQ__*`, `EXAMSERVICE__EXAM__ADDRESS`, `EXAMSERVICE__INTERNAL__API__KEY` | JWT Bearer with attempt scopes
api-gateway | reverse proxy | routes for auth/exam/attempt/course/vocabulary/speaking/writing/email/chatbot/dictionary; direct routes for admin/internal paths | `JwtSettings__Issuer`, `JwtSettings__Audience`, `JwtSettings__SignKey`, `ReverseProxy` clusters/destinations | JWT Bearer for protected upstreams
speaking-service | `/api/speaking`, `/api/admin/speaking`, `/api/upload`, `/ws/speaking` | transcript, grade, exam list/detail, history/list/detail, start; admin exam list/create/update/delete; upload audio; websocket transcript | `CONNECTIONSTRING__SPEAKING`, `JwtSettings__*`, `RABBITMQ__*`, `GEMINI__APIKEY`, `GEMINI__MODEL`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET`, `CLOUDINARY_CLOUD_NAME` | JWT Bearer (user/admin scopes), some endpoints anonymous
writing-service | `/api/writing`, `/api/admin/writing` | grade, exam list/start/detail, history list/detail; admin exam CRUD | `CONNECTIONSTRING__WRITING`, `JwtSettings__*`, `RABBITMQ__*`, `GEMINI__APIKEY`, `GEMINI__MODEL` | JWT Bearer (user/admin scopes)

## How to run (target state)
- Restore & build tests solution: `dotnet test tests/LangfensEnglish.Tests.sln`
- Docker required for Postgres/Redis/RabbitMQ testcontainers.
- Environment: no external network calls expected; all fakes/containers in test harness.

## Pending work
- Seed data per service, integration test suites for 46 functions, UT targets, smoke coverage.
- Update this report with final command, coverage numbers, and skip reasons once suites are implemented.
