# writing-service

IELTS Writing exam service with AI grading via ai-service. Handles submission, scoring, and feedback.

## Service Overview
- **Port**: 8091 (HTTP)
- **Stack**: ASP.NET Core 10, EF Core + Npgsql, MassTransit/RabbitMQ, HttpClient to ai-service, CircuitBreaker pattern
- **Database**: PostgreSQL via WritingDbContext (manual NpgsqlDataSource registration)
- **AI**: `IAiWritingGrader` + `IAiCompareClient` → `ai-service` via HttpClient with circuit breaker
- **Key pattern**: RabbitMQ consumer receives submissions; HTTP calls to ai-service for grading; response published back

## Key Files
```
Program.cs                           Entry point; NpgsqlDataSource manual registration
Infrastructure/
  Configuration/BootstrapExtensions.cs  Service-local extensions
  Persistence/WritingDbContext.cs     EF Core DbContext (WritingSubmission, WritingTask)
  Migrations/                        EF Core migrations
Features/
  Service/User/WritingService.cs      User writing submission logic
  Service/Admin/AdminService.cs       Admin management
  Handler/WritingSubmittedConsumer.cs  MassTransit consumer for grading requests
  RabbitMq/WritingSubmittedConsumer.cs  Legacy (check if duplicate)
  Helper/
    AiWritingGrader.cs               IWritingGrader implementation → ai-service HTTP
    AiCompareClient.cs               IAiCompareClient → ai-service HTTP
    CircuitBreaker.cs                Circuit breaker for AI service resilience
```

## Circuit Breaker Pattern
- `CircuitBreaker` registered as keyed singleton (`"grader"`, `"compare"`)
- Protects HTTP calls to `ai-service` from cascading failures
- Configured via env keys on the `CircuitBreaker` class

## AI Integration
- `IWritingGrader` (→ `AiWritingGrader`) POSTs to `AI_SERVICE_URL/grade`
- `IAiCompareClient` (→ `AiCompareClient`) POSTs to `AI_SERVICE_URL/compare`
- Timeout: 90 seconds
- Both clients configured via `builder.Services.AddHttpClient<>`

## MassTransit Consumer Pattern
```csharp
builder.Services.AddMassTransit(cfg =>
{
    cfg.AddConsumer<WritingSubmittedConsumer>();
    cfg.UsingRabbitMq((ctx, bus) =>
    {
        bus.Host(...);
        bus.ConfigureEndpoints(ctx); // auto-queues based on consumer type name
    });
});
```

### Adding a new consumer
1. Create `Features/Handler/{EventName}Consumer.cs : IConsumer<TMessage>`
2. Add to `cfg.AddConsumer<NewConsumer>()`
3. `ConfigureEndpoints` auto-assigns queue name

## Common Operations

### Adding a new writing endpoint
1. Add method to `IWritingService` / `IAdminService`
2. Create endpoint in `Features/Service/User/` or `Admin/`
3. Map: `app.MapWritingEndpoint()`, `app.MapWritingAdminEndpoint()`

### DB Migrations
```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/writing-service
dotnet ef migrations add <Name> --project writing-service.csproj --output-dir Migrations
dotnet ef database update --project writing-service.csproj
```
Note: Uses manual `NpgsqlDataSource` registration (not Aspire `AddNpgsqlDbContext`).

## How This Service Communicates with Others
- **RabbitMQ consumer**: Receives `WritingSubmitted` messages → triggers AI grading
- **RabbitMQ publisher**: Publishes grading results back (consumed by `attempt-service`)
- **HTTP**: `ai-service` for writing evaluation and comparison
- **gRPC**: None

## Authorization
- `AddWritingAuthorization()` — role/scope policies

## Environment Variables
```
RABBITMQ__HOST, RABBITMQ__USERNAME, RABBITMQ__PASSWORD, RABBITMQ__VHOST, RABBITMQ__PORT,
AI_SERVICE_URL, CONNECTIONSTRING__WRITING,
Aspire: writing-db connection string
```