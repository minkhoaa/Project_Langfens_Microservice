# RG10 — Historical Forensic Replay Audit Report

**Workflow:** Historical Forensic Replay (Preserves 22/22 original provider records without modified validation logic)  
**Evaluator:** NeutralEvaluatorV2_3 (`neutral-eval-v2.3`, `rubric-qgeval-v2.3`)  
**Raw Provider Records:** 22/22 consumed (100% accounted for, 0 unconsumed)  
**Total Tokens:** 23,886 tokens (EXACT confidence from provider response headers)  
**Calculated Spend:** $0.0358 USD  
**Replay Output Artifact:** `/home/code/workspaces/langfens/Project_Langfens_Microservice/generation_baseline/.execution/RG10_HISTORICAL_FORENSIC_REPLAY/historical_forensic_replay_results.json`  

---

## 1. Accounting and Dispatch Reconciliation

- **Total Original Dispatches:** 22 calls (100% accounted for in chronological sequence).
- **Consumption:** 22/22 records consumed (0 unconsumed).
- **Cumulative Tokens:** 23,886 tokens.
- **Evaluator Baseline:** NeutralEvaluatorV2_3.
- **Historical Verdict Distribution:** 4 PASS / 11 FAIL / 0 UNCERTAIN (26.67% pass rate).

---

## 2. Chronological Dispatch Sequence Ledger (22 Dispatches)

| # | Operation ID | Stage | Model | Provider Request ID | Prompt SHA256 (prefix) | Raw SHA256 (prefix) | Tokens (P/C/T) | Latency (ms) |
|---|---|---|---|---|---|---|---|---|
| 1 | `research-DIRECT_GENERATION_A-1` | `DIRECT_GENERATION_A` | `minimax/MiniMax-Text-01` | `0720fa447227729d338ff0f5f768f746` | `17809dbe76` | `32e1ada8c0` | 1038/398/1436 | 20550.7 |
| 2 | `research-DRAFT_GENERATION-2` | `DRAFT_GENERATION` | `minimax/MiniMax-Text-01` | `0720fa57a285c1862b2fac0c9d10e5cb` | `a839d8c092` | `fd5246d624` | 1038/404/1442 | 15556.9 |
| 3 | `research-SELF_CRITIQUE-3` | `SELF_CRITIQUE` | `minimax/MiniMax-Text-01` | `0720fa67526833820bb68fd43fbe61f4` | `125ce4a116` | `52cb7b86ea` | 483/319/802 | 13195.6 |
| 4 | `research-BOUNDED_REVISION-4` | `BOUNDED_REVISION` | `minimax/MiniMax-Text-01` | `0720fa74ae79f12924b1ac25c0f76a1b` | `47ad02f232` | `e71012d6d9` | 1285/398/1683 | 14930.7 |
| 5 | `research-GENERATOR-5` | `GENERATOR` | `minimax/MiniMax-Text-01` | `0720fa8354f22ef21611b03225f0a929` | `f048a7e15e` | `fd5246d624` | 1036/404/1440 | 16361.7 |
| 6 | `research-REVIEWER-6` | `REVIEWER` | `minimax/MiniMax-Text-01` | `0720fa937cb10586d901cccdbd0f6075` | `afcdcf6598` | `6f574e875a` | 539/159/698 | 6868.3 |
| 7 | `research-REPAIR-7` | `REPAIR` | `minimax/MiniMax-Text-01` | `0720fa9a9c11ad6ed52840c812b0201b` | `5d859849c6` | `c69a938572` | 1392/400/1792 | 14087.0 |
| 8 | `research-REVIEWER-8` | `REVIEWER` | `minimax/MiniMax-Text-01` | `0720faa8b5d6f5b1a360aca33ee8e542` | `bbf997a812` | `37d0e293d2` | 541/154/695 | 6045.1 |
| 9 | `research-DIRECT_GENERATION_A-9` | `DIRECT_GENERATION_A` | `minimax/MiniMax-Text-01` | `0720faae07798477250d3b3e3dd5cc5f` | `3aaf21f6d6` | `2bdff67ada` | 1124/367/1491 | 16991.8 |
| 10 | `research-DRAFT_GENERATION-10` | `DRAFT_GENERATION` | `minimax/MiniMax-Text-01` | `0720fabf1b255fc1b04767976403ee7e` | `7bd1957c65` | `14f4843a60` | 1124/477/1601 | 20387.8 |
| 11 | `research-SELF_CRITIQUE-11` | `SELF_CRITIQUE` | `minimax/MiniMax-Text-01` | `0720fad458f24a4b69f711b95e60b54c` | `12301c7336` | `800b85a25a` | 637/62/699 | 2876.8 |
| 12 | `research-BOUNDED_REVISION-12` | `BOUNDED_REVISION` | `minimax/MiniMax-Text-01` | `0720fad71c2fba82e60e0f7ddbb97b24` | `823d98124c` | `abc9c30169` | 1454/416/1870 | 17130.9 |
| 13 | `research-GENERATOR-13` | `GENERATOR` | `minimax/MiniMax-Text-01` | `0720fae81798aeabc9b6e071be261559` | `ed02177ba3` | `d2b98aaedc` | 1122/479/1601 | 18538.1 |
| 14 | `research-REVIEWER-14` | `REVIEWER` | `minimax/MiniMax-Text-01` | `0720fafa13923429215ed3267e6de8db` | `a1b2b37ef3` | `c600b810c4` | 679/16/695 | 1354.4 |
| 15 | `research-BLIND_SOLVER-15` | `BLIND_SOLVER` | `minimax/MiniMax-Text-01` | `0720fafcb056df70b6c5b9cafd8a7ca3` | `af6c8beaa8` | `5bf6c2f5ec` | 662/60/722 | 2913.9 |
| 16 | `research-VALIDATOR-16` | `VALIDATOR` | `minimax/MiniMax-Text-01` | `0720faff5a93aadeaea1b0dd7019f556` | `8ef2eff80f` | `796e4ebe9f` | 737/8/745 | 1024.8 |
| 17 | `research-GENERATOR-17` | `GENERATOR` | `minimax/MiniMax-Text-01` | `0720fb008315c04faa23e3b4634df316` | `89718568ef` | `3b2c0b43e0` | 1036/251/1287 | 8974.3 |
| 18 | `research-REVIEWER-18` | `REVIEWER` | `minimax/MiniMax-Text-01` | `0720fb0917bcc1502013ccde74503d64` | `f5c9406552` | `50e03ba1e6` | 422/57/479 | 3218.8 |
| 19 | `research-REPAIR-19` | `REPAIR` | `minimax/MiniMax-Text-01` | `0720fb0c09fb4da15f3daf82c3f7a530` | `85596cf883` | `1292509b8d` | 1177/252/1429 | 10337.2 |
| 20 | `research-REVIEWER-20` | `REVIEWER` | `minimax/MiniMax-Text-01` | `0720fb1615537b3f7c910218fd304e02` | `f5c9406552` | `c600b810c4` | 422/16/438 | 1534.9 |
| 21 | `research-BLIND_SOLVER-21` | `BLIND_SOLVER` | `minimax/MiniMax-Text-01` | `0720fb18a5f7682d296e02865dd40b51` | `c224fcf9fa` | `b4db9172a7` | 405/19/424 | 1394.1 |
| 22 | `research-VALIDATOR-22` | `VALIDATOR` | `minimax/MiniMax-Text-01` | `0720fb19ea8b522799e36a69510abfa9` | `172d9c94b3` | `796e4ebe9f` | 409/8/417 | 1029.3 |

---

## 3. Question-Level Matrix (n = 15) with Authoritative Provenance

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

### Historical Verdict Distribution:
- **Total Questions:** 15
- **Evaluator PASS:** 4 (26.7%)
- **Evaluator FAIL:** 11 (73.3%)
  - Missing Answer Key in Terminal Revision: 6 questions (Reading B Q1-Q3, Reading C Q1-Q3)
  - Distractor Ambiguity: 3 questions (Grammar A Q2, Grammar C Q1, Grammar C Q2)
  - Entailment Contradiction (v2.3 contrastive defect): 2 questions (Reading A Q1, Reading A Q3)
- **Zero Borrowed Answers:** Preserves original missing answer state without borrowing from rejected drafts.
