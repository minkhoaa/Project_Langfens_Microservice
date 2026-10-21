# Technical Design Specification: Autonomous IELTS Reading Generation Harness

**Document ID:** `SPEC-2026-10-21-AUTONOMOUS-READING-HARNESS`  
**Location:** `docs/superpowers/specs/2026-10-21-autonomous-reading-generation-harness-design.md`  
**Repository:** `minkhoaa/Project_Langfens_Microservice`  
**Target Branch:** `autonomous-generation`  
**Status:** DRAFT (Under Review)  
**Date:** 2026-10-21  

---

## 1. Executive Summary & Intent

### 1.1 The "Why"
The current IELTS Reading generation pipeline can produce syntactically valid JSON payloads that nonetheless fail academic quality standards: questions with multiple defensible answers, ungrounded answer keys, weak or misleading distractors, broken evidence references, or mismatched blank numbers. In the current production pipeline, any failure in validation either terminates execution or triggers naive full-batch retries that discard valid, high-quality questions and repeat prompts without diagnostic feedback.

### 1.2 Mission
Transform the unified Reading pipeline into an **autonomous, quality-driven IELTS Academic Reading generation harness** that:
1. Reuses the mature, fail-closed `BoundedLoopRuntime` engine (`app/loop/`) as the **single execution authority** for iterative generation, evaluation, diagnosis, and repair, without introducing competing orchestration layers.
2. Supports all **19 IELTS Reading question families** end-to-end across candidate generation, validation, zero-leakage blind solving, adversarial ambiguity detection, surgical repair, and downstream grading.
3. Implements **dynamic blueprint allocation** that selects authentic IELTS Academic question combinations and flexible group counts summing to exactly 40 questions, while preserving the legacy 6-type preset for backward compatibility.
4. Provides an **autonomous recovery engine** operating on a strict escalation ladder (`ITEM_REPAIR` → `ITEM_RESELECT` → `GROUP_REPAIR` → `PASSAGE_REPAIR` → `REGENERATE`), preserving unaffected accepted questions and updating artifact heads via atomic compare-and-swap (CAS).
5. Enforces **dependency-aware revalidation**: tracks exact evidence spans and group dependencies; when parent artifacts change, revalidates conservatively.
6. Generates, sanitizes, and verifies **renderable visual assets (SVG)** for visual question types without external image generation services.
7. Guarantees **crash resumption and backward compatibility** with immutable checkpoint records in PostgreSQL, never rewriting historical hashes.

---

## 2. Goals, Non-Goals, and Anti-Goals

### 2.1 Goals
- **Autonomous Repair of Question-Level Defects:** When Question 23 fails academic evaluation (e.g., adversary finds a second valid answer), diagnose the defect, isolate Question 23, apply targeted repair or candidate replacement, revalidate, and CAS-commit while preserving the other 39 questions.
- **End-to-End 19-Type Support:** Implement Pydantic candidate schemas, prompt templates, normalizers, blind solver comparisons, and repair planners for all 19 `QuestionPromptFamily` entries.
- **Dynamic Blueprinting:** Dynamically allocate question types and group sizes based on passage evidence and IELTS Academic suitability, targeting exactly 40 questions across 3 sections.
- **Visual Asset Generation & Validation:** Support diagram labelling and flowchart completion with renderable SVGs validated for well-formedness, sanitization, responsive viewports, accessibility, text collision avoidance, and answer-to-callout alignment.
- **Single Orchestration Authority:** Retire split orchestrators; integrate `BoundedLoopRuntime` as the sole loop state machine governing stages.
- **Immutable Checkpoints & Resumption:** Interface cleanly with `exam-service`'s `CheckpointService.cs` using canonical artifact hashing, preserving historical records and resume capabilities.
- **Fail-Closed Gate:** Zero synthetic passes. Never bypass an evaluator to force paper completion.
- **Full-Stack End-to-End Publication in .NET exam-service:** Update `ReadingPaperRules.cs`, `ReadingPaperWorker.cs`, and `ReadingPaperFinalSnapshot.cs` to accept dynamic group allocations (2–4 groups per section) and all 19 question types for final exam publication, while preserving the legacy 6-type preset as an explicit validation profile.

### 2.2 Non-Goals
- **External Image Generation:** No DALL-E, Midjourney, or diffusion models. All diagrams/flowcharts are structured vector graphics (SVG) generated from textual blueprints.
- **Forcing 19 Types into One Paper:** Real IELTS papers feature 3–5 question types per test. Dynamic blueprinting selects an authentic, cohesive mix.
- **Modifying Historical Baseline Artifacts:** Treat `generation_baseline/` as immutable reference material.
- **Live Paid Model Calls During Build:** All structural, unit, and integration verifications use deterministic mocks, offline test fixtures, or dry-run gateways.
### 2.3 Anti-Goals
- **Naive Full-Section / Full-Paper Retries:** Never discard 39 valid questions because 1 question is defective.
- **Prompt Replay Without Diagnostics:** Never resend an identical prompt after an academic evaluation failure.
- **Synthetic Quality Passes:** Never hardcode or relax thresholds to manufacture a PASS.
- **Mutating Historical Artifact Hashes:** Never rewrite existing database rows or invent non-reproducible hash schemes.

---

## 3. Architecture & Unified Execution Flow

### 3.1 Unified Canonical Pipeline Flow
The generation harness operates as a linear sequence of macro-stages, where each stage is driven internally by `BoundedLoopRuntime`:

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

### 3.2 Single Orchestration Authority (`BoundedLoopRuntime`)
- `ReadingGenerationPipeline` (`app/pipeline.py`) acts as the top-level orchestrator invoked by `ReadingPaperWorker.cs` via `POST /v1/autogen/reading-paper/execute`.
- Instead of naive while-loops in `SectionRunner`, each stage delegates its core iterative logic to `BoundedLoopRuntime`:
  - `PassageLoop`: Drafts and verifies passage text against word count, CEFR style, and factual claim grounding.
  - `QuestionCandidateLoop`: Drafts question groups, evaluates candidates via blind solvers, manages candidate reserve pools, and performs surgical item repair.
  - `SectionLoop`: Verifies section-wide distinctness and coverage.
  - `PaperLoop`: Cross-section sanity, answer distribution, and finalization.
- `StageExecutor` is retained exclusively for lifecycle persistence fencing (managing `LoopCursorCheckpoint`, draft reservations, and CAS commits) and does not maintain duplicate loop logic.

---

## 4. The 19-Type IELTS Reading Capability Matrix

All 19 question types defined in `QuestionPromptFamily` are supported with canonical contracts, schemas, blind solver normalizers, and repair strategies:

| # | Question Type | Canonical Wire Constant | Output Schema Model | Blind Solving / Adversary Logic | Scoped Repair Strategy | Visual / Asset Requirements |
|---|---|---|---|---|---|---|
| 1 | True / False / Not Given | `TRUE_FALSE_NOT_GIVEN` | `TrueFalseCandidate` | Strict 3-state normalizer; adversary tests contradiction vs absence | Diagnostic wording adjustment; NG justification repair | None (Text) |
| 2 | Yes / No / Not Given | `YES_NO_NOT_GIVEN` | `YesNoCandidate` | Strict 3-state normalizer; adversary tests writer's opinion vs text fact | Claims vs opinion adjustment; NG justification repair | None (Text) |
| 3 | Sentence Completion | `SENTENCE_COMPLETION` | `SentenceCompletionCandidate` | Canonical completion normalizer; word count enforcement (≤ 3 words) | Trimming filler words; blank marker `______` positioning | None (Text) |
| 4 | Summary Completion | `SUMMARY_COMPLETION` | `SummaryCompletionCandidate` | Passage span completion normalizer; group anti-leakage check | Sibling deduplication; summary flow rewriting | Shared summary box |
| 5 | Summary Completion (Box) | `SUMMARY_COMPLETION_BOX` | `SummaryBoxCandidate` | Option letter/word mapping normalizer; distractor plausibility | Pool distractor calibration; synonym alignment | Shared option box |
| 6 | Multiple Choice (Single) | `MULTIPLE_CHOICE_SINGLE` | `MultipleChoiceSingleCandidate` | Option letter normalizer; adversary searches for second defensible choice | Distractor weakening/strengthening; stem disambiguation | Standard 4 options |
| 7 | Multiple Choice (Multiple) | `MULTIPLE_CHOICE_MULTIPLE` | `MultipleChoiceMultipleCandidate` | Multi-select set comparison; partial match grading semantics | Subset repair; remove overlapping choices | Multi-select options |
| 8 | Matching Headings | `MATCHING_HEADING` | `MatchingHeadingsCandidate` | 1-to-1 paragraph-to-heading normalizer; distractor heading check | Heading distractor rebalancing; paragraph focus repair | List of Roman numerals |
| 9 | Matching Information | `MATCHING_INFORMATION` | `MatchingInformationCandidate` | Paragraph letter normalizer; NB "you may use any letter more than once" check | Disambiguate paragraph statements; shift target paragraph | List of paragraph letters |
| 10 | Matching Features | `MATCHING_FEATURES` | `MatchingFeaturesCandidate` | Feature-to-statement mapping; entity verification in passage | Statement rewriting; entity attribution repair | Shared feature list |
| 11 | Matching Sentence Endings | `MATCHING_ENDINGS` | `MatchingSentenceEndingsCandidate` | Stem-to-ending pairing; grammatical syntax compatibility check | Ending distractor repair; syntax alignment | List of endings (A–G) |
| 12 | Table Completion | `TABLE_COMPLETION` | `TableCompletionCandidate` | Cell span normalizer; row/column header consistency check | Cell blank realignment; table structure reformatting | Markdown / HTML Table |
| 13 | Flow Chart Completion | `FLOW_CHART` | `FlowChartCompletionCandidate` | Sequential process normalizer; step dependency check | Step ordering repair; callout blank verification | Renderable SVG Flowchart |
| 14 | Diagram Label Completion | `DIAGRAM_LABEL` | `DiagramLabelCandidate` | Spatial callout normalizer; pointer-to-part verification | Callout coordinate shift; part description repair | Renderable SVG Diagram |
| 15 | Short Answer Questions | `SHORT_ANSWER` | `ShortAnswerCandidate` | Verbatim text span extractor; word limit check (≤ 3 words) | Question stem tightening; answer span trimming | None (Text) |
| 16 | Note Completion | `NOTE_COMPLETION` | `NoteCompletionCandidate` | Heading/bullet hierarchical completion normalizer | Bullet hierarchy repair; blank marker alignment | Hierarchical notes |
| 17 | Form Completion | `FORM_COMPLETION` | `FormCompletionCandidate` | Field-value pair normalizer; categorical data format check | Field prompt adjustment; format validation | Structured form |
| 18 | Classification | `CLASSIFICATION` | `ClassificationCandidate` | Multi-category assignment normalizer; category exclusivity check | Category boundary clarification; statement repair | Shared category list |
| 19 | Choosing a Title | `CHOOSING_A_TITLE` | `ChoosingTitleCandidate` | Global main-idea normalizer; adversary tests distractor paragraph scope | Distractor scope adjustment (too narrow vs too broad) | Standard 4 options |

---

## 5. Dynamic Blueprint Planning & Allocation

### 5.1 Dynamic Allocation Engine
- The planner analyzes the source topic and passage structure (or planned passage outline) to dynamically generate an `ExamBlueprint`:
  - Exactly 3 sections.
  - Exactly 40 questions total (e.g., Section 1: 13, Section 2: 13, Section 3: 14).
  - Configurable group allocation: dynamically assigns question groups per section based on passage suitability and IELTS Academic conventions (ensuring every group has >= 1 question and the entire exam sums to exactly 40 questions), without hardcoding 2–4 groups.
- **Academic Suitability Filters:**
  - Section 1: Descriptive, factual, lower difficulty (TFNG, Notes, Table, Flowchart, Multiple Choice Single).
  - Section 2: Discursive, technical, moderate difficulty (Matching Information, Matching Features, Summary Completion, Diagram Label).
  - Section 3: Complex argument, academic debate, high difficulty (Matching Headings, Yes/No/Not Given, Multiple Choice Multiple, Sentence Endings).
- **Backward-Compatible Preset:** The legacy 6-type preset remains selectable via `blueprint_mode="legacy_preset"` in `PinnedExecutionPolicy`, preserving existing integration test expectations.


### 5.2 Downstream .NET exam-service Alignment
- **`ReadingPaperRules.cs`:**
  - Decouple validation from hardcoded `[7, 6], [6, 7], [7, 7]` and strict 2-group constraints.
  - Dynamically validate that each section contains >= 1 groups, all questions sum to exactly 40 across the exam, and all question families are valid IELTS types.
  - Retain legacy preset validation as an explicit backward-compatible profile (`ValidateLegacyPreset()`).
- **`ReadingPaperWorker.cs` (`BuildExam`):**
  - Extend mapping to transform all 19 question families into `ExamQuestion` records.
  - Populate `BlankAcceptTexts` (completion types), `MatchPairs` (matching types), `Options` (MCQ single/multiple), and inline SVGs (`InstructionMd`) so downstream attempt-service graders evaluate student attempts correctly.
- **`ReadingPaperFinalSnapshot.cs`:**
  - Update required evaluator definitions to reflect clean semantic versioning for dynamic blueprints rather than hardcoded legacy strings.
---

## 6. Autonomous Recovery Engine & Intelligent Repair Routing

### 6.1 State Machine Lifecycle
Every question slot or group progresses through the canonical autonomous recovery cycle:

$$\text{GENERATE} \longrightarrow \text{PARSE} \longrightarrow \text{VALIDATE} \longrightarrow \text{DIAGNOSE} \longrightarrow \text{ROUTE REPAIR} \longrightarrow \text{REVALIDATE} \longrightarrow \text{ACCEPT}$$

### 6.2 Intelligent Escalation Ladder
When academic evaluation detects an issue, `LoopController` routes recovery to the smallest valid scope based on defect severity and progress:

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

1. **`ITEM_REPAIR`:** The primary repair action for single-question defects (e.g., Question 23 has 2 valid options). The diagnostic payload includes the adversary's counter-claim and specific conflicting text span. MiniMax rewrites only the question stem or distractor.
2. **`ITEM_RESELECT`:** If item repair fails or the group generator pre-computed candidate reserves, the engine discards the flawed candidate and selects a replacement candidate grounded in an alternative passage span.
3. **`GROUP_REPAIR`:** Applied when shared structures (e.g., summary paragraph text, matching headings list, diagram labels) are inconsistent or ambiguous across multiple questions.
4. **`REGENERATE`:** Triggered when repairs stagnate (detected by `StagnationDetector` after 2 identical issue hashes). The slot or group is regenerated with fresh seeds.
5. **`PASSAGE_REPAIR`:** Escalation of last resort when an essential question group cannot be grounded without clarifying passage facts. Triggers conservative downstream invalidation.
6. **`NEEDS_SOURCES`:** Terminal failure when source evidence is inherently contradictory.

### 6.3 Stagnation & Oscillation Defense
- `IssueLedgerManager` computes a deterministic SHA-256 fingerprint for every detected issue:
  $$\text{IssueHash} = \text{SHA-256}(\text{issueCode} + \text{artifactRef} + \text{evaluatorId} + \text{canonicalEvidence})$$
- `StagnationDetector`: Flags repeated identical issue hashes across successive iterations and forces escalation from `ITEM_REPAIR` to `ITEM_RESELECT` or `REGENERATE`.
- `OscillationDetector`: Detects alternating issue states ($A \to B \to A$) and aborts cyclical loops.

---

## 7. Dependency Tracking & Conservative Invalidation

### 7.1 Exact Dependency Grounding
To guarantee academic integrity without relying solely on abstract `parentRefs`:
- **Evidence Span Tracking:** Every question candidate stores exact evidence offsets:
  `evidence_spans: List[Tuple[int, int]]` (exact character start and end offsets in the passage text).
- **Group Interdependency:** Questions belonging to shared-pool groups (`MATCHING_HEADINGS`, `SUMMARY_COMPLETION_BOX`, `MATCHING_FEATURES`, `DIAGRAM_LABEL_COMPLETION`) maintain explicit bidirectional edges to their parent `groupId`.

### 7.2 Conservative Invalidation Policy
1. **Isolated Question Repair (`ITEM_REPAIR` / `ITEM_RESELECT`):** Only Question 23's text, options, or answer key change. Sibling questions share no mutable state; Question 23 alone is revalidated, leaving Questions 1–22 and 24–40 locked.
2. **Group Repair (`GROUP_REPAIR`):** Shared options or summary instructions change. All questions in that group are invalidated and re-evaluated.
3. **Passage Repair (`PASSAGE_REPAIR`):** If a passage is edited:
   - Identify the edited character range.
   - Any question whose evidence span intersects or follows the change is invalidated.
   - **Conservative Rule:** If there is any uncertainty about sentence re-numbering or claim shifting, the engine revalidates all questions in that section.
4. **Zero PASS Inheritance:** An invalidated artifact must undergo fresh blind solving and grounding checks. It never inherits a PASS verdict from an older hash.

---

## 8. Visual Asset (SVG) Engine & Verification

### 8.1 Structured Vector Generation
Visual question types (`DIAGRAM_LABEL_COMPLETION`, `FLOW_CHART_COMPLETION`) require student-facing graphical representations without external image models:
- **Layout Blueprint:** The generator outputs a structured geometric schema (boxes, connectors, pointers, callout badge coordinates).
- **Deterministic SVG Compiler:** Produces clean, standards-compliant SVG with explicit `viewBox`.

### 8.2 Visual Verification Suite (`SvgVisualEvaluator`)
The generated SVG must pass comprehensive verification before acceptance:
1. **XML & Sanitization:** Strict parsing; rejection of scripts, external entity references (`<!ENTITY>`), and external hyperlinks.
2. **Viewport & Responsive Scaling:** Valid `viewBox` ensuring crisp scaling on desktop and mobile.
3. **Collision & Alignment Verification:**
   - Text bounding boxes must not intersect graphical strokes or other labels.
   - Pointers must terminate clearly at their intended diagram feature.
4. **Answer-to-Callout Consistency:** Every question blank (e.g., blank 14 in Section 1) maps 1-to-1 to a visible callout badge (`[14]`) in the SVG.
5. **Accessibility:** Descriptive `<title>`, `<desc>`, and high-contrast color styling.
6. **Zero Answer Leakage:** SVGs contain only callout indicators, never answer key text.


### 8.3 Checkpoint & Delivery Integration
Validated SVGs are stored directly within the question group payload and serialized into `ExamQuestionGroup.InstructionMd` (as embedded SVG markup). The markup is strictly sanitized against an allowlist of SVG elements (`svg`, `path`, `rect`, `circle`, `line`, `polyline`, `polygon`, `text`, `g`, `defs`, `marker`, `style`) and non-executable attributes, stripping any `<script>`, `onload`, or external resource references. This guarantees secure, renderable diagrams directly within existing frontend views without database schema migrations.
---

## 9. Checkpoint Authority, Hashing & Crash Resumption

### 9.1 Immutable Checkpoint Authority (.NET `exam-service`)
- `exam-service` (`CheckpointService.cs`) is the authoritative source of truth.
- PostgreSQL tables enforce strict relational integrity:
  - `reading_paper_runs`: Tracks job execution state, lease epoch, and run status.
  - `reading_paper_checkpoints`: Durable ledger of stage advances and cursor states.
  - `reading_paper_artifacts`: Immutable store of versioned payloads and parent references.
  - `reading_paper_artifact_heads`: Authoritative accepted artifact heads updated via CAS.
  - `reading_paper_evaluations`: Comprehensive record of all evaluator findings and issue codes.

### 9.2 Content Hashing & Artifact Identity
- Canonical SHA-256 content hashes are calculated using sorted JSON serialization:
  $$\text{ContentHash} = \text{SHA-256}(\texttt{\{"parentRefs": [sorted], "payload": canonical\_payload\}})$$
- **Canonical Artifact Identity:** The harness standardizes on the pipeline's canonical format:
  `source:{run_id}:{sec_idx}`, `evidence:{run_id}:{sec_idx}`, `blueprint:{run_id}`, `passage:{run_id}:{sec_idx}`, `question:{run_id}:{q_num}`, `section:{run_id}:{sec_idx}`, `paper:{run_id}`.
- **Explicit Checkpoint Compatibility:** To preserve crash resumability for in-flight jobs or historical runs, the client incorporates an explicit, deterministic lookup table mapping historical run conventions (`art_passage_s{i}` $\to$ `passage:{run_id}:{i}`). Existing hashes in PostgreSQL are never altered or rewritten.

### 9.3 Crash Resumption Protocol
1. On worker restart or retry, `ReadingPaperWorker.cs` queries `CheckpointService.GetLatestCheckpointAsync(runId)`.
2. Python `ReadingGenerationPipeline` inspects existing accepted artifact heads:
   - If all 40 questions are accepted, it jumps directly to Stage 8 (Finalization).
   - If Section 1 is complete and Section 2 is partially drafted, Section 1's accepted artifacts are loaded directly as immutable dependencies.
   - Section 2 resumes from the last accepted question slot or restarts the unaccepted group loop.
3. No accepted artifact head is ever silently overwritten or regenerated without an explicit invalidating parent change.

---

## 10. Verification Strategy & Acceptance Criteria

### 10.1 Automated Verification Suites
- **Unit & Contract Suite:**
  - Pydantic v2 serialization tests for all 19 `QuestionPromptFamily` candidate schemas.
  - Canonical hash equivalence tests across Python and .NET `ArtifactContracts.cs`.
  - Blind solver normalizer tests for all 19 question types (checking zero-leakage serialization).
- **Loop & Recovery Suite:**
  - Mocked provider tests simulating Question 23 failure: verify diagnostic extraction, `ITEM_REPAIR` execution, solver revalidation, and isolated CAS head advance.
  - Stagnation detection test: verify that 2 identical failure hashes trigger escalation to candidate reselection.
  - Dependency invalidation test: verify that a surgical passage edit invalidates only overlapping question slots.
- **Visual Asset Suite:**
  - SVG generation and validation tests for diagram and flowchart completion.
- **Evaluator Versioning & Snapshot Consistency Suite:**
  - Verify that Python evaluators emit clean, semantic versions matching updated definitions in `ReadingPaperFinalSnapshot.cs`.
- **.NET Exam Publication & Rendering Suite:**
  - Verify `ReadingPaperRules.Validate()` admits dynamic 2–4 group configurations summing to 40 questions.
  - Verify `ReadingPaperWorker.BuildExam()` maps all 19 question families and inline SVG into `ExamQuestion` and `ExamQuestionGroup` without throwing HTTP 422.
- **End-to-End Orchestration Smoke Check:**
  - Complete offline generation run of a 40-question paper using the unified `BoundedLoopRuntime` pipeline against mocked provider responses.

### 10.2 Final Delivery Report
Upon implementation completion, a full report will be rendered to:
`generation_baseline/verification/AUTONOMOUS_READING_HARNESS_IMPLEMENTATION.md`
detailing runtime performance, 19-type test coverage, recovery metrics, and instructions for live MiniMax verification.

---

## 11. Builder Decisions (What is Handed to Implementation)
The following implementation choices are decided as engineering defaults:
1. **SVG Geometry Constants:** Standardized canvas dimensions of $800 \times 600$ for diagrams and $800 \times 400$ for flowcharts with responsive `viewBox`.
2. **Reserve Pool Sizing:** Group generator drafts $\max(N + 2, \lceil 1.5N \rceil)$ candidates for question groups when candidate over-provisioning is enabled, enabling instant `ITEM_RESELECT`.
3. **Stagnation Threshold:** Configured to 2 consecutive identical issue hashes before escalating repair scope.
4. **Maximum Loop Iterations:** Capped at 5 iterations per question slot and 3 iterations per group before raising an unrepairable defect.
