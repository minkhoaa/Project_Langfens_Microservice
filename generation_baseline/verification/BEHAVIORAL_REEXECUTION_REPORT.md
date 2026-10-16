# RG10 DEV Hardening — Current Behavioral Re-execution Report

**Execution Mode:** Current Behavioral Re-execution (execution graph reflecting updated validation rules; not byte-identical historical replay)  
**Evaluator:** NeutralEvaluatorV2_3 (`neutral-eval-v2.3`, `rubric-qgeval-v2.3`)  
**Raw Provider Dispatches Replayed:** 21 authentic MiniMax calls  
**Unconsumed Provider Records:** 1 record(s)  
**Replay Output Artifact:** `/home/code/workspaces/langfens/Project_Langfens_Microservice/generation_baseline/.execution/RG10_DEV_HARDENING_V3_REPLAY/quality_dev_hardening_results.json`  

---

## 1. Accounting and Telemetry Summary

- **Total Dispatches:** 21 calls (100% replayed from authentic raw provider responses)
- **Cumulative Tokens:** 23,191 tokens (EXACT confidence from provider response headers)
- **Spend:** $0.0348 USD
- **Completed Assignments:** 4/6 (66.67% completion rate)
- **Preserved Terminal Failures:** 2/6 (33.33% failed validation; Arm B and Arm C terminated strictly without fake passes)
- **Unconsumed Raw Records:** 1 record(s) (research-REVIEWER-8_REVIEWER_1792133038741024377.json). Note: research-REVIEWER-8 was unconsumed because research-REPAIR-7 omitted answer keys, triggering PROPOSED_ANSWERS_MISSING terminal failure before post-repair review dispatch.
- **Replay Ambiguity Audit:** 1 dispatch(es) with identical (stage, prompt_sha256) matches (REVIEWER-18 vs REVIEWER-20). Resolution: Bound to pre-interleave candidate before stage(s): ['REPAIR']
---

## 2. Question-Level Matrix (n = 15) with Authoritative Answer Provenance

| Domain | Arm | Q# | Type | Authoritative Proposed Answer | Provenance Status | Evaluator v2.3 Verdict | Grounding | Rationale & Behavioral Finding |
|---|---|---|---|---|---|---|---|---|
| **READING** | A | 1 | TFNG | `TRUE` | AVAILABLE | **FAIL** | 1.0 | Entailment contradiction: passage contradicts TRUE statement; Grounding score 1.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. |
| **READING** | A | 2 | TFNG | `FALSE` | AVAILABLE | **PASS** | 4.0 | Verified consistent with rubric. |
| **READING** | A | 3 | TFNG | `TRUE` | AVAILABLE | **FAIL** | 1.0 | Entailment contradiction: passage contradicts TRUE statement; Grounding score 1.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. |
| **READING** | B | 1 | TFNG | `None` | UNSCORABLE_MISSING_ANSWER | **FAIL** | 1.0 | UNSCORABLE_MISSING_ANSWER: Question provides no proposed answer key |
| **READING** | B | 2 | TFNG | `None` | UNSCORABLE_MISSING_ANSWER | **FAIL** | 1.0 | UNSCORABLE_MISSING_ANSWER: Question provides no proposed answer key |
| **READING** | B | 3 | TFNG | `None` | UNSCORABLE_MISSING_ANSWER | **FAIL** | 1.0 | UNSCORABLE_MISSING_ANSWER: Question provides no proposed answer key |
| **READING** | C | 1 | TFNG | `None` | UNSCORABLE_MISSING_ANSWER | **FAIL** | 1.0 | UNSCORABLE_MISSING_ANSWER: Question provides no proposed answer key |
| **READING** | C | 2 | TFNG | `None` | UNSCORABLE_MISSING_ANSWER | **FAIL** | 1.0 | UNSCORABLE_MISSING_ANSWER: Question provides no proposed answer key |
| **READING** | C | 3 | TFNG | `None` | UNSCORABLE_MISSING_ANSWER | **FAIL** | 1.0 | UNSCORABLE_MISSING_ANSWER: Question provides no proposed answer key |
| **GRAMMAR** | A | 1 | GRAMMAR_MCQ | `B` | AVAILABLE | **PASS** | 4.0 | Verified consistent with rubric. |
| **GRAMMAR** | A | 2 | GRAMMAR_MCQ | `A` | AVAILABLE | **FAIL** | 2.0 | Ambiguous MCQ: multiple options [1, 4] exhibit grammatically valid it-cleft syntax; Grounding score 2.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. |
| **GRAMMAR** | B | q1 | GRAMMAR_MCQ | `A` | AVAILABLE | **PASS** | 4.0 | Verified consistent with rubric. |
| **GRAMMAR** | B | q2 | GRAMMAR_MCQ | `B` | AVAILABLE | **PASS** | 4.0 | Verified consistent with rubric. |
| **GRAMMAR** | C | GRAMMAR_MCQ_1 | GRAMMAR_MCQ | `It was the new findings that surprised the scientific community.` | AVAILABLE | **FAIL** | 2.0 | Ambiguous MCQ: multiple options [1, 2, 3] exhibit grammatically valid it-cleft syntax; Grounding score 2.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. |
| **GRAMMAR** | C | GRAMMAR_MCQ_2 | GRAMMAR_MCQ | `It was the research methodology that the team developed.` | AVAILABLE | **FAIL** | 2.0 | Ambiguous MCQ: multiple options [1, 2, 3, 4] exhibit grammatically valid it-cleft syntax; Grounding score 2.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. |

### Verdict Distribution:
- **Total Questions:** 15
- **Evaluator PASS:** 4 (26.7%)
- **Evaluator FAIL:** 11 (73.3%)
  - Missing Answer Key in Terminal Revision: 6 questions (Reading B Q1-Q3, Reading C Q1-Q3)
  - Distractor Ambiguity / Multiple Defensible Keys: 3 questions
- **Zero Borrowed Answers:** In earlier reports, Reading B and C answers were borrowed from earlier rejected drafts. Under authentic answer provenance, these questions are correctly marked `UNSCORABLE_MISSING_ANSWER`.

---

## 3. The 12 Experimental Dimensions

1. **Execution Completion:** 66.67% (4/6 requests completed, 2/6 FAILED_VALIDATION preserved).
2. **Question Availability:** 60.0% (9/15 questions had answer keys; 6/15 terminal revisions omitted answer key).
3. **Structural Validity:** 100.0% schema conformance (15/15 items valid NeutralQuestion instances).
4. **Answer Correctness:** 26.67% pass rate (4/15 verified answers).
5. **Answer Uniqueness:** 50.0% unique key pass rate (3/6 Grammar MCQs had single unambiguous keys; 3 flagged for distractor ambiguity).
6. **Distractor Quality:** 3 Grammar MCQs caught with distractor validity issues.
7. **Semantic Verdicts:** 4 PASS, 11 FAIL, 0 UNCERTAIN.
8. **Label Diversity:** Reading: {'TRUE': 2, 'FALSE': 1, 'NOT_GIVEN': 0, 'UNSCORABLE_MISSING': 6}. Complete 3-way coverage achieved: False. Grammar keys: {'A': 2, 'B': 4, 'C': 0, 'D': 0}.
9. **Content Novelty:** 100.0% novelty rate across n=6 Grammar MCQs (0 rule pack copies).
10. **Repair Effectiveness:** 2 repairs invoked: 1 recovered (50.0%), 1 terminal review failure preserved (50.0%).
11. **Evaluator v2.3 Calibration:** Calibrated on 17-item adversarial corpus (FAR=0.0, FRR=0.4286, accuracy on decided=82.35%).
12. **Provider Telemetry:** 21 calls, 23191 tokens, $0.0348 spend, EXACT confidence, 209.3s cumulative provider latency (0.04s replay wall time).
