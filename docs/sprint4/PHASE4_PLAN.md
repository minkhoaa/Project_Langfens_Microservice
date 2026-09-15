# Sprint 4 — Phase 4 Mini-Plan: Enable Vitest Test Suite

**Branch:** `refactor/sync-dotest-admin-renderer`
**FE Repo:** `/home/khoa/Projects/langfens/langfens-fe-app`
**Current HEAD:** `1c2d1b3` (working tree ahead of origin by 2 commits; package.json modified but uncommitted)
**Source-of-truth tasks:** `docs/sprint4/PLAN.md` Task 4.1 (L265–277) + Task 4.2 (L279–288)
**Scope:** No production-code logic changes. Two commits. Read-only planning artifact (this file) → then two implementation commits.

---

## §1 — Pre-conditions (confirmed via repo inspection 2026-09-11)

| Item | Status | Evidence |
|---|---|---|
| `package.json` valid JSON + scripts present | ✅ DONE (worker just landed) | `git diff package.json` shows `test`, `test:watch`, `test:ui` scripts + `vitest ^2.1.0`, `@vitejs/plugin-react ^4.3.0`, `happy-dom ^15.0.0` devDeps added |
| `vitest.config.ts` tracked in git | ✅ DONE (commit `245dd1e`) | `git log --oneline -- vitest.config.ts` returns `245dd1e refactor(fe-do-test): extract parseUserAnswer function and add tests for it` |
| Vitest deps declared | ✅ DONE | Listed under `devDependencies` |
| Vitest deps installed | ❌ TODO — Step A | No `node_modules/vitest` yet; `npx vitest --version` will fail |
| `parseUserAnswer` exported | ✅ DONE | `src/app/attempts/_components/parseUserAnswer.ts:14` has `export function parseUserAnswer(...)` |
| Both test files use explicit `import { describe, it, expect } from "vitest"` | ✅ Verified | Grep confirms — tests do NOT depend on globals |
| 2 test files skipped | ✅ TODO — Step C | `src/app/attempts/_components/__tests__/ResultV3Review.parseUserAnswer.test.ts:17` and `src/app/do-test/[skill]/[attemptId]/_components/cards/__tests__/CompletionCard.sort.test.tsx:25` both `describe.skip(...)` |

### Existing `vitest.config.ts` content (current; tracked; will be overwritten in Step B)

```typescript
import { defineConfig } from "vitest/config";
import path from "node:path";

export default defineConfig({
  test: {
    environment: "node",
    include: ["src/**/__tests__/**/*.test.ts"],
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
});
```

### Target `vitest.config.ts` content (per PLAN.md Task 4.1)

```typescript
import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";
import path from "node:path";

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: { "@": path.resolve(__dirname, "./src") },
  },
  test: {
    environment: "happy-dom",
    globals: true,
    include: ["src/**/*.{test,spec}.{ts,tsx}"],
    exclude: ["node_modules", ".next", "dist"],
  },
});
```

Quoted with double-quotes to match existing project style.

---

## §2 — Implementation steps (in order)

### Step A — Install npm dependencies

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npm install --no-audit --no-fund
```

**Expected outcomes:**
- `node_modules/vitest`, `node_modules/@vitejs/plugin-react`, `node_modules/happy-dom` populated.
- `package-lock.json` rewritten (deps + transitive lockfile entries for `vitest@^2.1.0`, `@vitejs/plugin-react@^4.3.0`, `happy-dom@^15.0.0`).
- `package.json` itself is already correct, so npm install must NOT add/remove devDeps (lockfile-only change).

**Verify (read-only):**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
ls -d node_modules/vitest node_modules/@vitejs/plugin-react node_modules/happy-dom   # all 3 exist
npx vitest --version                                                                 # prints 2.1.x
git diff --stat package-lock.json                                                   # large diff expected
```

If `npx vitest --version` errors with `vitest: command not found` → npm install did not resolve; STOP and investigate peer-dep failure (see §3 Risk 1).

### Step B — Overwrite `vitest.config.ts` with PLAN.md Task 4.1 spec

**Strategy: overwrite, not merge.** Justification:

1. Current `environment: "node"` is incompatible with the JSX/TSX test (`CompletionCard.sort.test.tsx` will fail at React module resolution under Node).
2. Current `include: ["src/**/__tests__/**/*.test.ts"]` excludes `.test.tsx` files — it would silently skip `CompletionCard.sort.test.tsx`.
3. Missing `plugins: [react()]` — JSX not transformed.
4. Missing `exclude` — slow runs scanning `node_modules`/`.next`/`dist`.
5. Missing `globals: true` — not strictly required for current tests (they import explicitly), but PLAN.md spec calls for it to unblock future test authors.

`edit` would require 4 separate range-edits on a 14-line file; full `write` is clearer and atomic.

**Action:** Use `write` to replace the file with the target content (above, §1).

**Verify (read-only):**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
cat vitest.config.ts                                                                # confirms new content
npx vitest --version                                                                 # still 2.1.x
```

### Step C — Un-skip both test files

For each file, edit one line: replace `describe.skip(` with `describe(`.

- File 1: `src/app/attempts/_components/__tests__/ResultV3Review.parseUserAnswer.test.ts` (line 17)
- File 2: `src/app/do-test/[skill]/[attemptId]/_components/cards/__tests__/CompletionCard.sort.test.tsx` (line 25)

**Verify and run tests:**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
grep -rn "describe.skip" src/                                                        # MUST return 0 matches
npx vitest run --reporter=basic                                                     # MUST exit 0; expect 2 test files, all tests pass
```

**Stop condition:** If ANY test FAILS, DO NOT modify the test code. STOP and report:
- which test(s) failed,
- the actual vs expected output,
- the stack trace tail.

The plan accounts for this as Risk 5 (§3) — the tests were authored under commit `245dd1e` against the same code currently in HEAD, so they should pass; if they don't, that is a regression requiring investigation, not silent fixing.

### Step D — Verify TypeScript compilation still passes

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npx tsc --noEmit 2>&1 | tail -10
```

**Expected:** exit 0, OR the same 7 (or N) pre-existing errors that existed BEFORE this phase. No NEW errors introduced.

Acceptance: `tsc --noEmit` exit code unchanged from pre-phase baseline; error count unchanged from pre-phase baseline.

---

## §3 — Risk matrix

| # | Risk | Mitigation |
|---|---|---|
| 1 | `vitest@2.1.x` peer-dep conflict with React 19 (Next 15 ships React 19) | `@vitejs/plugin-react ^4.3.0` explicitly supports React 19. If `npm install` errors on peer-deps, retry with `--legacy-peer-deps` and document in commit body. Do NOT downgrade React. |
| 2 | Test code relies on global `describe`/`it`/`expect` (no imports) | Verified at planning time: both test files explicitly `import { describe, it, expect } from "vitest"` at line 4/8. `globals: true` is still in config per PLAN.md Task 4.1 spec for future tests. No tsconfig change needed for current tests. (See §6 open question.) |
| 3 | `CompletionCard.sort.test.tsx` needs JSX/React env | `environment: "happy-dom"` + `plugins: [react()]` in config. happy-dom is lighter than jsdom and matches PLAN.md spec. |
| 4 | `parseUserAnswer.test.ts` imports `@/components/exam-v3/types` (path alias) | `resolve.alias` already maps `@` → `./src`. No additional setup. |
| 5 | `parseUserAnswer` may not be exported from `parseUserAnswer.ts` | Verified at planning time: `src/app/attempts/_components/parseUserAnswer.ts:14` has `export function parseUserAnswer(ans?: AttemptAnswerItem): UserAnswerValue`. If absent at execution time → STOP. |
| 6 | `npm install` mutates `package-lock.json` — must be committed together with `package.json` | Already-uncommitted `package.json` change + `package-lock.json` go in **Commit 1** (see §4). |
| 7 | Running `npx vitest` accidentally discovers/imports `.next/` build artifacts and hangs | `exclude: ["node_modules", ".next", "dist"]` in config. |
| 8 | Step C tests fail (regression since authoring) | DO NOT FIX. Stop, report failing test name + diff, escalate to planner. |
| 9 | `tsc --noEmit` shows new errors from missing `@types` for `vitest` or `happy-dom` | Both ship their own types; no `@types/*` package needed. If errors appear, check whether they reference vitest's `expect` or `vi` namespace; fix by adding `"types": ["vitest/globals"]` to `tsconfig.json` ONLY if needed (do not pre-emptively edit tsconfig). |
| 10 | Branch is 2 commits ahead of origin — push gate | Phase 4 commits add 2 more commits on top. User/main agent decides when to push. Local-only is acceptable. |

---

## §4 — Commit strategy

**Two commits, applied in this exact order:**

### Commit 1 — Install test tooling

```
chore(fe-test): install vitest 2.1 + react plugin + happy-dom
```

- **Files changed:**
  - `package.json` (already modified — staged uncommitted)
  - `package-lock.json` (mutated by `npm install`)
- **Body:**
  ```
  Sprint 4 Phase 4 / Task 4.1.

  Declared in package.json by previous worker; this commit materializes
  the lockfile via `npm install --no-audit --no-fund`.

  - vitest ^2.1.0
  - @vitejs/plugin-react ^4.3.0
  - happy-dom ^15.0.0
  ```

### Commit 2 — Enable vitest config + un-skip 2 test suites

```
test(fe-do-test): enable vitest config + un-skip parseUserAnswer and CompletionCard tests
```

- **Files changed:**
  - `vitest.config.ts` (overwrite per PLAN.md Task 4.1 — happy-dom env, react plugin, .tsx glob, exclude node_modules/.next/dist)
  - `src/app/attempts/_components/__tests__/ResultV3Review.parseUserAnswer.test.ts` (`describe.skip` → `describe`)
  - `src/app/do-test/[skill]/[attemptId]/_components/cards/__tests__/CompletionCard.sort.test.tsx` (`describe.skip` → `describe`)
- **Body:**
  ```
  Sprint 4 Phase 4 / Tasks 4.1 + 4.2.

  Replaces minimal node-env config with happy-dom + react plugin so
  the .tsx test file can execute JSX. Include glob expanded to
  {test,spec}.{ts,tsx}; .next/dist excluded.

  Both describe.skip blocks (parseUserAnswer, CompletionCard.sort)
  un-skipped; both suites expected to pass.

  Verified via `npx vitest run` — 2 files, 0 failures.
  ```

**Commit ordering rationale:** Commit 1 must land first so the working tree has `vitest` in `node_modules` when CI (or anyone re-running `npm ci` on a cache) encounters Commit 2. Splitting also keeps the `package.json`/`package-lock.json` change atomically reviewable as "infrastructure only" vs "test enablement."

---

## §5 — Verification (post-implementation)

| Check | Command | Expected |
|---|---|---|
| All tests pass | `cd /home/khoa/Projects/langfens/langfens-fe-app && npx vitest run` | exit 0; 2 test files; all suites pass; 0 skipped suites |
| `npm run test` works | `cd /home/khoa/Projects/langfens/langfens-fe-app && npm run test` | same as above (proves the new script) |
| `npm run test:watch` triggers | `cd /home/khoa/Projects/langfens/langfens-fe-app && timeout 2 npm run test:watch; echo exit=$?` | exit ≠ 0 (because we killed it) but banner shows vitest 2.1.x watch mode (smoke only — do NOT keep running) |
| TS still compiles | `cd /home/khoa/Projects/langfens/langfens-fe-app && npx tsc --noEmit` | exit 0, OR same error count as pre-phase baseline |
| Working tree clean | `cd /home/khoa/Projects/langfens/langfens-fe-app && git status` | exactly 5 files modified across the two commits, then clean after commit: `package.json`, `package-lock.json`, `vitest.config.ts`, + 2 test files. Nothing else. |
| Commit count | `cd /home/khoa/Projects/langfens/langfens-fe-app && git log --oneline origin/refactor/sync-dotest-admin-renderer..HEAD` | exactly 2 new commits |

---

## §6 — Open questions / decisions deferred

1. **`tsconfig.json` `types` for vitest globals.** Plan does NOT pre-emptively edit `tsconfig.json`. If a *future* test (not in this phase) uses global `describe`/`it`/`expect` without explicit imports, then `tsconfig.json`'s `compilerOptions.types` may need to include `"vitest/globals"`. Not in scope here because both current test files use explicit imports. **Action deferred** to the author of any future global-style test.

2. **`npm run test:ui` script.** The script `"test:ui": "vitest --ui"` was added by the prior worker. Vitest UI requires a browser-launched dev server on port 51204 by default. **Not exercised in this phase.** If user wants UI mode verified, it is a separate task (potentially CI-headless via `vitest --ui --browser.headless` if Vitest 2.1 supports it — needs investigation).

3. **jsdom vs happy-dom.** PLAN.md accepts either; happy-dom chosen because it's faster and is the literal PLAN.md spec example. No future swap planned unless happy-dom causes issues with specific DOM API tests.

4. **`vitest.config.ts` test-file glob edge cases.** The pattern `src/**/*.{test,spec}.{ts,tsx}` will also pick up any `.spec.tsx` co-located with components. None currently exist, so no exclusion needed. Revisit if naming conventions diverge.

5. **Pre-existing `tsc --noEmit` error count.** Not measured at planning time. Step D captures a baseline before/after; if a delta appears, that is a regression and must be investigated (likely vitest types leakage, see Risk 9).

---

## Plan execution contract

- This plan is read-only; no code edits are made by the planner.
- Implementation runs Step A → B → C → D in strict order.
- Step C failure ⇒ STOP, do not proceed to Step D, escalate.
- Step D failure (new tsc errors) ⇒ STOP, do not commit, escalate.
- On clean exit, make Commit 1, then Commit 2, then run §5 verification.
