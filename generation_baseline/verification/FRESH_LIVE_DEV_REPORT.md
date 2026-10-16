# RG10 — Fresh Live DEV Execution Report (MiniMax-Text-01)

**Date:** 2026-10-16T09:38:27Z  
**Model:** `minimax/MiniMax-Text-01`  
**Endpoint:** `https://api.minimaxi.chat/v1`  
**Credentials:** Authenticated via `deploy/envs/ai.env` (`MINIMAX_API_KEY` present; unlogged)  
**Output Artifact:** `/home/code/workspaces/langfens/Project_Langfens_Microservice/generation_baseline/.execution/RG10_DEV_FRESH_V3/fresh_live_dev_results.json`  

---

## 1. Accounting and Live Dispatches

- **Total Live Dispatches:** 18 provider calls against live MiniMax endpoint
- **Total Tokens Consumed:** 21,096 tokens (exact from provider response headers)
- **Estimated Spend:** $0.0316 USD (calculated at $0.0015/1k tokens; billed amount governed by MiniMax account balance)
- **Elapsed Wall Time:** 137.3s
- **Assignments:** 5/6 completed (83.3%)

---

## 2. Terminal Answer Availability & Provenance Binding

- **Total Evaluated Questions:** 15
- **Proposed Answers Available:** 15/15 (100.0%)
- **Missing Proposed Answers:** 0/15
- **Cryptographic Provenance:** Every terminal question has its proposed answer bound to its `question_text`, `question_content_hash`, and `output_response_sha256`.
- **Zero Draft Borrowing:** No answers borrowed from rejected drafts. Reviewer and blind solver remained answer-blind.

---

## 3. Question-Level Matrix (n = 15)

| Domain | Arm | Q# | Proposed Answer | Status | v2.5 Verdict | Blind Judge | Rationale / Finding |
|---|---|---|---|---|---|---|---|
| **READING** | A | 1 | `FALSE` | AVAILABLE | **PASS** | **PASS** | Verified consistent with rubric. |
| **READING** | A | 2 | `TRUE` | AVAILABLE | **PASS** | **PASS** | Verified consistent with rubric. |
| **READING** | A | 3 | `FALSE` | AVAILABLE | **PASS** | **PASS** | Verified consistent with rubric. |
| **READING** | B | 1 | `TRUE` | AVAILABLE | **FAIL** | **FAIL** | Entailment contradiction: passage contradicts TRUE statement; Grounding score 1.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. |
| **READING** | B | 2 | `FALSE` | AVAILABLE | **PASS** | **PASS** | Verified consistent with rubric. |
| **READING** | B | 3 | `TRUE` | AVAILABLE | **FAIL** | **FAIL** | Entailment contradiction: passage contradicts TRUE statement; Grounding score 1.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. |
| **READING** | C | 1 | `TRUE` | AVAILABLE | **FAIL** | **FAIL** | Entailment contradiction: passage contradicts TRUE statement; Grounding score 1.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. |
| **READING** | C | 2 | `FALSE` | AVAILABLE | **PASS** | **PASS** | Verified consistent with rubric. |
| **READING** | C | 3 | `TRUE` | AVAILABLE | **FAIL** | **FAIL** | Entailment contradiction: passage contradicts TRUE statement; Grounding score 1.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. |
| **GRAMMAR** | A | 1 | `A` | AVAILABLE | **FAIL** | **FAIL** | Tense agreement discord: Present copula 'is' clashes with past relative verb 'surprised' (expected 'was'); Grounding score 2.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. |
| **GRAMMAR** | A | 2 | `A` | AVAILABLE | **PASS** | **PASS** | Verified consistent with rubric. |
| **GRAMMAR** | B | Q1 | `A` | AVAILABLE | **FAIL** | **FAIL** | Ambiguous MCQ: multiple options [1, 3] exhibit grammatically valid it-cleft syntax; Grounding score 2.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. |
| **GRAMMAR** | B | Q2 | `D` | AVAILABLE | **FAIL** | **FAIL** | Ambiguous MCQ: multiple options [3, 4] exhibit grammatically valid it-cleft syntax; Grounding score 2.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. |
| **GRAMMAR** | C | 1 | `B` | AVAILABLE | **FAIL** | **FAIL** | Ambiguous MCQ: multiple options [1, 2, 4] exhibit grammatically valid it-cleft syntax; Grounding score 2.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. |
| **GRAMMAR** | C | 2 | `A` | AVAILABLE | **FAIL** | **FAIL** | Defective cleft MCQ: proposed answer is not a valid it-cleft construction; Grounding score 2.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. |

---

## 4. Evaluator Reliability and Abstention

- **NeutralEvaluatorV2_5 Verdicts:** 6 PASS / 9 FAIL
- **Blinded Semantic Judge Verdicts:** 6 PASS / 9 FAIL / 0 UNCERTAIN
- **Abstention on Linguistic Boundaries:** 0 items escalated to explicit UNCERTAIN pending human panel review
- **Human Review Integrity:** `verified_human_truth = False` (AI models cannot certify human gold truth)
