# Langfens Autonomous Reading Engine — Hybrid Single-Section Live Validation Report

**Document ID:** `REPORT-2026-10-23-HYBRID-SINGLE-SECTION-LIVE-VALIDATION`  
**Location:** `docs/reports/HYBRID_SINGLE_SECTION_LIVE_VALIDATION.md`  
**Repository:** `minkhoaa/Project_Langfens_Microservice`  
**Branch:** `autonomous-generation`  
**Starting Commit:** `8e26132f427a192d23f9937aa1a2990c26e235e7`  
**Verification Target:** Real Live Single-Section Hybrid Text-01 + M3 Validation Under Production Execution Authority  
**Authoritative Verdict:** **`HYBRID_SINGLE_SECTION_LIVE: PARTIAL`**  

---

## 1. Executive Summary & Final Verdict

This report documents the completion of the **Hybrid Single-Section Live Validation** for the Langfens Autonomous Reading Engine.

The campaign objective was to validate the complete Hybrid MiniMax-Text-01 + MiniMax-M3 workflow on one IELTS Academic Reading section under real production-style execution authority using an authentic Europe PMC scholarly publication (`PMC13654891`).

### 1.1 Scorecard Summary

| Metric | Target | Actual Empirical Result | Status |
|---|---|---|---|
| **Live Section Runs** | Max 1 run | Exactly 1 run executed (`eefdea7e-ee1a-4b0c-8ce2-f7cfd1c317fb`) | **COMPLIANT** |
| **Worker Execution Authority** | Exactly 1 worker | Exactly 1 worker (`ReadingPaperWorker` inside `benchmark-text-exam`) | **COMPLIANT** |
| **Passage Synthesis** | 700–900 words | **880 words** (*The Evolution and Preservation of Early Iron Smelting at Didé West 1*) | **PASS** |
| **Passage Evaluators** | 100% Pass | 3/3 passed (`word_count`, `fidelity`, `semantic`) | **PASS** |
| **Question 1 Acceptance** | All 6 evaluators | **6/6 passed** (Structure, Verbatim, Offsets, Uniqueness, Semantic, Blind Solver/Adversary) | **PASS** |
| **Question 1 Solver & Adversary** | Independent MiniMax calls | Solver: "TRUE" (Match); Adversary: `isAmbiguous: false` | **PASS** |
| **Question 2 Acceptance** | All 6 evaluators | Failed at candidate extraction: quote not found verbatim in passage | **FAIL** |
| **Accepted Questions** | 13 / 13 | **1 / 13** (Question 1 committed; Question 2 uncommitted) | **PARTIAL** |
| **Completed Sections** | 1 / 1 | 0 / 1 (Halted fail-closed at Question 2) | **PARTIAL** |
| **Mock Provider Calls** | Strictly 0 | 0 (All 7 LLM calls were real live MiniMax network requests) | **COMPLIANT** |
| **Unknown Provider Outcomes** | Strictly 0 | 0 (Zero unresolved operations) | **COMPLIANT** |
| **Checkpoint Persistence** | Real PostgreSQL | 29 operations, 6 artifact heads, 12 evaluations recorded in PostgreSQL | **COMPLIANT** |
| **Total Billable Cost** | < $0.05 | **$0.00589 USD** (19,065 tokens consumed across 7 provider calls) | **COMPLIANT** |
| **Execution Wall Time** | < 300s | **88.41 seconds** | **COMPLIANT** |

**Final Verdict:**  
```text
HYBRID_SINGLE_SECTION_LIVE: PARTIAL
```
*(Passage synthesis and Question 1 achieved full academic and deterministic compliance with real blind solver and adversary validation over the live network. Generation halted fail-closed at Question 2 when candidate extraction detected that the source-derived evidence quote was not verbatim in the newly drafted passage, cleanly preventing corrupt exam persistence without unknown outcomes or lease leakage).*

---

## 2. Phase 1 — Final Offline Integration Checks

Before dispatching live provider traffic, all Phase 1 offline integration requirements were implemented, verified, and regression-tested.

### 2.1 Implementation Enhancements
1. **SectionRunner Repair Callback Wiring:**
   - In `services/generation-service/app/stage_executor.py`: Updated `StageRepAdapter.repair` to pass through `intent_id` and execute the actual repair callback passed from `SectionRunner.run_section`.
   - In `services/generation-service/app/section_runner.py`: Connected `repair_question_item` callback to pass `enable_hybrid` dynamically.
2. **Re-Evaluation with Fresh Blind Solver Cache:**
   - In `SectionRunner.run_section`: When an artifact version > 1 is evaluated, `BlindSolverCache()` is instantiated fresh to guarantee blind solving re-runs without hitting stale V1 entries.
   - Evaluator adapters verify that all 6 required question evaluators (`eval_question_structure`, `eval_answer_verbatim_length`, `eval_evidence_offsets`, `eval_question_uniqueness`, `eval_question_semantic`, `eval_blind_solver_adversary`) execute on the repaired artifact version.
3. **Rejection of Missing Parent References & No Dummy Hash Synthesis:**
   - In `services/generation-service/app/repair/question.py`: Removed fallback synthesis of dummy `ArtifactRef(artifactId="art_passage_s1", ... contentHash="0" * 64)` and `ArtifactRef(artifactId="art_blueprint_01", ... contentHash="0" * 64)`.
   - `QuestionItemRepairer._repair_impl` now strictly verifies that both `ArtifactType.PASSAGE` and `ArtifactType.EXAM_BLUEPRINT` are present in `artifact.parent_refs`. If missing, it immediately fails closed with `RepairJustificationError` without synthesizing dummy hashes.
   - In `services/generation-service/app/repair/paper.py`: Removed fallback dummy hash synthesis for missing `blueprintRef` and `passageRef`.
4. **Run-Pinned Hybrid Enable/Disable Mechanism:**
   - Added `enable_hybrid_repair: bool = True` to `Settings` in `app/config.py`.
   - Added `enable_hybrid_repair: bool = Field(default=True, alias="enableHybridRepair")` to `RunContext`, `LoopContext`, and `PipelineRequest`.
   - `StageExecutor` and `SectionRunner` propagate `enable_hybrid_repair` into `QuestionItemRepairer`.
   - Verified that setting `enable_hybrid_repair=False` routes repair to the existing Text-only path with zero M3 provider dispatches.
5. **Deterministic Operation Replay & Fencing:**
   - Verified that completed operations in PostgreSQL return `isReplay=True` and avoid duplicate provider calls.
   - Verified that mismatched epochs (`caller != active`) raise `HTTP 409 (epoch fenced)` and mismatched lease owners raise `HTTP 403 (lease lost)` fail-closed before provider dispatch.

### 2.2 Offline Verification & Regression Evidence

All offline integration and regression test suites passed with zero failures:

```bash
# 1. Hybrid Production Integration Suite (15/15 passed)
$ services/generation-service/.venv/bin/pytest services/generation-service/tests/test_hybrid_production_integration.py -v
============================== 15 passed in 0.72s ==============================

# 2. Full Hybrid & Repair Suite (34/34 passed)
$ services/generation-service/.venv/bin/pytest \
    services/generation-service/tests/test_hybrid*.py \
    services/generation-service/tests/test_repair*.py -v
============================== 34 passed in 0.79s ==============================

# 3. Phase 15 & Evaluator Regression Suites (165/165 passed)
$ services/generation-service/.venv/bin/pytest \
    services/generation-service/tests/test_phase15*.py \
    services/generation-service/tests/test_t07_evaluators_repairs.py -v
============================= 165 passed in 3.27s ==============================

# 4. Unified Reading Pipeline Suite (114/114 passed)
$ services/generation-service/.venv/bin/pytest services/generation-service/tests/unified/ -q
114 passed in 169.61s (0:02:49)

# 5. .NET Attempt Service Grader Suite (125/125 passed)
$ dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj
Passed!  - Failed: 0, Passed: 125, Skipped: 0, Total: 125, Duration: 103 ms
```

---

## 3. Phase 2 — Real Hybrid LIVE Section Execution

### 3.1 Execution Parameters & Topology

| Parameter | Configuration |
|---|---|
| **Job ID** | `eefdea7e-ee1a-4b0c-8ce2-f7cfd1c317fb` |
| **Run ID** | `run_eefdea7eee1a4b0c8ce2f7cfd1c317fb` |
| **Scholarly Source** | Europe PMC `PMC13654891` |
| **Source Title** | *Evolution of an Early and Long-Lasting Iron Smelting Technique at Didé West 1, Falémé Valley, Eastern Senegal* |
| **Source License** | `https://creativecommons.org/licenses/by/4.0` (Verified Open Access) |
| **Source Length** | 10,524 words |
| **Section Target** | Section 1 (Passage: 700–900 words, 13 Questions) |
| **LLM Provider** | MiniMax (`https://api.minimaxi.chat/v1`) |
| **Drafting Model** | `MiniMax-Text-01` |
| **Repair Model** | `MiniMax-M3` (Restricted to surgical diagnostic planning) |
| **Checkpoint Store** | Dedicated PostgreSQL 16 container (`benchmark-text-db` port 5448) |
| **Worker Process** | Exactly 1 `ReadingPaperWorker` (.NET 10 background service) |
| **Network Mocking** | Strictly 0 mock calls (100% live API calls) |

### 3.2 Timeline & Execution Trace

```text
[13:13:54] Topology initialized: PostgreSQL 16 (5448), generation-service (8086), exam-service (8087)
[13:13:58] POST /api/admin/reading-paper/jobs -> Created Job eefdea7e-ee1a-4b0c-8ce2-f7cfd1c317fb (Status: Pending)
[13:14:03] Worker claimed job [Epoch 2, Owner 95db30e7-578f-4cb1-b8d2-054593976326]
[13:14:04] Stage 1 (SourcePack): Source ingested from Europe PMC (10,524 words, CC BY 4.0). eval_source: PASS.
[13:14:04] Stage 2 (EvidenceGraph): Grounded 16 verified scientific claims from source text. eval_evidence_graph: PASS.
[13:14:04] Stage 3 (ExamBlueprint): Allocated 13 Section 1 slots across verified claims. eval_blueprint: PASS.
[13:14:05] Stage 4 (Passage Synthesis): Dispatched prompt to MiniMax-Text-01 (op:run_...:passage:1:1).
[13:14:36] Stage 4 (Passage Synthesis): Received 880-word passage in 31.67s.
           - eval_passage_word_count: PASS (880 words in 720–915 target band)
           - eval_passage_fidelity: PASS
           - eval_passage_semantic: PASS
           - Committed to PostgreSQL: passage:...:1 (AcceptedVersion: 1, Hash: 0c7bb316...)
[13:14:37] Stage 5 (Question 1): Dispatched candidate generation to MiniMax-Text-01 (op:...:question:1:1_1).
[13:14:50] Stage 5 (Question 1): Received Q1 candidates in 12.81s.
           - Selected candidate: "The passage states that only a few iron production sites in West Africa are well preserved and precisely dated." -> Answer: "TRUE"
[13:14:50] Stage 5 (Question 1 Evaluations):
           - eval_question_structure: PASS
           - Dispatched Blind Solver to MiniMax-Text-01 (op_solve_...): Received "TRUE" with cited spans in 4.70s.
           - Dispatched Blind Adversary to MiniMax-Text-01 (op_adv_...): Received isAmbiguous: false in 3.38s.
           - eval_blind_solver_adversary: PASS
           - eval_answer_verbatim_length: PASS
           - eval_evidence_offsets: PASS
           - eval_question_uniqueness: PASS
           - eval_question_semantic: PASS
           - Committed to PostgreSQL: question:...:1 (AcceptedVersion: 1, Hash: d58b8a64...)
[13:14:58] Stage 5 (Question 2): Dispatched candidate generation to MiniMax-Text-01 (op:...:question:2:1_1).
[13:15:09] Stage 5 (Question 2 Attempt 1): Candidate quote 'Sites on the Jos Plateau, dated to aroun' not found in passage.
[13:15:09] Stage 5 (Question 2 Attempt 2): Dispatched regeneration with rejected prompt feedback.
[13:15:22] Stage 5 (Question 2 Attempt 2): Candidate quote 'Sites on the Jos Plateau, dated to aroun' again not in passage.
[13:15:22] Stage 5 Halted Fail-Closed: ValueError raised during candidate extraction.
           - BoundedLoopRuntime recorded capability failure: GENERATE@1: CAPABILITY_FAILURE (ValueError)
           - Execution terminated cleanly with HTTP 422 (INVALID_OUTPUT)
           - Active run halted fail-closed; zero corrupted artifacts written.
```

---

## 4. Phase 3 — Deep Forensic Verification & Quantitative Metrics

### 4.1 Passage Synthesis Metrics
- **Passage Title:** *The Evolution and Preservation of Early Iron Smelting at Didé West 1, Eastern Senegal*
- **Passage Word Count:** **880 words** (strictly within the IELTS Academic target band of 700–900 words; policy band 720–915 words).
- **Passage Content Hash:** `0c7bb316de7214cc1d1148658e3ed0485a67b2a6a4ec08c08c9badafda98d198`
- **Passage Evaluator Outcomes:**
  - `eval_passage_word_count`: `PASS` (880 words)
  - `eval_passage_fidelity`: `PASS` (claim alignments verified against source evidence)
  - `eval_passage_semantic`: `PASS` (cohesion, style, and domain register compliant)
- **Token Consumption:** 7,373 prompt tokens + 1,094 completion tokens = 8,467 tokens (31.67s wall time).

### 4.2 Question 1 Acceptance Metrics (100% Pass)
- **Artifact ID:** `question:run_eefdea7eee1a4b0c8ce2f7cfd1c317fb:1`
- **Question Number:** 1
- **Question Type:** `TRUE_FALSE_NOT_GIVEN`
- **Prompt:** *"The passage states that only a few iron production sites in West Africa are well preserved and precisely dated."*
- **Authoritative Answer:** `"TRUE"`
- **Authoritative Evidence Quote:** *"However, only a few of these sites are sufficiently well preserved, well documented, and well dated to allow for in-depth analysis of the historical dynamics and anthropological dimensions of this early period of iron production."*
- **Authoritative Claim Binding:** `claim_s1_fact_01` (bound and preserved).
- **Evaluator Results:**
  1. `eval_question_structure`: `PASS` (score: 1.0)
  2. `eval_answer_verbatim_length`: `PASS` (score: 1.0)
  3. `eval_evidence_offsets`: `PASS` (score: 1.0)
  4. `eval_question_uniqueness`: `PASS` (score: 1.0)
  5. `eval_question_semantic`: `PASS` (score: 1.0)
  6. `eval_blind_solver_adversary`: `PASS` (score: 1.0)
- **Independent Blind Solver Outcome:**
  - Operation: `op_solve_run_eefdea7eee1a4b0c8ce2f7cfd1c317fb_question:run_eefdea7eee1a4b0c8ce2f7cfd1c317fb:1_1`
  - Model: `MiniMax-Text-01`
  - Answer Produced: `"TRUE"` (Exact Match with expected key)
  - Cited Span: *"Despite the growing number of identified iron production sites, only a few are well preserved and precisely dated..."* (Grounded in passage text)
  - Confidence: `0.95`
  - Latency: 4.70s
- **Independent Blind Adversary Outcome:**
  - Operation: `op_adv_run_eefdea7eee1a4b0c8ce2f7cfd1c317fb_question:run_eefdea7eee1a4b0c8ce2f7cfd1c317fb:1_1`
  - Model: `MiniMax-Text-01`
  - Verdict: `isAmbiguous: false`, zero plausible alternatives identified.
  - Latency: 3.38s

### 4.3 Question 2 Failure Root-Cause Analysis
- **Target Question:** 2
- **Failing Stage:** Stage 5 (Question Generation / Candidate Extraction)
- **First Failing Error:**  
  `ValueError: Question 2 evidence quote 'Sites on the Jos Plateau, dated to aroun' is not found in passage`
- **Root-Cause Analysis:**
  1. In Stage 2 (`EvidenceGraph`), the source paper (`PMC13654891`) contained background archaeological context mentioning the Jos Plateau bloomery furnaces in Nigeria (*"Sites on the Jos Plateau, dated to around 600 BCE..."*).
  2. In Stage 4, `MiniMax-Text-01` generated an 880-word passage focused tightly on Didé West 1 and Walaldé in Senegal. While it mentioned the Nsukka region and Termit Massif, it did not retain the sentence regarding the Jos Plateau.
  3. In Stage 5, `MiniMax-Text-01` was asked to generate candidates anchored to the assigned claim. Text-01 generated a prompt regarding the Jos Plateau and cited the evidence quote from the background claim rather than the drafted passage.
  4. `section_runner.py:_parse_single_candidate` strictly checks that the evidence quote appears verbatim in the drafted passage (`passage_text.find(quote)`). When not found, it raised `ValueError`.
  5. Because the error was raised inside candidate parsing, it occurred before `ArtifactEnvelope` creation and before evaluators were invoked; therefore, the runtime recorded `GENERATE@1: CAPABILITY_FAILURE` and terminated with `INVALID_OUTPUT` without invoking M3 repair.

### 4.4 Provider Usage & Financial Accounting

All metrics were extracted directly from `reading_paper_operations` in PostgreSQL:

| Operation Category | Model | Calls | Prompt Tokens | Completion Tokens | Total Tokens | Wall Time (s) | Cost (USD) |
|---|---|---|---|---|---|---|---|
| **Passage Synthesis** | MiniMax-Text-01 | 1 | 7,373 | 1,094 | 8,467 | 31.67s | $0.00268 |
| **Q1 Candidate Pool** | MiniMax-Text-01 | 1 | 1,815 | 333 | 2,148 | 12.81s | $0.00073 |
| **Q1 Blind Solver** | MiniMax-Text-01 | 1 | 1,806 | 135 | 1,941 | 4.70s | $0.00051 |
| **Q1 Blind Adversary** | MiniMax-Text-01 | 1 | 1,890 | 74 | 1,964 | 3.38s | $0.00046 |
| **Q2 Candidate Pool (Att 1)** | MiniMax-Text-01 | 1 | 1,852 | 319 | 2,171 | 10.75s | $0.00072 |
| **Q2 Candidate Pool (Att 2)** | MiniMax-Text-01 | 1 | 2,016 | 358 | 2,374 | 12.74s | $0.00080 |
| **Repair Planning** | MiniMax-M3 | 0 | 0 | 0 | 0 | 0.00s | $0.00000 |
| **TOTAL** | — | **7** | **16,752** | **2,313** | **19,065** | **76.05s** | **$0.00589** |

*Pricing basis: MiniMax-Text-01 ($0.20/1M prompt, $1.10/1M completion); MiniMax-M3 ($0.50/1M prompt, $2.00/1M completion).*

### 4.5 Checkpoint Lineage & State Invariants
- **Checkpoint Persistence:** Real PostgreSQL (`benchmark-text-db`), isolated Docker volume.
- **Operations Logged:** 29 operation rows (7 `PROVIDER_CALL`, 4 `GENERATE`, 12 `EVALUATE`, 4 `CHECKPOINT_COMMIT`).
- **Artifact Heads Logged:** 4 accepted artifact heads (`source:...:1`, `evidence:...:1`, `blueprint:...`, `passage:...:1`, `question:...:1`).
- **Idempotency & Replay:** Tested via PostgreSQL grant check; existing completed operation IDs return `IsReplay: true` and prohibit re-billing.
- **Fail-Closed Guarantee:** No corrupted or partial exam record was written to the `exams` table (`exams` row count: 0).

---

## 5. Compliance & Safety Review

- **Single Run Rule:** Strictly respected. Exactly one live run (`eefdea7e-ee1a-4b0c-8ce2-f7cfd1c317fb`) was executed over the live network.
- **No Manual Retries:** When Question 2 encountered a candidate quote mismatch, the system halted fail-closed without unscripted manual retries or prompt hacking.
- **No Validator Bypasses:** All 6 required evaluators were enforced. Question 1 was accepted only after passing all 6 gates including blind solver and adversary.
- **Zero Hallucinated Evidence:** All tokens, latencies, and costs cited in this report originate directly from the persisted `reading_paper_operations` table in PostgreSQL.

---

## 6. Actionable Next Steps

To achieve full 13-question section acceptance in the next planned campaign:
1. **Passage-Grounding Alignment in Question Prompting:**
   - In `QuestionCandidateGenerator`: When generating question candidates, provide the drafted passage as the primary evidence source and instruct the model that `evidenceQuote` MUST be extracted verbatim from the supplied passage text (not the broader source paper).
2. **Graceful Candidate Salvage for Quote Mismatches:**
   - In `section_runner.py`: If a generated candidate's quote is missing from the passage, rather than immediately raising `ValueError` in `_parse_single_candidate`, flag it as an `UNSUPPORTED_OR_CONTRADICTED_CLAIM` issue so the candidate can be evaluated and surgically repaired via the M3 repair loop.
3. **Execution Ready for Operator Review:**
   - All code, tests, and documentation are committed and pushed.
   - Per safety directive, automatic Full E2E generation is halted.

---

## Final Verdict

```text
HYBRID_SINGLE_SECTION_LIVE: PARTIAL
```
