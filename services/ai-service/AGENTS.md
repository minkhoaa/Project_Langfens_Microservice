# AI service
FastAPI inference for writing/grammar, speaking, embeddings/RAG and ASR; not the autonomous Reading generator.

- `app/main.py`: lifespan/router wiring; `app/config.py`: settings; `app/schemas/` and router-local models define Pydantic boundaries.
- `app/routers/` handles APIs; `app/services/` owns inference/retrieval; `app/prompts/` owns templates.
- LLM judge calls use `llm_service.generate()` → `groq_service`; preserve configured Groq/MiniMax routing, key rotation, cooldowns and cost guardrails (`app/core/`).
- Ollama BGE-M3 supplies embeddings; speaking roleplay's direct Ollama chat and local Qwen/LoRA grading are separate paths, not judge fallbacks.
- Qdrant collections must match the configured embedding model/dimensions (BGE-M3 default 1024); reuse `qdrant_factory` and existing Redis cache keys/invalidation.
- Keep explicit provider/search failure semantics; never fabricate successful scores or retrieval results.
- Use Pydantic v2 boundaries, async I/O and thread offloading for blocking inference; preserve the speech-evaluate 25 MiB input limit.
- From this directory in its existing venv: `python -m pytest -m "not live"`.
- `tests/e2e/` live tests can run whenever the stack is reachable even without `--run-live`; that flag bypasses reachability skipping, not an opt-in gate.
- `tests/conftest.py` can stub absent ML dependencies: passing tests do not establish real inference or model/container availability.
- Startup may ingest data into empty Qdrant collections; `DISABLE_INGESTION_ON_STARTUP` controls this. Do not start the service merely to validate documentation.
- Detailed cross-service grading flows: `../../docs/AI_ARCHITECTURE_AND_FLOWS.md` (verify current behavior against source).
