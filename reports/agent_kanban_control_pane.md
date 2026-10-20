# Team Agent Orchestration — Control Pane & Agent Kanban

**Branch:** `autonomous-generation`  
**Date:** 2026-10-20  
**Objective:** Critical Content Generation Correctness Gate for Langfens Autonomous Reading Generation  

## Operating Model & Rules
- **Integrator:** Orchestrator
- **Policy Invariant:** NO live MiniMax calls; use realistic recorded/mock provider fixtures. Fail-closed on errors.
- **Single Runner Invariant:** Exactly ONE `ReadingGenerationPipeline` and ONE `SectionRunner` across S1, S2, and S3.
- **Semantic Correctness:** Real provider responses must be parsed, validated, and evaluated. Zero synthetic passage padding or answer key rotation/fabrication.

---

## Agent Kanban Board

| ID | Title | Owner | State | File Scope | Acceptance Criteria | Merge Gate | Handoff |
|---|---|---|---|---|---|---|---|
| **CARD-001** | Real Provider Passage Synthesis & Anti-Padding | `passage-engineer` | `merged` | `services/generation-service/app/section_runner.py`, `app/reading_generation.py` | Passage committed originates from provider draft; fail-closed on provider failure; no synthetic padding | Passage evaluation passes; provider failure blocks acceptance | Verified via `test_gate_1`, `test_gate_2` |
| **CARD-002** | Real Question Candidate Pool Generation & Valid Answers | `question-engineer` | `merged` | `services/generation-service/app/section_runner.py`, `app/reading_generation.py` | Questions originate from provider candidate pools; no answer rotation or template keys; true absence assessment for NOT GIVEN | Structure, verbatim, and evidence offset evaluators pass | Verified via `test_gate_3`, `test_gate_4`, `test_gate_4b` |
| **CARD-003** | Blind-Solver & Adversarial Integration in SectionRunner | `eval-specialist` | `merged` | `services/generation-service/app/section_runner.py`, `app/reading_evaluation.py` | Independent blind solver and adversary review execute in SectionRunner and can reject ambiguous or mismatched questions | `eval_blind_solver_adversary` executes and blocks mismatched/ambiguous items | Verified via `test_gate_5a`, `test_gate_5b` |
| **CARD-004** | Single Pipeline & SectionRunner Across S1/S2/S3 with Fencing | `arch-integrator` | `merged` | `services/generation-service/app/pipeline.py`, `app/section_runner.py` | S1, S2, S3 all execute through single SectionRunner; checkpoint/fencing/budget preserved; safe S2/S3 reuse | 40-question paper mock E2E passes sequential & parallel | Verified via `test_gate_6`, `test_reading_pipeline_mock_e2e.py` |
| **CARD-005** | Acceptance Test Suite with Realistic Recorded Fixtures | `qa-lead` | `merged` | `services/generation-service/tests/unified/*` | 7 acceptance criteria verified: real passage origin, provider failure fails closed, questions from candidates, bad keys rejected, blind solver blocks, full paper mock E2E, crash recovery | All 7 acceptance tests + regression suite pass 100% | Verified: 29/29 unified, 205/205 core, 80/80 .NET |

---

## Merge Readiness Checklist
- [x] Gate 1: Committed passage originates from provider response (no synthetic fabrication on failure)
- [x] Gate 2: Provider failure cannot produce an ACCEPTED passage
- [x] Gate 3: Generated questions actually originate from parsed provider candidates
- [x] Gate 4: Incorrect MCQ keys and unsupported TFNG/YNNG answers rejected
- [x] Gate 5: Blind-solver and adversarial checks run and block acceptance
- [x] Gate 6: All three sections use the same runner and pass full-paper mock E2E
- [x] Gate 7: Crash recovery preserves accepted content and handles CAS/leases properly

---

## Verification Evidence
1. `tests/unified/test_content_generation_correctness_gates.py`: 9/9 passed
2. `tests/unified/`: 29/29 passed
3. `tests/test_extractor.py tests/test_prompts.py tests/test_pipeline.py tests/test_r03_config_caps.py tests/test_r03_runtime_caps.py tests/test_t06_loop_runtime.py`: 205/205 passed
4. `attempt-service.Tests.csproj`: 80/80 passed
