# Course service
Courses, lessons, enrollments and progress; persistence: `Infrastructure/CourseDbContext.cs`.

- Extend the matching `Features/{Admin,Public,User}Endpoint/` handler/service.
- Preserve `AddCourseAuthorization()` tier policies and enrollment/progress ownership checks.
- MassTransit is publisher-only; there is no registered consumer/queue convention here.
- Lesson/progress events feed gamification; do not award XP in this service.
- Verify enrollment authorization and progress event payloads with isolated persistence/broker.
