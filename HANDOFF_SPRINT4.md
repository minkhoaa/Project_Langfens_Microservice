# Langfens — Sprint 4 Handoff & Kickoff

> Audience: fresh session, zero context. Both repos on branch `refactor/sync-dotest-admin-renderer`.
> This document closes Sprint 3, records live verified baseline state, and defines Sprint 4 scope, readiness, and verification. Read top-to-bottom before touching anything.

---

## §0 — State summary

**Repository & Branch Baseline.** The backend repository (`/home/khoa/Projects/langfens/Project_Langfens_Microservice`) is on branch `refactor/sync-dotest-admin-renderer` at HEAD `25f1d29`. The frontend repository (`/home/khoa/Projects/langfens/langfens-fe-app`) is on branch `refactor/sync-dotest-admin-renderer` at HEAD `1cb7ed0`. Sprint 3 is officially closed with all closure criteria marked **DONE** across 19 commits (10 BE + 9 FE) and verified database updates. Specifically, Option X (1-indexed blank key convention across the entire stack) closed in `d25ae5f` (BE seeders + tests) and `1cb7ed0` (FE learner runtime, admin validation, schemas, and tests); pre-S32 grader key sorting closed in `00ffab1`, `0494cde`, and `f814d87` (BE); G27 AwardedPoints invariant helper closed in `1dff82b` (BE); G10 MatchingHeading feedback and FlowChart SequenceEqual closed in `e2e4f78` (BE); S31 click-to-add-blank cursor insertion and coverage validator closed in `c621516` and `e9ac69c` (FE); S32 Phases 1–3 runtime fallback retirement, JSON schema templates, and prompt rewriting closed in `4c77bcb`, `1e885b2`, `f89135d`, `d2b7615`, `44e3454`, `d119a8b`, `14679b9`, and `43352d3`; Fix A admin save flow refetch, toast, and duplicate guard closed in `41b5720` (FE); Fix B Section 1 canonical restoration for `ielts-reading-practice-1` (5 rows Idx 0..4) closed via direct SQL; Day 1 cross-DB orphan sweep closed with 0 orphaned answers post-Migrate-7; G20 card rewiring closed in `86a325d`, `bd420de`, and `fde62e2` (FE); G14 question type consolidation closed in `c8a08f1`, `f2dc0b1`, and `7e28667` (FE); and G15 cleanAnswer regex tighten closed in `8e3126c` (FE). Live database audits verify exactly 0 rows with key `"0"` in `exam_questions.BlankAcceptTexts` and 0 rows with `%"0":%` in `attempt_answer.TextAnswer`. Refer to `HANDOFF_SPRINT3.md` §0–§6 for comprehensive historical evidence.

**Sprint 4 Status (Closure).** Sprint 4 is officially closed as of 2026-09-11. The 5 readiness items published in Sprint 3 §11 plus the 10-item Group D backlog were processed as follows:
- Item #1 (Fix `scripts/migrate_blank_keys_to_1_indexed.py` port hardcode) is **DONE** via commit `25f1d29` (carried from Sprint 3 closure, no change in Sprint 4).
- Item #2 (Apply migration script to any DB introducing 0-idx rows later) is **DONE** via Phase 3.4 verification — `docs/sprint4/VERIFICATION_2026-09-11.md` Check 5+6 confirmed 0 rows with key `"0"` in both `exam-db` and `attempt-db`. Live DB was migrated externally between Phase 2.2 audit and Phase 3.4 verification (13 MCQ rows removed externally; audit trail not captured in session logs). Script extension with MCQ-scan capability landed in `scripts/migrate_blank_placeholders.py` (uncommitted, BE working tree).
- Item #3 (Verify Group C bugs C1–C6 and mark REAL or HALLUCINATED) is **DONE** via `docs/sprint4/VERDICT_groupC.md` — 0 REAL / 6 HALLUCINATED.
- Item #4 (Address Group D backlog: 10 active items across Quick Wins, Data Hygiene, and Engineering) is **PARTIAL DONE**. Item 1 (zero-Idx residuals) marked LEGITIMATE in `docs/sprint4/AUDIT_zeroIdx.md`; Item 2 (blank-q rows) PARTIAL in `docs/sprint4/AUDIT_blankQ.md` with DB already canonical (verified `docs/sprint4/UUID_CHECK_11111111.md`); Item 3 (UUID seeders) **DEFERRED** to Sprint 5; Items 6 & 7 (DRY helpers) **DEFERRED** to Sprint 5; Item 8 (Vitest) **DONE** via FE commits `5c7319e` + `3ff2e41`; Item 9 (G11 dispatcher) **DEFERRED** to Sprint 5; Item 10 (script naming) **DONE** via `2c5843c`.
- Item #5 (Cleanup MAP_LABEL `"1:"` typo in `src/app/admin/_lib/questionSchemas.ts:394`) is **DONE** via commit `1c2d1b3`.

**Sprint 4 artifacts.** `docs/sprint4/PLAN.md` (Sprint 4 plan) and `docs/sprint4/REVIEW.md` (post-execution review with 8 fixes applied) were authored. Supporting audit docs: `AUDIT_zeroIdx.md`, `AUDIT_blankQ.md`, `VERDICT_groupC.md`, `UUID_CHECK_11111111.md`, `VERIFICATION_2026-09-11.md`, `PHASE4_PLAN.md`. All artifacts live under `/docs/sprint4/` (gitignored).

---

## §1 — Repository state

| Repo | Path | Branch | HEAD |
|------|------|--------|------|
| BE (.NET 10 + Python AI) | `/home/khoa/Projects/langfens/Project_Langfens_Microservice` | `refactor/sync-dotest-admin-renderer` | `25f1d29` |
| FE (Next.js) | `/home/khoa/Projects/langfens/langfens-fe-app` | `refactor/sync-dotest-admin-renderer` | `1cb7ed0` |

Root `CLAUDE.md` contains Aspire/AppHost resource maps, RabbitMQ env conventions, gRPC details, and shared library references.

### Live Infrastructure & DB Ports (Verified 2026-09-11)

- **exam-db container**: `exam-db-server-7c03dc93` (postgres:17.6), host port **32779** (NOT 5433).
- **attempt-db container**: `attempt-db-server-7c03dc93`, host port **32780** (NOT 5435).
- Other service DBs use dynamic `32768`-range host ports allocated by Aspire (auth-db: 32781, dictionary-db: 32775, speaking-db: 32777, vocabulary-db: 32776, gamification-db: 32769, writing-db: 32768, course-db: 32770). Compose ports in `CLAUDE.md` do not match live host ports.
- Migration script `scripts/migrate_blank_keys_to_1_indexed.py` (committed in `25f1d29`) reads `EXAM_DB_PORT` (default 5433) and `ATTEMPT_DB_PORT` (default 5435), supporting live execution via `EXAM_DB_PORT=32779 ATTEMPT_DB_PORT=32780 python3 scripts/migrate_blank_keys_to_1_indexed.py`.

### Live DB State Verification Snapshot

```
exam-db     host=localhost port=32779 user=exam     password=exam     dbname=exam-db
attempt-db  host=localhost port=32780 user=attempt  password=attempt  dbname=attempt-db
```

#### Section 1 of `ielts-reading-practice-1` (Canonical)
5 rows Idx 0..4 (Idx 2 absent by design):
| Idx | Type | Id | BlankAcceptTexts |
|-----|------|----|------------------|
| 0 | MULTIPLE_CHOICE_SINGLE | `fce88b41-e945-41f9-9f19-0d8a8c289d89` | `null` |
| 1 | TRUE_FALSE_NOT_GIVEN | `33333333-3333-3333-3333-333333333332` | `null` |
| 3 | MULTIPLE_CHOICE_SINGLE | `6d0e7597-fdfe-43e0-95ad-0fb3b8305586` | `null` |
| 3 | SENTENCE_COMPLETION | `e22dc454-8a11-494b-b7c3-c0bf0e84a2f1` | `{"1":["polypropylene","polypropylene nets"],"2":["underground","underground tanks"],"3":["meters"]}` |
| 4 | TRUE_FALSE_NOT_GIVEN | `33333333-3333-3333-3333-333333333335` | `null` |

#### Key Sweeps & Orphan Invariants
- `exam-db.exam_questions WHERE "BlankAcceptTexts" ? '0'`: **0 rows**
- `attempt-db.attempt_answer WHERE "TextAnswer" LIKE '%"0":%'`: **0 rows**
- `attempt_answer` rows referencing UUIDs absent from `exam_questions`: **0 rows** (post-Migrate-7).

### Wire Contract Summary (Option X Invariant)
Every `BlankAcceptTexts` / `BlankAcceptRegex` dict key across the stack is **1-indexed**, matching prompt `[N]` tokens 1-to-1:
1. **Admin Authoring:** Toolbar blank insertion (`BlankAcceptsEditor.tsx:131-177`) inserts literal `[N]` and initializes dict entry `"N"` atomically.
2. **Admin Save:** `QuestionEditor.handleSave` triggers `showToast` and scoped `loadSection(sectionId)` refetch (`page.tsx:472-473`).
3. **API & DB:** `POST`/`PUT` `/admin/question/update/{id}` persists `{"1":[...],"2":[...]}` verbatim to `exam_questions.BlankAcceptTexts`.
4. **Learner Attempt:** `TestV2Runner.answerValueToString` encodes `{"1":"ans1","2":"ans2"}` into `attempt_answer.text_answer`.
5. **Grading:** `CompletionGrader.Grade` iterates `SortedUnionKeys(texts, regs)` (`"1"`, `"2"`, `"3"`) to compare submitted answers against normalized accept-texts lists.

---

## §2 — Sprint 4 scope & carryover

The Sprint 3 backlog (§7 of `HANDOFF_SPRINT3.md`) is republished below under three distinct operational categories. Backlog item #5 (migration script port hardcode) was resolved in `25f1d29` and is officially dropped from the backlog, leaving 10 active tasks.

### 1. Quick Wins
- **Item 4 — MAP_LABEL `"1:"` typo in questionSchemas.ts**
  - Location: `src/app/admin/_lib/questionSchemas.ts:394`.
  - Description: Schema example payload contains `blankAcceptTexts: { "0": ["library"], "1:": ["park"] }`. `"1:"` should be `"1"`.
  - Impact: Cosmetic documentation fix; runtime fixtures already use valid 1-indexed values.
- **Item 11 — Document rotation & SHA verification**
  - Location: Repository root docs.
  - Description: `HANDOFF_SPRINT3.md` is preserved as historical record; `HANDOFF_SPRINT4.md` serves as the active handoff document. Fresh sessions must verify SHAs via `git log` before starting tasks.
- *Parent track planning note:* These items can be picked up as warm-ups or batched together with trivial schema edits.

### 2. Data Hygiene
- **Item 1 — 6 zero-Idx residual rows in `ielts-reading-practice-{1,2}`**
  - Location: `exam-db` questions table.
  - Description: Investigate Section X residual rows with Idx > 100 or duplicated ordinals. Audit and determine whether to DELETE or re-index.
- **Item 2 — 18 blank-q rows in `mentor/*` and `mini-ielts*` exams**
  - Location: `exam-db` exams and questions.
  - Description: Audit legacy exams with `blank-q\d+` placeholder patterns. Once verified, execute `scripts/migrate_blank_keys_to_1_indexed.py` using live ports (`EXAM_DB_PORT=32779 ATTEMPT_DB_PORT=32780`).
- **Item 3 — Seeder file UUID convention cleanup**
  - Location: `services/exam-service/Data/ReadingSeeder.cs` (lines 99, 116, 132, 146, 163, 179, 194, 208, 225, 240), `ListeningSeeder.cs`, `GeneratedReadingSeeder.cs`.
  - Description: Replace brittle test-pattern UUIDs (`Guid.Parse("33333333-3333-3333-3333-33333333333X")`) with deterministic `Guid.NewGuid()` maps keyed by question index so fresh seeds do not reintroduce hardcoded UUIDs into Section 1.
- *Parent track planning note:* Run read-only SQL audits first to inspect affected rows before executing database updates or seeder modifications.

### 3. Engineering
- **Item 6 — DRY `cleanAnswer` helper**
  - Location: `langfens-fe-app/src/lib/cleanAnswer.ts`.
  - Description: G15 tightened the inline regex in do-test cards (`8e3126c`). Consolidate duplicated regex logic into a central helper module.
- **Item 7 — DRY `buildQuestion` helper**
  - Location: `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/_components/cards/`.
  - Description: Question object assembly logic is duplicated across multiple card components; extract into a shared utility function.
- **Item 8 — Vitest test infrastructure**
  - Location: `langfens-fe-app/package.json`.
  - Description: Install `vitest`, configure the test runner, add an npm `test` script, and un-skip test files including `ResultV3Review.parseUserAnswer.test.ts`.
- **Item 9 — G11 dispatcher fallback stub**
  - Location: `langfens-fe-app` test runner card dispatcher.
  - Description: The current fallback for unhandled question types is `console.warn` returning `null`. Implement a visible UI card stating "Unsupported question type: [TYPE]" to prevent silent render failures.
- **Item 10 — Migration script naming and scope clarification**
  - Location: `Project_Langfens_Microservice/scripts/`.
  - Description: Distinguish `scripts/migrate_blank_placeholders.py` (migrates `[N]` text placeholders in `.cs` seeder SQL) from `scripts/migrate_blank_keys_to_1_indexed.py` (migrates live PostgreSQL JSONB keys from 0 to 1). Add documentation or standardize script naming.
- *Parent track planning note:* Prioritize Vitest setup (Item 8) early to give immediate regression protection for DRY refactors (Items 6 & 7).

---

## §3 — Sprint 4 readiness checklist

Re-published from §11 of `HANDOFF_SPRINT3.md` with final closure statuses (Sprint 4 closed 2026-09-11):

1. **Fix `scripts/migrate_blank_keys_to_1_indexed.py` port hardcode.** — **DONE** in commit `25f1d29` (`feat(scripts): commit env-driven migration script for 0→1 blank key shift`). The script reads `EXAM_DB_PORT` and `ATTEMPT_DB_PORT` from environment variables, falling back to compose ports (5433/5435), allowing direct execution against live Docker ports (32779/32780).
2. **Apply migration script** to any DB introducing 0-idx rows later — **DONE** via Phase 3.4 verification: `docs/sprint4/VERIFICATION_2026-09-11.md` Check 5+6 confirms 0 rows with key `"0"` in both `exam-db` (`BlankAcceptTexts ? '0'`) and `attempt-db` (`TextAnswer LIKE '%"0":%'`). Live DB was migrated externally between Phase 2.2 audit and Phase 3.4 verification. Script extension with MCQ-scan capability landed in `scripts/migrate_blank_placeholders.py` (uncommitted, BE working tree) — commit on demand when re-seed occurs.
3. **Verify Group C bugs (C1–C6)** from earlier gap analysis; mark REAL or HALLUCINATED per item. — **DONE** via `docs/sprint4/VERDICT_groupC.md` — 0 REAL / 6 HALLUCINATED.
4. **Address Group D backlog** (§2 — 10 active items across Quick Wins, Data Hygiene, and Engineering). — **PARTIAL DONE**. Sub-item outcomes:
   - Item 1 (zero-Idx residuals in `ielts-reading-practice-{1,2}`): **DONE / no action** — `docs/sprint4/AUDIT_zeroIdx.md` classified as LEGITIMATE.
   - Item 2 (18 blank-q rows in `mentor/*` and `mini-ielts*`): **DONE / no action** — `docs/sprint4/AUDIT_blankQ.md` classified as PARTIAL with DB already canonical (verified `docs/sprint4/UUID_CHECK_11111111.md`, 0 remaining `11111111-1111-1111-1111-1111111111XX` UUIDs).
   - Item 3 (Seeder UUID convention cleanup): **DEFERRED to Sprint 5** (multi-file, touches live DB UUIDs on next seed).
   - Item 6 (DRY `cleanAnswer` helper): **DEFERRED to Sprint 5** (depends on Vitest, now in place).
   - Item 7 (DRY `buildQuestion` helper): **DEFERRED to Sprint 5** (depends on Vitest).
   - Item 8 (Vitest test infrastructure): **DONE** via FE commits `5c7319e` (Vitest 2.1 + react plugin + happy-dom install) + `3ff2e41` (Vitest config rewrite: happy-dom + `.tsx` glob). 9 tests passing (2 previously skipped files now run).
   - Item 9 (G11 dispatcher fallback stub): **DEFERRED to Sprint 5** (independent).
   - Item 10 (Migration script naming and scope clarification): **DONE** via commit `2c5843c` (`docs(scripts): clarify migrate_blank_* scope`).
5. **Cleanup MAP_LABEL `"1:"` typo** in `src/app/admin/_lib/questionSchemas.ts:394` (cosmetic). — **DONE** in commit `1c2d1b3` (FE: typo fix + 0-key sibling fix).

---

## §4 — Manual verification steps

Use these steps to re-verify the baseline closure state and live system health:

```bash
# 1. Branch check
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice && git branch --show-current
cd /home/khoa/Projects/langfens/langfens-fe-app && git branch --show-current
# Expected on both: refactor/sync-dotest-admin-renderer

# 2. Commit graph
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice && git log --oneline | head -10
cd /home/khoa/Projects/langfens/langfens-fe-app && git log --oneline | head -10

# 3. Zero 0-indexed keys
docker exec exam-db-server-7c03dc93 sh -c \
  'PGPASSWORD=exam psql -U exam -d exam-db -c \
    "SELECT COUNT(*) FROM exam_questions WHERE \"BlankAcceptTexts\" ? '\''0'\'';"'
# Expected: count = 0

docker exec attempt-db-server-7c03dc93 sh -c \
  'PGPASSWORD=attempt psql -U attempt -d attempt-db -c \
    "SELECT COUNT(*) FROM attempt_answer WHERE \"TextAnswer\" LIKE '\''%\"0\":%'\'';"'
# Expected: count = 0

# 4. Section 1 layout
docker exec exam-db-server-7c03dc93 sh -c \
  'PGPASSWORD=exam psql -U exam -d exam-db -c \
    "SELECT q.\"Idx\", q.\"Type\", q.\"Id\"::text, LEFT(q.\"PromptMd\", 50) AS prompt, q.\"BlankAcceptTexts\" FROM exam_questions q JOIN exam_sections s ON s.\"Id\" = q.\"SectionId\" JOIN exams e ON e.\"Id\" = s.\"ExamId\" WHERE e.\"Slug\" = '\''ielts-reading-practice-1'\'' AND s.\"Idx\" = 0 ORDER BY q.\"Idx\";"'
# Expected: 5 rows, Idx 0/1/3/3/4, Idx=3 SENTENCE_COMPLETION has dict {"1":[...],"2":[...],"3":[...]}

# 5. BE tests
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj --no-build 2>&1 | tail -10

# 6. FE typecheck
cd /home/khoa/Projects/langfens/langfens-fe-app
npx tsc --noEmit 2>&1 | tail -10

# 7. Sprint 4 Migration Script dry-run check
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
EXAM_DB_PORT=32779 ATTEMPT_DB_PORT=32780 python3 scripts/migrate_blank_keys_to_1_indexed.py
# Expected: pre_texts_with_key_0: 0, pre_with_key_0: 0, OK
```

## §6 — Sprint 4 Closure Summary

> Closure date: 2026-09-11
> Branches: BE `refactor/sync-dotest-admin-renderer` HEAD `2c5843c` (1 commit on Sprint 4: BE doc), FE `refactor/sync-dotest-admin-renderer` HEAD `3ff2e41` (3 commits on Sprint 4: FE typo + 2 vitest commits).
> Sprint 4 working tree (BE): `M scripts/migrate_blank_placeholders.py` (uncommitted), `M HANDOFF_SPRINT3.md`, `?? HANDOFF_SPRINT4.md`, `?? docs/sprint4/*` (gitignored).

### Shipped
| Item | Commit / Doc |
|---|---|
| Port hardcode fix (carryover Sprint 3) | `25f1d29` |
| FE MAP_LABEL typo + 0-key sibling fix | `1c2d1b3` |
| BE migration script doc clarifier | `2c5843c` |
| FE Vitest 2.1 + react plugin + happy-dom install | `5c7319e` |
| FE Vitest config rewrite (happy-dom + .tsx glob) | `3ff2e41` |
| Zero-Idx audit verdict | `docs/sprint4/AUDIT_zeroIdx.md` |
| Blank-Q audit verdict | `docs/sprint4/AUDIT_blankQ.md` |
| Group C C1-C6 verdict | `docs/sprint4/VERDICT_groupC.md` |
| Full Sprint 4 verification (8 invariants) | `docs/sprint4/VERIFICATION_2026-09-11.md` |
| Phase 4 implementation plan | `docs/sprint4/PHASE4_PLAN.md` |
| Plan + Review (with 8 fixes applied) | `docs/sprint4/PLAN.md`, `docs/sprint4/REVIEW.md` |

### Deferred to Sprint 5
| Item | Reason |
|---|---|
| Migration script extension commit (BE working tree) | DB already canonical; commit on demand when re-seed occurs |
| Sprint 5 deferred backlog: Seeder UUID cleanup (Item 3) | Multi-file, touches live DB UUIDs on next seed |
| DRY cleanAnswer (Item 6) | Depends on vitest (now in place) |
| DRY buildQuestion (Item 7) | Depends on vitest |
| G11 dispatcher UI fallback (Item 9) | Independent |

### Risks for Sprint 5
- `scripts/migrate_blank_placeholders.py` extension is uncommitted on BE. If a hotfix touches this file before commit, the MCQ-scan capability may be lost.
- `docs/sprint4/*.md` are gitignored under `/docs/`. Sprint 5 must either commit them (force-add or relax gitignore) or regenerate.
- 13 MCQ rows were migrated externally between Phase 2.2 audit and Phase 3.4 verification. Audit trail for who/when is unknown (session logs were searched but no script execution found).

---

## §7 — Acronyms / glossary

- **S32** (Sprint 3 Appendix Gap #32): Standardization of the `[N]` placeholder convention. Completion-family questions use literal `[1] [2] [3]` in the prompt paired 1-to-1 with `{"1":..., "2":..., "3":...}` dictionary keys. Phased delivery: P1 = validator tighten + admin schema revert + Python audit tool + JSON schema doc + safety-net README (`4c77bcb` + `1e885b2` + `f89135d` + `d2b7615` + `44e3454`); P2 = retire `___` runtime fallback in `CompletionCardV3` (`d119a8b`); P3 = rewrite seed SQL to `[N]` ordinal (`14679b9`); follow-on = validator skip DIAGRAM/MAP false-positives (`43352d3`).
- **S31** (Sprint 3 Appendix Gap #31): Click-to-add-blank UX. Admin clicks a button in the prompt textarea toolbar to insert `[N]` at cursor and atomically instantiate the matching dictionary entry. Shipped via `c621516` (cursor insertion toolbar) + `e9ac69c` (`validatePromptBlanksCoverage` validator).
- **Fix A** (`41b5720`): Admin question-save flow refactoring. `handleSaveQuestion` calls `loadSection(sectionId)` (scoped refetch, avoiding full `loadExam()`) and triggers `showToast()`. The `Duplicate` button gained a `window.confirm` guard (`QuestionEditor.tsx:566`) and explicit label.
- **Fix B** (DB-only): Section 1 canonical restoration for `ielts-reading-practice-1`. Corrected drifted state by deleting misplaced/corrupted records and inserting canonical question 4 with `gen_random_uuid()`. Verified: 5 rows Idx 0..4 with Idx=3 SENTENCE_COMPLETION carrying 1-indexed dictionary.
- **Option X**: Stack-wide 1-indexed blank key convention. Delivered in `d25ae5f` (BE seeders + tests) + `1cb7ed0` (FE learner runtime, admin validation, schemas, and tests). Migration script `scripts/migrate_blank_keys_to_1_indexed.py` was made env-aware and committed in `25f1d29`.
- **MS2** (Sprint 2): Milestone 2 gap deliverables referenced by seeder conventions. Commit `be186fb` provides per-type validation rules introduced in Sprint 2 that remain active constraints.
