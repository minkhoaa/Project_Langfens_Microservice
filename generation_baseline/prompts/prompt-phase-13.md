# RG13 — Cross-system acceptance, evidence audit and handoff

**Status:** `TARGET_SPEC / NOT_RUN`  
**Depends on:** RG10, RG11, RG12  
**Coverage:** Five bounded micro-sprint specifications; all mandatory for this phase gate.

## Research and system objective

Checked contracts, regressions, reproducibility, RQ2 deliverables, remaining risks and handoff.

**Decisive acceptance condition:** Rely only on real gate evidence; do not claim RQ1 or operational canary/rollback completed.

The phase prompt is a **target specification**, not a plan or execution playbook. Existing source capability may be reused if RG01 establishes proof; equivalent implementations are permitted only when normative behavior, verification and backward compatibility are preserved.

## Scope boundaries

**Included capabilities:** all C1–C5, RQ2 evidence, historical/operational separation. The phase is limited to its five listed micro-sprints and their compatibility, security and evidence requirements.

**Explicit exclusions:** Deployments, production cutover/canary/rollback, changing original thesis research claims.

## Required independent micro-sprint outcomes

| Canonical spec | Named requirement | Observable deliverable |
|---|---|---|
| [RG13-S01](sprints/prompt-sprint-13-01.md) | Cross-gate versioned evidence audit | 14 RG gates, sprint evidence, accepted hashes, assignment/results and source commits reconciled |
| [RG13-S02](sprints/prompt-sprint-13-02.md) | End-to-end functional/security regression | Reading full paper, research reading, grammar, evaluation, A/B/C and product roles tested |
| [RG13-S03](sprints/prompt-sprint-13-03.md) | Independent reproduction of reported RQ2 metrics | Separate re-run of analysis scripts from sealed dataset and manifests |
| [RG13-S04](sprints/prompt-sprint-13-04.md) | Operational limitations and boundary statement | Canary/rollback/RQ1/third-party quotas separated from accepted RQ2 scope |
| [RG13-S05](sprints/prompt-sprint-13-05.md) | Final traceable release and handoff package | Source/test/report hashes, unresolved risks, README and reproduction pointers consolidated |

The five artifacts are independently inspectable: satisfying one does not imply the others have passed. Implementation order and lifecycle management are external to this requirement baseline.

## Required phase-wide behavior

1. The result meets: **Checked contracts, regressions, reproducibility, RQ2 deliverables, remaining risks and handoff.**.
2. Every sprint's output is internally consistent with the other sprint outputs and with parent normative contracts.
3. The exact source/config/dataset/result evidence supports **Rely only on real gate evidence; do not claim RQ1 or operational canary/rollback completed.**.
4. Existing strict Reading V2 and authoritative state invariants remain intact where this phase touches them; the independent research evaluator is not contaminated by arm labels/internal PASS.
5. Missing external data or provider/DB dependencies are labeled `NOT_RUN` or `BLOCKED`, never silently inferred from documents.

## Cross-cutting nonregression and safety

- Authorization and data minimization at every trust boundary, including retrieved documents and evaluator views.
- No fake PASS, backfilled evidence, invisible failed requests or silent provider/model fallback.
- Legacy V2 accepted-head hash/closure, checkpoint fencing, idempotence and production Draft nonregression wherever touched.
- Research data, gold references and intermediate verdicts never leaking into student payload or blind solve.
- Every result is attributable to concrete versioned source/config/dataset identities; unknowns stay UNKNOWN/NOT_RUN.

## Phase acceptance and evidence requirements

The phase-level verdict is `PASS` only when each **RG13-S01…S05** has evidence for positive, meaningful negative, applicable edge and regression checks, and the complete phase result meets its decisive acceptance condition. The associated source commit, code owners, policy/rubric/dataset hashes, tests, report paths, blockers and environment type must be attributable. Documentation-level PASS does not substitute for live/DB evidence where the requirement demands it.

**No future phase is authorized solely by this document.** Production canary/rollback, RQ1 and any historical status not directly verified remain separately scoped.
