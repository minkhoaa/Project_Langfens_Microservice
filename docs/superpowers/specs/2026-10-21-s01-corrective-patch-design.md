# Technical Design Specification: S01 Corrective Patch (P0/P1 Blockers)

**Target Repository:** `minkhoaa/Project_Langfens_Microservice`  
**Target Branch:** `autonomous-generation`  
**Base Commit:** `09005b241e8fed3ff16beb3fc93fc5244a2caa31`  
**Document Path:** `docs/superpowers/specs/2026-10-21-s01-corrective-patch-design.md`  
**Date:** 2026-10-21  

---

## 1. Intent & Context

During Sprint 01 compatibility auditing and hardening of the legacy Reading Generation Engine (`app/loop/`), four critical defects were identified across policy adaptation, immutable checkpoint resumption, question candidate parsing, and operation scope tracking:

1. **P0-A — Policy Bridge & Persisted Hash Mismatch:** `LoopPolicy.from_pinned_execution_policy()` conflates canonical `policy.hash` (SHA-256 of `PinnedExecutionPolicy`) with `cap_profile_sha256` (SHA-256 of the persisted JSON snapshot). Furthermore, float types (e.g., `loopOperationWallReservationSeconds`) and missing .NET budget keys violate the 32-bit integer schema and validation in `ReadingPaperCapsProfile.cs`.
2. **P0-B — Immutable Recovery Bypasses Evaluator Evidence:** `PassageLoop` and `SectionLoop` return zero-call `DecisionType.PASS` whenever content hashes match, skipping the evaluation ledger, evaluator IDs/versions, and blind-solver coverage. Existing `test_regression_01` seeded an artifact with `evaluations=[]`, proving zero-call resume passed without academic acceptance evidence. In addition, an `if p.artifact_id in store_accepted_heads` loop condition allows missing parents to bypass stale-dependency validation.
3. **P1-C — Candidate Correctness Not Fail-Closed:** `QuestionCandidateGenerator` contains fallback prompt synthesis (`f"Question {question_number} prompt."`), an evidence quote length bypass (`len(ev_quote) >= 15`), and unvalidated MCQ answer-to-option mapping. Downstream, structural validation is not cleanly separated from semantic correctness, and blind-solver/grounding checks are omitted from mandatory acceptance gates.
4. **P1-D — Non-Deterministic Workflow Recovery & Scope Mismatch:** `QuestionCandidateLoop` selects any arbitrary reserved workflow using `existing_reserved[0]` without filtering by section index, group, or request hash, using random UUIDs that break deterministic replay. Additionally, divergent `SectionId` formatting (`"1"` vs `"section_1"`) causes .NET `CheckpointService.cs` parent-child checks to reject child grants with HTTP 422.

This patch is a **targeted corrective implementation**, strictly preserving the mature legacy engine architecture without performing a runtime cutover or rewrite.

---

## 2. Goals, Non-Goals, and Anti-Goals

### Goals
- **P0-A Canonical Policy Bridge:**
  - Generate a canonical, .NET-compatible cap snapshot dictionary containing all mandatory 32-bit positive integer fields, including `standaloneRunBudgetCapCalls`, `standaloneRunBudgetCapTokens`, and `standaloneRunBudgetCapWallTimeSeconds`.
  - Cast all cap values (including `loopOperationWallReservationSeconds`) to `int`.
  - Distinguish `policy.hash` from `cap_profile_sha256 = cap_snapshot_sha256(snapshot)` while exposing `policy_hash` on `LoopPolicy`.
  - Ensure both `LoopPolicy.from_cap_snapshot(snapshot)` and `validate_cap_bounds()` succeed.
  - Enforce finite ceilings: provider <= 180s, section <= 900s / 100k tokens, paper <= 2700s / 300k tokens.
- **P0-B Immutable Recovery & Evidence Integrity:**
  - Enforce strict parent dependency closure: every parent in `envelope.parent_refs` MUST exist in `store_accepted_heads` and match exact version and content hash (remove `if ... in store_accepted_heads` filtering loophole).
  - Enforce full evaluation ledger verification on zero-call resume: verify that `resume_state.evaluations` contains passing records for all `required_evaluator_ids` bound to `target_ref == envelope.to_ref()`, matching parent refs and non-empty evaluator versions.
  - Artifacts lacking valid evaluation records must not be granted automatic PASS; they fall through to loop execution with `current_artifact = accepted_envelope` to undergo mandatory evaluation in `LoopState.EVALUATING`, leaving historical data unmutated.
- **P1-C Strict Fail-Closed Candidate Generation:**
  - Remove prompt fallback: missing/empty prompt must set `rejected = True` with `"Missing prompt"`.
  - Remove quote length bypass: any non-empty `evidenceQuote` must be checked against `passage_text` regardless of length (except valid NOT GIVEN).
  - Validate MCQ answer keys: if the answer key does not resolve to an option key A-D, mark rejected with `"MCQ answer key not found in options"`.
  - Ensure candidate acceptance requires passing structural, semantic grounding (`eval_grounding_fidelity`), and blind solver (`eval_blind_solver_adversary`) evaluations before final artifact commitment.
- **P1-D Deterministic Workflow Recovery & Operation Alignment:**
  - Replace `existing_reserved[0]` with deterministic matching on `operationId` scheme `f"op_workflow_qcand_s{section_index}_{run_id[:8]}"`, which round-trips via `OperationResumeInfo.operationId`.
  - Bind workflow operations to `sectionId = normalize_section_id(section_index)`.
  - Align child operation `SectionId` with parent operation `SectionId` to satisfy `CheckpointService.cs:445` parent-child equality checks.
- **Verification & Documentation:**
  - Add new focused regression test file: `services/generation-service/tests/test_s01_corrective_regression.py`.
  - Generate comprehensive verification report: `reports/unified-flow/S01-CORRECTIVE-VERIFICATION.md`.

### Non-Goals
- No cutover to `StageExecutor` or new orchestration engine.
- No live external LLM/MiniMax network calls.
- No PostgreSQL schema migrations or EF Core entity alterations.
- No modification of historical accepted S2/S3 artifact payloads.
- No merge into `master` branch.

### Anti-Goals (Forbidden Practices)
- **Zero Test Manipulation:** Never modify, delete, or weaken existing tests (including `test_regression_01` and `test_regression_08`) to force a green test suite.
- **Zero Content Fabrication:** Never synthesize placeholder questions, fake options, or artificial quotes.
- **No Unsafe Replay or Silent Fallbacks:** Never bypass token caps or retry exhausted budgets with zero-token reservations.

---

## 3. User Decisions & Invariants

1. **Test Integrity Policy:** Existing tests under `tests/test_legacy_hardening_regression.py` must remain completely untouched.
   - If `test_regression_01` fails because production code now enforces mandatory evaluation evidence on resume, that test will turn RED.
   - If `test_regression_08` fails because production code properly distinguishes `cap_profile_sha256` from `policy.hash`, that test will turn RED.
   - Both specification conflicts MUST be documented and explained in `reports/unified-flow/S01-CORRECTIVE-VERIFICATION.md` rather than modifying the tests or weakening production code.
2. **New Regression Tests Only:** All new behavioral verifications must reside in a dedicated test file: `tests/test_s01_corrective_regression.py`.
3. **Fail-Closed Verification:** Any missing parent, hash corruption, missing evaluation, or invalid candidate must immediately fail closed.

---

## 4. Detailed Component Technical Design

### 4.1 Policy Bridge & Snapshot Generation (`app/loop/policy.py`)
In `LoopPolicy.from_pinned_execution_policy(policy, scope, section_index, **overrides)`:
- Compute finite integer limits:
  - `max_provider_seconds = int(min(float(getattr(policy, "provider_call_seconds", 180)), 180.0))`
  - `max_wall = int(min(float(getattr(policy, "run_wall_seconds" if is_paper else "section_wall_seconds", 2700 if is_paper else 900)), 2700.0 if is_paper else 900.0))`
  - `max_tokens = int(min(int(getattr(policy, "run_token_cap" if is_paper else "section_token_cap", 300_000 if is_paper else 100_000)), 300_000 if is_paper else 100_000))`
  - `max_calls = int(getattr(policy, "run_call_cap" if is_paper else "section_call_cap", 30 if is_paper else 15))`
- Construct `snapshot`:
  ```python
  snapshot = {
      "profileVersion": "pinned-execution-v2",
      "profileSource": f"PinnedExecutionPolicy ({getattr(policy, 'provider', 'pinned')})",
      "policyHash": policy_hash,
      "benchmarkMode": "LIMITED",
      "benchmarkMonetaryCapMode": "LIMITED",
      "caps": {
          "loopMaxVersions": 3,
          "loopMaxGeneratedVersions": 3,
          "loopMaxRepairAttemptsPerVersion": 2,
          "loopMaxTotalRepairs": int(getattr(policy, "max_repairs", 2)),
          "loopMaxConsecutiveNoProgress": 2,
          "loopMaxOscillationCycles": 2,
          "loopMaxTotalCalls": max_calls,
          "loopMaxTotalTokens": max_tokens,
          "loopMaxWallTimeSeconds": max_wall,
          "generateTokenReservation": min(15_000, max_tokens),
          "passageGenerateTokenReservation": min(15_000, max_tokens),
          "passageGenerateMaxTokens": min(15_000, max_tokens),
          "evaluateTokenReservation": min(10_000, max_tokens),
          "repairTokenReservation": min(15_000, max_tokens),
          "loopOperationWallReservationSeconds": max_provider_seconds,
          "loopMaxResponseBytes": 500_000,
          "evaluatorSemanticTimeoutSeconds": 30,
          "evaluatorStageTimeoutSeconds": 60,
          "evaluatorDeterministicTimeoutSeconds": 5,
          "repairTimeoutSeconds": 30,
          "repairMaxTokensPerAttempt": 3000,
          "evaluatorMaxTokensPerEvaluation": 4000,
          # .NET CheckpointService MatchesRunBudget compatibility keys:
          "standaloneRunBudgetCapCalls": max_calls,
          "standaloneRunBudgetCapTokens": max_tokens,
          "standaloneRunBudgetCapWallTimeSeconds": max_wall,
      },
  }
  ```
- Calculate canonical `cap_sha256 = cap_snapshot_sha256(snapshot)`.
- Set `cap_profile_sha256 = cap_sha256` and expose `policy_hash = policy_hash` as a distinct field/property on `LoopPolicy`.

### 4.2 Immutable Recovery & Evaluation Ledger Verification (`app/loop/passage.py` & `app/loop/section.py`)
In `PassageLoop.run()` and `SectionLoop.run()`:
1. **Strict Parent Validation:**
   ```python
   parents_match_input = tuple(accepted_envelope.parent_refs) == tuple(expected_input_deps)
   parents_valid = len(accepted_envelope.parent_refs) == len(expected_input_deps) and all(
       p.artifact_id in store_accepted_heads and store_accepted_heads[p.artifact_id] == p
       for p in accepted_envelope.parent_refs
   )
   ```
2. **Mandatory Evaluation Ledger Check:**
   - Retrieve `evaluations = getattr(resume_state, "evaluations", None) or []`.
   - Filter evaluations for `target_ref == accepted_envelope.to_ref()`.
   - Validate that all `self.policy.required_evaluator_ids` are present in `evaluations` with:
     - `status == EvaluationStatus.PASS`
     - Matching `target_ref` and `parent_refs`
     - Non-empty `evaluator_version`
   - If evaluations are valid, complete, and passing: return zero-call `LoopResult(decision=DecisionType.PASS, acceptedArtifact=accepted_envelope, callsCount=0, tokensConsumed=0)`.
   - If evaluations are missing or incomplete: do not award zero-call `PASS`. Log that accepted artifact requires revalidation, and pass `current_artifact = accepted_envelope` to `BoundedLoopRuntime`. The runtime enters `LoopState.EVALUATING` to execute required evaluators and commit the verified evaluation ledger before final acceptance.

### 4.3 Candidate Correctness & Validation (`app/generators/question/generator.py`)
In `build_pool_from_raw_candidates()`:
- **Prompt:**
  ```python
  raw_prompt = str(raw.get("prompt") or "").strip()
  if not raw_prompt:
      rejection_reasons.append("Missing prompt")
      raw_prompt = "[MISSING]"
  ```
- **Evidence Quote:**
  ```python
  ev_quote = str(raw.get("evidenceQuote") or "").strip()
  if passage_text:
      is_not_given = family in (
          QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN,
          QuestionPromptFamily.YES_NO_NOT_GIVEN,
      ) and raw_ans in ("NOT GIVEN", "NOT_GIVEN", "NG")

      if not ev_quote and not is_not_given:
          rejection_reasons.append("Missing evidence quote")
      elif ev_quote and ev_quote.casefold() not in passage_text.casefold():
          # Strict check without length-based bypass
          rejection_reasons.append(f"Evidence quote is unsupported by passage: '{ev_quote[:60]}'")
  ```
- **MCQ Option Mapping:**
  If `family == QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE`:
  - If `not matched_key`:
    `rejection_reasons.append(f"Answer key '{raw_ans_str}' not found in options")`
- **Candidate Rejection:**
  Any candidate with `rejection_reasons` must have `cand.rejected = True`.

### 4.4 Mandatory Acceptance Gates in Question Loop (`app/loop/question.py`)
- In `QuestionCandidateLoop.__init__`:
  Ensure `self.policy.required_evaluator_ids` includes the mandatory semantic and blind-solver gates:
  - `"eval_question_structure"`
  - `"eval_answer_verbatim_length"`
  - `"eval_blind_solver_adversary"` (when solver evaluator registered)
  - `"eval_grounding_fidelity"` (when grounding evaluator registered)

### 4.5 Deterministic Operation Recovery & Scope Compatibility (`app/loop/question.py` & `app/loop/runtime.py`)
1. **Deterministic Workflow Recovery:**
   - Deterministic workflow operation ID format:
     `expected_workflow_op_id = f"op_workflow_qcand_s{section_index}_{run_id[:8]}"`
   - Deterministic request hash:
     `wf_req_hash = f"workflow:questions:s{section_index}:{run_id}:v1"`
   - Match existing reserved workflow from `stored_state.operations` via projected `operationId`:
     ```python
     matching_reserved = [
         o for o in (stored_state.operations or [])
         if o.operationType == "WORKFLOW"
         and o.status == "RESERVED"
         and o.operationId == expected_workflow_op_id
     ]
     if matching_reserved:
         workflow_op_id = matching_reserved[0].operationId
     else:
         workflow_op_id = expected_workflow_op_id
     ```
   - Grant workflow with `sectionId = str(section_index)`.
2. **Scope Normalization with .NET `CheckpointService.cs`:**
   - In `BoundedLoopRuntime._reserve`:
     Inspect `parent_op = self._parent_operation_id()`. If parent operation exists in `self._operations` or resume state, inherit the parent's `sectionId` to prevent string mismatch on `CheckpointService.cs:445`. Otherwise, use `str(self.context.section_id)`.

---

## 5. Architectural Calls Made by Builder

1. **Deterministic Workflow ID via `operationId`:** Because `OperationResumeInfo` projects `operationId` but omits `sectionId`, deterministic recovery relies on `f"op_workflow_qcand_s{section_index}_{run_id[:8]}"`, ensuring clean round-trips without cross-service DTO modifications.
2. **Revalidation Pathway for Incomplete Artifacts:** When an accepted artifact in resume state lacks required evaluation evidence, rather than crashing with an unhandled exception or mutating historical database records, the loop classifies the artifact as needing revalidation and invokes the evaluation pipeline on the preserved envelope.
3. **SectionId Inheritance:** If a parent operation has an existing `SectionId` (e.g. `"section_1"` or `"1"`), child operations adopt that exact string formatting to guarantee parent-child consistency checks in .NET pass without modifying `CheckpointService.cs`.
4. **Strict Zero-Bypass Quote Check:** All evidence quotes of any non-zero length must exist verbatim (case-insensitive) in the passage text, eliminating the previous `>= 15` char threshold.

---

## 6. Verification and Acceptance Criteria

1. **New Regression Suite (`tests/test_s01_corrective_regression.py`):**
   - Scenario 1: Policy bridge snapshot passes `from_cap_snapshot` and `validate_cap_bounds` with identical hashes.
   - Scenario 2: Zero-call resume requires complete passing evaluations; missing evaluations trigger revalidation.
   - Scenario 3: Missing parent ref in `store_accepted_heads` fails closed (no loophole bypass).
   - Scenario 4: Short invalid evidence quote (<15 chars) is rejected.
   - Scenario 5: Missing prompt is rejected fail-closed (no fabricated prompt).
   - Scenario 6: MCQ with answer not matching parsed options is rejected.
   - Scenario 7: Question workflow recovery isolates Section 1 from Section 2/3 deterministically.
   - Scenario 8: Child operation inherits parent `SectionId` preventing 422 mismatch.
2. **Documented Specification Conflicts:**
   - `test_regression_01` (evaluations requirement) and `test_regression_08` (hash separation) in `test_legacy_hardening_regression.py` remaining RED will be recorded in `reports/unified-flow/S01-CORRECTIVE-VERIFICATION.md` as expected consequences of enforcing academic acceptance invariants.
3. **Execution Report:**
   - Comprehensive `reports/unified-flow/S01-CORRECTIVE-VERIFICATION.md` documenting root-cause matrix, diff, test logs, and GO/NO-GO assessment.
