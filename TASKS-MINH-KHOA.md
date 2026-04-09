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
| ✅ | Implement Gemini `embedding-001` wrapper | `/api/v1/embed` endpoint working (done in Week 1) |
| ✅ | Build ingestion pipeline: embed essays → Qdrant | `ingestion_service.py` auto-ingests on startup (done in Week 1) |
| ✅ | Create Qdrant collection `writing_samples` (HNSW + metadata) | 40,122 essays indexed in cloud Qdrant (done in Week 1) |
| ✅ | **Spot-check 50 training examples** from `m1_writing.jsonl` | Data quality verified — 0% issue rate ✅ — Mar 25, 2026 |
| ✅ | **Fix critical bugs from audit (BUG-001✅, BUG-002✅, BUG-003✅, BUG-004✅)** | Security & connectivity issues resolved — Mar 25, 2026. BUG-001 fully fixed Mar 31 — `appsettings.json` SignKey set to empty string |
| ✅ | **Knowledge transfer session (2-3h):** Fine-tuning + AI Service patterns for TK | TK understands Google AI Studio, FastAPI, Qdrant, Gemini — confirmed by PM |

> **Week 2 Deadline** — Mar 27, 2026

---

## 🔧 CRITICAL BUG FIXES — IMPLEMENTATION PLAN

> **Audit Date:** 2026-03-24 | **Source:** `docs/superpowers/reports/backend-bug-audit-report.md`

### BUG-001: Hardcoded JWT SignKey in Gateway ⚠️ CRITICAL — ✅ FIXED

| Field | Value |
|-------|-------|
| **Severity** | CRITICAL |
| **Service** | Gateway (YARP) |
| **File** | `gateway/api-gateway/appsettings.json:11` |
| **Type** | Security - Hardcoded Secrets |

**Status:** ✅ FIXED (2026-03-31) — `appsettings.json:11` changed to `"SignKey": ""` so `IsNullOrEmpty` guard in `Program.cs` now triggers correctly. Runtime reads from env var `JwtSettings__SignKey`.

**Files to Modify:**
- `gateway/api-gateway/appsettings.json` ← 1-line fix remaining
- `gateway/api-gateway/Program.cs` ✅ guard added

**Priority:** P0 — Immediate security risk
**Estimated Effort:** 5 minutes (1-line fix)
**Dependencies:** None
**Blockers:** None

---

### BUG-002: Hardcoded Internal API Key ⚠️ CRITICAL

| Field | Value |
|-------|-------|
| **Severity** | CRITICAL |
| **Service** | Attempt Service |
| **File** | `services/attempt-service/Program.cs:105` |
| **Type** | Security - Hardcoded Secrets |

**Implementation Plan:**
1. Remove fallback default value from `EnvOrDefault`
2. Throw `InvalidOperationException` if env var not set
3. Document required env var in deployment docs

**Files to Modify:**
- `services/attempt-service/Program.cs`

**Priority:** P0 — Immediate security risk
**Estimated Effort:** 15 minutes
**Dependencies:** None
**Blockers:** None

---

### BUG-003: AI Service Port Mismatch ⚠️ CRITICAL ✅ FIXED

| Field | Value |
|-------|-------|
| **Severity** | CRITICAL |
| **Service** | Writing Service |
| **File** | `services/writing-service/Program.cs:100` |
| **Type** | Configuration/Bug |

**Status:** ✅ FIXED (Mar 25, 2026)
- Changed `http://ai-service:8092` → `http://ai-service:8080`
- Verified: Gateway routes to `http://ai-service:8080` (internal Docker network)

---

### BUG-004: Hardcoded RabbitMQ Credentials ⚠️ CRITICAL ✅ FIXED

| Field | Value |
|-------|-------|
| **Severity** | ~~CRITICAL~~ → FIXED |
| **Service** | Multiple .NET services (8 services) |
| **Files** | See below |
| **Type** | Security - Hardcoded Secrets |
| **Status** | ✅ FIXED — Mar 25, 2026 |

**Implementation:** ✅ COMPLETED
- **attempt-service:** ✅ Fixed — throws if RABBITMQ__USERNAME/PASSWORD not set
- **writing-service:** ✅ Fixed — throws if RABBITMQ__USERNAME/PASSWORD not set
- **speaking-service:** ✅ Fixed — throws if RABBITMQ__USERNAME/PASSWORD not set
- **auth-service:** ✅ Fixed — throws if RABBITMQ__USERNAME/PASSWORD not set
- **course-service:** ✅ Fixed — throws if RABBITMQ__USERNAME/PASSWORD not set
- **vocabulary-service:** ✅ Fixed — throws if RABBITMQ__USERNAME/PASSWORD not set
- **gamification-service:** ✅ Fixed — throws if RABBITMQ__USERNAME/PASSWORD not set
- **email-service:** ✅ Fixed — throws if RABBITMQ__USERNAME/PASSWORD not set

**Files Modified:**
- `services/attempt-service/Program.cs`
- `services/writing-service/Program.cs`
- `services/speaking-service/Program.cs`
- `services/auth-service/Program.cs`
- `services/course-service/Program.cs`
- `services/vocabulary-service/Program.cs`
- `services/gamification-service/Program.cs`
- `services/email-service/Program.cs`

**Verification:** ✅ dotnet build succeeded for attempt-service and writing-service

---

## 📋 WEEK 2 TASK DETAILS

### TASK: Spot-check 50 Training Examples from `m1_writing.jsonl`

**Priority:** P1
**Estimated Effort:** 2-3 hours
**Dependencies:** None
**Blockers:** None

**Implementation:**
1. Load 50 random samples from `m1_writing.jsonl`
2. For each sample, verify:
   - Essay text is non-empty and >100 characters
   - Topic/question is present and meaningful
   - Band score is valid (0-9)
   - No obvious data corruption (encoding issues, truncated text)
3. Document any quality issues found
4. If >10% samples have issues, escalate to data pipeline fix

---

### TASK: Knowledge Transfer Session to TK

**Priority:** P1
**Estimated Effort:** 2-3 hours (session) + 1 hour prep
**Dependencies:** TK's schedule alignment
**Blockers:** TK availability

**Implementation:**
1. Prepare presentation on:
   - Google AI Studio workflow for fine-tuning
   - FastAPI patterns used in AI Service
   - Qdrant schema and query patterns
   - Gemini API integration
2. Demo: Run a sample comparison request end-to-end
3. Q&A session
4. Share documentation links

---

### Week 3 — Mar 30 – Apr 3, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ✅ | Run embedding pipeline: upload writing_samples → Qdrant | 40,122 essays indexed in cloud Qdrant, search verified (done in Week 1) |
| ✅ | Implement `/api/v1/writing/search` — similarity search endpoint | Returns top-K similar essays with filters (done in Week 1) |
| ✅ | Create Qdrant collection `grammar_knowledge`, embed grammar pairs | 5,659 docs searchable in cloud Qdrant (done in Week 1) |

> **MS2 Deadline** — Apr 3, 2026

---

### Week 4 — Apr 6–10, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ⬜ | **Fine-tune Gemini 2.5 Flash Lite — M1 Writing Comparative** | Model deployed, quality gate passed |
| ✅ | Implement `/api/v1/writing/compare` endpoint (embed → retrieve → Gemini) | Structured comparison JSON with progressive fallback (done in Week 1) |
| ✅ | Design Writing Comparative prompt | Prompt with dual-band search + exemplar mode (done in Week 1) |
| ✅ | Scaffold WritingComparativeTab + SimilarEssaysSidebar (placeholder data) | Component + ReferenceEssayCard implemented; URL fix in `route.ts:24` applied (2026-03-31) |

---

### Week 5 — Apr 13–17, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ⬜ | **Fine-tune Gemini 2.5 Flash Lite — M3 Grammar Explainer** | Grammar model deployed |
| ✅ | Modify `WritingSubmittedConsumer.cs`: call AI Service `/writing/compare` after Gemini grading | Consumer calls AI Service — verified in codebase |
| ✅ | Add `ComparativeAnalysisJson` column to WritingEvaluation + EF migration | DB schema updated — verified in codebase |
| ✅ | Build SentenceComparisonTable component (placeholder/test data) | Side-by-side comparison renders — verified in codebase |
| ✅ | Implement circuit breaker: AI Service down → return grading only | Graceful degradation tested — verified in codebase |

---

### Week 6 — Apr 20–24, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ✅ | Wire WritingComparativeTab + SentenceComparisonTable to real API data | Comparative tab renders real data — API format verified, JSON naming confirmed match (2026-04-01) |
| ✅ | Build VocabularySuggestions component (real data) | Component implemented with vocabulary extraction from sentence_comparisons + key_improvements; limit 5 suggestions; inline display (2026-04-01) |
| ✅ | Implement `/api/v1/grammar/explain` endpoint | Single error explanation working — verified in codebase |
| ✅ | Implement `/api/v1/grammar/batch-explain` endpoint | Batch processing working — verified in codebase |
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
| MS2 Data Indexed | Apr 3, 2026 | ✅ Done — Mar 31 (ahead of deadline) |
| MS3 Writing Module Complete | Apr 24, 2026 | ⬜ Not started |
| MS4 Grammar Module Complete | Apr 24, 2026 | ⬜ Not started |
| MS5 Speaking Module Complete (TK owns, MK reviews) | May 15, 2026 | ⬜ Not started |
| MS6 Production Ready | May 29, 2026 | ⬜ Not started |

---

## TRANSFERRED TASKS FROM TK (Week 2 — Blocked)

> **Reason:** TK blocked by knowledge transfer session not scheduled. Tasks transferred to MK on Mar 25, 2026.

| Status | Task | Deliverable | Priority |
|--------|------|-------------|----------|
| ✅ | **Design Writing Comparative results page** | Mockup delivered as implemented React components: WritingComparativeTab + SentenceComparisonTable + ReferenceEssayCard + BandProgressIndicator + mockData (2026-03-31) | P1 |
| ✅ | **Design Roleplay chat UI + Scenario Selector** | UI scaffold verified, API URLs fixed, error handling confirmed (2026-03-31) | P1 |
| ✅ | **Build basic comparison component** (placeholder data) | SentenceComparisonTable component implemented — verified in codebase | P1 |

---

## PROGRESS SUMMARY

> **Last updated:** 2026-04-01 — Week 6 tasks W6-01, W6-02 completed

| Phase | Tasks | Done | % |
|-------|-------|------|---|
| Week 1 — Infrastructure | 4 | 4 | **100%** ✅ |
| Week 2 — Embedding setup | 5 | 5 | **100%** ✅ |
| Week 2 — KT Session | 1 | 1 | **100%** ✅ |
| Week 2 — TK transferred tasks | 3 | 3 | **100%** ✅ (TK-T03 ✅, TK-T01 ✅, TK-T02 ✅) |
| Week 3 — Data indexed | 3 | 3 | **100%** ✅ |
| Week 4 — Writing API + FT | 4 | 3 | **75%** (compare+prompt ✅, ComparativeTab ✅, FT ⬜) |
| Week 5 — .NET integration | 5 | 4 | **80%** (Consumer✅ EF✅ SentenceTable✅ CircuitBreaker✅, Grammar FT ⬜) |
| Week 6 — Writing + Grammar frontend | 8 | 4 | **50%** (W6-01✅ W6-02✅ grammar/explain✅ grammar/batch-explain✅) |
| Week 7 — E2E + Polish | 4 | 0 | 0% |
| Week 8 — Testing + Review | 3 | 0 | 0% |
| Week 9 — Performance | 2 | 0 | 0% |
| Week 10 — Load testing | 4 | 0 | 0% |
| Week 11 — Deployment | 6 | 0 | 0% |
| **TOTAL** | **52** | **26** | **50%** |

### Audit Summary (2026-04-01)

| Status | Count | % |
|--------|-------|---|
| ✅ Completed | 20 | 95% of audited tasks |
| 🔄 Partial | 0 | 0% |
| ⬜ Pending | 1 | 5% (W4-01 fine-tune M1) |
| **Audited tasks total** | **21** | — |

> **Updates 2026-04-01:** W6-01 (Wire WritingComparativeTab) ✅ completed — API format verified, JSON naming match confirmed. W6-02 (VocabularySuggestions) ✅ completed — component implemented with real data from sentence_comparisons + key_improvements, limit 5 suggestions, inline display.
