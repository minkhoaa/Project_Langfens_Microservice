# G07–G10 Recovery Verification

**Verdict:** G07–G10 remain **BLOCKED**. The current clean corpus passes the local split/coverage audit, but no eligible clean-holdout G07 or live G10 campaign exists. More importantly, the current `metrics.py` source hash differs from the freeze; the offline allocation builder exits 1 before producing a current request. G08’s paired outputs are 3/3 PASS but its CAS claim is fake-backed; G09’s own PostgreSQL evidence is recorded, but its snapshot is stale. A token-reservation gap remains for prompt tokens and G07 retries.

This audit re-read the worktree and raw checkpoints and recalculated both G07 diagnostics. It did not start a paid campaign. The stored allocation remains `REQUESTED`, `dryRun: true`, `providerCallsStarted: 0`; no authorization files exist. No `root-cause-report.md` was found; root-cause entries are in phase fix logs.

## Gate disposition

| Gate | Current disposition | Evidence / limitation |
|---|---|---|
| **G07** | **BLOCKED** | Corpus integrity passes, but both recorded holdout runs bind the retired corpus. No clean run/authorization exists, and current G07 config hash differs from the freeze. |
| **G08** | **BLOCKED** | G07 is blocked. Paired V2 results are 3/3 PASS, but `DurableStoreFake` is reported as authoritative CAS; no passage-specific production .NET/PostgreSQL accept/resume evidence is present. |
| **G09** | **BLOCKED** | Its candidate and PostgreSQL tests are recorded PASS, but dependencies G07/G08 are blocked and current gate/snapshot evidence does not bind this dirty candidate. |
| **G10** | **BLOCKED** | G07–G09 are blocked; no live solver/adversary campaign or serialized payload trace exists, and current G10 config hash differs from the freeze. |

The Phase 10 gate records `READY_FOR_PHASE_11_ARCHITECTURE_WITH_KNOWN_GAPS`, but its snapshot is stale and does not certify this worktree. Phase 11 architecture may proceed only as independent test/simulation work; production acceptance, V2 promotion and accepted-quality claims remain blocked.

## Verified facts

### Frozen corpus integrity

I recomputed the current source-family and five-word-shingle comparisons using the tokenization in `scripts/refactor/build_clean_g07_holdout.py` (`words`, `shingles`, `jaccard`), rather than accepting the stored report alone:

- Current holdout families: `surface_icing`, `exoplanet_atmospheres`, `subsurface_fracture_hydraulics`, `engram_memory`.
- Development families: `coral_reefs`, `antarctic_ice`, `renewable_energy`, `urban_agri`.
- Retired families: `deep_sea_hydrothermal`, `quantum_computing`, `smart_grids`, `vertical_aeroponics`.
- Family overlap: **0**. Maximum within-clean-holdout Jaccard-5: **0.0**. Maximum clean-holdout-to-available-dev/retired Jaccard-5: **0.0006305170**, below the **0.01** limit.
- Corpus contents: **120 questions**, exactly 10 valid and 10 invalid for each of six types; all 120 have a rationale. **40 fidelity cases**, 10 ambiguity questions, 12 critical canaries, 14 section graphs, 14 paper graphs, and 24 security cases.
- Current question/fidelity hashes: `2d8362ff84853e70e7cb07840e672ec0948aa5381355686cd8ae326a4c4955bc` / `e4ae0987939f02bddadf048786b12451957af24373d107af95784ba7f78d4e31`.

`provenance.json` binds four Europe PMC JATS sources and CC BY 4.0 metadata. It states that one AI annotator manually authored prompts, keys, evidence, validity labels, and rationales; labels were not derived from the evaluator. A separate read-only audit checked source/license/split/leakage, **not labels**. It explicitly discloses no second label reviewer/adjudicator. The annotator and audit reviewer are not named and the annotator model is not recorded, so model-family independence cannot be established from this record.

### Frozen config versus current source

The freeze binds `metrics.py` source SHA-256 `94ef211c…e5f8`; the current file hashes to `a6a55a25…92331`. Recomputed `acceptance_config` values are G07 `d2cae21f…8035b` and G10 `807b6353…f017c`, versus frozen `c73ca54a…4153c3` and `c3e8b73c…36c1080`. The only differing source-code entry is `services/generation-service/app/evaluators/metrics.py`; prompt versions and the 15/60,000/300 caps are unchanged.

The no-dispatch allocation builder confirms the mismatch: `services/generation-service/.venv/bin/python scripts/refactor/build_g07_g10_budget_request.py --output /tmp/g07_g10_audit_budget_request.json` exits **1** with “G07 evaluator/provider/accounting configuration differs from the freeze.” It writes no request. The current G10 runner also explicitly rejects a config hash that differs from the freeze (`run_phase10_blind_benchmark.py:225–226`). Thus the stored request’s hashes are not usable against current code, even after authorization.

### Raw G07 results, recomputed with the current metric engine

The canonical offline recalculator (`METRIC_ENGINE_VERSION=2.3.1`, hash `96d2ba2c214fd39a`) was run against the persisted checkpoints. These are diagnostic measurements only: both campaigns’ manifests bind holdout hash `b2057e9c…b2cc67c`, not the frozen clean hash above; their question gold references use all four retired families.
Historical provider evidence is real-but-incompatible: the G07 manifests report MiniMax / MiniMax-Text-01, and the a1360d raw evaluator messages include Groq HTTP 429/400 responses (not just a fake-provider label). Those runs are still retired-corpus diagnostics and have no current authorization/config/authoritative-grant binding. G10 has no provider or solver/adversary result trace at all.


| Campaign | Questions | Overall blocking recall | Per-type recall (MCQ / Sentence / Short / Summary / TFNG / YNNG) | Ambiguity recall | Semantic false rejection | All valid items rejected incl. operational | Operational failures | Critical-canary aggregate / worst run |
|---|---:|---:|---|---:|---:|---:|---:|---:|
| `camp_g07_20261004_113228_e5b930` | 120 (60 valid, 60 invalid) | 59/60 = **98.33%** | 9/10 = **90%** / 100% / 100% / 100% / 100% / 100% | 10/10 = **100%** | 3/60 = **5%** | 3/60 = **5%** | **0/120** | checkpoint: 48/48, **100% / 100%** |
| `camp_g07_20261004_112937_a1360d` | 120 (60 valid, 60 invalid) | 49/60 = **81.67%** | 1/10 = **10%** / 100% / 100% / 100% / 100% / 8/10 = **80%** | 8/10 = **80%** | 3/60 = **5%** | 20/60 = **33.33%** | **28/120 (23.33%)** | checkpoint: 48/48, **100% / 100%** |

Both are diagnostics on the retired holdout, not acceptance results. For `a1360d`, raw labels divide the 28 operational failures into **17 valid** and **11 invalid** cases; the current v2.3.1 recalculation reports 17 operational rejections of valid items and 20 total valid rejections. The saved v2.3.0 manifest/confusion summary instead records 28 and 31/60 (51.67%).

For `e5b930`, the checkpoint has 120 question, 30 `fid_`, and 48 canary records (198 total). Its adjacent `results.json` lists 42 fidelity results and a canary summary of 12; the confusion artifact counts 48 canary observations. The new freeze requires 40 fidelity cases plus 12 canaries repeated three times (36 observations; 184 child runs). Those mismatches make the old result bundle internally inconsistent even before its retired-corpus binding is considered.

## Verified recovery changes (not gate passes)

1. The frozen clean corpus is source-family-disjoint from the available dev/retired snapshots, meets the stated size/type/fidelity/graph/security counts, and binds the exact question/fidelity hashes above. Label provenance says one unnamed AI annotator, not the evaluator under test.
2. The current metric engine counts operational rejections only for valid-gold rows. The mixed valid/invalid regression added here passes; old raw summaries remain stale and the source-hash change invalidates the freeze.
3. Campaign authorization binding, durable reservations, grant-before-dispatch, UNKNOWN_OUTCOME retention and completed-operation no-replay paths exist in the Python ledger, ProviderGateway and PostgreSQL checkpoint service. The reported real-PostgreSQL budget test covers its existing crash/replay/exhaustion scenarios, but there are no G07/G10 grants and F-09 remains open.
4. G09’s artifacts record real-PostgreSQL candidate-resume tests; its upstream dependencies and snapshot remain blocked. G10’s T10 tests record deterministic payload isolation with fake transport, not a live blind campaign.
## Findings

### F-01 — The G07 “holdout PASS” is not the frozen clean holdout

**Reproduction:**

```sh
sha256sum artifacts/refactor/phase-07/corpus/questions_holdout_corpus.json \
  artifacts/refactor/phase-07/corpus/fidelity_corpus.json
jq '{campaignId,partition,status,corpusHashes,rates,model}' \
  artifacts/refactor/phase-07/campaigns/camp_g07_20261004_113228_e5b930_manifest.json
services/generation-service/.venv/bin/python scripts/refactor/recalculate_phase07_metrics.py \
  --checkpoint artifacts/refactor/phase-07/campaigns/camp_g07_20261004_113228_e5b930_checkpoint.json \
  --output /tmp/camp_g07_20261004_113228_e5b930_audit_metrics.json
```

**Expected:** Campaign input hashes equal the frozen clean question/fidelity hashes, the case families are disjoint from development and retired data, and checkpoint denominators match the authorized request.

**Observed:** The current files hash to `2d8362ff…4955bc` / `e4ae0987…7d4e31`; the campaign manifest binds `b2057e9c…b2cc67c` / `9cd2f9f1…a8cc81`. Campaign time is 11:32–11:38 UTC; the clean freeze is 20:08 UTC that day. Raw `sourceFamily` values are the four retired families. The campaign checkpoint lacks the current authorization/config/corpus bindings and current case counts. The recorded old command was `...run_phase07_semantic_benchmark.py --partition holdout --fresh --concurrency 2` (exit 0), with no `--authorization-file`; current runner code requires an authorized allocation.

**Location/policy:** `artifacts/refactor/phase-07/campaigns/camp_g07_20261004_113228_e5b930_{manifest,checkpoint,results}.json`; `corpus/clean_holdout_freeze.json`; `03-OUTPUT-AND-GATE-CONTRACT.md` §§3–4,7; Phase 07 P07-09 and verification prompt. A passing score from a retired/exposed split cannot establish clean acceptance.

**Smallest remedy:** Keep these runs diagnostic-only. Resolve F-02 and regenerate the freeze/request first; only then explicitly authorize the current binding and start a new G07 campaign. Retain its matching checkpoint, manifest and raw results. Never relabel or reuse the retired checkpoint.

**Exact recheck:** After F-02 succeeds and the new request is authorized, use its listed G07 start command:

```sh
python3 scripts/refactor/run_phase07_semantic_benchmark.py --partition holdout --concurrency 2 \
  --campaign-id camp_g07_clean_holdout_20261004_v1 \
  --authorization-file artifacts/refactor/phase-07/campaigns/camp_g07_clean_holdout_20261004_v1_authorization.json
```

On restart use the request’s listed `--checkpoint-file` resume command; reconcile before retry. No campaign was started in this audit.

### F-02 — Gate snapshots and the frozen config do not bind current code

**Reproduction:**

```sh
git rev-parse HEAD
sha256sum services/generation-service/app/evaluators/metrics.py
services/generation-service/.venv/bin/python scripts/refactor/build_g07_g10_budget_request.py \
  --output /tmp/g07_g10_audit_budget_request.json
```

**Expected:** The exact current source/config/prompt/corpus hashes agree with the freeze and request; the no-dispatch request builder exits 0 and writes a request before any authorization.

**Observed:** HEAD is `f56a0970bbf6190ea7e3af58d2ec8db9e5c9714f`. G07–G09 gates claim `7a4d0e7503710d3b87c95e15831829552ba7be8d`; G10 claims HEAD. The four snapshot manifests are identical, timestamped `2026-10-04T15:24:16Z`, bind retired question/fidelity hashes `b2057e9c…b2cc67c` / `9cd2f9f1…a8cc81`, and record metric engine 2.1.0. They predate the 20:08 clean freeze and omit its freeze/request and the G10 runner.

The freeze binds metric source SHA-256 `94ef211c…e5f8`; current `metrics.py` is `a6a55a25…92331`. Current G07/G10 config hashes recompute to `d2cae21f…8035b` / `807b6353…f017c`, not frozen `c73ca54a…4153c3` / `c3e8b73c…36c1080`. Frozen provider/model pairs are MiniMax-Text-01 and Groq openai/gpt-oss-20b; solver/adversary prompts are v1.0.0 (hashes `231daa92…fa75de` / `31a783f1…7c17a0d`) and those fields match current config. The only config source-file mismatch is `metrics.py`. The allocation builder exits **1** with “G07 evaluator/provider/accounting configuration differs from the freeze” and writes no request; the G10 runner independently rejects its config mismatch. Thus this is both a stale snapshot and a stale freeze/request binding, not just a Git-SHA discrepancy.
The mixed-label regression added by this audit also postdates these manifests. It is test-only and does not change `acceptance_config`, but the final whole-tree snapshot must include it.

**Location/policy:** `artifacts/refactor/phase-07..10/snapshot-manifest.json`, current freeze/request, `acceptance_config` in `scripts/refactor/benchmark_campaign.py`, and G10 guard in `run_phase10_blind_benchmark.py:225–226`; `03-OUTPUT-AND-GATE-CONTRACT.md` §§3–4. A SHA alone does not bind dirty/untracked content.

**Smallest remedy:** Freeze the same clean corpus against the final current source/config, regenerate the allocation request without changing caps, then regenerate snapshots and rerun affected gates on that single candidate. Do not hand-edit hashes or authorize the old request.

**Exact recheck:** After the final code is fixed:

```sh
services/generation-service/.venv/bin/python scripts/refactor/build_clean_g07_holdout.py
services/generation-service/.venv/bin/python scripts/refactor/build_g07_g10_budget_request.py --output /tmp/g07_g10_audit_budget_request.json
services/generation-service/.venv/bin/python scripts/refactor/generate_unified_tree_manifest.py
```

The builder must exit 0; compare both config hashes and corpus hashes to the regenerated freeze before requesting authorization. No campaign was run for this audit.
### F-03 — No authorized clean G07 or live G10 campaign exists

**Reproduction:**

```sh
jq '{status,dryRun,providerCallsStarted,combinedRequestedCaps,gates}' \
  artifacts/refactor/campaign_allocation_request.json
test -f artifacts/refactor/phase-07/campaigns/camp_g07_clean_holdout_20261004_v1_authorization.json; echo "G07 auth exit=$?"
test -f artifacts/refactor/phase-10/campaigns/camp_g10_clean_holdout_20261004_v1_authorization.json; echo "G10 auth exit=$?"
```

**Expected:** G07 and G10 have explicit `AUTHORIZED` records, and their campaign outputs show actual provider/model traces plus the frozen hashes. G10 additionally has blind solver and adversary cases and actual serialized student-visible payload hashes/versions.

**Observed:** The request is `REQUESTED`, `dryRun: true`, and `providerCallsStarted: 0`; both authorization files are absent. Phase 10 has no campaign directory, checkpoint, result, or serialized payload trace. The request lists MiniMax/Groq credential presence only; that is not a network/quota smoke. T10 serialization tests use fake transport. Current G07/G10 config hashes do not match the freeze (F-02), so neither the stored allocation binding nor the G10 runner is current.

**Location/policy:** `campaign_allocation_request.json`; absent campaign/auth files; `scripts/refactor/run_phase10_blind_benchmark.py::projected_trace`; Phase 10 P10-01/02/06/09 and `03-OUTPUT-AND-GATE-CONTRACT.md` §§2–4,7.

**Smallest remedy:** Resolve F-02 first; then request explicit authorization against the regenerated allocation. Run G07, reconcile its current campaign/case/grant checkpoint and upstream G08/G09 gates, then run G10. Preserve sanitized actual solver/adversary payloads, provider/model, prompt/evaluator versions, and case-level operation status. Do not replay completed or unknown calls.

**Exact recheck:** Only after the freeze/request are regenerated and each campaign is separately authorized, use the start commands in that new request. The current G10 command below is not valid against the present config mismatch.

```sh
python3 scripts/refactor/run_phase10_blind_benchmark.py \
  --campaign-id camp_g10_clean_holdout_20261004_v1 \
  --authorization-file artifacts/refactor/phase-10/campaigns/camp_g10_clean_holdout_20261004_v1_authorization.json
```

Use its listed checkpoint resume command only after reconciling persisted campaign/case/provider-operation state. No G10 run was started in this audit.

### F-04 — Allocation arithmetic is bounded but not authorized; no campaign grants are evidenced

**Reproduction:** Read `artifacts/refactor/campaign_allocation_request.json` and `scripts/refactor/build_g07_g10_budget_request.py`; inspect `CampaignBudgetLedger.reserve/recover_after_restart`, `CampaignCheckpointClient.grant_operation_async`, `ProviderGateway.execute`, and `CheckpointService.GrantOperationAsync/ReconcileOperationAsync/RecordUnknownOutcomeAsync`.

**Expected:** The requested campaign caps, child-run caps, provider-attempt bounds, persisted reservations and authoritative PostgreSQL grants agree; retries and unknown outcomes cannot reset accounting or replay completed work.

**Observed:** The request is `REQUESTED`, not authorized. It asks G07 for 127 logical gateway operations across 184 children and G10 for 368 across 184; combined: **495 operations / 22,080,000 tokens / 110,400 seconds**. The per-child hard caps remain **15 / 60,000 / 300**. Token/wall totals are the sum of child maxima; operation caps are the smaller planned totals (not 184×15), so they are stricter campaign call limits. G07 plans up to 381 provider attempts (3 per logical operation); G10 pins solver/adversary calls to one attempt each. The request’s planned provider-token reservations are 105,600 (G07) and 1,507,328 (G10), separately from the broader accounted-token caps; F-09 covers why those per-operation reservations are not a proven worst-case bound.

The current runner code requires explicit authorization and binds the campaign ID, corpus/config hashes, authorization digest and caps. `CampaignBudgetLedger` persists reservations under a file lock/atomic replace; restart promotes orphaned `RESERVED` calls to `UNKNOWN_OUTCOME` without refund; completed/replayed IDs are rejected. `ProviderGateway` grants before dispatch, reconciles successful usage, and records unknown outcomes after exhausted attempts. The .NET checkpoint service atomically enforces campaign/child reservations and retains unknown reservations. The targeted PostgreSQL budget test was reported **1 passed**; it proves that test scenario, not any G07/G10 grant. Old G07 checkpoints contain case results but no current authorization/grant binding, and there is no live G10 checkpoint at all.

The old `a1360d` operational failures include one provider HTTP 429, five HTTP 400 JSON-validation errors, six truncated Groq outputs, four exhausted operations with “Last error: None”, and 12 semantic-inconclusive cases. These do not indicate internal campaign-cap exhaustion; only the 429 is explicit provider rate-limit evidence. No current clean campaign has a persisted authoritative grant to inspect.

**Location/policy:** `build_g07_g10_budget_request.py::_campaign_request`; `CampaignBudgetLedger.reserve/recover_after_restart`; `ProviderGateway.execute`; `CheckpointService.GrantOperationAsync/ReconcileOperationAsync/RecordUnknownOutcomeAsync`; exam-service campaign rules and `03-OUTPUT-AND-GATE-CONTRACT.md` §§2,7.

**Smallest remedy:** Do not change the production 15/60,000/300 run caps. Resolve the stale freeze/request (F-02), close F-09’s reservation gap, then seek explicit authorization and retain each campaign’s grant/reconcile/resume evidence. Never authorize the currently stale request.

**Exact recheck:** Current authorization builder (currently exits 1 until F-02 is fixed):

```sh
services/generation-service/.venv/bin/python scripts/refactor/build_g07_g10_budget_request.py --output /tmp/g07_g10_audit_budget_request.json
```

After adding a PostgreSQL assertion for worst-case retry/prompt-token reservation, rerun the existing budget integration target:

```sh
services/generation-service/.venv/bin/pytest -q services/generation-service/tests/test_t09_real_postgres_durability.py::test_real_postgres_campaign_budget_crash_resume_exhaustion_and_no_replay
```

### F-05 — Stored rejection totals are stale; current v2.3.1 recalculation is correct

**Reproduction:**

```sh
services/generation-service/.venv/bin/python scripts/refactor/recalculate_phase07_metrics.py \
  --checkpoint artifacts/refactor/phase-07/campaigns/camp_g07_20261004_112937_a1360d_checkpoint.json \
  --output /tmp/camp_g07_20261004_112937_a1360d_audit_metrics.json
jq '{rates: .rates, status: .acceptanceStatus}' /tmp/camp_g07_20261004_112937_a1360d_audit_metrics.json
```

**Expected:** Operational failures remain an all-question count; only valid-gold operational rejections contribute to all-valid-item rejection. `totalValidRejected = semantic false positives + valid-gold operational rejections`.

**Observed:** Current `metrics.py` v2.3.1 computes `op_rej_count = valid_total - tn - sem_fp_count`. Recalculation returns 28 operational failures overall, 17 valid / 11 invalid operational cases, 17 operational rejections of valid items, and 20/60 total valid rejected (33.33%). The saved `a1360d` manifest/confusion summary records 28 and 31/60 (51.67%). Those stored artifacts do not record a metric-engine version/hash; the Phase 07 fix/command logs record v2.3.0 before the campaign and no current-version run binding. Treat the 28/31 summary as historical/stale, not current recalculator behavior. The old run still fails recall and operational thresholds.

**Location/policy:** `services/generation-service/app/evaluators/metrics.py::MetricCalculationResult.to_canonical_summary` and `calculate_semantic_benchmark_metrics` (valid-subset formula); exact-denominator requirement in Phase 07. The Phase 07 fix log records v2.3.0 and does not document the current v2.3.1 correction.

**Smallest remedy:** Keep original campaign artifacts as historical raw evidence; consume the v2.3.1 recalculation, add the v2.3.1 change to the fix log, and preserve a mixed valid/invalid operational regression. The regression was added here to `test_metric_separate_reporting_of_semantic_fp_and_total_valid_rejected`; the current test distinguishes 17 valid from 11 invalid errors. Because the source file changed after the freeze, resolve F-02 before any clean live call.

**Exact recheck:** The focused mixed-label test passed **1 test** in 0.61s; the raw recalculation above also completed and wrote the corrected counts:

```sh
services/generation-service/.venv/bin/pytest -q services/generation-service/tests/test_t07_metrics.py::test_metric_separate_reporting_of_semantic_fp_and_total_valid_rejected
services/generation-service/.venv/bin/python scripts/refactor/recalculate_phase07_metrics.py \
  --checkpoint artifacts/refactor/phase-07/campaigns/camp_g07_20261004_112937_a1360d_checkpoint.json \
  --output /tmp/camp_g07_20261004_112937_a1360d_audit_metrics.json
```

### F-06 — G08 marks fake persistence as authoritative CAS; its review denominator is stale

**Reproduction:**

```sh
jq '{eligibleGenerationSuccess,acceptedArtifactWordCountCompliance,authoritativeCASCommit,groundingFidelityPassRate}' artifacts/refactor/phase-08/paired-passage-benchmark-report.json
jq -r '.cases | map(select(.v2.decision == "PASS" and .v2.groundingEvaluation.status == "PASS")) | length' artifacts/refactor/phase-08/paired-passage-benchmark-report.json
```

Inspect `run_phase08_paired_passage_benchmark.py`, `exercise_phase08_service_route.py`, and `test_t08_passage_loop.py::test_t08_06_crash_resumption_and_fencing_invariants`.

**Expected:** `hasAuthoritativeCAS` and route-integration PASS require the authenticated .NET/PostgreSQL checkpoint boundary. Paired-review denominators must agree with raw cases; provider/model evidence must identify the actual V2 provider.

**Observed:** The paired report has **3/3** V2 decisions PASS at 762/751/800 words, all three grounding checks PASS, 3/3 eligible runs and 3/3 in-range passages. Phase 09’s review says 1/3 success and 1/1 in range, which contradicts those raw counts. The paired runner and route exercise use `DurableStoreFake`; the route exercise also uses `FakePassageProvider`. T08-06/T08-08 use those doubles too. The paired runner does initialize the configured provider registry/gateway and records usage/latency, but it omits V2 provider/model per case. All three paired source IDs are from the retired G07 diagnostic set. The report nonetheless sets per-case `hasAuthoritativeCAS: true` and aggregate CAS 1.0; Phase 08’s review repeats that unsupported claim. This supports a narrow paired output observation, not authoritative passage acceptance or traceable V2 provider attribution.

**Location/policy:** `scripts/refactor/run_phase08_paired_passage_benchmark.py` (fake store and CAS label); `scripts/refactor/exercise_phase08_service_route.py`; `services/generation-service/tests/test_t08_passage_loop.py`; paired report and `artifacts/refactor/phase-09/independent-review.md`; P08-08/09 and `03-OUTPUT-AND-GATE-CONTRACT.md` §§4,7.

**Smallest remedy:** Correct the review denominator to 3/3 and label fake-store CAS/route results simulation. Add a passage-specific authenticated .NET/PostgreSQL accept-and-resume test with zero regenerated provider calls, plus per-case provider/model traces. Do not rerun the paid paired benchmark merely to audit its existing three outputs.

**Exact recheck:** The current raw-count and simulated T08 checks are:

```sh
jq -r '.cases | map(select(.v2.decision == "PASS" and .v2.groundingEvaluation.status == "PASS")) | length' artifacts/refactor/phase-08/paired-passage-benchmark-report.json
services/generation-service/.venv/bin/pytest -q services/generation-service/tests/test_t08_passage_loop.py
```

No existing command performs the required real passage checkpoint recheck. After adding `test_t08_06_real_postgres_accepted_passage_resume_no_regeneration` to that test file, run:

```sh
services/generation-service/.venv/bin/pytest -q services/generation-service/tests/test_t08_passage_loop.py::test_t08_06_real_postgres_accepted_passage_resume_no_regeneration
```

### F-07 — Predecessor gates are stale and the referenced Validation Matrix is missing

**Reproduction:** Read `artifacts/refactor/phase-00..06/gate.json`, `artifacts/refactor/verify-after-phase-06/gate.json`, and the G07–G10 gate files; check the cited `docs/refactor/01-validation-matrix.md` path.

**Expected:** Every required predecessor gate and its policy source exists and is compatible with the current candidate. Dependencies are G07←G01/G04/G05/G06, G08←G03–G07, G09←G05–G08, and G10←G07–G09.

**Observed:** G00–G06 gate files all exist and say PASS on SHA `999dc94f…`; they are historical. The later `verify-after-phase-06/gate.json` is BLOCKED on production-cap configuration. Current `Settings` has 15/60,000/300 defaults and campaign scripts assert them, but no fresh G06 gate binds this dirty candidate; the checked deploy env/compose files have no explicit cap overrides. G09’s own gate/test artifacts do record candidate tests (24/24), ten real-PostgreSQL scenarios and three .NET worker crash tests as passing. That evidence is not current-bound: the phase09 gate SHA is `7a4d0e…`, and its snapshot binds `test_t09_real_postgres_durability.py` hash `3804064f…d8b5d6` while the current file is `e9739dae…876b34`. G07/G08/G09 are BLOCKED; G10 is BLOCKED on HEAD `f56a097…`. The referenced Validation Matrix is absent, so its authoritative thresholds cannot be independently checked from this checkout (the phase prompts and gate files do state thresholds).

**Location/policy:** `artifacts/refactor/phase-00..06/gate.json`, `artifacts/refactor/verify-after-phase-06/gate.json`, G07–G10 gates, missing `docs/refactor/01-validation-matrix.md`, and `03-OUTPUT-AND-GATE-CONTRACT.md` §§3–4. Required missing/incompatible evidence blocks PASS.

**Smallest remedy:** Restore the authoritative Matrix; refresh/reconcile G06 cap evidence against current deployment configuration; then rerun G00–G10’s affected checks and gates on one snapshot. Do not inherit G06’s earlier PASS over its later BLOCKED verification. G01/G02 evidence exists and should be re-evaluated, not recreated as missing.

**Exact recheck:**

```sh
for f in docs/refactor/01-validation-matrix.md artifacts/refactor/phase-00/gate.json \
         artifacts/refactor/phase-01/gate.json artifacts/refactor/phase-02/gate.json \
         artifacts/refactor/phase-03/gate.json artifacts/refactor/phase-04/gate.json \
         artifacts/refactor/phase-05/gate.json artifacts/refactor/phase-06/gate.json \
         artifacts/refactor/verify-after-phase-06/gate.json; do
  if test -f "$f"; then printf 'PRESENT %s\n' "$f"; else printf 'MISSING %s\n' "$f"; fi
done
services/generation-service/.venv/bin/python scripts/refactor/generate_phase06_artifacts.py
PYTHONPATH=services/generation-service services/generation-service/.venv/bin/pytest services/generation-service/tests/test_t09_real_postgres_durability.py -v
```

### F-08 — Removing the tautological version-pin test was appropriate; full-suite evidence is historical

**Reproduction:** The removed `test_metric_to_canonical_summary_consistency_between_live_and_offline` compared two calls to the same function and pinned an incidental engine string (2.3.0) while the current engine was 2.3.1.

**Expected:** Tests cover externally meaningful metric behavior/boundaries, not an incidental version string or a tautological same-function comparison.

**Observed:** That test is removed. Its removal does not change production behavior; the separate metric behavior change is addressed in F-05 and changes the frozen source hash in F-02. The current mixed valid/invalid operational regression passes 1/1. The recovery run reported 71 impacted tests and 13 focused metric tests passing, but those aggregate results were not rerun after the current worktree/test update; the phase command log’s 14-test run is against v2.3.0.

**Smallest remedy:** Keep the tautological test removed; retain the current mixed-label regression and refresh command/test evidence against the final candidate snapshot.

**Exact recheck:**

```sh
services/generation-service/.venv/bin/pytest -q \
  services/generation-service/tests/test_t07_evaluators_repairs.py \
  services/generation-service/tests/test_t07_metrics.py \
  services/generation-service/tests/test_t08_passage_loop.py \
  services/generation-service/tests/test_t09_question_candidates.py \
  services/generation-service/tests/test_t10_blind_solvers.py \
  services/generation-service/tests/test_campaign_budget_ledger.py
```

### F-09 — Pre-dispatch token reservations do not cover prompt tokens or G07 retries

**Reproduction:**

```sh
jq '.gates | map_values({requestedCaps,plannedBounds,operationBreakdown})' artifacts/refactor/campaign_allocation_request.json
```

Trace `ProviderGateway.execute` through `OperationGrantRequest.tokenReservation`, `RetryPolicy.max_attempts`, `CampaignBudgetLedger.reserve/reconcile/mark_unknown`, and .NET `CheckpointService.ReconcileOperationAsync`.

**Expected:** Before dispatch, the durable reservation bounds prompt plus completion tokens for every possible provider attempt. An unknown outcome retains that full worst-case reservation; authoritative reconciliation cannot let actual usage exceed the run or campaign hard cap.

**Observed:** `ProviderGateway.execute` grants once with `tokenReservation=request.max_tokens`, then may retry up to three provider attempts for G07 under one 20-second operation deadline. `ProviderRequest.max_tokens` is the completion limit; `UsageReport.total_tokens` includes prompt and completion tokens. The G07 allocation reserves 105,600 tokens for 127 logical operations, but allows up to 381 attempts; G10 reserves 1,507,328 for 368 operations and does not include prompt tokens. On an unknown result, only the single request reservation is retained. On success, PostgreSQL adjusts counters by actual-minus-reserved after dispatch without rejecting an over-cap reconciliation; subsequent grants may be stopped, but the just-completed call is already spent. This is a code-path budget gap; no current campaign grant or measured overspend exists to quantify its impact.

**Location/policy:** `services/generation-service/app/providers/gateway.py::ProviderGateway.execute` (single grant, retry loop); `app/providers/retry.py::RetryPolicy`; `scripts/refactor/build_g07_g10_budget_request.py` token-reservation formulas; `scripts/refactor/benchmark_campaign.py::CampaignBudgetLedger`; `services/exam-service/Features/ReadingPaper/CheckpointService.cs::ReconcileOperationAsync`; P07-08, P10-09 and `03-OUTPUT-AND-GATE-CONTRACT.md` §7.

**Smallest remedy:** Compute a conservative input-token estimate plus completion limit across maximum attempts and persist that bound before dispatch; retain it for UNKNOWN_OUTCOME. Reject or mark non-pass any reconciliation that would exceed the authoritative run/campaign cap. Rebuild the freeze/request after this accounting change and keep 15/60,000/300 run caps unchanged.

**Exact recheck:** Extend the existing real-PostgreSQL budget test with a retry/input-token usage case that proves pre-dispatch rejection at the limit and reservation retention after crash, then run:

```sh
services/generation-service/.venv/bin/pytest -q services/generation-service/tests/test_t09_real_postgres_durability.py::test_real_postgres_campaign_budget_crash_resume_exhaustion_and_no_replay
```

The current test was reported 1 passed for its existing unknown/replay/exhaustion scenarios; it does not yet cover this reservation gap.
## Targeted verification for this report

The offline G07 recalculators ran against `e5b930` and `a1360d`, wrote under `/tmp`, and returned the metrics above. The no-dispatch allocation builder exited **1** on the current config/freeze mismatch and wrote no request. I added the mixed valid/invalid operational case and ran `pytest -q services/generation-service/tests/test_t07_metrics.py::test_metric_separate_reporting_of_semantic_fp_and_total_valid_rejected`: **1 passed** in 0.61s.

The recovery run reported 71 impacted Python tests, 13 metric tests, and one real-PostgreSQL campaign-budget test passing. Those prior results are recorded, not rerun here; the current snapshot does not bind the modified PostgreSQL test file. No full campaign was rerun and no live provider calls were made for this audit.

## Reviewer limitations

The corpus has one unnamed AI label author, no second label reviewer/adjudicator, and a separate provenance/leakage audit that did not inspect labels. The model/tool identity is absent; the near-duplicate result compares only locally available dev/retired passage snapshots, not unavailable complete development articles. Phase 07 names a reviewer role, not an identifiable person; Phase 08 explicitly says no separate model subagent was spawned; Phase 09/10 reviews are sequential “Senior Reviewer” roles. This audit is also a sequential file/code review, not independent human or statistically independent model review.

## Phase 11 readiness

**Architecture/coding:** The gate records Phase 11 architecture readiness with known gaps, but that status is not current-snapshot proof. Proceed only in an explicitly simulated/test path and rebind the candidate before relying on any gate.

**Acceptance/promotion:** **NOT READY.** Keep production defaults and accepted artifacts on the legacy path. Resolve F-01/F-02/F-03/F-04/F-06/F-07/F-09, rebind G07/G10 freeze and snapshots, obtain explicit allocation authorization, prove G08’s real passage checkpoint acceptance, reconfirm G09 on compatible predecessors, then run the authorized G07 and G10 live campaigns. Overall G07–G10 remain BLOCKED until every required dependency and current-snapshot check passes.