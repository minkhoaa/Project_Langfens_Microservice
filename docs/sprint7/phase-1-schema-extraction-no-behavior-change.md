# Phase 1 — Schema Extraction (no behavior change)

> **Plan file:** This is Phase 1 of Sprint 7. Read [`README.md`](./README.md) for global constraints, file structure, and execution handoff.

---

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
