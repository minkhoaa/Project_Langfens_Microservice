# Speaking service
Owns submissions/audio; Whisper.net transcribes locally and ai-service grades over HTTP.

- `Features/RabbitMq/SpeakingGradingConsumer.cs` downloads audio, transcribes, calls `ISpeakingGrader` and publishes a correlated attempt response; Python is not this queue's consumer.
- Startup may download Whisper weights; runtime fallback is CUDA → CPU → CPU-no-AVX.
- `Features/Services/User/CloudinaryService.cs` owns storage; preserve stream disposal/cancellation and WebSocket routes.
- Kestrel upload limit is 50 MiB, distinct from Python's 25 MiB speech limit; settings use `AI_SERVICE_URL` and `CLOUDINARY__*`.
- No dedicated tests; mock audio/model/cloud/AI calls. `README.md` has manual probes, not endpoint discovery.
