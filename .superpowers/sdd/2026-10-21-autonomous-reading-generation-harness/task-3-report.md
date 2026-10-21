# Task 3 Report: 19-Type Prompt Generation & Candidate Validation Engine

## 1. Overview & What Was Implemented
Task 3 ensures that the prompt generation templates (`app/generators/question/prompts.py`) and candidate validation engine (`app/context.py` and `app/generators/question/context.py`) support all 19 IELTS Reading question families end-to-end.

### Key Deliverables:
1. **`app/generators/question/prompts.py`**:
   - Updated `QuestionPromptFamily` enum and flexible resolver `from_raw` to support all 19 canonical IELTS question families with their wire constants and camelCase aliases.
   - Added complete system prompts (`SYSTEM_PROMPTS`) and prompt templates (`PROMPT_TEMPLATES`) for newly integrated families: `SUMMARY_COMPLETION_BOX`, `CHOOSING_TITLE`, `FLOW_CHART`, `DIAGRAM_LABEL`, and complex matching/completion types.
   - For visual and process types (`FLOW_CHART`, `DIAGRAM_LABEL`), enhanced prompt templates to ask for layout descriptions, step sequences, part descriptions, and blank callout numbers.
   - Implemented `render_question_prompt(family: Union[QuestionPromptFamily, str], slot_number: int, passage_text: str, ...)` providing formatted prompts with system instructions, passage envelope, and output JSON schemas.
2. **`app/context.py`**:
   - Implemented `validate_candidate_slot(candidate: Any, family: Union[QuestionPromptFamily, str]) -> List[ContextValidationIssue]`:
     - Checks prompt and answer non-emptiness and placeholder prevention.
     - Validates English-only language policy.
     - Validates TFNG and YNNG valid answer strings (`TRUE`, `FALSE`, `NOT GIVEN` / `YES`, `NO`, `NOT GIVEN`) and requires an `absence_assessment` confirming omission from passage for NOT GIVEN candidates.
     - Enforces word count limits (<= 3 words) across all completion types (`SENTENCE_COMPLETION`, `SUMMARY_COMPLETION`, `TABLE_COMPLETION`, `NOTE_COMPLETION`, `FORM_COMPLETION`, `FLOW_CHART`, `DIAGRAM_LABEL`, `SHORT_ANSWER`).
     - Enforces blank marker requirements (`______`) for sentence completions.
     - Enforces options cardinality and duplicate detection for `MULTIPLE_CHOICE_SINGLE` (4 options A-D), `CHOOSING_TITLE` (4 options A-D), `MULTIPLE_CHOICE_MULTIPLE` (>= 4 options), `SUMMARY_COMPLETION_BOX` (>= 3 options), `MATCHING_HEADING` (>= 3 headings), `MATCHING_FEATURES`, `MATCHING_ENDINGS`, and `CLASSIFICATION` (>= 2 options).
     - Enforces sequential flow steps for `FLOW_CHART` and callout label / part description for `DIAGRAM_LABEL`.
3. **`app/generators/question/context.py`**:
   - Extended `QuestionCandidate.validate_type_specific_invariants` to validate candidates across all 19 families and integrated `validate_candidate_slot`.
4. **Test Suite `services/generation-service/tests/test_question_candidates_19types.py`**:
   - Comprehensive unit and integration test suite covering prompt rendering and candidate validation across all 19 IELTS families.

---

## 2. TDD Evidence

### Step 1 & 2: RED Phase (Failing Test)
**Command:**
```bash
pytest tests/test_question_candidates_19types.py -v
```
**Output:**
```
__________ ERROR collecting tests/test_question_candidates_19types.py __________
ImportError while importing test module '/home/code/workspaces/langfens/Project_Langfens_Microservice/services/generation-service/tests/test_question_candidates_19types.py'.
tests/test_question_candidates_19types.py:18: in <module>
    from app.generators.question.prompts import render_question_prompt
E   ImportError: cannot import name 'render_question_prompt' from 'app.generators.question.prompts'
ERROR tests/test_question_candidates_19types.py
pytest: 1 error in 0.46s
```

### Step 4 & 5: GREEN Phase (Passing Test)
**Command:**
```bash
pytest tests/test_question_candidates_19types.py -v
```
**Output:**
```
tests/test_question_candidates_19types.py::test_render_question_prompt_all_19_types PASSED [ 14%]
tests/test_question_candidates_19types.py::test_validate_candidate_slot_true_false_and_yes_no PASSED [ 28%]
tests/test_question_candidates_19types.py::test_validate_candidate_slot_completions PASSED [ 42%]
tests/test_question_candidates_19types.py::test_validate_candidate_slot_mcq_single_and_multiple PASSED [ 57%]
tests/test_question_candidates_19types.py::test_validate_candidate_slot_visual_and_complex_types PASSED [ 71%]
tests/test_question_candidates_19types.py::test_validate_candidate_slot_with_pydantic_instances PASSED [ 85%]
tests/test_question_candidates_19types.py::test_validate_candidate_slot_comprehensive_19_families PASSED [100%]

============================== 7 passed in 0.29s ===============================
```

### Regression Verification:
**Command:**
```bash
pytest tests/test_question_candidates_19types.py tests/test_t09_question_candidates.py tests/test_dynamic_blueprint.py -v
```
**Output:**
```
============================== 21 passed in 3.30s ==============================
```

---

## 3. Files Changed
- `services/generation-service/app/generators/question/prompts.py` (Modified): Added 19 families support, system prompts, templates with visual details, and `render_question_prompt`.
- `services/generation-service/app/context.py` (Created): Implemented candidate slot validation engine and `ContextValidationIssue`.
- `services/generation-service/app/generators/question/context.py` (Modified): Integrated 19-family candidate validation into `QuestionCandidate`.
- `services/generation-service/tests/test_question_candidates_19types.py` (Created): TDD tests covering all 19 prompt templates and candidate slot validation scenarios.

---

## 4. Commits Created
- `d0c9ec5 feat(generation): support prompt generation and candidate validation for 19 question families`

---

## 5. Self-Review Findings
- **Consistency**: Verified all 19 enum members in `QuestionPromptFamily` align across `app.contracts.question_type`, `app.generators.question.prompts`, and candidate schemas in `app.contracts.questions`. All lookup aliases handle case and underscore variations.
- **Scope**: Changes were strictly limited to question prompts and candidate validation contracts without breaking existing callers or modifying unrelated files.
- **Verification**: Verified 7 new tests and 14 existing regression tests across the question generator test suite; all pass cleanly.

## 6. Review Findings Resolution (Task 3 Fixes)

### Issues Addressed:
1. **Critical: Prompt Schema vs Slot Validator Contradiction (`MATCHING_HEADING`, `MATCHING_FEATURES`, `MATCHING_ENDINGS`, `CLASSIFICATION`)**:
- Updated JSON schemas in `prompts.py` for `MATCHING_HEADING` to explicitly include a `"headings"` array (>= 3 headings) and for `MATCHING_FEATURES`, `MATCHING_ENDINGS`, and `CLASSIFICATION` to include an `"options"` array.
- Updated `context.py` to flexibly query candidate options/headings across dict keys and object attributes.
2. **Important: Defective Absence Assessment Check for Pydantic Models (`NOT GIVEN`)**:
- Fixed `app/context.py` to evaluate truthiness of `is_absent` and `absence_confirmed` properly for both dicts and Pydantic object instances (`getattr(absence_raw, "is_absent", ...)`).
3. **Important: Blank Marker Validation Across Completion Families**:
- Extended blank marker validation (`______`, `[blank]`, or `[1]`) across all completion question families (`SENTENCE_COMPLETION`, `TABLE_COMPLETION`, `NOTE_COMPLETION`, `FORM_COMPLETION`, and `FLOW_CHART`).

### Test Coverage & Verification:
- Added `test_matching_and_classification_prompt_schemas_include_options_and_headings` in `tests/test_question_candidates_19types.py`.
- Added tests for Pydantic object absence assessment validation (falsy vs truthy `is_absent`).
- Added tests enforcing blank marker requirements across all completion families and flow charts.
- Full test suite passed: 8 passed in `tests/test_question_candidates_19types.py`, 22 passed across question generator suites.
