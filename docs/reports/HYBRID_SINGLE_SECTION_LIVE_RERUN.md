# Langfens Autonomous Reading Engine — Hybrid Single-Section Live Rerun Report

**Document ID:** `REPORT-2026-10-23-HYBRID-SINGLE-SECTION-LIVE-RERUN`  
**Location:** `docs/reports/HYBRID_SINGLE_SECTION_LIVE_RERUN.md`  
**Repository:** `minkhoaa/Project_Langfens_Microservice`  
**Branch:** `autonomous-generation`  
**Starting Commit:** `8e9cb8d8870d0864c1839abea1b97e6f04f19d96`  
**Implementation Commit SHA:** `cc5b0908eb8817bf57f1bf249b6ffb480c88591f`  
**Verification Scope:** Full Single-Section Hybrid Live Validation with Grounding Repair and Word Budget Protection  
**Target:** 1 IELTS Academic Reading passage, 13 accepted questions, real PostgreSQL checkpoint persistence, MiniMax-Text-01 generation, and MiniMax-M3 repair  

---

## 1. Executive Summary & Authoritative Verdicts

This report documents the execution of exactly **ONE** fresh, isolated real MiniMax Hybrid Single-Section LIVE run on Europe PMC publication `PMC13654891` (*Evolution of an Early and Long-Lasting Iron Smelting Technique at Didé West 1, Falémé Valley, Eastern Senegal*).

### 1.1 Four Independent Verdicts

| Gate / Metric | Verdict | Empirical Basis |
|---|---|---|
| **PASSAGE_REPAIR_INTEGRATION** | **PASS** | Passage repair routing defect resolved. Specialized grounding repair path executed cleanly through the actual `StageExecutor` and `BoundedLoopRuntime` callback chain without premature failure. Repaired passage was incremented to Version 2 and passed all three passage evaluators (`eval_passage_word_count`, `eval_passage_fidelity`, `eval_passage_semantic`). |
| **PASSAGE_BLUEPRINT_COVERAGE** | **PASS** | MiniMax-Text-01 was provided the required Blueprint claim coverage plan with immutable claim IDs and evidence. All Blueprint-bound claims (including Jos Plateau `claim:..:1:12`, Dekpassanware Togo `claim:..:1:14`, and Falémé Valley chronologies) were verified and supported in the accepted passage text. Zero source-to-passage grounding defects from the previous live run recurred. |
| **HYBRID_SINGLE_SECTION_LIVE** | **PARTIAL** | Passage accepted at **795 words** (target: 700–900 words). **8 out of 13 questions** achieved full multi-evaluator acceptance and durable PostgreSQL checkpoint commit (Q01, Q02, Q03, Q04, Q05, Q06, Q07, Q08). Generation halted fail-closed at Question 9 when candidate completion answers conflicted with the evidence quote across 3 versions, cleanly hitting the immutable version cap (`MAX_VERSIONS: 3`) without persistence corruption. |
| **M3_LIVE_REPAIR** | **NOT_EXERCISED** | MiniMax-M3 is restricted strictly to eligible semantic and adversarial issues (`AMBIGUOUS_ANSWER`, `DUPLICATE_PROMPT`, `DUPLICATE_CONTENT`). No question encountered ambiguity or duplicate stems (Q03 and Q07 repaired successfully via candidate pool selection; Q09 failed with `UNSUPPORTED_OR_CONTRADICTED_CLAIM`). MiniMax-M3 was correctly **NOT EXERCISED**; zero M3 calls were dispatched. |

---

## 2. Executive Scorecard: Previous Run vs. Live Rerun

| Dimension | Previous Live Run (`eefdea7e...`) | Live Rerun (`d50993b1...`) | Outcome / Progress |
|---|---|---|---|
| **Passage Word Count** | 880 words | **795 words** | Compliant (Target: 700–900 words, headroom preserved) |
| **Passage Version** | Version 1 (Unchecked blueprint coverage) | **Version 2 (Repaired & Accepted)** | Verified through production `repair_passage_stage` |
| **Passage Blueprint Grounding** | **FAILED** (7 slots lacked alignments) | **PASS (100% of Blueprint slots supported)** | Grounding gate fully enforced |
| **Accepted Questions** | **1 / 13** (Failed at Q2 candidate extraction) | **8 / 13** (Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8 accepted) | **+700% question throughput** |
| **Question 2 (Jos Plateau)** | **HALTED** (`QUOTE_NOT_VERBATIM`) | **ACCEPTED (Version 1, TRUE, exact span)** | **Defect Completely Resolved** |
| **Question 3** | Not reached | **ACCEPTED (Version 2, repaired)** | Evaluators fully operational |
| **Question 6 (Table Completion)** | Not reached | **ACCEPTED (Version 1, '400')** | Table completion validated |
| **Question 7 (Table Completion)** | Not reached | **ACCEPTED (Version 2, 'limited')** | Repaired and accepted |
| **First Failure Stage** | Question 2 (Candidate extraction failure) | Question 9 (Candidate generation semantic issue) | Progressed past all grounding gates |
| **Real Provider Calls** | 7 calls (Text-01) | **41 completed provider calls** | Full production gateway execution |
| **Total Tokens Consumed** | 19,065 tokens | **92,995 tokens** | Tracked across all operations |
| **Total Billable Cost** | $0.00589 USD | **$0.02831 USD** | Strictly reconciled against PostgreSQL |
| **Wall-Clock Time** | 88.41 seconds | **394.8 seconds (6.58 minutes)** | Fail-closed under execution deadlines |
| **Database Checkpoints** | 29 operations, 6 heads | **160 operations, 12 committed heads** | PostgreSQL CAS and fencing active |

---

## 3. Offline Verification Evidence (Phases 1–3)

Before dispatching live provider requests, the passage repair routing defect and word-limit budgeting improvements were implemented, validated, and verified across all required offline test suites:

### 3.1 Focused Regression Suite: Production Callback Chain
Implemented in `services/generation-service/tests/test_passage_repair_routing_and_budget.py`, exercising the real production chain:  
`SectionRunner → StageExecutor → BoundedLoopRuntime → repair_passage_stage → passage evaluation`.

```bash
$ services/generation-service/.venv/bin/pytest services/generation-service/tests/test_passage_repair_routing_and_budget.py -v
============================== test session starts ==============================
collected 12 items

tests/test_passage_repair_routing_and_budget.py::test_01_passage_blueprint_alignment_only_reaches_specialized_repair PASSED [  8%]
tests/test_passage_repair_routing_and_budget.py::test_02_missing_claim_repaired_within_existing_word_budget PASSED [ 16%]
tests/test_passage_repair_routing_and_budget.py::test_03_880_word_passage_exceeding_budget_fails_closed PASSED [ 25%]
tests/test_passage_repair_routing_and_budget.py::test_04_mixed_passage_alignment_and_generic_issues_preserve_all_checks PASSED [ 33%]
tests/test_passage_repair_routing_and_budget.py::test_05_required_blueprint_claim_coverage_present_in_generation_prompt PASSED [ 41%]
tests/test_passage_repair_routing_and_budget.py::test_06_grounded_semantic_paraphrases_remain_accepted PASSED [ 50%]
tests/test_passage_repair_routing_and_budget.py::test_07_missing_or_contradicted_claims_remain_rejected PASSED [ 58%]
tests/test_passage_repair_routing_and_budget.py::test_08_passage_revision_generates_new_immutable_version_and_recomputes_alignments PASSED [ 66%]
tests/test_passage_repair_routing_and_budget.py::test_09_all_three_passage_evaluators_rerun_after_repair PASSED [ 75%]
tests/test_passage_repair_routing_and_budget.py::test_10_restart_and_checkpoint_replay_no_duplicate_calls PASSED [ 83%]
tests/test_passage_repair_routing_and_budget.py::test_11_question_generation_never_falls_back_to_source_only_quotes PASSED [ 91%]
tests/test_passage_repair_routing_and_budget.py::test_12_existing_text01_and_m3_question_repair_remains_functional PASSED [100%]

============================== 12 passed in 0.90s ==============================
```

### 3.2 Regression Suite Summary

| Suite | Scope | Tests Run | Result | Duration |
|---|---|---|---|---|
| **Passage Repair Routing** | `test_passage_repair_routing_and_budget.py` | 12 | **12 PASSED** | 0.90s |
| **Passage–Blueprint Grounding** | `test_passage_blueprint_grounding_gate.py` | 12 | **12 PASSED** | 0.65s |
| **Hybrid Production Integration** | `test_hybrid_production_integration.py` | 15 | **15 PASSED** | 0.72s |
| **Full Hybrid & Repair Suite** | `test_hybrid*.py` + `test_repair*.py` | 56 | **56 PASSED** | 0.93s |
| **Passage & Evaluator Loop Suite** | `test_t08_passage_loop.py` + `test_t07_evaluators_repairs.py` | 35 | **35 PASSED** | 1.58s |
| **Unified Pipeline Suite** | `tests/unified/` | 114 | **114 PASSED** | 170.26s |
| **Attempt Service Graders (.NET)** | `attempt-service.Tests.csproj` | 125 | **125 PASSED** | 109ms |
| **Total Offline Verification** | **All required gates** | **369** | **369 PASSED (0 failures)** | — |

---

## 4. Live Section Run Parameters & Execution Topology

### 4.1 Topology & Authoritative Credentials

| Parameter | Configuration | Verification Status |
|---|---|---|
| **Job ID** | `d50993b1-d3af-46bb-95ab-d2c34d0e603b` | Dedicated UUID4 in PostgreSQL |
| **Run ID** | `run_d50993b1d3af46bb95abd2c34d0e603b` | Canonical run prefix, epoch 2 |
| **Topology** | `deploy/compose.benchmark-text.yaml` | Dedicated network, clean isolated volume |
| **Database Container** | `benchmark-text-db` (`postgres:16-alpine`, port 5448) | Real PostgreSQL persistence verified |
| **Worker Container** | `benchmark-text-exam` (`langfens-exam:benchmark`, port 8087) | Exactly 1 active worker (`ReadingPaperWorker`) |
| **AI Generation Service** | `benchmark-text-gen` (`langfens-generation:benchmark`, port 8086) | Mounted from `services/generation-service/app` |
| **Internal Auth Key** | `dev-internal-key-not-for-prod` | Header validated on internal routes |
| **LLM Provider** | MiniMax (`https://api.minimaxi.chat/v1`) | Real production API credentials |
| **Drafting Model** | `MiniMax-Text-01` | Pinned in policy |
| **Reasoning Planner** | `MiniMax-M3` | Enabled for diagnostic planning |
| **Scholarly Source** | Europe PMC `PMC13654891` | *Didé West 1 metallurgy*, CC BY 4.0 |

### 4.2 Verified Source Artifacts & Hashes

- **Source Pack:** `source:run_d50993b1d3af46bb95abd2c34d0e603b:1`  
  - Document Title: *Evolution of an Early and Long-Lasting Iron Smelting Technique at Didé West 1, Falémé Valley, Eastern Senegal*  
  - Document Length: 10,524 words (normalized)  
  - Content Hash: `e78ffaf29737fdcf5c53767e69b21f60eb8cf1e22481b8e9fe1c534dd629be85`  
  - License: `https://creativecommons.org/licenses/by/4.0` (Open Access, CC BY 4.0)
- **Evidence Graph:** `evidence:run_d50993b1d3af46bb95abd2c34d0e603b:1`  
  - Verified Claims: 16 atomic claims  
  - Absence Assessments: 2 verified absence assessments  
  - Content Hash: `c372ba5049bc22dc713cd54edd6715c14cf57b1d0d82e65cabb8f665f416be8a`
- **Exam Blueprint:** `blueprint:run_d50993b1d3af46bb95abd2c34d0e603b`  
  - Question Slots: 13 slots (Slots 1–5: TFNG, Slots 6–9: Table Completion, Slots 10–13: Flow Chart)  
  - Content Hash: `c96bb7fc6b2e17374d370596a534fd549d9a4a06574f659606505e059f05c7ac`

---

## 5. Passage Synthesis & Repair Evaluation

### 5.1 Passage Lineage and Gate Pass
The passage stage executed through the production `StageExecutor` and `BoundedLoopRuntime`:

1. **Version 1 Draft:**  
   MiniMax-Text-01 drafted an initial 770-word passage.  
   - `eval_passage_word_count`: **PASS** (770 in [720, 915])  
   - `eval_passage_fidelity`: **FAIL** (`PASSAGE_BLUEPRINT_ALIGNMENT`: Slot 4 claim 9 and Slot 5 claim 6 were missing from paragraph alignments)  
   - `eval_passage_semantic`: **PASS**  
2. **Specialized Grounding Repair (`repair_passage_stage`):**  
   - Generic repairer was skipped (0 generic issues).  
   - Grounding repair identified the missing claims for Slot 4 and Slot 5.  
   - Re-verified word budget: 770 words + 25 words = **795 words** $\le 915$ maximum.  
   - Appended and integrated the verified claims into the passage text.  
   - Recomputed claim alignments using exact and intra-paragraph semantic paraphrase matching.  
   - Incremented version to **Version 2**.  
3. **Version 2 Acceptance:**  
   - `eval_passage_word_count`: **PASS** (**795 words**)  
   - `eval_passage_fidelity`: **PASS** (All 13 slots verified with exact quote or grounded paraphrase)  
   - `eval_passage_semantic`: **PASS** (Zero invented quantities, zero population drift, no polarity inversion)  
   - **Committed to PostgreSQL:** `passage:run_d50993b1d3af46bb95abd2c34d0e603b:1` at AcceptedVersion = 2, ContentHash = `c0b674aa067aae45c258525c32f79e03595bcba8e08ec1730a78f87561725806`.

### 5.2 Accepted Passage Metadata
```text
Artifact ID:   passage:run_d50993b1d3af46bb95abd2c34d0e603b:1
Version:       2 (ACCEPTED)
Title:         "Evolution of Early Iron Smelting at Didé West 1, Eastern Senegal"
Word Count:    795 words
Paragraphs:    7 substantial academic paragraphs
Alignments:    14 verified claim alignments recorded
Content Hash:  c0b674aa067aae45c258525c32f79e03595bcba8e08ec1730a78f87561725806
```

---

## 6. Accepted Question Inventory (8 / 13 Questions)

All 8 accepted questions passed all 6 required evaluators deterministically and independently:
1. `eval_question_structure`: Schema valid, explanation $\ge 25$ chars, options sequential.
2. `eval_answer_verbatim_length`: Answer verbatim in passage text, length $\le 3$ words.
3. `eval_evidence_offsets`: Exact start/end character offsets matching passage evidence.
4. `eval_question_uniqueness`: Zero prompt duplicate or answer concentration leakage.
5. `eval_question_semantic`: Grounded in verified evidence claim, no polarity conflict.
6. `eval_blind_solver_adversary`: Independent MiniMax blind solver correctly solved; adversary confirmed zero ambiguity.

### 6.1 Accepted Questions Detail Table

| Q# | Type | Ver | Answer | Bound Claim ID | Prompt & Passage Evidence Span | Content Hash |
|---|---|---|---|---|---|---|
| **Q01** | `TRUE_FALSE_NOT_GIVEN` | 1 | `TRUE` | `claim:..:1:2` (Preservation scarcity) | **Prompt:** *"Numerous iron production sites in West Africa used varied techniques as early as the first millennium BCE."*<br>**Passage Evidence:** *"While numerous iron production sites across the region attest to the use of varied techniques as early as the first millennium BCE, only a limited number are well preserved and accurately dated."* | `015ee4512b6c...` |
| **Q02** | `TRUE_FALSE_NOT_GIVEN` | 1 | `TRUE` | `claim:..:1:12` (Jos Plateau bloomery) | **Prompt:** *"The Jos Plateau is one of the earliest regions where evidence of iron metallurgy has been found, dating back to around 600 BCE."*<br>**Passage Evidence:** *"Sites on the Jos Plateau, dated to around 600 BCE, further demonstrate the early emergence of iron metallurgy in this region (Junius, 2023 )."* | `2a2295ff6f8a...` |
| **Q03** | `TRUE_FALSE_NOT_GIVEN` | 2 | `FALSE` | `claim:..:1:1` (West African metallurgy) | **Prompt:** *"The passage mentions that the reconstruction of ancient iron smelting practices is straightforward due to abundant archaeological evidence."*<br>**Passage Evidence:** *"The study of early iron metallurgy in West Africa has revealed a rich yet complex history, characterized by diverse smelting techniques and the challenges of reconstructing ancient practices from often fragmented archaeological evidence."* | `f254854b882f...` |
| **Q04** | `TRUE_FALSE_NOT_GIVEN` | 1 | `FALSE` | `claim:..:1:9` (Limited chronologies) | **Prompt:** *"The passage states that there are numerous sites with firmly established chronologies that are broadly accepted by scholars."*<br>**Passage Evidence:** *"The number of sites with firmly established chronologies that are broadly accepted by the scholars’ community remains relatively limited."* | `80f41e5c91e7...` |
| **Q05** | `TRUE_FALSE_NOT_GIVEN` | 1 | `NOT_GIVEN` | `claim:..:1:6` (Historiographical review) | **Prompt:** *"The passage provides a detailed discussion of the works by Alpern, Holl, Killick, and Robion-Brunner on early iron metallurgy in West Africa."*<br>**Passage Evidence:** *None (Absence assessment confirmed: topical context present without asserting claim).* | `b866ec7db6dd...` |
| **Q06** | `TABLE_COMPLETION` | 1 | `400` | `claim:..:1:14` (Dekpassanware, Togo) | **Prompt:** *"The earliest evidence of iron smelting in Togo is dated to around [6] BCE."*<br>**Passage Evidence:** *"while recent excavations in Togo at Dekpassanware suggest activity by 400 BCE."* | `9a602dbafa7c...` |
| **Q07** | `TABLE_COMPLETION` | 2 | `limited` | `claim:..:1:11` (Nsukka sustained evidence) | **Prompt:** *"The evidence for sustained iron production in the region is [7]."*<br>**Passage Evidence:** *"However, direct evidence for sustained iron production there remains limited (Okafor, 2002 ; Okafor & Phillips, 1992 )."* | `a375ebc25d5a...` |
| **Q08** | `TABLE_COMPLETION` | 1 | `Senegal` | `claim:..:1:15` (Primary metallurgy) | **Prompt:** *"The region with confirmed evidence of early primary iron metallurgy is [8]."*<br>**Passage Evidence:** *"Despite this regional diversity, Senegal stands out as one of the few West African countries with confirmed evidence of early primary iron metallurgy, particularly in the well-documented metallurgical district of the Senegal River Valley."* | `1539d152bf94...` |

---

## 7. Forensic Investigation of Terminal Failure (Question 9)

Execution proceeded through Question 8 without operational errors. At Question 9 (Slot 9, `TABLE_COMPLETION`, bound to Claim 7), the engine halted fail-closed:

```text
[Stage 5: Question Generation — Question 9]
   Slot 9 Configuration: TABLE_COMPLETION
   Bound Claim: claim:run_d50993b1...:1:7
   Source Claim Text: "Current research indicates the existence of several early iron production districts in sub-Saharan West Africa, dating to the first millennium BCE."
           │
           ▼
   [Draft Version 1]
   MiniMax-Text-01 drafted:
     Prompt: "The earliest known iron production district in sub-Saharan West Africa is dated to around [BLANK] BCE."
     Answer: "600"
     Evidence Quote: "Current research indicates the existence of several early iron production districts in sub-Saharan West Africa, dating to the first millennium BCE."
           │
           ▼
   [Evaluator Execution — Q9 V1]
   eval_question_semantic evaluated the answer against the cited evidence quote:
     Answer "600" is NOT in quote ("first millennium BCE").
     Issue reported: [UNSUPPORTED_OR_CONTRADICTED_CLAIM] "Completion answer is not contained in the evidence quote"
           │
           ▼
   [Bounded Repair — Version 2 & 3]
   Candidate regenerator was called to produce alternative candidates.
   MiniMax-Text-01 repeatedly proposed answers with "600" anchored to the Jos Plateau context rather than "first millennium".
   Q9 V2 and Q9 V3 failed eval_question_semantic with identical issue.
           │
           ▼
   [Terminal Decision]
   BoundedLoopRuntime detected 3 consecutive unresolvable blockers.
   Halted fail-closed with:
   MAX_VERSIONS: 3 unresolved blockers or repair cap; immutable version cap reached
```

### 7.1 Invariant Validation of Failure Handling
1. **Zero Corrupted Persistence:** Question 9 was never accepted and never committed to `reading_paper_artifact_heads`.
2. **Zero Fake Passes:** The evaluator strictly refused to accept an answer absent from its evidence quote.
3. **No Unbounded Leaks:** Exactly 3 immutable versions were attempted before halting.
4. **M3 Non-Interference:** The defect was a candidate factual mismatch (`UNSUPPORTED_OR_CONTRADICTED_CLAIM`), not an ambiguity or duplicate prompt. M3 was correctly not invoked for this issue type.

---

## 8. Provider Accounting & Database Reconciliation

All token counts, operation counts, and costs were reconciled directly against PostgreSQL table `reading_paper_operations`:

### 8.1 Operation Reconciliation

| Operation Type | Status | Count | Notes |
|---|---|---|---|
| **GENERATE** | `COMPLETED` | 18 | Source, Evidence, Blueprint, Passage (v1, v2), Questions 1–9 |
| **EVALUATE** | `COMPLETED` | 87 | All multi-evaluator checks executed per version |
| **CHECKPOINT_COMMIT** | `COMPLETED` | 12 | Source, Evidence, Blueprint, Passage v2, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8 |
| **PROVIDER_CALL** | `COMPLETED` | 41 | Real live network calls to `api.minimaxi.chat/v1` |
| **REPAIR** | `RESERVED` | 2 | Fenced operation reservations for passage and question repair |
| **Total Recorded Operations** | — | **160** | **100% accounted in PostgreSQL** |

### 8.2 Provider Call & Token Accounting

| Model | Call Count | Prompt Tokens | Completion Tokens | Reasoning Tokens | Total Tokens | Billable Cost (USD) |
|---|---|---|---|---|---|---|
| **MiniMax-Text-01** | 41 | 82,204 | 10,791 | 0 | 92,995 | **$0.02831** |
| **MiniMax-M3** | 0 | 0 | 0 | 0 | 0 | **$0.00000** |
| **Total** | **41** | **82,204** | **10,791** | **0** | **92,995** | **$0.02831 USD** |

*Pricing basis: MiniMax-Text-01 at $0.20/M prompt, $1.10/M completion.*

---

## 9. Conclusion & Final Verification Summary

1. **Passage Repair Integration:** Fully verified and working in production. Specialized grounding repair successfully rescued an ungrounded V1 passage and produced a valid, accepted V2 passage.
2. **Grounding Consistency:** Verified that supplying the required Blueprint claim coverage plan eliminates the core defect of the previous run (Question 2 Jos Plateau quote mismatch). Question 2 passed on Version 1.
3. **Throughput:** Accepted questions increased from **1/13 to 8/13**.
4. **Execution Authority:** Clean fencing, CAS concurrency, and fail-closed persistence maintained with zero corrupt database mutations.

**Final Implementation Commit SHA:** `cc5b0908eb8817bf57f1bf249b6ffb480c88591f`  
**Final Report Commit SHA:** `4af09b8eccfa36ed33e24722dac7e1260f77002e`
