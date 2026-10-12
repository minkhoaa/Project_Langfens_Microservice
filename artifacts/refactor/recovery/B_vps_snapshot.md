# B_vps_snapshot.md — VPS state preserved BEFORE any mutation

Captured non-destructively from `code@57.159.24.245:~/workspaces/langfens/Project_Langfens_Microservice` over SSH and from a non-mutating `git bundle` brought into the local main repo (`refs/vps/*`). No `git reset --hard`, no force-push, no branch/stash deletion, no service restart performed on the VPS. Local main checkout working-tree state is **unchanged** (`status --porcelain | wc -l = 318` before and after fetch).

## 1. Identity

| Field | Value |
|---|---|
| Capture host | `code@code-std` (`code@57.159.24.245`) |
| Capture UTC | `2026-10-12T15:05Z` (initial probe) / `2026-10-12T15:07Z` (bundle create) |
| Repo path (VPS) | `~/workspaces/langfens/Project_Langfens_Microservice` |
| Repo path (local main) | `/home/khoa/Projects/langfens/Project_Langfens_Microservice` |
| Recovery worktree | `/home/khoa/Projects/langfens/recovery-wt-B` |
| Recovery branch | `refactor/recovery-vps-product` |
| Recovery worktree HEAD | `04fdbd714eb4d9c71b6cf2d0a7985dea83286e4d` |

## 2. HEAD, branches, refs (VPS, captured verbatim)

```
$ git rev-parse HEAD
04fdbd714eb4d9c71b6cf2d0a7985dea83286e4d

$ git branch -vv
  master                              af83797 [origin/master] docs: add empirical performance benchmarks and production [+22]
  refactor/phase15-v2rate-recovery    04fdbd7 feat(phase15): commit full Phase 15 remediation worktree
* refactor/sync-dotest-admin-renderer 04fdbd7 feat(phase15): commit full Phase 15 remediation worktree

$ git for-each-ref (selected)
af83797c1c16eed5932bde23fd8e86309ba051d1 commit  refs/heads/master
04fdbd714eb4d9c71b6cf2d0a7985dea83286e4d commit  refs/heads/refactor/phase15-v2rate-recovery
04fdbd714eb4d9c71b6cf2d0a7985dea83286e4d commit  refs/heads/refactor/sync-dotest-admin-renderer
af83797c1c16eed5932bde23fd8e86309ba051d1 commit  refs/remotes/origin/HEAD
af83797c1c16eed5932bde23fd8e86309ba051d1 commit  refs/remotes/origin/master
56d060d45b2f55e6d1af03240e019c60084b1261 commit  refs/remotes/origin/refactor/sync-dotest-admin-renderer
b322fdbda4b5e569c0ca7c2e7db2ea8f2c995a17 commit  refs/stash
+ 11 origin/pr/* refs (pr/1 .. pr/12, excluding pr/10 was renamed in the bundle listing)
+ 2 worktree HEADs visible in `git bundle verify`:
    56d060d45b2f55e6d1af03240e019c60084b1261 worktrees/pre-v2-build/HEAD
    7d2b9e187dd0d393571ef6047cb4e0b9e3d9ea4d worktrees/pre-v2-sprint6/HEAD
```

## 3. Working-tree state (VPS)

```
$ git status --porcelain=v1 -uall
 M artifacts/refactor/phase-07/local-dev-test-confusion-matrices.json
 M services/generation-service/tests/test_t06_loop_runtime.py

$ git diff --cached
(empty — nothing staged)
```

Both unstaged files are recorded in `artifacts/refactor/recovery/B_product_delta.md`. They are uncommitted local edits on the VPS only — they are NOT on the recovery worktree, which is a clean checkout of `04fdbd7`.

## 4. Stash list + anatomy (VPS)

```
$ git stash list
stash@{0}: On sync-dotest-admin-renderer: phase15 rebase-repair: restored engine files + reconstructed test helpers

$ git stash show --stat stash@{0}
 ... 30 files changed, 1099 insertions(+), 31713 deletions(-)
 .gitignore                                                 |     6 +-
 AppHost/Program.cs                                         |    15 -
 Project_Langfens_Microservice.sln                          |    15 -
 artifacts/refactor/phase-00/.../section-error-stream-...ndjson | 4 -
 artifacts/refactor/phase-00/fixtures-hashes.json           |    27 -
 artifacts/refactor/phase-02/constraints.json               |   265 -
 artifacts/refactor/phase-04/graph-verification-report.json |   121 -
 artifacts/refactor/phase-05/policy-parity-report.json      |    69 -
 artifacts/refactor/phase-06/state-coverage-report.json     |   115 -
 artifacts/refactor/phase-07/campaigns/camp_g07_20261004_112756_25d534_manifest.json | 57 -
 artifacts/refactor/phase-07/campaigns/camp_g07_20261004_113228_e5b930_results.json  | 30009 -------------------
 artifacts/refactor/phase-07/local-dev-test-confusion-matrices.json | 65 +-
 artifacts/refactor/phase-08/test-report.json               |    90 -
 artifacts/refactor/verify-after-phase-06/state-coverage-report.json | 115 -
 deploy/compose.local.yaml                                  |     2 -
 deploy/compose.yaml                                       |    18 -
 services/ai-service/app/config.py                         |     7 -
 services/ai-service/app/prompts/autogen.py                |    11 +-
 services/ai-service/app/prompts/autogen_contract.json     |    50 +-
 services/ai-service/app/prompts/autogen_data.py            |   725 +-
 services/ai-service/app/prompts/autogen_templates.py       |    10 +-
 services/ai-service/app/services/groq_service.py          |   288 +-
 services/ai-service/app/services/llm_service.py           |    22 +-
 services/ai-service/tests/test_autogen_prompts.py          |     5 +-
 services/ai-service/tests/test_autogen_router.py           |   292 +-
 services/ai-service/tests/test_groq_service.py             |   264 +-
 services/exam-service/Domains/Entities/ExamSection.cs      |     6 -
 services/generation-service/tests/test_t06_loop_runtime.py |    64 +-
 services/generation-service/tests/test_t08_passage_loop.py |    40 +-
 services/generation-service/tests/test_t09_real_postgres_durability.py | 35 +
```

`stash@{0} -p` line count = 33,524 lines. **Stash was NOT applied, dropped, or popped on the VPS.**

### 4.1 Stash parents (3 parents — `--include-untracked` style stash)

```
stash@{0}^0 = b322fdbda4b5e569c0ca7c2e7db2ea8f2c995a17  (stash commit itself)
stash@{0}^1 = e48025c151aa8df34a7d29ebe34fc4b440be8075  (WIP parent — pre-rebase-repair state)
stash@{0}^2 = 21cb33fbd5746581a4ec362fe797554eb7868964  (untracked tree 1)
stash@{0}^3 = 6cea2802467053971e75f308e592ea3f87cfdb71  (untracked tree 2 — root of untracked commit)
```

`stash@{0}^1 = e48025c` is the rebased WIP commit created by the interrupted rebase (see §5). Its subject is `test(phase15): record 18/18 valid-Draft acceptance campaign evidence`. The stash's `^0` parent line is `e48025c 21cb33fbd5 6cea2802467053…`, meaning the stash captured BOTH the WIP changes (engine files + reconstructed helpers) AND the untracked artifacts (phase-00/02/04/05/06 reports, ai-service files, deploy/*, exam-service files, etc.) at that moment.

### 4.2 Is the stash post-HEAD or pre-HEAD residue?

```
$ git merge-base --is-ancestor stash@{0} 04fdbd7  →  exit 1  (NOT ancestor)
$ git merge-base --is-ancestor 04fdbd7 stash@{0}  →  exit 1  (NOT ancestor)
```

**The stash and `04fdbd7` are on divergent lineages.** The stash's `^1 = e48025c` is a rebased commit on the abandoned rebase continuation (reflog entries `e48025c HEAD@{8..10}`); `04fdbd7` is on a fresh commit created on the `refactor/phase15-v2rate-recovery` branch starting from `f56a097`. Both share ancestry at `f56a097` → `7a4d0e7`-ish lineage but never converge. **The stash is **pre-HEAD residue** from the abandoned rebase-repair work, captured for safety.** It contains material the user explicitly asked NOT to apply, drop, or pop.

### 4.3 Candidate-for-recovery assessment

The stash **is** a candidate for recovery (it predates the destructive overwrite in `04fdbd7` and contains engine files + reconstructed test helpers), but per task contract it was never touched on the VPS. The other recovery agent (LOCAL side) owns test-helper reconstruction; the engine files inside the stash are a partial duplicate of what `e96f71b..04fdbd7` already committed, so the value is limited.

## 5. Reflog — full lineage of `04fdbd7` and the orphaned `e48025c` rebased path

```
$ git reflog -20
04fdbd7 HEAD@{0}: reset: moving to 04fdbd7
56d060d HEAD@{1}: reset: moving to origin/refactor/sync-dotest-admin-renderer
e48025c HEAD@{2}: checkout: moving from refactor/phase15-v2rate-recovery to refactor/sync-dotest-admin-renderer
04fdbd7 HEAD@{3}: commit: feat(phase15): commit full Phase 15 remediation worktree
f255b8b HEAD@{4}: commit: chore(phase15): advance G15 P15-03 to PASS on executed evidence; retain T15-06/T15-07
4477819 HEAD@{5}: commit: docs(phase15): record 18/18 acceptance campaign evidence and remediation log
e96f71b HEAD@{6}: commit: fix(generation-service): recover V2 valid-Draft rate and fix benchmark harness integrity
f56a097 HEAD@{7}: checkout: moving from refactor/sync-dotest-admin-renderer to refactor/phase15-v2rate-recovery
e48025c HEAD@{8}: reset: moving to HEAD
e48025c HEAD@{9}: rebase (continue) (finish): returning to refs/heads/refactor/sync-dotest-admin-renderer
e48025c HEAD@{10}: rebase (continue) (pick): test(phase15): record 18/18 valid-Draft acceptance campaign evidence
d5de48a HEAD@{11}: rebase (continue): fix(generation-service): phase 15 v2 valid-Draft rate remediation
f56a097 HEAD@{12}: rebase (start): checkout FETCH_HEAD
9314c68 HEAD@{13}: commit: test(phase15): record 18/18 valid-Draft acceptance campaign evidence
8deff37 HEAD@{14}: commit: fix(generation-service): phase 15 v2 valid-Draft rate remediation

$ git reflog refs/heads/refactor/sync-dotest-admin-renderer
04fdbd7 @{0}: reset: moving to 04fdbd7
56d060d @{1}: reset: moving to origin/refactor/sync-dotest-admin-renderer
e48025c @{2}: rebase (continue) (finish): returning to refs/heads/refactor/sync-dotest-admin-renderer
9314c68 @{3}: commit: test(phase15): record 18/18 valid-Draft acceptance campaign evidence
8deff37 @{4}: commit: fix(generation-service): phase 15 v2 valid-Draft rate remediation

$ git reflog refs/heads/refactor/phase15-v2rate-recovery
04fdbd7 @{0}: commit: feat(phase15): commit full Phase 15 remediation worktree
f255b8b @{1}: commit: chore(phase15): advance G15 P15-03 to PASS on executed evidence; retain T15-06/T15-07
4477819 @{2}: commit: docs(phase15): record 18/18 acceptance campaign evidence and remediation log
e96f71b @{3}: commit: fix(generation-service): recover V2 valid-Draft rate and fix benchmark harness integrity
f56a097 @{4}: branch: Created from f56a097
```

The "7th commit" in the task's hedging is `e48025c`. It is **not** reachable from current HEAD `04fdbd7`:

```
$ git merge-base --is-ancestor e48025c 04fdbd7  →  exit 1  (NO)
$ git merge-base --is-ancestor e48025c 7a4d0e7  →  exit 1  (NO)
$ git merge-base --is-ancestor 8deff37 04fdbd7  →  exit 1  (NO)   (pre-rebase ancestor of e96f71b)
$ git merge-base --is-ancestor 9314c68 04fdbd7  →  exit 1  (NO)   (pre-rebase ancestor of 4477819)
$ git merge-base --is-ancestor d5de48a 04fdbd7  →  exit 1  (NO)   (rebased-but-orphaned)
```

So `e48025c`, `d5de48a`, `9314c68`, `8deff37` form an orphaned lineage (the abandoned rebase-repair attempt). It survives only in `refs/stash` (`^1`), in the reflog, and in the bundle's packfile.

## 6. Behavior-defining file content hashes

```
$ git hash-object <VPS-working-tree-version>
services/generation-service/app/config.py      : 358967457aba1a8039179001de420850e6b16e20  (371 lines)
services/generation-service/app/router.py       : 561a112d7d332f8a92378fe69b1b49e7974c82c9  (1055 lines)
services/generation-service/pytest.ini          : 6f94355f5aa7f4ef131ef85247ad4a3874b9ee45  (3 lines)
services/generation-service/pyproject.toml      : MISSING
deploy/compose.yaml                            : eefc6efbe2b31f698d211c659574f591df2b93eb  (488 lines)
deploy/compose.local.yaml                      : 734cb2e7952f4efb0670ccff33ea147641575561  (518 lines)
AppHost/Program.cs                             : cba010e84717516c757790bd24b3467241f9db39  (372 lines)
```

```
$ git rev-parse HEAD:<same-path>
HEAD:services/generation-service/app/config.py  : 358967457aba1a8039179001de420850e6b16e20  (matches working tree)
HEAD:services/generation-service/app/router.py   : 561a112d7d332f8a92378fe69b1b49e7974c82c9  (matches)
HEAD:deploy/compose.yaml                        : eefc6efbe2b31f698d211c659574f591df2b93eb  (matches)
HEAD:AppHost/Program.cs                         : cba010e84717516c757790bd24b3467241f9db39  (matches)
```

```
$ git rev-parse 7a4d0e7:<same-path>   (LOCAL BASE — parent of 1ea298a)
7a4d0e7:services/generation-service/app/config.py : 6fb2f732301995c4a4288a5942ff87140003cbe9   (CHANGED → 35896745…)
7a4d0e7:services/generation-service/app/router.py  : 76d66aa18692316a6ba4ca1a9d8044baf8cabacf   (CHANGED → 561a112d…)
7a4d0e7:deploy/compose.yaml                        : eefc6efbe2b31f698d211c659574f591df2b93eb   (IDENTICAL to HEAD)
7a4d0e7:AppHost/Program.cs                         : 22061362ac8ed2fbe717af3ee59a869f3e8c982b   (CHANGED → cba010e8…, −14 lines)

$ git rev-parse 56d060d:<same-path>   (ORIGIN REMOTE-TRACKING — 5 commits BEHIND local 7a4d0e7)
56d060d:services/generation-service/app/config.py : MISSING
56d060d:services/generation-service/app/router.py  : MISSING
56d060d:deploy/compose.yaml                        : 77c248eacc30af9f6e6c6ec890653795a4003796
56d060d:AppHost/Program.cs                         : cba010e84717516c757790bd24b3467241f9db39
```

**Observations (corrected):**
- **The local base is `7a4d0e7`, NOT `56d060d`.** `56d060d` is `origin/refactor/sync-dotest-admin-renderer` and is the **5-commit ancestor** of `7a4d0e7`. Comparisons in this report use `7a4d0e7`.
- `services/generation-service/app/config.py` and `router.py` **exist at `7a4d0e7`** (`6fb2f732…`, `76d66aa1…`) and are **modified** by the incoming range (→ `35896745…`, `561a112d…`). They are absent at `56d060d` only because origin is 5 commits behind.
- **`AppHost/Program.cs` is NOT net-zero against `7a4d0e7`.** `04fdbd7` removes **14 lines** vs local base: it deletes the whole `generationService` Docker resource and the exam-service wiring that depends on it. `04fdbd7`'s blob is identical to `56d060d`, i.e. the incoming range reverts to the *origin* version of this file, discarding local's generation-service AppHost wiring. **See `B_product_delta.md` P-10.**
- `deploy/compose.yaml` is **byte-identical at `7a4d0e7` and `04fdbd7`** (`eefc6efb…`). It differs from origin `56d060d` (`77c248ea…`), so the rewrite landed in local's own `7a4d0e7`, not in the incoming range.

## 7. Env files (.env / .env.example) — paths + SHA-256, values never read

**Env files are untracked and gitignored on both machines.** `.gitignore` lines 19 (`deploy/envs/**`), 25–28 (`.env`, `.env.*`, `**/.env`, `**/.env.*`). `git rev-parse HEAD:deploy/envs/ai.env` on the VPS → *"path exists on disk, but not in 'HEAD'"*. Therefore these have **no git blob hash**; the stable identifier below is the **SHA-256 of the file content**, computed without emitting any value.

| Path | VPS `04fdbd7` SHA-256 | VPS keys | Local SHA-256 | Local keys | Status |
|---|---|---|---|---|---|
| `deploy/envs/ai.env` | `8f2727caa05c959da9ca54826bebe73eabfd74e6761c056941ebaf89a66e7d53` | 32 | `36282f0b6ec2550892ba6ab24b56144afb974a5ee4b56e5e6f024fba9118ebac` | 45 | **DIFFERS** |
| `deploy/envs/attempt.env` | `5620b0a70dc08f00787dac5420df351da439a343a25c9c66080a26e7183c0d48` | 14 | `11fc29b5368b251b3fa1ea5482910b7e6d4c66377a5ac668b33116bd73a254c7` | 13 | **DIFFERS** |
| `deploy/envs/auth.env` | `376485471bc50a9fcb85fa4ca36aa686abf435648cb842312de8447370418867` | 11 | `43a4d379fcf407e04e76716c4f3e28d0e4afd9d5ad897c8048491f2eb163e027` | 10 | **DIFFERS** |
| `deploy/envs/course.env` | `5d23140fd8726e0e8df98088fa65981bb5e57ba22d72f30dd8a23fc7728b9eb3` | 3 | `cf60ce40db678829a4e1e5eb8e29ed85d413c72d743825114d220216d7142204` | 2 | **DIFFERS** |
| `deploy/envs/dictionary.env` | `0b49340c6eb90fc3298d0a6abd71235a46c3e39dba11379dadc2872f5d8a5a5e` | 5 | `b8a3344b1b0420e7d2724aa67db72dcad7724ae2b3caf80006f18ab86b03db54` | 4 | **DIFFERS** |
| `deploy/envs/email.env` | `ea1030c01218e99f7302bf913537aa41ae6be283d71e204eed4687cb043062b7` | 17 | `a256866a250ee933f2c53e476e2317f83715aff4a8c0815ee1f9102a5e791863` | 16 | **DIFFERS** |
| `deploy/envs/exam.env` | `f66b09f0e47b421a087800602b119ae62c6b440e438b8c841d1962051b6fc0ff` | 3 | `543265e162efda59043d0f587db342f0516d72ef5e04802a7a2a57db13b58043` | 2 | **DIFFERS** |
| `deploy/envs/frontend.env` | `53fb41457c1725a44080a49f54e17eba6db86b283d1241a4d65de8c4b6c0b648` | 3 | `48a780b6fd037fee2df6bb39743b33348e00acdb42b27b4121244b98bccf72c2` | 2 | **DIFFERS** |
| `deploy/envs/gamification.env` | `c4fd10dc2169a7d9394f4595d0e642687503f4ac8cc325d3c56234e5cd833aaf` | 8 | `935d8c44bf82f4f244a1e84a556209aaafc6048e0d80497226022fa48886cc56` | 7 | **DIFFERS** |
| `deploy/envs/gateway.env` | `0afdd3c649f6893bfd000724294ac02acb191b3f9ccf95050420dc22b85c8b0a` | 2 | `bc9023b2c2a5d041d97de91911940a9444e554373f636423eb5b1353afbaf987` | 2 | **DIFFERS** |
| **`deploy/envs/loop-caps.env`** | `da9f7fc617fc704157e2da649f02f28e82975f583d59d9e6834efd95353030c7` | 68 | **ABSENT** | — | **ONLY VPS** |
| `deploy/envs/speaking.env` | `f312006a6fe3a3488c49569e5674565fa8429f3b2034e8c22c4a8ae1591dd8a3` | 17 | `d6b03b170e26ae6fb917d9b609a861fe898cd943a358b9b3f3d567ee9e2cabc4` | 17 | **DIFFERS** |
| `deploy/envs/vocabulary.env` | `859550b1e77078dd2e8c44e0c79aed26fda6e93095bf340218b87a2d2b39e930` | 11 | `a3d26c40f3381de2a1e965fb17bd4c92d8d539d7af2c963f2d7f9dddbc7f2039` | 11 | **DIFFERS** |
| `deploy/envs/writing.env` | `eb63df23360555108449e0dbc87d15b0dd93abcc28dd7e16fa1461eb12f4002c` | 14 | `a2522de2356b2b4a3f497789f3e203dcd3bea60dd1bac34661166611b2cf8dbe` | 14 | **DIFFERS** |

**`.env.example` / `.env.sample`: none exist on either machine** (`find -maxdepth 4` over both trees → empty). No `.env` at repo root on either side.

Key-count deltas are **+1 on every service file except `speaking.env` (+0)** — consistent with the VPS copies carrying one extra key each (a comment/blank-line difference will also move the SHA even where the key set matches). **`loop-caps.env` is the only VPS-only file**, and its SHA-256 `da9f7fc617fc704157e2da649f02f28e82975f583d59d9e6834efd95353030c7` **exactly matches** the hash the fix-log claims is the unchanged approved production cap profile (`v2rate-root-cause-and-fix-log.md` §5: "`deploy/envs/loop-caps.env` is unchanged (`da9f7fc6…`)"). **This is independent corroboration of the "no cap was raised" claim.**

Because every SHA differs, these files carry **machine-specific secrets** and must **never** be merged across machines. Per contract §4, carry only the **key names and shapes** (see `B_mismatch_map.md` E-01…E-03 and `mismatch_map.json` `environment_profile`); values were never read or emitted.

## 8. Layout of `artifacts/refactor/phase-15/`, `phase-07/`, `phase-08/`, and VPS host dirs

```
artifacts/refactor/phase-15/
  active_generation_job.json          bench-diagnostic-replay/cases/      bench-diagnostic-replay-v3/cases/
  benchmarks/                         bench-pre-v2ratefix-backup/         canary/
  benchmarks-acceptance-v1/cases/     bench-historical-36calls/           deletion-inventory.jsonl
  benchmarks-acceptance-v2/cases/     bench-diagnostic-replay-v2/cases/   dotnet-test-exam.log
  benchmarks-acceptance-v3/                                                   ← camp_G15_022943e248ec lives here
    cases/                                  36 files: case_{01..18}_{v2,legacy}.json
    campaigns/camp_G15_022943e248ec/    ← ALSO here as a sub-tree (identical blobs)
      cases/                                36 files: case_{01..18}_{v2,legacy}.json
      distributions.json                    (36 lines, same hash as benchmarks-acceptance-v3/distributions.json)
      paired-benchmark-report.json          (2383 lines, same hash)
      provider-dispatch.jsonl               (1013 lines, same hash)
      token-accounting.json                 (29 lines, same hash)
    distributions.json
    paired-benchmark-report.json
    provider-dispatch.jsonl
    token-accounting.json
  browser_e2e_report.json             export/                              rollback/
  browser_interaction_result.json     final-acceptance-report.md           screenshots/
  drain/                              gate.json   ← CRITICAL (see B_g15_audit.md)
  evidence-summary.md                 legacy-symbol-map-closed.csv          snapshot-manifest.json
  exports/                            logs/                                 staging-promotion-evidence.json
  git-integrity-report.json           network-events-sanitized.jsonl        student-isolation/
  phase-report.md                     paired-comparisons/                   release-manifest.json
  phase15_live_verification_bundle.json  provider-dispatch.jsonl (top-level) pytest-results.xml
                                                                       pytest-run.log

artifacts/refactor/phase-07/         (medium, see B_product_delta.md for the local-side edits)
artifacts/refactor/phase-08/         (medium)

~/deployments/langfens/              backend/, frontend/, frontend-build/  ← production deployment tree (NOT touched)
~/deployments/docs/                  MIGRATION_RUNBOOK.md, RESOURCE_PLAN.md
~/backups/langfens_source/           attempt-db.dump, attempt-db.sql, auth-db.dump, auth-db.sql, exam-db.dump, exam-db.sql,
                                     langfens-backend.service, langfens-frontend.service, manifest.sha256,
                                     pg_dumpall.sql, redis_dump.rdb, Caddyfile  (kitten_baseline_20261008_024745)
```

## 9. Operations performed

| Op | Where | Mutating? |
|---|---|---|
| `ssh ... 'git rev-parse HEAD && git status ...'` | VPS | read-only |
| `ssh ... 'git stash show -p stash@{0} | wc -l'` | VPS | read-only |
| `ssh ... 'git bundle create /tmp/vps_full.bundle --all'` | VPS | **NON-destructive** — `git bundle create` only packs reachable objects into a file, never modifies the repo |
| `scp vps_full.bundle /tmp/vps_full.bundle` | VPS→local | read-only |
| `git -C local fetch /tmp/vps_full.bundle 'refs/heads/*:refs/vps/heads/*' 'refs/remotes/*:refs/vps/remotes/*' 'refs/stash:refs/vps/stash'` | local main repo | **NON-destructive** — `git fetch` only updates remote-tracking refs, NEVER the working tree |
| `git -C local worktree add -b refactor/recovery-vps-product /home/khoa/Projects/langfens/recovery-wt-B vps/heads/refactor/sync-dotest-admin-renderer` | local | creates a new worktree directory + branch tip; main repo branch tip unchanged |

**Nothing on the VPS was reset, popped, dropped, force-pushed, cleaned, redeployed, restarted, or otherwise mutated.** `stash@{0}` remains untouched. Local main checkout `status --porcelain | wc -l` was **318 before and 318 after** — no working-tree state was added or removed.

## 10. Authoritative hashes (single source of truth for downstream agents)

```
VPS HEAD              = 04fdbd714eb4d9c71b6cf2d0a7985dea83286e4d
VPS origin (base)     = 56d060d45b2f55e6d1af03240e019c60084b1261
VPS stash@{0} commit  = b322fdbda4b5e569c0ca7c2e7db2ea8f2c995a17
VPS stash@{0}^1       = e48025c151aa8df34a7d29ebe34fc4b440be8075  (orphaned rebased lineage)
VPS stash@{0}^2       = 21cb33fbd5746581a4ec362fe797554eb7868964  (untracked)
VPS stash@{0}^3       = 6cea2802467053971e75f308e592ea3f87cfdb71  (untracked root)
Local base (this machine) = 7a4d0e7503710d3b87c95e15831829552ba7be8d
Recovery branch ref   = refs/heads/refactor/recovery-vps-product → 04fdbd7…
Worktree HEAD         = 04fdbd714eb4d9c71b6cf2d0a7985dea83286e4d (clean checkout)
Bundle file           = /tmp/vps_full.bundle  (155,139,937 bytes, 22 refs, sha1)
```