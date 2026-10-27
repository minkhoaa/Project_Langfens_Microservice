# AI service
FastAPI grading/explanations, embeddings/RAG, roleplay and ASR; routes/lifespan: `app/main.py`, settings: `app/config.py`.

- Use a service-local venv: `python -m pip install -r requirements-dev.txt`; test here with `python -m pytest -m "not live"`.
- Live E2E runs when services are reachable even without `--run-live`; the root test runner does not exclude it.
- Settings auto-load `deploy/envs/ai.env`; use `AI_SERVICE_ENV_FILE` to select isolated test configuration.
- Judges use `llm_service.generate()` → Groq with key rotation/cooldowns; Ollama roleplay and local Qwen/LoRA are separate paths, not judge fallbacks.
- Ollama BGE-M3 defaults to 1024 dimensions; match Qdrant collections, reuse `qdrant_factory` and preserve Redis cache invalidation.
- Keep Pydantic v2 boundaries, nonblocking inference and the 25 MiB speech input limit; never fabricate successful scores/retrieval on failure.
- Startup can ingest Qdrant and prewarm models (`DISABLE_INGESTION_ON_STARTUP` disables that lifespan work); do not start for passive checks. Mocked tests do not prove model availability.
