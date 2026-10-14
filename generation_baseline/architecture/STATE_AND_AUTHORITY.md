# State machines and decision authority

## Distinct dimensions

- ExecutionStatus: `PENDING`, `RUNNING`, `COMPLETED`, `FAILED_VALIDATION`, `FAILED_RUNTIME`, `TIMED_OUT`, `CANCELLED` (persisted legacy names can differ; adapter must preserve semantics).
- OutputAvailability: `NONE`, `RAW_ONLY`, `PARSEABLE`, `NORMALIZED`; independent of execution status.
- EvaluationVerdict: `PASS`, `FAIL`, `UNCERTAIN`, or `NOT_RUN` (the last is an execution status for a check, never a false PASS).
- EvidenceStatus: `TARGET_SPEC`, `UNKNOWN`, `NOT_RUN`, `VERIFIED`, `PARTIAL`, `BLOCKED`, `FAILED`.

## Proposals vs commits

Reviewer issue (INFO/WARNING/BLOCKING) → Validator constraints/evidence and solver finding → Coordinator policy decision (`CONTINUE`, `REPAIR`, `ABORT`, `PROPOSE_COMMIT`) → .NET authoritative transition after hash/lease/policy/dependency checks. Reviewer may flag BLOCKING; it may not write accepted state. Validator cannot directly commit. Invalidated/stale eval cannot justify commit.

## Durable invariants

- Lease token/epoch and compare-and-swap version checked at commit.
- Every accepted head points to content-addressed immutable artifacts with valid source and dependency closure.
- Repair changes authoritative artifacts and invalidates all affected evaluations; in-memory edits alone are never accepted.
- Transaction to Draft persists complete exam graph or none; retry after lost ACK resolves same ExamId.
- Research policy may select different *required semantic checks*, never exempt underlying hash, lease, auth or dependency constraints.
- No research artifact may enter production PublishedSnapshot via any route, including bulk import or alternate endpoint.
