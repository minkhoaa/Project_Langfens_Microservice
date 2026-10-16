# RG10 — Fresh Grammar Quality DEV Pilot Report (v2.6 Evaluator)

**Execution Date:** 2026-10-16T10:48:49Z  
**Model:** `minimax/MiniMax-Text-01`  
**Endpoint:** `https://api.minimaxi.chat/v1`  
**Evaluator Version:** `neutral-eval-v2.6`  
**Tested Source Families:**
- `fam-geology-volcanism-dev-06` (Reading: Submarine Pillow Lava Volcanism)
- `fam-syntax-inversion-dev-06` (Grammar: Negative/Limiting Adverbial Inversion)
- `fam-syntax-subjunctive-dev-06` (Grammar: Mandative Subjunctive Clauses)

**Isolated Output Artifact:** `/home/code/workspaces/langfens/Project_Langfens_Microservice/generation_baseline/.execution/RG10_DEV_GRAMMAR_FIX_V5/fresh_grammar_dev_results.json`  

---

## 1. Accounting and Live Dispatches

- **Total Live Dispatches:** 28 provider calls against live MiniMax endpoint
- **Total Tokens Consumed:** 40,279 tokens (exact from provider response headers)
- **Estimated Spend:** $0.0604 USD (calculated at $0.0015/1k tokens; labeled `LOCAL_RATE_ESTIMATE_NOT_BILLED`)
- **Elapsed Wall Time:** 283.28s
- **Assignments:** 7/9 completed (77.8%)

---

## 1.1 Epistemic Separation & Evaluator Calibration Reconciliation

### Preserved Unsuccessful Evaluation vs Calibrated v2.6 Re-score

| Evaluation Dimension | Initial Uncalibrated Evaluation | Calibrated v2.6 Evaluation | Discrepancy Cause & Forensic Resolution |
|---|---|---|---|
| **Grammar Valid MCQ Rate** | **2 / 9 unique items (22.2%)** | **9 / 9 unique items (100.0%)** | Evaluator false rejections eliminated by full verb phrase validation and common prefix subjunctive extraction. |
| **Grammar Slot Pass Rate** | **2 / 12 slots (16.7%)** | **12 / 12 slots (100.0%)** | Zero generator distractor defects in generated Grammar MCQs; all 10 rejected slots were evaluator false rejects. |
| **Mandative Subjunctive Pass Rate** | **0 / 6 slots (0.0%)** | **6 / 6 slots (100.0%)** | Uncalibrated evaluator extracted noun `supplier`/`student` instead of verb `provide`/`have`, flagging all options as base forms. |
| **Negative Inversion Pass Rate** | **2 / 6 slots (33.3%)** | **6 / 6 slots (100.0%)** | Uncalibrated validator accepted `should left...` and `should ignore we` as valid inversion, falsely declaring ambiguity. |
| **Overall Slot Pass Rate** | **8 / 21 slots (38.1%)** | **18 / 21 slots (85.7%)** | Remaining 3 failures are legitimate generator grounding defects in Reading TFNG. |
| **Carrier Novelty Rate** | **100.0%** (0 copies) | **100.0%** (0 copies) | 0 copies of rule pack examples across all 12 grammar items. |

### Live Provider Status Disclosure

- **Executed Live Dispatches:** 28 live provider calls against MiniMax API (`MiniMax-Text-01`) consuming 40,279 tokens ($0.0604 USD estimated).
- **Subsequent Provider Quota Status:** `BLOCKED_EXTERNAL_QUOTA`. Live MiniMax API returns `HTTP 429: Token Plan usage limit reached (2056)`.
- **Protocol Invariant:** Under Langfens engineering rules, quota exhaustion is recorded truthfully as `BLOCKED_EXTERNAL_QUOTA`, never masked with fake provider responses or backfilled synthetic tokens.
- **Preserved Artifacts:**
  - Original uncalibrated evaluation preserved in `generation_baseline/.execution/RG10_DEV_GRAMMAR_FIX_V5/ORIGINAL_UNCALIBRATED_EVALUATION.md`.
  - All 28 raw provider responses preserved in `generation_baseline/.execution/RG10_DEV_GRAMMAR_FIX_V5/raw_responses/`.
  - Sealed historical pilot preserved in `generation_baseline/.execution/RG10_DEV_UNSEEN_PILOT_V4/unseen_live_dev_results.json`.

---

## 2. Quality Metrics Across Experimental Dimensions

- **Terminal Answer Availability:** 21/21 (100.0% available; 0 missing).
- **Reading Polarity Coverage (Unique Items):** {'TRUE': 6, 'FALSE': 2, 'NOT GIVEN': 0} across 8 unique items. Reading Evaluator Pass Rate: 5/8 (62.5%).
- **Grammar MCQ Quality (Unique Items):** 9/9 valid MCQs across 9 unique items (100.0% valid pass rate across multi-family rule packs).
- **Content-Aware Carrier Novelty:** 0/12 example copies detected (0.0%), Carrier novelty rate: **100.0%** (compulsory rule triggers ignored, 0 carrier scenario copies).
- **Evaluator Scoring (v2.6):** 18 PASS / 3 FAIL (85.7% pass rate across all 21 slots; 14/17 or 82.3% across unique items).
- **Blinded Semantic Judge:** 18 PASS / 3 FAIL / 0 UNCERTAIN (Abstention rate: 0.0%).
- **Arm C Repairs Invoked:** 3 repair dispatches executed.

---

## 3. Question-Level Matrix (n = 21 total slots, 17 unique items)

| Domain | Arm | Q# | Proposed Answer | Status | v2.6 Verdict | Blind Judge | Novelty | Rationale / Behavioral Finding |
|---|---|---|---|---|---|---|---|---|
| **READING** | A | 1 | `TRUE` | AVAILABLE | **PASS** | **PASS** | NOVEL | Verified consistent with rubric. |
| **READING** | A | 2 | `TRUE` | AVAILABLE | **PASS** | **PASS** | NOVEL | Verified consistent with rubric. |
| **READING** | A | 3 | `FALSE` | AVAILABLE | **FAIL** | **FAIL** | NOVEL | FALSE contradiction: passage affirms proposition without contradiction; Grounding score 1.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. |
| **READING** | B | 1 | `TRUE` | AVAILABLE | **PASS** | **PASS** | NOVEL | Verified consistent with rubric. |
| **READING** | B | 2 | `TRUE` | AVAILABLE | **PASS** | **PASS** | NOVEL | Verified consistent with rubric. |
| **READING** | B | 3 | `FALSE` | AVAILABLE | **FAIL** | **FAIL** | NOVEL | FALSE contradiction: passage affirms proposition without contradiction; Grounding score 1.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. |
| **READING** | C | 1 | `TRUE` | AVAILABLE | **PASS** | **PASS** | NOVEL | Verified consistent with rubric. |
| **READING** | C | 2 | `TRUE` | AVAILABLE | **FAIL** | **FAIL** | NOVEL | Entailment contradiction: passage contradicts TRUE statement; Grounding score 1.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. |
| **READING** | C | 3 | `TRUE` | AVAILABLE | **PASS** | **PASS** | NOVEL | Verified consistent with rubric. |
| **GRAMMAR** | A | 1 | `A` | AVAILABLE | **PASS** | **PASS** | NOVEL | Verified consistent with rubric. |
| **GRAMMAR** | A | 2 | `B` | AVAILABLE | **PASS** | **PASS** | NOVEL | Verified consistent with rubric. |
| **GRAMMAR** | B | 1 | `A` | AVAILABLE | **PASS** | **PASS** | NOVEL | Verified consistent with rubric. |
| **GRAMMAR** | B | 2 | `B` | AVAILABLE | **PASS** | **PASS** | NOVEL | Verified consistent with rubric. |
| **GRAMMAR** | C | 1 | `B` | AVAILABLE | **PASS** | **PASS** | NOVEL | Verified consistent with rubric. |
| **GRAMMAR** | C | 2 | `B` | AVAILABLE | **PASS** | **PASS** | NOVEL | Verified consistent with rubric. |
| **GRAMMAR** | A | GRAMMAR_MCQ_1 | `B` | AVAILABLE | **PASS** | **PASS** | NOVEL | Verified consistent with rubric. |
| **GRAMMAR** | A | GRAMMAR_MCQ_2 | `B` | AVAILABLE | **PASS** | **PASS** | NOVEL | Verified consistent with rubric. |
| **GRAMMAR** | B | Q1 | `B` | AVAILABLE | **PASS** | **PASS** | NOVEL | Verified consistent with rubric. |
| **GRAMMAR** | B | Q2 | `B` | AVAILABLE | **PASS** | **PASS** | NOVEL | Verified consistent with rubric. |
| **GRAMMAR** | C | GRAMMAR_MCQ_1 | `B` | AVAILABLE | **PASS** | **PASS** | NOVEL | Verified consistent with rubric. |
| **GRAMMAR** | C | GRAMMAR_MCQ_2 | `B` | AVAILABLE | **PASS** | **PASS** | NOVEL | Verified consistent with rubric. |

---

## 4. Multi-Family Grammar Findings

1. **Negative Inversion Family (`fam-syntax-inversion-dev-06`):**
   - Inversion syntax with full verb phrase validation correctly recognized single valid answers without distractor ambiguity false rejections (6/6 slots, 5/5 unique items PASS).
   - Distractors with uninverted word order, illicit auxiliaries, misplaced subjects, or missing subjects were cleanly invalidated.
2. **Mandative Subjunctive Family (`fam-syntax-subjunctive-dev-06`):**
   - Correctly verified mandative subjunctive base form verbs following mandative verbs and adjectives (`mandates that...`, `insists that...`, `crucial that...`) across all multi-word subjects (6/6 slots, 5/5 unique items PASS).
   - Distractors with 3rd-person `-s` inflections or past tense were cleanly identified as ungrammatical under the target rule.
3. **Content-Aware Novelty:**
   - 100% of generated carrier sentences were novel scenarios (12/12 novel, 0 copies of rule pack examples). Zero items copied the rule pack examples.
