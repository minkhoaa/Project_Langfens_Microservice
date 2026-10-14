# RG01 — Verify source reality and contract mapping

**Status:** `TARGET_SPEC / NOT_RUN`  
**Depends on:** RG00  
**Coverage:** Five bounded micro-sprint specifications; all mandatory for this phase gate.

## Research and system objective

A read-only code map with source SHA, file:line/symbol evidence, capabilities and technical gaps.

**Decisive acceptance condition:** No uninspected capability is asserted implemented and no historical cleanup is authorized.

The phase prompt is a **target specification**, not a plan or execution playbook. Existing source capability may be reused if RG01 establishes proof; equivalent implementations are permitted only when normative behavior, verification and backward compatibility are preserved.

## Scope boundaries

**Included capabilities:** source-to-contract map, actual route and storage owners, test and configuration inventory. The phase is limited to its five listed micro-sprints and their compatibility, security and evidence requirements.

**Explicit exclusions:** Editing source/docs, creating cleanup commits, applying migrations or asserting runtime configuration from old reports.

## Required independent micro-sprint outcomes

| Canonical spec | Named requirement | Observable deliverable |
|---|---|---|
| [RG01-S01](sprints/prompt-sprint-01-01.md) | Git and repository snapshot | Read-only source SHA/branch/worktree/dirty state and applicable AGENTS instructions |
| [RG01-S02](sprints/prompt-sprint-01-02.md) | Service topology and persistence ownership | File:line mapping of frontend, gateway, .NET exam-service, Python generation-service, DB, APIs and auth |
| [RG01-S03](sprints/prompt-sprint-01-03.md) | Reading loops and runtime policies | Trace SourcePack→Blueprint→Passage→Candidates→Section→Paper→Draft with real symbols and 3/3/2/5 definitions |
| [RG01-S04](sprints/prompt-sprint-01-04.md) | Retrieval, grammar and learner inventory | Map current vector/RAG, grammar content, grading, publish, attempts and learning history |
| [RG01-S05](sprints/prompt-sprint-01-05.md) | Evidence-backed implementation gap map | Contract-to-code matrix with owner, test gaps, priority, compatibility and scoped decisions |

The five artifacts are independently inspectable: satisfying one does not imply the others have passed. Implementation order and lifecycle management are external to this requirement baseline.

## Required phase-wide behavior

1. The result meets: **A read-only code map with source SHA, file:line/symbol evidence, capabilities and technical gaps.**.
2. Every sprint's output is internally consistent with the other sprint outputs and with parent normative contracts.
3. The exact source/config/dataset/result evidence supports **No uninspected capability is asserted implemented and no historical cleanup is authorized.**.
4. Existing strict Reading V2 and authoritative state invariants remain intact where this phase touches them; the independent research evaluator is not contaminated by arm labels/internal PASS.
5. Missing external data or provider/DB dependencies are labeled `NOT_RUN` or `BLOCKED`, never silently inferred from documents.

## Cross-cutting nonregression and safety

- Authorization and data minimization at every trust boundary, including retrieved documents and evaluator views.
- No fake PASS, backfilled evidence, invisible failed requests or silent provider/model fallback.
- Legacy V2 accepted-head hash/closure, checkpoint fencing, idempotence and production Draft nonregression wherever touched.
- Research data, gold references and intermediate verdicts never leaking into student payload or blind solve.
- Every result is attributable to concrete versioned source/config/dataset identities; unknowns stay UNKNOWN/NOT_RUN.

## Phase acceptance and evidence requirements

The phase-level verdict is `PASS` only when each **RG01-S01…S05** has evidence for positive, meaningful negative, applicable edge and regression checks, and the complete phase result meets its decisive acceptance condition. The associated source commit, code owners, policy/rubric/dataset hashes, tests, report paths, blockers and environment type must be attributable. Documentation-level PASS does not substitute for live/DB evidence where the requirement demands it.

**No future phase is authorized solely by this document.** Production canary/rollback, RQ1 and any historical status not directly verified remain separately scoped.
