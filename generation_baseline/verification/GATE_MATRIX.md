# Acceptance gate matrix — TARGET SPECIFICATION, no code verified

Gate truth comes from real tests and evidence, never a planned checklist. Optional product ablation is not a mandatory prerequisite; RG13 remains dependent on the required learner integration.

| Phase | Required sprints | Decisive gate criterion | Actual status |
|---|---:|---|---|
| RG00 | 5 | Requirement conflicts are resolved explicitly or marked BLOCKED; RQ1 remains separate. | PASS |
| RG01 | 5 | No uninspected capability is asserted implemented and no historical cleanup is authorized. | TARGET_SPEC / NOT_RUN |
| RG02 | 5 | Negative authorization/leakage, stale-hash and compatibility tests prove invariants. | TARGET_SPEC / NOT_RUN |
| RG03 | 5 | Internal generation PASS or configuration labels cannot contaminate research verdict. | TARGET_SPEC / NOT_RUN |
| RG04 | 5 | No holdout reuse for tuning; coverage/FAR/FRR and error counts are transparent. | TARGET_SPEC / NOT_RUN |
| RG05 | 5 | Full 3-section/40-question production regression and integrity remain intact. | TARGET_SPEC / NOT_RUN |
| RG06 | 5 | Rule provenance is not misrepresented as independently verified question gold. | TARGET_SPEC / NOT_RUN |
| RG07 | 5 | Every assigned attempt including failures and partial results is reconciled. | TARGET_SPEC / NOT_RUN |
| RG08 | 5 | Final sealed benchmark is never used to debug or optimize the pipeline. | TARGET_SPEC / NOT_RUN |
| RG09 | 5 | Family-disjoint datasets; evaluator, endpoints, analysis, exclusions and resource policies frozen. | TARGET_SPEC / NOT_RUN |
| RG10 | 5 | Counts match frozen assignments exactly and retries/failures remain visible. | TARGET_SPEC / NOT_RUN |
| RG11 | 5 | No cherry-picking, pseudo-replication, or interpreting non-significance as equivalence. | TARGET_SPEC / NOT_RUN |
| RG12 | 5 | Research artifacts cannot publish; all grading pins the published snapshot; ablation is optional. | TARGET_SPEC / NOT_RUN |
| RG13 | 5 | Rely only on real gate evidence; do not claim RQ1 or operational canary/rollback completed. | TARGET_SPEC / NOT_RUN |

Total **14** phase gates and **70** mandatory sprints. `verification/TEST_CATALOG.json` enumerates **280 planned test cases** (positive, negative, edge, regression ×70). All real execution test statuses start `NOT_RUN`. Offline verification verifies only structure/paths/schema/test definitions.
