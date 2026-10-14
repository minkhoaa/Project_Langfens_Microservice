# RG01-S04 — Retrieval, grammar and learner inventory

**Status:** `TARGET_SPEC / NOT_RUN`  
**Parent:** [RG01](../prompt-phase-01.md)  
**Normative references:** [Source of truth](../../SOURCE_OF_TRUTH.md) · [Contract registry](../../contracts/CONTRACT_REGISTRY.md) · [Gate policy](../../verification/EVIDENCE_AND_GATE_POLICY.md)

## Objective and bounded scope

Map current vector/RAG, grammar content, grading, publish, attempts and learning history.

**In scope:** Read-only source/code/config/test inspection and traceability evidence. No source edits, cleanup, commits or runtime mutations.

**Out of scope:** Other sprints and phases; production deployment/publish, unrelated refactor, historical G00–G15 cleanup; weakening of auth, hashing, lease/epoch, research separation or the frozen RQ2 protocol. When changes affect existing production logic, strict V2 nonregression remains mandatory.

## Preconditions and input contract

- Parent dependencies: **RG00**; within-phase predecessor: **RG01-S03**.
- Relevant contract boundaries: **source-to-contract map, actual route and storage owners, test and configuration inventory**.
- Observed module owners/paths are sourced from RG01 source audit; this target specification intentionally does not invent method names, routes or existing database columns.
- Source version, provider/model/config, output artifact refs and applicable permissions must be recorded when this sprint touches runtime or persisted data.

## Required observable behavior

1. **Principal functional requirement:** Map current vector/RAG, grammar content, grading, publish, attempts and learning history.
2. **Success semantics:** Per-feature status is VERIFIED/PARTIAL/MISSING/UNKNOWN with evidence.
3. **Failure semantics:** Unknown service/table is not labeled missing after a superficial search.
4. **State and data semantics:** The parent phase and all cross-cutting invariants remain applicable; this sprint supplies one independently testable slice only.
5. **Compatibility requirement:** Relevant existing V2 contracts and client/worker callers must retain their behavior; explicit versioned adapters are required for any observable shape change.
6. **Trust and provenance:** Resulting evidence must be tied to the actual content/source/config identities and must not disclose private answers, expert gold, secrets or another user's information.

## Verification requirements

| Case | Required proof |
|---|---|
| `POS-RG01-S04` | Per-feature status is VERIFIED/PARTIAL/MISSING/UNKNOWN with evidence. Evidence identifies input fixture/source and observed output. |
| `NEG-RG01-S04` | Unknown service/table is not labeled missing after a superficial search. Verify safe rejection/abstention/blocked outcome rather than ignored or synthetic PASS. |
| `EDGE-RG01-S04` | Test missing, stale, malformed, partial, duplicate or interrupted inputs relevant to this deliverable; assert explicit error/status and no silent data loss. |
| `REG-RG01-S04` | Touched API/schema/authorization or strict Reading V2 regression (when applicable); no new unauthorized publish or accepted-head mutation. |

## Acceptance and required evidence

The sprint is acceptable only if the deliverable is inspectable in the actual owner layer, expected behavior is demonstrated, meaningful negative/edge behavior is proved, applicable regressions pass and all required environment-dependent checks have executed. Necessary evidence fields: source SHA, relevant request/operation IDs, schema/policy/dataset hashes, exercised test IDs/commands, observed outcomes, safe artifact references and known limitations.

For live or DB-dependent behaviors, mock-only evidence is insufficient to close the real-environment gate; a blocked external prerequisite remains explicit. For documentation-only requirements, inspectable files and offline validation are appropriate evidence.

**Acceptance fails or remains BLOCKED** on missing evidence, wrong scope, stale acceptance hashes, leaked answers/gold, silently omitted failed assignments or changed immutable datasets.
