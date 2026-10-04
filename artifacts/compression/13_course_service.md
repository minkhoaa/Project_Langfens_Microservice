# 13 — course-service

> Source-of-truth: `services/course-service/*`. Verified by direct reads.

## Role in the system

Course/lesson management. Admin CRUD for courses + lessons. Public read APIs. User enrollment + progress + lesson completion (publishes `LessonCompletedEvent` for gamification).

## Stack

- ASP.NET Core 10, EF Core + Npgsql (`NonRetryingExecutionStrategy`).
- MassTransit + RabbitMQ (publisher only).

## Persistence

`CourseDbContext`: `Courses`, `Lessons`, `Enrollments` (with `EnrollmentStatus`).

## Endpoints

`Features/CourseEndpoint.cs`:

| Method | Path | Scope |
|---|---|---|
| GET | `/api/getpublishedcourse/` | anonymous |
| GET | `/api/getbyslug/{slug}` | anonymous |
| GET | `/api/getlessonbyslug/{slug}` | anonymous |
| GET | `/api/lesson/{lessonId:guid}` | anonymous |
| GET | `/api/{courseId}/{userId}:enroll` | `CourseScope.CourseEnroll` |
| POST | `/api/{userId}/{lessonId}:complete` | `CourseScope.CourseComplete` |
| POST | `/api/{userId}/progress` | `CourseScope.CourseRead` |
| POST | `/api/admin/create` | `CourseScope.CourseManage` |
| PUT | `/api/admin/update/{courseId}` | `CourseScope.CourseManage` |
| DELETE | `/api/admin/delete/{courseId}` | `CourseScope.CourseManage` |
| POST | `/api/admin/{courseId}/lesson/create` | `CourseScope.CourseManage` |

(Program.cs calls `app.MapCourseEndpoint(); app.MapLessonEndpoint(); app.MapAdminEndpoint();` — file-level paths follow the convention above.)

## RabbitMQ

- `MassTransit.UsingRabbitMq((ctx, cfg) => { cfg.Host(...); })` — no explicit `ReceiveEndpoint`. MassTransit auto-assigns endpoint names via `ConfigureEndpoints` for any future consumers.
- Publishes `LessonCompletedEvent(UserId, LessonId, CourseId)` when lesson completed.

## Health checks

- `course-db` (NpgSql)
- `rabbitmq` (URI-based AMQP probe)

## Environment variables (verified)

| Key | Purpose |
|---|---|
| `RABBITMQ__HOST/PORT/USERNAME/PASSWORD/VHOST/USESSL` | broker |
| `ConnectionStrings__course-db` | Aspire-injected |

## Authorization

`AddCourseAuthorization()`: `Roles.User`/`Roles.Admin` + scopes `CourseScope.{CourseRead, CourseEnroll, CourseComplete, CourseManage}`.
