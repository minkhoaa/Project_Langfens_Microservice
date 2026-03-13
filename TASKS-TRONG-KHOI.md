# TASK ASSIGNMENT — NGUYEN BA TRONG KHOI
### Dev B — Frontend & AI Support

**Project:** Langfens Phase 2 — Adaptive AI Tutor
**Duration:** March 16 – May 29, 2026 (11 weeks)
**Hard Deadline:** May 29, 2026 (before June 1)

---

## ROLE SUMMARY

- All frontend UI for 3 modules (Writing Comparative, Speaking Roleplay, Grammar Explainer)
- **Grammar Explainer backend** — own the `/api/v1/grammar/explain` and `/api/v1/grammar/batch-explain` endpoints (mentored by Minh Khoa)
- Grammar rules authoring — 200 rules in JSON format
- Roleplay scenario authoring — 20 scenarios in JSON format
- Prompt testing and quality validation across all modules
- API documentation (OpenAPI/Swagger)
- Cross-browser and accessibility testing

---

## AI RESPONSIBILITIES

You are responsible for the **Grammar Deep Error Explainer** backend — the simplest of the 3 AI modules. Minh Khoa will:
- Provide starter templates and code patterns
- Set up the fine-tuned Gemini model you'll call
- Review your code before merge

Your Grammar backend tasks:
1. Implement `/api/v1/grammar/explain` — embed error sentence, retrieve matching grammar theory from Qdrant, call fine-tuned Gemini for explanation
2. Implement `/api/v1/grammar/batch-explain` — handle multiple errors from one evaluation
3. Design the Grammar Explainer prompt (with Minh Khoa's guidance)

---

## WEEKLY TASKS

### Week 1 — Mar 16–20, 2026

| Task | Dependencies | Deliverable |
|------|-------------|-------------|
| Research UI libraries/patterns for side-by-side text comparison | None | UI approach documented |
| Set up frontend project structure for Phase 2 features | None | New pages/routes scaffolded |

> **MILESTONE MS1: Infrastructure Ready** — Deadline: Mar 20, 2026

### Week 2 — Mar 23–27, 2026

| Task | Dependencies | Deliverable |
|------|-------------|-------------|
| Design Writing Comparative results page (Figma/mockup) | Research done | Mockup approved by team |
| Build basic reusable comparison component (placeholder data) | Mockup | Component renders side-by-side text |

### Week 3 — Mar 30 – Apr 3, 2026

| Task | Dependencies | Deliverable |
|------|-------------|-------------|
| Author 100 grammar rules (JSON): common IELTS grammar errors with theory + examples | None | `scripts/grammar/grammar_rules/*.json` |
| Build Writing results page layout (tabs: Scores / Comparative / Suggestions) | Mockup | Page structure renders with tab navigation |
| Design Grammar Explainer UI mockup | None | Mockup: Error -> Theory -> Examples layout |

> **MILESTONE MS2: Data Indexed** — Deadline: Apr 3, 2026

### Week 4 — Apr 6–10, 2026

| Task | Dependencies | Deliverable |
|------|-------------|-------------|
| Integrate real `/writing/search` API into frontend (test with search-only) | Search endpoint (Minh Khoa) | Frontend shows similar essays from Qdrant |
| Build "Similar Essays" sidebar component | API integration | Shows 3 similar essays with band + snippet |
| Build Grammar Explainer basic component (static layout) | Mockup | Component renders Error/Theory/Example sections |

### Week 5 — Apr 13–17, 2026

| Task | Dependencies | Deliverable |
|------|-------------|-------------|
| Build Comparative tab: "Your sentence" vs "Band 9.0 version" table | Compare API schema (Minh Khoa) | Side-by-side comparison renders |
| Build vocabulary suggestions component (word replacements from sample essays) | Compare API schema | Suggestions displayed with context |

### Week 6 — Apr 20–24, 2026

| Task | Dependencies | Deliverable |
|------|-------------|-------------|
| Implement `/api/v1/grammar/explain` endpoint: embed error -> retrieve theory -> fine-tuned Gemini explanation | Grammar collection + model tuned (Minh Khoa) | Single error explanation working |
| Implement `/api/v1/grammar/batch-explain`: multiple errors from one evaluation | Single explain | Batch processing working |
| Design Grammar Explainer prompt: error identification, theory citation, examples | Minh Khoa guidance | Prompt tested with 20 common errors |
| Integrate Grammar API into Grammar Explainer component | Grammar endpoints | Component fetches + renders real data |
| Polish Writing Comparative UI + Grammar Explainer UI | All components done | Production-quality UI |

> **MILESTONE MS3: Writing Module Complete** — Deadline: Apr 24, 2026
> **MILESTONE MS4: Grammar Module Complete** — Deadline: Apr 24, 2026

### Week 7 — Apr 27 – May 1, 2026

| Task | Dependencies | Deliverable |
|------|-------------|-------------|
| Author 10 roleplay scenarios (JSON): airport, job interview, restaurant, hotel, Part 2 cue cards | None | 10 scenario files in `ai-service/app/data/scenarios/` |
| Design Roleplay chat UI mockup | None | Mockup: chat interface + scenario selector |
| Cross-browser testing for Writing + Grammar features | UI polish | Chrome, Firefox, Safari verified |

### Week 8 — May 4–8, 2026

| Task | Dependencies | Deliverable |
|------|-------------|-------------|
| Build Scenario Selector page (grid/list of available scenarios with difficulty) | Scenarios list API (Minh Khoa) | User can browse + select scenarios |
| Build Chat interface component (message bubbles, input, send) | Mockup | Basic chat UI renders |
| Author 10 more scenarios (total: 20) | None | 20 scenario files complete |

### Week 9 — May 11–15, 2026

| Task | Dependencies | Deliverable |
|------|-------------|-------------|
| Integrate Chat UI with roleplay API (start, turn, end) | All roleplay APIs (Minh Khoa) | Real conversations in UI |
| Build end-of-session Report UI (vocabulary stats, pronunciation, suggestions) | End API (Minh Khoa) | Report page renders all feedback |
| Build audio recording component (if needed beyond existing) | STT flow | User can record + send audio |
| Polish Roleplay UI (responsive, smooth transitions, loading states) | All integration done | Production-quality UI |

> **MILESTONE MS5: Speaking Module Complete** — Deadline: May 15, 2026

### Week 10 — May 18–22, 2026

| Task | Dependencies | Deliverable |
|------|-------------|-------------|
| E2E testing from frontend perspective | All modules done | Frontend test report |
| Fix UI bugs discovered during testing | Test report | All UI bugs fixed |
| Cross-browser testing for Speaking features | UI polish | Chrome, Firefox, Safari verified |
| Accessibility review for all new UI features | UI finalized | WCAG compliance checked |
| Mobile responsive testing + fixes | UI finalized | Mobile UX verified |

### Week 11 — May 25–29, 2026

| Task | Dependencies | Deliverable |
|------|-------------|-------------|
| Final UI polish based on staging testing | Staging deployed (Minh Khoa) | Last UI adjustments |
| Write API documentation (OpenAPI/Swagger for AI Service) | APIs finalized | API docs published |
| Write user guide for new features | None | User guide document |
| Prepare demo presentation (joint with Minh Khoa) | All complete | Demo ready |

> **MILESTONE MS6: Production Ready** — Deadline: May 29, 2026

---

## KEY DEPENDENCIES ON MINH KHOA

These are tasks where you are blocked until Minh Khoa delivers:

| Your Task | Blocked By | Expected Ready |
|-----------|------------|----------------|
| Integrate `/writing/search` API | Search endpoint | Apr 3, 2026 |
| Build Comparative tab | Compare API + schema | Apr 10, 2026 |
| Grammar backend endpoints | Fine-tuned grammar model + Qdrant collection | Apr 17, 2026 |
| Scenario Selector page | Scenarios list API | May 8, 2026 |
| Chat UI integration | Roleplay start/turn/end APIs | May 8, 2026 |
| Report UI | End session API | May 8, 2026 |
| Staging UI polish | Staging deployment | May 25, 2026 |

---

## CONTENT AUTHORING DEADLINES

| Content | Count | Deadline | Format |
|---------|-------|----------|--------|
| Grammar rules | 100 (first batch) | Apr 3, 2026 (Week 3) | JSON files in `scripts/grammar/grammar_rules/` |
| Grammar rules | 100 more (total 200) | Apr 24, 2026 (Week 6) | Same format |
| Roleplay scenarios | 10 (first batch) | May 1, 2026 (Week 7) | JSON files in `ai-service/app/data/scenarios/` |
| Roleplay scenarios | 10 more (total 20) | May 8, 2026 (Week 8) | Same format |
