# Langfens Final Question Prompt Contract Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Eliminate the prompt-to-parser contract mismatch across all 21 `QuestionPromptFamily` templates so that candidate generation prompts enforce passage-grounded explanations (>= 25 characters), verbatim quotes, and all question-type specific properties required by `_parse_candidate_payload()`, verified by parameterized offline contract tests.

**Architecture:** Update `services/generation-service/app/generators/question/prompts.py` so that every one of the 21 `QuestionPromptFamily` templates and system prompts explicitly mandates and illustrates a passage-grounded explanation (>= 25 characters), verbatim `evidenceQuote`, canonical answer formats, and required question properties. Update `services/generation-service/app/section_runner.py`'s `_parse_candidate_payload()` to support `MAP_LABEL` and remove dead fallback code. Add a comprehensive parameterized offline test suite in `services/generation-service/tests/test_question_prompt_parser_contract.py` that validates prompt structure, realistic provider responses, and fail-closed rejection of missing or short explanations across all 21 families.

**Tech Stack:** Python 3.12/3.14, Pydantic v2, pytest, pytest-asyncio.

**Spec:** Problem statement and task directives in prompt for job failure recovery at Section 1, Question 6 (`FLOW_CHART`).

## Global Constraints

- No MiniMax LIVE calls.
- No new jobs, retries or resumes.
- No modification to failed historical jobs.
- No changes to `generation_baseline/`.
- No broad architectural redesign.
- Explanations must be passage-grounded and at least 25 characters; no synthesizing fake explanations or weakening validators.
- Preserve existing retry budgets, fail-closed behavior, and checkpoint integrity.
- Stop after offline verification and push to `origin/autonomous-generation`.

## Review Focus

1. `FLOW_CHART` candidate payload missing `explanation`: parser raises `ValueError("Question ... explanation is missing or too short (< 25 characters)")`.
2. `SUMMARY_COMPLETION` nested `blanks` candidates missing `explanation`: each blank must carry its own passage-grounded explanation >= 25 characters.
3. Candidate payloads with short explanations (< 25 chars) or whitespace: parser fails closed with strict validation error.
4. Visual/layout question families (`FLOW_CHART`, `DIAGRAM_LABEL`, `MAP_LABEL`) must specify layout fields (`flowSteps`, `calloutLabel`, `partDescription`).
5. All 21 prompt hashes in `PROMPT_HASHES` must compute deterministically and dynamically from the updated templates.

---

### Task 1: Align All 21 QuestionPromptFamily Templates and System Prompts

**Files:**
- Modify: `services/generation-service/app/generators/question/prompts.py`
- Test: `services/generation-service/tests/test_question_candidates_19types.py`

**Interfaces:**
- Consumes: `QuestionPromptFamily` enum from `app.contracts.question_type`.
- Produces: `SYSTEM_PROMPTS` and `PROMPT_TEMPLATES` for all 21 families with explicit `explanation`, `evidenceQuote`, and required properties.

- [ ] **Step 1: Write a test asserting that every family template contains `"explanation"` and minimum 25 characters guidance**

Add a test in `services/generation-service/tests/test_question_candidates_19types.py` that iterates all 21 families in `QuestionPromptFamily`, builds the prompt, and asserts:
- `"explanation"` in `template`
- Minimum length or 25-character specification in prompt
- `"evidenceQuote"` in `template`

- [ ] **Step 2: Run test to verify it fails**

Run: `cd services/generation-service && .venv/bin/pytest tests/test_question_candidates_19types.py::test_all_21_families_templates_contain_explanation_and_evidence -v`
Expected: FAIL because 18 of 21 templates currently lack `"explanation"`.

- [ ] **Step 3: Update `SYSTEM_PROMPTS` and `PROMPT_TEMPLATES` in `services/generation-service/app/generators/question/prompts.py`**

For all 21 question families:
1. `TRUE_FALSE_NOT_GIVEN`: Add requirement for passage-grounded explanation >= 25 chars.
2. `YES_NO_NOT_GIVEN`: Add requirement for passage-grounded explanation >= 25 chars.
3. `SENTENCE_COMPLETION`: Add `"explanation": "Detailed passage-grounded explanation (minimum 25 characters) explaining how the passage context supports the answer."`
4. `SUMMARY_COMPLETION`: In each blank of `blanks`, add `"explanation": "Detailed passage-grounded explanation (minimum 25 characters) justifying the answer for this blank."`
5. `MULTIPLE_CHOICE_SINGLE`: Ensure `"explanation": "Detailed passage-grounded explanation (minimum 25 characters) explaining why option A is correct and others are incorrect."`
6. `SHORT_ANSWER`: Add `"explanation": "Detailed passage-grounded explanation (minimum 25 characters) proving why this answer directly answers the question."`
7. `TABLE_COMPLETION`: Add `"explanation"`, `"tableContext"`, `"rowHeader"`, `"colHeader"`.
8. `NOTE_COMPLETION`: Add `"explanation"`, `"headingContext"`, `"bulletPrefix"`.
9. `FORM_COMPLETION`: Add `"explanation"`, `"fieldLabel"`.
10. `DIAGRAM_LABEL`: Add `"explanation"`, `"calloutLabel"`, `"partDescription"`.
11. `MAP_LABEL`: Add `"explanation"`, `"calloutLabel"`, `"partDescription"`.
12. `MULTIPLE_CHOICE_MULTIPLE`: Add `"explanation"`, `"options"`, `"answers"`.
13. `MULTIPLE_CHOICE_SINGLE_IMAGE`: Add `"explanation"`, `"options"`.
14. `MATCHING_HEADING`: Add `"explanation"`, `"paragraphRef"`, `"headings"`.
15. `MATCHING_INFORMATION`: Add `"explanation"`, `"targetParagraph"`, `"options"`.
16. `MATCHING_FEATURES`: Add `"explanation"`, `"options"`.
17. `MATCHING_ENDINGS`: Add `"explanation"`, `"options"`.
18. `CLASSIFICATION`: Add `"explanation"`, `"options"`.
19. `FLOW_CHART`: Add `"explanation"`, `"flowSteps"`, `"stepIndex"`.
20. `SUMMARY_COMPLETION_BOX`: Add `"explanation"`, `"summaryText"`, `"options"`.
21. `CHOOSING_TITLE`: Add `"explanation"`, `"options"`.

Ensure `SYSTEM_PROMPTS` for all 21 families instruct:
- "- Include a detailed passage-grounded explanation of at least 25 characters for every candidate question or blank."

- [ ] **Step 4: Run test to verify it passes**

Run: `cd services/generation-service && .venv/bin/pytest tests/test_question_candidates_19types.py -v`
Expected: PASS.

- [ ] **Step 5: Commit changes**

```bash
git add services/generation-service/app/generators/question/prompts.py services/generation-service/tests/test_question_candidates_19types.py
git commit -m "fix(generation): align all 21 QuestionPromptFamily templates with parser explanation contract"
```

---

### Task 2: Align `_parse_candidate_payload()` in `app/section_runner.py`

**Files:**
- Modify: `services/generation-service/app/section_runner.py`
- Test: `services/generation-service/tests/unified/test_negative_correctness_suite.py`

**Interfaces:**
- Consumes: `raw_payload`, `q_num`, `q_type`, `passage_text`, `claims_map`, `claim_id`, `difficulty`.
- Produces: Validated canonical question dictionary with `explanation`, `passageEvidence`, and question-type specific fields.

- [ ] **Step 1: Write test verifying MAP_LABEL and strict fail-closed explanation checks**

Add tests verifying:
- `MAP_LABEL` is successfully parsed by `_parse_candidate_payload()` when given valid candidates with `explanation` >= 25 chars.
- Short explanations (< 25 chars) strictly raise `ValueError` for all completion types, with no fake explanation synthesis.

- [ ] **Step 2: Run test to verify it fails**

Run: `cd services/generation-service && .venv/bin/pytest tests/unified/test_negative_correctness_suite.py -k test_map_label -v`
Expected: FAIL because `MAP_LABEL` is currently unsupported in `_parse_candidate_payload()`.

- [ ] **Step 3: Update `_parse_candidate_payload()` in `app/section_runner.py`**

- In `_parse_candidate_payload()`:
  - Add `MAP_LABEL` to `elif q_type in ("DIAGRAM_LABEL", "MAP_LABEL"):`.
  - Remove dead code at lines 290-291 that attempted to synthesize fallback explanation strings if `len(explanation) < 25`.
  - Ensure strict fail-closed validation of `explanation` at line 87 remains inviolable.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd services/generation-service && .venv/bin/pytest tests/unified/test_negative_correctness_suite.py -v`
Expected: PASS.

- [ ] **Step 5: Commit changes**

```bash
git add services/generation-service/app/section_runner.py services/generation-service/tests/unified/test_negative_correctness_suite.py
git commit -m "fix(section_runner): support MAP_LABEL and enforce strict fail-closed candidate explanation contract"
```

---

### Task 3: Parameterized Offline Contract Tests for All 21 Families

**Files:**
- Create: `services/generation-service/tests/test_question_prompt_parser_contract.py`

**Interfaces:**
- Consumes: `QuestionPromptFamily`, `build_question_prompt()`, `render_question_prompt()`, `_parse_candidate_payload()`.
- Produces: Test coverage verifying prompt JSON schemas, realistic candidate parsing, and rejection of incomplete/malformed payloads across all 21 families.

- [ ] **Step 1: Implement parameterized test module covering all 21 families**

Write `test_question_prompt_parser_contract.py` with:
1. `test_prompt_template_renders_valid_json_structure(family)`:
   - Renders each of 21 families.
   - Extracts JSON example block from user prompt and verifies it parses as valid JSON or valid JSON schema structure.
   - Verifies `"explanation"` is present in the example schema.
   - Verifies 25-character explanation requirement is present in the prompt.
2. `test_parse_realistic_candidate_payload(family)`:
   - Deterministic test data representing realistic provider outputs for each family conforming to the prompt.
   - Passes to `_parse_candidate_payload()`.
   - Asserts all required fields are populated: `questionNumber`, `questionType`, `explanation` (len >= 25), `answer`, `passageEvidence`, and family-specific fields (`options`, `flowSteps`, `calloutLabel`, `tableContext`, etc.).
3. `test_rejection_missing_or_short_explanation(family)`:
   - Missing `explanation` -> raises `ValueError` ("explanation is missing or too short").
   - Short `explanation` (< 25 chars) -> raises `ValueError` ("explanation is missing or too short").
4. `test_rejection_malformed_payload(family)`:
   - Missing `candidates` and `blanks` -> raises `ValueError` ("missing candidates/blanks").
   - Non-dict payload -> raises `ValueError` ("Expected dict").

- [ ] **Step 2: Run new contract test suite**

Run: `cd services/generation-service && .venv/bin/pytest tests/test_question_prompt_parser_contract.py -v`
Expected: All tests PASS.

- [ ] **Step 3: Commit changes**

```bash
git add services/generation-service/tests/test_question_prompt_parser_contract.py
git commit -m "test(generation): add parameterized offline contract tests for all 21 QuestionPromptFamily templates"
```

---

### Task 4: Full Regression and Verification Suite

**Files:**
- Run all test suites across the generation service.

- [ ] **Step 1: Run complete 19-family/21-template test suites**

Run:
```bash
cd services/generation-service && .venv/bin/pytest \
  tests/test_question_prompt_parser_contract.py \
  tests/test_question_candidates_19types.py \
  tests/unified/test_golden_19_families_fixtures.py \
  tests/test_question_types_contract.py \
  tests/test_blind_solvers_19types.py \
  tests/test_phase15_v2_generator_fixes.py \
  tests/test_t09_question_candidates.py \
  tests/unified/test_section_standalone.py \
  tests/unified/test_negative_correctness_suite.py \
  tests/test_unified_pipeline_execution.py \
  tests/unified/test_content_generation_correctness_gates.py -v
```
Expected: All tests PASS with zero regressions.

- [ ] **Step 2: Verify git status and diff cleanly**

Run: `git status && git diff origin/autonomous-generation`
Confirm only intended files are modified/added, and no untracked files are unintentionally staged.

---

### Task 5: Push to Remote and Final Report

- [ ] **Step 1: Push branch to origin/autonomous-generation**

Run: `git push origin autonomous-generation`

- [ ] **Step 2: Produce final report**

Report:
- Exact templates fixed (all 21 `QuestionPromptFamily` templates and system prompts).
- Contract-test coverage (all 21 families tested for prompt rendering, JSON schema, realistic candidate parsing, and fail-closed rejection).
- Full regression results (all 116+ existing tests + new contract tests passing).
- Final git commit SHA and push status.
- Confirm LIVE_E2E was not run (offline verification only).
- STOP.
