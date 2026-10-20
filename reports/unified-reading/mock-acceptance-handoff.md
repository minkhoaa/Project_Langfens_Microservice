# Unified Reading Generation Rebuild — Mock E2E Acceptance Lane Handoff

## Delivered Artifacts

1. `services/generation-service/tests/unified/mock_fixtures.py`
2. `services/generation-service/tests/unified/test_section_standalone.py`
3. `services/generation-service/tests/unified/test_reading_pipeline_mock_e2e.py`
4. `services/generation-service/tests/unified/test_concurrency_and_fencing.py`
5. `services/generation-service/tests/unified/test_resume_and_invalidation.py`

## Component Architectures

### 1. `MockProvider` (`BaseProvider` Subclass)
- Inherits from `app.providers.base.BaseProvider`.
- Returns deterministic, compliant `ProviderResponse` objects without network calls.
- Provides automatic generation for `Capability.GENERATE_JSON`, `Capability.SOLVE_ITEM`, `Capability.EVALUATE_ITEM`.
- Full request and telemetry audit trail:
  - `call_log`: list of `(request, deadline)` tuples
  - `requests`: list of `ProviderRequest` objects
  - `token_calls`: list of tokens used per dispatch
  - `total_tokens_used`: cumulative token counter
- Dynamic test control:
  - `fail_next(exc)`: injects a single-shot exception on the subsequent call
  - `script_response(key, data)`: overrides responses for specific operation IDs or capabilities

### 2. `InMemoryCheckpointClient` (`CheckpointClient` Subclass)
- In-memory persistence authority strictly adhering to .NET CheckpointService invariants:
  - **Fencing & Lease Locks**: verifies `epoch`, `leaseOwner`, and `status == "RUNNING"` on every mutation. Stale epoch raises HTTP 409 (`InvalidEpochError`); mismatched lease raises HTTP 403 (`LeaseLostError`).
  - **Loop Cursor CAS**: validates `expectedRevision` against current revision; raises HTTP 409 (`CursorConflictError`) on mismatch.
  - **Head CAS**: validates `expectedHeadVersion` and `expectedHeadHash`; raises HTTP 409 on mismatch.
  - **Dependency Closure**: validates all `parent_refs` exist, match current head version/hash, and are not marked stale.
  - **Operation Grants & Reconciles**: tracks `status="RESERVED"`, `tokensUsed`, `isReplay` detection, and budget accounting.
  - **Unknown Outcome**: records `status="UNKNOWN_OUTCOME"` and preserves token reservations.
  - **Transitive Invalidation**: `invalidate_dependencies` identifies all direct and indirect DAG descendants of a target artifact and marks them stale while preserving unaffected sibling artifacts.
  - **Exam Finalization**: `build_exam` / `build_exam_async` generates UUID `examId` and slug.

### 3. Realistic Scientific Source Corpora
- Sourced from authentic PMC Open Access literature (>=600 words each, verified CC-BY license, HTTPS Europe PMC URLs):
  - Section 1: Archaeological and paleoecological wetland cultivation (PMC12804876)
  - Section 2: Marine stoichiometry and the classical Redfield ratio 106:16:1 (PMC9640808)
  - Section 3: Atmospheric transmission spectroscopy and exoplanetary transit retrieval (PMC8556156)

---

## Test Suites Summary

### 1. `test_section_standalone.py` (4 tests)
- `test_section_standalone_generation`: Parametrized across Sections 1, 2, and 3:
  - Section 1: Contiguous Q1–13 (7 True/False/Not Given, 6 Sentence Completion).
  - Section 2: Contiguous Q14–26 (6 Multiple Choice Single, 7 Summary Completion).
  - Section 3: Contiguous Q27–40 (7 Yes/No/Not Given, 7 Short Answer).
  - Passage word count within configured limits (720..915 words).
- `test_section_runner_is_strictly_identical_class_across_sections`: Asserts that Sections 1, 2, and 3 execute through the exact same `SectionRunner` class and instance without hardcoded index branching.
- `test_section_standalone_zero_cross_section_state_leakage`: Confirms that running Section 2 commits only section 2 artifacts.
- `test_section_standalone_deterministic_reproducibility`: Confirms that identical inputs yield byte-identical artifact payloads and hashes across runs.

### 2. `test_reading_pipeline_mock_e2e.py` (5 tests)
- `test_full_reading_pipeline_sequential_mock_e2e`: Complete sequential generation of 3 sections, contiguous Q1–40, paper assembly, total words within [2150, 2750], and finalization (`exam_id` created via `build_exam`).
- `test_full_reading_pipeline_parallel_mock_e2e`: Complete parallel generation (`parallel=True` via `asyncio.gather`), sorted output, complete paper and exam finalization.
- `test_reading_pipeline_without_finalization`: When `finalize=False`, paper is assembled but `exam_id` is None and `build_exam` is not called.
- `test_reading_pipeline_subset_section_execution`: Single section (Section 2) pipeline run leaves paper unfinalized.
- `test_reading_pipeline_idempotent_re_execution`: Re-running pipeline on completed run reuses existing artifacts and returns stable exam ID.

### 3. `test_concurrency_and_fencing.py` (5 tests)
- `test_same_stage_cursor_cas_conflict_detection`: Competing writers on the same stage cursor; winner advances revision, loser receives `CursorConflictError` via deterministic barrier synchronization (no `time.sleep`).
- `test_concurrent_independent_sections_proceed_safely`: Concurrent section generation runs on independent cursors without conflict.
- `test_lease_revocation_rejects_with_lease_lost_error`: Mid-flight lease owner mutation triggers HTTP 403 / `LeaseLostError`.
- `test_epoch_bump_fencing_rejects_stale_epoch`: Authority epoch advancement fences out stale writers with HTTP 409 / `InvalidEpochError`.
- `test_head_version_cas_mismatch_rejected`: Stale expectedHeadVersion is rejected with HTTP 409.

### 4. `test_resume_and_invalidation.py` (4 tests)
- `test_resume_partially_completed_paper_zero_provider_calls`: Resuming a run with Sections 1 & 2 already committed executes Section 3 with **0 provider calls** for Sections 1 and 2.
- `test_dependency_invalidation_regenerates_only_affected_descendants`: Invalidating Section 2's source pack marks Section 2 and paper stale, while Sections 1 and 3 remain preserved and untouched.
- `test_unknown_outcome_halts_execution_and_refuses_silent_replay`: Unresolved `UNKNOWN_OUTCOME` halts `StageExecutor` with `UnresolvedProviderOutcomeError` and `ProviderGateway` refuses silent replay.
- `test_token_accounting_isolation_across_operations`: Verifies reservation and actual token usage are tracked per operation and section without budget leakage.

---

## Verification Command for Main Agent

```bash
cd services/generation-service
pytest tests/unified -v
```

Expected result: **18 tests passing, 0 failures, 0 warnings**.
