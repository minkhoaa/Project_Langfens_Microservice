# TASK ASSIGNMENT — TU MINH KHOA
### Full-stack: Writing Comparative + Grammar Explainer + Shared Infrastructure

**Project:** Langfens Phase 2 — Adaptive AI Tutor
**Duration:** March 16 – May 29, 2026 (11 weeks)
**Hard Deadline:** May 29, 2026 (before June 1)

**Legend:** `✅` Done · `🔄` In Progress · `⬜` Not Started · `🚫` Blocked

---

## ROLE SUMMARY

- **Full-stack M1 Writing Comparative:** Backend AI + .NET integration + frontend UI
- **Full-stack M3 Grammar Explainer:** Backend AI + frontend UI
- **Fine-tuning:** Writing model + Grammar model (2 models)
- **Shared infrastructure:** Qdrant, AI Service scaffold, embedding service, Docker/CI/CD
- **Mentorship:** Knowledge transfer to Trong Khoi (fine-tuning, AI patterns, Whisper STT)
- **Code review:** Speaking Roleplay backend (quick Week 6, full Week 8)

---

## FINE-TUNING SCHEDULE

| Module | Training Data | Fine-Tuning Start | Model Ready By | Quality Gate |
|--------|---------------|-------------------|----------------|--------------|
| M1 Writing Comparative | 23,961 pairs (ready) | Week 4 (Apr 6) | Apr 10, 2026 | 8/10 essays get relevant comparisons |
| M3 Grammar Explainer | 5,659 pairs (ready) | Week 5 (Apr 13) | Apr 17, 2026 | 20 errors get accurate explanations |

---

## WEEKLY TASKS

### Week 1 — Mar 16–20, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ✅ | Set up Qdrant container in `deploy/compose.yaml` | Qdrant v1.13.6 at `:6333/:6334` on `backend` network |
| ✅ | Create AI Service scaffold: FastAPI, Dockerfile, `/healthz` | `services/ai-service/` — health returns `{"status":"ok","qdrant":"ok"}` |
| ✅ | Add YARP gateway route `/api-ai/*` → AI Service | Route + cluster, timeout 60s |
| ✅ | AI Service config management (env vars, pydantic-settings) | `app/config.py`, `deploy/envs/ai.env` |

> **✅ MS1 DONE** — Mar 16 (ahead of Mar 20 deadline)

---

### Week 2 — Mar 23–27, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ⬜ | Implement Gemini `text-embedding-004` wrapper | `/api/v1/embed` endpoint working |
| ⬜ | Build `embed_and_upload.py`: embed essays → Qdrant | Script processes writing_samples.jsonl |
| ⬜ | Create Qdrant collection `writing_samples` (HNSW + metadata) | Collection schema verified |
| ⬜ | Spot-check 50 training examples from `m1_writing.jsonl` | Data quality verified, issues documented |
| ⬜ | **Knowledge transfer session (2-3h):** Fine-tuning + AI Service patterns for TK | TK understands Google AI Studio, FastAPI, Qdrant, Gemini |

---

### Week 3 — Mar 30 – Apr 3, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ⬜ | Run embedding pipeline: upload writing_samples → Qdrant | 12,339 essays indexed, search verified |
| ⬜ | Implement `/api/v1/writing/search` — similarity search endpoint | Returns top-K similar essays |
| ⬜ | Create Qdrant collection `grammar_knowledge`, embed grammar pairs | 5,659 docs searchable |

> **MS2 Deadline** — Apr 3, 2026

---

### Week 4 — Apr 6–10, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ⬜ | **Fine-tune Gemini 2.5 Flash Lite — M1 Writing Comparative** | Model deployed, quality gate passed |
| ⬜ | Implement `/api/v1/writing/compare` endpoint (embed → retrieve → Gemini) | Structured comparison JSON |
| ⬜ | Design Writing Comparative prompt | Prompt tested with 10 essays |
| ⬜ | Scaffold WritingComparativeTab + SimilarEssaysSidebar (placeholder data) | Frontend page renders with mock data |

---

### Week 5 — Apr 13–17, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ⬜ | **Fine-tune Gemini 2.5 Flash Lite — M3 Grammar Explainer** | Grammar model deployed |
| ⬜ | Modify `WritingSubmittedConsumer.cs`: call AI Service `/writing/compare` after Gemini grading | Consumer calls AI Service |
| ⬜ | Add `ComparativeAnalysisJson` column to WritingEvaluation + EF migration | DB schema updated |
| ⬜ | Build SentenceComparisonTable component (placeholder/test data) | Side-by-side comparison renders |
| ⬜ | Implement circuit breaker: AI Service down → return grading only | Graceful degradation tested |

---

### Week 6 — Apr 20–24, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ⬜ | Wire WritingComparativeTab + SentenceComparisonTable to real API data | Comparative tab renders real data |
| ⬜ | Build VocabularySuggestions component (real data) | Suggestions displayed with context |
| ⬜ | Implement `/api/v1/grammar/explain` endpoint | Single error explanation working |
| ⬜ | Implement `/api/v1/grammar/batch-explain` endpoint | Batch processing working |
| ⬜ | Design Grammar Explainer prompt | Prompt tested with 20 errors |
| ⬜ | Build GrammarExplainerCard + GrammarBatchView frontend | Grammar UI renders real data |
| ⬜ | Define Grammar-Writing cross-module UX (click error → Grammar Explainer) | Cross-module navigation working |
| ⬜ | **Quick code review:** TK's Speaking endpoints (start + turn) | Early feedback given |

> **MS3 + MS4 Deadline** — Apr 24, 2026

---

### Week 7 — Apr 27 – May 1, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ⬜ | Integration test: full writing flow E2E | Writing flow verified |
| ⬜ | Performance: cache Qdrant queries in Redis | Writing response < 5s |
| ⬜ | Polish Writing + Grammar frontend | Production-quality UI |
| ⬜ | **Whisper STT pairing session (2h):** Walk TK through .NET Speaking Service | TK understands cross-service STT flow |

---

### Week 8 — May 4–8, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ⬜ | Cross-browser testing Writing + Grammar | Chrome, Firefox, Safari verified |
| ⬜ | Writing + Grammar bug fixes | All critical bugs fixed |
| ⬜ | **Full code review Speaking backend** (all endpoints, prompts, memory) | Quality approved |

---

### Week 9 — May 11–15, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ⬜ | Performance optimization: batch embedding, connection pooling | Response times meet targets |
| ⬜ | Prepare load testing scripts | Scripts ready |

> **MS5 Deadline** — May 15, 2026

---

### Week 10 — May 18–22, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ⬜ | E2E testing: Writing + Grammar modules (10 real scenarios) | Test report |
| ⬜ | Load testing: 50 concurrent users | Load test report |
| ⬜ | Rate limiting for AI Service endpoints | Rate limits configured |
| ⬜ | Structured logging (request/response, latency, errors) | Logs queryable |

---

### Week 11 — May 25–29, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ⬜ | Docker image optimization (multi-stage, caching) | Images optimized |
| ⬜ | Deploy to staging | Full system on staging |
| ⬜ | Staging smoke test: all 3 modules | Smoke test pass |
| ⬜ | Security review: API keys, rate limits, input validation | Security checklist done |
| ⬜ | Write technical report | Technical report document |
| ⬜ | Prepare demo (joint with Trong Khoi) | Demo ready |

> **MS6 Deadline** — May 29, 2026

---

## MILESTONE OWNERSHIP

| Milestone | Deadline | Status |
|-----------|----------|--------|
| MS1 Infrastructure Ready | Mar 20, 2026 | ✅ Done — Mar 16 |
| MS2 Data Indexed | Apr 3, 2026 | ⬜ Not started |
| MS3 Writing Module Complete | Apr 24, 2026 | ⬜ Not started |
| MS4 Grammar Module Complete | Apr 24, 2026 | ⬜ Not started |
| MS5 Speaking Module Complete (TK owns, MK reviews) | May 15, 2026 | ⬜ Not started |
| MS6 Production Ready | May 29, 2026 | ⬜ Not started |

---

## PROGRESS SUMMARY

| Phase | Tasks | Done | % |
|-------|-------|------|---|
| Week 1 — Infrastructure | 4 | 4 | **100%** ✅ |
| Week 2 — Embedding setup | 5 | 0 | 0% |
| Week 3 — Data indexed | 3 | 0 | 0% |
| Week 4 — Writing API + FT | 4 | 0 | 0% |
| Week 5 — .NET integration | 5 | 0 | 0% |
| Week 6 — Writing + Grammar frontend | 8 | 0 | 0% |
| Week 7 — E2E + Polish | 4 | 0 | 0% |
| Week 8 — Testing + Review | 3 | 0 | 0% |
| Week 9 — Performance | 2 | 0 | 0% |
| Week 10 — Load testing | 4 | 0 | 0% |
| Week 11 — Deployment | 6 | 0 | 0% |
| **TOTAL** | **48** | **4** | **8%** |
