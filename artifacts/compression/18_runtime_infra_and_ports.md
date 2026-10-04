# 18 — Runtime Infrastructure & Ports

> Source-of-truth: `deploy/compose.yaml`, `AppHost/Program.cs`, `gateway/api-gateway/appsettings.json`.

## Compose host-port map (verified)

| Service / infra | Container port | Host port (compose) | Notes |
|---|---|---|---|
| gateway-service | 8080 | **5000** | published |
| auth-service | 8080 | **8080** | published |
| attempt-service | 8080 | **8081** | published |
| exam-service (HTTP) | 8080 | **8082** | published |
| exam-service (gRPC) | 8081 | exposed only | not published to host |
| writing-service | 8080 | **8091** | published |
| speaking-service | 8080 | **8090** | published |
| vocabulary-service | 8080 | **8093** | published |
| dictionary-service | 8080 | **8094** | published |
| gamification-service | 8080 | **8096** | published |
| course-service | 8080 | internal | not published |
| email-service | 8080 | internal | not published (cluster `email-cluster` uses `http://email-service:3000` in `appsettings.json` — historic; AppHost overrides to actual endpoint) |
| ai-service | 8080 | **8092** | published |
| generation-service | 8080 | **8095** | published |
| frontend-service (Next.js) | 3000 | **3000** | published |
| rabbitmq-service | 5672 (AMQP), 15672 (mgmt) | mgmt 15672 | healthcheck `rabbitmq-diagnostics -q ping` |
| redis | 6379 | 6379 | `--save ""`, `--appendonly no`, `--maxmemory 128mb`, `--maxmemory-policy allkeys-lru` |
| ollama | 11434 | 11434 | persistent volume `ollama-data` |
| ollama-init | — | — | one-shot `ollama pull bge-m3` |
| Postgres exam | 5432 | **5433** | host port locked for dev `psql` |
| Postgres auth | 5432 | **5434** | |
| Postgres attempt | 5432 | **5435** | |
| Postgres writing | 5432 | **5440** | |
| Postgres speaking | 5432 | **5441** | |
| Postgres dictionary | 5432 | **5443** | |
| Postgres gamification | 5432 | **5444** | |
| Postgres course | 5432 | internal | |
| Postgres vocabulary | 5432 | **5987** | |

Network: `backend` (bridge). Volume: `pgdata` (all Postgres), `rabbitmq_data`, `ollama_data`.

## Aspire port allocation

AppHost declares Aspire-allocated ports for everything except the gateway (pinned 5000). Service URLs are injected via `service.GetEndpoint("http")` overrides on `ReverseProxy__Clusters__<name>__Destinations__d1__Address`. Two endpoints on `exam-service`: `http` → `Kestrel__HttpPort`, `grpc` → `Kestrel__GrpcPort`.

## Auth & authorization

- JWT HS256 (`JwtSettings__SignKey` shared between gateway and services).
- No fallback authorization policy → `/health`, `/alive`, swagger stay anonymous.
- Authorization policies registered per service:
  - exam-service: `AddExamAuthorization`
  - attempt-service: `AddAttemptAuthorization`
  - writing-service: `AddWritingAuthorization`
  - speaking-service: `AddSpeakingAuthorization`
  - vocabulary-service: `AddVocabularyAuthorization`
  - gamification-service: `AddGamificationAuthorization`
  - course-service: `AddCourseAuthorization`
  - dictionary-service: **no auth (`AddLangfensAuth` not called)**
  - email-service: **no auth (`AddLangfensAuth` not called)** — internal-only behind gateway
  - gateway: only `Admin` policy registered (for `ai-autogen-admin` + `generation-api`)

## Health checks per service

| Service | Health checks |
|---|---|
| auth-service | auth-db (NpgSql), auth-redis (Redis) |
| exam-service | exam-db (NpgSql) |
| attempt-service | attempt-db (NpgSql), rabbitmq (URI) |
| writing-service | writing-db (NpgSql) |
| speaking-service | speaking-db (NpgSql), rabbitmq (URI) |
| vocabulary-service | vocabulary-db (NpgSql) — RabbitMQ probe intentionally omitted |
| dictionary-service | dictionary-db (NpgSql) |
| gamification-service | gamification-db (NpgSql), rabbitmq (URI) |
| course-service | course-db (NpgSql), rabbitmq (URI) |
| email-service | rabbitmq (URI) |

## Persistence characteristics

| Service | DB | EF Core retry strategy | Notes |
|---|---|---|---|
| auth-service | auth-db | default | Identity schema (users/roles/etc.) + sessions |
| exam-service | exam-db | default + `EnableDynamicJson` for jsonb | reading-paper job tables |
| attempt-service | attempt-db | **NonRetrying** | explicit transactions in Submit |
| writing-service | writing-db | NpgsqlDataSource singleton (manual) | legacy `CONNECTIONSTRING__WRITING` env |
| speaking-service | speaking-db | **NonRetrying** | |
| vocabulary-service | vocabulary-db | **NonRetrying** | |
| dictionary-service | dictionary-db | **NonRetrying** | `pg_trgm` extension + GIN index |
| gamification-service | gamification-db | **NonRetrying** | |
| course-service | course-db | **NonRetrying** | |
| email-service | — | — | no DB |
| ai-service | — | — | Qdrant + Redis |
| generation-service | — | — | stateless; calls `exam-service` checkpoints via `CheckpointClient` |

## Broker topology

- All services using RabbitMQ share the same broker.
- `email-service` is a pure consumer (`email-testping`, `user-registered-send-otp`).
- `auth-service` is a publisher (`UserRegisteredSendOtp`, `UserCreatedEvent`).
- `course-service` publishes `LessonCompletedEvent`.
- `vocabulary-service` publishes `CardReviewedEvent`.
- `attempt-service` publishes grading requests + consumes grading responses + publishes `AttemptCompletedEvent`.
- `writing-service` is consumer + publisher (grading).
- `speaking-service` is consumer + publisher (grading).
- `gamification-service` is consumer-only (4 consumers; 0 publishers).

## Observability

- OTel logs/metrics/traces via `Shared.ServiceDefaults.AddServiceDefaults()`.
- OTLP exporter enabled when `OTEL_EXPORTER_OTLP_ENDPOINT` is set (else exporter is a no-op per Aspire defaults).
- HTTP resilience: retry + circuit breaker + timeout on `HttpClient` via `ConfigureHttpClientDefaults`.

## DNS workarounds

Gateway configures `handler.PooledConnectionLifetime = TimeSpan.FromSeconds(30)` to refresh pooled connections every 30s. Without this, YARP caches the upstream IP for the process lifetime, breaking DNS resolution after container recreation.
