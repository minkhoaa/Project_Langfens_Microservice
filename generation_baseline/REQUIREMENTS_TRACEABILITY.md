# Requirement → owner → proof index

| Requirement | Required deliverable | Gate(s) | Proof class |
|---|---|---|---|
| RQ2-01 | 4 logical roles and authority isolation | RG02 | trace enums + forbidden commit tests |
| RQ2-02 | bounded evidence-grounded Reading | RG05, RG13 | source and solver evidence + full V2 regression |
| RQ2-03 | grounded Grammar with independently verified reference answers | RG06 | rule and question-level gold fixtures |
| RQ2-04 | scoped bounded repair invalidates stale evaluations | RG02, RG06 | artifact hash and repair negative tests |
| RQ2-05 | identical paired A/B/C tasks & same independent scoring | RG07, RG10 | frozen assignment/scorer hashes |
| RQ2-06 | QGEval-inspired independent quality rubric | RG03 | scored dimension and hard-error fixtures |
| RQ2-07 | calibrated evaluator with distinct judge holdout | RG04 | FAR, FRR, abstention, coverage and counts |
| RQ2-08 | 25–40 Reading and 25–40 Grammar FINAL tasks | RG09 | family-disjoint frozen dataset |
| RQ2-09 | failure-inclusive quality, cost and timing analysis | RG10, RG11 | row counts, usage, paired statistics |
| RQ2-10 | blind human review subset | RG09, RG10 | anonymized records/adjudicated labels |
| RQ2-11 | reproduced report from raw sealed campaign evidence | RG11, RG13 | deterministic analytics + difference report |
| PROD-01 | manual versioned publish, no research promotion | RG12 | AuthZ negative + immutable snapshot |
| PROD-02 | student grading and owned learning history | RG12 | pinned attempt and tenant tests |
| SEC-01 | SolverView/gold separation | RG02, RG03 | nested leakage canary |
| SEC-02 | source license, eligibility, tenant and SSRF | RG01, RG05, RG06 | invalid source denial |
| DUR-01 | authoritative hash/closure/fencing/atomicity | RG02, RG08 | real DB fault-injection |
| OPS-01 | unexecuted production canary/rollback truthfully reported | RG13 | boundary summary, NOT_RUN evidence |
| RQ1-01 | Speaking research remains separate | RG00, RG13 | thesis alignment statement |

Each phase and sprint has a prompt under `prompts/` and an independent acceptance check. Any unknown concrete source code names are resolved by RG01, not guessed here.
