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