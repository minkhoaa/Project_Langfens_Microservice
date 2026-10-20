# LANGFENS — Parallel Section 2 & 3 Generation Demo Report

- **Branch**: `autonomous-generation`
- **Commit SHA**: `05ba55ec5c91910fd67c7671bc213982fe2b1d78`
- **Execution Date**: 2026-10-20
- **Execution Mode**: Concurrent V2 Execution via `POST /api/v1/autogen/reading-paper/section`
- **LLM Provider**: `minimax` (`MiniMax-Text-01`)
- **Execution Status**: **FAILED AT INITIAL PASSAGE TRANSPORT (DEADLINE EXCEEDED / UNKNOWN_OUTCOME)**

---

## 1. Executive Summary

This report documents the concurrent execution of two fresh, authorized, independent section-generation runs for Section 2 and Section 3 under commit `05ba55e`:

1. **Section 2 (`run_35100bd42184424cbef163ae623a0df5`, job `35100bd4-2184-424c-bef1-63ae623a0df5`)**:
   - Source: `PMC9640808` ("Global patterns and predictors of C:N:P in marine ecosystems", 6,664 words).
   - Target Question Formats: Q14–Q26 (6 Multiple Choice + 7 Summary Completion).
2. **Section 3 (`run_2f58e732f5004211a6471b37925dcb01`, job `2f58e732-f500-4211-a647-1b37925dcb01`)**:
   - Source: `PMC8556156` ("Next-generation ensemble projections reveal higher climate risks for marine ecosystems", 5,285 words).
   - Target Question Formats: Q27–Q40 (7 Yes/No/Not Given + 7 Short Answer).

### Key Verification & Findings

1. **Parent Wall-Time Sizing Fix Verified**:
   - The scoped fix in `services/generation-service/app/loop/runtime.py` successfully sized the parent `GENERATE` operation wall-time reservation to **180 seconds** ($3 \times 60.0\text{s}$) for both Section 2 (`loop:run_35100bd4...:art_passage_s2:GENERATE:1:2.0.0`) and Section 3 (`loop:run_2f58e732...:art_passage_s3:GENERATE:1:2.0.0`).
   - Both parent operations were granted successfully by `CheckpointService` with `WallTimeReservationSeconds = 180.0`.
   - The previous failure (`BudgetExhaustedError: Parent operation reservation exceeded (60s)`) **did not recur**.

2. **Transport Timeout & UNKNOWN_OUTCOME Status**:
   - Both tasks concurrently dispatched initial passage generation requests to MiniMax-Text-01 (`op_pass_gen_10f99021` for Section 2, `op_pass_gen_6a7734a0` for Section 3).
   - In both cases, MiniMax-Text-01 did not return a complete response before the 60.0s client deadline elapsed (`DeadlineExceededError: Overall deadline of 60.0s exceeded for operation`).
   - `generation-service` correctly notified `CheckpointService` via `POST /checkpoints/unknown-outcome`. Both operations transitioned durably to status `UNKNOWN_OUTCOME` in PostgreSQL.

3. **Execution & Token Accounting Disclosure**:
   - **Reservation Ceiling Non-Compliance**: `InitDemoRun` initialized `GENERATE_SECTION` parent operations with legacy default reservations of **380,000 tokens** per section, which did not comply with the approved 100,000-token per-section reservation ceiling. While this represents a hierarchical reservation hold rather than confirmed consumption, the reservation ceiling was exceeded at run setup.
   - **No automatic client retries** or re-runs were dispatched.
   - **No replay of failed runs**: Two completely fresh authorized runs were initialized and executed.
   - **Actual Tokens Consumed**: **UNKNOWN** (stored `TokensUsed` in database is 0 as a placeholder upon deadline timeout; no completion usage receipt was received).
   - **Conservative Provider Reservation Liability**: Retained at **14,201 tokens** (Section 2) + **14,184 tokens** (Section 3) = **28,385 tokens total**. In accordance with strict accounting rules, unreported provider usage is **not** treated as zero spending.
   - **Transport Retry Caveat**: While client-side execution was single-shot without retries, `GenerationFacade` constructs `ProviderGateway` with its default `RetryPolicy(max_attempts=3)`. Therefore, within the 60.0s transport window, physical HTTP transport attempt count is unverified.

---

## 2. Task Diagnostics & Execution Details

| Attribute | Task A — Section 2 | Task B — Section 3 | Combined / Total |
| :--- | :--- | :--- | :--- |
| **Source PMCID** | `PMC9640808` | `PMC8556156` | — |
| **Section Index** | `2` | `3` | — |
| **Target Question Formats** | Q14–Q26 (6 Multiple Choice + 7 Summary) | Q27–Q40 (7 Yes/No/Not Given + 7 Short Answer) | 27 Questions Target |
| **Job ID** | `35100bd4-2184-424c-bef1-63ae623a0df5` | `2f58e732-f500-4211-a647-1b37925dcb01` | — |
| **Run ID** | `run_35100bd42184424cbef163ae623a0df5` | `run_2f58e732f5004211a6471b37925dcb01` | — |
| **Execution Status** | `Failed` (`DeadlineExceededError`) | `Failed` (`DeadlineExceededError`) | `Failed` |
| **Duration** | `63.65s` | `63.70s` | Concurrent (~64s wall) |
| **Parent GENERATE Wall Reservation** | **180.0s** (`RESERVED`, Granted) | **180.0s** (`RESERVED`, Granted) | Verified Fix |
| **Child Provider Operation** | `op_pass_gen_10f99021` | `op_pass_gen_6a7734a0` | 2 Operations |
| **Child Operation Status** | `UNKNOWN_OUTCOME` | `UNKNOWN_OUTCOME` | Durable UNKNOWN |
| **Actual Tokens Consumed** | `UNKNOWN` (stored placeholder: 0) | `UNKNOWN` (stored placeholder: 0) | `UNKNOWN` (no receipt) |
| **Conservative Provider Liability** | **14,201 tokens** | **14,184 tokens** | **28,385 tokens** |
| **Section Parent Reservation Hold** | 380,000 tokens (legacy default) | 380,000 tokens (legacy default) | Exceeds 100k approval |
| **Passage Text Produced** | `None` (halted at initial probe) | `None` (halted at initial probe) | — |
| **Questions Generated** | `0` | `0` | **0 questions** |
| **Export File** | `reports/demo_section_2.json` | `reports/demo_section_3.json` | — |

---

## 3. Operation Ledger Breakdown (PostgreSQL Durable State)

### Section 2 (`run_35100bd42184424cbef163ae623a0df5`)

| Operation ID | Operation Type | Status | Token Reservation | Tokens Used | Wall Res. | Wall Used |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `op_run_35100bd4..._sec_2` | `GENERATE_SECTION` | `RESERVED` | 380,000 | 0 | 800.0s | 0.0s |
| `init:run_35100bd4...:sp_sec_2` | `CHECKPOINT_COMMIT` | `COMPLETED` | 0 | 0 | 10.0s | 0.1s |
| `init:run_35100bd4...:eg_sec_2` | `CHECKPOINT_COMMIT` | `COMPLETED` | 0 | 0 | 10.0s | 0.1s |
| `init:run_35100bd4...:bp_sec_2` | `CHECKPOINT_COMMIT` | `COMPLETED` | 0 | 0 | 10.0s | 0.1s |
| `loop:run_35100bd4...:art_passage_s2:GENERATE:1:2.0.0` | `GENERATE` | `RESERVED` | 40,000 | 0 | **180.0s** | 0.0s |
| `op_pass_gen_10f99021` | `PROVIDER_CALL` | `UNKNOWN_OUTCOME` | 14,201 | 0 | 60.0s | 0.0s |

### Section 3 (`run_2f58e732f5004211a6471b37925dcb01`)

| Operation ID | Operation Type | Status | Token Reservation | Tokens Used | Wall Res. | Wall Used |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `op_run_2f58e732..._sec_3` | `GENERATE_SECTION` | `RESERVED` | 380,000 | 0 | 800.0s | 0.0s |
| `init:run_2f58e732...:sp_sec_3` | `CHECKPOINT_COMMIT` | `COMPLETED` | 0 | 0 | 10.0s | 0.1s |
| `init:run_2f58e732...:eg_sec_3` | `CHECKPOINT_COMMIT` | `COMPLETED` | 0 | 0 | 10.0s | 0.1s |
| `init:run_2f58e732...:bp_sec_3` | `CHECKPOINT_COMMIT` | `COMPLETED` | 0 | 0 | 10.0s | 0.1s |
| `loop:run_2f58e732...:art_passage_s3:GENERATE:1:2.0.0` | `GENERATE` | `RESERVED` | 40,000 | 0 | **180.0s** | 0.0s |
| `op_pass_gen_6a7734a0` | `PROVIDER_CALL` | `UNKNOWN_OUTCOME` | 14,184 | 0 | 60.0s | 0.0s |

---

## 4. Deliverables

- `reports/demo_section_2.json`: Verified operation ledger, conservative reservation accounting (14,201 tokens), and failure diagnostics for Section 2.
- `reports/demo_section_3.json`: Verified operation ledger, conservative reservation accounting (14,184 tokens), and failure diagnostics for Section 3.
- `reports/parallel_section_demo_report.md`: This comprehensive evaluation report.

---
*STOPPED after both demos for manual verification. Zero further code changes or live dispatches executed.*
