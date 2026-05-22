# course-service

Manages courses and lessons with RabbitMQ messaging for enrollment events.

## Service Overview
- **Port**: 5446 (HTTP)
- **Stack**: ASP.NET Core 10, EF Core + Npgsql, MassTransit/RabbitMQ
- **Database**: PostgreSQL via CourseDbContext
- **No gRPC**: Pure REST + RabbitMQ

## Key Files
```
Program.cs                           Entry point
Infrastructure/
  Persistence/CourseDbContext.cs     EF Core DbContext (Courses, Lessons, Enrollments)
  Migrations/                        EF Core migrations
Features/
  AdminEndpoint/                     Admin CRUD for courses/lessons
  PublicEndpoint/                    Public read APIs
  UserEndpoint/                      User-facing APIs (enrollment, progress)
```

## Common Operations

### Adding a new course/lesson endpoint
1. Add service method to `IAdminEndpointService` / `IPublicEndpointService` / `IUserEndpointService`
2. Create endpoint file in the appropriate `Features/{Tier}Endpoint/` folder
3. Register in `Program.cs`: `app.MapCourseEndpoint()`, `app.MapLessonEndpoint()`, etc.

### RabbitMQ (MassTransit) — publisher only
- This service uses MassTransit to **publish** domain events (e.g., `EnrollmentCreated`)
- Configure in `Program.cs` with `UsingRabbitMq`
- No explicit consumer registration (uses `ConfigureEndpoints(ctx)` auto-registration)

### DB Migrations
```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/course-service
dotnet ef migrations add <Name> --project course-service.csproj --output-dir Migrations
dotnet ef database update --project course-service.csproj
```

## How This Service Communicates with Others
- **RabbitMQ**: Publishes events to other services (e.g., `gamification-service` for lesson completion XP)
- **REST**: Public API for frontend; internal endpoints for admin

## Authorization
- `AddCourseAuthorization()` — adds role/scope-based policies

## Environment Variables
```
RABBITMQ__HOST, RABBITMQ__USERNAME, RABBITMQ__PASSWORD, RABBITMQ__VHOST, RABBITMQ__PORT,
Aspire: course-db connection string
```