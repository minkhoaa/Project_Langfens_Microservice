# RG07 — Paired configuration A/B/C runners

**Status:** `TARGET_SPEC / NOT_RUN`  
**Depends on:** RG04, RG05, RG06  
**Coverage:** Five bounded micro-sprint specifications; all mandatory for this phase gate.

## Research and system objective

Common neutral input/output and independent evaluator for A direct, B sequential self-review, C multi-agent.

**Decisive acceptance condition:** Every assigned attempt including failures and partial results is reconciled.

This is an **autonomous phase execution prompt and target specification**. Source capabilities are reused only when audited; any equivalent implementation must preserve required behavior and backwards compatibility.

## Scope boundaries

**Included capabilities:** C1 Generation, C2 Execution, C4 Experiment, A/B/C scoring. The phase is limited to its five listed micro-sprints and their compatibility, security and evidence requirements.

**Explicit exclusions:** Unrelated service refactors, spontaneous provider replacement, old-handoff cleanup, automatic student publication, unapproved live deployment or changes to the other research question.

## Required independent micro-sprint outcomes

| Canonical spec | Named requirement | Observable deliverable |
|---|---|---|
| [RG07-S01](sprints/prompt-sprint-07-01.md) | Paired assignments and common task fixture | One experiment item mapped to A/B/C with immutable prompt/model/source pins and stable IDs |
| [RG07-S02](sprints/prompt-sprint-07-02.md) | Configuration A direct generator | Direct LLM generation, exactly declared generation path, canonical output/failure accounting |
| [RG07-S03](sprints/prompt-sprint-07-03.md) | Configuration B sequential self-review | Same foundation LLM does generation, self-feedback and bounded revision on distinct trace |
| [RG07-S04](sprints/prompt-sprint-07-04.md) | Configuration C production-derived research runner | Reuse C multi-agent capabilities with canonical output adapter and independent scoring |
| [RG07-S05](sprints/prompt-sprint-07-05.md) | Failure, usage, denominators and replay ledger | All assignments and attempts including timeout/partial/cancel/failure mapped with usage confidence |

The five artifacts are independently inspectable: satisfying one does not imply the others have passed. Execute these as five independently planned, implemented, verified and checkpointed micro-sprints under the native pipeline below.

## Required phase-wide behavior

1. The result meets: **Common neutral input/output and independent evaluator for A direct, B sequential self-review, C multi-agent.**.
2. Every sprint's output is internally consistent with the other sprint outputs and with parent normative contracts.
3. The exact source/config/dataset/result evidence supports **Every assigned attempt including failures and partial results is reconciled.**.
4. Existing strict Reading V2 and authoritative state invariants remain intact where this phase touches them; the independent research evaluator is not contaminated by arm labels/internal PASS.
5. Missing external data or provider/DB dependencies are labeled `NOT_RUN` or `BLOCKED`, never silently inferred from documents.

## Cross-cutting nonregression and safety

- Authorization and data minimization at every trust boundary, including retrieved documents and evaluator views.
- No fake PASS, backfilled evidence, invisible failed requests or silent provider/model fallback.
- Legacy V2 accepted-head hash/closure, checkpoint fencing, idempotence and production Draft nonregression wherever touched.
- Research data, gold references and intermediate verdicts never leaking into student payload or blind solve.
- Every result is attributable to concrete versioned source/config/dataset identities; unknowns stay UNKNOWN/NOT_RUN.

## Phase acceptance and evidence requirements

The phase-level verdict is `PASS` only when each **RG07-S01…S05** has evidence for positive, meaningful negative, applicable edge and regression checks, and the complete phase result meets its decisive acceptance condition. The associated source commit, code owners, policy/rubric/dataset hashes, tests, report paths, blockers and environment type must be attributable. Documentation-level PASS does not substitute for live/DB evidence where the requirement demands it.

**No future phase is authorized solely by this document.** Production canary/rollback, RQ1 and any historical status not directly verified remain separately scoped.

## Autonomous RG07 execution — run this phase end to end

**You are the implementation agent for RG07, not a separate planner or external workflow skill.** The only authorized feature scope is this phase and its five micro-sprints. Read [the built-in agent pipeline](../AGENT_PIPELINE.md), [source of truth](../SOURCE_OF_TRUTH.md) and the linked sprint specs. You may use normal repository/code/testing tools without a slash-command dependency.

**Domain-specific work focus — A/B/C experiment runners:** Use paired frozen task specifications, common foundation model and output adapter; A direct, B sequential self-review, C full multi-agent; neutral evaluator downstream.

**Execution sequence:**

1. **Orient:** inspect repository instructions/Git HEAD/dirty state, prior phase evidence and specific interfaces actually present. Treat handoff facts as reported until verified. Missing prerequisites => record `BLOCKED`, not PASS.
2. **Record a compact phase scope:** concrete owners discovered, five sprint success boundaries, contract/nonregression risks and phase-level test targets. Do not turn this into an unbounded refactor plan.
3. **Execute RG07-S01 through RG07-S05 individually**, reading each linked sprint file in full. Within each sprint: inspect current owner -> derive ≤4 small steps -> implement minimal change -> run its named positive/negative/edge/regression checks -> record evidence/checkpoint -> close PASS or stop BLOCKED/FAILED. Preserve unrelated changes.
4. **Between sprints:** re-check source SHA and prerequisites. Do not start the next sprint if its predecessor has unresolved gate blockers. Avoid inventing tool capabilities; record missing environment resources truthfully.
5. **Phase-wide verification focus:** Reconcile all assignments, raw/partial failures, no hidden dropped outputs, retry and accounting across A/B/C.. Run the tests applicable to *the integrated phase*, not just independent sprint units; check touched strict Reading V2 boundaries and research/security isolation.
6. **Closure:** reconcile five sprint records plus phase-level integration results; generate `generation_baseline/.execution/RG07/PHASE_STATUS.json` and concise redacted gate report, listing actual files, commands, outcomes and next resume point. Mark PASS **only** on proved criteria; otherwise retain explicit status and stop. **Never begin RG08 automatically.**

**Special stopping rule:** Preserve authoritative hashes, immutable accepted heads, lease fencing, version pinning and research publication isolation wherever applicable.

**Required result format:** `phase`, `source_sha`, `sprints (S01..S05)`, `changed_files`, `verified_test_ids`, `actual_commands/results`, `mock_vs_real`, `blocked_items`, `phase_gate`, `evidence_refs`. A recorded PASS without real evidence is invalid.
