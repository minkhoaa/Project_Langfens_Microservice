# RG11 — Compute statistics and answer research question RQ2

**Status:** `TARGET_SPEC / NOT_RUN`  
**Depends on:** RG10  
**Coverage:** Five bounded micro-sprint specifications; all mandatory for this phase gate.

## Research and system objective

Paired effect estimates, uncertainty, quality/latency/cost results, human agreement and limitations.

**Decisive acceptance condition:** No cherry-picking, pseudo-replication, or interpreting non-significance as equivalence.

This is an **autonomous phase execution prompt and target specification**. Source capabilities are reused only when audited; any equivalent implementation must preserve required behavior and backwards compatibility.

## Scope boundaries

**Included capabilities:** C4 Experiment, analysis protocol, RQ2 evidence. The phase is limited to its five listed micro-sprints and their compatibility, security and evidence requirements.

**Explicit exclusions:** Editing sealed primary data, adding favorable post hoc primary outcomes or treating question count as independent N.

## Required independent micro-sprint outcomes

| Canonical spec | Named requirement | Observable deliverable |
|---|---|---|
| [RG11-S01](sprints/prompt-sprint-11-01.md) | Primary/secondary metric computation | E2E pass on assigned requests, conditional quality on evaluable outputs, error by type and completion rates |
| [RG11-S02](sprints/prompt-sprint-11-02.md) | Paired inference and uncertainty | Paired contrasts with CIs/intervals and item-cluster resampling, sample sensitivity |
| [RG11-S03](sprints/prompt-sprint-11-03.md) | Quality-latency-cost tradeoff | Calls, repairs, tokens, cost usage confidence, median/P95 latency and cost per valid item compared |
| [RG11-S04](sprints/prompt-sprint-11-04.md) | Error taxonomy, interpretation and optional ablation design | Representative errors, reviewer disagreement, confounders, limitations and optional ablation hypotheses |
| [RG11-S05](sprints/prompt-sprint-11-05.md) | RQ2 thesis-ready report and reproducibility | Methods, flow diagram, tables, uncertainty, effect sizes, costs, limitation and reproduction instructions |

The five artifacts are independently inspectable: satisfying one does not imply the others have passed. Execute these as five independently planned, implemented, verified and checkpointed micro-sprints under the native pipeline below.

## Required phase-wide behavior

1. The result meets: **Paired effect estimates, uncertainty, quality/latency/cost results, human agreement and limitations.**.
2. Every sprint's output is internally consistent with the other sprint outputs and with parent normative contracts.
3. The exact source/config/dataset/result evidence supports **No cherry-picking, pseudo-replication, or interpreting non-significance as equivalence.**.
4. Existing strict Reading V2 and authoritative state invariants remain intact where this phase touches them; the independent research evaluator is not contaminated by arm labels/internal PASS.
5. Missing external data or provider/DB dependencies are labeled `NOT_RUN` or `BLOCKED`, never silently inferred from documents.

## Cross-cutting nonregression and safety

- Authorization and data minimization at every trust boundary, including retrieved documents and evaluator views.
- No fake PASS, backfilled evidence, invisible failed requests or silent provider/model fallback.
- Legacy V2 accepted-head hash/closure, checkpoint fencing, idempotence and production Draft nonregression wherever touched.
- Research data, gold references and intermediate verdicts never leaking into student payload or blind solve.
- Every result is attributable to concrete versioned source/config/dataset identities; unknowns stay UNKNOWN/NOT_RUN.

## Phase acceptance and evidence requirements

The phase-level verdict is `PASS` only when each **RG11-S01…S05** has evidence for positive, meaningful negative, applicable edge and regression checks, and the complete phase result meets its decisive acceptance condition. The associated source commit, code owners, policy/rubric/dataset hashes, tests, report paths, blockers and environment type must be attributable. Documentation-level PASS does not substitute for live/DB evidence where the requirement demands it.

**No future phase is authorized solely by this document.** Production canary/rollback, RQ1 and any historical status not directly verified remain separately scoped.

## Autonomous RG11 execution — run this phase end to end

**You are the implementation agent for RG11, not a separate planner or external workflow skill.** The only authorized feature scope is this phase and its five micro-sprints. Read [the built-in agent pipeline](../AGENT_PIPELINE.md), [source of truth](../SOURCE_OF_TRUTH.md) and the linked sprint specs. You may use normal repository/code/testing tools without a slash-command dependency.

**Domain-specific work focus — RQ2 analysis:** Use paired task-level inference, request-level denominator, confidence intervals, missing-usage policies and transparent negative/null findings.

**Execution sequence:**

1. **Orient:** inspect repository instructions/Git HEAD/dirty state, prior phase evidence and specific interfaces actually present. Treat handoff facts as reported until verified. Missing prerequisites => record `BLOCKED`, not PASS.
2. **Record a compact phase scope:** concrete owners discovered, five sprint success boundaries, contract/nonregression risks and phase-level test targets. Do not turn this into an unbounded refactor plan.
3. **Execute RG11-S01 through RG11-S05 individually**, reading each linked sprint file in full. Within each sprint: inspect current owner -> derive ≤4 small steps -> implement minimal change -> run its named positive/negative/edge/regression checks -> record evidence/checkpoint -> close PASS or stop BLOCKED/FAILED. Preserve unrelated changes.
4. **Between sprints:** re-check source SHA and prerequisites. Do not start the next sprint if its predecessor has unresolved gate blockers. Avoid inventing tool capabilities; record missing environment resources truthfully.
5. **Phase-wide verification focus:** Independently recompute tables from sealed data; test grouping and avoid pseudo-replication by question.. Run the tests applicable to *the integrated phase*, not just independent sprint units; check touched strict Reading V2 boundaries and research/security isolation.
6. **Closure:** reconcile five sprint records plus phase-level integration results; generate `generation_baseline/.execution/RG11/PHASE_STATUS.json` and concise redacted gate report, listing actual files, commands, outcomes and next resume point. Mark PASS **only** on proved criteria; otherwise retain explicit status and stop. **Never begin RG12 automatically.**

**Special stopping rule:** Never rewrite any frozen dataset, model/prompt manifest or human gold to make failed assignments PASS; paid/final live execution requires separately confirmed authorization.

**Required result format:** `phase`, `source_sha`, `sprints (S01..S05)`, `changed_files`, `verified_test_ids`, `actual_commands/results`, `mock_vs_real`, `blocked_items`, `phase_gate`, `evidence_refs`. A recorded PASS without real evidence is invalid.
