# RG00 requirements freeze — design specification

**Date:** 2026-10-14  
**Design status:** Conversation-approved; written-spec review pending  
**RG00 acceptance:** NOT_RUN  
**Inspected baseline commit:** `56bffd8bafe74cd2b9176351b58b83946b2c42a9`  
**Decision authority:** User acting as the RG00 scope and requirements approver
**Open freeze blocker:** Exact section 3.b → RQ2 binding needs explicit user confirmation or documentary evidence.

This document records the approved design for [RG00](../prompts/prompt-phase-00.md). It does not replace the canonical requirements, constitute an implementation plan, close any sprint, or authorize another phase. The current review checkpoint permits only this design document to be written and committed.

## 1. Objective and boundaries

RG00 produces a frozen, internally consistent RQ2 requirements baseline with stable IDs, explicit authority and ownership, traceability, change decisions and attributable documentation-level evidence. All five sprint outcomes are mandatory and independently inspectable.

The thesis titles remain unchanged:

- **Vietnamese:** Phát triển hệ thống học tiếng Anh tích hợp trợ lý AI hội thoại và tự động tạo nội dung bằng đa tác nhân.
- **English:** Developing an English Learning System Integrated with Conversational AI Assistant and Multi-Agent Automated Test Generation.

The two exercise families are distinct from Reading question groups:

| Family | Required research output | Boundary |
|---|---|---|
| Reading | One evidence-grounded passage plus one or two question groups, with type/count fixed by the request | Not a fabricated full-paper Draft Exam; full-paper constraints do not automatically apply |
| Grammar | Contextual exercises tied to an eligible, versioned rule pack, with proposed answers and independently verified reference-answer evidence | Retrieved rules and generator proposals are not independent item-level gold |

The scientific target remains paired A/B/C comparison: direct generation, same-model sequential self-review, and separated multi-agent generation/review/validation with bounded repair. The target is 25–40 Reading requests and 25–40 Grammar requests, each assigned to all three arms: 150–240 assignments before optional repeats. No result or superiority of C is presumed.

Relevant product integration remains traceable to RG12: human publication, immutable learner delivery, version-pinned attempts, grading, history and progress. RG00 records these requirements; it does not implement or demonstrate them.

### Exclusions

- Application-source or baseline-tooling source changes, new service interfaces, migrations or database changes.
- Provider calls, paid campaigns, deployment, canary/rollback execution, automatic publication or research-to-production promotion.
- RQ1 experimental design or claims that RQ2 proves phoneme-level pronunciation accuracy, STT/GOP performance or Speaking pedagogical efficacy.
- Changes to thesis titles, historical document cleanup, branch creation, pushing or automatic execution of RG01–RG13.
- Freezing numerical evaluator thresholds, final datasets, provider revisions or campaign settings owned by later gates.

Documentation and evidence-data changes for the five outcomes require the written-spec review and planning transition described in section 10. They are not made merely by recording this design.

## 2. Selected approach and alternatives

**Decision:** Extend the existing canonical documents and add a scoped freeze/evidence record. Requirements retain one authority chain under `generation_baseline/`; evidence refers to those documents rather than creating a second requirements baseline.

| Approach | Benefit | Cost and disposition |
|---|---|---|
| Extend canonical documents plus freeze/evidence record | Reuses established authority and keeps each sprint independently inspectable | Requires cross-document consistency and hash checks; selected |
| Separate five-file freeze package | Isolates each sprint output visibly | Duplicates requirements and creates drift/precedence risk; rejected |
| One consolidated specification | Minimizes document count | Obscures independent ownership and acceptance of five outcomes; rejected |

The consequence is deliberate separation between normative targets, documentation evidence and future implementation evidence. Additional evidence records are not an alternative source of requirements.

## 3. Authority, provenance and ownership

The precedence in [SOURCE_OF_TRUTH.md](../SOURCE_OF_TRUTH.md) remains controlling. Audited source can establish implementation reality but cannot silently weaken the target requirements.

### Approved proposal authority

The user explicitly selected **“Approve the repository summary”** for [MASTER_PROPOSAL.md](../MASTER_PROPOSAL.md) and [HISTORICAL_AND_PROPOSAL_CONTEXT.md](../references/HISTORICAL_AND_PROPOSAL_CONTEXT.md). This is normative approval for RG00, not verification that either file reproduces the original submitted outline verbatim.

RG00-S01 requires section labels 2.2.e, 3.b, 4.e and 4.g. The approved historical/proposal summary explicitly names 2.2.e, 4.e and 4.g, plus 2.2.f for learner integration. Those mappings identify their summary source and remain labeled **summary-derived; original-outline verification NOT_RUN**. No missing original wording is invented or quoted as inspected primary evidence.

**Section 3.b binding is UNKNOWN:** the sprint requires that label, and the master proposal defines RQ2, but neither approved summary explicitly binds the two. The user must explicitly confirm that binding, or documentary evidence must establish it, before the affected S01/S05 section-coverage claim can pass; until then that claim is BLOCKED. The approved RQ2 scope itself is not in doubt.

### Evidence classes

| Class | What it can establish | Logical owner and limitation |
|---|---|---|
| Approved requirement | Intended behavior, scope, constraints and acceptance criteria | User/research owner; not implementation proof |
| Verified current source/execution | Capability observed at a concrete source and environment identity | Actual owner established by RG01; not established by this design |
| Frozen experiment | Versioned assignments, model/policy/evaluator configuration and sealed outcomes | Research owner under the later freeze/campaign gates; not yet produced |
| Independent human gold | Adjudicated item-level reference evidence | Authorized research gold custodian/adjudicator; never generator or blind-solver input |
| Reported V2 history | What the historical handoff reports | Historical evidence custodian; not current-source or live/DB PASS |
| Hypothesis | A hazard or proposed explanation that still needs investigation | Relevant logical requirement owner; verification remains NOT_RUN |

Every requirement names its normative origin, logical owner, expected proof class, acceptance gate and evidence state. Human role names describe responsibilities, not invented personnel assignments or access grants.

The user approves RG00 scope and change decisions. Target component responsibilities follow the proposal: the coordinator routes work, the generator proposes content, the reviewer raises issues, the validator checks conditions, and .NET authoritative storage alone commits accepted state. Human editorial approval owns publication; the independent research evaluator owns external scoring.

Concrete source paths, actual code owners, API names, DTOs and persisted columns remain UNKNOWN until RG01 establishes them. This is a declared later-phase prerequisite, not permission to invent confirmed implementation ownership. Missing logical accountability for a mandatory frozen requirement does block RG00 freeze.

## 4. Five independently inspectable outcomes

| Sprint | Canonical artifact | Required design content |
|---|---|---|
| [RG00-S01](../prompts/sprints/prompt-sprint-00-01.md) | `MASTER_PROPOSAL.md` | Unchanged titles; Reading/Grammar units; RQ2 question and A/B/C targets; summary-derived proposal-section links; RQ1 boundary; product integration and explicit non-goals |
| [RG00-S02](../prompts/sprints/prompt-sprint-00-02.md) | `SOURCE_OF_TRUTH.md` | Normative precedence; evidence-class/claim/owner map; original-outline and reported-history limitations; explicit UNKNOWN/NOT_RUN rules |
| [RG00-S03](../prompts/sprints/prompt-sprint-00-03.md) | `architecture/STATE_AND_AUTHORITY.md` | Stable invariant IDs with applicability, owner, prohibited transition/failure behavior, proof class and future verification gate |
| [RG00-S04](../prompts/sprints/prompt-sprint-00-04.md) | `CHANGE_CONTROL.md` | Explicit decision register; reference-bound snapshot of all 14 phases and 70 sprints; dependency interpretation; unresolved assumptions and their disposition |
| [RG00-S05](../prompts/sprints/prompt-sprint-00-05.md) | `REQUIREMENTS_TRACEABILITY.md` | Proposal section → stable requirement ID → output → owner → gate → research metric/evidence; full must-have coverage and design-review disposition |

Existing `RQ2-*`, `PROD-*`, `SEC-*`, `DUR-*`, `OPS-*` and `RQ1-*` IDs remain stable. New invariant and decision IDs link to these requirements; they do not rename or silently replace them.

The existing [phase index](../PHASE_INDEX.md), [sprint index](../SPRINT_INDEX.md), [contract registry](../contracts/CONTRACT_REGISTRY.md), [research protocol](../research/RQ2_PROTOCOL.md), [rubric](../research/RUBRIC.md) and [RQ1 boundary](../research/RQ1_BOUNDARY.md) remain canonical references. Necessary consistency clarifications do not expand the phase or imply runtime changes.

## 5. Invariant inventory requirements

S03 gives each invariant a stable ID and explicit violation disposition. At minimum, it covers the following distinct boundaries.

| Boundary | Required invariant and failure behavior |
|---|---|
| Strict full-paper Reading | Three sections, six groups, exactly 40 continuously numbered questions; S1: 7 TFNG + 6 sentence completion; S2: 6 MCQ Single + 7 summary completion; S3: 7 YNNG + 7 short answer. An incompatible full-paper candidate cannot be accepted |
| Full-paper source/length policy | Preserve the applicable 720–915 words per passage and 2,150–2,750 total target; apply source eligibility/licensing and source-specific minimums only to the routes they govern, not universally |
| Historical 3×40 evidence | Three historical full papers/120 questions remain reported acceptance, distinct from each paper's three-section/40-question shape and from smaller research units. Neither is newly verified by RG00 |
| Authoritative ownership | .NET exam-service/PostgreSQL owns durable Job/Run/artifact/operation/accepted-head/checkpoint/Exam transitions; Python and AI roles cannot mutate the authoritative graph directly |
| Hash and closure | Acceptance requires current content-bound evaluations, valid source/dependency closure and compliant head transitions; stale or mismatched evidence cannot justify acceptance |
| Fencing and recovery | Lease/epoch/version checks, cancellation, retries and idempotence remain enforced; a stale worker cannot commit |
| Draft persistence | A strict full-paper transaction persists the complete Draft graph or none; lost-ACK replay resolves the existing Exam identity rather than duplicating it |
| Role separation | Coordinator/generator/reviewer/validator responsibilities do not grant direct commit authority; unresolved BLOCKING issues cannot be ignored |
| Answer/gold privacy | SolverView excludes proposed/generated/gold answers and internal verdicts; AnswerVerificationView follows the recorded blind solve; expert gold remains restricted to scoring/adjudication |
| Independent evaluation | All arms receive the same independent downstream rubric; arm identity, hidden costs/traces and internal PASS cannot contaminate blind solve or independent scoring |
| Research isolation | Standard and ablation research outputs cannot publish through any route; disabling semantic stages never disables auth, licensing, hashing, closure, fencing or honest NOT_RUN accounting |
| Human publication and learner ACL | Explicit authorized human publication creates an immutable snapshot; answer-free delivery and later feedback follow release policy; attempts/grading bind the snapshot and owned history enforces learner/tenant ACL |
| Provider/resource policy | The actual provider/model obeys its pin; pinned MiniMax-only runs have no silent fallback. Approved uncapped cumulative application budgets do not remove finite repair, per-call limits, cancellation, quotas, accounting or consent |
| Failure-inclusive accounting | Execution status, output availability and evaluation verdict remain independent; failures/partials remain visible in assigned denominators; unknown usage is not fabricated as zero |
| Trust boundaries | Auth, tenant separation, data minimization, permitted source access and provenance/licensing hold at every applicable boundary, including retrieved documents and evaluator views |

These are frozen target obligations. Recording a failure rule is not evidence that an actual runtime rejects it; those checks retain their future gates.

## 6. Dependencies, decisions and unresolved assumptions

### Phase dependency inventory

The inventory to be frozen follows the canonical phase specifications and indexes:

| Phase | Prerequisites |
|---|---|
| RG00 | None |
| RG01 | RG00 |
| RG02 | RG01 |
| RG03 | RG02 |
| RG04 | RG03 |
| RG05 | RG02, RG03 |
| RG06 | RG02, RG03, RG04 |
| RG07 | RG04, RG05, RG06 |
| RG08 | RG07 |
| RG09 | RG08 |
| RG10 | RG09 |
| RG11 | RG10 |
| RG12 | RG02, RG06 |
| RG13 | RG10, RG11, RG12 |

All 70 canonical sprint IDs, their parent phases and declared preconditions must exist in the snapshot; five mandatory sprints belong to each phase. RG00's dependency check detects absent prerequisites, duplicate IDs, index/spec disagreement and cycles. This inventory is a dependency contract, not authorization or a schedule for executing later phases.

### Accepted decision register

| ID | Decision | Reason and consequence |
|---|---|---|
| RG00-D01 | Use the user-approved repository summary as normative RG00 proposal authority | Enables requirements freeze while keeping primary-outline verification unclaimed |
| RG00-D02 | Extend canonical documents and attach separate evidence | Avoids competing requirements copies; changes require cross-document/hash consistency |
| RG00-D03 | Interpret Reading and Grammar as the two output families; research Reading permits one or two groups | Removes shorthand ambiguity without changing research or strict full-paper scope |
| RG00-D04 | Treat within-phase predecessors as artifact acceptance/consistency dependencies, not mandated drafting order | Reconciles sprint preconditions with the parent rule that implementation order and lifecycle are external; dependent acceptance requires a consistent predecessor artifact |
| RG00-D05 | Keep requirement plans separate from executed evidence | Planned NOT_RUN entries are never backfilled as if runtime tests ran |
| RG00-D06 | Permit only documentation-level RG00 acceptance under this design | Live/DB/provider evidence and concrete source mappings remain owned by later phases |
| RG00-D07 | Treat unresolved mandatory freeze conflicts or missing logical owners as blockers | Explicitly recording BLOCKED is honest disclosure, not a reason to award phase PASS |

S04 records each decision's authority, affected requirement IDs, evidence identity, impact and acceptance checks. A new contradiction follows the precedence/change-control rules: resolve it explicitly with the accountable approver or retain a concrete BLOCKED disposition. No substantive requirement is silently softened.

### Known limitations and disposition

- Original submitted outline: unavailable in the inspected repository; original-outline verification NOT_RUN. D01 permits summary-derived scope mapping, not primary-source claims.
- Section 3.b → RQ2 binding: UNKNOWN; the affected S01/S05 section-coverage claim remains BLOCKED pending explicit user confirmation or documentary evidence. General summary approval is not recorded as confirmation of an unstated section binding.
- Actual source capabilities, routes, DTOs and code-owner mappings: UNKNOWN; RG01 supplies them. No source capability is asserted by RG00.
- Historical V2 accepted-head closure, live persistence, frontend rendering, canary and rollback: reported or unverified as documented; no current PASS inferred.
- Evaluator thresholds/reliability, sealed gold/datasets, final model revisions and campaign outcomes: NOT_RUN or not yet frozen under their later gates.
- Optional ablation: remains optional; it does not become a mandatory RG00 or RG13 prerequisite unless separately included in scope.

## 7. Proposal coverage and research metrics

S05 preserves the existing requirement IDs while adding proposal-section provenance, accountable logical owner, concrete output, required gate, metric/proof class and evidence state. No mandatory RQ2 requirement may lack any of those links.

The matrix covers specialized roles, bounded Reading, grounded Grammar, scoped repair, independent evaluation, calibrated judge, family-disjoint datasets, paired A/B/C assignments, blinded human review, failure-inclusive accounting, reproducible analysis, publication safety, durability and the separate RQ1 boundary.

Research metrics retain the protocol's semantics:

- Primary: independent valid completion divided by all frozen assigned request/arm slots; missing, uncertain, failed and timed-out outcomes are not PASS.
- Secondary: completion, conditional evaluable-output quality with its denominator, type-specific hard/semantic errors, latency P50/P95 and timeout censoring, calls, repairs, tokens, priced cost and cost per independently valid output.
- Evaluator reliability: confusion counts, decided FAR/FRR, abstention, decided coverage and uncertainty; zero denominators are undefined/N/A, not fabricated zero error.
- Inference: paired contrasts and request/source-family-aware uncertainty; do not treat questions within a passage as independent requests or interpret a null result as equivalence.

RG00 freezes metric definitions and gate ownership, not observed values, numeric calibration thresholds or final campaign configuration.

## 8. Freeze identity and evidence records

Two documentation-data outputs accompany the eventual canonical changes:

- `verification/RG00_FREEZE.json`: freeze identity, base source commit, canonical document paths and SHA-256 digests, governing-reference digests, requirement/invariant/decision IDs, phase/sprint inventory references, logical owners, approval provenance and limitations/blockers.
- `verification/RG00_VERIFICATION.json`: the freeze digest and separately attributable executed check records, including test ID, input/fixture identity, expected and observed outcome, reproducible command or documented inspection method, execution result, artifact references, environment kind and disposition.

Each check record binds to the actual executed source commit (full SHA) and checked input/worktree digests, including the validation tool, not only the intended freeze digest. Dirty-worktree changes and isolated-copy origin are disclosed. Missing identity or an unexplained mismatch between the executed inputs and frozen artifact identities makes the check BLOCKED, never PASS. A different HEAD must be disclosed and explicitly mapped to matching frozen inputs; the authoring-time commit in this specification is not execution evidence.

The freeze record hashes the five canonical outputs and their governing references, not itself or the verification report. The verification report references the freeze digest; the final documentation commit binds both records. This avoids a circular hash dependency. Base source commit and changed document digests are distinct identities; evidence never implies that an uncommitted document already belonged to the base commit.

Policy/rubric document hashes identify the normative versions inspected, not a future calibrated judge or sealed experiment. Uncreated datasets and unexecuted provider/DB checks carry explicit absence/NOT_RUN reasons rather than invented hashes or request IDs. Evidence excludes secrets, private learner data, gold answers and paid-provider payloads.

The existing planned `verification/TEST_CATALOG.json` entries remain NOT_RUN as definitions. Actual RG00 results are recorded separately. The RG00 row in the gate matrix may reference documentation-only PASS only after all required evidence exists; later rows remain unchanged. Package inventory references are kept consistent with documented outputs without claiming a package manifest proves implementation.

## 9. Verification and acceptance

The documentation phase uses the existing offline package validator plus disposable offline checks and explicit semantic review of the actual artifacts. It adds no application tests or permanent tooling source. Documentation fixtures and mutations are not simulations of live provider or database proof.

| Sprint | Positive proof | Meaningful negative proof | Edge proof | Documentation regression proof |
|---|---|---|---|---|
| S01 | Scope and claims map to the required summary-derived proposal sections; RQ1 stays separate | An RQ2-based pronunciation/RQ1 completion claim is rejected | Missing original outline or incomplete section provenance stays explicitly unverified/blocked for that claim | Both titles, Reading/Grammar units and RQ1/non-goal boundaries remain unchanged |
| S02 | Every requirement has an evidence class and logical owner | Reported history cannot become current verified PASS without executed evidence | Missing/stale evidence identity cannot support a verified claim | Authority precedence and historical limitations are retained |
| S03 | Every invariant has a unique ID, scope, owner and failure behavior | A proposed research-publication exception or fencing/hash/privacy waiver is rejected | Conflicting policy applicability or missing invariant identity blocks acceptance | Strict full-paper, durability, privacy and no-fallback obligations are preserved |
| S04 | All 14 phases/70 sprints exist with valid, acyclic dependencies and explicit decisions | Invented confirmed interfaces and invalid dependency graphs are rejected | Missing/duplicate nodes, index/spec mismatch or stale snapshot identity is detected | Existing phase boundaries and the D04 scheduling distinction are preserved |
| S05 | Every mandatory RQ2 requirement has output, owner, gate and metric/proof coverage | Missing ownership/coverage or an unresolved mandatory conflict blocks freeze | Orphan requirement, duplicate ID or stale cross-reference is detected | Existing IDs, independent evaluation, denominators and future-phase boundaries remain intact |

Evidence uses the existing `POS-RG00-S01` through `REG-RG00-S05` case IDs: four classes for each of five sprints. A passing validator run alone does not close these 20 cases. Negative checks demonstrate rejection or blocked disposition on the relevant documentation data, not merely the presence of a sentence describing rejection.

Where runtime regression is inapplicable because application behavior is untouched, record that scope explicitly and perform the documentation regression above. Do not claim that V2, auth, publication, database atomicity or provider behavior was exercised.

### Gate rules

- Each sprint has inspectable output and attributable positive, meaningful negative, applicable edge and documentation regression evidence.
- All five outcomes use compatible document identities, policy semantics and dependency decisions.
- A mandatory missing owner, uncovered requirement, unresolved contradictory requirement or missing required evidence prevents phase PASS. Marking the affected claim BLOCKED satisfies truthful disclosure, not acceptance.
- `DESIGN_COMPLETE`, documentation-level RG00 PASS, source verification and later implementation/research/product acceptance remain separate states.
- RG00 may close only its documentation obligations. No future phase, RQ1 claim, historical acceptance or operational readiness is authorized or verified by that closure.

## 10. Approval and transition boundary

The user approved the repository-summary authority and all three design sections in this conversation. This written specification is now submitted for review; written-spec approval is still pending.

This checkpoint permits creation and a local commit of this design file only. The five canonical artifacts, freeze/evidence records, planned test statuses and gate verdicts are not yet changed. No source code, provider, database or production operation is touched, and nothing is pushed.

After the user approves the written specification, the next step is the writing-plans skill for an RG00-only implementation plan. It must retain all five outcomes, their documentation-level checks and these authorization boundaries. It must not treat the 14-phase dependency inventory as permission to execute RG01 or later work.
