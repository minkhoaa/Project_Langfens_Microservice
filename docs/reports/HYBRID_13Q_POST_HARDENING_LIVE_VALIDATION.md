# Hybrid 13-Question Post-Hardening Validation

## Implementation identity

- Repository branch: `autonomous-generation`
- Starting implementation: `5455d69d98e4e3a9d90f12e7897290aa95e039f5`
- Verified implementation commit: `aeda8c2a379389d0c75d26e8e5c8ab6b77d57d7b`
- Scope: exact Blueprint-bound provenance, mandatory authoritative EvidenceGraph validation, factual discriminator checks, and accessible text stimulus requirements. `generation_baseline/` was not changed.

## Offline verification

The requested offline regression selection was run from the repository root with the service virtualenv and `PYTHONPATH=services/generation-service`:

```text
pytest -q \
  services/generation-service/tests/test_question_claim_provenance_and_stimulus_gate.py \
  services/generation-service/tests/test_tfng_semantic_contract_and_m3_repair.py \
  services/generation-service/tests/test_question_answer_grounding_and_rerun.py \
  services/generation-service/tests/test_blind_solvers_19types.py \
  services/generation-service/tests/test_question_candidates_19types.py \
  services/generation-service/tests/test_passage_blueprint_grounding_gate.py \
  services/generation-service/tests/test_question_prompt_parser_contract.py \
  services/generation-service/tests/test_t10_blind_solvers.py \
  services/generation-service/tests/test_autonomous_blueprint_recovery.py \
  services/generation-service/tests/test_e2e_autonomous_harness_smoke.py
```

Result: **230 passed** (the original 225-selection plus five added provenance/stimulus regression cases).

Additional production-path and compatibility selection:

```text
pytest -q \
  services/generation-service/tests/test_question_claim_provenance_and_stimulus_gate.py \
  services/generation-service/tests/test_tfng_semantic_contract_and_m3_repair.py \
  services/generation-service/tests/test_question_answer_grounding_and_rerun.py \
  services/generation-service/tests/test_blind_solvers_19types.py \
  services/generation-service/tests/test_question_candidates_19types.py \
  services/generation-service/tests/test_passage_blueprint_grounding_gate.py \
  services/generation-service/tests/test_question_prompt_parser_contract.py \
  services/generation-service/tests/test_t10_blind_solvers.py \
  services/generation-service/tests/test_autonomous_blueprint_recovery.py \
  services/generation-service/tests/test_e2e_autonomous_harness_smoke.py \
  services/generation-service/tests/test_hybrid_production_integration.py
```

Result: **245 passed**. This covers autonomous/dynamic Blueprint recovery, Hybrid repair, production-shaped `SectionRunner → StageExecutor → BoundedLoopRuntime` integration, mandatory evaluator reruns, bounded retries/checkpoint replay, the 19-family blind-solver suite, and Hybrid/M3 routing regressions.

New regression evidence:

- Q2/Q4/Q5 historical wrong-claim assignments are rejected; valid paraphrased evidence and NOT_GIVEN absence semantics remain accepted.
- Blueprint-bound evaluation now fails with `CLAIM_PROVENANCE_MISMATCH` when the authoritative EvidenceGraph is absent, including mock-provider execution. Candidate provenance checks no longer skip the mock path.
- Evidence with overlapping vocabulary but differing numeric facts, qualifiers, or entities is rejected when associated with the competing claim.
- Q10 `hosted districts` remains rejected as a non-contiguous answer span before independent provider evaluation.
- DIAGRAM_LABEL/MAP_LABEL accept accessible textual descriptions, but opaque SVG IDs, SVG markup, and image URLs alone do not count as evidence accessible to the blind solver.

Supplementary checks found existing failures outside the listed acceptance selection. `test_unified_pipeline_execution.py::test_question_item_repair_and_stagnation_ladder` supplies a QUESTION artifact with no required passage/Blueprint parent references and terminates on the strict parent-reference fence. Two tests in `test_r03_runtime_caps.py` also fail (`test_r03_configured_token_cap_bounds_admission` returns `MAX_VERSIONS` rather than `TOKEN_CAP`; `test_r03_call_cap_admission_uses_run_profile` returns `ACCEPTED` rather than `CALL_CAP`). These code paths were not modified. They were not silently repaired as part of this scoped hardening; runtime-cap readiness remains an observed concern.

## LIVE attempt and infrastructure preflight

**No LIVE generation was started.** There is no job ID or run ID, no passage word count, no accepted-question count, no live evaluator results, no provider operations, no checkpoint lineage, no wall time, and no live cost. These are **NOT RUN / UNKNOWN**, not zero.

Preflight did not establish the conditions required for safe single-run execution:

- No MiniMax credential variable was present in the inspected process environment (credential values were not read).
- `pg_isready` was unavailable, so PostgreSQL checkpoint connectivity was not verified.
- Process inspection showed two `uvicorn ... --reload` process entries; one authoritative active worker could not be established.
- The authoritative lease/fencing state was not verified against the runtime service.

Because the user requires all of these prerequisites before LIVE inference, launching a provider-backed job would violate the live-run gate. No retry, resume, or second job was attempted. MiniMax-Text-01/MiniMax-M3 live calls: **0 / NOT RUN**. Usage telemetry and token counts: **UNKNOWN / NOT RUN**. M3 planning calls/actions/recovery outcomes: **NOT EXERCISED**.

## Verdicts

- `OFFLINE_HARDENING: PASS` — requested offline acceptance selection and additional production-path selection passed; supplementary pre-existing runtime-cap test failures are disclosed above.
- `QUESTION_PROVENANCE: PASS` — exact slot binding and authoritative graph requirements are enforced and covered offline.
- `STIMULUS_INTEGRITY: PASS` — opaque visual references alone are rejected; accessible text is required.
- `HYBRID_SINGLE_SECTION_LIVE: BLOCKED` — runtime credentials, PostgreSQL connectivity, worker singularity, and authoritative lease fencing were not established; no LIVE inference occurred.
- `M3_LIVE_REPAIR: NOT_EXERCISED` — no LIVE run was started.

This report SHA-256 is reported separately because embedding a file's own content hash in that same file would make the hash self-referential.
