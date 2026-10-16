# Human Expert Review Protocol & Scoring Rubric (RG10 Phase E)

**Status:** APPROVED RESEARCH PROTOCOL  
**Date:** 2026-10-16  
**Governing Standard:** `generation_baseline/research/RUBRIC.md` & `DATA_GOVERNANCE.md`  

---

## 1. Ethical Governance and Human Ground Truth Principle

In compliance with repository invariants and empirical research standards:
- **No AI Model May Certify Human Ground Truth:** Predictions from secondary LLMs, blind solvers, or heuristic evaluators cannot substitute for human expert judgment. All synthetic or automated verdicts are flagged with `verified_human_truth = False`.
- **Human Panel Requirement:** Confirmatory research readiness requires blind annotation by qualified human experts using an immutable double-blind protocol.

---

## 2. Reviewer Qualification Criteria

Annotators must satisfy all of the following professional requirements prior to panel onboarding:
1. **Certification:** Official IELTS Academic Band 8.5+ or CEFR Level C2 certification in English.
2. **Professional Experience:** Minimum 3 years of professional experience in English for Academic Purposes (EAP) assessment design or official IELTS test preparation.
3. **Training & Calibration:** Must achieve $\ge 90\%$ agreement ($\kappa \ge 0.85$) on a standardized 10-item calibration test prior to live batch assignment.

---

## 3. Anonymization and Blinding Protocol

To eliminate bias across configurations (Arms A, B, and C):
1. **Configuration Anonymization:** Question items from Arm A, Arm B, and Arm C are pooled and randomly interleaved under opaque cryptographic task IDs (`task_hrev_[a-f0-9]{12}`).
2. **Metadata Stripping:** All pipeline metadata (stage tags, model identifiers, revision counts, prompt versions, in-loop reviewer comments, and automated evaluator scores) are stripped.
3. **Proposed Answer Blindness:** Reviewers receive questions without any suggested answer key, evaluating question stem clarity and distractor defensibility independently.

---

## 4. 4-Dimension Human Review Rubric (5-Point Scale)

Reviewers evaluate each item across 4 primary dimensions on a 1–5 scale ($1 = \text{Unacceptable}, 5 = \text{Exemplary}$):

### Dimension 1: Source Grounding (Reading) / Rule Conformance (Grammar)
- **5 (Exemplary):** Perfect factual entailment (TRUE) directly supported by explicit passage evidence, unequivocal contradiction (FALSE), or completely unmentioned topic relation (NOT GIVEN). For Grammar: flawless application of target rule.
- **3 (Acceptable):** Entailed or contradicted, but requires minor contextual inference.
- **1 (Defective):** Direct factual hallucination, ungrounded speculation falsely marked TRUE, or violation of target grammar rule.

### Dimension 2: Answer Key Uniqueness & Defensibility
- **5 (Exemplary):** Exactly ONE option is grammatically and factually defensible; all distractors are unambiguously incorrect.
- **3 (Borderline):** Single correct key, but one distractor has stylistic awkwardness rather than clear factual/grammatical error.
- **1 (Defective):** Multiple valid keys (ambiguous question) or proposed key is incorrect/unsupported.

### Dimension 3: Distractor Plausibility & Quality
- **5 (Exemplary):** Distractors are plausible, natural academic English sentences with unambiguous syntactic defects (e.g. word order, missing auxiliary, tense discord).
- **3 (Acceptable):** Distractors are clearly incorrect but somewhat artificial.
- **1 (Defective):** Distractors are nonsensical fragments, ungrammatical gibberish, or completely irrelevant.

### Dimension 4: Linguistic Naturalness & Academic Register
- **5 (Exemplary):** Flawless formal academic register appropriate for IELTS Academic Reading / Grammar.
- **3 (Acceptable):** Understandable, minor register awkwardness.
- **1 (Defective):** Mechanical artifacts, unnatural repetitive phrasing, or colloquialisms.

---

## 5. Dual-Blind Adjudication & Disagreement Resolution

1. **Independent Dual Scoring:** Each item is independently scored by two qualified reviewers (Annotator 1 and Annotator 2).
2. **Inter-Annotator Agreement:** Measured via Cohen's quadratic-weighted Kappa ($\kappa$). Target threshold: $\kappa \ge 0.80$.
3. **Adjudication Trigger:** Where annotators disagree on the binary acceptability decision (Pass vs Fail) or exhibit a score delta $\ge 2$ on any dimension, the item is automatically routed to the Senior Chief Adjudicator.
4. **Binding Resolution:** The Senior Adjudicator reviews the blinded item, passage, and both reviewer rationales, producing an immutable binding verdict and explanatory finding.
5. **Audit Trail:** All individual annotator scores, timestamps, confidence ratings, and adjudication logs are permanently stored in `generation_baseline/adjudication/`.
