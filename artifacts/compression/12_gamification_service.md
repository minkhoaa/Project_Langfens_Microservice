# 12 — gamification-service

> Source-of-truth: `services/gamification-service/*`. Verified by direct reads.

## Role in the system

XP, levels, streaks, achievements, leaderboard, in-app notifications. **Pure event-driven**: every state transition comes from a RabbitMQ message.

## Stack

- ASP.NET Core 10, EF Core + Npgsql (`NonRetryingExecutionStrategy`).
- MassTransit (4 consumers + none publishes).
- No outgoing HTTP — fully driven by events.

## Consumers (all in `Features/Consumers/`)

| Consumer | Trigger event | Side effects |
|---|---|---|
| `AttemptCompletedConsumer` | `AttemptCompletedEvent(UserId, AttemptId, Skill?, Score)` | XP by skill (`Reading`/`Listening`/`Writing`/`Speaking` switch — Reading=10, others configurable), updates `UserStats.TotalXp`, `Level = UserStats.CalculateLevel(TotalXp)`, increments `TotalTestsCompleted`, updates streak, adds `XpTransaction`, checks achievements, creates notifications (test completed, level up, achievements, streak milestones at 7/14/30/60/100) |
| `CardReviewedConsumer` | `CardReviewedEvent(UserId, CardId, Grade, IsCorrect)` | Awards XP for flashcard review |
| `LessonCompletedConsumer` | `LessonCompletedEvent(UserId, LessonId, CourseId)` | Awards XP for lesson completion |
| `UserCreatedConsumer` | `UserCreatedEvent(UserId, Email, CreatedAt)` | Creates initial `UserStats` row |

`AttemptCompletedConsumer` notification triggers (in order): Test completed, Level up, each new Achievement, Streak milestone (7/14/30/60/100).

## Endpoints (`/api/gamification`)

`Features/GamificationEndpoint.cs`:

| Method | Path | Notes |
|---|---|---|
| GET | `/api/gamification/me` | current user stats |
| GET | `/api/gamification/achievements` | all achievements for current user |
| GET | `/api/gamification/leaderboard?limit=50` | global leaderboard (anonymous) |
| GET | `/api/gamification/history?limit=20` | XP history |
| POST | `/api/gamification/daily-checkin` | daily check-in |
| GET | `/api/gamification/progress-ring` | progress ring for FE |

Notification endpoints (`MapNotificationEndpoints`):

| Method | Path | Notes |
|---|---|---|
| GET | `/api/notifications` | list notifications for user |
| … | … | mark-read / clear |

(Notification endpoint routes mounted via `MapNotificationEndpoints` in `Program.cs` — verify against `Features/NotificationEndpoint.cs` for exact verb set.)

## Entities

`UserStats { UserId, TotalXp, Level, CurrentStreak, TotalTestsCompleted, … }`.
`XpTransaction { UserId, Amount, Reason, OccurredAt, … }`.
`Achievement { Code, Name, Description, … }` + join table for user unlocks.
`Notification { UserId, Type, Title, Body, Payload (json), CreatedAt, ReadAt? }`.

## Health checks

- `gamification-db` (NpgSql)
- `rabbitmq` (URI-based AMQP probe)

## Environment variables (verified)

| Key | Purpose |
|---|---|
| `RABBITMQ__HOST/PORT/USERNAME/PASSWORD/VHOST/USESSL` | broker |
| `ConnectionStrings__gamification-db` | Aspire-injected |

## Authorization

`AddGamificationAuthorization()` (service-local): `Roles.User`/`Roles.Admin` plus optional scope policies; uses `HasAnyScope` helper.

## Why this design?

Decouples XP economy from the host services: attempts/vocab/course/auth publish events, gamification owns the canonical record. New event-driven rewards only need a new consumer + DI registration.
