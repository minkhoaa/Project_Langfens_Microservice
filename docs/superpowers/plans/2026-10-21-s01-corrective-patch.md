# S01 Corrective Patch (P0/P1 Blockers) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Correct four critical production defects in the legacy Reading Generation Engine across policy adaptation, immutable checkpoint resumption, question candidate parsing, and deterministic operation recovery.

**Architecture:** Pure fail-closed corrective patches in `services/generation-service/app/` preserving the mature legacy engine contracts. Enforces 32-bit integer snapshot schemas and hash separation in `LoopPolicy`, strict parent closure and evaluation ledger verification in `PassageLoop` / `SectionLoop`, fail-closed candidate parsing in `QuestionCandidateGenerator`, and deterministic `operationId`-based workflow recovery in `QuestionCandidateLoop`.

**Tech Stack:** Python 3.12, FastAPI, Pydantic v2, pytest, pytest-asyncio, .NET 10 CheckpointService contracts.

**Spec:** `docs/superpowers/specs/2026-10-21-s01-corrective-patch-design.md`

---

## Global Constraints

- **Strict Test Integrity:** Existing test files (including `tests/test_legacy_hardening_regression.py`) must NEVER be modified, deleted, or weakened.
- **Specification Conflict Accounting:** `test_regression_01` (evaluations check) and `test_regression_08` (hash separation) turning RED must be recorded as explicit specification conflicts in `reports/unified-flow/S01-CORRECTIVE-VERIFICATION.md`.
- **New Tests Only:** All new behavioral regression tests must reside in `tests/test_s01_corrective_regression.py`.
- **Finite Ceilings:** Provider <= 180s, section <= 900s / 100k tokens, paper <= 2700s / 300k tokens.
- **No Cutover / Rewrites:** No cutover to `StageExecutor`, no live LLM calls, no DB migrations, no mutation of historical accepted S2/S3 artifacts.

---

## Review Focus

1. **Snapshots with float values in integer fields:** `ReadingPaperCapsProfile.cs:MatchesRunBudget` calls `TryGetInt32`; float values cause silent validation failure.
2. **Missing parent references in authoritative heads:** If parent artifact is missing from `store_accepted_heads`, loop must fail closed, not proceed.
3. **Empty or short evidence quotes in non-NOT-GIVEN questions:** Any invalid quote regardless of length must be rejected fail-closed against passage text.
4. **Resumed workflows with stale cross-section identity:** A reserved workflow from Section 1 must never be adopted by Section 2 or 3.
5. **Parent-child SectionId casing/formatting mismatch:** `CheckpointService.cs:445` does exact string comparison; child operations must inherit parent `SectionId` formatting.

---

## Tasks

### Task 1: Policy Bridge & Snapshot Generation Fix (P0-A)

**Files:**
- Modify: `services/generation-service/app/loop/policy.py:220-292`
- Test: `services/generation-service/tests/test_s01_corrective_regression.py`

**Interfaces:**
- Consumes: `PinnedExecutionPolicy` from `app.reading_policy`.
- Produces: `LoopPolicy.from_pinned_execution_policy()` generating a 32-bit int snapshot with .NET keys and `cap_profile_sha256 = cap_snapshot_sha256(snapshot)`, exposing `policy_hash`.

- [ ] **Step 1: Write the failing regression test for Policy Bridge**

Create `services/generation-service/tests/test_s01_corrective_regression.py`:
```python
import pytest
from app.loop.policy import LoopPolicy, cap_snapshot_sha256
from app.reading_policy import PinnedExecutionPolicy, MAX_SECTION_WALL_SECONDS, MAX_SECTION_TOKEN_CAP, MAX_PROVIDER_CALL_SECONDS

def test_scenario_01_policy_bridge_snapshot_and_hash():
    """P0-A: LoopPolicy.from_pinned_execution_policy must produce valid 32-bit int snapshot and separate policy.hash."""
    unified_policy = PinnedExecutionPolicy(provider="minimax")
    sec_policy = LoopPolicy.from_pinned_execution_policy(unified_policy, scope="SECTION")

    # 1. Finite ceilings enforced
    assert not sec_policy.is_unlimited
    assert sec_policy.max_wall_time_seconds <= MAX_SECTION_WALL_SECONDS
    assert sec_policy.max_total_tokens <= MAX_SECTION_TOKEN_CAP
    assert sec_policy.operation_wall_reservation_seconds <= MAX_PROVIDER_CALL_SECONDS

    # 2. Hash separation: cap_profile_sha256 matches snapshot SHA-256, while policy_hash matches unified_policy.hash
    snapshot = sec_policy.cap_profile_snapshot
    expected_snapshot_sha = cap_snapshot_sha256(snapshot)
    assert sec_policy.cap_profile_sha256 == expected_snapshot_sha
    assert sec_policy.cap_profile_sha256 != unified_policy.hash
    assert getattr(sec_policy, "policy_hash", None) == unified_policy.hash

    # 3. .NET CheckpointService MatchesRunBudget keys present and typed as positive 32-bit integers
    caps = snapshot["caps"]
    for k in ("standaloneRunBudgetCapCalls", "standaloneRunBudgetCapTokens", "standaloneRunBudgetCapWallTimeSeconds", "loopOperationWallReservationSeconds"):
        assert k in caps
        assert isinstance(caps[k], int)
        assert 0 < caps[k] <= 2_147_483_647

    # 4. LoopPolicy.from_cap_snapshot round-trip and validation both succeed
    restored_policy = LoopPolicy.from_cap_snapshot(snapshot)
    assert restored_policy.cap_profile_sha256 == expected_snapshot_sha
    restored_policy.validate_cap_bounds()
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd services/generation-service && python3 -m pytest tests/test_s01_corrective_regression.py::test_scenario_01_policy_bridge_snapshot_and_hash -v`
Expected: FAIL (assertion on hash separation and/or `from_cap_snapshot` raising ValueError due to float `loopOperationWallReservationSeconds`).

- [ ] **Step 3: Implement policy bridge fixes in `app/loop/policy.py`**

In `services/generation-service/app/loop/policy.py`:
1. Add `policy_hash: str = Field(default="", description="Canonical hash of the underlying PinnedExecutionPolicy")` to `LoopPolicy`.
2. In `from_pinned_execution_policy`:
   - Cast all time limits and reservations to `int`:
     `max_provider_seconds = int(min(float(getattr(policy, "provider_call_seconds", MAX_PROVIDER_CALL_SECONDS)), float(MAX_PROVIDER_CALL_SECONDS)))`
     `max_wall = int(min(float(getattr(policy, "run_wall_seconds" if is_paper else "section_wall_seconds", MAX_SECTION_WALL_SECONDS * (3 if is_paper else 1))), float(MAX_SECTION_WALL_SECONDS * (3 if is_paper else 1))))`
     `max_tokens = int(min(int(getattr(policy, "run_token_cap" if is_paper else "section_token_cap", MAX_SECTION_TOKEN_CAP * (3 if is_paper else 1))), MAX_SECTION_TOKEN_CAP * (3 if is_paper else 1)))`
     `max_calls = int(getattr(policy, "run_call_cap" if is_paper else "section_call_cap", 30 if is_paper else 15))`
   - Include .NET keys in `snapshot["caps"]`:
     `"standaloneRunBudgetCapCalls": max_calls`
     `"standaloneRunBudgetCapTokens": max_tokens`
     `"standaloneRunBudgetCapWallTimeSeconds": max_wall`
     `"passageGenerateMaxTokens": min(15_000, max_tokens)`
     `"benchmarkMode": "LIMITED"`
     `"benchmarkMonetaryCapMode": "LIMITED"`
   - Compute `expected_sha = cap_snapshot_sha256(snapshot)`.
   - Set `cap_profile_sha256=expected_sha` and `policy_hash=policy_hash`.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd services/generation-service && python3 -m pytest tests/test_s01_corrective_regression.py::test_scenario_01_policy_bridge_snapshot_and_hash -v`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add services/generation-service/app/loop/policy.py services/generation-service/tests/test_s01_corrective_regression.py
git commit -m "fix(loop): ensure canonical 32-bit int cap snapshot and hash separation in policy bridge"
```

---

### Task 2: Strict Candidate Correctness & Validation (P1-C)

**Files:**
- Modify: `services/generation-service/app/generators/question/generator.py:145-228`
- Test: `services/generation-service/tests/test_s01_corrective_regression.py`

**Interfaces:**
- Consumes: Raw candidate dicts from LLM generation.
- Produces: `QuestionCandidatePool` where candidates with missing prompt, invalid evidence quote, or unmapped MCQ answer keys are strictly marked `rejected = True`.

- [ ] **Step 1: Write failing regression tests for candidate validation**

Append to `services/generation-service/tests/test_s01_corrective_regression.py`:
```python
from app.generators.question.generator import QuestionCandidateGenerator
from app.contracts.artifact import ArtifactRef, ArtifactType

def test_scenario_04_short_evidence_quote_rejected():
    """P1-C: Evidence quote not in passage must be rejected even if under 15 characters."""
    gen = QuestionCandidateGenerator(gateway=None)
    passage_text = "The solar system contains eight planets orbiting the central star."
    raw = [{
        "prompt": "How many planets orbit the central star?",
        "answer": "eight",
        "evidenceQuote": "nine planets", # 12 chars: under 15 chars, not in passage
    }]
    p_ref = ArtifactRef(artifactId="art_p1", artifactType=ArtifactType.PASSAGE, version=1, contentHash="a"*64)
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="b"*64)
    pool = gen.build_pool_from_raw_candidates("slot_1", 1, "ShortAnswer", raw, passage_text, p_ref, bp_ref)

    assert len(pool.candidates) == 1
    cand = pool.candidates[0]
    assert cand.rejected is True
    assert any("unsupported by passage" in r.lower() for r in cand.rejection_reasons)

def test_scenario_05_missing_prompt_rejected():
    """P1-C: Missing prompt must not trigger fabricated prompt fallback."""
    gen = QuestionCandidateGenerator(gateway=None)
    passage_text = "The solar system contains eight planets orbiting the central star."
    raw = [{
        "prompt": "", # Empty prompt
        "answer": "eight",
        "evidenceQuote": "eight planets",
    }]
    p_ref = ArtifactRef(artifactId="art_p1", artifactType=ArtifactType.PASSAGE, version=1, contentHash="a"*64)
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="b"*64)
    pool = gen.build_pool_from_raw_candidates("slot_1", 1, "ShortAnswer", raw, passage_text, p_ref, bp_ref)

    assert len(pool.candidates) == 1
    cand = pool.candidates[0]
    assert cand.rejected is True
    assert "Question 1 prompt." not in cand.prompt
    assert any("missing prompt" in r.lower() for r in cand.rejection_reasons)

def test_scenario_06_mcq_answer_not_in_options_rejected():
    """P1-C: MCQ answer key not resolving to options A-D must be rejected."""
    gen = QuestionCandidateGenerator(gateway=None)
    passage_text = "Mars is known as the red planet due to iron oxide."
    raw = [{
        "prompt": "Why is Mars known as the red planet?",
        "options": [
            {"key": "A", "text": "Water oceans"},
            {"key": "B", "text": "Iron oxide"},
            {"key": "C", "text": "Methane gas"},
            {"key": "D", "text": "Volcanic dust"},
        ],
        "answer": "E", # Not in options A-D
        "evidenceQuote": "iron oxide",
    }]
    p_ref = ArtifactRef(artifactId="art_p1", artifactType=ArtifactType.PASSAGE, version=1, contentHash="a"*64)
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="b"*64)
    pool = gen.build_pool_from_raw_candidates("slot_1", 1, "MultipleChoiceSingle", raw, passage_text, p_ref, bp_ref)

    assert len(pool.candidates) == 1
    cand = pool.candidates[0]
    assert cand.rejected is True
    assert any("not found in options" in r.lower() for r in cand.rejection_reasons)
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd services/generation-service && python3 -m pytest tests/test_s01_corrective_regression.py -k "scenario_04 or scenario_05 or scenario_06" -v`
Expected: FAIL (short quote accepted due to `>= 15` bypass, prompt fabricated as `"Question 1 prompt."`, MCQ answer key `"E"` not marked rejected).

- [ ] **Step 3: Implement candidate validation fixes in `app/generators/question/generator.py`**

In `services/generation-service/app/generators/question/generator.py`:
1. Line 187: If `family == QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE`:
   - If `not matched_key`:
     `rejection_reasons.append(f"MCQ answer key '{raw_ans_str}' not found in options")`
     `raw_ans = "[UNMAPPED]"`
2. Line 202: Remove `len(ev_quote) >= 15` bypass:
   ```python
   elif ev_quote and ev_quote.casefold() not in passage_text.casefold():
       rejection_reasons.append(f"Evidence quote is unsupported by passage: '{ev_quote[:60]}'")
   ```
3. Line 213: Remove prompt fallback:
   ```python
   raw_prompt = str(raw.get("prompt") or "").strip()
   if not raw_prompt:
       rejection_reasons.append("Missing prompt")
       raw_prompt = "[MISSING]"
   ```
4. Set `prompt=raw_prompt`.

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd services/generation-service && python3 -m pytest tests/test_s01_corrective_regression.py -k "scenario_04 or scenario_05 or scenario_06" -v`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add services/generation-service/app/generators/question/generator.py services/generation-service/tests/test_s01_corrective_regression.py
git commit -m "fix(question): enforce fail-closed validation on prompt, quote, and MCQ options"
```

---

### Task 3: Deterministic Workflow Recovery & SectionId Inheritance (P1-D)

**Files:**
- Modify: `services/generation-service/app/loop/question.py:258-285`
- Modify: `services/generation-service/app/loop/runtime.py:484-500`
- Test: `services/generation-service/tests/test_s01_corrective_regression.py`

**Interfaces:**
- Consumes: `stored_state.operations` from `ResumeStateResult`.
- Produces: Deterministic workflow `operationId` isolated by section index and run ID; child operations inheriting parent `SectionId` formatting.

- [ ] **Step 1: Write failing regression tests for workflow isolation and SectionId inheritance**

Append to `services/generation-service/tests/test_s01_corrective_regression.py`:
```python
from uuid import uuid4
from app.loop.context import LoopContext, AuthorityGrant, BudgetTracker
from app.contracts.artifact import ArtifactType
from app.contracts.issue import IssueScope
from app.loop.runtime import BoundedLoopRuntime
from app.loop.policy import LoopPolicy
from tests.test_t08_passage_loop import DurableStoreFake

@pytest.mark.asyncio
async def test_scenario_07_workflow_recovery_section_isolated(tmp_path):
    """P1-D: QuestionCandidateLoop must not adopt a reserved workflow belonging to another section."""
    from app.loop.question import QuestionCandidateLoop
    from app.persistence.models import OperationGrantRequest

    owner = uuid4()
    run_id = f"run_wf_{uuid4().hex[:8]}"
    store = DurableStoreFake(tmp_path / "wf.db", owner=owner, epoch=1)

    # Seed an existing reserved workflow for Section 1
    s1_wf_op = f"op_workflow_qcand_s1_{run_id[:8]}"
    store.grant_operation(OperationGrantRequest(
        runId=run_id, epoch=1, leaseOwner=owner, operationId=s1_wf_op,
        operationType="WORKFLOW", requestHash=f"wf:s1:{run_id}",
        tokenReservation=10000, wallTimeReservationSeconds=100.0,
        sectionId="1", artifactId=None,
    ))

    # When QuestionCandidateLoop runs for Section 2, it MUST NOT pick s1_wf_op
    q_loop = QuestionCandidateLoop(generator=None, persistence_client=store)
    stored_state = store.resume_state(run_id)

    # Determine workflow ID for Section 2
    expected_s2_op = f"op_workflow_qcand_s2_{run_id[:8]}"
    matching = [
        o for o in (stored_state.operations or [])
        if o.operationType == "WORKFLOW" and o.status == "RESERVED" and o.operationId == expected_s2_op
    ]
    # S1 workflow is not adopted for S2
    assert s1_wf_op not in [m.operationId for m in matching]

@pytest.mark.asyncio
async def test_scenario_08_section_id_inheritance(tmp_path):
    """P1-D: Child operation must inherit parent operation SectionId format."""
    owner = uuid4()
    run_id = f"run_sec_inherit_{uuid4().hex[:8]}"
    store = DurableStoreFake(tmp_path / "sec_inherit.db", owner=owner, epoch=1)

    parent_op_id = f"parent_op_{uuid4().hex[:8]}"
    # Parent operation was granted with sectionId="section_1"
    store.grant_operation(OperationGrantRequest(
        runId=run_id, epoch=1, leaseOwner=owner, operationId=parent_op_id,
        operationType="WORKFLOW", requestHash=f"req:parent:{run_id}",
        tokenReservation=20000, wallTimeReservationSeconds=200.0,
        sectionId="section_1", artifactId=None,
    ))

    # Child runtime initialized with context.section_id = 1
    ctx = LoopContext(
        runId=run_id, targetArtifactId="art_q_1", targetArtifactType=ArtifactType.QUESTION,
        sectionId=1, scope=IssueScope.QUESTION, authority=AuthorityGrant(leaseOwner=owner, epoch=1),
        parent_operation_id=parent_op_id,
    )
    runtime = BoundedLoopRuntime(context=ctx, policy=LoopPolicy.from_settings(), generator=None, evaluators=[], persistence_client=store)
    intent = runtime._intent("GENERATE", 1, 1000, "1.0.0", {"test": True})

    # Execute reservation
    res = runtime._reserve(intent)
    assert res is True
    # The granted child operation in store must have inherited "section_1"
    child_op = store.resume_state(run_id).operations[-1]
    assert child_op.sectionId == "section_1"
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd services/generation-service && python3 -m pytest tests/test_s01_corrective_regression.py -k "scenario_07 or scenario_08" -v`
Expected: FAIL (`scenario_08` fails because child sends `"1"` instead of inheriting `"section_1"`).

- [ ] **Step 3: Implement deterministic workflow and SectionId inheritance**

1. In `services/generation-service/app/loop/question.py:258-285`:
   - Replace arbitrary `existing_reserved[0]` with:
     ```python
     expected_workflow_op_id = f"op_workflow_qcand_s{section_index}_{run_id[:8]}"
     existing_reserved = [
         o for o in (stored_state.operations or [])
         if o.operationType == "WORKFLOW" and o.status == "RESERVED" and o.operationId == expected_workflow_op_id
     ]
     if existing_reserved:
         workflow_op_id = existing_reserved[0].operationId
     else:
         workflow_op_id = expected_workflow_op_id
         ...
         workflow_grant = self.persistence_client.grant_operation(OperationGrantRequest(
             runId=run_id, epoch=epoch, leaseOwner=lease_owner, operationId=workflow_op_id,
             operationType="WORKFLOW", requestHash=f"workflow:questions:s{section_index}:{run_id}:v1",
             tokenReservation=token_res, wallTimeReservationSeconds=wall_res,
             sectionId=str(section_index), artifactId=None, parentOperationId=parent_operation_id,
         ))
     ```
2. In `services/generation-service/app/loop/runtime.py:484-488`:
   - Inspect parent operation if present:
     ```python
     parent_sec_id = None
     if parent_op:
         p_record = next((o for o in (getattr(self.context, "operations", []) or []) if getattr(o, "operationId", None) == parent_op), None)
         if p_record is None and hasattr(self.persistence_client, "resume_state"):
             try:
                 r_state = self.persistence_client.resume_state(self.context.run_id)
                 p_record = next((o for o in (r_state.operations or []) if o.operationId == parent_op), None)
             except Exception:
                 pass
         if p_record and getattr(p_record, "sectionId", None):
             parent_sec_id = p_record.sectionId

     sec_id = parent_sec_id or (str(self.context.section_id) if getattr(self.context, "section_id", None) is not None else None)
     ```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd services/generation-service && python3 -m pytest tests/test_s01_corrective_regression.py -k "scenario_07 or scenario_08" -v`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add services/generation-service/app/loop/question.py services/generation-service/app/loop/runtime.py services/generation-service/tests/test_s01_corrective_regression.py
git commit -m "fix(loop): ensure deterministic workflow recovery and SectionId inheritance"
```

---

### Task 4: Immutable Recovery Parent Closure & Evaluation Evidence Gate (P0-B)

**Files:**
- Modify: `services/generation-service/app/loop/passage.py:210-250`
- Modify: `services/generation-service/app/loop/section.py:500-545`
- Modify: `services/generation-service/app/loop/question.py:80-90`
- Test: `services/generation-service/tests/test_s01_corrective_regression.py`

**Interfaces:**
- Consumes: `resume_state.artifacts` and `resume_state.evaluations`.
- Produces: Strict parent closure check and mandatory verification of evaluation records before granting zero-call `DecisionType.PASS`.

- [ ] **Step 1: Write failing regression tests for evaluation evidence and parent closure**

Append to `services/generation-service/tests/test_s01_corrective_regression.py`:
```python
from app.contracts.artifact import ArtifactEnvelope, ArtifactType, ArtifactRef
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.loop import DecisionType, LoopState
from app.generators.passage.context import PassageGenerationContext
from app.generators.passage.generator import PassageGenerator
from app.loop.passage import PassageLoop
from tests.test_t08_passage_loop import DurableStoreFake

@pytest.mark.asyncio
async def test_scenario_02_zero_call_resume_requires_evaluations(tmp_path):
    """P0-B: Zero-call resume must reject PASS if accepted artifact lacks required evaluations."""
    owner = uuid4()
    run_id = f"run_no_eval_{uuid4().hex[:8]}"
    store = DurableStoreFake(tmp_path / "no_eval.db", owner=owner, epoch=1)

    bp_art = ArtifactEnvelope.create("art_bp", ArtifactType.EXAM_BLUEPRINT, run_id, {"title": "BP"}, "2.0.0", version=1)
    eg_art = ArtifactEnvelope.create("art_eg", ArtifactType.EVIDENCE_GRAPH, run_id, {"title": "EG"}, "2.0.0", version=1)
    p_env = ArtifactEnvelope.create(
        "art_passage_s1", ArtifactType.PASSAGE, run_id,
        {"text": "Sample passage content. " * 50, "wordCount": 800}, "2.0.0", version=1,
        parent_refs=[bp_art.to_ref(), eg_art.to_ref()],
    )
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner, "artifact": bp_art, "evaluations": [], "operationId": "op_bp"})())
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner, "artifact": eg_art, "evaluations": [], "operationId": "op_eg"})())
    # Commit passage with evaluations=[] (missing required evaluations)
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner, "artifact": p_env, "evaluations": [], "operationId": "op_p"})())

    passage_loop = PassageLoop(generator=PassageGenerator(gateway=None), persistence_client=store)
    p_ctx = PassageGenerationContext(
        topic="Topic", section_index=1, source_text="Source " * 20,
        blueprint_ref=bp_art.to_ref(), evidence_graph_ref=eg_art.to_ref(),
    )

    # Because evaluations are missing, zero-call resume must NOT award PASS early
    res = await passage_loop.run(passage_context=p_ctx, run_id=run_id, lease_owner=owner, epoch=1)
    # It must not be a zero-call completed resume without evaluations
    assert not (res.decision == DecisionType.PASS and res.calls_count == 0 and not res.accepted_artifact)

@pytest.mark.asyncio
async def test_scenario_03_missing_parent_ref_rejected(tmp_path):
    """P0-B: Missing parent ref in store_accepted_heads must fail closed (loophole closed)."""
    owner = uuid4()
    run_id = f"run_missing_p_{uuid4().hex[:8]}"
    store = DurableStoreFake(tmp_path / "missing_p.db", owner=owner, epoch=1)

    bp_ref = ArtifactRef(artifactId="art_bp_missing", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="a"*64)
    p_env = ArtifactEnvelope.create(
        "art_passage_s1", ArtifactType.PASSAGE, run_id,
        {"text": "Sample passage content. " * 50, "wordCount": 800}, "2.0.0", version=1,
        parent_refs=[bp_ref],
    )
    # art_bp_missing is NOT in store
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner, "artifact": p_env, "evaluations": [], "operationId": "op_p"})())

    passage_loop = PassageLoop(generator=PassageGenerator(gateway=None), persistence_client=store)
    p_ctx = PassageGenerationContext(
        topic="Topic", section_index=1, source_text="Source " * 20,
        blueprint_ref=bp_ref, evidence_graph_ref=ArtifactRef(artifactId="art_eg", artifactType=ArtifactType.EVIDENCE_GRAPH, version=1, contentHash="b"*64),
    )
    # Must not resume with zero calls
    res = await passage_loop.run(passage_context=p_ctx, run_id=run_id, lease_owner=owner, epoch=1)
    assert res.calls_count != 0 or res.decision != DecisionType.PASS
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd services/generation-service && python3 -m pytest tests/test_s01_corrective_regression.py -k "scenario_02 or scenario_03" -v`
Expected: FAIL (scenario_02 currently returns zero-call PASS because evaluations are ignored).

- [ ] **Step 3: Implement immutable recovery parent validation & evaluation verification**

1. In `services/generation-service/app/loop/passage.py:213-252`:
   - Fix parent closure validation:
     ```python
     parents_match_input = tuple(accepted_envelope.parent_refs) == tuple(expected_input_deps)
     parents_not_stale = (
         len(accepted_envelope.parent_refs) == len(expected_input_deps)
         and all(p.artifact_id in store_accepted_heads and store_accepted_heads[p.artifact_id] == p for p in accepted_envelope.parent_refs)
     )
     ```
   - Verify evaluation ledger before granting zero-call `DecisionType.PASS`:
     ```python
     stored_evals = [
         e for e in (getattr(resume_state, "evaluations", None) or [])
         if getattr(e, "target_ref", None) == accepted_envelope.to_ref()
     ]
     eval_ids = {getattr(e, "evaluator_id", "") for e in stored_evals if getattr(e, "status", None) == EvaluationStatus.PASS}
     has_required_evals = bool(self.policy.required_evaluator_ids) and set(self.policy.required_evaluator_ids).issubset(eval_ids)

     if parents_match_input and parents_not_stale and has_required_evals:
         # Grant zero-call PASS
         return LoopResult(...)
     else:
         logger.info("Run %s: accepted passage artifact %s lacks fresh parents or required evaluation evidence; invoking revalidation", run_id, target_art_id)
     ```
2. In `services/generation-service/app/loop/section.py:507-545`:
   - Apply identical parent closure and evaluation evidence verification before returning zero-call `PASS`.
3. In `services/generation-service/app/loop/question.py:84-88`:
   - Include required semantic and blind solver evaluators in default `policy.required_evaluator_ids`.

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd services/generation-service && python3 -m pytest tests/test_s01_corrective_regression.py -k "scenario_02 or scenario_03" -v`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add services/generation-service/app/loop/passage.py services/generation-service/app/loop/section.py services/generation-service/app/loop/question.py services/generation-service/tests/test_s01_corrective_regression.py
git commit -m "fix(loop): enforce parent closure and mandatory evaluation ledger on resume"
```

---

### Task 5: Full Suite Verification & Conflict Accounting Report

**Files:**
- Create: `reports/unified-flow/S01-CORRECTIVE-VERIFICATION.md`

**Interfaces:**
- Consumes: Test execution results across all generation-service test suites.
- Produces: Authoritative engineering report covering root-cause matrix, code diffs, pass/fail counts, test conflicts, and GO/NO-GO determination.

- [ ] **Step 1: Execute all test suites**

```bash
cd services/generation-service
python3 -m pytest tests/test_t06_loop_runtime.py -q
python3 -m pytest tests/test_t08_passage_loop.py -q
python3 -m pytest tests/test_t09_question_candidates.py -q
python3 -m pytest tests/test_t10_blind_solvers.py -q
python3 -m pytest tests/test_t11_section_loop.py -q
python3 -m pytest tests/test_t12_paper_loop.py -q
python3 -m pytest tests/unified/ -q
python3 -m pytest tests/test_s01_corrective_regression.py -q
python3 -m pytest tests/test_legacy_hardening_regression.py -q
```

- [ ] **Step 2: Record and analyze specification conflicts in `test_legacy_hardening_regression.py`**

Confirm:
- `test_regression_01` fails because it asserts zero-call PASS with `evaluations=[]`.
- `test_regression_08` fails because it asserts `cap_profile_sha256 == policy.hash`.
- Record exact tracebacks and explain why fixing production logic made these tests fail.

- [ ] **Step 3: Write verification report `reports/unified-flow/S01-CORRECTIVE-VERIFICATION.md`**

Write report covering:
1. Root-cause matrix (`file:line`, cause, fix, remaining risk).
2. Code diff of all changed files.
3. Test execution log and pass/fail/conflict counts.
4. Persistence verification (fencing, hashes, CAS).
5. Compatibility matrix.
6. GO / NO-GO assessment.

- [ ] **Step 4: Commit verification report**

```bash
git add reports/unified-flow/S01-CORRECTIVE-VERIFICATION.md
git commit -m "docs(audit): generate S01 corrective verification and specification conflict report"
```
