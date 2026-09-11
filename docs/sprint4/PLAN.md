# Sprint 4 Execution Plan

> Generated: 2026-09-11
> Source scope: HANDOFF_SPRINT4.md §2 (10 active backlog items)
> Audience: fresh session executing Sprint 4

## §1 — Scope & Non-Goals

In-scope items (numbering matches HANDOFF_SPRINT4.md §2):
- Item 4 — MAP_LABEL "1:" typo

- Item 1 — Zero-Idx residual rows
- Item 2 — 18 blank-q rows
- Item 3 — Seeder UUID cleanup ← DEFERRED to Sprint 5 (see §2 for rationale)
- Item 6 — DRY cleanAnswer
- Item 7 — DRY buildQuestion
- Item 8 — Vitest test infrastructure
- Item 9 — G11 dispatcher UI fallback
- Item 10 — Migration script naming clarification

Out-of-scope (explicit non-goals for Sprint 4):
- Item 3 (UUID seeder cleanup) — deferred to Sprint 5
- Any new feature work beyond §2 backlog
- Production deploy / Docker image rebuild
- Cross-service refactors not in §2

## §2 — Key Decisions & Rationale

**Item 4 — MAP_LABEL "1:" typo**: Correct the schema example in `/home/khoa/Projects/langfens/langfens-fe-app/src/app/admin/_lib/questionSchemas.ts` at line 394 by replacing `"blankAcceptTexts": { "0": ["library"], "1:": ["park"] }` with valid 1-indexed keys `"1"` and `"2"`. Scope is deliberately restricted to this single documentation fixture because runtime execution fixtures are already 1-indexed. The change carries near-zero risk and is validated by running `npx tsc --noEmit`.

**Item 11 — Document rotation**: Preserve `/home/khoa/Projects/langfens/Project_Langfens_Microservice/HANDOFF_SPRINT3.md` as an immutable historical record and designate `/home/khoa/Projects/langfens/Project_Langfens_Microservice/HANDOFF_SPRINT4.md` as the active operational baseline. Scope is limited to document lifecycle governance and baseline commit SHA verification across both repositories. Risk of executing against unverified commits is mitigated by running explicit `git log` and `git branch` checks before initiating subsequent tasks.

**Item 1 — Zero-Idx residual rows**: Audit the 6 rows with `Idx = 0` in `ielts-reading-practice-1` and `ielts-reading-practice-2` within the `exam-db` questions table. Scope covers investigating whether these rows represent corrupt legacy ordinals or valid section-local zero-indexing (3 sections per exam = 6 section heads). Risk of corrupting valid exam section questions is mitigated by executing read-only SQL audits first and avoiding destructive deletion if ordinals are confirmed to be intentional section-relative offsets.

**Item 2 — 18 blank-q rows**: Audit and migrate completion-family questions in `mentor/*` and `mini-ielts*` exams still carrying `blank-q\d+` placeholder tokens or dict keys. Scope entails converting prompt text placeholders to `[N]` and stripping prefixes from dictionary keys, followed by executing `/home/khoa/Projects/langfens/Project_Langfens_Microservice/scripts/migrate_blank_keys_to_1_indexed.py` using live ports (32779/32780). Risk of breaking legacy exam answer keys is mitigated by using atomic database transactions and pre-migration dry runs.

**Item 3 — Seeder UUID cleanup (DEFERRED)**: UUID seeder cleanup touches 3 seeder files and would change live DB UUIDs on next seed run. Risk-to-value ratio is unfavorable during Sprint 4's refactor-heavy phase. Defer to Sprint 5 when refactor pressure is lower and dev workflow can absorb UUID changes.

**Item 6 — DRY cleanAnswer**: Consolidate duplicated regex answer-cleaning logic from `/home/khoa/Projects/langfens/langfens-fe-app/src/app/attempts/[attemptId]/utils.ts` and `/home/khoa/Projects/langfens/langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/common/QuestionPanel.tsx` into a central shared utility `/home/khoa/Projects/langfens/langfens-fe-app/src/lib/cleanAnswer.ts`. Scope strictly retains the G15 non-greedy allowlist behavior while standardizing slash-split pattern handling. Risk of altering answer string normalization in review screens is mitigated by dedicated unit tests executed via Vitest.

**Item 7 — DRY buildQuestion**: Extract the duplicated 50-line `buildQuestion(q: any): UiQuestion` function from `/home/khoa/Projects/langfens/langfens-fe-app/src/app/do-test/[skill]/[attemptId]/page.tsx` and `/home/khoa/Projects/langfens/langfens-fe-app/src/app/placement/[attemptId]/page.tsx` into `/home/khoa/Projects/langfens/langfens-fe-app/src/lib/buildQuestion.ts`. Scope addresses question object normalization and `uiKind` mapping without altering individual card component internals. Risk of UI render regression is mitigated by TypeScript type checking and existing page-level integration flows.

**Item 8 — Vitest test infrastructure**: Install `vitest` into `/home/khoa/Projects/langfens/langfens-fe-app/package.json`, add `/home/khoa/Projects/langfens/langfens-fe-app/vitest.config.ts`, configure an npm `test` script, and un-skip `ResultV3Review.parseUserAnswer.test.ts` and `CompletionCard.sort.test.tsx`. Scope focuses solely on frontend unit/component test execution without modifying existing Playwright e2e configs. Risk of dependency incompatibility with Next.js 16/React 19 is mitigated by selecting compatible Vitest versions and configuring alias paths in `vitest.config.ts`.

**Item 9 — G11 dispatcher UI fallback**: Replace silent empty rendering and unhandled question logging in `/home/khoa/Projects/langfens/langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/common/QuestionPanel.tsx` and `_components/QuestionCard.tsx` with an explicit fallback card stating "Unsupported question type: [TYPE]". Scope is strictly presentational for unhandled backend question types and does not touch existing registered question cards. Risk of visual disruption is mitigated by scoping the fallback to a clearly bounded error banner card.

**Item 10 — Migration script naming clarification**: Clarify the distinct operational scopes of `/home/khoa/Projects/langfens/Project_Langfens_Microservice/scripts/migrate_blank_placeholders.py` (which audits/migrates `[N]` text placeholders and strips `blank-q` prefixes in `exam-db`) and `/home/khoa/Projects/langfens/Project_Langfens_Microservice/scripts/migrate_blank_keys_to_1_indexed.py` (which shifts numeric JSONB keys 0→1 across both `exam-db` and `attempt-db`). Scope includes adding unambiguous module header documentation to both scripts and adding an explicit 'Live execution example' block to each script header showing required env vars (`PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD`, `PGDATABASE`, plus `EXAM_DB_PORT`/`ATTEMPT_DB_PORT` for the keys script). Risk of developer confusion leading to incorrect script execution is mitigated by documented examples with live…

## §3 — Dependency Graph

```mermaid
flowchart TD
    subgraph Phase 1 [Phase 1: Quick Wins]
        T11[Task 1.1: MAP_LABEL typo fix]
        T12[Task 1.2: Script doc & conn fix]

    end

    subgraph Phase 2 [Phase 2: Research & Audit]
        T21[Task 2.1: Audit zero-Idx rows]
        T22[Task 2.2: Audit 18 blank-q rows]
        T23[Task 2.3: Audit Group C gaps C1-C6]
    end

    subgraph Phase 3 [Phase 3: DB Hygiene]
        T31[Task 3.1: Resolve zero-Idx status]
        T32[Task 3.2: Migrate legacy blank-q rows]
    end

    subgraph Phase 4 [Phase 4: Test Infrastructure]
        T41[Task 4.1: Install & config Vitest]
        T42[Task 4.2: Un-skip existing tests]
    end

    subgraph Phase 5 [Phase 5: Engineering Refactors]
        T51[Task 5.1: DRY cleanAnswer & tests]
        T52[Task 5.2: DRY buildQuestion]
        T53[Task 5.3: G11 dispatcher fallback]
        T51 --> T53

    subgraph Phase 6 [Phase 6: Sprint 4 Closure]
        T61[Task 6.1: Full verification suite]
        T62[Task 6.2: Update HANDOFF_SPRINT4.md]
        T63[Task 6.3: Author HANDOFF_SPRINT5.md]
    end

    Phase 1 --> Phase 6
    Phase 2 --> Phase 3
    Phase 4 --> Phase 5
    Phase 3 --> Phase 6
    Phase 5 --> Phase 6
```

**Note:** Phase 2.3 (Group C audit) may surface REAL items that expand Phase 3 scope. If REAL findings emerge, treat them as new Phase 3.X sub-tasks. Default assumption: documentation-only, no DB writes needed.

### Critical Path Analysis
- **Parallel tracks**: Phase 1, Phase 2, and Phase 4 can start concurrently in a fresh session.
- **Serialization boundaries**:
  - Phase 3 strictly depends on Phase 2 audit findings before modifying database records.
  - Phase 5 strictly depends on Phase 4 test infrastructure so refactored helpers have immediate unit test protection.
  - Phase 6 requires all work across Phases 1, 3, and 5 to land before final verification and document closure.
  - Within Phase 5, T51 (DRY cleanAnswer) → T53 (G11 dispatcher fallback) must run sequentially because both edit `QuestionPanel.tsx`. T52 (DRY buildQuestion) can run in parallel with the T51 → T53 sequence (touches different files).
- **Longest Dependency Chain (Critical Path)**:
  `Phase 4 (Vitest setup) → Phase 5 (Engineering Refactors) → Phase 6 (Sprint 4 Closure)`. Total estimated duration: ~85 minutes.

### Pre-flight checks (before Phase 1)

- Confirm both repos on `refactor/sync-dotest-admin-renderer` branch and HEAD matches `25f1d29` (BE) / `1cb7ed0` (FE) via `git log --oneline -n 1`. (Sprint 3 closure pre-condition.)

## §4 — Phase Breakdown

### Phase 1: Quick Wins (typo + script doc)

#### Task 1.1: Fix MAP_LABEL "1:" typo in questionSchemas.ts (Item 4)
- **Worker flavor**: `fast`
- **File list**:
  - `/home/khoa/Projects/langfens/langfens-fe-app/src/app/admin/_lib/questionSchemas.ts`
- **Acceptance criteria**:
  - `grep -n '"1:":' /home/khoa/Projects/langfens/langfens-fe-app/src/app/admin/_lib/questionSchemas.ts` returns 0 matches.
  - Line 394 contains `"blankAcceptTexts": { "1": ["library"], "2": ["park"] }`.
  - Command `cd /home/khoa/Projects/langfens/langfens-fe-app && npx tsc --noEmit` exits with code 0.
- **Commit message suggestion**: `fix(fe-admin): correct MAP_LABEL example blankAcceptTexts key typo`
- **Estimated effort**: S (10 minutes)

#### Task 1.2: Clarify migration script scopes and fix connection kwargs (Item 10)
- **Worker flavor**: `fast`
- **File list**:
  - `/home/khoa/Projects/langfens/Project_Langfens_Microservice/scripts/migrate_blank_placeholders.py`
  - `/home/khoa/Projects/langfens/Project_Langfens_Microservice/scripts/migrate_blank_keys_to_1_indexed.py`
- **Acceptance criteria**:
  - Both scripts contain explicit docstrings in the first 30 lines distinguishing text placeholder migration (`migrate_blank_placeholders.py` — operates on `exam-db` only, modifies `BlankAcceptTexts` text values) from numeric JSONB key shifting (`migrate_blank_keys_to_1_indexed.py` — operates on both `exam-db` and `attempt-db`, shifts dict keys).
  - Both scripts contain a "Live execution example" block with concrete `export PGHOST=localhost PGPORT=32779 PGUSER=exam PGPASSWORD=exam PGDATABASE=exam-db` invocations (and analogous for `attempt-db`).
  - Running `PGHOST=localhost PGPORT=32779 PGUSER=exam PGPASSWORD=exam PGDATABASE=exam-db python3 /home/khoa/Projects/langfens/Project_Langfens_Microservice/scripts/migrate_blank_placeholders.py audit` (without `--mock`) exits with code 0.
- **Commit message suggestion**: `docs(scripts): document placeholder vs key migration scopes and fix psycopg2 kwargs`
- **Estimated effort**: S (15 minutes)


---

### Phase 2: Research & Audit (read-only — Group C, zero-Idx, blank-q)

#### Task 2.1: Audit 6 zero-Idx rows in ielts-reading-practice-{1,2} (Item 1)
- **Worker flavor**: `good`
- **File list**:
  - Read-only database inspection against `exam-db` container (`exam-db-server-7c03dc93`).
- **Verbatim SQL query**:
  ```sql
  SELECT e."Slug", s."Idx" AS section_idx, q."Idx" AS question_idx, q."Type", q."Id"::text, LEFT(q."PromptMd", 40) AS prompt_snippet
  FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" IN ('ielts-reading-practice-1', 'ielts-reading-practice-2') AND q."Idx" = 0
  ORDER BY e."Slug", s."Idx";
  ```
- **Acceptance criteria**:
  - Audit confirms exactly 6 rows with `Idx = 0` (1 row per section across 3 sections in practice-1 and 3 sections in practice-2).
  - Confirms ordinals represent section-local index restart (0-indexed per section), with no duplicated ordinals within any single section.
- **Commit message suggestion**: No commit required (read-only audit).
- **Estimated effort**: S (15 minutes)

#### Task 2.2: Audit 18 blank-q rows in mentor/* and mini-ielts* exams (Item 2)
- **Worker flavor**: `good`
- **File list**:
  - Read-only database inspection against `exam-db` container (`exam-db-server-7c03dc93`).
- **Verbatim SQL query**:
  ```sql
  SELECT e."Slug", s."Idx" AS section_idx, q."Idx" AS question_idx, q."Type", q."Id"::text, q."BlankAcceptTexts", q."BlankAcceptRegex"
  FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE q."PromptMd" LIKE '%blank-q%'
     OR q."BlankAcceptTexts"::text LIKE '%blank-q%'
     OR q."BlankAcceptRegex"::text LIKE '%blank-q%'
  ORDER BY e."Slug", q."Idx";
  ```
- **Acceptance criteria**:
  - Audit returns full list of affected rows (13-18 rows across `ielts-mentor-*` and `mini-ielts-*` slugs).
  - Records each row ID and maps legacy keys (e.g. `"blank-q27"`) to target 1-indexed completion keys.
- **Commit message suggestion**: No commit required (read-only audit).
- **Estimated effort**: S (15 minutes)

#### Task 2.3: Audit Group C gap items C1–C6 (Group C verification)
- **Worker flavor**: `good`
- **File list**:
  - Read-only audit across `exam-db` and `attempt-db`.
- **Verbatim SQL queries**:
  ```sql
  -- C1/C2: Questions with null or empty options where Type requires options
  SELECT q."Id", q."Type", COUNT(o."Id") AS option_count
  FROM exam_questions q
  LEFT JOIN exam_options o ON o."QuestionId" = q."Id"
  WHERE q."Type" IN ('MULTIPLE_CHOICE_SINGLE', 'MULTIPLE_CHOICE_MULTIPLE', 'TRUE_FALSE_NOT_GIVEN', 'YES_NO_NOT_GIVEN')
  GROUP BY q."Id", q."Type"
  HAVING COUNT(o."Id") = 0;

  -- C3/C4: Completion questions missing BlankAcceptTexts and BlankAcceptRegex
  SELECT q."Id", q."Type", q."PromptMd"
  FROM exam_questions q
  WHERE q."Type" LIKE '%COMPLETION' AND q."BlankAcceptTexts" IS NULL AND q."BlankAcceptRegex" IS NULL;

  -- C5/C6: Orphaned attempt_answer records pointing to nonexistent questions
  SELECT a."id", a."question_id"
  FROM attempt_answer a
  LEFT JOIN exam_questions q ON q."Id" = a."question_id"
  WHERE q."Id" IS NULL;
  ```
- **Acceptance criteria**:
- **Commit message suggestion**: No commit required (read-only audit).
- **Estimated effort**: M (20 minutes)

If REAL findings emerge (e.g., orphan `attempt_answer` rows requiring DELETE), escalate to lead engineer. Sprint 4 default: treat findings as documentation-only and defer DB fixes to Sprint 5 backlog.

---

### Phase 3: DB Hygiene (apply migration + DELETE residuals)

#### Task 3.1: Record resolution for zero-Idx rows (Item 1)
- **Worker flavor**: `fast`
- **File list**:
  - `/home/khoa/Projects/langfens/Project_Langfens_Microservice/docs/sprint4/AUDIT_zeroIdx.md` (new file created by Task 3.1)
- **Acceptance criteria**:
  - New file `/home/khoa/Projects/langfens/Project_Langfens_Microservice/docs/sprint4/AUDIT_zeroIdx.md` exists, contains the Phase 2.1 SQL query results verbatim, and concludes the 6 rows are valid section-local ordinals.
  - Re-run verification query returns 6 legitimate section-head rows:
    ```sql
    SELECT COUNT(*) FROM exam_questions q
    JOIN exam_sections s ON s."Id" = q."SectionId"
    JOIN exams e ON e."Id" = s."ExamId"
    WHERE e."Slug" IN ('ielts-reading-practice-1', 'ielts-reading-practice-2') AND q."Idx" = 0;
    ```
  - Result is exactly 6. Zero rows deleted because data is confirmed valid section-local numbering.
- **Commit message suggestion**: `docs(audit): record zero-Idx section-local ordinal validation`
- **Estimated effort**: S (10 minutes)

#### Task 3.2: Migrate legacy blank-q rows in exam-db (Item 2)
- **Worker flavor**: `good`
- **File list**:
  - `/home/khoa/Projects/langfens/Project_Langfens_Microservice/scripts/migrate_blank_placeholders.py`
  - `/home/khoa/Projects/langfens/Project_Langfens_Microservice/scripts/migrate_blank_keys_to_1_indexed.py`
- **Execution & verification queries**:
  - Apply placeholder migration:
    ```bash
    PGHOST=localhost PGPORT=32779 PGUSER=exam PGPASSWORD=exam PGDATABASE=exam-db \
      python3 /home/khoa/Projects/langfens/Project_Langfens_Microservice/scripts/migrate_blank_placeholders.py migrate --apply
    ```
    ```bash
    EXAM_DB_HOST=localhost EXAM_DB_PORT=32779 ATTEMPT_DB_HOST=localhost ATTEMPT_DB_PORT=32780 python3 /home/khoa/Projects/langfens/Project_Langfens_Microservice/scripts/migrate_blank_keys_to_1_indexed.py
    ```
  - Verbatim verification SQL query:
    ```sql
    SELECT COUNT(*) FROM exam_questions
    WHERE "PromptMd" LIKE '%blank-q%'
       OR "BlankAcceptTexts"::text LIKE '%blank-q%'
       OR "BlankAcceptTexts" ? '0';
    ```
- **Acceptance criteria**:
  - Verification query returns count = 0.
  - Script output reports `pre_texts_with_key_0: 0` and `post_texts_with_key_0: 0` on subsequent run (idempotent).
- **Commit message suggestion**: `chore(db): migrate legacy blank-q placeholder tokens and dict keys`
- **Estimated effort**: M (25 minutes)

---

### Phase 4: Test Infrastructure (Vitest install)

#### Task 4.1: Install Vitest and configure test runner (Item 8)
- **Worker flavor**: `good`
- **File list**:
  - `/home/khoa/Projects/langfens/langfens-fe-app/package.json`
  - `/home/khoa/Projects/langfens/langfens-fe-app/vitest.config.ts`
- **Acceptance criteria**:
  - File `/home/khoa/Projects/langfens/langfens-fe-app/vitest.config.ts` exists and configures `@` path alias to `./src`.
  - `/home/khoa/Projects/langfens/langfens-fe-app/package.json` contains `"vitest"` in `devDependencies` and `"test": "vitest run"` in `scripts`.
  - Command `cd /home/khoa/Projects/langfens/langfens-fe-app && npm run test` executes vitest without configuration errors.
  - `package.json` pins `"vitest": "^2.1.0"`, `"@vitejs/plugin-react": "^4.3.0"`, and `"happy-dom": "^15.0.0"` (or `"jsdom": "^25.0.0"`) as devDependencies.
  - Vitest config sets `test.environment` to `happy-dom` (or `jsdom`) and explicitly maps `@` to `./src` via `resolve.alias`.
- **Commit message suggestion**: `feat(fe-test): install vitest and configure test runner`
- **Estimated effort**: M (20 minutes)

#### Task 4.2: Un-skip existing test suites (Item 8)
- **Worker flavor**: `fast`
- **File list**:
  - `/home/khoa/Projects/langfens/langfens-fe-app/src/app/attempts/_components/__tests__/ResultV3Review.parseUserAnswer.test.ts`
  - `/home/khoa/Projects/langfens/langfens-fe-app/src/app/do-test/[skill]/[attemptId]/_components/cards/__tests__/CompletionCard.sort.test.tsx`
- **Acceptance criteria**:
  - `describe.skip` replaced with `describe` in both test files.
  - Command `cd /home/khoa/Projects/langfens/langfens-fe-app && npm run test` passes all tests with 0 failures and 0 skipped suites.
- **Commit message suggestion**: `test(fe-attempt): un-skip parseUserAnswer and CompletionCard sort unit tests`
- **Estimated effort**: S (10 minutes)

---

### Phase 5: Engineering Refactors (DRY cleanAnswer, DRY buildQuestion, G11 dispatcher)

#### Task 5.1: Consolidate cleanAnswer helper and add unit tests (Item 6)
- **Worker flavor**: `good`
- **File list**:
  - `/home/khoa/Projects/langfens/langfens-fe-app/src/lib/cleanAnswer.ts`
  - `/home/khoa/Projects/langfens/langfens-fe-app/src/lib/__tests__/cleanAnswer.test.ts`
  - `/home/khoa/Projects/langfens/langfens-fe-app/src/app/attempts/[attemptId]/utils.ts`
  - `/home/khoa/Projects/langfens/langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/common/QuestionPanel.tsx`
- **Acceptance criteria**:
  - `/home/khoa/Projects/langfens/langfens-fe-app/src/lib/cleanAnswer.ts` exports canonical `cleanAnswer(s: string | undefined): string`.
  - Both callers (`utils.ts` and `QuestionPanel.tsx`) import `cleanAnswer` from `@/lib/cleanAnswer` instead of defining local copies.
  - Test file `/home/khoa/Projects/langfens/langfens-fe-app/src/lib/__tests__/cleanAnswer.test.ts` covers prefix stripping, `D / D` split, and non-greedy word retention (`Reason:` intact).
  - Test `/home/khoa/Projects/langfens/langfens-fe-app/src/lib/__tests__/cleanAnswer.test.ts` includes an explicit G15 invariant assertion: `expect(cleanAnswer("Reason: foo")).toBe("foo")` (proves the non-greedy allowlist preserves `Reason:` prefix).
  - Command `cd /home/khoa/Projects/langfens/langfens-fe-app && npm run test` passes.
- **Commit message suggestion**: `refactor(fe-attempt): consolidate cleanAnswer into shared lib helper with tests`
- **Estimated effort**: M (25 minutes)

#### Task 5.2: Extract buildQuestion to shared lib (Item 7)
- **Worker flavor**: `good`
- **File list**:
  - `/home/khoa/Projects/langfens/langfens-fe-app/src/lib/buildQuestion.ts`
  - `/home/khoa/Projects/langfens/langfens-fe-app/src/app/do-test/[skill]/[attemptId]/page.tsx`
  - `/home/khoa/Projects/langfens/langfens-fe-app/src/app/placement/[attemptId]/page.tsx`
- **Acceptance criteria**:
  - Function `buildQuestion(q: any): UiQuestion` extracted to `/home/khoa/Projects/langfens/langfens-fe-app/src/lib/buildQuestion.ts`.
  - Both `page.tsx` files import `buildQuestion` from `@/lib/buildQuestion` and remove local definitions.
  - Command `cd /home/khoa/Projects/langfens/langfens-fe-app && npx tsc --noEmit` exits with code 0.
- **Commit message suggestion**: `refactor(fe-do-test): extract buildQuestion into shared lib utility`
- **Estimated effort**: M (25 minutes)

**Note:** Task 5.3 must run AFTER Task 5.1 because both touch `QuestionPanel.tsx`. Parallel execution causes merge conflicts.

#### Task 5.3: Implement G11 dispatcher UI fallback card (Item 9)
- **Worker flavor**: `fast`
- **File list**:
  - `/home/khoa/Projects/langfens/langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/common/QuestionPanel.tsx`
  - `/home/khoa/Projects/langfens/langfens-fe-app/src/app/do-test/[skill]/[attemptId]/_components/QuestionCard.tsx`
- **Acceptance criteria**:
  - When `TargetComponent` is undefined in `QuestionPanel.tsx` and `uiKind !== "matching_paragraph"`, `questionContent` renders a visible card container containing text `"Unsupported question type: [TYPE]"`.
  - When `QuestionCard.tsx` encounters an unknown type in `renderBody()`, fallback renders an element with text `"Unsupported question type: {t}"` instead of silent empty div.
  - Command `cd /home/khoa/Projects/langfens/langfens-fe-app && npx tsc --noEmit` exits with code 0.
- **Commit message suggestion**: `feat(fe-do-test): add visible UI fallback card for unsupported question types`
- **Estimated effort**: S (15 minutes)

---

### Phase 6: Sprint 4 Closure (verify, update doc, author Sprint 5 doc)

#### Task 6.1: Run full verification suite
- **Worker flavor**: `good`
- **File list**: Both repositories.
- **Acceptance criteria**:
  - Command `cd /home/khoa/Projects/langfens/Project_Langfens_Microservice && dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj --no-build` exits with code 0.
  - Command `cd /home/khoa/Projects/langfens/langfens-fe-app && npx tsc --noEmit` exits with code 0.
  - Command `cd /home/khoa/Projects/langfens/langfens-fe-app && npm run test` passes with 0 failures.
  - Live database check shows 0 rows with `BlankAcceptTexts ? '0'`.
- **Commit message suggestion**: No commit required (verification step).
- **Estimated effort**: S (15 minutes)

#### Task 6.2: Update HANDOFF_SPRINT4.md with closure status
- **Worker flavor**: `fast`
- **File list**:
  - `/home/khoa/Projects/langfens/Project_Langfens_Microservice/HANDOFF_SPRINT4.md`
- **Acceptance criteria**:
  - §0 state summary marks Sprint 4 completed.
  - §3 readiness checklist marks Items 4, 1, 2, 6, 7, 8, 9, 10 as DONE with commit SHAs, and Item 3 as DEFERRED.
- **Commit message suggestion**: `docs(handoff): close Sprint 4 and record verification baseline`
- **Estimated effort**: S (10 minutes)

#### Task 6.3: Author HANDOFF_SPRINT5.md
- **Worker flavor**: `good`
- **File list**:
  - `/home/khoa/Projects/langfens/Project_Langfens_Microservice/HANDOFF_SPRINT5.md`
- **Acceptance criteria**:
  - File `/home/khoa/Projects/langfens/Project_Langfens_Microservice/HANDOFF_SPRINT5.md` exists.
  - Defines Sprint 5 primary backlog item as Item 3 (Seeder UUID convention cleanup across `ReadingSeeder.cs`, `ListeningSeeder.cs`, `GeneratedReadingSeeder.cs`).
  - Records latest BE and FE commit SHAs from Sprint 4 closure.
- **Commit message suggestion**: `docs(handoff): author Sprint 5 handoff document with carryover backlog`
- **Estimated effort**: S (15 minutes)

## §5 — Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation | Owner |
|------|------------|--------|------------|-------|
| Vitest + Next.js 16/React 19 compatibility conflicts | Medium | Medium | Use standard `@vitejs/plugin-react` or lightweight Node environment without bundling entire Next.js runtime; configure path aliases via `vitest.config.ts`. | FE Worker |
| DB write impact on live user answers during migration | Very Low | High | Live audit (HANDOFF_SPRINT4.md §0) confirms 0 rows match `BlankAcceptTexts ? '0'` and `TextAnswer LIKE '%"0":%'`. Migration script is idempotent no-op today; would only become active if Sprint 4 introduces 0-idx rows (which audit says it won't). | DB Worker |
| 6 zero-Idx residuals may be intentional dev data (not actually wrong) | High | Low | Run read-only audit in Phase 2 before issuing any `DELETE` or `UPDATE`; confirm section-relative ordinals restart at 0 per section. | DB Worker |
| Refactor regressions in cleanAnswer and buildQuestion | Medium | High | Implement Vitest in Phase 4 prior to refactoring in Phase 5; write unit tests locking in G15 regex rules before caller migration. | FE Worker |
| Cross-session file conflicts if multiple workers edit same file | Medium | Medium | Strict Phase boundary enforcement; separate BE script updates from FE component work; coordinate caller edits sequentially. | Lead Engineer |

## §6 — Sprint 4 Closure Checklist

Mapping back to `/home/khoa/Projects/langfens/Project_Langfens_Microservice/HANDOFF_SPRINT4.md` §3:

1. **Item 1 — Fix scripts/migrate_blank_keys_to_1_indexed.py port hardcode**: DONE (commit `25f1d29` in BE).
2. **Item 2 — Apply migration script to any DB introducing 0-idx rows later**: DONE (verified 0 rows matching `? '0'` in live `exam-db` and `attempt-db`).
3. **Item 3 — Verify Group C bugs C1–C6 and mark REAL or HALLUCINATED**: DONE (audit queries executed in Phase 2; documented in closure).
4. **Item 4 — Address Group D backlog**:
   - Item 1 (Zero-Idx residuals): DONE (verified intentional section-local ordinals; 0 orphan rows).
   - Item 2 (18 blank-q rows): DONE (placeholders and dict keys migrated to 1-indexed format).
   - Item 3 (Seeder UUID cleanup): DEFERRED to Sprint 5 (rationale documented in §2).
   - Item 6 (DRY cleanAnswer): DONE (consolidated into `src/lib/cleanAnswer.ts` with unit tests).
   - Item 7 (DRY buildQuestion): DONE (consolidated into `src/lib/buildQuestion.ts`).
   - Item 8 (Vitest test infrastructure): DONE (vitest installed, configured, 2 test suites un-skipped and passing).
   - Item 9 (G11 dispatcher UI fallback): DONE (fallback card rendered for unhandled question types).
   - Item 10 (Migration script naming): DONE (docstrings and connection kwargs standardized).
   - Item 11 (Document rotation): DONE (HANDOFF_SPRINT3 archived, HANDOFF_SPRINT4 active).
5. **Item 5 — MAP_LABEL "1:" typo in questionSchemas.ts:394**: DONE (corrected to `"1"` and `"2"`).

**Closure Operations**:
- Update `/home/khoa/Projects/langfens/Project_Langfens_Microservice/HANDOFF_SPRINT4.md` §0 and §3 with closure status and commit SHAs.
- Author `/home/khoa/Projects/langfens/Project_Langfens_Microservice/HANDOFF_SPRINT5.md` defining Sprint 5 scope (Item 3 Seeder UUID cleanup).
- Execute final manual verification re-run across BE tests, FE typecheck, FE unit tests, and live SQL invariants.

## §7 — Acceptance Criteria (Definition of Done for Sprint 4)

Sprint 4 is DONE when ALL of the following criteria are true:
- All items in §1 are marked DONE except Item 3, which is explicitly DEFERRED to Sprint 5.
- `/home/khoa/Projects/langfens/Project_Langfens_Microservice/HANDOFF_SPRINT4.md` §3 checklist shows DONE for items 4, 1, 2, 6, 7, 8, 9, 10, and DEFERRED for item 3.
- `/home/khoa/Projects/langfens/Project_Langfens_Microservice/HANDOFF_SPRINT5.md` exists and references Sprint 5 scope = Item 3 (Seeder UUID cleanup) + any newly discovered follow-ups.
- Section 4 manual verification steps from `HANDOFF_SPRINT4.md` all pass when re-run:
  1. Branch check returns `refactor/sync-dotest-admin-renderer` on both repositories.
  2. SQL check `SELECT COUNT(*) FROM exam_questions WHERE "BlankAcceptTexts" ? '0';` returns 0.
  3. SQL check `SELECT COUNT(*) FROM attempt_answer WHERE "TextAnswer" LIKE '%"0":%';` returns 0.
  4. Section 1 layout check on `ielts-reading-practice-1` returns 5 rows (Idx 0, 1, 3, 3, 4).
  5. Command `dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj --no-build` exits with code 0.
  6. Command `npx tsc --noEmit` in `langfens-fe-app` exits with code 0.
  7. Command `npm run test` in `langfens-fe-app` exits with code 0 with all test suites passing.
- No untracked files left in working tree on either repository.
- Both repositories remain on branch `refactor/sync-dotest-admin-renderer`.
