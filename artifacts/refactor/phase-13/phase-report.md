# Phase 13 Report — API, Events, Observability và UI

## 1. Executive Summary

Phase 13 establishes the production-grade external API surfaces, authoritative outbox event streaming, observability infrastructure, privacy/redaction filters, and frontend/gateway integration for the Langfens Loop Engine V2.

All 10 work packages (P13-01 through P13-10) are implemented and verified:
- **API Surface (P13-01, P13-02):** Thin API routes in `services/generation-service/app/router.py` delegating cleanly to `GenerationFacade` in `app/facade.py`, mounting `/metrics` and `/api/metrics` in `app/main.py`, and preserving 100% G00 baseline contract parity.
- **Authoritative Event Outbox (P13-03–P13-07):** Event outbox in `services/generation-service/app/events/` and `services/exam-service/`, PostgreSQL transactional sequencing with EF Core migration `20261008120000_AddReadingPaperEventOutboxSequence`, unique constraint on `(RunId, Sequence)`, DB-backed cursor replay, disconnect reconciliation, bounded ring buffer backpressure (1000 items), and isolated background heartbeats (5s interval).
- **Observability & Privacy (P13-08, P13-09):** Telemetry, metrics, W3C distributed tracing, token accounting (reported vs estimated vs unknown), pricing snapshot, secret/thinking redaction canaries, Prometheus/Grafana dashboard configurations.
- **Gateway & UI Integration (P13-10):** Verified workflow: Job creation in `Pending` / `NeedsSources`, status polling, `NeedsSources` escalation, `Replace Sources` resetting checkpoints, `Retry` on failed jobs, manual exam CRUD, `ExamStatus.Draft` shielding from public view (404 NotFound), and manual `Publish` (200 OK).

---

## 2. Verification & Gate Summary

- **Deterministic Tests:** 73 Python tests + 17 .NET tests pass cleanly. In active workspace `langfens-fe-app`, 177 unit tests across 11 pure TypeScript test suites pass.
- **Validation Matrix Provenance:** Fully resolved by recovering authentic `00-master-plan.md` (SHA-256 `44dbfcd50f0bee0c4ff2701ab2f94e6d0c2b308c563adc9d35e1d02643379ebf`) and authentic `01-validation-matrix.md` (SHA-256 `97710cfff1bcb7f0e7ccf04ee551e3781d2bf8f4fc7b98ed10e27d4940396cfe`). `test_validation_matrix_provenance.py` passes 3/3 tests.
- **Live Browser E2E:** `scripts/refactor/run_browser_e2e.py` executed Playwright Chromium against `http://localhost:3000` with direct PostgreSQL state inspection, creating Job `16895531-8a45-4c1c-9334-edaf59f3b54f`, executing full live MiniMax generation across 3 passages and 40 questions to terminal Completed state, generating Exam `d4d18cbb-e8a8-4c6a-82d5-bfc73f193321` (Slug: `reading-168955318a454c1c9334edaf59f3b54f`), performing question feedback edit, validating draft shielding (404), and publishing via browser UI to public HTTP 200 OK.
- **Gate Status:** **`PASS`**.
- **Phase 14 Readiness:** **`READY_FOR_PHASE_14`**.
