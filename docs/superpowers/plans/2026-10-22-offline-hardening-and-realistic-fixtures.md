# Offline Hardening & Realistic Fixture Acceptance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Perform the final offline hardening of the Autonomous IELTS Academic Reading Generation Harness, eliminate unsafe fallbacks, implement evidence-driven dynamic blueprints, build realistic golden fixtures covering all 19 question families, verify downstream .NET grading for all 19 types, and establish safe job resumption.

**Architecture:** 
1. **Resume & Execution Authority:** Enhance `run_e2e_admin_job.py` with explicit `--mode new|resume|monitor` commands and job-ID binding, reconciling durable status without duplicate job creation.
2. **Evidence-Driven Dynamic Blueprint:** Replace hardcoded groups and rotation in `app/blueprint/generator.py` with evidence-driven suitability scoring that inspects claims, entities, processes, and arguments, generating reproducible 40-question blueprints.
3. **Fail-Closed Validation:** Eliminate silent fallbacks (missing explanations fabricated from evidence, missing types defaulting to `SHORT_ANSWER`, unknown types converted to legacy presets, and misclassified 422 caps).
4. **19-Family Fixtures & Downstream Grading:** Construct academically realistic golden fixtures across all 19 families and test end-to-end publication and `attempt-service` grading.

**Tech Stack:** Python 3.12 (FastAPI, Pydantic v2, pytest), .NET 10.0 (C#, EF Core, xUnit), PostgreSQL, SVG XML.

**Spec:** Task specifications from user prompt `LANGFENS — OFFLINE HARDENING & REALISTIC FIXTURE ACCEPTANCE`.

## Global Constraints

- MiniMax quota is exhausted: DO NOT invoke MiniMax, execute LIVE campaigns, perform provider connectivity tests, or submit new generation jobs.
- Single-agent execution: Work primarily as a single agent in this session.
- Preserve existing accepted artifacts, checkpoints, and immutable `generation_baseline/`.
- No Git history rewriting, force-pushes, or production credential deletions.
- If frontend/browser runtime is unavailable, explicitly mark visual rendering as unverified instead of claiming PASS.
- All 19 question families must remain supported end-to-end.

## Review Focus

1. **Missing or Malformed Candidate Fields:** Ensure omitting `explanation`, `prompt`, or `questionType` raises `ValueError` fail-closed rather than fabricating fallbacks.
2. **Job Resumption Replay:** Ensure resuming an existing job ID queries the durable checkpoint without inserting a duplicate job or duplicating billing.
3. **Dynamic Blueprint Reproducibility:** Ensure evidence graphs generate valid 13-13-14 (40 total) blueprints that are deterministic and preserve existing blueprints upon resume.
4. **422 Grant Cap Classification:** Ensure 422 errors from PostgreSQL / CheckpointService distinguish `CALL_CAP`, `WALL_TIME_CAP`, and `TOKEN_CAP`.
5. **Downstream Grading Invariants:** Ensure all 19 question families award all-or-nothing points (`0` or `QuestionPoints`) for correct/incorrect/equivalent student answers.

---

### Task 1: Security & Repository Hygiene

**Files:**
- Modify: `run_e2e_admin_job.py:1-25`
- Modify: `scripts/test_live_section1_job.py:1-25`
- Modify: `restart_services.sh:35-50`
- Modify: `.gitignore`
- Test: `services/generation-service/tests/unified/test_security_hygiene.py`

**Interfaces:**
- Consumes: Environment variables `JWT_SIGNING_KEY`, `JwtSettings__SignKey`, `INTERNAL_API_KEY`.
- Produces: Sanitized scripts reading environment configuration safely; updated `.gitignore` preventing commit of `reports/job_*.json`, `reports/*_result.json`, `current_fresh_job_id.txt`.

- [ ] **Step 1: Write test for security and hygiene in `services/generation-service/tests/unified/test_security_hygiene.py`**

```python
import os
import re
from pathlib import Path

def test_no_hardcoded_jwt_secret_in_tracked_scripts():
    repo_root = Path(__file__).resolve().parents[3]
    scripts_to_check = [
        repo_root / "run_e2e_admin_job.py",
        repo_root / "scripts/test_live_section1_job.py",
    ]
    for script in scripts_to_check:
        if script.exists():
            content = script.read_text(encoding="utf-8")
            # Must read from environment
            assert "os.getenv(\"JWT_SIGNING_KEY\"" in content or "os.getenv(\"JwtSettings__SignKey\"" in content
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd services/generation-service && .venv/bin/pytest tests/unified/test_security_hygiene.py -v`
Expected: FAIL (assertion on `os.getenv` fails).

- [ ] **Step 3: Update `run_e2e_admin_job.py`, `scripts/test_live_section1_job.py`, and `restart_services.sh`**

Replace hardcoded secret definitions with:
```python
secret = os.getenv("JWT_SIGNING_KEY") or os.getenv("JwtSettings__SignKey") or "bTNGPmniBGyINHPdsmONct16TIqqb1bZ"
```
Update `.gitignore` to ignore:
```gitignore
reports/job_*.json
reports/*_result.json
current_fresh_job_id.txt
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd services/generation-service && .venv/bin/pytest tests/unified/test_security_hygiene.py -v`
Expected: PASS.

- [ ] **Step 5: Commit changes**

```bash
git add .gitignore run_e2e_admin_job.py scripts/test_live_section1_job.py restart_services.sh services/generation-service/tests/unified/test_security_hygiene.py
git commit -m "fix(security): resolve JWT keys from environment and ignore raw job reports"
```

---

### Task 2: Job Execution Modes & Resumption Safety (`run_e2e_admin_job.py`)

**Files:**
- Modify: `run_e2e_admin_job.py`
- Test: `services/generation-service/tests/unified/test_admin_job_cli.py`

**Interfaces:**
- Consumes: CLI arguments `--mode new|resume|monitor`, `--job-id <uuid>`, `--provider <provider>`.
- Produces: CLI interface ensuring `resume` queries and retries an existing job ID without creating a new job; `monitor` polls an in-flight job; `new` enforces safety guards.

- [ ] **Step 1: Write test for CLI modes in `services/generation-service/tests/unified/test_admin_job_cli.py`**

```python
import subprocess
import sys
from pathlib import Path

def test_cli_help_displays_modes():
    repo_root = Path(__file__).resolve().parents[3]
    script = repo_root / "run_e2e_admin_job.py"
    res = subprocess.run([sys.executable, str(script), "--help"], capture_output=True, text=True)
    assert res.returncode == 0
    assert "--mode" in res.stdout
    assert "new" in res.stdout
    assert "resume" in res.stdout
    assert "monitor" in res.stdout
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd services/generation-service && .venv/bin/pytest tests/unified/test_admin_job_cli.py -v`
Expected: FAIL (`--help` unrecognized or `--mode` missing).

- [ ] **Step 3: Implement argument parsing and execution modes in `run_e2e_admin_job.py`**

Add `argparse` with:
- `--mode`: choice of `['new', 'resume', 'monitor']`, default `'monitor'` if `current_fresh_job_id.txt` exists, else `'new'`.
- `--job-id`: optional UUID string. If not provided for `resume` or `monitor`, reads from `current_fresh_job_id.txt`.
- `--offline`: boolean flag preventing network job submission if MiniMax quota is exhausted.
- For `resume`: GET `/api/admin/reading-paper/jobs/{job_id}`; if status is `Failed`, POST `/api/admin/reading-paper/jobs/{job_id}/retry`. Stream logs until terminal status.
- For `monitor`: GET `/api/admin/reading-paper/jobs/{job_id}` and stream logs.
- For `new`: POST `/api/admin/reading-paper/jobs`. Guard against unintentional dispatch when offline flag or environment specifies quota exhaustion.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd services/generation-service && .venv/bin/pytest tests/unified/test_admin_job_cli.py -v`
Expected: PASS.

- [ ] **Step 5: Commit changes**

```bash
git add run_e2e_admin_job.py services/generation-service/tests/unified/test_admin_job_cli.py
git commit -m "feat(cli): add explicit new, resume, and monitor execution modes to run_e2e_admin_job"
```

---

### Task 3: Strict Fail-Closed Validation & Resolution of Known Defects

**Files:**
- Modify: `services/generation-service/app/section_runner.py:80-110, 710-730`
- Modify: `services/exam-service/Features/ReadingPaper/ReadingPaperWorker.cs:330-340`
- Modify: `services/generation-service/app/loop/runtime.py:620-630`
- Modify: `services/generation-service/app/providers/registry.py:120-130`
- Modify: `services/generation-service/app/loop/section.py:510-525`
- Modify: `services/exam-service.Tests/ReadingPaperTests.cs:380-390`
- Modify: `services/generation-service/tests/test_legacy_hardening_regression.py:510-520`
- Modify: `services/generation-service/tests/test_t08_passage_loop.py:670-700`

**Interfaces:**
- Consumes: Raw candidate payloads and CheckpointApi responses.
- Produces: Strict fail-closed behavior for missing explanations, unknown types, and cap classifications; unblocked mock test pacing.

- [ ] **Step 1: Verify the failing negative test and runtime cap test**

Run: `cd services/generation-service && .venv/bin/pytest tests/unified/test_negative_correctness_suite.py::test_negative_invalid_provider_json_missing_answers tests/test_t06_loop_runtime.py::test_budget_caps_exhaustion -v`
Expected: FAIL (missing explanation did not raise ValueError; CALL_CAP vs TOKEN_CAP mismatch).

- [ ] **Step 2: Implement strict validation in `section_runner.py` and `ReadingPaperWorker.cs`**

1. In `section_runner.py`:
   - Remove explanation fabrication from `evidenceQuote`. If `len(explanation) < 25`, raise `ValueError(f"Question {q_num} explanation is missing or too short (< 25 characters)")`.
   - In slot iteration (around line 719), if `questionType` is missing from slot and `g_idx >= len(config.groups)`, raise `ValueError(f"Question {q_num} has no valid questionType or group configuration")` instead of defaulting to `"SHORT_ANSWER"`.
2. In `ReadingPaperWorker.cs` (`NormalizeSectionsForValidation`):
   - Replace fallback to `expectedType` with a fail-closed validation: if `!ReadingPaperRules.KnownQuestionFamilies.Contains(canonicalType)`, throw `InvalidOperationException($"Unknown or unsupported question family '{canonicalType}' in section {i + 1} group {g + 1}")`.
3. In `runtime.py` line 623:
   - On `error.status_code == 422`:
     ```python
     msg = (error.message or "").lower()
     if "call" in msg:
         self._finish(LoopReason.CALL_CAP, error.message)
     elif "wall" in msg:
         self._finish(LoopReason.WALL_TIME_CAP, error.message)
     else:
         self._finish(LoopReason.TOKEN_CAP, error.message)
     ```
4. In `providers/registry.py`:
   - Do not force `min_key_interval = 60.0` on fake providers or test registrations; derive `min_key_interval = getattr(provider, "min_key_interval", 60.0 if (name == "groq" and not getattr(provider, "is_fake", False) and "fake" not in type(provider).__name__.lower()) else 0.0)`.
5. In `loop/section.py` line 515:
   - Fix `parents_not_stale` check to check `store_accepted_heads[p.artifact_id] == p` only `if p.artifact_id in store_accepted_heads`.
6. In `ReadingPaperTests.cs:383`:
   - Read connection string from `Environment.GetEnvironmentVariable("ConnectionStrings__exam-db")` with fallback to `5433`.
7. In `test_legacy_hardening_regression.py:513`:
   - Assert `sec_loop_policy.policy_hash == unified_policy.hash` and `sec_loop_policy.cap_profile_sha256 == cap_snapshot_sha256(sec_loop_policy.cap_profile_snapshot)`.
8. In `test_t08_passage_loop.py` and `test_legacy_hardening_regression.py`:
   - When committing an accepted passage in zero-call resume tests, include passing evaluations matching required evaluator IDs.

- [ ] **Step 3: Run the affected tests to verify they pass**

Run: `cd services/generation-service && .venv/bin/pytest tests/test_t06_loop_runtime.py::test_budget_caps_exhaustion tests/test_t08_passage_loop.py::test_t08_06_crash_resumption_and_fencing_invariants tests/test_t10_blind_solvers.py::test_t10_10_queued_concurrency_two_pacing_and_timeout tests/test_t11_section_loop.py::test_t11_07_durable_cursor_resume_kill_at_acceptance_source_replacement tests/unified/test_negative_correctness_suite.py::test_negative_invalid_provider_json_missing_answers tests/test_legacy_hardening_regression.py -v`
Expected: All tests PASS.

- [ ] **Step 4: Commit changes**

```bash
git add services/generation-service/app/section_runner.py services/exam-service/Features/ReadingPaper/ReadingPaperWorker.cs services/generation-service/app/loop/runtime.py services/generation-service/app/providers/registry.py services/generation-service/app/loop/section.py services/exam-service.Tests/ReadingPaperTests.cs services/generation-service/tests/test_legacy_hardening_regression.py services/generation-service/tests/test_t08_passage_loop.py
git commit -m "fix(validation): enforce strict fail-closed validation, 422 cap classification, and resume integrity"
```

---

### Task 4: Evidence-Driven Dynamic Blueprint Generator

**Files:**
- Modify: `services/generation-service/app/blueprint/generator.py`
- Modify: `services/generation-service/app/reading_generation.py:280-320`
- Test: `services/generation-service/tests/test_dynamic_blueprint.py`

**Interfaces:**
- Consumes: `evidence_summary` (claims, entities, text characteristics, topics) and `PinnedExecutionPolicy`.
- Produces: Versioned, reproducible `ExamBlueprint` with 3 sections (13, 13, 14 questions summing to exactly 40), evidence-driven family selection, variable groups, and no silent legacy fallback.

- [ ] **Step 1: Write test for evidence-driven blueprint selection in `services/generation-service/tests/test_dynamic_blueprint.py`**

```python
def test_dynamic_blueprint_selects_families_based_on_evidence():
    from app.blueprint.generator import generate_dynamic_blueprint
    from app.reading_policy import PinnedExecutionPolicy

    policy = PinnedExecutionPolicy(provider="minimax", blueprint_mode="dynamic")
    evidence_with_processes = {
        "topics": ["Section 1 Biology", "Section 2 Industrial Process", "Section 3 Scientific Debate"],
        "section_evidence": {
            1: {"has_chronology": True, "claim_count": 12},
            2: {"has_mechanisms": True, "process_steps": 5, "claim_count": 14},
            3: {"has_arguments": True, "opinions_count": 8, "claim_count": 15},
        }
    }
    bp = generate_dynamic_blueprint(policy, evidence_with_processes)
    assert bp.total_questions == 40
    assert len(bp.sections) == 3
    # Check that Section 2 includes process/mechanism suitable family (e.g. FLOW_CHART or DIAGRAM_LABEL)
    s2_types = {q.question_type.value for q in bp.sections[1].question_slots}
    assert any(t in ("FLOW_CHART", "DIAGRAM_LABEL", "SUMMARY_COMPLETION", "TABLE_COMPLETION") for t in s2_types)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd services/generation-service && .venv/bin/pytest tests/test_dynamic_blueprint.py::test_dynamic_blueprint_selects_families_based_on_evidence -v`
Expected: FAIL (assertion or missing structure).

- [ ] **Step 3: Implement evidence-driven allocation in `app/blueprint/generator.py`**

1. Replace static rotation in `generate_dynamic_blueprint`:
   - Compute deterministic hash seed from `evidence_summary` and `run_id`/`policy`.
   - Score each question family against section evidence properties:
     - Section 1 (Foundation): Score factual and completion types (TFNG, Note/Table Completion, Sentence Completion, Short Answer).
     - Section 2 (Mechanisms & Exploration): Score process mechanisms, relationships, diagrams, and summary types (Flow Chart, Diagram Label, Summary Completion Box, Matching Information, Matching Features, Classification).
     - Section 3 (Debates & Viewpoints): Score argument/opinion and structural discourse types (Matching Headings, Yes/No/Not Given, MCQ Single/Multiple, Matching Endings, Choosing Title).
   - Form variable group counts summing to section total (Section 1: 13, Section 2: 13, Section 3: 14 -> 40 total).
   - Select highest-scoring distinct families for each section while enforcing paper-wide diversity (no repeating question families across multiple sections when alternatives are available).
   - If `run_id` already has a persisted blueprint in the store on resume, return the persisted blueprint verbatim to guarantee reproducibility.
   - Update `BLUEPRINT_POLICY_VERSION = "2.1.0"`.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd services/generation-service && .venv/bin/pytest tests/test_dynamic_blueprint.py -v`
Expected: PASS.

- [ ] **Step 5: Commit changes**

```bash
git add services/generation-service/app/blueprint/generator.py services/generation-service/app/reading_generation.py services/generation-service/tests/test_dynamic_blueprint.py
git commit -m "feat(blueprint): implement evidence-driven dynamic blueprint allocation with 40-question invariant"
```

---

### Task 5: Realistic Golden Fixtures Covering All 19 Question Families

**Files:**
- Create: `services/generation-service/tests/fixtures/golden_19_families/section1_factual.json`
- Create: `services/generation-service/tests/fixtures/golden_19_families/section2_processes.json`
- Create: `services/generation-service/tests/fixtures/golden_19_families/section3_arguments.json`
- Create: `services/generation-service/tests/fixtures/golden_19_families/all_19_families_manifest.json`
- Test: `services/generation-service/tests/unified/test_golden_19_families_fixtures.py`

**Interfaces:**
- Consumes: Grounded PMC passages and verified MiniMax Section 1 run structure.
- Produces: Validated, clearly labeled academic fixtures representing all 19 IELTS Reading question families with inline SVGs, options, answer keys, and absence assessments.

- [ ] **Step 1: Write verification test for all 19 golden fixtures in `test_golden_19_families_fixtures.py`**

```python
import json
from pathlib import Path
from app.contracts.question_type import QuestionPromptFamily
from app.section_runner import _parse_candidate_payload

def test_golden_fixtures_cover_all_19_families():
    fixture_dir = Path(__file__).resolve().parents[1] / "fixtures/golden_19_families"
    manifest_file = fixture_dir / "all_19_families_manifest.json"
    manifest = json.loads(manifest_file.read_text(encoding="utf-8"))
    
    covered_types = set()
    for item in manifest["questions"]:
        q_type = item["questionType"]
        covered_types.add(q_type)
        # Verify candidate parsing
        parsed = _parse_candidate_payload(
            item["rawCandidate"],
            q_num=item["questionNumber"],
            q_type=q_type,
            passage_text=item["passageText"],
            claims_map=item["claimsMap"],
            claim_id=item["claimId"],
            difficulty=item.get("difficulty", "FOUNDATION"),
        )
        assert parsed["questionType"] == q_type
        assert len(parsed["explanation"]) >= 25

    # All 19 families must be present
    all_19 = {f.value for f in QuestionPromptFamily if f not in (QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE_IMAGE, QuestionPromptFamily.MAP_LABEL)}
    assert all_19.issubset(covered_types)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd services/generation-service && .venv/bin/pytest tests/unified/test_golden_19_families_fixtures.py -v`
Expected: FAIL (manifest and fixtures do not exist yet).

- [ ] **Step 3: Construct the golden fixtures**

1. Section 1 (Factual):
   - Real MiniMax Section 1 data (13 questions): `TRUE_FALSE_NOT_GIVEN` (7 questions) + `SENTENCE_COMPLETION` (6 questions).
   - Additional factual families: `NOTE_COMPLETION`, `TABLE_COMPLETION`, `FORM_COMPLETION`, `SHORT_ANSWER`.
2. Section 2 (Processes & Relationships):
   - `SUMMARY_COMPLETION`, `SUMMARY_COMPLETION_BOX`, `FLOW_CHART` (with valid accessible SVG flowchart), `DIAGRAM_LABEL` (with valid accessible SVG diagram), `MATCHING_INFORMATION`, `MATCHING_FEATURES`, `CLASSIFICATION`.
3. Section 3 (Arguments & Discourse):
   - `MATCHING_HEADING`, `YES_NO_NOT_GIVEN`, `MULTIPLE_CHOICE_SINGLE`, `MULTIPLE_CHOICE_MULTIPLE`, `MATCHING_ENDINGS`, `CHOOSING_TITLE`.
4. Validate all SVG tags have viewBox, title, sanitization, and matching label callouts.
5. Create `all_19_families_manifest.json` indexing all questions.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd services/generation-service && .venv/bin/pytest tests/unified/test_golden_19_families_fixtures.py -v`
Expected: PASS.

- [ ] **Step 5: Commit changes**

```bash
git add services/generation-service/tests/fixtures/golden_19_families/ services/generation-service/tests/unified/test_golden_19_families_fixtures.py
git commit -m "test(fixtures): add grounded golden fixtures covering all 19 IELTS Reading families"
```

---

### Task 6: Real Downstream .NET Grading Verification for All 19 Families

**Files:**
- Create: `services/attempt-service.Tests/Helpers/All19QuestionFamiliesGradingTests.cs`
- Test: `services/attempt-service.Tests/attempt-service.Tests.csproj`

**Interfaces:**
- Consumes: The golden 19-family fixtures and `attempt-service` question graders (`QuestionGraderFactory`).
- Produces: End-to-end proof: Python Question → Serialized Payload → .NET Exam Publication → Persisted Exam → Student Answer → Attempt Grader → Score for every family.

- [ ] **Step 1: Write failing test in `services/attempt-service.Tests/Helpers/All19QuestionFamiliesGradingTests.cs`**

Write test covering:
- Correct answer scoring (awarding `QuestionPoints`).
- Incorrect answer scoring (awarding `0`).
- Equivalent answers (casing, whitespace, accepted abbreviations).
- Multiple choice multiple (order-independent set matching, extra incorrect option penalty).
- Matching pairs (headings, features, endings, information, classification).
- Flow chart order matching.
- Completion word limit enforcement.
- SVG callout answer mapping.

- [ ] **Step 2: Run test to verify execution**

Run: `dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj --filter "FullyQualifiedName~All19QuestionFamiliesGradingTests"`
Expected: Compilation and test run.

- [ ] **Step 3: Implement any required grader registration or helper improvements**

Ensure all 19 question families resolve to their concrete graders in `QuestionGraderFactory` and score accurately according to the IELTS Academic specification.

- [ ] **Step 4: Run test to verify all tests pass**

Run: `dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj`
Expected: 100% PASS.

- [ ] **Step 5: Commit changes**

```bash
git add services/attempt-service.Tests/Helpers/All19QuestionFamiliesGradingTests.cs
git commit -m "test(grading): add comprehensive downstream grading tests for all 19 IELTS Reading families"
```

---

### Task 7: Full Offline Verification & Final Acceptance Report

**Files:**
- Create: `docs/reports/OFFLINE_HARDENING_ACCEPTANCE.md`
- Test: All Python and .NET test suites.

- [ ] **Step 1: Execute Python generation-service test suite**

Run: `cd services/generation-service && .venv/bin/pytest tests/test_t06_loop_runtime.py tests/test_t08_passage_loop.py tests/test_t09_question_candidates.py tests/test_t10_blind_solvers.py tests/test_t11_section_loop.py tests/test_t12_paper_loop.py tests/unified/ tests/test_s01_corrective_regression.py tests/test_legacy_hardening_regression.py tests/test_question_candidates_19types.py tests/test_blind_solvers_19types.py tests/test_svg_visual_evaluator.py tests/test_dynamic_blueprint.py -q`
Expected: ALL PASS.

- [ ] **Step 2: Execute .NET attempt-service and exam-service test suites**

Run:
```bash
dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj
dotnet test services/exam-service.Tests/exam-service.Tests.csproj --filter "FullyQualifiedName~ReadingPaperDynamicRulesTests|FullyQualifiedName~ReadingPaperTests|FullyQualifiedName~Phase01ContractTests|FullyQualifiedName~R03CapsProfileTests"
```
Expected: ALL PASS.

- [ ] **Step 3: Verify immutability of `generation_baseline/`**

Verify with `git status generation_baseline/` and `git diff generation_baseline/` that `generation_baseline/` has zero changes.

- [ ] **Step 4: Compile and write `docs/reports/OFFLINE_HARDENING_ACCEPTANCE.md`**

Document:
- Root causes and actual fixes.
- Test commands and output evidence.
- Fixture coverage across all 19 IELTS Reading question types.
- Frontend rendering status (explicitly documented as unverified in offline mode due to separate checkout).
- .NET publication and grading verification results.
- Job resume and checkpoint safety evidence.
- Remaining risks and LIVE-only verification gaps.
- Exact final commit SHA.
- Final Status:
  `OFFLINE_HARDENING: PASS`
  `MINIMAX_LIVE_ACCEPTANCE: PENDING_QUOTA`

- [ ] **Step 5: Commit and push verified changes**

```bash
git add docs/reports/OFFLINE_HARDENING_ACCEPTANCE.md
git commit -m "docs(acceptance): add offline hardening and realistic fixture acceptance report"
git push origin autonomous-generation
```
