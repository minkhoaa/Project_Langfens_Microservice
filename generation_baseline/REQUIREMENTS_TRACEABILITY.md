# Requirements traceability matrix — proposal coverage and design review

This matrix traces each proposal section and nonnegotiable requirement to its concrete deliverable, accountable logical owner, verification gate, research metric/proof class, and evidence status.

## Traceability matrix

| Proposal section | Req ID | Required deliverable / Output | Accountable logical owner | Gate(s) | Metric / Proof class | Evidence class & Freeze status |
|---|---|---|---|---|---|---|
| 2.2.e, 4.e | `RQ2-01` | 4 logical roles (Coordinator, Generator, Reviewer, Validator) and authority isolation | Architecture / Orchestrator | RG02 | Execution traces, forbidden commit tests | Approved requirement (`FROZEN`) |
| 2.2.e, 3.b | `RQ2-02` | Bounded evidence-grounded Reading (1 passage + 1–2 groups) | Generation Service / Reading Pipeline | RG05, RG13 | Source grounding, solver evidence, strict V2 nonregression | Approved requirement (`FROZEN`) |
| 2.2.e, 3.b | `RQ2-03` | Grounded Grammar with independently verified reference answers | Grammar Service / Retrieval Port | RG06 | Rule pack provenance, question-level gold fixtures | Approved requirement (`FROZEN`) |
| 2.2.e, 4.e | `RQ2-04` | Scoped bounded repair loops invalidating stale evaluations | Orchestrator / Closure Engine | RG02, RG06 | Content hash change, repair negative tests | Approved requirement (`FROZEN`) |
| 4.g | `RQ2-05` | Identical paired A/B/C tasks evaluated under same independent rubric | Experiment Lead | RG07, RG10 | Frozen assignment manifest, scorer hash consistency | Approved requirement (`FROZEN`) |
| 4.g | `RQ2-06` | QGEval-inspired independent quality rubric (relevance, fluency, answerability) | Evaluation Lead | RG03 | Scored dimensions, hard task validity checks | Approved requirement (`FROZEN`) |
| 4.g | `RQ2-07` | Calibrated evaluator with disjoint source-family holdout | Evaluation Lead | RG04 | FAR, FRR, abstention rate, decided coverage | Approved requirement (`FROZEN`) |
| 4.g | `RQ2-08` | 25–40 Reading and 25–40 Grammar benchmark tasks | Dataset Custodian | RG09 | Frozen benchmark dataset, source-family disjointness | Approved requirement (`FROZEN`) |
| 4.g | `RQ2-09` | Failure-inclusive quality, cost, and latency analysis across all slots | Analytics Lead | RG10, RG11 | All assigned denominators, P50/P95 latency, priced costs | Approved requirement (`FROZEN`) |
| 4.g | `RQ2-10` | Blinded human review subset for external validation | Research Gold Custodian | RG09, RG10 | Anonymized records, inter-annotator agreement | Approved requirement (`FROZEN`) |
| 4.g | `RQ2-11` | Fully reproducible report generated from sealed raw evidence | Analytics Lead | RG11, RG13 | Deterministic analytics scripts, difference report | Approved requirement (`FROZEN`) |
| 2.2.f | `PROD-01` | Manual versioned editorial publication; research promotion forbidden | Admin Gateway / Publish Guard | RG12 | AuthZ negative tests, immutable snapshot commit | Approved requirement (`FROZEN`) |
| 2.2.f | `PROD-02` | Student attempt delivery, grading, and owned learning history | Attempt Service / Student Gateway | RG12 | Pinned snapshot attempt, tenant ACL isolation | Approved requirement (`FROZEN`) |
| 2.2.e, 4.e | `SEC-01` | SolverView / GoldReferenceView isolation without answer leakage | View Projection Layer | RG02, RG03 | Leakage canary tests, JSON schema validation | Approved requirement (`FROZEN`) |
| 2.2.e | `SEC-02` | Source licensing, tenant boundary, and SSRF prevention | Ingestion Service / Security Guard | RG01, RG05, RG06 | Invalid source rejection, SSRF network block | Approved requirement (`FROZEN`) |
| 2.2.e, 4.e | `DUR-01` | Authoritative hash/closure, fencing, and EF transaction atomicity | .NET Storage Authority | RG02, RG08 | Real DB fault-injection, CAS concurrency test | Approved requirement (`FROZEN`) |
| (Governance) | `OPS-01` | Truthful reporting of unexecuted production canary and rollback | DevOps / Release Lead | RG13 | Boundary summary, truthful NOT_RUN evidence | Approved requirement (`FROZEN`) |
| Thesis | `RQ1-01` | Speaking / acoustic phoneme evaluation remains strictly separate | Research Owner | RG00, RG13 | Thesis boundary statement, prohibition of false claims | Approved requirement (`FROZEN`) |

## Proposal section coverage and review disposition

1. **Summary-derived and reconciled proposal sections:** Sections 2.2.e, 2.2.f, 3.b, 4.e, and 4.g are fully mapped to requirements `RQ2-01` through `RQ2-11`, `PROD-01`, `PROD-02`, `SEC-01`, `SEC-02`, and `DUR-01`.
2. **Section 3.b verified mapping:** Section 3.b explicitly defines the two representative Multi-Agent content groups: (1) Passage-grounded Reading questions (`RQ2-02`), and (2) Grammar exercises with reference answers (`RQ2-03`). This is fully consistent with Sections 2.2.e, 2.3 (RQ2), 4.e, and 4.g. The original submitted KLTN proposal document is unavailable in the repository; original-source verification remains `NOT_RUN`, while this mapping is recorded as user-confirmed.
3. **Requirement conflict analysis:** All 18 requirements have defined logical owners and assigned verification gates. With Section 3.b reconciled, requirement conflicts are zero (0). Decisive acceptance criteria are satisfied without blockers.
4. **Ownership completeness:** Every must-have requirement has an accountable logical owner layer; missing ownership is zero. Concrete source code bindings will be established in RG01 source audit.
