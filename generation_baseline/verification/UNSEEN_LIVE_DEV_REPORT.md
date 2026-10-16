# RG10 — Unseen Live DEV Pilot Report (MiniMax-Text-01)

**Date:** 2026-10-16T09:55:36Z  
**Model:** `minimax/MiniMax-Text-01`  
**Endpoint:** `https://api.minimaxi.chat/v1`  
**Disjoint Source Families:** `fam-oceanography-abyssal-05` (Reading) & `fam-syntax-inversion-05` (Grammar)  
**Output Artifact:** `/home/code/workspaces/langfens/Project_Langfens_Microservice/generation_baseline/.execution/RG10_DEV_UNSEEN_PILOT_V4/unseen_live_dev_results.json`  

---

## 1. Accounting and Live Dispatches

- **Total Live Dispatches:** 19 provider calls against live MiniMax endpoint
- **Total Tokens Consumed:** 22,299 tokens (exact from provider response headers)
- **Estimated Spend:** $0.0334 USD (calculated at $0.0015/1k tokens; labeled `LOCAL_RATE_ESTIMATE_NOT_BILLED`)
- **Elapsed Wall Time:** 153.67s
- **Assignments:** 6/6 completed (100.0%)

---

## 2. Quality Metrics Across Experimental Dimensions

- **Terminal Answer Availability:** 15/15 (100.0% available; 0 missing).
- **Reading Polarity Coverage (Unique Items):** {'FALSE': 4, 'TRUE': 2, 'NOT GIVEN': 1} across 7 unique items (Total slots: 9). Complete 3-way TRUE/FALSE/NOT GIVEN coverage achieved: TRUE=2, FALSE=4, NOT GIVEN=1. Reading Evaluator Pass Rate: 6/7 (85.7%).
- **Grammar MCQ Quality (Unique Items):** 1/5 valid MCQs across 5 unique items (20.0% valid pass rate; 1 cross-arm duplicate between Arm A and Arm C; 4 items flagged for distractor ambiguity/cues). Rule-pack example copies: 3/6 (50.0%), Carrier novelty rate: 50.0%.
- **Evaluator Scoring (v2.5):** 9 PASS / 6 FAIL (60.0% pass rate across all 15 slots; 7/12 or 58.3% across 12 unique items).
- **Blinded Semantic Judge:** 9 PASS / 6 FAIL / 0 UNCERTAIN (Abstention rate: 0.0%).

---

## 3. Question-Level Matrix (n = 15 total slots, 12 unique items)

| Domain | Arm | Q# | Proposed Answer | Status | v2.5 Verdict | Blind Judge | Rationale / Behavioral Finding |
|---|---|---|---|---|---|---|---|
| **READING** | A | 1 | `FALSE` | AVAILABLE | **PASS** | **PASS** | Verified consistent with rubric. |
| **READING** | A | 2 | `TRUE` | AVAILABLE | **PASS** | **PASS** | Verified consistent with rubric. |
| **READING** | A | 3 | `FALSE` | AVAILABLE | **PASS** | **PASS** | Verified consistent with rubric. |
| **READING** | B | 1 | `TRUE` | AVAILABLE | **PASS** | **PASS** | Verified consistent with rubric. |
| **READING** | B | 2 | `FALSE` | AVAILABLE | **PASS** | **PASS** | Verified consistent with rubric. |
| **READING** | B | 3 | `FALSE` | AVAILABLE | **FAIL** | **FAIL** | FALSE contradiction: passage affirms proposition without contradiction; Grounding score 1.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. |
| **READING** | C | 1 | `FALSE` | AVAILABLE | **PASS** | **PASS** | Verified consistent with rubric. |
| **READING** | C | 2 | `TRUE` | AVAILABLE | **PASS** | **PASS** | Verified consistent with rubric. |
| **READING** | C | 3 | `NOT GIVEN` | AVAILABLE | **PASS** | **PASS** | Verified consistent with rubric. |
| **GRAMMAR** | A | 1 | `A` | AVAILABLE | **FAIL** | **FAIL** | Defective MCQ: no options exhibit valid negative inversion (Not only cue missing from cue list) |
| **GRAMMAR** | A | 2 | `A` | AVAILABLE | **FAIL** | **FAIL** | Ambiguous MCQ: multiple options [1, 3] exhibit valid negative inversion (distractor validity failure) |
| **GRAMMAR** | B | 1 | `A` | AVAILABLE | **FAIL** | **FAIL** | Ambiguous MCQ: multiple options [1, 3] exhibit valid negative inversion (distractor validity failure) |
| **GRAMMAR** | B | 2 | `A` | AVAILABLE | **FAIL** | **FAIL** | Ambiguous MCQ: multiple options [1, 3] exhibit valid negative inversion (distractor validity failure) |
| **GRAMMAR** | C | Q1 | `A` | AVAILABLE | **FAIL** | **FAIL** | Defective MCQ: no options exhibit valid negative inversion (Not only cue missing from cue list) |
| **GRAMMAR** | C | Q2 | `C` | AVAILABLE | **PASS** | **PASS** | Verified consistent with rubric. |

---

## 4. Architectural Separation & Cross-Arm Analysis

- **Arm A (Direct Generation):** Executed single-shot with 0 repairs and 0 critiques. Produced 3 Reading items and 2 Grammar MCQs.
- **Arm B (Sequential Self-Review):** Internal self-critique with bounded revision executed without external reviewer. Produced 3 distinct Reading items and 2 distinct Grammar MCQs.
- **Arm C (Multi-Agent Coordinated):** Generation -> Answer-blind reviewer -> Blind solver -> Scoped repair -> Validator. Reviewer and solver received scrubbed candidate payloads with zero answer leakage.
- **Cross-Arm Overlap Finding:** Arm C produced 2 Reading items and 1 Grammar MCQ whose question text was byte-identical to Arm A generation. This demonstrates that when operating under the same passage and task constraints without diversity penalties, unguided multi-agent review can converge to the same high-entailment statements as direct generation.
