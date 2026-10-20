# LANGFENS — Parallel Section 2 & 3 Generation Demo Report

- **Branch**: `autonomous-generation`
- **Date**: 2026-10-20
- **Execution Mode**: Concurrent V2 Execution via `POST /api/v1/autogen/reading-paper/section`
- **LLM Provider**: `minimax` (`MiniMax-Text-01`)
- **Status**: **FAILED AT PASSAGE LOOP (WALL-TIME RESERVATION EXCEEDED)**

---

## 1. Executive Summary

This report documents the concurrent execution of independent section-generation tasks for Section 2 and Section 3 under the existing V2 orchestration pipeline:

1. **Task A (Section 2)**: Source `PMC9640808`, index 2, target formats Q14–Q26 (6 MULTIPLE_CHOICE_SINGLE + 7 SUMMARY_COMPLETION).
2. **Task B (Section 3)**: Source `PMC8556156`, index 3, target formats Q27–Q40 (7 YES_NO_NOT_GIVEN + 7 SHORT_ANSWER).

### Key Takeaways
- **Durable Run Initialization Resolved**: Reused existing `ReadingPaperJob`, `ReadingPaperRun`, `ReadingPaperBudgetAllocation`, and `CheckpointService.SetBudgetAllocationsAsync` in `exam-service` via `POST /api/admin/reading-paper/demo-run`. This completely resolved the previous `HTTP 404: Run not found` blocker, establishing genuine authorized leases and checkpoint heads without fabricating credentials.
- **Real MiniMax Dispatch & Spend**: Both tasks dispatched real calls to MiniMax-Text-01 concurrently. Task A completed passage generation draft consuming **8,285 tokens** (32.6s). Task B completed passage generation draft consuming **8,750 tokens** (46.4s).
- **Terminal Stop**: Both tasks terminated cleanly on `BudgetExhaustedError` when the child operation reservation exceeded the parent `GENERATE` operation's 60s wall-time reservation.
- **Strict Compliance & Attempt Audit**: Per instructions, **zero caps were modified** and **zero fallback content was fabricated**. No in-engine automatic retries occurred. An initial client probe (runs `run_8fd72478` and `run_734c79a5`) was interrupted by a 30s tool-call timeout during MiniMax streaming, leaving orphaned RESERVED operations with unreconciled upstream spend; this was followed by a fresh execution under a 600s process deadline where MiniMax calls finished and generated the verified token receipts (8,285 and 8,750 tokens).

---

## 2. Task Diagnostics & Execution Details

| Attribute | Task A — Section 2 | Task B — Section 3 |
| :--- | :--- | :--- |
| **Source PMCID** | `PMC9640808` | `PMC8556156` |
| **Source Title** | Global patterns and predictors of C:N:P in marine ecosystems | Next-generation ensemble projections reveal higher climate risks |
| **Section Index** | `2` | `3` |
| **Target Question Formats** | Q14–Q26 (6 Multiple Choice + 7 Summary) | Q27–Q40 (7 Yes/No/Not Given + 7 Short Answer) |
| **Job ID** | `44414bc2-4005-4875-a654-a5078dea6921` | `9a839b83-2fc3-448d-a76e-42c530a881cc` |
| **Run ID** | `run_44414bc240054875a654a5078dea6921` | `run_9a839b832fc3448da76e42c530a881cc` |
| **Execution Status** | `Failed` (`502 Bad Gateway`) | `Failed` (`502 Bad Gateway`) |
| **Duration** | `37.06s` | `50.51s` |
| **Actual Tokens Used** | **8,285 tokens** (1 MiniMax call) | **8,750 tokens** (1 MiniMax call) |
| **Prompt Tokens** | `7,115 tokens` | `7,453 tokens` |
| **Completion Tokens** | `1,170 tokens` | `1,297 tokens` |
| **Questions Generated** | `0` (Halted before question generation) | `0` (Halted before question generation) |
| **Error Message** | `Parent operation reservation exceeded: parent 'loop:run_...:art_passage_s2:GENERATE:1:2.0.0' wall-time reservation (60s) would be exceeded by child reservation 59.999s (current child allocated: 32.6s)` | `Parent operation reservation exceeded: parent 'loop:run_...:art_passage_s3:GENERATE:1:2.0.0' wall-time reservation (60s) would be exceeded by child reservation 59.999s (current child allocated: 46.4s)` |
| **Export File** | `reports/demo_section_2.json` | `reports/demo_section_3.json` |

---

## 3. Root Cause Analysis

### 1. Successful Authorization & Upstream Bootstrapping
`exam-service`'s new `InitDemoRun` endpoint correctly:
1. Validated sources and set section metadata.
2. Created a running `ReadingPaperJob` and `ReadingPaperRun` with finite budget caps.
3. Created default budget allocations (`section_{index}`, `art_passage_s{index}`, `questions_section_{index}`) using `CheckpointService.SetBudgetAllocationsAsync`.
4. Granted the parent `GENERATE_SECTION` operation via `CheckpointService.GrantOperationAsync`.

When `POST /api/v1/autogen/reading-paper/section` was called, upstream artifacts (`sp_sec_{index}`, `eg_sec_{index}`, `bp_sec_{index}`) were durably committed at version 1 without any 404 or 409 fencing violations.

### 2. Mechanism of the Wall-Time Cap Halt
`generation-service`'s `BoundedLoopRuntime` enforces hierarchical time reservations under parent operations.
- The parent operation `loop:...:art_passage_s{N}:GENERATE:1:2.0.0` was granted with a default `WallTimeReservationSeconds` of 60.0s.
- The initial MiniMax passage generation provider call consumed:
  - **Section 2**: 32.62 seconds.
  - **Section 3**: 46.40 seconds.
- The subsequent evaluation step attempted to reserve a 60-second child window.
- `CheckpointService.GrantOperationAsync` verified:
  `allocatedWallTime + request.WallTimeReservationSeconds > parentOperation.WallTimeReservationSeconds`
  - Section 2: `32.6s + 60.0s = 92.6s > 60.0s` -> REJECTED (BudgetExhaustedError).
  - Section 3: `46.4s + 60.0s = 106.4s > 60.0s` -> REJECTED (BudgetExhaustedError).
- Because instruction STRICT forbids modifying caps or optimizing tokens, the engine failed closed honestly rather than attempting arbitrary retries or cap increases.

---

## 4. Deliverables

- `reports/demo_section_2.json`: Complete failure diagnostic, token breakdown (8,285 tokens), and operation ledger for Section 2.
- `reports/demo_section_3.json`: Complete failure diagnostic, token breakdown (8,750 tokens), and operation ledger for Section 3.
- `reports/parallel_section_demo_report.md`: This comprehensive evaluation report.

---
*STOPPED after both demos for manual academic verification.*
