# Autonomous IELTS Reading Generation Harness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform the IELTS Reading generation pipeline into an autonomous, quality-driven generation harness supporting all 19 question families end-to-end, dynamic blueprinting, zero-leakage blind solving, visual SVG asset generation, dependency-aware recovery, and .NET exam publication.

**Architecture:** Integrate the mature, fail-closed `BoundedLoopRuntime` (`app/loop/`) as the single loop execution authority inside `ReadingGenerationPipeline`. Dynamic blueprinting allocates authentic IELTS Academic question groups summing to 40 questions, evaluated by adversarial blind solvers, repaired via an escalation ladder (`ITEM_REPAIR` → `ITEM_RESELECT` → `GROUP_REPAIR` → `PASSAGE_REPAIR` → `REGENERATE`), and published to PostgreSQL via `exam-service` CAS checkpoints.

**Tech Stack:** Python 3.12 (FastAPI, Pydantic v2, pytest), .NET 10.0 (C#, EF Core, xUnit), PostgreSQL, SVG XML.

**Spec:** `docs/superpowers/specs/2026-10-21-autonomous-reading-generation-harness-design.md`

---

## Global Constraints

- **Single Execution Authority:** `BoundedLoopRuntime` is the exclusive state machine for generation, evaluation, and repair; no competing orchestration engines.
- **19-Type End-to-End Coverage:** All 19 IELTS Reading question families supported across schemas, prompts, normalizers, blind solving, repair, and downstream grading.
- **Configurable Group Allocation:** Section question groups are dynamically allocated based on passage suitability and IELTS Academic conventions, strictly summing to 40 questions total, without hardcoded group counts.
- **Backward-Compatible Legacy Preset:** The 6-type preset remains selectable via `blueprint_mode="legacy_preset"` in `PinnedExecutionPolicy` and `ReadingPaperRules.ValidateLegacyPreset()`.
- **Dependency-Aware Conservative Invalidation:** Item repair isolates the single question; passage edits invalidate intersecting character evidence spans or conservatively revalidate the entire section.
- **Fail-Closed Quality Gate:** Zero synthetic passes. Never bypass an evaluator or accept unresolved issues to force paper completion.
- **Renderable Visual Assets:** Deterministic SVG generation and DOM sanitization for flowcharts and diagrams without external image models.
- **Immutable Checkpoints:** Never rewrite historical artifact hashes or database rows in PostgreSQL.

---

## Review Focus

1. **Question Ambiguity Recovery:** Question 23 has 2 defensible answers flagged by the adversarial blind solver; the engine isolates Question 23, extracts diagnostic issues, applies `ITEM_REPAIR`, re-solves, and CAS-commits without altering the other 39 questions.
2. **Stagnation Escalation:** When surgical prompt repair produces 2 consecutive identical issue hashes, `StagnationDetector` escalates from `ITEM_REPAIR` to candidate reselection or slot regeneration.
3. **Passage Edit Invalidation Closure:** If an unresolvable defect triggers `PASSAGE_REPAIR`, questions whose evidence offsets intersect or follow the edit are invalidated and re-evaluated, never inheriting stale PASS verdicts.
4. **.NET Dynamic Publication Safety:** When a paper with dynamic group allocation (e.g., 3 groups in Section 1) finalizes at Stage 8, `ReadingPaperRules.Validate()` and `ReadingPaperWorker.BuildExam()` publish the `Exam` entity without HTTP 422 errors.
5. **Resume Compatibility:** In-flight runs containing legacy artifact IDs (`art_passage_s1`) resume cleanly through explicit identity mappings without failing hash checks.

---

## File Structure

```
services/
├── _shared/
│   └── Shared.PublicContracts/Contracts/Exam/Enums/QuestionType.cs
├── exam-service/
│   └── Features/ReadingPaper/
│       ├── ReadingPaperRules.cs
│       ├── ReadingPaperWorker.cs
│       └── ReadingPaperFinalSnapshot.cs
├── generation-service/
│   ├── app/
│   │   ├── contracts/
│   │   │   ├── question_type.py
│   │   │   ├── questions.py
│   │   │   └── blueprint.py
│   │   ├── blueprint/
│   │   │   ├── generator.py
│   │   │   └── validators.py
│   │   ├── generators/question/
│   │   │   ├── prompts.py
│   │   │   └── generator.py
│   │   ├── visual/
│   │   │   ├── models.py
│   │   │   ├── compiler.py
│   │   │   └── evaluator.py
│   │   ├── solvers/
│   │   │   ├── comparison.py
│   │   │   ├── serializer.py
│   │   │   └── adjudication.py
│   │   ├── evaluators/
│   │   │   ├── solver.py
│   │   │   └── paper.py
│   │   ├── loop/
│   │   │   ├── runtime.py
│   │   │   ├── controller.py
│   │   │   └── detectors.py
│   │   ├── repair/
│   │   │   ├── planner.py
│   │   │   ├── question.py
│   │   │   └── passage.py
│   │   ├── pipeline.py
│   │   ├── section_runner.py
│   │   └── persistence/client.py
```

---

## Tasks

### Task 1: Contract & Type Alignment Across Python and .NET

**Files:**
- Modify: `services/_shared/Shared.PublicContracts/Contracts/Exam/Enums/QuestionType.cs`
- Modify: `services/generation-service/app/contracts/question_type.py`
- Modify: `services/generation-service/app/contracts/questions.py`
- Test: `services/generation-service/tests/test_question_types_contract.py`

**Interfaces:**
- Consumes: Canonical string definitions from `Shared.PublicContracts.QuestionType`.
- Produces: `QuestionPromptFamily` enum and Pydantic v2 candidate schemas for all 19 types (`TrueFalseCandidate`, `YesNoCandidate`, `SentenceCompletionCandidate`, `SummaryCompletionCandidate`, `SummaryBoxCandidate`, `MultipleChoiceSingleCandidate`, `MultipleChoiceMultipleCandidate`, `MatchingHeadingsCandidate`, `MatchingInformationCandidate`, `MatchingFeaturesCandidate`, `MatchingSentenceEndingsCandidate`, `TableCompletionCandidate`, `FlowChartCandidate`, `DiagramLabelCandidate`, `ShortAnswerCandidate`, `NoteCompletionCandidate`, `FormCompletionCandidate`, `ClassificationCandidate`, `ChoosingTitleCandidate`).

- [ ] **Step 1: Write failing contract test**

```python
# services/generation-service/tests/test_question_types_contract.py
from app.contracts.question_type import QuestionPromptFamily
from app.contracts.questions import get_candidate_schema

def test_all_19_types_have_schemas_and_wire_names():
    assert len(QuestionPromptFamily) >= 19
    for family in QuestionPromptFamily:
        schema_cls = get_candidate_schema(family)
        assert schema_cls is not None
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest services/generation-service/tests/test_question_types_contract.py -v`  
Expected: FAIL with missing candidate schemas or family constants.

- [ ] **Step 3: Implement candidate schemas and wire constants**

In `services/_shared/Shared.PublicContracts/Contracts/Exam/Enums/QuestionType.cs`, verify all constants exist (`TrueFalseNotGiven`, `YesNoNotGiven`, `SentenceCompletion`, `SummaryCompletion`, `MultipleChoiceSingle`, `MatchingHeading`, `MatchingInformation`, `MatchingFeatures`, `MatchingEndings`, `MultipleChoiceMultiple`, `TableCompletion`, `FlowChart`, `DiagramLabel`, `ShortAnswer`, `NoteCompletion`, `FormCompletion`, `Classification`, `SummaryCompletionBox`, `ChoosingTitle`).  
In `services/generation-service/app/contracts/question_type.py` and `questions.py`, define Pydantic v2 models for each family with strict field validation and `get_candidate_schema()`.

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest services/generation-service/tests/test_question_types_contract.py -v`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add services/_shared/ services/generation-service/app/contracts/ services/generation-service/tests/
git commit -m "feat(contracts): align 19 IELTS question family schemas and wire constants"
```

---

### Task 2: Dynamic Blueprint Planner & Configurable Allocation

**Files:**
- Create: `services/generation-service/app/blueprint/generator.py`
- Modify: `services/generation-service/app/blueprint/validators.py:35-150`
- Modify: `services/generation-service/app/reading_policy.py:50-120`
- Test: `services/generation-service/tests/test_dynamic_blueprint.py`

**Interfaces:**
- Consumes: `SourceMetadata`, `PinnedExecutionPolicy`.
- Produces: `generate_dynamic_blueprint(policy: PinnedExecutionPolicy, evidence_summary: dict) -> ExamBlueprint`.

- [ ] **Step 1: Write failing dynamic blueprint test**

```python
# services/generation-service/tests/test_dynamic_blueprint.py
from app.blueprint.generator import generate_dynamic_blueprint
from app.blueprint.validators import validate_blueprint
from app.reading_policy import PinnedExecutionPolicy

def test_dynamic_blueprint_allocates_40_questions_variable_groups():
    policy = PinnedExecutionPolicy(blueprint_mode="dynamic")
    blueprint = generate_dynamic_blueprint(policy, {"topics": ["marine_biology"]})
    assert blueprint.total_questions == 40
    assert len(blueprint.sections) == 3
    issues = validate_blueprint(blueprint)
    assert not any(i.severity.value == "critical" for i in issues)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest services/generation-service/tests/test_dynamic_blueprint.py -v`  
Expected: FAIL with `validate_blueprint` rejecting variable group counts or non-6 types.

- [ ] **Step 3: Implement dynamic blueprint generator and update validators**

In `app/blueprint/validators.py`, update `validate_blueprint` so that when `blueprint_mode != "legacy_preset"`, it allows $\ge 1$ groups per section, validates that questions across all sections sum to exactly 40, and verifies all group types are valid IELTS types. In `app/blueprint/generator.py`, implement academic suitability allocation mapping Section 1 (factual/descriptive), Section 2 (technical/discursive), Section 3 (argumentative/debate).

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest services/generation-service/tests/test_dynamic_blueprint.py -v`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add services/generation-service/app/blueprint/ services/generation-service/app/reading_policy.py services/generation-service/tests/
git commit -m "feat(blueprint): implement dynamic blueprint generator and configurable allocation"
```

---

### Task 3: 19-Type Prompt Generation & Candidate Validation Engine

**Files:**
- Modify: `services/generation-service/app/generators/question/prompts.py`
- Modify: `services/generation-service/app/context.py:65-200`
- Test: `services/generation-service/tests/test_question_candidates_19types.py`

**Interfaces:**
- Consumes: `QuestionPromptFamily`, passage text, slot metadata.
- Produces: `render_question_prompt(family, ...)` and `validate_candidate_slot(candidate, family) -> List[Issue]`.

- [ ] **Step 1: Write failing candidate generation and validation test**

```python
# services/generation-service/tests/test_question_candidates_19types.py
from app.contracts.question_type import QuestionPromptFamily
from app.generators.question.prompts import render_question_prompt
from app.context import validate_candidate_slot

def test_prompt_and_candidate_validation_all_19_types():
    for family in QuestionPromptFamily:
        prompt = render_question_prompt(family, slot_number=1, passage_text="Sample passage text.")
        assert len(prompt) > 50
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest services/generation-service/tests/test_question_candidates_19types.py -v`  
Expected: FAIL with unhandled prompt families or missing validation logic.

- [ ] **Step 3: Implement prompt rendering and slot validation for all 19 types**

In `app/generators/question/prompts.py`, provide prompt templates and JSON schemas for all 19 families. In `app/context.py`, update `validate_candidate_slot` to dispatch to type-specific schema validators verifying options count, blank markers (`______`), character length, and absence assertions for NG.

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest services/generation-service/tests/test_question_candidates_19types.py -v`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add services/generation-service/app/generators/question/ services/generation-service/app/context.py services/generation-service/tests/
git commit -m "feat(generation): support prompt generation and candidate validation for 19 question families"
```

---

### Task 4: Zero-Leakage Blind Solvers, Adversary Ambiguity & Adjudication for All 19 Types

**Files:**
- Modify: `services/generation-service/app/solvers/serializer.py`
- Modify: `services/generation-service/app/solvers/comparison.py`
- Modify: `services/generation-service/app/solvers/adjudication.py`
- Modify: `services/generation-service/app/evaluators/solver.py`
- Test: `services/generation-service/tests/test_blind_solvers_19types.py`

**Interfaces:**
- Consumes: Question candidates, passage text.
- Produces: `BlindSolverEvaluator.evaluate_item(item, passage) -> AdjudicationResult`.

- [ ] **Step 1: Write failing blind solving test for complex types**

```python
# services/generation-service/tests/test_blind_solvers_19types.py
from app.solvers.serializer import project_to_student_visible
from app.solvers.comparison import compare_answers
from app.contracts.question_type import QuestionPromptFamily

def test_student_visible_projection_has_zero_leakage_all_types():
    # Verify no correct answer or evidence keys leak into solver prompt
    for family in QuestionPromptFamily:
        visible = project_to_student_visible(family, candidate_payload)
        assert "isCorrect" not in str(visible)
        assert "evidenceQuote" not in str(visible)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest services/generation-service/tests/test_blind_solvers_19types.py -v`  
Expected: FAIL with unhandled families in `project_to_student_visible` or `compare_answers`.

- [ ] **Step 3: Implement comparison normalizers and zero-leakage serializers**

In `app/solvers/comparison.py`, implement normalizers for matching sets, classification tables, multi-choice sets, and box completions. In `app/solvers/serializer.py`, ensure `project_to_student_visible` strips all answer keys and evidence quotes for all 19 types. In `app/solvers/adjudication.py`, support detecting ambiguous alternatives across matching and multi-choice selections.

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest services/generation-service/tests/test_blind_solvers_19types.py -v`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add services/generation-service/app/solvers/ services/generation-service/app/evaluators/solver.py services/generation-service/tests/
git commit -m "feat(solvers): implement zero-leakage blind solving and adversary comparison for all 19 types"
```

---

### Task 5: Structured Visual Asset (SVG) Engine, Compiler & Evaluator

**Files:**
- Create: `services/generation-service/app/visual/models.py`
- Create: `services/generation-service/app/visual/compiler.py`
- Create: `services/generation-service/app/visual/evaluator.py`
- Test: `services/generation-service/tests/test_svg_visual_evaluator.py`

**Interfaces:**
- Consumes: Visual question candidate layout specification.
- Produces: `compile_svg(spec: VisualLayoutSpec) -> str` and `SvgVisualEvaluator.evaluate(svg_text: str, question_numbers: List[int]) -> VisualValidationResult`.

- [ ] **Step 1: Write failing SVG visual verification test**

```python
# services/generation-service/tests/test_svg_visual_evaluator.py
from app.visual.compiler import compile_svg
from app.visual.evaluator import SvgVisualEvaluator
from app.visual.models import DiagramLayoutSpec, DiagramElement

def test_svg_compilation_and_validation():
    spec = DiagramLayoutSpec(title="Water Pump", width=800, height=600, elements=[...], callouts=[{"id": 14, "x": 100, "y": 200}])
    svg = compile_svg(spec)
    result = SvgVisualEvaluator().evaluate(svg, expected_callouts=[14])
    assert result.is_valid
    assert "<script" not in svg
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest services/generation-service/tests/test_svg_visual_evaluator.py -v`  
Expected: FAIL with missing module `app.visual`.

- [ ] **Step 3: Implement SVG layout models, deterministic compiler, and evaluator**

In `app/visual/models.py`, define Pydantic models for flowchart and diagram layout blueprints. In `app/visual/compiler.py`, implement deterministic SVG generator with responsive `viewBox`. In `app/visual/evaluator.py`, implement `SvgVisualEvaluator` validating XML well-formedness, sanitization (stripping scripts/events), text collision avoidance, accessibility `<title>`/`<desc>`, and 1-to-1 blank callout matching.

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest services/generation-service/tests/test_svg_visual_evaluator.py -v`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add services/generation-service/app/visual/ services/generation-service/tests/
git commit -m "feat(visual): implement structured SVG compiler, sanitization, and visual verification suite"
```

---

### Task 6: Autonomous Recovery Engine & BoundedLoop Integration

**Files:**
- Modify: `services/generation-service/app/loop/runtime.py`
- Modify: `services/generation-service/app/loop/controller.py`
- Modify: `services/generation-service/app/loop/detectors.py`
- Modify: `services/generation-service/app/loop/ledger.py`
- Modify: `services/generation-service/app/repair/planner.py`
- Modify: `services/generation-service/app/repair/question.py`
- Modify: `services/generation-service/app/repair/passage.py`
- Test: `services/generation-service/tests/test_autonomous_recovery_loop.py`

**Interfaces:**
- Consumes: Evaluator failure issues, candidate artifacts, execution context.
- Produces: `plan_repair(issues, context) -> RepairPlan` and execution of `ITEM_REPAIR`, `ITEM_RESELECT`, `GROUP_REPAIR`, `PASSAGE_REPAIR`.

- [ ] **Step 1: Write failing recovery loop test simulating Question 23 failure**

```python
# services/generation-service/tests/test_autonomous_recovery_loop.py
from app.loop.controller import LoopController
from app.contracts.issue import AcademicIssue, IssueSeverity
from app.contracts.loop import DecisionType

def test_recovery_isolates_defective_question_and_escalates_on_stagnation():
    controller = LoopController(...)
    issue = AcademicIssue(code="AMBIGUOUS_ANSWER", severity=IssueSeverity.CRITICAL, artifact_ref="question:run1:23")
    decision = controller.decide(issues=[issue])
    assert decision.decision_type == DecisionType.REPAIR
    assert decision.target_scope == "ITEM_REPAIR"
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest services/generation-service/tests/test_autonomous_recovery_loop.py -v`  
Expected: FAIL with unhandled scope or missing escalation ladder.

- [ ] **Step 3: Implement intelligent repair routing, stagnation escalation, and conservative invalidation**

In `app/loop/controller.py`, implement the escalation ladder: `ITEM_REPAIR` → `ITEM_RESELECT` → `GROUP_REPAIR` → `PASSAGE_REPAIR` → `REGENERATE`. In `app/loop/detectors.py`, trigger stagnation escalation when identical issue hashes repeat twice. In `app/repair/question.py`, format diagnostic feedback with adversary counter-claims. In `app/repair/passage.py`, compute exact downstream evidence offset invalidation closure.

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest services/generation-service/tests/test_autonomous_recovery_loop.py -v`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add services/generation-service/app/loop/ services/generation-service/app/repair/ services/generation-service/tests/
git commit -m "feat(recovery): implement autonomous escalation ladder, stagnation defense, and conservative invalidation"
```

---

### Task 7: Unified Pipeline Stage Integration & Checkpoint Adapter

**Files:**
- Modify: `services/generation-service/app/pipeline.py`
- Modify: `services/generation-service/app/section_runner.py`
- Modify: `services/generation-service/app/stage_executor.py`
- Modify: `services/generation-service/app/persistence/client.py`
- Test: `services/generation-service/tests/test_unified_pipeline_execution.py`

**Interfaces:**
- Consumes: `POST /v1/autogen/reading-paper/execute` request.
- Produces: Unified pipeline execution using `BoundedLoopRuntime` inside stages, persisting artifacts with canonical identities (`question:{run_id}:{q_num}`) and legacy compatibility mapping.

- [ ] **Step 1: Write failing unified pipeline execution test**

```python
# services/generation-service/tests/test_unified_pipeline_execution.py
from app.pipeline import ReadingGenerationPipeline
from app.persistence.client import CheckpointClient

async def test_pipeline_delegates_to_bounded_loop_with_canonical_ids():
    pipeline = ReadingGenerationPipeline(...)
    result = await pipeline.execute(run_id="test_run", policy=...)
    assert result.status == "COMPLETED"
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest services/generation-service/tests/test_unified_pipeline_execution.py -v`  
Expected: FAIL with competing stage executor loops or disconnected loop runtime.

- [ ] **Step 3: Unify stage executor with BoundedLoopRuntime and canonical IDs**

In `services/generation-service/app/pipeline.py` and `section_runner.py`, replace naive while-loops with `BoundedLoopRuntime` delegations. Standardize artifact IDs to `source:{run_id}:{sec_idx}`, `passage:{run_id}:{sec_idx}`, `question:{run_id}:{q_num}`, `section:{run_id}:{sec_idx}`, `paper:{run_id}`. In `persistence/client.py`, add explicit identity mapping for historical runs (`art_passage_s{i}` $\to$ `passage:{run_id}:{i}`).

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest services/generation-service/tests/test_unified_pipeline_execution.py -v`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add services/generation-service/app/pipeline.py services/generation-service/app/section_runner.py services/generation-service/app/stage_executor.py services/generation-service/app/persistence/ services/generation-service/tests/
git commit -m "refactor(pipeline): unify BoundedLoopRuntime as sole loop authority and standardize canonical artifact IDs"
```

---

### Task 8: Downstream .NET exam-service Decoupling & Exam Publication

**Files:**
- Modify: `services/exam-service/Features/ReadingPaper/ReadingPaperRules.cs`
- Modify: `services/exam-service/Features/ReadingPaper/ReadingPaperWorker.cs`
- Modify: `services/exam-service/Features/ReadingPaper/ReadingPaperFinalSnapshot.cs`
- Create: `services/exam-service.Tests/ReadingPaperDynamicRulesTests.cs`

**Interfaces:**
- Consumes: Dynamically blueprinted paper payload from Stage 8 (`POST /api/internal/reading-paper/checkpoints/build-exam`).
- Produces: Persisted `Exam`, `ExamSection`, `ExamQuestionGroup`, `ExamQuestion` records without 422 errors.

- [ ] **Step 1: Write failing C# test for dynamic blueprint exam publication**

```csharp
// services/exam-service.Tests/ReadingPaperDynamicRulesTests.cs
using Xunit;
using ExamService.Features.ReadingPaper;

public class ReadingPaperDynamicRulesTests
{
    [Fact]
    public void Validate_AllowsVariableGroups_AndAll19Types_SummingTo40()
    {
        var sections = CreateDynamicTestSections(); // 3 groups in Sec 1, DiagramLabel, etc.
        var issues = ReadingPaperRules.Validate(sections);
        Assert.Empty(issues);
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dotnet test services/exam-service.Tests/exam-service.Tests.csproj --filter "FullyQualifiedName~ReadingPaperDynamicRulesTests"`  
Expected: FAIL with `ReadingPaperRules.Validate` expecting exactly 2 groups and 6 legacy types.

- [ ] **Step 3: Update ReadingPaperRules, ReadingPaperWorker, and FinalSnapshot**

In `ReadingPaperRules.cs`:
- Remove hardcoded `[7,6], [6,7], [7,7]` count checks. Validate dynamic groups $\ge 1$, total questions $== 40$, and valid IELTS families.
- Preserve legacy check as `ValidateLegacyPreset(sections)`.
In `ReadingPaperWorker.cs` (`BuildExam`):
- Map all 19 families: populate `BlankAcceptTexts`, `MatchPairs`, `Options`, and inline SVGs into `ExamQuestionGroup.InstructionMd`.
In `ReadingPaperFinalSnapshot.cs`:
- Update required evaluator definitions with clean semantic versioning for dynamic blueprints.

- [ ] **Step 4: Run test to verify it passes**

Run: `dotnet test services/exam-service.Tests/exam-service.Tests.csproj --filter "FullyQualifiedName~ReadingPaperDynamicRulesTests"`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add services/exam-service/ services/exam-service.Tests/
git commit -m "feat(exam-service): support dynamic groups, 19 question families, and inline SVG in exam publication"
```

---

### Task 9: End-to-End Orchestration & Offline Smoke Run

**Files:**
- Create: `services/generation-service/tests/test_e2e_autonomous_harness_smoke.py`
- Create: `generation_baseline/verification/AUTONOMOUS_READING_HARNESS_IMPLEMENTATION.md`

**Interfaces:**
- Consumes: Complete autonomous pipeline with mock provider fixtures.
- Produces: Verified 40-question paper generation, simulated defect recovery, CAS commits, and comprehensive verification report.

- [ ] **Step 1: Write end-to-end smoke test covering autonomous defect recovery**

```python
# services/generation-service/tests/test_e2e_autonomous_harness_smoke.py
import pytest
from app.pipeline import ReadingGenerationPipeline

@pytest.mark.asyncio
async def test_end_to_end_autonomous_generation_with_q23_defect_recovery():
    # Injects simulated ambiguity on Question 23 on iteration 1
    # Asserts Question 23 undergoes ITEM_REPAIR, passes revalidation, and paper accepts 40 questions
    pipeline = ReadingGenerationPipeline(...)
    result = await pipeline.execute(run_id="smoke_run", policy=...)
    assert result.status == "COMPLETED"
    assert result.accepted_questions_count == 40
```

- [ ] **Step 2: Run test to verify it executes and passes against mock provider**

Run: `pytest services/generation-service/tests/test_e2e_autonomous_harness_smoke.py -v`  
Expected: PASS with 40 accepted questions and logged recovery event for Question 23.

- [ ] **Step 3: Generate the comprehensive verification report**

Render `generation_baseline/verification/AUTONOMOUS_READING_HARNESS_IMPLEMENTATION.md` documenting:
1. Final runtime architecture.
2. 19-type capability status matrix.
3. Issue taxonomy and recovery routing table.
4. State transitions and crash-resumption verification.
5. Reused vs modified source files.
6. Acceptance smoke test results and live MiniMax verification procedure.

- [ ] **Step 4: Commit**

```bash
git add services/generation-service/tests/ generation_baseline/verification/AUTONOMOUS_READING_HARNESS_IMPLEMENTATION.md
git commit -m "docs(verification): add end-to-end autonomous harness smoke test and implementation report"
```
