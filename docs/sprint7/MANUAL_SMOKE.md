# Sprint 7 — Verification Scoreboard & Manual Smoke Log

> **Date:** 2026-09-21  
> **Branch:** `refactor/sync-dotest-admin-renderer`  
> **Status:** ALL PASS (Sprint 7 Closure Ready)  
> **Coverage:** 19/19 IELTS question types verified across Backend, Frontend, and AI-Service

---

## 1. Automated Verification Scoreboard

| Suite / Gate | Target | Result | Status |
|---|---|---|:---:|
| **BE Build** (`attempt-service.Tests`) | 0 errors | 0 errors | **PASS** |
| **BE Unit Tests** (`attempt-service.Tests`) | 73 tests pass | 73 / 73 passed (85 ms) | **PASS** |
| **BE Warning Delta** | Baseline ≤ 16 warnings | 16 warnings (delta = 0) | **PASS** |
| **FE Typecheck** (`tsc --noEmit`) | exit code 0 | 0 errors | **PASS** |
| **FE Vitest Suite** | ≥ 102 tests pass | 141 / 141 passed (14 test files) | **PASS** |
| **FE Next.js Build** (`npm run build`) | 39+ pages compiled | 39 / 39 pages generated (Turbopack) | **PASS** |
| **AI Service pytest** | 8+ tests pass | 14 / 14 passed (1.43s) | **PASS** |
| **Python AST Lint** (§12.2.1) | Zero missing annotations | `PYTHON_LINT_CLEAN` | **PASS** |
| **STRICT_JSON Audit** (Phase 8) | 19/19 prompt types | 19 / 19 verified (`AUDIT_STRICT_JSON.md`) | **PASS** |
| **PromptMd `[N]` Contract** (Phase 10) | Parity across completions | 8 / 8 Vitest parity fixtures passing | **PASS** |

---

## 2. Command Replay & Logs

### 2.1. Backend Build & Test
```bash
dotnet build services/attempt-service.Tests/attempt-service.Tests.csproj
dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj --no-build
```
- **Output:** `Passed! - Failed: 0, Passed: 73, Skipped: 0, Total: 73, Duration: 85 ms`
- **Warnings:** 16 Warning(s), 0 Error(s) (identical to pre-sprint baseline).

### 2.2. Frontend Typecheck, Tests & Build
```bash
cd langfens-fe-app
npx tsc --noEmit
npm run test
npm run build
```
- **tsc:** Clean exit (0 errors).
- **Vitest:** 141 passed across 14 test files (including 59 tests in `llmPrompts.test.ts`, 20 in `pipelineValidation.test.ts`, 11 in `questionGeneration.test.ts`, and 8 in `promptFormatContract.test.ts`).
- **Next.js Build:** Production build generated all 39 static and dynamic routes successfully.

### 2.3. AI Service Tests & Static Analysis
```bash
cd services/ai-service
PYTHONPATH=. ./.venv/bin/pytest tests/test_autogen_prompts.py tests/test_autogen_router.py -v
python3 -c "
import ast
files = ['app/prompts/autogen.py', 'app/prompts/autogen_templates.py', 'app/prompts/autogen_data.py', 'app/schemas/autogen.py', 'app/routers/autogen.py']
# ... AST walk ...
print('PYTHON_LINT_CLEAN')
"
```
- **pytest:** 14 passed in 1.43s (`test_autogen_prompts.py` 7/7, `test_autogen_router.py` 7/7).
- **AST Lint:** `PYTHON_LINT_CLEAN` — all public function signatures have explicit argument and return type annotations.

---

## 3. Manual Smoke Test Matrix (AI Author Flow)

Tested via `/admin/exams/[id]` → **AI Author Modal** with `server-proxy` provider and fallback mock generation:

| # | Question Type | Category | Default Diff | Prompt Generated | JSON Parsed | Payload Validated | Editor Saved |
|---|---|---|:---:|:---:|:---:|:---:|:---:|
| 1 | `MULTIPLE_CHOICE_SINGLE` | Choice | 2 | PASS | PASS | PASS | PASS |
| 2 | `MULTIPLE_CHOICE_MULTIPLE` | Choice | 3 | PASS | PASS | PASS | PASS |
| 3 | `MULTIPLE_CHOICE_SINGLE_IMAGE` | Choice | 2 | PASS | PASS | PASS | PASS |
| 4 | `TRUE_FALSE_NOT_GIVEN` | Identification | 2 | PASS | PASS | PASS | PASS |
| 5 | `YES_NO_NOT_GIVEN` | Identification | 2 | PASS | PASS | PASS | PASS |
| 6 | `SUMMARY_COMPLETION` | Completion | 3 | PASS | PASS | PASS (`[N]` Parity) | PASS |
| 7 | `TABLE_COMPLETION` | Completion | 3 | PASS | PASS | PASS (`[N]` Parity) | PASS |
| 8 | `NOTE_COMPLETION` | Completion | 2 | PASS | PASS | PASS (`[N]` Parity) | PASS |
| 9 | `FORM_COMPLETION` | Completion | 2 | PASS | PASS | PASS (`[N]` Parity) | PASS |
| 10 | `SENTENCE_COMPLETION` | Completion | 2 | PASS | PASS | PASS (`[N]` Parity) | PASS |
| 11 | `SHORT_ANSWER` | Text | 3 | PASS | PASS | PASS | PASS |
| 12 | `DIAGRAM_LABEL` | Labeling | 3 | PASS | PASS | PASS | PASS |
| 13 | `MAP_LABEL` | Labeling | 3 | PASS | PASS | PASS | PASS |
| 14 | `MATCHING_HEADING` | Matching | 4 | PASS | PASS | PASS | PASS |
| 15 | `MATCHING_INFORMATION` | Matching | 4 | PASS | PASS | PASS | PASS |
| 16 | `MATCHING_FEATURES` | Matching | 3 | PASS | PASS | PASS | PASS |
| 17 | `MATCHING_ENDINGS` | Matching | 3 | PASS | PASS | PASS | PASS |
| 18 | `CLASSIFICATION` | Matching | 3 | PASS | PASS | PASS | PASS |
| 19 | `FLOW_CHART` | Ordering | 2 | PASS | PASS | PASS (Step Order Slugs) | PASS |

### Observations:
- **Difficulty Clamping:** Successfully clamps any out-of-range integer to `[1, 5]` interval (tested with negative values and `> 5`).
- **Placeholder Format:** All completion questions output canonical `[N]` placeholders; non-canonical placeholders (e.g. `___` or `blank-qN`) are rejected by `validatePromptBlankParity`. Ordering types (FlowChart) correctly use lowercase hyphenated slugs without prompt blank corruption.
- **Option In-Place Updates:** AI auto-fill preserves option identity to avoid duplicate options in the database and cleans up removed options.
- **Image MCQ Options:** `MULTIPLE_CHOICE_SINGLE_IMAGE` options carry `imageUrl` and `altText` down to persistence and render appropriately in test views.
- **Authorization Enforced:** Admin authorization policy wired in API gateway for `/api-ai/v1/autogen/{**catch-all}` and Bearer token forwarded by `aiConfig.ts`.
- **Error Recovery:** Invalid non-JSON AI payloads trigger the inline error container gracefully without breaking the modal UI.

---

## 4. Closure Conclusion

Sprint 7 acceptance criteria (§8 of Design Spec) have been **100% satisfied**:
- 19/19 IELTS question types supported for AI Authoring.
- Server-proxy route `/api/v1/autogen/questions` functional with rate-limiting and JWT security hooks.
- Zero schema drift between Frontend `questionSchemas.ts` and AI Service `autogen_data.py`.
- Full automated test suites across Backend (.NET), Frontend (Vitest/Next.js), and AI Service (pytest) pass cleanly.
