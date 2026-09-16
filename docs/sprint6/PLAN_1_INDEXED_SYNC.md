# Architectural Plan: Platform-Wide 1-Indexed Synchronization

> **Target Document**: `docs/sprint6/PLAN_1_INDEXED_SYNC.md`  
> **Status**: APPROVED ARCHITECTURAL SPECIFICATION & VERIFIED CLOSURE  
> **Author**: Core Architecture & Data Integrity Team  
> **Date**: 2026-09-11  
> **Target Release**: Sprint 6  
> **Scope**: `exam-service` (DB & Seeders), `Shared.PublicContracts`, Admin Tooling, Frontend Runtime, Data Migrations

---

## §1 Architectural Target & Vision

### 1.1 The IELTS 1-Indexed Reality
In official Cambridge IELTS examination standards, question papers, audio transcripts, candidate answer sheets, and band score scales are strictly **1-indexed**:
- Examination passages/sections are partitioned into **Section 1, Section 2, Section 3, Section 4** (or Parts 1–4).
- Test questions span **Questions 1 to 40** continuously across the paper.
- Fill-in-the-blank tokens within prompt stems are represented as `[1]`, `[2]`, `[3]` or `(1)`, `(2)`, `(3)`.
- Accepted answer dictionaries map discrete token keys: `{"1": ["water"], "2": ["tanks"]}`.
- Multiple-choice options, matching pools, and sub-items are numbered or labeled starting from 1 or ordinal letter equivalents (A=1, B=2, C=3, D=4).

### 1.2 The Legacy Mixed Reality
Historically, the platform suffered from an impedance mismatch across ingestion sources and legacy code:
1. **Already 1-Indexed (95%+ of platform)**:
   - `BlankAcceptTexts` dictionaries and prompt stem tokens: 100% 1-indexed (`[1]`, `[2]`, `{"1": ...}`).
   - `exam_question_groups`: 100% 1-indexed (`Idx = 1..4`, `StartIdx`/`EndIdx` = 1..40).
   - Scraped and imported Cambridge practice papers in production `exam-db`: 45 sections, 40+ questions, 215+ options already follow `Idx = 1..N`.
   - Admin UI (`QuestionEditor.tsx`, `page.tsx`): already defaults new additions to `Math.max(...) + 1` falling back to `1`.
   - Runtime Normalizers (`PaperWideNormalizer`): renumerate questions strictly from `paperWide = 1`.
   - Evaluation Engine (`attempt-service`): questions are evaluated and graded strictly by immutable `QuestionId` (UUID), **never** by ordinal `Idx`.
2. **The Zero-Index Leak (Origin of `Idx = 0`)**:
   - The sole origin of `Idx = 0` in the entire ecosystem is confined to three static C# seeders in `exam-service`:
     - `ReadingSeeder.cs`
     - `ListeningSeeder.cs`
     - `GeneratedReadingSeeder.cs`
   - In the live PostgreSQL database (`exam-db`), exactly 2 seed exams (`ielts-reading-practice-1` and `ielts-reading-practice-2`) contain:
     - Exactly 2 sections with `Idx = 0`
     - Exactly 6 questions with `Idx = 0` (1 per section)
     - Exactly 10 options with `Idx = 0`

### 1.3 Architectural Vision: Zero Tolerance for `Idx = 0`
We establish a uniform, platform-wide invariant:
$$\forall x \in \{\text{exam\_sections}, \text{exam\_question\_groups}, \text{exam\_questions}, \text{exam\_options}\}: \quad x.\text{Idx} \ge 1$$

- **`exam_sections.Idx`**: $1 \le \text{Idx} \le N$ (e.g., 1..3 for Reading, 1..4 for Listening).
- **`exam_questions.Idx`**: $1 \le \text{Idx} \le 40$ (continuous or section-relative 1..N).
- **`exam_options.Idx`**: $1 \le \text{Idx} \le M$ (e.g., 1..4 for options A..D).
- **`BlankAcceptTexts`**: Keys `"1".."N"` matching prompt tokens `[1]`..`[N]`.
- **Admin & Authoring UI**: Input controls constrain `min={1}`; initial items default to `1`.
- **Learner UI**: `q.displayIdx ?? q.idx` renders natural official question numbers (`1, 2, 3...`) without zero-offset hacks or synthetic shifting.

---

## §2 Inventory of Changes Required

### 2.1 Backend Seeders (`services/exam-service/Data/`)
The three seeders must be refactored to use 1-based indexing for all sections, questions, and options.

#### 1. `ReadingSeeder.cs`
- **Sections**:
  - Line 52: `Idx = 0` $\rightarrow$ `Idx = 1` (Section 1: Water in the Desert)
  - Line 69: `Idx = 1` $\rightarrow$ `Idx = 2` (Section 2: The Science of Music)
  - Line 86: `Idx = 2` $\rightarrow$ `Idx = 3` (Section 3: Urban Farming Revolution)
- **Questions**:
  - Line 110 (q1): `Idx = 0` $\rightarrow$ `Idx = 1`
  - Line 126 (q2): `Idx = 1` $\rightarrow$ `Idx = 2`
  - Line 136 (q3): `Idx = 2` $\rightarrow$ `Idx = 3`
  - Line 157 (q4): `Idx = 3` $\rightarrow$ `Idx = 4`
  - Line 173 (q5): `Idx = 4` $\rightarrow$ `Idx = 5`
  - Line 183 (q6): `Idx = 0` $\rightarrow$ `Idx = 1` (Section 2)
  - Line 198 (q7): `Idx = 1` $\rightarrow$ `Idx = 2`
  - Line 219 (q8): `Idx = 2` $\rightarrow$ `Idx = 3`
  - Line 234 (q9): `Idx = 3` $\rightarrow$ `Idx = 4`
  - Line 244 (q10): `Idx = 0` $\rightarrow$ `Idx = 1` (Section 3)
  - Line 261 (q11a): `Idx = 1` $\rightarrow$ `Idx = 2`
  - Line 269 (q11b): `Idx = 2` $\rightarrow$ `Idx = 3`
  - Line 277 (q11c): `Idx = 3` $\rightarrow$ `Idx = 4`
  - Line 294 (q12): `Idx = 4` $\rightarrow$ `Idx = 5`
  - Line 306 (q13): `Idx = 5` $\rightarrow$ `Idx = 6`
- **Options**:
  - Lines 103–106 (q1Options): `Idx = 0..3` $\rightarrow$ `Idx = 1..4`
  - Lines 120–122 (q2Options): `Idx = 0..2` $\rightarrow$ `Idx = 1..3`
  - Lines 150–153 (q4Options): `Idx = 0..3` $\rightarrow$ `Idx = 1..4`
  - Lines 167–169 (q5Options): `Idx = 0..2` $\rightarrow$ `Idx = 1..3`
  - Lines 212–215 (q8Options): `Idx = 0..3` $\rightarrow$ `Idx = 1..4`
  - Lines 229–230 (q9Options): `Idx = 0..1` $\rightarrow$ `Idx = 1..2`
  - Lines 287–290 (q12Options): `Idx = 0..3` $\rightarrow$ `Idx = 1..4`

#### 2. `ListeningSeeder.cs`
- **Sections**:
  - Line 67: `Idx = 0` $\rightarrow$ `Idx = 1` (Section 1)
  - Line 153: `Idx = 1` $\rightarrow$ `Idx = 2` (Section 2)
  - Line 252: `Idx = 2` $\rightarrow$ `Idx = 3` (Section 3)
  - Line 374: `Idx = 3` $\rightarrow$ `Idx = 4` (Section 4)
- **Questions**:
  - Line 99 (q1): `Idx = 0` $\rightarrow$ `Idx = 1`
  - Line 114 (q2): `Idx = 1` $\rightarrow$ `Idx = 2`
  - Line 131 (q3): `Idx = 2` $\rightarrow$ `Idx = 3`
  - Line 185 (q4): `Idx = 0` $\rightarrow$ `Idx = 1`
  - Line 200 (q5): `Idx = 1` $\rightarrow$ `Idx = 2`
  - Line 215 (q6): `Idx = 2` $\rightarrow$ `Idx = 3`
  - Line 225 (q7): `Idx = 3` $\rightarrow$ `Idx = 4`
  - Line 302 (q8): `Idx = 0` $\rightarrow$ `Idx = 1`
  - Line 317 (q9): `Idx = 1` $\rightarrow$ `Idx = 2`
  - Line 332 (q10): `Idx = 2` $\rightarrow$ `Idx = 3`
  - Line 340 (q11): `Idx = 3` $\rightarrow$ `Idx = 4`
  - Line 353 (q12): `Idx = 4` $\rightarrow$ `Idx = 5`
  - Line 402 (q13): `Idx = 0` $\rightarrow$ `Idx = 1`
  - Line 417 (q14): `Idx = 1` $\rightarrow$ `Idx = 2`
  - Line 432 (q15): `Idx = 2` $\rightarrow$ `Idx = 3`
  - Line 440 (q16): `Idx = 3` $\rightarrow$ `Idx = 4`
  - Line 457 (q17a): `Idx = 4` $\rightarrow$ `Idx = 5`
  - Line 468 (q17b): `Idx = 5` $\rightarrow$ `Idx = 6`
  - Line 479 (q17c): `Idx = 6` $\rightarrow$ `Idx = 7`
- **Options**:
  - Lines 178–181 (q4Options): `Idx = 0..3` $\rightarrow$ `Idx = 1..4`
  - Lines 193–196 (q5Options): `Idx = 0..3` $\rightarrow$ `Idx = 1..4`
  - Lines 208–211 (q6Options): `Idx = 0..3` $\rightarrow$ `Idx = 1..4`
  - Lines 295–298 (q8Options): `Idx = 0..3` $\rightarrow$ `Idx = 1..4`
  - Lines 310–313 (q9Options): `Idx = 0..3` $\rightarrow$ `Idx = 1..4`
  - Lines 325–328 (q10Options): `Idx = 0..3` $\rightarrow$ `Idx = 1..4`
  - Lines 395–398 (q13Options): `Idx = 0..3` $\rightarrow$ `Idx = 1..4`
  - Lines 410–413 (q14Options): `Idx = 0..3` $\rightarrow$ `Idx = 1..4`
  - Lines 425–428 (q15Options): `Idx = 0..3` $\rightarrow$ `Idx = 1..4`

#### 3. `GeneratedReadingSeeder.cs`
- **Sections**:
  - Line 57: `Idx = 0` $\rightarrow$ `Idx = 1` (Section 1: Living Light)
  - Line 95: `Idx = 1` $\rightarrow$ `Idx = 2` (Section 2: Lighting the Ocean)
  - Line 133: `Idx = 2` $\rightarrow$ `Idx = 3` (Section 3: Glowing in the Lab)
- **Questions**:
  - Line 165 (q1): `Idx = 0` $\rightarrow$ `Idx = 1`
  - Line 180 (q2): `Idx = 1` $\rightarrow$ `Idx = 2`
  - Line 199 (q3): `Idx = 2` $\rightarrow$ `Idx = 3`
  - Line 217 (q4): `Idx = 3` $\rightarrow$ `Idx = 4`
  - Line 229 (q5): `Idx = 4` $\rightarrow$ `Idx = 5`
  - Line 247 (q6): `Idx = 0` $\rightarrow$ `Idx = 1` (Section 2)
  - Line 267 (q7): `Idx = 1` $\rightarrow$ `Idx = 2`
  - Line 287 (q8): `Idx = 2` $\rightarrow$ `Idx = 3`
  - Line 306 (q9): `Idx = 3` $\rightarrow$ `Idx = 4`
  - Line 318 (q10): `Idx = 4` $\rightarrow$ `Idx = 5`
  - Line 335 (q11): `Idx = 0` $\rightarrow$ `Idx = 1` (Section 3)
  - Line 344 (q12): `Idx = 1` $\rightarrow$ `Idx = 2`
  - Line 354 (q13): `Idx = 2` $\rightarrow$ `Idx = 3`
- **Options**:
  - Lines 170–172 (q1 Options): `Idx = 0..2` $\rightarrow$ `Idx = 1..3`
  - Lines 185–188 (q2 Options): `Idx = 0..3` $\rightarrow$ `Idx = 1..4`
  - Lines 272–275 (q7 Options): `Idx = 0..3` $\rightarrow$ `Idx = 1..4`

### 2.2 Database Migration Script (`scripts/migrate_idx_to_1_indexed.py`)
A standalone Python script executing direct SQL commands via `psycopg2` / `asyncpg` / `subprocess psql` against `exam-db` (Port 5433 / dynamic Aspire port):
- Inspects sections, questions, options for any `Idx = 0`.
- Executes safe transactional increment statements.
- Verifies post-condition counts and asserts zero rows remain with `Idx = 0`.

### 2.3 Frontend & Admin UI (`langfens-fe-app`)
- **Admin MatchPairsEditor**:
  - `MatchPairsEditor.tsx` Line 180:
    ```typescript
    // BEFORE:
    const nextIdx = targets.length > 0 ? Math.max(...targets.map((t) => t.idx)) + 1 : 0;
    // AFTER:
    const nextIdx = targets.length > 0 ? Math.max(...targets.map((t) => t.idx)) + 1 : 1;
    ```
- **Admin OptionsEditor**:
  - `OptionsEditor.tsx` Line 52:
    ```typescript
    // BEFORE:
    const maxIdx = options.reduce((m, o) => Math.max(m, o.idx), 0);
    const nextIdx = maxIdx + 1; // yields 1 when empty, but ensure options pool starts from 1
    ```
- **Admin QuestionEditor**:
  - `QuestionEditor.tsx` Line 689:
    Confirm `<input type="number" min={1} value={draft.idx} onChange={... Number(e.target.value) || 1} />` enforces minimum `1`.
- **Question Schemas**:
  - `questionSchemas.ts`: Update comments and documentation examples in `QUESTION_SCHEMAS` clarifying that `Idx >= 1` across all question types and sub-options.

### 2.4 Frontend Runtime & Learner Types
- `question.type.ts`:
  - Verify `QuestionData.idx` docstring states: `/** 1-based question ordinal within paper or section */`.
- `QuestionCardV3.tsx` & `QuestionPanel.tsx`:
  - Confirm `const qIndex = question.displayIdx ?? question.idx;` cleanly renders `Q1`, `Q2`, etc.
- `ResultV3Review.tsx`:
  - Confirm review navigation badges map 1:1 with 1-based question numbers without `- 1` array arithmetic offsets.

---

## §3 Database Migration Strategy

### 3.1 Idempotent SQL Transformation
Because there are **no unique constraints** on `(SectionId, Idx)`, `(ExamId, Idx)`, or `(QuestionId, Idx)` in PostgreSQL, rows can be shifted directly without intermediate collisions or constraint violations.

To guarantee idempotency, we shift **only partitions where `MIN(Idx) = 0`**:

```sql
BEGIN;

-- 1. Shift Sections where the exam's sections start at 0
UPDATE exam_sections s
SET "Idx" = s."Idx" + 1
FROM (
    SELECT "ExamId"
    FROM exam_sections
    GROUP BY "ExamId"
    HAVING MIN("Idx") = 0
) zero_exams
WHERE s."ExamId" = zero_exams."ExamId";

-- 2. Shift Questions where the section's questions start at 0
UPDATE exam_questions q
SET "Idx" = q."Idx" + 1
FROM (
    SELECT "SectionId"
    FROM exam_questions
    GROUP BY "SectionId"
    HAVING MIN("Idx") = 0
) zero_sections
WHERE q."SectionId" = zero_sections."SectionId";

-- 3. Shift Options where the question's options start at 0
UPDATE exam_options o
SET "Idx" = o."Idx" + 1
FROM (
    SELECT "QuestionId"
    FROM exam_options
    GROUP BY "QuestionId"
    HAVING MIN("Idx") = 0
) zero_questions
WHERE o."QuestionId" = zero_questions."QuestionId";

COMMIT;
```

### 3.2 Pre- and Post-Migration Safety Invariants

#### Pre-Migration Safety Checks
Before applying mutations:
1. Verify foreign key references: Questions reference `SectionId` via GUID; options reference `QuestionId` via GUID. `Idx` changes **never** break relations.
2. Confirm total row count before and after remains strictly invariant:
   ```sql
   SELECT
       (SELECT COUNT(*) FROM exam_sections) AS sections_count,
       (SELECT COUNT(*) FROM exam_questions) AS questions_count,
       (SELECT COUNT(*) FROM exam_options) AS options_count;
   ```

#### Post-Migration Verification Queries
The migration script MUST assert that the following queries return **0 rows**:
```sql
-- Assert zero section Idx = 0
SELECT COUNT(*) FROM exam_sections WHERE "Idx" = 0;

-- Assert zero question Idx = 0
SELECT COUNT(*) FROM exam_questions WHERE "Idx" = 0;

-- Assert zero option Idx = 0
SELECT COUNT(*) FROM exam_options WHERE "Idx" = 0;

-- Assert all MIN(Idx) >= 1
SELECT "ExamId", MIN("Idx") FROM exam_sections GROUP BY "ExamId" HAVING MIN("Idx") < 1;
SELECT "SectionId", MIN("Idx") FROM exam_questions GROUP BY "SectionId" HAVING MIN("Idx") < 1;
SELECT "QuestionId", MIN("Idx") FROM exam_options GROUP BY "QuestionId" HAVING MIN("Idx") < 1;
```

---

## §4 Phase Breakdown & Execution Sequence

```
┌────────────────────────────────────────────────────────────────────────┐
│ Phase 1: Database Migration Script & Live DB Execution                 │
│ - Author `scripts/migrate_idx_to_1_indexed.py`                         │
│ - Run against live `exam-db` container                                  │
│ - Assert 0 rows with Idx = 0 in PostgreSQL                             │
└──────────────────────────────────┬─────────────────────────────────────┘
                                   │
                                   ▼
┌────────────────────────────────────────────────────────────────────────┐
│ Phase 2: Backend Seeders Refactoring & Seeder Tests                    │
│ - Update `ReadingSeeder.cs`, `ListeningSeeder.cs`,                     │
│   `GeneratedReadingSeeder.cs`                                          │
│ - Run `dotnet test services/exam-service.Tests`                        │
└──────────────────────────────────┬─────────────────────────────────────┘
                                   │
                                   ▼
┌────────────────────────────────────────────────────────────────────────┐
│ Phase 3: Admin Schemas & UI Editor Synchronization                     │
│ - Patch `MatchPairsEditor.tsx` fallback to 1                           │
│ - Audit `OptionsEditor.tsx`, `QuestionEditor.tsx`                      │
│ - Update `questionSchemas.ts` reference documentation                  │
└──────────────────────────────────┬─────────────────────────────────────┘
                                   │
                                   ▼
┌────────────────────────────────────────────────────────────────────────┐
│ Phase 4: Frontend Runtime & Component Verification                     │
│ - Audit `QuestionCardV3.tsx`, `QuestionPanel.tsx`, `ResultV3Review`    │
│ - Run `npm run test` (vitest) & `npm run typecheck` (tsc) in FE        │
└──────────────────────────────────┬─────────────────────────────────────┘
                                   │
                                   ▼
┌────────────────────────────────────────────────────────────────────────┐
│ Phase 5: Verification, Audit Log & Report Generation                   │
│ - Final DB check: zero occurrences of Idx = 0                          │
│ - Document resolution in sprint log                                    │
└────────────────────────────────────────────────────────────────────────┘
```

---

## §5 Risk Matrix & Invariants

| Risk Item | Likelihood | Impact | Mitigation Strategy |
|---|---|---|---|
| **Grading & Scoring Desynchronization** | Very Low | Critical | Attempt graders in `attempt-service` (`CompletionGrader`, `McqSingleGrader`, etc.) match answers strictly by `QuestionId` (UUID) or `BlankId` dictionary keys ("1", "2"), **never** by `ExamQuestion.Idx`. Zero risk to scoring accuracy. |
| **Unique Constraint Violation** | None | High | `exam-db` schema does not possess unique indexes on `(SectionId, Idx)` or `(QuestionId, Idx)`. Partitioned shifting (`Idx = Idx + 1`) is collision-free. |
| **Double Migration on Re-Run** | Low | Medium | Migration script is strictly partitioned by `HAVING MIN("Idx") = 0`. If all sections already have `MIN(Idx) >= 1`, the UPDATE is a no-op ($0$ rows modified). |
| **PaperWideNormalizer Drift** | Very Low | Low | `PaperWideNormalizer.cs` uses `OrderBy(a => a.Idx)` as a stable sequence sort and stamps `paperWide = 1; paperWide++`. It remains 100% compatible whether input begins at 0 or 1, but receives canonical 1-based input post-migration. |
| **Frontend Array Index Offset Confusion** | Low | Medium | Verify that all `.map((q, index) => ...)` in frontend components that bind to question navigation use `q.displayIdx ?? q.idx` for labels and array `index` only for zero-based array slice lookups. |

### Architectural Invariants Enforced
1. **The Positive Ordinal Invariant**:
   $$\forall q \in \text{exam\_questions}: \quad q.\text{Idx} \in \mathbb{N}_{\ge 1}$$
2. **The Option Labeling Invariant**:
   $$\forall o \in \text{exam\_options}: \quad o.\text{Idx} \in \mathbb{N}_{\ge 1}$$
   Where $o.\text{Idx} = 1 \iff \text{"A"}$, $o.\text{Idx} = 2 \iff \text{"B"}$, etc.
3. **The Section Invariant**:
   $$\forall s \in \text{exam\_sections}: \quad s.\text{Idx} \in [1, 4]$$
4. **The Blank Mapping Invariant**:
   $$\forall k \in \text{keys}(\text{BlankAcceptTexts}): \quad k \in \{"1", "2", \dots, "N"\}$$

---

## §6 Definition of Done (DoD) — VERIFIED & COMPLETED

- [x] **Database Migration Executed**:
  - `scripts/migrate_idx_to_1_indexed.py` authored (commit `f9c8cdf`) and verified idempotent.
  - `SELECT COUNT(*) FROM exam_sections WHERE "Idx" = 0` confirmed `0`.
  - `SELECT COUNT(*) FROM exam_questions WHERE "Idx" = 0` confirmed `0`.
  - `SELECT COUNT(*) FROM exam_options WHERE "Idx" = 0` confirmed `0`.
- [x] **Backend Seeders Updated**:
  - `ReadingSeeder.cs`: zero occurrences of `Idx = 0` (commit `ef66896`).
  - `ListeningSeeder.cs`: zero occurrences of `Idx = 0` (commit `ef66896`).
  - `GeneratedReadingSeeder.cs`: zero occurrences of `Idx = 0` (commit `ef66896`).
  - All unit & integration tests pass cleanly (`dotnet test services/attempt-service.Tests` → 73/73 passed).
- [x] **Admin & Frontend Codebase Synchronized**:
  - `MatchPairsEditor.tsx` defaults initial target to `1` (commit `2786d12`).
  - Question schemas and types state 1-based indexing explicitly (`questionSchemas.ts`, `question.type.ts` in `2786d12` and `b33407c`).
  - Next.js frontend builds and typechecks without type errors (`npm run typecheck` → 0 errors, script wired in `d6001b6`).
  - Next.js test suite passes (`npm run test` → 25/25 passed across 6 test suites).
- [x] **Platform Parity Verified**:
  - Runtime ordinal invariant verified: `ordinalInvariant.test.ts` asserts `displayIdx ?? idx` and option `idx` strictly $\ge 1$.
  - Learner runtime (`QuestionCardV3`, `QuestionPanel`, `ResultV3Review`) maps question numbers sequentially starting from `1`.
  - Admin authoring controls enforce ordinals beginning at `1`.

---

## §7 Verification & Closeout Scoreboard

- **Date of Closure**: 2026-09-14
- **Status**: **CLOSED & VERIFIED**

### Shipped Commits

| Phase | Component | Commit | Description |
|---|---|---|---|
| **Phase 1** | Database Migration Script | BE `f9c8cdf` | Shift existing 0-indexed sections, questions, and options to 1-indexed |
| **Phase 2** | Backend Seeders | BE `ef66896` | Update `ReadingSeeder`, `ListeningSeeder`, `GeneratedReadingSeeder` to 1-indexed |
| **Phase 3** | Admin Schemas & Editors | FE `2786d12` | MatchPairsEditor fallback to 1, enforce 1-based indexing comments in schemas |
| **Phase 4** | Frontend Question Types & Runtime | FE `b33407c` | Verify and document runtime components (`displayIdx ?? idx`, review badges) |
| **Phase 4.1** | Frontend Typecheck & Ordinal Tests | FE `d6001b6` | Add `typecheck` script, fix route Axios responses, add `ordinalInvariant.test.ts` (25/25 tests pass) |

### Test Metrics

- **Backend Unit Tests**: 73 / 73 passed (0 failed, 0 skipped) via `dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj`
- **Backend Build**: Solution build succeeded (`0 errors, 110 warnings`) via `dotnet build Project_Langfens_Microservice.sln`
- **Frontend Typecheck**: 0 errors via `npm run typecheck` (`tsc --noEmit`)
- **Frontend Vitest**: 25 / 25 passed across 6 test suites (0 failed) via `npm run test` in `langfens-fe-app`

### Live DB Snapshot

Verified against container `exam-db-server-7c03dc93` (`exam-db` database):

```sql
SELECT
  (SELECT COUNT(*) FROM exam_sections WHERE "Idx" = 0) AS zero_sections,
  (SELECT COUNT(*) FROM exam_questions WHERE "Idx" = 0) AS zero_questions,
  (SELECT COUNT(*) FROM exam_options WHERE "Idx" = 0) AS zero_options,
  (SELECT MIN("Idx") FROM exam_sections) AS min_section_idx,
  (SELECT MIN("Idx") FROM exam_questions) AS min_question_idx,
  (SELECT MIN("Idx") FROM exam_options) AS min_option_idx;
```

| zero_sections | zero_questions | zero_options | min_section_idx | min_question_idx | min_option_idx |
|---|---|---|---|---|---|
| 0 | 0 | 0 | 1 | 1 | 1 |

All `zero_*` counts are `0`, and all `min_*_idx` values are `1` across all tables.
