# Langfens — Sprint 6 Handoff & Closure

> **Audience**: Fresh session, zero context. Both repositories on branch `refactor/sync-dotest-admin-renderer`.
> **Scope**: Platform-Wide 1-Indexed Synchronization, Typecheck Unblocking & Technical Debt Resolution.
> **Date**: 2026-09-14
> **Review Verdict**: APPROVED & FULLY VERIFIED (see `docs/sprint6/REVIEW.md`).

---

## §0 — State Summary

- **Repository Baseline**:
  - Backend: `/home/khoa/Projects/langfens/Project_Langfens_Microservice` (branch `refactor/sync-dotest-admin-renderer`).
  - Frontend: `/home/khoa/Projects/langfens/langfens-fe-app` (branch `refactor/sync-dotest-admin-renderer`).
- **Sprint 6 Status**: **OFFICIALLY CLOSED & VERIFIED** as of 2026-09-14.
- **Key Deliverables Shipped**:
  1. Complete removal of `Idx = 0` across all PostgreSQL tables (`exam_sections`, `exam_questions`, `exam_options`) via idempotent script `scripts/migrate_idx_to_1_indexed.py`.
  2. Complete 1-indexed refactor across all backend seeders (`ReadingSeeder.cs`, `ListeningSeeder.cs`, `GeneratedReadingSeeder.cs`).
  3. Admin UI synchronization: `MatchPairsEditor.tsx`, `OptionsEditor.tsx`, `QuestionEditor.tsx`, and `questionSchemas.ts`.
  4. Frontend typecheck unblocked: added `"typecheck": "tsc --noEmit"` to `package.json`, fixed Axios/NextResponse mismatch in speaking roleplay route handlers, restored missing `DeckCard.tsx`.
  5. Added runtime ordinal invariant test suite `ordinalInvariant.test.ts`.
- **Test Invariants**:
  - Backend tests: **73 / 73 passed** (`services/attempt-service.Tests`).
  - Frontend tests: **25 / 25 passed** across 6 test suites (`npx vitest run`).
  - Frontend typecheck: **0 errors** (`npm run typecheck`).
  - Solution build: **0 errors** (`dotnet build Project_Langfens_Microservice.sln`).

---

## §1 — Repository State Snapshot

| Repo | Path | Branch | HEAD Commit | Notes |
|---|---|---|---|---|
| BE (.NET 10 + Python AI) | `/home/khoa/Projects/langfens/Project_Langfens_Microservice` | `refactor/sync-dotest-admin-renderer` | `e59a0f0` | Clean build, 0 errors |
| FE (Next.js 16) | `/home/khoa/Projects/langfens/langfens-fe-app` | `refactor/sync-dotest-admin-renderer` | `d6001b6` | Typecheck clean, 25 tests passing |

---

## §2 — Sprint 6 Delivery Breakdown

### Phase 1: Database Migration Script
- **Commit**: BE `f9c8cdf`
- **Artifact**: `scripts/migrate_idx_to_1_indexed.py`
- **Outcome**: Safely shifts sections, questions, and options where `MIN(Idx) = 0` to `Idx + 1`. Fully idempotent on re-run.

### Phase 2: Backend Seeders
- **Commit**: BE `ef66896`
- **Files**:
  - `services/exam-service/Data/ReadingSeeder.cs`
  - `services/exam-service/Data/ListeningSeeder.cs`
  - `services/exam-service/Data/GeneratedReadingSeeder.cs`
- **Outcome**: All sections, questions, and options start at index 1. Preserved deterministic GUID generation (`SeederHelpers.CreateDeterministicGuid`).

### Phase 3: Admin Schemas & Editors
- **Commit**: FE `2786d12`
- **Files**:
  - `src/app/admin/exams/[id]/_components/editors/MatchPairsEditor.tsx`
  - `src/app/admin/_lib/questionSchemas.ts`
- **Outcome**: Target indices default to 1; schemas document `Idx >= 1` across all question variants.

### Phase 4 & 4.1: Frontend Runtime, Type Safety & Invariant Tests
- **Commits**: FE `b33407c` and `d6001b6`
- **Files**:
  - `package.json`: added `"typecheck": "tsc --noEmit"`
  - `src/types/question.type.ts`: documented 1-based question ordinal invariant
  - `src/app/api/speaking/roleplay/scenarios/route.ts`: fixed Axios `response.data` return
  - `src/app/api/speaking/roleplay/scenarios/[slug]/chat/route.ts`: fixed Axios `response.data` return
  - `src/app/flashcards/explore/components/DeckCard.tsx`: restored component and fixed type signatures
  - `src/lib/__tests__/ordinalInvariant.test.ts`: 3 unit tests verifying monotonic 1..N question & option indexing.

---

## §3 — Scoreboard & Closure Acceptance

| Phase | Task | Deliverable | Repository | Commit SHA | Status |
|---|---|---|---|---|---|
| Phase 1 | DB Migration | `scripts/migrate_idx_to_1_indexed.py` | BE | `f9c8cdf` | SHIPPED |
| Phase 2 | Seeders | 1-indexed seeder rewrite | BE | `ef66896` | SHIPPED |
| Phase 3 | Admin Editors | `MatchPairsEditor` & schema doc | FE | `2786d12` | SHIPPED |
| Phase 4 | Runtime Doc | `question.type.ts` comments | FE | `b33407c` | SHIPPED |
| Phase 4.1 | Typecheck & Test | `typecheck` script + TS fixes + `ordinalInvariant.test.ts` | FE | `d6001b6` | SHIPPED |
| Phase 5 | Review & Handoff | `docs/sprint6/REVIEW.md` + `HANDOFF_SPRINT6.md` | BE | Current | SHIPPED |

---

## §4 — Verification Commands

```bash
# 1. Backend tests (73 / 73 passed)
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj --no-build

# 2. Solution build (0 errors)
dotnet build Project_Langfens_Microservice.sln

# 3. Frontend typecheck (0 errors)
cd /home/khoa/Projects/langfens/langfens-fe-app
npm run typecheck

# 4. Frontend unit tests (25 / 25 passed across 6 test suites)
npm run test
```

---

## §5 — Next Steps (Sprint 7 Kickoff & Mainline Integration)

1. **Remote Push**: Push local commits on branch `refactor/sync-dotest-admin-renderer` to remote tracking branches on both BE and FE.
2. **Pull Request / Merge to Master**: Merge `refactor/sync-dotest-admin-renderer` into `master` now that Sprints 3 through 6 are fully unified, verified, and passing all tests.
3. **Phase 2 AI Tutor Continuation**:
   - M1 Writing Comparative: Connect frontend `SentenceComparisonTable` with AI service `/api/v1/writing/compare`.
   - M2 Speaking Roleplay: Connect voice input pipeline (Whisper STT) and multi-turn scenario chat.
   - M3 Grammar Explainer: Implement `GrammarExplainerCard` cross-module linking from Writing.
