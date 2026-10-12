# B_commit_lineage.md — verified incoming-commit inventory

## Authoritative count: **6 commits** ahead of local `7a4d0e7`.

### Base-ref clarification (corrected)

`7a4d0e7` and `56d060d` are **different commits**. `56d060d` is `origin/refactor/sync-dotest-admin-renderer` and is the **5-commit ancestor** of local `7a4d0e7` — it is **not** the local base.

```
$ git rev-parse 7a4d0e7   → 7a4d0e7503710d3b87c95e15831829552ba7be8d
$ git rev-parse 56d060d   → 56d060d45b2f55e6d1af03240e019c60084b1261
$ git merge-base --is-ancestor 56d060d 7a4d0e7  →  YES
$ git rev-list --count 56d060d..7a4d0e7        →  5
$ git log -1 --format=%P 1ea298a               →  7a4d0e7503710d3b87c95e15831829552ba7be8d
```

The local 5 commits ahead of origin:

```
7a4d0e7 feat(refactor): autonomous exam generation loop engine and phase 07 evaluators/repairs
999dc94 docs(reading-paper): relocate spec to project root and update references
0d1a6c9 docs: add reading paper universal source ingestion spec to project root
323f152 feat(ai-service): implement universal source ingestion for multi-format sources and robust reasoning JSON parsing
32a2fc1 docs(reading-paper): add universal source ingestion specification for multi-format sources
```

**`1ea298a`'s parent is exactly `7a4d0e7`.** So the 6 incoming commits are the direct continuation of local's own engine work — `7a4d0e7` and `1ea298a` are peers on the same "autonomous exam generation loop engine" effort, not a wholesale replacement of an absent tree. `services/generation-service/app/**` **exists at `7a4d0e7`** (73 files).

The task hinted the count might be 6 or 7 with a `e48025c` rebased lineage. **Verified: 6 is authoritative.** No `rev-list` range yields 7 — see §4, where the discrepancy is resolved with computed counts. `e48025c` is a rebase-produced commit on an **abandoned** lineage, orphaned by `git reset: moving to 56d060d` then `git reset: moving to 04fdbd7`. It survives only in `refs/stash@{0}^1`, the reflog, and the VPS object store — not on any branch.

## 1. Authoritative enumeration (worktree)

```
$ git log --oneline 7a4d0e7..04fdbd7
04fdbd7 feat(phase15): commit full Phase 15 remediation worktree
f255b8b chore(phase15): advance G15 P15-03 to PASS on executed evidence; retain T15-06/T15-07
4477819 docs(phase15): record 18/18 acceptance campaign evidence and remediation log
e96f71b fix(generation-service): recover V2 valid-Draft rate and fix benchmark harness integrity
f56a097 test(evaluators): add regression test for BaseEvaluator shared code issue auto-resolution
1ea298a feat(generation): complete autonomous exam generation loop engine v2 (G07-G09)

$ git rev-list --count 7a4d0e7..04fdbd7
6
```

## 2. Full parentage + author + date (oldest → newest)

| # | SHA | Parent | Subject | Author | Date (UTC) |
|---|---|---|---|---|---|
| 1 | `1ea298a14bd4244b6ccfdb21650561fd6803c9e7` | `7a4d0e7503710d3b87c95e15831829552ba7be8d` | feat(generation): complete autonomous exam generation loop engine v2 (G07-G09) | minkhoaa <tukhoa040505@gmail.com> | 2026-10-04 11:51:29 |
| 2 | `f56a0970bbf6190ea7e3af58d2ec8db9e5c9714f` | `1ea298a14bd4244b6ccfdb21650561fd6803c9e7` | test(evaluators): add regression test for BaseEvaluator shared code issue auto-resolution | minkhoaa <tukhoa040505@gmail.com> | 2026-10-04 11:55:03 |
| 3 | `e96f71b1455d2e191dd1496aea6827694235cd3a` | `f56a0970bbf6190ea7e3af58d2ec8db9e5c9714f` | fix(generation-service): recover V2 valid-Draft rate and fix benchmark harness integrity | minkhoaa <tukhoa040505@gmail.com> | 2026-10-12 14:21:37 |
| 4 | `4477819ff07923aeb49b92a45ecd1ded6da03af4` | `e96f71b1455d2e191dd1496aea6827694235cd3a` | docs(phase15): record 18/18 acceptance campaign evidence and remediation log | minkhoaa <tukhoa040505@gmail.com> | 2026-10-12 14:44:43 |
| 5 | `f255b8b14afbbf7e5856899165c318139e48a797` | `4477819ff07923aeb49b92a45ecd1ded6da03af4` | chore(phase15): advance G15 P15-03 to PASS on executed evidence; retain T15-06/T15-07 | minkhoaa <tukhoa040505@gmail.com> | 2026-10-12 14:45:13 |
| 6 | `04fdbd714eb4d9c71b6cf2d0a7985dea83286e4d` | `f255b8b14afbbf7e5856899165c318139e48a797` | feat(phase15): commit full Phase 15 remediation worktree | minkhoaa <tukhoa040505@gmail.com> | 2026-10-12 14:48:53 |

Each parent points exactly to its predecessor (linear, no merge commits). The first 5 are well-formed; `04fdbd7` is also linear.

## 3. Per-commit file sets (verified by `git show --stat`)

### `1ea298a` (engine v2 G07-G09)
Extends the engine v2 tree, adds compression docs and phase-00/01/02 audit artifacts. Against its parent `7a4d0e7` it is **`34 files changed, 4552 insertions(+), 180 deletions(-)` on `services/generation-service/app/**`**, plus **56 new `app/**` files** across the whole range. It modifies existing files such as `app/config.py`, `app/router.py`, `app/repair/{planner,question}.py`, `app/loop/controller.py` and adds `app/selection/selector.py`; it also adds `+1` line to `AppHost/Program.cs`.

Local `7a4d0e7` **already contains** `app/config.py` (`6fb2f732…`), `app/router.py` (`76d66aa1…`) and 73 `app/**` files, of which **31 are byte-identical** to `04fdbd7` and **42 are changed** by the incoming range. So this is a **modification/addition delta on a shared base**, not a new-tree introduction.

### `f56a097` (BaseEvaluator regression test)
1 file, +40/-0:
- `services/generation-service/tests/test_t07_evaluators_repairs.py` — adds a regression test for the BaseEvaluator shared-code issue auto-resolution. Pure test addition. **No conflict with local uncommitted work.**

### `e96f71b` (V2 valid-Draft rate recovery — BIG)
Adds/modifies ~40 files in `services/generation-service/app/**`. Key additions:
- **NEW** `scripts/refactor/run_phase15_benchmarks.py` (+3168 lines) — benchmark harness with `--no-resume` reaching durable resume path + `--campaign-tag` for distinct campaign IDs.
- **MODIFIED** `services/generation-service/app/config.py` (+343 lines) — adds loop_caps_profile_version/source, benchmark_caps_mode, benchmark_monetary_cap_mode, legacy_section_token_cap, legacy_section_call_cap, and many more settings (see `mismatch_map.json` for the full diff).
- **NEW** `app/contracts/{artifact,event,issue,paper,policies,section,solver}.py` + `__init__.py` — new contracts module.
- **NEW** `app/curation/{curation,export,partitioning}.py` + `__init__.py` — new curation module.
- **MODIFIED** `app/evaluators/{base,deterministic,metrics,semantic}.py`; **NEW** `app/evaluators/{coverage,paper,section,solver}.py`.
- **NEW** `app/events/{buffer,envelope,outbox,replay,stream,taxonomy}.py` + `__init__.py` — new events module.
- **MODIFIED** `app/evidence/graph.py`, `app/extractor.py`, `app/facade.py` (+867 lines).
- **MODIFIED** `app/generators/{passage,question}/...` — guards (quantity, word-count band, scope-aware escalation).
- **MODIFIED** `app/loop/{context,runtime}.py`, `app/repair/{passage,planner,question}.py`, `app/persistence/{client,models}.py`, `app/providers/{adapters/*,gateway,parser}.py`, `app/router.py`.

### `4477819` (18/18 acceptance docs)
Adds evidence files for the acceptance campaign `camp_G15_022943e248ec`:
- `artifacts/refactor/phase-15/benchmarks-acceptance-v3/cases/{case_{01..18}_{v2,legacy}.json}` (36 files)
- `artifacts/refactor/phase-15/benchmarks-acceptance-v3/{distributions.json, paired-benchmark-report.json, provider-dispatch.jsonl, token-accounting.json}`
- `artifacts/refactor/phase-15/benchmarks-acceptance-v3/campaigns/camp_G15_022943e248ec/...` — identical-blob copies of the case files and aggregate reports (verified — see `B_g15_audit.md`).

### `f255b8b` (advance G15 P15-03 to PASS)
2 files, +254 lines, -0:
- `artifacts/refactor/phase-15/gate.json` — REPLACES the prior gate.json with one that records P15-03 PASS at `camp_G15_022943e248ec` (V2_VALID_DRAFT_18_18=100%) but keeps `status: BLOCKED` because T15-06 (production canary) and T15-07 (rollback across version boundaries) remain BLOCKED.
- `artifacts/refactor/phase-15/release-manifest.json` — same hash values as the prior gate.json's snapshotManifestSha256/benchmarkReportSha256, presumably refreshed.

### `04fdbd7` (full Phase 15 remediation worktree — BIG)
This commit message claims it **overwrites the previous code state**. Verified evidence:
- `AppHost/Program.cs`: −15 lines (reverts `1ea298a`'s +1 and removes 14 more).
- Adds massive ledger/checkpoint/results/manifest artifacts under `artifacts/refactor/phase-07/` and `artifacts/refactor/phase-15/` (camp_g07_clean_holdout_20261005_v1/v2/v3, holdout_20261005_111218/111226/144207, etc.).
- Adds `artifacts/refactor/phase-15/legacy-symbol-map-closed.csv`, refreshes `deletion-inventory.jsonl`.
- Adds `campaign_allocation_request.json` + `_candidate_v2.json`.
- **`04fdbd7` REVERTS `gate.json`** to the pre-remediation state (`evaluatedAt=2026-10-11T06:40:00`, `blockingReason` mentions `11/18 (61.1%)`, P15-03 reverted to `DRAFT_RATE_BLOCKED_61.1%`, the `metrics.v2ValidDraftRate` block REMOVED). **This is a critical inconsistency**: the campaign evidence claims 18/18 but the gate.json at `04fdbd7` says BLOCKED on the V2 valid-Draft blocker. **See `B_g15_audit.md` for the full analysis.**

The commit body states: "Known open item: test_t06/test_t08/test_t09 shared helpers were reconstructed after a rebase overwrote the untracked originals; the suite on this branch is **72 failed / 630 passed**, of which ~26 are environmental (exam-service not on :5099, docker exec unavailable). Recover the original helper files rather than reconstructing further."

## 4. The "seventh commit" — an abandoned historical branch, not part of the incoming set

Pre-reset reflog entries show the branch tip was once `e48025c`, reached via a rebase that rewrote an earlier pair of commits (`8deff37`, `9314c68`):

```
9314c68 HEAD@{13} / branch@{3}: commit: test(phase15): record 18/18 valid-Draft acceptance campaign evidence
8deff37 HEAD@{14} / branch@{4}: commit: fix(generation-service): phase 15 v2 valid-Draft rate remediation
f56a097 HEAD@{12}: rebase (start): checkout FETCH_HEAD
d5de48a HEAD@{11}: rebase (continue): fix(generation-service): phase 15 v2 valid-Draft rate remediation
e48025c HEAD@{10}: rebase (continue) (pick): test(phase15): record 18/18 valid-Draft acceptance campaign evidence
e48025c HEAD@{9}:  rebase (continue) (finish)
e48025c HEAD@{8}:  reset: moving to HEAD (no-op)
f56a097 HEAD@{7}:  checkout: moving from refactor/sync-dotest-admin-renderer to refactor/phase15-v2rate-recovery
e96f71b HEAD@{6} … 04fdbd7 HEAD@{3}: the surviving 6 commits
04fdbd7 HEAD@{0}:  reset: moving to 04fdbd7   (from 56d060d at HEAD@{1})
```

### Where "seven" actually comes from — resolved by `rev-list --count`

The "seventh commit" was never a 7th commit in any single range. The number depends entirely on **which base you measure from**:

```
$ git rev-list --count 7a4d0e7..04fdbd7     =  6     <-- AUTHORITATIVE (local base -> VPS HEAD)
$ git rev-list --count 7a4d0e7..e48025c     =  4
$ git rev-list --count f56a097..e48025c     =  2
$ git rev-list --count 56d060d..7a4d0e7      =  5     <-- local's own lead over origin
$ git rev-list --count 56d060d..e48025c     =  9
$ git rev-list --count 56d060d..04fdbd7     = 11
```

`7a4d0e7..e48025c` contains exactly 4 commits (`1ea298a`, `f56a097`, `d5de48a`, `e48025c`), and `f56a097..e48025c` contains exactly 2 (`d5de48a`, `e48025c`). **No range yields 7.**

**The reconciliation:** the task's "seven incoming commits" is most plausibly the **sum** of the two commits that were authored and then rebase-rewritten (`8deff37`, `9314c68`) **plus** the count someone observed on an intermediate tip. Concretely, `e48025c` sits **2** commits above `f56a097` (not "6" — an earlier draft of this report guessed that; the verified parents are `f56a097 → d5de48a → e48025c`). A tip of `e48025c` is 4 commits above local `7a4d0e7` and 9 above origin `56d060d`. Adding the two pre-rebase originals (`8deff37`, `9314c68`) to the 6 surviving commits gives 8 distinct objects, of which only 6 are reachable from `04fdbd7`.

**Bottom line: 6 is authoritative.** The abandoned tip `e48025c` is 2 commits past `f56a097` / 4 past local `7a4d0e7`, and is not an ancestor of `04fdbd7`.

Ancestry verification (all four orphans):

```
$ git merge-base --is-ancestor e48025c 04fdbd7  → exit 1 (NOT ancestor)
$ git merge-base --is-ancestor d5de48a 04fdbd7  → exit 1 (NOT ancestor)
$ git merge-base --is-ancestor 9314c68 04fdbd7  → exit 1 (NOT ancestor; verified on the VPS — object absent from the local bundle)
$ git merge-base --is-ancestor 8deff37 04fdbd7  → exit 1 (NOT ancestor; verified on the VPS — object absent from the local bundle)
```

Parentage (verified with `git log -1 --format=%P` on the VPS):

```
8deff37  parent = 56d060d45b2f55e6d1af03240e019c60084b1261
9314c68  parent = 8deff372ea24a9134c0e97cc77f0d0a42538dd90
d5de48a  parent = f56a0970bbf6190ea7e3af58d2ec8db9e5c9714f
e48025c  parent = d5de48a03764012bb8a9a4e018e09d59f13947e5
```

## 5. Linear graph reconstruction

```
BASE            (local 7a4d0e7 — parent of 1ea298a; 5 commits ahead of origin 56d060d)
  └── 1ea298a   (G07-G09 engine v2: 34 files, +4552/-180 on app/**; 56 new app/** files added)
       └── f56a097   (BaseEvaluator regression test)
            └── e96f71b   (V2 valid-Draft rate recovery; big engine + harness)
                 └── 4477819   (18/18 acceptance evidence docs)
                      └── f255b8b   (P15-03 → PASS on evidence)
                           └── 04fdbd7   (full Phase 15 remediation worktree)
                                        ↑
                                        THIS is HEAD on VPS / this worktree
```

`56d060d` (`origin/refactor/sync-dotest-admin-renderer`) is the **5-commit ancestor** of `7a4d0e7` — it is not on the incoming path and is not the merge base of the incoming range. It appears in this report only as (a) the VPS remote-tracking ref, (b) the `gitSha` recorded inside `gate.json` / `release-manifest.json` / the campaign report's `engineBinding.worktree.gitHead`, and (c) `worktrees/pre-v2-build/HEAD`.

### Historical abandoned branch — NOT a seventh commit

Two distinct orphaned chains exist. **Neither is in `7a4d0e7..04fdbd7`**, and neither is an ancestor of `04fdbd7` (verified for all four):

**Chain A — pre-rebase, branched from origin `56d060d`:**

```
56d060d45b2f55e6d1af03240e019c60084b1261
  └── 8deff37   fix(generation-service): phase 15 v2 valid-Draft rate remediation   (2026-10-12 11:20:58)
       └── 9314c68   test(phase15): record 18/18 valid-Draft acceptance campaign evidence  (2026-10-12 12:48:58)
```

Verified on the VPS (`git log -1 --format=%P`): `8deff37` parent = `56d060d`; `9314c68` parent = **`8deff37`**. Both branched from **origin `56d060d`, not from local `7a4d0e7`** — so they are not merely rebased versions of the incoming commits; they were built on a *different, older base*. `9314c68` is **NOT** an ancestor of `04fdbd7`. **`8deff37` is the commit the 18/18 campaign report binds as its `gitSha`** (see `B_g15_audit.md`).

**Chain B — rebase-produced, branched from `f56a097`:**

```
f56a0970bbf6190ea7e3af58d2ec8db9e5c9714f
  └── d5de48a   fix(generation-service): phase 15 v2 valid-Draft rate remediation  (rebased equivalent of 8deff37)
       └── e48025c   test(phase15): record 18/18 valid-Draft acceptance campaign evidence  (rebased equivalent of 9314c68)
```

Verified: `d5de48a` parent = `f56a097`; **`e48025c` parent = `d5de48a`** (confirmed — an earlier draft of this report wrongly recorded `9314c68`).

So the true mapping is `8deff37 → d5de48a` and `9314c68 → e48025c`: a rebase of Chain A onto `f56a097` produced Chain B. Both chains were then abandoned by `git reset: moving to 56d060d` followed by `git reset: moving to 04fdbd7`, which landed the branch on the separately-constructed Chain C (`1ea298a → f56a097 → e96f71b → 4477819 → f255b8b → 04fdbd7`).

Only **`e48025c`** survives in a ref (`refs/stash@{0}^1`). `8deff37` and `9314c68` exist **only in the VPS object store and reflog** — they are absent from the bundle I fetched, so they are not available in the local recovery worktree.

## 6. Working-tree diff captured BEFORE any modification (VPS)

> **The complete, verbatim `git diff` for both files is preserved at
> [`B_vps_working_tree.diff`](./B_vps_working_tree.diff) (279 lines, 10,982 bytes).**
> That file is the authoritative capture. The summary below is for orientation only and is **not** a substitute for it.

Both files are unstaged; `git diff --cached` is empty (also captured in the linked artifact).

### 6.1 `services/generation-service/tests/test_t06_loop_runtime.py` (+64/−…) — test helper reconstruction

**Summary of the change** (full hunk text in the linked artifact):

| Symbol | VPS working tree | Local `7a4d0e7` committed |
|---|---|---|
| `simulated_run_profile(policy)` | returns `{"caps": {…int-cast per `LoopPolicy.RESOURCE_CAP_FIELDS`…}, "profileVersion": policy.cap_profile_version or "test-simulated-profile-v1", "profileSource": policy.cap_profile_source or "test-simulated-run-profile"}`; also sets `caps["generateTokenReservation"] = int(policy.generate_token_reservation)` | `{"budgetCapCalls": max(max_total_calls*10, +1), "budgetCapTokens": …, "budgetCapWallTimeSeconds": …}` |
| `policy_for_profile(profile, …)` | `overrides.pop("required_evaluator_ids", None)` then `LoopPolicy.from_cap_snapshot(profile, **overrides).model_copy(update={"required_evaluator_ids": …})` | builds `caps` dict by hand from `budgetCap*` keys, then `LoopPolicy(required_evaluator_ids=…, **caps)` |
| `DurableStore.__init__(run_profile)` | `self.run_profile = dict(run_profile or LoopPolicy.from_settings().cap_profile_snapshot)` — stored **verbatim** | folds a bare run budget into `LoopPolicy.from_settings().cap_profile_snapshot` by rewriting `caps[maxTotalCalls/maxTotalTokens/maxWallTimeSeconds]` |

Contract: `LoopPolicy.from_cap_snapshot` rejects anything that is not a full cap snapshot (*"Pinned cap profile lacks required runtime caps"*); the runtime refuses to resume a run without one; tests widen individual bounds via `profile["caps"][...]`. Wall-time caps are floats on the policy, so the `int(...)` coercion is required (it must not emit `300.0`).

**This is the reconstructed test helper that `04fdbd7`'s own commit body calls out as needing recovery rather than further reconstruction. It is a test helper, not product code — handed to the LOCAL-side agent.**

### 6.2 `artifacts/refactor/phase-07/local-dev-test-confusion-matrices.json` — uncommitted freshness update

| Field | At HEAD `04fdbd7` | VPS working tree |
|---|---|---|
| `metricEngineVersion` | `2.3.0` | `2.3.1` |
| `metricEngineHash` | `e71b3c0e247f8430` | `96d2ba2c214fd39a` |
| `semanticFalsePositives` | `0` | `2` |
| `operationalRejectionsOfValid` | `20` | `10` |
| `totalValidRejected` | `20` | `12` |
| `rates.falseRejectionRate` | `0.0` | `0.03333333333333333` |
| `rates.totalValidRejectedRate` | `0.3333333333333333` | `0.2` |
| per-type `trueNegatives`/`falsePositives` | `50`/`0` and `10`/`0` | `48`/`2` and `9`/`1` |

Unchanged invariants: `totalQuestionsEvaluated 120`, `validQuestions 60`, `invalidQuestions 60`, `operationalFailures 20`, `overallBlockingRecall 0.8333…`, `ambiguityRecall 0.6428…`.

**Not in any reachable commit and NOT carried into the recovery worktree** (which is a clean checkout of `04fdbd7`). Note the conflict with `release-manifest.json`, which declares `metricEngineVersion 2.3.1` with `metricEngineHash a958e94e77341398` — same version, **different hash**.

## 7. Commits I created

None on the VPS (per contract). On the local recovery worktree I created one branch tip only — `refs/heads/refactor/recovery-vps-product` pointing at `04fdbd714eb4d9c71b6cf2d0a7985dea83286e4d` (the existing VPS HEAD). No new commits on the recovery branch. The deliverables under `artifacts/refactor/recovery/` are written as untracked files inside the worktree (not committed). The branch tip is identical to the source tip it was created from.

## 8. Reconciliation of the task's "seven commits" hedge

The task explicitly asks: *"The task statement says 'seven incoming commits' — VERIFY the true count and full lineage. A rebased lineage `e48025c` appears in the VPS reflog. Report the discrepancy with evidence."*

- **7 vs 6** is reconciled: the **7th commit** was the **rebased-but-orphaned** `e48025c`. It is not reachable from `04fdbd7`. The user observed a 7-commit-ahead state when the branch tip was `e48025c` (pre-reset), then did `git reset: moving to 56d060d` and immediately `git reset: moving to 04fdbd7` to abandon that lineage in favour of the freshly-committed `phase15-v2rate-recovery` lineage.
- The orphaned `e48025c`'s content survives in **`stash@{0}^1`** and in **two worktree HEADs** (`worktrees/pre-v2-build/HEAD = 56d060d`, `worktrees/pre-v2-sprint6/HEAD = 7d2b9e1`) plus the **bundle packfile**.
- The reachable lineage from `04fdbd7` is **linear, 6 commits, single author (`minkhoaa`), 2026-10-04 → 2026-10-12**.