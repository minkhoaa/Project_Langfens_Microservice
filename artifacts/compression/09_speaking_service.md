# 09 — speaking-service

> Source-of-truth: `services/speaking-service/*`. Verified by direct reads.

## Role in the system

IELTS Speaking pipeline. **Two distinct paths**, both relying on local Whisper STT + HTTP call to `ai-service`:

1. **Direct user submission** (`POST /api/speaking/grade`, multipart):
   - `SpeakingService.SpeakingSubmit` runs **synchronously**: `WhisperService.Transcript(submitForm.Speech)` → `_grader.GradeAsync` (HTTP `ai-service /api/v1/speaking/grade`).
   - Persists `SpeakingSubmission` + `SpeakingEvaluation`, returns the band scores to the FE.
   - **Does NOT use RabbitMQ.**
2. **Placement flow** (triggered by `attempt-service/PlacementWorkflow` for `ExamCategory.PLACEMENT` attempts):
   - `attempt-service` publishes `SpeakingGradingRequestMessage` carrying a Cloudinary `AudioUrl`.
   - `SpeakingGradingConsumer` (queue `speaking-graded-response`, MassTransit `IConsumer<SpeakingGradingRequestMessage>`) consumes the request, downloads the audio via `IAudioDownloader`, runs Whisper transcription, then `_grader.GradeAsync`, builds `SpeakingGradingResponseMessage`, and **publishes** it back.
   - `attempt-service.SpeakingGradedConsumer` invokes `PlacementWorkflow.OnSpeakingGradedAsync` → updates `PlacementResult.SpeakingBand` + `SpeakingGradeJson` and may flip attempt status to `Graded`.
3. **Live STT** via WebSocket endpoint `GET /ws/speaking/transcript` — streams Whisper transcription; no grading involved.

## Stack

- ASP.NET Core 10, EF Core + Npgsql (`NonRetryingExecutionStrategy`).
- MassTransit (consumer + publisher).
- **Whisper.net** with model bootstrap via `WhisperModelHelper.EnsureModelDownloadedAsync()`.
- **Cloudinary** (CDN storage for audio).
- HttpClient to `ai-service` (`AiSpeakingGrader`).
- Kestrel `MaxRequestBodySize = 50 MB`.
- WebSocket endpoint via `app.MapWebsocketSpeaking()`.

## Whisper runtime

`Program.cs` order: `RuntimeOptions.RuntimeLibraryOrder = [RuntimeLibrary.Cuda, RuntimeLibrary.Cpu, RuntimeLibrary.CpuNoAvx]`.

DI:

```csharp
builder.Services.AddSingleton<WhisperFactory>(_ => WhisperFactory.FromPath(whisperModelPath));
builder.Services.AddScoped<WhisperProcessor>(sp =>
    sp.GetRequiredService<WhisperFactory>()
      .CreateBuilder()
      .WithLanguage("en")
      .Build());
```

## Cloudinary

`Features/Storage/CloudinaryConfig.cs` holds credentials (`CLOUDINARY__CLOUDNAME/APIKEY/APISECRET`).

`ICloudinaryService` (`Features/Services/User/CloudinaryService.cs`) implements upload + delete.

## Endpoints

`Features/SpeakingEndpoint.cs`:

| Method | Path | Notes |
|---|---|---|
| POST | `/api/speaking/transcript` | multipart; Whisper STT only (anonymous) |
| POST | `/api/speaking/grade` | multipart/form-data (`SpeakingSubmitForm`); `Roles.User`; Antiforgery disabled |
| GET | `/api/speaking/exams` | anonymous |
| GET | `/api/speaking/exams/{examId:guid}` | anonymous |
| GET | `/api/speaking/history` | `Roles.User` |
| GET | `/api/speaking/history/{submissionId:guid}` | `Roles.User` |
| POST | `/api/speaking/start/{examId}` | `Roles.User` |
| GET | `/ws/speaking/transcript` | WebSocket stream |
| POST | `/api/upload/audio` | multipart audio upload (anonymous) |
| GET | `/api/admin/speaking/exams` | `Roles.Admin` |
| POST | `/api/admin/speaking/exams` | `Roles.Admin` |
| PUT | `/api/admin/speaking/exams/{examId:guid}` | `Roles.Admin` |
| DELETE | `/api/admin/speaking/exams/{examId:guid}` | `Roles.Admin` |

## Helpers

- `AudioDownloader` — HttpClient to fetch Cloudinary audio.
- `AudioNormalizer` — pre-process audio for Whisper.
- `WhisperModelHelper` — model download/load.
- `LlmToResponseHelper` — convert LLM JSON to `SpeakingGradingResponseMessage`.
- `ExtractJsonObject` — defensive LLM JSON parsing.
- `AiSpeakingGrader` — HttpClient → ai-service.
- `SpeakingGradeResult` — typed wrapper.

## RabbitMQ

- Consumer `SpeakingGradingConsumer` registered via `bus.ConfigureEndpoints(ctx)` (no explicit `ReceiveEndpoint` and no `KebabCaseEndpointNameFormatter` — verified at `services/speaking-service/Program.cs:87`). MassTransit's default `DefaultEndpointNameFormatter` applies PascalCase **with the trailing `Consumer` suffix stripped** to the class name → receive queue is **`SpeakingGrading`** (from `SpeakingGradingConsumer`). The string `speaking-graded-response` is **only** configured in `services/attempt-service/Program.cs` for **that service's** response-side consumer (`SpeakingGradedConsumer`); it is **not** a queue name on the speaking-service side.
- Consumes `SpeakingGradingRequestMessage`; publishes `SpeakingGradingResponseMessage` via `IPublishEndpoint`.
- speaking-service is **not** the originator of `SpeakingGradingRequestMessage` — that comes from `attempt-service/PlacementWorkflow.OnPlacementSubmittedAsync`. speaking-service is a **pure consumer+publisher in this path**.
- The direct user submission path (`POST /api/speaking/grade`) does not use RabbitMQ at all.

## Health checks

- `speaking-db` (NpgSql)
- `rabbitmq` (URI-based AMQP probe)

## Environment variables (verified)

| Key | Purpose |
|---|---|
| `CLOUDINARY__CLOUDNAME` | CDN |
| `CLOUDINARY__APIKEY` | CDN |
| `CLOUDINARY__APISECRET` | CDN |
| `AI_SERVICE_URL` | ai-service base |
| `RABBITMQ__HOST/PORT/USERNAME/PASSWORD/VHOST/USESSL` | broker |
| `ConnectionStrings__speaking-db` | Aspire-injected |

## Authorization

`AddSpeakingAuthorization()` (service-local): `Roles.User`/`Roles.Admin` + `SpeakingScope.{Start,Create,ViewOwn,ViewAny}` via `HasAnyScope`.

## Notable design points

- Whisper runs **locally** (CUDA → CPU → CPU-no-AVX fallback); the user's audio is not shipped to a 3rd-party ASR.
- The audio is stored on Cloudinary so the **placement flow** can download it asynchronously — direct user submissions don't need Cloudinary (Whisper runs on the uploaded file in-process).
- WebSocket endpoint is *separate* from the multipart REST API; both share `WhisperProcessor` DI.
