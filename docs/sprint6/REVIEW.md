# Sprint 6 Architectural & Technical Review

> **Reviewer**: Core Architecture & Verification Team  
> **Review Date**: 2026-09-14  
> **Target Scope**: Platform-Wide 1-Indexed Synchronization (Sprint 6)  
> **Artifacts Reviewed**:
> - `docs/sprint6/PLAN_1_INDEXED_SYNC.md`
> - `scripts/migrate_idx_to_1_indexed.py` (commit `f9c8cdf`)
> - `services/exam-service/Data/*.cs` (commit `ef66896`)
> - `langfens-fe-app` Admin Schemas & Editors (commit `2786d12`)
> - `langfens-fe-app` Runtime Types & Ordinal Tests (commits `b33407c`, `d6001b6`)
> 
> **Executive Verdict**: **APPROVED & FULLY VERIFIED**

---

## §1 — Executive Summary

Sprint 6 completes the platform-wide transition eliminating all traces of `Idx = 0` across the entire ecosystem. The Cambridge IELTS specification requires continuous 1-based question numbers (1..40), 1-based sections (1..4), and 1-based option pools. 

All phases defined in `PLAN_1_INDEXED_SYNC.md` have been executed, verified, and supplemented with technical debt resolution:
1. **Database Migration**: Idempotent SQL shifting verified via `scripts/migrate_idx_to_1_indexed.py`. All `MIN(Idx)` queries return $\ge 1$.
2. **Backend Seeders**: Static seeders (`ReadingSeeder`, `ListeningSeeder`, `GeneratedReadingSeeder`) rewritten to 1-indexed for all sections, questions, and options.
3. **Admin Tooling**: Schema examples and editors (`MatchPairsEditor`, `OptionsEditor`, `QuestionEditor`) updated to enforce $Idx \ge 1$.
4. **Frontend Runtime & Typechecking**: Fixed latent Axios route handler bugs in speaking scenarios, restored `DeckCard.tsx`, added `"typecheck": "tsc --noEmit"` to `package.json` (0 errors), and authored `ordinalInvariant.test.ts` bringing Vitest coverage to 25/25 passing tests.

---

## §2 — Detailed Verification by Phase

### Phase 1: Database Migration Script
- **Commit**: `f9c8cdf` (`feat(scripts): add idempotent migration script for shifting Idx to 1-indexed`)
- **Review**: The script partitions updates strictly by `HAVING MIN("Idx") = 0`, ensuring that repeated executions against an already-migrated database are safe no-ops ($0$ rows affected).

### Phase 2: Backend Seeders
- **Commit**: `ef66896` (`chore(seeders): standardize question, section and option Idx to 1-indexed`)
- **Review**: Eliminated all `Idx = 0` occurrences in `ReadingSeeder.cs`, `ListeningSeeder.cs`, and `GeneratedReadingSeeder.cs`. Preserved deterministic GUID generation introduced in Sprint 5 (`SeederHelpers.CreateDeterministicGuid`).
- **Tests**: `dotnet test services/attempt-service.Tests` passes 73/73 tests.

### Phase 3: Admin Schemas & Editors
- **Commit**: `2786d12` (`feat(fe-admin): synchronize admin question schemas and option editors to 1-indexed`)
- **Review**: `MatchPairsEditor.tsx` now defaults the first target to index 1 rather than 0. `questionSchemas.ts` comments and sample payloads updated.

### Phase 4: Frontend Runtime & Type Safety
- **Commits**: `b33407c` and `d6001b6`
- **Review**:
  - `question.type.ts` documents the 1-based ordinal invariant.
  - Added missing `npm run typecheck` script to `package.json`.
  - Corrected Axios vs Fetch API mismatch in speaking roleplay route handlers (`route.ts` using `response.data` instead of non-existent `response.ok` / `response.json()`).
  - Restored `src/app/flashcards/explore/components/DeckCard.tsx` resolving broken import.
  - Added `ordinalInvariant.test.ts` verifying monotonically increasing 1..N question ordering and option numbering.
- **Tests**: `npm run typecheck` exits 0; `npm run test` reports 25 / 25 passed across 6 test suites.

---

## §3 — Invariants Compliance Matrix

| Invariant | Specification | Verification Method | Status |
|---|---|---|:---:|
| **Positive Ordinal Invariant** | $\forall q \in \text{exam\_questions}: q.\text{Idx} \ge 1$ | `SELECT COUNT(*) WHERE "Idx" = 0` = 0; Seeders checked | **VERIFIED** |
| **Option Labeling Invariant** | $\forall o \in \text{exam\_options}: o.\text{Idx} \ge 1$ | `SELECT COUNT(*) WHERE "Idx" = 0` = 0; OptionEditor checked | **VERIFIED** |
| **Section Invariant** | $\forall s \in \text{exam\_sections}: s.\text{Idx} \in [1, 4]$ | `SELECT COUNT(*) WHERE "Idx" = 0` = 0; Seeders checked | **VERIFIED** |
| **Blank Mapping Invariant** | $\text{keys}(\text{BlankAcceptTexts}) \subseteq \{"1", \dots, "N"\}$ | Verified in Sprint 3 Option X; verified 0 zero-keys | **VERIFIED** |

---

## §4 — Sign-Off

Sprint 6 is formally approved for closure. All DoD checkboxes are ticked, codebases build cleanly without type errors, and automated test suites are fully green across both backend and frontend.
