# Micro-Sprint Plan: V2-S01 — Immutable Quarantine of V1 & Historical Baseline Protection

**Sprint ID**: `V2-S01`  
**Parent Master Plan**: `generation_baseline/plans/2026-10-18-rq2-dataset-v2-recovery-plan.md`  
**Document ID**: `PLAN-V2-S01-QUARANTINE`  
**Status**: `PROPOSED_SPRINT_PLAN_CANDIDATE_AWAITING_USER_APPROVAL`  
**Approval Evidence**: `NONE_INVENTED` (Candidate sprint plan authored under V2-S01 preflight; awaiting explicit human review and sign-off; approval not invented per prompt mandate)  
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
