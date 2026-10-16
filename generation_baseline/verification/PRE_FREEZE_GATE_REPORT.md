# PRE_FREEZE_GATE_REPORT — RG10 Research-Readiness Blocker Closure & Quality Audit

**Repository:** `Project_Langfens_Microservice`  
**Branch:** `autonomous-generation`  
**Base Source Commit SHA:** `2b19810ff3153bcf4b06fdd9514fe8c1cb98946b`  
**Working Tree Status:** All modifications are uncommitted working-tree changes on top of base commit `2b19810`  
**Host Runtime Environment:** CPython 3.10.12 (Azure Linux x86_64; production container images target Python 3.12)  
**Report Date:** 2026-10-16  
**Final Phase Gate Verdict:** **`HOLD`** (Software verified; Quality & Research gates held pending grammar distractor refinement, human panel, and holdout unsealing)

---

## 1. Executive Summary & The Three Independent Gates

In strict accordance with the RG10 acceptance criteria and research governance, readiness is evaluated across three independent, uncoupled gates:

| Gate | Assessment Standard | Evidence Base | Verdict |
|---|---|---|---|
| **1. SOFTWARE_READY** | Implementation, replay correctness, answer provenance binding, answer-blind review, regression suites | 245 RG10 pytest passed; 73 .NET tests passed; 133 caps passed; 22/22 forensic vs 21/22 behavioral replay reconciled | **`PASS`** |
| **2. QUALITY_READY** | Real generation quality diagnosed; 15/15 terminal answer availability; complete 3-way Reading TFNG coverage; distractor uniqueness & novelty measured on unseen DEV | 2 live MiniMax pilots (V3 & V4); 100% answer availability; verified NOT GIVEN; failure-cause matrix documented; Grammar MCQ pass rate 1/6 (16.7%) | **`HOLD`** |
| **3. RESEARCH_READY** | Uninspected confirmatory holdout sealed; disjoint source families quarantined; human expert review protocol & rubric approved | `CONFIRMATORY_HOLDOUT_SPECIFICATION.md` & `HUMAN_REVIEW_PROTOCOL_AND_RUBRIC.md` published; external panel pending | **`HOLD`** |

**Final Phase Gate Verdict:** **`HOLD`**  
The engine is software-ready. Unfreezing for the final A/B/C campaign or RG11 is strictly held until Grammar MCQ distractor generation is hardened, the external human expert review panel is onboarded, and the uninspected holdout corpus is sealed.

---

## 2. Inventory of Modified and Created Files (17 Files Total)

### Modified Source Files (5)
1. `services/generation-service/app/experiment/runners.py`:
   - Updated `_Run.finish()` to bind every question in `authoritative_answer_provenance` directly to its `question_text`, `question_text_sha256`, `question_content_hash`, `output_response_sha256`, and `status`.
   - Updated `_GENERATION_SYSTEM`, `SELF_CRITIQUE`, and `REVIEWER` prompts to mandate 3-way TFNG balance (explicit NOT GIVEN criteria) and unambiguous MCQ distractors with syntactic defects.
   - Preserved unconditional answer-key scrubbing in `_Run.visible()`.
2. `services/generation-service/app/evaluators/blinded_judge.py`:
   - Enhanced `UncertaintyEscalationProtocol` with Boundary C (comparative direction inversion) and Boundary D (cross-clause factual chimera).
   - Removed hardcoded lexical lookups to preserve honest abstention on linguistic boundaries without memorized answer keys.
3. `generation_baseline/tools/replay_quality_dev_hardening.py`:
   - Enhanced `ReplayExperimentClient` with stable `operation_id` matching, pipeline interleave sequence resolution, and fail-closed strict ambiguity mode.
   - Separated `run_historical_forensic_replay()` (22/22 records) from `run_behavioral_reexecution()` (21/22 records).
   - Made publication to `generation_baseline/verification/` opt-in (`publish_to_verification=False` by default).
   - Dynamically computes question denominators instead of hardcoding `15`.
4. `services/generation-service/tests/test_rg10_provider_record_integrity.py`:
   - Unit tests for stable `operation_id` matching and regression verification of forensic (22/22) vs behavioral (21/22) replay separation.
5. `services/generation-service/tests/test_rg10_blinded_semantic_judge.py`:
   - Tests for Item 19 (`COMPARATIVE_DIRECTION_INCONCLUSIVE`) and Item 20 (`CROSS_CLAUSE_CHIMERA_INCONCLUSIVE`).
   - Labeled synthetic test cases as `AUTHOR_WRITTEN_NOT_INDEPENDENT` to prevent false holdout claims.

### New Test and Tool Files (3)
6. `generation_baseline/tools/run_fresh_live_dev.py`:
   - Standalone live DEV experiment runner targeting isolated `.execution/RG10_DEV_FRESH_V3/`. Reads `MINIMAX_API_KEY` securely from `deploy/envs/ai.env` without logging credentials.
7. `generation_baseline/tools/run_unseen_live_dev_pilot.py`:
   - Standalone live DEV pilot runner targeting `.execution/RG10_DEV_UNSEEN_PILOT_V4/` evaluating previously unseen development fixtures (hydrothermal vents + negative adverbial inversion).
8. `services/generation-service/tests/test_rg10_terminal_answer_preservation.py`:
   - Regression suite asserting exact question text, question content hash, and response hash binding; zero draft borrowing; answer-blind review; and arm separation.

### Research Governance & Specification Artifacts (2)
9. `generation_baseline/research/CONFIRMATORY_HOLDOUT_SPECIFICATION.md`:
   - Formal specification of uninspected holdout protocol, reserving 4 disjoint source families (`fam-astrophysics-pulsar-08`, `fam-paleontology-cambrian-09`, `fam-mood-subjunctive-08`, `fam-aspect-participle-09`).
10. `generation_baseline/research/HUMAN_REVIEW_PROTOCOL_AND_RUBRIC.md`:
    - Double-blind human review protocol, 4-dimension 5-point analytic scoring rubric, reviewer qualification criteria, and Cohen's Kappa adjudication workflow.

### Verification Deliverables & Reports (7)
11. `generation_baseline/verification/HISTORICAL_FORENSIC_REPLAY_REPORT.md`: Sealed forensic accounting report covering all 22 original provider records.
12. `generation_baseline/verification/HISTORICAL_FORENSIC_REPLAY_REPORT.json`: Machine-readable forensic dispatch ledger.
13. `generation_baseline/verification/BEHAVIORAL_REEXECUTION_REPORT.md`: Behavioral re-execution report covering 21/22 consumed records.
14. `generation_baseline/verification/FRESH_LIVE_DEV_REPORT.md`: Live DEV report from MiniMax-Text-01 (V3 DEV split).
15. `generation_baseline/verification/FRESH_LIVE_DEV_REPORT.json`: Machine-readable live DEV output (V3).
16. `generation_baseline/verification/UNSEEN_LIVE_DEV_REPORT.md`: Live DEV pilot report on unseen fixtures (V4 DEV split).
17. `generation_baseline/verification/UNSEEN_LIVE_DEV_REPORT.json`: Machine-readable unseen live DEV output (V4).

---

## 3. Actual Test and Verification Evidence

All verification suites were executed from clean working directories:

### A. Python RG10 Regression Suite
```bash
python -m pytest tests/test_rg10_*.py
```
- **Result:** **245 passed in 3.91s** (0 failed).
- All 19 RG10 suites passed, including `test_rg10_accounting_integrity.py` (18), `test_rg10_arm_c_repair_loop.py` (8), `test_rg10_blinded_semantic_judge.py` (8), `test_rg10_evaluator_v2_5_calibration.py` (4), `test_rg10_provider_record_integrity.py` (12), and `test_rg10_terminal_answer_preservation.py` (5).

### B. Core Loop Caps & Runtime Suite
```bash
python -m pytest tests/test_r03_config_caps.py tests/test_r03_runtime_caps.py tests/test_t06_loop_runtime.py
```
- **Result:** **133 passed in 20.79s** (0 failed).

### C. .NET Microservice Suite (Attempt-Service Graders)
```bash
dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj
```
- **Result:** **73 passed in 549ms** (0 failed).

### D. Generation-Service Full Pytest Suite Audit
```bash
python -m pytest -m "not live"
```
- **Result:** **1,040 passed, 33 skipped, 1 failed in 153.67s**.
- **Failure Audit:** The single failed test is `tests/test_t14_harness_integration.py::test_full_phase14_lifecycle_e2e`, which failed on `Npgsql: Failed to connect to 127.0.0.1:5433 (Connection refused)`.
- **Finding:** Environment-dependent integration test requiring a live PostgreSQL daemon. Not a code regression. Local database was deliberately not started to preserve schema isolation per repo invariants.
- **Runtime Note:** Local verification executed under host CPython 3.10.12. Production container images target Python 3.12.

---

## 4. Historical Forensic Replay vs. Current Behavioral Re-execution

| Dimension | Historical Forensic Replay | Current Behavioral Re-execution | Delta / Explanatory Finding |
|---|---|---|---|
| **Raw Provider Dispatches** | 22 / 22 calls (100%) | 21 / 22 calls (95.5%) | 1 skipped call (`research-REVIEWER-8`) |
| **Unconsumed Records** | 0 records | 1 record (`research-REVIEWER-8_...`) | Bypassed: repair candidate lacked proposed answers |
| **Tokens Consumed** | 23,886 tokens (EXACT) | 23,191 tokens (EXACT) | Difference equals exact 695 tokens of Call 8 |
| **Calculated Provider Spend** | $0.0358 USD | $0.0348 USD | -$0.0010 USD (`LOCAL_RATE_ESTIMATE_NOT_BILLED`) |
| **Ambiguity Binding** | Strict dispatch sequence | Pipeline interleave / stable op ID | Fail-closed on unprovable duplicates |
| **Questions Evaluated** | 15 items | 15 items | Identical terminal candidate questions |
| **Historical v2.3 PASS/FAIL** | 4 PASS / 11 FAIL (26.7%) | 4 PASS / 11 FAIL (26.7%) | Exact reproducible baseline |
| **Equivalence Status** | Forensic Historical Accounting | Behavioral Execution Graph | Execution graph changed by current validation rules |

---

## 5. Phase B: Real Generation Quality Diagnosis (Fresh MiniMax DEV Run)

Reconstruction and classification of all 15 questions from the initial fresh DEV run (`RG10_DEV_FRESH_V3`):
- Completed assignments: 5/6 (83.33%).
- Terminal answer keys available: 15/15 (100.0%).
- Evaluator v2.5 Scoring: 6 PASS / 9 FAIL (40.0% pass rate).

### Full Failure-Cause Matrix (9 Rejected Items)

| Item | Domain & Arm | Question Prompt | Proposed Answer | Evaluator Rationale | Failure Category Classification | Explanatory Analysis |
|---|---|---|---|---|---|---|
| 1 | **READING** B-Q1 | *"CAM plants open their stomata at night specifically for the purpose of assimilating atmospheric carbon dioxide."* | `TRUE` | Entailment contradiction: passage contradicts TRUE statement | **Evaluator False Rejection** | Contrastive clause exclusion defect in v2.5: sentence split on *"Unlike standard C3 plants that open stomata during daylight hours"* caused legitimate nocturnal stomata opening assertion to be falsely flagged as contradictory. |
| 2 | **READING** B-Q3 | *"During the day, CAM plants internally release carbon dioxide while keeping their stomata closed to prevent water loss."* | `TRUE` | Entailment contradiction: passage contradicts TRUE statement | **Evaluator False Rejection** | Exactly matches passage (*"while stomata remain firmly closed to minimize transpiration"*), but falsely excluded due to lexical stem overlap with the C3 contrastive clause. |
| 3 | **READING** C-Q1 | *"CAM plants open their stomata at night to absorb carbon dioxide."* | `TRUE` | Entailment contradiction: passage contradicts TRUE statement | **Evaluator False Rejection** | Grounded factual entailment falsely rejected by contrastive clause heuristic. |
| 4 | **READING** C-Q3 | *"CAM plants release carbon dioxide during the day while their stomata remain closed."* | `TRUE` | Entailment contradiction: passage contradicts TRUE statement | **Evaluator False Rejection** | Direct factual paraphrase of passage text falsely rejected by contrastive clause heuristic. |
| 5 | **GRAMMAR** A-Q1 | *"Choose the sentence that correctly uses an it-cleft structure."* | `A` | Tense agreement discord: Present copula 'is' clashes with past relative verb 'surprised' | **Evaluator False Rejection (Rule-Pack Prescriptive Artifact)** | In standard academic English it-clefts, present copula with past relative clause is fully grammatical (*"It is the new findings that surprised the scientific community"* expresses present relevance). The FAIL was driven by an artificial rule-pack exception (*"Tense consistency between copula and cleft clause is mandatory"*), which the evaluator enforced. |
| 6 | **GRAMMAR** B-QQ1 | *"Which of the following sentences correctly uses an it-cleft structure to emphasize 'the research methodology'?"* | `A` | Ambiguous MCQ: multiple options [1, 3] exhibit grammatically valid it-cleft syntax | **Ambiguous Question (Multiple Valid Keys)** | Distractor Option C (*"It was the research methodology that the team has developed"*) is also a grammatically standard it-cleft. Generator failed to make distractors syntactically ungrammatical. |
| 7 | **GRAMMAR** B-QQ2 | *"Which sentence correctly uses an it-cleft structure with proper tense consistency?"* | `D` | Ambiguous MCQ: multiple options [3, 4] exhibit grammatically valid it-cleft syntax | **Ambiguous Question (Multiple Valid Keys)** | Both Option C (present copula + present verb) and Option D (past copula + past verb) exhibit proper tense consistency. Two defensible keys exist. |
| 8 | **GRAMMAR** C-Q1 | *"Which of the following sentences correctly uses an it-cleft structure?"* | `B` | Ambiguous MCQ: multiple options [1, 2, 4] exhibit grammatically valid it-cleft syntax | **Ambiguous Question (Multiple Valid Keys)** | Distractors were standard sentences rather than ungrammatical clefts; multiple options were defensible. |
| 9 | **GRAMMAR** C-Q2 | *"What is the correct way to complete this it-cleft sentence? 'It is the students' dedication ______ makes the program successful.'"* | `A` | Defective cleft MCQ: proposed answer is not a valid it-cleft construction | **Genuine Grammatical Defect (Format Defect)** | Generator emitted single relative pronouns (`that`, `which`, `who`, `what`) instead of complete candidate sentences exemplifying the target structure. |

### Classification Summary of Rejections
- **Evaluator False Rejections:** **5 / 9 (55.6%)** (4 Reading contrastive exclusion false rejections + 1 Grammar copula tense prescriptive artifact).
- **Ambiguous Questions / Multiple Valid Keys:** **3 / 9 (33.3%)** (Distractors were standard English sentences instead of ungrammatical options).
- **Genuine Format / Grammatical Defects:** **1 / 9 (11.1%)** (1 fill-in-the-blank pronoun fragment format violation).
- **Incorrect Generated Answers:** 0 / 9 (0.0%).
- **Reading Polarity Gap Observed:** 5 TRUE, 4 FALSE, 0 NOT GIVEN (Demonstrated severe binary sampling bias in live LLM output).

---

## 6. Phase D: Unseen Live DEV Pilot Results (MiniMax-Text-01)

Executed on 2026-10-16T09:55:36Z against `https://api.minimaxi.chat/v1` via `run_unseen_live_dev_pilot.py` into isolated directory `.execution/RG10_DEV_UNSEEN_PILOT_V4/`:

- **Disjoint Source Families Tested**:
  1. Reading: Deep-sea hydrothermal vent chemosynthesis (`fam-oceanography-abyssal-05`)
  2. Grammar: Negative and restrictive adverbial inversion (`fam-syntax-inversion-05`, `pack-inversion-dev-05`)
- **Assignment Completion:** 6 / 6 assignments completed (100% completion rate).
- **Total Provider Dispatches:** 19 live network calls.
- **Provider Telemetry:** 22,299 total tokens (exact from headers), $0.0334 USD estimated spend (`LOCAL_RATE_ESTIMATE_NOT_BILLED`), 153.7s elapsed wall time.
- **Terminal Answer Availability:** **15 / 15 questions (100.0%)** carry complete, valid proposed answers.
- **Reading Polarity Coverage (Unique Items):**
  - Total Reading Slots: 9. Unique Reading Items: **7**.
  - Unique Item Polarity Distribution: **FALSE = 4, TRUE = 2, NOT GIVEN = 1**.
  - **Complete 3-way TRUE/FALSE/NOT GIVEN coverage achieved.**
  - Verified NOT GIVEN item (Reading Arm C Q3): *"The blood hemoglobin in Riftia pachyptila can bind carbon dioxide."* (Proposed answer: `NOT GIVEN`; Evaluator v2.5: `PASS`; Blind Judge: `PASS`).
  - Reading Evaluator Verdicts: **8 PASS / 1 FAIL** across the 9 slots (6 PASS / 1 FAIL across the 7 unique items; 85.7% unique pass rate).
  - Single Reading Failure (Reading Arm B Q3): Falsely rejected by evaluator on *"FALSE contradiction: passage affirms proposition without contradiction"*, because the text stated blood hemoglobin (not the trophosome) binds oxygen and sulfide.
- **Grammar MCQ Quality (Unique Items):**
  - Total Grammar Slots: 6. Unique MCQs: **5** (Arm A Q1 and Arm C QQ1 were byte-identical across prompt and options).
  - Authentic Evaluator Pass Rate: **1 / 6 (16.7%)** passing across slots (1 / 5 unique passing).
  - Explanatory Finding: 5 items failed because evaluator's `detect_negative_inversion_syntax` matched distractors containing auxiliary-subject word order (e.g. *"Under no circumstances should we to open"*, *"Seldom did he knows"*) as standard inversion, flagging distractor ambiguity (`multiple options [1, 3]`).
  - Measured Example Copies: 3 / 6 (50.0%) flagged by the 30-character prefix match on the target adverbial *"Under no circumstances should "*, which is explicitly sanctioned by the rule pack. Zero items copied the actual autoclave/temperature scenario; true carrier sentence novelty rate is **100.0%** (with prefix heuristic false positive noted).
- **Cross-Arm Convergence Finding:**
  - Arm C generated 2 Reading questions and 1 Grammar MCQ whose text was byte-identical to Arm A's generation. When unguided by explicit diversity penalties, multi-agent review under identical source texts converged to the same high-entailment statements as direct generation.
- **Overall Evaluator Scoring:** **9 PASS / 6 FAIL** (60.0% pass rate across 15 slots; 7/12 or 58.3% pass rate across 12 unique items).

---

## 7. Independent Evaluator Reliability & Holdout Status

### Extended Adversarial Calibration Corpus (n = 23)
- **NeutralEvaluatorV2_5 (Base Heuristic)**:
  - TP = 8, TN = 11, FP = 3, FN = 1.
  - False Acceptance (FP = 3): Item 19 (comparative direction inversion), Item 20 (cross-clause chimera), Item 21 (collective noun that/who cleft ambiguity).
  - False Rejection (FN = 1): Item 18 (legitimate academic paraphrase).
  - FAR = 21.43%, FRR = 11.11%, Accuracy on decided = 82.61%.
- **BlindedSemanticJudgeProtocol (Uncertainty Escalation)**:
  - Items 18, 19, 20, and 21 are escalated to explicit `UNCERTAIN` with grounded rationales.
  - False acceptance on linguistic boundaries is eliminated through honest abstention rather than unverified guessing.
  - Abstention rate: 21.74% (5/23 items escalated to UNCERTAIN). Accuracy on decided items: 100% (18/18).
  - All calibration labels in `EVALUATOR_V2_5_CALIBRATION_CORPUS` remain strictly unchanged.

### Independent Holdout Status & Integrity Blockers
- **`JUDGE_HOLDOUT_CORPUS` (Historical)**: Declared **`RETIRED`** (read and evaluated pre-tuning on 2026-10-16).
- **`FRESH_JUDGE_HOLDOUT_CORPUS_V2`**: Declared **`INSPECTED_EXPLORATORY`** (opened and inspected during DEV calibration on 2026-10-16; cannot serve as sealed confirmatory holdout evidence).
- **In-Sample Metric Disclosure:** All reported v2.5 and judge calibration figures are in-sample development measurements. Claiming they represent independent, unseen control performance is scientifically prohibited.
- **Human Adjudication Panel:** Status remains **`BLOCKED_PENDING_EXTERNAL_PANEL`**. Invariant `verified_human_truth = False` is strictly enforced.

---

## 8. Remaining Gate Blockers & Explicit Verdict

### Remaining Mandatory Blockers
1. **Grammar Distractor Uniqueness & Evaluator Inversion Parsing (Gate 2 Blocker)**:
   - On the negative inversion rule pack, Grammar MCQs achieved only a 16.7% evaluator pass rate (1/6). Distractors containing auxiliary errors were flagged as ambiguous valid inversion by evaluator regexes, and 50% of items copied adverbial triggers from rule pack examples. Grammar generator and evaluator distractor alignment must be hardened before Gate 2 can pass.
2. **Confirmatory Holdout Corpus Unsealing Pending (Gate 3 Blocker)**:
   - Both historical holdout splits are retired or previously inspected.
   - Formal specification published in `CONFIRMATORY_HOLDOUT_SPECIFICATION.md`, reserving 4 disjoint source families (`fam-astrophysics-pulsar-08`, `fam-paleontology-cambrian-09`, `fam-mood-subjunctive-08`, `fam-aspect-participle-09`). Holdout dataset must be sealed cryptographically prior to unfreezing.
3. **External Human Expert Adjudication Panel Pending (Gate 3 Blocker)**:
   - `human_adjudication_panel.status = "BLOCKED_PENDING_EXTERNAL_PANEL"`.
   - Protocol published in `HUMAN_REVIEW_PROTOCOL_AND_RUBRIC.md`. Qualified external examiners must be onboarded before Phase Gate can unfreeze.
4. **Cross-Arm Diversity Enforcement (Quality Blocker)**:
   - In live sampling without explicit inter-arm diversity prompts, Arm C converged on 2 Reading items and 1 Grammar MCQ identical to Arm A. Campaign execution must incorporate per-arm random seeds or diversity directives to ensure architectural divergence.

---

### Final Gate Verdict

$$\mathbf{HOLD}$$

- **Gate 1: SOFTWARE_READY** — **`PASS`**. Replay correctness separated and provable; terminal answer provenance cryptographically bound; answer-blind review enforced; uncertainty escalation verified; 245 regression tests green.
- **Gate 2: QUALITY_READY** — **`HOLD`**. 100% answer availability achieved; 3-way Reading TFNG coverage (including verified NOT GIVEN) demonstrated; but Grammar negative inversion distractor quality and evaluator alignment achieved only 16.7% pass rate (1/6) with 50% example copying.
- **Gate 3: RESEARCH_READY** — **`HOLD`**. Uninspected confirmatory holdout corpus unsealing and external human expert adjudication panel are mandatory prerequisites for final research freeze.
- **Mandatory Directive:** Maintain all working-tree code and verification artifacts. **Do not launch the final paired research campaign or proceed to RG11 automatically.**
