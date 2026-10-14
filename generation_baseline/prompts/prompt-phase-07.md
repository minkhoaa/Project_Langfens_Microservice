# RG07 — Paired configuration A/B/C runners

**Status:** `TARGET_SPEC / NOT_RUN`  
**Depends on:** RG04, RG05, RG06  
**Coverage:** Five bounded micro-sprint specifications; all mandatory for this phase gate.

## Research and system objective

Common neutral input/output and independent evaluator for A direct, B sequential self-review, C multi-agent.

**Decisive acceptance condition:** Every assigned attempt including failures and partial results is reconciled.

The phase prompt is a **target specification**, not a plan or execution playbook. Existing source capability may be reused if RG01 establishes proof; equivalent implementations are permitted only when normative behavior, verification and backward compatibility are preserved.

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

The five artifacts are independently inspectable: satisfying one does not imply the others have passed. Implementation order and lifecycle management are external to this requirement baseline.

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
