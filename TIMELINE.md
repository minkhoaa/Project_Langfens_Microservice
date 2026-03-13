# LANGFENS PHASE 2 — PROJECT TIMELINE
### "The Intelligent and Agentic Learning Platform"

**Project:** Langfens — Adaptive AI Tutor (Vector DB + RAG)
**Duration:** 11 weeks
**Start Date:** March 16, 2026
**Hard Deadline:** May 29, 2026 (before June 1)
**Team:**

| Role | Name | Responsibilities |
|------|------|-----------------|
| **Dev A — Backend & AI Lead** | Tu Minh Khoa | AI Service (Python/FastAPI), Qdrant infrastructure, .NET integration, RAG/LangChain, data pipeline, fine-tuning pipeline (all 3 modules), Writing Comparative module, Speaking Roleplay module, Docker, CI/CD |
| **Dev B — Frontend & AI Support** | Nguyen Ba Trong Khoi | UI for all 3 modules, Grammar Explainer backend (small AI module), roleplay scenario authoring, grammar rules content, prompt testing, UX design |

---

## TECH STACK

| Component | Technology | Purpose |
|-----------|-----------|---------|
| AI Service | Python 3.12 / FastAPI | RAG orchestrator for all 3 modules |
| Vector DB | Qdrant v1.13+ | Semantic search (essays, grammar, memory) |
| LLM | Gemini 2.5 Flash Lite (fine-tuned) | All 3 modules — comparative grading, roleplay, grammar explanation |
| Embedding | Gemini text-embedding-004 | 768-dim vectors for all collections |
| Orchestration | LangChain (as library) | Prompt templates, retrievers, output parsers |
| Communication | REST via YARP Gateway | .NET services <-> AI Service |
| Session State | Redis | Active roleplay conversation history |
| Fine-Tuning | Google AI Studio / Vertex AI | Custom model tuning per module |

---

## 3 MODULES

| # | Module | Description | Lead | Priority |
|---|--------|-------------|------|----------|
| M1 | **Writing Comparative Examiner** | Compare student essays against 3 Band 8-9 reference samples from Qdrant using fine-tuned Gemini 2.5 Flash Lite | Minh Khoa | MUST-HAVE |
| M2 | **Speaking Roleplay Agent** | Context-aware conversation with long-term memory, vocabulary tracking, powered by fine-tuned Gemini 2.5 Flash Lite | Minh Khoa | MUST-HAVE |
| M3 | **Grammar Deep Error Explainer** | Explain grammar errors using theory retrieved from Vector DB, powered by fine-tuned Gemini 2.5 Flash Lite | Trong Khoi (backend) + Minh Khoa (mentor) | MUST-HAVE |

---

## DATASET

| Source | Location | Count | Status |
|--------|----------|-------|--------|
| IELTS Essays (with band scores) | `/home/khoa/dataset_ielts/essays_clean/` | 41,146 | Ready |
| Practice Tests | `/home/khoa/dataset_ielts/tests/valid/` | 2,592 | Ready |
| HuggingFace Datasets | `/home/khoa/dataset_ielts/hf_datasets/` | 45+ sets | Ready |
| Grammar Rules | To be authored | Target: 200 | Not started |
| Roleplay Scenarios | To be authored | Target: 20-30 | Not started |

---

## MILESTONES

| ID | Milestone | Deadline | Acceptance Criteria |
|----|-----------|----------|---------------------|
| **MS1** | Infrastructure Ready | Mar 20, 2026 (Week 1) | Qdrant + AI Service running in Docker Compose, accessible via YARP Gateway, health endpoint returns 200 |
| **MS2** | Data Indexed | Apr 3, 2026 (Week 3) | 5,000+ Band 7-9 essays embedded in Qdrant `writing_samples`. 100+ grammar rules in `grammar_knowledge`. Search endpoint returns relevant results |
| **MS3** | Writing Module Complete | Apr 24, 2026 (Week 6) | Student submits essay -> receives comparative analysis (fine-tuned Gemini) with side-by-side "Your sentence vs Band 9.0". Frontend displays results |
| **MS4** | Grammar Module Complete | Apr 24, 2026 (Week 6) | `/grammar/explain` returns relevant theory + examples for detected errors. Frontend displays Error -> Theory -> Examples |
| **MS5** | Speaking Module Complete | May 15, 2026 (Week 9) | Full roleplay flow: select scenario -> multi-turn conversation -> end session with report. Memory persists across sessions |
| **MS6** | Production Ready | May 29, 2026 (Week 11) | All 3 modules pass E2E testing. Load testing completed. Staging deployment verified. Documentation complete |

---

## DEPENDENCIES

```
MS1 (Infrastructure) ─────> MS2 (Data Indexed) ─────> MS3 (Writing)
                                      |                     |
                                      |                     └──> MS4 (Grammar)
                                      |
                                      └─────────────────────> MS5 (Speaking)
                                                                  |
MS3 + MS4 + MS5 ─────────────────────────────────────────────> MS6 (Production)
```

- MS2 depends on MS1 (need Qdrant running to index data)
- MS3 + MS4 depend on MS2 (need indexed data for RAG)
- MS5 depends on MS1 (needs Qdrant for memory, but not essay data)
- MS6 depends on MS3 + MS4 + MS5 (all modules complete)
- Frontend tasks can start in parallel from Week 1 (mockups, component design)
- Fine-tuning runs in parallel — training data preparation starts Week 2, model tuning Weeks 4-6

---

## WEEKLY BREAKDOWN

### PHASE 1: FOUNDATION + DATA (Weeks 1-3)

---

#### Week 1 — Mar 16-20, 2026

| Task | Owner | Dependencies | Deliverable |
|------|-------|-------------|-------------|
| Set up Qdrant container in `deploy/compose.yaml` | Minh Khoa | None | Qdrant running at `:6333` on `backend` network |
| Create AI Service project scaffold: FastAPI app, Dockerfile, `/healthz` endpoint | Minh Khoa | None | `services/ai-service/` with working health check |
| Add YARP gateway route `/api-ai/*` -> AI Service | Minh Khoa | AI Service scaffold | Gateway routes requests to AI Service |
| Implement AI Service config management (env vars, settings) | Minh Khoa | AI Service scaffold | Config for Qdrant URL, Gemini API keys |
| Research UI libraries/patterns for side-by-side text comparison | Trong Khoi | None | UI approach documented |
| Set up frontend project structure for Phase 2 features | Trong Khoi | None | New pages/routes scaffolded |

> **MILESTONE MS1: Infrastructure Ready** — Deadline: Mar 20, 2026

---

#### Week 2 — Mar 23-27, 2026

| Task | Owner | Dependencies | Deliverable |
|------|-------|-------------|-------------|
| Test end-to-end: Frontend -> Gateway -> AI Service -> Qdrant | Minh Khoa | MS1 | Connectivity verified |
| Implement embedding service wrapper (Gemini `text-embedding-004`) | Minh Khoa | Config management | `/api/v1/embed` test endpoint working |
| Build `filter_and_embed.py`: filter Band 7-9 essays from `essays_clean/`, embed into Qdrant | Minh Khoa | MS1 | Script processes 41K essays, upserts filtered ones |
| Create Qdrant collection `writing_samples` with proper schema + HNSW index | Minh Khoa | MS1 | Collection created with metadata filtering support |
| Prepare fine-tuning training data for Writing module (input/output pairs from high-band essays) | Minh Khoa | Dataset available | 500+ training examples in JSONL format |
| Design Writing Comparative results page (Figma/mockup) | Trong Khoi | Research done | Mockup approved by team |
| Build basic reusable comparison component (placeholder data) | Trong Khoi | Mockup | Component renders side-by-side text |

#### Week 3 — Mar 30 - Apr 3, 2026

| Task | Owner | Dependencies | Deliverable |
|------|-------|-------------|-------------|
| Run embedding pipeline: embed 5,000-10,000 Band 7-9 essays into Qdrant | Minh Khoa | Script ready | Qdrant `writing_samples` populated, search verified |
| Implement `/api/v1/writing/search` — similarity search endpoint | Minh Khoa | Collection created | Returns top-K similar essays for a given query |
| Prepare fine-tuning training data for Speaking + Grammar modules | Minh Khoa | Dataset available | Training examples for all 3 modules ready |
| Create Qdrant collection `grammar_knowledge`, embed initial grammar rules | Minh Khoa | Rules authored | Collection searchable |
| Author 100 grammar rules (JSON): common IELTS grammar errors with theory + examples | Trong Khoi | None | `scripts/grammar/grammar_rules/*.json` |
| Build Writing results page layout (tabs: Scores / Comparative / Suggestions) | Trong Khoi | Mockup | Page structure renders with tab navigation |
| Design Grammar Explainer UI mockup | Trong Khoi | None | Mockup: Error -> Theory -> Examples layout |

> **MILESTONE MS2: Data Indexed** — Deadline: Apr 3, 2026

---

### PHASE 2: WRITING + GRAMMAR MODULES (Weeks 4-6)

---

#### Week 4 — Apr 6-10, 2026

| Task | Owner | Dependencies | Deliverable |
|------|-------|-------------|-------------|
| Fine-tune Gemini 2.5 Flash Lite for Writing Comparative module | Minh Khoa | Training data ready | Fine-tuned model deployed and accessible via API |
| Implement `/api/v1/writing/compare` endpoint: embed essay -> retrieve 3 samples -> call fine-tuned Gemini | Minh Khoa | MS2 + model tuned | Endpoint returns structured comparison JSON |
| Design Comparative Agent prompt: vocabulary suggestions, structure analysis, side-by-side | Minh Khoa | Search working | Prompt tested with 10 sample essays |
| Define Pydantic request/response schemas for all writing endpoints | Minh Khoa | None | OpenAPI/Swagger docs auto-generated |
| Integrate real `/writing/search` API into frontend (test with search-only) | Trong Khoi | Search endpoint | Frontend shows similar essays from Qdrant |
| Build "Similar Essays" sidebar component | Trong Khoi | API integration | Shows 3 similar essays with band + snippet |
| Build Grammar Explainer basic component (static layout) | Trong Khoi | Mockup | Component renders Error/Theory/Example sections |

#### Week 5 — Apr 13-17, 2026

| Task | Owner | Dependencies | Deliverable |
|------|-------|-------------|-------------|
| Fine-tune Gemini 2.5 Flash Lite for Grammar Explainer module | Minh Khoa | Training data ready | Fine-tuned grammar model deployed |
| Modify `WritingSubmittedConsumer.cs`: after existing grading, HTTP call to AI Service `/writing/compare` | Minh Khoa | Compare endpoint | Consumer calls AI Service, handles response |
| Add `ComparativeAnalysisJson` column to `WritingEvaluation` entity + EF migration | Minh Khoa | Consumer changes | DB schema updated, migration applied |
| Extend `WritingGradeResponseMessage` with optional comparative data | Minh Khoa | DB changes | Message contract backward-compatible |
| Implement circuit breaker: if AI Service unavailable, return grading without comparison | Minh Khoa | Consumer changes | Graceful degradation tested |
| Build Comparative tab: "Your sentence" vs "Band 9.0 version" table | Trong Khoi | Compare API schema | Side-by-side comparison renders |
| Build vocabulary suggestions component (word replacements from sample essays) | Trong Khoi | Compare API schema | Suggestions displayed with context |

#### Week 6 — Apr 20-24, 2026

| Task | Owner | Dependencies | Deliverable |
|------|-------|-------------|-------------|
| Fine-tune Gemini 2.5 Flash Lite for Speaking Roleplay module | Minh Khoa | Training data ready | Fine-tuned speaking model deployed |
| Integration test: full writing flow (submit -> existing grading -> RAG comparison -> frontend display) | Minh Khoa | All writing changes | E2E flow verified |
| Performance optimization: cache frequent Qdrant queries in Redis | Minh Khoa | Full flow working | Response time < 5s for comparison |
| Code review Grammar Explainer backend (Trong Khoi's implementation) | Minh Khoa | Grammar endpoints done | Quality approved |
| Implement `/api/v1/grammar/explain` endpoint: embed error -> retrieve theory -> fine-tuned Gemini explanation | Trong Khoi | Grammar collection + model tuned | Single error explanation working |
| Implement `/api/v1/grammar/batch-explain`: multiple errors from one evaluation | Trong Khoi | Single explain | Batch processing working |
| Design Grammar Explainer prompt: error identification, theory citation, examples | Trong Khoi | Minh Khoa guidance | Prompt tested with 20 common errors |
| Integrate Grammar API into Grammar Explainer component | Trong Khoi | Grammar endpoints | Component fetches + renders real data |
| Polish Writing Comparative UI + Grammar Explainer UI | Trong Khoi | All components done | Production-quality UI |

> **MILESTONE MS3: Writing Module Complete** — Deadline: Apr 24, 2026
> **MILESTONE MS4: Grammar Module Complete** — Deadline: Apr 24, 2026

---

### PHASE 3: SPEAKING ROLEPLAY MODULE (Weeks 7-9)

---

#### Week 7 — Apr 27 - May 1, 2026

| Task | Owner | Dependencies | Deliverable |
|------|-------|-------------|-------------|
| Implement `/api/v1/speaking/roleplay/start` endpoint: load scenario, query user memory, create session | Minh Khoa | MS1 + model tuned | Session initialization working |
| Implement `/api/v1/speaking/roleplay/turn` endpoint: process transcript, generate response | Minh Khoa | Start endpoint | Agent responds to user utterances |
| Create Qdrant collection `speaking_memory` (user ideas, preferences, past topics) | Minh Khoa | MS1 | Collection created with user_id filtering |
| Set up Redis session state for active conversations | Minh Khoa | Redis available | Session state persists across turns |
| Author 10 roleplay scenarios (JSON): airport, job interview, restaurant, hotel, Part 2 cue cards | Trong Khoi | None | 10 scenario files in `ai-service/app/data/scenarios/` |
| Design Roleplay chat UI mockup | Trong Khoi | None | Mockup: chat interface + scenario selector |
| Cross-browser testing for Writing + Grammar features | Trong Khoi | UI polish | Chrome, Firefox, Safari verified |

#### Week 8 — May 4-8, 2026

| Task | Owner | Dependencies | Deliverable |
|------|-------|-------------|-------------|
| Design roleplay prompt: scenario context + conversation history + target vocabulary + memory | Minh Khoa | Turn endpoint | Agent stays in character, steers toward vocabulary |
| Implement vocabulary tracking: detect target words in user transcripts | Minh Khoa | Turn endpoint | Vocabulary usage tracked per session |
| Implement repeated idea detection: query `speaking_memory` for past mentions | Minh Khoa | Memory collection | Agent recognizes previous mentions |
| Implement `/api/v1/speaking/roleplay/end` endpoint: generate session report | Minh Khoa | Turn endpoint | Report includes vocabulary stats, feedback |
| Implement `/api/v1/speaking/roleplay/scenarios` — list available scenarios | Minh Khoa | Scenarios authored | GET endpoint returns scenario catalog |
| Connect STT flow: audio -> Speaking Service (Whisper) -> transcript -> AI Service roleplay | Minh Khoa | All endpoints | Full voice pipeline working |
| Build Scenario Selector page (grid/list of available scenarios with difficulty) | Trong Khoi | Scenarios list API | User can browse + select scenarios |
| Build Chat interface component (message bubbles, input, send) | Trong Khoi | Mockup | Basic chat UI renders |
| Author 10 more scenarios (total: 20) | Trong Khoi | None | 20 scenario files complete |

#### Week 9 — May 11-15, 2026

| Task | Owner | Dependencies | Deliverable |
|------|-------|-------------|-------------|
| Store session summary in Qdrant `speaking_memory` for long-term recall | Minh Khoa | End endpoint | Memory persists across sessions |
| Integration test: full roleplay flow (select -> start -> 5 turns -> end -> report) | Minh Khoa | All components | E2E verified |
| Test long-term memory: 2 sessions for same user, verify agent recalls past context | Minh Khoa | Memory working | Memory continuity verified |
| Prompt tuning: iterate on roleplay agent quality (natural conversation, stays in character) | Minh Khoa | Full flow working | Agent quality meets standard |
| Integrate Chat UI with roleplay API (start, turn, end) | Trong Khoi | All roleplay APIs | Real conversations in UI |
| Build end-of-session Report UI (vocabulary stats, pronunciation, suggestions) | Trong Khoi | End API | Report page renders all feedback |
| Build audio recording component (if needed beyond existing) | Trong Khoi | STT flow | User can record + send audio |
| Polish Roleplay UI (responsive, smooth transitions, loading states) | Trong Khoi | All integration done | Production-quality UI |

> **MILESTONE MS5: Speaking Module Complete** — Deadline: May 15, 2026

---

### PHASE 4: TESTING, QA & DEPLOYMENT (Weeks 10-11)

---

#### Week 10 — May 18-22, 2026

| Task | Owner | Dependencies | Deliverable |
|------|-------|-------------|-------------|
| E2E testing: all 3 modules with real user scenarios | Minh Khoa | MS3+MS4+MS5 | Test report with pass/fail |
| Fix bugs discovered during E2E testing (backend) | Minh Khoa | Test report | All critical backend bugs fixed |
| Performance optimization: batch embedding, Qdrant query caching, connection pooling | Minh Khoa | Full system running | Response times meet targets |
| Load testing: simulate 50 concurrent users across all modules | Minh Khoa | Bugs fixed | Load test report with metrics |
| Add rate limiting to AI Service endpoints | Minh Khoa | None | Rate limits configured |
| Add structured logging to AI Service (request/response, latency, errors) | Minh Khoa | None | Logs queryable |
| E2E testing from frontend perspective | Trong Khoi | All modules done | Frontend test report |
| Fix UI bugs discovered during testing | Trong Khoi | Test report | All UI bugs fixed |
| Cross-browser testing for Speaking features | Trong Khoi | UI polish | Chrome, Firefox, Safari verified |
| Accessibility review for all new UI features | Trong Khoi | UI finalized | WCAG compliance checked |
| Mobile responsive testing + fixes | Trong Khoi | UI finalized | Mobile UX verified |

#### Week 11 — May 25-29, 2026

| Task | Owner | Dependencies | Deliverable |
|------|-------|-------------|-------------|
| Docker image optimization: multi-stage builds, caching, minimal images | Minh Khoa | None | Image sizes optimized |
| Deploy to staging environment | Minh Khoa | CI/CD ready | Full system running on staging |
| Staging smoke test: all 3 modules | Minh Khoa | Staging deployed | Smoke test pass |
| Security review: API key management, rate limits, input validation | Minh Khoa | Staging running | Security checklist complete |
| Write technical report (architecture, design decisions, evaluation) | Minh Khoa | None | Technical report document |
| Final UI polish based on staging testing | Trong Khoi | Staging deployed | Last UI adjustments |
| Write API documentation (OpenAPI/Swagger for AI Service) | Trong Khoi | APIs finalized | API docs published |
| Write user guide for new features | Trong Khoi | None | User guide document |
| Prepare demo presentation | Both | All complete | Demo ready |

> **MILESTONE MS6: Production Ready** — Deadline: May 29, 2026

---

## FINE-TUNING SCHEDULE

All 3 modules use **Gemini 2.5 Flash Lite** as the base model, fine-tuned with module-specific training data.

| Module | Training Data Prep | Fine-Tuning Start | Model Ready By | Owner |
|--------|-------------------|-------------------|----------------|-------|
| M1 Writing Comparative | Week 2-3 (Mar 23 - Apr 3) | Week 4 (Apr 6) | Apr 10, 2026 | Minh Khoa |
| M3 Grammar Explainer | Week 3 (Mar 30 - Apr 3) | Week 5 (Apr 13) | Apr 17, 2026 | Minh Khoa |
| M2 Speaking Roleplay | Week 3 (Mar 30 - Apr 3) | Week 6 (Apr 20) | Apr 24, 2026 | Minh Khoa |

**Notes:**
- Training data format: JSONL with input/output pairs per module
- Fine-tuning via Google AI Studio or Vertex AI
- Each module gets its own fine-tuned model endpoint
- Minh Khoa owns all fine-tuning; Trong Khoi assists with grammar training data (annotating errors + corrections)

---

## TASK DISTRIBUTION SUMMARY

### Tu Minh Khoa (Backend & AI Lead)
- AI Service scaffold, infrastructure, Docker
- Qdrant setup, data pipeline, embedding scripts
- Fine-tuning pipeline for all 3 models (Gemini 2.5 Flash Lite)
- Writing Comparative module (full backend)
- Speaking Roleplay module (full backend)
- .NET integration (consumers, DB migrations, circuit breaker)
- Code review of Trong Khoi's Grammar backend work
- E2E testing, load testing, deployment

### Nguyen Ba Trong Khoi (Frontend & AI Support)
- All frontend UI (Writing, Speaking, Grammar — 3 modules)
- **Grammar Explainer backend** (`/api/v1/grammar/explain`, `/api/v1/grammar/batch-explain` endpoints)
- Grammar rules authoring (200 rules in JSON)
- Roleplay scenario authoring (20 scenarios in JSON)
- Prompt testing and quality validation (all modules)
- API documentation
- Cross-browser and accessibility testing

---

## STATUS TRACKING

### Module Progress

| Module | Design | Backend API | Fine-Tuning | Data Pipeline | .NET Integration | Frontend UI | Testing | Status |
|--------|--------|-------------|-------------|---------------|------------------|-------------|---------|--------|
| M1 Writing Comparative | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | Not Started |
| M2 Speaking Roleplay | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | Not Started |
| M3 Grammar Explainer | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | Not Started |

### Infrastructure Progress

| Component | Status | Notes |
|-----------|--------|-------|
| Qdrant in Docker Compose | [ ] Not Started | |
| AI Service Scaffold | [ ] Not Started | |
| YARP Gateway Route | [ ] Not Started | |
| Essay Data Embedding | [ ] Not Started | 41,146 essays available |
| Grammar Rules Authoring | [ ] Not Started | Target: 200 rules (Trong Khoi) |
| Roleplay Scenarios | [ ] Not Started | Target: 20 scenarios (Trong Khoi) |
| Fine-Tuning: Writing Model | [ ] Not Started | Gemini 2.5 Flash Lite |
| Fine-Tuning: Grammar Model | [ ] Not Started | Gemini 2.5 Flash Lite |
| Fine-Tuning: Speaking Model | [ ] Not Started | Gemini 2.5 Flash Lite |

### Weekly Status Log

| Week | Dates | Completed | Blockers | Notes |
|------|-------|-----------|----------|-------|
| 1 | Mar 16-20 | | | |
| 2 | Mar 23-27 | | | |
| 3 | Mar 30 - Apr 3 | | | |
| 4 | Apr 6-10 | | | |
| 5 | Apr 13-17 | | | |
| 6 | Apr 20-24 | | | |
| 7 | Apr 27 - May 1 | | | |
| 8 | May 4-8 | | | |
| 9 | May 11-15 | | | |
| 10 | May 18-22 | | | |
| 11 | May 25-29 | | | |

---

## RISK REGISTER

| # | Risk | Probability | Impact | Mitigation | Owner |
|---|------|-------------|--------|------------|-------|
| R1 | RAG comparison adds 5-10s to writing grading | Medium | High | Run async — return basic grading immediately, push comparison later | Minh Khoa |
| R2 | Speaking roleplay latency > 2s | Medium | High | Fine-tuned Gemini 2.5 Flash Lite is optimized for speed; stream responses | Minh Khoa |
| R3 | Some essays have incorrect band scores (crowd-sourced) | Medium | Medium | Filter by `quality_tier = "complete"/"scored"`. Spot-check 50 essays manually | Minh Khoa |
| R4 | AI Service down breaks writing grading | Low | Critical | Circuit breaker — existing grading works independently (additive design) | Minh Khoa |
| R5 | Trong Khoi unfamiliar with AI/RAG for Grammar backend | Medium | Medium | Minh Khoa provides mentorship, code reviews, and starter templates. Grammar module is the simplest AI module | Both |
| R6 | Compressed 11-week timeline tight for 3 modules | High | High | No descoping. If behind: simplify Grammar UI to basic text display first, polish later. Parallel work maximized | Both |
| R7 | Fine-tuning quality insufficient for grading accuracy | Medium | High | Prepare high-quality training data. Iterate with evaluation metrics. Fallback: use base Gemini with prompt engineering | Minh Khoa |
| R8 | Copyright issues with grammar content | Low | Medium | Use freely available sources only (Purdue OWL). Author original content | Trong Khoi |

---

## COST ESTIMATE (Monthly at Scale)

| Item | Unit Cost | Volume (daily) | Monthly |
|------|-----------|----------------|---------|
| Embedding (one-time 10K essays) | Free tier / $0.00 (Gemini API) | One-time | ~$0.00 |
| Gemini 2.5 Flash Lite — writing comparison | ~$0.01/call | 100 submissions | ~$30 |
| Gemini 2.5 Flash Lite — speaking roleplay | ~$0.001/turn | 500 turns | ~$15 |
| Gemini 2.5 Flash Lite — grammar explanation | ~$0.001/call | 200 calls | ~$6 |
| Fine-tuning (one-time, 3 models) | ~$5-10/model | One-time | ~$15-30 |
| Qdrant (self-hosted) | $0 | - | $0 |
| **Total** | | | **~$50-80/month** |
