# RG02 — Executable contracts, authority and research isolation

**Status:** `TARGET_SPEC / NOT_RUN`  
**Depends on:** RG01  
**Coverage:** Five bounded micro-sprint specifications; all mandatory for this phase gate.

## Research and system objective

Versioned schemas/adapters, restricted data views, secure authoritative state transitions and 4-role telemetry.

**Decisive acceptance condition:** Negative authorization/leakage, stale-hash and compatibility tests prove invariants.

This is an **autonomous phase execution prompt and target specification**. Source capabilities are reused only when audited; any equivalent implementation must preserve required behavior and backwards compatibility.

## Scope boundaries

**Included capabilities:** C1 Generation, C2 Execution, C3 Evaluation views, C4 Experiment, C5 Product authority. The phase is limited to its five listed micro-sprints and their compatibility, security and evidence requirements.

**Explicit exclusions:** Unrelated service refactors, spontaneous provider replacement, old-handoff cleanup, automatic student publication, unapproved live deployment or changes to the other research question.

## Required independent micro-sprint outcomes

| Canonical spec | Named requirement | Observable deliverable |
|---|---|---|
| [RG02-S01](sprints/prompt-sprint-02-01.md) | Schema mapping and version negotiation | Executable Generation/Execution/Evaluation/Experiment DTO adapters and discriminator compatibility |
| [RG02-S02](sprints/prompt-sprint-02-02.md) | Three isolated evidence views | SolverView/AnswerVerificationView/GoldReferenceView with explicit allowlists and ACL checks |
| [RG02-S03](sprints/prompt-sprint-02-03.md) | Authoritative acceptance protocol | Validator verdict and coordinator proposal to .NET atomic accept with hashes, lease/epoch and fresh policy checks |
| [RG02-S04](sprints/prompt-sprint-02-04.md) | Research policy and publish protection | STRICT_PRODUCTION/RESEARCH_STANDARD/RESEARCH_ABLATION guards, isolation and semantic-check policy |
| [RG02-S05](sprints/prompt-sprint-02-05.md) | Agent traces, usage and compatibility | Four agent_role traces with capability_name, usage confidence, idempotent IDs and safe logging |

The five artifacts are independently inspectable: satisfying one does not imply the others have passed. Execute these as five independently planned, implemented, verified and checkpointed micro-sprints under the native pipeline below.

## Required phase-wide behavior

1. The result meets: **Versioned schemas/adapters, restricted data views, secure authoritative state transitions and 4-role telemetry.**.
2. Every sprint's output is internally consistent with the other sprint outputs and with parent normative contracts.
3. The exact source/config/dataset/result evidence supports **Negative authorization/leakage, stale-hash and compatibility tests prove invariants.**.
4. Existing strict Reading V2 and authoritative state invariants remain intact where this phase touches them; the independent research evaluator is not contaminated by arm labels/internal PASS.
5. Missing external data or provider/DB dependencies are labeled `NOT_RUN` or `BLOCKED`, never silently inferred from documents.

## Cross-cutting nonregression and safety

- Authorization and data minimization at every trust boundary, including retrieved documents and evaluator views.
- No fake PASS, backfilled evidence, invisible failed requests or silent provider/model fallback.
- Legacy V2 accepted-head hash/closure, checkpoint fencing, idempotence and production Draft nonregression wherever touched.
- Research data, gold references and intermediate verdicts never leaking into student payload or blind solve.
- Every result is attributable to concrete versioned source/config/dataset identities; unknowns stay UNKNOWN/NOT_RUN.

## Phase acceptance and evidence requirements

The phase-level verdict is `PASS` only when each **RG02-S01…S05** has evidence for positive, meaningful negative, applicable edge and regression checks, and the complete phase result meets its decisive acceptance condition. The associated source commit, code owners, policy/rubric/dataset hashes, tests, report paths, blockers and environment type must be attributable. Documentation-level PASS does not substitute for live/DB evidence where the requirement demands it.

**No future phase is authorized solely by this document.** Production canary/rollback, RQ1 and any historical status not directly verified remain separately scoped.

## Autonomous RG02 execution — run this phase end to end

**You are the implementation agent for RG02, not a separate planner or external workflow skill.** The only authorized feature scope is this phase and its five micro-sprints. Read [the built-in agent pipeline](../AGENT_PIPELINE.md), [source of truth](../SOURCE_OF_TRUTH.md) and the linked sprint specs. You may use normal repository/code/testing tools without a slash-command dependency.

**Domain-specific work focus — Contracts & authorities:** Implement versioned adapters/schemas across Python/.NET boundaries; restrict SolverView, GoldReferenceView and research publication; preserve auth, hash closure and atomic state.

**Execution sequence:**

1. **Orient:** inspect repository instructions/Git HEAD/dirty state, prior phase evidence and specific interfaces actually present. Treat handoff facts as reported until verified. Missing prerequisites => record `BLOCKED`, not PASS.
2. **Record a compact phase scope:** concrete owners discovered, five sprint success boundaries, contract/nonregression risks and phase-level test targets. Do not turn this into an unbounded refactor plan.
3. **Execute RG02-S01 through RG02-S05 individually**, reading each linked sprint file in full. Within each sprint: inspect current owner -> derive ≤4 small steps -> implement minimal change -> run its named positive/negative/edge/regression checks -> record evidence/checkpoint -> close PASS or stop BLOCKED/FAILED. Preserve unrelated changes.
4. **Between sprints:** re-check source SHA and prerequisites. Do not start the next sprint if its predecessor has unresolved gate blockers. Avoid inventing tool capabilities; record missing environment resources truthfully.
5. **Phase-wide verification focus:** Negative tests for forbidden fields/transition, stale hash, replay, leases and strict-v2 compatibility.. Run the tests applicable to *the integrated phase*, not just independent sprint units; check touched strict Reading V2 boundaries and research/security isolation.
6. **Closure:** reconcile five sprint records plus phase-level integration results; generate `generation_baseline/.execution/RG02/PHASE_STATUS.json` and concise redacted gate report, listing actual files, commands, outcomes and next resume point. Mark PASS **only** on proved criteria; otherwise retain explicit status and stop. **Never begin RG03 automatically.**

**Special stopping rule:** Preserve authoritative hashes, immutable accepted heads, lease fencing, version pinning and research publication isolation wherever applicable.

**Required result format:** `phase`, `source_sha`, `sprints (S01..S05)`, `changed_files`, `verified_test_ids`, `actual_commands/results`, `mock_vs_real`, `blocked_items`, `phase_gate`, `evidence_refs`. A recorded PASS without real evidence is invalid.
