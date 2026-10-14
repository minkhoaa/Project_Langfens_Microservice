# RG06-S01 — Grammar exercise blueprint and rule pack

**Status:** `TARGET_SPEC / NOT_RUN`  
**Parent:** [RG06](../prompt-phase-06.md)  
**Normative references:** [Source of truth](../../SOURCE_OF_TRUTH.md) · [Contract registry](../../contracts/CONTRACT_REGISTRY.md) · [Gate policy](../../verification/EVIDENCE_AND_GATE_POLICY.md)

## Objective and bounded scope

Task schema for level, target rule, gap/mcq/error-correction, contexts, exceptions and provenance.

**In scope:** Only the narrowly described capability/deliverable for this sprint. Related modules may be inspected for compatibility, but unrelated components are not within the requested feature change.

**Out of scope:** Other sprints and phases; production deployment/publish, unrelated refactor, historical G00–G15 cleanup; weakening of auth, hashing, lease/epoch, research separation or the frozen RQ2 protocol. When changes affect existing production logic, strict V2 nonregression remains mandatory.

## Preconditions and input contract

- Parent dependencies: **RG02, RG03, RG04**; within-phase predecessor: **none**.
- Relevant contract boundaries: **C1 Generation, GrammarRulePack, KnowledgeRetrievalPort, C3 Evaluation**.
- Observed module owners/paths are sourced from RG01 source audit; this target specification intentionally does not invent method names, routes or existing database columns.
- Source version, provider/model/config, output artifact refs and applicable permissions must be recorded when this sprint touches runtime or persisted data.

## Required observable behavior

1. **Principal functional requirement:** Task schema for level, target rule, gap/mcq/error-correction, contexts, exceptions and provenance.
2. **Success semantics:** Every generated unit pins rule version, license and difficulty target.
3. **Failure semantics:** No assumption that a retrieved rule validates generated answer.
4. **State and data semantics:** The parent phase and all cross-cutting invariants remain applicable; this sprint supplies one independently testable slice only.
5. **Compatibility requirement:** Relevant existing V2 contracts and client/worker callers must retain their behavior; explicit versioned adapters are required for any observable shape change.
6. **Trust and provenance:** Resulting evidence must be tied to the actual content/source/config identities and must not disclose private answers, expert gold, secrets or another user's information.

## Verification requirements

| Case | Required proof |
|---|---|
| `POS-RG06-S01` | Every generated unit pins rule version, license and difficulty target. Evidence identifies input fixture/source and observed output. |
| `NEG-RG06-S01` | No assumption that a retrieved rule validates generated answer. Verify safe rejection/abstention/blocked outcome rather than ignored or synthetic PASS. |
| `EDGE-RG06-S01` | Test missing, stale, malformed, partial, duplicate or interrupted inputs relevant to this deliverable; assert explicit error/status and no silent data loss. |
| `REG-RG06-S01` | Touched API/schema/authorization or strict Reading V2 regression (when applicable); no new unauthorized publish or accepted-head mutation. |

## Acceptance and required evidence

The sprint is acceptable only if the deliverable is inspectable in the actual owner layer, expected behavior is demonstrated, meaningful negative/edge behavior is proved, applicable regressions pass and all required environment-dependent checks have executed. Necessary evidence fields: source SHA, relevant request/operation IDs, schema/policy/dataset hashes, exercised test IDs/commands, observed outcomes, safe artifact references and known limitations.

For live or DB-dependent behaviors, mock-only evidence is insufficient to close the real-environment gate; a blocked external prerequisite remains explicit. For documentation-only requirements, inspectable files and offline validation are appropriate evidence.

**Acceptance fails or remains BLOCKED** on missing evidence, wrong scope, stale acceptance hashes, leaked answers/gold, silently omitted failed assignments or changed immutable datasets.

## Self-contained native execution pipeline — RG06-S01

**Act as the coding agent for this sprint only.** This file is the exact task boundary; it requires no external planning skill, execution skill, slash command or orchestration framework. [Native protocol](../../AGENT_PIPELINE.md) and [parent gate](../prompt-phase-06.md) remain normative.

**Implementation target:** Grammar exercise blueprint and rule pack — Task schema for level, target rule, gap/mcq/error-correction, contexts, exceptions and provenance.

**Domain strategy:** Grounding-first: trace provenance and answer dependencies; add a typed fixture for invalid/ambiguous content, use smallest compatible generation/validation adapter, then verify acceptance and regression.

1. **Inspect and ground:** examine `AGENTS.md`, source HEAD and dirty work, prior sprint record and relevant contract; resolve the true code owner/route/schema from current source. Stop rather than guess if an external prerequisite is missing.
2. **Local micro-plan:** inside `RG06-S01`'s own status record, list ≤4 concrete work items, named files, input/output behavior, one likely failure mode and focused commands/tests. This is part of execution, not a separate planning workflow or another sprint.
3. **Implement narrow change:** reuse established source components. For executable behavior, capture a failing check for the missing requirement when practical, then implement a minimal fix. For audit/doc-only sprint, create only its owned auditable artifact. No other sprint's implementation, production rollout, legacy cleanup or unapproved provider campaign.
4. **Verify with real outcomes:**
   - Positive `POS-RG06-S01`: Every generated unit pins rule version, license and difficulty target
   - Negative `NEG-RG06-S01`: No assumption that a retrieved rule validates generated answer
   - Edge `EDGE-RG06-S01`: run an applicable malformed/missing/stale/interrupted/duplicate case; explicitly identify any non-applicable case and why.
   - Regression `REG-RG06-S01`: run touched API/DTO/ACL/strict V2 or experiment-isolation checks as applicable.
   - Phase-domain verification emphasis: Rule provenance, contextual gold, ambiguous grammar, multiple-choice distractor uniqueness.
5. **Checkpoint and close:** write `generation_baseline/.execution/RG06/RG06-S01.json` (see [status schema template](../../templates/SPRINT_STATUS_TEMPLATE.json)) with `source_sha`, file diffs, tests & exit results, mock/DB/live distinction, evidence links and blockers. Mark PASS only when expected behavior and mandatory checks are supported. Else BLOCKED/FAILED/PARTIAL and stop with an exact resume point.

**Required response:** concise Vietnamese or repo-preferred language: what changed, why this scoped change, concrete tests and statuses, source SHA, files and unresolved risks. Do not claim a passing phase because this individual sprint passed.
