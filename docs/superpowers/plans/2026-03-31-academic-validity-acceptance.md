# Academic Validity & Production Acceptance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the remaining acceptance gaps in academic validity, scholarly source provenance, fail-closed semantic claim binding, and real acceptance-to-grading cross-service integration for the Langfens autonomous reading paper generator.

**Architecture:** Replace synthetic filler questions and mismatched source metadata in `canonical_40_question_reading_paper.json` with academically valid, passage-grounded tasks derived from verified CC-BY open-access publications (`PMC13654891`, `PMC13667678`, `PMC13665993`). Enforce strict eligibility and fail-closed claim membership validation on the authoritative pipeline and evaluator paths (`evaluate_blueprint`, `bind_claims_to_slots`, `compose_questions`). Verify real evaluator acceptance and execute the full publication and grading lifecycle against isolated PostgreSQL and `attempt-service` graders.

**Tech Stack:** Python 3.12 / 3.14 (FastAPI, Pydantic v2, pytest), .NET 10 (C#, EF Core, Npgsql, xUnit, gRPC protobuf contracts, PostgreSQL 17 test container).

**Spec:** Langfens Final Corrective Pass: Academic Validity & Production Acceptance guidelines.

## Global Constraints

- No MiniMax LIVE inference, Groq, Ollama or live model calls.
- Zero mutations to deployed/shared services or `generation_baseline/`.
- No Git history rewriting; commit locally on branch `autonomous-generation`.
- Exactly 3 IELTS Academic Reading passages, exactly 40 questions (13/13/14 distribution, 1..40 continuous numbering).
- Word count bounds: Section passages in [720, 915], total paper words in [2150, 2750].
- All-or-nothing awarded points (0 or positive) preserved in question grading.
- Preserve 19-family representative test coverage and CAS retry concurrency.

## Review Focus

1. `DIAGRAM_LABEL` questions (Q14–Q17) must have valid SVG diagram assets with callout badges matching question numbers, and answers must be authentic physical components rather than adverbs.
2. `MATCHING_ENDINGS` (Q27–Q31) and `MATCHING_HEADING` (Q32–Q36) must have distinct, academically defensible answers across competing distractors (no all-A or all-I monotony).
3. Authoritative `evaluate_blueprint` must verify that slot claims exist in the section's `evidenceGraphRef` when provided, failing closed on unverified or cross-section claims.
4. `compose_questions` must never substitute the first paragraph when a bound claim quote cannot be located in the passage; it must fail closed.
5. In .NET publication (`CheckpointService.BuildExamIdempotentAsync`), the reloaded exam must preserve all 40 question answer keys, and `QuestionGraderFactory` must award positive points for correct answers and zero for incorrect answers across all 40 items.

---

### Task 1: Verified Academic Source Provenance & Passage Reconstruction

**Files:**
- Modify: `services/generation-service/tests/fixtures/canonical_40_question_reading_paper.json`
- Create: `services/generation-service/tests/unified/test_academic_source_provenance.py`

**Interfaces:**
- Section 1 Source: `PMC13654891` (Didé West 1 Iron Smelting in Senegal, African Archaeological Review 2026, CC-BY 4.0, DOI: 10.1007/s10437-026-09653-z)
- Section 2 Source: `PMC13667678` (Combined Wind–Rain Piezoelectric Energy Harvester, Sensors 2026, CC-BY 4.0, DOI: 10.3390/s26196271)
- Section 3 Source: `PMC13665993` (Bedrock Erodibility & Transient Orogenic Erosion, Science Advances 2026, CC-BY 4.0, DOI: 10.1126/sciadv.aei9275)

- [ ] **Step 1: Write provenance validation tests in `test_academic_source_provenance.py`**
  Verify that all 3 sections resolve to genuine publications, non-empty authors, real DOIs, verified CC-BY 4.0 licenses, and non-empty verified claims. Add negative tests B1–B6 (mismatched title, missing license, fabricated claim, altered hash).
- [ ] **Step 2: Run test to observe failures on uncorrected fixture**
  Run: `pytest services/generation-service/tests/unified/test_academic_source_provenance.py -v`
  Expected: FAIL (mismatched titles / fabricated PMC metadata).
- [ ] **Step 3: Update source metadata and passages in `canonical_40_question_reading_paper.json`**
  Embed authentic publication metadata and scholarly passages (720–915 words each, 2150–2750 total) aligned with verified XML texts and claims.
- [ ] **Step 4: Run test to verify it passes**
  Run: `pytest services/generation-service/tests/unified/test_academic_source_provenance.py -v`
  Expected: PASS

---

### Task 2: Academic Validity of the Canonical 40-Question Paper

**Files:**
- Modify: `services/generation-service/tests/fixtures/canonical_40_question_reading_paper.json`
- Create: `services/generation-service/tests/unified/test_canonical_40q_academic_validity.py`

**Interfaces:**
- 40 questions: Q1–Q13 (Section 1), Q14–Q26 (Section 2), Q27–Q40 (Section 3).
- Groups:
  - S1: Q1–Q5 `TRUE_FALSE_NOT_GIVEN`, Q6–Q9 `TABLE_COMPLETION`, Q10–Q13 `FLOW_CHART`
  - S2: Q14–Q17 `DIAGRAM_LABEL` (with valid SVG), Q18–Q22 `SUMMARY_COMPLETION`, Q23–Q26 `SUMMARY_COMPLETION_BOX`
  - S3: Q27–Q31 `MATCHING_ENDINGS`, Q32–Q36 `MATCHING_HEADING`, Q37–Q40 `YES_NO_NOT_GIVEN`

- [ ] **Step 1: Write academic validity test suite in `test_canonical_40q_academic_validity.py`**
  Assert:
  - Exact 40 question contracts valid.
  - No generic prompts; each question is passage-specific.
  - Answers are defensible and unique across completions and matching.
  - Distractors are plausible, non-empty, and distinct.
  - SvgVisualEvaluator passes for Q14–Q17 (DIAGRAM_LABEL) and Q10–Q13 (FLOW_CHART).
  - All 40 questions pass production `evaluate_question`.
  - Sections pass `evaluate_section`.
  - Paper passes `evaluate_paper` (structure, cross-section, leakage, monotony, closure).
- [ ] **Step 2: Run test to observe failure on old fixture**
  Run: `pytest services/generation-service/tests/unified/test_canonical_40q_academic_validity.py -v`
  Expected: FAIL (monotony on all-A, all-I, generic prompts, invalid diagram answers).
- [ ] **Step 3: Correct all 40 questions in `canonical_40_question_reading_paper.json`**
  Review and replace questions with passage-grounded, academically rigorous questions, exact quotes, valid diagram SVGs, varied answer patterns, and detailed explanations.
- [ ] **Step 4: Run test to verify it passes**
  Run: `pytest services/generation-service/tests/unified/test_canonical_40q_academic_validity.py -v`
  Expected: PASS

---

### Task 3: Fail-Closed Semantic Claim Binding & Authoritative Production Validation

**Files:**
- Modify: `services/generation-service/app/blueprint/claim_binding.py`
- Modify: `services/generation-service/app/blueprint/validators.py`
- Modify: `services/generation-service/app/reading_evaluation.py`
- Modify: `services/generation-service/app/reading_generation.py`
- Modify: `services/generation-service/app/pipeline.py`
- Modify: `services/generation-service/app/section_runner.py`
- Create: `services/generation-service/tests/unified/test_fail_closed_claim_grounding.py`

**Interfaces:**
- `check_claim_eligibility_for_family(claim_dict: dict, question_family: str, section_id: int) -> bool`
- `bind_claims_to_slots(slots, claims, section_id, graph_id, run_id) -> list[QuestionSlot]`
- `evaluate_blueprint(artifact, policy, indices, evidence_map=None) -> list[EvaluationResult]`

- [ ] **Step 1: Write failing tests C1–C11 in `test_fail_closed_claim_grounding.py`**
  Test suitable claim accepted, irrelevant claim rejected, unsuitable claims fail closed, cross-section claim rejected, missing graph membership rejected, missing passage quote rejected, no fallback to paragraph 1.
- [ ] **Step 2: Run tests to confirm failures**
  Run: `pytest services/generation-service/tests/unified/test_fail_closed_claim_grounding.py -v`
  Expected: FAIL
- [ ] **Step 3: Implement explicit eligibility and fail-closed logic**
  - Implement `check_claim_eligibility_for_family` and minimum score threshold in `claim_binding.py`.
  - Validate claim membership and eligibility in `evaluate_blueprint` (`reading_evaluation.py`).
  - Wire `evidence_envelopes` into `evaluate_blueprint_stage` in `pipeline.py`.
  - Remove paragraph-1 fallback and synthetic claim fallback in `compose_questions` (`reading_generation.py`).
  - Remove `"claim_1"` synthetic fallback in `section_runner.py`.
- [ ] **Step 4: Run tests to verify they pass**
  Run: `pytest services/generation-service/tests/unified/test_fail_closed_claim_grounding.py -v`
  Expected: PASS

---

### Task 4: Real Acceptance-to-Grading Integration Suite

**Files:**
- Modify: `services/exam-service.Tests/ReadingPaperRealistic40QuestionE2ETests.cs`
- Create: `services/generation-service/tests/unified/test_acceptance_to_publication_bridge.py`

**Interfaces:**
- Python: Verification that canonical fixture passes actual production evaluators and produces durable accepted envelopes with valid hashes.
- .NET: `ReadingPaperRealistic40QuestionE2ETests.cs` testing negative gates D1–D6 and full PostgreSQL persistence and grading D7–D15.

- [ ] **Step 1: Write Python bridge test in `test_acceptance_to_publication_bridge.py`**
  Load corrected fixture, run genuine production evaluators, verify all evaluate to PASS with zero major/critical issues, and output envelopes.
- [ ] **Step 2: Run Python bridge test**
  Run: `pytest services/generation-service/tests/unified/test_acceptance_to_publication_bridge.py -v`
  Expected: PASS
- [ ] **Step 3: Update `ReadingPaperRealistic40QuestionE2ETests.cs`**
  - Ensure isolated PostgreSQL (port 5433) safety check.
  - Add tests D1–D6: reject mismatched source, missing license, invalid offsets, missing diagram.
  - Update D7–D15: execute full idempotent exam publication via `CheckpointService.BuildExamIdempotentAsync`, reload from PostgreSQL, compile answer keys, grade all 40 correct (100% positive) and incorrect (0 points) answers.
- [ ] **Step 4: Run .NET test suite**
  Run: `dotnet test services/exam-service.Tests/exam-service.Tests.csproj --filter "FullyQualifiedName~ReadingPaperRealistic40QuestionE2ETests"`
  Expected: PASS

---

### Task 5: Full Regression Run & Acceptance Report Delivery

**Files:**
- Create: `FINAL_ACADEMIC_OFFLINE_ACCEPTANCE_REPORT.md`

- [ ] **Step 1: Run all Python test suites**
  Run: `pytest services/generation-service/tests/unified/`
  Run: `pytest services/generation-service/tests/test_v2_source_authenticity.py services/generation-service/tests/test_v2_anti_padding.py services/generation-service/tests/test_v2_passage_segmentation.py`
  Run: `pytest services/generation-service/tests/test_svg_visual_evaluator.py`
- [ ] **Step 2: Run all safe .NET test suites**
  Run: `dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj`
  Run: `dotnet test services/exam-service.Tests/exam-service.Tests.csproj --filter "FullyQualifiedName~ReadingPaperConcurrentRetryCasTests|FullyQualifiedName~ReadingPaperRealistic40QuestionE2ETests"`
- [ ] **Step 3: Compile `FINAL_ACADEMIC_OFFLINE_ACCEPTANCE_REPORT.md`**
  Detail all 12 required report sections, gate matrix, evidence, and verdict.
- [ ] **Step 4: Commit changes locally**
  Stage modified production files, fixtures, tests, and report. Create descriptive git commit on branch `autonomous-generation`.
