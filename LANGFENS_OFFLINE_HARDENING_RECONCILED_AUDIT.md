# LANGFENS — OFFLINE HARDENING RECONCILED AUDIT REPORT

**Document ID:** `REPORT-2026-10-22-OFFLINE-HARDENING-RECONCILED-AUDIT`  
**Location:** `LANGFENS_OFFLINE_HARDENING_RECONCILED_AUDIT.md` (Untracked report file)  
**Role:** Senior Verification & Reliability Engineer  
**Repository:** `minkhoaa/Project_Langfens_Microservice`  
**Branch:** `autonomous-generation`  
**Audited Commit SHA:** `abfae42c62fa063033cd83a626e2bc8f3edebd3a`  
**Parent Commit SHA:** `5f6c2ad4a0d9e830e25539ff8e7d23a7806527ba`  
**Mode:** STRICT OFFLINE REVERIFICATION & AUDIT RECONCILIATION  
**Security Hygiene Notice:** All cryptographic secrets and signing keys are fully redacted in this document.

---

## 1. Executive Summary & Acceptance Verdict

This report presents the authoritative, evidence-backed reverification and reconciliation of the disputed findings from the prior independent audit of the Autonomous IELTS Academic Reading Generation Harness.

The prior audit classified 17 hypotheses as confirmed defects. However, several conclusions were inaccurate or overstated—most notably regarding production question offset evaluator bypass (H18), blueprint determinism root causes (H07), and concurrent retry atomicity. Every hypothesis was re-evaluated against the production execution paths, concrete code implementations, and reproducible test executions under strict offline constraints.

### Authoritative Acceptance Decision
```text
======================================================
FINAL HARNESS RECONCILED AUDIT STATUS:
  OFFLINE_HARDENING:        BLOCKED
  MINIMAX_LIVE_ACCEPTANCE:  PENDING_QUOTA
======================================================
```

**Justification for `OFFLINE_HARDENING: BLOCKED`:**
Although the downstream .NET question graders (125 tests) and core contract parsing (87 tests) are verified, and 253 Python component tests pass in isolation, the harness cannot receive an unconditional PASS due to four confirmed blocking defects:
1. **Offline Safety Breach (H02):** `run_e2e_admin_job.py --mode resume --offline` fails to respect the `--offline` flag when resuming a `Failed` job. Lines 133–144 unconditionally issue `POST /api/admin/reading-paper/jobs/{id}/retry`, resetting the job status to `Pending` and making it immediately eligible for background worker acquisition, risking live provider spend in offline mode.
2. **Golden Fixture Grounding Flaws (H08, H09):** In `tests/fixtures/golden_19_families/all_19_families_manifest.json`, Q1 is labeled `minimax_live_accepted` but contains a paraphrased quote not present in the passage text (`startChar: -1, endChar: -1`), causing it to fail `eval_evidence_offsets`. Q8 has a truncated evidence span (`"In Southeast Asian seas"`) that completely omits the answer `"20"`, causing it to fail `eval_question_semantic`.
3. **Blueprint Reproducibility Hash Drift (H07):** In `services/generation-service/app/reading_generation.py:358-360`, `build_blueprint` serializes `dyn_bp` to JSON without stripping the volatile `createdAt` timestamp and without stripping the nested `contentHash` computed during the generator stage. As a result, two consecutive calls with identical pinned inputs produce drifting `contentHash` values (`PROVEN_NONDETERMINISTIC` in its current serialization implementation).
4. **Security & Key Hygiene (H01, H14, H15):** Plaintext signing secrets (`[REDACTED]`) remain embedded as silent fallbacks in `run_e2e_admin_job.py:13`, `scripts/test_live_section1_job.py:8`, and `restart_services.sh:36`. Additionally, 26 raw job result JSON files remain actively tracked in Git index despite `.gitignore` entries.

---

## 2. Reverification Environment & Test Evidence

All verification commands were executed strictly offline using local Python 3.14.8 venv, .NET 10 SDK, in-memory/mock transports, and isolated database targets. Zero live provider calls (MiniMax/Groq/Ollama) were made.

| Test Suite | Working Directory | Command Executed | Tests Run | Passed | Failed | Skipped | Duration | Isolation / Transport |
|---|---|---|---|---|---|---|---|---|
| **Python Generation Harness** | `services/generation-service` | `.venv/bin/pytest tests/test_t06_loop_runtime.py tests/test_t08_passage_loop.py tests/test_t09_question_candidates.py tests/test_t10_blind_solvers.py tests/test_t11_section_loop.py tests/test_t12_paper_loop.py tests/unified/ tests/test_s01_corrective_regression.py tests/test_legacy_hardening_regression.py tests/test_question_candidates_19types.py tests/test_blind_solvers_19types.py tests/test_svg_visual_evaluator.py tests/test_dynamic_blueprint.py tests/test_r03_runtime_caps.py` | 253 | 253 | 0 | 0 | 125.19s | Python 3.14.8, Mock Gateway, No Network |
| **.NET Attempt Graders** | `services/attempt-service.Tests` | `dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj` | 125 | 125 | 0 | 0 | 108 ms | .NET 10.0, In-Memory Strategy Graders |
| **.NET Exam Contracts & Dynamic Rules** | `services/exam-service.Tests` | `dotnet test services/exam-service.Tests/exam-service.Tests.csproj --filter "ReadingPaperDynamicRulesTests\|ReadingPaperTests\|Phase01ContractTests\|R03CapsProfileTests"` | 87 | 87 | 0 | 0 | 3.0 s | .NET 10.0, Safe filtered subset |
| **Full Exam DB Suite** | `services/exam-service.Tests` | *Filtered out per AGENTS.md* | N/A | N/A | N/A | N/A | N/A | Destructive fixtures (`DROP SCHEMA ... CASCADE`) avoided |
| **TOTAL INDEPENDENTLY VERIFIED** | Monorepo | | **465** | **465** | **0** | **0** | **~128s** | Strict Offline |

---

## 3. Disputed Hypotheses Reconciliation Matrix (H01 – H18)

| ID | Hypothesis Description | Original Audit Claim | Actual Observed Production Reality | Reconciled Classification | Impact on Acceptance |
|---|---|---|---|---|---|
| **H01** | Hardcoded JWT fallback in scripts | Unsetting env vars generates valid tokens via hardcoded secret. | Confirmed. `run_e2e_admin_job.py:13` and `scripts/test_live_section1_job.py:8` execute `os.getenv(...) or "[REDACTED]"`. | **CONFIRMED_DEFECT** | Critical Key Hygiene Failure |
| **H02** | Offline resume triggers `/retry` | `--offline` resume dispatches `POST /retry` on Failed jobs, triggering provider spend. | Confirmed. Line 87 only guards `mode == "new"`. Lines 133–144 unconditionally send `POST /retry` on Failed jobs. | **CONFIRMED_DEFECT** | Mandatory Offline Guard Failure |
| **H03** | Unsafe implicit NEW mode default | CLI defaults to `--mode new` instead of safe monitor. | Confirmed. `run_e2e_admin_job.py:52` defines `default="new"`. Omitting flags triggers live job submission. | **CONFIRMED_DEFECT** | Operational Hazard |
| **H04** | Evidence-independent group allocation | Question group counts in `generator.py` ignore passage evidence. | Confirmed. `_determine_section_group_counts(sec_id, sec_evidence, seed_int)` takes `sec_evidence` but never reads it. | **CONFIRMED_DEFECT** | Algorithmic Dead Code |
| **H05** | Topic-driven family selection | Dynamic blueprint scores families on topic keywords because no section evidence is passed. | Confirmed. `reading_generation.py:285` passes `evidence_summary` without `section_evidence`. `generator.py:145` scores on topic string alone. | **CONFIRMED_DEFECT** | Planning Evidence Disconnect |
| **H06** | Semantically weak claim binding | Claims bound via rotating modulo; empty claims fabricate synthetic IDs. | Confirmed. `reading_generation.py:304` binds claims via `(q_num - 1) % len(claims)` and defaults to `claim:{run_id}:{sec_idx}:1`. | **CONFIRMED_DEFECT** | Grounding Defect |
| **H07** | Blueprint reproducibility & hash drift | Blueprint is non-deterministic because generator assigns random `blueprint_id` and does not pop `createdAt`. | **CORRECTED.** The raw generator UUID does NOT reach production (`build_blueprint` overrides `blueprint_id` and `run_id` deterministically). Allocations, slots, and claim bindings ARE 100% deterministic. However, the serialized `contentHash` drifts because `reading_generation.py` hashes `createdAt` and the nested `contentHash`. | **CONFIRMED_DEFECT** (Root Cause Corrected) | Reproducibility Defect |
| **H08** | Fixture grounding & provenance (Q1) | Q1 has fabricated FALSE statement, paraphrase quote not in passage (`[-1:-1]`), and false `minimax_live_accepted` label. | **CORRECTED.** The statement in Q1 IS semantically contradicted by the passage (FALSE is justified). However, the evidence quote was paraphrased, producing `startChar: -1, endChar: -1` which fails `eval_evidence_offsets`. Provenance is mislabeled. | **CONFIRMED_DEFECT** (Nuance Corrected) | Grounding Defect |
| **H09** | Fixture evidence quote truncation (Q8) | Evidence span for Q8 omits answer `"20"` and fails offset evaluator. | **CORRECTED.** Parser clause splitting truncated the quote to `"In Southeast Asian seas"`, which omits the answer `"20"`. Evaluator failure is semantic insufficiency (`UNSUPPORTED_OR_CONTRADICTED_CLAIM`), not offset boundary failure. | **CONFIRMED_DEFECT** (Evaluator Identified) | Grounding Defect |
| **H10** | Fixture claim reference mismatch (Q16) | Claim `claim_p2_16` tests thermal tolerance while prompt tests trophic chemosynthesis. | Confirmed. The question content and evidence span are valid, but the metadata `claim_ref_ids` references an unaligned claim. | **CONFIRMED_DEFECT** | Metadata Inconsistency |
| **H11** | Missing shared-fixture cross-service tests | No automated test passes Python golden fixtures into .NET publication and grading pipeline. | Confirmed as an integration coverage gap. C# unit tests verify all 19 graders with synthetic objects (125/125 passing), but no cross-service deserialization test exists. | **CONFIRMED_DEFECT** | Integration Coverage Gap |
| **H12** | Missing 40-question full paper dynamic acceptance | 40-question paper verified on legacy preset, but dynamic 19-family paper is missing. | Confirmed. `reading_paper_valid.json` proves 40-question invariants for the 6-type preset. Dynamic 19-family golden fixture has 19 items. | **PARTIAL** | Coexistence Gap |
| **H13** | Preflight import defect | `scripts/test_live_section1_job.py` omits `import os`, crashing on execution. | Confirmed. Line 1 lacks `import os`; calling `create_admin_jwt()` raises `NameError: name 'os' is not defined`. | **CONFIRMED_DEFECT** | Script Bug |
| **H14** | Plaintext credentials in restart script | `restart_services.sh` hardcodes secrets in plaintext. | Confirmed. Lines 36–39 contain plaintext secrets (`[REDACTED]`). | **CONFIRMED_DEFECT** | Operational Hygiene Defect |
| **H15** | Tracked reports in git index | 26 raw job result JSON files remain tracked in Git index despite `.gitignore`. | Confirmed. `git ls-files reports/job_*.json` returns 26 tracked files. | **CONFIRMED_DEFECT** | Repository Hygiene Defect |
| **H16** | CLI/API retry eligibility mismatch | CLI sends `POST /retry` for `NeedsSources`, which server rejects with HTTP 409. | Confirmed. Server `ReadingPaperEndpoints.cs:282` strictly requires `Status == "Failed"`. | **CONFIRMED_DEFECT** | State Machine Mismatch |
| **H17** | Stale commit SHA in report | `OFFLINE_HARDENING_ACCEPTANCE.md` cites non-existent SHA `3cd5149`. | Confirmed. Current HEAD is `abfae42c...`; parent is `5f6c2ad4...`. SHA `3cd5149` does not exist in git log. | **CONFIRMED_DEFECT** | Documentation Defect |
| **H18** | Evaluator registration and reachability | `EvidenceOffsetEvaluator` was never registered and question offsets bypassed validation globally. | **DISPROVED & RECONCILED.** False claim of global production bypass. In the production pipeline (`SectionRunner -> StageExecutor`), `reading_evaluation.evaluate_question()` strictly validates offsets, produces `eval_evidence_offsets`, and `StageExecutor` enforces it fail-closed. However, `Facade.run_question_loop` and `QuestionCandidateLoop` secondary registries omit it, and `AnswerVerbatimAndLengthEvaluator` omits completion types. | **PARTIAL** (Production Path Secure; Subsystem Discrepancies) | Non-Blocking in Production, Quality Gap |

---

## 4. In-Depth Technical Reverification

### 4.1. H07 — Blueprint Reproducibility & Content Hash Drift

#### Test Methodology
`build_blueprint` was executed twice consecutively in `services/generation-service` with identical pinned inputs:
- Run ID: `test_run_repro_12345`
- Policy: `PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic")`
- Topic: `"Marine Biology"`
- Sections: `(1, 2, 3)`
- Pinned Evidence: Verified claims, graph IDs, and hashes for sections 1, 2, and 3.

#### Runtime Observations
```text
Blueprint 1 contentHash: 5a15a7bc9e5c8ff4ab63ed3e56316d8dad42010c9579a8e7bc0bd11a430e1d5f
Blueprint 2 contentHash: b753e5eaf9054205c067a35062d05a39d54cfcbe4d59d2e7aab80d61bc3ce32d
contentHash matches?:    False

bp1 blueprintId:         blueprint:test_run_repro_12345
bp2 blueprintId:         blueprint:test_run_repro_12345
bp1 runId:               test_run_repro_12345
bp2 runId:               test_run_repro_12345
bp1 createdAt:           2026-10-22T09:11:16.332049Z
bp2 createdAt:           2026-10-22T09:11:16.383748Z

Top-level diff keys:     ['contentHash', 'createdAt']
Sections equal (allocations, slots, claim bindings)?: True
```

#### Precise Root Cause Analysis
1. **The prior audit's claim that random generator UUIDs reach production is disproved:** In `reading_generation.py:344-345`, `dyn_bp` has its `blueprint_id` overwritten with `f"blueprint:{run_id}"` and `run_id` overwritten with `run_id`.
2. **All question allocations, difficulty assignments, group counts, and claim bindings are 100% deterministic.**
3. **The cause of hash drift is volatile field leakage during serialization:** In `reading_generation.py:358-360`:
   ```python
   canonical_dict = dyn_bp.model_dump(mode="json", by_alias=True)
   canonical_json = json.dumps(canonical_dict, sort_keys=True, separators=(",", ":"))
   content_hash = hashlib.sha256(canonical_json.encode("utf-8")).hexdigest()
   ```
   `canonical_dict` contains `createdAt` (generated via `datetime.now(timezone.utc)`) and the nested `contentHash` (generated in `generator.py` over an ephemeral UUID). Because neither `createdAt` nor `contentHash` is popped before `canonical_json` is produced, the resulting hash differs across runs.
4. **Normalized Invariance Proof:** When `createdAt` and `contentHash` are popped from `canonical_dict`, the normalized content hash is 100% stable:
   - `Normalized hash bp1`: `71dff1117dd050d031ac917102b1fa0f5c74bb953366547c762db2249689f362`
   - `Normalized hash bp2`: `71dff1117dd050d031ac917102b1fa0f5c74bb953366547c762db2249689f362`
   - Match: `True`
5. **Dependency Invalidation Proof:** Mutating Section 1 evidence graph (`g1_v2`, `claim_1_altered`) changes the normalized content hash to `89b70d6b0181781d6ee633fa8b6d29fb3de972bee9222a4eba1ecd58c3e70105`, verifying proper invalidation tracking.
- **Verdict:** **PROVEN_NONDETERMINISTIC** (in current un-popped serialization).

---

### 4.2. H08–H10 — Golden Fixture Grounding Analysis

The 19 golden family records in `tests/fixtures/golden_19_families/all_19_families_manifest.json` were audited by parsing through `_parse_candidate_payload` and evaluating through `reading_evaluation.evaluate_question`:

#### Case Q1 (`TRUE_FALSE_NOT_GIVEN`):
- **Candidate Statement:** *"Lux meters are considered a globally recognized standard for monitoring biologically active light."*
- **Passage Text:** *"...There is no globally recognized standard for monitoring biologically active light, and the tools commonly used, such as lux meters, often fail to account for the full spectrum of light wavelengths that are biologically relevant..."*
- **Candidate Quote:** `"lux meters, while useful for human visual perception, are biologically irrelevant for measuring ecological light pollution"`
- **Semantic Finding:** The passage explicitly states there is no standard and lux meters fail to account for biologically relevant light. Therefore, the answer **`FALSE` is semantically justified**.
- **Quote Alignment Finding:** The raw candidate quote was paraphrased and does not exist in the passage text. The parser returned `startChar: -1, endChar: -1`.
- **Evaluator Outcome:** `eval_evidence_offsets` returns `FAIL` with `EVIDENCE_MISSING: Question has no exact passage offsets and verified claim identity`.
- **Provenance:** Mislabeled as `minimax_live_accepted`. In the true resumed live run (`reports/resumed_job_result.json`), Q1 was a TRUE question regarding ALAN expansion.

#### Case Q8 (`SENTENCE_COMPLETION`):
- **Candidate Prompt:** *"In Southeast Asian seas, ALAN penetrates to approximately [8] meters."*
- **Candidate Answer:** `"20"`
- **Passage Text (pos 1238–1370):** *"...In Southeast Asian seas, such as the Gulf of Thailand and the South China Sea, ALAN penetrates to approximately 20 meters..."*
- **Candidate Quote:** `"In Southeast Asian seas, biologically meaningful artificial light was found to penetrate to depths of approximately 20 meters."`
- **Parser Normalization Finding:** Because the raw quote was paraphrased, `_parse_candidate_payload` fell back to matching the longest clause `>= 20` characters: `"In Southeast Asian seas"` (`startChar: 1238, endChar: 1261`).
- **Semantic Finding:** The answer `"20"` occurs at pos 1361. The normalized span `[1238:1261]` completely omits `"20"`.
- **Evaluator Outcome:** `eval_evidence_offsets` passed (the truncated string exists in the passage), but `eval_question_semantic` failed with:
  `UNSUPPORTED_OR_CONTRADICTED_CLAIM: Completion answer is not contained in the evidence quote`.

#### Case Q16 (`CLASSIFICATION`):
- **Candidate Prompt:** *"Classify the following adaptation: converts hydrogen sulfide into chemical energy"*
- **Candidate Answer:** `A. Primary chemotrophs`
- **Passage Evidence:** `"Chemosynthetic bacteria form the primary trophic foundation converting hydrogen sulfide into cellular energy."` (`[100:209]`)
- **Assigned Claim Reference (`claim_p2_16`):** *"Researchers classify benthic fauna into distinct physiological groupings based on thermal tolerance."*
- **Finding:** The question prompt, options, answer, and evidence quote are completely aligned and pass all question evaluators. However, the metadata reference `claim_ref_ids` was bound to an unrelated claim (thermal tolerance vs trophic chemosynthesis).

#### 19-Family Fixture Summary:
- **16 of 19 fixtures** pass 100% of production evaluators (`eval_question_structure`, `eval_answer_verbatim_length`, `eval_evidence_offsets`, `eval_question_uniqueness`, `eval_question_semantic`).
- **Q1** fails `eval_evidence_offsets` (`EVIDENCE_MISSING`).
- **Q8** fails `eval_question_semantic` (`UNSUPPORTED_OR_CONTRADICTED_CLAIM`).
- **Q16** has a metadata claim reference mismatch.

---

### 4.3. H18 — Evaluator Registration & Reachability Matrix

The prior audit asserted:
> *"EvidenceOffsetEvaluator is implemented in deterministic.py:710 but is never registered in QuestionLoop, PaperLoop, or Facade. Consequently, question artifacts with missing evidence or invalid offsets ([-1:-1]) are admitted as valid in production."*

This claim conflated secondary loop classes with the authoritative production execution path.

#### Path-by-Path Execution Matrix:

| Execution Path | Evaluator Registry / Implementation | Offset Check Required? | Offset Check Executed? | Can Invalid Question (e.g. `[-1:-1]`) Reach ACCEPTED State? | Empirical Verification Evidence |
|---|---|---|---|---|---|
| **Authoritative Production Pipeline** (`.NET -> /execute -> Pipeline -> SectionRunner -> StageExecutor`) | `reading_evaluation.evaluate_question()` called inside `evaluate_question_stage`; wrapped by `StageEvalSingleAdapter("eval_evidence_offsets")` in `StageExecutor` | **YES** (`STAGE_REQUIRED_EVALUATORS[ArtifactType.QUESTION]`) | **YES** | **NO (REJECTED)** | Execution test injecting Q1 (`startChar: -1, endChar: -1`) into `StageExecutor.execute` raised `EvaluationRejectedError`. Valid Q2 was accepted. |
| **Facade Question Loop** (`GenerationFacade.run_question_loop`) | Fresh `EvaluatorRegistry()` instantiated in `facade.py:316-320` registering: `QuestionStructure`, `AnswerVerbatimAndLength`, `AmbiguityAndDistractor`, `NotGivenSemantics`. | **NO** (`EvidenceOffsetEvaluator` omitted) | **NO** | **YES** (Subsystem Only) | Code inspection of `app/facade.py:316-320`. Note: Path is uncalled in production and test suites. |
| **Standalone QuestionCandidateLoop** (`QuestionCandidateLoop.__init__`) | Fallback registry in `app/loop/question.py:74-79` registering: `QuestionStructure`, `AnswerVerbatimAndLength`. | **NO** (`required_evaluator_ids` defaults to structure & verbatim) | **NO** | **YES** (Subsystem Only) | Inspected `app/loop/question.py:74-95`. Path is bypassed by `SectionRunner`. |
| **Facade Global Registry** (`GenerationFacade.__init__`) | Global registry registers `EvidenceOffsetEvaluator` (line 104). | Registered in container | Uncalled by per-request loops | N/A | Code inspection of `app/facade.py:104`. |

#### Schema Shape Discrepancy Note:
- `EvidenceOffsetEvaluator` in `deterministic.py` expects: `evidenceStart`, `evidenceEnd`, `evidenceQuote`.
- The candidate parser in `section_runner.py` produces: `passageEvidence: {startChar, endChar, text}` and `evidenceQuote`.
- `reading_evaluation.evaluate_question()` validates `passageEvidence.startChar` and `endChar`.
- In `AnswerVerbatimAndLengthEvaluator`, `_check_answer` only checks `SHORT_ANSWER`, `SENTENCE_COMPLETION`, and `SUMMARY_COMPLETION`, omitting `NOTE_COMPLETION`, `TABLE_COMPLETION`, and `FORM_COMPLETION`.

- **Verdict on H18:** **PARTIAL** (The production pipeline does enforce offset validation fail-closed and rejects invalid artifacts; however, `Facade.run_question_loop`, `QuestionCandidateLoop`, and schema field names exhibit genuine registry discrepancies).

---

### 4.4. Concurrent Retry Atomicity & Fencing

#### Code Inspection (`ReadingPaperEndpoints.cs:282-297`):
```csharp
private static async Task<IResult> Retry(Guid id, ExamDbContext db, CancellationToken ct)
{
    var job = await db.ReadingPaperJobs.FirstOrDefaultAsync(x => x.Id == id, ct);
    if (job is null) return Results.NotFound();
    if (job.Status != "Failed" || job.ExamId is not null)
        return Results.Conflict(new { error = "Only a failed, unsaved job can be retried" });
    job.Status = "Pending";
    job.Error = null;
    job.LeaseUntil = null;
    job.LeaseOwner = null;
    job.UpdatedAt = DateTime.UtcNow;
    job.Logs += SerializeLog("Information", "Retry requested; the worker will resume from the last saved passage.");
    await db.SaveChangesAsync(ct);
    return Results.Ok(View(job));
}
```

#### Technical Vulnerability Analysis:
1. **No Optimistic Concurrency Check:** `ReadingPaperJob` has no `[ConcurrencyCheck]`, `[Timestamp]`, or `xmin` mapping.
2. **No Atomic Conditional Update:** `Retry` uses standard EF Core tracking (`FirstOrDefaultAsync` + `SaveChangesAsync`). EF Core generates an update with `WHERE id = @id`, without checking `Status == "Failed"` or matching `Epoch`.
3. **Contrast with `Cancel` Endpoint:** The `Cancel` endpoint in lines 315–330 of the same file uses `ExecuteUpdateAsync` with an explicit CAS predicate:
   ```csharp
   .Where(x => x.Id == id && (x.Status == "Pending" || x.Status == "Running" || x.Status == "NeedsSources") &&
               x.CancelVersion == expectedCancelVersion && x.Epoch == expectedEpoch)
   ```
4. **Race Condition Outcome:** If two requests arrive concurrently for the same `Failed` job:
   - Both read `Status == "Failed"`.
   - Both update `Status = "Pending"`.
   - Both return **HTTP 200 OK**.
   - Neither receives HTTP 409 Conflict.
5. **Worker-Level Protection:** Downstream in `ReadingPaperWorker.cs:41-47`, job acquisition IS protected by atomic `ExecuteUpdateAsync`:
   ```csharp
   .Where(x => x.Id == id && (x.Status == "Pending" || (x.Status == "Running" && x.LeaseUntil < now)))
   .ExecuteUpdateAsync(x => x.SetProperty(j => j.Status, "Running").SetProperty(j => j.Epoch, j => j.Epoch + 1)...)
   ```
   Thus, even if dual retries occur at the API edge, only ONE worker can claim the job lease. Duplicate execution or publication is prevented by worker-level fencing.
6. **Classification:** Per user guidelines (no disposable DB test executed in this session), concurrent retry atomicity is classified as:  
   **`CONCURRENT_RETRY_VERIFICATION: NOT_VERIFIED`** (Code analysis indicates an unprotected API race condition, but worker-level fencing mitigates duplicate execution).

---

## 5. Summary of Findings Reconciled

| Category | Count | Finding IDs |
|---|---|---|
| **Disputed Findings Confirmed** | 15 | H01, H02, H03, H04, H05, H06, H08, H09, H10, H11, H13, H14, H15, H16, H17 |
| **Disputed Findings Corrected / Disproved** | 3 | H07 (root cause corrected), H12 (classified as PARTIAL), H18 (production bypass disproved; corrected to PARTIAL) |
| **Disputed Findings Unresolved / Not Verified** | 1 | Concurrent Retry Atomicity (classified as NOT_VERIFIED per guidelines) |

---

## 6. Minimal Remediation Scope (Supported by Evidence)

To unblock offline hardening acceptance (`OFFLINE_HARDENING: PASS`), the following minimal corrections are required:

1. **Fix Offline Resume Safety (`run_e2e_admin_job.py`):**
   - Add offline check in `mode == "resume"`: block `POST /retry` when `args.offline` is True.
   - Do not send `POST /retry` when status is `NeedsSources` (prompt user to update sources via `PUT /sources`).
   - Change default `--mode` from `"new"` to `"monitor"` or require explicit mode flag.
2. **Remove Hardcoded Key Fallbacks:**
   - Remove plaintext signing key fallback in `run_e2e_admin_job.py` and `scripts/test_live_section1_job.py`. Raise explicit error when unset.
   - Add `import os` to `scripts/test_live_section1_job.py`.
   - Resolve credentials in `restart_services.sh` from environment variables.
3. **Purge Tracked Report Files from Git Index:**
   - Run `git rm --cached reports/job_*.json reports/demo_*.json reports/*_result.json` to enforce `.gitignore`.
4. **Fix Golden Fixtures (Q1, Q8, Q16):**
   - **Q1:** Replace paraphrased quote with exact passage quote (`"There is no globally recognized standard for monitoring biologically active light, and the tools commonly used, such as lux meters, often fail to account for the full spectrum of light wavelengths that are biologically relevant."`) and update offsets to `[4441:4654]`.
   - **Q8:** Update evidence quote and span to include `"20"`: `"In Southeast Asian seas, such as the Gulf of Thailand and the South China Sea, ALAN penetrates to approximately 20 meters."` (`[1238:1367]`).
   - **Q16:** Update `claim_ref_ids` to reference the passage claim addressing chemosynthetic trophic energy conversion.
5. **Harden Blueprint Determinism (`reading_generation.py`):**
   - In `reading_generation.py:358-360`, pop `createdAt` and `contentHash` from `canonical_dict` before computing `hashlib.sha256(canonical_json.encode())`.
   - Pass `section_evidence` from `evidence_map` into `generate_dynamic_blueprint`.
6. **Unify Evaluator Registry & Schema Field Names:**
   - Register `EvidenceOffsetEvaluator` in `Facade.run_question_loop` and `QuestionCandidateLoop`.
   - Support `passageEvidence.startChar/endChar` in `EvidenceOffsetEvaluator`.
   - Add `NOTE_COMPLETION`, `TABLE_COMPLETION`, and `FORM_COMPLETION` to `AnswerVerbatimAndLengthEvaluator`.
7. **Harden Retry Endpoint with CAS:**
   - In `ReadingPaperEndpoints.Retry`, replace tracking update with `ExecuteUpdateAsync` checking `x.Status == "Failed"`.

---

## 7. Final Deliverable Summary

- **Audited HEAD:** `abfae42c62fa063033cd83a626e2bc8f3edebd3a`
- **Disputed findings confirmed:** 15
- **Disputed findings corrected/disproved:** 3
- **Disputed findings unresolved:** 1
- **Concurrent retry verification:** `NOT_VERIFIED`
- **Independent test evidence:** 465 passed (253 Python, 125 attempt-service, 87 exam-service)
- **Status:**  
  - **`OFFLINE_HARDENING: BLOCKED`**  
  - **`MINIMAX_LIVE_ACCEPTANCE: PENDING_QUOTA`**
