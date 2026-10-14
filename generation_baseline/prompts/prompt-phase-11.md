# RG11 — Compute statistics and answer research question RQ2

**Status:** `TARGET_SPEC / NOT_RUN`  
**Depends on:** RG10  
**Coverage:** Five bounded micro-sprint specifications; all mandatory for this phase gate.

## Research and system objective

Paired effect estimates, uncertainty, quality/latency/cost results, human agreement and limitations.

**Decisive acceptance condition:** No cherry-picking, pseudo-replication, or interpreting non-significance as equivalence.

The phase prompt is a **target specification**, not a plan or execution playbook. Existing source capability may be reused if RG01 establishes proof; equivalent implementations are permitted only when normative behavior, verification and backward compatibility are preserved.

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

The five artifacts are independently inspectable: satisfying one does not imply the others have passed. Implementation order and lifecycle management are external to this requirement baseline.

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
