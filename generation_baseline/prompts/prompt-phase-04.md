# RG04 — Calibrate and freeze independent evaluator

**Status:** `TARGET_SPEC / NOT_RUN`  
**Depends on:** RG03  
**Coverage:** Five bounded micro-sprint specifications; all mandatory for this phase gate.

## Research and system objective

Labeled calibration/holdout, tuned evaluator, reported reliability and frozen judge manifest.

**Decisive acceptance condition:** No holdout reuse for tuning; coverage/FAR/FRR and error counts are transparent.

The phase prompt is a **target specification**, not a plan or execution playbook. Existing source capability may be reused if RG01 establishes proof; equivalent implementations are permitted only when normative behavior, verification and backward compatibility are preserved.

## Scope boundaries

**Included capabilities:** R1 rubric, Evaluator freeze manifest, calibration/holdout split. The phase is limited to its five listed micro-sprints and their compatibility, security and evidence requirements.

**Explicit exclusions:** Unrelated service refactors, spontaneous provider replacement, old-handoff cleanup, automatic student publication, unapproved live deployment or changes to the other research question.

## Required independent micro-sprint outcomes

| Canonical spec | Named requirement | Observable deliverable |
|---|---|---|
| [RG04-S01](sprints/prompt-sprint-04-01.md) | Labeled calibration corpus | Expert-labeled positive and adversarial error items across Reading and Grammar types |
| [RG04-S02](sprints/prompt-sprint-04-02.md) | Sealed judge holdout and human guidelines | Separate provenance-disjoint judge-holdout, blinded IDs, reviewer instructions and adjudication policy |
| [RG04-S03](sprints/prompt-sprint-04-03.md) | Calibrate judge on allowed data | Score anchors, prompts and thresholds fit only on CALIBRATION; revision history retained |
| [RG04-S04](sprints/prompt-sprint-04-04.md) | One-time holdout reliability | Measure decided FAR/FRR, abstention/coverage, confusion by type, intervals and raw counts |
| [RG04-S05](sprints/prompt-sprint-04-05.md) | Freeze judge and reliability decision | Immutable evaluator manifest/hash with acceptable error limits or explicit BLOCKED |

The five artifacts are independently inspectable: satisfying one does not imply the others have passed. Implementation order and lifecycle management are external to this requirement baseline.

## Required phase-wide behavior

1. The result meets: **Labeled calibration/holdout, tuned evaluator, reported reliability and frozen judge manifest.**.
2. Every sprint's output is internally consistent with the other sprint outputs and with parent normative contracts.
3. The exact source/config/dataset/result evidence supports **No holdout reuse for tuning; coverage/FAR/FRR and error counts are transparent.**.
4. Existing strict Reading V2 and authoritative state invariants remain intact where this phase touches them; the independent research evaluator is not contaminated by arm labels/internal PASS.
5. Missing external data or provider/DB dependencies are labeled `NOT_RUN` or `BLOCKED`, never silently inferred from documents.

## Cross-cutting nonregression and safety

- Authorization and data minimization at every trust boundary, including retrieved documents and evaluator views.
- No fake PASS, backfilled evidence, invisible failed requests or silent provider/model fallback.
- Legacy V2 accepted-head hash/closure, checkpoint fencing, idempotence and production Draft nonregression wherever touched.
- Research data, gold references and intermediate verdicts never leaking into student payload or blind solve.
- Every result is attributable to concrete versioned source/config/dataset identities; unknowns stay UNKNOWN/NOT_RUN.

## Phase acceptance and evidence requirements

The phase-level verdict is `PASS` only when each **RG04-S01…S05** has evidence for positive, meaningful negative, applicable edge and regression checks, and the complete phase result meets its decisive acceptance condition. The associated source commit, code owners, policy/rubric/dataset hashes, tests, report paths, blockers and environment type must be attributable. Documentation-level PASS does not substitute for live/DB evidence where the requirement demands it.

**No future phase is authorized solely by this document.** Production canary/rollback, RQ1 and any historical status not directly verified remain separately scoped.
