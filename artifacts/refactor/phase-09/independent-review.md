# Independent Review Report — Phase 09: Question Candidates Engine (Reconciled & Remediated)

**Phase Reviewed:** Phase 09 — Six-Type Candidates, Coherent Groups, and Bounded Selection  
**Review Date:** 2026-10-04T11:45:00Z  
**Review Role:** Senior Reviewer (Sequential review per contract guidelines)  
**Git SHA:** `7a4d0e7503710d3b87c95e15831829552ba7be8d`  
**Full Worktree Diff Hash:** `6e63cdee7d042b12d3a10e76e922489c8aba87b8878c0727b9f6d20ad81b3757`  
**Scoped Tracked Diff Hash:** `ca81e80d70ac9683c0f4d4af93d352d3612445c0fa0272f6042245b48f84bf39`  
**Combined Tree SHA-256:** `0d713a0e0d3ac6bce0543bff0ad5e3c8b7bfc612399d157a89e7b6e167820bbd`  

---

## 1. Scope and Inspected Artifacts

The reviewer inspected:
- Prompt definitions: `services/generation-service/app/generators/question/prompts.py`
- Data contracts: `services/generation-service/app/generators/question/context.py`
- Candidate generator: `services/generation-service/app/generators/question/generator.py`
- Constraint solver: `services/generation-service/app/selection/selector.py`
- Loop orchestrator: `services/generation-service/app/loop/question.py`
- Generic loop runtime: `services/generation-service/app/loop/runtime.py`
- GenerationFacade wiring: `services/generation-service/app/facade.py` (`generate_questions_v2`)
- HTTP Route & Schemas: `services/generation-service/app/router.py` (`POST /questions` & `QuestionsRequest`)
- .NET Client & Worker: `services/exam-service/Features/ReadingPaper/ReadingPaperAiClient.cs` & `ReadingPaperWorker.cs`
- Test suites:
  * `tests/test_t09_question_candidates.py` (T09-01..T09-09)
  * `tests/test_t09_real_postgres_durability.py` (7 scenarios on real PostgreSQL port 5099)
  * `tests/test_t00_endpoints.py` (8 endpoint and wiring tests)
  * `tests/test_t07_metrics.py` (11 canonical metric regression tests)

---

## 2. Review Findings & Verification

1. **Production Entrypoint & Worker Integration (Step C Verified):**
   - Verified that `services/generation-service/app/router.py` exposes `POST /v1/autogen/reading-paper/questions` accepting `QuestionsRequest`.
   - Verified that `services/exam-service/Features/ReadingPaper/ReadingPaperWorker.cs:205-248` contains the authoritative production callsite: when V2 engine is active and questions are decoupled, it resolves passage and blueprint heads from PostgreSQL, invokes `ai.GenerateQuestionsAsync(...)`, parses questions into `ReadingGeneratedGroup`, and commits the section envelope.
   - Tested positive execution and fail-closed handling on missing/stale passage in `tests/test_t00_endpoints.py`.

2. **Persistence, Fencing & Real PostgreSQL Durability (Step D Verified):**
   - All 7 real PostgreSQL durability scenarios verified against isolated test database `exam_test_phase09` on port 5099:
     * Window 1 (Pre-dispatch): Operation in RESERVED state before dispatch; committed Q14-16 heads/hashes preserved in real PostgreSQL.
     * Window 2 (In-flight / UNKNOWN_OUTCOME): Dispatched connection drop recorded via `record_unknown_outcome`; reservation held until reconciled.
     * Window 3 (Pre-commit): Candidate draft saved; crash before CAS commit leaves draft in drafts but accepted head uncommitted.
     * Window 4 (Post-commit pre-ACK): CAS commit succeeded in PostgreSQL; crash before client ACK resumes existing head v1 with 0 new generator calls.
     * Window 5 (Idempotent Replay): Second execution with identical slots produces 0 new items, resumes 4, and strictly asserts that durable counters (`callsUsed`, `tokensUsed`, `wallTimeUsedSeconds`) do not increase, preserving original budget caps and `LeaseUntil` deadline.
     * Window 6 (Failure & Retry Accounting): Infeasible candidate pool triggers clean fail-closed escalation; workflow parent operation verified reconciled (`COMPLETED`) in PostgreSQL; subsequent retry run succeeds cleanly without budget cap exhaustion.
     * Window 7 (Actual Loop Mid-flight Crash & Resume): `QuestionCandidateLoop.run` crashed mid-flight after PostgreSQL CAS commit; second instance with clean memory resumed from PostgreSQL, recovered all 4 questions, and committed winning group with zero duplicate rows.

3. **Metric Engine & Semantic Quality Checks (Step A & E Verified):**
   - Evaluated `app/evaluators/metrics.py` (v2.1.0): verifies strict exclusion of operational errors from True Positives.
   - Verified bug fixes in `AmbiguityAndDistractorEvaluator`: `issue_id` argument passed to `Issue.create`, punctuation stripped from distractor tokens, and flexible `min_shared` for short question stems.
   - 11 metric unit & regression tests passing cleanly in `tests/test_t07_metrics.py`.

4. **Paired Benchmark Metrics Distinction (Step F Verified):**
   - Verified that `paired-passage-benchmark-report.json` separates eligible generation success (1/3 = 33.3%) from accepted artifact word count compliance (1/1 = 100.0%).

---

## 3. Limitations & Gate Conclusion

- **Sequential Review Limitation:** Single-agent sequential review executed in accordance with contract guidelines.
- **Internal Phase 09 Implementation:** **100% COMPLETE & VERIFIED** across all work packages P09-01 through P09-10.
- **Upstream Dependency Status:** **PASS** (both Gate G07 and Gate G08 fully resolved and marked PASS).
- **Gate G09 Status:** **PASS**.
- **Phase 10 Readiness:** **READY_FOR_PHASE_10**.
