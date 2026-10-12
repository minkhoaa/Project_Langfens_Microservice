# Phase 12 — Paper Loop, .NET Worker Integration, and Final Draft

**Status**: **BLOCKED (Implementation & Durability PASS; Live Model Campaign Pending)**  
**Gate**: **G12**  
**Readiness for Phase 13 Coding**: **READY_FOR_PHASE_13_CODING**

## 1. Summary of Changes & Architecture
- **P12-01 (Immutable Paper Snapshot & Student Payload Isolation)**:
  - Created canonical `ReadingPaperSnapshot`, `ReadingPaperPayload`, `AuthoringPaperResult`, and `StudentVisibleReadingPaper` contracts.
  - Implemented `assemble_immutable_paper` validating 3 sections, 40 contiguous questions (1-40), word limits (720-915 per passage, 2150-2750 total).
  - Implemented `to_student_visible_paper` and `assert_student_visible_paper_isolated` strictly purging all answers, evidence quotes, absence assessments, explanations, and solver metadata.
- **P12-02 & P12-03 (Cross-Section Duplication, Concentration, and Leakage Evaluators)**:
  - Implemented `PaperStructureEvaluator`: enforces 3 sections, 40 questions (1-40), word limits, group types, and question counts.
  - Implemented `PaperCrossSectionEvaluator`: validates 5-word shingle overlap <= 0.45 across passages and prompt uniqueness across all 40 questions.
  - Implemented `PaperLeakageEvaluator`: detects cross-section instruction and prompt answer leakage with type-aware boundaries (excluding fixed judgement enums and single-letter MCQ choices).
  - Implemented `PaperMonotonyEvaluator`: evaluates answer distribution diversity across True/False, Yes/No, and Multiple Choice questions.
- **P12-04 (Internal Authenticated Paper Evaluation & Repair Facade/Router)**:
  - Added `evaluate_paper_async`, `repair_paper_async`, and `generate_paper_v2` to `GenerationFacade`.
  - Added `/paper-evaluate`, `/paper-repair`, and `/paper-v2` endpoints in FastAPI `router.py`.
  - Added `GeneratePaperV2Async`, `EvaluatePaperAsync`, and `RepairPaperAsync` to .NET `ReadingPaperAiClient`.
- **P12-05 (Scoped Paper-Level Repair & Closure Invalidation)**:
  - Implemented `PaperRepairRouter` routing defects to minimal sufficient scopes (`ITEM_REPAIR`, `PASSAGE_REPAIR`, `SECTION_REPAIR`).
  - Implemented `PaperSurgicalRepairer` applying patches to target section/question while preserving unaffected section and question content hashes.
- **P12-06 & P12-07 (PaperLoop Controller & .NET Worker Integration)**:
  - Implemented `PaperLoop` controller supporting both bounded persistent runtime and standalone in-memory execution.
  - Updated `ReadingPaperWorker` to validate full paper rules and initiate `CheckpointService.BuildExamIdempotentAsync`.
  - Decoupled `SHORT_ANSWER` validation in `ReadingPaperRules.Validate` to emit accurate type-aware error messages (`"Question <built-in function next> has an invalid short answer"`).
- **P12-08 & P12-09 (.NET Transactional Finalizer & Replay Idempotency)**:
  - Atomic EF Core transaction saving `Exam`, `ExamSection`, `ExamQuestionGroup`, `ExamQuestion`, `ExamOption` and setting job `Status="Completed"`, run `Status="COMPLETED"`.
  - Transaction rollback on simulated fault ensures zero orphaned rows.
  - Replay on lost ACK / crash returns existing `ExamId` with `IsExisting=true`.

## 2. Work Packages (P12-01 .. P12-09)
| Work Package | Status | Key Files / Symbols |
|---|---|---|
| P12-01 | PASS | `app/contracts/paper.py` (`assemble_immutable_paper`, `to_student_visible_paper`) |
| P12-02 | PASS | `app/evaluators/paper.py` (`PaperStructureEvaluator`, `PaperCrossSectionEvaluator`) |
| P12-03 | PASS | `app/evaluators/paper.py` (`PaperLeakageEvaluator`, `PaperMonotonyEvaluator`) |
| P12-04 | PASS | `app/facade.py`, `app/router.py`, `ReadingPaperAiClient.cs` |
| P12-05 | PASS | `app/repair/paper.py` (`PaperRepairRouter`, `PaperSurgicalRepairer`) |
| P12-06 | PASS | `app/loop/paper.py` (`PaperLoop`), `ReadingPaperWorker.cs` |
| P12-07 | PASS | `ReadingPaperModels.cs` (`ReadingPaperRules.Validate`), `CheckpointService.cs` |
| P12-08 | PASS | `CheckpointService.BuildExamIdempotentAsync`, `Exam.cs`, `ExamSection.cs` |
| P12-09 | PASS | `BuildExamIdempotentAsync` CAS fencing & idempotent replay |

## 3. Test Verification Matrix (T12-01 .. T12-08)
| Test ID | Area | Status | Verification Detail |
|---|---|---|---|
| T12-01 | Numbering & Counts | PASS | 3 sections, 40 questions (contiguous 1-40) pass; 39/41/gap/duplicate ordinals rejected |
| T12-02 | Word Policy Parity | PASS | [720, 915] passage bounds & [2150, 2750] total bounds enforced in Python & .NET |
| T12-03 | Duplication & Scoped Repair | PASS | Shingle overlap > 0.45 and duplicate prompts rejected; surgical repair preserves unaffected hashes |
| T12-04 | Answer Leakage Boundaries | PASS | Cross-section prompt/instruction leakage detected with type-aware boundaries |
| T12-05 | Fencing & Lease CAS | PASS | Stale epoch / lease owner mismatch / cancel blocks stale writer |
| T12-06 | Atomic Transaction Rollback | PASS | Injected fault during exam build rolls back entire graph with zero orphaned rows |
| T12-07 | Idempotent Replay | PASS | Replay returns identical Draft ExamId with IsExisting: true |
| T12-08 | Real E2E Exam Graph & CRUD | PASS | Full 40-question Exam graph created in PostgreSQL; student isolation verified |

## 4. Gate G12 Status & Phase 13 Readiness
- **Gate G12 Status**: **BLOCKED**
  - Implementation: **PASS** (P12-01..P12-09 complete)
  - Deterministic & Durability: **PASS** (T12-01..T12-08 passing across Python and .NET)
  - Live Model Quality: **BLOCKED_PENDING_LIVE_CAMPAIGN** (Live MiniMax paper generation campaign pending execution)
- **Readiness for Phase 13**: **READY_FOR_PHASE_13_CODING** (Downstream API, events, and observability coding can proceed with simulations/fakes).
