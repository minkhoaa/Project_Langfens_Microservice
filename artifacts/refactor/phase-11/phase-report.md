# Phase 11 — Section Loop, Exact Resume, and Scoped Repairs

## 1. Summary of Changes
Phase 11 implements the Section Loop for Langfens Loop Engine V2:
- **Immutable Section Snapshots**: Assembled from exact accepted passage, blueprint, and question candidate references with explicit evaluation summary bindings.
- **Strict Distributions & Word Counts**:
  - Section 1: 13 questions (7 TFNG + 6 Sentence Completion), 720-915 words.
  - Section 2: 13 questions (6 MCQ Single + 7 Summary Completion), 720-915 words.
  - Section 3: 14 questions (7 YNNG + 7 Short Answer), 720-915 words.
  - Total contiguous numbering: 1..40.
- **Quality & Concentration Evaluators**:
  - `SectionStructureEvaluator`: Enforces 2 groups, word bounds, exact distributions, and strict fail-closed validation on fresh solver/adversary coverage.
  - `SectionDuplicateAndConcentrationEvaluator`: Detects duplicate prompts (e.g. Q23 duplicate of Q18), 5-word shingle overlaps > 0.45, prompt answer leakage, span concentration, and answer distribution monotony.
  - `SectionEditorialEvaluator`: Assesses editorial instructions and skill diversity, computing non-blocking heuristic confidence metrics.
- **Surgical Scoped Repairs**:
  - Duplicate item -> targeted item repair/reselection (invalidates only defective item, keeps unaffected items).
  - Group coherence -> targeted group repair.
  - Passage flaw -> PassageLoop + descendant question invalidation.
  - Source defect -> NeedsSources workflow escalation.
- **Authoritative .NET Persistence & SectionsJson Bridge**:
  - Synchronous atomic/idempotent projection from Section artifact envelope into legacy `job.SectionsJson`.
  - CAS/fencing/cancel preconditions strictly verified.
  - Section acceptance does NOT build an exam or complete the paper (deferred to Phase 12 PaperLoop).

## 2. Work Packages (P11-01 .. P11-08)
| Work Package | Status | Key Files / Symbols |
|---|---|---|
| P11-01 | PASS | `app/contracts/section.py` (`SectionSnapshot`, `SectionPayload`, `assemble_immutable_section`, `to_student_visible_section`) |
| P11-02 | PASS | `app/evaluators/section.py` (`SectionStructureEvaluator`) |
| P11-03 | PASS | `app/evaluators/section.py` (`SectionDuplicateAndConcentrationEvaluator`) |
| P11-04 | PASS | `app/evaluators/section.py` (`SectionEditorialEvaluator`) |
| P11-05 | PASS | `app/repair/section.py` (`SectionRepairRouter`, `SectionSurgicalRepairer`) |
| P11-06 | PASS | `CheckpointService.cs` (`SyncSectionToLegacyJob`, `ParseCanonicalV2Section`), `ReadingPaperWorker.cs` |
| P11-07 | PASS | `app/loop/section.py` (`SectionLoop`), `Phase11SectionLoopTests.cs` |
| P11-08 | PASS | `app/router.py` (`/section-v2`), `ReadingPaperAiClient.cs` (`GenerateSectionV2Async`) |

## 3. Test Evidence (T11-01 .. T11-08)
| Test ID | Name | Result |
|---|---|---|
| T11-01 | Three sections count (13/13/14), types, contiguous numbering (1-40), passage word bounds [720, 915] | PASS |
| T11-02 | Fresh evaluations, zero missing/stale required evaluations, blind solver & adversary coverage | PASS |
| T11-03 | Section-wide duplicate detection (Q23 vs Q18), shingle overlap >0.45, leakage, span concentration | PASS |
| T11-04 | Editorial style & skill diversity, separate warnings vs blockers, diagnostic heuristic score | PASS |
| T11-05 | SectionLoop on generic BoundedLoopRuntime, scoped repair routing, dynamic closure invalidation | PASS |
| T11-06 | Authoritative checkpoint persistence, atomic SectionsJson bridge, CAS/fencing, idempotent replay | PASS |
| T11-07 | Exact durable cursor resume across sections, crash resumption, Section 3 source replacement preserving Section 1-2 | PASS |
| T11-08 | Typed workflow mapping (NeedsSources, escalation), .NET consumer round-trip, student payload isolation | PASS |

## 4. Gate G11 Conclusion
Gate G11 status is **PASS**. All predecessor quality gates (G06, G07, G08, G09, G10) are verified and PASS.
Readiness for Phase 12 (Paper Loop, full 3-section assembly, final Draft validation, and exam publication) is **READY_FOR_PHASE_12**.
