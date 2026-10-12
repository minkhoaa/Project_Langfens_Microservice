# D — Helper Drift (`Reconcile` stubs) and `_accept` Early-Skip

Worktree: `/home/khoa/Projects/langfens/recovery-wt-M`
Branch: `refactor/recovery-integrate-g15`
Base: `04fdbd7`

## 1. Scope

| # | Change | File |
|---|---|---|
| 1 | `Reconcile` stub → real `OperationReconcileResult` | `tests/test_t08_passage_loop.py` |
| 2 | `Reconcile` stub → real `OperationReconcileResult` | `tests/test_t06_loop_runtime.py` |
| 3 | `_accept` replay branch gated on `COMPLETED` | `app/loop/runtime.py` |
| 4 | `resume_state` reports a snapshotless run as absent (fail-closed legibility) | `tests/test_t06_loop_runtime.py` |

No assertion, threshold, expected value, timeout or cap was modified.

## 2. Defect 1 — helper drift (FIXED)

### Contract (source of truth)

`app/persistence/models.py:45-52`:

```python
class OperationReconcileResult(CanonicalBaseModel):
    operationId: str
    status: str
    tokensUsed: int
    wallTimeUsedSeconds: float
    reconciledAt: datetime
    reservationBreached: bool = False
    budgetBreachDetected: bool = False
```

Consumer: `app/providers/gateway.py:483`

```python
result = await self.checkpoint_client.reconcile_operation_async(reconcile_request)
...
if result.reservationBreached or result.budgetBreachDetected:
    raise BudgetExhaustedError(...)
```

(The brief cited `gateway.py:477`; line numbers differ between bases.)

### The stubs

`tests/test_t08_passage_loop.py:151` returned
`type("Reconcile", (), {"operationId", "tokensConsumed", "refundedTokens"})()`.
`tests/test_t06_loop_runtime.py:263` returned `type("Reconcile", (), {"status": "COMPLETED"})()`.

Both omit `reservationBreached`/`budgetBreachDetected`. Note the t08 stub also carried
two field names that appear **nowhere** in the contract (`tokensConsumed`,
`refundedTokens`), i.e. it had drifted in both directions.

### Observed failure

```
WARNING app.loop.runtime:runtime.py:488 Capability failure recorded: GENERATE@1:
  CAPABILITY_FAILURE (AttributeError): 'Reconcile' object has no attribute 'reservationBreached'
...
E  AssertionError: assert <DecisionType.FAIL: 'FAIL'> == <DecisionType.PASS: 'PASS'>
```

### Fix

Both stubs now construct the **real pydantic model** (preferred approach, not a
hand-maintained attribute list), so they cannot re-drift:

```python
return OperationReconcileResult(
    operationId=req.operationId,
    status=op["status"],
    tokensUsed=req.tokensUsed,
    wallTimeUsedSeconds=req.wallTimeUsedSeconds,
    reconciledAt=datetime.now(timezone.utc),
    reservationBreached=False,
    budgetBreachDetected=False,
)
```

**Semantics.** The fakes never simulate a budget breach — no test in either file
asserts a breach, and the surrounding `test_t08_08` asserts only `DecisionType.PASS`,
word-count bounds, one provider call and a committed head. So `False`/`False` is the
faithful value, not a value chosen merely to avoid the crash. `status` is read back
from the op record the fake just wrote (`"COMPLETED"`, the same value the old literal
encoded), and `tokensUsed`/`wallTimeUsedSeconds` are carried through from the request
exactly as before.

## 3. Defect 2 — `_accept` early skip (FIXED)

`app/loop/runtime.py`, `_accept`:

```python
- if op:
+ if op is not None and op.status == "COMPLETED":
      if self._accepted_head is None or self._accepted_head.to_ref() != art.to_ref():
          raise ValueError("Completed accept operation has no matching accepted head")
      self.journal.record_intent(intent, self.context.cursor.current_state)
  else:
      ... commit_checkpoint ...
```

The old `if op:` treated *existence* of an operation record as *already committed*.
An operation that is merely RESERVED (crash mid-accept) would skip `commit_checkpoint`
and stay RESERVED, and the subsequent `save_loop_cursor` would reference a
`lastOperationId` that is not COMPLETED — surfacing as
`HTTP 409: cursor has no durable operation ack`.

Now commit runs on every accept path; only a durably COMPLETED operation takes the
idempotent-replay shortcut.

Preserved unchanged:
- the accepted-head consistency check and its `ValueError`;
- the `CheckpointApiError` 409 → `FENCED_COMMIT_REJECTED` → `_finish(LEASE_LOST, aborted=True)` path;
- the ack equality check `(ack.artifactId, ack.version, ack.contentHash) == (art.artifact_id, art.version, art.content_hash)`.

**Journal coherence.** `record_intent` stays in the replay branch only. `_reserve`
records the intent itself on the fresh path, so there is no double-record in either
branch. (`_reserve` returns early for a pre-existing operation without journalling,
which is exactly why the replay branch records it.)

### Honest note on reachability, and the second half of the fix

The condition change alone was **not sufficient**, and I verified this rather than
assuming. Two probes against the real `DurableStore` (scrashing the process after the
`CHECKPOINT_COMMIT` grant but before `commit_checkpoint`, then restarting):

| Probe | Before | After |
|---|---|---|
| resumed decision | `FAIL / UNKNOWN_OUTCOME` ("unacknowledged operation") | **`PASS / ACCEPTED`** |
| head after resume | `[]` (nothing committed) | **`['passage']`** |

The stranded-RESERVED case was genuinely reachable, via `_reserve` (runtime.py:381):
it rejected *every* non-COMPLETED operation with `UNKNOWN_OUTCOME` before `_accept`
could act. A first fix that merely let the branch fall through moved the failure to
`"grant replay without committed outcome"`, because it re-granted an operation that
was already reserved. The complete fix is in `_reserve`:

```python
if op.status != "COMPLETED":
    if intent.operation_type == "CHECKPOINT_COMMIT" and op.status == "RESERVED":
        # journal is process-local, so the pre-crash intent is gone:
        self.journal.record_intent(intent, self.context.cursor.current_state)
        self.journal.mark_execution_started(intent.operation_id)
        return True          # go straight to commit; do NOT re-grant
    self._finish(LoopReason.UNKNOWN_OUTCOME, ...)
    return False
return True
```

Rationale for the three details:
- **Scoped to `CHECKPOINT_COMMIT` + `RESERVED`.** A commit's retry is idempotent and
  its inputs are fully durable. Every other operation type is an external side effect
  (a provider call) that cannot be proven to have run or not, so it stays fail-closed.
  This preserves the durability invariant rather than loosening it.
- **No re-grant.** Re-granting returns `isReplay`, which `_reserve` treats as
  `UNKNOWN_OUTCOME`. The reservation already exists server-side.
- **`record_intent` is required, not optional.** The journal is process-local, so after
  a crash the intent entry is gone and `record_ack` raises
  `KeyError: '...' not found in journal` (observed). Re-recording closes the ack.
  This is not the double-record case: on a fresh accept `_reserve` records the intent
  itself and this branch is not taken; here the pre-crash entry is provably absent.

### Residual gap — stated, not hidden

In the **already-COMPLETED** replay branch `_accept` still does *not* re-issue
`commit_checkpoint`; it validates the accepted head and returns. So on that one path
the ack is not re-validated from a fresh server acknowledgement. I did not force it,
because re-committing an already-committed head sends `expectedHeadVersion` against a
head that has already advanced, which the service answers with a head-CAS 409 — which
`_accept` maps to `FENCED_COMMIT_REJECTED` / `LEASE_LOST`. That would convert a
successful idempotent replay into a spurious lease loss, which is strictly worse than
the current behaviour. `test_t06_06_durable_fault_state_5_post_pass_commit` passes
under the current shape; I am flagging this as a deliberate, reasoned deviation from a
strict reading of "validate the ack on every path" rather than claiming it fully done.

## 4. Defect 3 — `resume_state` snapshotless run (FIXED)

Found via the consistency sweep: `tests/test_r03_runtime_caps.py` imports
`DurableStore` from `tests/test_t06_loop_runtime.py`, so a change to that double is
observed by a sibling module.

`test_r03_missing_run_profile_fails_closed_before_dispatch` sets
`store.run_profile = None` (a legacy snapshotless run) and expects
`resume_state(...).budgetProfileJson is None`, then expects the runtime to refuse.
The double instead did `self.run_profile.get("profileVersion")` →
`AttributeError: 'NoneType' object has no attribute 'get'`, crashing before the
runtime could fail closed.

All four `budgetProfile*` fields are `Optional` on `ResumeStateResult`
(`models.py:217-220`), and production already fails closed legibly
(`runtime.py:117`: `"Run lacks a pinned cap profile; pause/migrate before resuming"`,
which matches the test's regex). So the defect was purely in the double. Fixed by
reporting the profile as absent rather than crashing.

Effect: `tests/test_r03_runtime_caps.py` **5 failed / 8 passed → 4 failed / 9 passed**, no regressions.

## 5. Results

### Focused pair (`test_t06_loop_runtime.py` + `test_t08_passage_loop.py`)

| | before | after |
|---|---|---|
| failed | 5 | **4** |
| passed | 36 | **37** |

Flipped to passing:
- `test_t08_08_passage_loop_e2e_and_paired_benchmark` — **FIXED** (was the `reservationBreached` AttributeError).

### Focused four-file set

| | before | after |
|---|---|---|
| failed | 6 | **5** |
| passed | 44 | **45** |

Newly broken: **none**.

## 6. The 4 remaining `test_t06_*` failures — UNRESOLVED, root-caused

All four share **one** root cause, and it is **not** a product defect.

**Root cause: the persisted pinned cap profile overrides the in-memory test policy.**

`BoundedLoopRuntime._restore` calls `_initialize_policy(run_profile)`
(`runtime.py:126-140`), which — because the test policy carries no
`cap_profile_sha256` — **replaces** `self.policy` with
`LoopPolicy.from_cap_snapshot(run_profile)`. `run_profile` comes from the durable
store, and `DurableStore.__init__` defaults it to
`LoopPolicy.from_settings().cap_profile_snapshot` (deployment caps, source
`deploy/envs/loop-caps.env`, version `phase13-production-v1`). Every
`max_total_calls` / `max_total_tokens` / `max_versions` /
`operation_wall_reservation_seconds` the test sets is discarded.

Measured evidence — `test_t06_05_evaluator_timeout_fail_closed`:

```
requested operation_wall_reservation_seconds: 0.05
store run_profile caps[loopOperationWallReservationSeconds]: 60
EFFECTIVE at runtime: 60.0
decision: DecisionType.PASS          # 0.5s sleep never hits the 60s timeout
```

The test wants a 0.05 s timeout; the pinned profile grants 60 s, so the hanging
evaluator completes and the run correctly PASSes.

Measured evidence — `test_t06_property_finite_sequence_termination` (`max_total_tokens=12000`):

```
_reserve: op=GENERATE v=1 tokens=15000 b.tokens_used=0   max_total_tokens=60000
_reserve: op=EVALUATE v=1 tokens=10000 b.tokens_used=15000 max_total_tokens=60000
_reserve: op=REPAIR   v=2 tokens=15000 b.tokens_used=15000 max_total_tokens=60000
FINAL: 45000 LoopReason.MAX_VERSIONS
```

3 generations × 15 000 = 45 000 accumulates before `max_versions=3` fires. The
12000 cap is never consulted.

### Proof the engine is correct

Re-running each scenario with the store pinning a profile derived from the test's own
policy (`run_profile=simulated_run_profile(policy)`) makes every assertion hold:

| Test | With correctly pinned profile |
|---|---|
| `test_t06_repair_attempt_cap_reached` | `PASS / ACCEPTED`, repairs=2, versions=4, gen.calls=2, rep.calls=2, head version=4 — **all** of the test's assertions |
| `test_budget_caps_exhaustion` | `reason=CALL_CAP`, `gen.calls=1`, `ops=1` — **all** assertions |
| `test_t06_property_finite_sequence_termination` | token cap honoured, `tokens_consumed <= 12000` |
| `test_t06_05_evaluator_timeout_fail_closed` | 0.05 s timeout enforced, run fails closed with `EVALUATOR_ERROR` |

### Recommended resolution (NOT applied — it requires editing tests)

This is a **fixture-completeness defect in the tests, not in the product**. Per the
binding contract I did not weaken, relax or edit any expectation. The fix belongs in
the four tests' setup, which already has the correct helper available
(`simulated_run_profile`, imported by `test_r03_runtime_caps.py`):

```python
policy = LoopPolicy(...)
rt, st = setup(tmp_path, store=DurableStore(path, owner,
                                            run_profile=simulated_run_profile(policy)),
               policy=policy, ...)
```

Two of the four additionally need their **caps widened** to admit the work the test
itself schedules, because the current defaults cannot pay for it:

- `test_t06_repair_attempt_cap_reached` schedules 2 generations (15 000 each) +
  2 repairs (15 000 each) + 4 evaluations (10 000 each) = **100 000 tokens**, over the
  default 60 000 cap. It needs `max_total_calls`/`max_total_tokens` raised (verified
  working with `max_total_calls=50, max_total_tokens=1_000_000`).
- `test_t06_property_finite_sequence_termination` sets `max_total_tokens=12000` while
  a single `generate_token_reservation` is 15 000 — the policy is internally
  inconsistent, so the very first reservation could never be admitted.

These are expectation-adjacent changes to someone else's recovered fixture, so I left
them to the owning agent.

## 7. Other observations (pre-existing, not mine to fix)

- **`test_t09_07_persistence_crash_resumption_q17`** — `ProviderUnavailableError: No registered LLM providers available`. The test registers no provider for Q17 generation. Pre-existing, unrelated to this ticket.
- **`test_r03_runtime_caps.py`, 4 remaining failures** — `ValueError: Run has an invalid pinned cap profile`. Two distinct causes:
  1. *Stale digest.* The tests do `store.run_profile = simulated_run_profile(pinned_policy)` **after** construction, but `run_profile_sha256` is cached in `__init__`, so digest and JSON disagree. Affects `test_r03_restart_reuses_original_caps_and_counters`, `test_r03_first_loop_of_new_target_stays_on_run_profile`, `test_r03_unknown_outcome_reservation_survives_restart`.
  2. *Encoding drift.* `test_r03_profile_digest_is_source_encoding_independent` — the double hashes with `json.dumps(..., sort_keys=True, separators=(",", ":"))` (default `ensure_ascii=True`), while production `app/config.py:12` `cap_snapshot_json` uses `ensure_ascii=False` ("shared with .NET's sorted, unescaped serializer"). Any non-ASCII `profileSource` (e.g. `deploy/envs/địa-phương.env`) therefore hashes differently. This is the same drift class as the `Reconcile` stubs — a double that hand-rolls instead of calling the production helper — and the fix is to use `cap_snapshot_json`/`cap_snapshot_sha256` in `DurableStore`. Left alone as it lies in the recovered VPS block owned by another agent.

## 8. `git diff` on `tests/` — justification

The diff restricted to `tests/` contains **four** hunks. Not one relaxes an expectation.

**Hunk 1 — `tests/test_t08_passage_loop.py`, import block (+1 line).**
Adds `OperationReconcileResult` to the existing `from app.persistence.models import (...)`.
Purely enables hunk 2. No assertion touched.

**Hunk 2 — `tests/test_t08_passage_loop.py`, `reconcile_operation` return (-1/+13).**
Replaces `type("Reconcile", ...)` with `OperationReconcileResult(...)`. This is the
reported defect: the returned object now satisfies the production contract the
gateway reads. Values carried through unchanged from the request; the two removed
attributes (`tokensConsumed`, `refundedTokens`) are not fields of the contract and
are read by nothing in the codebase (verified by grep — zero readers). Adds **zero**
assertions and changes **zero** expected values.

**Hunk 3 — `tests/test_t06_loop_runtime.py`, import block (+1/-1).**
Reflows the import list to add `OperationReconcileResult`. Enables hunk 4.

**Hunk 4 — `tests/test_t06_loop_runtime.py`, `reconcile_operation` return (+13/-1).**
Same transformation as hunk 2. The stub's only prior value, `status="COMPLETED"`, is
preserved (read from the op record the fake just wrote, which is set to `"COMPLETED"`
two lines above).

**Hunk 5 — `tests/test_t06_loop_runtime.py`, `resume_state` (+11/-4).**
Restructures the four `budgetProfile*` assignments to emit `None` when
`self.run_profile is None`. For every non-`None` profile the computed values are
byte-identical to before (`json.dumps(..., sort_keys=True, separators=(",", ":"))`,
the same cached sha, the same `.get(...)`). It only changes behaviour on the
snapshotless path, where the old code raised `AttributeError`. No assertion touched.

**Explicitly not in my commit** (owned by another agent, recovered from VPS, and
carrying a large behavioural diff): the `simulated_run_profile`, `policy_for_profile`
and `DurableStore.__init__` hunks in `tests/test_t06_loop_runtime.py`. I did not
revert, modify or rely on altering them.

## 9. Product diff

`app/loop/runtime.py`, two hunks:

```diff
@@ _reserve @@
             if op.status != "COMPLETED":
+                # A CHECKPOINT_COMMIT reservation that never reached commit_checkpoint
+                # (process died mid-accept) leaves a RESERVED operation whose work is
+                # fully durable and whose retry is idempotent. The reservation already
+                # exists server-side, so go straight to the commit: re-granting would
+                # return isReplay and abort the accept, and re-journalling would double
+                # count an intent that was recorded before the crash. Any other
+                # operation type is an external side effect we cannot prove either ran
+                # or didn't, so it stays fail-closed.
+                if intent.operation_type == "CHECKPOINT_COMMIT" and op.status == "RESERVED":
+                    # The journal is process-local, so the pre-crash intent is gone:
+                    # re-record it so the ack below has an entry to close.
+                    self.journal.record_intent(intent, self.context.cursor.current_state)
+                    self.journal.mark_execution_started(intent.operation_id)
+                    return True
                 self._finish(LoopReason.UNKNOWN_OUTCOME, f"unacknowledged operation {intent.operation_id}")
                 return False
-            return True

@@ _accept @@
-        if op:
+        if op is not None and op.status == "COMPLETED":
             if self._accepted_head is None or self._accepted_head.to_ref() != art.to_ref():
                 raise ValueError("Completed accept operation has no matching accepted head")
+            # _reserve returns early for an existing operation without journalling it.
             self.journal.record_intent(intent, self.context.cursor.current_state)
```

No behaviour outside the accept/reserve paths is touched;
`app/providers/gateway.py` was **not** modified.