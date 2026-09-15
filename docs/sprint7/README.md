# Sprint 7 — Auto-Gen LLM Prompt Coverage Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extend LLM auto-gen prompt coverage from 8/19 to 19/19 question types via a server-side Groq proxy through ai-service, eliminate schema/prompt drift via shared `jsonShape` extraction, and lock in D5 compliance with Vitest fixtures.

**Architecture:** Frontend builds system prompts by referencing `jsonShape` strings from `questionSchemas.ts` (single source of truth). FE → gateway YARP → ai-service FastAPI → Groq (server-side, secrets never reach browser). ai-service resolves jsonShape from its own Python mirror. JWT auth + 5 rpm/IP rate-limit on `/api/v1/autogen/questions`. Vitest + LLM-as-judge retry mock for round-trip validation.

**Tech Stack:**
- Frontend: Next.js 16, React 19, TypeScript, Vitest 2.1, happy-dom
- Backend: Python 3.10, FastAPI, LangChain, Groq OpenAI client
- Existing patterns: `groq_service.py:178-292` (GroqService with multi-key rotation), `questionSchemas.ts:1-647` (19 schema entries)

**Spec:** `docs/superpowers/specs/2026-09-14-sprint7-autogen-prompts-design.md`

---

## Global Constraints

These are non-negotiable constraints from the spec. Every task implicitly enforces these.

- **Python target**: 3.10. Use `from __future__ import annotations` + `Optional[T]` (not `T | None`). Match existing `groq_service.py` style.
- **TS target**: Next.js 16 / React 19 strict mode. No `any` in public function signatures. Optional fields use `?:`.
- **Vitest baseline**: 25 tests passing across 6 suites, 0 skipped. Sprint 7 must NOT regress.
- **pytest pattern**: async tests use `@pytest.mark.asyncio` (asyncio_mode=auto set). Mock at import boundary.
- **All new Python files must lint clean via §12.2.1 AST script** (zero `WARNING:` lines for missing type hints).
- **All new TS files must pass `npx tsc --noEmit` with exit 0**.
- **Existing conventions to match**:
  - Python routers use `APIRouter(prefix="/v1/...")` pattern (see `services/ai-service/app/routers/writing.py:7`).
  - TS prompts use `LlmPromptTemplate` interface (`llmPrompts.ts:1-5`).
  - Schema examples use `[N]` placeholders, never `___` (verified at `questionSchemas.ts:195`).
- **Branch**: `refactor/sync-dotest-admin-renderer` (don't switch).
- **No new dependencies** unless task explicitly states it.

---

## File Structure

### Files to CREATE (6 net-new)

| File | Responsibility | LOC est. |
|---|---|---|
| `langfens-fe-app/src/app/admin/_lib/jsonShape.ts` | Extract `jsonShape` + `constraints` from `QUESTION_SCHEMAS` | 30 |
| `langfens-fe-app/src/app/admin/_lib/llmPromptBuilder.ts` | Build canonical system + user prompts from jsonShape + per-type prose | 80 |
| `services/ai-service/app/prompts/autogen.py` | Server-side mirror of `llmPromptBuilder.ts` | 60 |
| `services/ai-service/app/prompts/autogen_templates.py` | Shared system prefix/suffix constants | 30 |
| `services/ai-service/app/schemas/autogen.py` | Pydantic `AutogenQuestionsRequest` + `AutogenQuestionsResponse` | 40 |
| `services/ai-service/app/routers/autogen.py` | `POST /api/v1/autogen/questions` endpoint | 60 |
| `services/ai-service/tests/test_autogen_prompts.py` | pytest snapshot tests for prompt builder | 50 |
| `services/ai-service/tests/test_autogen_router.py` | pytest router tests with mocked `groq_generate` | 80 |
| `langfens-fe-app/src/app/admin/_lib/__tests__/llmPrompts.test.ts` | Vitest fixtures + LLM-as-judge retry mock | 120 |

### Files to MODIFY (5 existing)

| File | Change | Lines touched |
|---|---|---|
| `langfens-fe-app/src/app/admin/_lib/llmPrompts.ts` | Refactor 8 + add 11 = 19 entries using `buildSystemPrompt` + `buildUserPrompt` | 23-185 (rewrite) |
| `langfens-fe-app/src/app/admin/_lib/aiConfig.ts` | Add `"server-proxy"` provider, update `callAi` signature | 1-87 (rewrite) |
| `langfens-fe-app/src/app/admin/exams/[id]/_components/AiAuthorModal.tsx` | Difficulty clamp + new `callAi` args | 60-90 (clamp) |
| `services/ai-service/app/main.py` | Register new router | 14, 82 |
| `services/ai-service/app/middleware/rate_limit.py` | Add `/api/v1/autogen/questions: 5` to ROUTE_LIMITS | 7-12 |

### Files NOT touched (verified 2026-09-14)

- `services/_shared/*` — no changes.
- `services/exam-service/*` — no changes (Sprint 8 concern).
- `services/writing-service/*` — no changes.
- `services/speaking-service/*` — no changes.
- `gateway/api-gateway/appsettings.json` — no YARP work needed (catch-all `/api/admin/question/{**}` exists).
- `AppHost/Program.cs` — `AI_SERVICE_URL` already injected for writing + speaking.


### Phase Index

Each phase is a self-contained file in this directory. Phases can be executed independently (with the Sprint 7 dependency on Sprint 7 being merged first).

| Phase | File | Purpose |
|---|---|---|
| Phase 1 | [`phase-1-schema-extraction-no-behavior-change.md`](./phase-1-schema-extraction-no-behavior-change.md) | Extract jsonShape helper + builder; refactor 8 existing prompts (no behavior change). |
| Phase 2 | [`phase-2-extend-prompts-to-19-types.md`](./phase-2-extend-prompts-to-19-types.md) | Add 11 missing LLM prompt entries to reach 19/19 types. |
| Phase 3 | [`phase-3-difficulty-clamp.md`](./phase-3-difficulty-clamp.md) | Clamp LLM-supplied Difficulty to [1, 5] in AiAuthorModal. |
| Phase 4 | [`phase-4-ai-service-prompt-module-mirror.md`](./phase-4-ai-service-prompt-module-mirror.md) | ai-service Python mirror: prompt templates, Pydantic schemas, prompt builder, pytest snapshot tests. |
| Phase 5 | [`phase-5-ai-service-autogen-router.md`](./phase-5-ai-service-autogen-router.md) | ai-service /api/v1/autogen/questions router + JWT auth + 5 rpm/IP rate-limit + pytest router tests. |
| Phase 6 | [`phase-6-fe-switch-to-server-proxy.md`](./phase-6-fe-switch-to-server-proxy.md) | FE switch to server-proxy provider: aiConfig rewrite + AiAuthorModal wiring. |
| Phase 7 | [`phase-7-vitest-coverage-retry-mock.md`](./phase-7-vitest-coverage-retry-mock.md) | Vitest fixtures for 19 prompts + LLM-as-judge retry mock. |
| Phase 8 | [`phase-8-strict-json-audit.md`](./phase-8-strict-json-audit.md) | STRICT_JSON_SUFFIX audit (verification log only). |
| Phase 9 | [`phase-9-sprint-7-closure.md`](./phase-9-sprint-7-closure.md) | Full verification suite (BE build+test, FE typecheck+vitest+build, ai-service pytest, warning delta tracking). |

---

## Self-Review

**1. Spec coverage:**
- §4.1 Architecture → Tasks 5.2, 6.1, 6.2 ✓
- §4.3 Data flow → Task 5.2 ✓
- §4.4 Wire contracts → Task 4.2 + Task 5.2 ✓
- §5.1 jsonShape.ts → Task 1.1 ✓
- §5.2 llmPromptBuilder.ts → Task 1.2 ✓
- §5.3 llmPrompts refactor → Task 1.3 ✓
- §5.3 + 5.4 prompt coverage 8→19 → Task 2.1 ✓
- §5.5 ai-service prompts → Tasks 4.1, 4.2, 4.3, 4.4 ✓
- §5.6 ai-service router → Tasks 5.1, 5.2, 5.3 ✓
- §5.7 aiConfig rewrite → Task 6.1 ✓
- §5.8 AiAuthorModal clamp + context → Tasks 3.1, 6.2 ✓
- §5.8 Vitest fixtures → Task 7.1 ✓
- §6 Phase plan (9 phases) → Phases 1-9 of this plan ✓
- §7 Risks → Mitigated via 5 rpm rate-limit (Task 5.2), JWT auth TODO comment ✓
- §8 Acceptance criteria → Tasks 7.1, 8.1, 9.1 ✓
- §12 Warning Verification Fixes → Tasks 4.1-4.4, 5.1-5.3, 6.1-6.2, 7.1, 9.1-9.4 ✓

**2. Placeholder scan:** No "TBD" / "TODO" / "implement later" / "add appropriate error handling" without specific code. The only "TODO" is in Task 5.2 about JWT auth wiring — that's an explicit gap to defer.

**3. Type consistency:**
- `getJsonShape(type: string): string` defined Task 1.1, used Tasks 1.2, 2.1, 7.1, 5.1 ✓
- `buildSystemPrompt(type: string): string` defined Task 1.2, used Tasks 1.3, 2.1 ✓
- `build_user_prompt(qtype, passage, count, difficulty, extra="")` defined Task 4.3, used Task 5.2 ✓
- `AutogenQuestionsRequest` fields match Task 5.2 router call ✓
- `callAi` 4th-arg context shape defined Task 6.1, used Task 6.2 ✓

**Issues found and fixed inline:** None — all types and method names match across tasks.

---



## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-09-14-sprint7-autogen-prompts.md`.

Sprint 7 has 9 phases → 25 tasks → ~14.5h estimated.

**Two execution options:**

1. **Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration
2. **Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?

