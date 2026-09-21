# Sprint 7 STRICT_JSON Audit

> **Execution Date:** 2026-09-21 (Plan specification date: 2026-09-14)  
> **Verification Status:** 19/19 Question types verified (100% PASS)  
> **Scope:** Frontend prompt builder (`langfens-fe-app`) and AI service mirror (`services/ai-service`).

---

## 1. Executive Summary

All 19 IELTS `QuestionType` entries have strict JSON mode instructions appended to their generated system prompts across both the Next.js frontend and the FastAPI AI service mirror.

- **Frontend coverage:** 19/19 question types in `LLM_PROMPTS` end with `STRICT_JSON_INSTRUCTION`.
- **Backend mirror coverage:** 19/19 question types in `JSON_SHAPES` end with `STRICT_JSON_SUFFIX`.
- **Unit test status:** 59/59 Vitest assertions PASS, 14/14 Pytest assertions PASS.
- **Code modification required:** None (PASS).

---

## 2. Architecture & Implementation Mapping

### 2.1. Frontend (`langfens-fe-app`)
- **Prompts Dictionary:** `src/app/admin/_lib/llmPrompts.ts` declares `LLM_PROMPTS` mapping all 19 `QuestionType` enum members.
- **System Prompt Assembly:** Each entry delegates to `buildSystemPrompt(QuestionType.<Type>)` in `src/app/admin/_lib/llmPromptBuilder.ts:28-37`.
- **Strict JSON Instruction:** Line 36 appends `STRICT_JSON_INSTRUCTION` defined in `src/app/admin/_lib/jsonShape.ts`:
  ```ts
  return `${schema.systemProse}\n\n${STRICT_JSON_INSTRUCTION}`;
  ```
- **Constraint Contract:** `STRICT_JSON_INSTRUCTION` enforces:
  - Output ONLY a single JSON array.
  - No prose, no markdown fences, no explanation.
  - Strict payload schema matching `QuestionType`.
  - Fallback error payload `{"error": "reason"}` if generation fails.

### 2.2. AI Service Python Mirror (`services/ai-service`)
- **Prompts Builder:** `app/prompts/autogen.py` defines `build_system_prompt(qtype, json_shape, constraints)`.
- **Suffix Constant:** Appends `STRICT_JSON_SUFFIX` from `app/prompts/autogen_templates.py`:
  - Enforces `Strict JSON mode`.
  - Enforces difficulty integer in range `[1, 5]`.
  - Enforces JSON-only output without markdown fences.

---

## 3. Verification Commands & Results

### 3.1. Frontend Vitest Runtime Test (Authoritative)
The test suite `src/app/admin/_lib/__tests__/llmPrompts.test.ts` iterates through all 19 `QuestionType` enum values and validates the presence of strict JSON markers:

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npx vitest run src/app/admin/_lib/__tests__/llmPrompts.test.ts
```

**Result:**
```text
✓ src/app/admin/_lib/__tests__/llmPrompts.test.ts (59 tests)
Test Files  1 passed (1)
Tests       59 passed (59)
```

### 3.2. Frontend Runtime Suffix Verification
Validates that `prompt.system.endsWith(STRICT_JSON_INSTRUCTION)` evaluates to `true` for each entry:

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npx tsx -e '
import { LLM_PROMPTS } from "./src/app/admin/_lib/llmPrompts";
import { STRICT_JSON_INSTRUCTION } from "./src/app/admin/_lib/jsonShape";

const entries = Object.entries(LLM_PROMPTS);
let pass = 0;
for (const [key, prompt] of entries) {
  if (prompt.system.endsWith(STRICT_JSON_INSTRUCTION)) pass++;
}
console.log(`FE System Prompts ending with STRICT_JSON_INSTRUCTION: ${pass}/${entries.length}`);
'
```

**Result:**
```text
FE System Prompts ending with STRICT_JSON_INSTRUCTION: 19/19
```

### 3.3. AI Service Pytest Test
Validates server-side prompt generation and autogen router:

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
./.venv/bin/pytest tests/test_autogen_prompts.py tests/test_autogen_router.py
```

**Result:**
```text
tests/test_autogen_prompts.py .......                                    [ 50%]
tests/test_autogen_router.py .......                                     [100%]
14 passed, 104 warnings in 1.28s
```

### 3.4. AI Service Runtime Suffix Verification
Validates that Python prompt generator ends with `STRICT_JSON_SUFFIX` for all 19 question types:

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
PYTHONPATH=services/ai-service ./services/ai-service/.venv/bin/python -c '
from app.prompts.autogen_data import JSON_SHAPES, get_constraints
from app.prompts.autogen import build_system_prompt
from app.prompts.autogen_templates import STRICT_JSON_SUFFIX

pass_count = sum(
    1 for qtype, shape in JSON_SHAPES.items()
    if build_system_prompt(qtype, shape, get_constraints(qtype)).endswith(STRICT_JSON_SUFFIX)
)
print(f"AI Service System Prompts ending with STRICT_JSON_SUFFIX: {pass_count}/{len(JSON_SHAPES)}")
'
```

**Result:**
```text
AI Service System Prompts ending with STRICT_JSON_SUFFIX: 19/19
```

---

## 4. Question Types Audited

| # | QuestionType Enum | FE `LLM_PROMPTS` | AI Service `JSON_SHAPES` | Suffix Attached |
|---|---|:---:|:---:|:---:|
| 1 | `MULTIPLE_CHOICE_SINGLE` | PASS | PASS | YES |
| 2 | `MULTIPLE_CHOICE_MULTIPLE` | PASS | PASS | YES |
| 3 | `MULTIPLE_CHOICE_SINGLE_IMAGE` | PASS | PASS | YES |
| 4 | `TRUE_FALSE_NOT_GIVEN` | PASS | PASS | YES |
| 5 | `YES_NO_NOT_GIVEN` | PASS | PASS | YES |
| 6 | `SUMMARY_COMPLETION` | PASS | PASS | YES |
| 7 | `TABLE_COMPLETION` | PASS | PASS | YES |
| 8 | `NOTE_COMPLETION` | PASS | PASS | YES |
| 9 | `FORM_COMPLETION` | PASS | PASS | YES |
| 10 | `SENTENCE_COMPLETION` | PASS | PASS | YES |
| 11 | `SHORT_ANSWER` | PASS | PASS | YES |
| 12 | `DIAGRAM_LABEL` | PASS | PASS | YES |
| 13 | `MAP_LABEL` | PASS | PASS | YES |
| 14 | `MATCHING_HEADING` | PASS | PASS | YES |
| 15 | `MATCHING_INFORMATION` | PASS | PASS | YES |
| 16 | `MATCHING_FEATURES` | PASS | PASS | YES |
| 17 | `MATCHING_ENDINGS` | PASS | PASS | YES |
| 18 | `CLASSIFICATION` | PASS | PASS | YES |
| 19 | `FLOW_CHART` | PASS | PASS | YES |

---

## 5. Conclusion

**PASS.** All 19 IELTS question types satisfy the Strict JSON mode prompt contract. Zero regressions, zero breaking changes.
