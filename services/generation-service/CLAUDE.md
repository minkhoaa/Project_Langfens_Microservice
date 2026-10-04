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
