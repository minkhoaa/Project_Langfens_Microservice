# "10/10" acceptance model — measurable, not rhetorical

**Meaning:** 10/10 indicates that every *mandatory* agreed requirement has a verified implementation and defensible evidence, not that every future AI output is 100% correct, that the multi-agent system always wins, or that production has completed an operational canary.

## Required dimensions and proof

| Dimension | 10/10 criterion | Required evidence | Gate |
|---|---|---|---|
| Thesis scope | RQ2 methods/outputs and separate RQ1 boundary traceable | thesis requirement mapping | RG00, RG13 |
| Source fidelity | every claimed code capability verified from actual repo | SHA, module and test mapping | RG01 |
| Four roles | role semantics, permission boundaries and authoritative commit | trace records, forbidden transition tests | RG02 |
| Contract safety | versioned schemas, error semantics, all data-view access guards | strict positive/negative compatibility suites | RG02 |
| State correctness | accepted heads, leases, hash/dependency closure, idempotent persistence | real DB/worker fault injection and V2 regression | RG02, RG08, RG13 |
| Neutral evaluation | A/B/C cannot bias downstream judge; blind solve sees no answer | canary/label permutation tests | RG03 |
| Judge reliability | calibrated thresholds, disjoint sealed holdout, FAR/FRR/coverage/abstention | labeled holdout and error analysis | RG04 |
| Reading generation | bounded research unit, full-paper behavior unchanged | source-grounded examples and 3×40 regression | RG05 |
| Grammar generation | verified rule provenance and question-level answer correctness | curated gold fixtures and ambiguity tests | RG06 |
| Fair A/B/C | same frozen input/base model and same downstream judge | paired assignment ledger and every-failure reconciliation | RG07–RG10 |
| Research evidence | 25–40 paired tasks per domain, independent scoring and human subset | sealed final campaign and review adjudication | RG09–RG10 |
| Statistical rigor | preregistered request-level endpoints, paired uncertainty, cost accounting | independently reproducible statistics | RG11, RG13 |
| Learner safety | manual publication, answer-free delivery, versioned grading, ACL | E2E/negative product tests | RG12 |
| Truthful handoff | audit of actual vs planned checks, limited claims, no hidden blockers | final source/evidence manifests | RG13 |

**Blocked or not executed mandatory work means the relevant dimension is not 10/10.** A passing offline documentation checker only proves package consistency, not runtime behavior. Evaluation metrics and target thresholds must be chosen on allowed calibration/DEV data and frozen before final evaluation. Failure to prove significant superiority of C to A/B does not invalidate a methodologically sound RQ2 result.

## Required closure states

`DESIGN_COMPLETE` (baseline self-consistent); `SOURCE_MAPPED` (RG01 verified); `IMPLEMENTED_AND_TESTED` (applicable RG gates passed); `RESEARCH_VALIDATED` (RG09–RG11 passed with frozen evidence); `PRODUCT_INTEGRATED` (RG12 passed); `FINAL_ACCEPTED` (RG13 passed). These states cannot be inferred from one another without their evidence.
