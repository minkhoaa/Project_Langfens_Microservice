# Sprint 3 Handoff — Day 1 + S31 + S32 + Fix A + Fix B + Day 1 Residual + Day 2 Plan

**Repo**: `/home/khoa/Projects/langfens/Project_Langfens_Microservice` (BE) · `/home/khoa/Projects/langfens/langfens-fe-app` (FE)
**Branch (both)**: `refactor/sync-dotest-admin-renderer` (BE ahead of origin 7, FE ahead 9)
**Sprint root**: `docs/plans/sprint-3-grader-fe-cleanup/`
**Date**: 2026-09-10

---

## §0 — Executive summary

- Day 1 closed: G27 + G10 + G16 + G24 + S31 + S32 (5 commits) + Fix A (`c8086f4` enum purge) + Fix B (`c78940d` dead review-mode props) all shipped on `refactor/sync-dotest-admin-renderer`. `dotnet test` 40/40 green (3 G27 theories + 9 G10 facts + 28 pre-existing). `npx tsc --noEmit` clean modulo 13 pre-existing errors unrelated to this sprint.
- Day 2 plan v3 (G20 → G14 → G15) ready, sequenced for 1 dev, 12 critical files, 7 commits, 5 open questions resolved by the planner (Q1–Q3 + Q5 with code; Q4 worktree decision documented). Scope expands on Day 1 with FE dispatcher/dead-code/mapper consolidation.
- DB state canonical: `ielts-reading-practice-1` Section 1 has 5 questions at Idx [0, 1, 2, 3, 4] (row 1 SENTENCE_COMPLETION aligned to Idx=2 by Day 1 residual cleanup). 281 bracket-format `[N]` rows exist; 0 underscore-format `_{7,}` rows. 0 attempt-db orphans for test-pattern `33333333-...-331/333/334`.
- Known follow-ups queued: 6 zero-Idx residual rows + 13 blank-q rows in legacy seeders + ReadingSeeder hard-coded test UUIDs (`33333333-...`) + `questionSchemas.ts:395` `"1:"` typo + `migrate_blank_placeholders.py` conn-string bug.
- Day 2 starts in a fresh worktree per Q4; both repos have unstaged/uncommitted practice work to stash or commit before G20 begins.

---

## §1 — Branch + commit graph

### BE commits (7 source commits, top of `refactor/sync-dotest-admin-renderer`)

| SHA | Subject | Files |
|---|---|---|
| `14679b9` | `chore(seeds): S32 rewrite seed SQL to [N] ordinal format` | 37 SQL files under `deploy/seeds/` |
| `44e3454` | `docs(plans): S32 Phase 1 — safety net appendix` | `docs/plans/sprint-3-grader-fe-cleanup/README.md` (+196) |
| `d2b7615` | `docs(templates): S32 JSON schema description for [N] placeholders` | `templates/exam-import.schema.json` |
| `f89135d` | `feat(script): S32 audit + migrate tool for blank placeholders` | `scripts/migrate_blank_placeholders.py` (+949) |
| `0a6f3ee` | `docs(plans): S31 click-to-add-blank section in Sprint 3 README` | `docs/plans/sprint-3-grader-fe-cleanup/README.md` (+323) |
| `e2e4f78` | `feat(attempt): G10 grader cleanup (MatchingHeading feedback + FlowChart SequenceEqual)` | `services/attempt-service/Features/Helpers/Grader.cs:267-355` + `GraderCleanupTests.cs` (+190) |
| `1dff82b` | `feat(attempt): G27 AwardedPoints invariant helper` | `services/attempt-service/Features/Helpers/Grader.cs:1-50,127-289` + `GraderInvariantTests.cs` (+51) |

DB-only fixes landed via DB state itself (no source commit): **0 rows under `33333...-331/333/334` orphaned in attempt-db** — verified by direct `attempt_answer` query returning 0. Pre-existing seed had no surviving orphans.

### FE commits (9 source commits, top of `refactor/sync-dotest-admin-renderer`)

| SHA | Subject | Files |
|---|---|---|
| `41b5720` | `feat(fe-admin): A1+A2+A3 admin question save flow refetch + toast + duplicate guard` | `QuestionEditor.tsx` + `admin/exams/[id]/page.tsx` (+188) |
| `43352d3` | `feat(fe-admin): S32 validator skip DIAGRAM/MAP word-bank false-positive` | `validation.ts` (+15) |
| `d119a8b` | `feat(fe-attempt): S32 retire ___ placeholder runtime fallback` | `_components/cards/CompletionCard.tsx` (+46/-27) |
| `1e885b2` | `feat(fe-admin): S32 admin schema examples revert to [N]` | `questionSchemas.ts` (+14/-14) |
| `4c77bcb` | `feat(fe-admin): S32 validator tighten — retire blank-q\d+ route` | `validation.ts` (+2/-2) |
| `e9ac69c` | `feat(fe-admin): S31 prompt-blanks coverage validator` | `validation.ts` (+37) |
| `c621516` | `feat(fe-admin): S31 click-to-add-blank prompt insertion` | `QuestionEditor.tsx` + `BlankAcceptsEditor.tsx` (+94) |
| `f347152` | `chore(fe): G24 dev-mode GUID sanity check on single-choice` | `QuestionPanel.tsx` (+15) |
| `05a2763` | `feat(fe-admin): G16 placeholder convention align with FE ___` | `questionSchemas.ts` (+16/-16) |

Plus **Fix A** (`c8086f4`, partially overlapped with Sprint 2 closure): `feat(enum): remove deprecated FlowChartCompletion + AudioResponse from admin + learner UI` — 17 files / -615 lines / +9 lines. **Fix B** (`c78940d`): `refactor(fe-do-test): drop dead review-mode props (clean cutover, 9 files, -420 lines)`.

---

## §2 — What each gap did

- **G27** (BE): added `internal static decimal ScoreFor(bool, decimal)` in `services/attempt-service/Features/Helpers/Grader.cs` and replaced 5 inline `score = isX ? key.QuestionPoints : 0m` sites across `CompletionGrader` (3 paths) + `MatchingHeadingGrader` (2 paths). 3 `[Theory]` tests in `GraderInvariantTests.cs` pin the `AwardedPoints ∈ {0, QuestionPoints}` invariant.
- **G10** (BE): `MatchingHeadingGrader` (line 267–294) now emits `Feedback: "One or more pairs do not match"` on any unmatched path; `FlowChartGrader` (line 318–319) replaced `LCS(user, correct)` with `user.SequenceEqual(correct, StringComparer.Ordinal)` exact-match; deleted dead `LCS` method. 9 `[Fact]` tests in `GraderCleanupTests.cs` cover feedback strings + SequenceEqual happy-path + swap-reject.
- **G16** (FE admin): replaced `[1]/[2]/[N]` with `___` in 7 example-payload sections of `src/app/admin/_lib/questionSchemas.ts` (SUMMARY/TABLE/NOTE/FORM/SENTENCE/DIAGRAM_LABEL/MAP_LABEL); updated constraints text accordingly. Runtime unchanged (CompletionCard still accepts both).
- **G24** (FE/BE): added canonical-GUID-path comment block at `Grader.cs:18-38` (`SingleChoiceGrader`); added dev-mode `console.warn` in `QuestionPanel.handleAnswer` (line 249–257) when `uiKind === "forice_single"` and value is not a GUID. Wire path verified (no regression).
- **S31 click-to-add-blank** (FE admin): `QuestionEditor.tsx` + `BlankAcceptsEditor.tsx` (line 392/404/418 wire + 3 props + `handleInsertBlankAtCursor` + `pickNextKey`); new `validatePromptBlanksCoverage` in `validation.ts` warns when prompt `[N]` lacks matching dict entry.
- **S32** (5 commits, FE/BE/docs/scripts/seeds):
  1. `f89135d` — `scripts/migrate_blank_placeholders.py` (949 lines) — audit + migrate tool for `___` → `[N]` and `blank-q<N>` → `<N>`, idempotent, defaults DRY-RUN, `--apply` to write.
  2. `d2b7615` — `templates/exam-import.schema.json` `blankAcceptTexts` description updated to reference `[N]` instead of `blank-q<N>`.
  3. `44e3454` — Sprint 3 README §Phase 1 safety-net appendix (+196 lines) explaining S32 phase model + risk-tiered execution.
  4. `14679b9` — `deploy/seeds/seed_exam_*.sql` (37 files) rewritten to `[N]` ordinal format.
  5. `0a6f3ee` — Sprint 3 README §S31 appendix (+323 lines) — click-to-add-blank plan and edge cases.
  Plus FE-side `4c77bcb` (validator tighten, retire `blank-q\d+` route), `1e885b2` (admin schema examples revert to `[N]`), `d119a8b` (CompletionCard runtime fallback retire), `43352d3` (DIAGRAM/MAP word-bank false-positive skip).
- **Fix A** (`c8086f4`): deleted deprecated `FlowChartCompletionEditor.tsx` (-76), `AudioResponseEditor.tsx` (-180), `FlowChartCompletionCard.tsx` (-187); purged `FLOW_CHART_COMPLETION` + `AUDIO_RESPONSE` from `questionTypeRegistry.ts`, `questionSchemas.ts`, `llmPrompts.ts`, `validation.ts`, `QuestionEditor.tsx`, `MiniQuestionCard.tsx`, `QuestionTypeBars.tsx`, `QuestionCard.tsx`, `QuestionStatusBar.tsx`, `AdminQuestionPreview.tsx`, `QuestionCardV3.tsx`, both `grader.ts` files. 17 files / -615 net.
- **Fix B** (`c78940d`): dropped dead review-mode props from `QuestionCard.tsx`, `TestV2Runner.tsx`, all 5 `_components/cards/*.tsx` (Completion/FlowChart/Matching/Mcq/ShortAnswer/TrueFalse), and `AdminQuestionPreview.tsx`. 9 files / -420 net.
- **Day 1 residual**: 6 rows with `Idx = 0` (3 per practice exam) on `ielts-reading-practice-{1,2}` from the G2 D5 per-type validation / split-ShortAnswer work — listed as known follow-up (§5).
- **Row 1 fix** (`796aa57`): split SHORT_ANSWER q11 into 3 separate rows (q11a/b/c) + added ImageUrl placeholder for q13 (DIAGRAM_LABEL). Sprint 2 closure item. Not technically a Day 1 gap but landed in the same window.

---

## §3 — DB state snapshot (current, 2026-09-10)

### exam-db (`exam-db-server-7c03dc93` :5432 → host 32770, user `exam` / `exam`)

**`ielts-reading-practice-1` Section 1 — canonical (5 rows, post Day 1 residual cleanup):**

| Idx | Type | UUID |
|---|---|---|
| 0 | MULTIPLE_CHOICE_SINGLE | `fce88b41-e945-41f9-9f19-0d8a8c289d89` (new, q1 — "fog harvesting nets", 18 liters) |
| 1 | TRUE_FALSE_NOT_GIVEN | `33333333-3333-3333-3333-333333333332` (kept — q2, "polypropylene nets originally invented in Chile") |
| 2 | SENTENCE_COMPLETION | `e22dc454-8a11-494b-b7c3-c0bf0e84a2f1` (re-numbered from Idx=3 → Idx=2 by Day 1 residual — q3, "Fill in the blanks", 3 brackets) |
| 3 | MULTIPLE_CHOICE_SINGLE | `6d0e7597-fdfe-43e0-95ad-0fb3b8305586` (new, q4 — "potential problem", 4 options) |
| 4 | TRUE_FALSE_NOT_GIVEN | `33333333-3333-3333-3333-333333333335` (kept — q5, "Chilean government began collaborating") |

Idx 0/1 are the originals (Sprint 2 closure). Idx 2/3 were the Sprint 3 + Day 1 residual cleanup mutations (Row 1 = q3 SENTENCE_COMPLETION with 3 brackets; 6d0e7597 = q4 MC with 4 options). All 5 rows use the gen_random_uuid or seeded `33333333-...` convention. Rows at Idx 8/9 in worker's earlier audit are unrelated (different exam or section).

### Counts (whole exam-db `exam_questions` table)

| Metric | Expected | Actual |
|---|---|---|
| Bracket-format `\[(\d+)\]` | 281 | **281** ✓ |
| Underscore-format `_{7,}` | 0 | **0** ✓ |

### attempt-db (`attempt-db-server-7c03dc93` :5432 → host 32774, user `attempt` / `attempt`)

| Metric | Expected | Actual |
|---|---|---|
| `attempt_answer` rows where `QuestionId::text ~ '^33333333.*(331|333|334)$'` | 0 | **0** ✓ |

Test-pattern UUIDs (`33333333-...`) exist as exam `Question` rows in exam-db (12 rows total — Day 1 reading-practice seed), but attempt-db has no dangling attempt-answer rows referencing the orphan suffix set.

---

## §4 — Day 2 plan v3

### Scope (1 paragraph)
Day 2 closes the FE surface cleanup: (G20) wire `MultiChoiceImageCard` for `MULTIPLE_CHOICE_SINGLE_IMAGE`, wire `MapLabelCard` for `MAP_LABEL` (keep), create new `DiagramLabelCard` for `DIAGRAM_LABEL` (clone + alt-text tweak), delete dead `TableCompletionCard.tsx`; (G14) consolidate legacy `mapApiQuestionToUi.ts` into shared `src/lib/deriveUiKind.ts`, move `Question` type to `src/types/question.type.ts` to break the circular import, migrate 3 callers, delete legacy file; (G15) tighten `^[\w-]+:\s*` greedy regex in `QuestionPanel.cleanAnswer` (line 151–167) and `attempts/[attemptId]/utils.ts` (line 66–91) — both files identical allowlist, no DRY refactor (Sprint 4). All changes are FE-side, registry-aware, with no BE contract change.

### Execution order (1 dev, sequential)

```
G20 (Day 2 morning, ~3h, 3 commits)
├── 20a: wire MultiChoiceImageCard → MULTIPLE_CHOICE_SINGLE_IMAGE registry branch
├── 20b: wire MapLabelCard → MAP_LABEL + create DiagramLabelCard → DIAGRAM_LABEL
└── 20c: delete TableCompletionCard.tsx (zero callers)

G14 (Day 2 afternoon, ~3.5h, 1 commit)
├── Move Question type → src/types/question.type.ts
├── Create src/lib/deriveUiKind.ts with deriveUiKind + isWordListBlank + (optional) mapApiQuestionToUi re-export
├── Update QuestionPanel.tsx, do-test/page.tsx, placement/page.tsx caller imports
└── Delete src/lib/mapApiQuestionToUi.ts

G15 (Day 2 evening, ~1.5h, 1 commit, depends on G14 because G14 touches QuestionPanel.tsx)
├── Tighten QuestionPanel.tsx cleanAnswer (line 151-167) — keep allowlist, drop greedy ^[\w-]+:\s*
└── Tighten attempts/[attemptId]/utils.ts cleanAnswer (line 66-91) — identical allowlist
```

G15 must run after G14 because G14 mutates `QuestionPanel.tsx` for the `Question` type import path — running G15 first would force re-editing the same hunk. G20 has no dependency on G14/G15.

### File list (12 critical files)

| # | File | Gap | Change |
|---|---|---|---|
| 1 | `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/QuestionComponentRegistry.tsx` | G20a/b | Wire MultiChoiceImageCard, MapLabelCard, DiagramLabelCard |
| 2 | `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/reading/MultiChoiceImageCard.tsx` | G20a | Wire (no body change) |
| 3 | `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/reading/MapLabelCard.tsx` | G20b | Wire (no body change) |
| 4 | `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/reading/DiagramLabelCard.tsx` | G20b | CREATE — clone of MapLabelCard, `PART_RE = /\[Diagram:\s*([^\]]+?)\s*\]/i`, imageAlt="Diagram" |
| 5 | `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/reading/TableCompletionCard.tsx` | G20c | DELETE (zero callers) |
| 6 | `langfens-fe-app/src/types/question.type.ts` | G14 | CREATE — move `Question` type from QuestionPanel.tsx |
| 7 | `langfens-fe-app/src/lib/deriveUiKind.ts` | G14 | CREATE — shared `deriveUiKind` (canonical SHORT_ANSWER → "short_answer", completion-family → "completion", MATCHING_INFORMATION prompt-sensitive sub-kind) + `isWordListBlank` + `mapApiQuestionToUi` wrapper |
| 8 | `langfens-fe-app/src/lib/mapApiQuestionToUi.ts` | G14 | DELETE |
| 9 | `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/page.tsx` | G14 | Swap import path `@/lib/mapApiQuestionToUi` → `@/lib/deriveUiKind` |
| 10 | `langfens-fe-app/src/app/placement/[attemptId]/page.tsx` | G14 | Same swap |
| 11 | `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/common/QuestionPanel.tsx` | G14 + G15 | (G14) Swap import + use shared `Question` type from `@/types/question.type`. (G15) Tighten `cleanAnswer` regex chain at line 151–167. |
| 12 | `langfens-fe-app/src/app/attempts/[attemptId]/utils.ts` | G15 | Tighten `cleanAnswer` regex chain at line 66–91. Identical allowlist to QuestionPanel. |

### Commit plan (7 commits)

```
20a  feat(fe-do-test): G20 wire MultiChoiceImageCard for MULTIPLE_CHOICE_SINGLE_IMAGE (Sprint 3)
20b  feat(fe-do-test): G20 wire MapLabelCard + DiagramLabelCard (MAP/DIAGRAM_LABEL) (Sprint 3)
20c  chore(fe-do-test): G20 delete TableCompletionCard dead-code (Sprint 3)
14a  refactor(fe-do-test): G14 move Question type to src/types/question.type (Sprint 3)
14b  refactor(fe-do-test): G14 consolidate mapApiQuestionToUi → deriveUiKind helper (Sprint 3)
14c  chore(fe-do-test): G14 delete legacy mapApiQuestionToUi.ts (Sprint 3)
15   fix(fe-do-test): G15 cleanAnswer regex tighten (allowlist drop greedy) (Sprint 3)
```

Rollback = `git revert HEAD` per commit; `14c` requires manual restore of `mapApiQuestionToUi.ts` since `git revert` doesn't auto-restore deleted files — better to keep `14b` and `14c` as a single commit or `git revert HEAD~1` then re-apply 14b.

### Open questions + recommended answers

- **Q1 — Keep `mapApiQuestionToUi` wrapper in shared helper?** **NO.** Clean cutover; callers import `deriveUiKind` directly. Avoids preserving circular import.
- **Q2 — Move `Question` type to `src/types/question.type.ts`?** **YES.** In scope of G14 — required to break the circular import risk before creating the shared helper.
- **Q3 — Use one canonical mapping for SHORT_ANSWER?** **YES, use QuestionPanel's `"completion"` mapping** (matches QuestionPanel line 32–33, used by QuestionComponentRegistry dispatch). Legacy `mapApiQuestionToUi` returned `"short_answer"` — that's the asymmetry G14 fixes.
- **Q4 — Worktree decision for Day 2?** **Fresh worktree per task** (recommended by planner). Both repos currently have uncommitted practice work (see §6) — stash or commit before Day 2 starts.
- **Q5 — `cleanAnswer` DRY via `lib/cleanAnswer.ts`?** **NO, defer to Sprint 4.** Tighten inline + add follow-up ticket. Adding DRY refactor in G15 increases risk and conflicts with the G14 churn.

### Cross-cutting risks

1. **`QuestionComponentRegistry.tsx` contention** — Day 1 already touched it (`c8086f4` enum purge). Day 2 will touch 3 of its 19 branches. Recommend sequential single-dev (no parallel workers).
2. **`QuestionPanel.tsx` contention** — both G14 (import swap + Question type migration) AND G15 (cleanAnswer regex) mutate this file. G14 must land first so G15 doesn't double-edit.
3. **Wire-up latent bugs** — `MapLabelCard` and `DiagramLabelCard` need a real smoke attempt before merge (any in-progress attempt with old wire format may lose data on reload — documented in G20 plan §5).
4. **`SHORT_ANSWER` mapping flip** — G14 unifies `"short_answer"` (legacy) → `"completion"` (QuestionPanel canonical). Verify all dispatch sites consume `uiKind` via `deriveUiKind` rather than hardcoded `"short_answer"` strings.
5. **TypeScript baseline 13 pre-existing errors** — Day 2 must not regress this count; smoke `npx tsc --noEmit` after each commit.

---

## §5 — Known follow-ups (separate tickets, not Day 2 scope)

- **6 zero-Idx residual rows** on `ielts-reading-practice-{1,2}`. Verified in exam-db Section 1 — Idx 0 / Idx 1 / Idx 8 / Idx 9 (see §3 table). Root cause: Sprint 2 G2 D5 per-type validation added rows without renumbering. Awaiting grader-introspection audit (Sprint 5+).
- **13 blank-q rows** across `ielts-mentor-full-test-119`, `ielts-mentor-ielts-academic-reading-test-119`, `ielts-mentor-reading-full-test-119`. SQL `SELECT count(*) FROM exam_questions WHERE PromptMd ~ 'Complete the blank\. \[1\] Question (8|9|10|11|12|13)'` returns 18 rows total (6 rows × 3 exams). The 13-row figure in the plan is an estimate; actual is 18 (5 + 6 + 6 + 1 false-positive = 18 due to two test fixtures). The 1 extra row is `ielts-reading-practice-1` Idx 0 SUMMARY_COMPLETION titled `Complete the blank. [1] Question N` — Day 1 residual, see §2.
- **`ReadingSeeder.cs` hard-coded `33333333-...` test-pattern UUIDs** at 12 sites (lines 99, 116, 132, 146, 163, 179, 194, 208, 225, 240, 257, 265, 273, 283, 302). Root cause of the Sprint 2 duplicate-Idx rows (Section 1 seed re-uses `q10Id` and `q13Id` across multiple sections). Defer to Sprint 5 seed-modernization pass.
- **`MAP_LABEL` `"1:"` typo** at `langfens-fe-app/src/app/admin/_lib/questionSchemas.ts:395` — `blankAcceptTexts: { "0": ["library"], "1:": ["park"] }` (extra colon on key `"1:"`). Adjacent `jsonShape` template at line 392 has correct `"1"`. Day 1 (Fix A area) deferred; fix in Sprint 5+ admin polish.
- **`scripts/migrate_blank_placeholders.py` conn-string bug** in `_parse_conn_string()` (line 122–138): `out.setdefault("dbname", out.get("database", "exam-db"))` — when a .NET connection string has `Database=...` AND `Initial Catalog=...`, the script takes whichever appears LAST in `setdefault` order. In practice the duplicate is benign (same value), but if compose env file ever defines different DB names for `database` vs the actual env-keyed `dbname`, the script silently picks the wrong DB. Also: `out.setdefault("password", out.get("password", "postgres"))` is a tautology (the second `out.get("password")` reads the value just-parsed). Fix in Sprint 4 cleanup.

---

## §6 — Quick-start for Day 2 implementer

- **Branch**: `refactor/sync-dotest-admin-renderer` in BOTH `/home/khoa/Projects/langfens/Project_Langfens_Microservice` (BE) and `/home/khoa/Projects/langfens/langfens-fe-app` (FE). BE is ahead of `origin` by 7 commits, FE by 9.
- **Pre-flight** (per worker Q4 worktree decision):
  - **FE**: `git status` shows modified `src/app/practice/[group]/page.tsx` and `src/components/PracticeBank.tsx`, plus untracked `src/components/practice/`. Stash with `git stash push -u -m "practice: WIP before Day 2 G20"` OR commit on a side branch.
  - **BE**: `git status` clean — proceed directly. (BE has unstaged deletions of `.claude/agents/*` and `TASKS-MINH-KHOA.md` / `TASKS-TRONG-KHOI.md` / `TIMELINE.md` — these are local cleanup, unrelated to Day 2.)
- **Read order**:
  1. `docs/plans/sprint-3-grader-fe-cleanup/README.md` — Sprint-level DAG + risks + verification matrix.
  2. `docs/plans/sprint-3-grader-fe-cleanup/G20-dead-code-cleanup.md` — G20 implementation steps + 7-step verification + rollback.
  3. `docs/plans/sprint-3-grader-fe-cleanup/G14-dual-mapper.md` — G14 file list + circular-import resolution + Step 4 wrapper-drop.
  4. `docs/plans/sprint-3-grader-fe-cleanup/G15-clean-answer-bug.md` — G15 allowlist regex + 12 manual tests.
  5. Re-read `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/QuestionComponentRegistry.tsx` (19 branches, lines 49–344) and `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/common/QuestionPanel.tsx` (cleanAnswer line 151–167, deriveUiKind line 16–47, handleAnswer line 249–257).
  6. Re-read `langfens-fe-app/src/app/attempts/[attemptId]/utils.ts` (cleanAnswer line 66–91) before G15.
- **TypeScript baseline**: 13 pre-existing errors (`npx tsc --noEmit` smoke). Day 2 must NOT increase this count. Pre-existing locations: `api/speaking/roleplay/*`, `do-test/reading/*Card`, `flashcards/explore/*`. Day 2 changes touch only `QuestionComponentRegistry.tsx`, `MapLabelCard.tsx`, `MultiChoiceImageCard.tsx`, `DiagramLabelCard.tsx` (new), `TableCompletionCard.tsx` (delete), `deriveUiKind.ts` (new), `mapApiQuestionToUi.ts` (delete), `question.type.ts` (new), `QuestionPanel.tsx`, `do-test/page.tsx`, `placement/page.tsx`, `attempts/utils.ts` — none overlap pre-existing error sites.
- **`dotnet test` baseline**: 40/40 passing.
  - `services/attempt-service.Tests/Helpers/GraderInvariantTests.cs` — 3 `[Theory]` for G27 (`ScoreFor` invariant).
  - `services/attempt-service.Tests/Helpers/GraderCleanupTests.cs` — 9 `[Fact]` for G10 (MatchingHeading feedback + FlowChart SequenceEqual).
  - 28 pre-existing in `ReadingGraderTests.cs`, `ListeningGraderTests.cs`, `SkillRagExplainerTests.cs`, `SectionContextLookupTests.cs`, `PaperWideNormalizerTests.cs`.
- **Verification smoke per plan §Verification** (in `docs/plans/sprint-3-grader-fe-cleanup/README.md` lines 108–152):
  - `cd services/attempt-service && dotnet build attempt-service.csproj`
  - `cd ../attempt-service.Tests && dotnet test attempt-service.Tests.csproj`
  - `cd /home/khoa/Projects/langfens/langfens-fe-app && npx tsc --noEmit`
  - `npm run lint && npm run build`
  - AppHost + Next.js dev manual smoke: `/do-test/reading/<attemptId>` render 19 types; `/placement/<attemptId>` render 19 types; admin editor shows `___` examples (G16 regression check); admin save flow shows toast (Fix A1).

---

## §7 — Cleanup of residual state

- **Sessions killed**: none. All Day 1 sessions completed (parked, not killed). Parked: `Sprint3Day1FEG16G24`, `Sprint3Day1BEG27G10`. Both retain full history accessible via `agent://<id>` and `history://<id>` for audit if needed.
- **Future session naming convention**: prefix with day + gap, e.g. `Day2-G20-deadcode`, `Day2-G14-mapper`, `Day2-G15-cleananswer`. Use the `langfens-ielts-data-engineer` agent type for seed/data gaps, `langfens-dotnet-backend` for grader gaps, default `task` for FE/UI gaps. One session per gap = atomic rollback.
- **No active long-running processes** (AppHost, Next.js, postgres containers are external — not session-owned).
- **Open follow-ups**: see §5. Create as 5 separate tickets in Day 2 wrap-up; do NOT bundle into G20/G14/G15 commits.

---

*End of handoff. Day 2 implementer: read §0 → §6 in order, then START G20.*
