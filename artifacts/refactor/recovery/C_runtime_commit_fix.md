# C: `_accept` CHECKPOINT_COMMIT early-skip defect

**Branch:** `refactor/recovery-runtime-commit-fix`
**Worktree:** `/home/khoa/Projects/langfens/recovery-wt-C`
**Base:** `7a4d0e7`
**File changed:** `services/generation-service/app/loop/runtime.py` (only)

## Root cause

`BoundedLoopRuntime._accept` reserved the `CHECKPOINT_COMMIT` operation, then gated the
`commit_checkpoint` call behind `if op and op.status == "COMPLETED"`.

Two distinct paths reach the code after `if not self._reserve(intent): return`:

1. **Fresh accept** — `_reserve` finds no operation, creates a **new RESERVED** operation.
   `op.status == "COMPLETED"` is `False`, so `commit_checkpoint` was **never called**.
2. **Crash-resume of a stranded RESERVED commit** — the new `_reserve` branch lets a prior
   `RESERVED` `CHECKPOINT_COMMIT` through instead of failing `UNKNOWN_OUTCOME`. The op is
   still `RESERVED`, so again `commit_checkpoint` was never called.

In both cases the subsequent `self._checkpoint(intent.operation_id)` issues
`save_loop_cursor` referencing `lastOperationId` that is still `RESERVED`. The server-side
invariant (mirrored by the test double at `tests/test_t06_loop_runtime.py:277-279`, and by the
real exam-service: `HTTP 409: Loop cursor refers to an unacknowledged operation`) requires that
operation to be `COMPLETED`, so it rejects.

Verified trace on the defective code: `runtime.py:615 run → 529 _evaluate → 601 _accept → 222 _checkpoint → test_t06_loop_runtime.py:279`.

The new `_reserve` branch is legitimate and is preserved unchanged. The guard was simply
written as an **early-skip** where it needed to be a **narrow replay special-case**.

## The fix

Restructured the block so the commit is issued on **every** successful accept path:

- `commit_checkpoint` is now **unconditional** — a fresh accept commits and reaches `COMPLETED`
  before the cursor references it; a stranded `RESERVED` commit is completed on resume.
- The `COMPLETED` branch is now only the replay special-case: it validates the accepted head
  against the artifact, re-issues the commit as an idempotent replay, and validates the ack.
  It also aligns `expectedHeadVersion` with the current accepted head version so the
  server-side head CAS check passes on re-commit.
- Preserved unchanged: the accepted-head consistency check, the `CheckpointApiError` 409 →
  `_finish(LEASE_LOST, "FENCED_COMMIT_REJECTED: …", aborted=True)` handling, re-raise of
  non-409 errors, and the `(artifactId, version, contentHash)` ack-mismatch check.
- Journal ordering stays coherent: `record_intent` is called only on the `COMPLETED` replay
  path (where `_reserve` returned early without recording). On fresh/resume paths `_reserve`
  already recorded the intent, so `_accept` does not double-record it. `record_ack` follows
  the successful commit in all cases.

Diff is confined to the `_accept` block: 18 insertions, 15 deletions.

Consistency check: `commit_checkpoint` has exactly **one** call site in product code. The
sibling paths (`save_draft_checkpoint` in `_draft`, `reconcile_operation` in `_evaluate`) read
back already-durable state on `COMPLETED` replay and never had this defect.

## Crash-resume verification

`tests/test_t06_loop_runtime.py::test_t06_06_durable_fault_state_5_post_pass_commit` — **PASSED**.

To confirm the fix is load-bearing rather than passing around the path, the stranded-RESERVED
scenario was reproduced directly by crashing between the durable `RESERVED` grant and the commit:

- **Defective code:** `CheckpointApiError: HTTP 409: cursor has no durable operation ack` at
  `_accept → _checkpoint`.
- **Fixed code:** ops after crash `[(GENERATE, COMPLETED), (EVALUATE, COMPLETED), (CHECKPOINT_COMMIT, RESERVED)]`
  → resume → `DecisionType.PASS`, ops after resume `CHECKPOINT_COMMIT: COMPLETED`, heads `['passage']`.

## t08_08 disposition — fixed, not a test relaxation

`test_t08_08_passage_loop_e2e_and_paired_benchmark` asserted 3 artifacts, code returned 2.

**The test was correct; the product code was genuinely dropping a durable artifact.** The
missing third artifact is the **accepted `PASSAGE` head** (`art_passage_s1`). The two
pre-seeded heads (`art_bp_01`, `art_eg_01`) were present; the accepted head was never
committed to the store because of the same `_accept` early-skip. Directly observed: the loop
returned `decision=PASS` with `accepted_artifact=art_passage_s1`, while the store's `heads`
still held only the two seeded artifacts. After the fix, all three heads are present
(`art_bp_01`, `art_eg_01`, `art_passage_s1`) and the accepted id is in the resumed set.

No test file was modified.

## Test counts

`tests/test_t06_loop_runtime.py` + `tests/test_t08_passage_loop.py`:

| | Before | After |
|---|---|---|
| Result | 15 failed, 26 passed | **41 passed** (33 t06 + 8 t08) |

Full focused four-file set (`t06`, `t08`, `t09_question_candidates`, `t09_real_postgres_durability`):

| | Before | After |
|---|---|---|
| Result | 22 failed, 38 passed | **3 failed, 57 passed** |

All 19 pre-existing failures were fixed. **No new failures.**

Note: at baseline, 4 tests in `test_t09_real_postgres_durability.py` failed against the **real**
Postgres-backed server with `HTTP 409: Loop cursor refers to an unacknowledged operation` —
independent confirmation that this was a product-code defect, not a test-double artifact.

### Remaining 3 failures — environment/credential, not code

All three are live MiniMax endpoint calls returning HTTP 402 `insufficient_balance_error`:

- `test_t09_question_candidates.py::test_t09_07_persistence_crash_resumption_q17`
- `test_t09_real_postgres_durability.py::test_real_postgres_t09_07_idempotent_replay_accounting`
- `test_t09_real_postgres_durability.py::test_real_postgres_t09_07_dotnet_worker_consumer_integration`

These are provider-account balance failures. Two of them fail identically on the unmodified
baseline, so they are pre-existing and unrelated to this change. They were not papered over.

## Main checkout untouched

The defect lives in uncommitted local work, so a worktree at `7a4d0e7` does not contain it.
The uncommitted `app/loop/runtime.py` was copied from the main checkout into the worktree as the
starting point, and — only because the focused tests import symbols that do not exist at
`7a4d0e7` — the other uncommitted `services/generation-service/app/**` files were copied across
as well, plus the three untracked test files `test_t08_passage_loop.py`,
`test_t09_question_candidates.py`, `test_t09_real_postgres_durability.py` (also absent at
`7a4d0e7`). These are worktree staging copies only; the main checkout was never written to.

Before and after:

| | Before | After |
|---|---|---|
| `git rev-parse HEAD` | `7a4d0e7503710d3b87c95e15831829552ba7be8d` | `7a4d0e7503710d3b87c95e15831829552ba7be8d` |
| `git status --porcelain \| wc -l` | 60 | 60 |

No destructive git operations were performed. No test file is modified in the commit —
`git diff --name-only` shows no path under `tests/`.