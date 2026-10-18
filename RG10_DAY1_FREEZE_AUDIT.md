# RG10 Day 1: Software Freeze Audit Report

**Date of Audit:** 2026-10-18  
**Audit Target:** Software Freeze, Version Pinning, Prompt Freeze, Evaluator Semantics, and Regression Verification  
**Repository:** `minkhoaa/Project_Langfens_Microservice`  
**Branch:** `autonomous-generation`  
**Governing Standard:** `generation_baseline/research/RQ2_PROTOCOL.md`, `DATA_GOVERNANCE.md`, and `ANALYSIS_PLAN.md`  
**Audit Mode:** Offline / Strictly Dry-Run (No MiniMax provider dispatches executed)  

---

## 1. Executive Summary

| Verification Pillar | Invariant / Requirement | Verified Finding / Evidence | Status |
|---|---|---|---|
| **Git Tree & Head SHA** | Verified local and origin SHAs | Local HEAD: `69007c8d0860eba40b0274837699f89970a46303`<br>Origin HEAD: `69007c8d0860eba40b0274837699f89970a46303`<br>Tree clean, 0 uncommitted changes. | **VERIFIED** |
| **Evaluator Version Isolation** | Evaluator v2.7 active, historical baselines immutable | `NeutralEvaluatorV2_7` in `independent.py`, rubric `rubric-qgeval-v2.7`. Semver tuple `(2, 7)`. Isolated from v2.6/v2.5. | **VERIFIED** |
| **Prompt Template Freeze** | Authorized A/B/C prompt digests | Arm A: `ca8d0c878f78148cb6db5ac6efa0bb17b843c37fafd83834b51eeccf08a3751c`<br>Arm B: `0c2d0183148695703ee17f1eee1192b63999b6177a9b1a25bbf23a93135c8e25`<br>Arm C: `0861af20f3262f6ec20ac1ade9f5f818a94914f99ae0e61509dbd5f7ac73b0eb` | **VERIFIED** |
| **Foundation Model Identity** | Pinned foundation model ID | `minimax/MiniMax-Text-01` pinned across manifests and freeze managers. | **VERIFIED** |
| **Roster & Denominators** | 168 assignments (56 tasks × 3 arms) | Total tasks: 56 (28 Reading, 28 Grammar).<br>Assignments: 168 (84 Reading, 84 Grammar; 56 per arm A/B/C).<br>Fingerprint mismatches: 0. Separate Holdout N=30. | **VERIFIED** |
| **Raw Response Preservation** | Telemetry and integrity of raw responses | 677/677 valid records verified across 9 execution directories. Missing: 0, Unverifiable: 0, Corrupt: 0. Telemetry fields intact. | **VERIFIED** |
| **Failure & Attempt Accounting** | Fail-closed on UNCERTAIN, 0 silent drops | 262 ledger attempts reconciled: 168 terminal, 94 non-terminal, 0 unresolved, 0 silent drops. | **VERIFIED** |
| **Offline RG10 Regressions** | Full suite execution | 24 RG10 test files executed: 353 passed in 6.07 seconds. | **VERIFIED** |

### Software Readiness Verdict
$$\mathbf{SOFTWARE\_READY: PASS}$$

*Note: While the software engine, auditor, and evaluation test harness are fully functional and pass all freeze invariants (`SOFTWARE_READY: PASS`), the overall research campaign remains on **HOLD** due to external provider quota exhaustion (HTTP 429), unsealed holdout specification, uncontracted human review panel, and the critical dataset eligibility defects documented in Day 2.*

---

## 2. Git State & Branch Identity

- **Local Commit SHA:** `69007c8d0860eba40b0274837699f89970a46303`
- **Origin Tracking SHA:** `origin/autonomous-generation` -> `69007c8d0860eba40b0274837699f89970a46303`
- **Working Tree Status:** Clean (no untracked modifications to core software or baseline fixtures).
- **Recent Audit Commits:**
  - `69007c8`: fix(auditor): resolve readiness status schema mismatch, silent-drop reconciliation, and prompt freeze hash validation
  - `82b2d87`: docs(readiness): record final readiness report generated from d491f2e
  - `d491f2e`: docs(readiness): publish final readiness report for verified auditor commit ef98b70
  - `ef98b70`: fix(auditor): eliminate unsupported readiness assertions and enforce full verification
  - `7969076`: fix(governance): unassert synthetic human/holdout ratings and separate source from packaging provenance

---

## 3. Candidate Evaluator v2.7 & Version Isolation

The candidate evaluator for the benchmark is `NeutralEvaluatorV2_7` paired with `rubric-qgeval-v2.7`.
- **Implementation File:** `services/generation-service/app/evaluators/independent.py`
- **Class:** `NeutralEvaluatorV2_7` (inherits from `NeutralEvaluatorV2_6` and `CandidateEvaluatorBase`)
- **Evaluator Version String:** `"neutral-eval-v2.7"`
- **Rubric Profile:** `RubricProfile(rubric_version="rubric-qgeval-v2.7")`
- **Semantic Version Tuple:** `(2, 7)` validated by `parse_evaluator_version_tuple("neutral-eval-v2.7")`
- **Version Isolation Invariants Verified:**
  1. `test_rg10_evaluator_version_isolation.py` confirms that `NeutralEvaluatorV2_7` is strictly distinct from historical evaluators `neutral-eval-v2.6`, `v2.5`, `v2.3`, `v2.2`.
  2. Historical DEV rescore baselines in `generation_baseline/verification/` (`RG10_DEV_V2_4_EXPLICIT_RESCORE.json`, `RG10_DEV_V2_6_EXPLICIT_RESCORE.json`) remain immutable.
  3. Evaluator v2.7 addresses the 25 diagnostic DEV acceptance cases (`test_rg10_v2_7_remediation.py`), eliminating false rejections caused by naive verb-inflection regexes (e.g., base verbs ending in `-ss` like `bypass`, `cross`, `discuss`) and restoring proper handling of inconclusive reading premises.

---

## 4. Frozen A/B/C Prompt Digests & Foundation Model Identity

The experimental arms A, B, and C evaluate prompt configurations against the pinned foundation model:
- **Foundation Model:** `minimax/MiniMax-Text-01`
- **Authoritative Freeze Source:** `ProviderFreezeManager` + `CampaignManifestBuilder`
- **Prompt Specifications:**
  - **Arm A (Direct Baseline):** Prompt Version `v2.1-baseline`
    - Template SHA-256: `ca8d0c878f78148cb6db5ac6efa0bb17b843c37fafd83834b51eeccf08a3751c`
  - **Arm B (Grounded Formulation):** Prompt Version `v2.2-grounded`
    - Template SHA-256: `0c2d0183148695703ee17f1eee1192b63999b6177a9b1a25bbf23a93135c8e25`
  - **Arm C (Adversarial Self-Correction / Repair):** Prompt Version `v3.0-adversarial`
    - Template SHA-256: `0861af20f3262f6ec20ac1ade9f5f818a94914f99ae0e61509dbd5f7ac73b0eb`
- **Verification Invariant:** Commit `69007c8` strictly enforces prompt hash checking in `CampaignReadinessAuditor`, rejecting any missing or altered digests.

---

## 5. Roster, Denominators, and Fingerprints

The benchmark roster is fully frozen in `generation_baseline/.execution/RG10/campaign_ledger.json`:
- **Task Count:** 56 distinct tasks
  - 28 Reading tasks (`final-reading-001` through `final-reading-028`)
  - 28 Grammar tasks (`final-grammar-001` through `final-grammar-028`)
- **Experimental Assignment Denominators:** $N = 168$
  - Reading assignments: 84 (28 per arm)
  - Grammar assignments: 84 (28 per arm)
  - Arm A assignments: 56
  - Arm B assignments: 56
  - Arm C assignments: 56
- **Canonical Fingerprint Invariant:**
  - Every assignment's task content SHA-256 was matched against the ledger's `fixture_hashes`.
  - Mismatches: `0`
  - Assignment discrepancies: `0`
- **Holdout Separation:**
  - Separate Judge Holdout denominator: $N = 30$ (18 Reading, 12 Grammar).
  - Benchmark vs Holdout family collisions: `0`.

---

## 6. Raw Response Preservation & Attempt-by-Attempt Reconciliation

- **Raw Responses on Disk:** 677 records across 9 execution directories:
  1. `generation_baseline/.execution/RG10/raw_responses`
  2. `generation_baseline/.execution/RG10/smoke_test/raw_responses`
  3. `generation_baseline/.execution/RG10_DEV_FRESH_V3/raw_responses`
  4. `generation_baseline/.execution/RG10_DEV_GRAMMAR_FIX_V5/raw_responses`
  5. `generation_baseline/.execution/RG10_DEV_HARDENING/raw_responses`
  6. `generation_baseline/.execution/RG10_DEV_HARDENING_V2/raw_responses`
  7. `generation_baseline/.execution/RG10_DEV_UNSEEN_PILOT_V4/raw_responses`
  8. `generation_baseline/.execution/RG10_REMEDIATION/raw_responses`
  9. `generation_baseline/.execution/RG11_DEV_V22/raw_responses`
- **Integrity Check:**
  - Valid parseable records: 677 / 677 (100.0%)
  - Missing, unverifiable, or corrupt records: 0
  - Required telemetry present in every record: `latency_ms`, `prompt_sha256`, `provider_request_id`, `raw_text_sha256`, `tokens`, `tokens_prompt_completion_total`.
- **Attempt-by-Attempt Reconciliation:**
  - Total recorded ledger attempts: 262
  - Reconciled terminal attempts: 168
  - Reconciled non-terminal attempts: 94
  - Ledger outputs: 260
  - Ledger evaluations: 166
  - Unresolved attempts: 0
  - Silent drops: 0

---

## 7. Offline Regression Suite Execution Results

All 24 test suites under `services/generation-service/tests/test_rg10_*.py` were executed offline using `pytest`:

```text
============================== test session starts ==============================
platform linux -- Python 3.10.12, pytest-9.1.1, pluggy-1.6.0
rootdir: /home/code/workspaces/langfens/Project_Langfens_Microservice/services/generation-service
configfile: pytest.ini
plugins: asyncio-1.4.0, anyio-4.15.1
collected 353 items

tests/test_rg10_accounting_integrity.py ..................               [  5%]
tests/test_rg10_arm_c_repair_loop.py ........                            [  7%]
tests/test_rg10_blinded_semantic_judge.py .........                      [  9%]
tests/test_rg10_campaign_readiness_integrity.py .......................  [ 16%]
tests/test_rg10_corpus_disjointness_and_readiness.py ..........          [ 19%]
tests/test_rg10_evaluator_v2_2_calibration.py ...................        [ 24%]
tests/test_rg10_evaluator_v2_3_calibration.py .......                    [ 26%]
tests/test_rg10_evaluator_v2_5_calibration.py ....                       [ 27%]
tests/test_rg10_evaluator_version_isolation.py ......                    [ 29%]
tests/test_rg10_experiment_provider.py ........                          [ 31%]
tests/test_rg10_generation_response_integrity.py ....................... [ 38%]
....................................                                     [ 48%]
tests/test_rg10_grammar_quality_correctness.py ......................... [ 55%]
.........                                                                [ 58%]
tests/test_rg10_phase_integration.py .........                           [ 60%]
tests/test_rg10_post_campaign_remediation.py ............                [ 64%]
tests/test_rg10_provider_record_integrity.py ............                [ 67%]
tests/test_rg10_s01_reading_batches.py ....                              [ 68%]
tests/test_rg10_s02_grammar_batches.py ....                              [ 69%]
tests/test_rg10_s03_independent_scoring.py ....                          [ 70%]
tests/test_rg10_s04_campaign_completeness.py ....                        [ 71%]
tests/test_rg10_s05_seal_research_snapshot.py .....                      [ 73%]
tests/test_rg10_scoring_integrity.py ................................... [ 83%]
...............                                                          [ 87%]
tests/test_rg10_terminal_answer_preservation.py .....                    [ 88%]
tests/test_rg10_v2_6_independent_acceptance.py ......................... [ 96%]
.                                                                        [ 96%]
tests/test_rg10_v2_7_remediation.py .............                        [100%]

============================== 353 passed in 6.07s ==============================
```

In addition, dry-run auditor utility `generation_baseline/tools/check_campaign_readiness.py` executed successfully with 0 live provider calls made.

---

## 8. Summary of Assertions and Open Campaign Blockers

1. **Software Assertions:** All 8 software readiness pillars pass without defect. Software is completely reproducible, frozen, and regression-tested.
2. **Campaign Gate Assertions:** The campaign execution gate remains on **`HOLD`** due to:
   - External provider quota exhausted: MiniMax HTTP 429 Token Plan usage limit reached (code 2056).
   - Confirmatory Holdout ($N=30$) status is `SPECIFICATION_PENDING_INDEPENDENT_CURATION` with null cryptographic seals.
   - Qualified human review panel is uncontracted/unpopulated (0 synthetic scores allowed).
   - Critical dataset integrity issues in Reading sources and Grammar task packaging (detailed in Day 2 report).

**Final Software Freeze Decision:** `SOFTWARE_READY = PASS`
