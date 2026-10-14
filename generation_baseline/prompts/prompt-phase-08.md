# RG08 — DEV pilot, safety and fault-injection evidence

**Status:** `TARGET_SPEC / NOT_RUN`  
**Depends on:** RG07  
**Coverage:** Five bounded micro-sprint specifications; all mandatory for this phase gate.

## Research and system objective

Pilot data, crash/replay/ACL/leakage checks, measurement diagnostics and readiness decision.

**Decisive acceptance condition:** Final sealed benchmark is never used to debug or optimize the pipeline.

The phase prompt is a **target specification**, not a plan or execution playbook. Existing source capability may be reused if RG01 establishes proof; equivalent implementations are permitted only when normative behavior, verification and backward compatibility are preserved.

## Scope boundaries

**Included capabilities:** C4 Experiment, C2 Execution, security and leakage policies. The phase is limited to its five listed micro-sprints and their compatibility, security and evidence requirements.

**Explicit exclusions:** Unrelated service refactors, spontaneous provider replacement, old-handoff cleanup, automatic student publication, unapproved live deployment or changes to the other research question.

## Required independent micro-sprint outcomes

| Canonical spec | Named requirement | Observable deliverable |
|---|---|---|
| [RG08-S01](sprints/prompt-sprint-08-01.md) | Small DEV paired pilot | Both task domains and A/B/C run on nonfinal inputs with representative constraints |
| [RG08-S02](sprints/prompt-sprint-08-02.md) | Crash/resume/idempotency fault scenarios | Worker crashes, lease loss, lost ACK, DB rollback and retry exercised with evidence |
| [RG08-S03](sprints/prompt-sprint-08-03.md) | Auth, evidence-view and publication negative cases | Attempt data leakage via nested fields; bypass role/tenant and publish research artifacts |
| [RG08-S04](sprints/prompt-sprint-08-04.md) | Evaluator robustness and resource drift | Check evaluator reproducibility, output-order bias, model usage/cost uncertainty and scoring drift |
| [RG08-S05](sprints/prompt-sprint-08-05.md) | Pilot exit decision and freeze prerequisites | Risk register, failed pilot cases, performance bottlenecks and exact final readiness criteria |

The five artifacts are independently inspectable: satisfying one does not imply the others have passed. Implementation order and lifecycle management are external to this requirement baseline.

## Required phase-wide behavior

1. The result meets: **Pilot data, crash/replay/ACL/leakage checks, measurement diagnostics and readiness decision.**.
2. Every sprint's output is internally consistent with the other sprint outputs and with parent normative contracts.
3. The exact source/config/dataset/result evidence supports **Final sealed benchmark is never used to debug or optimize the pipeline.**.
4. Existing strict Reading V2 and authoritative state invariants remain intact where this phase touches them; the independent research evaluator is not contaminated by arm labels/internal PASS.
5. Missing external data or provider/DB dependencies are labeled `NOT_RUN` or `BLOCKED`, never silently inferred from documents.

## Cross-cutting nonregression and safety

- Authorization and data minimization at every trust boundary, including retrieved documents and evaluator views.
- No fake PASS, backfilled evidence, invisible failed requests or silent provider/model fallback.
- Legacy V2 accepted-head hash/closure, checkpoint fencing, idempotence and production Draft nonregression wherever touched.
- Research data, gold references and intermediate verdicts never leaking into student payload or blind solve.
- Every result is attributable to concrete versioned source/config/dataset identities; unknowns stay UNKNOWN/NOT_RUN.

## Phase acceptance and evidence requirements

The phase-level verdict is `PASS` only when each **RG08-S01…S05** has evidence for positive, meaningful negative, applicable edge and regression checks, and the complete phase result meets its decisive acceptance condition. The associated source commit, code owners, policy/rubric/dataset hashes, tests, report paths, blockers and environment type must be attributable. Documentation-level PASS does not substitute for live/DB evidence where the requirement demands it.

**No future phase is authorized solely by this document.** Production canary/rollback, RQ1 and any historical status not directly verified remain separately scoped.
