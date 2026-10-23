# MiniMax Autonomous Live IELTS Academic Reading Generation Report

**Document ID:** `REPORT-2026-10-23-MINIMAX-LIVE-E2E-OUTCOME`  
**Location:** `docs/reports/MINIMAX_LIVE_AUTONOMOUS_E2E_REPORT.md`  
**Repository:** `minkhoaa/Project_Langfens_Microservice`  
**Branch:** `autonomous-generation`  
**Date:** 2026-10-23  
**Mode:** READ-ONLY MONITORING + FINAL VERIFICATION  
**Status:** `LIVE_E2E: FAIL` (Terminal Failure — Candidate Schema Validation Rejection at Section 1, Question 6)

---

## 1. Executive Summary & Verification Verdict

This document records the read-only monitoring and post-mortem verification of the autonomous MiniMax LIVE IELTS Academic Reading generation job `a50190aa-37ca-43fd-b8d4-4d3dc2e35776` (Run ID: `run_a50190aa37ca43fdb8d44d3dc2e35776`).

The autonomous pipeline demonstrated robust performance in earlier stages:
1. **Source Ingestion & Verification:** All 3 scientific sources successfully validated and committed.
2. **Evidence Graph Generation:** Verified 16 grounded factual claims per section across all 3 sections.
3. **Blueprint Allocation:** Successfully allocated 40 questions across 3 sections (13/13/14) spanning diverse question families.
4. **Passage Synthesis:** Section 1 passage generated (882 words) via live MiniMax call and passed all passage evaluations (`eval_passage_word_count`, `eval_passage_fidelity`, `eval_passage_semantic`).
5. **Question Synthesis & Multi-Turn Autonomous Repair:**
   - Question 1 (TRUE_FALSE_NOT_GIVEN): Passed on version 1.
   - Question 2 (TRUE_FALSE_NOT_GIVEN): Passed on version 1.
   - Question 3 (TRUE_FALSE_NOT_GIVEN): v1 failed offset & adversary checks; **autonomously repaired** and passed on version 2.
   - Question 4 (TRUE_FALSE_NOT_GIVEN): Passed on version 1.
   - Question 5 (TRUE_FALSE_NOT_GIVEN): v1 failed offset checks; **autonomously repaired** and passed on version 2.

However, the job experienced a terminal failure during **Section 1, Question 6** (the first `FLOW_CHART` question). The candidate generation prompt template for `QuestionPromptFamily.FLOW_CHART` omitted the `"explanation"` field in its target JSON schema specification, while `_parse_candidate_payload` strictly enforced `len(explanation) >= 25`. After two consecutive candidate generation attempts failed validation, the pipeline terminated with HTTP 422 (`CAPABILITY_FAILURE`).

- **Final Verdict:** `LIVE_E2E: FAIL`
- **Completed Sections:** 0 / 3
- **Total Persisted Questions:** 0 / 40
- **Final Exam ID:** `None`
- **Manual Interventions:** 0 (strict observer mode maintained throughout)

---

## 2. Job & Runtime Configuration

| Parameter | Value | Verification Evidence |
|---|---|---|
| **Job ID** | `a50190aa-37ca-43fd-b8d4-4d3dc2e35776` | Verified via `GET /api/admin/reading-paper/jobs/{id}` & PostgreSQL `reading_paper_jobs` |
| **Run ID** | `run_a50190aa37ca43fdb8d44d3dc2e35776` | Verified via `reading_paper_runs` table |
| **Topic** | `Scientific Innovation and Its Impact on Society` | Verified from job payload |
| **Provider** | `minimax` | Configured in job source metadata |
| **Model** | `MiniMax-Text-01` | Recorded in `reading_paper_operations.ResultRefJson` |
| **Provider Endpoint** | `https://api.minimaxi.chat/v1/chat/completions` | Observed in `/tmp/generation_service.log` |
| **Secret Hygiene** | Compliant | No API keys, JWT secrets, or tokens disclosed |
| **Platform Engine** | .NET 10 (`exam-service`) + Python 3.12 FastAPI (`generation-service`) | Process verification (`exam-service.dll` PID 133932, `uvicorn` PID 133864) |
| **Database** | PostgreSQL 17 (`exam-db` container on port 5433) | Inspected via `psql` |
| **Engine / Schema / Policy Version** | `2.0.0` / `2.0.0` / `2.0.0` | Recorded in `reading_paper_runs` |
| **Budget Allocations** | Cap: 250 calls, 1,200,000 tokens, 900s wall time | Recorded in `reading_paper_runs` |

---

## 3. Final Job Status & Timing

- **Job Status:** `Failed`
- **Run Status:** `RUNNING` (halted mid-flight upon HTTP 422 pipeline rejection; lease expired)
- **Job Created At:** `2026-10-23T02:46:22.904476Z`
- **Worker Claimed At:** `2026-10-23T02:46:28.893250Z`
- **Job Failed / Updated At:** `2026-10-23T02:50:33.698777Z`
- **Total Pipeline Execution Duration:** 250.794 seconds (~4 minutes 10.8 seconds)
- **Active Run ID:** `None` (cleared upon job failure by `ReadingPaperWorker`)
- **Exam ID:** `None`

---

## 4. Pipeline Stage Progression

```text
[Stage 1: Source Verification]         ======> COMPLETED (3/3 Sources Accepted)
[Stage 2: Evidence Graph Extraction]   ======> COMPLETED (3/3 Graphs, 16 claims each)
[Stage 3: Exam Blueprint Allocation]   ======> COMPLETED (40 Questions Planned: 13/13/14)
[Stage 4: Passage Synthesis]           ======> COMPLETED FOR SECTION 1 (Passage 1 Accepted)
[Stage 5: Question Generation]         ======> FAILED AT SECTION 1, QUESTION 6 (Slot 6, FLOW_CHART)
  ├── Q1 (TRUE_FALSE_NOT_GIVEN)        ───> COMPLETED (v1 PASS: 6 evaluators passed)
  ├── Q2 (TRUE_FALSE_NOT_GIVEN)        ───> COMPLETED (v1 PASS: 6 evaluators passed)
  ├── Q3 (TRUE_FALSE_NOT_GIVEN)        ───> REPAIRED  (v1 FAIL -> v2 PASS: 6 evaluators passed)
  ├── Q4 (TRUE_FALSE_NOT_GIVEN)        ───> COMPLETED (v1 PASS: 6 evaluators passed)
  ├── Q5 (TRUE_FALSE_NOT_GIVEN)        ───> REPAIRED  (v1 FAIL -> v2 PASS: 6 evaluators passed)
  └── Q6 (FLOW_CHART)                  ───> FAILED (Attempt 1: schema mismatch -> Attempt 2: retry failed -> HTTP 422)
[Stage 6: Paper Finalization]          ======> NOT REACHED
[Stage 7: Exam Persistence]            ======> NOT REACHED
```

---

## 5. Source, Evidence, and Blueprint Results

### 5.1 Sources
All 3 PMC open-access research papers were successfully loaded, validated, and evaluated by `eval_source`:
1. **Source 1:** *Evolution of an Early and Long-Lasting Iron Smelting Technique at Didé West 1, Falémé Valley, Eastern Senegal* (PMC13654891) — Evaluator status: `PASS`
2. **Source 2:** *Development of a Novel Combined Wind–Rain Piezoelectric Energy Harvester* (PMC13667678) — Evaluator status: `PASS`
3. **Source 3:** *Tailoring LED spectra and cultivation systems enhances lettuce productivity and nutritional quality in vertical indoor farming* (PMC13621526) — Evaluator status: `PASS`

### 5.2 Evidence Graphs
Three evidence graphs were deterministically derived and evaluated by `eval_evidence_graph`:
- `evidence:run_a50190aa37ca43fdb8d44d3dc2e35776:1` (16 claims, Status: `PASS`)
- `evidence:run_a50190aa37ca43fdb8d44d3dc2e35776:2` (16 claims, Status: `PASS`)
- `evidence:run_a50190aa37ca43fdb8d44d3dc2e35776:3` (16 claims, Status: `PASS`)

### 5.3 Blueprint
Artifact `blueprint:run_a50190aa37ca43fdb8d44d3dc2e35776` was verified by `eval_blueprint` (`PASS`):
- **Total Questions:** 40
- **Target Word Count:** 2,150 – 2,750 words (800 words/passage)
- **Section 1 (Questions 1–13):**
  - Q1–Q5: `TRUE_FALSE_NOT_GIVEN` (5 questions)
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
| **Section 1** | 13 (Q1–Q13) | 5 (Q1–Q5 committed to DB) | 0 | Aborted at Q6 candidate generation |
| **Section 2** | 13 (Q14–Q26) | 0 | 0 | Not started |
| **Section 3** | 14 (Q27–Q40) | 0 | 0 | Not started |
| **Total** | **40** | **5** | **0 / 3** | **Exam unpersisted** |

---

## 7. Evaluation & Autonomous Repair History

During Section 1 execution, 52 automated evaluations were executed across Passage 1 and Questions 1–5:

### 7.1 Passage 1 Evaluations
- `eval_passage_word_count`: `PASS`
- `eval_passage_fidelity`: `PASS`
- `eval_passage_semantic`: `PASS`

### 7.2 Question Evaluations & Autonomous Repairs
Each question candidate undergoes 6 rigorous evaluations:
1. `eval_question_structure`
2. `eval_answer_verbatim_length`
3. `eval_evidence_offsets`
4. `eval_question_uniqueness`
5. `eval_question_semantic`
6. `eval_blind_solver_adversary` (requires blind solver LLM and adversarial reviewer LLM)

| Artifact | Version | Status | Evaluator Details & Autonomous Repair |
|---|---|---|---|
| `question:1` | v1 | **PASS** | All 6 evaluators passed on first attempt. |
| `question:2` | v1 | **PASS** | All 6 evaluators passed on first attempt. |
| `question:3` | v1 | **FAIL** | `eval_evidence_offsets` failed; `eval_blind_solver_adversary` failed. |
| `question:3` | v2 | **PASS** | **Autonomous Repair:** Bounded loop re-prompted with evaluator feedback; v2 passed all 6 evaluators. |
| `question:4` | v1 | **PASS** | All 6 evaluators passed on first attempt. |
| `question:5` | v1 | **FAIL** | `eval_evidence_offsets` failed. |
| `question:5` | v2 | **PASS** | **Autonomous Repair:** Bounded loop re-prompted with defect feedback; v2 passed all 6 evaluators. |
| `question:6` | v1 (att 1) | **FAIL** | Candidate parse failed: missing `explanation`. |
| `question:6` | v1 (att 2) | **FAIL** | Candidate repair failed: missing `explanation`. Loop aborted. |

---

## 8. Provider Usage & Token Accounting

All 24 provider operations were executed live against MiniMax (`MiniMax-Text-01`). Budget limits (250 calls, 1,200,000 tokens) were respected with zero breaches.

### 8.1 Aggregate Provider Consumption
- **Total Provider Calls:** 24
- **Total Tokens Consumed:** 52,470 tokens
  - **Prompt Tokens:** 45,742 tokens (87.2%)
  - **Completion Tokens:** 6,728 tokens (12.8%)
- **Total Provider Wall Time / Latency:** 238.31 seconds
- **Average Provider Latency:** 9.93 seconds / call
- **Estimated Cost:** $0.00 (reported by provider gateway)

### 8.2 Detailed Operation Breakdown

| Operation ID | Target | Tokens | Prompt | Completion | Wall Time (s) | Status |
|---|---|---|---|---|---|---|
| `op:...:passage:1:1` | Passage 1 Generation | 8,317 | 7,354 | 963 | 31.10 | COMPLETED |
| `op:...:question:1:1_1` | Q1 Candidate Gen | 1,823 | 1,389 | 434 | 12.90 | COMPLETED |
| `op_solve_...:1_1` | Q1 Blind Solver | 1,879 | 1,736 | 143 | 4.83 | COMPLETED |
| `op_adv_...:1_1` | Q1 Adversary Review | 1,890 | 1,820 | 70 | 2.25 | COMPLETED |
| `op:...:question:2:1_1` | Q2 Candidate Gen | 1,735 | 1,436 | 299 | 12.92 | COMPLETED |
| `op_solve_...:2_1` | Q2 Blind Solver | 1,888 | 1,749 | 139 | 5.66 | COMPLETED |
| `op_adv_...:2_1` | Q2 Adversary Review | 2,182 | 1,833 | 349 | 9.59 | COMPLETED |
| `op:...:question:3:1_1` | Q3 v1 Candidate Gen | 1,723 | 1,464 | 259 | 7.80 | COMPLETED |
| `op_solve_...:3_1` | Q3 v1 Blind Solver | 1,862 | 1,737 | 125 | 6.19 | COMPLETED |
| `op_adv_...:3_1` | Q3 v1 Adversary Review | 2,239 | 1,821 | 418 | 16.45 | COMPLETED |
| `op:...:question:3:1_2` | Q3 v2 Candidate Gen (Repair) | 1,924 | 1,535 | 389 | 15.35 | COMPLETED |
| `op_solve_...:3_2` | Q3 v2 Blind Solver | 1,874 | 1,739 | 135 | 5.70 | COMPLETED |
| `op_adv_...:3_2` | Q3 v2 Adversary Review | 1,898 | 1,823 | 75 | 3.45 | COMPLETED |
| `op:...:question:4:1_1` | Q4 Candidate Gen | 1,856 | 1,495 | 361 | 11.17 | COMPLETED |
| `op_solve_...:4_1` | Q4 Blind Solver | 1,871 | 1,734 | 137 | 5.57 | COMPLETED |
| `op_adv_...:4_1` | Q4 Adversary Review | 1,881 | 1,818 | 63 | 3.30 | COMPLETED |
| `op:...:question:5:1_1` | Q5 v1 Candidate Gen | 1,835 | 1,501 | 334 | 13.43 | COMPLETED |
| `op_solve_...:5_1` | Q5 v1 Blind Solver | 1,848 | 1,732 | 116 | 4.18 | COMPLETED |
| `op_adv_...:5_1` | Q5 v1 Adversary Review | 1,897 | 1,816 | 81 | 2.83 | COMPLETED |
| `op:...:question:5:1_2` | Q5 v2 Candidate Gen (Repair) | 2,200 | 1,580 | 620 | 20.28 | COMPLETED |
| `op_solve_...:5_2` | Q5 v2 Blind Solver | 1,852 | 1,736 | 116 | 3.46 | COMPLETED |
| `op_adv_...:5_2` | Q5 v2 Adversary Review | 1,887 | 1,820 | 67 | 3.31 | COMPLETED |
| `op:...:question:6:1_1` | Q6 Candidate Gen (Attempt 1) | 2,032 | 1,520 | 512 | 18.40 | COMPLETED |
| `op:...:question:6:1_1_att2` | Q6 Candidate Gen (Attempt 2) | 2,077 | 1,554 | 523 | 18.20 | COMPLETED |

---

## 9. Final Exam ID & Persistence Verification

- **API Endpoint:** `GET /api/admin/reading-paper/jobs/a50190aa-37ca-43fd-b8d4-4d3dc2e35776`
  - Returned: `{"id": "a50190aa-37ca-43fd-b8d4-4d3dc2e35776", "examId": null, "completedSections": 0, "status": "Failed"}`
- **Database Query:** `SELECT "Id", "Title", "CreatedAt" FROM exams ORDER BY "CreatedAt" DESC LIMIT 5;`
  - Result: No exam record was created for job `a50190aa-37ca-43fd-b8d4-4d3dc2e35776`.
- **Finding:** Correct and consistent fail-closed behavior. No partial or corrupt exam was persisted to the database.

---

## 10. Root-Cause Analysis

### 10.1 Failure Symptom & Stack Trace
The job terminated at `2026-10-23T02:50:33.6971138Z` with the following error logged in `exam-service`:

```text
exam_service.Features.ReadingPaper.ReadingPipelineExecutionException: 
{"detail":"question:run_a50190aa37ca43fdb8d44d3dc2e35776:6: INVALID_OUTPUT: capability failed: ValueError: Question 6 explanation is missing or too short (< 25 characters)"}
   at exam_service.Features.ReadingPaper.ReadingPaperAiClient.ReadAsync[T](HttpResponseMessage response, CancellationToken ct, Boolean isPipeline) in /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/exam-service/Features/ReadingPaper/ReadingPaperAiClient.cs:line 48
   at exam_service.Features.ReadingPaper.ReadingPaperAiClient.PostAsync[T](String path, Object body, CancellationToken ct, Boolean isPipeline) in /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/exam-service/Features/ReadingPaper/ReadingPaperAiClient.cs:line 36
   at exam_service.Features.ReadingPaper.ReadingPaperAiClient.ExecutePipelineAsync(PipelineRequest request, CancellationToken ct) in /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/exam-service/Features/ReadingPaper/ReadingPaperAiClient.cs:line 25
   at exam_service.Features.ReadingPaper.ReadingPaperWorker.Process(ExamDbContext db, ReadingPaperAiClient ai, ReadingPaperJob job, Guid owner, CancellationToken ct) in /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/exam-service/Features/ReadingPaper/ReadingPaperWorker.cs:line 273
   at exam_service.Features.ReadingPaper.ReadingPaperWorker.RunOne(CancellationToken ct) in /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/exam-service/Features/ReadingPaper/ReadingPaperWorker.cs:line 166
```

In `generation-service` logs (`/tmp/generation_service.log`):
```text
WARNING:app.section_runner: Question 6 candidate defect: Question 6 explanation is missing or too short (< 25 characters); retrying with repair
INFO:httpx2: HTTP Request: POST https://api.minimaxi.chat/v1/chat/completions "HTTP/1.1 200 OK"
WARNING:app.loop.runtime: Capability failure recorded: GENERATE@1: CAPABILITY_FAILURE (ValueError): Question 6 explanation is missing or too short (< 25 characters)
WARNING:app.router: Stage rejected for Reading run run_a50190aa37ca43fdb8d44d3dc2e35776: question:run_a50190aa37ca43fdb8d44d3dc2e35776:6: INVALID_OUTPUT: capability failed: ValueError: Question 6 explanation is missing or too short (< 25 characters)
INFO: 127.0.0.1:43068 - "POST /api/v1/autogen/reading-paper/execute HTTP/1.1" 422 Unprocessable Content
```

### 10.2 Technical Mechanism & Defect Identification

The defect stems from a **contractual prompt-template discrepancy** between question prompt generation and question candidate ingestion:

#### 1. The Validation Rule (`services/generation-service/app/section_runner.py:94-96`)
`_parse_candidate_payload` unconditionally asserts that every question candidate contains an explanation of at least 25 characters:
```python
matched_claim = claims_map.get(claim_id)
explanation = str(cand.get("explanation") or "").strip()
if len(explanation) < 25:
    raise ValueError(f"Question {q_num} explanation is missing or too short (< 25 characters)")
```

#### 2. The Prompt Template (`services/generation-service/app/generators/question/prompts.py:535-555`)
While question types like `TRUE_FALSE_NOT_GIVEN` and `MULTIPLE_CHOICE` explicitly include `"explanation": "..."` in their prompt schema, `QuestionPromptFamily.FLOW_CHART` completely omits the `"explanation"` property from its target JSON specification:
```python
QuestionPromptFamily.FLOW_CHART: (
    "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
    "Generate Flow Chart process ordering candidates for question #{question_number}.\n"
    "RULES FOR FLOW CHART:\n"
    "- Flow chart prompts must represent sequential processes with step layout descriptions and blank callout numbers.\n"
    "- Each step must describe a clear stage in the process.\n"
    "Output JSON format:\n"
    "{{\n"
    '  "candidates": [\n'
    "    {{\n"
    '      "prompt": "Complete the flow chart below. Step {question_number}: ______",\n'
    '      "answer": "step-slug-name",\n'
    '      "flowSteps": [\n'
    '        "Stage 1: initial process step",\n'
    '        "Stage 2: subsequent process step",\n'
    '        "Stage 3: final process step with blank ______"\n'
    '      ],\n'
    '      "stepIndex": {question_number},\n'
    '      "evidenceQuote": "verbatim sentence"\n'
    "    }}\n"
    "  ]\n"
    "}}"
)
```

#### 3. LLM Behavioral Adherence
MiniMax adhered strictly to the requested JSON schema in both Attempt 1 (`op:...:question:6:1_1`) and Attempt 2 (`op:...:question:6:1_1_att2`), outputting:
```json
{
  "prompt": "Complete the flow chart below. Step 6: ______",
  "answer": "analyze-smelting-techniques",
  "flowSteps": [
    "Stage 1: Identify iron production sites in West Africa",
    "Stage 2: Assess the preservation and documentation of sites",
    "Stage 3: Date the sites using available evidence",
    "Stage 4: Study the geographical distribution of sites",
    "Stage 5: Examine the technological aspects of iron production",
    "Stage 6: ______"
  ],
  "stepIndex": 6,
  "evidenceQuote": "In West Africa, a growing number of iron production sites attest to the use of diverse smelting techniques as early as the first millennium BCE (Robion-Brunner, 2018 )."
}
```
Because the JSON schema in the prompt did not ask for `"explanation"`, MiniMax did not include it. Even when Attempt 2 prepended `PREVIOUS ATTEMPT DEFECT: Question 6 explanation is missing or too short (< 25 characters)`, the schema example still lacked `"explanation"`, so MiniMax once again omitted it.

#### 4. Classification
- **Not a Provider Failure:** MiniMax responded promptly (18.4s and 18.2s) with HTTP 200 and syntactically valid JSON.
- **Not a Budget Exhaustion:** Only 24 of 250 calls and 52,470 of 1,200,000 tokens were consumed.
- **Not a Checkpoint / Fencing Failure:** Checkpoints committed correctly; fencing leases remained valid.
- **Implementation Defect:** Missing `"explanation"` property in `PROMPT_TEMPLATES[QuestionPromptFamily.FLOW_CHART]` in `services/generation-service/app/generators/question/prompts.py`.

---

## 11. Manual Intervention Log

In strict adherence to the read-only monitoring directive:
- **New generation jobs created:** 0
- **Manual retries or resumes executed:** 0
- **Code or test modifications applied:** 0
- **Configuration changes:** 0
- **Service restarts:** 0
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
1. Job `a50190aa-37ca-43fd-b8d4-4d3dc2e35776` reached a terminal status of `Failed`.
2. No complete 3-passage, 40-question IELTS Academic Reading exam was generated or persisted.
3. Exam ID is `None`. Completed sections is 0.
4. The failure occurred during Section 1 Question 6 (`FLOW_CHART`) due to candidate validation rejection on a missing `explanation` field.
5. All 24 live MiniMax provider calls succeeded with valid tokens and low latencies.
6. Multi-turn autonomous repair for Questions 3 and 5 demonstrated that the self-healing evaluation loops function correctly when the prompt template aligns with the validation schema.
7. System behaved with full integrity: failed closed, persisted no corrupted artifacts, logged exact errors, and recorded complete accounting.
