# Phase 12 Live Harness Plan & Coordination Contract

**Date:** 2026-10-07  
**Subagent:** A (Live Harness & Campaign Orchestrator)  
**Gate:** G12 (Phase 12 — Paper Loop, .NET worker and authoritative Draft)  

---

## 1. Ownership and Boundaries

- **Subagent A Ownership:**
  - Harness orchestrators (`scripts/refactor/run_phase12*`).
  - G12-only launcher helpers with parameterizable ports, databases, and secure credential passing.
  - Phase 12 campaign, commands, sanitized transport, and evidence artifacts in `artifacts/refactor/phase-12/` (excluding B's runtime evidence).
- **Subagent B Ownership:**
  - Production code in `services/exam-service/` (.NET) and `services/generation-service/app/` (Python).
  - Production .NET tests and Python runtime T12 test implementations.
  - `runtime-*` evidence files under `artifacts/refactor/phase-12/`.
- **Main Ownership:**
  - Independent gate assessment and final G12 verdict.
  - Verification that G11 prerequisites, candidate compatibility, and live evidence meet specification.
  - No premature PASS stamps from plan artifacts or dry runs.

---

## 2. Sanitized Environment Inventory & Isolation Map

### 2.1 Protected G11 Environment (Untouchable & Read-Only)
- **Database:** `exam_test_phase11` inside Docker container `exam-database` (port 5433). Must NOT be touched, altered, migrated, or dropped.
- **Occupied Ports and Active PIDs:**
  - **Port 5099:** Occupied by active `exam-service` (PID 67426 / PPID 67399).
  - **Port 8092:** Occupied by active `generation-service` uvicorn (PID 67618).
  - *Stance:* Both existing processes and ports are treated as untouchable. No termination, restart, or port reuse without sanitized inventory proving complete ownership release.
- **Predecessor Evidence:** `artifacts/refactor/phase-11/` artifacts and campaign records are strictly read-only. G11 synthetic mock outputs will NEVER be relabeled as live evidence.

### 2.2 Allocated Isolated G12 Environment
To guarantee 100% isolation from ongoing processes and G11 assets:
- **G12 Live Harness Environment (Subagent A):**
  - **PostgreSQL Database:** `exam_test_phase12_g12` (in container `exam-database` on port 5433).
  - **`exam-service` Port:** **5199** (HTTP).
  - **`generation-service` Port:** **8192** (HTTP).
- **Subagent B Reserved Runtime Environment (if needed for B's isolated tests):**
  - **PostgreSQL Database:** `exam_test_phase12_runtime`.
  - **`exam-service` Port:** **5299** (HTTP).
  - **`generation-service` Port:** **8292** (HTTP).
- **Launcher Security:**
  - Use NEW G12-only launcher helpers (`scripts/refactor/launch_phase12_services.py`).
  - Parameterize ports, DB names, and service URLs.
  - Inject environment securely from `deploy/envs/exam.env`, `deploy/envs/ai.env`, and `deploy/envs/loop-caps.env`.
  - Zero hardcoded fallback secrets or test tokens. No prompts, headers, or raw source text dumped to public command logs or evidence files.

---

## 3. Configured Provider Credential Presence (Sanitized)

*Note: All secret values are omitted. Only configuration presence and source validity are verified.*

- **MiniMax Credentials:**
  - Source file: `deploy/envs/ai.env`.
  - `MINIMAX_API_KEY`: **PRESENT** (configured, non-empty, length > 100 characters).
  - `MINIMAX_BASE_URL`: **PRESENT** (configured, non-empty).
  - `MINIMAX_MODEL`: **PRESENT** (`MiniMax-Text-01`).
  - Ambient process environment: **MISSING** (must be injected at launch from `deploy/envs/ai.env` or via `GENERATION_SERVICE_ENV_FILE`).
- **Fallback Providers:**
  - `GROQ_API_KEYS`: **PRESENT** in `deploy/envs/ai.env`.
  - `CEREBRAS_API_KEYS`: **PRESENT** in `deploy/envs/ai.env`.
  - `GEMINI_API_KEY`: Configured but empty in `deploy/envs/ai.env`.

---

## 4. Early Queue & Instrumentation Contract for Subagent B

### 4.1 Planned Replacement of Legacy Harness Bypass
- **Status:** The legacy harness directly assembled sections in Python, SQL-updated `reading_paper_jobs."SectionsJson"`, and directly invoked `/build-exam`.
- **Target Contract:** Planned replacement until implemented and verified via end-to-end smoke test. The live acceptance path MUST execute via the authoritative .NET `ReadingPaperWorker` background service triggering generation-service `/paper-v2` and completing the authoritative Draft exam.

### 4.2 Runtime Interface Requirements for Subagent B
1. **Worker Queue Ingress Contract:**
   - Problem: In `services/exam-service/Features/ReadingPaper/ReadingPaperWorker.cs` (lines 37, 42), the query filters:
     ```csharp
     .Where(x => !x.Topic.StartsWith("Benchmark ") && (x.Status == "Pending" || ...))
     ```
     Benchmark cases provisioned via `BenchmarkCaseProvisionRequest` default to topics beginning with `"Benchmark "`, causing `ReadingPaperWorker.RunOne` to skip them.
   - Requirement from B: Provide a campaign-compatible topic naming scheme or adjust the worker claim predicate so that actual benchmark jobs are claimed and processed by `ReadingPaperWorker`.
2. **Worker -> Generation Service DTO Contract:**
   - In V2 engine mode, `ReadingPaperWorker.Process` invokes:
     - `POST api/v1/autogen/reading-paper/paper-v2` with `PaperV2Request(blueprintRef, sectionRefs, runId, leaseOwner, epoch, title, engine="v2")`.
     - `POST api/v1/autogen/reading-paper/paper-evaluate` with `paperEnvelope`.
   - Mandatory evaluators required by `ReadingPaperWorker.Process`:
     - `eval_paper_structure`
     - `eval_paper_cross_section`
     - `eval_paper_leakage`
     - `eval_paper_monotony`
   - All 4 evaluators must return status `PASS` with zero unresolved CRITICAL or HIGH issues.
   - Worker then commits paper checkpoint, validates rules via `ReadingPaperRules.Validate(sections)`, and executes `CheckpointService.BuildExamIdempotentAsync`.
3. **Gateway Transport Instrumentation:**
   - Provider calls in `generation-service` must pass through the production `ProviderGateway`.
   - The gateway recorder must capture: `operationId`, `runId`, `provider`, `model`, `tokensUsed`, `latencyMs`, `requestSha256`, and `responseSha256`.
   - Evidence records emitted to `artifacts/refactor/phase-12/sanitized-transport-evidence.jsonl`.
   - Raw secrets, provider reasoning, and raw prompt texts MUST NOT appear in logs or evidence.

---

## 5. T12-08 E2E Admin Publish & Student Projection Verification

1. **Authoritative Generated Exam Preservation:**
   - The authoritative Draft Exam generated by `ReadingPaperWorker` is preserved untouched in PostgreSQL to serve as immutable proof of the 40-question paper graph.
2. **Admin Publish via Actual API:**
   - Route: `PUT /api/admin/exam/update/{id}`.
   - Authorization: Bearer JWT signed with configured `JwtSettings` from `deploy/envs/exam.env`, carrying claim `"roles": "ADMIN"`.
   - Body: `AdminExamUpdate` DTO with `Status: "Published"`.
   - Verification: Authoritative DB status changes from `Draft` to `Published`.
3. **Student View Projection Isolation:**
   - Route: `GET /api/public/exam/getby/{slug}`.
   - While in `Draft`: Verify API returns HTTP 404 Not Found.
   - After `Published`: Verify API returns HTTP 200 with 3 sections, 40 contiguous questions.
   - Verify HTTP payload strictly excludes student-ineligible fields (`IsCorrect`, `ExplanationMd`, `BlankAcceptTexts`, `MatchPairs`, `OrderCorrects`, `ShortAnswerAcceptTexts`).
4. **Dedicated Manual CRUD Verification:**
   - To avoid modifying or deleting the generated campaign exam, perform manual CRUD on a separate, dedicated manual exam created via `POST /api/admin/exam/addexam`.
   - Exercise: create exam -> add section -> add question -> add option -> update section/question/option -> delete option/question/section -> delete exam.

---

## 6. Execution Gates & Next Action

- **Current State:** Harness and launcher helpers implemented and isolated. Diagnostic readbacks prepared.
- **Hold Condition:** No cost-bearing campaign or final gate evaluation executed until Subagent B confirms:
  1. Worker queue ingress contract and topic handling ready.
  2. Production gateway transport instrumentation verified.
  3. Integrated worker path ready for smoke test.
- Await Main's integrated-run direction.
