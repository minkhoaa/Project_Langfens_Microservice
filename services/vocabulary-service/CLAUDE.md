# vocabulary-service

Flashcard management with SM2 spaced repetition algorithm and AI vocabulary enrichment.

## Service Overview
- **Port**: 8093 (HTTP)
- **Stack**: ASP.NET Core 10, EF Core + Npgsql, MassTransit/RabbitMQ (publisher only), Azure OpenAI
- **Database**: PostgreSQL via VocabularyDbContext
- **Key patterns**: SM2 spaced repetition, AI-generated vocabulary enrichment

## Key Files
```
Program.cs                           Entry point
Infrastructure/
  Configuration/BootstrapExtensions.cs  Service-local extensions
  Persistence/VocabularyDbContext.cs EF Core DbContext (Decks, FlashCards, UserDeckStatus)
  Migrations/                        EF Core migrations
Features/
  Admin/                             Admin deck/card management
  Public/                            Public deck listing
  User/                              User flashcard study, SM2 review scheduling
    UserService.cs                   UserService — handles card review + SM2 update
```

## SM2 Spaced Repetition Pattern
- `UserService.ReviewCard()` applies SM2 algorithm to update card due date
- Fields tracked per card: `EasinessFactor`, `Repetitions`, `Interval`, `NextReviewDate`
- Review scheduling: SM2 computes next interval based on quality rating (0–5)

## AI Integration (Azure OpenAI)
- Activated when `AZURE_OPENAI__ENDPOINT` + `AZURE_OPENAI__APIKEY` are set
- Deployment: `AZURE_OPENAI__DEPLOYMENT` (default `gpt-4o-mini`)
- `IAiEnrichmentService` — generates example sentences, synonyms, definitions
- `IVocabularyExtractionService` — extracts vocabulary from text content

## Common Operations

### Adding a new deck endpoint
1. Add method to `IUserService` / `IPublicService` / `IAdminService`
2. Create endpoint in `Features/{Tier}/`
3. Register routes: `app.MapPublicVocabularyEndpoints()`, `app.MapUserVocabularyEndpoints()`

### Modifying SM2 algorithm
- SM2 logic is in `UserService.ReviewCard()` or a dedicated `Sm2Calculator`
- Quality rating 0–5 maps to intervals: fail (0–2) resets, pass (3–5) grows interval

### DB Migrations
```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/vocabulary-service
dotnet ef migrations add <Name> --project vocabulary-service.csproj --output-dir Migrations
dotnet ef database update --project vocabulary-service.csproj
```

## How This Service Communicates with Others
- **RabbitMQ publisher**: Publishes `CardReviewed` events → `gamification-service` (for XP)
- **No consumers**: This service only publishes events
- **Azure OpenAI**: AI vocabulary enrichment (optional)

## Authorization
- `AddVocabularyAuthorization()` — role/scope policies

## Environment Variables
```
RABBITMQ__HOST, RABBITMQ__USERNAME, RABBITMQ__PASSWORD, RABBITMQ__VHOST, RABBITMQ__PORT,
AZURE_OPENAI__ENDPOINT, AZURE_OPENAI__APIKEY, AZURE_OPENAI__DEPLOYMENT,
Aspire: vocabulary-db connection string
```