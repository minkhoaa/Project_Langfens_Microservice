# Course service
Owns courses, lessons, enrollments and user learning progress.

- `Features/{Admin,Public,User}Endpoint/` separate management, public reads and learner operations.
- Extend the corresponding endpoint service/interface and map it in `Program.cs`; retain tier-specific authorization.
- `Infrastructure/CourseDbContext.cs` owns course/enrollment data; migrations live in `Migrations/`.
- `AddCourseAuthorization()` defines local role/scope policies.
- MassTransit is configured for publishing; there are no registered consumers. Preserve existing event contracts for downstream progress/XP workflows.
- Do not add a consumer or second queue convention merely because the broker is configured.
- Build from root: `dotnet build services/course-service/course-service.csproj`.
- No dedicated test project exists; verify enrollment/progress authorization and downstream event behavior when changing these paths.
