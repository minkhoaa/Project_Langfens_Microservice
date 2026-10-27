# Speaking service
Owns submissions/audio; Whisper.net transcribes locally and ai-service grades over HTTP.

- `Features/RabbitMq/SpeakingGradingConsumer.cs` downloads/transcribes audio and publishes correlated attempt responses; Python is not this queue's consumer.
- Startup may download Whisper weights; preserve runtime fallback CUDA → CPU → CPU-no-AVX.
- `Features/Services/User/CloudinaryService.cs` owns storage; preserve stream disposal/cancellation and WebSocket routes.
- Kestrel uploads allow 50 MiB, unlike Python's 25 MiB speech limit; clients use `AI_SERVICE_URL` and `CLOUDINARY__*`.
- Mock audio/model/cloud/AI calls for verification; `README.md` contains historical manual probes, not current endpoint discovery.
