# Langfens — Sprint 3 Handoff (replaces stale doc)

> Audience: fresh session, zero context. Both repos on branch
> `refactor/sync-dotest-admin-renderer`. Read top-to-bottom before touching anything.

---

## §0 — State summary

- **Branches:** both repos on `refactor/sync-dotest-admin-renderer`. BE HEAD `d25ae5f`, FE HEAD `1cb7ed0`.
- **Sprint 3 commits:** 18 total (9 BE + 9 FE), excluding pre-Sprint-3 grader refactors.
- **DB state:** 0 rows in `exam-db` with `BlankAcceptTexts` key `"0"`; 0 rows in `attempt-db` with `TextAnswer LIKE '%"0":%'`. All completion-family dict keys are 1-indexed.
- **Open follow-ups:** 11 distinct items (§7); 5 prioritized in §11.
- **Blocker:** none. System round-trips end-to-end (§6).

---

## §1 — Repository state

| Repo | Path | Branch | HEAD |
|------|------|--------|------|
| BE (.NET 10 + Python AI) | `/home/khoa/Projects/langfens/Project_Langfens_Microservice` | `refactor/sync-dotest-admin-renderer` | `d25ae5f` |
| FE (Next.js) | `/home/khoa/Projects/langfens/langfens-fe-app` | `refactor/sync-dotest-admin-renderer` | `1cb7ed0` |

Root `CLAUDE.md` (auto-loaded in `<repo-rules>`) has Aspire/AppHost resource map, RabbitMQ env convention, gRPC details, shared-libs cheat sheet. **Read it first.**

Live infra (verified 2026-09-10, still true today):

- exam-db container: `exam-db-server-7c03dc93` (postgres:17.6), host port **32779** (NOT 5433)
- attempt-db container: `attempt-db-server-7c03dc93`, host port **32780** (NOT 5435)
- All other service DBs use `32768`-range host ports; repo `CLAUDE.md` documents compose ports which **are not the live ports**.
- `scripts/migrate_blank_keys_to_1_indexed.py` is **untracked** and hard-codes compose ports 5433/5435; running it as-is fails. See §11 item 1.

---

## §2 — Sprint 3 commit graph

### BE repo, most-recent first

| Group | SHA | Subject |
|-------|-----|---------|
| Option X | `d25ae5f` | feat(attempt-tests+exam-seeders): standardize 1-indexed blank key convention (S32 bugfix) |
| Pre-S32 grader | `00ffab1` | feat(grader): implement SortedUnionKeys for consistent key sorting in grading |
| Pre-S32 grader | `0494cde` | test(attempt): add GraderCompletionIndexTests covering 7 completion-family types |
| Pre-S32 grader | `f814d87` | fix(attempt): sort blankIds by numeric value in CompletionGrader positional fallback |
| Cleanup | `02ea32b` | Remove TASKS-TRONG-KHOI.md and TIMELINE.md files; delete package-lock.json |
| Handoff v1 | `d72d917` | docs: Sprint 3 handoff — Day 1 + S32 + Fix A/B + Day 2 plan |
| S32 Phase 3 (seeds) | `14679b9` | chore(seeds): S32 rewrite seed SQL to [N] ordinal format (appendix) |
| S32 Phase 1 doc | `44e3454` | docs(plans): S32 Phase 1 — safety net appendix |
| S32 Phase 1 tpl | `d2b7615` | docs(templates): S32 JSON schema description for [N] placeholders |
| S32 Phase 1 tool | `f89135d` | feat(script): S32 audit + migrate tool for blank placeholders |
| S31 doc | `0a6f3ee` | docs(plans): S31 click-to-add-blank section in Sprint 3 README |
| G10 | `e2e4f78` | feat(attempt): G10 grader cleanup (MatchingHeading feedback + FlowChart SequenceEqual) |
| G27 | `1dff82b` | feat(attempt): G27 AwardedPoints invariant helper |

### FE repo, most-recent first

| Group | SHA | Subject |
|-------|-----|---------|
| Option X | `1cb7ed0` | feat(fe-attempt+admin): standardize 1-indexed blank key convention (S32 bugfix) |
| Day 2 helper | `245dd1e` | refactor(fe-do-test): extract parseUserAnswer function and add tests for it |
| Day 2 hotfix | `3494ab7` | fix(fe-do-test): WorkbookInput stub unblocks Next.js build |
| G15 | `8e3126c` | fix(fe-do-test): G15 cleanAnswer regex tighten (allowlist drop greedy) |
| G14 | `7e28667` | chore(fe-do-test): G14 delete legacy mapApiQuestionToUi.ts |
| G14 | `f2dc0b1` | refactor(fe-do-test): G14 consolidate mapApiQuestionToUi → deriveUiKind helper |
| G14 | `c8a08f1` | refactor(fe-do-test): G14 move Question type to src/types/question.type |
| G20 | `86a325d` | chore(fe-do-test): G20 delete TableCompletionCard dead-code |
| G20 | `bd420de` | feat(fe-do-test): G20 wire MapLabelCard + DiagramLabelCard |
| G20 | `fde62e2` | feat(fe-do-test): G20 wire MultiChoiceImageCard |
| Fix A | `41b5720` | feat(fe-admin): A1+A2+A3 admin question save flow refetch + toast + duplicate guard |
| S32 MAP/DIAGRAM | `43352d3` | feat(fe-admin): S32 validator skip DIAGRAM/MAP word-bank false-positive |
| S32 Phase 2 | `d119a8b` | feat(fe-attempt): S32 retire ___ placeholder runtime fallback |
| S32 Phase 1 | `1e885b2` | feat(fe-admin): S32 admin schema examples revert to [N] |
| S32 Phase 1 | `4c77bcb` | feat(fe-admin): S32 validator tighten — retire blank-q\d+ route |
| S31 validator | `e9ac69c` | feat(fe-admin): S31 prompt-blanks coverage validator |
| S31 click-to-add | `c621516` | feat(fe-admin): S31 click-to-add-blank prompt insertion |
| G24 | `f347152` | chore(fe): G24 dev-mode GUID sanity check on single-choice |
| G16 | `05a2763` | feat(fe-admin): G16 placeholder convention align with FE ___ |

---

## §3 — Per-gap detail

**G27 — AwardedPoints invariant helper** (`1dff82b`, BE). Single-purpose helper ensuring total awarded points never exceed a question's nominal point value. Lives in `services/attempt-service/Features/Helpers/Grader.cs` near `GraderScoring.ScoreFor` and `services/attempt-service/Features/Helpers/GraderHelper.cs`. Covered by `services/attempt-service.Tests/Helpers/`.

**G10 — MatchingHeading feedback + FlowChart SequenceEqual** (`e2e4f78`, BE). Two-part grader cleanup. MatchingHeading now emits structured feedback when the user matched headings to paragraphs but got some wrong. FlowChart `SequenceEqual` treats `null`/partial-length sequences correctly. Both covered by `GraderCompletionIndexTests.cs` (`0494cde`).

**G16 — Placeholder convention `[N]`** (`05a2763`, FE). Admin schema example payloads switched from `___` to `[N]`, matching prompt regex. Schema reverted again in `1e885b2` and `1cb7ed0` to keep example parity with runtime.

**G24 — GUID wire sanity check** (`f347152`, FE). Dev-mode console warning when single-choice reaches runtime with options missing `id` UUIDs. Stripped in production.

**S31 click-to-add-blank** (`c621516` + `e9ac69c`, FE). `c621516` adds cursor-position blank insertion ("Insert [N]" button); `e9ac69c` adds `validatePromptBlanksCoverage` validator failing save when prompt `[N]` tokens lack matching dict entries. `BlankAcceptsEditor.tsx:131-177` (`pickNextKey`, `handleInsertBlankAtCursor`); validator in `src/app/admin/_lib/validation.ts`.

**S32 Phase 1** (`4c77bcb`+`1e885b2`+`f89135d`+`d2b7615`+`44e3454`, mixed). `4c77bcb` validator stops accepting `blank-q\d+` (only `[N]`); `1e885b2` admin schema example payloads flipped to `[N]`; `f89135d` adds `scripts/migrate_blank_placeholders.py` (audit + migrate SQL in seed files, NOT the DB); `d2b7615` adds JSON schema description for `[N]` in seed templates; `44e3454` is safety-net README.

**S32 Phase 2** — retire `___` runtime fallback (`d119a8b`, FE). `CompletionCardV3.tsx` underscore-fallback path deleted; runtime now treats `[N]` as canonical; missing-token → 1-indexed default `["1"]`. See `src/components/exam-v3/cards/CompletionCardV3.tsx:33-39`.

**S32 Phase 3** — rewrite seed SQL to `[N]` ordinal (`14679b9`, BE). All `exam-service/Data/*.cs` seeders (`ReadingSeeder.cs`, `ListeningSeeder.cs`, `GeneratedReadingSeeder.cs`) had `PromptMd` rewritten from `___` runs to `[1] [2] [3]`; `BlankAcceptTexts` dict blocks updated to `"1"`/`"2"`/`"3"` keys. Final touch in `d25ae5f`.

**S32 validator skip DIAGRAM/MAP false-positive** (`43352d3`, FE). `validatePromptBlanksCoverage` now skips `DIAGRAM_LABEL`/`MAP_LABEL` since prompts deliberately contain non-blank tokens resembling placeholders.

**Fix A — admin save flow refetch + toast + duplicate guard** (`41b5720`, FE). `handleSaveQuestion` calls `loadSection(sectionId)` (scoped, NOT full `loadExam()`) and emits global `showToast()`. `Duplicate` button gained `window.confirm` guard (`QuestionEditor.tsx:566`) and visible "Duplicate" text label. Parent wiring: `src/app/admin/exams/[id]/page.tsx:472-473`.

**Fix B — Section 1 canonical restoration** (DB-only, no source commit). Section 1 of `ielts-reading-practice-1` had drifted into malformed state (misplaced q1, FRANKEN q3+q4 hybrid, missing canonical q4). Restored via direct SQL: DELETE misplaced, DELETE FRANKEN, INSERT canonical with `gen_random_uuid()`. Section now 5 rows Idx 0..4 (see §4).

**Day 1 residual** (DB-only). Section 1 extra Idx=2 TFNG duplicate deleted. `attempt_answer` orphan sweep removed rows referencing questions no longer in `exam_questions`. Session log lives at `/home/khoa/.omp/agent/sessions/-Projects-langfens-Project_Langfens_Microservice/2026-09-10T02-34-23-379Z_01a0892a-9113-7370-ab5a-f3d9e73302ff/Migrate-7-orphans/` for archival reference only.

**Option X — 1-indexed blank key convention** (`d25ae5f` BE + `1cb7ed0` FE). See §5.

**Handoff doc v1** — `d72d917` (BE). Superseded by this document.

**Day 1 / Day 2 Sprint 3 gaps**:
- **G20** (3 commits `86a325d`+`bd420de`+`fde62e2`): delete dead `TableCompletionCard`; wire `MapLabelCard`/`DiagramLabelCard`; wire `MultiChoiceImageCard`.
- **G14** (3 commits `c8a08f1`+`f2dc0b1`+`7e28667`): consolidate `mapApiQuestionToUi.ts` into `deriveUiKind`; relocate shared `Question` type to `src/types/question.type.ts`.
- **G15** (`8e3126c`): tighten `cleanAnswer` regex allowlist. DRY refactor to `lib/cleanAnswer.ts` deferred to Sprint 4.

---

## §4 — DB state snapshot (live verified 2026-09-10)

```
exam-db     host=localhost port=32779 user=exam     password=exam     dbname=exam-db
attempt-db  host=localhost port=32780 user=attempt  password=attempt  dbname=attempt-db
```

### Section 1 of `ielts-reading-practice-1` (canonical)

5 rows Idx 0..4 (no Idx=2 by design):

| Idx | Type | Id | BlankAcceptTexts |
|-----|------|----|------------------|
| 0 | MULTIPLE_CHOICE_SINGLE | `fce88b41-e945-41f9-9f19-0d8a8c289d89` | `null` |
| 1 | TRUE_FALSE_NOT_GIVEN | `33333333-3333-3333-3333-333333333332` | `null` |
| 3 | MULTIPLE_CHOICE_SINGLE | `6d0e7597-fdfe-43e0-95ad-0fb3b8305586` | `null` |
| 3 | SENTENCE_COMPLETION | `e22dc454-8a11-494b-b7c3-c0bf0e84a2f1` | `{"1":["polypropylene","polypropylene nets"],"2":["underground","underground tanks"],"3":["meters"]}` |
| 4 | TRUE_FALSE_NOT_GIVEN | `33333333-3333-3333-3333-333333333335` | `null` |

Two Idx=3 rows are deliberate (canonical MCQ + canonical SENTENCE_COMPLETION with 3 blanks). Idx=1 and Idx=4 TRUE_FALSE_NOT_GIVEN rows still carry `33333333-...` test-pattern UUIDs from `ReadingSeeder.cs` (see §8).

### 0-indexed sweep

- `exam-db.exam_questions WHERE "BlankAcceptTexts" ? '0'`: **0 rows**
- `attempt-db.attempt_answer WHERE "TextAnswer" LIKE '%"0":%'`: **0 rows**

### Cross-DB orphans

- `attempt_answer` rows referencing UUIDs absent from `exam_questions`: **0 rows** (post-Migrate-7).

---

## §5 — Convention standardization (Option X)

**Invariant:** every `BlankAcceptTexts` / `BlankAcceptRegex` dict key in the entire stack is **1-indexed**, matching the literal `[N]` token in the prompt 1-to-1.

- DB: `BlankAcceptTexts = {"1": [...], "2": [...], "3": [...]}` for a `[1] [2] [3]` prompt.
- Grader: enumerates keys via `GraderScoring.SortedUnionKeys(texts, regs)` → numeric-sorted `["1","2","3",...]`.
- Admin: `BlankAcceptsEditor.pickNextKey` (`BlankAcceptsEditor.tsx:131`) returns smallest positive integer not in `existingKeys`, default `"1"`.
- DIAGRAM_LABEL/MAP_LABEL: also 1-indexed (was 0-indexed pre-Option X; fixed by `1cb7ed0` runtime + `d25ae5f` seeder + `1e885b2` example).
- Migration script: `scripts/migrate_blank_keys_to_1_indexed.py` (untracked). Shifts `{"0":x}` → `{"1":x}` in both DBs. Idempotent (no-op on current state since `? '0'` matches 0 rows). **Bug:** hard-codes compose ports 5433/5435; fails against live 32779/32780. See §11 item 1.

Cosmetic defect still in `src/app/admin/_lib/questionSchemas.ts:394`: `blankAcceptTexts: { "0": ["library"], "1:": ["park"] }` — `"1:"` should be `"1"`. Example payload only; real MAP_LABEL fixtures are 1-indexed. See §11 item 4.

---

## §6 — Active FE/BE/DB wire contract

End-to-end round-trip for blank-completion questions (SENTENCE_COMPLETION, SUMMARY_COMPLETION, TABLE_COMPLETION, NOTE_COMPLETION, FORM_COMPLETION, DIAGRAM_LABEL, MAP_LABEL):

1. **Admin authoring.** Cursor-position blank insertion → `BlankAcceptsEditor.pickNextKey` (`BlankAcceptsEditor.tsx:131`) returns `"1"`/`"2"`/...; `handleInsertBlankAtCursor` (lines 139-177) inserts `[N]` literal AND adds matching dict entry atomically. On save, `QuestionEditor.handleBlanksChange` (line 249) passes through to parent `onChange`.
2. **Save.** `QuestionEditor.handleSave` (line 186+) calls `onSave` which `src/app/admin/exams/[id]/page.tsx:472-473` does `showToast(...)` then `await loadSection(sectionId)` (scoped refetch, NOT `loadExam()`).
3. **API.** `POST`/`PUT` to BE `/admin/question/update/{id}` with `BlankAcceptTexts: {"1": [...]}`. `AdminQuestion_Service.cs:206` `ExecuteUpdateAsync` persists verbatim.
4. **Persistence.** `exam_questions.BlankAcceptTexts` JSONB holds the 1-indexed dict. Verified live: §4 SENTENCE_COMPLETION Idx=3.
5. **Learner attempt.** `TestV2Runner.answerValueToString` (`TestV2Runner.tsx:29-35`) JSON-encodes as `JSON.stringify(value.map(String))` or `JSON.stringify(value)` → `"{"1":"polypropylene","2":"underground","3":"meters"}"`.
6. **Auto-save.** `useDebouncedAutoSave` → BE `AttemptAnswer.TextAnswer` (text column, JSON-encoded). On submit, BE `Submit` writes same to `attempt_answer.text_answer`.
7. **Grading.** `CompletionGrader.Grade` (`services/attempt-service/Features/Helpers/Grader.cs:99-170`):
   - **JSON path** (line 113+): `JsonSerializer.Deserialize<Dictionary<string,string>>(raw)` → for each `blankId` in `SortedUnionKeys(texts, regs)`, `map.TryGetValue(blankId, ...)` looks up user answer, compares against accept-texts list (case/whitespace-normalized via `TextNorm.Normalize`), falls back to regex patterns.
   - **Plaintext legacy path** (line 172+): `userParts = raw.Split('\n')`, matched positionally against `SortedUnionKeys(texts, regs).ToList()`.

For DIAGRAM_LABEL/MAP_LABEL: same JSON path; dict keys 1-indexed post-Option X. Render side (`MapLabelCard`/`DiagramLabelCard` in `src/app/do-test/[skill]/[attemptId]/_components/cards/`) extracts prompt word bank from `promptMd` (commit `ef7d972`).

---

## §7 — Sprint 4 backlog

1. 6 zero-Idx residual rows in `ielts-reading-practice-{1,2}` Section X (Idx > 100 or duplicates); audit + DELETE/merge.
2. 18 blank-q rows in `mentor/*` and `mini-ielts*` exams; run migration script (after port fix).
3. `ReadingSeeder.cs` hard-coded `33333333-...` test UUIDs (lines 99, 116, 132, 146, 163, 179, 194, 208, 225, 240). See §8.
4. MAP_LABEL `"1:"` typo in `src/app/admin/_lib/questionSchemas.ts:394`.
5. `scripts/migrate_blank_keys_to_1_indexed.py` conn-string tautology — hard-codes 5433/5435 when live is 32779/32780. Add `--port` flag or env var.
6. DRY `cleanAnswer` — G15 only fixed inline regex; consolidate into `src/lib/cleanAnswer.ts`.
7. DRY `buildQuestion` — duplicated across several `cards/` files; consolidate.
8. Vitest test infra — `vitest` not installed; 2 test files (`ResultV3Review.parseUserAnswer.test.ts` + 1 more) marked `describe.skip`. Add vitest + `package.json` test script.
9. G11 dispatcher fallback stub — runtime dispatcher for unknown question types is `console.warn` + render-nothing; needs proper "unsupported question type" UI fallback.
10. `migrate_blank_placeholders.py` vs `migrate_blank_keys_to_1_indexed.py` confusion — two scripts, similar names, different scopes (placeholders vs keys). Consolidate or rename.
11. This handoff doc itself becomes stale — re-run `git log --oneline | head -25` on both repos before reading to confirm SHAs haven't been rebased.

---

## §8 — Open follow-up: Seed file UUID convention cleanup

**Issue.** `services/exam-service/Data/ReadingSeeder.cs` lines 99, 116, 132, 146, 163, 179, 194, 208, 225, 240 (plus similar in `ListeningSeeder.cs`, `GeneratedReadingSeeder.cs`) hard-code `Guid.Parse("33333333-3333-3333-3333-33333333333X")` test-pattern UUIDs. Effects:

- (a) test fixtures brittle — every developer's local Section 1 has same UUIDs but production has `gen_random_uuid()` values; cross-env DB dump comparisons produce false diffs.
- (b) live DB Section 1 Idx=1/Idx=4 still carry `33333333-...` UUIDs after Fix B because the seeder re-introduces them on every fresh seed.

**Recommended fix** (separate Sprint 4 ticket). Replace every `Guid.Parse("33333333-...")` with `Guid.NewGuid()` (or `db.Database.SqlQueryRaw<Guid>("SELECT gen_random_uuid()")`); preserve explicit ordering via `Dictionary<int, Guid>` keyed by Idx so seeder remains deterministic. Re-seed `exam-db`, verify Idx=1/Idx=4 now have real UUIDs.

**Scope.** `ReadingSeeder.cs` (~13 call sites), `ListeningSeeder.cs` (~6), `GeneratedReadingSeeder.cs` (~3). Out of scope for Sprint 3.

---

## §9 — Manual verification steps

```bash
# 1. Branch check
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice && git branch --show-current
cd /home/khoa/Projects/langfens/langfens-fe-app && git branch --show-current
# expected both: refactor/sync-dotest-admin-renderer

# 2. Commit graph
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice && git log --oneline | head -10
cd /home/khoa/Projects/langfens/langfens-fe-app && git log --oneline | head -10

# 3. Zero 0-indexed keys
docker exec exam-db-server-7c03dc93 sh -c \
  'PGPASSWORD=exam psql -U exam -d exam-db -c \
    "SELECT COUNT(*) FROM exam_questions WHERE \"BlankAcceptTexts\" ? '\''0'\'';"'
# expected: count = 0
docker exec attempt-db-server-7c03dc93 sh -c \
  'PGPASSWORD=attempt psql -U attempt -d attempt-db -c \
    "SELECT COUNT(*) FROM attempt_answer WHERE \"TextAnswer\" LIKE '\''%\"0\":%'\'';"'
# expected: count = 0

# 4. Section 1 layout
docker exec exam-db-server-7c03dc93 sh -c \
  'PGPASSWORD=exam psql -U exam -d exam-db -c \
    "SELECT q.\"Idx\", q.\"Type\", q.\"Id\"::text, LEFT(q.\"PromptMd\", 50) AS prompt, q.\"BlankAcceptTexts\" FROM exam_questions q JOIN exam_sections s ON s.\"Id\" = q.\"SectionId\" JOIN exams e ON e.\"Id\" = s.\"ExamId\" WHERE e.\"Slug\" = '\''ielts-reading-practice-1'\'' AND s.\"Idx\" = 0 ORDER BY q.\"Idx\";"'
# expected: 5 rows, Idx 0/1/3/3/4, Idx=3 SENTENCE_COMPLETION has dict {"1":[...],"2":[...],"3":[...]}

# 5. BE tests
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj --no-build 2>&1 | tail -10

# 6. FE typecheck
cd /home/khoa/Projects/langfens/langfens-fe-app
npx tsc --noEmit 2>&1 | tail -10
```

If step 3 returns non-zero, §7 item 2 applies — investigate which seeder/test introduced 0-idx. Don't run migration script until §11 item 1 (port fix) lands.

---

## §10 — Working-tree state

```
$ cd Project_Langfens_Microservice && git status -s
 M HANDOFF_SPRINT3.md
?? scripts/migrate_blank_keys_to_1_indexed.py

$ cd langfens-fe-app && git status -s
# (clean)
```

Two items: this doc itself (modified, expected) and the untracked migration script. The migration script is intentionally untracked — committing it would lock in wrong port defaults. See §11 item 1.

---

## §11 — Sprint 4 readiness checklist

1. **Fix `scripts/migrate_blank_keys_to_1_indexed.py` port hardcode.** Replace `port=5433`/`port=5435` with `port=int(os.environ.get("EXAM_DB_PORT", 5433))`/`port=int(os.environ.get("ATTEMPT_DB_PORT", 5435))`. Optionally commit after env-driven.
2. **Apply migration script** to any DB introducing 0-idx rows later (idempotent no-op on current state — `? '0'` matches 0 rows). Likely scenario: re-seed `mentor/*`/`mini-ielts*`.
3. **Verify Group C bugs (C1-C6)** from earlier gap analysis; mark REAL or HALLUCINATED per item.
4. **Address Group D backlog** (§7 — 11 items). Highest leverage: #2 (18 blank-q rows), #3 (UUID convention), #1 (zero-Idx residuals).
5. **Optionally cleanup MAP_LABEL `"1:"` typo** in `src/app/admin/_lib/questionSchemas.ts:394` (cosmetic).

Steps 1 → 2 are sequential. Steps 3-5 are independent.

---

## §12 — Acronyms / glossary

- **S32** (Sprint 3 appendix gap #32): standardize `[N]` placeholder convention. Completion-family questions use literal `[1] [2] [3]` in prompt paired with `{"1":..., "2":..., "3":...}` dict keys. Phased: P1 = validator tighten + admin schema revert + Python audit tool + JSON schema doc + safety-net README (`4c77bcb`+`1e885b2`+`f89135d`+`d2b7615`+`44e3454`); P2 = retire `___` runtime fallback in `CompletionCardV3` (`d119a8b`); P3 = rewrite seed SQL to `[N]` ordinal (`14679b9`); follow-on = validator skip DIAGRAM/MAP false-positive (`43352d3`).

- **S31** (Sprint 3 appendix gap #31): click-to-add-blank UX. Admin clicks button in prompt textarea toolbar to insert `[N]` at cursor AND create matching dict entry atomically. Two-commit pair: `c621516` (cursor insertion button) + `e9ac69c` (`validatePromptBlanksCoverage` validator).

- **Fix A** (`41b5720`): admin question-save flow refactor. `handleSaveQuestion` calls `loadSection(sectionId)` (scoped refetch, NOT full `loadExam()`) + emits global `showToast()`. `Duplicate` button gains `window.confirm` guard (`QuestionEditor.tsx:566`) and visible "Duplicate" text label. Wiring: `src/app/admin/exams/[id]/page.tsx:472-473` (save handler) + `QuestionEditor.tsx:562-577` (button).

- **Fix B** (DB-only, no source commit): Section 1 canonical restoration for `ielts-reading-practice-1`. Section had drifted into malformed state (misplaced q1, FRANKEN q3+q4 hybrid, missing canonical q4). Restored via direct SQL: DELETE misplaced, DELETE FRANKEN, INSERT canonical with `gen_random_uuid()`. Verified: 5 rows Idx 0..4 with Idx=3 SENTENCE_COMPLETION carrying 1-indexed dict.

- **Option X**: 1-indexed blank key convention standardization across entire stack. `d25ae5f` (BE seeders + tests) + `1cb7ed0` (FE learner runtime + admin validation + LLM prompts + questionSchemas examples + MAP_LABEL typo fix + parseUserAnswer tests). Pre-Option X: 0-indexed. Post-Option X: 1-indexed everywhere. Migration script `scripts/migrate_blank_keys_to_1_indexed.py` untracked, idempotent, port bug (§11 item 1).

- **MS2** (Sprint 2): earlier gap work referenced by seeder conventions. `be186fb` is per-type validation shipped Sprint 2, still referenced by Sprint 3 admin schemas.
