# ADR-001: Authoritative Persistence Ownership and Service Boundary

**Status:** Accepted  
**Date:** 2026-09-30  
**Phase:** Phase 01  
**Deciders:** Langfens Engineering Team  

---

## 1. Context

In the Langfens Reading Paper generation architecture, two backend services collaborate:
1. `services/exam-service` (.NET 10, ASP.NET Core Minimal APIs, EF Core, owning PostgreSQL `exam-db`).
2. `services/generation-service` (Python 3.12+, FastAPI, executing the Loop Engine V2 generation pipeline).

In distributed architectures with multi-language runtimes, sharing a single relational database connection string or allowing multiple services to mutate tables concurrently introduces schema divergence, migration locks, split-brain race conditions, and uncoordinated rollback hazards.

## 2. Decision

We establish a strict single-authoritative-store model:
1. **`exam-service` is the sole authoritative owner of all persistent exam data**:
   - `exam-service` owns the PostgreSQL `exam-db` database schema and all EF Core migrations.
   - `exam-service` owns durable job state (`reading_paper_jobs`), worker leases, distributed locking, checkpoint persistence, audit logs, and final exam entities (`exams`, `exam_sections`, `exam_question_groups`, `exam_questions`, `exam_question_options`).
2. **`generation-service` is an ephemeral computational engine**:
   - `generation-service` does **not** have direct database credentials or network access to `exam-db`.
   - `generation-service` communicates all state changes, checkpoint saves, operation grants, and run progress exclusively via an authenticated internal HTTP API exposed by `exam-service` (`/api/internal/reading-paper/checkpoints`).
3. **Authentication & Authorization**:
   - Internal checkpoint and coordination endpoints require shared service-to-service authentication (e.g. `X-Internal-Service-Key` or mutual TLS / internal JWT).

## 3. Consequences

### Positive:
- **Zero Schema Divergence:** Database migrations remain centralized in EF Core without needing Alembic/Python database migrations in `generation-service`.
- **Zero Dual-Write Races:** Only one service writes to PostgreSQL, eliminating distributed transaction coordinator requirements.
- **Clean Blast Radius:** A failure or crash in `generation-service` cannot leave orphan transactions or locks in PostgreSQL.
- **Rollback Safety:** Upgrading or reverting `generation-service` images requires no database schema rollbacks.

### Negative / Trade-offs:
- State checkpointing incurs a lightweight HTTP round-trip between `generation-service` and `exam-service`.
- Both services must maintain synchronized DTO contracts (established in `app/contracts/` and `Features/ReadingPaper/Contracts/`).
