# exam-service

Manages exam content (questions, sections, options) with both REST and gRPC APIs.

## Service Overview
- **Ports**: 5433 (HTTP), gRPC 5075
- **Stack**: ASP.NET Core 10, EF Core + Npgsql, gRPC (protobuf), Aspire
- **Database**: PostgreSQL via ExamDbContext
- **Key patterns**: gRPC service for internal consumers (attempt-service), REST for admin/public endpoints

## Key Files
```
Program.cs                           Entry point, gRPC + HTTP multiplexing
Infrastructure/
  BootstrapExtensions.cs             Service-local extensions (AddExamAuthorization, etc.)
  Persistence/
    ExamDbContext.cs                 EF Core DbContext (Exams, Sections, Questions, Options)
    ExamDbContextFactory.cs           Design-time factory for migrations
  Migrations/                        EF Core migrations
Data/
  ReadingSeeder.cs                    Seeds Reading exam data on startup
Features/
  Exams/AdminEndpoint/               Admin CRUD endpoints
    ExamEndpoint/                    Create/Read/Update exam
    QuestionEndpoint/                Question management
    OptionEndpoint/                  Option management
    SectionEndpoint/                 Section management
  Exams/PublicEndpoint/              Public exam read APIs
  Exams/InternalEndpoint/            Internal APIs (auth-protected, not public)
  Exams/Delivery/                    Exam delivery logic
  Exams/Dtos/                        Shared DTOs
  QuestionBank/                      Question bank management
  Validation/                        Input validation
```

## Common Operations

### Adding a new exam question type
1. Add enum value to `QuestionType` in `Shared.PublicContracts/Contracts/Exam/Enums/QuestionType.cs`
2. Add entity fields to `ExamQuestion` in `ExamDbContext.cs`
3. Create migration: `dotnet ef migrations add AddNewQuestionType --project exam-service.csproj`
4. Add grader registration in `attempt-service` if auto-scored

### Modifying the gRPC interface
1. Proto files live in `Shared.Grpc` (shared library)
2. Regenerate: `dotnet grpc_tools protoc ...` — proto is shared, so regenerate there
3. Update service implementation in `Features/Exams/InternalEndpoint/`
4. Remember: `app.MapGrpcService<ExamInternalGrpcService>().AllowAnonymous()` (internal calls use internal API key)

### Adding an internal endpoint
- Internal endpoints use `[Authorize(Policy = InternalPolicy)]` — check `AddExamAuthorization()`
- Also add route prefix in `MapInternalExamEndpoint()`

### DB Migrations
```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/exam-service
dotnet ef migrations add <Name> --project exam-service.csproj --output-dir Migrations
dotnet ef database update --project exam-service.csproj
```
Note: startup runs `MigrateAsync` automatically if `IsRelational()`.

## gRPC Patterns
- **Service**: `ExamInternalGrpcService` — gRPC server for internal service calls
- **Clients**: `attempt-service` uses `ExamInternalClient` from `Shared.Grpc` via gRPC channel
- gRPC address via env `ExamService__GrpcAddress` (defaults to `http://exam-service:8081`)
- Under Aspire: ports are dynamic; under compose: ports from `Kestrel__HttpPort` / `Kestrel__GrpcPort`

## How This Service Communicates with Others
- **gRPC**: Serves `ExamInternal` service → consumed by `attempt-service` (answer key lookup, exam metadata)
- **REST internal**: `attempt-service` calls `EXAMSERVICE__EXAM__ADDRESS` + `X-Internal-Key` header for admin data
- **No RabbitMQ**: Pure request/response via gRPC + REST

## Testing Patterns
- No dedicated test project; write unit tests for `ExamService.cs`, `QuestionBankService.cs`
- Use `ExamDbContextFactory` for integration tests with in-memory or test PostgreSQL

## Environment Variables
```
Kestrel__HttpPort, Kestrel__GrpcPort, ASPNETCORE_URLS, KESTREL_GRPC_PORT,
Aspire: exam-db connection string
```