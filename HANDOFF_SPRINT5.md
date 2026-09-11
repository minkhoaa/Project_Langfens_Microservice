# Langfens — Sprint 5 Handoff & Kickoff

> Audience: fresh session, zero context. Both repos on branch `refactor/sync-dotest-admin-renderer`. Sprint 4 closed 2026-09-11. This document defines Sprint 5 scope, readiness, phase breakdown, and acceptance for the four Group D backlog items deferred from Sprint 4 (Item 3, Item 6, Item 7, Item 9) plus the `/docs/` policy decision (Item 0). Read top-to-bottom before touching anything.
> **Review Note:** Technical review conducted in `docs/sprint5/REVIEW.md` (verdict: **APPROVE-WITH-FIXES**). All 10 review findings (DEF-01 through DEF-10) and §4 actionable corrections have been incorporated into this handoff.

---

## §0 — State summary

**Repository & Branch Baseline.** The backend repository (`/home/khoa/Projects/langfens/Project_Langfens_Microservice`) is on branch `refactor/sync-dotest-admin-renderer` at HEAD `0f8fd4f` (Sprint 4 closure BE commit). The frontend repository (`/home/khoa/Projects/langfens/langfens-fe-app`) is on branch `refactor/sync-dotest-admin-renderer` at HEAD `3ff2e41` (Sprint 4 closure FE commit). Sprint 4 is officially closed as of 2026-09-11 with all five §3 readiness items marked DONE or DEFERRED, six Group C bugs declared HALLUCINATED, vitest infrastructure operational (9 tests passing across 2 files), and one backlog item (`scripts/migrate_blank_placeholders.py`) carried into Sprint 5 as an uncommitted working-tree modification.

**Sprint 5 Scope (Carryover).** Sprint 5 picks up four Group D backlog items explicitly DEFERRED from Sprint 4 §3 readiness checklist item #4. Item 3 replaces inline question-ID `Guid.Parse("33333333-…")` literals with deterministic GUID generation (e.g. `SeederHelpers.CreateDeterministicGuid(slug, idx)`) in three exam-service seeder files while preserving literal section/exam UUIDs; Item 6 consolidates two `cleanAnswer` regex implementations into a true union helper in `src/lib/cleanAnswer.ts` preserving case, G15, prefix stripping, and slash tokens; Item 7 extracts `buildQuestion` into `src/lib/buildQuestion.ts` while importing canonical `deriveUiKind` and `isWordListBlank` from `@/lib/deriveUiKind`; Item 9 replaces the silent `null` fallback in `QuestionPanel` with `UnsupportedQuestionCard` throttled by a seen-type warning set. Item 0 (`/docs/` gitignore policy) is added as a Phase 1 deliverable to prevent further accumulation of untracked working docs under `docs/sprint5/`.

**Sprint 5 Readback.** Vitest is operational from Sprint 4 commits `5c7319e` (install) + `3ff2e41` (config rewrite), so Items 6, 7, 9 each have a target test file precedent to extend. No new packages, no Aspire resource-graph changes, no gateway routing changes, no schema migrations are required for Items 6/7/9. Item 3 changes inline seed UUIDs — execution requires capturing `attempt_answer.QuestionId` references for orphan-mapping reconstruction, and the live `exam-db` is not re-seeded during Sprint 5 unless explicitly requested by the parent.
---

## §1 — Repository state

| Repo | Path | Branch | HEAD | Notes |
|------|------|--------|------|-------|
| BE (.NET 10 + Python AI) | `/home/khoa/Projects/langfens/Project_Langfens_Microservice` | `refactor/sync-dotest-admin-renderer` | `0f8fd4f` | Uncommitted: `M scripts/migrate_blank_placeholders.py` |
| FE (Next.js) | `/home/khoa/Projects/langfens/langfens-fe-app` | `refactor/sync-dotest-admin-renderer` | `3ff2e41` | Vitest 2.1 + react plugin + happy-dom operational, 9 tests passing |

Root `CLAUDE.md` contains Aspire/AppHost resource maps, RabbitMQ env conventions, gRPC details, and shared library references. Sprint 4 closure artifacts live under `/docs/sprint4/` (gitignored under root `/docs/`); `HANDOFF_SPRINT4.md` provides historical continuity. Sprint 5 working artifacts land at `/docs/sprint5/` (also gitignored unless Item 0 policy is resolved in Phase 1).

**Sprint 4 closure recap.** Item 1 (port hardcode), Item 4 (MAP_LABEL typo), Item 8 (vitest), and Item 10 (script naming) were SHIPPED. Items 3, 6, 7, 9 were DEFERRED to Sprint 5. Group C bugs C1-C6 were classified HALLUCINATED via `docs/sprint4/VERDICT_groupC.md`. Live DB held canonical state throughout Sprint 4 — `exam-db` Section 1 of `ielts-reading-practice-1` showed 5 rows Idx 0/1/3/3/4 with 1-indexed `BlankAcceptTexts` dict intact. Eight Sprint 4 audit/plan/docs artifacts (~128KB) are sitting untracked under `docs/sprint4/`.

---

## §2 — Sprint 5 scope & carryover

Four Group D items republished from `HANDOFF_SPRINT4.md` §2 (Engineering) + §2 (Data Hygiene). Item 0 added as Phase 1 prerequisite. Execution order intentionally places pure refactors (Items 6/7/9) ahead of the FK-touching seeder rewrite (Item 3) so that any vitest failures from the refactors surface before live-DB risk is introduced.

### Item 0 — `/docs/` policy decision

- **Location:** Both repo roots (`Project_Langfens_Microservice/.gitignore` line 32, `langfens-fe-app/.gitignore` line 29) ignore `/docs/`.
- **Trigger:** Eight Sprint 4 docs (`docs/sprint4/{PLAN,REVIEW,VERIFICATION_2026-09-11,VERDICT_groupC,UUID_CHECK_11111111,AUDIT_zeroIdx,AUDIT_blankQ,PHASE4_PLAN}.md`) plus the parallel Sprint 5 doc set will all be untracked. This accumulates working-doc debt that other agents and reviewers cannot discover via `git log` or `git diff`.
- **Approach:** Three options (no recommendation):
  1. **Force-add existing batch.** `git add -f docs/sprint4/*.md` plus equivalent for Sprint 5. Retros become visible in commit history; the `/docs/` ignore line remains broad.
  2. **Narrow gitignore (DEF-09).** Change root `.gitignore` to allow sprint docs via negation (e.g. `!/docs/sprint*` or un-ignoring `/docs/`), rather than ambiguous glob syntax. Documents each sprint but un-ignores tracked sprint docs cleanly.
  3. **Regenerate in tracked locations.** Move working docs into per-service paths (e.g. `services/exam-service/docs/`, `langfens-fe-app/src/lib/__docs__/`). Splits the docs surface; harder to locate from a single root.
- **Acceptance:** Parent picks one option in Phase 1. Choice recorded in this file's §6 closure summary.

### Item 3 — UUID seeder cleanup

- **Location:**
  - `services/exam-service/Data/ReadingSeeder.cs` (323 lines, 19 `Guid.Parse` calls; question IDs at lines 99, 116, 132, 146, 163, 179, 194, 208, 225, 240, 257, 265, 273, 283, 302 — 15 of them use the `33333333-3333-3333-3333-33333333333X` pattern).
  - `services/exam-service/Data/ListeningSeeder.cs` (522 lines, 24 `Guid.Parse` calls; 19 `55555555-…` question IDs at lines 95, 111, 128, 176, 192, 208, 225, 296, 312, 328, 344, 358, 401, 417, 433, 449, 466, 478, 490).
  - `services/exam-service/Data/GeneratedReadingSeeder.cs` (373 lines, 17 `Guid.Parse` calls; 13 `43333333-…` question IDs at lines 160, 176, 195, 213, 225, 243, 263, 283, 302, 314, 331, 340, 350).
- **Trigger:** Inline `Guid.Parse("33333333-…")` literals are unreadable, easy to typo, and re-seed runs after any code edit can silently re-introduce them. Converting to `Dictionary<int, Guid>` keyed by Idx collapses the literals into one declaration block per file.
- **Approach (deterministic GUID helper — DEF-03):** Instead of non-deterministic `Guid.NewGuid()` or `Random(DateTime.UtcNow.Ticks)`, generate deterministic GUIDs via helper `SeederHelpers.CreateDeterministicGuid(slug, idx)` (e.g. namespace UUIDv5/MD5 hash or static deterministic mapping table); replace each question-ID `var q<N>Id = Guid.Parse(...);` line with `var q<N>Id = qIds[N];`. Non-question IDs (Section/Exam IDs; ~4 in Reading, ~5 in Listening, ~4 in GeneratedReading) remain literal `Guid.Parse` calls because they do not carry question-style ordinals or question FK risk (DEF-08). Sidecar map is generated via standalone staging script, not inline seeder I/O (DEF-10).
- **Acceptance:**
  - Question-ID `Guid.Parse(` literals are eliminated in all three seeder files (remaining literal calls are strictly non-question Section/Exam IDs).
  - `dotnet build services/exam-service/services/exam-service.csproj` exits 0.
  - New test fixture in existing test project `services/attempt-service.Tests/Seeders/ReadingSeederDeterminismTests.cs` (DEF-04 fix) seeds twice and asserts byte-identical `Exam.Id`, `Section.Id`, and `Question.Id` outputs across runs.
  - `scripts/migrate_blank_placeholders.py` (BE working-tree carryover) gains a `Dictionary<Guid, Guid>` block exposing legacy `33333333-…`/`55555555-…`/`43333333-…` → new UUID mappings for FK repair, even if Sprint 5 does not invoke re-seed.

### Item 6 — DRY `cleanAnswer` helper

- **Location:**
  - Canonical: `langfens-fe-app/src/app/attempts/[attemptId]/utils.ts` lines 66-94 (exported, used by review/result views).
  - Inlined: `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/common/QuestionPanel.tsx` line 111 (private, weaker regex — no whitespace collapse, different slash dedup).
- **Trigger:** Two divergent regex chains. The canonical collapses whitespace and dedupes slashes; the inline one does neither. Question-panel submission may diverge from review-page rendering of the same input — risk for grading parity.
- **Approach (true union preserving case and G15 — DEF-01, DEF-02):** Extract true union regex helper into `langfens-fe-app/src/lib/cleanAnswer.ts` with signature `(s: string | undefined | null) => string`. Retain all prefix strips (`blank[-_]`, `label[-_]`, `step[-_]`, `node[-_]`, `feature[-_]`, `q\d+`, `paragraph|info|step|flow|node|part|section`, `heading|item|answer|key|option|part|section|paragraph|info|flow`). **Preserve case** (do NOT call `.toLowerCase()`). Preserve G15 invariant (legitimate answer prefixes like `"Reason: ..."` remain intact). Collapse whitespace (`\s+/g` → `" "`) and deduplicate slash tokens (`"D / D"` → `"D"`, `"A / B"` → `"A"`). Replace inline at `QuestionPanel.tsx:111` with `import { cleanAnswer } from '@/lib/cleanAnswer';`. Replace canonical site with `import { cleanAnswer } from '@/lib/cleanAnswer';` and re-export for back-compat.
- **Acceptance:**
  - `src/lib/cleanAnswer.ts` exists with exported `cleanAnswer` matching the true union specification.
  - `utils.ts` lines 66-94 call `cleanAnswer` (or re-export it after content moves).
  - `QuestionPanel.tsx` line 111 imports `cleanAnswer` instead of inline regex.
  - Existing vitest `langfens-fe-app/src/app/attempts/_components/__tests__/ResultV3Review.parseUserAnswer.test.ts` continues passing. New vitest spec `src/lib/__tests__/cleanAnswer.test.ts` adds cases covering whitespace collapse, slash-dedup edge cases, prefix strips, G15 preservation, case preservation (`"VII"`), undefined input, empty string.

### Item 7 — DRY `buildQuestion` helper

- **Location:**
  - Copy A: `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/page.tsx` lines 50-96 (47 lines).
  - Copy B: `langfens-fe-app/src/app/placement/[attemptId]/page.tsx` lines 56-102 (47 lines, character-for-character identical).
- **Trigger:** Two identical implementations risk divergence. Any future change to `UiQuestion` shape must be applied twice.
- **Approach (DEF-05, DEF-06):** Extract to `langfens-fe-app/src/lib/buildQuestion.ts` with signature `function buildQuestion(q: any): UiQuestion`. Import canonical `deriveUiKind` and `isWordListBlank` from `@/lib/deriveUiKind` (do NOT move or duplicate them). Use `import type { Question as UiQuestion } from "@/types/question.type"`. Both do-test and placement pages import the helper.
- **Acceptance:**
  - `src/lib/buildQuestion.ts` exists with `buildQuestion(q: any): UiQuestion` export and imports from `@/lib/deriveUiKind`.
  - `src/lib/deriveUiKind.ts` remains canonical and untouched.
  - Do-test page and placement page both call `import { buildQuestion } from '@/lib/buildQuestion';`.
  - New vitest spec `src/lib/__tests__/buildQuestion.test.ts` confirms behavior parity with a fixture capturing each Idx/Kind variant observed in production (`Reading`/`Listening`/`Writing` placement + do-test).

### Item 9 — G11 dispatcher fallback card

- **Location:**
  - Registry: `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/QuestionComponentRegistry.tsx` (note: `components/` not `components/common/`).
  - Cards directory: `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/_components/cards/` holds 6 cards (CompletionCard, FlowChartCard, MatchingCard, McqCard, ShortAnswerCard, TrueFalseCard).
  - Test precedent: `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/_components/cards/__tests__/CompletionCard.sort.test.tsx`.
- **Trigger:** Silent fallback: `const TargetComponent = QuestionComponentRegistry[q.backendType]; if (!TargetComponent) questionContent stays null`. Unsupported backend types render as empty UI with no `console.warn`. End-user debugging requires DevTools network inspection.
- **Approach (DEF-07):** Add `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/_components/cards/UnsupportedQuestionCard.tsx` taking `{ backendType: string }` with visible amber warning styling. Wire it directly at the dispatch site in `QuestionPanel.tsx` using an in-memory `seenWarnTypes = new Set<string>()` to throttle `console.warn` to exactly once per unmapped type. Optionally export `FALLBACK = UnsupportedQuestionCard` in `QuestionComponentRegistry.tsx`.
- **Acceptance:**
  - `UnsupportedQuestionCard.tsx` renders visible text `Unsupported question type: <TYPE>` with the actual backend type interpolated.
  - `QuestionPanel.tsx` renders `UnsupportedQuestionCard` when no registered card handles `q.backendType`.
  - New vitest spec `…/cards/__tests__/UnsupportedQuestionCard.test.tsx` asserts: (a) renders the type label and warning icon, (b) falls through to fallback card, (c) `console.warn` fires exactly once per unique unknown type across re-renders (mock with `vi.spyOn`).

---

## §3 — Sprint 5 readiness checklist

1. **Sprint 4 closure acknowledged.** README + handoff continuity confirmed via `HANDOFF_SPRINT4.md` §6 Closure Summary. — **READY** (Sprint 4 closed 2026-09-11).
2. **Vitest operational.** 9 tests passing (Sprint 4 commits `5c7319e` + `3ff2e41`). PostCSS workaround `css: { postcss: {} }` in `langfens-fe-app/vitest.config.ts`. — **READY** (all 4 Sprint 5 FE items can be backed by vitest specs; Item 3 targets .NET and uses an xUnit/NUnit project, no vitest involvement).
3. **Branches aligned.** Both repos on `refactor/sync-dotest-admin-renderer`. Working trees clean except BE `scripts/migrate_blank_placeholders.py` (Item 1 carryover). — **READY with action**: commit or revert the carryover before Sprint 5 starts. See Risk §6 (d).
4. **`/docs/` policy decision (Item 0).** Decide between options 1/2/3 in Phase 1 before authoring `docs/sprint5/PLAN.md` (because the chosen policy affects whether `PLAN.md` is force-added). — **BLOCKED on parent decision** at start of Phase 1.
5. **BE seeder FK risk reviewed.** Item 3 changes seed UUIDs; any new seed may orphan `attempt_answer.QuestionId` references. — **READY with caveat**: Item 3 must run with the existing `exam-db` left untouched in Phase 5. Pre/Post row-count snapshots recorded before and after the seeder rewrite so the FK mapping dictionary has a deterministic source.

---

## §4 — Manual verification steps

Use these steps to re-verify the post-Sprint-4 baseline and validate each Sprint 5 phase boundary. Each block is a real, runnable command sequence.

```bash
# PRE-SPRINT 5 — verify baseline (Sprint 4 closure preserved)
# 1. Branch / HEAD
( cd /home/khoa/Projects/langfens/Project_Langfens_Microservice && git branch --show-current && git log --oneline -1 )
# Expected: refactor/sync-dotest-admin-renderer / 0f8fd4f
( cd /home/khoa/Projects/langfens/langfens-fe-app && git branch --show-current && git log --oneline -1 )
# Expected: refactor/sync-dotest-admin-renderer / 3ff2e41

# 2. Vitest baseline (9 tests passing)
cd /home/khoa/Projects/langfens/langfens-fe-app && npx vitest run --reporter=verbose
# Expected: 2 test files, 9 tests passing

# 3. Item 3 baseline — count Guid.Parse in seeder files
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
grep -c 'Guid\.Parse(' services/exam-service/Data/ReadingSeeder.cs
# Expected: 19
grep -c 'Guid\.Parse(' services/exam-service/Data/ListeningSeeder.cs
# Expected: 24
grep -c 'Guid\.Parse(' services/exam-service/Data/GeneratedReadingSeeder.cs
# Expected: 17

# PHASE 2 (Item 6) — DRY cleanAnswer
cd /home/khoa/Projects/langfens/langfens-fe-app
ls src/lib/cleanAnswer.ts
npx vitest run src/lib/__tests__/cleanAnswer.test.ts
# Expected: cleanAnswer.ts present; vitest reports all cases pass; ResultV3Review.parseUserAnswer.test.ts still green

# PHASE 3 (Item 7) — DRY buildQuestion
cd /home/khoa/Projects/langfens/langfens-fe-app
ls src/lib/buildQuestion.ts
npx vitest run src/lib/__tests__/buildQuestion.test.ts
# Expected: buildQuestion.ts present; vitest reports all cases pass

# PHASE 4 (Item 9) — G11 dispatcher fallback
cd /home/khoa/Projects/langfens/langfens-fe-app
ls src/app/do-test/\[skill\]/\[attemptId\]/_components/cards/UnsupportedQuestionCard.tsx
npx vitest run src/app/do-test/\[skill\]/\[attemptId\]/_components/cards/__tests__/UnsupportedQuestionCard.test.tsx
# Expected: card present; test asserts (a) renders label, (b) ?? falls through, (c) console.warn fires once per unique type

# PHASE 5 (Item 3) — UUID seeder cleanup
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
grep -c 'Guid\.Parse(' services/exam-service/Data/ReadingSeeder.cs services/exam-service/Data/ListeningSeeder.cs services/exam-service/Data/GeneratedReadingSeeder.cs
# Expected: ~4 in Reading, ~5 in Listening, ~4 in GeneratedReading (question-ID literals = 0, Section/Exam IDs remain)
dotnet test services/attempt-service.Tests/Seeders/ReadingSeederDeterminismTests.cs --no-build
# Expected: determinism test passes (re-runs produce identical GUIDs)
```

```bash
# POST-SPRINT 5 — full-stack sanity
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
dotnet build Project_Langfens_Microservice.sln 2>&1 | tail -5
# Expected: Build succeeded, 0 Error(s)
cd /home/khoa/Projects/langfens/langfens-fe-app
npx tsc --noEmit 2>&1 | tail -5
# Expected: 0 errors
npx vitest run 2>&1 | tail -5
# Expected: 0 failures, total test count >= baseline (9) + Sprint 5 additions
```

---

## §5 — Phase breakdown

Six phases. Phases 1, 6 are repo-wide setup/closure. Phases 2-5 are items in execution order: pure refactors first (6, 7, 9), Item 3 (FK risk) last.

### Phase 1 — Repo setup + Item 0 (/docs/ policy)
- Files touched (no code): `Project_Langfens_Microservice/.gitignore`, `langfens-fe-app/.gitignore` (only if option 2 chosen).
- Verification: parent picks option 1/2/3 (decision recorded in §6 below).
- Commit message (option 1, force-add): `chore(docs): track sprint4 working artifacts`.
- Commit message (option 2, narrow gitignore): `chore(gitignore): un-ignore sprint4+ docs`.
- Commit message (option 3, regenerate): `chore(docs): relocate sprint4 to services/*/docs/`.
- Exit criteria: Item 0 decision made; whichever option chosen has its commit landed (or noted deferred).

### Phase 2 — Item 6 (DRY cleanAnswer, lowest risk)
- Files touched: `langfens-fe-app/src/lib/cleanAnswer.ts` (new); `langfens-fe-app/src/app/attempts/[attemptId]/utils.ts` (lines 66-94); `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/common/QuestionPanel.tsx` (line 111); `langfens-fe-app/src/app/attempts/_components/__tests__/ResultV3Review.parseUserAnswer.test.ts` (extend); `langfens-fe-app/src/lib/__tests__/cleanAnswer.test.ts` (new).
- Verification: `npx vitest run src/lib/__tests__/cleanAnswer.test.ts src/app/attempts/_components/__tests__/ResultV3Review.parseUserAnswer.test.ts` exits 0; `npx tsc --noEmit` exits 0.
- Commit message: `refactor(fe): consolidate cleanAnswer into src/lib/cleanAnswer`.

### Phase 3 — Item 7 (DRY buildQuestion)
- Files touched: `langfens-fe-app/src/lib/buildQuestion.ts` (new); `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/page.tsx` (lines 50-96); `langfens-fe-app/src/app/placement/[attemptId]/page.tsx` (lines 56-102); `langfens-fe-app/src/lib/__tests__/buildQuestion.test.ts` (new).
- Verification: `npx vitest run src/lib/__tests__/buildQuestion.test.ts` exits 0; visual diff confirms both pages render identical lists for fixture inputs; `npx tsc --noEmit` exits 0.
- Commit message: `refactor(fe): extract buildQuestion helper into src/lib`.

### Phase 4 — Item 9 (G11 dispatcher card)
- Files touched: `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/_components/cards/UnsupportedQuestionCard.tsx` (new); `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/common/QuestionPanel.tsx` (dispatcher wiring + throttled `console.warn`); `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/QuestionComponentRegistry.tsx` (optional `FALLBACK` export); `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/_components/cards/__tests__/UnsupportedQuestionCard.test.tsx` (new).
- Verification: `npx vitest run src/app/do-test/[skill]/[attemptId]/_components/cards/__tests__/UnsupportedQuestionCard.test.tsx` exits 0; manual smoke (load do-test with an unmapped question type) shows visible amber card.
- Commit message: `feat(fe): add UnsupportedQuestionCard for G11 dispatcher fallback`.

### Phase 5 — Item 3 (UUID seeders, FK risk)
- Files touched: `services/exam-service/Data/ReadingSeeder.cs`, `services/exam-service/Data/ListeningSeeder.cs`, `services/exam-service/Data/GeneratedReadingSeeder.cs`; `services/exam-service/Data/SeederHelpers.cs` (new deterministic GUID helper); `scripts/migrate_blank_placeholders.py` (Dictionary<Guid, Guid> mapping block); `services/attempt-service.Tests/Seeders/ReadingSeederDeterminismTests.cs` (new xUnit fixture in existing test project).
- Verification: `grep -c 'Guid\.Parse('` reports ~4 for Reading, ~5 for Listening, ~4 for GeneratedReading (question-ID literals eliminated); `dotnet build services/exam-service/services/exam-service.csproj` exits 0; `dotnet test services/attempt-service.Tests` exits 0 across 2 consecutive invocations (deterministic GUIDs); live `exam-db` row count for `ielts-reading-practice-1` unchanged (no re-seed performed).
- Commit message: `chore(seeders): replace GUID literals with deterministic dictionary lookup`.

### Phase 6 — Verification + handoff closure
- Files touched: `HANDOFF_SPRINT5.md` (this file, update §6 with closure summary).
- Verification: full-stack sanity per §4 (dotnet solution build, FE `tsc --noEmit`, full vitest run). All §7 acceptance criteria checked.
- Commit message: `docs(handoff): close Sprint 5 with §6 closure summary`.

---

## §6 — Risks

| ID | Risk | Likelihood | Impact | Mitigation | Owner |
|----|------|------------|--------|------------|-------|
| (a) | Item 3 seeder PK churn breaks `attempt_answer.QuestionId` FK refs on next re-seed | Med | High | Phase 5 captures pre-seed row counts and emits a `Dictionary<Guid, Guid>` FK remap via `scripts/migrate_blank_placeholders.py`. Sprint 5 does not re-seed live DB; FK remap is staged for any future re-seed event. | Parent |
| (b) | Item 6 `cleanAnswer` signature change breaks `ResultV3Review.parseUserAnswer.test.ts` | Low | Med | Signature `(s: string \| undefined) => string` is a pure superset of the prior inline behavior; vitest re-run before commit catches regressions. | Phase 2 implementer |
| (c) | Item 9 registry card needs visible render + log fallback simultaneously | Med | Low | New vitest spec explicitly verifies `console.warn` is fired once per unique type using `vi.spyOn`. Dispatcher guards re-warn with an in-memory Set of seen types. | Phase 4 implementer |
| (d) | `/docs/` policy debt accumulates (Sprint 4 already has 8 untracked docs) | High | Low | Item 0 forces a parent decision in Phase 1; chosen option tracked in §7 closure. | Parent |
| (e) | BE working-tree carryover `scripts/migrate_blank_placeholders.py` collides with Item 3 Phase 5 changes to the same file | Med | Med | Resolve by Phase 1: either commit the carryover separately (`chore(scripts): commit MCQ-scan extension`) or stash it. Item 3 Phase 5 modifications assume a clean base. | Phase 1 implementer |
| (f) | `docs/sprint5/` files remain untracked under chosen `/docs/` policy; subsequent agents cannot locate them via `git log` | Med | Low | If Item 0 = option 1, force-add `docs/sprint5/*.md` on each commit; if option 2, untracked paths become tracked by repo convention; if option 3, no `/docs/` surface at all. | Per phase committer |

---

## §7 — Acceptance criteria

1. **Item 0**: a `/docs/` policy is selected (one of options 1/2/3 in §2 Item 0), recorded in §6 closure summary of this file, and applied to existing Sprint 4 + new Sprint 5 docs.
2. **Item 3**: Question-ID `Guid.Parse(` calls are replaced with deterministic GUIDs in all three seeder files (~4 in Reading, ~5 in Listening, ~4 in GeneratedReading remain for Section/Exam IDs); `dotnet build` is green; determinism test in `services/attempt-service.Tests` passes twice consecutively with byte-identical GUIDs.
3. **Item 6**: `src/lib/cleanAnswer.ts` exists with the documented signature; both call sites import it; existing `ResultV3Review.parseUserAnswer.test.ts` still passes; new `cleanAnswer.test.ts` adds ≥ 4 cases.
4. **Item 7**: `src/lib/buildQuestion.ts` exists with the documented signature; both pages import it; new `buildQuestion.test.ts` adds ≥ 4 cases covering fixture Idx/Kind variants.
5. **Item 9**: `UnsupportedQuestionCard.tsx` exists; `QuestionComponentRegistry.tsx` exports `FALLBACK`; new `UnsupportedQuestionCard.test.tsx` covers (a) renders label, (b) registry `??` falls through, (c) `console.warn` fires once per unique type.
6. **Vitest counts**: post-Sprint-5 `npx vitest run` reports at least 9 baseline tests + all new Sprint 5 specs (≥ 4 + ≥ 4 + ≥ 3 = at least 20 total).
7. **Solution-wide build**: `dotnet build Project_Langfens_Microservice.sln` exits 0 with 0 errors.
8. **FE typecheck**: `npx tsc --noEmit` exits 0.
9. **No new seeder FK breakage**: live `exam-db` row count for `ielts-reading-practice-1` Section 1 = 5 unchanged; `attempt_answer` orphan count for that section = 0 (Phase 5 records both before and after).
10. **Handoff closure**: `HANDOFF_SPRINT5.md` §6 records the chosen `/docs/` policy, the 4 commit SHAs, and the final test count.
11. **No script/MD drift on the carryover**: `scripts/migrate_blank_placeholders.py` is committed in either its current form or with the Item 3 dictionary block added — no abandoned working-tree modifications at sprint close.

---

*End of HANDOFF_SPRINT5.md. Companion planning artifact: `docs/sprint5/PLAN.md` (deeper per-item design).*
