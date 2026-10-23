# Hybrid Text-01 + M3 Repair Planning Pilot Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement and test a minimal Hybrid Reasoning–Generation Loop in the development environment pairing `MiniMax-Text-01` (generation/rewriting) and `MiniMax-M3` (diagnostic reasoning/repair planning) under authoritative `BoundedLoopRuntime` control.

**Architecture:** Model routing is operation-scoped and pinned per request without mutating global `MINIMAX_MODEL`. `RepairPlanningCapability` invokes `MiniMax-M3` exclusively on eligible semantic/adversarial evaluation failures to produce a strictly typed `RepairPlan` with an immutable claim reference, which is then fed to `MiniMax-Text-01` for targeted regeneration, while `BoundedLoopRuntime` enforces all budgets, version caps, and fail-closed policies.

**Tech Stack:** Python 3.12/3.14, Pydantic v2, FastAPI, OpenAI-compatible Async Client, PostgreSQL/EF Core checkpoint persistence, pytest / pytest-asyncio.

**Spec:** User directive for LANGFENS — HYBRID TEXT + M3 REPAIR PLANNING PILOT (Phases 1 through 5).

## Global Constraints

- Never globally change `MINIMAX_MODEL` or settings during active runs; use operation-scoped `pinned_model`.
- Maintain strict 5-member `RepairAction` enum: `REPHRASE_STEM`, `SWAP_DISTRACTOR`, `REFINE_CLOZE_TARGET`, `CLARIFY_NOT_GIVEN_BOUNDARY`, `REGENERATE_DISTINCT_CANDIDATE`.
- Keep `preserveEvidenceClaimRef` strictly immutable matching the bound claim reference; reject any claim mutation fail-closed.
- Mechanical failures (e.g. `QUOTE_TRUNCATION`, simple answer word trimming) must be handled by existing deterministic logic and candidate pool regeneration; never invoke M3 for purely mechanical defects.
- M3 is strictly an advisory repair planner; it never directly commits artifacts, mutates state, or executes arbitrary tools.
- Never silently increase budgets or force 8,192 tokens for repair planning requests; respect explicit `max_tokens` (e.g., 2048) and accurately record `reasoning_tokens`.
- On provider failure or truncation (`finish_reason=length`), capture and reconcile real reported tokens (prompt, completion, and reasoning) rather than treating them as zero.
- Run exactly ONE isolated live repair pilot after offline tests pass; do not launch a full 40-question campaign or benchmark suite.

## Review Focus

1. **Reasoning Token Accounting on Truncation:** When M3 or any provider hits `finish_reason=length`, reported tokens and reasoning tokens must be reconciled into PostgreSQL checkpoints rather than recorded as 0.
2. **Claim Mutation Rejection:** When M3 returns a `RepairPlan` with a mutated or missing `preserveEvidenceClaimRef`, the plan must be rejected and fail closed.
3. **Mechanical vs Semantic Disambiguation:** `QUOTE_TRUNCATION` and word-limit trims must not trigger M3 calls; only semantic/adversarial issues (`AMBIGUOUS_ANSWER`, solver disagreement, duplicate prompt) trigger M3.
4. **Operation Hashing with Model Identity:** Attempt hash and grant requests must incorporate the pinned model name so replays and audit trails distinguish Text-01 from M3.
5. **Fail-Closed on M3 Invalidity:** If M3 times out, returns malformed JSON, or proposes an incompatible `RepairAction` for the given `IssueCode`, the repair loop fails closed without unbounded fallback loops.

---

### Task 1: Operation-Scoped Model Routing & Usage Accounting Fixes

**Files:**
- Modify: `services/generation-service/app/providers/models.py`
- Modify: `services/generation-service/app/providers/base.py`
- Modify: `services/generation-service/app/providers/adapters/openai_compatible.py`
- Modify: `services/generation-service/app/providers/adapters/minimax.py`
- Modify: `services/generation-service/app/providers/gateway.py`
- Test: `services/generation-service/tests/test_model_routing_and_accounting.py`

**Interfaces:**
- Produces: `ProviderRequest.pinned_model: Optional[str]`, `Capability.PLAN_REPAIR`, `BaseProvider.get_model_name(model_size: str, pinned_model: Optional[str] = None) -> str`.
- Preserves: `UsageReport.reasoning_tokens` attached to `TruncatedOutputError` on length truncation.

- [ ] **Step 1: Write failing tests for pinned model routing and truncation token accounting**

```python
# test_model_routing_and_accounting.py
@pytest.mark.asyncio
async def test_pinned_model_overrides_default_model_in_call_and_hash():
    ...
@pytest.mark.asyncio
async def test_truncation_preserves_reported_and_reasoning_tokens():
    ...
@pytest.mark.asyncio
async def test_minimax_adapter_respects_request_max_tokens_for_m3():
    ...
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd services/generation-service && .venv/bin/pytest tests/test_model_routing_and_accounting.py -v`
Expected: FAIL (AttributeError or ValidationError for pinned_model / missing Capability)

- [ ] **Step 3: Implement `pinned_model` in `ProviderRequest` and `Capability.PLAN_REPAIR`**

In `app/providers/models.py`:
- Add `PLAN_REPAIR = "plan_repair"` to `Capability`.
- Add `pinned_model: Optional[str] = Field(default=None, description="Operation-scoped explicit model override (e.g. MiniMax-M3)")` to `ProviderRequest`.

In `app/providers/base.py`:
- Update `get_model_name(self, model_size: str, pinned_model: Optional[str] = None) -> str`: return `pinned_model` if provided, else resolve alias.
- Update `conservative_token_reservation`: pass `request.pinned_model`.

In `app/providers/adapters/openai_compatible.py`:
- In `_build_create_kwargs`: resolve `model_name = request.pinned_model or self.get_model_name(request.model_size)`.
- In `call()`: resolve `model_name = request.pinned_model or self.get_model_name(request.model_size)`.
- In `call()`: compute `usage` (including `reasoning_tokens`) BEFORE raising `TruncatedOutputError` on `finish_reason == "length"`, and attach `trunc_err.usage = usage`.

In `app/providers/adapters/minimax.py`:
- Modify `_build_create_kwargs`: do not force 8192 if `request.max_tokens` is smaller and bounded (e.g. for repair planning); respect `request.max_tokens`. Preserve `extra_body = {"reasoning_split": True, "reasoning_effort": "low"}`.

In `app/providers/gateway.py`:
- Include `pinnedModel: request.pinned_model` in `logical_hash` and `attempt_hash`.
- Pass `model_name` correctly to token accountant and checkpoint reconcile request.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd services/generation-service && .venv/bin/pytest tests/test_model_routing_and_accounting.py -v`
Expected: PASS

- [ ] **Step 5: Commit Task 1**

```bash
git add services/generation-service/app/providers/ services/generation-service/tests/test_model_routing_and_accounting.py
git commit -m "feat(providers): introduce operation-scoped pinned_model routing and failure token accounting"
```

---

### Task 2: Strict Versioned `RepairAction` & `RepairPlan` Contracts

**Files:**
- Create: `services/generation-service/app/repair/contracts.py`
- Test: `services/generation-service/tests/test_repair_plan_contracts.py`

**Interfaces:**
- Produces: `RepairAction` enum (5 strict members), `RepairPlan` schema, `validate_repair_plan_compatibility(plan: RepairPlan, original_claim_ref: str) -> None`.

- [ ] **Step 1: Write failing tests for RepairAction and RepairPlan validation**

```python
# test_repair_plan_contracts.py
def test_valid_repair_plan_passes_validation():
    ...
def test_invalid_repair_action_rejected():
    ...
def test_incompatible_issue_code_and_action_rejected():
    ...
def test_claim_mutation_rejected():
    ...
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd services/generation-service && .venv/bin/pytest tests/test_repair_plan_contracts.py -v`
Expected: FAIL (ModuleNotFoundError: No module named 'app.repair.contracts')

- [ ] **Step 3: Implement `RepairAction`, `RepairPlan`, and validation logic**

In `services/generation-service/app/repair/contracts.py`:
- Define `RepairAction(str, Enum)`:
  - `REPHRASE_STEM = "REPHRASE_STEM"`
  - `SWAP_DISTRACTOR = "SWAP_DISTRACTOR"`
  - `REFINE_CLOZE_TARGET = "REFINE_CLOZE_TARGET"`
  - `CLARIFY_NOT_GIVEN_BOUNDARY = "CLARIFY_NOT_GIVEN_BOUNDARY"`
  - `REGENERATE_DISTINCT_CANDIDATE = "REGENERATE_DISTINCT_CANDIDATE"`
- Define `RepairPlan(CanonicalBaseModel)`:
  - `issue_code: IssueCode = Field(..., alias="issueCode")`
  - `target_question: int = Field(..., alias="targetQuestion")`
  - `repair_action: RepairAction = Field(..., alias="repairAction")`
  - `diagnosis: str`
  - `repair_constraints: List[str] = Field(default_factory=list, alias="repairConstraints")`
  - `preserve_evidence_claim_ref: str = Field(..., alias="preserveEvidenceClaimRef")`
  - `expected_correction: Optional[str] = Field(default=None, alias="expectedCorrection")`
- Define compatibility rules mapping `IssueCode` to permitted `RepairAction` sets.
- Define `validate_repair_plan_compatibility(plan: RepairPlan, authoritative_claim_ref: str) -> None`:
  - Enforce `plan.preserve_evidence_claim_ref == authoritative_claim_ref`.
  - Enforce `plan.repair_action in ALLOWED_ACTIONS_FOR_ISSUE[plan.issue_code]`.
  - Enforce non-empty `diagnosis` and non-empty `repair_constraints`.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd services/generation-service && .venv/bin/pytest tests/test_repair_plan_contracts.py -v`
Expected: PASS

- [ ] **Step 5: Commit Task 2**

```bash
git add services/generation-service/app/repair/contracts.py services/generation-service/tests/test_repair_plan_contracts.py
git commit -m "feat(repair): define strict RepairAction enum and validated RepairPlan schema"
```

---

### Task 3: Implement `RepairPlanningCapability` (MiniMax-M3)

**Files:**
- Create: `services/generation-service/app/repair/diagnostic_planner.py`
- Modify: `services/generation-service/app/repair/__init__.py`
- Test: `services/generation-service/tests/test_repair_planning_capability.py`

**Interfaces:**
- Consumes: `ProviderGateway`, `ProviderRequest`, `RepairPlan`, `RepairAction`.
- Produces: `RepairPlanningCapability.plan_repair(...) -> RepairPlan`.

- [ ] **Step 1: Write failing tests for RepairPlanningCapability**

```python
# test_repair_planning_capability.py
@pytest.mark.asyncio
async def test_repair_planning_capability_dispatches_to_m3_with_pinned_model():
    ...
@pytest.mark.asyncio
async def test_repair_planning_fails_closed_on_invalid_json():
    ...
@pytest.mark.asyncio
async def test_repair_planning_fails_closed_on_claim_tampering():
    ...
@pytest.mark.asyncio
async def test_repair_planning_fails_closed_on_timeout():
    ...
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd services/generation-service && .venv/bin/pytest tests/test_repair_planning_capability.py -v`
Expected: FAIL (ModuleNotFoundError: No module named 'app.repair.diagnostic_planner')

- [ ] **Step 3: Implement `RepairPlanningCapability`**

In `services/generation-service/app/repair/diagnostic_planner.py`:
- Create class `RepairPlanningCapability`:
  - `__init__(self, gateway: ProviderGateway, model_id: str = "MiniMax-M3")`
  - `async def plan_repair(...) -> RepairPlan`:
    * Construct prompt presenting the question, answer, passage context, authoritative evidence claim, validator issues, solver feedback, previous repair attempts, and remaining budget.
    * Specify the exact output schema matching `RepairPlan` with strict `repairAction` choices.
    * Build `ProviderRequest` with:
      - `capability=Capability.PLAN_REPAIR`
      - `preferred_provider="minimax"`
      - `pinned_provider="minimax"`
      - `pinned_model=self.model_id`
      - `max_tokens=2048`
      - `temperature=0.1`
      - `target_model=RepairPlan`
      - `response_schema=RepairPlan.model_json_schema()`
    * Call `await self.gateway.execute(request, ...)`.
    * Validate the returned plan with `validate_repair_plan_compatibility(plan, authoritative_claim_ref)`.
    * Raise `RepairJustificationError` or `RepairExecutionError` fail-closed if validation fails.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd services/generation-service && .venv/bin/pytest tests/test_repair_planning_capability.py -v`
Expected: PASS

- [ ] **Step 5: Commit Task 3**

```bash
git add services/generation-service/app/repair/diagnostic_planner.py services/generation-service/app/repair/__init__.py services/generation-service/tests/test_repair_planning_capability.py
git commit -m "feat(repair): implement M3-powered RepairPlanningCapability"
```

---

### Task 4: Integrate M3 Repair Planning into Question Candidate Loop

**Files:**
- Modify: `services/generation-service/app/repair/question.py`
- Modify: `services/generation-service/app/generators/question/generator.py`
- Modify: `services/generation-service/app/generators/question/prompts.py`
- Modify: `services/generation-service/app/loop/question.py`
- Test: `services/generation-service/tests/test_hybrid_question_repair_integration.py`

**Interfaces:**
- Consumes: `RepairPlanningCapability`, `QuestionItemRepairer`, `QuestionCandidateGenerator`.
- Produces: Integrated hybrid repair flow: Evaluator failure -> M3 Diagnostic Plan -> Text-01 Constrained Regeneration -> Re-evaluation.

- [ ] **Step 1: Write failing tests for hybrid question repair integration**

```python
# test_hybrid_question_repair_integration.py
@pytest.mark.asyncio
async def test_mechanical_issue_quote_truncation_bypasses_m3():
    ...
@pytest.mark.asyncio
async def test_semantic_adversary_issue_invokes_m3_and_regenerates_with_text01():
    ...
@pytest.mark.asyncio
async def test_m3_planning_failure_fails_closed_without_uncontrolled_retries():
    ...
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd services/generation-service && .venv/bin/pytest tests/test_hybrid_question_repair_integration.py -v`
Expected: FAIL

- [ ] **Step 3: Implement hybrid repair integration**

In `services/generation-service/app/repair/question.py`:
- In `QuestionItemRepairer`:
  - Check issue codes. If purely mechanical (`WORD_LIMIT_EXCEEDED` verbatim trimming, `QUOTE_TRUNCATION` verbatim match fix): execute local deterministic logic.
  - If eligible semantic/adversarial issue (`AMBIGUOUS_ANSWER`, `DUPLICATE_PROMPT`, solver disagreement):
    * Resolve `RepairPlanningCapability` with `gateway`.
    * Obtain `RepairPlan` from M3.
    * Invoke `QuestionCandidateGenerator.generate_candidate_pool` with `repair_constraints=plan.repair_constraints` and `diagnosis=plan.diagnosis` using `pinned_model="MiniMax-Text-01"`.
    * Apply regenerated candidate while verifying distinctness and evidence preservation.
    * If M3 planning fails or plan is invalid, fail closed with `RepairJustificationError`.

In `services/generation-service/app/generators/question/generator.py`:
- Accept optional `repair_constraints: Optional[List[str]] = None` and `diagnosis: Optional[str] = None`.
- If provided, inject them into user prompt instructions for targeted rewriting by Text-01.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd services/generation-service && .venv/bin/pytest tests/test_hybrid_question_repair_integration.py -v`
Expected: PASS

- [ ] **Step 5: Commit Task 4**

```bash
git add services/generation-service/app/repair/question.py services/generation-service/app/generators/question/ services/generation-service/tests/test_hybrid_question_repair_integration.py
git commit -m "feat(repair): integrate M3 repair planning with Text-01 constrained regeneration"
```

---

### Task 5: Offline Replay Tests & Fail-Closed Gate Verification

**Files:**
- Create: `services/generation-service/tests/test_hybrid_offline_replays.py`

**Interfaces:**
- Verifies: Historical failure replays (`AMBIGUOUS_ANSWER`, `DUPLICATE_PROMPT`, `QUOTE_TRUNCATION`, `NOT_GIVEN` semantic disagreement).
- Compares baseline blind regeneration vs M3-assisted repair.

- [ ] **Step 1: Write offline replay tests comparing baseline vs M3 repair**

```python
# test_hybrid_offline_replays.py
@pytest.mark.asyncio
async def test_replay_ambiguous_answer_repaired_via_m3_plan():
    ...
@pytest.mark.asyncio
async def test_replay_duplicate_prompt_repaired_via_regenerate_distinct():
    ...
@pytest.mark.asyncio
async def test_replay_quote_truncation_resolved_mechanically_without_m3():
    ...
@pytest.mark.asyncio
async def test_replay_not_given_semantic_disagreement_repaired_via_m3():
    ...
@pytest.mark.asyncio
async def test_replay_checkpoint_resume_with_pinned_model_operations():
    ...
```

- [ ] **Step 2: Run tests to verify implementation and comparisons**

Run: `cd services/generation-service && .venv/bin/pytest tests/test_hybrid_offline_replays.py -v`
Expected: PASS

- [ ] **Step 3: Run the full fast offline regression suite in generation-service**

Run: `cd services/generation-service && .venv/bin/pytest tests/test_model_routing_and_accounting.py tests/test_repair_plan_contracts.py tests/test_repair_planning_capability.py tests/test_hybrid_question_repair_integration.py tests/test_hybrid_offline_replays.py -v`
Expected: ALL PASS

- [ ] **Step 4: Commit Task 5**

```bash
git add services/generation-service/tests/test_hybrid_offline_replays.py
git commit -m "test(repair): add offline replays and comparative baseline tests for M3 repair"
```

---

### Task 6: Single Isolated Live MiniMax Pilot & Deliverable Report

**Files:**
- Create: `scripts/run_hybrid_live_pilot.py`
- Create: `docs/reports/HYBRID_TEXT_M3_REPAIR_PILOT.md`

**Interfaces:**
- Executes: Exactly ONE live pilot using real `MiniMax-Text-01` and `MiniMax-M3` over the network on a historically failed question context.
- Records: Original candidate, evaluator failure, M3 plan, Text-01 regenerated candidate, final verdict, calls, reasoning tokens, latency, cost.

- [ ] **Step 1: Write single-question isolated live pilot script**

In `scripts/run_hybrid_live_pilot.py`:
- Use real `MINIMAX_API_KEY` from `deploy/envs/ai.env`.
- Pick a grounded passage and historical candidate from Europe PMC / Markdown that triggered `AMBIGUOUS_ANSWER` or blind solver disagreement.
- Run deterministic evaluator -> verify failure -> call M3 for `RepairPlan` -> verify plan -> call Text-01 to rewrite -> run evaluator -> record verdict.
- Capture exact token usage (prompt, completion, reasoning) and latency.

- [ ] **Step 2: Execute single live pilot**

Run: `cd services/generation-service && .venv/bin/python ../../scripts/run_hybrid_live_pilot.py`
Verify: Execution completes with valid M3 reasoning tokens and Text-01 rewrite, all gates checked.

- [ ] **Step 3: Author `docs/reports/HYBRID_TEXT_M3_REPAIR_PILOT.md`**

Document:
- Implementation changes (routing, contracts, capability, loop integration)
- Offline test results and baseline comparison
- LIVE pilot outcome (tokens, reasoning tokens, latencies, costs, recovery verdict)
- Blockers, findings, and recommendation on whether Hybrid should advance to full E2E testing.

- [ ] **Step 4: Commit and push to `origin/autonomous-generation`**

```bash
git add scripts/run_hybrid_live_pilot.py docs/reports/HYBRID_TEXT_M3_REPAIR_PILOT.md
git commit -m "feat(pilot): execute single live MiniMax Text+M3 repair pilot and publish report"
git push origin autonomous-generation
```
