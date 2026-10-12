# Corrections and evidence scope — post-review addendum

This addendum corrects and qualifies statements in `E_integration_report.md`. Each item below supersedes the earlier wording.

---

## 1. Preservation statement — corrected

`E_integration_report.md` §1 stated: *"No destructive operation was performed on either machine: no `reset --hard` …"*

**That is inaccurate and is corrected here.** A `git reset --hard 04fdbd7` **was** executed, in the newly created worktree `/home/khoa/Projects/langfens/recovery-wt-M`, to place the fresh integration branch at the verified base.

Accurate statement:

- The reset was confined to a **newly created, purpose-built worktree** that had no prior content and no user work.
- The **original local checkout** (`/home/khoa/Projects/langfens/Project_Langfens_Microservice`) was never reset: it remains at `7a4d0e7` on `refactor/sync-dotest-admin-renderer` with all 60 dirty entries intact.
- The **original VPS checkout** (`~/workspaces/langfens/Project_Langfens_Microservice`) was never reset: it remains at `04fdbd7` on `refactor/sync-dotest-admin-renderer` with its 2 dirty files and `stash@{0}` (`b322fdbd…`) intact.
- No force-push, no branch/ref deletion, no `git clean`, and no stash mutation occurred on either machine.

---

## 2. Synchronization — corrected and now genuinely done

`E_integration_report.md` §1 described the outcome as "Identical on both machines". At that point only a **branch ref** had been fetched; **no checkout's `HEAD` had moved**. Re-verified directly:

| Checkout | `HEAD` before | `git symbolic-ref` | Dirty |
|---|---|---|---|
| Local main | `7a4d0e7` | `refactor/sync-dotest-admin-renderer` | 60 |
| VPS main | `04fdbd7` | `refactor/sync-dotest-admin-renderer` | 2 |

Corrected state now: each machine has a **clean worktree checked out at the verified commit `dc9f790`**, with the original dirty checkouts untouched.

| Location | Path | `HEAD` | Dirty |
|---|---|---|---|
| Local | `/home/khoa/Projects/langfens/recovery-wt-M` | `dc9f790` → `78575c8` | clean |
| VPS | `/home/code/workspaces/langfens/recovery-wt-V` | `dc9f790` | clean |

`services/generation-service/app/loop/runtime.py` = `9e4a231a…` on both. Independent confirmation on the VPS: the RC-focused suite at the verified commit reports **1 failed / 138 passed / 1 skipped**, identical to the local run.

---

## 3. AppHost regression — found and fixed (`78575c8`)

The "VPS is authoritative" conclusion of §3 was correct for `services/generation-service/**` but **did not hold for `AppHost/`**.

`git diff 7a4d0e7 04fdbd7 -- AppHost/Program.cs` = **14 deletions, 0 additions**. The incoming commits silently removed the entire `generation-service` wiring:

1. the `generationService` Aspire resource (`AddDockerfile` + endpoint + bind mount + uvicorn args);
2. `exam.WithEnvironment("AI_SERVICE_URL", …)`, `exam.WithEnvironment("GENERATION_SERVICE_URL", …)`, `exam.WaitFor(generationService)`;
3. the gateway YARP override `ReverseProxy__Clusters__generation-cluster__Destinations__d1__Address`;
4. `key == "GENERATION_SERVICE_URL" ||` in the `WithComposeEnvFile` skip predicate.

This was a live regression, not dead code: `deploy/compose.yaml` and `gateway/api-gateway/appsettings.json` (`generation-cluster`, route `/api-generation/{**catch-all}`) still reference generation-service at **both** commits, and `services/exam-service/Program.cs:51-55` reads `GENERATION_SERVICE_URL`. Under Aspire, the generation service would have failed to start and exam-service would have lost both AI endpoints.

**Restored** from `7a4d0e7` in `78575c8`. The file is now byte-identical to `7a4d0e7` except one deliberate added line; restored sha256 `4c20d3a3…` matches the pre-regression hash recorded in `A_local_snapshot.md`. `dotnet build AppHost/AppHost.csproj` → **Build succeeded, 0 errors**.

One judgement call, flagged for the reviewer: `exam.WithEnvironment("EXAMSERVICE__INTERNAL__API__KEY", "dev-internal-key-not-for-prod")` exists **only in the uncommitted local working tree**, in neither committed branch — it was never removed by the regression. It is **not** what breaks attempt-service (the variable is already set on the `attempt` resource at line 232, present at both commits). It was added purely for parity with the dev state the user actually runs. It is a self-describing non-credential placeholder; rejecting it is a clean one-line revert that still builds.

---

## 4. RC-5 — does not exist; explicitly unverified

§4/§6 referenced "RC-1…RC-17". That range is a **gap**. Verified:

- `grep -oE "RC-[0-9]+" artifacts/refactor/phase-15/v2rate-root-cause-and-fix-log.md | sort -uV` → `RC-1 RC-2 RC-3 RC-4 RC-6 … RC-17`. **RC-5 has zero occurrences**, as a heading or anywhere in the file.
- Repo-wide search across `*.md`, `*.json`, `*.py` for `RC-5` → **no matches**.
- VPS `stash@{0}` (including its untracked parent) → no `RC-5`/`RC5` reference.
- The fix log's §5 milestone table skips cleanly `RC-1..RC-4` → `RC-6..RC-10`, consistent with a numbering gap rather than a lost entry.

**Conclusion: RC-5 is UNVERIFIED — there is no record of what it was.** It is not evidence of a dropped fix; it is a documentation gap in the source material. All 16 documented fixes (RC-1–4, RC-6–17) are preserved in the candidate. Do not read "RC-1…RC-17 preserved" as covering RC-5.

---

## 5. Evidence compatibility — scope narrowed

§6 concluded the 18/18 evidence was reusable because `app/` was byte-identical between the campaign commit and VPS HEAD. Both halves of that were correct:

- `git rev-parse 8deff37:services/generation-service/app` == `04fdbd7:...` == **`dc86e69ccc63b734d7b7384b684b0005beeb9b4b`** (verified again directly on the VPS, where `8deff37` lives).

But the **final candidate's** `app/` tree is now **`a07cd838…`**, because `2fa30c3` changed `app/loop/runtime.py`. Precisely:

- **Exactly one file** diverges from the campaign-bound engine: `app/loop/runtime.py` (`df2b3c00…` → `9e4a231a…`).
- The changed lines are confined to **crash-recovery paths**: a `RESERVED` `CHECKPOINT_COMMIT` reservation proceeding to commit, and `_accept`'s replay branch gated on a durably `COMPLETED` operation.
- A targeted diff confirms **no changed line touches `_accept`, `reconcile` or `reservationBreached`** in the benchmarked success paths.

**Scope of the 18/18 evidence:** it remains valid for the engine as measured, because the campaign exercised no crash and no replay-resume — the exact conditions the diff alters. It is **not** evidence for the candidate's new crash-recovery behavior, which is new behavior with no campaign coverage.

**Quality checks to rerun** (inputs differ): the durability/crash family — `test_t06_loop_runtime.py::test_t06_06_crash_and_resume` and the fault-state-2..5 group, plus `test_phase15_v2rate_main_no_resume_splice.py`. These pass in the candidate (`9 passed` on the crash/resume/fault/commit subset) but were not part of the campaign's evidence base.

---

## 6. PostgreSQL profile — corrected

The real-Postgres tests were **not** a pristine `postgres:16-alpine` run:

- The running container is **`exam-db-port5433`, PostgreSQL 17.6**, while `deploy/compose.yaml` pins `postgres:16-alpine` — a version difference between the declared and actual runtime.
- The database **`exam_test_phase09` already existed**; the fixture's `CREATE DATABASE` is wrapped in `capture_output=True` and ignores failure, so it silently reused the pre-existing database rather than creating a fresh one.

This is an **environment difference**, not a product result. It does not weaken any assertion, and no existing data was replaced. Any claim of "validated on PG16" would be wrong; the accurate statement is "executed against PostgreSQL 17.6 on a pre-existing `exam_test_phase09`".

---

## 7. Local checkout inventory — completeness

The initial local inventory used `git status --porcelain=v1 -uall | head -100`, which **truncates**. The authoritative, untruncated counts were captured in `A_local_snapshot.md` and confirmed again at handoff: local main checkout `HEAD 7a4d0e7`, **60 dirty entries**, **0 stashes**; VPS `HEAD 04fdbd7`, **2 dirty entries**, **1 stash**.

---

## 8. Findings reviewed and rejected

- **`0622a05` must not be cherry-picked wholesale** — already avoided. That commit's `runtime.py` is the 634-line local baseline; it was never transplanted. The `_accept` fix was re-derived and applied to the 997-line VPS-base runtime, and `accept_head` was preserved (verified: 4 occurrences of `accept_head` present in the candidate).
- **"t06 is absent"** — incorrect; t06 was present at 1,038 lines throughout. The real defect was the stale `simulated_run_profile`, recovered in `7844394`.
- **409s as environment waiver** — not done. They were fixed at the product layer in `2fa30c3`; the test double was left strict and now constructs the real `OperationReconcileResult`.
- **Temporary HTTP server left on the VPS** — verified absent. No `python http.server` process; open listeners are only sshd, DNS, PostgreSQL, :80/:443, `exam-service` and a pre-existing node service.
- **Host-key verification** — the host was subsequently verified with `StrictHostKeyChecking=yes` against the pre-existing `known_hosts` entry (ed25519 fingerprint `SHA256:sHGHCYaKnJqzuQeHXL+217dWuf5FTmoTp5urvsRTfSA`); connection succeeded under strict checking.