# LANGFENS — AUTONOMOUS BLUEPRINT RECOVERY REPORT

**Repository:** `minkhoaa/Project_Langfens_Microservice`  
**Branch:** `autonomous-generation`  
**Commit:** `c752d883a0ef26473b430684948d611ce7138062`  
**Date:** 2026-10-23  

---

## 1. Executive Summary

This report documents the root-cause diagnosis, engineering repairs, and end-to-end verification resolving the catastrophic failure of LIVE reading generation job `d6a23408-bff7-41a7-8e5d-d67c94a497e3` at Stage 3 (Exam Blueprint Allocation).

The production pipeline now autonomously recovers from blueprint allocation and evidence incompatibility defects without human intervention, maintains fail-closed academic rigor, distinguishes pipeline errors from source acquisition failures, and preserves all checkpoint and deterministic hashing invariants.

---

## 2. Root Cause Analysis

### Incident Inspection (Job `d6a23408-bff7-41a7-8e5d-d67c94a497e3`)

Database inspection of PostgreSQL table `reading_paper_jobs` and `reading_paper_operations` for run `run_d6a23408bff741a78e5dd67c94a497e3` revealed:

```text
OperationId: loop:run_d6a23408bff741a78e5dd67c94a497e3:blueprint:run_d6a23408bff741a78e5dd67c94a497e3:GENERATE:1:1.0.0
OperationType: GENERATE
ArtifactId: blueprint:run_d6a23408bff741a78e5dd67c94a497e3
Status: RESERVED -> FAILED
Error: {"detail":"blueprint:run_d6a23408bff741a78e5dd67c94a497e3: INVALID_OUTPUT: capability failed: ValueError: Section 1 EvidenceGraph 'eg_sec1_run_d6a2' has no eligible verified claims for family 'TRUE_FALSE_NOT_GIVEN' (slot 1). Fail-closed: cannot force unsuitable evidence binding."}
```

### The Three Contributing Defects

#### 1. Claim Identity Contradiction
- `build_evidence()` in `app/reading_generation.py` deterministically derives canonical claim IDs:
  ```python
  claim_id = f"claim:{run_id}:{section_id}:{len(claims) + 1}"
  ```
- In live jobs, `run_id` begins with `"run_"`, producing IDs such as `claim:run_d6a23408bff741a78e5dd67c94a497e3:1:1`.
- However, `claim_binding.py`, `reading_evaluation.py`, and `blueprint/validators.py` enforced prefix-based rejection:
  ```python
  if cid.startswith("claim:synthetic:") or cid.startswith("claim:run_") ...:
      return False
  ```
- This rejected 100% of authentic, passage-grounded claims produced during the run as "fabricated synthetic claims", causing `eligible_candidates` to be empty and crashing slot binding.

#### 2. Error Classification Defect in .NET Client
- In `ReadingPaperAiClient.cs`, `ReadAsync` unconditionally converted any HTTP 422 response from any endpoint to `ReadingSourceUnavailableException`.
- In `ReadingPaperWorker.cs`, catching `ReadingSourceUnavailableException` caused the job status to be marked as `"NeedsSources"`:
  ```csharp
  var status = ex is ReadingSourceUnavailableException ? "NeedsSources" : "Failed";
  ```
- This misclassified internal blueprint validation failures as missing sources, misleading operators and halting the job incorrectly.

#### 3. Absence of Bounded Blueprint Self-Recovery
- When evidence for a section was insufficient for a selected question family, `generate_dynamic_blueprint` did not attempt deterministic reallocation or controlled evidence re-extraction from verified source text, halting with an unhandled `ValueError`.

---

## 3. Architecture & Code Changes

```text
Project_Langfens_Microservice/
├── services/
│   ├── exam-service/
│   │   ├── Features/ReadingPaper/
│   │   │   ├── ReadingPaperAiClient.cs            # Added ReadingPipelineExecutionException; routed 422 appropriately
│   │   │   └── ReadingPaperWorker.cs              # Preserved 'Failed' status and error diagnostics
│   │   └── exam-service.Tests/
│   │       └── ReadingPaperChunkStreamTests.cs    # Added 422 pipeline failure classification test
│   └── generation-service/
│       ├── app/
│       │   ├── blueprint/
│       │   │   ├── claim_binding.py               # Replaced claim:run_ rejection with graph membership & provenance
│       │   │   ├── generator.py                   # Implemented evidence-aware selection & deterministic reallocation
│       │   │   ├── validators.py                  # Added cross-section and graph membership validation
│       │   │   └── __init__.py                    # Exported InsufficientEvidenceForAllocationError
│       │   ├── reading_evaluation.py              # Evaluator graph membership and semantic suitability checks
│       │   └── reading_generation.py              # Added reextract_evidence_for_section and blueprint recovery loop
│       └── tests/
│           ├── test_autonomous_blueprint_recovery.py  # Comprehensive regression suite (9 tests)
│           ├── test_dynamic_blueprint.py              # Aligned test assertions with graph membership
│           └── unified/
│               └── test_semantic_claim_binding.py     # Updated fake prefix assertions
```

### Detailed Implementations

1. **`app/blueprint/claim_binding.py`:**
   - Removed `cid.startswith("claim:run_")`.
   - Verified that claims have non-empty text grounding.
   - Enforced cross-section rejection when `claim.sectionId != section_id` or parsed ID index `parts[2] != section_id`.
   - Maintained strict rejection of explicit fake/synthetic prefixes (`claim:synthetic:*`, `claim:placeholder:*`, `claim:None:*`, `claim:fake:*`, `claim:fake_*`).
   - Retained strict semantic scoring threshold (`score > 0.0`).

2. **`app/reading_evaluation.py` & `app/blueprint/validators.py`:**
   - Replaced prefix rejection of `claim:run_` with verified EvidenceGraph membership validation (`cid in claims_by_id` / `valid_cids`).
   - Added `BLUEPRINT_CROSS_SECTION_CLAIM_PROHIBITED` and `BLUEPRINT_CLAIM_NOT_FOUND`.
   - Enforced `check_claim_eligibility_for_family` on the authoritative evaluator path.

3. **`app/blueprint/generator.py`:**
   - Defined `InsufficientEvidenceForAllocationError`.
   - Filters candidate families in the section pool (`SECTION_1_FAMILIES`, `SECTION_2_FAMILIES`, `SECTION_3_FAMILIES`) to those with verified eligible claims.
   - Deterministically reallocates incompatible families to the highest-scoring compatible family in the section pool.
   - Automatically adapts group counts (e.g., from 3 groups to 2 groups) when compatible families are fewer than planned groups, strictly preserving the 40-question, 3-section, and difficulty invariants.

4. **`app/reading_generation.py`:**
   - Implemented `reextract_evidence_for_section()` to extract verified candidate spans directly from source text (`document.text`), byte-verified with `text[start:end] == trimmed`, non-conflicting, and grounded.
   - Wrapped dynamic blueprint generation in `build_blueprint()` in a bounded self-recovery loop:
     - Catches `InsufficientEvidenceForAllocationError`.
     - Enforces `policy.max_recovery_attempts` (default 3, cap 10).
     - Enforces stagnation detection (halts on identical source digests).
     - Mines verified claims from verified source text and re-evaluates the evidence graph using production `evaluate_evidence()`.
     - Retries blueprint allocation with verified evidence.
     - Fails closed with a truthful terminal `ValueError` if source text is genuinely insufficient.

5. **`ReadingPaperAiClient.cs` (.NET Service):**
   - Introduced `ReadingPipelineExecutionException`.
   - `/execute` pipeline/blueprint errors throw `ReadingPipelineExecutionException`, setting job status to `"Failed"` in `ReadingPaperWorker.cs` with the truthful error message preserved.
   - Source acquisition endpoints (`/source`, `/source/ingest`) and source-content errors retain `ReadingSourceUnavailableException` mapping to `"NeedsSources"`.

---

## 4. Recovery Transition Flow

```text
[Pipeline Stage 3: Exam Blueprint]
                 │
                 ▼
     [Evaluate Family Compatibility]
                 │
  ┌──────────────┴───────────────────────────┐
  │                                          │
  ▼                                          ▼
[All Families Compatible]       [Family Incompatible with Evidence]
  │                                          │
  ▼                                          ▼
[Bind Slots to Claims]         [Deterministic Family Reallocation]
  │                            Selects next compatible family from section pool
  │                            (e.g., TFNG / Sentence Completion for Sec 1)
  │                            Adapts group counts (13/13/14 total preserved)
  │                                          │
  │                             ┌────────────┴────────────┐
  │                             │                         │
  │                             ▼                         ▼
  │                    [Alternative Found]        [Zero Pool Families Supported]
  │                             │                         │
  │                             ▼                         ▼
  │                    [Bind Reallocated Slots]   [Controlled Evidence Re-Extraction]
  │                             │                 Mines verified spans from source text
  │                             │                 Asserts byte slice exact match
  │                             │                 Validates via evaluate_evidence()
  │                             │                         │
  │                             │           ┌─────────────┴─────────────┐
  │                             │           │                           │
  │                             │           ▼                           ▼
  │                             │     [Claims Found]            [Source Text Deficient]
  │                             │           │                           │
  │                             │           ▼                           ▼
  │                             │     [Retry Allocation]      [Truthful Terminal Error]
  │                             │           │                 Fails closed (ValueError)
  │                             │           │                 Job Status marked 'Failed'
  │                             ▼           ▼                 (Never 'NeedsSources')
  └──────────────────────────▶ [Blueprint Accepted]
                                Verified by evaluate_blueprint()
                                Checkpoint integrity preserved
```

---

## 5. Test Verification Matrix

### Python Test Suite (`services/generation-service`)

| Test File | Total Tests | Status | Duration |
|---|---|---|---|
| `tests/test_autonomous_blueprint_recovery.py` | 9 | **PASSED** | 1.00s |
| `tests/test_dynamic_blueprint.py` | 8 | **PASSED** | 0.22s |
| `tests/unified/test_fail_closed_claim_grounding.py` | 10 | **PASSED** | 0.08s |
| `tests/unified/test_semantic_claim_binding.py` | 9 | **PASSED** | 0.12s |
| `tests/unified/test_acceptance_to_publication_bridge.py` | 7 | **PASSED** | 0.08s |
| `tests/unified/test_academic_source_provenance.py` | 10 | **PASSED** | 0.07s |
| `tests/test_question_candidates_19types.py` | 8 | **PASSED** | 0.04s |
| `tests/test_blind_solvers_19types.py` | 55 | **PASSED** | 0.06s |
| `tests/test_autonomous_recovery_loop.py` | 14 | **PASSED** | 0.08s |
| **Combined Python Suite** | **130** | **PASSED** | **1.63s** |

### .NET Test Suite (`services/exam-service.Tests` & `services/attempt-service.Tests`)

| Test Suite | Total Tests | Status | Duration |
|---|---|---|---|
| `ReadingPaperChunkStreamTests` | 5 | **PASSED** | 0.27s |
| `ReadingPaperAiClientConfigurationTests` | 3 | **PASSED** | 0.18s |
| `attempt-service.Tests` (All 19 IELTS Question Graders) | 125 | **PASSED** | 1.00s |
| **Combined .NET Suite** | **133** | **PASSED** | **1.45s** |

---

## 6. Safety & Operational Constraints Audit

- **Live Job Isolation:** LIVE job `d6a23408-bff7-41a7-8e5d-d67c94a497e3` was inspected in read-only mode and was **NOT** retried or resumed.
- **Zero Job Injection:** No new live jobs were created.
- **Provider Quota Preservation:** Zero calls made to MiniMax or external LLMs.
- **Baseline Integrity:** `generation_baseline/` was untouched.
- **Remote Synchronization:** Verified changes were committed (`c752d88`) and pushed to branch `autonomous-generation` on GitHub.
- **Remaining Blockers:** None.
