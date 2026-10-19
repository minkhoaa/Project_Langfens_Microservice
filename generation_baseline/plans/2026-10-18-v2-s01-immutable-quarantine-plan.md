# Micro-Sprint Plan: V2-S01 — Immutable Quarantine of V1 & Historical Baseline Protection

**Sprint ID**: `V2-S01`  
**Parent Master Plan**: `generation_baseline/plans/2026-10-18-rq2-dataset-v2-recovery-plan.md`  
**Document ID**: `PLAN-V2-S01-QUARANTINE`  
**Status**: `APPROVED_BY_POST_IMPLEMENTATION_USER_SIGN_OFF`  
**Approval Evidence**: `POST_IMPLEMENTATION_USER_SIGN_OFF_20261019` (Formally reviewed and approved by user post-implementation on 2026-10-19 alongside completed V2-S01 implementation; recorded explicitly as post-implementation sign-off, not retroactive pre-implementation approval)  
**Governing Standard**: `generation_baseline/SOURCE_OF_TRUTH.md`  
**Repository**: `minkhoaa/Project_Langfens_Microservice`  
**Branch**: `autonomous-generation`  

---

## 1. Objectives & Executive Context

Following the Day 1 Software Freeze (`SOFTWARE_READY = PASS`, 353/353 tests passing) and Day 2 Dataset Eligibility Audit (`DATASET_READY = HOLD`), critical data-integrity and provenance defects were identified in benchmark dataset `final-v1.0` (DEF-DAT-01 through DEF-DAT-06).

Under the research integrity and change-control invariants of `generation_baseline/SOURCE_OF_TRUTH.md`, mutating historical files in place, recalculating hashes to mask failures, or overwriting historical execution ledgers is scientifically invalid.

This micro-sprint executes **Sprint V2-S01**:
1. Formally quarantine `final-v1.0` by creating `generation_baseline/verification/V1_QUARANTINE_MANIFEST.json`.
2. Catalog all historical source files, fixtures, manifests, execution ledgers, and raw responses with their authentic SHA-256 digests.
3. Link confirmed defects DEF-DAT-01..06 directly to their supporting evidence in `RQ2_DAY2_DATASET_ELIGIBILITY_REPORT.md` and `RG10_DAY1_DAY2_FINAL_DECISION.md`.
4. Initialize the isolated execution directory `generation_baseline/.execution/RQ2_V2/` with a minimal version-identification artifact, without generating a campaign ledger.
5. Strictly enforce zero historical mutations across all tracked and git-ignored historical assets.

---

## 2. Invariants & Non-Goals

### 2.1 Inviolable Invariants
- **ZERO In-Place Mutations**: `services/generation-service/app/experiment/final_dataset.py`, `services/generation-service/tests/fixtures/policies/sources_eligible.json`, and all files under `generation_baseline/.execution/RG10/` must remain byte-for-byte identical before and after this sprint.
- **No Provider Calls**: Zero external API calls to MiniMax or any other LLM provider.
- **No RG11 or Live Execution**: No live test generation, no campaign dispatch, and no new benchmark evaluation.
- **No Holdout Unsealing**: Confirmatory holdout specifications and seals remain untouched.
- **Namespace Separation**: All future V2 code and execution state will reside in dedicated V2 namespaces (`final_dataset_v2.py`, `.execution/RQ2_V2/`).

### 2.2 Exclusions & Non-Goals
- Sprints V2-S02 through V2-S06 are out of scope for this execution turn.
- No modifications to application microservices (`exam-service`, `gateway`, etc.).
- No generation of the V2 campaign ledger (reserved for Sprint V2-S06).

---

## 3. Implementation Steps

1. **Pre-Implementation Hash Snapshot**: Record baseline SHA-256 digests and file sizes for all historical assets, distinguishing git-tracked from git-ignored files.
2. **Author `V1_QUARANTINE_MANIFEST.json`**:
   - Register dataset version `final-v1.0` as `QUARANTINED_PROVENANCE_DEFECT`.
   - Embed complete defect ledger DEF-DAT-01..06 with severity, descriptions, affected item counts, and evidence cross-references.
   - Record exact paths, SHA-256 digests, and tracking status for source files, fixtures, manifests, reports, and execution ledgers.
   - Record itemized counts and integrity hashes for all RG10 batch states (12 files), raw responses (494 files), and smoke test files (45 files).
3. **Initialize `generation_baseline/.execution/RQ2_V2/`**:
   - Create directory `generation_baseline/.execution/RQ2_V2/`.
   - Author minimal version-identification artifact `EXPERIMENT_VERSION.json`.
   - Author minimal phase status `PHASE_STATUS.json`.
4. **Verification & Regression Testing**:
   - Run post-implementation hash comparison across all historical files to prove 0 mutations.
   - Run RG10 regression test suite (`tests/test_rg10_*.py`, 353 tests).
   - Run offline package verification (`verify_baseline.py`, 2015 checks).
   - Verify quarantine manifest schema and referenced file existence.
5. **Report & Gate Close**: Author comprehensive implementation and verification report and declare explicit sprint gate decision.

---

## 4. Post-Implementation Gate Close & Sign-Off

1. **Post-Implementation User Sign-Off**: Received explicit user approval of the completed V2-S01 implementation and `PLAN-V2-S01-QUARANTINE` on 2026-10-19. Recorded strictly as post-implementation sign-off.
2. **Verification Integrity Confirmation**: Re-ran `generation_baseline/tools/verify_v1_quarantine.py`: 594/594 files verified intact with zero mutations across git-tracked and git-ignored historical assets.
3. **Regression & Package Gate**: All 353 RG10 regression tests and 2,015 offline package checks pass cleanly.
4. **Preservation of Git-Ignored Historical Files**: 564 git-ignored historical files in `generation_baseline/.execution/RG10/` audited. Same-filesystem recovery copy created at `/home/code/backups/generation_baseline_rg10/rg10_historical_execution_backup_20261019.tar.gz` (SHA-256: `0ad80d800855b0e955a0ac6c51849203079f6719ea9d5e6fb79dd907b05331a0`) and verified with 100% hash correspondence against all 564 files. Explicitly documented the preservation risk that no off-site or multi-volume durable backup exists for these untracked files.
5. **Gate Promotion**: Sprint V2-S01 promoted from `HOLD` to `PASS`.
