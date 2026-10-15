# Change-control and conflict decision rules

This directory is a stable target specification. Source reality discovered in RG01 may differ from names or concrete shapes used here. A legitimate adaptation preserves the intended semantics and records (1) observed file/commit and reason for conflict, (2) proposed revised schema/adapter, (3) security/research/legacy regression impact, (4) test/evidence required, and (5) explicit decision ownership.

The following cannot be silently waived or softened: thesis title and RQ2 design; full Reading V2 acceptance invariants; authoritative .NET commit and hash/lease closure; answer/gold isolation; independent judge; assigned request denominator; research publication prohibition; student ACL; honest UNKNOWN/NOT_RUN treatment; frozen FINAL primary outcome and dataset.

A blocked third-party provider, absent credentials, missing DB access or unpublished deployment does not justify creating pretend green evidence. The baseline can be marked design-complete while source/external proof remains blocked. Config/schema changes after final experiment freeze imply a new version/campaign or an explicitly scoped deviation documented alongside original results.

## Frozen 14-phase DAG and 70 micro-sprint units

The lifecycle architecture consists of 14 strictly bounded phases and 70 atomic micro-sprints (5 sprints per phase, S01–S05). The dependency graph is strictly acyclic, with each phase depending solely on preceding phases.

| Phase | Title / Scope | Prerequisites | Sprints |
|---|---|---|---|
| **RG00** | Freeze research proposal and nonnegotiable requirements | None | RG00-S01 .. S05 |
| **RG01** | Audit source reality and pin baseline | RG00 | RG01-S01 .. S05 |
| **RG02** | Separate logical roles and contract boundaries | RG01 | RG02-S01 .. S05 |
| **RG03** | Specify independent quality rubric and scoring engine | RG02 | RG03-S01 .. S05 |
| **RG04** | Calibrate evaluator on disjoint holdout | RG03 | RG04-S01 .. S05 |
| **RG05** | Production Reading V2 integration and nonregression | RG02, RG03 | RG05-S01 .. S05 |
| **RG06** | Grammar exercise generation and verified reference answers | RG02, RG03, RG04 | RG06-S01 .. S05 |
| **RG07** | Design paired A/B/C experimental protocol | RG04, RG05, RG06 | RG07-S01 .. S05 |
| **RG08** | Implement blind solve and adversarial verification | RG07 | RG08-S01 .. S05 |
| **RG09** | Freeze benchmark dataset and execution pipeline | RG08 | RG09-S01 .. S05 |
| **RG10** | Execute sealed comparative campaign | RG09 | RG10-S01 .. S05 |
| **RG11** | Analyze paired results and cost-quality tradeoffs | RG10 | RG11-S01 .. S05 |
| **RG12** | Learner integration and publication safety | RG02, RG06 | RG12-S01 .. S05 |
| **RG13** | Synthesize research findings and final gate review | RG10, RG11, RG12 | RG13-S01 .. S05 |

*Acyclicity proof:* Phase indices strictly satisfy $i < j$ for all directed edges $(RG_i, RG_j)$ in the dependency relation, establishing an irreflexive partial order with topological sorting $RG00 \prec RG01 \prec RG02 \prec \dots \prec RG13$.

## Explicit decision register (RG00-D01 .. RG00-D07)

| Decision ID | Summary of Decision | Justification and Invariant Impact |
|---|---|---|
| `RG00-D01` | Use user-approved repository summary as normative proposal authority | Enables requirements freeze while keeping primary-outline verification unclaimed (`NOT_RUN`). |
| `RG00-D02` | Extend canonical documents and attach separate evidence records | Reuses established authority; prevents drift and competing requirements baselines. |
| `RG00-D03` | Interpret Reading and Grammar as the two exercise output families | Clarifies research unit (Reading = 1 passage + 1–2 groups; Grammar = contextual rules + gold) without altering full-paper V2 rules. |
| `RG00-D04` | Treat within-phase predecessors as artifact consistency dependencies | Reconciles sprint preconditions with external execution lifecycle; dependent acceptance requires consistent predecessor artifact. |
| `RG00-D05` | Keep planned requirements separate from executed evidence | Planned catalog items remain `NOT_RUN` until real execution; never backfill fake PASS. |
| `RG00-D06` | Permit only documentation-level RG00 acceptance under this design | Live/DB/provider verification and concrete source mappings remain strictly owned by later phases (RG01+). |
| `RG00-D07` | Treat unresolved mandatory conflicts or missing owners as blockers | Recording `BLOCKED` ensures honest status disclosure without falsely granting gate PASS. |

## Unresolved assumptions and disposition

1. **Original submitted KLTN proposal document:** Unavailable in inspected repository; original-source verification remains `NOT_RUN`. D01 permits summary-derived and user-confirmed proposal scope mapping without fabricating local file provenance.
2. **Section 3.b binding to RQ2:** Recorded as user-confirmed while original-source verification remains `NOT_RUN`: explicitly defines the two representative Multi-Agent content groups (Passage-grounded Reading questions and Grammar exercises with reference answers), consistent with Sections 2.2.e, 2.3 (RQ2), 4.e, and 4.g.
3. **Concrete source paths, API names, and DTOs:** Unresolved source API names **cannot be invented as confirmed contract**; their factual mappings are deferred to RG01 source audit.
4. **Historical V2 accepted-head closure and canary/rollback:** Retained as reported history; no current-source PASS inferred.
5. **Evaluator calibration thresholds & sealed gold:** Retained as `NOT_RUN` targets; frozen under RG04 and RG09.
6. **Optional ablation:** Remains optional product exploration; not a mandatory blocker for RG00 or RG13.
