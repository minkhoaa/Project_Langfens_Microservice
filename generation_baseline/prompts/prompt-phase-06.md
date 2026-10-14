# RG06 — Evidence-grounded Grammar exercise generation

**Status:** `TARGET_SPEC / NOT_RUN`  
**Depends on:** RG02, RG03, RG04  
**Coverage:** Five bounded micro-sprint specifications; all mandatory for this phase gate.

## Research and system objective

GrammarRulePack retrieval, grammar candidates, checked answers, blind solve and scoped repairs.

**Decisive acceptance condition:** Rule provenance is not misrepresented as independently verified question gold.

The phase prompt is a **target specification**, not a plan or execution playbook. Existing source capability may be reused if RG01 establishes proof; equivalent implementations are permitted only when normative behavior, verification and backward compatibility are preserved.

## Scope boundaries

**Included capabilities:** C1 Generation, GrammarRulePack, KnowledgeRetrievalPort, C3 Evaluation. The phase is limited to its five listed micro-sprints and their compatibility, security and evidence requirements.

**Explicit exclusions:** Unrelated service refactors, spontaneous provider replacement, old-handoff cleanup, automatic student publication, unapproved live deployment or changes to the other research question.

## Required independent micro-sprint outcomes

| Canonical spec | Named requirement | Observable deliverable |
|---|---|---|
| [RG06-S01](sprints/prompt-sprint-06-01.md) | Grammar exercise blueprint and rule pack | Task schema for level, target rule, gap/mcq/error-correction, contexts, exceptions and provenance |
| [RG06-S02](sprints/prompt-sprint-06-02.md) | Knowledge retrieval abstraction | KnowledgeRetrievalPort with adapter over observed KB/vector stack, provenance and safe no-evidence fallback |
| [RG06-S03](sprints/prompt-sprint-06-03.md) | Candidate and reference evidence generation | Grammar questions, candidate answer, acceptable variants, context and source-grounded explanation |
| [RG06-S04](sprints/prompt-sprint-06-04.md) | Grammar blind/reviewer/validator and repair | Independent grammar solve, distractor contradiction checks, rule application and scoped repair |
| [RG06-S05](sprints/prompt-sprint-06-05.md) | Grammar research persistence and surface | Resumable research outputs, canonical failure traces, safe admin review and compatible storage |

The five artifacts are independently inspectable: satisfying one does not imply the others have passed. Implementation order and lifecycle management are external to this requirement baseline.

## Required phase-wide behavior

1. The result meets: **GrammarRulePack retrieval, grammar candidates, checked answers, blind solve and scoped repairs.**.
2. Every sprint's output is internally consistent with the other sprint outputs and with parent normative contracts.
3. The exact source/config/dataset/result evidence supports **Rule provenance is not misrepresented as independently verified question gold.**.
4. Existing strict Reading V2 and authoritative state invariants remain intact where this phase touches them; the independent research evaluator is not contaminated by arm labels/internal PASS.
5. Missing external data or provider/DB dependencies are labeled `NOT_RUN` or `BLOCKED`, never silently inferred from documents.

## Cross-cutting nonregression and safety

- Authorization and data minimization at every trust boundary, including retrieved documents and evaluator views.
- No fake PASS, backfilled evidence, invisible failed requests or silent provider/model fallback.
- Legacy V2 accepted-head hash/closure, checkpoint fencing, idempotence and production Draft nonregression wherever touched.
- Research data, gold references and intermediate verdicts never leaking into student payload or blind solve.
- Every result is attributable to concrete versioned source/config/dataset identities; unknowns stay UNKNOWN/NOT_RUN.

## Phase acceptance and evidence requirements

The phase-level verdict is `PASS` only when each **RG06-S01…S05** has evidence for positive, meaningful negative, applicable edge and regression checks, and the complete phase result meets its decisive acceptance condition. The associated source commit, code owners, policy/rubric/dataset hashes, tests, report paths, blockers and environment type must be attributable. Documentation-level PASS does not substitute for live/DB evidence where the requirement demands it.

**No future phase is authorized solely by this document.** Production canary/rollback, RQ1 and any historical status not directly verified remain separately scoped.
