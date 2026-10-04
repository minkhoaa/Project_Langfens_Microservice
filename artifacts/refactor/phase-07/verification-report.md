# Independent Verification Report — Phase 07: Evaluators, Repairs & Quality Corpus (Reconciled)

**Phase:** Phase 07 — EvaluatorRegistry, RepairRegistry, and Evaluation Corpus  
**Gate:** G07  
**Date:** 2026-10-02  
**Overall Gate Status:** **BLOCKED**  
**Runtime Remediation Status:** **PASS**  
**Corpus Integrity Status:** **PASS (Authentic Europe PMC CC-BY-4.0 Sources Verified)**  
**Live Smoke Status:** **PASS**  
**Semantic Quality Status:** **FAIL (Official Holdout Recall 93.3% < 95.0%)**  
**Readiness for Phase 08:** **READY_FOR_PHASE_08_ARCHITECTURE_WITH_KNOWN_GAPS**  
**Git SHA:** `7a4d0e7503710d3b87c95e15831829552ba7be8d`  
**Diff Hash:** `c5e30cf50806fa401c3aa01227c6057c06f57fc4933cdf2979545430c91dcf8c`  

---

## 1. Executive Summary & Status Breakdown

An independent audit and remediation verification of Phase 07 was conducted in accordance with the Master Plan (`PLAN.md`), Validation Matrix, Phase 07 Specification (`phase-07-evaluators-repairs.md`), Caps ADR G06 (`ADR-004`), and repository evidence artifacts.

### Status Separation
| Dimension | Status | Notes |
|---|---|---|
| **runtimeRemediation** | **PASS** | All runtime defects (TypeError in BaseEvaluator error factory, nested SDK retries, missing required evaluator pipeline wiring, dynamic dependency closure in RepairPlanner, NOT GIVEN contradiction logic, and passage-wide chunked relation checking without truncation) have been fully remediated and verified with 26/26 executable regression tests. |
| **corpusIntegrity** | **PASS** | Fabricated descending PMC identifiers were retired and quarantined. Four authentic Europe PMC CC-BY-4.0 open-access articles were downloaded and validated directly from official JATS XML: `PMC13560651` (Deep-Sea Oceanography), `PMC13407692` (Quantum Physics), `PMC13517498` (Power Systems Engineering), and `PMC13621526` (Controlled Environment Agriculture). Stale snapshots were moved to `sources/quarantined/`. Cross-split 5-word shingle Jaccard overlap against dev is 0.0000 (strictly zero leakage). Both XML and TXT hashes bound in `corpus_manifest.json`. |
| **liveSmoke** | **PASS** | Live provider call executed live against MiniMax and Groq using configured credentials, verifying transport, parsing, and token accounting. |
| **semanticQuality** | **FAIL** | Official initial measurement on clean frozen Europe PMC holdout (`camp_g07_20261002_051852_40f2c1`) achieved: overall blocking recall **93.3%** (56/60, fails >= 95.0% threshold), MultipleChoiceSingle recall **80.0%** (8/10, fails >= 90.0% min), ambiguity recall **100.0%** (passes >= 90.0%), false rejection **5.0%** (passes <= 10.0%), critical canaries **100.0%** across 3 runs. |
| **overall G07** | **BLOCKED** | Gate G07 overall remains strictly BLOCKED due to holdout recall falling below the 95.0% threshold. Per contract rules, subsequent exploratory rerun (98.3%) is quarantined as contaminated and cannot override the gate block. |
| **readinessForPhase08** | **READY_FOR_PHASE_08_ARCHITECTURE_WITH_KNOWN_GAPS** | Architectural and runtime safety components are remediated, tested, and ready for consumption by Phase 08 passage loop. Downstream development proceeds under conditional coding with labeled fixtures and fakes. |

---

## 2. Dependencies Verification

| Dependency | Phase Description | Verified Gate Status | Verification Source |
|---|---|---|---|
| **G01** | Domain Contracts, Policies, Schemas | **PASS** | `artifacts/refactor/phase-01/gate.json` |
| **G04** | Ingestion, SourcePack, EvidenceGraph | **PASS** | `artifacts/refactor/phase-04/gate.json` |
| **G05** | ExamBlueprint & Source Suitability | **PASS** | `artifacts/refactor/phase-05/gate.json` |
| **G06** | Bounded Loop Runtime & IssueLedger | **PASS** | `artifacts/refactor/phase-06/gate.json` |

---

## 3. Findings Remediation & Regression Test Mapping

| Finding ID & Severity | Original Defect | Remediation Applied | Executable Regression Targets | Verified Status |
|---|---|---|---|---|
| **Finding 1 (High)** | Nested SDK retries in `OpenAICompatibleProvider._get_client` permitted OpenAI SDK `DEFAULT_MAX_RETRIES=2` to multiply attempts beneath `ProviderGateway.execute`. | Configured `max_retries=0` explicitly on `AsyncOpenAI` in `OpenAICompatibleProvider`, `GroqProvider`, and `MiniMaxProvider`. Added `http_client` injection for transport testing. | `tests/test_t03_providers.py` | **PASS (Resolved & Verified)** |
| **Finding 2 (High)** | `BaseEvaluator.evaluate` called `EvaluationResult.create_error` with mismatched keyword argument `message=` and omitted `evaluation_id`, raising unhandled `TypeError` on timeout/exception. | Corrected `create_error` call sites to pass `evaluation_id`, `error_message`, `target_ref`, `code`, `elapsed_ms`, and `scope`. Added explicit cancellation preservation. | `tests/test_t07_evaluators_repairs.py` | **PASS (Resolved & Verified)** |
| **Finding 3 (High)** | `NotGivenSemanticsEvaluator` truncated passage to `passage_text[:3000]`, dropping decisive evidence occurring after 3,000 characters. | Implemented `chunk_passage_coverage` guaranteeing 100% text coverage across paragraph/sentence boundaries without silent truncation. Enforced fail-closed `INCONCLUSIVE_OR_ERROR` on incomplete coverage. | `tests/test_t07_evaluators_repairs.py` | **PASS (Resolved & Verified)** |
| **Finding 4 (Medium)** | `validate_required_evaluators` was defined in `EvaluatorRegistry` but never called in `evaluate_pipeline`. | Wired `validate_required_evaluators` into `evaluate_pipeline` before execution plan dispatch. Missing required evaluators produce recorded `EvaluationResult(status=ERROR)` with `IssueCode.EVALUATOR_UNAVAILABLE`. | `tests/test_t07_evaluators_repairs.py` | **PASS (Resolved & Verified)** |
| **Finding 5 (Medium)** | `RepairPlanner.plan_repair` did not derive dependency closure dynamically or detect cycles. | Implemented `compute_dynamic_invalidation_closure` with forward dependency graph traversal, 3-color DFS cycle detection, and missing metadata fail-closed enforcement. | `tests/test_t07_evaluators_repairs.py` | **PASS (Resolved & Verified)** |
| **Finding 6 (Medium)** | Source provenance defect: holdout partition contained synthetic descending PMC IDs (`PMC8765432`, `PMC7654321`, etc.). | Replaced with verified Europe PMC CC-BY-4.0 open-access articles (`PMC13560651`, `PMC13407692`, `PMC13517498`, `PMC13621526`). XML and TXT snapshots saved; zero leakage verified (Jaccard = 0.0000). | `artifacts/refactor/phase-07/corpus/provenance.json`<br>`artifacts/refactor/phase-07/corpus/sources/` | **PASS (Resolved & Verified)** |

---

## 4. Live Benchmark Campaign Results

### Official Initial Frozen Holdout Measurement (`camp_g07_20261002_051852_40f2c1`)
Conducted on clean, frozen Europe PMC holdout partition within production caps:
- **Overall Blocking Recall:** **93.3%** (56/60 invalid items detected; Target: ≥ 95.00% ❌ **FAIL**)
- **Per-Type Blocking Recall:** (Target: ≥ 90.00%)
  - TrueFalseNotGiven: 90.0% (9/10 TP, 10/10 TN) ✅ **PASS**
  - SentenceCompletion: 100.0% (10/10 TP, 10/10 TN) ✅ **PASS**
  - MultipleChoiceSingle: 80.0% (8/10 TP, 10/10 TN) ❌ **FAIL**
  - SummaryCompletion: 100.0% (10/10 TP, 10/10 TN) ✅ **PASS**
  - YesNoNotGiven: 90.0% (9/10 TP, 9/10 TN, 1 FP) ✅ **PASS**
  - ShortAnswer: 100.0% (10/10 TP, 10/10 TN) ✅ **PASS**
- **Ambiguity Recall:** **100.0%** (14/14 gold items detected; Target: ≥ 90.00% ✅ **PASS**)
- **False Rejection Rate:** **5.0%** (3/60 valid rejected; Target: ≤ 10.00% ✅ **PASS**)
- **Critical Canaries Rejection (Worst of 3 Runs):** **100.0%** (12/12; Target: 100.0% ✅ **PASS**)

### Exploratory Rerun Disclaimer (`camp_g07_20261002_052446_28203b`)
A subsequent rerun on the holdout partition after dev remediation achieved 98.3% overall recall. However, per Validation Matrix contract rules and holdout integrity policy, this rerun is classified as **CONTAMINATED / EXPLORATORY** because it was evaluated on the same partition after seeing failure modes. It cannot be used as an official gate PASS claim. The official gate status preserves the initial measurement FAIL.

---

## 5. Remaining Blockers & Next Executable Commands

1. **BLOCKER-01-SEMANTIC-RECALL-FAIL:**
   - **Root Cause:** MultipleChoiceSingle recall on initial holdout was 80.0% (< 90.0%), pulling overall holdout recall to 93.3% (< 95.0%).
   - **Remedy:** Validate generic distractor detection on dev, freeze a fresh versioned holdout partition (v3), and benchmark without tuning on holdout.
   - **Executable Command:**
     ```bash
     PYTHONPATH=services/generation-service services/generation-service/.venv/bin/python scripts/refactor/run_phase07_semantic_benchmark.py --partition dev
     ```
