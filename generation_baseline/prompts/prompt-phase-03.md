# RG03 — Independent evaluation engine and multi-tier rubric

**Status:** `TARGET_SPEC / NOT_RUN`  
**Depends on:** RG02  
**Coverage:** Five bounded micro-sprint specifications; all mandatory for this phase gate.

## Research and system objective

A neutral post-generation evaluator with reproducible rubric, sealed solver/answer views and typed results.

**Decisive acceptance condition:** Internal generation PASS or configuration labels cannot contaminate research verdict.

The phase prompt is a **target specification**, not a plan or execution playbook. Existing source capability may be reused if RG01 establishes proof; equivalent implementations are permitted only when normative behavior, verification and backward compatibility are preserved.

## Scope boundaries

**Included capabilities:** C3 Evaluation, Rubric R1, Solver/answer/gold partitions. The phase is limited to its five listed micro-sprints and their compatibility, security and evidence requirements.

**Explicit exclusions:** Unrelated service refactors, spontaneous provider replacement, old-handoff cleanup, automatic student publication, unapproved live deployment or changes to the other research question.

## Required independent micro-sprint outcomes

| Canonical spec | Named requirement | Observable deliverable |
|---|---|---|
| [RG03-S01](sprints/prompt-sprint-03-01.md) | Versioned evaluation rubric | Three tiers: deterministic, QGEval-inspired dimensions and Reading/Grammar task-specific validity |
| [RG03-S02](sprints/prompt-sprint-03-02.md) | Neutral post-generation evaluator | Judge accepts canonical neutral output and source without knowing A/B/C internal verdicts |
| [RG03-S03](sprints/prompt-sprint-03-03.md) | Blind solve and answer verification | Separate answer-free solve, recorded solver result, then compare proposal against evidence; gold held apart |
| [RG03-S04](sprints/prompt-sprint-03-04.md) | Partial and uncertain evaluation results | Typed evaluability state, verdict PASS/FAIL/UNCERTAIN and reason/evidence; failed runs are classifiable |
| [RG03-S05](sprints/prompt-sprint-03-05.md) | Independence and robustness suite | Stability tests for config renaming, item ordering, schema drift and source context boundaries |

The five artifacts are independently inspectable: satisfying one does not imply the others have passed. Implementation order and lifecycle management are external to this requirement baseline.

## Required phase-wide behavior

1. The result meets: **A neutral post-generation evaluator with reproducible rubric, sealed solver/answer views and typed results.**.
2. Every sprint's output is internally consistent with the other sprint outputs and with parent normative contracts.
3. The exact source/config/dataset/result evidence supports **Internal generation PASS or configuration labels cannot contaminate research verdict.**.
4. Existing strict Reading V2 and authoritative state invariants remain intact where this phase touches them; the independent research evaluator is not contaminated by arm labels/internal PASS.
5. Missing external data or provider/DB dependencies are labeled `NOT_RUN` or `BLOCKED`, never silently inferred from documents.

## Cross-cutting nonregression and safety

- Authorization and data minimization at every trust boundary, including retrieved documents and evaluator views.
- No fake PASS, backfilled evidence, invisible failed requests or silent provider/model fallback.
- Legacy V2 accepted-head hash/closure, checkpoint fencing, idempotence and production Draft nonregression wherever touched.
- Research data, gold references and intermediate verdicts never leaking into student payload or blind solve.
- Every result is attributable to concrete versioned source/config/dataset identities; unknowns stay UNKNOWN/NOT_RUN.

## Phase acceptance and evidence requirements

The phase-level verdict is `PASS` only when each **RG03-S01…S05** has evidence for positive, meaningful negative, applicable edge and regression checks, and the complete phase result meets its decisive acceptance condition. The associated source commit, code owners, policy/rubric/dataset hashes, tests, report paths, blockers and environment type must be attributable. Documentation-level PASS does not substitute for live/DB evidence where the requirement demands it.

**No future phase is authorized solely by this document.** Production canary/rollback, RQ1 and any historical status not directly verified remain separately scoped.
