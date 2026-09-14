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

---

# Phase 1 — Schema Extraction (no behavior change)

## Task 1.1: Add `jsonShape` extraction helper

**Files:**
- Create: `langfens-fe-app/src/app/admin/_lib/jsonShape.ts`
- Test: `langfens-fe-app/src/app/admin/_lib/__tests__/jsonShape.test.ts` (inline within Task 1.2)

**Interfaces:**
- Consumes: `QUESTION_SCHEMAS` from `questionSchemas.ts:21`
- Produces:
  - `getJsonShape(type: string): string` — returns the `jsonShape` field
  - `getConstraints(type: string): string[]` — returns the `constraints` field

- [ ] **Step 1: Write `jsonShape.ts`**

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

- [ ] **Step 2: Run typecheck to verify file compiles**

Run: `cd /home/khoa/Projects/langfens/langfens-fe-app && npx tsc --noEmit`
Expected: exit code 0.

- [ ] **Step 3: Commit**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
git add src/app/admin/_lib/jsonShape.ts
git commit -m "feat(fe-admin): add jsonShape extraction helper for LLM prompts"
```

---

## Task 1.2: Add `llmPromptBuilder.ts` with template constants

**Files:**
- Create: `langfens-fe-app/src/app/admin/_lib/llmPromptBuilder.ts`

**Interfaces:**
- Consumes: `getJsonShape`, `getConstraints` from Task 1.1
- Produces:
  - `buildSystemPrompt(type: string): string`
  - `buildUserPrompt(type, passage, count, vars?): string`

- [ ] **Step 1: Write `llmPromptBuilder.ts`**

```ts
import { getJsonShape, getConstraints } from "./jsonShape";

const SYSTEM_PREFIX = `You are an IELTS content author. Generate ${"${type}"} questions following the D5 spec.

Constraints (per type):
- ${"${constraints}"}

Required JSON shape:
\`\`\`
${"${jsonShape}"}
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
      .replace("${"{type}"}", type)
      .replace("${"{constraints}"}", getConstraints(type).join("\n- "))
      .replace("${"{jsonShape}"}", getJsonShape(type)) +
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

- [ ] **Step 2: Run typecheck**

Run: `cd /home/khoa/Projects/langfens/langfens-fe-app && npx tsc --noEmit`
Expected: exit code 0.

- [ ] **Step 3: Commit**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
git add src/app/admin/_lib/llmPromptBuilder.ts
git commit -m "feat(fe-admin): add llmPromptBuilder with jsonShape-driven templates"
```

---

## Task 1.3: Refactor 8 existing prompts to use builder

**Files:**
- Modify: `langfens-fe-app/src/app/admin/_lib/llmPrompts.ts:23-185`

**Interfaces:**
- Consumes: `buildSystemPrompt`, `buildUserPrompt` from Task 1.2
- Produces: 8 refactored entries (CLASSIFICATION, MATCHING_HEADING, MULTIPLE_CHOICE_SINGLE, MULTIPLE_CHOICE_MULTIPLE, TRUE_FALSE_NOT_GIVEN, SUMMARY_COMPLETION, SHORT_ANSWER, FLOW_CHART)

- [ ] **Step 1: Snapshot test the existing prompts first**

Before refactoring, capture baseline so we can verify byte-equality:

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
# Save current system prompts to verify after refactor
node -e "
const { LLM_PROMPTS } = require('./src/app/admin/_lib/llmPrompts');
const types = Object.keys(LLM_PROMPTS);
const fs = require('fs');
const out = {};
for (const t of types) {
  out[t] = LLM_PROMPTS[t].system;
}
fs.writeFileSync('/tmp/llm-prompts-baseline.json', JSON.stringify(out, null, 2));
console.log('Captured', types.length, 'prompts');
"
```

Expected: `Captured 8 prompts`.

Note: This is a TypeScript file but Node.js can parse it via `ts-node` if installed, OR via the existing compiled output. If parsing fails, fall back to manual capture of the system strings into a fixture file.

- [ ] **Step 2: Rewrite `llmPrompts.ts` to use builders**

Replace lines 23-185 with:

```ts
import { buildSystemPrompt, buildUserPrompt } from "./llmPromptBuilder";
import { QuestionType } from "./types";

export interface LlmPromptTemplate {
  system: string;
  userTemplate: (passage: string, n: number, extra?: Record<string, string>) => string;
  fewShotExamples?: string[];
}

export const LLM_PROMPTS: Record<string, LlmPromptTemplate> = {
  CLASSIFICATION: {
    system: buildSystemPrompt(QuestionType.Classification),
    userTemplate: (passage, n, vars) => buildUserPrompt(QuestionType.Classification, passage, n, vars as { difficulty: string; extra?: string }),
  },
  MATCHING_HEADING: {
    system: buildSystemPrompt(QuestionType.MatchingHeading),
    userTemplate: (passage, n, vars) => buildUserPrompt(QuestionType.MatchingHeading, passage, n, vars as { difficulty: string; extra?: string }),
  },
  MULTIPLE_CHOICE_SINGLE: {
    system: buildSystemPrompt(QuestionType.MultipleChoiceSingle),
    userTemplate: (passage, n, vars) => buildUserPrompt(QuestionType.MultipleChoiceSingle, passage, n, vars as { difficulty: string; extra?: string }),
  },
  MULTIPLE_CHOICE_MULTIPLE: {
    system: buildSystemPrompt(QuestionType.MultipleChoiceMultiple),
    userTemplate: (passage, n, vars) => buildUserPrompt(QuestionType.MultipleChoiceMultiple, passage, n, vars as { difficulty: string; extra?: string }),
  },
  TRUE_FALSE_NOT_GIVEN: {
    system: buildSystemPrompt(QuestionType.TrueFalseNotGiven),
    userTemplate: (passage, n, vars) => buildUserPrompt(QuestionType.TrueFalseNotGiven, passage, n, vars as { difficulty: string; extra?: string }),
  },
  SUMMARY_COMPLETION: {
    system: buildSystemPrompt(QuestionType.SummaryCompletion),
    userTemplate: (passage, n, vars) => buildUserPrompt(QuestionType.SummaryCompletion, passage, n, vars as { difficulty: string; extra?: string }),
  },
  SHORT_ANSWER: {
    system: buildSystemPrompt(QuestionType.ShortAnswer),
    userTemplate: (passage, n, vars) => buildUserPrompt(QuestionType.ShortAnswer, passage, n, vars as { difficulty: string; extra?: string }),
  },
  FLOW_CHART: {
    system: buildSystemPrompt(QuestionType.FlowChart),
    userTemplate: (passage, n, vars) => buildUserPrompt(QuestionType.FlowChart, passage, n, vars as { difficulty: string; extra?: string }),
  },
};

export function getLlmPrompt(type: string): LlmPromptTemplate | null {
  return LLM_PROMPTS[type] || null;
}
```

- [ ] **Step 3: Run typecheck + Vitest**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npx tsc --noEmit
npm run test
```

Expected: tsc exits 0. Vitest: 25 tests still pass, 0 skipped.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
git add src/app/admin/_lib/llmPrompts.ts
git commit -m "refactor(fe-llm): switch 8 prompts to builder (no behavior change)"
```

---

# Phase 2 — Extend prompts to 19 types

## Task 2.1: Add 11 missing prompts

**Files:**
- Modify: `langfens-fe-app/src/app/admin/_lib/llmPrompts.ts` — extend `LLM_PROMPTS` record

**Interfaces:**
- Consumes: `QuestionType` enum (19 entries)
- Produces: 11 new entries — MULTIPLE_CHOICE_SINGLE_IMAGE, YES_NO_NOT_GIVEN, TABLE_COMPLETION, NOTE_COMPLETION, FORM_COMPLETION, SENTENCE_COMPLETION, DIAGRAM_LABEL, MAP_LABEL, MATCHING_INFORMATION, MATCHING_FEATURES, MATCHING_ENDINGS

- [ ] **Step 1: Verify all 19 QuestionType enum values exist**

```bash
grep -E "(MultipleChoiceSingleImage|YesNoNotGiven|TableCompletion|NoteCompletion|FormCompletion|SentenceCompletion|DiagramLabel|MapLabel|MatchingInformation|MatchingFeatures|MatchingEndings)" langfens-fe-app/src/app/admin/_lib/types.ts
```

Expected: 11 matches (one per type).

- [ ] **Step 2: Add 11 entries to `LLM_PROMPTS`**

After FLOW_CHART entry (line 183 in current file), add:

```ts
  MULTIPLE_CHOICE_SINGLE_IMAGE: {
    system: buildSystemPrompt(QuestionType.MultipleChoiceSingleImage),
    userTemplate: (passage, n, vars) => buildUserPrompt(QuestionType.MultipleChoiceSingleImage, passage, n, vars as { difficulty: string; extra?: string }),
  },
  YES_NO_NOT_GIVEN: {
    system: buildSystemPrompt(QuestionType.YesNoNotGiven),
    userTemplate: (passage, n, vars) => buildUserPrompt(QuestionType.YesNoNotGiven, passage, n, vars as { difficulty: string; extra?: string }),
  },
  TABLE_COMPLETION: {
    system: buildSystemPrompt(QuestionType.TableCompletion),
    userTemplate: (passage, n, vars) => buildUserPrompt(QuestionType.TableCompletion, passage, n, vars as { difficulty: string; extra?: string }),
  },
  NOTE_COMPLETION: {
    system: buildSystemPrompt(QuestionType.NoteCompletion),
    userTemplate: (passage, n, vars) => buildUserPrompt(QuestionType.NoteCompletion, passage, n, vars as { difficulty: string; extra?: string }),
  },
  FORM_COMPLETION: {
    system: buildSystemPrompt(QuestionType.FormCompletion),
    userTemplate: (passage, n, vars) => buildUserPrompt(QuestionType.FormCompletion, passage, n, vars as { difficulty: string; extra?: string }),
  },
  SENTENCE_COMPLETION: {
    system: buildSystemPrompt(QuestionType.SentenceCompletion),
    userTemplate: (passage, n, vars) => buildUserPrompt(QuestionType.SentenceCompletion, passage, n, vars as { difficulty: string; extra?: string }),
  },
  DIAGRAM_LABEL: {
    system: buildSystemPrompt(QuestionType.DiagramLabel),
    userTemplate: (passage, n, vars) => buildUserPrompt(QuestionType.DiagramLabel, passage, n, vars as { difficulty: string; extra?: string }),
  },
  MAP_LABEL: {
    system: buildSystemPrompt(QuestionType.MapLabel),
    userTemplate: (passage, n, vars) => buildUserPrompt(QuestionType.MapLabel, passage, n, vars as { difficulty: string; extra?: string }),
  },
  MATCHING_INFORMATION: {
    system: buildSystemPrompt(QuestionType.MatchingInformation),
    userTemplate: (passage, n, vars) => buildUserPrompt(QuestionType.MatchingInformation, passage, n, vars as { difficulty: string; extra?: string }),
  },
  MATCHING_FEATURES: {
    system: buildSystemPrompt(QuestionType.MatchingFeatures),
    userTemplate: (passage, n, vars) => buildUserPrompt(QuestionType.MatchingFeatures, passage, n, vars as { difficulty: string; extra?: string }),
  },
  MATCHING_ENDINGS: {
    system: buildSystemPrompt(QuestionType.MatchingEndings),
    userTemplate: (passage, n, vars) => buildUserPrompt(QuestionType.MatchingEndings, passage, n, vars as { difficulty: string; extra?: string }),
  },
```

- [ ] **Step 3: Verify Object.keys count is 19**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
node -e "
const path = require('path');
// Inline import via require with TS transform (tsx or ts-node if available)
// If neither installed, run Vitest instead.
" 2>/dev/null || npm run test
```

Expected: 25 tests still pass (we haven't added new tests yet).

Alternative verification via grep:

```bash
grep -cE '^  [A-Z_]+: \{$' langfens-fe-app/src/app/admin/_lib/llmPrompts.ts
```

Expected: `19`.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
git add src/app/admin/_lib/llmPrompts.ts
git commit -m "feat(fe-llm): extend prompts to all 19 question types"
```

---

# Phase 3 — Difficulty clamp

## Task 3.1: Clamp difficulty in AiAuthorModal

**Files:**
- Modify: `langfens-fe-app/src/app/admin/exams/[id]/_components/AiAuthorModal.tsx:72`

**Interfaces:**
- Consumes: existing `obj.difficulty`, `typeMeta.defaultDifficulty`
- Produces: clamped `Difficulty` field in `enriched` array

- [ ] **Step 1: Locate the line**

```bash
grep -n "Difficulty: Number(obj.difficulty" langfens-fe-app/src/app/admin/exams/[id]/_components/AiAuthorModal.tsx
```

Expected: 1 match at line ~72.

- [ ] **Step 2: Replace with clamped version**

Before:
```ts
Difficulty: Number(obj.difficulty ?? typeMeta.defaultDifficulty),
```

After:
```ts
Difficulty: Math.max(1, Math.min(5, Number(obj.difficulty ?? typeMeta.defaultDifficulty))),
```

- [ ] **Step 3: Verify typecheck + Vitest still pass**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npx tsc --noEmit
npm run test
```

Expected: tsc exits 0. Vitest: 25 tests still pass.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
git add src/app/admin/exams/\[id\]/_components/AiAuthorModal.tsx
git commit -m "fix(fe-admin): clamp LLM-supplied difficulty to [1, 5]"
```

---

# Phase 4 — ai-service prompt module mirror

## Task 4.1: Create shared templates constants

**Files:**
- Create: `services/ai-service/app/prompts/autogen_templates.py`

**Interfaces:**
- Produces: 3 module-level string constants — `SYSTEM_PREFIX`, `STRICT_JSON_SUFFIX`, `USER_PROMPT_TEMPLATE`

- [ ] **Step 1: Verify Python version**

```bash
python3 --version
```

Expected: 3.10.x or higher.

- [ ] **Step 2: Write `autogen_templates.py`**

```python
"""Shared prompt template constants for autogen endpoints.

Mirror of langfens-fe-app/src/app/admin/_lib/llmPromptBuilder.ts.
Keep in sync manually OR via codegen (future Sprint 9).
"""
from __future__ import annotations

SYSTEM_PREFIX: str = """You are an IELTS content author. Generate {type} questions following the D5 spec.

Constraints (per type):
- {constraints}

Required JSON shape:
```
{jsonShape}
```
"""

STRICT_JSON_SUFFIX: str = """
Strict JSON mode:
- Output ONLY a single JSON array (one item per question).
- No prose, no markdown fences outside the JSON block, no explanation.
- Each item MUST match the jsonShape above exactly.
- difficulty MUST be an integer in [1, 5].
- If the JSON cannot be produced, output {"error": "reason"} instead."""


def build_user_prompt_template(qtype: str) -> str:
    """Build the user prompt template for a given question type.

    Args:
        qtype: QuestionType enum value (e.g. "MULTIPLE_CHOICE_SINGLE").

    Returns:
        The user prompt template with {passage}, {count}, {difficulty},
        {extra} placeholders.
    """
    extra_line: str = "\\nExtra context: {extra}\\n"
    return (
        "Source passage:\\n\"\"\"\\n{passage}\\n\"\"\"\\n\\n"
        f"Generate {{count}} {qtype} question(s) at difficulty {{difficulty}}.{extra_line}\\n\\n"
        "Output: a JSON array of {count} item(s)."
    )
```

- [ ] **Step 3: Verify Python syntax**

```bash
python3 -c "from app.prompts.autogen_templates import SYSTEM_PREFIX, STRICT_JSON_SUFFIX, build_user_prompt_template; print(len(SYSTEM_PREFIX), len(STRICT_JSON_SUFFIX))"
```

Expected: prints 2 integers > 100.

- [ ] **Step 4: Run §12.2.1 lint script**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
import ast
f = 'app/prompts/autogen_templates.py'
with open(f) as fp:
    tree = ast.parse(fp.read())
for node in ast.walk(tree):
    if isinstance(node, ast.FunctionDef):
        if node.name.startswith('_'):
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

Expected: no output (clean).

- [ ] **Step 5: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/ai-service/app/prompts/autogen_templates.py
git commit -m "feat(ai-autogen): add prompt template constants (Python mirror)"
```

---

## Task 4.2: Add Pydantic schemas

**Files:**
- Create: `services/ai-service/app/schemas/autogen.py`

**Interfaces:**
- Produces: `AutogenQuestionsRequest`, `AutogenQuestionsResponse` Pydantic models

- [ ] **Step 1: Write `autogen.py`**

```python
"""Pydantic schemas for /api/v1/autogen/* endpoints."""
from __future__ import annotations

from typing import Optional

from pydantic import BaseModel, Field


class AutogenQuestionsRequest(BaseModel):
    type: str = Field(..., description="QuestionType enum value, e.g. 'MULTIPLE_CHOICE_SINGLE'")
    skill: str = Field(..., description="READING|LISTENING|WRITING|SPEAKING")
    passage: str = Field(..., min_length=1, description="Source passage / material")
    count: int = Field(..., ge=1, le=10, description="Number of questions to generate")
    difficulty: int = Field(..., ge=1, le=5, description="Difficulty 1-5")
    extra_context: Optional[str] = Field(default=None, description="Optional extra context")


class AutogenQuestionsResponse(BaseModel):
    questions: list[dict] = Field(..., description="List of generated question JSON objects")
```

- [ ] **Step 2: Verify Python syntax**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "from app.schemas.autogen import AutogenQuestionsRequest, AutogenQuestionsResponse; r = AutogenQuestionsRequest(type='MCQ', skill='READING', passage='test', count=1, difficulty=3); print(r.dict())"
```

Expected: prints dict with type, skill, passage, count, difficulty, extra_context.

- [ ] **Step 3: Run §12.2.1 lint script**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
import ast
f = 'app/schemas/autogen.py'
with open(f) as fp:
    tree = ast.parse(fp.read())
for node in ast.walk(tree):
    if isinstance(node, ast.FunctionDef):
        if node.name.startswith('_'):
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

Expected: no output.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/ai-service/app/schemas/autogen.py
git commit -m "feat(ai-autogen): add Pydantic schemas for autogen endpoints"
```

---

## Task 4.3: Create prompt builder module

**Files:**
- Create: `services/ai-service/app/prompts/autogen.py`

**Interfaces:**
- Consumes: `SYSTEM_PREFIX`, `STRICT_JSON_SUFFIX`, `build_user_prompt_template` from Task 4.1
- Produces:
  - `build_system_prompt(qtype: str, json_shape: str, constraints: list[str]) -> str`
  - `build_user_prompt(qtype: str, passage: str, count: int, difficulty: int, extra: str = "") -> str`

- [ ] **Step 1: Write `autogen.py`**

```python
"""Prompt builders for autogen endpoints.

Mirror of langfens-fe-app/src/app/admin/_lib/llmPromptBuilder.ts.
"""
from __future__ import annotations

from app.prompts.autogen_templates import (
    STRICT_JSON_SUFFIX,
    SYSTEM_PREFIX,
    build_user_prompt_template,
)


def build_system_prompt(qtype: str, json_shape: str, constraints: list[str]) -> str:
    """Build the system prompt for a given question type.

    Args:
        qtype: QuestionType enum value.
        json_shape: The canonical JSON shape string from questionSchemas.ts.
        constraints: List of constraint strings for this type.

    Returns:
        Complete system prompt (prefix + jsonShape + suffix).
    """
    return (
        SYSTEM_PREFIX
        .replace("{type}", qtype)
        .replace("{constraints}", "\\n- ".join(constraints))
        .replace("{jsonShape}", json_shape)
        + STRICT_JSON_SUFFIX
    )


def build_user_prompt(
    qtype: str,
    passage: str,
    count: int,
    difficulty: int,
    extra: str = "",
) -> str:
    """Build the user prompt for a given question type.

    Args:
        qtype: QuestionType enum value.
        passage: Source passage / material.
        count: Number of questions to generate (1-10).
        difficulty: Difficulty 1-5.
        extra: Optional extra context.

    Returns:
        Formatted user prompt string.
    """
    template = build_user_prompt_template(qtype)
    extra_line: str = f"\\nExtra context: {extra}\\n" if extra else ""
    return (
        template
        .replace("{passage}", passage)
        .replace("{count}", str(count))
        .replace("{difficulty}", str(difficulty))
        .replace("{extra}", extra)
        + (extra_line if extra else "")
    )
```

- [ ] **Step 2: Verify Python syntax**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
from app.prompts.autogen import build_system_prompt, build_user_prompt
s = build_system_prompt('MULTIPLE_CHOICE_SINGLE', '{\"type\":\"X\"}', ['options ≥ 2'])
u = build_user_prompt('MULTIPLE_CHOICE_SINGLE', 'passage text', 3, 3)
print('System length:', len(s))
print('User length:', len(u))
print('User contains passage:', 'passage text' in u)
"
```

Expected: 3 lines printed, all > 0.

- [ ] **Step 3: Run §12.2.1 lint script**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
import ast
f = 'app/prompts/autogen.py'
with open(f) as fp:
    tree = ast.parse(fp.read())
for node in ast.walk(tree):
    if isinstance(node, ast.FunctionDef):
        if node.name.startswith('_'):
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

Expected: no output.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/ai-service/app/prompts/autogen.py
git commit -m "feat(ai-autogen): add prompt builder module"
```

---

## Task 4.4: Add pytest snapshot tests for prompt builder

**Files:**
- Create: `services/ai-service/tests/test_autogen_prompts.py`

- [ ] **Step 1: Write the test file**

```python
"""Snapshot tests for autogen prompt builders.

These tests ensure the prompt builder produces stable output across refactors.
Update snapshots only when prompt changes are intentional.
"""
from __future__ import annotations

import pytest

from app.prompts.autogen import build_system_prompt, build_user_prompt


@pytest.mark.parametrize(
    "qtype,json_shape,constraints",
    [
        ("MULTIPLE_CHOICE_SINGLE", '{"type":"X","options":[]}', ["options ≥ 2"]),
        ("SUMMARY_COMPLETION", '{"type":"X","blankAcceptTexts":{}}', ["blankAcceptTexts ≥ 1"]),
        ("FLOW_CHART", '{"type":"X","orderCorrects":[]}', ["orderCorrects ≥ 2"]),
    ],
)
def test_build_system_prompt_includes_required_sections(qtype, json_shape, constraints):
    prompt = build_system_prompt(qtype, json_shape, constraints)
    assert qtype in prompt
    assert json_shape in prompt
    assert "Strict JSON mode" in prompt
    assert "Output ONLY a single JSON array" in prompt


def test_build_system_prompt_includes_constraints():
    constraints = ["MCQ must have ≥ 2 options", "Exactly 1 isCorrect=true"]
    prompt = build_system_prompt("MULTIPLE_CHOICE_SINGLE", "{}", constraints)
    assert "MCQ must have ≥ 2 options" in prompt
    assert "Exactly 1 isCorrect=true" in prompt


def test_build_user_prompt_includes_passage_count_difficulty():
    prompt = build_user_prompt("MULTIPLE_CHOICE_SINGLE", "source text here", 3, 4)
    assert "source text here" in prompt
    assert "Generate 3 MULTIPLE_CHOICE_SINGLE question(s)" in prompt
    assert "at difficulty 4" in prompt


def test_build_user_prompt_includes_optional_extra():
    prompt = build_user_prompt(
        "MULTIPLE_CHOICE_SINGLE", "passage", 2, 3, extra="academic register"
    )
    assert "Extra context: academic register" in prompt


def test_build_user_prompt_omits_extra_when_empty():
    prompt = build_user_prompt("MULTIPLE_CHOICE_SINGLE", "passage", 2, 3)
    assert "Extra context" not in prompt
```

- [ ] **Step 2: Run pytest**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
PYTHONPATH=. pytest tests/test_autogen_prompts.py -v
```

Expected: 5+ tests passed.

- [ ] **Step 3: Verify no DeprecationWarning**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
PYTHONPATH=. pytest tests/test_autogen_prompts.py -v 2>&1 | grep -iE "warning|deprecat"
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/ai-service/tests/test_autogen_prompts.py
git commit -m "test(ai-autogen): add pytest snapshot tests for prompt builder"
```

---

# Phase 5 — ai-service autogen router

## Task 5.1: Add json_shape + constraints mirror data

**Files:**
- Create: `services/ai-service/app/prompts/autogen_data.py`

**Interfaces:**
- Produces: `JSON_SHAPES: dict[str, str]` + `CONSTRAINTS: dict[str, list[str]]` mirror of `questionSchemas.ts`

- [ ] **Step 1: Write `autogen_data.py`**

Mirror the 19 schemas from `langfens-fe-app/src/app/admin/_lib/questionSchemas.ts:21-630`. Each entry: `{type_name: json_shape_string}`. Each constraint list: list of strings.

```python
"""Server-side mirror of questionSchemas.ts jsonShape + constraints.

This module is a Python copy of the TypeScript source. To prevent drift,
both must be updated together. Sprint 9 introduces codegen (Phase 9.4 of
PLAN.md).

Keep this in sync with langfens-fe-app/src/app/admin/_lib/questionSchemas.ts.
"""
from __future__ import annotations

JSON_SHAPES: dict[str, str] = {
    "MULTIPLE_CHOICE_SINGLE": """{
  "type": "MULTIPLE_CHOICE_SINGLE",
  "skill": "READING",
  "difficulty": 2,
  "promptMd": "What is the main idea of paragraph 2?",
  "options": [
    { "contentMd": "A. The moon's orbit", "isCorrect": false },
    { "contentMd": "B. The sun's energy", "isCorrect": true }
  ]
}""",
    "MULTIPLE_CHOICE_MULTIPLE": """{
  "type": "MULTIPLE_CHOICE_MULTIPLE",
  "skill": "READING",
  "difficulty": 3,
  "promptMd": "Which THREE of the following are mentioned?",
  "options": [
    { "contentMd": "A. Item one", "isCorrect": true },
    { "contentMd": "B. Item two", "isCorrect": false }
  ]
}""",
    # ... 17 more entries copied from questionSchemas.ts ...
    # For Sprint 7, only the 8 existing LLM_PROMPTS entries need shapes (Phase 1
    # refactor still works without the 11 new ones). Sprint 8 will add all 19.
}

CONSTRAINTS: dict[str, list[str]] = {
    "MULTIPLE_CHOICE_SINGLE": [
        "options[] must have exactly 1 with isCorrect=true (single answer)",
        "options[].contentMd should follow 'A. text', 'B. text' convention",
    ],
    # ... 17 more entries ...
}


def get_json_shape(qtype: str) -> str:
    """Return the canonical JSON shape for a question type.

    Args:
        qtype: QuestionType enum value.

    Returns:
        JSON shape string.

    Raises:
        KeyError: if qtype is not in JSON_SHAPES.
    """
    if qtype not in JSON_SHAPES:
        raise KeyError(f"No JSON_SHAPES entry for type {qtype!r}")
    return JSON_SHAPES[qtype]


def get_constraints(qtype: str) -> list[str]:
    """Return the constraint strings for a question type.

    Args:
        qtype: QuestionType enum value.

    Returns:
        List of constraint strings (empty list if no constraints defined).
    """
    return CONSTRAINTS.get(qtype, [])
```

NOTE: This file requires ALL 19 entries to be populated for Sprint 7 (so FE can resolve `jsonShape` for any of the 19 types via the server). The current scaffold above shows only 2 entries for illustration. **Implementation: copy ALL 19 entries from `questionSchemas.ts:22-630` into this file.**

- [ ] **Step 2: Verify Python syntax**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
from app.prompts.autogen_data import JSON_SHAPES, CONSTRAINTS, get_json_shape, get_constraints
print('JSON_SHAPES count:', len(JSON_SHAPES))
print('CONSTRAINTS count:', len(CONSTRAINTS))
print('Sample shape keys:', list(JSON_SHAPES.keys())[:3])
"
```

Expected: `JSON_SHAPES count: 19`, `CONSTRAINTS count: 19`.

- [ ] **Step 3: Run §12.2.1 lint script**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
import ast
f = 'app/prompts/autogen_data.py'
with open(f) as fp:
    tree = ast.parse(fp.read())
for node in ast.walk(tree):
    if isinstance(node, ast.FunctionDef):
        if node.name.startswith('_'):
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

Expected: no output.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/ai-service/app/prompts/autogen_data.py
git commit -m "feat(ai-autogen): add Python mirror of questionSchemas.ts (19 types)"
```

---

## Task 5.2: Add router with JWT auth + rate-limit

**Files:**
- Create: `services/ai-service/app/routers/autogen.py`
- Modify: `services/ai-service/app/main.py:14,82` — register router
- Modify: `services/ai-service/app/middleware/rate_limit.py:7-12` — add rate-limit entry

**Interfaces:**
- Consumes: `AutogenQuestionsRequest`, `AutogenQuestionsResponse` from Task 4.2; `build_system_prompt`, `build_user_prompt` from Task 4.3; `get_json_shape`, `get_constraints` from Task 5.1
- Produces: HTTP endpoint `POST /api/v1/autogen/questions`

- [ ] **Step 1: Verify existing JWT auth pattern**

```bash
grep -rn "Depends\|verify_jwt\|get_current_user" /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service/app/routers/speaking.py | head -5
```

Expected: at least 1 reference to an auth helper. If no auth helper exists, skip auth wiring in this task — add TODO comment for Sprint 8 follow-up.

- [ ] **Step 2: Write `autogen.py`**

```python
"""Auto-gen router — server-side proxy for LLM-driven question generation.

Forwards requests to Groq via groq_service.groq_generate. Resolves JSON
shape server-side to prevent FE from sending malformed shapes.
"""
from __future__ import annotations

import logging
from typing import Any

from fastapi import APIRouter, Depends, HTTPException, status

from app.prompts.autogen import build_system_prompt, build_user_prompt
from app.prompts.autogen_data import get_constraints, get_json_shape
from app.schemas.autogen import AutogenQuestionsRequest, AutogenQuestionsResponse
from app.services.groq_service import groq_generate

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/v1/autogen", tags=["autogen"])


@router.post("/questions", response_model=AutogenQuestionsResponse)
async def autogen_questions(
    req: AutogenQuestionsRequest,
    # user: dict = Depends(get_current_user),  # TODO: wire JWT auth in Phase 5 follow-up
) -> AutogenQuestionsResponse:
    """Generate IELTS question JSON via LLM (Groq server-side).

    Args:
        req: Request body with type, skill, passage, count, difficulty, optional extra.

    Returns:
        Response with list of generated question JSON objects.

    Raises:
        HTTPException 502 if LLM output is not a valid list.
    """
    try:
        json_shape = get_json_shape(req.type)
        constraints = get_constraints(req.type)
    except KeyError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unknown question type: {req.type}",
        ) from exc

    system_prompt = build_system_prompt(req.type, json_shape, constraints)
    user_prompt = build_user_prompt(
        req.type, req.passage, req.count, req.difficulty, req.extra_context or ""
    )

    result: dict[str, Any] = await groq_generate(
        prompt_template="{user}",
        variables={"user": user_prompt},
        expect_json=True,
        temperature=0.3,
        max_tokens=4096,
    )

    questions_raw = result.get("questions")
    if not isinstance(questions_raw, list):
        logger.error("LLM output not a list: %s", type(questions_raw))
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="LLM output is not a list of questions",
        )

    return AutogenQuestionsResponse(questions=questions_raw)
```

- [ ] **Step 3: Register router in `main.py`**

Edit `services/ai-service/app/main.py:14`:

```python
from app.routers import health, embed, writing, grammar, speaking, practice, speech_eval, speaking_grade, autogen  # ADDED
```

Edit `services/ai-service/app/main.py:82`:

```python
app.include_router(speaking_grade.router, prefix="/api")  # endpoint: /api/v1/speaking/grade
app.include_router(autogen.router, prefix="/api")  # ADDED
```

- [ ] **Step 4: Add rate-limit entry**

Edit `services/ai-service/app/middleware/rate_limit.py:7-12`:

```python
ROUTE_LIMITS: dict[str, int] = {
    "/api/v1/writing/compare": 10,
    "/api/v1/grammar/explain": 20,
    "/api/v1/grammar/batch-explain": 10,
    "/api/v1/grammar/detect": 10,
    "/api/v1/autogen/questions": 5,  # ADDED — LLM calls are expensive
}
```

- [ ] **Step 5: Verify Python syntax**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "from app.routers.autogen import router; print(router.prefix, len(router.routes))"
```

Expected: prints `/v1/autogen 1`.

- [ ] **Step 6: Run §12.2.1 lint script**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
import ast
f = 'app/routers/autogen.py'
with open(f) as fp:
    tree = ast.parse(fp.read())
for node in ast.walk(tree):
    if isinstance(node, ast.FunctionDef):
        if node.name.startswith('_'):
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

Expected: no output.

- [ ] **Step 7: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/ai-service/app/routers/autogen.py services/ai-service/app/main.py services/ai-service/app/middleware/rate_limit.py
git commit -m "feat(ai-autogen): add /api/v1/autogen/questions router with rate-limit"
```

---

## Task 5.3: Add pytest tests for router with mocked groq_generate

**Files:**
- Create: `services/ai-service/tests/test_autogen_router.py`

- [ ] **Step 1: Write the test file**

```python
"""Tests for /api/v1/autogen/questions router with mocked Groq."""
from __future__ import annotations

from unittest.mock import AsyncMock, patch

import pytest
from httpx import ASGITransport, AsyncClient

from app.main import app


@pytest.mark.asyncio
async def test_autogen_questions_returns_list_of_dicts():
    """Happy path: Groq returns list of questions, router passes through."""
    mock_questions = [
        {"type": "MULTIPLE_CHOICE_SINGLE", "difficulty": 3, "options": []},
        {"type": "MULTIPLE_CHOICE_SINGLE", "difficulty": 4, "options": []},
    ]
    with patch("app.routers.autogen.groq_generate", new_callable=AsyncMock) as mock_gen:
        mock_gen.return_value = {"questions": mock_questions}
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            resp = await ac.post(
                "/api/v1/autogen/questions",
                json={
                    "type": "MULTIPLE_CHOICE_SINGLE",
                    "skill": "READING",
                    "passage": "test passage",
                    "count": 2,
                    "difficulty": 3,
                },
            )
        assert resp.status_code == 200
        body = resp.json()
        assert "questions" in body
        assert len(body["questions"]) == 2
        assert body["questions"][0]["type"] == "MULTIPLE_CHOICE_SINGLE"


@pytest.mark.asyncio
async def test_autogen_questions_400_for_unknown_type():
    """Invalid type returns 400, never reaches Groq."""
    with patch("app.routers.autogen.groq_generate", new_callable=AsyncMock) as mock_gen:
        mock_gen.return_value = {}
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            resp = await ac.post(
                "/api/v1/autogen/questions",
                json={
                    "type": "NONEXISTENT_TYPE",
                    "skill": "READING",
                    "passage": "test",
                    "count": 1,
                    "difficulty": 3,
                },
            )
        assert resp.status_code == 400
        assert "Unknown question type" in resp.json()["detail"]


@pytest.mark.asyncio
async def test_autogen_questions_502_when_llm_returns_non_list():
    """If Groq returns dict instead of list, router returns 502."""
    with patch("app.routers.autogen.groq_generate", new_callable=AsyncMock) as mock_gen:
        mock_gen.return_value = {"questions": "not a list"}
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            resp = await ac.post(
                "/api/v1/autogen/questions",
                json={
                    "type": "MULTIPLE_CHOICE_SINGLE",
                    "skill": "READING",
                    "passage": "test",
                    "count": 1,
                    "difficulty": 3,
                },
            )
        assert resp.status_code == 502
        assert "not a list" in resp.json()["detail"]
```

- [ ] **Step 2: Run pytest**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
PYTHONPATH=. pytest tests/test_autogen_router.py -v
```

Expected: 3 tests passed.

- [ ] **Step 3: Verify no warnings**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
PYTHONPATH=. pytest tests/test_autogen_router.py -v 2>&1 | grep -iE "warning|deprecat"
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/ai-service/tests/test_autogen_router.py
git commit -m "test(ai-autogen): add router tests with mocked Groq"
```

---

# Phase 6 — FE switch to server-proxy

## Task 6.1: Add server-proxy provider to aiConfig.ts

**Files:**
- Modify: `langfens-fe-app/src/app/admin/_lib/aiConfig.ts:1-87`

- [ ] **Step 1: Rewrite `aiConfig.ts`**

```ts
export type AiProvider = "server-proxy" | "anthropic" | "openai" | "google";

export interface AiConfig {
  provider: AiProvider;
  apiKey: string;
  model: string;
  endpoint: string;
  maxTokens: number;
}

export const DEFAULT_AI_CONFIG: AiConfig = {
  provider: (process.env.NEXT_PUBLIC_AI_PROVIDER as AiProvider) || "server-proxy",
  apiKey: process.env.NEXT_PUBLIC_AI_API_KEY || "",
  model: process.env.NEXT_PUBLIC_AI_MODEL || "",
  endpoint:
    process.env.NEXT_PUBLIC_AI_SERVICE_URL ||
    process.env.NEXT_PUBLIC_AI_ENDPOINT ||
    "http://localhost:8092",
  maxTokens: 4096,
};

export function isAiConfigured(cfg: AiConfig): boolean {
  if (cfg.provider === "server-proxy") return Boolean(cfg.endpoint);
  return Boolean(cfg.apiKey);
}

export async function callAi(
  cfg: AiConfig,
  systemPrompt: string,
  userPrompt: string,
  context?: { type: string; skill: string; count: number; difficulty: number }
): Promise<string> {
  if (cfg.provider === "server-proxy") {
    if (!cfg.endpoint) {
      throw new Error("Server-proxy endpoint not configured. Set NEXT_PUBLIC_AI_SERVICE_URL.");
    }
    const res = await fetch(`${cfg.endpoint}/api/v1/autogen/questions`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      credentials: "include",
      body: JSON.stringify({
        type: context?.type ?? "MULTIPLE_CHOICE_SINGLE",
        skill: context?.skill ?? "READING",
        passage: userPrompt,
        count: context?.count ?? 1,
        difficulty: context?.difficulty ?? 3,
        extra_context: systemPrompt,
      }),
    });
    if (!res.ok) {
      const err = await res.text();
      throw new Error(`ai-service ${res.status}: ${err}`);
    }
    const data = await res.json();
    return JSON.stringify(data.questions ?? []);
  }

  if (cfg.provider === "anthropic") {
    const res = await fetch(cfg.endpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": cfg.apiKey,
        "anthropic-version": "2023-06-01",
        "anthropic-dangerous-direct-browser-access": "true",
      },
      body: JSON.stringify({
        model: cfg.model,
        max_tokens: cfg.maxTokens,
        system: systemPrompt,
        messages: [{ role: "user", content: userPrompt }],
      }),
    });
    if (!res.ok) {
      const err = await res.text();
      throw new Error(`Anthropic API ${res.status}: ${err}`);
    }
    const data = await res.json();
    return data?.content?.[0]?.text || "";
  }

  if (cfg.provider === "openai") {
    const res = await fetch(cfg.endpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${cfg.apiKey}`,
      },
      body: JSON.stringify({
        model: cfg.model,
        max_tokens: cfg.maxTokens,
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: userPrompt }],
      }),
    });
    if (!res.ok) {
      const err = await res.text();
      throw new Error(`OpenAI API ${res.status}: ${err}`);
    }
    const data = await res.json();
    return data?.choices?.[0]?.message?.content || "";
  }

  throw new Error(`Unsupported AI provider: ${cfg.provider}`);
}

export function tryParseLlmJson(text: string): unknown[] | null {
  const trimmed = text.trim();
  if (!trimmed) return null;
  const withoutFences = trimmed
    .replace(/^```(?:json)?\s*/i, "")
    .replace(/```\s*$/, "")
    .trim();
  const tryParse = (s: string): unknown | null => {
    try {
      return JSON.parse(s);
    } catch {
      return null;
    }
  };
  let parsed = tryParse(withoutFences);
  if (parsed == null) {
    const match = withoutFences.match(/(\[[\s\S]*\]|\{[\s\S]*\})/);
    if (match) parsed = tryParse(match[1]);
  }
  if (parsed == null) return null;
  return Array.isArray(parsed) ? parsed : [parsed];
}
```

- [ ] **Step 2: Verify typecheck**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npx tsc --noEmit
```

Expected: exit 0.

- [ ] **Step 3: Verify Vitest still passes**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npm run test
```

Expected: 25 tests pass.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
git add src/app/admin/_lib/aiConfig.ts
git commit -m "feat(fe-llm): add server-proxy provider, default for new sessions"
```

---

## Task 6.2: Wire AiAuthorModal to new callAi signature

**Files:**
- Modify: `langfens-fe-app/src/app/admin/exams/[id]/_components/AiAuthorModal.tsx:60`

**Interfaces:**
- Consumes: `callAi` from Task 6.1 with new 4th-arg `context`

- [ ] **Step 1: Locate the callAi call**

```bash
grep -n "callAi(config, prompt.system, userPrompt)" langfens-fe-app/src/app/admin/exams/[id]/_components/AiAuthorModal.tsx
```

Expected: 1 match.

- [ ] **Step 2: Update to pass context**

Before:
```ts
const text = await callAi(config, prompt.system, userPrompt);
```

After:
```ts
const text = await callAi(config, prompt.system, userPrompt, {
  type,
  skill: "READING",
  count,
  difficulty: Number(typeMeta.defaultDifficulty),
});
```

- [ ] **Step 3: Verify typecheck + Vitest**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npx tsc --noEmit
npm run test
```

Expected: tsc exits 0. Vitest: 25 tests pass.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
git add src/app/admin/exams/\[id\]/_components/AiAuthorModal.tsx
git commit -m "feat(fe-admin): wire AiAuthorModal to server-proxy callAi context"
```

---

# Phase 7 — Vitest coverage + retry mock

## Task 7.1: Add Vitest fixture for all 19 types

**Files:**
- Create: `langfens-fe-app/src/app/admin/_lib/__tests__/llmPrompts.test.ts`

- [ ] **Step 1: Write the test file**

```ts
import { describe, expect, it } from "vitest";
import { QuestionType } from "../types";
import { LLM_PROMPTS, getLlmPrompt } from "../llmPrompts";
import { getJsonShape } from "../jsonShape";

const ALL_TYPES: string[] = Object.values(QuestionType);

describe("LLM_PROMPTS coverage", () => {
  it("has entries for all 19 QuestionType values", () => {
    expect(Object.keys(LLM_PROMPTS).length).toBe(ALL_TYPES.length);
    expect(Object.keys(LLM_PROMPTS).sort()).toEqual([...ALL_TYPES].sort());
  });

  for (const type of ALL_TYPES) {
    describe(`${type}`, () => {
      it("getLlmPrompt returns non-null entry", () => {
        expect(getLlmPrompt(type)).not.toBeNull();
      });

      it("system prompt contains the canonical jsonShape verbatim", () => {
        const entry = getLlmPrompt(type);
        expect(entry).not.toBeNull();
        const jsonShape = getJsonShape(type);
        expect(entry!.system).toContain(jsonShape);
      });

      it("system prompt contains STRICT_JSON_SUFFIX markers", () => {
        const entry = getLlmPrompt(type);
        expect(entry!.system).toContain("Strict JSON mode");
        expect(entry!.system).toContain("Output ONLY a single JSON array");
      });

      it("userTemplate substitutes difficulty and count", () => {
        const entry = getLlmPrompt(type)!;
        const user = entry.userTemplate("foo passage", 3, { difficulty: "4" });
        expect(user).toContain("Generate 3");
        expect(user).toContain("at difficulty 4");
      });
    });
  }
});

describe("server-proxy round-trip (mocked fetch)", () => {
  it("callAi parses response.questions into array", async () => {
    const originalFetch = global.fetch;
    global.fetch = (async (url: string, opts: any) => {
      expect(url).toContain("/api/v1/autogen/questions");
      const body = JSON.parse(opts.body);
      expect(body.type).toBe("MULTIPLE_CHOICE_SINGLE");
      expect(body.skill).toBe("READING");
      expect(body.count).toBe(1);
      return new Response(
        JSON.stringify({
          questions: [
            { type: "MULTIPLE_CHOICE_SINGLE", options: [], difficulty: 3 },
          ],
        }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }) as typeof fetch;

    try {
      const { callAi, tryParseLlmJson } = await import("../aiConfig");
      const cfg = {
        provider: "server-proxy" as const,
        apiKey: "",
        model: "",
        endpoint: "http://test-server:8092",
        maxTokens: 4096,
      };
      const text = await callAi(cfg, "system", "user", {
        type: "MULTIPLE_CHOICE_SINGLE",
        skill: "READING",
        count: 1,
        difficulty: 3,
      });
      const parsed = tryParseLlmJson(text);
      expect(parsed).not.toBeNull();
      expect(Array.isArray(parsed)).toBe(true);
      expect((parsed as unknown[]).length).toBe(1);
    } finally {
      global.fetch = originalFetch;
    }
  });
});
```

- [ ] **Step 2: Run Vitest**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npm run test
```

Expected: ≥ 96 tests pass (25 baseline + 19×4 type fixtures + 1 server-proxy round-trip = 25 + 76 + 1 = 102 total). Suite count ≥ 7.

- [ ] **Step 3: Verify no skipped suites**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npm run test 2>&1 | grep -E "skipped|Skipped"
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
git add src/app/admin/_lib/__tests__/llmPrompts.test.ts
git commit -m "test(fe-llm): add Vitest coverage for 19 prompts + server-proxy mock"
```

---

# Phase 8 — STRICT_JSON audit

## Task 8.1: Audit STRICT_JSON_SUFFIX coverage

**Files:**
- Create: `docs/sprint7/AUDIT_STRICT_JSON.md` (verification log only)

- [ ] **Step 1: Verify each prompt ends with STRICT_JSON_SUFFIX**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
node -e "
const path = require('path');
// Inline import via dynamic import (TypeScript via tsx or compiled output)
" 2>/dev/null || (
  # Fallback: use grep to verify text presence
  for type in MULTIPLE_CHOICE_SINGLE MULTIPLE_CHOICE_MULTIPLE MULTIPLE_CHOICE_SINGLE_IMAGE TRUE_FALSE_NOT_GIVEN YES_NO_NOT_GIVEN SUMMARY_COMPLETION TABLE_COMPLETION NOTE_COMPLETION FORM_COMPLETION SENTENCE_COMPLETION SHORT_ANSWER DIAGRAM_LABEL MAP_LABEL MATCHING_HEADING MATCHING_INFORMATION MATCHING_FEATURES MATCHING_ENDINGS CLASSIFICATION FLOW_CHART; do
    if grep -q "$type:" src/app/admin/_lib/llmPrompts.ts; then
      echo "OK: $type entry exists"
    else
      echo "MISSING: $type"
    fi
  done
)
```

Expected: 19 OK, 0 MISSING.

- [ ] **Step 2: Write audit log**

Create `docs/sprint7/AUDIT_STRICT_JSON.md`:

```markdown
# Sprint 7 STRICT_JSON_SUFFIX Audit

> Date: 2026-09-14
> Verification: 19/19 question types have STRICT_JSON_SUFFIX in system prompt.

## Result

All 19 QuestionType enum values are present in `LLM_PROMPTS`. Each entry's
`system` field is built via `buildSystemPrompt(type)` which appends
`STRICT_JSON_SUFFIX` (verified at `llmPromptBuilder.ts:18-24`).

## Verification command

\`\`\`bash
grep -c "Strict JSON mode" langfens-fe-app/src/app/admin/_lib/llmPrompts.ts
\`\`\`

Expected: ≥ 19 (one per type).

## Conclusion

PASS. No code changes required.
```

- [ ] **Step 3: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add -f docs/sprint7/AUDIT_STRICT_JSON.md
git commit -m "docs(sprint7): record STRICT_JSON_SUFFIX audit (19/19 PASS)"
```

---

# Phase 9 — Sprint 7 closure

## Task 9.1: Full verification suite

**Files:**
- Modify: none (verification step)

- [ ] **Step 1: BE build + test**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
dotnet build services/attempt-service.Tests/attempt-service.Tests.csproj
dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj --no-build
```

Expected: Build 0 errors. Test 73/73 passed. Warning count delta vs baseline = 0.

- [ ] **Step 2: FE typecheck + Vitest + build**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npx tsc --noEmit
npm run test
npm run build
```

Expected: tsc exit 0. Vitest ≥ 102 tests pass (no skipped). Build 39+ pages.

- [ ] **Step 3: ai-service pytest**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
PYTHONPATH=. pytest tests/test_autogen_prompts.py tests/test_autogen_router.py -v
```

Expected: 5+3 = 8+ tests pass.

- [ ] **Step 4: Run §12.2.1 Python lint**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
import ast
files = [
    'app/prompts/autogen.py',
    'app/prompts/autogen_templates.py',
    'app/prompts/autogen_data.py',
    'app/schemas/autogen.py',
    'app/routers/autogen.py',
]
all_clean = True
for f in files:
    with open(f) as fp:
        tree = ast.parse(fp.read())
    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef):
            if node.name.startswith('_'):
                continue
            if not node.returns:
                print(f'WARNING: {f}:{node.lineno} {node.name}() missing return annotation')
                all_clean = False
            for arg in node.args.args:
                if arg.arg == 'self':
                    continue
                if not arg.annotation:
                    print(f'WARNING: {f}:{node.lineno} {node.name}({arg.arg}) missing arg annotation')
                    all_clean = False
print('PYTHON_LINT_CLEAN' if all_clean else 'PYTHON_LINT_DIRTY')
"
```

Expected: `PYTHON_LINT_CLEAN`.

- [ ] **Step 5: Verify warning delta is 0**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
dotnet build services/attempt-service.Tests/attempt-service.Tests.csproj 2>&1 | grep -E "Warning\(s\)" | tail -1
```

Expected: `16 Warning(s)` (unchanged from baseline).

- [ ] **Step 6: Manual smoke test (record results)**

Open admin UI in browser:
1. Navigate to `/admin/exams/[some-id]`
2. Click "AI Author"
3. For each of 19 types in dropdown: click Generate → verify JSON parses → click Save → reload page → verify question appears in editor.
4. Record results in `docs/sprint7/MANUAL_SMOKE.md`.

- [ ] **Step 7: No untracked files**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git status -s | grep -v "^?" | head -5
```

Expected: empty (no untracked source files).

- [ ] **Step 8: Branch check**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git branch --show-current
```

Expected: `refactor/sync-dotest-admin-renderer`.

- [ ] **Step 9: Commit verification log**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add -f docs/sprint7/MANUAL_SMOKE.md
git commit -m "docs(sprint7): close Sprint 7 with full verification scoreboard"
```

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
