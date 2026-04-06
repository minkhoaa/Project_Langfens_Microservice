# TASK ASSIGNMENT — NGUYEN BA TRONG KHOI
### Full-stack: Speaking Roleplay + Content Authoring

**Project:** Langfens Phase 2 — Adaptive AI Tutor
**Duration:** March 16 – May 29, 2026 (11 weeks)
**Hard Deadline:** May 29, 2026 (before June 1)

**Legend:** `✅` Done · `🔄` In Progress · `⬜` Not Started · `🚫` Blocked

---

## ROLE SUMMARY

- **Full-stack M2 Speaking Roleplay:** Backend AI (Python/FastAPI) + .NET STT integration + frontend UI
- **Fine-tuning:** Speaking model (1 model, with knowledge transfer from Minh Khoa)
- **Content authoring:** 20 roleplay scenarios (JSON)
- **API documentation:** OpenAPI/Swagger for AI Service
- **User guide:** End-user documentation for new features
- **Cross-browser + accessibility testing**

---

## AI RESPONSIBILITIES

You own the **Speaking Roleplay Agent** backend — the most complex of the 3 AI modules. Minh Khoa will:
- Set up shared infrastructure (Qdrant, AI Service scaffold, embedding service)
- Knowledge transfer session in Week 2 (fine-tuning, FastAPI patterns, Qdrant, Gemini)
- Whisper STT pairing session in Week 7 (explain .NET Speaking Service integration)
- Quick code review Week 6 (early feedback on start + turn endpoints)
- Full code review Week 8 (all endpoints, prompts, memory logic)

**Your backend ramp-up path:**
1. Week 1-2: Research + mockups (frontend focus)
2. Week 3: First FastAPI endpoint (`/scenarios` GET — read JSON, no AI) as warm-up
3. Week 4: Fine-tune Speaking model (Google AI Studio)
4. Week 5: Implement core endpoints (`/start`, `/turn`) with Redis + Qdrant
5. Week 6-7: Advanced features (prompt design, vocabulary tracking, memory, STT)
6. Week 8-9: Frontend integration + polish

---

## FINE-TUNING SCHEDULE

| Module | Training Data | Fine-Tuning Start | Model Ready By | Quality Gate |
|--------|---------------|-------------------|----------------|--------------|
| M2 Speaking Roleplay | 8,938 pairs (ready) | Week 4 (Apr 6) | Apr 10, 2026 | Stays in character 10+ turns, structured JSON >90% |

**If fine-tuning fails quality gate:** Retrain with adjusted data in Week 5, or fallback to base Gemini 2.5 Flash Lite with prompt engineering.

---

## CONTENT AUTHORING DEADLINES

| Content | Count | Deadline | Format | Notes |
|---------|-------|----------|--------|-------|
| Roleplay scenarios — batch 1 | 10 | Apr 3 (Week 3) | JSON in `ai-service/app/data/scenarios/` | airport, interview, restaurant, hotel, etc. |
| Roleplay scenarios — batch 2 | 10 (total: 20) | Apr 24 (Week 6) | Same format | library, gym, travel-agency, etc. |

> **Note:** Grammar rules (5,659 GEC pairs) already exist in `grammar_pairs/processed/` + `export/rag/grammar_knowledge.jsonl`. Schema defined in `scripts/grammar/grammar_rule_schema.json`. No manual authoring needed.

---

## WEEKLY TASKS

### Week 1 — Mar 16–20, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ✅ | Research UI patterns: side-by-side text comparison | UI approach documented |
| ✅ | Research UI patterns: chat interface for roleplay | Chat UI approach documented |
| ✅ | Set up frontend routes for Phase 2 features | New pages/routes scaffolded |

---

### Week 2 — Mar 23–27, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ✅ | **Attend knowledge transfer session (2-3h):** Learn fine-tuning, FastAPI, Qdrant, Gemini | Understand AI Service patterns |
| ✅ | Design Writing Comparative results page (mockup) | Mockup approved |
| ✅ | Design Roleplay chat UI + Scenario Selector (mockup) | Mockup approved |
| ✅ | Build basic comparison component (placeholder data) | Component renders |

---

### Week 3 — Mar 30 – Apr 3, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ✅ | Validate grammar_knowledge.jsonl against grammar_rule_schema.json | Schema compliance verified |
| ✅ | Author 10 roleplay scenarios (JSON) — batch 1 | 10 scenario files in `ai-service/app/data/scenarios/` |
| ✅ | Spot-check 50 training examples from `m2_speaking.jsonl` | Data quality verified |
| ✅ | **Backend warm-up:** Implement `/api/v1/speaking/roleplay/scenarios` GET endpoint (read JSON, no AI) | First FastAPI endpoint deployed and working |
| ✅ | Design Grammar Explainer UI mockup | Mockup: Error -> Theory -> Examples |

> **MS2 Deadline** — Apr 3, 2026

---

### Week 4 — Apr 6–10, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| 🔄 | **Fine-tune Gemini 2.5 Flash Lite — M2 Speaking Roleplay** | Speaking model deployed |
| ✅ | **Quality gate:** Evaluate model (5 scenarios, 10+ turns, JSON correctness) | Quality report. If FAIL → retrain or fallback |
| ✅ | Build Chat interface component (message bubbles, input, typing indicator) | Basic chat UI renders |
| ✅ | Build Scenario Selector page (integrate with real `/scenarios` API) | Scenario browsing with real data |

---

### Week 5 — Apr 13–17, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ⬜ | Implement `/api/v1/speaking/roleplay/start` endpoint | Session initialization working |
| ⬜ | Implement `/api/v1/speaking/roleplay/turn` endpoint | Agent responds to utterances |
| ⬜ | Create Qdrant collection `speaking_memory` (user_id filtering) | Collection ready |
| ⬜ | Set up Redis session state for active conversations | Session persists across turns |
| ⬜ | Build AudioRecorderBar component | Audio recording works |

---

### Week 6 — Apr 20–24, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ⬜ | Design Speaking roleplay prompt (scenario + history + vocabulary + memory) | Agent stays in character |
| ⬜ | Implement vocabulary tracking: detect target words in user transcripts | Vocabulary usage tracked per session |
| ⬜ | Author 10 more scenarios (total: 20) | 20 scenario files complete |

> **MS3 + MS4 Deadline** — Apr 24, 2026 (MK's modules, not blocked on TK)

---

### Week 7 — Apr 27 – May 1, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ⬜ | Assist MK with Writing + Grammar E2E testing | Test scenarios executed |
| ⬜ | Implement repeated idea detection (query `speaking_memory`) | Agent recognizes past mentions |
| ⬜ | Implement `/api/v1/speaking/roleplay/end` endpoint (report generation) | Session report with vocabulary stats + feedback |
| ⬜ | **Attend Whisper STT pairing session (2h) with MK** | Understand .NET Speaking Service Whisper integration |
| ⬜ | Connect STT: audio → Speaking Service (Whisper) → transcript → AI Service | Full voice pipeline working |

---

### Week 8 — May 4–8, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ⬜ | Integrate Chat UI with roleplay API (start, turn, end) | Real conversations in UI |
| ⬜ | Build SessionReportUI (vocabulary stats, errors, suggestions) | Report page renders all feedback |
| ⬜ | Store session summary → Qdrant `speaking_memory` | Memory persists across sessions |

---

### Week 9 — May 11–15, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ⬜ | Integration test: full roleplay flow (select → start → 5 turns → end → report) | E2E verified |
| ⬜ | Test long-term memory: 2 sessions same user | Memory continuity verified |
| ⬜ | Build MemoryIndicator component (shows when Agent recalls past session) | Visual indicator in chat UI |
| ⬜ | Polish Roleplay UI (responsive, transitions, loading states) | Production-quality UI |
| ⬜ | Prompt tuning: roleplay agent quality | Agent quality meets standard |

> **MS5 Deadline** — May 15, 2026

---

### Week 10 — May 18–22, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ⬜ | E2E testing: Speaking module (5 scenarios, full flows) | Test report |
| ⬜ | Cross-browser testing Speaking | Chrome, Firefox, Safari verified |
| ⬜ | Accessibility review all features | WCAG compliance checked |
| ⬜ | Mobile responsive testing + fixes | Mobile UX verified |

---

### Week 11 — May 25–29, 2026

| Status | Task | Deliverable |
|--------|------|-------------|
| ⬜ | Final UI polish based on staging testing | Last UI adjustments |
| ⬜ | API documentation (OpenAPI/Swagger for AI Service) | Docs published |
| ⬜ | Write user guide for new features | User guide document |
| ⬜ | Prepare demo presentation (joint with Minh Khoa) | Demo ready |

> **MS6 Deadline** — May 29, 2026

---

## KEY DEPENDENCIES ON MINH KHOA

| Your Task | Blocked By | Expected Ready |
|-----------|------------|----------------|
| Learn fine-tuning workflow | Knowledge transfer session | Week 2 (Mar 27) |
| Use embedding service for `speaking_memory` | Embedding wrapper | Week 2 (Mar 27) |
| Quick code review feedback | MK reviews start + turn | Week 6 (Apr 24) |
| Whisper STT integration | STT pairing session | Week 7 (May 1) |
| Full code review | MK reviews all Speaking backend | Week 8 (May 8) |

---

## MILESTONE OWNERSHIP

| Milestone | Deadline | Your Role | Status |
|-----------|----------|-----------|--------|
| MS1 Infrastructure Ready | Mar 20, 2026 | Observer (MK owns) | ✅ Done |
| MS2 Data Indexed | Apr 3, 2026 | Content (scenarios, grammar rules) + first endpoint | ✅ Done |
| MS3 Writing Module Complete | Apr 24, 2026 | Not involved (MK owns) | — |
| MS4 Grammar Module Complete | Apr 24, 2026 | Not involved (MK owns) | — |
| MS5 Speaking Module Complete | May 15, 2026 | **Primary owner** | ⬜ Not started |
| MS6 Production Ready | May 29, 2026 | Testing + documentation | ⬜ Not started |

---

## PROGRESS SUMMARY

| Phase | Tasks | Done | % |
|-------|-------|------|---|
| Week 1 — Research | 3 | 0 | 0% |
| Week 2 — Mockups | 4 | 0 | 0% |
| Week 3 — Content + Warm-up | 5 | 0 | 0% |
| Week 4 — Fine-tuning + FE | 4 | 0 | 0% |
| Week 5 — Speaking backend | 5 | 0 | 0% |
| Week 6 — Prompt + Vocab | 3 | 0 | 0% |
| Week 7 — End + STT + Content | 5 | 0 | 0% |
| Week 8 — Frontend integration | 3 | 0 | 0% |
| Week 9 — E2E + Polish | 5 | 0 | 0% |
| Week 10 — Testing | 4 | 0 | 0% |
| Week 11 — Documentation | 4 | 0 | 0% |
| **TOTAL** | **45** | **15** | **33.3%** |
