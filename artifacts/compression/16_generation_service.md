# 16 — generation-service (Python FastAPI)

> Source-of-truth: `services/generation-service/*`. Verified by direct reads.

## Role in the system

Autonomous **IELTS Academic Reading paper generation** microservice. Driven by `exam-service`'s durable `ReadingPaperJob` rows through `ReadingPaperAiClient`.

## Stack

- Python 3.12, FastAPI, Uvicorn, Pydantic v2, HTTPX, OpenAI client.
- External integrations: OpenAlex + Europe PMC (source candidates), MiniMax + Groq (LLM judges).

## Entrypoint

`app/main.py` mounts the router twice (with and without `/api` prefix) for compatibility:

```python
app.include_router(reading_paper_router, prefix="/api")
app.include_router(reading_paper_router)
```

`/healthz` and `/api/healthz` return `{status: ok, service: generation-service}`.

## Router (`app/router.py`)

All routes under `/v1/autogen/reading-paper`:

| Method | Path | Body | Notes |
|---|---|---|---|
| GET | `/v1/autogen/reading-paper/sources?topic=...` | — | OpenAlex + Europe PMC candidate search |
| POST | `/v1/autogen/reading-paper/source` | `{pmcid}` | Fetch Europe PMC full text by PMCID |
| POST | `/v1/autogen/reading-paper/source/ingest` | `{payload, license?}` | Ingest URL / HTML / Markdown / Plain Text (min 600 words) |
| POST | `/v1/autogen/reading-paper/section` | `{topic, index, source}` | Generate section; supports `Accept: application/x-ndjson` streaming |

## Pipeline (`app/pipeline.py`)

The pipeline is explicitly documented as a **four-phase** autonomous pipeline (verbatim from the module docstring `services/generation-service/app/pipeline.py:1-6`):

1. **Passage Synthesis** (720–915 words) with bounded extension.
2. **Source-Fidelity Audit & Targeted Revision** (fail-closed, max 2 rounds).
3. **Question Group Generation** (defensive extraction).
4. **Independent Answer Review & Surgical Replacement**.

These correspond to the `# ── Phase N: … ──` section comments at lines 555, 623, 686, 792 of `pipeline.py`. Question types covered: MCQ, TFNG, YNNG, Sentence Completion, Summary Completion, Short Answer.

Key validation utilities:

- `_answer_within_ielts_limit(answer)` — IELTS word-count limit.
- `_answer_occurs_in_passage(answer, passage)` — regex with word boundaries.
- `validate_passage_content(title, passage)` — rejects internal section labels.
- `trim_passage(passage)` — caps at ≤ 900 words.
- `validate_section(data, index)` — enforces section structure.
- `review_passage_source(source_text, passage, progress)` — source-fidelity audit.
- `review_answers(passage, groups, progress)` — adversarial answer verification.
- `replace_rejected_question(...)` — surgical replacement.

Source review and answer review issues sets (`SOURCE_REVIEW_ISSUES`, `QUESTION_REVIEW_ISSUES`) drive structured findings.

## Source ingestion (`app/extractor.py`)

SSRF protection + boilerplate removal. Multi-format: PMC, URL, HTML, Markdown, Plain Text. Min 600 words before pipeline proceeds.

## LLM gateway

`app/llm.py` is a **compatibility facade** delegating to a unified `ProviderGateway`:

- `app/providers/gateway.py` — `ProviderGateway`, `provider_gateway`.
- `app/providers/base.py` — `redact_secrets`.
- `app/providers/models.py` — provider-specific request/response models.
- `app/providers/parser.py` — `clean_reasoning_tags`, `parse_defensive_json`.
- `app/providers/registry.py` — provider registry.
- `app/providers/retry.py` — retry logic.
- `app/providers/adapters/` — provider adapters.

LLM providers: MiniMax (`MiniMax-Text-01`) + Groq (`openai/gpt-oss-20b`). Default order `minimax,groq`.

## Persistence (`app/persistence/`)

- `app/persistence/client.py` — `CheckpointClient` (calls back to `exam-service` checkpoints).
- `app/persistence/models.py` — DB models.

`app/llm.py` records deletion inventory to `DELETION_INVENTORY_PATH` (legacy).

## Config (`app/config.py`)

`Settings` Pydantic:

| Field | Default |
|---|---|
| `environment` | `development` |
| `port` | `8080` |
| `minimax_base_url/model/api_key/api_keys` | `https://api.minimaxi.chat/v1` / `MiniMax-Text-01` / `""` / `""` |
| `groq_base_url/model/api_key/api_keys` | `https://api.groq.com/openai/v1` / `openai/gpt-oss-20b` / `""` / `""` |
| `llm_provider_order` | `minimax,groq` |
| `openalex_api_key` | `""` |

Env file resolution: `GENERATION_SERVICE_ENV_FILE` (or `AI_SERVICE_ENV_FILE`) → `<repo>/deploy/envs/ai.env` → empty.

## Routing in gateway

Gateway routes via `generation-cluster` (45-minute timeout). Authorization policy: **Admin only** (`/api-generation/{**catch-all}` has `AuthorizationPolicy: Admin`).

## Interaction with exam-service

`exam-service/Features/ReadingPaper/ReadingPaperAiClient.cs` is an HttpClient that posts to `${GENERATION_SERVICE_URL}/api/v1/autogen/reading-paper/section` with `Accept: application/x-ndjson` for streaming progress. The `ReadingPaperWorker` polls durable `ReadingPaperJob` rows and persists progress to `ReadingPaperJobLog` (per migrations `20260924120000_AddReadingPaperJobs` etc.).
