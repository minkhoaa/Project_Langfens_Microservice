# Resume Checkpoint — Phase 09 Question Candidates Engine (Reconciled & Remediated)

**Checkpoint Date:** 2026-10-04T11:45:00Z  
**Phase Completed:** Phase 09 (Candidate Engine 100% Complete & Remediated; P09-01 through P09-10 fully satisfied with Real PostgreSQL Durability and Actual Worker Entrypoint Wiring Proven)  
**Current Gate:** Gate G09  
**Gate Status:** PASS  
**Readiness for Phase 10:** READY_FOR_PHASE_10  
**Git SHA:** `7a4d0e7503710d3b87c95e15831829552ba7be8d`  
**Full Worktree Diff SHA-256:** `6e63cdee7d042b12d3a10e76e922489c8aba87b8878c0727b9f6d20ad81b3757`  
**Scoped Tracked Diff SHA-256:** `ca81e80d70ac9683c0f4d4af93d352d3612445c0fa0272f6042245b48f84bf39`  
**Combined Tree SHA-256:** `0d713a0e0d3ac6bce0543bff0ad5e3c8b7bfc612399d157a89e7b6e167820bbd`  

---

## 1. Remediated & Completed Work

1. **Production Entrypoint & Worker Wiring (Step C):**
   - Implemented typed `POST /v1/autogen/reading-paper/questions` endpoint in `services/generation-service/app/router.py`.
   - Implemented `ReadingPaperAiClient.GenerateQuestionsAsync` in `services/exam-service/Features/ReadingPaper/ReadingPaperAiClient.cs`.
   - Wired production callsite in `ReadingPaperWorker.cs:205-248`: when V2 engine is active and questions are decoupled, `ReadingPaperWorker` calls `ai.GenerateQuestionsAsync(...)` with authoritative passage and blueprint refs from PostgreSQL, parses generated groups, and commits the section checkpoint.
   - Comprehensive test suite in `test_t00_endpoints.py` covering positive routing and negative fail-closed checks (stale/missing passage, wrong artifact type).

2. **Real PostgreSQL Durability & Crash Resumption (Step D):**
   - All 7 real PostgreSQL durability scenarios verified on port 5099 (`exam_test_phase09`):
     * Scenario 1: Pre-dispatch crash (RESERVED state before dispatch).
     * Scenario 2: In-flight connection drop (`record_unknown_outcome` -> UNKNOWN_OUTCOME reservation preserved).
     * Scenario 3: Pre-commit crash (draft saved, uncommitted accepted head).
     * Scenario 4: Post-commit pre-ACK crash (resumes existing head v1 with 0 new generator calls).
     * Scenario 5: Idempotent replay accounting (0 new items, calls/tokens/wall time delta = 0, deadline/LeaseUntil preserved, zero duplicate heads in PostgreSQL).
     * Scenario 6: Failure & retry accounting (infeasible pool triggers clean fail-closed escalation; workflow parent operation verified reconciled (`COMPLETED`) in PostgreSQL).
     * Scenario 7: Actual `QuestionCandidateLoop` mid-flight crash at Q17 and clean resumption from PostgreSQL (Q14-16 preserved, provider delta = 0, winning group committed).

3. **Metric Engine & Checkpoint Recalculation (Step A):**
   - Implemented canonical `app/evaluators/metrics.py` (v2.1.0) with explicit allowlists and frozen denominators.
   - Fixed missing `ambiguity_total` increment bug in benchmark runner.
   - Fixed evaluator ERROR being miscounted as True Positive.
   - Fixed `AmbiguityAndDistractorEvaluator`: added missing `issue_id` in conjoined answer check and stripped punctuation in distractor token matching.
   - 11 unit & regression tests in `tests/test_t07_metrics.py` passing cleanly.

4. **Paired Benchmark Metrics Distinction (Step F):**
   - Corrected metrics in `paired-passage-benchmark-report.json`: separated eligible generation success (1/3 = 33.3%) from accepted artifact word count compliance (1/1 = 100.0%).

5. **Full Microservice Regression Suite:**
   - 246/246 Python tests in `services/generation-service/tests/` passing in 20.60s.
   - 74/74 .NET tests in `services/exam-service.Tests/` passing in 16.0s.

---

## 2. Gate Decision & Blockers Breakdown

- **Internal Phase 09 Implementation:** **100% PASS** (all work packages P09-01 through P09-10 satisfied with executable proof).
- **Upstream Dependency Gates (G07, G08):** **PASS** (both G07 live semantic benchmarks and G08 paired live benchmark converged and stamped PASS).
- **Gate G09 Status:** **PASS**.
- **Phase 10 Readiness:** **READY_FOR_PHASE_10**.
