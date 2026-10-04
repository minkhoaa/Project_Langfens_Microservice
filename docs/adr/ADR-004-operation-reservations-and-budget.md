# ADR-004: Bounded Operation Reservations, Resource Budgets, and Event Streaming

**Status:** Accepted  
**Date:** 2026-09-30  
**Phase:** Phase 01  
**Deciders:** Langfens Engineering Team  

---

## 1. Context

Large Language Model (LLM) operations are characterized by:
1. Significant latency (10s – 60s per call).
2. Financial and quota costs per token.
3. Unpredictable transient failures (HTTP 429 rate limits, HTTP 503 service overload, timeouts).

In naive feedback loops, failed evaluations can cause infinite repair loops where the system repeatedly calls the LLM, burning entire API quotas and causing unbounded latency. Furthermore, when services crash during an LLM invocation, distributed state must remain reconcilable without duplicate charges or lost telemetry.

## 2. Decision

We establish three core operational mechanisms:

### 2.1 Bounded Operation Grants
- Before invoking any LLM provider, the runtime must acquire an `OperationGrant`.
- An `OperationGrant` specifies:
  - `grantId`: Unique identifier for the operation attempt.
  - `maxTokens`: Hard upper bound on token consumption.
  - `timeoutSeconds`: Hard execution deadline (e.g. 60.0s).
- An operation cannot proceed without an active `OperationGrant`. Once the operation completes or fails, the grant is marked `CONSUMED` or `RELEASED`.

### 2.2 Hard Budget Caps per Generation Run
- Every `GenerationRun` contains a `BudgetReservation` containing hard caps:
  - `maxCalls`: Maximum number of provider requests (e.g. 15 calls across all 3 sections).
  - `maxTokens`: Maximum cumulative tokens allowed.
  - `costCapUsd`: Optional monetary cap.
- Before issuing any new grant, the engine checks `budget.is_exhausted()`.
- If budget caps are breached, the engine halts further generation, issues `IssueCode.BUDGET_EXHAUSTED`, and transitions the run to `FAIL`. It never silently continues.

### 2.3 Event Delivery Semantics
- Domain events (`DomainEvent`) are streamed via NDJSON or recorded in an Outbox table.
- **Delivery Model: At-least-once.** Due to network retries, duplicate events may arrive.
- Every event includes an `idempotencyKey` and `epoch`.
- Consumers (such as the telemetry collector or UI progress listener) must be idempotent based on `idempotencyKey`.
- **LLM invocations are never assumed to be exactly-once.** If a request times out, the engine records an `ERROR` evaluation result and relies on the state machine to decide whether to retry under a new operation grant.

## 3. Consequences

### Positive:
- **Financial & Operational Safety:** Hard caps guarantee that a bug or adversarial prompt cannot cause an infinite billing loop.
- **Predictable Latency:** Timeouts and bounds ensure jobs fail cleanly rather than hanging indefinitely.
- **Auditability:** Every token spent is accountable through an operation grant and domain event log.

### Negative / Trade-offs:
- Strict budget caps mean runs that encounter multiple recoverable defects might fail if they exceed the allocated attempts, requiring administrator retry.
