# speaking-service

IELTS Speaking exam service with AI grading. Handles audio upload, transcription (Whisper), and AI grading via ai-service.

## Service Overview
- **Port**: 8090 (HTTP)
- **Stack**: ASP.NET Core 10, EF Core + Npgsql, MassTransit/RabbitMQ, Whisper.net, Cloudinary, HttpClient to ai-service
- **Database**: PostgreSQL via SpeakingDbContext
- **AI**: Whisper for STT (local CUDA/CPU model), `ISpeakingGrader` → `ai-service` via HttpClient
- **Storage**: Cloudinary for audio file storage
- **Key pattern**: RabbitMQ consumer receives grading requests; Whisper transcription; AI grading via HTTP

## Key Files
```
Program.cs                           Entry point; Whisper model bootstrap; Kestrel 50MB upload limit
Infrastructure/
  Configuration/BootstrapExtensions.cs  Service-local extensions
  Persistence/SpeakingDbContext.cs   EF Core DbContext
  Migrations/                        EF Core migrations
Features/
  Services/User/                      User-facing speaking APIs
  Services/Admin/                     Admin management
  Services/Helper/                    Helper services
  Storage/CloudinaryService.cs        ICloudinaryService — audio upload/download
  RabbitMq/SpeakingGradingConsumer.cs MassTransit consumer for grading results
  Helper/WhisperService.cs            IWhisperService — STT transcription
```

## Common Operations

### Adding a new speaking endpoint
1. Add method to `ISpeakingService` / `IAdminService`
2. Create endpoint in `Features/Services/User/` or `Admin/`
3. Register in `Program.cs`: `app.MapSpeakingEndpoint()`, `app.MapSpeakingAdminEndpoint()`
4. For WebSocket: `app.MapWebsocketSpeaking()` for real-time speaking practice

### Modifying Whisper transcription
- `WhisperService.cs` uses `WhisperFactory` + `WhisperProcessor`
- Model path bootstrapped in `Program.cs` via `WhisperModelHelper.EnsureModelDownloadedAsync()`
- Runtime order: CUDA → CPU → CPU-no-AVX

### AI Grading integration
- `ISpeakingGrader` → `AiSpeakingGrader` makes HTTP POST to `ai-service`
- URL via `AI_SERVICE_URL` env (default `http://ai-service:8080`)
- Grading consumer in `Features/RabbitMq/SpeakingGradingConsumer.cs`
- Requests published to RabbitMQ → ai-service → response on `speaking-graded-response` queue

### Audio upload
- Cloudinary configured in `Program.cs`
- `ICloudinaryService` handles upload/download
- Kestrel max body size: 50 MB

## Migration Postmortem — 2026-08-24

**Symptom:** `dotnet run` / AppHost start of `speaking-service` crashed with
`Npgsql.PostgresException 42703: column "ImageUrl" of relation "speaking_exams" does not exist`
during `Program.cs:136` (`db.Database.MigrateAsync()`).

**Root cause:** `Migrations/20260608000000_AddImageUrlToSpeakingExam.cs` had **no
`.Designer.cs`** file checked in. EF Core uses each migration's `<Name>.Designer.cs`
(which declares `[Migration("...")]` + a partial class implementing `BuildTargetModel`)
to enumerate migrations and compute deltas. Without a Designer file, EF silently
skipped the migration in `GetPendingMigrationsAsync()`. The runner then jumped
straight from `InitSpeakingDb` (the last applied) to `SyncSnapshotImageUrl`, which
issued `ALTER COLUMN "ImageUrl" DROP DEFAULT` — and the column had never been added.

Verified via:
- `dotnet ef migrations list` listed only `InitSpeakingDb` + `SyncSnapshotImageUrl`
  (the broken migration was invisible).
- `dotnet ef migrations script` produced SQL that skipped `AddImageUrlToSpeakingExam`
  entirely.
- Live DB `__EFMigrationsHistory` had only `InitSpeakingDb`; `speaking_exams`
  had no `ImageUrl` column.

**Fix applied:** deleted both `20260608000000_AddImageUrlToSpeakingExam.cs`
and `20260609040344_SyncSnapshotImageUrl*.cs` (the second migration only existed
to paper over the first one's `defaultValue: ""` artifact; with a clean migration
the column is just added without the unnecessary default-removal dance). Re-ran
`dotnet ef migrations add AddImageUrlToSpeakingExam`. Verified:
- `dotnet ef migrations list` now shows both `InitSpeakingDb` and the new
  `AddImageUrlToSpeakingExam`.
- `dotnet ef migrations script` emits `ALTER TABLE speaking_exams ADD "ImageUrl" text NOT NULL DEFAULT ''`.
- Manual application against the live `speaking-db-server` succeeded.
- `dotnet run` against the Aspire speaking-db container: `[EF] Pending migrations: 0`,
  service started cleanly, MassTransit bus + RabbitMQ consumer registered, listening
  on its bound port.

**Rule for the team:** every `dotnet ef migrations add <Name>` **must** be checked
in with its matching `<Name>.Designer.cs`. If you only commit the `.cs` file, EF
silently skips the migration and the next one will explode on a missing column.
When in doubt, run `dotnet ef migrations list` after `git add` and confirm the
new migration is present.

### DB Migrations
```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/speaking-service
dotnet ef migrations add <Name> --project speaking-service.csproj --output-dir Migrations
dotnet ef database update --project speaking-service.csproj
```



## How This Service Communicates with Others
- **RabbitMQ consumer**: `SpeakingGradingConsumer` — receives grading results from ai-service
- **RabbitMQ publisher**: Publishes grading requests to `ai-service`
- **HTTP**: `ISpeakingGrader` → `ai-service` for scoring
- **Cloudinary**: Audio asset CDN

## Environment Variables
```
RABBITMQ__HOST, RABBITMQ__USERNAME, RABBITMQ__PASSWORD, RABBITMQ__VHOST, RABBITMQ__PORT,
CLOUDINARY__CLOUDNAME, CLOUDINARY__APIKEY, CLOUDINARY__APISECRET,
AI_SERVICE_URL,
Aspire: speaking-db connection string
```