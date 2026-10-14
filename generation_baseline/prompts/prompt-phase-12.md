# RG12 — Product publish/attempt/history and optional ablations

**Status:** `TARGET_SPEC / NOT_RUN`  
**Depends on:** RG02, RG06  
**Coverage:** Five bounded micro-sprint specifications; all mandatory for this phase gate.

## Research and system objective

Immutable published exercise versions, ACL-safe student attempts, grading and progress; optional isolated ablation.

**Decisive acceptance condition:** Research artifacts cannot publish; all grading pins the published snapshot; ablation is optional.

This is an **autonomous phase execution prompt and target specification**. Source capabilities are reused only when audited; any equivalent implementation must preserve required behavior and backwards compatibility.

## Scope boundaries

**Included capabilities:** C5 Product, research publication isolation, versioned attempts. The phase is limited to its five listed micro-sprints and their compatibility, security and evidence requirements.

**Explicit exclusions:** Publishing research/ablation content; weakening credential, student privacy or grading rules.

## Required independent micro-sprint outcomes

| Canonical spec | Named requirement | Observable deliverable |
|---|---|---|
| [RG12-S01](sprints/prompt-sprint-12-01.md) | Learner product baseline and scope | Read-only map of publish/attempt/grading/history code before modifications |
| [RG12-S02](sprints/prompt-sprint-12-02.md) | Immutable human publication and student DTO | Admin-only publish to versioned snapshot, answer key private and stable audit lineage |
| [RG12-S03](sprints/prompt-sprint-12-03.md) | Version-pinned attempts and grading | Authenticated submission links to published_version_id, server-private marking and feedback release policy |
| [RG12-S04](sprints/prompt-sprint-12-04.md) | Learning history and progress reports | Aggregates by question type/grammar target with tenant/user access control and provenance |
| [RG12-S05](sprints/prompt-sprint-12-05.md) | Product regression and optional isolated ablation | Product E2E/ACL tests mandatory; ablation only if optional source/config available |

The five artifacts are independently inspectable: satisfying one does not imply the others have passed. Execute these as five independently planned, implemented, verified and checkpointed micro-sprints under the native pipeline below.

## Required phase-wide behavior

1. The result meets: **Immutable published exercise versions, ACL-safe student attempts, grading and progress; optional isolated ablation.**.
2. Every sprint's output is internally consistent with the other sprint outputs and with parent normative contracts.
3. The exact source/config/dataset/result evidence supports **Research artifacts cannot publish; all grading pins the published snapshot; ablation is optional.**.
4. Existing strict Reading V2 and authoritative state invariants remain intact where this phase touches them; the independent research evaluator is not contaminated by arm labels/internal PASS.
5. Missing external data or provider/DB dependencies are labeled `NOT_RUN` or `BLOCKED`, never silently inferred from documents.

## Cross-cutting nonregression and safety

- Authorization and data minimization at every trust boundary, including retrieved documents and evaluator views.
- No fake PASS, backfilled evidence, invisible failed requests or silent provider/model fallback.
- Legacy V2 accepted-head hash/closure, checkpoint fencing, idempotence and production Draft nonregression wherever touched.
- Research data, gold references and intermediate verdicts never leaking into student payload or blind solve.
- Every result is attributable to concrete versioned source/config/dataset identities; unknowns stay UNKNOWN/NOT_RUN.

## Phase acceptance and evidence requirements

The phase-level verdict is `PASS` only when each **RG12-S01…S05** has evidence for positive, meaningful negative, applicable edge and regression checks, and the complete phase result meets its decisive acceptance condition. The associated source commit, code owners, policy/rubric/dataset hashes, tests, report paths, blockers and environment type must be attributable. Documentation-level PASS does not substitute for live/DB evidence where the requirement demands it.

**No future phase is authorized solely by this document.** Production canary/rollback, RQ1 and any historical status not directly verified remain separately scoped.

## Autonomous RG12 execution — run this phase end to end

**You are the implementation agent for RG12, not a separate planner or external workflow skill.** The only authorized feature scope is this phase and its five micro-sprints. Read [the built-in agent pipeline](../AGENT_PIPELINE.md), [source of truth](../SOURCE_OF_TRUTH.md) and the linked sprint specs. You may use normal repository/code/testing tools without a slash-command dependency.

**Domain-specific work focus — Learner integration:** Preserve manual admin publish and immutable published version; secure student payload/attempts/grading/history; research/ablation outputs never publish.

**Execution sequence:**

1. **Orient:** inspect repository instructions/Git HEAD/dirty state, prior phase evidence and specific interfaces actually present. Treat handoff facts as reported until verified. Missing prerequisites => record `BLOCKED`, not PASS.
2. **Record a compact phase scope:** concrete owners discovered, five sprint success boundaries, contract/nonregression risks and phase-level test targets. Do not turn this into an unbounded refactor plan.
3. **Execute RG12-S01 through RG12-S05 individually**, reading each linked sprint file in full. Within each sprint: inspect current owner -> derive ≤4 small steps -> implement minimal change -> run its named positive/negative/edge/regression checks -> record evidence/checkpoint -> close PASS or stop BLOCKED/FAILED. Preserve unrelated changes.
4. **Between sprints:** re-check source SHA and prerequisites. Do not start the next sprint if its predecessor has unresolved gate blockers. Avoid inventing tool capabilities; record missing environment resources truthfully.
5. **Phase-wide verification focus:** End-to-end and unauthorized-publish/answer-leakage tests; grading pins exact published version.. Run the tests applicable to *the integrated phase*, not just independent sprint units; check touched strict Reading V2 boundaries and research/security isolation.
6. **Closure:** reconcile five sprint records plus phase-level integration results; generate `generation_baseline/.execution/RG12/PHASE_STATUS.json` and concise redacted gate report, listing actual files, commands, outcomes and next resume point. Mark PASS **only** on proved criteria; otherwise retain explicit status and stop. **Never begin RG13 automatically.**

**Special stopping rule:** Preserve authoritative hashes, immutable accepted heads, lease fencing, version pinning and research publication isolation wherever applicable.

**Required result format:** `phase`, `source_sha`, `sprints (S01..S05)`, `changed_files`, `verified_test_ids`, `actual_commands/results`, `mock_vs_real`, `blocked_items`, `phase_gate`, `evidence_refs`. A recorded PASS without real evidence is invalid.
