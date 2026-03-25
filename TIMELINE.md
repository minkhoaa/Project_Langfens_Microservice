# LANGFENS PHASE 2 — PROJECT TIMELINE (v2.0 Redesigned)
### "The Intelligent and Agentic Learning Platform"

**Project:** Langfens — Adaptive AI Tutor (Vector DB + RAG)
**Duration:** 11 weeks
**Start Date:** March 16, 2026
**Hard Deadline:** May 29, 2026 (before June 1)
**Spec:** `docs/superpowers/specs/2026-03-18-phase2-redesign-spec.md`
**Plan:** `docs/superpowers/plans/2026-03-18-phase2-redesign.md`

**Team:**

| Role | Name | Responsibilities |
|------|------|-----------------|
| **Full-stack: Writing + Grammar** | Tu Minh Khoa | Writing Comparative module (full-stack), Grammar Explainer module (full-stack), fine-tune Writing + Grammar models, shared infrastructure (Qdrant, AI Service, Docker/CI/CD), code review Speaking |
| **Full-stack: Speaking** | Nguyen Ba Trong Khoi | Speaking Roleplay module (full-stack), fine-tune Speaking model, scenario + grammar rules authoring, API documentation |

---

## TECH STACK

| Component | Technology | Purpose |
|-----------|-----------|---------|
| AI Service | Python 3.12 / FastAPI | RAG orchestrator for all 3 modules |
| Vector DB | Qdrant v1.13+ | Semantic search (essays, grammar, memory) |
| LLM | Gemini 2.5 Flash Lite (fine-tuned x3) | Comparative grading, roleplay, grammar explanation |
| Embedding | Gemini embedding-001 (`models/gemini-embedding-001`) | 768-dim vectors for all collections |
| Orchestration | LangChain (as library) | Prompt templates, retrievers, output parsers |
| Communication | REST via YARP Gateway | .NET services <-> AI Service |
| Session State | Redis 7.4 | Active roleplay conversation history |
| Fine-Tuning | Google AI Studio / Vertex AI | Custom model tuning per module |
| Frontend | Next.js 16, React 19, TypeScript 5 | Web UI |
| Styling | Tailwind CSS 4 + shadcn/ui | Component library |

---

## 3 MODULES

| # | Module | Description | Owner | Priority |
|---|--------|-------------|-------|----------|
| M1 | **Writing Comparative Examiner** | Compare student essays against 3 Band 8-9 reference samples from Qdrant using fine-tuned Gemini | Minh Khoa (full-stack) | MUST-HAVE |
| M2 | **Speaking Roleplay Agent** | Context-aware conversation with long-term memory, vocabulary tracking, powered by fine-tuned Gemini | Trong Khoi (full-stack) | MUST-HAVE |
| M3 | **Grammar Deep Error Explainer** | Explain grammar errors using theory retrieved from Vector DB, powered by fine-tuned Gemini | Minh Khoa (full-stack) | MUST-HAVE |

---

## DATASET

| Source | Location | Count | Status |
|--------|----------|-------|--------|
| IELTS Essays (with band scores) | `/home/khoa/dataset_ielts/essays_clean/` | 41,146 | Ready |
| Practice Tests | `/home/khoa/dataset_ielts/tests/valid/` | 2,592 | Ready |
| HuggingFace Datasets | `/home/khoa/dataset_ielts/hf_datasets/` | 45+ sets | Ready |
| Grammar Pairs (GEC) | `grammar_pairs/processed/` | 5,659 | Ready (coedit + jfleg) |
| Grammar Rule Schema | `scripts/grammar/grammar_rule_schema.json` | 1 | Ready |
| Roleplay Scenarios | `ai-service/app/data/scenarios/` | Target: 20 | Trong Khoi authors |

---

## MILESTONES

| ID | Milestone | Deadline | Owner | Acceptance Criteria |
|----|-----------|----------|-------|---------------------|
| **MS1** | Infrastructure Ready | Mar 20, 2026 (Week 1) | MK | Qdrant + AI Service running in Docker Compose, accessible via YARP Gateway, health endpoint returns 200 |
| **MS2** | Data Indexed | Apr 3, 2026 (Week 3) | MK + TK | 12,000+ Band 7-9 essays in Qdrant. 5,000+ grammar pairs indexed. Search returns relevant results. TK deployed first FastAPI endpoint |
| **MS3** | Writing Module Complete | Apr 24, 2026 (Week 6) | MK | Student submits essay -> comparative analysis with "Your sentence vs Band 9.0". Frontend displays. Circuit breaker works |
| **MS4** | Grammar Module Complete | Apr 24, 2026 (Week 6) | MK | `/grammar/explain` returns theory + examples for errors. Frontend displays Error -> Theory -> Examples. Click-through from Writing works |
| **MS5** | Speaking Module Complete | May 15, 2026 (Week 9) | TK | Full roleplay: select scenario -> multi-turn conversation -> report. Memory persists across sessions. Voice pipeline working |
| **MS6** | Production Ready | May 29, 2026 (Week 11) | Both | All 3 modules pass E2E. Load testing (50 users) done. Staging verified. Documentation complete |

---

## DEPENDENCIES

```
                    +------------------+
                    |  MS1: Infra      |  Week 1 (DONE)
                    |  Qdrant + AI Svc |
                    +--------+---------+
                             |
                    +--------+---------+
                    |  MS2: Data       |  Week 3
                    |  Essays + Grammar|
                    |  indexed         |
                    +--------+---------+
                             |
              +--------------+--------------+
              |                             |
    +---------+----------+       +----------+---------+
    |  MS3: Writing      |       |  MS5: Speaking     |
    |  (MK, Week 6)      |       |  (TK, Week 9)     |
    +---------+----------+       +----------+---------+
              |                             |
    +---------+----------+                  |
    |  MS4: Grammar      |                  |
    |  (MK, Week 6)      |                  |
    +---------+----------+                  |
              |                             |
              +--------------+--------------+
                             |
                    +--------+---------+
                    |  MS6: Production |  Week 11
                    |  Ready           |
                    +------------------+
```

**Cross-team dependencies (minimal):**

| TK blocked by MK | When | Duration |
|-------------------|------|----------|
| AI Service scaffold + embedding service | Week 1 | Done (MK delivered ahead) |
| Knowledge transfer: fine-tuning + AI patterns | Week 2 | 1 session (2-3h) |
| Embedding service for `speaking_memory` | Week 5 | Soft dependency |
| Whisper STT pairing session | Week 7 | 1 session (2h) |
| Quick code review (start + turn) | Week 6 | 1 day |
| Full code review Speaking backend | Week 8 | 2-3 days |

---

## WEEKLY BREAKDOWN

### PHASE 1: FOUNDATION + DATA (Weeks 1-3)

---

#### Week 1 — Mar 16-20, 2026

| Task | Owner | Deliverable |
|------|-------|-------------|
| Set up Qdrant container in `deploy/compose.yaml` | MK | Qdrant v1.13.6 at `:6333` on `backend` network |
| Create AI Service scaffold: FastAPI, Dockerfile, `/healthz` | MK | `services/ai-service/` with working health check |
| Add YARP gateway route `/api-ai/*` -> AI Service | MK | Gateway routes requests to AI Service |
| AI Service config management (env vars, pydantic-settings) | MK | `app/config.py`, `deploy/envs/ai.env` |
| Research UI patterns: side-by-side text comparison | TK | UI approach documented |
| Research UI patterns: chat interface for roleplay | TK | Chat UI approach documented |
| Set up frontend routes for Phase 2 features | TK | New pages/routes scaffolded |

> **MS1: Infrastructure Ready** — Deadline: Mar 20, 2026 | **Status: ✅ DONE (Mar 16)**

---

#### Week 2 — Mar 23-27, 2026

| Task | Owner | Deliverable |
|------|-------|-------------|
| Implement Gemini `text-embedding-004` wrapper | MK | `/api/v1/embed` endpoint working |
| Build `embed_and_upload.py`: embed essays -> Qdrant | MK | Script processes writing_samples.jsonl |
| Create Qdrant collection `writing_samples` (HNSW + metadata) | MK | Collection schema verified |
| Spot-check 50 training examples from `m1_writing.jsonl` | MK | Data quality verified |
| **Knowledge transfer session (2-3h):** Fine-tuning workflow + AI Service patterns | MK -> TK | TK understands Google AI Studio, FastAPI patterns, Qdrant, Gemini |
| Design Writing Comparative results page (mockup) | TK | Mockup approved |
| Design Roleplay chat UI + Scenario Selector (mockup) | TK | Mockup approved |
| Build basic comparison component (placeholder data) | TK | Component renders |

---

#### Week 3 — Mar 30 - Apr 3, 2026

| Task | Owner | Deliverable |
|------|-------|-------------|
| Run embedding pipeline: upload writing_samples -> Qdrant | MK | 12,339 essays indexed, search verified |
| Implement `/api/v1/writing/search` endpoint | MK | Returns top-K similar essays |
| Create Qdrant collection `grammar_knowledge`, embed grammar pairs | MK | 5,659 docs searchable |
| Validate grammar_knowledge.jsonl against grammar_rule_schema.json | TK | Schema compliance verified |
| Author 10 roleplay scenarios (JSON) — batch 1 | TK | 10 scenario files |
| Spot-check 50 training examples from `m2_speaking.jsonl` | TK | Data quality verified |
| **Backend warm-up:** Implement `/api/v1/speaking/roleplay/scenarios` GET endpoint | TK | TK's first FastAPI endpoint, returns scenario catalog |
| Design Grammar Explainer UI mockup | TK | Mockup: Error -> Theory -> Examples |

> **MS2: Data Indexed** — Deadline: Apr 3, 2026

---

### PHASE 2: WRITING + GRAMMAR MODULES (Weeks 4-6)

---

#### Week 4 — Apr 6-10, 2026

| Task | Owner | Deliverable |
|------|-------|-------------|
| **Fine-tune Gemini 2.5 Flash Lite — M1 Writing** | MK | Writing model deployed, quality gate passed |
| Implement `/api/v1/writing/compare` endpoint (embed -> retrieve -> Gemini) | MK | Structured comparison JSON |
| Design Writing Comparative prompt | MK | Prompt tested with 10 essays |
| Scaffold WritingComparativeTab + SimilarEssaysSidebar (placeholder data) | MK | Frontend page renders with mock data |
| **Fine-tune Gemini 2.5 Flash Lite — M2 Speaking** | TK | Speaking model deployed, quality gate passed |
| **Quality gate:** Evaluate Speaking model (10+ turns, JSON >90%) | TK | Quality report |
| Build Chat interface component (message bubbles, input) | TK | Basic chat UI renders |
| Build Scenario Selector page (integrate with real `/scenarios` API) | TK | Scenario browsing with real data |

> **Fine-tuning quality gate:** If model quality insufficient → Week 5 retrain window. Fallback: base Gemini + prompt engineering.

---

#### Week 5 — Apr 13-17, 2026

| Task | Owner | Deliverable |
|------|-------|-------------|
| **Fine-tune Gemini 2.5 Flash Lite — M3 Grammar** | MK | Grammar model deployed |
| Modify `WritingSubmittedConsumer.cs`: call AI Service `/writing/compare` | MK | Consumer calls AI Service after Gemini grading |
| Add `ComparativeAnalysisJson` column + EF migration | MK | DB schema updated |
| Build SentenceComparisonTable (placeholder/test data) | MK | Side-by-side comparison renders |
| Implement circuit breaker for AI Service | MK | Graceful degradation tested |
| Implement `/api/v1/speaking/roleplay/start` endpoint | TK | Session initialization working |
| Implement `/api/v1/speaking/roleplay/turn` endpoint | TK | Agent responds to utterances |
| Create Qdrant collection `speaking_memory` | TK | Collection with user_id filtering |
| Set up Redis session state for conversations | TK | Session persists across turns |
| Build AudioRecorderBar component | TK | Audio recording works |

---

#### Week 6 — Apr 20-24, 2026

| Task | Owner | Deliverable |
|------|-------|-------------|
| Wire WritingComparativeTab + SentenceComparisonTable to real API data | MK | Comparative tab renders real data |
| Build VocabularySuggestions component (real data) | MK | Suggestions displayed |
| Implement `/api/v1/grammar/explain` endpoint | MK | Single error explanation working |
| Implement `/api/v1/grammar/batch-explain` endpoint | MK | Batch processing working |
| Design Grammar Explainer prompt | MK | Prompt tested with 20 errors |
| Build GrammarExplainerCard + GrammarBatchView frontend | MK | Grammar UI renders real data |
| Define Grammar-Writing cross-module UX | MK | Click error -> Grammar Explainer |
| **Quick code review:** TK's Speaking endpoints (start + turn) | MK | Early feedback given |
| Design Speaking roleplay prompt (scenario + history + memory) | TK | Agent stays in character |
| Implement vocabulary tracking in turns | TK | Vocabulary usage tracked |
| Author 10 more scenarios (total: 20) | TK | 20 scenario files complete |

> **MS3: Writing Module Complete** — Deadline: Apr 24, 2026
> **MS4: Grammar Module Complete** — Deadline: Apr 24, 2026

---

### PHASE 3: SPEAKING ROLEPLAY MODULE (Weeks 7-9)

---

#### Week 7 — Apr 27 - May 1, 2026

| Task | Owner | Deliverable |
|------|-------|-------------|
| Integration test: full writing flow E2E | MK | Writing flow verified |
| Performance: cache Qdrant queries in Redis | MK | Writing response < 5s |
| Polish Writing + Grammar frontend | MK | Production-quality UI |
| Assist MK with Writing + Grammar E2E testing | TK | Test scenarios executed |
| Implement repeated idea detection (query speaking_memory) | TK | Agent recognizes past mentions |
| Implement `/api/v1/speaking/roleplay/end` endpoint | TK | Session report generated |
| **Whisper STT pairing session (2h):** MK walks TK through .NET Speaking Service | MK + TK | TK understands cross-service STT flow |
| Connect STT: audio -> Speaking Service (Whisper) -> transcript -> AI Service | TK | Full voice pipeline working |

---

#### Week 8 — May 4-8, 2026

| Task | Owner | Deliverable |
|------|-------|-------------|
| Cross-browser testing Writing + Grammar | MK | Chrome, Firefox, Safari verified |
| Writing + Grammar bug fixes | MK | All critical bugs fixed |
| **Full code review Speaking backend** (all endpoints, prompts, memory) | MK | Quality approved |
| Integrate Chat UI with roleplay API (start, turn, end) | TK | Real conversations in UI |
| Build SessionReportUI (vocabulary stats, errors, suggestions) | TK | Report page renders |
| Store session summary -> Qdrant speaking_memory | TK | Memory persists across sessions |

---

#### Week 9 — May 11-15, 2026

| Task | Owner | Deliverable |
|------|-------|-------------|
| Performance optimization: batch embedding, connection pooling | MK | Response times meet targets |
| Prepare load testing scripts | MK | Scripts ready |
| Integration test: full roleplay flow (select -> 5 turns -> end -> report) | TK | E2E verified |
| Test long-term memory: 2 sessions same user | TK | Memory continuity verified |
| Build MemoryIndicator component | TK | Visual indicator in chat UI |
| Polish Roleplay UI (responsive, transitions, loading states) | TK | Production-quality UI |
| Prompt tuning: roleplay agent quality | TK | Agent quality meets standard |

> **MS5: Speaking Module Complete** — Deadline: May 15, 2026

---

### PHASE 4: TESTING, QA & DEPLOYMENT (Weeks 10-11)

---

#### Week 10 — May 18-22, 2026

| Task | Owner | Deliverable |
|------|-------|-------------|
| E2E testing: Writing + Grammar modules | MK | Test report |
| Load testing: 50 concurrent users | MK | Load test report |
| Rate limiting for AI Service endpoints | MK | Rate limits configured |
| Structured logging (request/response, latency, errors) | MK | Logs queryable |
| E2E testing: Speaking module | TK | Test report |
| Cross-browser testing Speaking | TK | Chrome, Firefox, Safari verified |
| Accessibility review all features | TK | WCAG compliance checked |
| Mobile responsive testing + fixes | TK | Mobile UX verified |

#### Week 11 — May 25-29, 2026

| Task | Owner | Deliverable |
|------|-------|-------------|
| Docker image optimization (multi-stage, caching) | MK | Images optimized |
| Deploy to staging | MK | Full system on staging |
| Staging smoke test: all 3 modules | MK | Smoke test pass |
| Security review: API keys, rate limits, input validation | MK | Security checklist done |
| Write technical report | MK | Technical report document |
| Final UI polish based on staging | TK | Last UI adjustments |
| API documentation (OpenAPI/Swagger) | TK | Docs published |
| Write user guide | TK | User guide document |
| Prepare demo presentation | Both | Demo ready |

> **MS6: Production Ready** — Deadline: May 29, 2026

---

## FINE-TUNING SCHEDULE

| Module | Owner | Training Data | Fine-Tune Start | Model Ready | Quality Gate |
|--------|-------|---------------|-----------------|-------------|--------------|
| M1 Writing | Minh Khoa | 23,961 pairs (ready) | Week 4 (Apr 6) | Apr 10 | 8/10 essays get relevant comparisons |
| M2 Speaking | Trong Khoi | 8,938 pairs (ready) | Week 4 (Apr 6) | Apr 10 | 10+ turns in character, JSON >90% |
| M3 Grammar | Minh Khoa | 5,659 pairs (ready) | Week 5 (Apr 13) | Apr 17 | 20 errors get accurate explanations |

---

## RISK REGISTER

| # | Risk | Prob | Impact | Mitigation | Owner |
|---|------|------|--------|------------|-------|
| R1 | RAG comparison adds 5-10s to writing grading | Med | High | Async — return basic grading immediately, push comparison later | MK |
| R2 | Speaking roleplay latency > 2s | Med | High | Fine-tuned Flash Lite optimized for speed; stream responses | TK |
| R3 | Incorrect band scores in crowd-sourced data | Med | Med | Filter `quality_tier`. Spot-check 50 essays | MK |
| R4 | AI Service down breaks writing grading | Low | Critical | Circuit breaker — existing grading independent | MK |
| R5 | TK unfamiliar with fine-tuning | Med | Med | Week 2 knowledge transfer. Google AI Studio is accessible | MK+TK |
| R6 | Compressed 11-week timeline for 3 modules | High | High | Full-stack ownership reduces blocking | Both |
| R7 | Fine-tuning quality insufficient | Med | High | Quality gate Week 4. Fallback: base Gemini + prompt engineering | Both |
| R8 | TK Speaking backend quality | Med | Med | Two code reviews: quick Week 6, full Week 8 | MK |
| R9 | TK Speaking fine-tuning quality | Med | High | Quality gate Week 4 with explicit criteria | TK+MK |
| R10 | Whisper STT cross-service integration | Med | Med | Pairing session Week 7. Existing Whisper is stable | MK+TK |

---

## COST ESTIMATE

| Item | Unit Cost | Volume (daily) | Monthly |
|------|-----------|----------------|---------|
| Embedding (one-time 18K docs) | Free tier | One-time | ~$0 |
| Gemini Flash Lite — Writing comparison | ~$0.01/call | 100 | ~$30 |
| Gemini Flash Lite — Speaking roleplay | ~$0.001/turn | 500 | ~$15 |
| Gemini Flash Lite — Grammar explanation | ~$0.001/call | 200 | ~$6 |
| Fine-tuning (3 models, one-time) | ~$5-10/model | One-time | ~$15-30 |
| Qdrant (self-hosted) | $0 | - | $0 |
| **Total** | | | **~$50-80/month** |

---

## PHASE 3 PREVIEW — Reading & Listening AI (Post May 29)

**Scope:** Apply "Adaptive AI Tutor" philosophy to Reading and Listening — from "correct/wrong" to AI-powered feedback.

| Module | Description | Approach |
|--------|-------------|----------|
| M4: Reading Error Explainer | AI explains why user chose wrong answer, passage evidence analysis | RAG: embed passage + questions -> retrieve explanation patterns -> Gemini |
| M5: Listening Error Explainer | Similar to Reading but with transcript analysis | RAG: embed transcript segments -> retrieve + explain |
| M6: Strategy Coach | Analyze error patterns across many tests -> suggest strategies | Aggregate user attempt data -> Gemini analysis |

**Timeline:** Will be designed after Phase 2 is complete and stable.

---

## STATUS TRACKING

### Module Progress

| Module | Design | Backend API | Fine-Tuning | Data Pipeline | .NET Integration | Frontend UI | Testing | Status |
|--------|--------|-------------|-------------|---------------|------------------|-------------|---------|--------|
| M1 Writing Comparative | [ ] | [x] | [ ] | [x] | [ ] | [ ] | [ ] | In Progress |
| M2 Speaking Roleplay | [ ] | [x] | [ ] | [x] | [ ] | [ ] | [ ] | In Progress |
| M3 Grammar Explainer | [ ] | [x] | [ ] | [x] | [ ] | [ ] | [ ] | In Progress |

### Infrastructure Progress

| Component | Status | Notes |
|-----------|--------|-------|
| Qdrant in Docker Compose | [x] Done | v1.13.6, port 6333/6334 |
| AI Service Scaffold | [x] Done | FastAPI, /api/healthz |
| YARP Gateway Route | [x] Done | /api-ai/* -> ai-service:8080, timeout 60s |
| Essay Data Embedding | [x] Done | 40,122 essays indexed in cloud Qdrant |
| Grammar Rules (GEC pairs) | [x] Done | 5,659 pairs indexed in cloud Qdrant + schema defined |
| Roleplay Scenarios | [ ] Not Started | Target: 20 scenarios (Trong Khoi) |
| Fine-Tuning: Writing Model | [ ] Not Started | Training data: 23,961 pairs |
| Fine-Tuning: Grammar Model | [ ] Not Started | Training data: 5,659 pairs |
| Fine-Tuning: Speaking Model | [ ] Not Started | Training data: 8,938 pairs |

### Weekly Status Log

| Week | Dates | Completed | Blockers | Notes |
|------|-------|-----------|----------|-------|
| 1 | Mar 16-20 | Qdrant, AI Service scaffold, YARP gateway, full dataset pipeline, embedding service, search endpoints, compare endpoint, ingestion pipeline, scenario service, 40K essays + 5.6K grammar indexed in cloud Qdrant | None | **MS1 DONE** Mar 16. Also completed most of Week 2-4 backend tasks ahead of schedule |
| 2 | Mar 23-27 | BUG-003 fixed (port mismatch), implementing BUG-001, BUG-002, BUG-004 fixes | None | **Week 2 IN PROGRESS**. Critical bugs identified in backend audit (Mar 24). Remaining: spot-check data quality, knowledge transfer session |
| 3 | Mar 30 - Apr 3 | | | |
| 3 | Mar 30 - Apr 3 | | | |
| 4 | Apr 6-10 | | | |
| 5 | Apr 13-17 | | | |
| 6 | Apr 20-24 | | | |
| 7 | Apr 27 - May 1 | | | |
| 8 | May 4-8 | | | |
| 9 | May 11-15 | | | |
| 10 | May 18-22 | | | |
| 11 | May 25-29 | | | |
