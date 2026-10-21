# Sprint 01: Legacy Reading Generation Engine Compatibility & Hardening Audit

**Repository**: `minkhoaa/Project_Langfens_Microservice`  
**Branch**: `autonomous-generation`  
**Baseline**: `c97ec19`  
**Lead Engineer**: LANGFENS Reading Generation Lead  
**Scope**: Hardening compatibility, correctness, and durability of the mature legacy generation engine prior to runtime cutover.

---

## 1. Exact Files and Functions Inspected

The following implementation files were thoroughly audited line-by-line across all relevant entrypoints, callers, and test suites:

| Component | Exact File Path | Functions / Blocks Inspected | Purpose & Audit Findings |
|---|---|---|---|
| **Bounded Runtime** | `services/generation-service/app/loop/runtime.py` | `_restore`, `_reserve`, `_draft`, `_evaluate`, `_accept`, `_checkpoint` | Audited CAS fencing, budget reservation handling, operation identity tracking (`sectionId`, `artifactId`, `parentOperationId`), required evaluators enforcement, and unknown outcome handling. Found duplicate error assignment overwriting evaluator error evidence and an unreserved token retry bypass on HTTP 422. |
| **Loop Policy** | `services/generation-service/app/loop/policy.py` | `from_cap_snapshot`, `from_settings`, `validate_cap_bounds`, `is_unlimited`, `from_pinned_execution_policy` | Analyzed cap definitions and benchmark mode handling. Added strict bridge adapter from canonical `PinnedExecutionPolicy` enforcing provider ≤180s, section ≤900s, 100k tokens/section, 300k tokens/paper. |
| **Passage Loop** | `services/generation-service/app/loop/passage.py` | `PassageLoop.run`, `PassageGeneratorAdapter.generate` | Inspected crash resumption logic. Found section index was missing from `LoopContext`, artifact filtering was not checking `target_art_id`, and missing/corrupt envelopes were swallowed via debug logging rather than failing closed. |
| **Question Candidate Loop** | `services/generation-service/app/loop/question.py` | `QuestionCandidateLoop.run`, `QuestionCandidateLoop.assemble_immutable_section` | Audited slot resumption and committed questions parsing. Identified unsafe reconstruction where `ArtifactEnvelope.create` synthesized envelopes from partial `payloadJson`/`contentJson` when `envelopeJson` was missing or corrupt. |
| **Section Loop** | `services/generation-service/app/loop/section.py` | `SectionLoop.run`, `SectionGeneratorAdapter.generate` | Inspected accepted section resumption. Found `cached_env = ArtifactEnvelope.create(...)` reconstructed envelopes from `p_dict` without verifying `acceptedHash` vs `content_hash` or verifying immutable envelope integrity. |
| **Paper Loop** | `services/generation-service/app/loop/paper.py` | `PaperLoop.run`, `_resolve_live_paper_sections`, `PaperGeneratorAdapter` | Verified immutable section head resolution, multi-version repair compatibility, and fail-closed termination. |
| **Candidate Generator** | `services/generation-service/app/generators/question/generator.py` | `build_pool_from_raw_candidates`, `generate_candidate_pool`, `generate_summary_group_variants` | Audited raw candidate parsing. Identified `raw.get("answer") or "A"` fallback, distractor fabrication (`f"Option {k}"`), key shuffling (`(question_number + idx) % 4`), and ungrounded evidence acceptance. |
| **Unified Policy** | `services/generation-service/app/reading_policy.py` | `PinnedExecutionPolicy`, `SectionConfig`, `RemainingBudget`, `to_loop_policy` | Inspected canonical finite policy contract without unlimited representations. Added `to_loop_policy()` bridge. |
| **Stage Executor** | `services/generation-service/app/stage_executor.py` | `_restore`, `_envelope`, `_closure`, `_unknowns`, `_prior_pass`, `_generate`, `_evaluate_and_accept` | Reference implementation for authoritative checkpoint recovery, parent dependency closure verification, and evaluator requirements. |
| **Section Runner** | `services/generation-service/app/section_runner.py` | `SectionRunner.run_section`, `_parse_candidate_payload` | Reference implementation for unified section candidate parsing and blind solver integration. |
| **Reading Pipeline** | `services/generation-service/app/pipeline.py` | `ReadingGenerationPipeline.execute` | Confirmed canonical 9-stage orchestration boundary (Stage 0 to Stage 8). |
| **.NET Checkpoint Service** | `services/exam-service/Features/ReadingPaper/CheckpointService.cs` | `ValidateRunAuthorityAndFencingAsync`, `GrantOperationAsync`, `ReconcileOperationAsync`, `CommitCheckpointAsync`, `SaveLoopCursorAsync` | Verified PostgreSQL CAS revision checks, epoch fencing, writer lease validation, and operation tracking contracts. |
| **.NET Contracts** | `services/exam-service/Features/ReadingPaper/Contracts/CheckpointContracts.cs` | `OperationGrantRequest`, `CheckpointCommitRequest`, `ResumeStateResult`, `ArtifactResumeInfo` | Validated field-level mapping (`sectionId`, `artifactId`, `parentOperationId`, `envelopeJson`). |
| **.NET Worker** | `services/exam-service/Features/ReadingPaper/ReadingPaperWorker.cs` | `ExecuteAsync`, `RunOne` | Audited lease renewal, epoch increment, and canary routing integration. |

---

## 2. Legacy ↔ Unified Contract Mapping

| Domain / Concept | Legacy Engine (`BoundedLoopRuntime` / `app/loop/`) | Unified Pipeline (`StageExecutor` / `app/reading_policy.py`) | Reconciled Mapping & Status |
|---|---|---|---|
| **Execution Policy** | `LoopPolicy` (profile JSON snapshot, `RESOURCE_CAP_FIELDS`) | `PinnedExecutionPolicy` (`providerCallSeconds`, `sectionWallSeconds`, `sectionTokenCap`, `runTokenCap`) | `LoopPolicy.from_pinned_execution_policy(policy, scope)` maps pinned caps directly into `LoopPolicy` with identical SHA-256 hash. Hard limits enforced: provider ≤180s, section ≤900s, 100k tokens/section, 300k tokens/paper. |
| **State Machine States** | `LoopState` (`INITIALIZED`, `DRAFTING`, `EVALUATING`, `REPAIRING`, `COMPLETED`, `FAILED`, `ABORTED`) | `StageState` (`PENDING`, `RUNNING`, `EVALUATING`, `ACCEPTED`, `FAILED`, `CANCELLED`, `UNKNOWN_OUTCOME`) | Functional alignment: `COMPLETED` ↔ `ACCEPTED`; `ABORTED` ↔ `CANCELLED`; `FAILED` ↔ `FAILED`. Fencing conflicts map to `LoopReason.LEASE_LOST`. |
| **Durable Checkpoints** | `CheckpointCommitRequest`, `LoopCursorCheckpointRequest` | `LoopCursorCheckpointRequest`, `CheckpointCommitRequest` | Wire contracts match 100%. Both write through `CheckpointClient` to `services/exam-service`. |
| **Artifact Representation** | `ArtifactEnvelope` (`payload`, `content_hash`, `parent_refs`, `version`) | `ArtifactEnvelope` (`payload`, `content_hash`, `parent_refs`, `version`) | Exact match. All recovery paths now strictly consume `envelopeJson` only. |
| **Operation Accounting** | `OperationGrantRequest` (`tokenReservation`, `wallTimeReservationSeconds`, `sectionId`, `artifactId`, `parentOperationId`) | `OperationGrantRequest` (`tokenReservation`, `wallTimeReservationSeconds`, `sectionId`, `artifactId`, `parentOperationId`) | `loop/runtime.py` now explicitly passes `sectionId=str(context.section_id)`, `artifactId=context.target_artifact_id`, and `parentOperationId`. |
| **Question Invariants** | `QuestionCandidate` / `QuestionCandidatePool` | `CandidatePayload` in `SectionRunner` | Validated six-type question schemas, verbatim passage matches (1–3 words for completion/SA), distinct evidence quotes, and 4-option MCQs. |
| **Blind Solver Evaluation** | `BlindSolverEvaluator` registered in `EvaluatorRegistry` | `BlindSolverEvaluator` via `evaluate_question` | `eval_blind_solver_adversary` enforced before artifact acceptance. |

---

## 3. Defects Identified, Root Causes, and Implemented Fixes

### Defect 1: Unsafe Answer Key Fallback & Distractor Manufacture in Candidate Generator
- **Location**: `services/generation-service/app/generators/question/generator.py` (`build_pool_from_raw_candidates`)
- **Root Cause**: Lines 143–166 used `raw.get("answer") or "A"` and `raw_ans = "A"` if empty, fabricating answers for questions without valid keys. For MCQs, it forcibly rotated options to `keys[(question_number + idx) % 4]` and manufactured fake options (`f"Option {k}"`) when fewer than 4 distractors were produced.
- **Fix**:
  1. Extracted `raw_ans_str` from `raw.get("answer")` or `raw.get("correctOption")`. If missing/empty, marked candidate rejected (`"Missing answer key"`), never defaulting to `"A"`.
  2. Preserved valid MCQ option mappings without rotation or fake distractors. If fewer than 4 options exist, left them intact so `QuestionCandidate` validation rejects the candidate fail-closed.
  3. Added evidence quote validation against `passage_text` (case-insensitive substring check). Unsupported quotes are rejected (`"Evidence quote is unsupported by passage"`).

### Defect 2: Evaluator Error Evidence Overwriting
- **Location**: `services/generation-service/app/loop/runtime.py` (`_evaluate`)
- **Root Cause**: Line 949 immediately reassigned `result` with generic `"Evaluator returned ERROR without evidence"`, completely erasing the actual exception type, traceback, and error message recorded on line 948.
- **Fix**: Removed line 949 so the true evaluator failure reason is preserved in the evaluation record and issue ledger.

### Defect 3: Unlimited Fallback & Unreserved 422 Retry Hack
- **Location**: `services/generation-service/app/loop/runtime.py` (`_reserve`)
- **Root Cause**: On HTTP 422 (token budget exhausted), lines 496–516 attempted an unreserved zero-token grant retry when `self.policy.is_unlimited`, silently bypassing budget enforcement.
- **Fix**: Removed the zero-grant retry hack. An HTTP 422 response immediately terminates with `LoopReason.TOKEN_CAP` fail-closed.

### Defect 4: Hardcoded `sec_id = None` in Operation Grants
- **Location**: `services/generation-service/app/loop/runtime.py` (`_reserve`)
- **Root Cause**: Line 478 hardcoded `sec_id = None`, dropping section-level attribution for all child operations.
- **Fix**: Assigned `sec_id = str(self.context.section_id) if getattr(self.context, "section_id", None) is not None else None`.

### Defect 5: Unhandled Cursor CAS Revision Conflicts
- **Location**: `services/generation-service/app/loop/runtime.py` (`_checkpoint`)
- **Root Cause**: When `save_loop_cursor` returned HTTP 409 (CAS revision conflict or stale epoch), `_checkpoint` re-raised the exception unhandled, crashing the process instead of cleanly aborting the runtime.
- **Fix**: Caught `CheckpointApiError` with status 409/403, rolled back `cursor.revision`, and called `self._finish(LoopReason.LEASE_LOST, f"CAS_CONFLICT: {error.message}", aborted=True)`.

### Defect 6: Unsafe In-Memory Artifact Reconstruction during Passage Resumption
- **Location**: `services/generation-service/app/loop/passage.py` (`PassageLoop.run`)
- **Root Cause**:
  1. Failed to filter `art_info.artifactId == target_art_id`, risking cross-section passage confusion.
  2. Swallowed missing/corrupt checkpoints via `except Exception as exc: logger.debug(...)`.
  3. Lacked explicit verification of `content_hash`, `version`, `run_id`, and integrity on the deserialized envelope.
- **Fix**:
  1. Filtered by exact `target_art_id = f"art_passage_s{passage_context.section_index}"`.
  2. Required non-empty `envelopeJson` and validated integrity, hash, version, and runId, raising `ValueError` fail-closed on corruption.
  3. Verified parent dependency freshness against `store_accepted_heads`.
  4. Resumes valid artifacts with 0 provider calls and 0 tokens.

### Defect 7: Unsafe Question Envelope Synthesis from Partial Payloads
- **Location**: `services/generation-service/app/loop/question.py` (`QuestionCandidateLoop.run`)
- **Root Cause**: Lines 186–208 invoked `ArtifactEnvelope.create` to reconstruct synthetic question envelopes from `payloadJson` or `contentJson` when `envelopeJson` was missing or corrupt.
- **Fix**:
  1. Required valid `envelopeJson` for all question and question group artifacts. Missing `envelopeJson` or deserialization failure raises `ValueError` fail-closed.
  2. Verified `run_id`, `artifact_id`, `acceptedVersion`, `acceptedHash`, and `verify_integrity()`.
  3. Verified all parent references are accepted and fresh in `store_accepted_heads`.
  4. Eliminated synthetic `ArtifactEnvelope.create` fallback entirely.
  5. Preserved existing accepted S2/S3 artifacts across runs.

### Defect 8: Section Envelope Reconstruction from Loose Dictionaries
- **Location**: `services/generation-service/app/loop/section.py` (`SectionLoop.run`)
- **Root Cause**: Lines 485–495 called `ArtifactEnvelope.create` from `p_dict` without verifying content hash against `acceptedHash`.
- **Fix**:
  1. Resumes exclusively via `ArtifactEnvelope.model_validate_json(art_info.envelopeJson)`.
  2. Verified `content_hash == acceptedHash`, `version == acceptedVersion`, `run_id == run_id`, and `verify_integrity()`.
  3. Verified parent dependency alignment with `all_input_deps` and confirmed parents are not stale.
  4. Corrupt checkpoints or hash mismatches raise `ValueError` fail-closed.

### Defect 9: Missing Bridge between `PinnedExecutionPolicy` and `LoopPolicy`
- **Location**: `services/generation-service/app/loop/policy.py` & `app/reading_policy.py`
- **Root Cause**: No canonical mechanism existed to adapt `PinnedExecutionPolicy` into a `LoopPolicy` while preserving the policy SHA-256 digest and bounded limits.
- **Fix**: Implemented `LoopPolicy.from_pinned_execution_policy()` and `PinnedExecutionPolicy.to_loop_policy()`, clamping resource caps to hard ceilings (≤180s provider, ≤900s section, ≤2700s paper, ≤100k tokens/section, ≤300k tokens/paper).

---

## 4. Test Verification & Actual Results

### Full Service Verification Run

```bash
# 1. Bounded Loop Runtime Core Suite
python3 -m pytest tests/test_t06_loop_runtime.py -q
# Result: 33 passed in 16.29s

# 2. Passage Loop Suite
python3 -m pytest tests/test_t08_passage_loop.py -q
# Result: 8 passed in 2.37s

# 3. Question Candidates & Group Selection Suite
python3 -m pytest tests/test_t09_question_candidates.py -q
# Result: 9 passed in 2.97s

# 4. Blind Solvers Suite
python3 -m pytest tests/test_t10_blind_solvers.py -q
# Result: 12 passed in 63.39s

# 5. Section Loop Suite
python3 -m pytest tests/test_t11_section_loop.py -q
# Result: 10 passed in 2.68s

# 6. Paper Loop Suite
python3 -m pytest tests/test_t12_paper_loop.py -q
# Result: 29 passed in 3.02s

# 7. Unified Pipeline Suite
python3 -m pytest tests/unified/ -q
# Result: 38 passed in 125.97s

# 8. Focused Hardening Regression Suite (8 Mandatory Scenarios)
python3 -m pytest tests/test_legacy_hardening_regression.py -v
# Result: 8 passed in 1.56s

# 9. Non-Destructive .NET Exam-Service Tests
dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj
# Result: Passed! 80 passed, 0 failed in 1s
dotnet test services/exam-service.Tests/exam-service.Tests.csproj --filter "FullyQualifiedName~ReadingPaperAiClientConfigurationTests"
# Result: Passed! 3 passed, 0 failed in 129ms
```

### Cumulative Test Results Table

| Test Suite | Scope | Tests Run | Result | Notes |
|---|---|---|---|---|
| `test_t06_loop_runtime.py` | Runtime state machine, CAS fencing, error preservation | 33 | **33 PASSED** | Zero regressions |
| `test_t08_passage_loop.py` | Passage synthesis, crash resumption, store integration | 8 | **8 PASSED** | Exact envelope recovery |
| `test_t09_question_candidates.py` | 6 IELTS question types, distractors, joint selection | 9 | **9 PASSED** | Valid option mappings preserved |
| `test_t10_blind_solvers.py` | Adversarial review, blinded solve, agreement gates | 12 | **12 PASSED** | Deterministic solver verification |
| `test_t11_section_loop.py` | Section assembly, idempotent replay, cursor resume | 10 | **10 PASSED** | Replay returns v1 with 0 calls |
| `test_t12_paper_loop.py` | 3-section paper assembly, surgical repair, head binding | 29 | **29 PASSED** | Cross-section dependencies intact |
| `tests/unified/` | Unified ReadingGenerationPipeline stages 0–8 | 38 | **38 PASSED** | Full deterministic mock suite green |
| `test_legacy_hardening_regression.py` | 8 Sprint 01 mandatory regression gates | 8 | **8 PASSED** | Hardening gates verified |
| `.NET attempt-service.Tests` | Question grader deterministic engines | 80 | **80 PASSED** | Immutability and grading invariants |
| `.NET exam-service.Tests (Config)` | Client configuration and canary profiles | 3 | **3 PASSED** | Non-destructive test filter |

**Remaining Blockers**: **NONE**. All target files hardened, all regression scenarios passing, and zero regressions observed across 147 Python tests and 83 .NET tests.

---

## 5. Explicit GO / NO-GO Decision

### Recommendation: **GO**

**Decision**: **GO for adopting `BoundedLoopRuntime` inside the unified reading generation architecture.**

**Rationale**:
1. **Durability & Correctness Certified**: Crash resumption now strictly validates exact persisted `envelopeJson`, parent dependency freshness, content hashes, and version invariants. All partial/synthetic envelope reconstruction hacks have been removed.
2. **True Fail-Closed Behavior**: Corrupted checkpoints, missing envelopes, stale parent heads, missing answers, and unsupported evidence quotes now fail closed with typed errors rather than fabricating content or returning false PASSes.
3. **Budget & Finite Caps Enforced**: Provider timeouts and `UNKNOWN_OUTCOME` operations are never replayed. Unreserved 422 bypasses have been eliminated. `LoopPolicy` directly bridges from canonical `PinnedExecutionPolicy` with pinned SHA-256 hashes.
4. **Clean Boundary**: Existing accepted S2/S3 artifacts are strictly preserved. `StageExecutor` remains in place; no runtime cutover was performed during this sprint. The mature legacy loop engine is fully hardened and ready for unified orchestration integration in the subsequent sprint.
