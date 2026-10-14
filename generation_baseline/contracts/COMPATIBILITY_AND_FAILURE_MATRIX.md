# Cross-service and research failure semantics

| Input or failure | Required observable behavior | No-go behavior |
|---|---|---|
| Legacy JSON/NDJSON caller | Existing valid public response preserved or safely versioned | Silent breaking enum/wire rename |
| Solver receives nested `answer`/`gold` metadata | Rejected/stripped with observable validation failure and canary test | Blind solver sees gold indirectly |
| .NET/Python Unicode content hash difference | Detect mismatch and reject stale artifact or use audited canonical scheme | Accept with forged/rewritten hash |
| Worker lease expired | Old worker cannot commit; reclaimer operates under new epoch | Two writers both accept |
| Lost ACK after atomic exam write | Same ExamId returned under idempotency key | Duplicate Draft Exams |
| Retried provider error | Bounded recovery with usage record and stable operation identity | Nested unbounded retries |
| Provider usage unavailable | Confidence=UNKNOWN, cost unavailable or bounded estimate with disclosed assumptions | Fake 0 token usage |
| MiniMax-only run | No silent provider/model fallback | Unpinned model substitution |
| Research partial output | OutputAvailability tracked; evaluator may judge accessible portion | Erase failed row from denominator |
| Judge UNCERTAIN | Explicit abstention and non-PASS primary outcome | Coerce to PASS |
| Reviewer BLOCKING issue | Unresolved finding blocks proposed accept under declared policy | Ignore because deterministic format valid |
| Gold dataset requested from Generator | Deny access at data boundary | Leak labels in request or tool response |
| Research publish via alternative route | Service/AuthZ refuses | UI-only publish flag |
| Publish Draft edited later | Old published version and attempts immutable | Retroactive answer changes |
| FINAL benchmark retries | Same assignment ID, visible attempt history, preregistered retry rule | Refill success with fresh item |
| Partial provider/DB outage | Accurate FAILED/TIMED_OUT/UNKNOWN, retriable only per policy | Mock-only green treated as live proof |
