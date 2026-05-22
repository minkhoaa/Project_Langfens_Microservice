# gamification-service

Achievements, XP, and notifications. Consumes domain events from other services via MassTransit.

## Service Overview
- **Port**: 8096 (HTTP)
- **Stack**: ASP.NET Core 10, EF Core + Npgsql, MassTransit/RabbitMQ
- **Database**: PostgreSQL via GamificationDbContext (XP, achievements, user progress)
- **Key pattern**: Event-driven — consumes messages from course-service, attempt-service, vocabulary-service

## Key Files
```
Program.cs                           Entry point
Infrastructure/
  Persistence/GamificationDbContext.cs EF Core DbContext (UserXP, Achievements, etc.)
  Migrations/                        EF Core migrations
Features/
  Consumers/                         MassTransit consumers (domain event handlers)
    AttemptCompletedConsumer.cs      XP award when exam attempt completed
    CardReviewedConsumer.cs          XP for flashcard review
    LessonCompletedConsumer.cs       XP when lesson finished
    UserCreatedConsumer.cs           Initial XP setup for new user
```

## MassTransit Consumer Pattern (primary behavior)
This service is **driven entirely by events** from other services:
- `AttemptCompletedConsumer` — awards XP on exam completion
- `CardReviewedConsumer` — awards XP on vocabulary flashcard review
- `LessonCompletedConsumer` — awards XP on lesson completion
- `UserCreatedConsumer` — initializes gamification record for new user

### Adding a new consumer
1. Create `Features/Consumers/{EventName}Consumer.cs : IConsumer<TEvent>`
2. Register: `cfg.AddConsumer<NewConsumer>()` in `Program.cs` `AddMassTransit` block
3. Endpoint auto-registered via `bus.ConfigureEndpoints(ctx)`

## REST Endpoints
- `app.MapGamificationEndpoints()` — user XP/achievement APIs
- `app.MapNotificationEndpoints()` — notification APIs

## How This Service Communicates with Others
- **RabbitMQ consumer**: Listens to events from attempt-service, vocabulary-service, course-service
- **REST**: Exposes XP and achievement data to frontend
- **No direct DB writes from other services**: All cross-service updates go through events

## DB Migrations
```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/gamification-service
dotnet ef migrations add <Name> --project gamification-service.csproj --output-dir Migrations
dotnet ef database update --project gamification-service.csproj
```

## Authorization
- `AddGamificationAuthorization()` — role/scope policies

## Environment Variables
```
RABBITMQ__HOST, RABBITMQ__USERNAME, RABBITMQ__PASSWORD, RABBITMQ__VHOST, RABBITMQ__PORT,
Aspire: gamification-db connection string
```