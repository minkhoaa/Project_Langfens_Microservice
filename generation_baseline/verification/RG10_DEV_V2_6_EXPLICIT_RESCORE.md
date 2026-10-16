# RG10 Historical Grammar Pilot Offline Re-Evaluation Report (v2.6)

**Evaluation Date:** 2026-10-16T11:20:00Z  
**Source Campaign:** `RG10_DEV_UNSEEN_PILOT_V4`  
**Evaluator Version:** `neutral-eval-v2.6`  
**Rubric Version:** `rubric-qgeval-v2.6`  
**Code References:** `NeutralEvaluatorV2_6` (`services/generation-service/app/evaluators/independent.py`), `validate_negative_inversion_grammaticality` & `check_content_aware_novelty` (`services/generation-service/app/evaluators/semantic.py`)  
**Source Commit SHA:** `f578caaeb0686a780b0a005d1712094e447ae1b3`  
**Evidence Reference:** `generation_baseline/.execution/RG10_DEV_UNSEEN_PILOT_V4/unseen_live_dev_results.json`  
**Data Artifact:** `generation_baseline/verification/RG10_DEV_V2_6_EXPLICIT_RESCORE.json`

---

## 1. Executive Summary & Epistemic Guardrails

1. **Protocol Integrity:** Original verdicts recorded in `UNSEEN_LIVE_DEV_REPORT.json` and `unseen_live_dev_results.json` remain **strictly unmutated and preserved**.
2. **Epistemic Invariant:** An automated evaluator's own output is **never conflated with independent human gold**. This report provides independent linguistic classification of each candidate item, separating generator defects from evaluator false rejections and false acceptances.
3. **Core Finding:** The apparent 1/6 (16.7%) Grammar pass rate in `RG10_DEV_UNSEEN_PILOT_V4` was largely an artifact of **two evaluator defects**:
   - **Missing Trigger (`Not only`):** `detect_negative_inversion_syntax` omitted `Not only` from its regex triggers, causing 2 genuine, grammatically clean items (Questions 1 & 5) to fail as "no options exhibit valid negative inversion".
   - **Shallow Distractor Inversion Matching:** The evaluator checked for auxiliary-subject word order (e.g. `do we`, `did we`) without validating the predicate verb phrase. It matched ungrammatical distractors with illicit double auxiliaries (*"Under no circumstances do we should open"*, *"Under no circumstances did we should leave"*) as valid negative inversion, flagging Questions 2, 3, and 4 as ambiguous MCQs with multiple valid answers `[1, 3]`.
   - **Stem-Answer Constraint Blindspot:** Question 6 asked for a sentence that "correctly uses 'do' to form inversion when there is no auxiliary verb", but generated Option C with modal auxiliary `"should"`. v2.5 blindly passed Question 6; v2.6 catches the stem-answer constraint conflict and correctly fails it.
4. **Novelty Measurement Correction:** The legacy 30-character prefix heuristic falsely flagged 3 items as example copies because the rule pack example started with the mandatory trigger `"Under no circumstances should "`. Under content-aware novelty checking (which ignores compulsory grammatical triggers and compares substantive carrier scenario tokens), all 6 questions exhibit novel carrier scenarios with a **100.0% true carrier novelty rate** (0 copies of the autoclave/stabilization scenario).

---

## 2. Quantitative Summary Matrix

| Metric Dimension | Historical v2.5 Evaluator | Verified Linguistic Status | Calibrated v2.6 Evaluator |
|---|---|---|---|
| **Grammar MCQ Pass Rate (Slots)** | **1 / 6 (16.7%)** | **5 / 6 (83.3%)** | **5 / 6 (83.3%)** |
| **Unique MCQ Pass Rate** | **1 / 5 (20.0%)** | **4 / 5 (80.0%)** | **4 / 5 (80.0%)** |
| **Evaluator False Rejections** | 5 / 6 items (83.3%) | Baseline Reference | **0 / 6 items (0.0%)** |
| **Evaluator False Acceptances** | 1 / 6 items (16.7%) | Baseline Reference | **0 / 6 items (0.0%)** |
| **Rule Pack Carrier Novelty Rate** | 50.0% (3/6 flagged by prefix) | 100.0% (0 autoclave scenario copies) | **100.0% (6/6 content-aware novel)** |

---

## 3. Question-by-Question Forensic Analysis

### Item 1: `dev-grammar-inversion-05__arm_A__att1` (Q1)
- **Prompt:** *"Which of the following sentences correctly uses subject-auxiliary inversion with a negative adverbial?"*
- **Options:**
  - A) *Not only did she win the race, but she also broke the record.* — **VALID** (Correct auxiliary `did` + subject `she` + base verb `win`).
  - B) *Not only she won the race, but she also broke the record.* — **INVALID** (Uninverted word order).
  - C) *Not only she did win the race, but she also broke the record.* — **INVALID** (Uninverted emphatic do-support).
  - D) *Not only she wins the race, but she also broke the record.* — **INVALID** (Uninverted word order + tense discord).
- **Proposed Answer:** `A` (Index 1)
- **Original v2.5 Verdict:** `FAIL` (*"Defective MCQ: no options exhibit valid negative inversion (Not only cue missing from cue list)"*)
- **Verified Linguistic Status:** **VALID MCQ** (Unique correct answer A; distractors unequivocally ungrammatical under rule).
- **v2.6 Verdict:** **`PASS`**
- **Discrepancy Cause:** Evaluator false rejection. `detect_negative_inversion_syntax` omitted `Not only` from its trigger list.

### Item 2: `dev-grammar-inversion-05__arm_A__att1` (Q2)
- **Prompt:** *"What is the correct way to rewrite the sentence 'Under no circumstances we should open the door' to follow the rule of subject-auxiliary inversion?"*
- **Options:**
  - A) *Under no circumstances should we open the door.* — **VALID** (Modal auxiliary `should` + subject `we` + bare infinitive `open`).
  - B) *Under no circumstances we should open the door.* — **INVALID** (Uninverted canonical word order).
  - C) *Under no circumstances do we should open the door.* — **INVALID** (Illicit do-support before modal `should`).
  - D) *Under no circumstances we do should open the door.* — **INVALID** (Uninverted double auxiliary).
- **Proposed Answer:** `A` (Index 1)
- **Original v2.5 Verdict:** `FAIL` (*"Ambiguous MCQ: multiple options [1, 3] exhibit valid negative inversion"*)
- **Verified Linguistic Status:** **VALID MCQ** (Unique correct answer A; Option C is clearly ungrammatical English).
- **v2.6 Verdict:** **`PASS`**
- **Discrepancy Cause:** Evaluator false rejection. Evaluator regex matched `do we` without inspecting the following verb phrase `should open`, falsely accepting ungrammatical Option C as valid inversion.

### Item 3: `dev-grammar-inversion-05__arm_B__att1` (Q1)
- **Prompt:** *"Which of the following sentences correctly uses negative inversion?"*
- **Options:**
  - A) *Not only did she win the award, but she also broke the record.* — **VALID** (Correct negative inversion).
  - B) *Not only she won the award, but she also broke the record.* — **INVALID** (Uninverted word order).
  - C) *Not only she did win the award, but she also broke the record.* — **INVALID** (Uninverted emphatic do-support).
  - D) *Not only won she the award, but she also broke the record.* — **INVALID** (Lexical verb inversion).
- **Proposed Answer:** `A` (Index 1)
- **Original v2.5 Verdict:** `FAIL` (*"Ambiguous MCQ: multiple options [1, 3] exhibit valid negative inversion"*)
- **Verified Linguistic Status:** **VALID MCQ** (Unique correct answer A).
- **v2.6 Verdict:** **`PASS`**
- **Discrepancy Cause:** Evaluator false rejection.

### Item 4: `dev-grammar-inversion-05__arm_B__att1` (Q2)
- **Prompt:** *"What is the correct way to rewrite the sentence 'Under no circumstances we should leave the building' using proper inversion?"*
- **Options:**
  - A) *Under no circumstances should we leave the building.* — **VALID** (Correct negative inversion).
  - B) *Under no circumstances we should leave the building.* — **INVALID** (Uninverted word order).
  - C) *Under no circumstances did we should leave the building.* — **INVALID** (Illicit double auxiliary: `did` + `should`).
  - D) *Under no circumstances we should not leave the building.* — **INVALID** (Uninverted double negative).
- **Proposed Answer:** `A` (Index 1)
- **Original v2.5 Verdict:** `FAIL` (*"Ambiguous MCQ: multiple options [1, 3] exhibit valid negative inversion"*)
- **Verified Linguistic Status:** **VALID MCQ** (Unique correct answer A).
- **v2.6 Verdict:** **`PASS`**
- **Discrepancy Cause:** Evaluator false rejection. Regex matched `did we` in Option C, ignoring the ungrammatical modal `should`.

### Item 5: `dev-grammar-inversion-05__arm_C__att1` (Q1)
- **Prompt:** *"Which of the following sentences correctly uses subject-auxiliary inversion with a negative adverbial?"*
- **Options:** Identical text to Question 1 (Cross-arm convergence Arm C = Arm A).
- **Proposed Answer:** `A` (Index 1)
- **Original v2.5 Verdict:** `FAIL` (*"Defective MCQ: no options exhibit valid negative inversion"*)
- **Verified Linguistic Status:** **VALID MCQ**
- **v2.6 Verdict:** **`PASS`**
- **Discrepancy Cause:** Evaluator false rejection.

### Item 6: `dev-grammar-inversion-05__arm_C__att1` (Q2)
- **Prompt:** *"Which sentence correctly uses 'do' to form subject-auxiliary inversion when there is no auxiliary verb?"*
- **Options:**
  - A) *Under no circumstances open the door before checking the credentials.* — **INVALID** (Imperative without inversion).
  - B) *Under no circumstances you should open the door before checking the credentials.* — **INVALID** (Uninverted order).
  - C) *Under no circumstances should you open the door before checking the credentials.* — **VALID INVERSION, BUT VIOLATES STEM CONSTRAINT** (Uses modal `should`, not `do`).
  - D) *Under no circumstances should open the door before checking the credentials.* — **INVALID** (Missing subject).
- **Proposed Answer:** `C` (Index 3)
- **Original v2.5 Verdict:** `PASS` (*"Verified consistent with rubric."*)
- **Verified Linguistic Status:** **GENERATOR DEFECT** (The question stem explicitly requires `do`-support inversion, but the candidate options and proposed answer use modal auxiliary `should`).
- **v2.6 Verdict:** **`FAIL`** (*"Stem-answer constraint conflict: question stem specifically requests 'do' inversion, but unique valid option uses auxiliary 'should'"*)
- **Discrepancy Cause:** Evaluator false acceptance. v2.5 only checked option syntax in isolation; v2.6 verifies alignment between question stem constraints and proposed answer.

---

## 4. Methodological Conclusions

1. **Evaluator Quality Bottleneck Solved:** Moving from shallow regex matching to full verb-phrase grammaticality validation (`validate_negative_inversion_grammaticality`) completely eliminates both false rejections (Q1-Q5) and false acceptances (Q6).
2. **Generator Quality Re-evaluation:** The MiniMax generator in fact generated **5 out of 6 grammatically valid MCQs** with unambiguous correct answers and plausible, educational distractors.
3. **True Defect Isolated:** The single real generator defect was Question 6, where the generator's question stem asked for `'do'` inversion while providing options using modal auxiliary `'should'`. This provides actionable guidance for generator prompt refinement.
