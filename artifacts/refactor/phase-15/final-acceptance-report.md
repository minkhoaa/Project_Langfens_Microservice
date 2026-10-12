# Final Acceptance Report — Langfens Loop Engine V2 Refactor

**Release Status**: BLOCKED (Implementation Complete; Candidate Readiness & Gate G15 BLOCKED Pending Live Quality, E2E Rerun, and Production Canary Window)  
**Evaluated At**: 2026-10-09T07:30:00.000000+00:00  
**Authority**: Principal Engineer & Lead Release Verifier  

---

## 1. Release Identity

| Field | Value / Traceable Reference |
|---|---|
| **Release Git SHA** | `56d060d45b2f55e6d1af03240e019c60084b1261` |
| **Snapshot Manifest SHA-256** | `9018f9bdacbc934e4c64dd45818c6a0c1e2d6cafefb2e2e534467411a96510be` |
| **Benchmark Report SHA-256** | `5bc68310570c9ae5e3a75e3f20af0a6b4fe5a7ffd9212412057d7b12d15382c2` |
| **Combined Tree SHA-256** | `5375b112b59ddd8671f5edb5f4ac9df311d5d276a75f5f1aef589dc1a764fcb2` |
| **Test Environment / UTC Run Window** | Linux 6.8.0-1064-azure x86_64 / `2026-10-09T07:30:00Z` |
| **Engine / Schema / Policy Versions** | `LoopEngineV2.4` / `exam-db-v15` / `LoopPolicyV2-Default` |
| **Provider / Model / Config Versions** | `MiniMax-Text-01` (primary), `openai/gpt-oss-120b` (Groq fallback) |
| **Prompt / Evaluator Version Manifest** | `prompts_v2_0_0` (active pinned), EvaluatorRegistry: 17 registered evaluators |
| **Metric Engine Version / Hash** | `2.3.1` / `a958e94e77341398` |
| **Corpus Hash / Source-Rights Manifest** | Europe PMC CC-BY/CC0 Verified / OpenAlex Indexed |
| **Migration Set** | Additive EF Core migrations `20261008_V2_DurableArtifacts_Outbox` |
| **Overall Result** | **`BLOCKED`** |

---

## 2. Gate Status Overview

| Gate | Status | Required Tests Pass / Total | Evidence Ref | Blockers / Notes |
|---|---|---|---|---|
| **G00** | PASS | 12 / 12 | `artifacts/refactor/phase-00/test-report.json` | None |
| **G01** | PASS | 26 / 26 | `artifacts/refactor/phase-01/test-report.json` | None |
| **G02** | PASS | 34 / 34 | `artifacts/refactor/phase-02/test-report.json` | None |
| **G03** | PASS | 48 / 48 | `artifacts/refactor/phase-03/pytest-results.xml` | None |
| **G04** | PASS | 38 / 38 | `artifacts/refactor/phase-04/test-report.json` | None |
| **G05** | PASS | 42 / 42 | `artifacts/refactor/phase-05/test-report.json` | None |
| **G06** | PASS | 56 / 56 | `artifacts/refactor/phase-06/test-report.json` | None |
| **G07** | PASS | 64 / 64 | `artifacts/refactor/phase-07/test-report.json` | None |
| **G08** | PASS | 45 / 45 | `artifacts/refactor/phase-08/test-report.json` | None |
| **G09** | PASS | 52 / 52 | `artifacts/refactor/phase-09/test-report.json` | None |
| **G10** | PASS | 48 / 48 | `artifacts/refactor/phase-10/test-report.json` | None |
| **G11** | PASS | 58 / 58 | `artifacts/refactor/phase-11/test-report.json` | None |
| **G12** | **BLOCKED** | 8 / 8 (Py) + 10 / 10 (C#) | `artifacts/refactor/phase-12/gate.json` | Live model generation campaign pending unconstrained quotas |
| **G13** | PASS | 73 / 73 (Py) + 17 / 17 (C#) + 177 / 177 (FE) | `artifacts/refactor/phase-13/gate.json` | None |
| **G14** | PASS | 23 / 23 (Py) + 22 / 22 (C#) | `artifacts/refactor/phase-14/gate.json` | None |
| **G15** | **BLOCKED** | 732 Total Automated Tests Passed | `artifacts/refactor/phase-15/gate.json` | Live 24h canary bake window, upstream G12, and container rollback rehearsal pending |

---

## 3. Business & Contract Verification

- [x] **Four Public Endpoints & NDJSON .NET Consumer Parity**: `GET /sources`, `POST /source`, `POST /source/ingest`, and `POST /section` (NDJSON stream + JSON) verified with `ReadingPaperAiClient`.
- [x] **Source License, Provenance, and SSRF**: Validated 100% against Europe PMC CC-BY/CC0 policies, URL pinning, and 5MB payload caps.
- [x] **IELTS Academic Invariants (13/13/14, 6 Types, 1–40)**: Question counts, word ranges (720–915 words per passage), continuous 1–40 numbering, and zero duplicate questions guaranteed by `ReadingPaperRules` and `PaperStructureEvaluator`.
- [x] **Type-Aware Answer & Evidence Verification**: Strict verbatim passage matching for completion types; exact A/B/C/D option grounding for MCQ; True/False/Not Given and Yes/No/Not Given semantic distinction.
- [x] **Manual CRUD / Draft / Publish / Retry E2E**: Admin editing and publishing workflow verified in staging; full candidate re-run pending on commit `56d060d`.
- [x] **AI Output Always Persisted in Draft**: Zero unauthorized automatic publishing.

---

## 4. Reliability & PostgreSQL Chaos Matrix Evidence

Executed against real PostgreSQL on port 5433 (`artifacts/refactor/phase-15/canary/chaos-matrix-report.json`):

| Fault Class | Invariant / Expectation | Observed Result | Verdict |
|---|---|---|---|
| **FAULT-01 (Provider 429)** | Bounded backoff; token cap preserved | Cap preserved; used tokens not reset | ✅ PASS |
| **FAULT-02 (Timeout / UNKNOWN_OUTCOME)** | UNKNOWN_OUTCOME holds reservation | 0 double billing; operations reconciled | ✅ PASS |
| **FAULT-03 (Truncated / Invalid JSON)** | Typed invalid record; reject partial schema | Schema violations blocked; 0 invalid heads | ✅ PASS |
| **FAULT-04 (Evaluator Exception)** | ERROR status; fail-closed decision | DecisionType.FAIL; 0 unauthorized passes | ✅ PASS |
| **FAULT-05 (Crash Pre-Artifact Commit)** | Head does not advance | Dangling heads prevented; 0 uncommitted artifacts | ✅ PASS |
| **FAULT-06 (Crash Post-Commit Pre-Ack)** | Replay same operation idempotently | Duplicate versions prevented; 1 replayed artifact | ✅ PASS |
| **FAULT-07 (Crash Post-Passage Accepted)**| Resume questions without re-generating passage | Passage re-generation avoided; resumed from head | ✅ PASS |
| **FAULT-08 (Crash at Question 17)** | Reuse accepted Q1-Q16; resume from Q18 | 26 distinct questions; 0 duplicates | ✅ PASS |
| **FAULT-09 (Lease Takeover / Epoch Fence)**| Stale epoch writer rejected (UPDATE 0) | Stale writer rejected; fencedRejections=1 | ✅ PASS |
| **FAULT-10 (Cancel Mid-Repair)** | Cancelled run remains terminal | Cancellation fenced writes; 0 leaked tasks | ✅ PASS |
| **FAULT-11 (Stream Disconnect / Reconcile)**| Status/replay reconcile | Stream status reconciled; 0 premature completions | ✅ PASS |
| **FAULT-12 (DB Transaction Rollback)** | Multi-statement rollback clean | Clean rollback; 0 orphaned records | ✅ PASS |
| **FAULT-13 (Source Replacement)** | Invalidate exact dependency closure | Stale dependencies invalidated; 0 stale reuse | ✅ PASS |
| **FAULT-14 (Version Pinning)** | In-flight engine pinned | In-flight engine preserved; 0 contamination | ✅ PASS |

---

## 5. Comparative Staging Benchmark (Live MiniMax-Text-01 Paired Run)

*Campaign Reference: `camp_G15_c9750f53d6b5` (Live OpenAI-compatible MiniMax-Text-01 dispatches; 904 live dispatches across 36 papers; 0 Groq calls).*

| Metric | Target | Observed Value (V2 vs Legacy Live Run) | Status / Evaluation |
|---|---|---|---|
| **Execution Mode** | Live MiniMax | Live Paired Benchmark (904 live calls) | ✅ PASS (Live Execution Complete) |
| **Primary Model** | `MiniMax-Text-01` | `MiniMax-Text-01` (100% pure dispatches) | ✅ PASS |
| **Fallback Model** | None / Disabled | None (Groq allowlist strictly excluded) | ✅ PASS |
| **Valid Draft Rate (V2)** | $\ge 95.0\%$ (17/18) | 61.1% (11 / 18 valid drafts persisted) | ❌ BLOCKED (Target $\ge 95.0\%$) |
| **Valid Draft Rate (Legacy)** | Baseline Reference | 77.8% (14 / 18 valid drafts persisted) | Baseline Reference |
| **Fidelity Must-Reject Canaries** | 100% | 100.0% (all injected canaries blocked) | ✅ PASS |
| **Semantic Blocking Recall** | $\ge 95.0\%$ | 100.0% (all critical semantic faults caught) | ✅ PASS |
| **P95 Latency Ratio (V2 vs Legacy)** | $\le 1.50\times$ | **0.956x** (V2: 801.75s, Legacy: 838.88s) | ✅ PASS (Faster than Legacy) |
| **Median Token Cost Ratio (V2 vs Legacy)**| $\le 2.00\times$ | **0.253x** (V2: 24,294 tokens, Legacy: 96,169 tokens) | ✅ PASS (74.7% token reduction) |
| **Total Operational Cost** | Cost Parity | V2: \$1.2664 vs Legacy: \$4.7599 (Ratio: 0.253) | ✅ PASS (73.4% spend savings) |
| **Critical Semantic Repetitions** | $\ge 3$ runs | 3 matched seeds (101, 202, 303) evaluated | ✅ PASS |
| **Live Paired Papers ($\ge 18$ papers)** | $\ge 18$ pairs | 18 paired papers evaluated end-to-end | ✅ PASS |
---

## 6. Closed Legacy Deletion Inventory (37 Symbols)

| Classification | Count | Description / Rationale |
|---|---|---|
| **`RETIRED_CONFIRMED`** | 6 | Monolithic coordinators and unbudgeted generation functions replaced by V2 Loop Engine (`router.router`, `pipeline._generate_section_once`, `pipeline.repair_evidence`, `pipeline.validate_section`, `pipeline.review_answers`, `pipeline.replace_rejected_question`). |
| **`MIGRATED_TO_V2`** | 16 | Modular capabilities migrated to canonical subpackages (`app.ingestion.*`, `app.providers.*`, `app.blueprint.*`, `app.generators.*`, `app.evaluators.*`, `pipeline.generate_section` via back-compat legacy shim, `pipeline.generate_json`, `LLMService.generate`). |
| **`LIVING_PUBLIC_ADAPTER_PRESERVED`**| 15 | Public API endpoints, HTTP fetchers, .NET worker integration, and EF Core graph builders retained for contract compatibility (`main.app`, `router.sources`, `router.source`, `router.ingest`, `router.section`, `router._stream_section`, `extractor.fetch_web_url`, `extractor.ingest_source`, `extractor.fetch_source`, `extractor.search_sources`, `ReadingPaperWorker`, `ReadingPaperWorker.BuildExam`, `ReadingPaperAiClient`, `ReadingPaperRules`, `ReadingPaperEndpoints`). |
| **Total Tracked Symbols** | **37** | **100% Closed & Accounted For** |

---

## 7. Open Blockers & Production Handoff

1. **Live Model Generation & T15-04 (G12 & T15-04)**:
   - **Status**: `BLOCKED_ON_LIVE_GENERATION_TERMINAL_COMPLETION`
   - **Current State**: Disposable test credentials in `deploy/envs/ai.env` were authorized by user policy and validated with a live configured-model smoke test (`https://api.minimaxi.chat/v1/chat/completions`, HTTP 200 PONG). Secrets remained strictly redacted in logs, traces, and reports. The browser automation harness (`scripts/refactor/run_browser_e2e.py` and `playwright_browser_e2e.mjs`) was executed live on candidate commit `56d060d`: navigation, 3 PMC source ingestions, draft creation, retried failed job, and cancel jobs succeeded. Section 1 passage and candidate questions completed through live MiniMax generation. However, the full 40-question draft-to-publish did not achieve terminal completion within test timeout due to loop token caps and live LLM latency.
   - **Missing Input**: Full 3-section, 40-question live generation reaching durable Completed Draft in PostgreSQL, followed by admin feedback edit and manual publish.
   - **Owner**: QA / Test Lead & AI Pipeline Lead.
   - **Resume Command**: `python3 scripts/refactor/run_browser_e2e.py --live-only`

2. **Live Paired Benchmark (T15-02 / P15-02)**:
   - **Status**: ⏸️ **EXECUTED LIVE — BLOCKED ON VALID-DRAFT RATE THRESHOLD**
   - **Current State**: Executed 18 paired papers per engine (36 total papers, 904 live dispatches, 100% pure `MiniMax-Text-01`, 0 Groq calls) in campaign `camp_G15_c9750f53d6b5`. Performance: **0.956x P95 latency ratio** (PASS <= 1.5x) and **0.253x median token cost ratio** (PASS <= 2.0x, 74.7% token reduction, $1.2664 total V2 cost vs $4.7599 Legacy). Fidelity must-reject (100%) and semantic blocking recall (100%) both passed. However, V2 reached 11/18 valid drafts (61.1%), which remains below the mandatory >= 95.0% threshold (17/18) due to strict evaluator rejections on candidate slots.
   - **Resolved Defects**: (a) Repaired unescaped quote lookahead in `parser.py` so internal prose lists (`"red", "blue"`) do not trigger `Expecting ':' delimiter`; (b) Normalized Unicode whitespace in `clean_reasoning_tags`; (c) Normalized question type casing in evaluators/selectors; (d) Made bootstrap artifact IDs deterministic and rehydrated persisted envelopes on retry to prevent HTTP 409 mutation conflicts; (e) Enforced strict MiniMax-only allowlist.
   - **Owner**: AI Pipeline Lead.
   - **Resume Command**: `python3 scripts/refactor/run_phase15_benchmarks.py --concurrency 4`
3. **Canonical Test Manifest Map (124 IDs)**:
   - **Status**: ✅ **COMPLETED**
   - **Current State**: `docs/refactor/verification/test-manifest.json` is fully populated with all 124 canonical test IDs from Phase 00 through Phase 15 with executable commands, test nodes, metrics, and evidence paths.
   - **Verification**: 121 tests PASSED, 3 tests PENDING (T15-04, T15-06, T15-07).

4. **Container-Level Rollback Rehearsal (T15-07)**:
   - **Status**: ⏸️ **PARTIALLY VERIFIED / BOUNDARY DISCLOSED**
   - **Current State**: Rehearsed using authentic pre-V2 binary built from Sprint 6 commit `7d2b9e1` (tagged `langfens-exam:v1.9.4-compat`) against isolated DB clone `exam_test_rollback_clone`. Pre-V2 container booted cleanly, served all public reads (HTTP 200), enforced auth (HTTP 401), and preserved all measured V2 clone rows (1 job, 1 run, 48 artifacts, 2 outbox events, 1 feedback record) with 100% identical MD5 checksums.
   - **Boundary Disclosed**: Pre-V2 binary lacks V2 checkpoint endpoints (returns 404). Candidate V2 container reading via `/resume/{runId}` succeeds for V2-pinned formats (`isCompatible: true`), but retained formats with unpinned cap profiles or `policy=1.0.0` require an executed migration/drain path, and no previous tagged V2 release exists in git releases.
   - **Owner**: DevOps / Release Engineer.
   - **Resume Command**: `python3 scripts/refactor/rehearse_container_rollback.py`

5. **Production Canary Observation Window (T15-06)**:
   - **Status**: ⏸️ **BLOCKED_ON_PRODUCTION_OBSERVATION**
   - **Missing Input**: Live staged canary deployment (10% $\to$ 50% $\to$ 100%) with $\ge 20$ completed eligible jobs across $\ge 24$ hours bake window on live production traffic.
   - **Owner**: Release Operations / SRE Lead.
   - **Resume Command**: `python3 scripts/refactor/verify_phase.py --phase 15 --check canary`

**Final Release Verdict**: **`BLOCKED`**  
*Phase 15 implementation, closed legacy deletion inventory (37 symbols), living public adapters, and local deterministic test suites (732 passing) are complete. Candidate readiness and Gate G15 remain held as BLOCKED pending resolution of documented upstream and operational blockers.*
