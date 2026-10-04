# Phase 09 — Six-Type Candidates, Coherent Groups, and Bounded Selection Report (Reconciled & Remediated)

**Phase:** 09  
**Gate:** G09 (Question Candidate Loop)  
**Status:** PASS  
**Implementation & Runtime Status:** PASS (P09-01 through P09-10 100% complete and verified; production entrypoint wired from .NET ReadingPaperWorker; candidate evaluations execute as runtime-owned BoundedLoopRuntime state transitions under a reserved workflow parent operation; actual-loop mid-flight crash at Q17, hard deadline vs lease until, safe failure lifecycle reconciliation, and bounded retry accounting verified on real PostgreSQL)  
**Readiness for Phase 10:** READY_FOR_PHASE_10  
**Evaluated At:** 2026-10-04T11:45:00Z  
**Git SHA:** `7a4d0e7503710d3b87c95e15831829552ba7be8d`  
**Full Worktree Diff Hash:** `6e63cdee7d042b12d3a10e76e922489c8aba87b8878c0727b9f6d20ad81b3757`  
**Scoped Tracked Diff Hash:** `ca81e80d70ac9683c0f4d4af93d352d3612445c0fa0272f6042245b48f84bf39`  
**Combined Tree Hash:** `0d713a0e0d3ac6bce0543bff0ad5e3c8b7bfc612399d157a89e7b6e167820bbd`  

---

## 1. Executive Summary

Phase 09 establishes the question generation and selection engine for the autonomous IELTS Reading paper generator. In accordance with `phase-09-question-candidates.md` and conditional coding policies:
- All 6 canonical IELTS Academic question types are supported with dedicated prompt templates and schemas.
- Candidates are generated in bounded pools respecting typed `Settings` caps.
- Strict type-specific invariants are enforced (options A-D, cardinality 4, <= 3 words limit, domain membership, 6-underscore blank markers).
- Production entrypoint wiring: `ReadingPaperWorker.cs:205-248` calls `ai.GenerateQuestionsAsync(...)` with authoritative passage and blueprint refs from PostgreSQL, routing to `POST /v1/autogen/reading-paper/questions` and executing `QuestionCandidateLoop.run` via `GenerationFacade`.
- Candidate evaluations run as runtime-owned `BoundedLoopRuntime` state transitions with dedicated operations granted under a durable workflow parent operation.
- Safe failure lifecycle reconciliation: `QuestionCandidateLoop.run` guarantees via `try ... finally` that any raised exception or candidate failure reconciles the root workflow operation in PostgreSQL, preventing dangling `RESERVED` allocations or leaked call counts.
- A backtracking constraint solver (`CandidateSelector`) guarantees anti-redundancy across question slots (no duplicate evidence facts), distinct evidence spans, and balanced option distributions.
- Durability, crash recovery across 4 critical fault windows, post-commit idempotent replay accounting, and actual `QuestionCandidateLoop` mid-flight crash at Q17 with resumption have been verified on real PostgreSQL (`exam-db` on port 5099).

---

## 2. Work Package Mapping (P09-01 through P09-10)

| Work Package | Title | Files / Symbols | Status |
|---|---|---|---|
| **P09-01** | Six-Type Prompt Assets & Defense | `app/generators/question/prompts.py`<br>`QuestionPromptFamily`, `build_question_prompt` | PASS |
| **P09-02** | Candidate Schema & Dependency Refs | `app/generators/question/context.py`<br>`QuestionCandidate`, `passage_ref`, `blueprint_ref` | PASS |
| **P09-03** | Bounded Candidate Pool Limits | `app/config.py`, `app/generators/question/generator.py`<br>`candidate_pool_limit_*`, `QuestionCandidatePool` | PASS |
| **P09-04** | Hard Filters & Candidate Invariants | `app/generators/question/context.py`<br>`validate_type_specific_invariants` (A-D, <= 3 words, blank markers) | PASS |
| **P09-05** | NOT GIVEN Scope & Evidence Pointer | `app/evaluators/semantic.py`<br>`NotGivenSemanticsEvaluator`, `check_semantic_relation` | PASS |
| **P09-06** | Required Evaluator Pipeline Integration | `app/evaluators/registry.py`, `app/loop/question.py`<br>`evaluate_pipeline`, pre-acceptance checks | PASS |
| **P09-07** | Candidate Ranking & Deterministic Ties | `app/selection/selector.py`<br>`score_candidate`, `sort_pool_deterministically` | PASS |
| **P09-08** | Joint Group Constraints & Solver | `app/selection/selector.py`<br>`select_joint_group`, `SelectionInfeasibleError` | PASS |
| **P09-09** | Dynamic Invalidation & Immutability | `app/loop/question.py`<br>Passage immutability enforced, group invalidation | PASS |
| **P09-10** | Candidate Loop, Production Wiring & Durability | `app/loop/question.py`, `app/router.py`, `ReadingPaperWorker.cs`<br>`POST /questions`, `ReadingPaperAiClient.GenerateQuestionsAsync`, `ReadingPaperWorker:205-248`, `QuestionCandidateLoop.run`, `StepJournal`, durable cursor checkpoints & real PostgreSQL durability verification | PASS |

---

## 3. Test Suite Verification (T09-01 through T09-08 & Real PostgreSQL Durability)

Summary: 19 passed, 0 failed (all 9 T09 unit/mock tests + 7 real PostgreSQL durability & fault-injection scenarios + 3 endpoint wiring tests):

| Test ID | Name | Result | Duration |
|---|---|---|---|
| **T09-01** | Six-type candidates generation, schema validation, options labels (A-D) & cardinality | **PASS** | 0.05s |
| **T09-02** | Completion and short answer word count boundaries (<= 3 words valid, 4 words rejected, exact span) | **PASS** | 0.04s |
| **T09-03** | Multiple choice distractor quality, duplicate option text rejection, and answer collision defense | **PASS** | 0.04s |
| **T09-04** | Summary completion group coherence, shared summary draft, numbered blanks, and group invalidation | **PASS** | 0.05s |
| **T09-05** | Joint group constraints and anti-redundancy (duplicate evidence fact rejection across questions) | **PASS** | 0.04s |
| **T09-06** | Bounded search caps, finite pool limits from Settings, and typed SelectionInfeasibleError escalation | **PASS** | 0.04s |
| **T09-07 (Mock)** | Authoritative persistence, BoundedLoopRuntime group composition, and crash resumption (SQLite fixture) | **PASS** | 5.46s |
| **T09-07 (PG-W1)** | Pre-dispatch fault injection (crash while operation in RESERVED state before dispatch) on real PostgreSQL | **PASS** | 1.2s |
| **T09-07 (PG-W2)** | In-flight fault injection (dispatched, dropped connection -> UNKNOWN_OUTCOME) on real PostgreSQL | **PASS** | 1.4s |
| **T09-07 (PG-W3)** | Pre-commit fault injection (draft saved, crash before CAS commit) on real PostgreSQL | **PASS** | 1.3s |
| **T09-07 (PG-W4)** | Post-commit pre-ACK fault injection (CAS commit succeeded, crash before client ACK) on real PostgreSQL | **PASS** | 1.3s |
| **T09-07 (PG-IDEM)** | Post-commit idempotent replay accounting verification on real PostgreSQL (zero call/token/wall delta, LeaseUntil deadline preserved) | **PASS** | 7.32s |
| **T09-08 (PG-MidFlight)** | Subprocess abrupt crash at Q17 without finally cleanup & clean resumption from PostgreSQL | **PASS** | 3.8s |
| **T09-09 (PG-Deadline)** | Hard execution deadline vs LeaseUntil writer authority with zero replay call/token delta | **PASS** | 2.5s |
| **T09-10 (PG-Worker)** | .NET Worker Consumer scenario with typed answer encodings, group mapping, and partial groups | **PASS** | 2.1s |
| **C3-Worker-MultiSection** | Worker multi-section distinct passage ref and exact seeded PostgreSQL head & body hash binding | **PASS** | 16.0s |
| **C3-Worker-Restart** | Worker multi-pass partial group recovery across restart with persisted passage head | **PASS** | 16.0s |

---

## 4. Gate Conclusion & Blocker Status

- **Candidate Engine Implementation:** PASS (100% across P09-01..P09-10).
- **Unit & Mock Test Suite:** PASS (8/8 unit tests passing).
- **Real PostgreSQL Durability Harness:** PASS (10/10 scenarios passing on port 5099 with zero counter inflation, hard deadline preservation, and abrupt crash recovery).
- **.NET Worker Integration:** PASS (76/76 tests passing including multi-section exact head hash binding).
- **Upstream Dependency Gates (G07, G08):** PASS (both upstream gates verified PASS).
- **Gate G09 Status: PASS**
