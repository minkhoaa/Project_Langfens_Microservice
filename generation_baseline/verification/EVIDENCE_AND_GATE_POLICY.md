# Evidence, verification gates and acceptance protocol

Each requirement has a named observable output and at least one positive plus one meaningful negative or failure-mode check. Evidence must state: source commit/worktree identity; relevant config/provider/rubric/dataset hash; tested artifact IDs and state; command or test function with actual exit result; DB/API provider environment kind (mock/integration/live); redacted evidence reference; observed result; anomalies and gate disposition.

A `PASS` cannot be assigned using only copied historical reports, planned tests, unexecuted providers or an incomplete/fake mock for a mandatory real DB/provider check. `BLOCKED` records specific missing prerequisite and unaffected prior proof; `PARTIAL` records successful subset; `NOT_RUN` remains literal. Raw secrets, learner private data and paid provider payload must not be committed in report snapshots.

For phase acceptance: all five mandatory sprint outcomes verified under compatible source/config/contracts, parent-specific integration and negative regression criteria demonstrated and source-owned risk fully disclosed. No later phase automatically proves an earlier failed gate. Review cannot weaken a substantive test merely to make PASS.

Safety nonregression across all touched code: official auth/ACL; source license and SSRF; permitted solver/answer/gold views; version/hash/lease/fencing; immutable accepted heads; Python/.NET hash parity; idempotent final transaction; research publication denials; provider pinning/usage honesty; strict Reading 3×40 shape. RG12 optional ablation is not a mandatory gate unless explicitly included in final scope and run.
