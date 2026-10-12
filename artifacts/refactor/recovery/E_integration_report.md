# Recovery Integration Report — Langfens local ↔ VPS reconciliation

**Integration branch:** `refactor/recovery-integrate-g15`
**Base:** `04fdbd7` (VPS HEAD) · **Commits added:** `7844394`, `2fa30c3`
**Coordinator worktree:** `/home/khoa/Projects/langfens/recovery-wt-M`
**Verified:** 2026-10-12

---

## 1. Preserved state (recorded before any mutation)

| Item | Local | VPS |
|---|---|---|
| Branch | `refactor/sync-dotest-admin-renderer` | same |
| HEAD | `7a4d0e7` | `04fdbd7` |
| Stash | **empty** | `stash@{0}` = `b322fdbda4b5e569c0ca7c2e7db2ea8f2c995a17` (**intact, never applied/popped/dropped**) |
| Tracked changes | ~37 modified | 2 modified |
| Untracked | large `artifacts/` corpus | large `artifacts/` corpus |

No destructive operation was performed on either machine: no `reset --hard`, no force-push, no branch/ref deletion, no `git clean`, no stash mutation, no deploy, no service restart.

---

## 2. Premise corrections (measured, not assumed)

Three premises in the task brief were false. Each is recorded here with evidence rather than silently worked around.

| Premise | Verdict | Evidence |
|---|---|---|
| "test_t06/t08/t09 helpers are missing" | **FALSE** | Zero undefined names / unresolved `app.*` imports across all four files. `test_t06`'s helpers are **methods** of the `DurableStore` class, invisible to a `^def _*` grep. |
| "707 expected vs 702 collected, five tests missing" | **FALSE** | Local collects **250** / 18 modules; VPS `04fdbd7` collects **728** / 59 modules; zero collection errors either side. `707` = 701 passed + 6 failed (fix-log milestone table `v2rate-root-cause-and-fix-log.md:300`). `702` appears only as a passage word count in `logs/generation-service.log:103454`. The 478-test delta is 41 engine-v2 modules arriving with the 6 commits. **Post-merge target is 728.** |
| "seven incoming commits" | **FALSE — 6** | `git rev-list --count 7a4d0e7..04fdbd7` = 6. No range yields 7. `1ea298a`'s parent is exactly `7a4d0e7`. The apparent "7th" conflates the 6 reachable commits with 2 pre-rebase originals (`8deff37`, `9314c68`) on an abandoned lineage. |

---

## 3. Mismatch resolution: VPS is authoritative

All 13 product-code mismatches resolved `take_vps_three_way` (see `B_mismatch_map.md`).

Decisive evidence that VPS `04fdbd7` supersedes local uncommitted work rather than being merged with it:

- **Engine-v2 markers exist only on VPS:** `cap_profile_snapshot` → VPS 3 files / local 0; `budgetProfileSha256` → VPS 2 / local 0.
- **`app/` file count:** 73 (`7a4d0e7`) → 129 (`04fdbd7`), +56 added, 0 deleted.
- **Every** local-only file exists on VPS (`app/facade.py`, `app/loop/question.py`, `tests/test_t08`, `test_t09_*`, …). Local's uncommitted work is an **earlier draft of the same engine-v2 port**, lacking the cap-profile/budget-profile contract.
- `git diff 04fdbd7 -- services/generation-service/app/config.py` = `+75/-732`: the local draft deletes capabilities VPS has.

**Consequence:** local uncommitted work was **not** merged. It remains intact in the main checkout (318 porcelain entries, unchanged) for the owner to decide.

---

## 4. Recovery provenance

### 4.1 `test_t06_loop_runtime.py` — commit `7844394`

**This file exists only as an UNCOMMITTED VPS working-tree change.** It is absent from `04fdbd7`.

- Recovered read-only over SSH; md5 `4c9c3b703946c8e67d6aca5f2c109b37`, 1091 lines.
- Committed `simulated_run_profile` returned a bare run budget; engine-v2 tests widen bounds via `profile["caps"][...]` and `LoopPolicy.from_cap_snapshot` rejects a snapshot without `caps`.
- Effect: `-k phase15_v2rate` went **16 failed / 123 passed → 1 failed / 138 passed**, matching the VPS exactly (14 × `KeyError: 'caps'` eliminated).
- **Integrity:** 0 assertions added, removed or modified; all 33 tests retained.

### 4.2 Rejected recoveries (9 VPS-stash helper variants)

All required engine-v2 fields absent locally (`LoopPolicy.cap_profile_snapshot`, `ArtifactResumeInfo.budgetProfile*`), and `is_service_available()` is an explicit `skipif` guard — i.e. **coverage weakening**. `SQLiteCheckpointSimulation` alias claimed importers that `grep` shows do not exist. All rejected.

### 4.3 Product fixes — commit `2fa30c3`

| Defect | Layer | Fix |
|---|---|---|
| `Reconcile` stub returned a hand-rolled `type()` lacking `reservationBreached` / `budgetBreachDetected`; `gateway.py:483` reads them → `AttributeError` | test double | both fakes now construct the real `OperationReconcileResult` (matching `test_t03_providers.py`), so they cannot re-drift |
| `_accept` skipped `commit_checkpoint` whenever *any* op record existed, stranding a crash-left `RESERVED` commit → `HTTP 409: cursor has no durable operation ack` | product | replay branch now gated on a **durably COMPLETED** op; `_reserve` lets a `RESERVED` `CHECKPOINT_COMMIT` proceed to commit. Scoped to `CHECKPOINT_COMMIT` — a provider call still cannot be proven to have run, so it stays fail-closed |
| Snapshotless run crashed with `AttributeError: 'NoneType'` | product | now raises the legible `"Run lacks a pinned cap profile"`, so the runtime owns the fail-closed decision |

**Integrity:** `git show 2fa30c3 -- services/generation-service/tests/` contains **zero** `assert` lines.

---

## 5. Test inventory and results

| Suite | Baseline | Final |
|---|---|---|
| Full (`tests/`) at `04fdbd7` | 61 failed / 553 passed / 39 skipped / 8 errors | **39 failed / 652 passed / 37 skipped** |
| RC-focused (`-k phase15_v2rate`) | 16 failed / 123 passed | **1 failed / 138 passed** |
| VPS live checkout (reference) | 54 failed / 648 passed / 26 skipped | — |

The integration candidate is **healthier than the VPS baseline** (39F/652P vs 54F/648P), with no regression against the VPS failure set.

### Remaining failure classification

**Environment (not code):**
- `test_t14_harness_integration::test_full_phase14_lifecycle_e2e` — `psql` binary absent on this host (no sudo; present in container and on VPS).
- `test_t00_endpoints` (8) — needs a live exam-service; returns `503`.
- `test_t09_*` / `test_t09_real_postgres_*` — call the real MiniMax endpoint, HTTP `402 insufficient_balance_error`.
- `test_t15_benchmarks` / `test_t15_release_manifests` — assert against the **stale** `benchmarks/` report (11-case campaign, `assert 11 >= 18`), superseded by acceptance-v3.

**Pre-existing on VPS (parity confirmed, not regressions):**
- `test_t06_05_evaluator_timeout_fail_closed`, `test_budget_caps_exhaustion`, `test_t06_property_finite_sequence_termination`, `test_t06_repair_attempt_cap_reached`
- `test_phase15_v2rate_b_recovery_closure::test_phase15_v2rate_b_hanging_evaluator_fails_closed_under_wall_reservation`
- `test_phase15_v2rate_main_campaign_binding::test_report_binds_results_to_worktree_and_engine_surface`

**Root cause of the 4 `test_t06_*` failures (single shared cause, diagnosed and left unresolved rather than papered over):**
`BoundedLoopRuntime._restore` → `_initialize_policy` (`runtime.py:126-140`) **replaces** `self.policy` from the persisted pinned cap profile via `LoopPolicy.from_cap_snapshot(run_profile)`. `DurableStore` defaults `run_profile` to `LoopPolicy.from_settings().cap_profile_snapshot` (`deploy/envs/loop-caps.env`, `phase13-production-v1`), so every cap the test sets in memory is discarded — e.g. `test_t06_property_finite_sequence_termination` requests `max_total_tokens=12000` but the runtime enforces `60000`. Verified by re-running each scenario with `run_profile=simulated_run_profile(policy)`: **every assertion then holds** (`CALL_CAP`, `gen.calls==1`; fails-closed `EVALUATOR_ERROR`; repair cap PASS/ACCEPTED). This is **test-setup drift, not a product defect**, and the fix would require editing assertions/fixtures in the recovered helper — refused under the no-weakening rule. Recommendation: pass `run_profile=simulated_run_profile(policy)` in those four setups, widening caps where a test's own schedule exceeds the defaults.

---

## 6. G15 evidence audit — `camp_G15_022943e248ec`

Located at `artifacts/refactor/phase-15/benchmarks-acceptance-v3/campaigns/camp_G15_022943e248ec/`, committed in `4477819`, 79 tracked files, clean working tree.

### Snapshot and PostgreSQL lineage

| Field | Value |
|---|---|
| Report `gitSha` | `8deff372ea24a9134c0e97cc77f0d0a42538dd90` — an **orphaned pre-rebase** commit, NOT an ancestor of `04fdbd7` |
| `engineBinding.worktree.gitHead` | `56d060d` — **inconsistent with the report's own `gitSha`** |
| `worktreeDirty` | `true` (259 modified, 1179 untracked paths) |
| DB | `exam_test_phase15` @ `localhost:5433`, user `exam`, target `ISOLATED_STAGING_TEST` |
| Persistence audit | `v2AuthoritativePersistedCount=18`, `legacyShadowPersistedCount=0`, `shadowOverwrotePrimary=false` |

**Evidence-compatibility conclusion:** `git rev-parse 8deff37:services/generation-service/app` **==** `git rev-parse 04fdbd7:services/generation-service/app` **==** `dc86e69ccc63b734d7b7384b684b0005beeb9b4b`. The **engine tree is byte-identical** between the campaign commit and VPS HEAD, so the 18/18 evidence is reusable for the engine despite the differing commit hash.

### Absence of replay-row splicing — verified four independent ways

1. `provider-dispatch.jsonl`: 1013 rows, **zero** exact duplicates; 1013/1013 unique `operationId`, `requestSha256`, `responseSha256`; 36 distinct `runId`; 36 distinct start timestamps.
2. All 18 `(sourceTriple, seed)` combinations distinct (factorial 6 triples × 3 seeds, each exactly once).
3. **SQL self-join across all prior campaigns: `COUNT(*) = 0`** — zero run-ID overlap. The `--no-resume` / `--campaign-tag` anti-splice fix **held**.
4. All 8 FAILED rows **retained** in PostgreSQL, not overwritten by a retry; status 28 COMPLETED / 8 FAILED / 0 incomplete, matching `failedRunsCount=8`. All 8 failures are **legacy** arm; V2 validDraft is 18/18.

### 18/18 evidence: reusable

Compatible and reusable as-is: 18 paired papers / 36 runs, V2 valid-Draft 18/18 (100%, target ≥95%), legacy 10/18, P95 latency ratio 0.709×, median token ratio 0.235×, fidelity must-reject 100%, semantic recall 100%. 100% pure `MiniMax-Text-01`, 0 Groq calls.

### G15 remains BLOCKED — rollback/canary evidence still PENDING

`gate.json` is `BLOCKED` at `gitSha 56d060d`. `P15-04`/`T15-06` = `BLOCKED_ON_PRODUCTION_OBSERVATION`; `T15-07`/`P15-07` = `BLOCKED_PARTIAL_CONTAINER_REHEARSAL`; `G12` BLOCKED.

Canary evidence (`canary/chaos-matrix-report.json` 14/14, `canary/duplicate-exam-replay.json`) and rollback rehearsal (`rollback/rollback-rehearsal.json` 5/5) are bound to database `exam_test_phase14_lineage` and the **pre-remediation** commit era (`56d060d`, dated 2026-10-09/10). They therefore **do not revalidate the remediated engine** and must be rerun. G15 stays pending rollback/canary evidence; no production rollout was performed.

---

## 7. Machine-specific settings kept separate

| File | Status | Handling |
|---|---|---|
| `deploy/envs/loop-caps.env` | **VPS-only, gitignored** (`.gitignore:19 deploy/envs/**`), 68 keys | Required by `app/config.py:22`. Copied into the worktree as an untracked runtime input; **never committed**. |
| `deploy/envs/ai.env` | 32 VPS keys vs 45 local; 31 shared | 14 `LOOP_*` caps exist only locally, `CORS_ALLOWED_ORIGINS` only on VPS. Verified caps come from `loop-caps.env`. |
| `artifacts/refactor/phase-15/benchmarks/`, `logs/` | VPS-only, **0 tracked files** | Machine-local measurement evidence; copied untracked, never committed. |

Sanitized profiles compare key names and value shapes only — no secret values, tokens or full DSNs were emitted.

---

## 8. Deliverables index

| File | Contents |
|---|---|
| `A_local_snapshot.md` | preserved local state + hashes |
| `A_helper_recovery.md` | helper recovery provenance, 9 rejected variants |
| `A_test_inventory.md` | collected-test inventory; 707/702 correction |
| `A_mismatch_map.md` / `B_mismatch_map.md` / `mismatch_map.json` | mismatch map (local+helpers / VPS+product halves) |
| `B_vps_snapshot.md`, `B_commit_lineage.md` | VPS snapshot; verified 6-commit lineage |
| `B_product_delta.md` | per-file product delta, RC-1…RC-17 register |
| `B_g15_audit.md` | G15 audit detail |
| `C_runtime_commit_fix.md` | local-draft `_accept` diagnosis |
| `D_helper_drift_and_accept_fix.md` | stub drift + `_accept` fix verification |
| `E_integration_report.md` | this document |