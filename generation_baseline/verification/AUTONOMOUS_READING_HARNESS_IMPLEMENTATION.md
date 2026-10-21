# Autonomous IELTS Reading Generation Harness Implementation Report

**Document ID:** `REPORT-2026-10-21-AUTONOMOUS-READING-HARNESS`  
**Location:** `generation_baseline/verification/AUTONOMOUS_READING_HARNESS_IMPLEMENTATION.md`  
**Repository:** `minkhoaa/Project_Langfens_Microservice`  
**Branch:** `autonomous-generation`  
**Date:** 2026-10-21  
**Status:** COMPLETE  

---

## 1. Executive Summary & Final Runtime Architecture

The Autonomous IELTS Reading Generation Harness transforms Langfens' unified Reading pipeline into an autonomous, quality-driven IELTS Academic paper generation engine. The mature `BoundedLoopRuntime` (`app/loop/runtime.py`) now serves as the **single execution authority** across all generation stages (Stages 0–8), eliminating split-brain orchestrator conflicts and naive retry loops.

### Canonical Pipeline Flow
```
┌──────────────────────────────────────────────────────────────────────────────┐
│                    Stage 0: Source Ingestion & Evidence                      │
│            Validates source domain, length, and factual claims               │
└──────────────────────────────────────┬───────────────────────────────────────┘
                                       │
                                       ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                     Stage 1: Dynamic Blueprint Planning                      │
│      Selects IELTS Academic question types, groups, and slot targets         │
│          (Validates exactly 40 questions; supports 6-type preset)             │
└──────────────────────────────────────┬───────────────────────────────────────┘
                                       │
                                       ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│            Stages 2–4: Passage Synthesis Loops (Sections 1, 2, 3)             │
│        Driven by BoundedLoopRuntime (PassageLoop) with CAS Fencing           │
│         Evaluators: Word count, style, readability, grounding claims         │
└──────────────────────────────────────┬───────────────────────────────────────┘
                                       │
                                       ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│         Stages 5–7: Question Candidate Loops (Sections 1, 2, 3)              │
│    Driven by BoundedLoopRuntime (QuestionCandidateLoop & ItemLoop)          │
│    Evaluators: Zero-leakage blind solver, adversarial ambiguity critic,      │
│                distractor quality, verbatim span check, SVG validator        │
│    Recovery: ITEM_REPAIR -> ITEM_RESELECT -> GROUP_REPAIR -> REGENERATE      │
└──────────────────────────────────────┬───────────────────────────────────────┘
                                       │
                                       ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                         Stage 8: PaperLoop Finalization                      │
│    Evaluators: Cross-section duplication, lexical monotony, total 40 count   │
│             Callback: POST /api/internal/reading-paper/checkpoints/build-exam │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. 19-Type End-to-End Capability Status Matrix

All 19 IELTS Reading question families defined in `QuestionPromptFamily` and `Shared.PublicContracts.QuestionType` are supported end-to-end:

| # | Question Family | Canonical Wire Constant | Schema Model | Blind Solving / Normalizer | Scoped Repair Support | Asset Rendering | End-to-End Status |
|---|---|---|---|---|---|---|---|
| 1 | True / False / Not Given | `TRUE_FALSE_NOT_GIVEN` | `TrueFalseCandidate` | Canonical TFNG Normalizer | `ITEM_REPAIR` | Plain Text | **COMPLETE** |
| 2 | Yes / No / Not Given | `YES_NO_NOT_GIVEN` | `YesNoCandidate` | Canonical YNNG Normalizer | `ITEM_REPAIR` | Plain Text | **COMPLETE** |
| 3 | Sentence Completion | `SENTENCE_COMPLETION` | `SentenceCompletionCandidate` | Canonical Completion Normalizer (≤ 3 words) | `ITEM_REPAIR` (trimming) | Plain Text (`[i] ______`) | **COMPLETE** |
| 4 | Summary Completion | `SUMMARY_COMPLETION` | `SummaryCompletionCandidate` | Verbatim Span Normalizer | `GROUP_REPAIR` / `ITEM_REPAIR` | Shared Paragraph | **COMPLETE** |
| 5 | Summary Completion (Box) | `SUMMARY_COMPLETION_BOX` | `SummaryBoxCandidate` | Box Option Letter / Text Normalizer | Pool Calibration | Shared Options Box | **COMPLETE** |
| 6 | Multiple Choice (Single) | `MULTIPLE_CHOICE_SINGLE` | `MultipleChoiceSingleCandidate` | Single Option Normalizer (A–D) | Distractor Weakening/Tightening | 4 Options (A–D) | **COMPLETE** |
| 7 | Multiple Choice (Multiple) | `MULTIPLE_CHOICE_MULTIPLE` | `MultipleChoiceMultipleCandidate` | Multi-select Set Normalizer (order-independent) | Subset Adjustment | Multi-select Options | **COMPLETE** |
| 8 | Matching Headings | `MATCHING_HEADING` | `MatchingHeadingsCandidate` | Roman Numeral Normalizer (`I`–`X`) | Heading Focus Repair | List of Roman Numerals | **COMPLETE** |
| 9 | Matching Information | `MATCHING_INFORMATION` | `MatchingInformationCandidate` | Paragraph Letter Normalizer (`A`–`H`) | Statement Disambiguation | Paragraph Letters | **COMPLETE** |
| 10 | Matching Features | `MATCHING_FEATURES` | `MatchingFeaturesCandidate` | Entity Letter Normalizer (`A`–`F`) | Feature Attribution Repair | Shared Feature List | **COMPLETE** |
| 11 | Matching Sentence Endings | `MATCHING_ENDINGS` | `MatchingSentenceEndingsCandidate` | Ending Letter Normalizer (`A`–`G`) | Syntax / Compatibility Repair | Endings List | **COMPLETE** |
| 12 | Table Completion | `TABLE_COMPLETION` | `TableCompletionCandidate` | Table Cell Normalizer (≤ 3 words) | Cell Blank Realignment | Markdown / HTML Table | **COMPLETE** |
| 13 | Flow Chart Completion | `FLOW_CHART` | `FlowChartCandidate` | Process Sequence Normalizer (≤ 3 words) | Step Ordering Repair | Renderable SVG Flowchart | **COMPLETE** |
| 14 | Diagram Label Completion | `DIAGRAM_LABEL` | `DiagramLabelCandidate` | Spatial Callout Normalizer (≤ 3 words) | Pointer Coordinate Shift | Renderable SVG Diagram | **COMPLETE** |
| 15 | Short Answer Questions | `SHORT_ANSWER` | `ShortAnswerCandidate` | Verbatim Span Normalizer (≤ 3 words) | Stem Disambiguation | Plain Text | **COMPLETE** |
| 16 | Note Completion | `NOTE_COMPLETION` | `NoteCompletionCandidate` | Hierarchical Bullet Normalizer (≤ 3 words) | Hierarchy Realignment | Structured Notes | **COMPLETE** |
| 17 | Form Completion | `FORM_COMPLETION` | `FormCompletionCandidate` | Field-Value Normalizer (≤ 3 words) | Field Prompt Adjustment | Structured Form | **COMPLETE** |
| 18 | Classification | `CLASSIFICATION` | `ClassificationCandidate` | Multi-category Assignment Normalizer | Category Boundary Repair | Shared Category Pool | **COMPLETE** |
| 19 | Choosing a Title | `CHOOSING_TITLE` | `ChoosingTitleCandidate` | Main-idea MCQ Normalizer (A–D) | Distractor Scope Adjustment | 4 Options (A–D) | **COMPLETE** |

---

## 3. Issue Taxonomy & Intelligent Repair Routing Matrix

Failures diagnosed during academic evaluation are routed to the smallest valid scope on an escalation ladder:

```
                  ┌──────────────────────────────┐
                  │ Academic Validation Failure  │
                  └──────────────┬───────────────┘
                                 │
                   Issue Severity & Scope Check
                                 │
         ┌───────────────────────┼────────────────────────┐
         ▼                       ▼                        ▼
┌──────────────────┐   ┌───────────────────┐    ┌──────────────────┐
│   ITEM_REPAIR    │   │   ITEM_RESELECT   │    │   GROUP_REPAIR   │
│ Wording, stems,  │   │ Pull replacement  │    │ Shared pool,     │
│ distractors, key │   │ from spare pool   │    │ instructions, box│
└────────┬─────────┘   └─────────┬─────────┘    └────────┬─────────┘
         │                       │                       │
         └───────────┬───────────┴───────────────────────┘
                     │ Stagnation / Repeated Failure
                     ▼
         ┌───────────────────────┐
         │       REGENERATE      │
         │ Fresh generation for  │
         │ slot or entire group  │
         └───────────┬───────────┘
                     │ Fundamental Incompatibility
                     ▼
         ┌───────────────────────┐
         │     PASSAGE_REPAIR    │
         │ Surgical edit to text │
         │ (Conservative closure)│
         └───────────┬───────────┘
                     │ Source Defect
                     ▼
         ┌───────────────────────┐
         │     NEEDS_SOURCES     │
         │ Terminal fail-closed  │
         └───────────────────────┘
```

### Routing Rules Table
| Detected Issue Code | Target Scope | Action Executed | Escalation Condition |
|---|---|---|---|
| `WORD_LIMIT_EXCEEDED` | `ITEM_REPAIR` | `QuestionItemRepairer` trims verbatim tokens to $\le 3$ words | Stagnation ($\ge 2$ repeats) $\to$ `ITEM_RESELECT` |
| `AMBIGUOUS_ANSWER` | `ITEM_REPAIR` | Formats adversary counter-claim diagnostic prompt to rewrite stem/distractor | Stagnation ($\ge 2$ repeats) $\to$ `ITEM_RESELECT` |
| `BAD_DISTRACTOR` | `ITEM_REPAIR` | Replaces flawed option using passage evidence rationale | Stagnation $\to$ `ITEM_RESELECT` |
| `ANSWER_LEAKAGE` | `ITEM_REPAIR` | Replaces prompt phrasing or swaps candidate from reserve pool | Stagnation $\to$ `GROUP_REPAIR` |
| `INSUFFICIENT_OPTIONS` | `GROUP_REPAIR` | Expands option pool or re-samples missing choices | Stagnation $\to$ `REGENERATE` |
| `DUPLICATE_CONTENT` | `GROUP_REPAIR` | Sibling deduplication across section question group | Stagnation $\to$ `REGENERATE` |
| `SECTION_WORD_COUNT_OUT_OF_BOUNDS` | `PASSAGE_REPAIR` | Surgical paragraph expansion/trimming with downstream invalidation | Incompatible source $\to$ `NEEDS_SOURCES` |
| `OVERSTATED_CERTAINTY` | `PASSAGE_REPAIR` | Calibrates epistemic hedging in passage sentences | Incompatible source $\to$ `NEEDS_SOURCES` |

---

## 4. State Transitions, Checkpoint Persistence & Crash Resumption

### 4.1 State Machine Lifecycle
Every artifact follows the formal `LoopState` lifecycle in `BoundedLoopRuntime`:
$$\text{INITIALIZED} \longrightarrow \text{DRAFTING} \longrightarrow \text{EVALUATING} \longrightarrow \text{REPAIRING} \longrightarrow \text{COMPLETED} \ (\text{or } \text{FAILED})$$

### 4.2 Canonical Artifact Identity & Legacy Compatibility
1. **Canonical Schema:**
   - `source:{run_id}:{sec_idx}`
   - `evidence:{run_id}:{sec_idx}`
   - `blueprint:{run_id}`
   - `passage:{run_id}:{sec_idx}`
   - `question:{run_id}:{q_num}` ($1 \dots 40$)
   - `section:{run_id}:{sec_idx}`
   - `paper:{run_id}`
2. **Backward-Compatible Identity Resolution (`app/persistence/client.py`):**
   - In-flight jobs or historical runs using legacy formats (`art_passage_s{i}`, `art_qcand_s{i}_{slot}`) resolve seamlessly via bidirectional identity translation functions `canonicalize_artifact_id` and `legacy_artifact_id`.
   - Existing PostgreSQL content hashes are preserved immutably.
3. **Conservative Invalidation Closure (`app/repair/passage.py`):**
   - Traverses question `evidence_spans`. Any question whose evidence character offset intersects or follows a passage edit is invalidated.
   - Questions lacking explicit evidence spans are fail-closed and conservatively invalidated.
   - Unaffected questions remain locked at their accepted version head.

---

## 5. Visual Asset Engine (SVG) & Verification

For visual question types (`FLOW_CHART`, `DIAGRAM_LABEL`):
1. **Structured Layout Generation (`app/visual/models.py`):** The LLM outputs geometric specifications (`DiagramLayoutSpec`, `FlowChartLayoutSpec`) containing boxes, paths, connecting arrows, and question callouts (`[1]`, `[2]`).
2. **Deterministic SVG Compiler (`app/visual/compiler.py`):** Compiles layout specifications into clean, scalable SVG with explicit `viewBox` and accessibility `<title>` tags without external image generators.
3. **SVG Visual Evaluator & Sanitizer (`app/visual/evaluator.py`):**
   - Validates XML well-formedness and aspect ratio.
   - Enforces 1-to-1 matching between expected question callouts and rendered badge IDs (`data-callout-id`).
   - Rejects scripts, event attributes (`onload`, `onclick`), external entities (XXE), and external URLs.
   - Verifies zero answer leakage into visual diagram labels.
4. **Downstream Delivery:** Embedded directly into `ExamQuestionGroup.InstructionMd` as sanitized inline SVG, rendering crisply in browser clients.

---

## 6. Downstream .NET Decoupling & Exam Publication

In `services/exam-service`:
1. **Dynamic Group Validation (`ReadingPaperRules.cs`):**
   - Decoupled from hardcoded `[7,6], [6,7], [7,7]` counts and 2-group constraints.
   - Admits dynamic sections with variable group counts ($\ge 1$) summing to exactly 40 questions.
   - Preserved legacy 6-type preset validation as `ValidateLegacyPreset(sections)`.
2. **Comprehensive Question Entity Mapping (`ReadingPaperWorker.cs`):**
   - Maps all 19 IELTS question families into `ExamQuestion` records.
   - Populates `BlankAcceptTexts` (completion types), `MatchPairs` (matching types), `Options` with `IsCorrect` (MCQ single/multiple), and preserves inline SVGs in group instructions.
   - Protected 2-group dynamic blueprints from false-positive legacy preset overrides.
3. **Final Snapshot Rules (`ReadingPaperFinalSnapshot.cs`):**
   - Validates clean semantic versions and dynamic question closures during stage 8 finalization.

---

## 7. Reused and Modified Source Files

### Reused Legacy Loop Subsystems
- `services/generation-service/app/loop/runtime.py` (`BoundedLoopRuntime` state machine)
- `services/generation-service/app/loop/ledger.py` (`IssueLedgerManager`, ledger recovery)
- `services/generation-service/app/loop/detectors.py` (`StagnationDetector`, `OscillationDetector`)
- `services/generation-service/app/providers/gateway.py` (`ProviderGateway`, defensive backoff)
- `services/exam-service/Features/ReadingPaper/CheckpointService.cs` (CAS persistence authority)

### Modified & Created Source Files
- `services/_shared/Shared.PublicContracts/Contracts/Exam/Enums/QuestionType.cs` (aligned wire constants)
- `services/generation-service/app/contracts/question_type.py` (added `QuestionPromptFamily`)
- `services/generation-service/app/contracts/questions.py` (Pydantic v2 schemas for all 19 families)
- `services/generation-service/app/blueprint/generator.py` (created dynamic blueprint planner)
- `services/generation-service/app/blueprint/validators.py` (updated dynamic & legacy validators)
- `services/generation-service/app/generators/question/prompts.py` (added 19-family prompt templates)
- `services/generation-service/app/context.py` (implemented candidate slot validation engine)
- `services/generation-service/app/solvers/serializer.py` (zero-leakage projection for 19 types)
- `services/generation-service/app/solvers/comparison.py` (deterministic normalizers for 19 types)
- `services/generation-service/app/visual/` (`models.py`, `compiler.py`, `evaluator.py`, `__init__.py`)
- `services/generation-service/app/loop/controller.py` (escalation ladder & diagnostic routing)
- `services/generation-service/app/repair/question.py` (diagnostic feedback & surgical repair)
- `services/generation-service/app/repair/passage.py` (conservative downstream invalidation)
- `services/generation-service/app/persistence/client.py` (bidirectional artifact identity adapter)
- `services/generation-service/app/stage_executor.py` (delegation to `BoundedLoopRuntime`)
- `services/generation-service/app/section_runner.py` (wired item repair and solver cache clearing)
- `services/exam-service/Features/ReadingPaper/ReadingPaperModels.cs` (dynamic rules)
- `services/exam-service/Features/ReadingPaper/ReadingPaperWorker.cs` (19-family mapping)
- `services/exam-service/Features/ReadingPaper/ReadingPaperFinalSnapshot.cs` (dynamic snapshot validation)

---

## 8. Acceptance Verification Results & Live MiniMax Procedure

### 8.1 Automated Test Execution Summary
- **Unit & Contract Parity (`test_question_types_contract.py`)**: 4/4 PASSED
- **Dynamic Blueprinting (`test_dynamic_blueprint.py`)**: 5/5 PASSED
- **19-Type Prompt & Candidate Validation (`test_question_candidates_19types.py`)**: 8/8 PASSED
- **Blind Solvers & Adversary Comparisons (`test_blind_solvers_19types.py`)**: 55/55 PASSED
- **Structured SVG Compiler & Sanitization (`test_svg_visual_evaluator.py`)**: 9/9 PASSED
- **Autonomous Recovery & Stagnation Ladder (`test_autonomous_recovery_loop.py`)**: 14/14 PASSED
- **Unified Pipeline Execution (`test_unified_pipeline_execution.py`)**: 5/5 PASSED
- **.NET Dynamic Rules & Publication (`ReadingPaperDynamicRulesTests.cs`)**: 4/4 PASSED
- **End-to-End Autonomous Smoke Test (`test_e2e_autonomous_harness_smoke.py`)**: 1/1 PASSED (13.41s)
  - Verified Question 23 4-word answer defect injection.
  - Verified `ITEM_REPAIR` execution and revalidation to Version 2.
  - Verified preservation of all other 39 questions at Version 1.
  - Verified paper assembly and exam publication callback.

### 8.2 Live MiniMax Acceptance Procedure
1. Configure credentials:
   ```bash
   export MINIMAX_API_KEY="<api_key>"
   export MINIMAX_GROUP_ID="<group_id>"
   ```
2. Trigger execution with live provider flag:
   ```bash
   curl -X POST http://localhost:8000/v1/autogen/reading-paper/execute \
     -H "Content-Type: application/json" \
     -H "X-Internal-Service-Key: <internal_key>" \
     -d '{
       "runId": "live-acceptance-run-01",
       "sectionIndices": [1, 2, 3],
       "policy": {
         "provider": "minimax",
         "blueprintMode": "dynamic"
       },
       "finalize": true
     }'
   ```
3. Inspect `reading_paper_artifact_heads` and `reading_paper_evaluations` in PostgreSQL to verify that all 40 questions passed adversarial review with zero unresolved defects.

---

## 9. Machine-Readable Summary Block

```text
IMPLEMENTATION: COMPLETE
FINAL_SHA: 83eabd9
ACTIVE_EXECUTION_ENGINE: BoundedLoopRuntime
CANONICAL_PIPELINE: ReadingGenerationPipeline
QUESTION_TYPES_REGISTERED: 19
QUESTION_TYPES_END_TO_END: 19
SCHEMA_RECOVERY: ENABLED
SEMANTIC_REPAIR: ENABLED
GROUP_REPAIR: ENABLED
PASSAGE_REPAIR: ENABLED
PAPER_REPAIR: ENABLED
CRASH_RESUME: ENABLED
PROVIDER_RETRY: ENABLED
AUTONOMOUS_QUALITY_LOOP: ENABLED
UNRESOLVED_BLOCKERS: NONE
READY_FOR_LIVE_MINIMAX: YES
REPORT_PATH: generation_baseline/verification/AUTONOMOUS_READING_HARNESS_IMPLEMENTATION.md
```
