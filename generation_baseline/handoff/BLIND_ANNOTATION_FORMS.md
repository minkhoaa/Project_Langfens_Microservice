# Blind Human Annotation Forms: Reading & Grammar

**Phase:** RG10 Confirmatory Research Freeze  
**Document:** Standardized Blind Annotation Forms  
**Target:** Qualified Human Expert Annotators (Annotator 1, Annotator 2, Chief Adjudicator)  
**Governing Standard:** `generation_baseline/research/HUMAN_REVIEW_PROTOCOL_AND_RUBRIC.md`  

---

## 1. Blinding Protocol & Instructions to Annotators

To ensure scientific validity and eliminate confirmation bias:
1. **Blind Evaluation:** You will receive questions and passages identified only by opaque task IDs (`task_hrev_[a-f0-9]{12}`). You will NOT receive:
   - Experimental arm labels (Arm A, Arm B, Arm C).
   - Pipeline metadata (model name, prompt version, revision iterations).
   - Automated evaluator scores or pass/fail flags.
   - Proposed system answer keys.
2. **Independent Key Determination:** You must independently determine the correct, defensible answer without reference to any system prediction.
3. **Four Dimension Scores (1 to 5 Scale):**
   - **Dimension 1:** Source Grounding (Reading) / Rule Conformance (Grammar)
   - **Dimension 2:** Answer Key Uniqueness & Defensibility
   - **Dimension 3:** Distractor Plausibility & Defect Definitiveness
   - **Dimension 4:** Linguistic Naturalness & IELTS Academic Register
4. **Binary Acceptability:** Assign `PASS` (suitable for official IELTS Academic publication) or `FAIL` (contains factual error, multiple keys, ungrounded statement, or unnatural syntax).

---

## 2. Standardized Blind Annotation Form: Reading (TFNG)

*Complete one form per Reading item.*

```yaml
---
annotation_record:
  form_type: "READING_TFNG_BLIND_EVALUATION"
  task_id: "task_hrev_000000000000"           # Opaque task identifier
  annotator_id: "annotator_01"                # "annotator_01" or "annotator_02"
  annotation_timestamp: "YYYY-MM-DDTHH:MM:SSZ"

evaluation_inputs_received:
  passage_text: "[Full passage text presented to reviewer]"
  statement: "[Statement presented to reviewer]"
  options_available: ["TRUE", "FALSE", "NOT GIVEN"]

annotator_judgment:
  annotator_selected_key: "[ANNOTATOR: EXACTLY ONE OF 'TRUE', 'FALSE', 'NOT GIVEN']"
  key_confidence: "[ANNOTATOR: INTEGER 1 (LOW) TO 5 (CERTAIN)]"
  
  rubric_dimension_scores:
    dim1_source_grounding: "[ANNOTATOR: INTEGER 1 TO 5]"
    dim2_key_uniqueness: "[ANNOTATOR: INTEGER 1 TO 5]"
    dim3_distractor_quality: "[ANNOTATOR: INTEGER 1 TO 5]"
    dim4_academic_register: "[ANNOTATOR: INTEGER 1 TO 5]"
  
  overall_verdict: "[ANNOTATOR: 'PASS' OR 'FAIL']"
  
  textual_evidence:
    verbatim_passage_span: "[ANNOTATOR: VERBATIM PASSAGE SPAN; NULL IF NOT GIVEN]"
    paragraph_number: "[ANNOTATOR: INTEGER PARAGRAPH NUMBER OR NULL]"
    sentence_number: "[ANNOTATOR: INTEGER SENTENCE NUMBER OR NULL]"
    
  qualitative_finding: >
    [ANNOTATOR: DETAILED QUALITATIVE FINDING EXPLAINING ENTAILMENT / CONTRADICTION / UNMENTIONED STATUS]
---
```

---

## 3. Standardized Blind Annotation Form: Grammar (MCQ)

*Complete one form per Grammar item.*

```yaml
---
annotation_record:
  form_type: "GRAMMAR_MCQ_BLIND_EVALUATION"
  task_id: "task_hrev_000000000000"           # Opaque task identifier
  annotator_id: "annotator_01"                # "annotator_01" or "annotator_02"
  annotation_timestamp: "YYYY-MM-DDTHH:MM:SSZ"

evaluation_inputs_received:
  question_stem: "[Question prompt text presented to reviewer]"
  options:
    A: "[Option A text]"
    B: "[Option B text]"
    C: "[Option C text]"
    D: "[Option D text]"

annotator_judgment:
  annotator_selected_key: "[ANNOTATOR: EXACTLY ONE OF 'A', 'B', 'C', 'D' OR 'NONE']"
  key_confidence: "[ANNOTATOR: INTEGER 1 (LOW) TO 5 (CERTAIN)]"
  
  rubric_dimension_scores:
    dim1_rule_conformance: "[ANNOTATOR: INTEGER 1 TO 5]"
    dim2_key_uniqueness: "[ANNOTATOR: INTEGER 1 TO 5 (MUST BE 1 IF MULTIPLE DEFENSIBLE KEYS)]"
    dim3_distractor_plausibility: "[ANNOTATOR: INTEGER 1 TO 5]"
    dim4_academic_register: "[ANNOTATOR: INTEGER 1 TO 5]"
  
  overall_verdict: "[ANNOTATOR: 'PASS' OR 'FAIL']"

  distractor_analysis:
    flaw_in_first_distractor: "[ANNOTATOR: EXPLANATION OF SYNTACTIC DEFECT IN DISTRACTOR 1]"
    flaw_in_second_distractor: "[ANNOTATOR: EXPLANATION OF SYNTACTIC DEFECT IN DISTRACTOR 2]"
    flaw_in_third_distractor: "[ANNOTATOR: EXPLANATION OF SYNTACTIC DEFECT IN DISTRACTOR 3]"
    
  qualitative_finding: >
    [ANNOTATOR: DETAILED QUALITATIVE FINDING EXPLAINING DEFENSIBILITY OF KEY AND DEFECTS OF DISTRACTORS]
---
```

---

## 4. Scoring Form Submission Protocol

Annotators submit completed YAML/JSON records directly to the Senior Adjudicator repository directory (`generation_baseline/adjudication/submissions/`). Neither developers nor automated system processes may access or parse these files until both annotators have submitted complete batches.
