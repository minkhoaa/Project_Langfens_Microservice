# AI Service — Claude Code Setup

## Service Purpose

AI inference microservice for Langfens. Handles:
- **LLM calls** — Ollama (Qwen2.5), Groq, MiniMax, Gemini
- **Embeddings** — BGE-M3 via Ollama, stored in Qdrant vector DB
- **ASR** — faster-whisper for speech-to-text
- **RAG** — Qdrant-backed retrieval for writing and grammar

**Port:** 8092
**Stack:** Python, FastAPI, LangChain, Redis, Qdrant, faster-whisper

## Key Files

```
app/
├── main.py              # FastAPI app, lifespan, middleware (rate-limit, request logging)
├── config.py            # Pydantic Settings (env vars, Qdrant, Ollama, Redis)
├── schemas.py            # All Pydantic request/response models
├── core/
│   └── cost_guardrails.py
├── prompts/
│   ├── writing_grade.py   # WRITING_GRADE_PROMPT + build_grade_prompt()
│   ├── writing_compare.py
│   ├── grammar_explain.py
│   ├── grammar_detect.py
│   └── speaking_grade.py
├── routers/
│   ├── health.py          # GET /api/healthz, /llm-status
│   ├── embed.py           # POST /api/v1/embed
│   ├── writing.py         # POST /api/v1/writing/{search,compare,grade}
│   ├── grammar.py         # POST /api/v1/grammar/{search,explain,batch-explain,detect}
│   ├── speaking.py        # POST /api/v1/speaking/roleplay/{scenarios,start,turn,turn-with-speech}
│   ├── speaking_grade.py  # POST /api/v1/speaking/grade
│   ├── speech_eval.py      # POST /api/v1/speech/evaluate (file upload)
│   └── practice.py        # /practice endpoints (dev)
└── services/
    ├── cache_service.py       # Redis caching (get_cached, set_cached)
    ├── ingestion_service.py  # Qdrant data ingestion on startup
    ├── groq_service.py        # Groq multi-key LLM service (sole LLM provider)
    ├── llm_service.py         # Thin facade routing to groq_service
    ├── embedding_service.py   # Embedding generation (Ollama BGE-M3)
    ├── search_service.py      # Qdrant vector search
    ├── grade_service.py       # Writing/speaking grading chains
    ├── compare_service.py     # Essay comparison with references
    ├── grammar_service.py     # Grammar explanation & detection
    ├── speech_eval_service.py # faster-whisper transcription + scoring
    ├── ollama_service.py      # Ollama roleplay generation
    ├── roleplay_chat_service.py
    ├── roleplay_session_service.py
    ├── roleplay_scenario_service.py
    ├── qdrant_factory.py      # Qdrant client singleton
    └── speaking_memory_service.py
```

## API Patterns

- All routers are FastAPI `APIRouter` with `prefix` set at router level
- Request/response models use Pydantic `BaseModel`, `Field` for validation
- Async handlers (`async def`) for I/O (LLM calls, Qdrant, Redis)
- Thread pool executor for sync operations (whisper, ingestion)
- Middleware: `RateLimitMiddleware`, `RequestLoggingMiddleware` (adds `X-Request-ID` header)

## AI Integration

- **Groq** (sole LLM): `app/services/groq_service.py` uses the OpenAI-compatible Python SDK
  against `https://api.groq.com/openai/v1`. Multi-key rotation via
  `GROQ_API_KEYS` (comma-separated) with single-key fallback `GROQ_API_KEY`.
  Default model `openai/gpt-oss-20b`. 60s cooldown on HTTP 429.
- **Ollama** (embeddings only): `app/services/embedding_service.py` calls
  `POST /api/embeddings` with `model=bge-m3` (1024 dims) for query-time
  embeddings and ingestion. The Ollama container is still required in
  `deploy/compose.yaml` for this.
- Speaking roleplay (`app/services/ollama_service.py` + `routers/speaking.py`)
  uses Ollama chat directly and is **independent** of the LLM-judge path.
- Speaking grading uses a local Qwen2.5 LoRA (`app/services/qwen_service.py`)
  via `POST /api/v1/speaking/grade`.
- Prompt templates in `app/prompts/` — raw strings with `{variable}` placeholders.
- All LLM-judge calls go through `llm_service.generate()` (a thin facade that
  delegates to `groq_service.groq_generate`).

## Vector Search (Qdrant)

- Collections: `writing_samples`, `grammar_knowledge`, `speaking_memory`
- Embedding dim: `settings.ollama_embed_dimensions` (default 1024 for BGE-M3)
- `search_service.search()` handles Qdrant query + Redis cache lookup
- Cache key: SHA256 of truncated vector (first 32 dims) + top_k + filters
- Data ingestion runs on startup if collections are empty (skip with `PYTEST_CURRENT_TEST`)

## Speech-to-Text (faster-whisper)

- Endpoint: `POST /api/v1/speech/evaluate` — accepts `UploadFile` (audio) + optional `Form` target text
- Pipeline: `transcribe_audio()` → `compare_text()` → `compute_score()`
- Max audio size: 25 MB
- 25MB hard limit enforced before processing

## Redis Caching

- `cache_service.py` provides `get_cached()` / `set_cached()` keyed on embedding vector hash
- TTL: 3600s default
- Graceful degradation: returns `None` if Redis unavailable
- Vector cache key: SHA256 of first 32 dims of query vector + top_k + filters JSON

## Adding a New Endpoint

1. **Define schemas** in `app/schemas.py`:
   ```python
   class MyRequest(BaseModel):
       text: str = Field(..., min_length=1, max_length=500)
   class MyResponse(BaseModel):
       result: str
   ```
2. **Add router** in `app/routers/my_feature.py`:
   ```python
   from fastapi import APIRouter
   router = APIRouter(prefix="/v1/myfeature")
   @router.post("/action", response_model=MyResponse)
   async def do_action(req: MyRequest):
       ...
   ```
3. **Register** in `app/main.py`:
   ```python
   from app.routers import my_feature
   app.include_router(my_feature.router, prefix="/api")
   ```
4. **Add prompt** in `app/prompts/my_prompt.py` if LLM is involved

## Testing Patterns

- Unit tests: `pytest`, `pytest-asyncio`, `unittest.mock.AsyncMock`
- Mock pattern: `patch("module.llm_service.generate", new_callable=AsyncMock, return_value={...})`
- E2E tests in `tests/e2e/` — use `@pytest.mark.live` (skipped unless `--run-live`)
- Config: `pytest.ini` sets `asyncio_mode = auto`

## Environment Variables

```env
# Qdrant
QDRANT_HOST=localhost
QDRANT_PORT=6333
QDRANT_GRPC_PORT=6334
QDRANT_COLLECTION_WRITING=writing_samples
QDRANT_COLLECTION_GRAMMAR=grammar_knowledge

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# Ollama (primary AI)
USE_OLLAMA=true
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=qwen2.5
OLLAMA_EMBED_MODEL=bge-m3
OLLAMA_EMBED_DIMENSIONS=1024
OLLAMA_TEMPERATURE=0.3
OLLAMA_TIMEOUT=120

# Ollama path override (optional)
OLLAMA_EMBED_URL=http://localhost:11434/api/embed

# OpenAI-like providers (Groq/MiniMax fallback)
GROQ_BASE_URL=https://api.groq.com/openai/v1
GROQ_MODEL=openai/gpt-oss-20b
GROQ_API_KEY=...                 # single-key fallback
GROQ_API_KEYS=key1,key2,key3     # multi-key rotation (preferred)

# Legacy envs (no longer read by LLM-judge path; retained for speaking code
# and backward compatibility with other deploy targets):
#   USE_OLLAMA, USE_OPENAI_LIKE, GEMINI_*, MINIMAX_*, CEREBRAS_*

# Data paths
DATA_DIR=/app/data
ROLEPLAY_SCENARIOS_DIR=/app/data/scenarios

# Ingestion control
FORCE_REINGEST=false
DISABLE_INGESTION_ON_STARTUP=false

# Config file override
AI_SERVICE_ENV_FILE=  # absolute path to .env file

# Python
PYTHONDONTWRITEBYTECODE=1
PYTEST_CURRENT_TEST=   # auto-set by pytest
```

## Docker

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8092"]
```

Service starts on port 8092. Ollama must be reachable at `OLLAMA_BASE_URL` for ingestion and LLM calls.