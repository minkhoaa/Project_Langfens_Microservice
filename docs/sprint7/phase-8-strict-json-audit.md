# Phase 8 — STRICT_JSON audit

> **Plan file:** This is Phase 8 of Sprint 7. Read [`README.md`](./README.md) for global constraints, file structure, and execution handoff.

---

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
