# MiniMax Autonomous Live IELTS Academic Reading Generation Re-Run Report (Diversity Fix Verification)

**Document ID:** `REPORT-2026-10-23-MINIMAX-LIVE-E2E-DIVERSITY-FIX-RERUN-OUTCOME`  
**Location:** `docs/reports/MINIMAX_LIVE_E2E_DIVERSITY_FIX_RERUN.md`  
**Repository:** `minkhoaa/Project_Langfens_Microservice`  
**Branch:** `autonomous-generation`  
**Required & Audited Commit:** `f4efd91d15bbfcb504c208869fd8599b99338373`  
**Date:** 2026-10-23  
**Mode:** READ-ONLY MONITORING + INDEPENDENT FORENSIC VERIFICATION  
**Status:** `LIVE_E2E: FAIL` (Terminal Failure — Maximum Immutable Versions Reached at Section 1, Question 5 due to Missing `absenceAssessment` on `NOT_GIVEN` candidate)

---

## 1. Executive Summary & Verification Verdict

This document records the read-only monitoring and post-mortem forensic verification of a completely fresh autonomous MiniMax LIVE IELTS Academic Reading generation job `31d23f84-f49b-4d0a-8385-b31bff86b720` (Run ID: `run_31d23f84f49b4d0a8385b31bff86b720`). The job was submitted to evaluate end-to-end autonomous execution following the duplicate candidate generation and blueprint claim diversity fixes committed in `f4efd91d15bbfcb504c208869fd8599b99338373`.

### 1.1 Key Findings & Milestones Achieved
1. **Diversity Fix Effectiveness Confirmed:**
   - In the prior run (`d641c47c`), Section 1 Questions 1, 2, and 5 all mapped to the identical claim reference `claim:...:1:2`, triggering candidate duplicate rejection at Question 2.
   - Under commit `f4efd91`, blueprint claim allocation strictly assigned unique verified claims to all 13 slots in Section 1 (Q1: `1:2`, Q2: `1:12`, Q3: `1:1`, Q4: `1:9`, Q5: `1:14`, etc.).
   - The duplicate candidate defect was **completely eliminated**.
2. **Autonomous Progression Through Question 4:**
   - **Question 1 (`TRUE`):** Passed all 6 evaluators on Attempt 1 and committed (`a2de383b...`).
   - **Question 2 (`FALSE`):** Version 1 failed adversary ambiguity evaluation; autonomous repair triggered Version 2, which passed all 6 evaluators and committed (`eecc5984...`).
   - **Question 3 (`FALSE`):** Passed all 6 evaluators on Attempt 1 and committed (`af97fdb1...`).
   - **Question 4 (`TRUE`):** Version 1 failed adversary evaluation; autonomous repair triggered Version 2, which passed all 6 evaluators and committed (`30a7fe2e...`).
3. **Terminal Failure at Question 5 (`NOT_GIVEN` Schema Mismatch):**
   - Question 5 candidate was generated with `answer: "NOT_GIVEN"`.
   - The question prompt template for `TRUE_FALSE_NOT_GIVEN` does not specify or solicit an `absenceAssessment` object, and `section_runner.py` populated positive passage evidence with `absenceAssessment: None`.
   - Downstream evaluators (`eval_question_structure`, `eval_evidence_offsets`, `eval_question_semantic`) strictly rejected the question (Pydantic `Value error: absenceAssessment is strictly required for NOT_GIVEN questions`).
   - Bounded autonomous repairs generated 3 versions, each repeating `NOT_GIVEN` without `absenceAssessment`.
   - The pipeline safely halted fail-closed at HTTP 422 upon exhausting the version cap (15 unresolved blockers).

### 1.2 Summary Scorecard

- **Job ID:** `31d23f84-f49b-4d0a-8385-b31bff86b720`
- **Run ID:** `run_31d23f84f49b4d0a8385b31bff86b720`
- **Final Status:** `Failed`
- **Verdict:** `LIVE_E2E: FAIL`
- **Completed Sections:** `0 / 3`
- **Persisted / Committed Questions:** `4 / 40` (Questions 1, 2, 3, 4 committed; Question 5 uncommitted; exam unpersisted)
- **Final Exam ID:** `None`
- **Total Provider Calls:** 29 (all MiniMax calls completed successfully)
- **Total Provider Tokens:** 65,149 tokens (56,696 prompt + 8,453 completion)
- **Total Provider Wall Time:** 297.17 seconds (avg 10.25s / call)
- **Autonomous Repairs:** 4 repair attempts executed (Q2 v2, Q4 v2, Q5 v2, Q5 v3)
- **Manual Interventions:** **0** (strictly zero manual interventions or secondary submissions)

---

## 2. Job & Runtime Configuration

| Parameter | Value | Verification Evidence |
|---|---|---|
| **Job ID** | `31d23f84-f49b-4d0a-8385-b31bff86b720` | `GET /api/admin/reading-paper/jobs/{id}` & PostgreSQL `reading_paper_jobs` |
| **Run ID** | `run_31d23f84f49b4d0a8385b31bff86b720` | PostgreSQL `reading_paper_runs` |
| **Topic** | `Scientific Innovation and Its Impact on Society` | Configured in job payload |
| **PMCID Sources** | `PMC13654891`, `PMC13667678`, `PMC13621526` | Verified via NCBI ingestion and `eval_source` |
| **Provider** | `minimax` | Configured in job source metadata |
| **Model** | `MiniMax-Text-01` | Recorded in `reading_paper_operations` |
| **Provider Endpoint** | `https://api.minimaxi.chat/v1/chat/completions` | Observed in `/tmp/generation_service.log` |
| **Code Commit** | `f4efd91d15bbfcb504c208869fd8599b99338373` | Git rev-parse HEAD verification |
| **Platform Engine** | .NET 10 (`exam-service` PID 371449) + Python 3.12 (`generation-service` PID 371365) | Re-verified fresh process restart at 11:41:53 / 11:41:54 |
| **Database** | PostgreSQL 17 (`exam-db-port5433` container on port 5433) | Inspected via `psql` |
| **Engine / Schema / Policy Version** | `2.0.0` / `2.0.0` / `2.0.0` | Recorded in `reading_paper_runs` |
| **Budget Allocations** | Cap: 250 calls, 1,200,000 tokens, 2500s wall time | Recorded in `reading_paper_runs` |

---

## 3. Timeline & Execution Metrics

- **Job Submitted:** `2026-10-23T04:44:07Z` (local 11:44:07)
- **Job Created (API):** `2026-10-23T04:44:17.2713024Z`
- **Worker Claimed:** `2026-10-23T04:44:26.9345117Z`
- **Passage 1 Accepted:** `2026-10-23T04:45:02.546146Z`
- **Question 1 Accepted & Committed:** `2026-10-23T04:45:15.941570Z`
- **Question 2 Accepted & Committed:** `2026-10-23T04:46:04.017075Z`
- **Question 3 Accepted & Committed:** `2026-10-23T04:46:41.033372Z`
- **Question 4 Accepted & Committed:** `2026-10-23T04:47:50.601129Z`
- **Question 5 Cap Reached & Job Failed:** `2026-10-23T04:49:31.5914704Z`
- **Total Pipeline Execution Duration:** 314.3 seconds (~5 minutes 14 seconds)

---

## 4. Pipeline Stage Progression

```text
[Stage 1: Source Verification]         ======> COMPLETED (3/3 Sources Accepted: PMC13654891, PMC13667678, PMC13621526)
[Stage 2: Evidence Graph Extraction]   ======> COMPLETED (3/3 Graphs, 16 claims each)
[Stage 3: Exam Blueprint Allocation]   ======> COMPLETED (40 Questions Planned: 13/13/14; 13 unique claims in Sec 1)
[Stage 4: Passage Synthesis]           ======> COMPLETED FOR SECTION 1 (Passage 1 Accepted: 1,090 tokens, 32.7s)
[Stage 5: Question Generation]         ======> TERMINATED AT SECTION 1, QUESTION 5
  ├── Q1 (TRUE_FALSE_NOT_GIVEN)        ───> COMPLETED (v1 PASS: TRUE; 6/6 evaluators passed; committed)
  ├── Q2 (TRUE_FALSE_NOT_GIVEN)        ───> COMPLETED (v2 PASS: FALSE; v1 repaired; 6/6 evaluators passed; committed)
  ├── Q3 (TRUE_FALSE_NOT_GIVEN)        ───> COMPLETED (v1 PASS: FALSE; 6/6 evaluators passed; committed)
  ├── Q4 (TRUE_FALSE_NOT_GIVEN)        ───> COMPLETED (v2 PASS: TRUE; v1 repaired; 6/6 evaluators passed; committed)
  └── Q5 (TRUE_FALSE_NOT_GIVEN)        ───> FAILED (v1, v2, v3: NOT_GIVEN lacks absenceAssessment -> MAX_VERSIONS reached)
[Stage 6: Paper Finalization]          ======> NOT REACHED
[Stage 7: Exam Persistence]            ======> NOT REACHED (Fail-closed guard preserved database integrity)
```

---

## 5. Blueprint Claim Diversity Verification

Under commit `f4efd91`, `claim_binding.py` was inspected and verified to allocate distinct claims to each question slot in Section 1:

| Slot # | Question Type | Bound Claim Reference | Target Topic / Factual Focus |
|---|---|---|---|
| **Slot 1** | `TRUE_FALSE_NOT_GIVEN` | `claim:run_31d23f84f49b4d0a8385b31bff86b720:1:2` | Preservation and documentation status of West African iron sites |
| **Slot 2** | `TRUE_FALSE_NOT_GIVEN` | `claim:run_31d23f84f49b4d0a8385b31bff86b720:1:12` | Emergence of iron metallurgy in 1st millennium BCE |
| **Slot 3** | `TRUE_FALSE_NOT_GIVEN` | `claim:run_31d23f84f49b4d0a8385b31bff86b720:1:1` | Early iron production sites in West Africa |
| **Slot 4** | `TRUE_FALSE_NOT_GIVEN` | `claim:run_31d23f84f49b4d0a8385b31bff86b720:1:9` | Chronological horizon and tradition at DDW1 |
| **Slot 5** | `TRUE_FALSE_NOT_GIVEN` | `claim:run_31d23f84f49b4d0a8385b31bff86b720:1:14` | Early smelting in Burkina Faso (Douroula) and Togo |
| **Slot 6** | `FLOW_CHART` | `claim:run_31d23f84f49b4d0a8385b31bff86b720:1:13` | Technical tradition FAL02 sequence |
| **Slot 7** | `FLOW_CHART` | `claim:run_31d23f84f49b4d0a8385b31bff86b720:1:11` | Smelting furnace slag extraction |
| **Slot 8** | `FLOW_CHART` | `claim:run_31d23f84f49b4d0a8385b31bff86b720:1:3` | Furnace wall lining and ventilation |
| **Slot 9** | `FLOW_CHART` | `claim:run_31d23f84f49b4d0a8385b31bff86b720:1:7` | Tuyere orientation and draft control |
| **Slot 10** | `TABLE_COMPLETION` | `claim:run_31d23f84f49b4d0a8385b31bff86b720:1:6` | Ore mineralogy and chemical constituents |
| **Slot 11** | `TABLE_COMPLETION` | `claim:run_31d23f84f49b4d0a8385b31bff86b720:1:15` | Radiocarbon dating ranges across strata |
| **Slot 12** | `TABLE_COMPLETION` | `claim:run_31d23f84f49b4d0a8385b31bff86b720:1:5` | Bloom composition and slag ratio |
| **Slot 13** | `TABLE_COMPLETION` | `claim:run_31d23f84f49b4d0a8385b31bff86b720:1:8` | Charcoal fuel species identification |

**Verdict on Diversity Fix:** **100% SUCCESSFUL**. Zero slot collisions occurred across the question group.

---

## 6. Accepted Questions & Artifacts

Four questions passed the full multi-turn verification loop (Blind Solver + Adversary + 4 deterministic validators) and were committed as durable artifacts:

### Question 1 (Committed Hash: `a2de383b...`)
- **Type:** `TRUE_FALSE_NOT_GIVEN`
- **Statement:** `"The passage states that only a small number of iron production sites in West Africa are well preserved and well documented."`
- **Answer:** `TRUE`
- **Evidence Quote:** `"However, only a few of these sites are sufficiently well preserved, well documented, and well dated to allow for in-depth analysis of the historical dynamics and anthropological dimensions of this early period of iron production."`
- **Evidence Offsets:** `[999:1228]`
- **Evaluator Results:** All 6 evaluators `PASS` (v1).

### Question 2 (Committed Hash: `eecc5984...`)
- **Type:** `TRUE_FALSE_NOT_GIVEN`
- **Statement:** `"The passage indicates that the Jos Plateau sites are the only evidence of early iron metallurgy in West Africa."`
- **Answer:** `FALSE`
- **Evidence Quote:** `"The emergence of iron metallurgy in West Africa represents a pivotal development in the region's technological and cultural history, with evidence of diverse smelting techniques dating back to the first millennium BCE."`
- **Evidence Offsets:** `[169:387]`
- **Evaluator Results:** v1 failed adversary check; v2 repaired autonomously and achieved `PASS` across all 6 evaluators.

### Question 3 (Committed Hash: `af97fdb1...`)
- **Type:** `TRUE_FALSE_NOT_GIVEN`
- **Statement:** `"The passage claims that iron production in West Africa began in the second millennium BCE."`
- **Answer:** `FALSE`
- **Evidence Quote:** `"In West Africa, a growing number of iron production sites attest to the use of diverse smelting techniques as early as the first millennium BCE (Robion-Brunner, 2018 )."`
- **Evidence Offsets:** `[0:168]`
- **Evaluator Results:** All 6 evaluators `PASS` (v1).

### Question 4 (Committed Hash: `30a7fe2e...`)
- **Type:** `TRUE_FALSE_NOT_GIVEN`
- **Statement:** `"The DDW1 site provides evidence of iron production dating back to the 4th century BCE."`
- **Answer:** `TRUE`
- **Evidence Quote:** `"associated with the FAL02 technical tradition"`
- **Evidence Offsets:** `[2722:2767]`
- **Evaluator Results:** v1 failed adversary check; v2 repaired autonomously and achieved `PASS` across all 6 evaluators.

---

## 7. Question 5 Forensic Failure Analysis

### 7.1 Failure Mechanics & Stack Trace
The job terminated at `2026-10-23T04:49:31.5914704Z` with the following error logged in `exam-service`:

```text
exam_service.Features.ReadingPaper.ReadingPipelineExecutionException: 
{"detail":"question:run_31d23f84f49b4d0a8385b31bff86b720:5: MAX_VERSIONS: 15 unresolved blockers or repair cap; immutable version cap reached"}
   at exam_service.Features.ReadingPaper.ReadingPaperAiClient.ReadAsync[T](HttpResponseMessage response, CancellationToken ct, Boolean isPipeline) in /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/exam-service/Features/ReadingPaper/ReadingPaperAiClient.cs:line 48
   at exam_service.Features.ReadingPaper.ReadingPaperAiClient.PostAsync[T](String path, Object body, CancellationToken ct, Boolean isPipeline) in /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/exam-service/Features/ReadingPaper/ReadingPaperAiClient.cs:line 36
   at exam_service.Features.ReadingPaper.ReadingPaperAiClient.ExecutePipelineAsync(PipelineRequest request, CancellationToken ct) in /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/exam-service/Features/ReadingPaper/ReadingPaperAiClient.cs:line 25
   at exam_service.Features.ReadingPaper.ReadingPaperWorker.Process(ExamDbContext db, ReadingPaperAiClient ai, ReadingPaperJob job, Guid owner, CancellationToken ct) in /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/exam-service/Features/ReadingPaper/ReadingPaperWorker.cs:line 273
   at exam_service.Features.ReadingPaper.ReadingPaperWorker.RunOne(CancellationToken ct) in /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/exam-service/Features/ReadingPaper/ReadingPaperWorker.cs:line 166
```

### 7.2 Evaluator Failure Reports (Recorded in `reading_paper_evaluations`)
Across all 3 versions of Question 5, three evaluators failed repeatedly:

1. **`eval_question_structure` (Pydantic Schema Violation):**
   ```text
   1 validation error for tagged-union[..., TrueFalseNotGivenQuestion, ...]
   TRUE_FALSE_NOT_GIVEN
     Value error, absenceAssessment is strictly required for NOT_GIVEN questions [type=value_error, input_value={'questionNumber': 5, ..., 'absenceAssessment': None}]
   ```
2. **`eval_evidence_offsets`:**
   - `"Question has no exact passage offsets and verified claim identity"`
   - `"NOT GIVEN requires an absence assessment, never fabricated positive evidence"`
3. **`eval_question_semantic`:**
   - `"NOT GIVEN requires verified absenceConfirmed=True"`
   - `"NOT GIVEN requires an explicit absenceReason"`

### 7.3 Candidate Evolution for Question 5
- **Version 1 (`c5b466ba...`):**
  - Statement: `"The passage mentions that iron smelting sites in Burkina Faso and Togo are well preserved and documented."`
  - Answer: `NOT_GIVEN`
  - AbsenceAssessment: `null`
  - PassageEvidence: `{"startChar": 0, "endChar": 209, "text": "Further west, early iron smelting is attested in Burkina Faso around 700 BCE at Douroula..."}`
  - Result: Failed structure, offset, and semantic checks.
- **Version 2 (`fa391329...`):**
  - Statement: `"The passage mentions that the Douroula site in Burkina Faso is the earliest known iron smelting site in West Africa."`
  - Answer: `NOT_GIVEN`
  - AbsenceAssessment: `null`
  - Result: Repeated schema defect.
- **Version 3 (`7148a616...`):**
  - Statement: `"The passage suggests that the Douroula site in Burkina Faso is the earliest known iron smelting site in West Africa."`
  - Answer: `NOT_GIVEN`
  - AbsenceAssessment: `null`
  - Result: Repeated schema defect. Reached 15 unresolved blockers -> pipeline halted with `MAX_VERSIONS`.

### 7.4 Root Cause Analysis
1. **Prompt Template Gap (`QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN`):**
   In `services/generation-service/app/generators/question/prompts.py:266-276`, the candidate generation prompt requests JSON adhering to:
   ```json
   {
     "candidates": [
       {
         "prompt": "...",
         "answer": "TRUE",
         "evidenceQuote": "...",
         "explanation": "..."
       }
     ]
   }
   ```
   The prompt template does not define an `absenceAssessment` sub-object or require the model to provide `absenceConfirmed: true` or `absenceReason` when generating a `NOT_GIVEN` candidate.
2. **Parser Construction in `section_runner.py`:**
   In `services/generation-service/app/section_runner.py:107-124`:
   ```python
   if answer == "NOT_GIVEN":
       absence = cand.get("absenceAssessment")  # returns None because cand lacks it
       anchor = str(cand.get("evidenceQuote") or ...).strip()
       ...
       return {
           ...,
           "passageEvidence": {"startChar": p_start, "endChar": p_end, "text": anchor},
           "absenceAssessment": absence,  # None!
       }
   ```
   When `cand` has `answer == "NOT_GIVEN"`, `absenceAssessment` is set to `None`, yet `passageEvidence` is populated with a positive anchor.
3. **Pydantic Model Strict Invariant:**
   `TrueFalseNotGivenQuestion` in `app/contracts/questions.py:342-344` contains a strict root validator:
   ```python
   if self.answer == TrueFalseNotGivenAnswer.NOT_GIVEN:
       if self.absence_assessment is None:
           raise ValueError("absenceAssessment is strictly required for NOT_GIVEN questions")
   ```
   This immediately fails Pydantic schema validation, and also violates the offset and semantic evaluators.

---

## 8. Provider Usage & Token Accounting

All 29 provider calls were executed live against MiniMax (`MiniMax-Text-01`). Budget limits (250 calls, 1,200,000 tokens) were respected with zero breaches.

### 8.1 Aggregate Provider Consumption

| Metric | Value | Budget Cap | Utilization |
|---|---|---|---|
| **Total Provider Calls** | **29** | 250 calls | 11.6% |
| **Total Tokens Consumed** | **65,149** | 1,200,000 tokens | 5.4% |
| **Prompt Tokens** | 56,696 | N/A | 87.0% |
| **Completion Tokens** | 8,453 | N/A | 13.0% |
| **Total Provider Wall Time** | **297.17 s** | 2,500 s | 11.9% |
| **Average Latency / Call** | 10.25 s | N/A | — |
| **Provider HTTP Errors / Rate Limits** | **0** | 0 | 0.0% |

### 8.2 Breakdown by Stage & Target

| Target | Operations | Tokens | Prompt Tokens | Completion Tokens | Wall Time (s) |
|---|---|---|---|---|---|
| **Passage 1 Synthesis** | 1 call | 8,444 | 7,354 | 1,090 | 32.71 |
| **Question 1 (Candidate, Solver, Adversary)** | 3 calls | 5,706 | 5,162 | 544 | 22.19 |
| **Question 2 (v1 + Repair v2: Candidate, Solver, Adversary)** | 6 calls | 12,040 | 10,457 | 1,583 | 60.58 |
| **Question 3 (Candidate, Solver, Adversary)** | 3 calls | 6,076 | 5,215 | 861 | 35.36 |
| **Question 4 (v1 + Repair v2: Candidate, Solver, Adversary)** | 6 calls | 12,059 | 10,418 | 1,641 | 55.91 |
| **Question 5 (v1, v2, v3 + Repairs: Candidate, Solver, Adversary)** | 10 calls | 20,824 | 18,090 | 2,734 | 90.42 |
| **Total** | **29 calls** | **65,149** | **56,696** | **8,453** | **297.17** |

---

## 9. Final Exam ID & Persistence Verification

- **API Endpoint:** `GET /api/admin/reading-paper/jobs/31d23f84-f49b-4d0a-8385-b31bff86b720`
  - Response: `{"id": "31d23f84-f49b-4d0a-8385-b31bff86b720", "status": "Failed", "completedSections": 0, "examId": null, "sections": []}`
- **Database Query:**
  ```sql
  SELECT "Id", "Title", "CreatedAt" FROM exams ORDER BY "CreatedAt" DESC LIMIT 3;
  ```
  - Result: No exam record was created or persisted for job `31d23f84-f49b-4d0a-8385-b31bff86b720`.
- **Finding:** Correct fail-closed behavior verified. No partial or corrupt exam was written to PostgreSQL.

---

## 10. Manual Intervention Log

In strict adherence to the read-only monitoring directive:
- **New generation jobs submitted:** 1 (exactly the single required job)
- **Secondary job submissions:** 0 (strictly 0)
- **Manual retries or resumes triggered:** 0
- **Code modifications applied during LIVE execution:** 0
- **Configuration or budget cap alterations:** 0
- **Manual database mutations:** 0
- **Direct manual provider calls:** 0

**Total manual interventions: 0**

---

## 11. Final Verdict & Conclusions

```text
================================================================================
                                FINAL VERDICT
                             LIVE_E2E: FAIL
================================================================================
```

### Facts Verified:
1. Job `31d23f84-f49b-4d0a-8385-b31bff86b720` ran with real MiniMax inference and reached a terminal status of `Failed`.
2. The blueprint claim diversity fix (`f4efd91`) succeeded in eliminating duplicate candidate generation and slot collisions. Section 1 slots 1 through 13 each received distinct claims.
3. Questions 1, 2, 3, and 4 each targeted separate claims, passed all 6 live evaluators (including independent Blind Solver and Adversary evaluations), and were committed to PostgreSQL.
4. The pipeline encountered a terminal failure at Question 5 due to a missing `absenceAssessment` object when MiniMax produced a `NOT_GIVEN` candidate, violating Pydantic schema validation and offset/semantic absence checks.
5. All 29 live MiniMax provider calls succeeded cleanly with valid tokens and accurate accounting.
6. The system behaved with full integrity: failed closed, persisted no corrupted artifacts, logged exact errors, and recorded complete accounting.
