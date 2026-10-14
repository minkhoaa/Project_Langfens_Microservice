# RG07-S04 — Configuration C production-derived research runner

**Status:** `TARGET_SPEC / NOT_RUN`  
**Parent:** [RG07](../prompt-phase-07.md)  
**Normative references:** [Source of truth](../../SOURCE_OF_TRUTH.md) · [Contract registry](../../contracts/CONTRACT_REGISTRY.md) · [Gate policy](../../verification/EVIDENCE_AND_GATE_POLICY.md)

## Objective and bounded scope

Reuse C multi-agent capabilities with canonical output adapter and independent scoring.

**In scope:** Only the narrowly described capability/deliverable for this sprint. Related modules may be inspected for compatibility, but unrelated components are not within the requested feature change.

**Out of scope:** Other sprints and phases; production deployment/publish, unrelated refactor, historical G00–G15 cleanup; weakening of auth, hashing, lease/epoch, research separation or the frozen RQ2 protocol. When changes affect existing production logic, strict V2 nonregression remains mandatory.

## Preconditions and input contract

- Parent dependencies: **RG04, RG05, RG06**; within-phase predecessor: **RG07-S03**.
- Relevant contract boundaries: **C1 Generation, C2 Execution, C4 Experiment, A/B/C scoring**.
- Observed module owners/paths are sourced from RG01 source audit; this target specification intentionally does not invent method names, routes or existing database columns.
- Source version, provider/model/config, output artifact refs and applicable permissions must be recorded when this sprint touches runtime or persisted data.

## Required observable behavior

1. **Principal functional requirement:** Reuse C multi-agent capabilities with canonical output adapter and independent scoring.
2. **Success semantics:** Blind solver/reviewer/validator recorded without inflating scoring privilege.
3. **Failure semantics:** No C-only accepted-head predicate used as A/B/C quality metric.
4. **State and data semantics:** The parent phase and all cross-cutting invariants remain applicable; this sprint supplies one independently testable slice only.
5. **Compatibility requirement:** Relevant existing V2 contracts and client/worker callers must retain their behavior; explicit versioned adapters are required for any observable shape change.
6. **Trust and provenance:** Resulting evidence must be tied to the actual content/source/config identities and must not disclose private answers, expert gold, secrets or another user's information.

## Verification requirements

| Case | Required proof |
|---|---|
| `POS-RG07-S04` | Blind solver/reviewer/validator recorded without inflating scoring privilege. Evidence identifies input fixture/source and observed output. |
| `NEG-RG07-S04` | No C-only accepted-head predicate used as A/B/C quality metric. Verify safe rejection/abstention/blocked outcome rather than ignored or synthetic PASS. |
| `EDGE-RG07-S04` | Test missing, stale, malformed, partial, duplicate or interrupted inputs relevant to this deliverable; assert explicit error/status and no silent data loss. |
| `REG-RG07-S04` | Touched API/schema/authorization or strict Reading V2 regression (when applicable); no new unauthorized publish or accepted-head mutation. |

## Acceptance and required evidence

The sprint is acceptable only if the deliverable is inspectable in the actual owner layer, expected behavior is demonstrated, meaningful negative/edge behavior is proved, applicable regressions pass and all required environment-dependent checks have executed. Necessary evidence fields: source SHA, relevant request/operation IDs, schema/policy/dataset hashes, exercised test IDs/commands, observed outcomes, safe artifact references and known limitations.

For live or DB-dependent behaviors, mock-only evidence is insufficient to close the real-environment gate; a blocked external prerequisite remains explicit. For documentation-only requirements, inspectable files and offline validation are appropriate evidence.

**Acceptance fails or remains BLOCKED** on missing evidence, wrong scope, stale acceptance hashes, leaked answers/gold, silently omitted failed assignments or changed immutable datasets.
