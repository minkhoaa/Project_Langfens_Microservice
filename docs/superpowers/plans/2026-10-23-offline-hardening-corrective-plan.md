# Offline Hardening Corrective Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Resolve confirmed offline hardening defects across CLI job control, credential hygiene, blueprint reproducibility and evidence awareness, golden fixture grounding, evaluator alignment, and concurrent retry atomicity under strict offline constraints.

**Architecture:** Maintain strict offline boundaries with zero external network or LLM provider calls. Enforce fail-closed security and validation. Harden Python generation service blueprints, evaluators, and fixtures, and harden .NET exam service retry endpoint with atomic database compare-and-swap (CAS).

**Tech Stack:** Python 3.12 / 3.14 (FastAPI, Pydantic v2, pytest), .NET 10.0 (C# Minimal APIs, EF Core 10, Npgsql), PostgreSQL, Bash.

**Spec:** The prompt requirements in conjunction with `LANGFENS_OFFLINE_HARDENING_RECONCILED_AUDIT.md`.

## Global Constraints

- NEVER invoke MiniMax or any live LLM provider. Zero live network calls.
- Strictly offline execution using deterministic mocks and blocked provider transports.
- Do not modify `generation_baseline/`.
- No Git history rewrite, force-push, or credential rotation.
- Do not print or leak plaintext credentials in logs, tests, or reports.
- Avoid destructive operations on shared or populated development/production databases.
- Preserve existing question type contracts (all 19 IELTS question families) and legacy 6-type preset behavior.

## Review Focus

1. **Unintended Job Enqueueing / Spend in Offline Mode:** Ensure `run_e2e_admin_job.py` never dispatches a mutating POST request when `--offline` or `OFFLINE_MODE` is active, even on Failed or NeedsSources jobs.
2. **Plaintext Credential Fallback:** Ensure missing signing keys fail closed immediately without falling back to hardcoded strings, while allowing properly configured test keys.
3. **Blueprint Non-Determinism (Hash Drift):** Ensure identical inputs to blueprint generation produce identical canonical hashes by stripping volatile timestamps (`createdAt`) and intermediate nested hashes before calculating the SHA-256 digest.
4. **Fixture Grounding & Alignment:** Ensure Q1, Q8, and Q16 in `golden_19_families` contain authentic verbatim passage quotes, valid exact offsets, and semantically aligned claims, passing all production evaluators.
5. **Race Condition in Job Retry:** Ensure concurrent retry requests on a failed job execute with atomic CAS semantics so that only one request transitions the job to Pending while concurrent callers receive HTTP 409 Conflict.

---

### Task 1: Fix Offline Job Control & CLI State Machine

**Files:**
- Modify: `run_e2e_admin_job.py`
- Test: `services/generation-service/tests/unified/test_admin_job_cli.py`

**Interfaces:**
- Consumes: CLI arguments (`--mode`, `--job-id`, `--provider`, `--offline`, `--base-url`) and `OFFLINE_MODE` env var.
- Produces: Hardened CLI script that enforces explicit mode or safe non-mutating behavior, blocks all mutating requests in offline mode, and handles job statuses according to server state rules.

- [ ] **Step 1: Write failing tests for offline job control in `test_admin_job_cli.py`**
  Cover scenarios:
  A. `new + offline` -> zero mutating requests, exits with error.
  B. `resume + offline + Failed` -> zero POST requests, does not retry.
  C. `resume + offline + NeedsSources` -> zero POST requests, does not retry.
  D. `monitor` -> GET only.
  E. `completed` -> no retry/publication.
  F. invalid UUID -> immediate failure without network mutation.
  G. missing required config (e.g. missing signing key) -> explicit safe failure.
  H. no explicit mode -> safe failure or non-mutating default, no job creation.

- [ ] **Step 2: Run tests to verify failures**
  Run: `cd services/generation-service && .venv/bin/pytest tests/unified/test_admin_job_cli.py -v`
  Expected: FAIL on offline resume / status handling / mode defaults.

- [ ] **Step 3: Implement offline job control in `run_e2e_admin_job.py`**
  - Set `--mode` default to `None` or require explicit `--mode`.
  - Check offline guard for ALL mutating paths (`mode == "new"` or `mode == "resume"` attempting retry).
  - Enforce server state rules: `NeedsSources` is never retried via `POST /retry` (report that sources must be provided).
  - Only `Failed` status can be retried in online mode, and in offline mode report status and monitor without POST.
  - Upfront UUID validation before any network request.

- [ ] **Step 4: Run tests to verify they pass**
  Run: `cd services/generation-service && .venv/bin/pytest tests/unified/test_admin_job_cli.py -v`
  Expected: PASS

---

### Task 2: Credential Hygiene & Key Fallbacks

**Files:**
- Modify: `run_e2e_admin_job.py`
- Modify: `scripts/test_live_section1_job.py`
- Modify: `restart_services.sh`
- Test: `services/generation-service/tests/unified/test_security_hygiene.py`

**Interfaces:**
- Consumes: Environment variables `JWT_SIGNING_KEY`, `JwtSettings__SignKey`, `INTERNAL_API_KEY`.
- Produces: Scripts that fail closed when required credentials are missing, with zero plaintext secret fallbacks.

- [ ] **Step 1: Write failing tests in `test_security_hygiene.py`**
  Verify that when `JWT_SIGNING_KEY` and `JwtSettings__SignKey` are unset, importing/running `run_e2e_admin_job.py` and `scripts/test_live_section1_job.py` raises an explicit error and does not produce tokens with a hardcoded fallback. Verify that no hardcoded fallback string appears in source files.

- [ ] **Step 2: Run tests to verify failures**
  Run: `cd services/generation-service && .venv/bin/pytest tests/unified/test_security_hygiene.py -v`
  Expected: FAIL due to existing hardcoded fallbacks.

- [ ] **Step 3: Implement credential hygiene fixes**
  - In `run_e2e_admin_job.py`: remove `"bTNGPmniBGyINHPdsmONct16TIqqb1bZ"`. If both env vars are unset, exit with `sys.exit("ERROR: JWT_SIGNING_KEY or JwtSettings__SignKey environment variable is required")`.
  - In `scripts/test_live_section1_job.py`: add `import os`. Remove hardcoded key fallback. Raise `ValueError("JWT_SIGNING_KEY or JwtSettings__SignKey is required")` if unset.
  - In `restart_services.sh`: source credentials dynamically from environment:
    `${JwtSettings__SignKey:-${JWT_SIGNING_KEY:?JwtSettings__SignKey or JWT_SIGNING_KEY required}}`
    `${INTERNAL_API_KEY:-${EXAMSERVICE__INTERNAL__API__KEY:?INTERNAL_API_KEY required}}`
    `${ConnectionStrings__exam-db:-Host=127.0.0.1;Port=5433;Database=exam-db;Username=exam;Password=exam}`

- [ ] **Step 4: Run tests to verify they pass**
  Run: `cd services/generation-service && .venv/bin/pytest tests/unified/test_security_hygiene.py -v`
  Expected: PASS

---

### Task 3: Blueprint Reproducibility & Content Hash Normalization

**Files:**
- Modify: `services/generation-service/app/reading_generation.py`
- Modify: `services/generation-service/app/blueprint/generator.py`
- Modify: `services/generation-service/app/contracts/blueprint.py`
- Test: `services/generation-service/tests/test_dynamic_blueprint.py`

**Interfaces:**
- Consumes: `ExamBlueprint` model, pinned policy, evidence summary.
- Produces: Stable, reproducible canonical SHA-256 `content_hash` across identical runs.

- [ ] **Step 1: Write failing test in `test_dynamic_blueprint.py`**
  Call `build_blueprint` twice with identical pinned inputs. Assert that `contentHash` is identical across both runs. Assert that mutating evidence alters `contentHash`.

- [ ] **Step 2: Run test to verify failure**
  Run: `cd services/generation-service && .venv/bin/pytest tests/test_dynamic_blueprint.py -k "reproducibility" -v`
  Expected: FAIL (hashes drift due to un-popped `createdAt` and nested `contentHash`).

- [ ] **Step 3: Implement canonical hashing and deterministic ID handling**
  - Define `compute_canonical_blueprint_hash(bp: ExamBlueprint) -> str` in `app/contracts/blueprint.py` or `generator.py`.
  - Strip volatile fields: `createdAt`, `contentHash`, `invalidatedDescendants`.
  - Use consistent `json.dumps(dict, sort_keys=True, separators=(",", ":"))`.
  - In `reading_generation.py:build_blueprint`: use canonical hashing before returning dict.
  - In `generator.py`: ensure deterministic `blueprint_id` based on `run_id`.

- [ ] **Step 4: Run test to verify it passes**
  Run: `cd services/generation-service && .venv/bin/pytest tests/test_dynamic_blueprint.py -v`
  Expected: PASS

---

### Task 4: Evidence-Aware Dynamic Blueprint Allocation & Semantic Claim Binding

**Files:**
- Modify: `services/generation-service/app/reading_generation.py`
- Modify: `services/generation-service/app/blueprint/generator.py`
- Test: `services/generation-service/tests/test_dynamic_blueprint.py`

**Interfaces:**
- Consumes: `evidence_map` containing verified claims and passage metadata.
- Produces: Evidence-driven question family selection and semantic claim binding without synthetic claim fallbacks.

- [ ] **Step 1: Write failing tests for evidence-driven allocation**
  - Test that passing process-oriented evidence elevates flow chart / diagram label suitability.
  - Test that missing claims causes fail-closed behavior instead of synthetic `claim:{run_id}:{sec_idx}:1` fallback.
  - Test that all 40 question slots have claim references resolving to verified evidence.

- [ ] **Step 2: Run tests to verify failures**
  Run: `cd services/generation-service && .venv/bin/pytest tests/test_dynamic_blueprint.py -k "evidence_aware" -v`
  Expected: FAIL

- [ ] **Step 3: Implement evidence-aware allocation and claim binding**
  - In `reading_generation.py`: pass `section_evidence={sec_idx: _payload(evidence_map[sec_idx])}` into `generate_dynamic_blueprint`.
  - In `generator.py`: use `sec_evidence` (claim count, claim text, themes) in `_determine_section_group_counts` and `_score_family_suitability`.
  - In `reading_generation.py`: bind question slots to verified claims from evidence. If claims are empty/missing, raise `ValueError("Verified claims are required for question slot allocation; cannot fabricate synthetic claims")`.

- [ ] **Step 4: Run tests to verify they pass**
  Run: `cd services/generation-service && .venv/bin/pytest tests/test_dynamic_blueprint.py -v`
  Expected: PASS

---

### Task 5: Repair Golden Fixture Grounding & Negative Test Suite

**Files:**
- Modify: `services/generation-service/tests/fixtures/golden_19_families/all_19_families_manifest.json`
- Modify: `services/generation-service/tests/fixtures/golden_19_families/section1_factual.json`
- Modify: `services/generation-service/tests/fixtures/golden_19_families/section2_processes.json`
- Modify: `services/generation-service/tests/unified/test_golden_19_families_fixtures.py`
- Test: `services/generation-service/tests/unified/test_golden_19_families_fixtures.py`
- Test: `services/generation-service/tests/unified/test_negative_correctness_suite.py`

**Interfaces:**
- Consumes: Golden 19-family test fixtures.
- Produces: Fully grounded fixtures that pass all production evaluators (`evaluate_question`).

- [ ] **Step 1: Write failing tests in `test_golden_19_families_fixtures.py`**
  Add full evaluator run: for every item in all 19 families, parse candidate payload and pass to `reading_evaluation.evaluate_question(envelope, passage, difficulty, siblings)`. Assert all 5 evaluation results have status `PASS`.

- [ ] **Step 2: Run test to verify failures**
  Run: `cd services/generation-service && .venv/bin/pytest tests/unified/test_golden_19_families_fixtures.py -v`
  Expected: FAIL on Q1 (offsets `[-1:-1]`), Q8 (truncated evidence quote omitting `"20"`), and Q16.

- [ ] **Step 3: Correct golden fixtures**
  - Q1: Replace paraphrased quote with exact passage quote (`"There is no globally recognized standard for monitoring biologically active light, and the tools commonly used, such as lux meters, often fail to account for the full spectrum of light wavelengths that are biologically relevant."`). Update offsets dynamically from passage text. Provenance: `"academically_grounded_golden_fixture"`. Answer `FALSE` preserved.
  - Q8: Replace truncated quote with full clause containing `"20"`: `"In Southeast Asian seas, such as the Gulf of Thailand and the South China Sea, ALAN penetrates to approximately 20 meters."`. Update offsets. Answer `"20"` preserved.
  - Q16: Update `claimId` and `claimsMap` to reference chemosynthetic trophic energy conversion: `"Chemosynthetic bacteria form the primary trophic foundation converting hydrogen sulfide into cellular energy."`.
  - Add negative test cases in `test_negative_correctness_suite.py`: invalid offsets, wrong answer, missing claim, answer leakage.

- [ ] **Step 4: Run tests to verify they pass**
  Run: `cd services/generation-service && .venv/bin/pytest tests/unified/test_golden_19_families_fixtures.py tests/unified/test_negative_correctness_suite.py -v`
  Expected: PASS

---

### Task 6: Question Evaluator Alignment & Completion Coverage

**Files:**
- Modify: `services/generation-service/app/facade.py`
- Modify: `services/generation-service/app/loop/question.py`
- Modify: `services/generation-service/app/evaluators/deterministic.py`
- Modify: `services/generation-service/app/reading_evaluation.py`
- Test: `services/generation-service/tests/test_t09_question_candidates.py`
- Test: `services/generation-service/tests/test_question_candidates_19types.py`

**Interfaces:**
- Consumes: Question artifacts with `passageEvidence` or flat `evidenceStart`/`evidenceEnd`.
- Produces: Consistent evaluator registration and enforcement across primary and secondary loops.

- [ ] **Step 1: Write failing test for secondary evaluator registration and completion validation**
  - Test that `EvidenceOffsetEvaluator` handles `passageEvidence: {startChar, endChar, text}` correctly and rejects negative or mismatched offsets.
  - Test that `AnswerVerbatimAndLengthEvaluator` and `reading_evaluation.evaluate_question` check verbatim presence and word limits for `NOTE_COMPLETION`, `TABLE_COMPLETION`, and `FORM_COMPLETION`.

- [ ] **Step 2: Run test to verify failure**
  Run: `cd services/generation-service && .venv/bin/pytest tests/test_t09_question_candidates.py -k "completion_verbatim" -v`
  Expected: FAIL

- [ ] **Step 3: Implement evaluator harmonization**
  - In `app/facade.py:run_question_loop`: register `EvidenceOffsetEvaluator`.
  - In `app/loop/question.py`: include `EvidenceOffsetEvaluator` in default registry and required list.
  - In `app/evaluators/deterministic.py`:
    - In `EvidenceOffsetEvaluator`: extract `start`, `end`, and `quote` from `passageEvidence` / `passage_evidence` when present.
    - In `AnswerVerbatimAndLengthEvaluator`: include `NOTECOMPLETION`, `TABLECOMPLETION`, `FORMCOMPLETION`.
  - In `app/reading_evaluation.py`: include `NOTE_COMPLETION`, `TABLE_COMPLETION`, `FORM_COMPLETION` in completion validation checks.

- [ ] **Step 4: Run tests to verify they pass**
  Run: `cd services/generation-service && .venv/bin/pytest tests/test_t09_question_candidates.py tests/test_question_candidates_19types.py -v`
  Expected: PASS

---

### Task 7: Retry Endpoint Atomic State Transition & Concurrency Hardening

**Files:**
- Modify: `services/exam-service/Features/ReadingPaper/ReadingPaperEndpoints.cs`
- Modify: `services/exam-service.Tests/ReadingPaperIntegrationTests.cs` (or dedicated concurrency test)
- Test: `services/exam-service.Tests/`

**Interfaces:**
- Consumes: `POST /api/admin/reading-paper/jobs/{id}/retry`.
- Produces: Atomic CAS transition: only one concurrent retry transitions `Failed` -> `Pending` and returns HTTP 200, concurrent requests return HTTP 409 Conflict.

- [ ] **Step 1: Write concurrent test for Retry endpoint**
  Write an integration test in `exam-service.Tests` that seeds a `Failed` job and initiates concurrent retry requests.
  Run it on disposable PostgreSQL (or isolated in-memory DB if PostgreSQL unavailable) to observe race condition.

- [ ] **Step 2: Run test and record outcome**
  Run: `dotnet test services/exam-service.Tests/exam-service.Tests.csproj --filter "Retry"`
  Observe race or baseline behavior.

- [ ] **Step 3: Implement atomic CAS update in `ReadingPaperEndpoints.Retry`**
  ```csharp
  var now = DateTime.UtcNow;
  var retryLog = SerializeLog("Information", "Retry requested; worker will resume from last saved passage.");
  var rows = await db.ReadingPaperJobs
      .Where(x => x.Id == id && x.Status == "Failed" && x.ExamId == null)
      .ExecuteUpdateAsync(x => x
          .SetProperty(j => j.Status, "Pending")
          .SetProperty(j => j.Error, (string?)null)
          .SetProperty(j => j.LeaseUntil, (DateTime?)null)
          .SetProperty(j => j.LeaseOwner, (Guid?)null)
          .SetProperty(j => j.UpdatedAt, now)
          .SetProperty(j => j.Logs, j => j.Logs + "\n" + retryLog),
          ct);

  if (rows == 0)
  {
      var existing = await db.ReadingPaperJobs.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id, ct);
      if (existing is null) return Results.NotFound();
      return Results.Conflict(new { error = "Only a failed, unsaved job can be retried" });
  }

  var updatedJob = await db.ReadingPaperJobs.AsNoTracking().FirstAsync(x => x.Id == id, ct);
  return Results.Ok(View(updatedJob));
  ```

- [ ] **Step 4: Run test to verify atomic behavior**
  Run: `dotnet test services/exam-service.Tests/exam-service.Tests.csproj --filter "ReadingPaperDynamicRulesTests|ReadingPaperTests|Phase01ContractTests|R03CapsProfileTests|Retry"`
  Expected: PASS

---

### Task 8: Repository Hygiene, Untracking Reports, & Finding Count Reconciliation

**Files:**
- Untrack: `reports/job_*.json`, `reports/demo_*.json`, `reports/*_result.json`, `reports/reading_generation_*.json`
- Modify: `.gitignore`
- Modify: `LANGFENS_OFFLINE_HARDENING_RECONCILED_AUDIT.md` (reconcile finding count)

**Interfaces:**
- Consumes: Git repository tracking status.
- Produces: Clean git index with generated report files untracked and preserved locally; corrected finding counts.

- [ ] **Step 1: Untrack report files using `git rm --cached`**
  Ensure local files remain intact while removing them from git index.

- [ ] **Step 2: Verify `.gitignore` rules**
  Ensure `.gitignore` covers `reports/job_*.json`, `reports/*_result.json`, `reports/demo_*.json`, and `reports/reading_generation_*.json`.

- [ ] **Step 3: Correct audit finding counts**
  In `LANGFENS_OFFLINE_HARDENING_RECONCILED_AUDIT.md`:
  Reconcile section 5 and 7 table counts: 15 confirmed defects (H01, H02, H03, H04, H05, H06, H08, H09, H10, H11, H13, H14, H15, H16, H17), 3 corrected/partial (H07, H12, H18), 1 not verified (concurrent retry API race boundary).

- [ ] **Step 4: Check git status to confirm clean tracking**
  Run: `git status`

---

### Task 9: Cross-Service Shared Fixture Serialization & Full Acceptance Verification

**Files:**
- Create/Modify: `services/generation-service/tests/unified/test_cross_service_contracts.py`
- Create: `CORRECTIVE_OFFLINE_HARDENING_IMPLEMENTATION_REPORT.md`

**Interfaces:**
- Consumes: Python golden fixtures and C# public contract definitions.
- Produces: Automated verification that Python fixtures match C# model contracts and full acceptance report.

- [ ] **Step 1: Write cross-service contract serialization test**
  Verify that golden fixtures map cleanly to `QuestionType` and JSON schema expected by .NET services.

- [ ] **Step 2: Run all test suites across the monorepo**
  1. Python tests in `services/generation-service`
  2. .NET attempt-service tests in `services/attempt-service.Tests`
  3. .NET exam-service safe tests in `services/exam-service.Tests`
  Record exact test counts, pass/fail/skip numbers.

- [ ] **Step 3: Generate implementation report**
  Write `CORRECTIVE_OFFLINE_HARDENING_IMPLEMENTATION_REPORT.md` documenting initial/final SHA, confirmed defect fixes, test evidence, concurrency findings, and acceptance status.
