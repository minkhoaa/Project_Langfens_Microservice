# Speaking service
Owns speaking submissions and audio workflows; Whisper.net transcribes locally, ai-service grades over HTTP.

- `Features/Services/{User,Admin,Helper}/` implements APIs/services; `Features/Helper/` contains transcription/grading helpers.
- `Features/RabbitMq/SpeakingGradingConsumer.cs` consumes `SpeakingGradingRequestMessage`, downloads audio, transcribes, calls `ISpeakingGrader`, then publishes the correlated response to attempt-service.
- Python ai-service does not consume these RabbitMQ messages; preserve the HTTP/broker boundary.
- `Program.cs` bootstraps the Whisper model with CUDA → CPU → CPU-no-AVX fallback; startup can download a model.
- `Features/Services/User/CloudinaryService.cs` owns audio storage; retain stream disposal and cancellation through download/grading.
- Kestrel's upload limit is 50 MiB (different from Python speech-evaluate's limit); preserve WebSocket speaking routes too.
- `AI_SERVICE_URL` configures HTTP grading; Cloudinary uses `CLOUDINARY__*`.
- Build from root: `dotnet build services/speaking-service/speaking-service.csproj`.
- No dedicated test project exists; mock model/audio/cloud/AI calls for unit tests. `README.md` contains manual transcription probes, not local-dev endpoint discovery.
- Detailed standalone vs attempt grading flows: `../../docs/AI_ARCHITECTURE_AND_FLOWS.md`.
