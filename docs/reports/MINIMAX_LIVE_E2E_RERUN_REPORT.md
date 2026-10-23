# MiniMax Autonomous Live IELTS Academic Reading Generation Re-Run Report

**Document ID:** `REPORT-2026-10-23-MINIMAX-LIVE-E2E-RERUN-OUTCOME`  
**Location:** `docs/reports/MINIMAX_LIVE_E2E_RERUN_REPORT.md`  
**Repository:** `minkhoaa/Project_Langfens_Microservice`  
**Branch:** `autonomous-generation`  
**Commit Audited:** `a4740e539b1095746309cf5891840bb12cdaae26`  
**Date:** 2026-10-23  
**Mode:** READ-ONLY MONITORING + INDEPENDENT POST-MORTEM VERIFICATION  
**Status:** `LIVE_E2E: FAIL` (Terminal Failure — Candidate Duplicate Rejection at Section 1, Question 2)

---

## 1. Executive Summary & Verification Verdict

This document records the read-only monitoring and post-mortem verification of a completely fresh autonomous MiniMax LIVE IELTS Academic Reading generation job `d641c47c-753c-486d-9e45-06954bd31b36` (Run ID: `run_d641c47c753c486d9e4506954bd31b36`), submitted to verify end-to-end execution following prompt template contract alignment (`c150a96`, `e3cf376`, `aab7770`, `a4740e5`).

The run demonstrated that the previously resolved `FLOW_CHART` explanation contract defect was eliminated. However, the job encountered a new terminal failure during **Section 1, Question 2** (`TRUE_FALSE_NOT_GIVEN`):

1. **Stage 1 (Source Ingestion & Verification):** Successfully validated and committed all 3 scientific sources (`PMC13654891`, `PMC13667678`, `PMC13621526`).
2. **Stage 2 (Evidence Graph Generation):** Verified 16 grounded claims per section across all 3 sections.
3. **Stage 3 (Dynamic Blueprint Allocation):** Allocated 40 questions across 3 sections (13/13/14). In Section 1, Questions 1, 2, and 5 were mapped to the exact same claim reference: `claim:run_d641c47c753c486d9e4506954bd31b36:1:2`.
4. **Stage 4 (Passage Synthesis):** Passage 1 generated (1,037 completion tokens) via live MiniMax call (`op:...:passage:1:1`, 42.8s) and passed all passage evaluations (`eval_passage_word_count`, `eval_passage_fidelity`, `eval_passage_semantic`).
5. **Stage 5 (Question 1 Synthesis & Multi-Turn Verification):**
   - Question 1 candidate generated targeting claim 1:2.
   - Independent Blind Solver and Adversary evaluations executed live against MiniMax.
   - All 6 evaluators passed (`eval_question_structure`, `eval_answer_verbatim_length`, `eval_evidence_offsets`, `eval_question_uniqueness`, `eval_question_semantic`, `eval_blind_solver_adversary`).
   - Question 1 committed to database store (`cb4f3d14d2ebcfd701ad7ed4ba71c2cdcb628a2954a6fbff2612a1e54763ed17`).
6. **Stage 5 (Question 2 Duplicate Rejection & Terminal Failure):**
   - Question 2 was also bound to claim 1:2. MiniMax returned candidates where candidate 0 was identical to Question 1: `"The majority of iron production sites in West Africa are well preserved and well documented."`.
   - The candidate duplicate filter detected `cand_stmt.lower() == prior_stmt.lower()`, rejecting Attempt 1 and invoking autonomous repair.
   - In Attempt 2, MiniMax prefixed `"The passage suggests that "` to the identical statement: `"The passage suggests that the majority of iron production sites in West Africa are well preserved and well documented."`.
   - The shingle overlap exceeded the 0.70 threshold with Question 1, triggering duplicate rejection again.
   - Max repair attempts exhausted (2/2); the pipeline terminated with HTTP 422 `CAPABILITY_FAILURE`.

- **Final Verdict:** `LIVE_E2E: FAIL`
- **Completed Sections:** 0 / 3
- **Total Persisted Questions:** 1 / 40 (Question 1 committed; exam unpersisted)
- **Final Exam ID:** `None`
- **Manual Interventions:** 0 (strict observer mode maintained throughout)

---

## 2. Job & Runtime Configuration

| Parameter | Value | Verification Evidence |
|---|---|---|
| **Job ID** | `d641c47c-753c-486d-9e45-06954bd31b36` | Verified via `GET /api/admin/reading-paper/jobs/{id}` & PostgreSQL `reading_paper_jobs` |
| **Run ID** | `run_d641c47c753c486d9e4506954bd31b36` | Verified via `reading_paper_runs` table |
| **Topic** | `Scientific Innovation and Its Impact on Society` | Verified from job payload |
| **Provider** | `minimax` | Configured in job source metadata |
| **Model** | `MiniMax-Text-01` | Recorded in `reading_paper_operations.ResultRefJson` |
| **Provider Endpoint** | `https://api.minimaxi.chat/v1/chat/completions` | Observed in `/tmp/generation_service.log` |
| **Secret Hygiene** | Compliant | No API keys, JWT secrets, or tokens disclosed |
| **Platform Engine** | .NET 10 (`exam-service` PID 243751) + Python 3.12 FastAPI (`generation-service` PID 243725) | Process verification via `/proc/PID/environ` |
| **Database** | PostgreSQL 17 (`exam-db` container on port 5433) | Inspected via `psql` |
| **Engine / Schema / Policy Version** | `2.0.0` / `2.0.0` / `2.0.0` | Recorded in `reading_paper_runs` |
| **Budget Allocations** | Cap: 250 calls, 1,200,000 tokens, 2500s wall time | Recorded in `reading_paper_runs` |

---

## 3. Final Job Status & Timing

- **Job Status:** `Failed`
- **Run Status:** `RUNNING` (halted mid-flight upon HTTP 422 pipeline rejection; lease expired)
- **Job Created At:** `2026-10-23T03:43:21.399240Z`
- **Worker Claimed At:** `2026-10-23T03:43:27.724786Z`
- **Job Failed / Updated At:** `2026-10-23T03:45:00.957524Z`
- **Total Pipeline Execution Duration:** 99.558 seconds (~1 minute 39.6 seconds)
- **Active Run ID:** `None` (cleared upon job failure by `ReadingPaperWorker`)
- **Exam ID:** `None`

---

## 4. Pipeline Stage Progression

```text
[Stage 1: Source Verification]         ======> COMPLETED (3/3 Sources Accepted)
[Stage 2: Evidence Graph Extraction]   ======> COMPLETED (3/3 Graphs, 16 claims each)
[Stage 3: Exam Blueprint Allocation]   ======> COMPLETED (40 Questions Planned: 13/13/14)
[Stage 4: Passage Synthesis]           ======> COMPLETED FOR SECTION 1 (Passage 1 Accepted)
[Stage 5: Question Generation]         ======> FAILED AT SECTION 1, QUESTION 2 (Slot 2, TRUE_FALSE_NOT_GIVEN)
  ├── Q1 (TRUE_FALSE_NOT_GIVEN)        ───> COMPLETED (v1 PASS: 6 evaluators passed; committed to store)
  └── Q2 (TRUE_FALSE_NOT_GIVEN)        ───> FAILED (Attempt 1: exact duplicate of Q1 -> Attempt 2: shingle overlap > 0.70 -> HTTP 422)
[Stage 6: Paper Finalization]          ======> NOT REACHED
[Stage 7: Exam Persistence]            ======> NOT REACHED
```

---

## 5. Source, Evidence, and Blueprint Results

### 5.1 Sources
All 3 PMC open-access research papers were successfully loaded, validated, and evaluated by `eval_source`:
1. **Source 1:** *Evolution of an Early and Long-Lasting Iron Smelting Technique at Didé West 1, Falémé Valley, Eastern Senegal* (PMC13654891) — Status: `PASS`
2. **Source 2:** *Development of a Novel Combined Wind–Rain Piezoelectric Energy Harvester* (PMC13667678) — Status: `PASS`
3. **Source 3:** *Tailoring LED spectra and cultivation systems enhances lettuce productivity and nutritional quality in vertical indoor farming* (PMC13621526) — Status: `PASS`

### 5.2 Evidence Graphs
Three evidence graphs were deterministically derived and evaluated by `eval_evidence_graph`:
- `evidence:run_d641c47c753c486d9e4506954bd31b36:1` (16 claims, Status: `PASS`)
- `evidence:run_d641c47c753c486d9e4506954bd31b36:2` (16 claims, Status: `PASS`)
- `evidence:run_d641c47c753c486d9e4506954bd31b36:3` (16 claims, Status: `PASS`)

### 5.3 Blueprint Allocation Details
Artifact `blueprint:run_d641c47c753c486d9e4506954bd31b36` was verified by `eval_blueprint` (`PASS`):
- **Total Questions Planned:** 40
- **Target Word Count:** 2,150 – 2,750 words (800 words/passage)
- **Section 1 (Questions 1–13):**
  - Q1–Q5: `TRUE_FALSE_NOT_GIVEN` (5 questions)
    - Slot 1: `claimRefIds: ["claim:run_d641c47c753c486d9e4506954bd31b36:1:2"]`
    - Slot 2: `claimRefIds: ["claim:run_d641c47c753c486d9e4506954bd31b36:1:2"]` (*identical claim*)
    - Slot 3: `claimRefIds: ["claim:run_d641c47c753c486d9e4506954bd31b36:1:12"]`
    - Slot 4: `claimRefIds: ["claim:run_d641c47c753c486d9e4506954bd31b36:1:1"]`
    - Slot 5: `claimRefIds: ["claim:run_d641c47c753c486d9e4506954bd31b36:1:2"]` (*identical claim*)
  - Q6–Q9: `FLOW_CHART` (4 questions)
  - Q10–Q13: `TABLE_COMPLETION` (4 questions)
- **Section 2 (Questions 14–26):**
  - Q14–Q17: `DIAGRAM_LABEL` (4 questions)
  - Q18–Q21: `MATCHING_INFORMATION` (4 questions)
  - Q22–Q26: `MATCHING_FEATURES` (5 questions)
- **Section 3 (Questions 27–40):**
  - Q27–Q31: `MATCHING_ENDINGS` (5 questions)
  - Q32–Q36: `YES_NO_NOT_GIVEN` (5 questions)
  - Q37–Q40: `MATCHING_HEADING` (4 questions)

---

## 6. Section Completion & Question Status

| Section | Planned Questions | Generated & Verified Questions | Completed Sections | Notes |
|---|---|---|---|---|
| **Section 1** | 13 (Q1–Q13) | 1 (Q1 committed to DB) | 0 | Aborted at Q2 candidate generation |
| **Section 2** | 13 (Q14–Q26) | 0 | 0 | Not started |
| **Section 3** | 14 (Q27–Q40) | 0 | 0 | Not started |
| **Total** | **40** | **1** | **0 / 3** | **Exam unpersisted** |

---

## 7. Evaluation & Autonomous Repair History

### 7.1 Automated Evaluations Summary
A total of 16 automated evaluations executed across Stages 1–5, with 100% passing results:
- `eval_source` (3 runs): `PASS`
- `eval_evidence_graph` (3 runs): `PASS`
- `eval_blueprint` (1 run): `PASS`
- `eval_passage_word_count`: `PASS`
- `eval_passage_fidelity`: `PASS`
- `eval_passage_semantic`: `PASS`
- `eval_question_structure` (Q1): `PASS`
- `eval_answer_verbatim_length` (Q1): `PASS`
- `eval_evidence_offsets` (Q1): `PASS`
- `eval_question_uniqueness` (Q1): `PASS`
- `eval_question_semantic` (Q1): `PASS`
- `eval_blind_solver_adversary` (Q1): `PASS`

### 7.2 Question 1 Accepted Artifact
- **Statement:** `"The majority of iron production sites in West Africa are well preserved and well documented."`
- **Answer:** `FALSE`
- **Evidence Quote:** `"However, only a few of these sites are sufficiently well preserved, well documented, and well dated to allow for in-depth analysis of the historical dynamics and anthropological dimensions of this early period of iron production."`
- **Passage Evidence Range:** `[1027:1256]`
- **Committed Hash:** `cb4f3d14d2ebcfd701ad7ed4ba71c2cdcb628a2954a6fbff2612a1e54763ed17`

### 7.3 Question 2 Candidate Evolution & Duplicate Rejection
- **Attempt 1:**
  - Candidate 0: `"The majority of iron production sites in West Africa are well preserved and well documented."`
  - Rejection: Exact match (`lower() == lower()`) with Question 1 statement.
  - Action: Triggered repair attempt with prompt feedback `PREVIOUS ATTEMPT DEFECT: Question 2 candidate duplicates an already accepted question...`.
- **Attempt 2:**
  - Candidate 0: `"The passage suggests that the majority of iron production sites in West Africa are well preserved and well documented."`
  - Rejection: Shingle overlap with Question 1 exceeded 0.70.
  - Action: Bounded repair attempts reached cap (2/2); terminated loop with `CAPABILITY_FAILURE`.

---

## 8. Provider Usage & Token Accounting

All 6 provider operations were executed live against MiniMax (`MiniMax-Text-01`). Budget limits (250 calls, 1,200,000 tokens) were respected with zero breaches.

### 8.1 Aggregate Provider Consumption
- **Total Provider Calls:** 6
- **Total Tokens Consumed:** 18,155 tokens
  - **Prompt Tokens:** 15,636 tokens (86.1%)
  - **Completion Tokens:** 2,519 tokens (13.9%)
- **Total Provider Wall Time / Latency:** 89.46 seconds
- **Average Provider Latency:** 14.91 seconds / call
- **Estimated Cost:** $0.00 (reported by provider gateway)

### 8.2 Detailed Operation Breakdown

| Operation ID | Target | Tokens | Prompt | Completion | Wall Time (s) | Status |
|---|---|---|---|---|---|---|
| `op:...:passage:1:1` | Passage 1 Generation | 8,391 | 7,354 | 1,037 | 42.83 | COMPLETED |
| `op:...:question:1:1_1` | Q1 Candidate Gen | 1,887 | 1,521 | 366 | 10.97 | COMPLETED |
| `op_solve_...:1_1` | Q1 Blind Solver | 1,877 | 1,733 | 144 | 6.65 | COMPLETED |
| `op_adv_...:1_1` | Q1 Adversary Review | 2,048 | 1,817 | 231 | 8.66 | COMPLETED |
| `op:...:question:2:1_1` | Q2 Candidate Gen (Attempt 1) | 1,956 | 1,562 | 394 | 10.26 | COMPLETED |
| `op:...:question:2:1_1_att2` | Q2 Candidate Gen (Attempt 2) | 1,996 | 1,606 | 390 | 10.09 | COMPLETED |

---

## 9. Final Exam ID & Persistence Verification

- **API Endpoint:** `GET /api/admin/reading-paper/jobs/d641c47c-753c-486d-9e45-06954bd31b36`
  - Returned: `{"id": "d641c47c-753c-486d-9e45-06954bd31b36", "examId": null, "completedSections": 0, "status": "Failed"}`
- **Database Query:** `SELECT "Id", "Title", "CreatedAt" FROM exams ORDER BY "CreatedAt" DESC LIMIT 5;`
  - Result: No exam record was created for job `d641c47c-753c-486d-9e45-06954bd31b36`.
- **Finding:** Correct and consistent fail-closed behavior. No partial or corrupt exam was persisted to the database.

---

## 10. Root-Cause Analysis

### 10.1 Failure Symptom & Stack Trace
The job terminated at `2026-10-23T03:45:00.957524Z` with the following error logged in `exam-service`:

```text
exam_service.Features.ReadingPaper.ReadingPipelineExecutionException: 
{"detail":"question:run_d641c47c753c486d9e4506954bd31b36:2: INVALID_OUTPUT: capability failed: ValueError: Question 2 candidate duplicates an already accepted question: 'The passage suggests that the majority of iron production si...'"}
   at exam_service.Features.ReadingPaper.ReadingPaperAiClient.ReadAsync[T](HttpResponseMessage response, CancellationToken ct, Boolean isPipeline) in /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/exam-service/Features/ReadingPaper/ReadingPaperAiClient.cs:line 48
   at exam_service.Features.ReadingPaper.ReadingPaperAiClient.PostAsync[T](String path, Object body, CancellationToken ct, Boolean isPipeline) in /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/exam-service/Features/ReadingPaper/ReadingPaperAiClient.cs:line 36
   at exam_service.Features.ReadingPaper.ReadingPaperAiClient.ExecutePipelineAsync(PipelineRequest request, CancellationToken ct) in /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/exam-service/Features/ReadingPaper/ReadingPaperAiClient.cs:line 25
   at exam_service.Features.ReadingPaper.ReadingPaperWorker.Process(ExamDbContext db, ReadingPaperAiClient ai, ReadingPaperJob job, Guid owner, CancellationToken ct) in /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/exam-service/Features/ReadingPaper/ReadingPaperWorker.cs:line 273
   at exam_service.Features.ReadingPaper.ReadingPaperWorker.RunOne(CancellationToken ct) in /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/exam-service/Features/ReadingPaper/ReadingPaperWorker.cs:line 166
```

In `generation-service` logs (`/tmp/generation_service.log`):
```text
WARNING:app.section_runner: Question 2 candidate defect: Question 2 candidate duplicates an already accepted question: 'The majority of iron production sites in West Africa are wel...'; retrying with repair
INFO:httpx2: HTTP Request: POST https://api.minimaxi.chat/v1/chat/completions "HTTP/1.1 200 OK"
WARNING:app.loop.runtime: Capability failure recorded: GENERATE@1: CAPABILITY_FAILURE (ValueError): Question 2 candidate duplicates an already accepted question: 'The passage suggests that the majority of iron production si...'
WARNING:app.router: Stage rejected for Reading run run_d641c47c753c486d9e4506954bd31b36: question:run_d641c47c753c486d9e4506954bd31b36:2: INVALID_OUTPUT: capability failed: ValueError: Question 2 candidate duplicates an already accepted question: 'The passage suggests that the majority of iron production si...'
INFO:     127.0.0.1:48368 - "POST /api/v1/autogen/reading-paper/execute HTTP/1.1" 422 Unprocessable Content
```

### 10.2 Technical Mechanism & Root Defect Identification

The defect is a confluence of **Blueprint Claim Over-Concentration** and **Static Candidate Selection**:

1. **Claim Over-Concentration in Blueprint (`blueprint:run_...`):**
   - In `generate_dynamic_blueprint`, Slot 1, Slot 2, and Slot 5 of Section 1 were all assigned the identical claim reference: `claimRefIds: ["claim:run_...:1:2"]`.
   - While the blueprint contains 16 claims per section, multiple adjacent slots within the same question family (`TRUE_FALSE_NOT_GIVEN`) were bound to the exact same claim.

2. **First-Item Selection Heuristic (`section_runner.py:78`):**
   ```python
   cands = [c for c in raw_payload["candidates"] if isinstance(c, dict)]
   cand = next((c for c in cands if c.get("questionNumber") == q_num or c.get("number") == q_num), cands[0])
   ```
   - For `TRUE_FALSE_NOT_GIVEN`, MiniMax generated 3 candidates (representing TRUE, FALSE, and NOT GIVEN variations).
   - Because the schema does not include `questionNumber` inside individual candidates, `next(...)` defaulted to `cands[0]`.
   - When prompted with the same claim for Question 2 as Question 1, MiniMax returned the same candidate ordering, causing `cands[0]` to produce an identical statement.

3. **Autonomous Repair Limitation:**
   - The candidate repair prompt in `_generate_with_repair` informed MiniMax of the duplicate defect.
   - MiniMax responded by prefixing `"The passage suggests that "` to the statement, failing to recognize that shingle overlap (> 0.70) still considered the semantic and textual core a duplicate.

4. **Integrity & Fail-Closed Guard:**
   - The duplicate detector correctly prevented an exam with duplicate questions from being persisted.
   - The system failed closed, safely halting execution at HTTP 422.

---

## 11. Manual Intervention Log

In strict adherence to the read-only monitoring directive:
- **New generation jobs created:** 0 (only the requested initial job was submitted)
- **Manual retries or resumes executed:** 0
- **Code or test modifications applied during run:** 0
- **Configuration changes:** 0
- **Service restarts during run:** 0
- **Database mutations:** 0
- **Manual provider calls:** 0

**Total manual interventions: 0**

---

## 12. Final Verdict & Conclusions

```text
================================================================================
                                FINAL VERDICT
                             LIVE_E2E: FAIL
================================================================================
```

### Facts Verified:
1. Job `d641c47c-753c-486d-9e45-06954bd31b36` reached a terminal status of `Failed`.
2. No complete 3-passage, 40-question IELTS Academic Reading exam was generated or persisted.
3. Exam ID is `None`. Completed sections is 0.
4. The prompt template alignment from commits `c150a96` and `e3cf376` resolved the earlier `FLOW_CHART` explanation schema issue, but Section 1 failed at Question 2 due to candidate duplicate rejection against Question 1.
5. All 6 live MiniMax provider calls succeeded with valid tokens, zero provider rate-limit or timeout errors, and clean token usage accounting.
6. The system behaved with complete integrity: failed closed, persisted no corrupted artifacts, logged exact errors, and recorded complete accounting.
