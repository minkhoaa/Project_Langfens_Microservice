# Sprint 4 Plan Review

> Reviewer: 2026-09-11
> Plan under review: docs/sprint4/PLAN.md (420 lines)
> Verdict: APPROVE-WITH-FIXES

## §1 — Verdict & Summary

The plan is fundamentally sound: scope respects the 10-item Sprint 4 backlog from HANDOFF_SPRINT4.md §2, the dependency graph is correct (Phases 1/2/4 parallel; Phase 4 → Phase 5 → Phase 6 critical path), and the critical-path estimate of ~85 minutes is plausible for a coordinated parallel execution. However, two factual errors require correction before execution: (a) the plan claims `migrate_blank_placeholders.py` has a `database` vs `dbname` kwarg conflict to fix, but reading the actual code shows `_parse_conn_string` correctly uses `setdefault` to map `database → dbname` with no duplication possible (line 135) — this acceptance criterion in Task 1.2 is a hallucinated bug; and (b) Task 3.1's file list points at `docs/sprint4/PLAN.md` as the artifact to edit, which is incoherent because the task is recording audit findings, not modifying the plan itself. Two structural concerns are also worth flagging: Phase 1.3 (doc rotation) is redundant because HANDOFF_SPRINT4.md already records baseline SHAs (the live audit confirms both repos at `25f1d29` / `1cb7ed0`), and Task 3.1's commit message `docs(audit): …` does not match its target file. Verdict is **APPROVE-WITH-FIXES** — these are targeted corrections, not structural rewrites.

## §2 — Factual Findings

| # | Claim | Source line in PLAN.md | Verdict | Evidence |
|---|-------|------------------------|---------|----------|
| 1 | `questionSchemas.ts:394` contains `blankAcceptTexts: { "0": ["library"], "1:": ["park"] }` typo | §2 Item 4 (L29), Task 1.1 (L107, L113) | TRUE | `grep -n '"1:"' /home/khoa/Projects/langfens/langfens-fe-app/src/app/admin/_lib/questionSchemas.ts` returned `394:      blankAcceptTexts: { "0": ["library"], "1:": ["park"] },`. The file also has a second typo `"0"` instead of `"1"`. |
| 2 | `package.json` shows Next.js 16 / React 19, requiring compatible Vitest versions | §2 Item 8 (L43), §5 risks row 1 | TRUE | `/home/khoa/Projects/langfens/langfens-fe-app/package.json` lines 27-30: `"next": "^16.1.7"`, `"react": "19.1.0"`, `"react-dom": "19.1.0"`. |
| 3 | `cleanAnswer` exists in both `attempts/[attemptId]/utils.ts` and `QuestionPanel.tsx` | §2 Item 6 (L39), Task 5.1 (L295) | TRUE | `attempts/[attemptId]/utils.ts:66-94` exports `cleanAnswer`; `QuestionPanel.tsx:105-130` defines local `cleanAnswer` with G15 non-greedy allowlist. Both files contain the function. |
| 4 | `buildQuestion` exists in both `do-test/[skill]/[attemptId]/page.tsx` and `placement/[attemptId]/page.tsx` | §2 Item 7 (L41), Task 5.2 (L322) | TRUE | `do-test/[skill]/[attemptId]/page.tsx:50` defines `function buildQuestion(q: any): UiQuestion`; `placement/[attemptId]/page.tsx:56` defines the same. Plan's "50-line" size claim is unverified but the duplication claim is true. |
| 5 | Both vitest target test files exist and currently use `describe.skip` | §2 Item 8 (L43), Task 4.2 (L283-284) | TRUE | `ls` confirmed both files exist. `grep -n describe` returned `17:describe.skip("parseUserAnswer", ...)` in `ResultV3Review.parseUserAnswer.test.ts` and `25:describe.skip("CompletionCard blankKeys sort (Sprint 3)", ...)` in `CompletionCard.sort.test.tsx`. |
| 6 | `vitest` is not yet installed and no `test` script exists | §2 Item 8 (L43), Task 4.1 (L268-276) | TRUE | `grep -nE "vitest|test\":" package.json` returned only `"@playwright/test": "^1.59.1"` (line 42). No `vitest` dep, no `test` script in `scripts` block. |
| 7 | `migrate_blank_placeholders.py` has a `database` vs `dbname` kwarg conflict that needs fixing | §2 Item 10 (L47), Task 1.2 (L125) | FALSE | `_parse_conn_string` (lines 123-138) does `out.setdefault("dbname", out.get("database", "exam-db"))` — `dbname` only set if missing; `database` is consumed as alias, never duplicated. The dict never contains both keys. The whole Task 1.2 acceptance criterion "removes duplicate `database` key from connection dictionary" is a hallucinated bug. |
| 8 | BE HEAD = `25f1d29`, FE HEAD = `1cb7ed0`, branch = `refactor/sync-dotest-admin-renderer` | Phase 1.3 acceptance (L136-138), §7 (L420) | TRUE | `git log --oneline -n 1` on both repos returned the claimed SHAs; `git branch --show-current` returned `refactor/sync-dotest-admin-renderer` on both. |
| 9 | `scripts/migrate_blank_keys_to_1_indexed.py` reads `EXAM_DB_PORT` / `ATTEMPT_DB_PORT` env vars | Phase 3.2 (L249) | TRUE | File header (lines 9-13) confirms `EXAM_DB_PORT` and `ATTEMPT_DB_PORT` overrides; `_conn_params` (lines 43-50) implements the env-read pattern. |
| 10 | `migrate_blank_placeholders.py` honors `PGPORT=32779` for live execution | Phase 3.2 (L245) | PARTIAL | The script reads `PGPORT` via `os.environ.get("PGPORT", "5432")` (line 161) and through `_parse_conn_string` setdefault (line 134), but the file's documented preferred path is `deploy/envs/exam.env` → `ConnectionStrings__exam-db`. Using `PGPORT=32779` works but the audit-logic path (`resolve_connection`) prefers the env file. Worker should also export `PGHOST=localhost PGPORT=32779 PGDATABASE=exam-db PGUSER=exam PGPASSWORD=exam` for full coverage. |
| 11 | Task 3.1 points at `docs/sprint4/PLAN.md` as its file to edit | Task 3.1 file list (L224) | FALSE | The task records audit findings (zero-Idx validated as section-local) but PLAN.md is the input, not the output. The acceptance criterion re-runs the SQL query — which is read-only against `exam-db` — and the commit message is `docs(audit): …`. No plausible artifact path is given. The task should target a new file like `docs/sprint4/AUDIT_zeroIdx.md` or `HANDOFF_SPRINT4.md` §0 update. |
| 12 | Phase 1.3 (doc rotation) is a real outstanding task | §1 scope (L11), Task 1.3 (L130-140) | PARTIAL | HANDOFF_SPRINT4.md is already on disk (verified during this review) and the live SHAs match. The "rotation" itself is DONE; only "verification" remains, which is a 30-second spot-check, not a 5-minute task. Either drop Task 1.3 or fold into the executor's pre-flight checklist. |

## §3 — Scope & Boundary Issues

- **Item 11 (Doc rotation) is borderline scope creep.** The Sprint 3 closure already published `HANDOFF_SPRINT4.md` with the correct baseline. Treating it as a Phase 1 task implies unfinished work; in reality only verification is left.
- **Task 6.3 (Author HANDOFF_SPRINT5.md) is well-defined** but the §7 acceptance criteria require referencing "newly discovered follow-ups" — workers must decide what counts, leaving a small amount of discretionary scope in Sprint 5 planning.
- **Phase 2.3 (Group C audit) is added scope** beyond the explicit 10-item backlog. HANDOFF_SPRINT3.md §7 item 3 ("Verify Group C bugs C1–C6") and HANDOFF_SPRINT4.md §3 item 3 do mention this, but the original Sprint 4 scope list does not include C1-C6 by name. Acceptable since it maps to a pre-existing readiness item, but should be flagged in the plan as "carryover from Sprint 3 §11 item 3".
- **No scope drift** on Items 1, 2, 4, 6, 7, 8, 9, 10 — they all map cleanly to HANDOFF_SPRINT4.md §2.
- **Item 3 (UUID seeder cleanup)** correctly deferred with explicit rationale.

## §4 — Dependency & Sequencing Issues

- **Phase 1 / Phase 2 / Phase 4 are correctly parallelizable.** None of T11/T12/T13, T21/T22/T23, or T41/T42 needs files from the others.
- **Phase 4 → Phase 5 serialization is correct.** Task 5.1's acceptance criteria explicitly require `npm run test` to pass; without Vitest installed in Phase 4, this fails. Phase 5 must wait for Phase 4.
- **Phase 5 internal tasks are shown as siblings** (T51, T52, T53) without explicit ordering. They touch different files (`src/lib/cleanAnswer.ts`+callers, `src/lib/buildQuestion.ts`+two pages, `QuestionPanel.tsx`+`QuestionCard.tsx`). Task 5.3 touches `QuestionPanel.tsx` (same file as Task 5.1) — these cannot run in parallel within a single working copy. Plan should serialize T51 and T53.
- **Phase 3 (DB Hygiene) depends only on Phase 2 audit findings.** Plan correctly shows Phase 2 → Phase 3 edge. Task 3.1's "no rows deleted" outcome makes the dependency mostly informational; the worker could execute 3.1 before 3.2 finishes if 2.1 results are clear. Plan's serialization is conservative and acceptable.
- **Phase 6 (closure) correctly waits for Phases 1, 3, 5.** The closure also requires Sprint 5 doc authorship (T63), which is a sequential terminal task.
- **Missing edge:** Phase 2.3 (Group C audit) findings could surface REAL items that need DB fixes, which would expand Phase 3. The graph does not show this feedback loop. Either commit to "findings are documentation-only" or add a Phase 3.X task.

## §5 — Risk Realism

- **§5 Row 1 "Vitest + Next.js 16/React 19 compatibility" (Medium likelihood)** — **Real and plausible**. Vitest 2.x officially supports React 19; Next.js 16 is recent enough that some Vitest plugins may lag. Mitigation in plan ("use `@vitejs/plugin-react` or lightweight Node environment") is reasonable but underspecified — should add: "pin `vitest@^2.1.0` and `@vitejs/plugin-react@^4.3.0`; if RSC imports break tests, gate with `// @vitest-environment node` per file."
- **§5 Row 2 "DB write impact on live user answers" (Low / High)** — **Overstated**. HANDOFF_SPRINT4.md §0 documents 0 rows with `BlankAcceptTexts ? '0'` and 0 rows with `TextAnswer LIKE '%"0":%'`. The migration script is idempotent and currently a no-op. Risk should be rated Very Low, not Low, with a one-line note that the live audit makes this a no-op.
- **§5 Row 3 "6 zero-Idx may be intentional" (High / Low)** — **Plausible but framing is wrong**. The Phase 2.1 SQL query will return rows regardless; what is "intentional" vs "wrong" is the real judgment call. Plan should commit to "all 6 are legitimate section-head ordinals" as the working hypothesis and require evidence (e.g., section Idx + question prompt content) to refute it.
- **§5 Row 4 "Refactor regressions in cleanAnswer/buildQuestion" (Medium / High)** — **Real**. G15 explicitly tightened the regex; reverting to a "shared" implementation could re-introduce the bug if the consolidated helper drops the explicit allowlist. Plan's mitigation (Vitest first, then refactor) is correct. **Acceptance criterion for T51 must include: "test asserts `Reason:` is preserved"** to actually pin the G15 invariant.
- **§5 Row 5 "Cross-session file conflicts" (Medium / Medium)** — **Generic boilerplate**. With Sprint 4 scoped as a single-session execution, this risk is much lower than the plan implies. Either remove or restate as "if execution is parallelized across workers, file ownership is per task; in single-session mode this risk is N/A."
- **Missing risk:** `migrate_blank_placeholders.py` mock-run may behave differently from live-run (the mock rows in `_MOCK_ROWS` are canned). Acceptance criterion "Running `PGPORT=32779 python3 .../migrate_blank_placeholders.py audit --mock` exits with code 0" only proves the script runs in mock mode, NOT against live DB. Add a separate acceptance: "Live `audit` (without `--mock`) against `exam-db:32779` returns the same row counts as the Phase 2.2 SQL audit."
- **Missing risk:** Plan assumes `dotnet test` will work without rebuild — but if Sprint 4 BE commits change shared code, `--no-build` may produce stale binaries. Either rebuild first or scope T61 to `dotnet build services/attempt-service.Tests/...csproj && dotnet test ... --no-build`.

## §6 — Acceptance Criteria Concerns

- **Task 1.2 L124 — "Both scripts contain explicit docstrings distinguishing…":** Subjective. Worker can satisfy with a 2-line note; reviewer cannot mechanically verify "explicit".
- **Task 1.2 L126 — `audit --mock` exit code 0:** Testable, but as noted above, only verifies mock mode.
- **Task 2.3 L213 — "Findings categorized as REAL or HALLUCINATED":** Subjective judgment. Each finding needs a written justification, not just a label.
- **Task 3.1 L233 — "Result is exactly 6":** Testable but assumes the underlying DB state matches HANDOFF_SPRINT4 baseline. If Sprint 4 Phase 2 finds anomalies, this acceptance criterion is impossible to meet without changing scope. Add: "if result != 6, escalate to lead engineer rather than fixing in-task."
- **Task 5.1 L305-308 — CleanAnswer test acceptance:** Covers behaviors but does NOT specify the exact regex pattern to pin G15. Worker must choose; reviewer should require the test to include `assert cleanAnswer("Reason: foo") === "foo"` as the explicit G15 invariant.
- **§7 L401-407 closure criteria:** Mostly verifiable. "No untracked files" requires `git status -s` returning empty on both repos; if `docs/sprint4/AUDIT_*.md` is untracked when authored, this fails. Either commit each doc as it lands or relax to "no untracked source files".
- **Phase 4.2 L287 — "0 failures and 0 skipped suites":** Currently the two test files are the ONLY tests in the codebase (`grep` found only `@playwright/test`); once they're un-skipped, this is trivially true. But if any worker adds new test files during Phase 5, the count grows — plan should say "0 failures across ALL suites including new ones".
- **§7 L414 — `npm run test` exits with code 0:** Requires Vitest installed (Phase 4.1). Plan correctly orders this.

## §7 — Recommended Fixes (priority order)

1. **Drop or correct the `database`/`dbname` kwarg fix in Task 1.2 (HIGH priority).**
   - Where: PLAN.md §2 Item 10 (L47), Task 1.2 file list (L121), acceptance criteria (L124-126).
   - Why: There is no conflict to fix. `_parse_conn_string` correctly maps `database → dbname` via `setdefault` (line 135 of `migrate_blank_placeholders.py`).
   - Change: Replace the "duplicate `database` key" acceptance criterion with "Both scripts contain explicit module-header docstrings distinguishing their scopes, including a 'Live execution example' block showing the required env vars for live DB access."
   - Effort: S (text edit, no code change).

2. **Fix Task 3.1's file list and target artifact (HIGH priority).**
   - Where: PLAN.md Task 3.1 (L222-235), especially L224 and L226-233.
   - Why: Task records audit findings but lists PLAN.md as the file to modify; PLAN.md is the input, not the output.
   - Change: Replace file list with `/home/khoa/Projects/langfens/Project_Langfens_Microservice/docs/sprint4/AUDIT_zeroIdx.md` (new file). Update acceptance criterion to: "New file `/home/khoa/Projects/langfens/Project_Langfens_Microservice/docs/sprint4/AUDIT_zeroIdx.md` exists, contains the Phase 2.1 SQL query results, and concludes the 6 rows are valid section-local ordinals."
   - Effort: S.

3. **Drop or demote Phase 1.3 (doc rotation verification) (MEDIUM priority).**
   - Where: PLAN.md §1 scope L11, Phase 1.3 (L130-140).
   - Why: HANDOFF_SPRINT4.md is already authored; this task is a 30-second spot-check, not a 5-minute task. Including it as a Phase 1 task implies outstanding work where none exists.
   - Change: Move to a "Pre-flight checks" subsection at the top of PLAN.md §4 (or fold into the executor's session-start checklist). Drop the standalone Phase 1.3 task.
   - Effort: S.

4. **Add serialization between Tasks 5.1 and 5.3 (MEDIUM priority).**
   - Where: PLAN.md §3 mermaid (L51-92) and §4 Phase 5 (L293-342).
   - Why: Both tasks touch `QuestionPanel.tsx`. Parallel execution on the same file produces merge conflicts in a multi-worker fan-out.
   - Change: Add `T51 --> T53` edge in the mermaid (T51 first). Adjust §3 critical path note.
   - Effort: S.

5. **Pin Vitest versions in Task 4.1 acceptance (MEDIUM priority).**
   - Where: PLAN.md Task 4.1 (L268-278), §5 risks row 1.
   - Why: Vitest 2.x supports React 19; pinning avoids Next.js 16 / Vitest peer-dependency conflicts.
   - Change: Add explicit versions: `"vitest": "^2.1.0"`, `"@vitejs/plugin-react": "^4.3.0"`. Add acceptance: "Test for G15 invariant: `expect(cleanAnswer('Reason: foo')).toBe('foo')`."
   - Effort: S.

6. **Add a Group C → Phase 3 feedback loop (LOW priority).**
   - Where: PLAN.md §3 mermaid (L51-92), §4 Phase 2.3 (L186-215).
   - Why: Group C audit findings may require DB fixes; the graph silently assumes "no REAL items."
   - Change: Either (a) add `Phase 2.3 --> Phase 3` edge with note "if REAL findings emerge, expand Phase 3", or (b) commit to "Group C findings are documentation-only; deferred to Sprint 5 if REAL".
   - Effort: S.

7. **Revise Phase 3.2 execution commands to cover env-file + PGPORT path (LOW priority).**
   - Where: PLAN.md Task 3.2 (L243-250).
   - Why: The plan uses `PGPORT=32779` directly, but `migrate_blank_placeholders.py` prefers `deploy/envs/exam.env`; the worker should also export `PGHOST/PGUSER/PGPASSWORD/PGDATABASE` for full coverage.
   - Change: Update execution command to `PGHOST=localhost PGPORT=32779 PGDATABASE=exam-db PGUSER=exam PGPASSWORD=exam python3 ...`.
   - Effort: S.

8. **Reframe §5 Row 2 risk as Very Low (LOW priority).**
   - Where: PLAN.md §5 risks row 2 (L376).
   - Why: Live audit shows 0 rows with key `'0'`; migration is a no-op.
   - Change: Likelihood: Very Low; add note: "Live audit (HANDOFF_SPRINT4.md §0) confirms 0 rows match the predicate; migration is currently idempotent no-op."
   - Effort: S.

## §8 — Items NOT Reviewed

- **The 50-line size claim of `buildQuestion`** in §2 Item 7 — did not measure both functions' line counts; only confirmed their existence.
- **The exact behaviors pinned in `parseUserAnswer` tests** — did not read the test bodies, only confirmed `describe.skip` is present.
- **The completion-family question SQL in Phase 2.2/3.2 verification queries** — accepted the SQL syntax; did not execute against live DB.
- **The `dotnet test` outcome** — did not run the BE test suite; only confirmed the task reference.
- **HANDOFF_SPRINT4.md §2 cross-references** — accepted as source-of-truth; did not cross-check every claim against Sprint 3 commit log.
- **Phase 5 refactor semantics** — did not verify that the consolidated `cleanAnswer` will be a behavior-preserving extract; the G15 regex invariants were not checked against the current `QuestionPanel.tsx` implementation beyond confirming the function exists.
- **Migration script mock-mode behavior** — only verified `_MOCK_ROWS` exists; did not run `--mock` to confirm exit code 0.
- **Risk §5 Row 4 mitigation specificity** — accepted the "Vitest first" ordering as sound; did not author test cases.

---

**End of review.**