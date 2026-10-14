# RG03-S05 — Independence and robustness suite

**Status:** `TARGET_SPEC / NOT_RUN`  
**Parent:** [RG03](../prompt-phase-03.md)  
**Normative references:** [Source of truth](../../SOURCE_OF_TRUTH.md) · [Contract registry](../../contracts/CONTRACT_REGISTRY.md) · [Gate policy](../../verification/EVIDENCE_AND_GATE_POLICY.md)

## Objective and bounded scope

Stability tests for config renaming, item ordering, schema drift and source context boundaries.

**In scope:** Only the narrowly described capability/deliverable for this sprint. Related modules may be inspected for compatibility, but unrelated components are not within the requested feature change.

**Out of scope:** Other sprints and phases; production deployment/publish, unrelated refactor, historical G00–G15 cleanup; weakening of auth, hashing, lease/epoch, research separation or the frozen RQ2 protocol. When changes affect existing production logic, strict V2 nonregression remains mandatory.

## Preconditions and input contract

- Parent dependencies: **RG02**; within-phase predecessor: **RG03-S04**.
- Relevant contract boundaries: **C3 Evaluation, Rubric R1, Solver/answer/gold partitions**.
- Observed module owners/paths are sourced from RG01 source audit; this target specification intentionally does not invent method names, routes or existing database columns.
- Source version, provider/model/config, output artifact refs and applicable permissions must be recorded when this sprint touches runtime or persisted data.

## Required observable behavior

1. **Principal functional requirement:** Stability tests for config renaming, item ordering, schema drift and source context boundaries.
2. **Success semantics:** Perturbations expose judge bias and leave audit trail.
3. **Failure semantics:** Judge does not peek at internal trace or unfrozen gold labels.
4. **State and data semantics:** The parent phase and all cross-cutting invariants remain applicable; this sprint supplies one independently testable slice only.
5. **Compatibility requirement:** Relevant existing V2 contracts and client/worker callers must retain their behavior; explicit versioned adapters are required for any observable shape change.
6. **Trust and provenance:** Resulting evidence must be tied to the actual content/source/config identities and must not disclose private answers, expert gold, secrets or another user's information.

## Verification requirements

| Case | Required proof |
|---|---|
| `POS-RG03-S05` | Perturbations expose judge bias and leave audit trail. Evidence identifies input fixture/source and observed output. |
| `NEG-RG03-S05` | Judge does not peek at internal trace or unfrozen gold labels. Verify safe rejection/abstention/blocked outcome rather than ignored or synthetic PASS. |
| `EDGE-RG03-S05` | Test missing, stale, malformed, partial, duplicate or interrupted inputs relevant to this deliverable; assert explicit error/status and no silent data loss. |
| `REG-RG03-S05` | Touched API/schema/authorization or strict Reading V2 regression (when applicable); no new unauthorized publish or accepted-head mutation. |

## Acceptance and required evidence

The sprint is acceptable only if the deliverable is inspectable in the actual owner layer, expected behavior is demonstrated, meaningful negative/edge behavior is proved, applicable regressions pass and all required environment-dependent checks have executed. Necessary evidence fields: source SHA, relevant request/operation IDs, schema/policy/dataset hashes, exercised test IDs/commands, observed outcomes, safe artifact references and known limitations.

For live or DB-dependent behaviors, mock-only evidence is insufficient to close the real-environment gate; a blocked external prerequisite remains explicit. For documentation-only requirements, inspectable files and offline validation are appropriate evidence.

**Acceptance fails or remains BLOCKED** on missing evidence, wrong scope, stale acceptance hashes, leaked answers/gold, silently omitted failed assignments or changed immutable datasets.
