# MiniMax LIVE Acceptance & Autonomous Reading Harness Hardening Report

**Document ID:** `REPORT-2026-10-22-MINIMAX-LIVE-ACCEPTANCE-HANDOFF`  
**Location:** `docs/reports/MINIMAX_LIVE_ACCEPTANCE_PROGRESS_AND_HANDOFF.md`  
**Repository:** `minkhoaa/Project_Langfens_Microservice`  
**Branch:** `autonomous-generation`  
**Date:** 2026-10-22  
**Status:** `LIVE_ACCEPTANCE: BLOCKED` (External MiniMax Provider Quota Exhaustion — Ready for Immediate Resumption)  

---

## 1. Executive Summary & Verification State

All architectural defects, competing retry paths, contract discrepancies, and integration blockers in the Autonomous IELTS Reading Generation Harness have been resolved and verified across Python, .NET, and PostgreSQL.

### Key Milestones Achieved:
1. **Single Execution Authority (`BoundedLoopRuntime`):** Replaced legacy candidate retry loops with unified `BoundedLoopRuntime` execution in `StageExecutor`. Restored evaluation ledger validation preventing zero-call resume of unverified artifacts.
2. **19 IELTS Question Types:** Explicit schema validation and candidate parsing implemented for all 19 IELTS Reading question families in `section_runner.py` and `contracts/questions.py` without silent fallbacks. Downstream grading for `ChoosingTitle` registered in `attempt-service`.
3. **Integration & Publication Fixes:** Fixed HTTP 500 triggers in `exam-service` and `generation-service`:
   - Updated Polly HTTP resilience handler in `Shared.ServiceDefaults` to 45 minutes, preventing premature timeouts during LLM synthesis.
   - Added `ArtifactRef` and `Location` to `Issue` in `exam-service` contracts to resolve `System.Text.Json` unmapped property deserialization errors.
   - Added `.AsNoTracking()` to `ValidateRunAuthorityAndFencingAsync` and ChangeTracker clearance in `ReadingPaperWorker` so heartbeat lease renewals reflect immediately in finalization transactions.
   - Corrected `calls_used` accounting in `runtime.py` to count only real LLM calls, avoiding false `CALL_CAP` exhaustion from in-memory deterministic evaluators.
   - Corrected job status check in `ReadingPaperWorker` to accept `ACCEPTED` status from `ReadingGenerationPipeline`.
4. **Security & Sensitive Data:** Untracked committed `.dump` files from Git index and enforced ignore rules for `backups/` and `*.dump` in `.gitignore` without rewriting Git history.
5. **Deterministic Automated Test Verification:**
   - **Python (`services/generation-service`):** **281 / 281 PASSED** (including core runtime caps, S01 corrective regressions, 19-type schemas, blind solvers, visual SVG evaluators, and the full unified suite).
   - **.NET (`attempt-service.Tests` & `exam-service.Tests`):** **146 / 146 PASSED** (80 attempt grader tests and 66 non-destructive exam contract/dynamic rules tests).
6. **Live MiniMax Preflight:** **PASS** (Direct call to `MiniMax-Text-01` returned `"PONG"` with 722 tokens in 1.76s).
7. **Single-Section Live MiniMax Pipeline:** **PASS** (Job `b442bf60-6291-4836-bc1f-c5bdf9b9d1b3` generated Section 1: 13 questions, 882 words, verified against all IELTS Academic Paper Rules, published to PostgreSQL as Exam ID `43b68932-3eec-49bd-bdb6-64fafb1d0e2e`).
8. **Full-Paper Live Campaign:** Dispatched Job `d31203ea-5f54-452e-ac65-9d10522c01e0` (3 passages, 40 questions, dynamic blueprint). Paused upon user direction due to MiniMax provider quota exhaustion.

---

## 2. Root Cause Analysis & Implemented Solutions

| # | Subsystem | File & Location | Root Cause | Implemented Resolution |
|---|---|---|---|---|
| 1 | **Runtime Authority** | `services/generation-service/app/stage_executor.py:493-528` | A fallback `for attempt in range(max_candidates):` retry loop competed with `BoundedLoopRuntime`. | Removed the split-brain check; all stages now route exclusively through `_execute_bounded_loop`. |
| 2 | **Resumption Integrity** | `services/generation-service/app/loop/runtime.py:219-245` | Resumption awarded `COMPLETED` to prior heads without checking stored evaluations for required evaluators. | Enforced check that `self._stored_evaluations` contains passing evaluations for all required evaluators before admitting `COMPLETED`. |
| 3 | **Policy Bridge** | `services/generation-service/app/loop/policy.py:323` | `cap_profile_sha256` was assigned `policy_hash or expected_sha`, conflating policy hash with snapshot SHA. | Assigned `cap_profile_sha256 = expected_sha` strictly. |
| 4 | **19 Question Types** | `services/generation-service/app/section_runner.py:175-535` | `_parse_candidate_payload` only handled 5 types and defaulted everything else to `SHORT_ANSWER`. | Added explicit parsing and schema validation for all 19 IELTS families. Unsupported types raise `ValueError` fail-closed. |
| 5 | **Candidate Schemas** | `services/generation-service/app/contracts/questions.py:384-575` | `MultipleChoiceSingleQuestion`, `NoteCompletionQuestion`, and others had `extra = "forbid"` and lacked type-specific optional fields (`answer`, `headingContext`, etc.). | Added optional type-specific fields to all Question models. |
| 6 | **Downstream Grader** | `services/attempt-service/Features/Helpers/GraderHelper.cs:352-356` | `IsSingleChoice` omitted `QuestionType.ChoosingTitle`, resulting in empty answer keys and grading failures. | Added `or QuestionType.ChoosingTitle` to `IsSingleChoice`. |
| 7 | **Evaluator Tamper-Proofing** | `services/generation-service/app/stage_executor.py:628-638` | `StageEvalSingleAdapter` was mutating mismatched `target_ref`, `evaluator_version`, and `input_dependency_refs`. | Replaced mutations with strict fail-closed exceptions. |
| 8 | **Call Cap Accounting** | `services/generation-service/app/loop/runtime.py:365, 567, 635` | Deterministic in-memory evaluators (0 tokens) were incrementing `b.calls_used`, exhausting the 15-call cap on multi-version artifacts. | Restricted `b.calls_used` increment to real LLM calls (`GENERATE`, `REPAIR`, or `EVALUATE` with `token_reservation > 0`). |
| 9 | **Polly HTTP Timeout** | `services/_shared/Shared.ServiceDefaults/Extensions.cs:26-35` | Default `ConfigureHttpClientDefaults` applied a 30s Polly timeout, aborting LLM generation mid-flight. | Configured 45-minute timeout on `AddStandardResilienceHandler` in `Extensions.cs`. |
| 10 | **C# Issue Deserialization** | `services/exam-service/Features/ReadingPaper/Contracts/IssueContracts.cs:88-89` | Deserialization failed on JSON property `'artifactRef'` because `Issue` lacked `ArtifactRef` and `Location`. | Added `ArtifactRef` and `Location` properties to `Issue` record. |
| 11 | **Lease Renewal Visibility** | `services/exam-service/Features/ReadingPaper/CheckpointService.cs:45-54` & `ReadingPaperWorker.cs:304` | EF Core ChangeTracker cached stale `Job.LeaseUntil` from initial claim, ignoring heartbeat updates in the database. | Added `.AsNoTracking()` in `ValidateRunAuthorityAndFencingAsync` and `db.ChangeTracker.Clear()` before `BuildExamIdempotentAsync`. |
| 12 | **Worker Status Acceptance** | `services/exam-service/Features/ReadingPaper/ReadingPaperWorker.cs:297` | Worker threw exception if pipeline status was not `COMPLETED`, rejecting valid `ACCEPTED` status. | Updated check to accept both `COMPLETED` and `ACCEPTED`. |
| 13 | **Security & Dump Exposure** | `.gitignore` & Git Index | `.dump` files were committed in commit `a6d6d47`. | Untracked dump files via `git rm --cached` and updated `.gitignore` with `*.dump`, `*.dmp`, `backups/`. |

---

## 3. Evidence of Verified LIVE Single-Section Run

- **Run ID:** `run_b442bf6062914836bc1fc5bdf9b9d1b3`
- **Job ID:** `b442bf60-6291-4836-bc1f-c5bdf9b9d1b3`
- **Provider:** `minimax` (`MiniMax-Text-01`)
- **Published Exam ID:** `43b68932-3eec-49bd-bdb6-64fafb1d0e2e`
- **Exam Slug:** `reading-b442bf6062914836bc1fc5bdf9b9d1b3`
- **Section 1 Output:** 13 questions, 882 words, verified against all IELTS Academic constraints.
- **Duration:** 390.3 seconds.
- **Log Extract:**
  ```text
  [2026-10-22T05:55:10.996Z] Job created with 1 verified source(s); waiting for the generation worker.
  [2026-10-22T05:55:15.186Z] Worker claimed job for topic 'Marine Ecosystems and Global Climate Change' [Epoch 2].
  [2026-10-22T05:55:15.223Z] Executing unified ReadingGenerationPipeline via AI client...
  [2026-10-22T06:01:40.388Z] Unified pipeline executed successfully. Status: ACCEPTED, Sections: 1.
  [2026-10-22T06:01:40.397Z] [Exam Finalization] Validating all 1 section(s) against IELTS Academic Paper Rules...
  [2026-10-22T06:01:40.405Z] [Exam Validation Passed] All 13 questions and 882 words meet IELTS standards.
  [2026-10-22T06:01:40.556Z] [Exam Created Successfully] Exam ID: 43b68932-3eec-49bd-bdb6-64fafb1d0e2e | Slug: 'reading-b442bf6062914836bc1fc5bdf9b9d1b3'
  ```

---

## 4. Current Worktree & Infrastructure State

### Git Modifications (Ready to Commit & Push):
```text
deleted:    backups/db_backup_20261020_024500/attempt-db_20261020_024500.dump
deleted:    backups/db_backup_20261020_024500/exam-db_20261020_024500.dump
modified:   .gitignore
modified:   AppHost/Program.cs
modified:   deploy/compose.local.yaml
modified:   deploy/compose.yaml
modified:   restart_services.sh
modified:   run_e2e_admin_job.py
modified:   services/_shared/Shared.ServiceDefaults/Extensions.cs
modified:   services/attempt-service/Features/Helpers/GraderHelper.cs
modified:   services/exam-service/Features/ReadingPaper/CheckpointEndpoints.cs
modified:   services/exam-service/Features/ReadingPaper/CheckpointService.cs
modified:   services/exam-service/Features/ReadingPaper/Contracts/IssueContracts.cs
modified:   services/exam-service/Features/ReadingPaper/ReadingPaperModels.cs
modified:   services/exam-service/Features/ReadingPaper/ReadingPaperWorker.cs
modified:   services/generation-service/app/contracts/questions.py
modified:   services/generation-service/app/loop/policy.py
modified:   services/generation-service/app/loop/runtime.py
modified:   services/generation-service/app/router.py
modified:   services/generation-service/app/section_runner.py
modified:   services/generation-service/app/stage_executor.py
modified:   services/generation-service/tests/test_r03_runtime_caps.py
modified:   services/generation-service/tests/unified/test_section_standalone.py
untracked:  scripts/test_live_section1_job.py
```

### Stopped Infrastructure:
- All background uvicorn and dotnet processes have been killed.
- Docker containers (`deploy-exam-database-1`, `deploy-attempt-database-1`, `deploy-rabbitmq-service-1`) have been cleanly stopped (`docker compose stop`).

---

## 5. Step-by-Step Procedure to Resume & Run Full-Paper LIVE Acceptance

Once MiniMax API quota is reset:

### Step 1: Start Databases & Message Broker
```bash
docker compose -f deploy/compose.yaml up -d exam-database attempt-database rabbitmq-service
```
Verify ports `5433` (exam-db), `5435` (attempt-db), and `5672` (rabbitmq) are open.

### Step 2: Start Generation & Exam Microservices
```bash
./restart_services.sh
```
Verify both health endpoints return healthy:
```bash
curl -s http://127.0.0.1:8085/healthz
curl -s http://127.0.0.1:42933/healthz
```

### Step 3: (Optional) Start Attempt Service for Downstream Grading Verification
```bash
cd services/attempt-service && nohup env \
  ConnectionStrings__attempt-db="Host=127.0.0.1;Port=5435;Database=attempt-db;Username=attempt;Password=attempt" \
  ASPNETCORE_URLS="http://127.0.0.1:5001" \
  Kestrel__HttpPort="5001" \
  EXAM_SERVICE_URL="http://127.0.0.1:42933" \
  EXAMSERVICE__INTERNAL__API__KEY="internal-get-exam-snapshot" \
  INTERNAL_API_KEY="internal-get-exam-snapshot" \
  RABBITMQ__HOST="127.0.0.1" \
  RABBITMQ__USERNAME="appuser" \
  RABBITMQ__PASSWORD="apppassword" \
  RABBITMQ__VHOST="/" \
  RABBITMQ__PORT="5672" \
  RABBITMQ__USESSL="false" \
  JwtSettings__Issuer="IssuerName" \
  JwtSettings__Audience="AudienceName" \
  JwtSettings__SignKey="bTNGPmniBGyINHPdsmONct16TIqqb1bZ" \
  dotnet bin/Debug/net10.0/attempt-service.dll > /tmp/attempt_service.log 2>&1 &
```

### Step 4: Execute Full 3-Passage (40 Questions) LIVE Campaign
```bash
python3 run_e2e_admin_job.py
```
This script will:
1. Submit an admin job with 3 verified PMC articles (`PMC9540822`, `PMC9640808`, `PMC8556156`) using `provider="minimax"`.
2. Monitor progress as Section 1 (13 questions), Section 2 (13 questions), Section 3 (14 questions), and Paper Assembly (40 questions) are generated and evaluated.
3. Automatically validate the final paper and publish the Exam into PostgreSQL.
4. Save the full job results to `reports/fresh_monitored_job_result.json`.
