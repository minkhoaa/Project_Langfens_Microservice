# RG10 Evaluator v2.6 Independent Acceptance & Gate Assessment Report

**Execution Date:** 2026-10-16T12:55:00Z  
**Branch:** `autonomous-generation`  
**Evaluator Version:** `neutral-eval-v2.6`  
**Rubric Version:** `rubric-qgeval-v2.6`  
**Governing Standard:** `generation_baseline/research/RQ2_PROTOCOL.md` & `DATA_GOVERNANCE.md`  
**Local Runtime Environment:** Python 3.10.12, .NET 10.0 (Production container target: Python 3.12)  

---

## 1. Executive Summary & Readiness Verdicts

This report provides the independent evaluation and software-quality assessment for **Evaluator v2.6** under RG10, strictly preserving all historical research artifacts.

### Three-Pillar Readiness Separation

| Pillar | Gate Verdict | Evidence & Rationale |
|---|---|---|
| **SOFTWARE_READY** | **QUALIFIED_PASS (PREREQUISITE_LIMITED)** | Deterministic unit and evaluator suites pass 100% (1,084 passed, 33 skipped in generation-service unit/functional tests; 26 passed in v2.6 acceptance test suite; 39 passed in isolation/grammar suite; 133 passed in loop runtime/caps suite; 73 passed in .NET attempt-service suite). Complete version isolation verified with zero regression in historical evaluators (v2.0–v2.5). **Prerequisite limits disclosed:** Full-suite run recorded 1 failure in `test_t14_harness_integration.py` due to absent live PostgreSQL instance on port 5433 (infrastructure dependency, not evaluator defect). Local runner executed under Python 3.10.12 (production containers are pinned to Python 3.12). |
| **QUALITY_READY** | **HOLD (EVALUATOR_DEFECTS_UNRESOLVED)** | Evaluator v2.6 eliminates historical regex blindspots (Not only missing trigger, shallow auxiliary distractor matching, and mandative noun-verb extraction errors). However, exploratory DEV testing on 25 items across 5 grammar families exposed **concrete unresolved evaluator defects** (FR rate = 13.3% [2/15], FA rate = 20.0% [2/10]: base verbs ending in `-s`/`-ss`, non-inverted *if* matching, and mandative adjective stems). Furthermore, because these 25 cases served to diagnose implementation limits, they do not constitute an independent post-freeze acceptance set. Quality acceptance remains incomplete. |
| **RESEARCH_READY** | **HOLD** | **Blocked on external prerequisites:** Live MiniMax API returned `HTTP 429: Token Plan usage limit reached (2056)` (truthfully recorded as `BLOCKED_EXTERNAL_QUOTA`). Confirmatory holdout specification ($N=30$) defines quotas across disjoint source families, but real item curation and cryptographic seals remain pending external panel execution (`SPECIFICATION_PENDING_INDEPENDENT_CURATION`). Certified human expert panel review is prepared with empty review packets (`AWAITING_HUMAN_PANEL`) without synthetic human score fabrication. |
| **OVERALL GATE VERDICT** | **`HOLD`** | **Do NOT start RG11 or the final A/B/C campaign.** Evaluator v2.6 exhibits known software-quality defects and lacks independent post-freeze holdout evaluation; hold until external quota is restored, evaluator defects are repaired, confirmatory holdout is independently curated, and human expert panel data is gathered. |

---

## 2. Independent Audit: Historical (6) and Fresh (12) Grammar MCQs

*Epistemic Disclosure:* Ground truth labels in this section represent an **internal analytical linguistic audit** (non-human gold), strictly separated from certified human ground truth. All automated evaluator scores are classified as **evaluator predictions / model rescores**, not independent gold.

### 2.1 Historical Grammar Pilot (RG10_DEV_UNSEEN_PILOT_V4, n = 6 slots)

| Item ID | Question Stem / Construction | Proposed Answer | Analytical Linguistic Status (Non-Human Gold) | Evaluator v2.5 Prediction | Evaluator v2.6 Prediction | Discrepancy Cause & Forensic Resolution |
|---|---|---|---|---|---|---|
| `dev-inv-05__arm_A__att1 (Q1)` | *Not only did she win the race...* | `A` | **VALID** | `FAIL` | **`PASS`** | Evaluator False Rejection: `Not only` trigger was missing from v2.5 trigger regex. |
| `dev-inv-05__arm_A__att1 (Q2)` | *Under no circumstances should we open the door...* | `A` | **VALID** | `FAIL` | **`PASS`** | Evaluator False Rejection: Distractor C (*"do we should"*) was falsely matched as valid inversion, creating false ambiguity. |
| `dev-inv-05__arm_B__att1 (Q1)` | *Not only did she win the award...* | `A` | **VALID** | `FAIL` | **`PASS`** | Evaluator False Rejection: Missing trigger / shallow auxiliary match. |
| `dev-inv-05__arm_B__att1 (Q2)` | *Under no circumstances should we leave the building...* | `A` | **VALID** | `FAIL` | **`PASS`** | Evaluator False Rejection: Distractor C (*"did we should"*) falsely matched as valid inversion. |
| `dev-inv-05__arm_C__att1 (Q1)` | *Not only did she win the race...* | `A` | **VALID** | `FAIL` | **`PASS`** | Evaluator False Rejection: Cross-arm convergence identical to Q1. |
| `dev-inv-05__arm_C__att1 (Q2)` | *Which sentence correctly uses 'do' to form inversion...* | `C` | **GENERATOR DEFECT** | `PASS` | **`FAIL`** | Evaluator False Acceptance in v2.5: Question stem requested `'do'` inversion, but option C provided modal auxiliary `'should'`. v2.6 correctly catches stem-answer constraint conflict. |

*Historical Audit Summary:* In v2.5, apparent pass rate was 1/6 (16.7%). Analytical linguistic audit reveals **5/6 (83.3%) valid MCQs** and **1/6 generator defect**. Evaluator v2.6 achieves **6/6 concordance** with the analytical linguistic classification.

### 2.2 Fresh Grammar Pilot (RG10_DEV_GRAMMAR_FIX_V5, n = 12 slots)

*All 12 items were evaluated via Evaluator v2.6 rescore (model predictions):*

- **Negative Inversion Family (`fam-syntax-inversion-dev-06`, 6 slots):**
  - Q1 (Arm A): *Not only did the experiment fail...* (Key `A`) -> **VALID** -> v2.6 prediction: **`PASS`**
  - Q2 (Arm A): *Under no circumstances should we ignore...* (Key `B`) -> **VALID** -> v2.6 prediction: **`PASS`**
  - Q3 (Arm B): *Never have I seen such a beautiful sunset...* (Key `A`) -> **VALID** -> v2.6 prediction: **`PASS`**
  - Q4 (Arm B): *Under no circumstances should the equipment be left...* (Key `B`) -> **VALID** -> v2.6 prediction: **`PASS`**
  - Q5 (Arm C): *Under no circumstances should we compromise...* (Key `B`) -> **VALID** -> v2.6 prediction: **`PASS`**
  - Q6 (Arm C): *Scarcely did the meeting start when the fire alarm rang...* (Key `B`) -> **VALID** -> v2.6 prediction: **`PASS`**
- **Mandative Subjunctive Family (`fam-syntax-subjunctive-dev-06`, 6 slots):**
  - Q7 (Arm A): *The contract stipulates that the supplier provide...* (Key `B`) -> **VALID** -> v2.6 prediction: **`PASS`**
  - Q8 (Arm A): *It is vital that she attend the conference...* (Key `B`) -> **VALID** -> v2.6 prediction: **`PASS`**
  - Q9 (Arm B): *The policy requires that each student have...* (Key `B`) -> **VALID** -> v2.6 prediction: **`PASS`**
  - Q10 (Arm B): *Which sentence demonstrates incorrect use...* (Key `B`, *submits*) -> **VALID** -> v2.6 prediction: **`PASS`**
  - Q11 (Arm C): *The policy requires that each student attend...* (Key `B`) -> **VALID** -> v2.6 prediction: **`PASS`**
  - Q12 (Arm C): *It is important that she be on time...* (Key `B`) -> **VALID** -> v2.6 prediction: **`PASS`**

*Fresh Pilot Audit Summary:* Generator prompt improvements successfully produced 12/12 analytically defensible MCQs with 100.0% content-aware carrier novelty (zero scenario copying). Evaluator v2.6 predicted all 12 slots as PASS.

---

## 3. Internal DEV Acceptance Suite (25 Diagnostic Cases)

*Epistemic Guardrail:* Because these 25 acceptance cases were used to diagnose evaluator implementation limits during development, this suite constitutes **exploratory developmental evidence, NOT an independent confirmatory holdout**. Only a post-freeze, uninspected dataset can provide confirmatory research claims.

### 3.1 Benchmark Stratification and Error Matrix

- **Total Cases ($N$):** 25
- **Analytical Gold VALID Items ($N_{\text{valid}}$):** 15 (Explicit denominator for False Rejection Rate)
- **Analytical Gold INVALID Items ($N_{\text{invalid}}$):** 10 (Explicit denominator for False Acceptance Rate)

```
                       Evaluator v2.6 Prediction
                     ┌──────────────┬──────────────┐
                     │     PASS     │     FAIL     │
       ┌─────────────┼──────────────┼──────────────┤
       │ Gold VALID  │   TP = 13    │   FN = 2     │  N_valid = 15
Actual │             │              │ (False Rej)  │
       ├─────────────┼──────────────┼──────────────┤
       │ Gold INVALID│   FP = 2     │   TN = 8     │  N_invalid = 10
       │             │ (False Acc)  │              │
       └─────────────┴──────────────┴──────────────┘
                       Total Items = 25
```

### 3.2 Metrics with Explicit Denominators

| Metric | Formula | Observed Value | Percentage | Protocol Characterization |
|---|---|---|---|---|
| **Coverage** | $\frac{\text{Decisive (PASS + FAIL)}}{\text{Total}}$ | $\frac{25}{25}$ | **100.0%** | Full decisive coverage across diagnostic items |
| **Abstention Rate** | $\frac{\text{UNCERTAIN}}{\text{Total}}$ | $\frac{0}{25}$ | **0.0%** | Reported per protocol; 0 unhandled stalls |
| **False Rejection Rate (FRR)** | $\frac{\text{FN}}{N_{\text{valid}}}$ | $\frac{2}{15}$ | **13.3%** | Evaluator defect boundary (INV-DEV-02, CND-DEV-01) |
| **False Acceptance Rate (FAR)** | $\frac{\text{FP}}{N_{\text{invalid}}}$ | $\frac{2}{10}$ | **20.0%** | Evaluator defect boundary (SUB-DEV-04, SUB-DEV-05) |
| **Overall Diagnostic Concordance** | $\frac{\text{TP} + \text{TN}}{\text{Total}}$ | $\frac{21}{25}$ | **84.0%** | Descriptive exploratory baseline (not an RQ2 gate) |
### 3.3 Root Cause Analysis of Evaluator Discrepancies

1. **False Rejection 1 (`INV-DEV-02`, Inversion):**
   - *Sentence:* *"Under no circumstances should we bypass the interlock."* (Analytical Gold: VALID)
   - *Evaluator Prediction:* `FAIL` (*"Modal auxiliary 'should' cannot be followed by 3rd-person inflected verb 'bypass'"*)
   - *Defect Mechanism:* The heuristic verb-inflection filter flagged words ending in `-s` as 3rd-person inflections without exempting base verbs ending in `-ss` (e.g. *bypass*, *cross*, *discuss*).
2. **False Rejection 2 (`CND-DEV-01`, Conditionals):**
   - *Question:* Inverted third conditional (*"Had the crew checked..."*). (Analytical Gold: VALID)
   - *Evaluator Prediction:* `FAIL` (*"Ambiguous conditional MCQ: multiple options [1, 3] are defensible"*)
   - *Defect Mechanism:* The conditional validator accepted Option C (*"If the crew had checked..."*) as a valid option, ignoring the stem constraint specifically requesting an *inverted* conditional.
3. **False Acceptance 1 (`SUB-DEV-04`, Subjunctive):**
   - *Question:* Ambiguous subjunctive MCQ with two base-form options (Option B *pay*, Option C *appear*). (Analytical Gold: INVALID)
   - *Evaluator Prediction:* `PASS`
   - *Defect Mechanism:* Multi-option base form ambiguity was not detected when carrier clauses diverged in subject noun phrasing.
4. **False Acceptance 2 (`SUB-DEV-05`, Subjunctive):**
   - *Question:* Defective subjunctive MCQ with zero base forms. (Analytical Gold: INVALID)
   - *Evaluator Prediction:* `PASS`
   - *Defect Mechanism:* Stem used the adjective *mandative* rather than trigger verbs (*mandate*, *insist*), causing `is_mandative` to evaluate to `False`, bypassing distractor checks.

*Scientific Integrity Note:* Under task rules, **references were not relabeled** to cosmetically inflate metrics. These error rates represent the true empirical performance envelope of Evaluator v2.6.

---

## 4. Reading Quality Reconciliation (RG10_DEV_GRAMMAR_FIX_V5)

Forensic analysis of the three failing Reading slots in `RG10_DEV_GRAMMAR_FIX_V5`:

### Item 1: Arm A, Question 3
- **Stem:** *"Pyroclastic fragmentation occurs in deep benthic environments due to high hydrostatic pressure."*
- **Proposed Answer:** `FALSE`
- **Original Evaluator Verdict:** `FAIL` (*"FALSE contradiction: passage affirms proposition without contradiction"*)
- **Passage Text:** *"...abyssal hydrostatic pressure exceeding two hundred atmospheres suppresses volatile exsolution, thereby preventing pyroclastic fragmentation in deep benthic environments."*
- **Forensic Finding:** **Evaluator False Rejection (`EVALUATOR_DEFECT`)**. The passage explicitly states hydrostatic pressure *prevents* fragmentation; the statement asserts it *occurs due to* pressure. The generator's proposed answer (`FALSE`) is factually and contextually correct. The evaluator's shallow contradiction regex failed to recognize *"preventing"* as a negative polarity marker.
- **Corrected Derived Interpretation:** `VALID_FALSE_QUESTION` (Grounding: 5.0, Corrected Derived Verdict: `PASS`). Original recorded response and verdict remain unmutated in historical storage.

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
  1. *Category Confusion:* Conflates physical pressure (*atmospheres*) with depth (*meters*).
  2. *Passage Hallucination:* The passage does not assert that pillow lava only forms at pressures exceeding 200 atmospheres. Under IELTS rules, this is `NOT GIVEN` or unsupported.
  3. *Evaluator Diagnostic Defect:* While the evaluator correctly issued a `FAIL` verdict, its internal diagnostic was flawed (triggering an antonym/numeric clash between 200 atmospheres and 2 degrees Celsius).
- **Corrected Derived Interpretation:** `DEFECTIVE_QUESTION` (Verdict `FAIL` upheld on grounds of insufficient passage support).

---

## 5. Research Integrity & Epistemic Guardrails

1. **Historical Campaign Immutability:** All historical execution files in `generation_baseline/.execution/` and reports in `generation_baseline/verification/` remain unmutated.
2. **Holdout Quarantine:** All items inspected during DEV (including the 6 historical MCQs, 12 fresh MCQs, and 25 DEV acceptance cases) are permanently designated `EXPLORATORY_DEV` and cannot serve as confirmatory holdout data.
3. **Confirmatory Holdout Specification:** The holdout framework (`CONFIRMATORY_HOLDOUT_MANIFEST.json`) defines target quotas ($N=30$) across 4 disjoint source families (`fam-astrophysics-pulsar-08`, `fam-paleontology-cambrian-09`, `fam-mood-subjunctive-08`, `fam-aspect-participle-09`). Its status is `SPECIFICATION_PENDING_INDEPENDENT_CURATION`, with cryptographic seals kept `null` until real curated items are hashed, preventing fabrication of holdout integrity.
4. **Provider Quota Status:** MiniMax quota exhaustion is recorded truthfully as `BLOCKED_EXTERNAL_QUOTA`. No mock provider responses or synthetic tokens were used to simulate live dispatches.
5. **Human Review Materials:** Human review packets (`HUMAN_REVIEW_PACKET.json` / `.md`) have been formatted with blinded task IDs and stripped answer keys, with scoring fields explicitly set to `null` awaiting a certified human panel (`AWAITING_HUMAN_PANEL`). Zero synthetic human scores were fabricated.

---

## 6. Final Gate Assessment & Recommendation

- **SOFTWARE_READY: `QUALIFIED_PASS (PREREQUISITE_LIMITED)`**
- **QUALITY_READY: `HOLD (EVALUATOR_DEFECTS_UNRESOLVED)`**
- **RESEARCH_READY: `HOLD`**
- **Overall Verdict: `HOLD`**
**Prerequisites for Next Steps:**
1. Replenish MiniMax provider API quotas and verify live connectivity.
2. Complete external independent curation of the 30 holdout items with cryptographic SHA-256 digests.
3. Onboard certified human expert annotators (CEFR C2 / IELTS 8.5+).
4. Run the preregistered confirmatory campaign under frozen RQ2 protocol. Do not advance to RG11 prior to external unblocking.
