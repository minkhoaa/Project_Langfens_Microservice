# Course service
Owns courses, lessons, enrollments and learner progress in `Infrastructure/CourseDbContext.cs`.

- `Features/{Admin,Public,User}Endpoint/` separates management, discovery and learner operations; extend the matching handler/service.
- Preserve `AddCourseAuthorization()` tier policies and enrollment/progress access checks.
- MassTransit is publisher-only here; broker configuration is not evidence of a consumer/queue convention.
- Keep progress/lesson events compatible with gamification; this service does not award XP directly.
- No dedicated tests; verify enrollment authorization and progress events with isolated persistence/broker.
