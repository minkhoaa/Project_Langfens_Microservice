# 15 — ai-service (Python FastAPI)

> Source-of-truth: `services/ai-service/*`. Verified by direct reads.

## Role in the system

Centralized AI inference for Langfens:

- **LLM judge** for writing / speaking / grammar / roleplay — multi-provider (Groq + MiniMax), multi-key rotation, JSON extraction.
- **Embeddings** via Ollama BGE-M3 (1024-dim).
- **Vector RAG** over Qdrant collections (`writing_samples`, `grammar_knowledge`, `reading_samples`, `listening_samples`, `speaking_memory`).
- **Roleplay speaking practice** with sessions, scenarios, and Qwen2.5-LoRA adapter.
- **Speech evaluation** via faster-whisper (transcribe + WER-style scoring).
- **Reading/Listening per-item explainers** returning `RagFeedbackEnvelope`.
- **AutoGen** question JSON generation (server-side proxy to Groq).
- **Ingestion** of seed corpora into Qdrant on startup (idempotent; skip if collections populated).
- **Redis** response cache for embedding-vector queries.

## Stack

- Python 3.12, FastAPI, Uvicorn, Pydantic v2 (`pydantic-settings`).
- OpenAI client (against Groq + MiniMax OpenAI-compatible endpoints).
- `qdrant-client` (sync; `qdrant_factory.get_qdrant_client()`).
- `redis` (sync; `cache_service`).
- `faster-whisper` for STT.
- `requests` for Ollama embedding REST.

## Entrypoint

`app/main.py`:

```python
app = FastAPI(title="Langfens AI Service", version="1.0.0", lifespan=lifespan)

class RequestLoggingMiddleware(BaseHTTPMiddleware): ...
app.add_middleware(RateLimitMiddleware)         # from app.middleware.rate_limit
app.add_middleware(RequestLoggingMiddleware)
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

app.include_router(health.router,           prefix="/api")
app.include_router(embed.router,            prefix="/api")
app.include_router(writing.router,          prefix="/api")
app.include_router(grammar.router,          prefix="/api")
app.include_router(speaking.router,         prefix="/api")
app.include_router(practice.router,         prefix="/api")
app.include_router(speech_eval.router,      prefix="/api")
app.include_router(speaking_grade.router,   prefix="/api")
app.include_router(autogen.router,          prefix="/api")
app.include_router(reading.router,          prefix="/api")
app.include_router(listening.router,        prefix="/api")
```

Lifespan: background ingestion + (optional) Qwen2.5-LoRA pre-warm.

## Routers (concrete paths)

| Path prefix | File | Endpoints |
|---|---|---|
| `/api/healthz`, `/api/llm-keys-status`, `/api/llm-status` | `health.py` | liveness + LLM runtime status |
| `/api/v1/embed` | `embed.py` | `POST /embed` |
| `/api/v1/writing/{search,compare,grade}` | `writing.py` | RAG search / essay compare / grade |
| `/api/v1/grammar/{search,explain,batch-explain,detect}` | `grammar.py` | RAG search / explain single / batch / detect |
| `/api/v1/speaking/roleplay/{scenarios,start,turn,turn-with-speech,turn-local,turn-audio}` | `speaking.py` | scenarios / session lifecycle / text turn / audio turn |
| `/api/v1/speaking/grade` | `speaking_grade.py` | speaking grading LLM judge |
| `/api/v1/speech/evaluate` | `speech_eval.py` | audio upload, Whisper STT, scoring |
| `/api/v1/reading/explain-item` | `reading.py` | returns `RagFeedbackEnvelope` |
| `/api/v1/listening/explain-item` | `listening.py` | returns `RagFeedbackEnvelope` |
| `/api/v1/autogen/questions` | `autogen.py` | server-side question JSON generation via Groq |
| `/api/practice/...` | `practice.py` | dev practice endpoints |

## LLM layer

- `services/llm_service.py` — thin facade `generate(prompt_template, variables, expect_json=False)` → delegates to `services/groq_service.groq_generate(...)`.
- `services/groq_service.py` — `KeyManager` (multi-key rotation, 60s cooldown on HTTP 429), Groq + MiniMax provider registry; default model `openai/gpt-oss-20b` (Groq), `MiniMax-Text-01` (MiniMax); default provider order `minimax,groq`.
- Provider order is configurable via `LLM_PROVIDER_ORDER` env var (comma-separated).
- All LLM-judge calls flow through `llm_service.generate(...)`.
- Legacy envs (`GEMINI_*`, `MINIMAX_*` legacy, `CEREBRAS_*`) are kept in `config.py` for backward compatibility but not used by the LLM-judge path.

## Embeddings

- `services/embedding_service.py` — `embed_query(text)` POSTs `${OLLAMA_BASE_URL}/api/embeddings` with `model=bge-m3`, `options={"num_gpu": 0}` (forced CPU due to NaN-on-CUDA bug).
- `EMBEDDING_DIM = settings.ollama_embed_dimensions` (default 1024).
- `_MAX_EMBED_CHARS = 4000`.

## Vector search (Qdrant)

- `services/qdrant_factory.py` — singleton `QdrantClient` (host/port or endpoint + api key).
- `services/search_service.py` — `search()`, `search_and_reassemble()`, `build_reference_excerpts()`.
- `services/cache_service.py` — Redis-cached query results, key = SHA256 of `{first 32 dims, top_k, filters}`. TTL default 3600s; graceful degradation if Redis unavailable.

Collections:

| Name | Purpose | Loader |
|---|---|---|
| `writing_samples` | IELTS essay exemplars for grading RAG | ingestion_service |
| `grammar_knowledge` | Grammar rules + explanations | ingestion_service |
| `reading_samples` | Reading items + evidence | ingestion_service |
| `listening_samples` | Listening items + evidence | ingestion_service |
| `speaking_memory` | Long-term roleplay memory | roleplay/speaking services |

## Grading services

`services/grade_service.py`:

- `grade_writing(req)` — RAG over `writing_samples`, build reference excerpts, prompt LLM (via `llm_service.generate(expect_json=True)`), parse JSON, return `WritingGradeResponse`.
- `grade_speaking(req)` — LLM judge (no RAG), returns `SpeakingGradeResponseSchema`.
- Internal helpers: `_estimate_band_from_word_count`, `_length_floor`, `_grammar_error_density`, `_ERROR_PATTERNS` regex.

`services/compare_service.py` — `compare_essay(req)` for essay-vs-reference.

`services/grammar_service.py` — `explain_single`, `explain_batch`, `detect`.

## Roleplay / Speaking LoRA

- `services/qwen_service.py` — local Qwen2.5-1.5B-Instruct + LoRA at `/app/models/qwen25-lora`. Device auto-detect (cuda→cpu fallback). Lazy `asyncio.Lock` for loading. `load_qwen_model()` pre-warms at lifespan if `USE_LOCAL_LORA=true`.
- `services/ollama_service.py` — Ollama chat for roleplay (independent path).
- `services/roleplay_chat_service.py` — multi-turn roleplay (Gemini fallback legacy).
- `services/roleplay_scenario_service.py` — loads scenarios from `DATA_DIR/scenarios`.
- `services/roleplay_session_service.py` — in-memory session state.
- `services/speaking_memory_service.py` — Qdrant write/read for `speaking_memory`.
- `services/per_criterion_rag.py` — per-criterion RAG hint enrichment.
- `services/pronunciation_scorer.py` — local Wav2Vec2 fine-tuned model.

## Speech evaluation

`services/speech_eval_service.py` — `transcribe_audio(audio_bytes)` (faster-whisper), `compare_text()`, `compute_score()`. 25 MB hard limit (`_MAX_AUDIO_BYTES`).

## AutoGen

`routers/autogen.py` proxies question generation to Groq server-side:

- Inputs: `{type, passage, count, difficulty, extra_context?}`.
- Resolves JSON shape + constraints from `app.prompts.autogen_data.{get_json_shape, get_constraints}`.
- Builds system + user prompt via `app.prompts.autogen.{build_system_prompt, build_user_prompt}`.
- Calls `groq_service.groq_generate` with `expect_json=True`, returns `AutogenQuestionsResponse`.
- Defensive normalizer `_normalize_questions(result)` handles LLM output as list or wrapped dict.

## Config (`app/config.py`)

Pydantic Settings with `extra=ignore`. Notable fields:

| Field | Default | Notes |
|---|---|---|
| `qdrant_host/port/grpc_port/endpoint/api_key` | localhost / 6333 / 6334 / "" / "" | either host or endpoint |
| `qdrant_collection_writing/grammar/speaking_memory/reading/listening` | `writing_samples`/`grammar_knowledge`/`speaking_memory`/`reading_samples`/`listening_samples` | |
| `redis_host/port/password/ssl` | localhost / 6379 / "" / False | |
| `data_dir/roleplay_scenarios_dir` | `/app/data`/`/app/data/scenarios` | |
| `force_reingest/disable_ingestion_on_startup` | False / False | |
| `ollama_base_url/embed_model/embed_dimensions/timeout` | `http://ollama:11434`/`bge-m3`/1024/60 | |
| `groq_base_url/model` | `https://api.groq.com/openai/v1`/`openai/gpt-oss-20b` | |
| `minimax_base_url/model/api_key/api_keys` | `https://api.minimaxi.chat/v1`/`MiniMax-Text-01`/`""`/`""` | multi-key rotation |
| `llm_provider_order` | `minimax,groq` | |
| `use_local_lora/lora_model_path/lora_base_model/lora_device` | False / `/app/models/qwen25-lora` / `Qwen/Qwen2.5-1.5B-Instruct` / `cuda` | |
| `lora_load_in_4bit/max_new_tokens/temperature/top_p/repetition_penalty` | False / 200 / 0.7 / 0.9 / 1.1 | |
| `pronunciation_scorer_path/device` | `/app/models/pronunciation-scorer-v2/best_checkpoint.pt` / `cpu` | |
| `gemini_*` legacy fields | various | retained for non-judge speaking code; slated for removal |

Env file resolution: `AI_SERVICE_ENV_FILE` → `<repo>/deploy/envs/ai.env` → empty (Docker injects).

## Ingestion

`services/ingestion_service.py` — `run_ingestion()` runs on lifespan (skipped if `PYTEST_CURRENT_TEST`, `disable_ingestion_on_startup`, or during pytest):

- For each collection in `COLLECTIONS` dict (writing/grammar/reading/listening), ensures collection + payload indexes; ingests from `DATA_DIR/<file>.jsonl` in `BATCH_SIZE=100` batches with `SLEEP_BETWEEN_BATCHES=0.1`.

## Endpoints consumed by .NET services

- `writing-service` → `/api/v1/writing/grade`, `/api/v1/writing/compare`
- `speaking-service` → `/api/v1/speaking/grade` (also `/api/v1/speech/evaluate` if used)
- `attempt-service` → `/api/v1/reading/explain-item`, `/api/v1/listening/explain-item`
- `exam-service` → does **not** call ai-service for reading-paper generation. Reading-paper generation is handled by `exam-service.ReadingPaperAiClient` whose BaseAddress is `GENERATION_SERVICE_URL ?? AI_SERVICE_URL ?? "http://generation-service:8080"` (verbatim from `services/exam-service/Program.cs:51-55`). Under AppHost the resolution is generation-service (AppHost sets `GENERATION_SERVICE_URL` explicitly); the literal final fallback matches the compose service name; the `AI_SERVICE_URL` fallback would resolve to ai-service (which does NOT expose the `/api/v1/autogen/reading-paper/section` route) and would 404.
- `/api/v1/autogen/questions` (ai-service) → **not** called by any .NET service in this repo. The Next.js admin panel **may** reach it via YARP route `ai-autogen-admin` (`/api-ai/v1/autogen/{**catch-all}`, `AuthorizationPolicy=Admin`) when `langfens-fe-app/src/app/admin/_lib/aiConfig.ts:42-49` falls through `NEXT_PUBLIC_AI_SERVICE_URL \|\| NEXT_PUBLIC_AI_ENDPOINT \|\| NEXT_PUBLIC_GATEWAY_URL + "/api-ai"` to the gateway default — note **JavaScript logical OR**, not TypeScript `??`, so an empty-string env var also falls through. Either of the first two env vars **overrides the default base**; `cfg.endpoint` is then treated as an arbitrary base URL by `callAi` (`aiConfig.ts:55-58`), and the **override's value** determines the actual target (ai-service, a different proxy, etc.) — not a guaranteed bypass to ai-service. The code path is exercised in the FE source, but runtime traffic shape depends on the env at FE startup — YARP is the **default-config** path. The `Depends(get_current_user)` dep inside the router is commented out (`// TODO: wire JWT auth in Phase 5 follow-up`); when traffic flows through YARP, admin gating is enforced by the route's `AuthorizationPolicy=Admin`. Rate-limit middleware caps the route at 5 req/min.
- `gateway` routes via `ai-cluster` (10-minute timeout).

## Health checks

- `GET /api/healthz` returns `{status, qdrant, llm}`.
- `GET /api/llm-status` returns runtime LLM key status (active providers, available keys).
- `GET /api/llm-keys-status` is the legacy alias.
