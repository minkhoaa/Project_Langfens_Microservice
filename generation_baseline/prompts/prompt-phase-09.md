# RG09 — Final dataset and preregistration freeze

**Status:** `TARGET_SPEC / NOT_RUN`  
**Depends on:** RG08  
**Coverage:** Five bounded micro-sprint specifications; all mandatory for this phase gate.

## Research and system objective

25–40 Reading and 25–40 Grammar paired input items; gold isolation and immutable campaign manifest.

**Decisive acceptance condition:** Family-disjoint datasets; evaluator, endpoints, analysis, exclusions and resource policies frozen.

The phase prompt is a **target specification**, not a plan or execution playbook. Existing source capability may be reused if RG01 establishes proof; equivalent implementations are permitted only when normative behavior, verification and backward compatibility are preserved.

## Scope boundaries

**Included capabilities:** C4 Experiment, frozen dataset, statistical pre-registration. The phase is limited to its five listed micro-sprints and their compatibility, security and evidence requirements.

**Explicit exclusions:** Changing the existing judge, generative model, primary endpoint or gold labels in response to final results.

## Required independent micro-sprint outcomes

| Canonical spec | Named requirement | Observable deliverable |
|---|---|---|
| [RG09-S01](sprints/prompt-sprint-09-01.md) | Frozen paired FINAL tasks | 25–40 Reading passage/group and 25–40 Grammar requests with balanced difficulty/type strata |
| [RG09-S02](sprints/prompt-sprint-09-02.md) | Sealed gold and blind review export | Verified grammar rules and item references, secure gold mapping, random reviewer IDs and adjudication policy |
| [RG09-S03](sprints/prompt-sprint-09-03.md) | Primary endpoints and statistical preregistration | End-to-end pass definition, abstention rule, paired contrasts, resampling unit and CIs fixed |
| [RG09-S04](sprints/prompt-sprint-09-04.md) | Freeze providers, prompts, resources and safety | Model revisions if available, sampling params, prompt hashes, budgets/timeouts and fallback policies versioned |
| [RG09-S05](sprints/prompt-sprint-09-05.md) | Final immutable manifest and access separation | Sealed manifest hash, assignment roster, checkable evidence references and reviewer access partitions |

The five artifacts are independently inspectable: satisfying one does not imply the others have passed. Implementation order and lifecycle management are external to this requirement baseline.

## Required phase-wide behavior

1. The result meets: **25–40 Reading and 25–40 Grammar paired input items; gold isolation and immutable campaign manifest.**.
2. Every sprint's output is internally consistent with the other sprint outputs and with parent normative contracts.
3. The exact source/config/dataset/result evidence supports **Family-disjoint datasets; evaluator, endpoints, analysis, exclusions and resource policies frozen.**.
4. Existing strict Reading V2 and authoritative state invariants remain intact where this phase touches them; the independent research evaluator is not contaminated by arm labels/internal PASS.
5. Missing external data or provider/DB dependencies are labeled `NOT_RUN` or `BLOCKED`, never silently inferred from documents.

## Cross-cutting nonregression and safety

- Authorization and data minimization at every trust boundary, including retrieved documents and evaluator views.
- No fake PASS, backfilled evidence, invisible failed requests or silent provider/model fallback.
- Legacy V2 accepted-head hash/closure, checkpoint fencing, idempotence and production Draft nonregression wherever touched.
- Research data, gold references and intermediate verdicts never leaking into student payload or blind solve.
- Every result is attributable to concrete versioned source/config/dataset identities; unknowns stay UNKNOWN/NOT_RUN.

## Phase acceptance and evidence requirements

The phase-level verdict is `PASS` only when each **RG09-S01…S05** has evidence for positive, meaningful negative, applicable edge and regression checks, and the complete phase result meets its decisive acceptance condition. The associated source commit, code owners, policy/rubric/dataset hashes, tests, report paths, blockers and environment type must be attributable. Documentation-level PASS does not substitute for live/DB evidence where the requirement demands it.

**No future phase is authorized solely by this document.** Production canary/rollback, RQ1 and any historical status not directly verified remain separately scoped.
