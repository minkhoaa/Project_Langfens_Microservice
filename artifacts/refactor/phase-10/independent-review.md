# Independent Review Report — Phase 10: Blind Solver, Adversary & Grounding Uniqueness

**Phase Reviewed:** Phase 10 — Blind Solver, Adversary, and Evidence-Backed Uniqueness  
**Review Date:** 2026-10-04T12:45:00Z  
**Review Role:** Senior Reviewer (Sequential review per contract guidelines)  
**Git SHA:** `f56a0970bbf6190ea7e3af58d2ec8db9e5c9714f`  
**Tracked Diff Hash:** `ce10a9135f1b15bace8f62263448b57fc73db9b9c25ac2a58940df9b752a243a`  
**Full Worktree Diff Hash:** `ce10a9135f1b15bace8f62263448b57fc73db9b9c25ac2a58940df9b752a243a`  
**Combined Tree Hash:** `6ca2eff62764a093dc56d0515997678df5789e2b9ad12f07d642c00b5f88f630`  
**Gate Status:** **BLOCKED** (Implementation & Integration PASS; Upstream G07 Predecessor Deficit Unresolved)  

---

## 1. Scope and Inspected Artifacts

The reviewer inspected:
- **Canonical Contracts & DTOs:** `services/generation-service/app/contracts/solver.py`
  * `StudentVisibleQuestion`, `StudentVisibleOption`, `BlindSolverInput`
  * `SolverOutput`, `SolverSpan`, `AdversaryOutput`, `AdversaryAlternative`
  * `ComparisonResult`, `AdjudicationResult`, `DiversityProfile`
- **Serialization & Envelopes:** `services/generation-service/app/solvers/serializer.py`
  * `project_to_student_visible`, `build_blind_solver_input`, `build_secure_envelope`
  * XML attribute escaping and injection sanitization
- **Versioned Prompts & Assets:** `services/generation-service/app/solvers/prompts.py`
  * `SOLVER_PROMPT_VERSION`, `ADVERSARY_PROMPT_VERSION`, asset hashes, redacted logging
- **Core Solver & Adversary Engines:**
  * `services/generation-service/app/solvers/solver.py`: span grounding verification, CoT rejection, question-type-conditioned normalization
  * `services/generation-service/app/solvers/adversary.py`: outside-knowledge rejection & ambiguity classification
  * `services/generation-service/app/solvers/comparison.py`: canonical TFNG/YNNG/MCQ/completion matching without fuzzy fallback
  * `services/generation-service/app/solvers/diversity.py`: Settings-derived provider selection, dynamic profile updating, correlation tracking
  * `services/generation-service/app/solvers/adjudication.py`: evidence-backed adjudication without majority-vote override
  * `services/generation-service/app/solvers/cache.py`: student-visible cache keying with key-swap invariance
- **Authoritative Evaluator & Runtime Composition:**
  * `services/generation-service/app/evaluators/solver.py`: `BlindSolverEvaluator` with `allow_simulation=False` default fail-closed behavior
  * `services/generation-service/app/loop/question.py`: `QuestionCandidateLoop`
  * `services/generation-service/app/facade.py`: `GenerationFacade`
- **Test Suites:**
  * `services/generation-service/tests/test_t10_blind_solvers.py` (10 tests covering T10-01..T10-08, fail-closed gateway check, real gateway durability accounting, and full loop composition)
  * `services/generation-service/tests/test_t09_question_candidates.py` (9 regression tests)
  * `services/generation-service/tests/test_t07_evaluators_repairs.py` & `test_t08_passage_loop.py` (35 regression tests)

---

## 2. Review Findings & Verification

1. **DTO Transport Blindness & Allowlist Isolation (P10-01, P10-02 / T10-01, T10-02):**
   - Verified that `BlindSolverInput.to_canonical_payload()` and `project_to_student_visible()` project candidates strictly through an allowlist consisting only of approved passage text, question stem, instructions, visible options, and shared context.
   - Tested that expected answers, evidence quotes, explanations, absence assessments, generation prompts, and hidden canaries are 100% absent from serialized requests and prompt messages.
   - Verified untrusted student prompt text containing literal quotes (e.g. `"answer": "TRUE"`) remains safely escaped inside `<prompt>` tags as data. Extra fields on `StudentVisibleQuestion` are rejected by `extra="forbid"`.
   - Verified XML attributes (`question_number`, `question_type`) are quoted and escaped, preventing attribute/tag injection.
   - Verified key-swap invariance: swapping the expected answer on a question from "A" to "B" leaves the SHA-256 request hash and cache key completely identical, while flipping the comparison outcome from match to mismatch.

2. **Grounding, Spans, and Answer Comparison (P10-03, P10-05 / T10-03):**
   - Verified that solver outputs must cite exact verbatim spans from the approved passage. Spans not existing verbatim in the passage fail closed. Per P10-03, missing or invalid spans are non-pass for all answers (including NOT_GIVEN complete coverage).
   - Verified that hidden chain-of-thought fields (`thought`, `scratchpad`) are rejected.
   - Tested canonical comparison for TFNG (`TRUE`/`FALSE`/`NOT_GIVEN`), YNNG (`YES`/`NO`/`NOT_GIVEN`), MCQ option letters, and completion strings with fixed UK/US spelling aliases. Normalization is conditioned on question type so completion answers like `"T"` or `"A."` are not coerced into booleans/options. Fuzzy matching (Levenshtein, token overlap) is strictly prohibited.

3. **Adversary Verification & Outside-Knowledge Defense (P10-04, P10-07 / T10-04, T10-05):**
   - Verified that grounded multiple valid options detected by the adversary trigger an `AMBIGUOUS_DEFECTIVE` adjudication verdict with `HIGH` severity.
   - Verified that adversary claims relying on outside world knowledge without valid passage text citations are classified as unsupported and filtered out; valid items are accepted without false rejection.
   - Proved that adjudication never changes the answer key to match the solver and never uses majority vote to override passage grounding.

4. **Authoritative Gateway Dispatch, Fencing & Accounting (P10-09 / T10-06):**
   - Verified that missing gateway strictly fails closed with `EVALUATOR_UNAVAILABLE` unless `allow_simulation=True` is explicitly passed.
   - Verified that all solver and adversary calls execute through `ProviderGateway` with temporary `RetryPolicy(max_attempts=1)` enforcing SDK retry=0.
   - Verified exact fencing propagation: `_dispatch_solver` and `_dispatch_adversary` read `context.authority.lease_owner` and `context.authority.epoch` from `LoopContext.authority`.
   - Verified response payload extraction via `resp.parsed_payload if resp.parsed_payload is not None else resp.raw_text`.
   - Verified in `test_t10_06_b` that operations are durably granted in `DurableStoreFake`, token/wall-time usage is reconciled, and operations transition to `COMPLETED`.
   - Verified diversity profile is dynamically refreshed from actual `ProviderResponse.provider_name` and `model_name`.

5. **Legacy Branch Preservation & Facade Composition:**
   - Per Phase 10 specification, the legacy default branch is preserved: `QuestionCandidateLoop.__init__` and `GenerationFacade.__init__` maintain their default registries without unconditionally registering `BlindSolverEvaluator`.
   - Verified in `test_t10_06_c` that opt-in V2 composition with `eval_blind_solver_adversary` in `required_evaluator_ids` executes through `BoundedLoopRuntime` state transitions and commits winning question groups into durable storage.

---

## 3. Review Limitations & Gate Determination

1. **Predecessor Quality Deficit (G07):**
   - Clean G07 corpus/config is frozen, but no live campaign has run; historical metrics cited by older reports used the retired corpus and are not current acceptance results.
   - G07 remains BLOCKED pending authorization and a threshold-passing live run. G08/G09 are also blocked through this dependency; their implementation tests remain PASS.

2. **Pending live G10 semantic campaign:**
   - The single allocation request covers both gates, but G10 authorization is still REQUESTED. Tests and fake transports do not establish live quality; exact commands and caps are in artifacts/refactor/campaign_allocation_request.json.

### Final Conclusion
- **Implementation Status:** **PASS** (P10-01..P10-09 and T10-01..T10-08 verified).
- **Gate G10 Status:** **BLOCKED** pending authorized clean G07/G10 live campaigns.
- **Phase 11 Readiness:** **READY_FOR_PHASE_11_ARCHITECTURE_WITH_KNOWN_GAPS**.
