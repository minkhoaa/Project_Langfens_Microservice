# TASK ASSIGNMENT — TU MINH KHOA
### Dev A — Backend & AI Lead

**Project:** Langfens Phase 2 — Adaptive AI Tutor
**Duration:** March 16 – May 29, 2026 (11 weeks)
**Hard Deadline:** May 29, 2026 (before June 1)

---

## ROLE SUMMARY

- AI Service (Python/FastAPI) — full ownership
- Qdrant Vector DB infrastructure and data pipeline
- Fine-tuning pipeline for all 3 Gemini 2.5 Flash Lite models
- Writing Comparative module — full backend
- Speaking Roleplay module — full backend
- .NET integration (consumers, DB migrations, circuit breaker)
- Code review of Trong Khoi's Grammar Explainer backend
- Docker, CI/CD, deployment, load testing

---

## FINE-TUNING SCHEDULE

| Module | Training Data Prep | Fine-Tuning Start | Model Ready By |
|--------|-------------------|-------------------|----------------|
| M1 Writing Comparative | Week 2-3 (Mar 23 – Apr 3) | Week 4 (Apr 6) | Apr 10, 2026 |
| M3 Grammar Explainer | Week 3 (Mar 30 – Apr 3) | Week 5 (Apr 13) | Apr 17, 2026 |
| M2 Speaking Roleplay | Week 3 (Mar 30 – Apr 3) | Week 6 (Apr 20) | Apr 24, 2026 |

---

## WEEKLY TASKS

### Week 1 — Mar 16–20, 2026

| Task | Dependencies | Deliverable |
|------|-------------|-------------|
| Set up Qdrant container in `deploy/compose.yaml` | None | Qdrant running at `:6333` on `backend` network |
| Create AI Service project scaffold: FastAPI app, Dockerfile, `/healthz` endpoint | None | `services/ai-service/` with working health check |
| Add YARP gateway route `/api-ai/*` -> AI Service | AI Service scaffold | Gateway routes requests to AI Service |
| Implement AI Service config management (env vars, settings) | AI Service scaffold | Config for Qdrant URL, Gemini API keys |

> **MILESTONE MS1: Infrastructure Ready** — Deadline: Mar 20, 2026

### Week 2 — Mar 23–27, 2026

| Task | Dependencies | Deliverable |
|------|-------------|-------------|
| Test end-to-end: Frontend -> Gateway -> AI Service -> Qdrant | MS1 | Connectivity verified |
| Implement embedding service wrapper (Gemini `text-embedding-004`) | Config management | `/api/v1/embed` test endpoint working |
| Build `filter_and_embed.py`: filter Band 7-9 essays from `essays_clean/`, embed into Qdrant | MS1 | Script processes 41K essays, upserts filtered ones |
| Create Qdrant collection `writing_samples` with proper schema + HNSW index | MS1 | Collection created with metadata filtering support |
| Prepare fine-tuning training data for Writing module (input/output pairs from high-band essays) | Dataset available | 500+ training examples in JSONL format |

### Week 3 — Mar 30 – Apr 3, 2026

| Task | Dependencies | Deliverable |
|------|-------------|-------------|
| Run embedding pipeline: embed 5,000-10,000 Band 7-9 essays into Qdrant | Script ready | Qdrant `writing_samples` populated, search verified |
| Implement `/api/v1/writing/search` — similarity search endpoint | Collection created | Returns top-K similar essays for a given query |
| Prepare fine-tuning training data for Speaking + Grammar modules | Dataset available | Training examples for all 3 modules ready |
| Create Qdrant collection `grammar_knowledge`, embed initial grammar rules | Rules authored (Trong Khoi) | Collection searchable |

> **MILESTONE MS2: Data Indexed** — Deadline: Apr 3, 2026

### Week 4 — Apr 6–10, 2026

| Task | Dependencies | Deliverable |
|------|-------------|-------------|
| Fine-tune Gemini 2.5 Flash Lite for Writing Comparative module | Training data ready | Fine-tuned model deployed and accessible via API |
| Implement `/api/v1/writing/compare` endpoint: embed essay -> retrieve 3 samples -> call fine-tuned Gemini | MS2 + model tuned | Endpoint returns structured comparison JSON |
| Design Comparative Agent prompt: vocabulary suggestions, structure analysis, side-by-side | Search working | Prompt tested with 10 sample essays |
| Define Pydantic request/response schemas for all writing endpoints | None | OpenAPI/Swagger docs auto-generated |

### Week 5 — Apr 13–17, 2026

| Task | Dependencies | Deliverable |
|------|-------------|-------------|
| Fine-tune Gemini 2.5 Flash Lite for Grammar Explainer module | Training data ready | Fine-tuned grammar model deployed |
| Modify `WritingSubmittedConsumer.cs`: after existing grading, HTTP call to AI Service `/writing/compare` | Compare endpoint | Consumer calls AI Service, handles response |
| Add `ComparativeAnalysisJson` column to `WritingEvaluation` entity + EF migration | Consumer changes | DB schema updated, migration applied |
| Extend `WritingGradeResponseMessage` with optional comparative data | DB changes | Message contract backward-compatible |
| Implement circuit breaker: if AI Service unavailable, return grading without comparison | Consumer changes | Graceful degradation tested |

### Week 6 — Apr 20–24, 2026

| Task | Dependencies | Deliverable |
|------|-------------|-------------|
| Fine-tune Gemini 2.5 Flash Lite for Speaking Roleplay module | Training data ready | Fine-tuned speaking model deployed |
| Integration test: full writing flow (submit -> existing grading -> RAG comparison -> frontend display) | All writing changes | E2E flow verified |
| Performance optimization: cache frequent Qdrant queries in Redis | Full flow working | Response time < 5s for comparison |
| Code review Grammar Explainer backend (Trong Khoi's implementation) | Grammar endpoints done | Quality approved |

> **MILESTONE MS3: Writing Module Complete** — Deadline: Apr 24, 2026
> **MILESTONE MS4: Grammar Module Complete** — Deadline: Apr 24, 2026

### Week 7 — Apr 27 – May 1, 2026

| Task | Dependencies | Deliverable |
|------|-------------|-------------|
| Implement `/api/v1/speaking/roleplay/start` endpoint: load scenario, query user memory, create session | MS1 + model tuned | Session initialization working |
| Implement `/api/v1/speaking/roleplay/turn` endpoint: process transcript, generate response | Start endpoint | Agent responds to user utterances |
| Create Qdrant collection `speaking_memory` (user ideas, preferences, past topics) | MS1 | Collection created with user_id filtering |
| Set up Redis session state for active conversations | Redis available | Session state persists across turns |

### Week 8 — May 4–8, 2026

| Task | Dependencies | Deliverable |
|------|-------------|-------------|
| Design roleplay prompt: scenario context + conversation history + target vocabulary + memory | Turn endpoint | Agent stays in character, steers toward vocabulary |
| Implement vocabulary tracking: detect target words in user transcripts | Turn endpoint | Vocabulary usage tracked per session |
| Implement repeated idea detection: query `speaking_memory` for past mentions | Memory collection | Agent recognizes previous mentions |
| Implement `/api/v1/speaking/roleplay/end` endpoint: generate session report | Turn endpoint | Report includes vocabulary stats, feedback |
| Implement `/api/v1/speaking/roleplay/scenarios` — list available scenarios | Scenarios authored (Trong Khoi) | GET endpoint returns scenario catalog |
| Connect STT flow: audio -> Speaking Service (Whisper) -> transcript -> AI Service roleplay | All endpoints | Full voice pipeline working |

### Week 9 — May 11–15, 2026

| Task | Dependencies | Deliverable |
|------|-------------|-------------|
| Store session summary in Qdrant `speaking_memory` for long-term recall | End endpoint | Memory persists across sessions |
| Integration test: full roleplay flow (select -> start -> 5 turns -> end -> report) | All components | E2E verified |
| Test long-term memory: 2 sessions for same user, verify agent recalls past context | Memory working | Memory continuity verified |
| Prompt tuning: iterate on roleplay agent quality (natural conversation, stays in character) | Full flow working | Agent quality meets standard |

> **MILESTONE MS5: Speaking Module Complete** — Deadline: May 15, 2026

### Week 10 — May 18–22, 2026

| Task | Dependencies | Deliverable |
|------|-------------|-------------|
| E2E testing: all 3 modules with real user scenarios | MS3+MS4+MS5 | Test report with pass/fail |
| Fix bugs discovered during E2E testing (backend) | Test report | All critical backend bugs fixed |
| Performance optimization: batch embedding, Qdrant query caching, connection pooling | Full system running | Response times meet targets |
| Load testing: simulate 50 concurrent users across all modules | Bugs fixed | Load test report with metrics |
| Add rate limiting to AI Service endpoints | None | Rate limits configured |
| Add structured logging to AI Service (request/response, latency, errors) | None | Logs queryable |

### Week 11 — May 25–29, 2026

| Task | Dependencies | Deliverable |
|------|-------------|-------------|
| Docker image optimization: multi-stage builds, caching, minimal images | None | Image sizes optimized |
| Deploy to staging environment | CI/CD ready | Full system running on staging |
| Staging smoke test: all 3 modules | Staging deployed | Smoke test pass |
| Security review: API key management, rate limits, input validation | Staging running | Security checklist complete |
| Write technical report (architecture, design decisions, evaluation) | None | Technical report document |
| Prepare demo presentation (joint with Trong Khoi) | All complete | Demo ready |

> **MILESTONE MS6: Production Ready** — Deadline: May 29, 2026

---

## MILESTONE OWNERSHIP

| Milestone | Deadline | Primary Owner |
|-----------|----------|---------------|
| MS1 Infrastructure Ready | Mar 20, 2026 | Minh Khoa |
| MS2 Data Indexed | Apr 3, 2026 | Minh Khoa |
| MS3 Writing Module Complete | Apr 24, 2026 | Minh Khoa |
| MS4 Grammar Module Complete | Apr 24, 2026 | Shared (Trong Khoi backend, Minh Khoa review) |
| MS5 Speaking Module Complete | May 15, 2026 | Minh Khoa |
| MS6 Production Ready | May 29, 2026 | Minh Khoa |
