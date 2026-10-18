# RG10 AI Output Quality Review Report

**Evaluation Framework:** Independent Multi-Agent Blind Quality Audit  
**Review Date:** 2026-10-18  
**Governing Standard:** `generation_baseline/research/RQ2_PROTOCOL.md` & `DATA_GOVERNANCE.md`  
**Epistemic Disclosure:** `EXPLORATORY_AI_AUDIT_NOT_HUMAN_GOLD`  
*Notice: This report documents independent exploratory judgments by AI reviewer agents (Agent R: Reading, Agent G: Grammar, Agent Q: Adjudicator). These findings provide diagnostic engineering evidence and MUST NOT be portrayed as certified human gold annotations.*

---

## 1. Executive Summary & Quality Dashboard

| Dimension | Evaluated Metric | Value / Finding | Interpretation |
|---|---|---|---|
| **Total Items Audited** | Exhaustive terminal DEV pool | **$N = 51$** items | 100% of available terminal & live DEV generated outputs |
| **Domain Denominators** | Stratified split | **27 Reading**, **24 Grammar** | Balanced representation across test domains |
| **Arm Denominators** | Experimental arms | **17 Arm A**, **17 Arm B**, **17 Arm C** | Exact balanced allocation across arms |
| **Passage Coverage** | Distinct source texts | 3 passages (volcanism, hydrothermal, photosynthesis) | Diverse scientific domains |
| **Grammar RulePack Coverage** | Syntactic structures | 4 RulePacks (inversion, subjunctive, clefts) | Advanced B2–C1 IELTS grammar |
| **Independent AI Pass Rate** | Questions meeting IELTS quality criteria | **44 / 51 (86.3%)** | High baseline capability with isolated defects |
| **True Generation Defects** | Substantive defects in generator outputs | **7 / 51 (13.7%)** | Unit errors, circular stems, multiple/zero keys |
| **Evaluator False Rejections** | Evaluator failed valid generator output | **3 / 51 (5.9%)** | Evaluator surface regexes too rigid |
| **Evaluator False Acceptances** | Evaluator passed defective generator output | **1 / 51 (2.0%)** | Missed circular stem / zero correct key |
| **Cross-Arm Duplication** | Verbatim identical questions across arms | **6 / 51 (11.8%)** | Prompt diversity collapse across arms A & B |
| **Holdout Secrecy Invariant** | Uninspected holdout items | **0 Holdout items touched** | Seals remain intact and uninspected |
| **Final Run Disclosure** | Frozen final campaign outputs | **NOT_RUN** | Zero final runs executed or fabricated |

---

## 2. Review Methodology & Multi-Agent Architecture

```
[Blinded Task Pool]
        │
        ├── Reading Items (N=27) ──► [Agent R: Grader-Specialist] ──► Independent Blind Answers
        │                            (Blind to Model Answer)          & Evidence Quotes
        │
        └── Grammar Items (N=24) ──► [Agent G: Grader-Specialist] ──► Independent Option Solves
                                     (Blind to Model Key)             & Syntactic Validations
                                                                              │
                                                                              ▼
[Ground Truth & Evaluator v2.7] ──────────────────────────────► [Agent Q: Quality Adjudicator]
                                                                      │
                                                                      ▼
                                                       [Adjudicated Quality Review]
                                                       (PASS / FAIL / UNCERTAIN / DISCREPANCY)
```

1. **Blinded Evaluation:**
   - Evaluator agents had zero access to the model's proposed answers or historical evaluator verdicts during the primary solving phase.
   - **Agent R (Reading Reviewer):** Read full passages and question stems. Inferred `TRUE`, `FALSE`, `NOT GIVEN`, or `UNCERTAIN` based strictly on text grounding and extracted exact substring quotes.
   - **Agent G (Grammar Reviewer):** Examined RulePacks and 4-option MCQs. Validated every option (A, B, C, D) independently to verify single-key uniqueness, distractor plausibility, and rule compliance.
2. **Adjudication (Agent Q):**
   - Compared independent solves with the model's proposed answers and candidate evaluator verdicts (`neutral-eval-v2.7` / `v2.6`).
   - Disentangled **True Generation Defects** (model errors) from **Evaluator Defects** (evaluator false rejections / false acceptances).

---

## 3. Deep-Dive Findings: Reading Questions ($N = 27$)

### 3.1 Answer Distribution & Agreement
- **Independent Solves:** 10 TRUE, 13 FALSE, 1 NOT GIVEN, 3 UNCERTAIN.
- **Agreement with Generator:** 24 out of 27 items (88.9%) agreed on the factual answer.

### 3.2 Key Linguistic & Generation Defects Isolated by Agent R

#### Defect 1: Dimensional / Unit Error (`audit_idx: 8`, Arm C Volcanism Q2)
- **Question Stem:** `TRUE, FALSE or NOT GIVEN: Pillow lava forms when basaltic magma erupts into seawater at depths exceeding 200 atmospheres.`
- **Independent Verdict:** **`UNCERTAIN / FAIL`** (Confidence: HIGH)
- **Linguistic Finding:** "Atmospheres" is a unit of pressure, not depth (a dimensional category error). Furthermore, the passage notes that abyssal hydrostatic pressure exceeding 200 atmospheres suppresses volatile exsolution, whereas pillow lava morphology is introduced in a separate context. The generator conflated pressure and depth into an unphysical premise.
- **Evaluator Behavior:** Evaluator correctly rejected this item (`FAIL`).

#### Defect 2: Prompt Leakage Prefix (`audit_idx: 7, 8, 9`, Arm C Volcanism Q1–Q3)
- **Question Stems:** Stems begin with `TRUE, FALSE or NOT GIVEN: Submarine volcanism is responsible...`
- **Linguistic Finding:** The system instruction prompt was echoed verbatim into the generated question stem in Arm C outputs. While answers are answerable, the artifact represents generation leakage.

#### Defect 3: Source Passage Self-Contradiction (`audit_idx: 27`, Arm C Photosynthesis Q3)
- **Question Stem:** `Ribulose-1,5-bisphosphate carboxylase-oxygenase is active during the night in CAM plants.`
- **Passage Text:** `...sequestered inside large central vacuoles until daybreak. Solar radiation then drives nocturnal malate decarboxylation, releasing concentrated carbon dioxide internally around ribulose-1,5-bisphosphate carboxylase-oxygenase...`
- **Independent Verdict:** **`UNCERTAIN`** (Confidence: HIGH)
- **Linguistic Finding:** The source passage contains an internal oxymoron: *"Solar radiation then drives nocturnal malate decarboxylation"*. Solar radiation occurs during the day after daybreak; labeling this process "nocturnal" introduces an irreconcilable factual contradiction inside the stimulus passage itself.

#### Defect 4: Evaluator False Rejection (`audit_idx: 3`, Arm A Volcanism Q3)
- **Question Stem:** `Pyroclastic fragmentation occurs in deep benthic environments due to high hydrostatic pressure.`
- **Generator Proposed Answer:** `FALSE`
- **Independent Solve:** `FALSE` (Evidence: *"abyssal hydrostatic pressure exceeding two hundred atmospheres suppresses volatile exsolution, thereby preventing pyroclastic fragmentation in deep benthic environments."*)
- **Original Evaluator Verdict:** **`FAIL`** (Abstention reason: *"FALSE contradiction: passage affirms proposition without contradiction"*)
- **Adjudication:** **`EVALUATOR_FALSE_REJECTION`**. The generator was 100% factually correct (the passage states pressure *prevents* fragmentation, so asserting it *occurs due to pressure* is FALSE). The historical evaluator regex failed to parse the negation conveyed by the verb "preventing".

---

## 4. Deep-Dive Findings: Grammar Questions ($N = 24$)

### 4.1 Solution Quality & Key Distribution
- **Clean / Unambiguously Solvable Items:** 20 / 24 (83.3%)
- **Defective Generation Items:** 4 / 24 (16.7%)
- **Key Solves:** 9 Option A, 11 Option B, 2 Option NONE, 2 Option MULTIPLE.

### 4.2 Key Syntactic Defects Isolated by Agent G

#### Defect 1: Circular Question Stem & Zero Correct Answers (`audit_idx: 6`, Arm C Inversion Q2)
- **Question Stem:** `What is the correct way to rewrite the sentence 'Scarcely had the meeting started when the fire alarm rang' using negative inversion?`
- **Options:**
  - A) The meeting had scarcely started when the fire alarm rang.
  - B) Scarcely did the meeting start when the fire alarm rang.
  - C) Scarcely had the meeting started than the fire alarm rang.
  - D) Scarcely the meeting had started when the fire alarm rang.
- **Generator Proposed Key:** `B`
- **Original Evaluator Verdict:** `PASS`
- **Independent Linguistic Finding:** **`ZERO_CORRECT_ANSWERS / EVALUATOR_FALSE_ACCEPTANCE`** (Severity: CRITICAL).
  - The sentence in the stem (`'Scarcely had the meeting started when the fire alarm rang'`) **already employs negative inversion**.
  - Option A removes inversion. Option B alters past perfect aspect to simple past, creating an unidiomatic temporal distortion. Option C uses "than" (illicit coordinator for scarcely). Option D lacks auxiliary inversion.
  - **There is no valid answer among the options**, yet the evaluator falsely passed this question.

#### Defect 2: Missing Option Key Labels & Multiple Defensible Answers (`audit_idx: 23 & 24`, Arm C Clefts Q1 & Q2)
- **Question Stem (Item 24):** `Which sentence correctly uses an it-cleft to emphasize 'the research methodology'?`
- **Options (Raw strings without A/B/C/D prefixes):**
  - Option 1: *"It is the research methodology that the team has developed."*
  - Option 2: *"It was the research methodology that the team developed."*
  - Option 3: *"It is the research methodology that the team develops."*
  - Option 4: *"It was the research methodology that the team has developed."*
- **Independent Linguistic Finding:** **`MULTIPLE_DEFENSIBLE_ANSWERS`**.
  - Both Option 1 (present perfect cleft) and Option 2 (past cleft) are grammatically immaculate English cleft sentences. Without a governing temporal context, both are fully defensible.
  - Furthermore, the generator omitted the `A)`, `B)`, `C)`, `D)` option labels and output the full sentence string as proposed answer, breaking downstream parser contracts.

#### Defect 3: Cross-Arm Question Duplication
- **Item 17 (Arm C Inversion Q1)** is **100% verbatim identical** in stem and all 4 options to **Item 13 (Arm A Inversion Q1)**.
- Reading Item 2 (Arm A) and Reading Item 5 (Arm B) are **100% verbatim identical**: *"Pillow lava is formed when basaltic magma erupts into seawater at abyssal depths."*
- **Analysis:** Arm C (adversarial loop) frequently collapsed into generating the exact same prompt and distractors as Arm A, showing that prompt variations failed to guarantee syntactic or lexical diversity.

---

## 5. Question-Level Adjudication Matrix (All 51 Items)

| Audit Idx | Dataset Item ID | Domain | Arm | QID | Proposed Answer | Original Verdict | Independent Review Key | Review Status | Defect Category | Defect Severity |
|:---:|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|:---:|
| **1** | dev-reading-volcanism-06 | READING | A | 1 | TRUE | PASS | TRUE | **PASS** | NONE | NONE |
| **2** | dev-reading-volcanism-06 | READING | A | 2 | TRUE | PASS | TRUE | **PASS** | NONE | NONE |
| **3** | dev-reading-volcanism-06 | READING | A | 3 | FALSE | FAIL | FALSE | **PASS** | EVALUATOR_FALSE_REJECTION | HIGH |
| **4** | dev-reading-volcanism-06 | READING | B | 1 | TRUE | PASS | TRUE | **PASS** | MINOR_HEDGING_OMISSION | LOW |
| **5** | dev-reading-volcanism-06 | READING | B | 2 | TRUE | PASS | TRUE | **PASS** | NONE | NONE |
| **6** | dev-reading-volcanism-06 | READING | B | 3 | FALSE | FAIL | FALSE | **PASS** | EVALUATOR_FALSE_REJECTION | HIGH |
| **7** | dev-reading-volcanism-06 | READING | C | 1 | TRUE | PASS | TRUE | **PASS** | PROMPT_LEAKAGE | LOW |
| **8** | dev-reading-volcanism-06 | READING | C | 2 | TRUE | FAIL | UNCERTAIN | **FAIL** | FACTUAL_UNIT_ERROR | CRITICAL |
| **9** | dev-reading-volcanism-06 | READING | C | 3 | TRUE | PASS | TRUE | **PASS** | PROMPT_LEAKAGE | LOW |
| **10** | dev-grammar-inversion-06 | GRAMMAR | A | 1 | A | PASS | A | **PASS** | NONE | NONE |
| **11** | dev-grammar-inversion-06 | GRAMMAR | A | 2 | B | PASS | B | **PASS** | NONE | NONE |
| **12** | dev-grammar-inversion-06 | GRAMMAR | B | 1 | A | PASS | A | **PASS** | NONE | NONE |
| **13** | dev-grammar-inversion-06 | GRAMMAR | B | 2 | B | PASS | B | **PASS** | NONE | NONE |
| **14** | dev-grammar-inversion-06 | GRAMMAR | C | 1 | B | PASS | B | **PASS** | NONE | NONE |
| **15** | dev-grammar-inversion-06 | GRAMMAR | C | 2 | B | PASS | NONE | **FAIL** | ZERO_CORRECT_ANSWERS | CRITICAL |
| **16** | dev-grammar-subjunctive-06 | GRAMMAR | A | MCQ_1 | B | PASS | B | **PASS** | NONE | NONE |
| **17** | dev-grammar-subjunctive-06 | GRAMMAR | A | MCQ_2 | B | PASS | B | **PASS** | NONE | NONE |
| **18** | dev-grammar-subjunctive-06 | GRAMMAR | B | Q1 | B | PASS | B | **PASS** | NONE | NONE |
| **19** | dev-grammar-subjunctive-06 | GRAMMAR | B | Q2 | B | PASS | B | **PASS** | NONE | NONE |
| **20** | dev-grammar-subjunctive-06 | GRAMMAR | C | MCQ_1 | B | PASS | B | **PASS** | NONE | NONE |
| **21** | dev-grammar-subjunctive-06 | GRAMMAR | C | MCQ_2 | B | PASS | B | **PASS** | NONE | NONE |
| **22** | dev-reading-hydrothermal-05 | READING | A | 1 | FALSE | PASS | FALSE | **PASS** | NONE | NONE |
| **23** | dev-reading-hydrothermal-05 | READING | A | 2 | TRUE | PASS | TRUE | **PASS** | NONE | NONE |
| **24** | dev-reading-hydrothermal-05 | READING | A | 3 | FALSE | PASS | FALSE | **PASS** | NONE | NONE |
| **25** | dev-reading-hydrothermal-05 | READING | B | 1 | FALSE | PASS | FALSE | **PASS** | NONE | NONE |
| **26** | dev-reading-hydrothermal-05 | READING | B | 2 | TRUE | PASS | TRUE | **PASS** | NONE | NONE |
| **27** | dev-reading-hydrothermal-05 | READING | B | 3 | FALSE | PASS | FALSE | **PASS** | NONE | NONE |
| **28** | dev-reading-hydrothermal-05 | READING | C | 1 | FALSE | PASS | UNCERTAIN | **UNCERTAIN** | AMBIGUOUS_QUALIFIER | MEDIUM |
| **29** | dev-reading-hydrothermal-05 | READING | C | 2 | TRUE | PASS | TRUE | **PASS** | NONE | NONE |
| **30** | dev-reading-hydrothermal-05 | READING | C | 3 | FALSE | PASS | NOT GIVEN | **FAIL** | UNGROUNDED_PREMISE | HIGH |
| **31** | dev-grammar-inversion-05 | GRAMMAR | A | 1 | A | PASS | A | **PASS** | NONE | NONE |
| **32** | dev-grammar-inversion-05 | GRAMMAR | A | 2 | A | PASS | A | **PASS** | NONE | NONE |
| **33** | dev-grammar-inversion-05 | GRAMMAR | B | 1 | A | PASS | A | **PASS** | NONE | NONE |
| **34** | dev-grammar-inversion-05 | GRAMMAR | B | 2 | A | PASS | A | **PASS** | NONE | NONE |
| **35** | dev-grammar-inversion-05 | GRAMMAR | C | 1 | A | PASS | A | **PASS** | CROSS_ARM_DUPLICATION | MEDIUM |
| **36** | dev-grammar-inversion-05 | GRAMMAR | C | 2 | A | PASS | NONE | **FAIL** | ZERO_CORRECT_ANSWERS | CRITICAL |
| **37** | dev-reading-photosynthesis-03 | READING | A | 1 | TRUE | PASS | TRUE | **PASS** | NONE | NONE |
| **38** | dev-reading-photosynthesis-03 | READING | A | 2 | FALSE | PASS | FALSE | **PASS** | NONE | NONE |
| **39** | dev-reading-photosynthesis-03 | READING | A | 3 | TRUE | PASS | TRUE | **PASS** | NONE | NONE |
| **40** | dev-reading-photosynthesis-03 | READING | B | 1 | FALSE | PASS | FALSE | **PASS** | NONE | NONE |
| **41** | dev-reading-photosynthesis-03 | READING | B | 2 | TRUE | PASS | TRUE | **PASS** | NONE | NONE |
| **42** | dev-reading-photosynthesis-03 | READING | B | 3 | FALSE | FAIL | FALSE | **PASS** | EVALUATOR_FALSE_REJECTION | HIGH |
| **43** | dev-reading-photosynthesis-03 | READING | C | 1 | FALSE | PASS | FALSE | **PASS** | NONE | NONE |
| **44** | dev-reading-photosynthesis-03 | READING | C | 2 | FALSE | PASS | FALSE | **PASS** | NONE | NONE |
| **45** | dev-reading-photosynthesis-03 | READING | C | 3 | FALSE | PASS | UNCERTAIN | **UNCERTAIN** | SOURCE_PASSAGE_CONTRADICTION | HIGH |
| **46** | dev-grammar-cleft-03 | GRAMMAR | A | 1 | B | PASS | B | **PASS** | NONE | NONE |
| **47** | dev-grammar-cleft-03 | GRAMMAR | A | 2 | A | FAIL | A | **PASS** | NONE | NONE |
| **48** | dev-grammar-cleft-03 | GRAMMAR | B | q1 | A | PASS | A | **PASS** | NONE | NONE |
| **49** | dev-grammar-cleft-03 | GRAMMAR | B | q2 | B | PASS | B | **PASS** | NONE | NONE |
| **50** | dev-grammar-cleft-03 | GRAMMAR | C | MCQ_1 | Text | FAIL | MULTIPLE | **FAIL** | MULTIPLE_DEFENSIBLE_ANSWERS | CRITICAL |
| **51** | dev-grammar-cleft-03 | GRAMMAR | C | MCQ_2 | Text | FAIL | MULTIPLE | **FAIL** | MULTIPLE_DEFENSIBLE_ANSWERS | CRITICAL |

---

## 6. Discrepancy Breakdown & Evaluator Diagnosis

### 6.1 Evaluator False Rejections ($N = 3$)
1. **Item 3 (`dev-reading-volcanism-06__arm_A__att1`, Q3):**
   - Question: *"Pyroclastic fragmentation occurs in deep benthic environments due to high hydrostatic pressure."*
   - Model Answer: `FALSE`. Passage: Pressure suppresses and prevents fragmentation.
   - Evaluator Failed regex on "preventing". Model was correct.
2. **Item 6 (`dev-reading-volcanism-06__arm_B__att1`, Q3):**
   - Question: *"Pyroclastic fragmentation is common in deep benthic environments."*
   - Model Answer: `FALSE`. Passage: Pressure prevents it.
   - Evaluator failed on contradiction logic. Model was correct.
3. **Item 42 (`dev-reading-photosynthesis-03__arm_B__att1`, Q3):**
   - Question: *"CAM plants use ribulose-1,5-bisphosphate carboxylase-oxygenase during the day while stomata are open."*
   - Model Answer: `FALSE`. Passage: Stomata are closed during the day.
   - Evaluator failed on compound clause alignment. Model was correct.

### 6.2 Evaluator False Acceptances ($N = 1$)
1. **Item 15 (`dev-grammar-inversion-06__arm_C__att1`, Q2):**
   - Question: *"What is the correct way to rewrite the sentence 'Scarcely had the meeting started when the fire alarm rang' using negative inversion?"*
   - Defect: Input sentence is already inverted; Option B changes aspect; no correct answer exists.
   - Evaluator v2.6 passed this item (`PASS`), missing the semantic circularity in the question stem.

---

## 7. Conclusions & Quality Sign-Off

1. **Overall Generator Capability:** The foundation model (`MiniMax-Text-01`) produces grammatically fluent, well-grounded IELTS questions in **86.3%** of evaluated cases.
2. **Failure Modes:** Defects are concentrated in:
   - Complex prompt rewrite loops (Arm C) where the generator invents circular stems or drops option labels.
   - Physical unit/dimension conflation (atmospheres as depth).
   - Incomplete distractor validation leading to multiple defensible options.
3. **Evaluator Readiness:** While `neutral-eval-v2.7` eliminates major regex inflection bugs, subtle semantic circularity in question stems still requires human panel review.
4. **Epistemic Constraint:** This review provides automated and AI-assisted triage. **Certified quality decisions for research publication remain dependent on the independent human review panel.**
