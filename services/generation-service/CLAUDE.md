# Generation Service — Claude Code Setup

## Service Purpose

Autonomous IELTS Reading paper generation microservice for Langfens.
Handles:
- **Passage Synthesis** — source-grounded academic reading passages (720–915 words)
- **Source Audit & Revision** — fact-checking against source text with fail-closed revision loop
- **Question Generation** — 6 canonical IELTS Academic Reading question types (MCQ, TFNG, YNNG, Sentence Completion, Summary Completion, Short Answer)
- **Independent Answer Review** — adversarial verification and surgical replacement of flawed items
- **Multi-format Ingestion** — PMC, URL, HTML, Markdown, and Plain Text with SSRF protection and boilerplate removal
- **Streaming NDJSON** — real-time token/paragraph logging directly to `exam-service` jobs

**Port:** 8080 (Compose: 8095; Aspire: dynamic)
**Stack:** Python 3.12, FastAPI, Uvicorn, HTTPX, OpenAI client, Pydantic

## Key Files

```text
services/generation-service/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI app, CORS, lifespan, healthz
│   ├── config.py            # Pydantic Settings (MINIMAX_*, GROQ_*, etc.)
│   ├── router.py            # APIRouter prefix="/v1/autogen/reading-paper"
│   ├── extractor.py         # Smart HTML article body cleaner & multi-format ingestion
│   ├── llm.py               # Dedicated streaming LLM client (MiniMax-Text-01 + Groq rotation)
│   ├── prompts.py           # IELTS Reading prompt templates & rubrics
│   └── pipeline.py          # 4-phase generation pipeline (Synthesis -> Audit -> Revision -> Questions -> Review)
├── tests/
│   ├── __init__.py
│   ├── test_extractor.py    # Unit tests for source cleaning and parsing
│   ├── test_prompts.py      # Unit tests for prompt constraints
│   └── test_pipeline.py     # End-to-end pipeline mocking tests
├── Dockerfile               # Python 3.12-slim lightweight container
├── requirements.txt         # fastapi, uvicorn, pydantic, httpx, openai, pytest
├── pytest.ini
└── CLAUDE.md
```

## API Endpoints

All endpoints are mounted with prefix `/v1/autogen/reading-paper` and `/api/v1/autogen/reading-paper`:
- `GET /sources?topic=...` — OpenAlex + Europe PMC candidate search
- `POST /source` — Fetch Europe PMC full text by PMCID
- `POST /source/ingest` — Ingest URL, HTML, Markdown, or text (minimum 600 words)
- `POST /section` — Generate reading section (supports `Accept: application/x-ndjson` streaming)
- `GET /healthz` — Service health check

## Running Tests

```bash
cd services/generation-service
pytest tests/
```

## Versioned Runtime Caps (R03 / G06)

- `deploy/envs/loop-caps.env` is the production resource-cap declaration shared by generation-service and exam-service. Compose requires it for both services; AppHost loads it via `WithComposeEnvFile("loop-caps")`. Do not duplicate resource caps in `ai.env`.
- Settings loads the repository cap profile, then the explicit `GENERATION_SERVICE_ENV_FILE` (or `AI_SERVICE_ENV_FILE`) override; process environment overrides dotenv values. Production requires every resource cap and explicit profile version/source; missing values never use development class defaults.
- Cap counts, token/byte limits and seconds use positive 32-bit integers, matching .NET configuration admission. Fractional/nonfinite values and inconsistent child/parent allocations are rejected. `READING_PAPER_*` allocation variables map explicitly to their Python Settings fields.
- `LoopPolicy.from_settings()` carries the effective cap profile into loop composition. Passage generation selects its declared passage reservation; question composition must not override the declared 60,000-token / 300-second child limits.
- New .NET runs persist profile JSON/version/source/SHA-256 and budget ceilings. Profile JSON uses sorted keys and canonical UTF-8 on both runtimes. Before the first loop cursor, Python takes the run's original cap profile, not a changed deployment profile. Saved cursors preserve the full loop policy and counters; new configuration affects only new runs. Missing/corrupt historical snapshots require pause/migration, never reconstruction from current environment.
- Runtime tests include `tests/test_r03_config_caps.py`, `tests/test_r03_runtime_caps.py` and `tests/test_t06_loop_runtime.py`. Local simulation and real-PostgreSQL diagnostics do not certify live model quality or promote G06.
