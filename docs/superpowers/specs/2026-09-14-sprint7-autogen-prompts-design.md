# Sprint 7 — Auto-Gen LLM Prompt Coverage & Schema Unification

> **Status**: PROPOSED — awaiting user approval  
> **Author**: brainstorming session, 2026-09-14  
> **Branch target**: `refactor/sync-dotest-admin-renderer`  
> **Effort estimate**: 12-18 hours (~2-3 working days, 1 dev)

---

## 1. Context

The `AiAuthorModal` in `langfens-fe-app/src/app/admin/exams/[id]/_components/AiAuthorModal.tsx` lets admins auto-generate question JSON via an LLM. The modal currently uses `llmPrompts.ts` for prompt templates and `aiConfig.ts` for LLM provider routing.

**Problem (verified by Sprint 6 recheck `docs/sprint6/RECHECK_2026-09-14.md` §4 gaps L1, L2, L3, L5, L7):**

1. **L1 — Coverage gap**: only **8 of 19** `QuestionType` enum values have prompt templates. The 11 missing types (`MULTIPLE_CHOICE_SINGLE_IMAGE`, `YES_NO_NOT_GIVEN`, `TABLE_COMPLETION`, `NOTE_COMPLETION`, `FORM_COMPLETION`, `SENTENCE_COMPLETION`, `DIAGRAM_LABEL`, `MAP_LABEL`, `MATCHING_INFORMATION`, `MATCHING_FEATURES`, `MATCHING_ENDINGS`) cause `AiAuthorModal.handleGenerate` to abort with `"No LLM prompt template for type <TYPE>"`.
2. **L2 — Schema drift**: every prompt inlines its own JSON shape in prose. Future changes to `questionSchemas.ts` JSON shape silently break prompts.
3. **L3 — Secret leakage**: `aiConfig.ts:34-35` throws if `NEXT_PUBLIC_AI_API_KEY` is unset. The repo's primary provider is Groq (via `ai-service`), not Anthropic/OpenAI. The FE currently has no way to talk to Groq.
4. **L5 — No regression coverage**: no Vitest ensures LLM-generated JSON deserializes correctly into `AdminQuestionUpsert` after the G13 DTO field additions (`imageUrl`, `modelAnswers`, `wordList`, `groupId`).
5. **L7 — Difficulty range**: `AiAuthorModal.tsx:72` passes `Number(obj.difficulty ?? defaultDifficulty)` without clamping. LLM can emit `difficulty: 7` and the BE D5 validator rejects it — poor UX.

**Existing canonical sources (verified prewalk 2026-09-14):**

- `langfens-fe-app/src/app/admin/_lib/questionSchemas.ts:1-647` — 19 entries, each with `jsonShape`, `examplePayload`, `constraints`. All 19 verified D5-aligned against `AdminQuestion_Service.ValidatePayload` (lines 38-111) and `SharedInternalExamDto.cs:54,71-73`.
- `services/ai-service/app/services/groq_service.py:178-292` — GroqService with multi-key rotation, JSON retry on `expect_json=True`, `groq_generate(prompt_template, variables, ...)` async wrapper.
- `services/ai-service/app/middleware/rate_limit.py:7-12` — `ROUTE_LIMITS` dict for per-route RPM limits (10 for `/writing/compare`, 20 for `/grammar/explain`, default 60).
- `gateway/api-gateway/appsettings.json:316-318` — `/api/admin/question/{**catch-all}` already routed to `exam-cluster`. No YARP work needed for `/api/admin/question/bulk`.
- `AppHost/Program.cs:48-50,212,219,220` — `aiService.GetEndpoint("http")` is already wired to `writing.WithEnvironment("AI_SERVICE_URL", ...)` and `speaking.WithEnvironment(...)`. Aspire auto-injects.

---

## 2. Goals

1. **G1**: Extend `LLM_PROMPTS` from 8 → 19 entries. Every `QuestionType` enum value returns a non-null `LlmPromptTemplate` from `getLlmPrompt()`.
2. **G2**: Extract `jsonShape` from `questionSchemas.ts` and have each prompt embed it as a string substitution. Schema and prompt never drift again.
3. **G3**: Add `POST /api/v1/autogen/questions` to `ai-service` that wraps `groq_service.groq_generate`. FE calls this endpoint via the existing `AI_SERVICE_URL` env var. Default provider becomes `"server-proxy"`.
4. **G4**: Add Vitest suite `llmPrompts.test.ts` that runs every `userTemplate` against a fixture passage + asserts JSON shape + runs LLM-as-judge retry mock to validate the new server-proxy path.
5. **G5**: Clamp `Difficulty` at `[1, 5]` in `AiAuthorModal.tsx:72` before sending.

## 3. Non-Goals

- Listening/Writing/Speaking auto-gen — covered by Sprint 8 spec.
- Bulk insert endpoint (`POST /api/admin/question/bulk`) — covered by Sprint 8.
- Admin FE wizard (`/admin/exams/auto-gen`) — covered by Sprint 8.
- New question types.
- DB migrations (no schema change).
- Replacing Anthropic/OpenAI providers — kept as fallback.
- SSE streaming — Sprint 8 optional.

---

## 4. Architecture

### 4.1 Component map

```
┌─────────────────────────────────────────────────────────────────────┐
│  FE (langfens-fe-app)                                               │
│                                                                     │
│  AiAuthorModal ─→ getLlmPrompt(type) ─→ buildSystemPrompt(type)     │
│       │                              │                              │
│       │                              └─→ getJsonShape(type)         │
│       │                                  (reads questionSchemas.ts) │
│       ▼                                                           │
│  aiConfig.callAi(cfg, system, user)                                │
│       │ provider = "server-proxy"                                  │
│       ▼                                                           │
│  fetch POST ${AI_SERVICE_URL}/api/v1/autogen/questions              │
│       { system, user, type, count, difficulty, skill }             │
│       │                                                           │
│       │  (Authorization: Bearer <admin-jwt>)                      │
│       ▼                                                           │
│  parse → setParsedQuestions → adminApi.createQuestion(q) ×N        │
└─────────────────────────────────────────────────────────────────────┘
              │
              │  Gateway YARP route `/api/ai/{**}` →
              ▼
┌─────────────────────────────────────────────────────────────────────┐
│  ai-service (Python/FastAPI)                                        │
│                                                                     │
│  routers/autogen.py (NEW)                                           │
│    POST /api/v1/autogen/questions                                  │
│       ├─ require admin role                                         │
│       ├─ resolve system prompt from prompts/autogen.py              │
│       ├─ call groq_service.groq_generate(...)                      │
│       └─ return { questions: list[dict] }                           │
│                                                                     │
│  prompts/autogen.py (NEW)                                           │
│    build_system_prompt(type) ─→ uses questionSchemas mirror        │
│    build_user_prompt(type, passage, n, difficulty, skill, extra)   │
└─────────────────────────────────────────────────────────────────────┘
```

### 4.2 Data flow (single generation)

1. Admin clicks "AI Author" in `/admin/exams/[id]` → `AiAuthorModal` opens with `type = "CLASSIFICATION"`, `count = 1`, `passage = ""`.
2. Admin types passage, clicks Generate.
3. `handleGenerate`:
   - Calls `getLlmPrompt(type)` → `LlmPromptTemplate` (now guaranteed non-null for all 19 types).
   - Calls `prompt.userTemplate(passage, count, { difficulty, extra })` → user prompt string.
   - Calls `callAi(cfg, prompt.system, userPrompt)` where `cfg.provider = "server-proxy"`.
   - `callAi` does `fetch(POST ${AI_SERVICE_URL}/api/v1/autogen/questions, { body: { system, user, type, count, difficulty, skill } })`.
4. `ai-service` router:
   - Resolves the canonical system prompt for `type` server-side (defense in depth — FE can't bypass).
   - Calls `groq_service.groq_generate(prompt_template, variables, expect_json=True)`.
   - `groq_generate` retries with stricter JSON system message if first parse fails (lines 235-258 of groq_service.py).
   - Returns `{"questions": [parsed_question_dicts]}`.
5. `tryParseLlmJson` validates FE-side; on success, `setParsedQuestions(enriched)` populates preview UI.
6. Admin clicks Save → `handleSaveAll` iterates `createQuestion(q)` calls → `POST /api/admin/question/add` (existing endpoint, no change).

### 4.3 Wire contracts

**FE → ai-service `POST /api/v1/autogen/questions`**:

```ts
// Request
{
  type: string;          // QuestionType enum value
  skill: "READING" | "LISTENING" | "WRITING" | "SPEAKING";
  passage: string;       // source material
  count: number;         // 1..10
  difficulty: number;    // 1..5 (clamped by FE)
  extra_context: string; // optional
}
// Response 200
{ questions: Record<string, unknown>[] }   // each is AdminQuestionUpsert-shaped (sans SectionId)
// Response 4xx
{ detail: string }
```

**ai-service internal call signature** (reuses `groq_service.groq_generate`):

```python
result = await groq_generate(
    prompt_template=AUTOGEN_TEMPLATE,
    variables={"system": system_prompt, "user": user_prompt, "passage": passage},
    expect_json=True,
    temperature=0.3,
    max_tokens=4096,
)
```

### 4.4 Authentication

- ai-service already has `RequestLoggingMiddleware` and `RateLimitMiddleware` (verified at `main.py:71-73`).
- Add `RequireAuthorization` (or JWT middleware) on `/api/v1/autogen/*` to prevent anonymous LLM calls.
- FE passes the user's existing JWT (acquired from auth-service) via `Authorization: Bearer <token>` header — no new auth flow.

---

## 5. Component Design

### 5.1 New file: `langfens-fe-app/src/app/admin/_lib/jsonShape.ts`

```ts
import { QUESTION_SCHEMAS, type QuestionSchema } from "./questionSchemas";

export function getJsonShape(type: string): string {
  const schema: QuestionSchema | undefined = QUESTION_SCHEMAS[type];
  if (!schema) throw new Error(`No QUESTION_SCHEMAS entry for type "${type}"`);
  return schema.jsonShape;
}

export function getConstraints(type: string): string[] {
  const schema = QUESTION_SCHEMAS[type];
  return schema?.constraints ?? [];
}
```

**Why**: Single source of truth. Any change to `questionSchemas.ts` propagates immediately to all prompts.

### 5.2 New file: `langfens-fe-app/src/app/admin/_lib/llmPromptBuilder.ts`

```ts
import { getJsonShape, getConstraints } from "./jsonShape";

const SYSTEM_PREFIX = `You are an IELTS content author. Generate ${"{type}"} questions following the D5 spec.

Constraints (per type):
${"{constraints}"}

Required JSON shape:
\`\`\`
${"{jsonShape}"}
\`\`\`
`;

const STRICT_JSON_SUFFIX = `
Strict JSON mode:
- Output ONLY a single JSON array (one item per question).
- No prose, no markdown fences outside the JSON block, no explanation.
- Each item MUST match the jsonShape above exactly.
- difficulty MUST be an integer in [1, 5].
- If the JSON cannot be produced, output {"error": "reason"} instead.`;

export function buildSystemPrompt(type: string): string {
  return (
    SYSTEM_PREFIX
      .replace("{type}", type)
      .replace("{constraints}", getConstraints(type).join("\n- "))
      .replace("{jsonShape}", getJsonShape(type)) +
    STRICT_JSON_SUFFIX
  );
}

export function buildUserPrompt(
  type: string,
  passage: string,
  count: number,
  vars: { difficulty: string; extra?: string } = { difficulty: "3" }
): string {
  const extraLine = vars.extra ? `\nExtra context: ${vars.extra}\n` : "";
  return (
    `Source passage:\n"""\n${passage}\n"""\n\n` +
    `Generate ${count} ${type} question(s) at difficulty ${vars.difficulty}.${extraLine}\n\n` +
    `Output: a JSON array of ${count} item(s).`
  );
}
```

### 5.3 Refactor: `llmPrompts.ts`

Replace inline `system` + `userTemplate` with `LLM_PROMPTS[type] = { system: buildSystemPrompt(type), userTemplate: (passage, count, vars) => buildUserPrompt(type, passage, count, vars) }` for ALL 19 types.

The 8 existing prompts become thin wrappers (no behavior change for users). 11 new entries added for the missing types.

### 5.4 New file: `services/ai-service/app/prompts/autogen.py`

Mirror of FE `llmPromptBuilder.py` so ai-service is not coupled to FE. Server-side re-resolution is the source of truth.

```python
from app.prompts.autogen_templates import SYSTEM_PREFIX, STRICT_JSON_SUFFIX, USER_PROMPT_TEMPLATE
from typing import Any

def build_system_prompt(qtype: str, json_shape: str, constraints: list[str]) -> str:
    return (
        SYSTEM_PREFIX
        .replace("{type}", qtype)
        .replace("{constraints}", "\n- ".join(constraints))
        .replace("{jsonShape}", json_shape)
        + STRICT_JSON_SUFFIX
    )

def build_user_prompt(qtype: str, passage: str, count: int, difficulty: int, extra: str = "") -> str:
    extra_line = f"\nExtra context: {extra}\n" if extra else ""
    return (
        f"Source passage:\n\"\"\"\n{passage}\n\"\"\"\n\n"
        f"Generate {count} {qtype} question(s) at difficulty {difficulty}.{extra_line}\n\n"
        f"Output: a JSON array of {count} item(s)."
    )
```

### 5.5 New file: `services/ai-service/app/routers/autogen.py`

```python
from fastapi import APIRouter, Depends, HTTPException
from app.prompts.autogen import build_system_prompt, build_user_prompt
from app.services.groq_service import groq_generate
from app.schemas.autogen import AutogenQuestionsRequest, AutogenQuestionsResponse

router = APIRouter(prefix="/v1/autogen", tags=["autogen"])

@router.post("/questions", response_model=AutogenQuestionsResponse)
async def autogen_questions(req: AutogenQuestionsRequest):
    system_prompt = build_system_prompt(req.type, req.json_shape, req.constraints)
    user_prompt = build_user_prompt(req.type, req.passage, req.count, req.difficulty, req.extra_context)
    result = await groq_generate(
        prompt_template="{user}",
        variables={"user": user_prompt},
        expect_json=True,
        temperature=0.3,
        max_tokens=4096,
    )
    questions = result.get("questions") or []
    if not isinstance(questions, list):
        raise HTTPException(status_code=502, detail="LLM output not a list")
    return AutogenQuestionsResponse(questions=questions)
```

**Note**: FE does NOT send `json_shape` + `constraints` — server resolves them from its own mirror of `questionSchemas.ts`. The FE→ai-service request body has just `{ type, skill, passage, count, difficulty, extra_context }`. Server looks up shape server-side. This eliminates a class of "FE sends wrong shape" bugs.

### 5.6 Edit: `aiConfig.ts`

```ts
export type AiProvider = "server-proxy" | "anthropic" | "openai" | "google";

export const DEFAULT_AI_CONFIG: AiConfig = {
  provider: (process.env.NEXT_PUBLIC_AI_PROVIDER as AiProvider) || "server-proxy",
  apiKey: process.env.NEXT_PUBLIC_AI_API_KEY || "",   // unused for server-proxy
  model: process.env.NEXT_PUBLIC_AI_MODEL || "",
  endpoint:
    process.env.NEXT_PUBLIC_AI_SERVICE_URL ||
    process.env.NEXT_PUBLIC_AI_ENDPOINT ||
    "http://localhost:8092",
  maxTokens: 4096,
};

export async function callAi(cfg, system, user, type, count, difficulty, skill) {
  if (cfg.provider === "server-proxy") {
    const res = await fetch(`${cfg.endpoint}/api/v1/autogen/questions`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      credentials: "include",
      body: JSON.stringify({ type, skill, passage: user, count, difficulty, extra_context: system }),
    });
    if (!res.ok) throw new Error(`ai-service ${res.status}`);
    const data = await res.json();
    return JSON.stringify(data.questions);  // caller uses tryParseLlmJson
  }
  // ... existing anthropic/openai branches unchanged
}
```

### 5.7 Edit: `AiAuthorModal.tsx`

```ts
Difficulty: Math.max(1, Math.min(5, Number(obj.difficulty ?? typeMeta.defaultDifficulty))),
```

Add `difficulty` to the prompt template substitution.

### 5.8 New file: `langfens-fe-app/src/app/admin/_lib/__tests__/llmPrompts.test.ts`

For each of 19 types:
- Assert `getLlmPrompt(type) !== null`.
- Assert `getLlmPrompt(type).system` contains `getJsonShape(type)` verbatim.
- Assert `getLlmPrompt(type).userTemplate("foo", 3, {difficulty: "4"})` returns a string with `"Generate 3"` and `"difficulty 4"`.

For the server-proxy round-trip (mocked):
- Mock `fetch` → return `{"questions": [valid_json_shape]}`.
- Call `callAi(serverProxyCfg, system, user, type, 1, 3, "READING")`.
- Assert result parses back to array of 1.

---

## 6. Phase Plan

Each phase is small enough to land as 1 PR. Each phase ends with a green test suite + manual smoke.

### Phase 1 — Schema extraction (no behavior change)

**Files**:
- Create `langfens-fe-app/src/app/admin/_lib/jsonShape.ts`
- Create `langfens-fe-app/src/app/admin/_lib/llmPromptBuilder.ts`
- Edit `langfens-fe-app/src/app/admin/_lib/llmPrompts.ts` — refactor 8 existing entries to use builders

**Acceptance**:
- `npm run test` still 25/25 green.
- `npx tsc --noEmit` exits 0.
- `Object.keys(LLM_PROMPTS).length === 8` (unchanged at this point).
- Generated system prompts byte-equal to existing inline shapes (snapshot test in `llmPrompts.test.ts`).

**Commit**: `refactor(fe-llm): extract jsonShape + builder, no prompt coverage change`

### Phase 2 — Extend prompts to 19 types

**Files**:
- Edit `langfens-fe-app/src/app/admin/_lib/llmPrompts.ts` — add 11 entries

**Acceptance**:
- `Object.keys(LLM_PROMPTS).length === 19`.
- All 19 keys equal to `Object.keys(QUESTION_SCHEMAS)`.
- Vitest snapshot updated to reflect new entries.

**Commit**: `feat(fe-llm): extend LLM prompts to all 19 question types`

### Phase 3 — Difficulty clamp + STRICT_JSON audit

**Files**:
- Edit `langfens-fe-app/src/app/admin/exams/[id]/_components/AiAuthorModal.tsx:72`
- Add per-type Vitest fixture asserting clamp behaviour.

**Acceptance**:
- `LLM-supplied difficulty: 7 → Difficulty: 5` in saved JSON.
- `LLM-supplied difficulty: 0 → Difficulty: 1`.
- All existing test still pass.

**Commit**: `fix(fe-admin): clamp LLM-supplied difficulty to [1, 5]`

### Phase 4 — ai-service autogen prompt module

**Files**:
- Create `services/ai-service/app/prompts/autogen.py`
- Create `services/ai-service/app/prompts/autogen_templates.py` (system prefix + suffix as constants)
- Create `services/ai-service/app/schemas/autogen.py` (Pydantic request/response)
- Create `services/ai-service/tests/test_autogen_prompts.py` (snapshot tests for build_system_prompt per type)

**Acceptance**:
- `pytest services/ai-service/tests/test_autogen_prompts.py` passes.
- Snapshot per type matches FE-side builder output (cross-check via Python script in test).

**Commit**: `feat(ai-autogen): add prompt builder module mirror`

### Phase 5 — ai-service autogen router (server-side proxy)

**Files**:
- Create `services/ai-service/app/routers/autogen.py`
- Edit `services/ai-service/app/main.py:14,82` — add router import + `app.include_router(autogen.router, prefix="/api")`
- Add `RequireAuthorization` dependency (reuse JWT verification from existing routers — confirm pattern)
- Update `services/ai-service/app/middleware/rate_limit.py:7-12` — add `/api/v1/autogen/questions: 5` (low limit — auto-gen is expensive)

**Acceptance**:
- `pytest services/ai-service/tests/test_autogen_router.py` passes (mock `groq_generate`).
- `curl -X POST http://localhost:8092/api/v1/autogen/questions` without auth → 401.
- `curl -X POST ...` with admin JWT → 200 with `{"questions": [...]}`.
- 6th request within 60s from same IP → 429.

**Commit**: `feat(ai-autogen): add server-side autogen router with auth + rate limit`

### Phase 6 — FE switch to server-proxy

**Files**:
- Edit `langfens-fe-app/src/app/admin/_lib/aiConfig.ts` — add `server-proxy` provider
- Edit `langfens-fe-app/src/app/admin/exams/[id]/_components/AiAuthorModal.tsx` — pass `type`, `count`, `difficulty`, `skill` to `callAi`
- Update env doc (`CLAUDE.md` or `frontend.env`)

**Acceptance**:
- `NEXT_PUBLIC_AI_PROVIDER=server-proxy` works with no API key.
- Manual smoke: admin opens `/admin/exams/[id]` → AI Author → for each of 19 types, click Generate → JSON parses → save → reload.
- `npm run test` passes.
- `npm run build` exits 0.

**Commit**: `feat(fe-llm): switch default provider to ai-service autogen proxy`

### Phase 7 — Vitest fixtures + LLM-as-judge retry mock

**Files**:
- Create `langfens-fe-app/src/app/admin/_lib/__tests__/llmPrompts.test.ts`
- Create `services/ai-service/tests/test_autogen_router.py` (extend with retry-mock scenarios)

**Acceptance**:
- `npm run test` reports ≥ 44 tests (25 existing + 19 prompt coverage).
- Mock scenarios:
  - First response not JSON → server retries with stricter system prompt → second response JSON → 200.
  - First response JSON but missing required keys → server rejects with `400` and detailed reason.

**Commit**: `test(fe-llm + ai-autogen): add Vitest fixtures and retry mocks`

### Phase 8 — STRICT_JSON_INSTRUCTION audit

**Files**:
- Edit `llmPrompts.ts` — confirm `STRICT_JSON_SUFFIX` is in `buildSystemPrompt` (Phase 1 already did this — Phase 8 is verification only)
- Audit log only — no code change if verified

**Acceptance**:
- Every type's system prompt ends with `STRICT_JSON_SUFFIX`.
- Audit log appended to `docs/sprint7/AUDIT_STRICT_JSON.md` (new file, 5-10 lines).

**Commit**: `chore(fe-llm): audit STRICT_JSON coverage across 19 types`

### Phase 9 — Sprint 7 closure

**Files**:
- `docs/sprint7/PLAN.md` — mark all phases DONE
- `HANDOFF_SPRINT7.md` (new) — record Sprint 8 input

**Acceptance**:
- All 8 phase commits landed on `refactor/sync-dotest-admin-renderer`.
- `dotnet test services/attempt-service.Tests` — 73/73 still pass (no BE regression).
- `npm run test` ≥ 44 tests pass.
- `npm run build` exits 0.
- Manual smoke: all 19 types generate via UI.
- No untracked files in working tree.

**Commit**: `docs(sprint7): close Sprint 7 with full verification scoreboard`

---

## 7. Risks & Mitigations

| # | Risk | Likelihood | Impact | Mitigation |
|---|------|------------|--------|------------|
| R1 | jsonShape in `questionSchemas.ts` becomes stale relative to D5 spec | Low | Medium | Phase 1 includes a snapshot test that fails on any drift; prewalk verified 19/19 are D5-aligned |
| R2 | LLM output drifts despite jsonShape injection | High | Medium | Vitest LLM-as-judge retry mock verifies the round-trip; admin can edit preview before save |
| R3 | ai-service Groq key rate-limit if many admins concurrently auto-gen | Medium | High | Rate limit middleware lowered to 5 rpm/IP for `/api/v1/autogen/questions`; documented in middleware |
| R4 | Browser direct Groq fallback leaks key | Low | High | Default provider is `server-proxy`; Anthropic/OpenAI paths retained but not default; `NEXT_PUBLIC_AI_API_KEY` no longer required when `server-proxy` is used |
| R5 | Difficulty clamp breaks question bank that stores `0` | Low | Low | D5 BE validator already rejects out-of-range; clamp prevents reaching validator |
| R6 | Server-proxy adds latency 5-15s round-trip | Medium | Low | Modal already shows "Generating..." debounce; cancellation supported |
| R7 | Auth middleware not yet wired on ai-service routers | Medium | High | Verify auth pattern in `services/ai-service/app/routers/speaking.py` for precedent; Phase 5 reuses |
| R8 | 11 new prompts produce lower quality than 8 existing | Medium | Low | All prompts go through `buildSystemPrompt` so tone/precision is enforced; manual smoke each in dev |

---

## 8. Acceptance Criteria (Definition of Done)

1. `Object.keys(LLM_PROMPTS).length === 19` and equals `Object.keys(QUESTION_SCHEMAS)`.
2. `grep "buildSystemPrompt" langfens-fe-app/src/app/admin/_lib/llmPrompts.ts` returns 19 matches (one per type).
3. `npx tsc --noEmit` exits 0.
4. `npm run test` reports `Tests 44+ passed (44+)` across ≥ 7 suites.
5. `npm run build` exits 0.
6. `pytest services/ai-service/tests/test_autogen_*.py` all green.
7. Manual: for each of 19 types, admin UI generates 1 question → parses → saves → reload shows it in QuestionEditor.
8. Live: `curl -X POST http://localhost:8092/api/v1/autogen/questions` with admin JWT returns 200 with `questions` array of length 1+ for a real IELTS passage.
9. 6th request within 60s from same IP → 429 (rate limit enforced).
10. `grep -rn "NEXT_PUBLIC_AI_API_KEY" services/ langfens-fe-app/src/` shows no NEW references (existing kept for backward compat in Anthropic/OpenAI paths).
11. Branch remains `refactor/sync-dotest-admin-renderer`.
12. (Warning fix) Sprint 7 introduces **0 new .NET warnings** beyond the 16 baseline CVE + nullable (verified via `dotnet build` warning count delta).
13. (Warning fix) Sprint 7 introduces **0 Python warnings** in new ai-service files (verified via §12.2.1 lint script).
14. (Warning fix) Sprint 7 introduces **0 TypeScript errors** in new FE files (verified via `tsc --noEmit`).
15. (Warning fix) Sprint 7 introduces **0 `describe.skip` regressions** in Vitest (verified via §12.2.3 grep).
16. (Warning fix) Sprint 7 introduces **0 pytest warnings** in new ai-service test files (verified via §12.2.4 grep).


---

## 9. Effort Estimate

| Phase | Effort | Notes |
|---|---|---|
| 1 — Schema extraction | 1.5 h | Mechanical refactor, 8 entries × builder swap |
| 2 — 11 prompt templates | 2 h | Each ~10 LOC builder call |
| 3 — Difficulty clamp | 0.5 h | Trivial |
| 4 — ai-service prompt module | 2 h | Mirror + Pydantic schema + snapshot test |
| 5 — ai-service router | 2 h | Endpoint + auth + rate-limit entry |
| 6 — FE switch | 2 h | aiConfig rewrite + AiAuthorModal wiring |
| 7 — Vitest + retry mock | 3 h | 19 fixtures + 2 retry scenarios |
| 8 — STRICT_JSON audit | 0.5 h | Verification + audit doc |
| 9 — Closure | 1 h | Verification + docs |
| **Total** | **~14.5 h** | **~2-3 working days** |

---

## 10. Open Questions

1. **Auth on ai-service router**: Reuse existing JWT verification (from `speaking.py` etc.) or use a simpler admin API key? **Default**: JWT, matches existing pattern.
2. **Schema mirror**: Should we generate Python `json_shape` constants from the TS source via codegen, or maintain manually? **Default**: manually mirror initially, codegen later if drift becomes a problem.
3. **`extra_context` field**: Should it be free-form string, or structured (e.g. `{academic_register: true, focus: "vocabulary"}`)? **Default**: free-form string for Sprint 7; structure in Sprint 9 if needed.

---

## 11. Out of Scope (deferred)

- Real TTS for Listening (Sprint 9+).
- Bulk insert endpoint (Sprint 8).
- Admin wizard `/admin/exams/auto-gen` (Sprint 8).
- SSE streaming preview (Sprint 8 optional).
- Chart image generation for Writing Task 1 (Sprint 9+).
---

## 12. Warning Verification Fixes (In-Scope)

This sprint introduces **6 net-new files** (4 Python, 2 TypeScript) and edits **5 existing files**. Verification ran `dotnet build services/attempt-service.Tests/attempt-service.Tests.csproj` and surfaced these warning classes (categorized by scope):

### 12.1 Baseline warning inventory (2026-09-14)

| Warning ID | Source | File scope | In Sprint 7 scope? |
|---|---|---|---|
| `NU1903` Microsoft.AspNetCore.OpenApi 8.0.22 has high CVE | Shared.Bootstrap / attempt-service / email-service / exam-service | None — no Sprint 7 .NET files | **OUT** (security backlog) |
| `NU1902` OpenTelemetry.Api 1.13.1 + OpenTelemetry.Exporter.OpenTelemetryProtocol 1.13.0 have moderate CVE | Shared.ServiceDefaults | None | **OUT** |
| `NU1603` xunit.runner.visualstudio 3.0.0 vs pinned 2.9.3 | attempt-service.Tests.csproj | None — Sprint 7 uses Vitest + pytest | **OUT** |
| `NU1510` Microsoft.Extensions.Diagnostics.HealthChecks pruning | writing-service.csproj | None | **OUT** |
| `CS8604` Possible null reference argument (4 instances in AttemptService.cs, StudyPlanService.cs, Dto.Internal.cs, exam-service) | .NET features we don't touch | None | **OUT** |
| `CS8625` Cannot convert null literal to non-nullable (4 instances) | .NET features we don't touch | None | **OUT** |
| `CS8629` Nullable value type may be null (1 instance) | .NET feature we don't touch | None | **OUT** |
| `CS8619` Nullability mismatch in seeders (4 instances) | ReadingSeeder.cs, GeneratedReadingSeeder.cs | None — Sprint 7 doesn't edit seeders | **OUT** |
| `CS8981` Lowercase class name | Migration files | None | **OUT** |
| (none — Python warnings) | ai-service files we touch | `prompts/autogen.py`, `prompts/autogen_templates.py`, `schemas/autogen.py`, `routers/autogen.py` | **IN** — new files must lint clean |
| (none — TypeScript warnings) | FE files we touch | `llmPrompts.ts`, `aiConfig.ts`, `AiAuthorModal.tsx`, `jsonShape.ts`, `llmPromptBuilder.ts` | **IN** — `tsc --noEmit` must remain 0 errors |

**Decision**: All CVEs and pre-existing .NET warnings are **out of scope** for Sprint 7. The new Python and TypeScript files we create must be clean from day 1.

### 12.2 In-scope warning prevention (concrete tasks)

#### 12.2.1 Python: `py_compile` + manual type-hint lint on new ai-service files

For each new file in Phase 4 + Phase 5:

+ `services/ai-service/app/prompts/autogen.py`
+ `services/ai-service/app/prompts/autogen_templates.py`
+ `services/ai-service/app/schemas/autogen.py`
+ `services/ai-service/app/routers/autogen.py`

**Required patterns** (verified existing convention at `groq_service.py:178-187`):

+ All public functions have type hints on parameters and return.
+ `from __future__ import annotations` at top of file (allows forward references, matches existing pattern).
+ `Optional[T]` for nullable params (not `T | None`) — matches Python 3.10 compat target.
+ No `# noqa` without justification comment.
+ No unused imports.

**Verification command** (added to Phase 9 closure):
```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
import ast
files = [
    'app/prompts/autogen.py',
    'app/prompts/autogen_templates.py',
    'app/schemas/autogen.py',
    'app/routers/autogen.py',
]
for f in files:
    with open(f) as fp:
        tree = ast.parse(fp.read())
    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef):
            if node.name.startswith('_'):  # private — skip
                continue
            if not node.returns:
                print(f'WARNING: {f}:{node.lineno} {node.name}() missing return annotation')
            for arg in node.args.args:
                if arg.arg == 'self':
                    continue
                if not arg.annotation:
                    print(f'WARNING: {f}:{node.lineno} {node.name}({arg.arg}) missing arg annotation')
"
```

**Acceptance**: Zero `WARNING:` lines printed.

#### 12.2.2 TypeScript: `tsc --noEmit` clean on touched FE files

For each FE file touched (Phases 1, 2, 3, 6):

+ `langfens-fe-app/src/app/admin/_lib/llmPrompts.ts`
+ `langfens-fe-app/src/app/admin/_lib/jsonShape.ts` (new)
+ `langfens-fe-app/src/app/admin/_lib/llmPromptBuilder.ts` (new)
+ `langfens-fe-app/src/app/admin/_lib/aiConfig.ts`
+ `langfens-fe-app/src/app/admin/exams/[id]/_components/AiAuthorModal.tsx`

**Required patterns** (matches existing convention):

+ All exported functions have explicit parameter types and return types.
+ No `any` in public function signatures — use `unknown` if type is genuinely unknown.
+ No `@ts-ignore` without justification.
+ All optional fields use `?:` modifier (e.g. `imageUrl?: string | null`), not `| undefined`.

**Verification command** (added to every phase's local CI):
```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npx tsc --noEmit
```

**Acceptance**: exit code 0, zero TS errors.

#### 12.2.3 Vitest: avoid `describe.skip` regression

Sprint 3 un-skipped 2 test files (`ResultV3Review.parseUserAnswer.test.ts`, `CompletionCard.sort.test.tsx`). Sprint 7 adds 1 new test file (`llmPrompts.test.ts`). Sprint 7 must NOT regress the "0 skipped suites" baseline.

**Verification command** (added to Phase 7):
```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npm run test 2>&1 | grep -E "skipped|Skipped" | head -5
```

**Acceptance**: Zero "skipped" entries in output. If any `describe.skip` appears, the test must be either completed (preferred) or removed with justification comment in commit message.

#### 12.2.4 pytest: zero warnings on new test files

For each new test file in Phase 4 + Phase 7:

+ `services/ai-service/tests/test_autogen_prompts.py`
+ `services/ai-service/tests/test_autogen_router.py`

**Required patterns** (matches existing convention):

+ Use `pytest` fixtures, not unittest-style `setUp`/`tearDown`.
+ All async tests use `@pytest.mark.asyncio` (asyncio_mode=auto is set in `pytest.ini`).
+ Mock at the import boundary: `monkeypatch.setattr(...)` or `patch("module.function", ...)`.
+ No `print()` in tests — use `pytest -s` only when debugging.

**Verification command** (added to Phase 9 closure):
```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
PYTHONPATH=. pytest tests/test_autogen_prompts.py tests/test_autogen_router.py -v --tb=short 2>&1 | grep -iE "warning|deprecat" | head -10
```

**Acceptance**: Zero "DeprecationWarning" or "PendingDeprecationWarning" entries.

### 12.3 Warning delta tracking

**Baseline (before Sprint 7)**:

+ `dotnet build` warnings: 16 (all CVE + nullable, OUT of scope)
+ `npm run test` skipped suites: 0
+ Python warnings: unknown (no pytest installed in PATH)

**Target (after Sprint 7)**:

+ `dotnet build` warnings: 16 (unchanged — all pre-existing, OUT of scope)
+ `npm run test` skipped suites: 0 (unchanged)
+ Python warnings: 0 (newly created files lint clean)

If any Sprint 7 phase introduces a NEW warning (e.g. a Python `import not used`), the phase's commit message must include a "fixup" line referencing the warning ID. The closing phase (Phase 9) verifies the delta is exactly 0.

### 12.4 Why this section exists

The verification pass before Sprint 7 design surfaced 16 .NET warnings (none in scope). Sprint 7 introduces new files in ai-service (Python) + FE (TypeScript) + tests (pytest + Vitest). Without an explicit "warning-free from day 1" gate:

+ New Python files could ship with type-hint gaps that `groq_service.py` doesn't have.
+ New TS files could introduce `any` leaks that `deriveUiKind.ts` doesn't have.
+ New pytest tests could ship with `DeprecationWarning` patterns.
+ New Vitest tests could regress `describe.skip` baseline.

The §12.2.1-§12.2.4 verification commands + §12.3 baseline/target tracking prevent this drift.

---

**Spec status**: ready for user review. Awaiting explicit approval before any implementation.
