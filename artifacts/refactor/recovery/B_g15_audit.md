# B_g15_audit.md — audit of `camp_G15_022943e248ec` and the G15 evidence chain

Everything below is either a **CONFIRMED FACT** (a command and its observed output) or explicitly marked **INCONCLUSIVE** with the exact missing input. No verdict is invented.

---

## (a) Do the referenced commit hashes still exist, and does their tree content match the evidence's claimed state?

### CONFIRMED FACT — the campaign report binds an **orphaned** commit

`artifacts/refactor/phase-15/benchmarks-acceptance-v3/campaigns/camp_G15_022943e248ec/paired-benchmark-report.json`:

```
gitSha = 8deff372ea24a9134c0e97cc77f0d0a42538dd90
engineBinding.worktree = {
  gitHead: 56d060d45b2f55e6d1af03240e019c60084b1261,   <-- the ORIGIN BASE, not HEAD
  dirty: True,
  modifiedPathCount: 259,
  untrackedPathCount: 1179,
  modifiedPaths: [...],
}
engineBinding.configCoversFileCount = 133
engineBinding.configSha256 = 93578853df64f4175495f427f0ef77489dc7c6690ffb7a37b5580eec668eefb9
engineBinding.corpusSha256 = b54beda21c66e2bfa18c108ca91191b37e39743efc1630b8645c22c1b84caf13
```

`8deff37` is the **pre-rebase** version of the v2rate remediation:

```
$ git log -1 --format='%H%n  subject: %s%n  parents: %P%n  date: %ai' 8deff37   [on the VPS]
8deff372ea24a9134c0e97cc77f0d0a42538dd90
  subject: fix(generation-service): phase 15 v2 valid-Draft rate remediation
  parents: 56d060d45b2f55e6d1af03240e019c60084b1261
  date:   2026-10-12 11:20:58 +0000

$ git merge-base --is-ancestor 8deff37... 04fdbd7   →  NOT ancestor (orphaned)
```

**`8deff37` is NOT reachable from `04fdbd7`, and is NOT present in the bundle I fetched** (`git cat-file -t 8deff37…` → `fatal: … could not get object info` locally; the object exists only in the VPS object store). Its reachable counterpart is `e96f71b` ("recover V2 valid-Draft rate and fix benchmark harness integrity").

### CONFIRMED FACT (Main) — the engine tree is byte-identical, so the evidence IS reusable

Main verified against the live checkout:

```
git rev-parse 8deff37:services/generation-service/app  ==  git rev-parse HEAD:services/generation-service/app
                                                   ==  dc86e69ccc63b734d7b7384b684b0005beeb9b4b
```

**This is the key evidence-compatibility conclusion.** The campaign ran against an orphaned commit, but the `app/` engine tree it exercised is **byte-for-byte the same tree that is at VPS HEAD `04fdbd7`**. So the 18/18 result is **reusable as evidence for the current engine**, even though no *reachable* commit can reproduce the run as-recorded.

### CONFIRMED FACT — internal binding inconsistency in the campaign report

The report disagrees with itself:

```
top-level gitSha                          = 8deff372ea24a9134c0e97cc77f0d0a42538dd90
engineBinding.worktree.gitHead            = 56d060d45b2f55e6d1af03240e019c60084b1261
engineBinding.worktree.dirty              = true   (259 modified, 1179 untracked paths)
```

Top-level `gitSha` names `8deff37`; the nested `worktree.gitHead` names the origin base `56d060d`. They cannot both describe the same checkout, and the tree was **dirty at 1438 paths** when the campaign ran. This does not invalidate the run (the engine tree is identical to HEAD and the dispatch ledger is internally consistent), but it means the campaign identity is **not** a clean-tree binding and should not be relied on for byte-exact reproduction.

### CONFIRMED FACT (Main) — canary and rollback evidence predate the remediation

`canary/chaos-matrix-report.json` (14/14), `canary/duplicate-exam-replay.json`, and `rollback/rollback-rehearsal.json` (5/5) are all bound to database **`exam_test_phase14_lineage`** and to the **`56d060d` commit era, dated 2026-10-09/10** — i.e. **before** the v2rate remediation. They therefore **do not revalidate the remediated engine**. Rollback and canary evidence remain **PENDING** for the current candidate.

### CONFIRMED FACT — but the two are **content-identical** where it matters

```
scripts/refactor/run_phase15_benchmarks.py  @8deff37 = 2a8027db214879fb8174315778f44ff347faae4f
                                           @04fdbd7 = 2a8027db214879fb8174315778f44ff347faae4f   IDENTICAL
services/generation-service/app/config.py  @8deff37 = 358967457aba1a8039179001de420850e6b16e20
                                           @04fdbd7 = 358967457aba1a8039179001de420850e6b16e20   IDENTICAL
```

So the 18/18 run executed **byte-identical harness and config code** to what is at `04fdbd7` today. **The orphaned-commit binding does not invalidate the product-code claim**, but it does mean **no reachable commit in this repo can reproduce the run as-recorded** (the binding points at an object absent from the fetched history).

### CONFIRMED FACT — `gate.json` and `release-manifest.json` are internally contradictory at HEAD

| Artifact | @`f255b8b` | @`04fdbd7` (HEAD) |
|---|---|---|
| `gate.json` | NEW file, `evaluatedAt 2026-10-12`, P15-03 = `V2_VALID_DRAFT_18_18=100%_PASS`, `metrics.v2ValidDraftRate = {value:"18/18", passed:true, campaignId:"camp_G15_022943e248ec"}` | **REVERTED**: `evaluatedAt 2026-10-11T06:40:00`, P15-03 = `DRAFT_RATE_BLOCKED_61.1%`, `metrics.v2ValidDraftRate` **block removed**, `blockingReason` cites `camp_G15_c9750f53d6b5` and `11/18 (61.1%)` |
| `release-manifest.json` | ADDED (`gitSha 56d060d…`) | **UNCHANGED** (`187046f4` both sides) |
| `phase-report.md`, `final-acceptance-report.md`, `evidence-summary.md`, `phase15_live_verification_bundle.json`, `snapshot-manifest.json` | **do not exist** at `4477819`/`f255b8b` | **ADDED** by `04fdbd7`, and they narrate the OLD campaign: `final-acceptance-report.md` contains `11/18` and 2× `camp_G15_c9750f53d6b5`; `snapshot-manifest.json` contains **82×** `camp_G15_c9750f53d6b5` |
| `v2rate-root-cause-and-fix-log.md` | present | modified; still ends `## 9. Final campaign results and gate status` / **`Pending.`** and header `Status: IN PROGRESS` |

**Net state at HEAD `04fdbd7`: two artifacts assert 11/18-BLOCKED and two assert 18/18-PASS, over the same gate.** `release-manifest.json` says `metricEngineVersion 2.3.1` / `metricEngineHash a958e94e77341398`, while the uncommitted VPS working-tree matrix says `2.3.1` / `96d2ba2c214fd39a` — different hashes, same version.

### CONFIRMED FACT — tree contents referenced by the release manifest resolve

```
release-manifest.json gitSha 56d060d45b2f55e6d1af03240e019c60084b1261 → exists (origin base)
snapshotManifestSha256 07e60b4c707178d887f9664c42a2c238afa953be9484d60f0dc6b3076a9a9f35
benchmarkReportSha256  601fe8655257b6903f05c45ae3217909b31f90c43d4106f2296ea1db3883f72b
```

`gate.json` carries **different** `snapshotManifestSha256` (`1471711d…`) for the **same** `benchmarkReportSha256` (`601fe865…`) — consistent with `release-manifest.json` being the newer of the two manifests. The `benchmarkReportSha256` was **not** recomputed against `camp_G15_022943e248ec`, whose report is a different file.

---

## (b) PostgreSQL database, server port, database name, and schema/table lineage

> **CORRECTION.** An earlier draft of this section asserted the campaign DB was **`exam-db`** (inferred from `deploy/compose.local.yaml`'s `POSTGRES_DB: exam-db` on host port `5433`). **That was wrong.** The harness that produced this evidence — verified byte-identical to `04fdbd7` (`2a8027db214879fb8174315778f44ff347faae4f`) — explicitly **forbids** `exam-db`. Corrected below.

### CONFIRMED FACT — harness-defined target: `exam_test_phase15` on port 5433

From `scripts/refactor/run_phase15_benchmarks.py` (3168 lines), lines 391–420:

```python
FORBIDDEN_PROD_DBS = {
    "exam-db", "auth-db", "attempt-db", "writing-db", "speaking-db",
    "course-db", "gamification-db", "dictionary-db", "vocabulary-db",
}

def __init__(self):
    self.host     = os.environ.get("PGHOST",    "localhost")     # key: PGHOST
    self.port     = os.environ.get("PGPORT",    "5433")          # key: PGPORT
    self.user     = os.environ.get("PGUSER",    "<role>")        # key: PGUSER     (value redacted)
    self.password = os.environ.get("PGPASSWORD", "<REDACTED>")   # key: PGPASSWORD (value redacted)
    self.requested_target = os.environ.get("PG_BENCHMARK_DB", "exam_test_phase15")
    self.dbname   = self.requested_target

    if self.dbname in FORBIDDEN_PROD_DBS:
        raise RuntimeError(
            f"Target database '{self.dbname}' is a production database name and is strictly forbidden "
            f"for benchmark persistence. Must use an isolated staging/test target (e.g. 'exam_test_phase15')."
        )

    self.db_identity = {
        "target": "ISOLATED_STAGING_TEST",
        "requestedDatabase": self.requested_target,
        "resolvedDatabase": self.dbname,
        "host": self.host,
        "port": int(self.port) if str(self.port).isdigit() else 5433,
        "user": self.user,
        "isIsolatedStagingTarget": True,
    }
```

The shared server is the **exam-db container's Postgres on host port 5433** (container 5432), but the **database is the isolated staging target `exam_test_phase15`**, created on demand by `_ensure_database_exists()`. The harness also re-points exam-service at it when it (re)starts it in isolation (line 750), setting the connection-string key `ConnectionStrings__exam-db` to a **key/value DSN of shape**:

```
Host=<host>;Port=<port>;Database=<dbname>;Username=<role>;Password=<REDACTED>
```

with `Host=localhost`, `Port=5433`, `Database=exam_test_phase15`.

> Credential **values** are redacted everywhere in this report. Only key names and value *shapes* are shown. No `.env` value was read or emitted; the harness defaults were visible in source but are withheld here.

### CONFIRMED FACT — schema / table lineage

The harness creates and owns one table and writes two more:

| Table | Line | Role |
|---|---|---|
| **`phase15_persisted_exams`** | 455 (`CREATE TABLE IF NOT EXISTS`), 481 (`INSERT`), 504 (`SELECT engine, count(*) … GROUP BY engine`) | Created by the harness. Columns: `exam_id VARCHAR(128) PK`, `engine VARCHAR(64) NOT NULL`, `run_id VARCHAR(128) NOT NULL`, `is_primary BOOLEAN`, `sections_count INT`, `total_questions`, `payload_json`. **Shadow Legacy runs are strictly excluded** (header lines 17–18; line 1864: "Shadow legacy run strictly does NOT insert into `phase15_persisted_exams`"). |
| **`reading_paper_runs`** | 526, 539, 566, 611, 640, 687 | Pre-existing exam-service table. Harness `UPDATE`s `SourceRevisionsJson`, `EngineVersion`, `Status='FAILED'`, `Status='RUNNING'` + `LeaseOwner`/`LeaseUntil`; `SELECT`s `RunId, JobId, Epoch, Status`. **This is the table the RC/§3.6 splice hazard is about.** |
| **`reading_paper_jobs`** | 525, 540, 553, 567, 688, 699 | Pre-existing exam-service table. Harness `UPDATE`s `SourcesJson`, `SectionsJson`, `CompletedSections=3`, `Status`, `Error`, lease columns. |
| **`exams`** | 699 | Joined read-only (`JOIN exams e ON e."Id" = j."ExamId"`) to confirm the job's active run. |

§3.6 of the fix log states `reading_paper_runs` keys on `(BenchmarkCampaignId, BenchmarkCaseId)` with a **UNIQUE index** — that index is exactly what made `--no-resume` / campaign-id collision a splice hazard.

### CONFIRMED FACT — live DB state (Main, verified against the running VPS database)

Main audited the live DB directly. **Container `exam-database`, host port 5433, database `exam_test_phase15`** — matching the harness default exactly. Reported `persistenceAudit`:

```
target                 ISOLATED_STAGING_TEST
resolvedDatabase       exam_test_phase15
host:port              localhost:5433
user                   exam
v2AuthoritativePersistedCount   18
legacyShadowPersistedCount      0
postgresConfirmedCounts  {v2: 18, legacy: 0}
shadowOverwrotePrimary          false
```

This **corroborates** the harness's own invariant (legacy shadow runs never insert) with independent DB counts.

### OBSERVATION (not a verdict) — cross-campaign row-count anomaly

Campaign **`camp_G15_855da04e41ba`** has **48 rows** in this DB versus the **36** expected for an 18-paper paired campaign. Recorded as an observation only. It does **not** affect `camp_G15_022943e248ec` (which has exactly 36). Investigate only if cheap; **do not block the merge on it**.

### CONFIGURED TARGET vs UNVERIFIED LIVE ROWS — explicit distinction

| Claim | Status |
|---|---|
| Harness is *configured* to target `exam_test_phase15` @ `localhost:5433` as user `exam`, refuses production DB names | **CONFIRMED** (source, lines 391–420) |
| `exam_test_phase15` is reachable at `localhost:5433` on the VPS; `5433` is listening | **CONFIRMED** (Main's live query; my read-only `ss -lntp` also shows `0.0.0.0:5433`) |
| The campaign's 36 rows exist with matching run ids, and the 8 FAILED rows are retained | **CONFIRMED by Main's live SQL** — 28 COMPLETED / 8 FAILED / 0 incomplete, matching the report's `failedRunsCount=8, incompleteRunsCount=0`; the 8 retained failures are `case_legacy_01_s101, _02_s202, _07_s101, _08_s202, _09_s303, _13_s101, _15_s303, _16_s101` |
| My own independent `psql -l` against 5433 | **returned no rows** — I lacked working credentials in my SSH context and did **not** attempt to extract or use any password. My DB-level contribution is therefore nil; the DB evidence in this report is Main's, attributed as such. |
| I started / restarted / migrated any database | **NO** — no DB process was touched (contract: no mutation of the running stack) |

---

## (c) REPLAY-ROW SPLICING — explicit check

The specific risk, per the fix log §3.6, was that the acceptance campaign would "silently **splice the 7-case diagnostic replay's successful rows** into its own results for cases 4, 8, 9, 13, 14, 16 and 18 — presenting replayed work as a fresh 18-case run." The fix (`--campaign-tag`, `resume` gating `should_resume`) was applied **before** this campaign ran.

### Check C1 — exact-content duplication within the campaign (the "copied rows" test)

```
$ python3 - <<'PY'   # 36 case files, canonical JSON, sorted keys
... v2 exact-content dupes: 0 (zero = no content copy)
... legacy exact-content dupes: 0 (zero = no content copy)
PY
```
**CONFIRMED: 0 duplicated case files in either engine leg.** No row was a byte-copy of another.

### Check C2 — identity uniqueness (runId / jobId / persistedExamId)

```
v2 runIds: 18 total, 18 unique
v2 jobIds: 18 total, 18 unique
legacy runIds: 18 total, 18 unique
legacy jobIds: 18 total, 18 unique
v2 vs legacy jobId overlap: 0
v2 vs legacy runId overlap: 0
persistedExamId non-null count: 18 (all 18 distinct UUIDs; isPrimaryPersisted true)
v2 status: Counter({'ACCEPTED': 18})     v2 FAILED count: 0
```
**CONFIRMED: 36 genuinely distinct runs.**

### Check C3 — input fingerprints: are the 18 cases actually 18 different inputs?

```
Source triples: 18 total, 6 unique
Triple distribution: Counter({
  (PMC13560651, PMC13407692, PMC13517498): 3,
  (PMC13407692, PMC13517498, PMC13621526): 3,
  (PMC13517498, PMC13621526, PMC13503497): 3,
  (PMC13621526, PMC13503497, PMC13583341): 3,
  (PMC13503497, PMC13583341, PMC13560651): 3,
  (PMC13583341, PMC13560651, PMC13407692): 3})
v2 seeds: Counter({101: 6, 202: 6, 303: 6})
Distinct (caseIndex, seed, sourceTriple) combos in v2: 18 of 18
```
**CONFIRMED: the design is 6 source triples × 3 seeds = 18 cases.** Every case is a unique `(caseIndex, seed, sourceTriple)` tuple, and the source triples form a rotating 6-window over 6 distinct PMC articles. **This is a factorial design, not a copied set** — but note the **effective independent-input count is 6 (source triples), not 18**; seeds vary sampling, not source material. `[INFERENCE]` the 18/18 rate is therefore a 6-source-triple result reported at 18-sample granularity. `distributions.json` records this honestly: `"totalPairedPapers": 18, "distinctSourceTriples": 6`.

### Check C4 — cross-campaign overlap (the actual splice detector)

```
$ python3 - <<'PY'   # 10 campaign dirs, sets of runId/jobId per campaign
camp_G15_022943e248ec: runs=36 jobs=36     <-- the 18/18 acceptance campaign
camp_G15_d2c833c1c04f: runs=36 jobs=36
camp_G15_dde0f9bd38d4: runs=36 jobs=36
camp_G15_c9750f53d6b5: runs=36 jobs=36
camp_G15_eef49d5aff21: runs=14 jobs=14     (diagnostic replay, 7 cases)
camp_G15_ea082a506cd4: runs=14 jobs=14
camp_G15_72751c8f84be: runs=19 jobs=19
camp_G15_0eec2904aed5: runs=10 jobs=10
camp_G15_988f6f521bdb: runs=2  jobs=2
camp_G15_52e8bce8de13: runs=1  jobs=1
runId overlap pairs: 1  [('G15_72751c8f84be', 'G15_c9750f53d6b5', 18)]
jobId overlap pairs: 1  [('G15_72751c8f84be', 'G15_c9750f53d6b5', 18)]
*** SPLATE RISK lines printed: NONE
PY
```
**CONFIRMED: `camp_G15_022943e248ec` has ZERO runId and ZERO jobId overlap with ANY other campaign** (including the 7-case diagnostic replay `camp_G15_eef49d5aff21` and the canonical 11/18 baseline `camp_G15_c9750f53d6b5`). This is exactly what the fix log claims ("verified by SQL self-join across campaigns: 0", and "zero run-ID overlap with **both** prior campaigns").

The **one** overlap pair found — `camp_G15_72751c8f84be` × `camp_G15_c9750f53d6b5` sharing **18** runIds/jobs — is **not** the acceptance campaign. `72751c8f84be` lives in `artifacts/refactor/phase-15/benchmarks-diagnostic-replay/campaigns/`, i.e. it is a **replay of the canonical baseline**, which is what a diagnostic replay *is* supposed to be. It does not touch `022943e248ec`.

### Check C5 — dispatch-ledger forensics (the strongest independent signal)

```
$ wc -l provider-dispatch.jsonl   →  1013 events
runs in ledger: 36   total events: 1013
time window: 2026-10-12T10:18:21.461Z .. 2026-10-12T11:49:02.957Z   (≈90.7 min wall clock)

per-run windows (first 6 / last 4 shown):
  bench_519096072db91e25dfd767ba0da251e1   12 calls  10:18:21 → 10:24:19   span 358.3 s
  bench_0876da8f84851d710cc707e5251f8c47   30 calls  10:18:22 → 10:24:46   span 383.9 s
  bench_268b2599347d46c47cea98dd3b126f65   12 calls  10:18:25 → 10:25:04   span 398.4 s
  bench_bc7299e6f5497495506bce5f5cd2e7b6   48 calls  10:18:26 → 10:28:25   span 598.3 s
  bench_87a33656f035b11205468c1a37a97ab8   20 calls  10:25:23 → 10:31:03   span 340.4 s
  bench_4e84b46b47f9cc39ee8683ec747e495c   10 calls  10:25:24 → 10:31:06   span 342.4 s
  ...
  bench_6a6edb774d33c9d14621b67827ef3e82   10 calls  11:33:26 → 11:39:15   span 349.3 s
  bench_98c68fc411bfbb3c8c6142df40dd9d08   55 calls  11:33:33 → 11:44:05   span 632.2 s
  bench_a0b9c69c3646d4fad25bf0eaeb2a43ac   53 calls  11:38:33 → 11:49:02   span 629.1 s
  bench_0d879231771e3a1d1ab674434e7f506c   11 calls  11:38:36 → 11:44:49   span 373.0 s

duplicate requestSha256 within same run : total requests=1013  duplicates=0
duplicate responseSha256 across ALL runs: responses=1013  unique=1013  dup=0
```

Every ledger field is present on all 1013 events: `timestamp, operationId, runId, provider, model, tokensUsed, latencyMs, requestSha256, responseSha256`.

### Check C6 — live-DB SQL self-join (Main, verified against the running database)

Main ran a SQL self-join across **all** prior campaigns in `exam_test_phase15`:

```
run-ID overlap with any other campaign:  COUNT(*) = 0
status distribution:  28 COMPLETED / 8 FAILED / 0 incomplete
                       (matches the report's failedRunsCount=8, incompleteRunsCount=0)
```

All **8** FAILED rows are **retained in Postgres**, not overwritten by a retry:
`case_legacy_01_s101, case_legacy_02_s202, case_legacy_07_s101, case_legacy_08_s202, case_legacy_09_s303, case_legacy_13_s101, case_legacy_15_s303, case_legacy_16_s101`.
All 8 failures are in the **LEGACY arm**; the V2 arm is **18/18**.

This is the decisive check: it is performed **against the database the campaign actually wrote to**, not against the JSON files. It confirms the `--no-resume` / `--campaign-tag` anti-splice fix documented in the fix log **held in practice**, and it independently validates the report's own `failedRunsCount` / `incompleteRunsCount` fields.

### VERDICT on (c): **NO replay-row splicing. This check is PASS.**

Six independent signals agree, spanning filesystem **and** database:

| # | Check | Scope | Result |
|---|---|---|---|
| C1 | Byte-duplicate case files | 36 files | 0 duplicates |
| C2 | runId / jobId / persistedExamId uniqueness | 36 runs | 36/36 unique each; 0 cross-leg overlap |
| C3 | Input fingerprints | 18 V2 cases | 18/18 unique `(caseIndex, seed, sourceTriple)`; factorial 6 triples × 3 seeds |
| C4 | Cross-campaign overlap (filesystem) | 10 campaigns | **0** overlap for `022943e248ec` against any other |
| C5 | Dispatch-ledger forensics | 1013 events / 36 runs | 0 duplicate `requestSha256` in-run; 0 duplicate `responseSha256` globally; ~91 min spread |
| **C6** | **Live-DB SQL self-join (Main)** | **`exam_test_phase15`** | **`COUNT(*) = 0` overlap; 8 FAILED rows retained** |

A copy or splice would necessarily reuse either a `runId`, a `responseSha256`, or a durable row — all three are clean, the last one at the database layer itself.

**Remaining caveat (do not drop):** the 8 retained legacy failures being present in Postgres is what proves *no row was silently replaced*. It does **not** by itself prove the 18 V2 rows are independent of each other; that rests on C1–C5 plus C6's zero-overlap result.

---

## (d) Which of the 18 evidence items are reusable as-is, and which are invalidated

The "18 items" = the 18 V2 cases (each with a `_v2` and a `_legacy` file → 36 files, 18 paired papers). Reuse is judged against three questions: (i) is the file intact and internally consistent, (ii) does its binding (commit/config/engine hash) still resolve, (iii) is the claim it supports contradicted by another artifact at HEAD.

### Reusable as-is (structural integrity intact, bindings resolve)

| Item | File | Evidence |
|---|---|---|
| `case_01_v2` … `case_18_v2` (all 18) | `benchmarks-acceptance-v3/cases/case_NN_v2.json` | 0 content dupes; unique runId/jobId/examId; every one has dispatch-ledger coverage; `provider-dispatch.jsonl` corroborates each `runId` |
| `case_01_legacy` … `case_18_legacy` (all 18) | same dir | same; legacy leg's 8 FAILED rows are recorded, not hidden — `status`, `failureReason` (HTTP 422 etc.), `evaluatorIssues` are populated, contradicting the old hardcoded-literals defect |
| `distributions.json` | `benchmarks-acceptance-v3/` | recomputed from the 36 case files independently: v2Latency min 385.59 / p50 421.978 / p95 556.578 / max 560.992 **matches** the per-case latency values I read (min 385.6, max 561.0, 18 unique values); ratios 0.709 / 0.235 match the stated gate values |
| `provider-dispatch.jsonl` | `campaigns/camp_G15_022943e248ec/` | 1013 well-formed events, 36 runs, no fingerprint collisions |
| `token-accounting.json` | both paths | 29 lines, identical blob at both paths |

**Reusability qualification for all 18:** the *artifact* is reusable as evidence that a run produced these numbers. The *claim that these numbers prove a release-ready engine at HEAD* is **not** reusable — see invalidated list.

### Invalidated / contradicted at HEAD — do NOT reuse as a gate verdict

| # | Item | Why invalidated | Evidence |
|---|---|---|---|
| 1 | **`gate.json` at HEAD as the G15 verdict** | `04fdbd7` reverted it to `11/18` BLOCKED while `release-manifest.json` (unchanged, same commit) says 18/18 PASS. The gate file at HEAD **contradicts itself against its sibling manifest**. | `git rev-parse f255b8b:gate.json = 5729170e` vs `04fdbd7:gate.json = bc91fb74`; `release-manifest.json` `187046f4` at both |
| 2 | **`final-acceptance-report.md` as the acceptance verdict** | Narrates only `camp_G15_c9750f53d6b5` (11/18, BLOCKED) and predates the acceptance campaign; it is the *pre-remediation* report. | contains `11/18` ×1 and `camp_G15_c9750f53d6b5` ×2; absent at `f255b8b` |
| 3 | **`phase-report.md` as the acceptance verdict** | Same: added at `04fdbd7`, P15-03 = `BLOCKED`, `Git Commit SHA: 56d060d…`, `Gate G15 Verdict: BLOCKED` | grep of `@04fdbd7:phase-report.md` |
| 4 | **`snapshot-manifest.json` as a snapshot of this campaign** | References `camp_G15_c9750f53d6b5` **82 times**, 0 references to `camp_G15_022943e248ec` | grep count |
| 5 | **`v2rate-root-cause-and-fix-log.md` §9 "Final campaign results"** | Literally `Pending.` — §9 was never filled in. Header still `Status: IN PROGRESS`. RC-16/RC-17 are documented but their *campaign confirmation* is absent. | tail of `@04fdbd7:v2rate-root-cause-and-fix-log.md` |
| 6 | **The `gitSha` binding for reproducing the run** | Binds `8deff37…`, which is **orphaned** (not an ancestor of `04fdbd7`) and **absent from the fetched bundle**. Nothing reachable reproduces the run as recorded. Harness+config blobs are byte-identical, so product-code equivalence holds, but *reproducibility from a reachable commit does not*. | `merge-base --is-ancestor` → no; local `cat-file -t` → no such object |
| 7 | **`benchmarkReportSha256 = 601fe865…`** | Identical in `gate.json` (both revisions) and `release-manifest.json`, i.e. it was **not recomputed** for the new campaign; the two docs also disagree on `snapshotManifestSha256` (`1471711d…` vs `07e60b4c…`). | grep of both files |
| 8 | **`release-manifest.json` `metricEngineHash a958e94e77341398`** | The uncommitted VPS working-tree phase-07 matrix reports `2.3.1` / `96d2ba2c214fd39a`. Same version, different hash ⇒ the matrix was regenerated after the manifest freeze. | VPS working-tree diff §7.2 |
| 9 | **Test-suite pass/fail counts** | `04fdbd7` commit body: **72 failed / 630 passed**. `v2rate` §5: **6 failed / 701 passed / 42 skipped**. Mutually inconsistent; neither was re-run by me. | commit body vs fix-log §5 table |

### INCONCLUSIVE — cannot be adjudicated from the repo

| Question | Missing input |
|---|---|
| Do the 36 `reading_paper_runs` rows exist in `exam-db:5433` with matching run ids / timestamps? | Working read credentials for port 5433 (psql returned no rows); I did not start or migrate any DB |
| Do `cases/attempts/` archives exist proving no failed row was overwritten by a retry? | No `cases/attempts/` directory present in the committed tree |
| Was the campaign executed with the *rotated* MiniMax credential (RC-9) or the exhausted one? | `provider_binding_snapshot()` excludes API keys by design, so the ledger cannot answer this |
| Are `T15-06` (production canary) / `T15-07` (rollback) now executed? | `rollback/{container-rollback-report.json,rollback-rehearsal.json}` and `staging-promotion-evidence.json` were added by `04fdbd7` but `gate.json` at HEAD still lists both BLOCKED; I did not read their contents as part of the 18/18 audit |

---

## Bottom line

- **`camp_G15_022943e248ec` exists with a concrete, complete snapshot record.** 36 case files, 4 aggregate reports, a 1013-event dispatch ledger, at two blob-identical paths.
- **Replay-row splicing: PASS, no splicing.** Five independent filesystem checks, including 0 global `responseSha256` duplication across 1013 provider responses and 0 runId/jobId overlap with any of the other 9 campaigns.
- **The 18/18 gate verdict is nevertheless NOT reusable at HEAD**, because `04fdbd7` reverted `gate.json` to the 11/18 BLOCKED text while leaving `release-manifest.json` at 18/18 PASS, and because the five narrative docs added by that same commit describe only the older `camp_G15_c9750f53d6b5` campaign.
- **DB-level confirmation is INCONCLUSIVE** (no credentials; no DB was started or mutated).