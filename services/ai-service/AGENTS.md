# AI service
FastAPI writing/grammar/speaking inference, embeddings/RAG and ASR; autonomous Reading belongs to generation-service.

- `app/main.py` wires lifespan/routes; `app/config.py` settings, `app/services/` inference and `app/prompts/` templates.
- Judges call `llm_service.generate()` → `groq_service`; preserve Groq/MiniMax routing, key cooldowns and cost guardrails.
- Ollama BGE-M3 embeddings default to 1024 dimensions; Qdrant collections must match. Reuse `qdrant_factory` and Redis cache invalidation.
- Direct Ollama roleplay and local Qwen/LoRA grading are separate paths, not judge fallbacks; never fabricate successful scores/retrieval on failure.
- Keep Pydantic v2 boundaries, async/thread-offloaded inference and the 25 MiB speech input limit.
- Local venv: `python -m pytest -m "not live"`; live E2E can run whenever reachable even without `--run-live`.
- `tests/conftest.py` stubs missing ML dependencies: passing tests do not verify real model availability.
- Startup can ingest empty Qdrant collections (`DISABLE_INGESTION_ON_STARTUP`); do not start it for passive verification.
