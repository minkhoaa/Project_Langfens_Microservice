# Phase 2 — Extend prompts to 19 types

> **Plan file:** This is Phase 2 of Sprint 7. Read [`README.md`](./README.md) for global constraints, file structure, and execution handoff.

---

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
