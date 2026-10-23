# Langfens Autonomous Reading Engine — Hybrid Repair Production Integration Gate Report

**Document ID:** `REPORT-2026-10-23-HYBRID-REPAIR-PRODUCTION-INTEGRATION-GATE`  
**Location:** `docs/reports/HYBRID_REPAIR_PRODUCTION_INTEGRATION_GATE.md`  
**Repository:** `minkhoaa/Project_Langfens_Microservice`  
**Branch:** `autonomous-generation`  
**Starting Commit:** `f2614b537eeb41a874d771562ad40cf97d2f0b0e`  
**Verification Target:** Production Integration of Hybrid MiniMax-Text-01 + MiniMax-M3 Repair Path  
**Gate Status:** **`PASS`**  

---

## 1. Executive Summary & Gate Objective

This gate verifies and hardens the production integration of the **Hybrid MiniMax-Text-01 + MiniMax-M3 repair loop** in the Langfens Autonomous Reading Engine.

Following the initial offline replays (`test_hybrid_offline_replays.py`) and single isolated live pilot (`HYBRID_TEXT_M3_REPAIR_PILOT.md`), several production-integration defects were identified that prevented reliable end-to-end operation in the actual production pipeline:
1. **Context and Authority Mismatch:** The production pipeline passes `RunContext`, exposing `epoch` and `lease_owner` directly, while downstream repair components expected `LoopContext.authority`. When missing, fallback logic fabricated random lease owners via `uuid4()` and defaulted `epoch` to 1, breaking checkpoint fencing.
2. **Contract Deficiencies in RepairPlan Validation:** Validation allowed unknown issue codes to fail open, lacked `DUPLICATE_CONTENT` in permitted action mappings, permitted fallback claim ID fabrication (`f"claim_s{sec_id_str}_q{q_num_val}"`), and did not check `target_question` or eligible issue codes against detected failures.
3. **Non-Durable Operation Identities:** Both M3 planning and Text-01 regeneration generated non-deterministic `uuid4().hex[:8]` operation IDs, defeating checkpoint idempotency and re-dispatching completed operations on restart.

All defects were isolated, minimally repaired, and verified using 10 comprehensive production-path offline integration tests exercising the real `SectionRunner` repair callback with production-shaped `RunContext` and fenced `CheckpointClient`.

**Final Gate Verdict:** **`HYBRID_PRODUCTION_INTEGRATION: PASS`**

---

## 2. Reproduced Defects & Root Cause Analysis

### 2.1 Context and Lease Authority Mismatch
- **Execution Chain:**  
  `SectionRunner → StageExecutor → BoundedLoopRuntime → QuestionItemRepairer → RepairPlanningCapability → QuestionCandidateGenerator`
- **Root Cause:**  
  In production, `SectionRunner.run` receives `RunContext` (from `reading_models.py`), which exposes `epoch: int` and `lease_owner: UUID` at the root level.
  However, `QuestionItemRepairer._repair_impl` attempted `auth_grant = getattr(context, "authority", None)`, and when `auth_grant` was `None`, executed:
  ```python
  lease_owner = getattr(auth_grant, "lease_owner", uuid4())  # Fabricated new UUID!
  epoch = getattr(auth_grant, "epoch", 1)                     # Silently defaulted to epoch 1!
  ```
  Furthermore, `QuestionCandidateGenerator.generate_candidate_pool` attempted:
  ```python
  epoch=context.authority.epoch,
  lease_owner=context.authority.lease_owner
  ```
  which raised `AttributeError: 'RunContext' object has no attribute 'authority'` when passed `RunContext`.
- **Checkpoint Impact:**  
  Fabricating a random `lease_owner` UUID causes `CheckpointClient.fence` to reject grants with `HTTP 403 (lease lost)`. Defaulting `epoch` to 1 causes `HTTP 409 (epoch fenced)` whenever a run advances beyond epoch 1.

### 2.2 Incomplete RepairPlan Safety Contract
- **Root Cause:**  
  In `services/generation-service/app/repair/contracts.py`:
  - `ALLOWED_ACTIONS_FOR_ISSUE.get(plan.issue_code)` returned `None` for unknown or unconfigured issue codes. The check `if allowed is not None and plan.repair_action not in allowed:` silently passed when `allowed is None` (fail-open defect).
  - `IssueCode.DUPLICATE_CONTENT` was omitted from `ALLOWED_ACTIONS_FOR_ISSUE`, despite being handled in the repair loop.
  - `validate_repair_plan_compatibility` did not verify `plan.target_question == target_q_num`, permitting plans to target unrelated questions.
  - `validate_repair_plan_compatibility` did not verify that `plan.issue_code` was among the detected authoritative issues.
  - In `services/generation-service/app/repair/question.py`, if a question lacked a claim reference, fallback claim fabrication was performed: `auth_claim_ref = ... or f"claim_s{sec_id_str}_q{q_num_val}"`.

### 2.3 Non-Deterministic Operation Identities
- **Root Cause:**  
  - In `RepairPlanningCapability.plan_repair`: `op_id = f"op_m3_plan_q{target_q_num}_{uuid4().hex[:8]}"`
  - In `QuestionCandidateGenerator.generate_candidate_pool`: `op_id = f"gen_qpool_{question_number}_{uuid4().hex[:8]}"`
- **Checkpoint Replay Impact:**  
  `ProviderGateway` guarantees idempotency and prevents duplicate billing by querying the checkpoint client for completed operations matching `attempt_operation_id`. Because these IDs contained random UUID hex fragments, every process restart or crash recovery generated fresh operation IDs, bypassing replay cache and duplicating LLM billing.

---

## 3. Minimal Fixes Implemented

### 3.1 Unified Authority Adapter (`RunAuthorityAdapter` and `resolve_run_authority`)
- **File:** `services/generation-service/app/loop/context.py`
  - Defined `RunAuthorityAdapter`: Canonical model carrying validated `lease_owner: UUID`, `epoch: int >= 1`, and `run_id: Optional[str]`, exposing `@property def authority -> AuthorityGrant` and `check_authority()`.
  - Implemented `resolve_run_authority(context: Any) -> RunAuthorityAdapter`:
    - Validates that `context` is non-null.
    - Resolves `epoch` from direct `context.epoch` or `context.authority.epoch`. Rejects missing epoch (no default to 1) and verifies `epoch >= 1`. If both exist, verifies consistency (`direct == nested`).
    - Resolves `lease_owner` from direct `context.lease_owner` or `context.authority.lease_owner`. Rejects missing lease owner (no `uuid4()` fabrication) and verifies valid UUID format. If both exist, verifies consistency.
    - Rejects missing or inconsistent authority **before any provider dispatch**.
  - Added properties on `LoopContext`: `@property def epoch` and `@property def lease_owner`.
- **File:** `services/generation-service/app/reading_models.py`
  - Added property on `RunContext`: `@property def authority -> AuthorityGrant`.
- **File:** `services/generation-service/app/evaluators/solver.py`
  - Integrated `resolve_run_authority` in `BlindSolverEvaluator.evaluate_blind_input` to eliminate fallback `uuid4()` and default `epoch=1`.

### 3.2 Hardened RepairPlan Contract
- **File:** `services/generation-service/app/repair/contracts.py`
  - Added `IssueCode.DUPLICATE_CONTENT` to `ALLOWED_ACTIONS_FOR_ISSUE` mapped to `{RepairAction.REGENERATE_DISTINCT_CANDIDATE, RepairAction.REPHRASE_STEM}`.
  - Updated `validate_repair_plan_compatibility` with optional parameters `target_question: Optional[int] = None` and `eligible_issues: Optional[Sequence[Any]] = None`:
    - Verifies `plan.target_question == target_question`.
    - Verifies `plan.issue_code` matches one of `eligible_issues`.
    - Fails closed when `allowed is None` (`Unsupported issue code '{code}'; no permitted repair actions configured`).
    - Enforces claim preservation: `plan.preserve_evidence_claim_ref == authoritative_claim_ref`.
- **File:** `services/generation-service/app/repair/diagnostic_planner.py`
  - In `RepairPlanningCapability.plan_repair`:
    - Validates `lease_owner` is not None and `epoch >= 1` upfront.
    - Removed `epoch: int = 1` default from function signature.
    - Catches `TruncatedOutputError`, `ProviderTimeoutError`, and `DeadlineExceededError` fail-closed with `RepairJustificationError`.
    - Passes `target_question=target_q_num` and `eligible_issues=issues` into `validate_repair_plan_compatibility`.

### 3.3 Stable Durable Operation Identities
- **File:** `services/generation-service/app/repair/diagnostic_planner.py`
  - Replaced random UUID generation with deterministic operation ID:
    ```python
    if parent_operation_id:
        op_id = f"{parent_operation_id}:m3_plan:q{target_q_num}"
    else:
        op_id = f"op:{run_id}:repair_plan:q{target_q_num}"
    ```
- **File:** `services/generation-service/app/generators/question/generator.py`
  - Replaced random UUID generation in `generate_candidate_pool` with deterministic operation ID:
    ```python
    auth = resolve_run_authority(context)
    eff_parent_op = parent_operation_id or (getattr(context, "parent_operation_id", None) if context else None)
    if eff_parent_op:
        op_id = f"{eff_parent_op}:text_regen:q{question_number}"
    else:
        op_id = f"op:{run_id}:qpool:q{question_number}"
    ```
  - Replaced random UUID in `generate_summary_group_candidates` with deterministic operation ID using `resolve_run_authority(context)`.

### 3.4 Wire Repair Callbacks in SectionRunner & QuestionItemRepairer
- **File:** `services/generation-service/app/section_runner.py`
  - `repair_question_item` callback instantiates `QuestionItemRepairer(gateway=self.gateway)` passing `self.gateway` explicitly.
  - Accepts `intent_id: Optional[str] = None` and passes `effective_intent_id = intent_id or f"op_repair_q_{ver}"` to `item_rep.repair`.
- **File:** `services/generation-service/app/stage_executor.py`
  - In `StageRepAdapter.repair`: passes `intent_id=intent_id` into the custom `repair` callback.
  - Instantiates `fallback_rep` with `gateway=getattr(self.context, "gateway", None)`.
- **File:** `services/generation-service/app/repair/question.py`
  - Added `enable_hybrid: bool = True` to `QuestionItemRepairer.__init__`.
  - In `_repair_impl`:
    - Fails closed with `RepairJustificationError` if question lacks verified blueprint claim (no fallback fabrication).
    - Uses `resolve_run_authority(context)` to retrieve `auth.lease_owner` and `auth.epoch`.
    - Enforces grounded verification when a candidate modifies an existing answer (`eff_quote` must appear in passage).
    - When `enable_hybrid` is False, bypasses M3 and executes existing Text-only repair logic.

---

## 4. Production-Path Offline Integration Tests

A comprehensive integration test suite was created in:  
`services/generation-service/tests/test_hybrid_production_integration.py`

All 10 requirements are verified against the real `SectionRunner` repair callback, production `RunContext`, and `FencedTestCheckpointClient`:

| # | Test Name | Invariants Verified | Status |
|---|---|---|---|
| 1 | `test_successful_m3_plan_followed_by_text01_regeneration` | Production `RunContext` executes repair callback; M3 plans; Text-01 regenerates with M3 constraints; V2 artifact accepted with preserved claim. | **PASS** |
| 2 | `test_missing_or_incorrect_authority_rejected_before_dispatch` | Missing `lease_owner`, inconsistent `epoch`, and invalid `epoch` (< 1) rejected fail-closed before any provider call. Zero dispatches. | **PASS** |
| 3 | `test_correct_epoch_and_lease_owner_propagated_to_both_providers` | Epoch (7) and non-default `lease_owner` UUID propagate identically to M3 planning, Text-01 regeneration, and checkpoint client. | **PASS** |
| 4 | `test_invalid_repair_action_or_mismatched_question_rejected` | Plans targeting wrong question number (Q99 vs Q2) or incompatible action (`SWAP_DISTRACTOR` for cloze) rejected fail-closed. Text-01 not called. | **PASS** |
| 5 | `test_unknown_issue_action_combination_rejected` | Unsupported issue codes (not in `ALLOWED_ACTIONS_FOR_ISSUE`) and issue code mismatches fail closed before regeneration. | **PASS** |
| 6 | `test_evidence_claim_remains_immutable_and_no_fallback_fabrication` | Claim tampering rejected immediately; questions without bound claims fail closed without fallback fabrication. | **PASS** |
| 7 | `test_repaired_question_passes_required_evaluations` | Repaired question candidate passes deterministic evaluation suite (`eval_question_structure`, `eval_answer_verbatim_length`, `eval_evidence_offsets`, `eval_question_uniqueness`, `eval_question_semantic`). | **PASS** |
| 8 | `test_m3_truncation_and_timeout_handled_fail_closed` | `TruncatedOutputError` and `ProviderTimeoutError` fail closed with `RepairJustificationError`. No partial plans applied. | **PASS** |
| 9 | `test_crash_restart_preserves_durable_operation_identity_without_duplicate_billing` | Stable operation IDs `{intent_id}:m3_plan:q2` and `{intent_id}:text_regen:q2` allow idempotent replay from persistence without repeating LLM calls. | **PASS** |
| 10 | `test_existing_text_only_behavior_unchanged_when_hybrid_disabled` | When `enable_hybrid=False`, M3 planning is bypassed entirely (`m3_call_count == 0`), and Text-only regeneration executes normally. | **PASS** |

---

## 5. Verification Execution Evidence

### Fast Offline Test Suite
```bash
$ services/generation-service/.venv/bin/pytest services/generation-service/tests/test_hybrid_production_integration.py -v
============================== 10 passed in 0.64s ==============================
```

### Full Hybrid & Repair Test Suite
```bash
$ services/generation-service/.venv/bin/pytest \
    services/generation-service/tests/test_hybrid*.py \
    services/generation-service/tests/test_repair*.py -v
============================== 29 passed in 0.95s ==============================
```

### Phase 15 & Evaluator Regression Suites
```bash
$ services/generation-service/.venv/bin/pytest \
    services/generation-service/tests/test_phase15*.py \
    services/generation-service/tests/test_t07_evaluators_repairs.py -v
============================= 167 passed in 2.65s ==============================
```

### Unified SectionRunner Pipeline Suites
```bash
$ services/generation-service/.venv/bin/pytest services/generation-service/tests/unified/ -v
======================= 114 passed in 170.36s (0:02:50) ========================
```

---

## 6. Remaining Blockers & Next Steps

- **Live E2E Generation:** Not launched during this gate per prompt directive (*"Do not launch a full LIVE job during this gate. STOP after verification. No automatic Full E2E or additional MiniMax calls."*).
- **Production Gate Cleared:** The production-integration defects preventing robust Hybrid Text-01 + M3 operation are resolved, fenced, and verified offline. Full E2E generation may proceed in a subsequent, operator-authorized gate.

---

## Final Gate Verdict

```text
HYBRID_PRODUCTION_INTEGRATION: PASS
```
