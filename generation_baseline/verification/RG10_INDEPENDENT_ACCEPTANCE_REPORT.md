# RG10 Evaluator Independent Acceptance & Research Freeze Assessment Report

**Execution Date:** 2026-10-16T13:45:00Z  
**Branch:** `autonomous-generation`  
**Evaluator Versions:** `neutral-eval-v2.6` (Historical Baseline), `neutral-eval-v2.7` (Remediated Release)  
**Rubric Versions:** `rubric-qgeval-v2.6`, `rubric-qgeval-v2.7`  
**Governing Standard:** `generation_baseline/research/RQ2_PROTOCOL.md` & `DATA_GOVERNANCE.md`  
**Local Runtime Environment:** Python 3.10.12, .NET 10.0 (Production container target: Python 3.12)  

---

## 1. Executive Summary & Readiness Verdicts

This report provides the final software-quality verification and research freeze assessment for **Evaluator v2.7** under RG10, strictly preserving all historical evaluation records (v2.0–v2.6) and maintaining absolute separation between developmental calibration and post-freeze confirmatory testing.

### Three-Pillar Readiness Separation

| Pillar | Gate Verdict | Evidence & Rationale |
|---|---|---|
| **SOFTWARE_READY** | **PASS** | Evaluator v2.7 software corrections are fully verified offline. All 4 diagnosed DEV defect classes are resolved via linguistically justified mechanisms. Comprehensive offline regression suites pass 100%: 374 full research tests, 205 core generation-service caps/loop tests, 79 evaluator tests, and 73 .NET attempt-service grader tests pass deterministically. Evaluator version isolation is strictly verified with zero regression across historical evaluators (v2.0–v2.6). |
| **QUALITY_READY** | **QUALIFIED_PASS (IN_SAMPLE_CALIBRATION_ONLY; HOLDOUT_PENDING)** | Evaluator v2.7 achieves 100.0% concordance (25/25, FRR = 0.0%, FAR = 0.0%) on the internal diagnostic DEV acceptance suite. However, per repository rules and empirical research methodology: **in-sample calibration does not constitute independent confirmatory proof**. Quality acceptance on post-freeze data remains pending until the independent human holdout is curated and evaluated. |
| **RESEARCH_READY** | **HOLD** | **Blocked on external prerequisites:** Live provider quota returned `HTTP 429: Token Plan usage limit reached (2056)` (truthfully logged as `BLOCKED_EXTERNAL_QUOTA`). Confirmatory holdout ($N=30$) remains in `SPECIFICATION_PENDING_INDEPENDENT_CURATION` with all cryptographic seals strictly `null`. Human review packets remain unpopulated (`AWAITING_HUMAN_PANEL`) without synthetic score fabrication. |
| **OVERALL GATE VERDICT** | **`HOLD`** | **Do NOT start RG11 or the final A/B/C campaign.** Evaluator software is remediated and versioned; hold until external quota is restored, confirmatory holdout is independently curated, and human expert panel data is gathered. |

---

## 2. Independent Audit: Historical (6) and Fresh (12) Grammar MCQs

*Epistemic Disclosure:* Ground truth labels in this section represent an **internal analytical linguistic audit** (non-human gold), strictly separated from certified human ground truth. All automated evaluator scores are classified as **evaluator predictions / model rescores**, not independent gold.

### 2.1 Historical Grammar Pilot (RG10_DEV_UNSEEN_PILOT_V4, n = 6 slots)

| Item ID | Question Stem / Construction | Proposed Answer | Analytical Linguistic Status (Non-Human Gold) | Evaluator v2.5 Prediction | Evaluator v2.6 Prediction | Evaluator v2.7 Prediction | Discrepancy Cause & Forensic Resolution |
|---|---|---|---|---|---|---|---|
| `dev-inv-05__arm_A__att1 (Q1)` | *Not only did she win the race...* | `A` | **VALID** | `FAIL` | **`PASS`** | **`PASS`** | Evaluator False Rejection: `Not only` trigger was missing from v2.5 trigger regex. |
| `dev-inv-05__arm_A__att1 (Q2)` | *Under no circumstances should we open the door...* | `A` | **VALID** | `FAIL` | **`PASS`** | **`PASS`** | Evaluator False Rejection: Distractor C (*"do we should"*) was falsely matched as valid inversion. |
| `dev-inv-05__arm_B__att1 (Q1)` | *Not only did she win the award...* | `A` | **VALID** | `FAIL` | **`PASS`** | **`PASS`** | Evaluator False Rejection: Missing trigger / shallow auxiliary match. |
| `dev-inv-05__arm_B__att1 (Q2)` | *Under no circumstances should we leave the building...* | `A` | **VALID** | `FAIL` | **`PASS`** | **`PASS`** | Evaluator False Rejection: Distractor C (*"did we should"*) falsely matched as valid inversion. |
| `dev-inv-05__arm_C__att1 (Q1)` | *Not only did she win the race...* | `A` | **VALID** | `FAIL` | **`PASS`** | **`PASS`** | Evaluator False Rejection: Cross-arm convergence identical to Q1. |
| `dev-inv-05__arm_C__att1 (Q2)` | *Which sentence correctly uses 'do' to form inversion...* | `C` | **GENERATOR DEFECT** | `PASS` | **`FAIL`** | **`FAIL`** | Evaluator False Acceptance in v2.5: Question stem requested `'do'` inversion, but option C provided modal auxiliary `'should'`. v2.6/v2.7 correctly catch stem-answer constraint conflict. |

*Historical Audit Summary:* In v2.5, apparent pass rate was 1/6 (16.7%). Analytical linguistic audit reveals **5/6 (83.3%) valid MCQs** and **1/6 generator defect**. Evaluators v2.6 and v2.7 achieve **6/6 concordance** with the analytical linguistic classification.

### 2.2 Fresh Grammar Pilot (RG10_DEV_GRAMMAR_FIX_V5, n = 12 slots)

*All 12 items were evaluated via Evaluator v2.7 rescore (model predictions):*

- **Negative Inversion Family (`fam-syntax-inversion-dev-06`, 6 slots):**
  - Q1 (Arm A): *Not only did the experiment fail...* (Key `A`) -> **VALID** -> v2.7 prediction: **`PASS`**
  - Q2 (Arm A): *Under no circumstances should we ignore...* (Key `B`) -> **VALID** -> v2.7 prediction: **`PASS`**
  - Q3 (Arm B): *Never have I seen such a beautiful sunset...* (Key `A`) -> **VALID** -> v2.7 prediction: **`PASS`**
  - Q4 (Arm B): *Under no circumstances should the equipment be left...* (Key `B`) -> **VALID** -> v2.7 prediction: **`PASS`**
  - Q5 (Arm C): *Under no circumstances should we compromise...* (Key `B`) -> **VALID** -> v2.7 prediction: **`PASS`**
  - Q6 (Arm C): *Scarcely did the meeting start when the fire alarm rang...* (Key `B`) -> **VALID** -> v2.7 prediction: **`PASS`**
- **Mandative Subjunctive Family (`fam-syntax-subjunctive-dev-06`, 6 slots):**
  - Q7 (Arm A): *The contract stipulates that the supplier provide...* (Key `B`) -> **VALID** -> v2.7 prediction: **`PASS`**
  - Q8 (Arm A): *It is vital that she attend the conference...* (Key `B`) -> **VALID** -> v2.7 prediction: **`PASS`**
  - Q9 (Arm B): *The policy requires that each student have...* (Key `B`) -> **VALID** -> v2.7 prediction: **`PASS`**
  - Q10 (Arm B): *Which sentence demonstrates incorrect use...* (Key `B`, *submits*) -> **VALID** -> v2.7 prediction: **`PASS`**
  - Q11 (Arm C): *The policy requires that each student attend...* (Key `B`) -> **VALID** -> v2.7 prediction: **`PASS`**
  - Q12 (Arm C): *It is important that she be on time...* (Key `B`) -> **VALID** -> v2.7 prediction: **`PASS`**

*Fresh Pilot Audit Summary:* Generator prompt improvements produced 12/12 analytically defensible MCQs with 100.0% content-aware carrier novelty (zero scenario copying). Evaluator v2.7 predicted all 12 slots as PASS.

---

## 3. Internal DEV Acceptance Suite: v2.6 Baseline vs. v2.7 Remediation

*Epistemic Guardrail:* Because these 25 acceptance cases were used to diagnose evaluator implementation limits during development, this suite constitutes **exploratory developmental evidence, NOT an independent confirmatory holdout**. Only a post-freeze, uninspected dataset can provide confirmatory research claims.

### 3.1 Confusion Matrices with Explicit Denominators

- **Total Cases ($N$):** 25
- **Analytical Gold VALID Items ($N_{\text{valid}}$):** 15 (Explicit denominator for False Rejection Rate)
- **Analytical Gold INVALID Items ($N_{\text{invalid}}$):** 10 (Explicit denominator for False Acceptance Rate)

```
       Evaluator v2.6 (Baseline)                          Evaluator v2.7 (Remediated)
         ┌──────────────┬──────────────┐                    ┌──────────────┬──────────────┐
         │     PASS     │     FAIL     │                    │     PASS     │     FAIL     │
┌────────┼──────────────┼──────────────┤           ┌────────┼──────────────┼──────────────┤
│ Gold   │   TP = 13    │   FN = 2     │ N_val=15  │ Gold   │   TP = 15    │   FN = 0     │ N_val=15
│ VALID  │              │ (False Rej)  │           │ VALID  │              │ (False Rej)  │
├────────┼──────────────┼──────────────┤           ├────────┼──────────────┼──────────────┤
│ Gold   │   FP = 2     │   TN = 8     │ N_inv=10  │ Gold   │   FP = 0     │   TN = 10    │ N_inv=10
│ INVALID│ (False Acc)  │              │           │ INVALID│ (False Acc)  │              │
└────────┴──────────────┴──────────────┘           └────────┴──────────────┴──────────────┘
```

### 3.2 Performance Comparison Across Evaluator Versions

| Metric | Formula | v2.6 Observed | v2.6 Percentage | v2.7 Observed | v2.7 Percentage | Protocol Characterization |
|---|---|---|---|---|---|---|
| **Coverage** | $\frac{\text{Decisive (PASS + FAIL)}}{\text{Total}}$ | $\frac{25}{25}$ | 100.0% | $\frac{25}{25}$ | **100.0%** | Full decisive coverage across diagnostic items |
| **Abstention Rate** | $\frac{\text{UNCERTAIN}}{\text{Total}}$ | $\frac{0}{25}$ | 0.0% | $\frac{0}{25}$ | **0.0%** | 0 unhandled stalls on conclusive diagnostic items |
| **False Rejection Rate (FRR)** | $\frac{\text{FN}}{N_{\text{valid}}}$ | $\frac{2}{15}$ | 13.3% | $\frac{0}{15}$ | **0.0%** | Defect boundary fully resolved (INV-DEV-02, CND-DEV-01) |
| **False Acceptance Rate (FAR)** | $\frac{\text{FP}}{N_{\text{invalid}}}$ | $\frac{2}{10}$ | 20.0% | $\frac{0}{10}$ | **0.0%** | Defect boundary fully resolved (SUB-DEV-04, SUB-DEV-05) |
| **Diagnostic Concordance** | $\frac{\text{TP} + \text{TN}}{\text{Total}}$ | $\frac{21}{25}$ | 84.0% | $\frac{25}{25}$ | **100.0%** | Complete concordance on internal DEV diagnostic suite |

### 3.3 Root Cause Analysis & Remediation of the Four DEV Defects

1. **False Rejection 1 (`INV-DEV-02`, Inversion):**
   - *Sentence:* *"Under no circumstances should we bypass the interlock."* (Analytical Gold: VALID)
   - *v2.6 Verdict:* `FAIL` (*"Modal auxiliary 'should' cannot be followed by 3rd-person inflected verb 'bypass'"*)
   - *Defect Mechanism:* The heuristic verb-inflection filter flagged words ending in `-s` as 3rd-person inflections without exempting base verbs ending in `-ss` (e.g. *bypass*, *cross*, *discuss*, *assess*, *dismiss*). In English morphology, base verbs ending in sibilants take `-es` for 3rd-person singular (*bypasses*); therefore, stems ending in `-ss` are inherently base forms.
   - *v2.7 Remediation:* Morphological rule updated to `pred_verb.endswith("s") and not pred_verb.endswith("ss")` and `not pred_verb.endswith("eed")`. Valid base verbs (*bypass*, *assess*, *dismiss*, *exceed*) correctly recognized as bare infinitives. v2.7 verdict: **`PASS`**.
2. **False Rejection 2 (`CND-DEV-01`, Conditionals):**
   - *Question:* Inverted third conditional (*"Had the crew checked..."*). (Analytical Gold: VALID)
   - *v2.6 Verdict:* `FAIL` (*"Ambiguous conditional MCQ: multiple options [1, 3] are defensible"*)
   - *Defect Mechanism:* The conditional validator accepted Option C (*"If the crew had checked..."*) as a valid option, ignoring the question stem constraint specifically requesting an *inverted* conditional.
   - *v2.7 Remediation:* Question stem constraint parsing implemented: when the prompt requests an inverted conditional (`\binvert(?:ed|ion)?\b`), options introduced by the complementizer *if* are classified as non-inverted distractors. v2.7 verdict: **`PASS`**.
3. **False Acceptance 1 (`SUB-DEV-04`, Subjunctive):**
   - *Question:* Ambiguous subjunctive MCQ with two base-form options (Option B *pay*, Option C *appear*). (Analytical Gold: INVALID)
   - *v2.6 Verdict:* `PASS` (False Acceptance)
   - *Defect Mechanism:* Fragile common-prefix word splitting failed when carrier clauses diverged in subject noun phrasing, extracting nouns as verbs.
   - *v2.7 Remediation:* Robust subordinate clause parsing extracts verbs across varying subject noun phrase structures (determiner + adjective + noun + verb). Both Option B (*pay*) and Option C (*appear*) are recognized as base subjunctive forms, correctly detecting multi-option ambiguity. v2.7 verdict: **`FAIL`**.
4. **False Acceptance 2 (`SUB-DEV-05`, Subjunctive):**
   - *Question:* Defective subjunctive MCQ with zero base forms. (Analytical Gold: INVALID)
   - *v2.6 Verdict:* `PASS` (False Acceptance)
   - *Defect Mechanism:* Prompt used the adjective *mandative* rather than trigger verbs (*mandate*, *insist*), causing `is_mandative` to evaluate to `False`, bypassing distractor checks.
   - *v2.7 Remediation:* Mandative triggers expanded to include grammatical terms (*mandative*, *subjunctive*, *formulaic*) and carrier verbs (*stipulates that*, *demands that*). Zero base forms detected in all options. v2.7 verdict: **`FAIL`**.

### 3.4 Inconclusive Linguistic Judgment Handling (UNCERTAIN Verdicts)

In Evaluator v2.6, unparseable or ambiguous grammar structures were forced into `FAIL` or `PASS`.  
In Evaluator v2.7, genuinely inconclusive grammar cases yield `EvaluationVerdict.UNCERTAIN`:
- Inconclusive subordinate clause parsing: emits `EvaluationVerdict.UNCERTAIN` with `abstention_reason = "INCONCLUSIVE_LINGUISTIC_JUDGMENT: Inconclusive subjunctive MCQ: option(s) [...] could not be conclusively parsed into mandative subjunctive subordinate clause"`.
- Malformed conditional protasis/apodosis: emits `EvaluationVerdict.UNCERTAIN`.
- Ambiguous inversion participle forms: emits `EvaluationVerdict.UNCERTAIN`.
- This ensures the evaluator abstains when evidence is genuinely inconclusive rather than issuing an unsupported verdict.

---

## 4. Reading Quality Reconciliation (RG10_DEV_GRAMMAR_FIX_V5)

Forensic analysis of the three failing Reading slots in `RG10_DEV_GRAMMAR_FIX_V5`:

### Item 1: Arm A, Question 3
- **Stem:** *"Pyroclastic fragmentation occurs in deep benthic environments due to high hydrostatic pressure."*
- **Proposed Answer:** `FALSE`
- **Original Evaluator Verdict:** `FAIL` (*"FALSE contradiction: passage affirms proposition without contradiction"*)
- **Passage Text:** *"...abyssal hydrostatic pressure exceeding two hundred atmospheres suppresses volatile exsolution, thereby preventing pyroclastic fragmentation in deep benthic environments."*
- **Forensic Finding:** **Evaluator False Rejection (`EVALUATOR_DEFECT`)**. The passage explicitly states hydrostatic pressure *prevents* fragmentation; the statement asserts it *occurs due to* pressure. The generator's proposed answer (`FALSE`) is factually and contextually correct. The evaluator's shallow contradiction regex failed to recognize *"preventing"* as a negative polarity marker.
- **Corrected Derived Interpretation:** `VALID_FALSE_QUESTION` (Grounding: 5.0, Corrected Derived Verdict: `PASS`).

### Item 2: Arm B, Question 3
- **Stem:** *"Pyroclastic fragmentation is common in deep benthic environments."*
- **Proposed Answer:** `FALSE`
- **Original Evaluator Verdict:** `FAIL` (*"FALSE contradiction: passage affirms proposition without contradiction"*)
- **Passage Text:** *"...thereby preventing pyroclastic fragmentation in deep benthic environments."*
- **Forensic Finding:** **Evaluator False Rejection (`EVALUATOR_DEFECT`)**. A phenomenon that is *prevented* cannot be *common*. Proposing `FALSE` is linguistically and factually correct.
- **Corrected Derived Interpretation:** `VALID_FALSE_QUESTION` (Grounding: 5.0, Corrected Derived Verdict: `PASS`).

### Item 3: Arm C, Question 2
- **Stem:** *"TRUE, FALSE or NOT GIVEN: Pillow lava forms when basaltic magma erupts into seawater at depths exceeding 200 atmospheres."*
- **Proposed Answer:** `TRUE`
- **Original Evaluator Verdict:** `FAIL` (*"Entailment contradiction: passage contradicts TRUE statement"*)
- **Passage Text:** Sentence 1 mentions *pillow lava forms at abyssal depths*. Sentence 5 mentions *hydrostatic pressure exceeding 200 atmospheres suppresses volatile exsolution*.
- **Forensic Finding:** **Generator Defect & Insufficient Passage Support (`GENERATOR_DEFECT` / `INSUFFICIENT_PASSAGE_SUPPORT`)**.
  1. *Category Confusion:* Conflates physical pressure (*atmospheres*) with ocean depth (*meters*).
  2. *Passage Disconnect:* The passage does not state pillow lava forms *at pressures exceeding 200 atmospheres*; it states pillow lava forms *at abyssal depths*, and *hydrostatic pressure exceeding 200 atmospheres suppresses volatile exsolution*.
  3. The proposed answer `TRUE` is factually and inferentially defective.
- **Corrected Derived Interpretation:** `INVALID_QUESTION` (Corrected Derived Verdict: `FAIL`).

---

## 5. Holdout Governance & Human Review Readiness

### 5.1 Confirmatory Holdout Manifest Status
- **Manifest Path:** `generation_baseline/research/CONFIRMATORY_HOLDOUT_MANIFEST.json`
- **Specification Path:** `generation_baseline/research/CONFIRMATORY_HOLDOUT_SPECIFICATION.md`
- **Checklist Path:** `generation_baseline/research/INDEPENDENT_CURATOR_CHECKLIST_AND_SEALING_PROCEDURE.md`
- **Current Status:** **`SPECIFICATION_PENDING_INDEPENDENT_CURATION`**
- **Holdout Type:** `JUDGE_HOLDOUT` ($N = 30$ questions: 18 Reading, 12 Grammar)
- **Cryptographic Seals:** All seals (`reading_corpus_sha256`, `grammar_rule_packs_sha256`, `manifest_integrity_sha256`) remain strictly **`null`**.
- **Security Attestations:** Unverifiable claims remain strictly **`null`** or **`PENDING_INDEPENDENT_CURATOR_ATTESTATION`**.
- **Synthetic Data Prohibition:** Explicitly stated in manifest and specification: **Zero synthetic holdout items permitted**.
- **Corpus Separation:** The 30-item judge holdout is strictly separated from RQ2's 25–40 paired tasks per domain (150–240 arm assignments).

### 5.2 Concrete Tasks Requiring a Real Human Reviewer
The following actions cannot be automated and require actual human panel execution:
1. **Curator Panel Contracting:** Onboard qualified external curators (IELTS Band 8.5+ / CEFR C2, 3+ years EAP experience).
2. **Holdout Item Curation:** Curate 30 items from quarantined families (`fam-astrophysics-pulsar-08`, `fam-paleontology-cambrian-09`, `fam-mood-subjunctive-08`, `fam-aspect-participle-09`) with source citations.
3. **Curator Attestation & Sealing:** Compute canonical SHA-256 digests and sign the attestation in `CONFIRMATORY_HOLDOUT_MANIFEST.json`.
4. **Blinded Human Review Panel:** Execute double-blind review on anonymized review packet items (`task_hrev_*`) without suggested answer keys.
5. **Panel Lead Adjudication:** Adjudicate any annotator key or acceptability disagreements.

---

## 6. Known Evaluator Limitations

In the interest of scientific rigor and methodological transparency, the following limitations of Evaluator v2.7 are disclosed:
1. **Deterministic Lexical Heuristics:** Evaluator v2.7 uses rule-based syntactic parsing. Complex figurative language, highly elliptical clauses, or non-standard academic registers may trigger `UNCERTAIN` verdicts requiring human adjudication.
2. **In-Sample DEV Concordance:** The 100% concordance observed on the 25 DEV cases represents exploratory calibration, not post-freeze confirmatory proof. Real generalizability can only be measured on the sealed, uninspected holdout.
3. **Passage Grounding Boundaries:** In Reading evaluation, contradiction detection relies on polarity markers and lexical entailment; subtle pragmatic presuppositions without explicit lexical signals may be marked `UNCERTAIN`.
