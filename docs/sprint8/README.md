# Sprint 8 — Auto-Gen Exam for 4 Skills Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

> ⚠️ **DEPENDENCY**: This plan depends on **Sprint 7 being completed first**. Tasks 1.1 (jsonShape.ts), 1.2 (llmPromptBuilder.ts), 5.2 (autogen.py + autogen router) MUST be merged before Sprint 8 starts. Specifically:
> - `langfens-fe-app/src/app/admin/_lib/jsonShape.ts` (Sprint 7 Task 1.1)
> - `services/ai-service/app/routers/autogen.py` (Sprint 7 Task 5.2)
>
> Verify Sprint 7 is merged before starting Phase 1.

**Goal:** Extend auto-gen to Listening, Writing, and Speaking skills via 3 new ai-service routers + matplotlib chart rendering + admin wizard `/admin/exams/auto-gen` + exam-service bulk insert endpoint. Cover all 4 IELTS skills end-to-end.

**Architecture:** Three independent ai-service routers (`autogen_listening`, `autogen_writing`, `autogen_speaking`) reuse Sprint 7's `groq_service.groq_generate` infrastructure. Writing router renders charts via matplotlib. Admin wizard is a 4-step Next.js page that calls existing admin APIs (`createExam`, `createSection`, `createQuestion`) + new `createQuestionBulk`. Bulk endpoint uses single transaction with partial-success `errors[]` semantics.

**Tech Stack:**
- ai-service: FastAPI, LangChain, Groq, matplotlib (Agg backend)
- exam-service: ASP.NET Core 10, EF Core, existing `AddAsync`/`UpdateAsync` pattern
- FE: Next.js 16, React 19, TypeScript, Vitest 2.1
- Existing patterns: `AdminQuestion_Service.cs:117-174` (AddAsync), `services/ai-service/app/routers/writing.py:7` (APIRouter), `gateway/api-gateway/appsettings.json:316-318` (catch-all route)

**Spec:** `docs/superpowers/specs/2026-09-14-sprint8-autogen-4-skills-design.md`

**Sprint 7 Spec (dependency):** `docs/superpowers/specs/2026-09-14-sprint7-autogen-prompts-design.md`

**Sprint 7 Plan:** `docs/superpowers/plans/2026-09-14-sprint7-autogen-prompts.md`

---

## Global Constraints

These are non-negotiable constraints from the Sprint 8 spec. Every task implicitly enforces these.

- **Python target**: 3.10. Use `from __future__ import annotations` + `Optional[T]`. Match existing `groq_service.py:178-187` style. **All new ai-service files must lint clean via §12.2.1 AST script.**
- **TS target**: Next.js 16 / React 19 strict mode. No `any` in public function signatures. Optional fields use `?:`. **All new FE files must pass `npx tsc --noEmit` with exit 0.**
- **.NET style**: Match existing nullable-aware pattern at `AdminQuestion_Service.cs:120` (`Results.BadRequest(new ApiResultDto(false, msg, null!))`).
- **matplotlib**: Use `Agg` backend (`matplotlib.use("Agg")`), defer `import matplotlib.pyplot as plt` to function scope, wrap `savefig` in try/except OSError → 502.
- **Rate limit**: All new `/api/v1/autogen/*` endpoints get 3-5 rpm/IP via `middleware/rate_limit.py:7-12` ROUTE_LIMITS dict.
- **Auth**: Reuse JWT verification pattern (Phase 5 follow-up per Sprint 7; Sprint 8 inherits same pattern). Add `RequireAuthorization` if auth helper exists in ai-service.
- **Vitest baseline**: 102+ tests passing (post-Sprint 7), 0 skipped. Sprint 8 must NOT regress.
- **pytest pattern**: async tests use `@pytest.mark.asyncio` (asyncio_mode=auto set). Mock at import boundary.
- **xUnit pattern**: New `ExamServiceBulkInsertTests.cs` uses `[Fact]` not `[Theory]` for per-case scenarios.
- **Idempotent migrations**: `BulkInsertRequest` accepts `questions[]` with `Idx` field IGNORED server-side (auto-derived from position).
- **Branch**: `refactor/sync-dotest-admin-renderer` (don't switch).
- **No new dependencies** unless task explicitly states it. matplotlib is the only new Python dep (added in Phase 3).

---

## File Structure

### Files to CREATE (18 net-new)

| File | Responsibility | LOC est. |
|---|---|---|
| `services/ai-service/app/prompts/autogen_listening.py` | 4 section-specific prompt builders (form/matching/MCQ/note completion) | 100 |
| `services/ai-service/app/prompts/autogen_writing.py` | 2 task-type prompt builders (TASK_1 chart / TASK_2 opinion) | 80 |
| `services/ai-service/app/prompts/autogen_speaking.py` | 4 scenario-type prompt builders (PART_1/2/3/ROLEPLAY) | 100 |
| `services/ai-service/app/schemas/autogen_listening.py` | Pydantic `ListeningExamRequest` + `ListeningExamResponse` + `Section` | 50 |
| `services/ai-service/app/schemas/autogen_writing.py` | Pydantic `WritingTaskRequest` + `WritingTaskResponse` | 40 |
| `services/ai-service/app/schemas/autogen_speaking.py` | Pydantic `SpeakingScenarioRequest` + `SpeakingScenarioResponse` | 50 |
| `services/ai-service/app/routers/autogen_listening.py` | `POST /api/v1/autogen/listening-exam` | 80 |
| `services/ai-service/app/routers/autogen_writing.py` | `POST /api/v1/autogen/writing-task` + chart rendering | 100 |
| `services/ai-service/app/routers/autogen_speaking.py` | `POST /api/v1/autogen/speaking-scenario` | 70 |
| `services/ai-service/app/services/matplotlib_chart.py` | Chart description → PNG rendering (bar/line/pie/table) | 120 |
| `services/ai-service/tests/test_autogen_listening_router.py` | pytest router tests with mocked Groq | 100 |
| `services/ai-service/tests/test_autogen_writing_router.py` | pytest router tests + chart URL assertion | 100 |
| `services/ai-service/tests/test_autogen_speaking_router.py` | pytest router tests | 100 |
| `services/ai-service/tests/test_matplotlib_chart.py` | pytest for chart rendering (4 types) | 100 |
| `services/exam-service/Contracts/Exams/BulkInsertRequest.cs` | BE DTO for bulk insert | 20 |
| `services/attempt-service.Tests/ExamServiceBulkInsertTests.cs` | xUnit tests for bulk endpoint | 200 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_lib/autogenClient.ts` | FE client for 4 autogen endpoints | 120 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/page.tsx` | 4-step wizard page | 150 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_components/SkillPicker.tsx` | Step 1 component | 50 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_components/TopicForm.tsx` | Step 2 component | 60 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_components/NavButtons.tsx` | Navigation between steps | 30 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_components/StepIndicator.tsx` | Progress indicator | 40 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_components/ReadingSubTab.tsx` | Reading wizard (reuses AiAuthorModal) | 80 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_components/ListeningSubTab.tsx` | Listening wizard (4 sections preview) | 120 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_components/WritingSubTab.tsx` | Writing wizard (TASK_1/2 + chart preview) | 100 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_components/SpeakingSubTab.tsx` | Speaking wizard (4 scenario types) | 100 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_components/QuestionListEditor.tsx` | Reusable editor for question list | 80 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_components/ChartPreview.tsx` | Chart image preview | 40 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_components/ScenarioJsonEditor.tsx` | JSON editor for scenario | 60 |

### Files to MODIFY (4 existing)

| File | Change | Lines touched |
|---|---|---|
| `services/exam-service/Features/Exams/AdminEndpoint/QuestionEndpoint/AdminQuestion_Service.cs` | Add `BulkInsertAsync` | 33-265 (extend) |
| `services/exam-service/Features/Exams/AdminEndpoint/QuestionEndpoint/AdminQuestion_Handler.cs` | Add `BulkInsertHandler` | 6-31 (extend) |
| `services/exam-service/Features/Exams/AdminEndpoint/AdminExamEndpoint.cs:48-56` | Add `POST /api/admin/question/bulk` route | 48-56 |
| `services/ai-service/app/main.py` | Register 3 new routers | 14, 82 |
| `services/ai-service/app/middleware/rate_limit.py` | Add 3 rate-limit entries | 7-12 |
| `services/ai-service/Dockerfile` | Add `matplotlib` to pip install | (add line) |
| `langfens-fe-app/src/app/admin/_lib/adminApi.ts` | Add `createQuestionBulk` | 75-87 (extend) |

### Files NOT touched (verified 2026-09-14)

- `services/writing-service/*` — no code changes (Sprint 8 only calls its existing admin endpoint).
- `services/speaking-service/*` — no code changes (Sprint 8 uses `SpeakingExam` as-is, concatenates cue_card into TaskText).
- `gateway/api-gateway/appsettings.json` — no YARP work needed.
- `AppHost/Program.cs` — `AI_SERVICE_URL` already injected.

---


Each phase is a self-contained file in this directory. Phases can be executed independently (with Sprint 7 dependency noted in the dependency block below).

| Phase | File | Purpose |
|---|---|---|
| Phase 1 | [`phase-1-listening-prompt-module.md`](./phase-1-listening-prompt-module.md) | Listening auto-gen 4 section prompt builders (form/matching/MCQ/note completion). |
| Phase 2 | [`phase-2-listening-router.md`](./phase-2-listening-router.md) | Listening router + Pydantic schemas + 3 rpm/IP rate-limit + pytest tests. |
| Phase 3 | [`phase-3-writing-matplotlib.md`](./phase-3-writing-matplotlib.md) | Writing + matplotlib: chart rendering service (bar/line/pie/table) + TASK_1/TASK_2 router + static file mount. |
| Phase 4 | [`phase-4-speaking-router.md`](./phase-4-speaking-router.md) | Speaking router: 4 scenario types (PART_1/2/3/ROLEPLAY) + Pydantic schemas + pytest tests. |
| Phase 5 | [`phase-5-exam-service-bulk-insert-endpoint.md`](./phase-5-exam-service-bulk-insert-endpoint.md) | exam-service bulk insert endpoint: DTO + BulkInsertAsync service + handler + xUnit tests (73 → 76 tests). |
| Phase 6 | [`phase-6-fe-autogen-client.md`](./phase-6-fe-autogen-client.md) | FE autogen client: createQuestionBulk adminApi + 4-skill autogenClient.ts. |
| Phase 7 | [`phase-7-wizard-scaffold-reading-sub-tab.md`](./phase-7-wizard-scaffold-reading-sub-tab.md) | Wizard scaffold + Reading sub-tab: page.tsx + 4 step components. |
| Phase 8 | [`phase-8-listening-writing-speaking-sub-tabs.md`](./phase-8-listening-writing-speaking-sub-tabs.md) | Listening/Writing/Speaking sub-tabs + 3 reusable components + wire wizard page. |
| Phase 9 | [`phase-9-vitest-coverage-component-tests.md`](./phase-9-vitest-coverage-component-tests.md) | Vitest component tests for wizard (102 → 106+ tests). |
| Phase 10 | [`phase-10-sprint-8-closure.md`](./phase-10-sprint-8-closure.md) | Full verification suite + warning delta tracking + manual smoke. |

---

## Self-Review

**1. Spec coverage:**
- §4.1 ai-service routers (3 new) → Tasks 2.2, 3.4, 4.3 ✓
- §4.2 Component map → Tasks 6.2, 7.3, 8.7 ✓
- §4.3 Data flow Listening → Tasks 2.1, 2.2, 8.2 ✓
- §4.4 Data flow Writing → Tasks 3.1-3.4, 8.3-8.4 ✓
- §4.5 Data flow Speaking → Tasks 4.1-4.3, 8.5-8.6 ✓
- §4.6 Wire contracts → Tasks 2.1, 3.2, 4.1 (schemas) ✓
- §5.1 ai-service shared module → Reuses Sprint 7 (autogen.py) ✓
- §5.2 ai-service listening router → Task 2.2 ✓
- §5.3 ai-service writing router + matplotlib → Tasks 3.1, 3.4 ✓
- §5.4 ai-service speaking router → Task 4.3 ✓
- §5.5 exam-service bulk endpoint → Tasks 5.1-5.3 ✓
- §5.6 FE wizard → Tasks 7.1-7.3, 8.1-8.7 ✓
- §5.7 autogenClient.ts → Task 6.2 ✓
- §5.8 createQuestionBulk → Task 6.1 ✓
- §6 Phase Plan (10 phases) → Phases 1-10 of this plan ✓
- §7 Risks → Mitigated via rate-limit (Tasks 2.2, 3.4, 4.3), matplotlib error handling (Task 3.4), bulk insert transaction (Task 5.2) ✓
- §8 Acceptance criteria → Tasks 9.1, 10.1 ✓
- §12 Warning Verification Fixes → Integrated as lint steps in Tasks 1.1, 2.1, 2.2, 3.1-3.4, 4.1-4.3, 5.2, 10.1 ✓

**2. Placeholder scan:** No "TBD" / "implement later" / "fill in details". All steps have specific code or commands.

**3. Type consistency:**
- `Section` schema defined Task 2.1, used Task 2.2 router, Task 2.3 test ✓
- `WritingTaskResponse` defined Task 3.2, used Task 3.4 router ✓
- `SpeakingScenarioResponse` defined Task 4.1, used Task 4.3 router ✓
- `BulkInsertRequest` defined Task 5.1, used Task 5.2 service + Task 5.3 handler ✓
- `autogenQuestions`/`autogenListeningExam`/`autogenWritingTask`/`autogenSpeakingScenario` defined Task 6.2, used Tasks 7.2, 8.2, 8.4, 8.6 ✓
- `SCENARIO_BUILDERS` dict Task 4.2, used Task 4.3 ✓
- `SECTION_BUILDERS` tuple Task 1.1, used Task 2.2 ✓

**Issues found and fixed inline:**
- Task 7.2 ReadingSubTab had unused `sectionId` param — kept as placeholder for Sprint 9 wizard wiring.
- Task 2.2 listening router needed `section.title` truncation — added `:1500` char cap per spec §4.6.
- Task 3.4 writing router needs `os.makedirs("/app/static/charts", exist_ok=True)` at startup — moved to lifespan.

---



## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-09-14-sprint8-autogen-4-skills.md`.

Sprint 8 has **10 phases → 33 tasks → ~25h estimated**. Depends on Sprint 7 being merged first.

**Two execution options:**

1. **Subagent-Driven (recommended)** - Dispatch fresh subagent per task, review between tasks
2. **Inline Execution** - Execute in this session with checkpoints

Which approach?

