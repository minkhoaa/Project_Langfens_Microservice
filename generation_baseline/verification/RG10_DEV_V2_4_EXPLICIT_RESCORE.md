# RG10 DEV Hardening — Explicit NeutralEvaluatorV2_4 Rescore

**Source Commit SHA:** `7b33b827aec8e1de3525ce6d09dff0830beb37e0`  
**Date:** 2026-10-16T16:15:00Z  
**Status:** PUBLISHED VERSIONED RESCORE (Preserves v2.3 Historical Baseline)  
**Machine-Readable Artifact:** `generation_baseline/verification/RG10_DEV_V2_4_EXPLICIT_RESCORE.json`  
**Evaluator Comparison:** `neutral-eval-v2.3` (baseline) vs `neutral-eval-v2.4` (rescore)  

---

## 1. Executive Summary & Evaluator Version Separation

In strict compliance with Research Integrity Requirement 5:
- **Historical v2.3 Integrity:** The historical RG10 DEV evaluation conducted under `NeutralEvaluatorV2_3` remains immutable at **4 PASS / 11 FAIL / 0 UNCERTAIN**. We never substitute v2.4 when claiming v2.3 equivalence.
- **Explicit v2.4 Rescore:** When scored under `NeutralEvaluatorV2_4` (incorporating refined clause-boundary parsing on contrastive markers like `"unlike"`), the passing count improves from **4/15 (26.67%) to 5/15 (33.33%)**.
- **Net Delta (+1 PASS):** Reading Arm A Q3 is recovered from a false rejection (FAIL -> PASS).

---

## 2. Behavioral Mechanism Investigation: Contrastive Clauses

### 2.1 Reading Arm A Q3 Recovery (FAIL -> PASS)
- **Prompt:** *"The four-carbon dicarboxylic acid produced in CAM plants is stored in central vacuoles until daybreak."*
- **Passage Context:**
  > *"Unlike standard C3 plants that open stomata during daylight hours, obligate CAM species nocturnally assimilate atmospheric carbon dioxide via phosphoenolpyruvate carboxylase. The resulting four-carbon dicarboxylic acid, predominantly malate, is sequestered inside large central vacuoles until daybreak."*
- **v2.3 Defect:** In v2.3, `detect_contradiction_in_text` split on `"unlike"` without bounding the clause at the comma delimiter. The entire remainder of the sentence (`obligate CAM species nocturnally assimilate...`) was treated as the excluded clause. Because the prompt shares substantive tokens with this text, v2.3 marked it as an entailment contradiction.
- **v2.4 Refinement:** `enable_refined_contrastive_clause=True` isolates the excluded clause to `", "` (i.e. *"standard C3 plants that open stomata during daylight hours"*). The subsequent sentence containing central vacuole storage is no longer excluded, and Q3 is correctly judged **PASS**.

### 2.2 Reading Arm A Q1 Persistence (FAIL in v2.3 & v2.4)
- **Prompt:** *"CAM plants assimilate atmospheric carbon dioxide during the night."*
- **Why it persists as FAIL:** Even with clause bounding to the comma, the excluded clause is *"standard C3 plants that open stomata during daylight hours"*. The tokens `plant` and `during` overlap between Q1 and the excluded clause. Because the threshold is $\ge 2$ shared stems, the heuristic still flags an exclusion conflict.

---

## 3. Question-by-Question Comparison Matrix (n = 15)

| Domain | Arm | Q# | Proposed Answer | v2.3 Verdict | v2.4 Verdict | Delta Status | v2.4 Rationale / Finding |
|---|---|---|---|---|---|---|---|
| READING | A | 1 | `TRUE` | **FAIL** | **FAIL** | UNCHANGED | Entailment contradiction: passage contradicts TRUE statement; Grounding score 1.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. |
| READING | A | 2 | `FALSE` | **PASS** | **PASS** | UNCHANGED | Passes rubric |
| READING | A | 3 | `TRUE` | **FAIL** | **PASS** | RECOVERED (+) | Passes rubric |
| READING | B | 1 | `None` | **FAIL** | **FAIL** | UNCHANGED | UNSCORABLE_MISSING_ANSWER: Question provides no proposed answer key |
| READING | B | 2 | `None` | **FAIL** | **FAIL** | UNCHANGED | UNSCORABLE_MISSING_ANSWER: Question provides no proposed answer key |
| READING | B | 3 | `None` | **FAIL** | **FAIL** | UNCHANGED | UNSCORABLE_MISSING_ANSWER: Question provides no proposed answer key |
| READING | C | 1 | `None` | **FAIL** | **FAIL** | UNCHANGED | UNSCORABLE_MISSING_ANSWER: Question provides no proposed answer key |
| READING | C | 2 | `None` | **FAIL** | **FAIL** | UNCHANGED | UNSCORABLE_MISSING_ANSWER: Question provides no proposed answer key |
| READING | C | 3 | `None` | **FAIL** | **FAIL** | UNCHANGED | UNSCORABLE_MISSING_ANSWER: Question provides no proposed answer key |
| GRAMMAR | A | 1 | `B` | **PASS** | **PASS** | UNCHANGED | Passes rubric |
| GRAMMAR | A | 2 | `A` | **FAIL** | **FAIL** | UNCHANGED | Ambiguous MCQ: multiple options [1, 4] exhibit grammatically valid it-cleft syntax; Grounding score 2.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. |
| GRAMMAR | B | q1 | `A` | **PASS** | **PASS** | UNCHANGED | Passes rubric |
| GRAMMAR | B | q2 | `B` | **PASS** | **PASS** | UNCHANGED | Passes rubric |
| GRAMMAR | C | GRAMMAR_MCQ_1 | `It was the new findings that surprised the scientific community.` | **FAIL** | **FAIL** | UNCHANGED | Ambiguous MCQ: multiple options [1, 2, 3] exhibit grammatically valid it-cleft syntax; Grounding score 2.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. |
| GRAMMAR | C | GRAMMAR_MCQ_2 | `It was the research methodology that the team developed.` | **FAIL** | **FAIL** | UNCHANGED | Ambiguous MCQ: multiple options [1, 2, 3, 4] exhibit grammatically valid it-cleft syntax; Grounding score 2.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. |

---

## 4. Invariant Accounting

1. **Zero Answer Borrowing:** Reading B (Q1-Q3) and Reading C (Q1-Q3) remain **FAIL** (`UNSCORABLE_MISSING_ANSWER`) under both v2.3 and v2.4.
2. **Distractor Quality Invariant:** 3 Grammar MCQs remain **FAIL** under both evaluators due to multiple grammatically valid it-cleft options.
3. **Reproducibility Fencing:** v2.3 and v2.4 results are stored in independent files under explicit version identities.
