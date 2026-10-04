# Repository Inventory — Langfens Microservice (Phase 00 Baseline)

**Generated:** 2026-09-30  
**Git Head Commit SHA:** `999dc94f1c68102b1270690b3ba0d7e40117c788`  
**Git Status Hash (Pre-existing Changes):** `57e27a15d0507a0d079de1eba4776913ea58a2898b8a6c7f6bce652f8460afe5`  
**Pre-existing Git Diff Hash (SHA-256):** `d7f40c86feca13917f14792d4ea59a72cea2cfaa1fbece313f0ed20856dbaacd`  

---

## 1. Distinction of Changes: User Pre-existing vs. Phase 00

### 1.1 Pre-existing Uncommitted Changes (User / Previous Session)
As detailed in `HANDOFF_SEPARATE_GENERATION_SERVICE.md`:
- Extraction of reading paper generation out of `services/ai-service` into `services/generation-service`.
- Modified `AppHost/Program.cs`, `deploy/compose.yaml`, `gateway/api-gateway/appsettings.json` to register `generation-service`.
- Added `services/generation-service/` containing `app/` (`main.py`, `config.py`, `router.py`, `extractor.py`, `prompts.py`, `pipeline.py`, `llm.py`) and `tests/` (`test_extractor.py`, `test_prompts.py`, `test_pipeline.py`).
- Added `services/exam-service/Features/ReadingPaper/` (`ReadingPaperEndpoints.cs`, `ReadingPaperWorker.cs`, `ReadingPaperAiClient.cs`, `ReadingPaperModels.cs`).
- Added entity `ReadingPaperJob.cs` and migrations `20260924120000_AddReadingPaperJobs.cs`, `20260925120000_AddReadingPaperJobLogs.cs`.
- Added test project `services/exam-service.Tests/`.
- Modified `services/ai-service/app/services/reading_paper.py` (deleted) and `app/routers/reading_paper.py` (deleted).

### 1.2 Phase 00 Additions (Current Task)
- Refactor discovery documentation & inventories (`docs/refactor/repo-inventory.md`, `artifacts/refactor/phase-00/*`).
- Policy baseline configuration (`policy-baseline.json`).
- Legacy symbol map (`legacy-symbol-map.csv`).
- Contract snapshots and recordings (`contracts/*`).
- Regression test fixtures and offline fake provider test suite (`tests/refactor/phase-00/` or integrated within existing test suites).
- Verification runner script (`scripts/refactor/verify_phase.py`).
- Gate evaluation evidence (`gate.json`, `commands.jsonl`).

---

## 2. Runtime & Dependency Manifests

### 2.1 Services & Languages
| Service | Runtime / Framework | Project / Manifest Path | Test Runner | Status |
|---|---|---|---|---|
| `exam-service` | .NET 10 (C# 13) | `services/exam-service/exam-service.csproj` | `dotnet test` (`services/exam-service.Tests`) | Active |
| `generation-service` | Python 3.12+ (FastAPI, httpx, uvicorn, pydantic) | `services/generation-service/requirements.txt` | `pytest` (`services/generation-service/.venv`) | Active (72 passed unit tests) |
| `attempt-service` | .NET 10 (C# 13) | `services/attempt-service/attempt-service.csproj` | `dotnet test` (`services/attempt-service.Tests`) | Active (73 passed tests) |
| `ai-service` | Python 3.12+ (FastAPI, PyTorch, Whisper, Qdrant) | `services/ai-service/requirements.txt` | `pytest` (`services/ai-service/.venv`) | Active (writing/speaking only) |
| `api-gateway` | .NET 10 (YARP) | `gateway/api-gateway/api-gateway.csproj` | Integration | Active |
| `admin-frontend` | Next.js 14+ (TypeScript, React) | `/home/khoa/Projects/langfens/langfens-fe-app` | `npm run test` / `npm run dev` | External project |

### 2.2 Standard Build & Test Commands
- **Exam Service build & tests:**
  ```bash
  dotnet build services/exam-service/exam-service.csproj
  dotnet test services/exam-service.Tests/exam-service.Tests.csproj
  ```
- **Generation Service tests:**
  ```bash
  ./services/generation-service/.venv/bin/pytest services/generation-service/tests
  ```
- **Attempt Service tests:**
  ```bash
  dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj
  ```
- **AppHost Local Dev:**
  ```bash
  dotnet run --project AppHost/AppHost.csproj
  ```

---

## 3. Real Paths & Symbol Traceability

### 3.1 `generation-service`
- **Main App & Lifespan:** `services/generation-service/app/main.py`
  - Routes: `/healthz` (anonymous), mounts router with prefix `/v1/autogen/reading-paper`
- **Router:** `services/generation-service/app/router.py`
  - Endpoints:
    1. `GET /v1/autogen/reading-paper/sources` (`sources`)
    2. `POST /v1/autogen/reading-paper/source` (`source`)
    3. `POST /v1/autogen/reading-paper/source/ingest` (`ingest`)
    4. `POST /v1/autogen/reading-paper/section` (`section`, streaming `_stream_section`)
- **Ingestion & Extraction:** `services/generation-service/app/extractor.py`
  - Symbols: `clean_html`, `SemanticHTMLCleaner`, `clean_markdown`, `clean_plain_text`, `is_safe_url`, `fetch_web_url`, `detect_source_type`, `ingest_source`, `fetch_source`, `search_sources`, `parse_full_text`, `source_excerpt`
- **Pipeline Execution:** `services/generation-service/app/pipeline.py`
  - Symbols: `generate_section`, `_generate_section_once`, `generate_json`, `extend_passage`, `trim_passage`, `validate_passage_content`, `review_passage_source`, `validate_group_candidate`, `repair_evidence`, `validate_section`, `review_answers`, `replace_rejected_question`
- **LLM Gateway:** `services/generation-service/app/llm.py`
  - Symbols: `llm_generate`, `_extract_json`, `_clean_thinking`
- **Prompts & Profiles:** `services/generation-service/app/prompts.py`
  - Symbols: `SECTION_PROFILES`, `GROUP_INSTRUCTIONS`, `build_passage_prompt`, `build_passage_extension_prompt`, `build_passage_revision_prompt`, `build_question_prompt`, `build_group_instruction`

### 3.2 `exam-service`
- **Job Endpoints:** `services/exam-service/Features/ReadingPaper/ReadingPaperEndpoints.cs`
  - Mapped route group: `/api/admin/reading-paper` (Authorized: `Admin`)
  - Endpoints:
    - `GET /sources` -> calls `ai.SearchAsync`
    - `POST /sources/ingest` -> calls `ai.IngestSourceAsync`
    - `POST /jobs` -> creates `ReadingPaperJob` (`Status="Pending"` or `"NeedsSources"`)
    - `GET /jobs` -> lists 20 newest jobs
    - `GET /jobs/{id}` -> returns full job view with deserialized sources, sections, logs
    - `PUT /jobs/{id}/sources` -> replaces sources, resets sections, sets `Status="Pending"` or `"NeedsSources"`
    - `POST /jobs/{id}/retry` -> resets failed job to `"Pending"`
- **Worker & Lease Engine:** `services/exam-service/Features/ReadingPaper/ReadingPaperWorker.cs`
  - Class: `ReadingPaperWorker : BackgroundService`
  - Symbols: `ExecuteAsync`, `RunOne`, `Heartbeat`, `Process`, `ConfirmLease`, `BuildExam`, `AppendLogAsync`
- **AI Client:** `services/exam-service/Features/ReadingPaper/ReadingPaperAiClient.cs`
  - Class: `ReadingPaperAiClient`
  - Symbols: `SearchAsync`, `FetchSourceAsync`, `IngestSourceAsync`, `GenerateSectionAsync`, `ReadAsync`
- **Domain Models & Rules:** `services/exam-service/Features/ReadingPaper/ReadingPaperModels.cs`
  - Symbols: `ReadingSource`, `ReadingPaperLog`, `ReadingSearchResult`, `ReadingJobRequest`, `IngestSourceRequest`, `ReadingGeneratedQuestion`, `ReadingGeneratedGroup`, `ReadingGeneratedSection`, `ReadingPaperRules` (`Counts`, `Types`, `WordCount`, `Validate`, `Json`, `Shingles`)
- **Entities & Persistence:**
  - `services/exam-service/Domains/Entities/ReadingPaperJob.cs` (`ReadingPaperJob`)
  - `services/exam-service/Domains/Entities/Exam.cs`, `ExamSection.cs`, `ExamQuestionGroup.cs`, `ExamQuestion.cs`, `ExamOption.cs`
  - `services/exam-service/Infrastructure/Persistence/ExamDbContext.cs`
  - Migrations: `20260924120000_AddReadingPaperJobs.cs`, `20260925120000_AddReadingPaperJobLogs.cs`
- **Admin Exam CRUD & Publishing:**
  - `services/exam-service/Features/Exams/AdminEndpoint/ExamEndpoint/AdminExam_Service.cs`
  - Symbols: `AddAsync` (Status = Draft), `UpdateAsync` (Status = Published), `DeleteAsync`, `ListAllAsync`

### 3.3 Gateway
- `gateway/api-gateway/appsettings.json`:
  - Route `generation-api`: `/api-generation/{**catch-all}` -> `generation-cluster` (`http://generation-service:8080`), transforms `PathRemovePrefix: /api-generation`, `PathPrefix: /api`.
  - Route `exam-cluster`: `/api-exams/{**catch-all}` -> `exam-service`.

### 3.4 Admin Frontend
- Path: `/home/khoa/Projects/langfens/langfens-fe-app/src/app/admin/exams/reading-paper/readingPaperApi.ts`
  - Functions: `searchReadingSources`, `createReadingJob`, `ingestReadingSource`, `getReadingJob`, `listReadingJobs`, `replaceReadingSources`, `retryReadingJob`.
