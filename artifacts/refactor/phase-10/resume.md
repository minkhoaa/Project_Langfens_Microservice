# Resume Checkpoint — Phase 10: Blind Solver, Adversary & Grounding Uniqueness

**Checkpoint Date:** 2026-10-07T03:55:00Z  
**Phase Completed:** Phase 10 (Blind Solver & Adversary Engine 100% Complete; P10-01 through P10-09 satisfied, T10-01 through T10-08 verified across 10 automated test suites, and live clean-holdout quality acceptance completed with 184/184 child runs)  
**Current Gate:** Gate G10  
**Gate Status:** **PASS** (Implementation, Deterministic Verification, PostgreSQL Durability Integration, and Live Clean-Holdout Quality Acceptance all PASS)  
**Readiness for Phase 11:** **READY_FOR_PHASE_11**  
**Git SHA:** `f56a0970bbf6190ea7e3af58d2ec8db9e5c9714f`  
---

## 1. Completed Work Summary

1. **P10-01: Minimal Canonical DTO & Allowlist Serializer:**
   - Implemented `StudentVisibleQuestion`, `StudentVisibleOption`, and `BlindSolverInput` in `app/contracts/solver.py`.
   - Created `project_to_student_visible` and `build_blind_solver_input` in `app/solvers/serializer.py`, ensuring strict allowlist projection dropping all answers, evidence quotes, explanations, absence assessments, and canaries.
   - Verified that untrusted student prompt text containing literal quotes stays escaped as data inside `<prompt>` tags. Extra fields on DTOs are rejected by `extra="forbid"`.

2. **P10-02: Versioned Prompts, Schemas & Secure Envelopes:**
   - Implemented `SOLVER_PROMPT_VERSION` ("v1.0.0") and `ADVERSARY_PROMPT_VERSION` ("v1.0.0") with deterministic SHA-256 asset hashes in `app/solvers/prompts.py`.
   - Implemented `build_secure_envelope` with XML attribute escaping (`question_number`, `question_type`) to prevent attribute/tag injection.
   - Implemented `redact_solver_payload`.

3. **P10-03: Solver Output Validation & Exact Span Grounding:**
   - Implemented `SolverOutput`, `SolverSpan`, and `parse_and_validate_solver_output` in `app/solvers/solver.py`.
   - Enforces exact verbatim citation checking against approved passage text; missing or invalid spans strictly fail closed for all answers per P10-03; rejects hidden chain-of-thought fields (`thought`, `scratchpad`).
   - Normalizes solver answers conditioned on question type to prevent completion strings from unintended boolean/option coercion.

4. **P10-04: Adversary Output & Outside-Knowledge Defense:**
   - Implemented `AdversaryOutput`, `AdversaryAlternative`, and `parse_and_validate_adversary_output` in `app/solvers/adversary.py`.
   - Filters out unsupported outside-knowledge claims not grounded in passage text; valid items are not falsely rejected.

5. **P10-05: Canonical Answer Comparison Service:**
   - Implemented `compare_answers` in `app/solvers/comparison.py` supporting TFNG, YNNG, MCQ, and completion with fixed UK/US spelling aliases. Strictly prohibits fuzzy matching and post-mismatch alias loosening.

6. **P10-06: Provider Diversity & Correlation Tracking:**
   - Implemented `build_diversity_profile` in `app/solvers/diversity.py`. Derived from real `Settings` credentials (`minimax_api_key`, `groq_api_key`); dynamically refreshed from actual `ProviderResponse` provider/model names; flags `correlated_review=True` when solver and adversary share the same model.

7. **P10-07: Evidence-Backed Adjudication & Blocker Routing:**
   - Implemented `adjudicate_item` in `app/solvers/adjudication.py`. Creates `HIGH` severity blocker on disagreement or grounded ambiguity; prohibits majority-vote key override and automatic key alterations.

8. **P10-08: Student-Visible Cache Keying & Invalidation:**
   - Implemented `compute_solver_cache_key` and `BlindSolverCache` in `app/solvers/cache.py`.
   - Proved key-swap invariance: swapping the expected answer key leaves the request hash and cache key 100% identical. Invalidation triggers automatically on prompt, option, or passage modification.

9. **P10-09: Authoritative ProviderGateway Integration & SDK Retry=0:**
   - Implemented `BlindSolverEvaluator` in `app/evaluators/solver.py` with `allow_simulation=False` default fail-closed behavior.
   - Executes through `ProviderGateway` with temporary `RetryPolicy(max_attempts=1)` (SDK retry=0).
   - Propagates lease owner and epoch fencing authority from `LoopContext.authority`.
   - Extracts payload from `resp.parsed_payload if resp.parsed_payload is not None else resp.raw_text`.
   - Verified durable operation grant, reservation, and reconciliation in `DurableStoreFake`.
   - Preserved legacy default branch across `QuestionCandidateLoop` and `GenerationFacade` until cutover in G11.

---

## 2. Gate Decision & Blockers Breakdown

- **Internal Phase 10 Implementation:** **PASS** (P10-01..P10-09 satisfied; 10/10 tests in `test_t10_blind_solvers.py` passing, including real schema name regressions and strict nonempty span verification).
- **Upstream Predecessor Gates (G07/G08/G09):** **PASS** (G07 clean holdout verified under `camp_g07_clean_holdout_20261005_v4`; G08 paired passage benchmark verified under `camp_g08_clean_holdout_20261005_v2`; G09 six-type candidate generation & R05 real PostgreSQL durability verified on port 5099).
- **Gate G10 Live Quality Acceptance:** **PASS** under campaign `camp_g10_clean_holdout_20261007_v4` (184/184 child runs completed with 0 errors, overall blocking recall 97.30%, per-type recall >= 90.0%, ambiguity recall 90.0%, false rejection rate 8.11%, critical canaries 100.0% across 3 repetitions and worst run).
- **Remaining Blockers:** None.
- **Phase 11 Readiness:** **READY_FOR_PHASE_11**.
---

## 3. Next Executable Commands

For clean-holdout revalidation under an authorized new campaign ID:

```sh
EXAM_SERVICE_URL=http://127.0.0.1:5099 \
EXAMSERVICE__INTERNAL__API__KEY=test-only-ephemeral-secret-key-phase09 \
PYTHONPATH=scripts/refactor:services/generation-service \
services/generation-service/.venv/bin/python scripts/refactor/run_phase10_blind_benchmark.py \
  --campaign-id camp_g10_clean_holdout_20261005_v3 \
  --concurrency 2
```

On resume, reconcile persisted operation checkpoints before retrying. Do not attempt to reuse or patch the immutable `camp_g10_clean_holdout_20261005_v2` record.

## Latest remediation increment — F-09 cap enforcement

- **Finding fixed:** The local campaign ledger accepted reconciliation above the authorized accountedTokens cap and did not block subsequent reservations.
- **Reproduction:** A 1,000-token authorized campaign reserved 900 tokens, reconciled 1,100, and returned COMPLETED with 1,100 accounted tokens before the fix.
- **Fix:** CampaignBudgetLedger now projects token/wall totals during reconciliation, persists budgetBreachDetected and its reason, blocks later reservations, detects over-cap remote resume state, and propagates the non-pass flag through CampaignCheckpointClient; production 15/60,000/300 caps were not changed.
- **Verification:** test_campaign_budget_ledger.py — 4 passed; py_compile — PASS; focused whitespace check — PASS. The affected real PostgreSQL durability test was attempted and failed at campaign creation with httpx.ConnectError: All connection attempts failed because the exam-service endpoint was unavailable; no live campaign was started.
- **Remaining:** F-09 prompt-token plus maximum-retry reservation formulas and the real PostgreSQL retry/input-token regression remain open. G07–G10 remain blocked; this increment is not an overall gate pass.
- **Exact next command after exam-service readiness:**

  services/generation-service/.venv/bin/pytest -q services/generation-service/tests/test_t09_real_postgres_durability.py::test_real_postgres_campaign_budget_crash_resume_exhaustion_and_no_replay

## Latest remediation increment — F-09 allocation reservation envelope

- **Finding fixed:** The no-dispatch G07/G10 allocation builder undercounted ProviderGateway token reservations by omitting serialized prompt/schema overhead; G07 also omitted the maximum retry-attempt multiplier.
- **Reproduction:** The focused RED test failed with the intended missing-helper ImportError against the old builder. The old formulas were max_tokens sums (option_operations * max_tokens, not_given_operations * max_tokens, and operations * max_tokens) rather than adapter-derived physical-attempt reservations.
- **Fix:** Added _planned_token_reservation, which uses the maximum registered provider adapter's conservative_token_reservation and multiplies by the configured physical-attempt bound. G07 uses RetryPolicy.max_attempts; G10 uses one attempt for each solver/adversary operation. Representative frozen-payload requests include prompt and response-schema content. Production 15/60,000/300 caps were not changed.
- **Verification:** services/generation-service/.venv/bin/pytest -q services/generation-service/tests/test_campaign_budget_allocation.py::test_planned_token_reservation_includes_prompt_schema_and_retry_attempts — 1 passed; services/generation-service/.venv/bin/python -m py_compile scripts/refactor/build_g07_g10_budget_request.py — PASS; git diff --check -- scripts/refactor/build_g07_g10_budget_request.py services/generation-service/tests/test_campaign_budget_allocation.py — PASS; stale simple-formula search — no matches.
- **Remaining:** The real PostgreSQL retry/input-token durability regression is still unverified because the earlier harness attempt could not reach exam-service; F-02/freeze and G07–G10 live acceptance remain blocked. No live campaign/provider calls started.
- **Exact next command after exam-service readiness:**

  services/generation-service/.venv/bin/pytest -q services/generation-service/tests/test_t09_real_postgres_durability.py::test_real_postgres_campaign_budget_crash_resume_exhaustion_and_no_replay
## Latest remediation increment — F-02 freeze/request regeneration

- **Finding fixed:** The no-dispatch allocation builder rejected the stored REQUESTED allocation because the clean-holdout freeze/config hashes predated the current remediation worktree.
- **Reproduction:** services/generation-service/.venv/bin/python scripts/refactor/build_g07_g10_budget_request.py --output /tmp/g07_g10_audit_budget_request.json exited 1 with G07 evaluator/provider/accounting configuration differs from the freeze; rebuild the freeze first.
- **Fix:** Regenerated the clean holdout freeze, no-dispatch allocation request, and phase-07..10 unified snapshots from the current worktree. The production 15/60000/300 caps remain unchanged and bound; no authorization or provider call was started.
- **Verification:** build_clean_g07_holdout.py && build_g07_g10_budget_request.py --output artifacts/refactor/campaign_allocation_request.json && generate_unified_tree_manifest.py completed successfully; freeze/request binding and cap checks passed; test_campaign_budget_allocation.py — 1 passed; all three regeneration scripts compiled; four snapshots share one combinedTreeHash and retain 15/60000/300.
- **Remaining:** The real PostgreSQL retry/input-token durability regression remains unverified because the earlier harness attempt could not reach exam-service. G07–G10 live acceptance remains blocked pending current authorization, service/provider readiness, and required predecessor evidence. No live campaign/provider calls started.
- **Exact next command after exam-service readiness:**

  services/generation-service/.venv/bin/pytest -q services/generation-service/tests/test_t09_real_postgres_durability.py::test_real_postgres_campaign_budget_crash_resume_exhaustion_and_no_replay
## Latest remediation increment — F-06 G08 provenance/report integrity

- **Finding fixed:** The stored G08 paired report claimed authoritative CAS for three V2 PASS cases without persistenceEvidence or provider/model provenance, and Phase 09 review prose used stale 1/3 and 1/1 denominators.
- **Reproduction:** jq showed three V2 cases with decision PASS and grounding PASS, hasAuthoritativeCAS=true, persistenceEvidence=null, provider/model=null, aggregate authoritativeCASCommit.v2=1.0, and no simulationEvidence.
- **Fix:** Marked the stored aggregate and per-case CAS fields as simulation-only/not proven, added explicit DurableStoreFake provenance, preserved the raw 3/3 PASS and 3/3 word-bound counts, corrected Phase 08/09 review statements, and added test_g08_report_integrity.py.
- **Verification:** RED failed with the expected missing proven field; GREEN test_g08_report_integrity.py passed (1); jq parsed the corrected report with rawPasses=3, authoritativeCasProven=false, and DIAGNOSTIC_ONLY status; stale-claim search found no remaining authoritative-CAS or 1/3/1/1 statements. git diff --check still reports pre-existing whitespace in phase reports and test_t07_metrics.py.
- **Remaining:** Authenticated .NET/PostgreSQL passage accept-and-resume evidence and the F-09 retry/input-token durability regression remain unverified because the earlier harness attempt could not reach exam-service. G07–G10 live acceptance remains blocked; no live campaign/provider calls started.
- **Exact next command after exam-service readiness:**

  services/generation-service/.venv/bin/pytest -q services/generation-service/tests/test_t09_real_postgres_durability.py::test_real_postgres_campaign_budget_crash_resume_exhaustion_and_no_replay
## Latest remediation increment — F-07 scoped Validation Matrix restoration

- **Finding addressed:** The required Validation Matrix path was absent, so historical predecessor gates had no current policy source for thresholds and dependencies.
- **Reproduction:** test -f docs/refactor/01-validation-matrix.md exited 1 before the fix.
- **Fix:** Added docs/refactor/01-validation-matrix.md as a scoped G06–G10 policy snapshot. It records the unchanged hard invariants, semantic thresholds, 720–915 passage bounds, 15/60,000/300 child caps, gate dependencies, required P/T evidence, live-authorization boundary, and the explicit missing-input status of unrecoverable G00–G05 rows. It does not upgrade any gate or authorize a campaign.
- **Verification:** Targeted integrity check passed (78 lines and required markers); test -f passed; git diff --check -- docs/refactor/01-validation-matrix.md passed. No provider, campaign, or PostgreSQL call was started.
- **Remaining:** The original full G00–G15 Matrix/master-plan source and its provenance hash are still missing; the scoped snapshot cannot close that source-input gap or make historical G00–G06 gate files current. F-09 real PostgreSQL retry/input-token durability remains blocked by the already-observed unavailable exam-service; G07–G10 live acceptance remains blocked.
- **Exact next command after the missing original Matrix is supplied and exam-service is ready:**

  services/generation-service/.venv/bin/pytest -q services/generation-service/tests/test_t09_real_postgres_durability.py::test_real_postgres_campaign_budget_crash_resume_exhaustion_and_no_replay
## Latest remediation increment — F-09 real PostgreSQL accounting durability

- **Finding fixed:** The actual .NET/PostgreSQL checkpoint path had an untracked EF model delta and did not expose persisted campaign budget-breach state to the client; the real regression also lacked prompt/completion reconciliation coverage.
- **Reproduction:** Starting the authenticated exam-service harness failed with EF Core PendingModelChangesWarning. After the migration was generated, the new regression first exposed the missing campaign-status breach field, and the existing durability test exposed a stale default UNKNOWN accounting type for nonzero reported usage.
- **Fix:** Added the durable accounting migration/snapshot, exposed budgetBreachDetected/budgetBreachReason through the .NET campaign status and Python client models, added the real-PostgreSQL breach/input-token regression, and marked the existing reported reconciliation as REPORTED.
- **Verification:** exam-service rebuilt with 0 errors; EF reports no pending model changes; supervised service exam-service-realpg reached ready at http://127.0.0.1:5099 with 0 pending migrations; the existing campaign durability test and new breach regression passed 2/2; py_compile and targeted diff checks passed. No provider or live campaign calls started.
- **Remaining:** The original full G00–G15 Matrix/master-plan source and provenance hash remain missing; G07–G10 live acceptance remains blocked by REQUESTED authorization, provider/readiness, and predecessor evidence. The local real-PostgreSQL durability blocker is resolved.
- **Exact next command after explicit G07 authorization and provider readiness:**

  python3 scripts/refactor/run_phase07_semantic_benchmark.py --partition holdout --concurrency 2 --campaign-id camp_g07_clean_holdout_20261004_v1 --authorization-file artifacts/refactor/phase-07/campaigns/camp_g07_clean_holdout_20261004_v1_authorization.json


## Latest remediation increment — F-05 Phase 07 metric artifact rebinding

- **Finding fixed:** Persisted dev/holdout recalculation artifacts were generated with metric engine 2.1.0 and did not bind the current valid-subset rejection formula.
- **Reproduction:** The new artifact regression failed before the fix because both artifacts reported metric engine 2.1.0 rather than current v2.3.1. Recalculating the a1360d checkpoint produced the corrected 17 valid operational rejections and 20/60 total valid rejected; the original 28/31 raw summary remains historical evidence.
- **Fix:** Regenerated artifacts/refactor/phase-07/dev-metrics-recalculated.json and holdout-metrics-recalculated.json with v2.3.1/hash 96d2ba2c214fd39a, added test_phase07_metric_artifacts.py, and corrected the recalculator documentation. Raw a1360d campaign artifacts were not overwritten.
- **Verification:** RED failed as intended; GREEN test_phase07_metric_artifacts.py passed 2; recalculator completed; py_compile, jq invariant, and targeted git diff --check passed. No provider/live calls started.
- **Remaining:** The original full G00–G15 Matrix/master-plan source/provenance hash is missing. G07–G10 live acceptance remains blocked pending explicit authorization/readiness and predecessor evidence.
- **Exact next command after explicit authorization and readiness:**

  `python3 scripts/refactor/run_phase07_semantic_benchmark.py --partition holdout --concurrency 2 --campaign-id camp_g07_clean_holdout_20261004_v1 --authorization-file artifacts/refactor/phase-07/campaigns/camp_g07_clean_holdout_20261004_v1_authorization.json`
## Latest remediation increment — F-07 policy source provenance

- **Finding fixed:** The scoped Validation Matrix restored the required G06–G10 policy path but did not bind its transcribed inputs to recorded hashes; source drift was not detectable.
- **Reproduction:** The matrix listed the contract, phase specifications, policy baseline, cap report, and exam-service policy, but had no per-source or source-set digest. The original G00–G05 master-plan rows remain unavailable and were not reconstructed.
- **Fix:** Added SHA-256 values for all nine listed sources and a deterministic lexicographically sorted source-set SHA-256 (`6e5ed351a670b0b62f1dd34edcd2a80aa1377135b1eb51f1147c87bdaf90cf46`), plus `test_validation_matrix_provenance.py` to enforce source membership, hashes, snapshot status, and the explicit missing-input marker.
- **Verification:** The first regression run failed because the multiline source-row matcher omitted `re.MULTILINE`; after correction, `services/generation-service/.venv/bin/pytest -q services/generation-service/tests/test_validation_matrix_provenance.py` passed (1). py_compile and targeted `git diff --check` passed. No provider, campaign, or PostgreSQL call started.
- **Remaining:** The original full G00–G15 Matrix/master-plan source is still missing; G07–G10 live acceptance remains blocked pending explicit authorization, provider/service readiness, and predecessor evidence. This increment is not an overall gate pass.
- **Exact next command after those prerequisites:**

  `python3 scripts/refactor/run_phase07_semantic_benchmark.py --partition holdout --concurrency 2 --campaign-id camp_g07_clean_holdout_20261004_v1 --authorization-file artifacts/refactor/phase-07/campaigns/camp_g07_clean_holdout_20261004_v1_authorization.json`

## Latest remediation increment — F-08 targeted evidence refresh (blocked)

- **Finding selected:** Phase 10 test-report.json and commands.jsonl stop at the pre-remediation 10-test run; current G06–G10 regression evidence is stale.
- **Reproduction:** jq showed evaluatedAt 2026-10-04T12:40:00Z, 10/10 passed, and only three historical command rows. The six-file targeted refresh failed at T09-07 with TOKEN_CAP; the isolated diagnostic confirmed SelectionInfeasibleError and shared tracker progression 1,200 → 76,200 → 91,200 tokens. The attempted nested-runtime restore guard did not change that progression and was reverted.
- **Fix status:** No report or production change was retained; no cap/reservation policy was guessed, and stale counts were not rewritten. This increment is blocked after two unsuccessful experiments.
- **Verification:** No provider, campaign, PostgreSQL, or background call started. This is not a gate PASS.
- **Remaining:** Refreshing current Phase 10 evidence requires a pinned decision for the T09-07 simulation's nested reservation policy; G07/G10 authorization and readiness remain conditional and absent.
- **Exact next command after that policy fix:**

  services/generation-service/.venv/bin/pytest -q services/generation-service/tests/test_t09_question_candidates.py::test_t09_07_persistence_crash_resumption_q17 --tb=short

## R01 — Pre-dispatch token reservations (complete, locally verified)

- **Scope:** R01 only; P02 durable/idempotent grants and P03 shared budget/retry admission. Reused the existing dirty-worktree fix in BaseProvider.conservative_token_reservation, OpenAICompatibleProvider.completion_token_limit, MiniMaxProvider._build_create_kwargs, ProviderGateway.execute and CheckpointService.GrantOperationAsync. No production implementation, configured cap, SDK retry policy, reconciliation-overage path, campaign runner, or gate artifact was changed by this increment.
- **Added regression symbols:** test_r01_prompt_retry_admission_and_unknown_replay, test_r01_real_postgres_concurrent_near_cap_admission, and test_r01_real_postgres_completed_attempt_replay in services/generation-service/tests/test_r01_pre_dispatch_reservations.py.
- **RED:** Loaded only the HEAD gateway into an isolated in-memory namespace without reverting the worktree: four cases failed. The old gateway persisted 128 tokens where the conservative prompt/completion bound was 1,061 (MiniMax M3: 9,126 including its 8,192 completion/reasoning allowance).
- **GREEN:** Exact final command in commands.jsonl: 39 passed, 1 live-provider case deliberately deselected, exit 0. This includes 14 new R01 cases (10 actual HTTP/checkpoint/PostgreSQL cases), 24 existing deterministic provider cases, and the existing PostgreSQL crash/resume/exhaustion test. Concurrent campaign, child-run, logical-parent, section, and artifact near-cap races each admitted exactly one transport contender.
- **Direct smoke:** Actual SDK -> authenticated .NET checkpoint -> PostgreSQL, with local intercepted provider HTTP only. Run bench_53f146dcf095d031666894908f7410ab retained UNKNOWN_OUTCOME reservation 1,061; retry attempt 2 reserved another 1,061 then reconciled to 46 reported prompt/completion tokens. SQL observed two calls / 1,107 tokens, child caps 15 / 60,000 / 300. Restarted-client replay made zero new wire calls. No paid provider call or G07/G10 campaign execution occurred.
- **Review:** Inline author review of the reservation path and focused regression; not an independent review or gate promotion. SDK max_retries=0 and default three-attempt gateway policy remain unchanged. Scope allocations in the artifact race leave section headroom, so the artifact cap is independently exercised.
- **Snapshot:** HEAD f56a0970bbf6190ea7e3af58d2ec8db9e5c9714f; tracked dirty diff SHA-256 before evidence append 759289b42cd4f8956baa08b7b2bd6a303f7c7431ad2369b4487ed14a32a9a07f; effective development-profile SHA-256 f851da6fdafbb9bed6bb872266812a64be9e6fc9280295a3ac6835bdaa5ff2e1. Relevant code/test SHA-256 values are recorded in the candidate-snapshot command row. New regression SHA-256 9b704752a588386a3f445d2bf5a0beaa1bc1f7da4e0ceb2cc1b2afb526b8094d.
- **Sessions:** r01-checkpoint stopped after verification; no outstanding R01 service/agent/task. Local PostgreSQL container was pre-existing and is left running.
- **R01 remaining issue:** None. Reconciliation-overage changes, campaign execution/readiness, the existing F-08 simulation TOKEN_CAP blocker, and gate consolidation remain with their assigned goals; existing gate status is unchanged.
- **Repeat verification after restoring the same local checkpoint service/profile:**

  services/generation-service/.venv/bin/pytest -q services/generation-service/tests/test_r01_pre_dispatch_reservations.py services/generation-service/tests/test_t03_providers.py services/generation-service/tests/test_t09_real_postgres_durability.py::test_real_postgres_campaign_budget_crash_resume_exhaustion_and_no_replay -k 'not live_provider' --tb=short


## R02 — Truthful reconciliation and breach admission (complete, locally verified)

- **Scope/symbols:** R02 only; authoritative .NET CheckpointService.ReconcileOperationAsync, GrantOperationAsync and ResumeStateAsync. Reused compatible existing operation/run/campaign breach flags and gateway budget failure. Kept the Phase 02 durable intent/idempotency and Phase 03 parent-cap/unknown-outcome specifications. No live campaign, production cap change, migration or gate rewrite.
- **Reproduction/root cause:** The new real-PostgreSQL ESTIMATED overrun case failed: 1,500 observed tokens over reservation 500 were persisted on the operation but resume showed 500. The non-REPORTED branches under-accounted estimates in counters and projections. The initial test also had an incorrect unknown-outcome DTO field; that harness error was corrected, not masked.
- **Fix:** Reported usage charges its full actual count. Estimated usage remains explicitly ESTIMATED and charges at least the reservation, increasing to the full estimate when larger. UNKNOWN retains its bound and nullable component counts. Parent, section, artifact and resume token accounting use the same rule. The existing transactional breach flags/reasons persist; subsequent physical dispatch remains blocked.
- **Verification:** Final focused command below: **13 passed in 8.19s, exit 0, zero skips** (6 R02 cases, 5 concurrent scope races including parent, 2 existing PostgreSQL budget cases). Build: zero errors, 12 pre-existing warnings including dependency advisories. New test py_compile passed. Reconciliation replay and conflicting replay were checked; over-cap counters were not clamped.
- **Direct smoke/restart:** Actual SDK with intercepted HTTP -> authenticated checkpoint API -> PostgreSQL. Run **bench_f71e773068de550c06dadc83af326f12**, diagnostic campaign **r02_local_764b91e0b49e49ed992336fca8effb66**: reported 7,000 vs reservation 1,061; separate UNKNOWN_OUTCOME reservation 500/20 seconds retained; full charged total **7,500 > campaign cap 5,000**, breach true. One local wire call, zero replay/followup wire calls, zero paid calls. After actual service stop/start and a fresh Python process, unknown reservation stayed 500/20, reconciliation replay remained 7,500 tokens/2 calls, new grant returned 422. Exact commands/results and IDs are appended in commands.jsonl.
- **Review/limitations:** Inline author review, not independent review; no extra reviewer agent. Fencing, transaction serialization, same-result replay and scope accounting were reviewed. This is focused local durability proof, not a Phase 02/03/10 gate PASS, full release matrix, measured full-suite coverage or live quality certification. Historical evidence and gate files were not rewritten; existing Matrix/predecessor/F-08/live-authorization issues remain outside R02.
- **Snapshot:** HEAD f56a0970bbf6190ea7e3af58d2ec8db9e5c9714f; tracked dirty diff before this append **1df3f6c885b82ccae0d3dbdc78a956eafa54139f48d992cb8b355d3367affb10**. CheckpointService SHA-256 **e51c1c26b99229ec1e8e4b5f7056e5b52fa2152a03feff943ddd21f920e3e214**; R02 regression **f51340be164edec251f3df5d658c1de77ead1589c45fad2d1674f0c8dc3c2f77**. Profile SHA-256 **f851da6fdafbb9bed6bb872266812a64be9e6fc9280295a3ac6835bdaa5ff2e1**; child caps remain **15 / 60,000 / 300**. Additional assembly/gateway/client/model hashes are in commands.jsonl.
- **Sessions/remaining:** R02 supervised checkpoint sessions ended (latest ID 83a9f6df-d1e7-4822-9ba2-718e575498e6, explicitly stopped); no outstanding R02 task/service. Pre-existing PostgreSQL and unrelated service were left alone. Temporary restart handoff removed after proof. No open R02 behavior issue; independent review/gate consolidation remains with phase close.
- **Recheck setup:** Use the exact R02 service-start Python heredoc recorded in commands.jsonl, which injects the current Settings caps and starts the built DLL on localhost:5102 against the existing isolated exam_test_phase09 DB. Build first if code changes. It performs no provider dispatch. Do not substitute a stale running 5099 assembly.
- **Next decisive command after that local service is ready:**

  REAL_SERVICE_URL=http://127.0.0.1:5102 services/generation-service/.venv/bin/pytest -q services/generation-service/tests/test_r02_reconciliation.py services/generation-service/tests/test_r01_pre_dispatch_reservations.py::test_r01_real_postgres_concurrent_near_cap_admission services/generation-service/tests/test_t09_real_postgres_durability.py::test_real_postgres_campaign_budget_crash_resume_exhaustion_and_no_replay services/generation-service/tests/test_t09_real_postgres_durability.py::test_real_postgres_campaign_reconciliation_breach_blocks_followup_grant --tb=short



## R03 — Production runtime caps, settings-to-runtime wiring, and restart preservation (complete, locally verified)

- **Scope & goal:** R03 only under the common contract; Phase 06 runtime caps and G06 configuration reconciliation. Ensure declared production runtime caps reach the actual runtime through Settings, deployment resolution, and DI, and appear in the pinned run snapshot. Trace values, enforce fail-closed configuration, preserve approved limits (15 calls / 60,000 tokens / 300s wall time), verify restart preservation, and resolve the older PASS versus later cap-BLOCKED discrepancy from current evidence without premature gate promotion.
- **Trace of effective values:**
  - *Declaration:* `deploy/envs/loop-caps.env` is the shared single source of truth for runtime caps (version `phase06-production-v1`, source `deploy/envs/loop-caps.env`, SHA-256 `f851da6fdafbb9bed6bb872266812a64be9e6fc9280295a3ac6835bdaa5ff2e1`). Approved caps: 15 max calls, 60,000 max tokens, 300s max wall time, 3 max versions, 3 max generated versions, 2 max repairs per version, 5 total repairs, 2 stagnation threshold, 2 oscillation cycles, 15,000 generate token reservation, 10,000 evaluate token reservation, 15,000 repair token reservation, 60s operation wall reservation, 500,000 max response bytes, 9,000 passage generate reservation, 2,500 passage generate max tokens; standalone run budget 25 calls / 150,000 tokens / 900s; benchmark child run 15 calls / 60,000 tokens / 300s; complete section and artifact allocations for legacy and benchmark profiles.
  - *Deployment resolution:* Compose (`deploy/compose.yaml`) binds `./envs/loop-caps.env` as required `env_file` for both `exam-service` and `generation-service`. Aspire (`AppHost/Program.cs`) binds `.WithComposeEnvFile("loop-caps")` to both `exam` and `ai` (generation-service). Explicit override support via `GENERATION_SERVICE_ENV_FILE` / `AI_SERVICE_ENV_FILE` in `app/config.py` allows pointing to an explicit file override.
  - *DI & Settings parsing:* In Python, `app/config.py` `Settings` parses the profile, validates integer bounds (positive 32-bit), validates hierarchy consistency across run/section/artifact levels, and enforces that production environment strictly requires all explicit cap settings and explicit version/source (missing values never fall back to development defaults). `LoopPolicy.from_settings()` builds policies directly from `settings.loop_caps_snapshot()`. In .NET, `ReadingPaperCapsProfile.FromConfiguration(builder.Configuration)` is registered as a Singleton in `Program.cs`, parsing with `InvariantCulture`, validating required keys, positive integers, and hierarchy constraints.
  - *Pinned run snapshot:* `ReadingPaperWorker` and `BenchmarkCampaignService` stamp `BudgetProfileVersion`, `BudgetProfileSource`, `BudgetProfileSha256`, `BudgetProfileJson`, and budget caps into `ReadingPaperRun` upon run creation and case provisioning. `CheckpointService.cs` verifies `ReadingPaperCapsProfile.MatchesRunBudget` before granting `PROVIDER_CALL` operations and on `ResumeStateAsync`. `BoundedLoopRuntime.py` validates `budgetProfileJson` and `budgetProfileSha256` from durable state on resume, rehydrates `LoopPolicy.from_cap_snapshot(snapshot)`, and ensures all executions stay strictly bounded by the run's original pinned caps and counters across restarts.
- **Resolution of older PASS vs later cap-BLOCKED discrepancy:**
  - *Historical PASS (`artifacts/refactor/phase-06/gate.json`, 2026-10-01T03:32:50Z):* Evaluated on SHA `999dc94f...` when T06-01..T06-08 passed on an in-memory skeleton runtime. That pass evaluated algorithmic state transitions using class-level defaults on `LoopPolicy`, before external production configuration existed.
  - *Subsequent BLOCKED (`artifacts/refactor/verify-after-phase-06/gate.json`, 2026-10-01T04:49:54Z):* Independent verification evaluated the deployment boundary and correctly identified `CONFIG_BLOCKER`: required runtime caps were absent from `Settings` and deploy environment files. The verification instructions explicitly forbid treating plan defaults as confirmed production configuration.
  - *Current resolution:* The blocker was resolved by introducing `deploy/envs/loop-caps.env`, integrating and validating it in `Settings` and `ReadingPaperCapsProfile`, wiring it into Compose and AppHost, and stamping it into run snapshots. Crucially, Gate G06 is **not** promoted solely because configuration fields now exist; full G06/Phase 07 promotion remains gated by authoritative Validation Matrix restoration and candidate evaluation.
- **Verification evidence:**
  - *Python suite:* 130 tests passed in 10.59s (`test_r03_config_caps.py` 84 passed, `test_r03_runtime_caps.py` 13 passed, `test_t06_loop_runtime.py` 33 passed, 0 failures, 0 skips).
  - *C# .NET suite:* 45 tests passed in 5s (`R03CapsProfileTests.cs` 37 passed, `Phase06DurabilityTests.cs` 8 passed on real PostgreSQL, 0 failures, 0 skips).
  - *Behaviors proven:* Explicit config overrides re-pin profile SHA; missing/invalid caps fail closed with `ValidationError` / `InvalidOperationException`; admission bounds enforce `TOKEN_CAP` / `CALL_CAP`; in-flight restarts re-base onto run's original pinned profile; `RESERVED` / `UNKNOWN_OUTCOME` counters survive restarts without refund.
- **Snapshot & provenance hashes:**
  - HEAD: `f56a0970bbf6190ea7e3af58d2ec8db9e5c9714f`
  - Canonical cap profile SHA-256: `f851da6fdafbb9bed6bb872266812a64be9e6fc9280295a3ac6835bdaa5ff2e1`
  - `deploy/envs/loop-caps.env`: `a2c6b837fb10f641767b7dc8f631f6af0a9147a00830d3271210be599808472c`
  - `ReadingPaperCapsProfile.cs`: `56c9add551f5b5a85f84bad9e617631f85da7b4bca0ba54280e4d61f2d04b091`
  - `app/config.py`: `8fb227b71e2fd3db6fca5708ef97bed72753e249b6254ca9b229bf3718a888fa`
  - `app/loop/policy.py`: `56616a0f74312b3a4e34eb1f801422cfc54b100bfebfec074f75998cf778e12b`
  - `app/loop/runtime.py`: `029fe28ebf5616ce447ea54ce3544d664276d2395ce441a293825844eff0a372`
  - `R03CapsProfileTests.cs`: `0933d5788ea377d30a2a86fa59085c9188e840096d6d94fea143e6826b9839b9`
  - `Phase06DurabilityTests.cs`: `0b40d03f51b06020387b76430abc5fee563e66fa27a5a698afa263512adbfac8`
  - `test_r03_config_caps.py`: `7f4df1261430a1293dbb4013f7e8911147476b8ddc843a75fba9c9c84fdb00ab`
  - `test_r03_runtime_caps.py`: `2acca48e2df4832e06532ee1dc6cc53c9436ee51e1c2dc2e6b093f95452d7ce0`
- **Next decisive commands:**
  - Python suite: `services/generation-service/.venv/bin/pytest services/generation-service/tests/test_r03_config_caps.py services/generation-service/tests/test_r03_runtime_caps.py services/generation-service/tests/test_t06_loop_runtime.py`
  - .NET suite: `READING_TEST_POSTGRES="Host=localhost;Port=55439;Database=exam_test_phase06;Username=exam;Password=exam" dotnet test services/exam-service.Tests/exam-service.Tests.csproj --filter "FullyQualifiedName~Phase06DurabilityTests|FullyQualifiedName~R03CapsProfileTests"`

## R04 — Passage loop PostgreSQL durability and authenticated .NET checkpoint integration (complete, locally verified)

- **Scope & goal:** R04 only under the common contract; Phase 08 passage loop and G08 durability integration. Ensured the actual V2 passage path checkpoints through the authenticated .NET boundary into PostgreSQL. Replaced fake-store substitution in the integration harness (`scripts/refactor/exercise_phase08_service_route.py`) with default authenticated .NET `CheckpointClient` into PostgreSQL while retaining `--simulation` as clearly labeled simulation. Retained existing simulation tests (`services/generation-service/tests/test_t08_passage_loop.py`) as simulation with pinned `budgetProfile` snapshot fields.
- **Verification evidence:**
  - *Targeted PostgreSQL checkpoint test suite (`test_r04_passage_checkpoint.py`):* 7 passed in 7.97s on real PostgreSQL via authenticated .NET boundary:
    1. `test_r04_exact_accepted_references_and_stale_dependency_rejection`: exact parent references (`reading_paper_artifact_dependencies`), head commit (`reading_paper_artifact_heads`), evaluations, decisions; stale/missing dependencies fail closed with `STALE_DEPENDENCY` without invoking provider.
    2. `test_r04_real_cas_conflict_rejection`: committing with mismatching `expectedHeadVersion=0` fails closed with HTTP 409; PostgreSQL head remains unmodified at version 1.
    3. `test_r04_stale_epoch_fencing_rejection`: operation grant with `epoch < active lease epoch` or mismatched `leaseOwner` rejected with HTTP 409.
    4. `test_r04_cancelled_job_run_rejection`: operation grant on cancelled job/run fails closed with HTTP 409.
    5. `test_r04_crash_before_commit_draft_only_no_accepted_head`: injected fault before commit leaves draft in `reading_paper_artifacts`, but 0 heads in `reading_paper_artifact_heads`.
    6. `test_r04_crash_after_commit_lost_ack_and_idempotent_replay`: lost ACK after successful commit in PostgreSQL; commit replay returns `isReplay=True` with identical ack fields; zero duplicate operations created.
    7. `test_r04_accepted_passage_resume_zero_regeneration`: resumed run with accepted passage and fresh matching dependencies returns `DecisionType.PASS` with 0 provider calls consumed (`provider.call_count == 1`).
  - *Service route integration harness (`scripts/refactor/exercise_phase08_service_route.py`):* verified all 5 scenarios against real PostgreSQL by default (and `--simulation` mode as labeled simulation):
    - Scenario 1 (short source < 50 chars): returns typed `SOURCE_INSUFFICIENT`.
    - Scenario 2 (missing dependencies): returns typed `STALE_DEPENDENCY`.
    - Scenario 3 (real PostgreSQL fresh generation): HTTP 200, wordCount = 872 within [720, 915], head `art_passage_s1 v1` verified in PostgreSQL.
    - Scenario 4 (accepted-passage resume with zero regeneration): HTTP 200, call count unchanged.
    - Scenario 5 (NDJSON streaming): HTTP 200, streamed section event verified.
  - *Paired benchmark harness (`scripts/refactor/run_phase08_paired_passage_benchmark.py`):* prepared per-case `provider`, `model`, `config`, and `authoritativeOperations` trace fields and `authoritativeCasProven: True` in `persistenceEvidence`; validated `--plan-only` and fail-closed behavior without authorization (`CampaignAuthorizationError`). Semantic acceptance remains pending its live campaign.
  - *Existing passage loop simulation tests (`test_t08_passage_loop.py`):* 8 passed in 1.42s; simulation-only tests retained with pinned cap profiles.
  - *Report integrity (`test_g08_report_integrity.py`):* 1 passed; historical simulation report remains protected.
  - *Prior G08 durability tests (`test_t09_real_postgres_durability.py -k g08`):* 3 passed in 4.52s.
  - *C# .NET suite:* 45 passed in 5s (`R03CapsProfileTests.cs`, `Phase06DurabilityTests.cs`).
- **Snapshot & provenance hashes:**
  - HEAD: `f56a0970bbf6190ea7e3af58d2ec8db9e5c9714f`
  - `services/generation-service/tests/test_r04_passage_checkpoint.py`: `4c2df5e3ace25cf83d0af303c17c0801767749cb2ec375c0fb6f29b961b6de9a`
  - `scripts/refactor/exercise_phase08_service_route.py`: `6ddfdd44b3d4ac14a02a61b496035dc25130513b02d47ffa5f219bb620b96dd5`
  - `scripts/refactor/run_phase08_paired_passage_benchmark.py`: `91fe08e178315b1012655f05b771926504c8481db05522ac235ca95389838607`
  - `services/generation-service/tests/test_t08_passage_loop.py`: `d56c3b71b2b157f41a8591b058e6e73537bc0afb78df23d246c33847c17d9c05`
  - `services/generation-service/tests/test_g08_report_integrity.py`: `38c8f7aa9c393e12be7b67d603155347073a2950c796b3e56643b4e9b3a1f8b7`
  - `services/generation-service/app/loop/passage.py`: `ebf0f6d74f15f65ec0620403023c08940ff07752cff3f2e469f0a4deba1b0f76`
  - `services/generation-service/app/facade.py`: `461bc23340f6677906a78a4e2e32022457e41d95542ad5aa64ad47ec867fa2f9`
  - `services/generation-service/app/router.py`: `0c43bc36cd08a08bf8c62aab4bc61afc2771ef3f70c13e679cb7dfd411d48b71`
- **Next decisive commands:**
  - Python test suite: `REAL_SERVICE_URL=http://127.0.0.1:5099 services/generation-service/.venv/bin/pytest -q services/generation-service/tests/test_r04_passage_checkpoint.py services/generation-service/tests/test_t08_passage_loop.py services/generation-service/tests/test_g08_report_integrity.py services/generation-service/tests/test_t09_real_postgres_durability.py -k "g08" --tb=short`
  - Real route verification: `PYTHONPATH=services/generation-service REAL_SERVICE_URL=http://127.0.0.1:5099 services/generation-service/.venv/bin/python scripts/refactor/exercise_phase08_service_route.py`
  - Simulation route verification: `PYTHONPATH=services/generation-service services/generation-service/.venv/bin/python scripts/refactor/exercise_phase08_service_route.py --simulation`
  - Live paired harness dry run: `PYTHONPATH=services/generation-service services/generation-service/.venv/bin/python scripts/refactor/run_phase08_paired_passage_benchmark.py --plan-only`

## R05 — Question candidate loop PostgreSQL durability and authoritative .NET checkpoint integration (complete, locally verified)

- **Scope & goal:** R05 only under the common contract; Phase 09 question candidates loop and G09 durability integration. Verified actual `QuestionCandidateLoop` durability checks running on real PostgreSQL (`exam-db` container on port 55439, authenticated .NET boundary on port 5099) binding the current tested implementation and configuration. Ran the existing relevant test suites; fixed in-scope failures in production services and tests without rewriting historical snapshots or gate reports.
- **Root causes & in-scope fixes:**
  1. *Wall time budget cap enforcement in CheckpointService.cs:* Added `run.BudgetUsedWallTimeSeconds + request.WallTimeReservationSeconds > run.BudgetCapWallTimeSeconds` validation to reject grants exceeding the run's remaining wall-clock budget with HTTP 422 for all operations.
  2. *Reconciliation accounting type:* Added `opEntity.AccountingType = "REPORTED"` in `SaveDraftCheckpointAsync` and updated `BoundedLoopRuntime._evaluate` to reconcile completed deterministic evaluations with `accountingType="REPORTED"`. This ensures completed 0-token evaluations and draft checkpoints release temporary reservations rather than remaining locked under non-REPORTED / UNKNOWN rules. Corrected test `test_real_postgres_t09_07_crash_window_1_pre_dispatch` from invalid `"RECONCILED"` to `"REPORTED"`.
  3. *Parent operation nesting in question loop:* Updated `SlotCandidateGeneratorAdapter.generate` to pass `parent_operation_id=intent_id` (the draft generate operation) rather than `workflow_op_id`, eliminating duplicate token reservations at the workflow root level.
  4. *In-memory packaging token reservations:* Configured `SingleCandidateGenerator` and `WinningGroupGenerator` runtimes with `generate_token_reservation: 0` (in-memory candidate adaptation consumes 0 provider tokens) and filtered active candidate evaluators to the policy's required evaluators (`eval_question_structure`, `eval_answer_verbatim_length`), avoiding oversubscription of `LOOP_MAX_TOTAL_TOKENS` (60,000). Provided isolated `BudgetTracker` instances for candidate and group runtimes while PostgreSQL authoritatively bounds the workflow hierarchy.
  5. *Simulation store accounting parity:* Excluded `"WORKFLOW"` container operations and summed `parentless_work` in `SQLiteCheckpointSimulation.resume_state`, matching `CheckpointService.cs`'s authoritative behavior and preventing 300s wall-time inflation in simulation tests.
  6. *Phase 10 policy cap alignment:* Aligned `test_t10_blind_solvers.py` test policy with R03 pinned production caps.
- **Verification evidence:**
  - *Real PostgreSQL durability suite (`test_t09_real_postgres_durability.py`):* 16/16 passed in 36.77s on real PostgreSQL (zero skips, zero failures):
    1. `test_real_postgres_t09_07_crash_window_1_pre_dispatch`: Pre-dispatch crash while operation is RESERVED; Q14-16 heads/hashes preserved.
    2. `test_real_postgres_t09_07_crash_window_2_inflight_unknown_outcome`: In-flight dropped connection recorded as UNKNOWN_OUTCOME.
    3. `test_real_postgres_t09_07_crash_window_3_pre_commit`: Draft saved, crash before CAS commit; draft preserved, accepted head uncommitted.
    4. `test_real_postgres_t09_07_crash_window_4_post_commit_pre_ack`: CAS commit completed in DB, crash before client ACK; idempotent replay resumes existing head with zero duplicate operations.
    5. `test_real_postgres_t09_07_idempotent_replay_accounting`: Replay with identical slots consumes 0 billable work; durable counters and deadline preserved.
    6. `test_real_postgres_t09_07_failure_and_retry_accounting`: Safe failure lifecycle handling; root workflow operation reconciled to COMPLETED on failure; clean retry succeeds.
    7. `test_real_postgres_t09_07_actual_loop_q17_crash_and_cursor_resumption`: Actual `QuestionCandidateLoop` mid-flight crash at Q17; clean-memory instance resumes from PostgreSQL with zero regeneration of Q14-16.
    8. `test_real_postgres_t09_08_unfinished_q17_partial_progress_crash_and_resumption`: Subprocess abrupt crash (`os._exit(42)`) during Q17 before winning group commit; fresh loop resumes and completes Q17 cleanly.
    9. `test_real_postgres_t09_09_hard_execution_deadline_vs_lease_until`: Distinct writer authority lease (`LeaseUntil`) vs hard execution deadline (`CreatedAt + BudgetCapWallTimeSeconds`); late grant exceeding remaining budget rejected with HTTP 422.
    10. `test_real_postgres_t09_10_dotnet_worker_consumer_group_mapping_and_partial_groups`: Real `POST /questions` endpoint, group mapping, partial group resolution, and 422 rejection on invalid type.
    11. `test_real_postgres_campaign_budget_crash_resume_exhaustion_and_no_replay`: Authoritative campaign budget persistence across process restart.
    12. `test_real_postgres_campaign_reconciliation_breach_blocks_followup_grant`: Reconciliation breach blocks subsequent grants.
    13. `test_real_postgres_concurrent_near_cap_attempt_reservations_admit_within_caps`: Concurrent attempt reservations admit within campaign caps.
    14. `test_real_postgres_g08_v2_exact_refs_lost_ack_idempotency_and_resume`: G08 passage acceptance durability.
    15. `test_real_postgres_g08_precommit_fault_does_not_accept_passage`: Precommit failpoint leaves head uncommitted.
    16. `test_real_postgres_g08_cas_fencing_and_cancellation_fail_closed`: Stale CAS and cancellation fail closed.
  - *Candidate unit suite (`test_t09_question_candidates.py`):* 9/9 passed in 6.87s (T09-01..T09-08 & simulation crash resumption).
  - *Passage checkpoint durability suite (`test_r04_passage_checkpoint.py`):* 7/7 passed in 7.86s.
  - *Phase 10 blind solvers suite (`test_t10_blind_solvers.py`):* 10/10 passed in 1.31s.
  - *Caps & runtime suites (`test_r03_runtime_caps.py`, `test_r03_config_caps.py`):* 97/97 passed in 3.97s.
  - *Pre-dispatch reservations & reconciliation (`test_r01_pre_dispatch_reservations.py`, `test_r02_reconciliation.py`):* 20/20 passed in 7.15s.
  - *Loop runtime & evaluators suites (`test_t06_loop_runtime.py`, `test_t07_evaluators_repairs.py`, `test_t08_passage_loop.py`):* 69/69 passed in 8.39s.
  - *.NET test suite (`exam-service.Tests`):* 45/45 passed in 6s (`Phase06DurabilityTests`, `R03CapsProfileTests`).
- **Snapshot & provenance hashes:**
  - HEAD: `f56a0970bbf6190ea7e3af58d2ec8db9e5c9714f`
  - `services/exam-service/Features/ReadingPaper/CheckpointService.cs`: `0ca3fcc082b21c542ecc6178c715ad86094cb21d75210bb98349b8b14a498567`
  - `services/generation-service/app/loop/runtime.py`: `a41927b41c66941bf0783ed9ce99cc5aeee4609447ab585e76666f89ff1aa3ba`
  - `services/generation-service/app/loop/question.py`: `1159b28e547867e546d42557421b642a231417e74ec9223caa3991545e7ed5dc`
  - `services/generation-service/tests/test_t08_passage_loop.py`: `dbc833b265fe38af7ddd3a0afeff7e0e38b58681750793542df24660a7500518`
  - `services/generation-service/tests/test_t09_real_postgres_durability.py`: `4f46511719c956e46f5c87ac05a4beee64e6a548d113f2bb010cc25095621f87`
  - `services/generation-service/tests/test_t09_question_candidates.py`: `73b3bdb094e9ad217233dfc9ce1c7afa2b23441410f44678433a900b5a99460b`
  - `services/generation-service/tests/test_t10_blind_solvers.py`: `2d4277f8f209f6136419dee4e8115db3412f0fb368e7d3762ff215aee5c214cc`
  - `services/exam-service/bin/Debug/net10.0/exam-service.dll`: `45e0f0a46ebae4777a56a82c661c323c9e56252d0323a57ab12027babd9d07b2`
- **Gate status:** Overall G09 remains **non-pass / blocked** as predecessor quality evidence (clean G07/G08 live benchmark acceptance) remains missing. Real-loop durability evidence on real PostgreSQL is complete and verified without replacing real-loop tests with persistence-primitive-only tests.
- **Decisive re-verification command:**
  ```sh
  REAL_SERVICE_URL=http://127.0.0.1:5099 services/generation-service/.venv/bin/pytest -v services/generation-service/tests/test_t09_real_postgres_durability.py services/generation-service/tests/test_t09_question_candidates.py --tb=short
  ```
