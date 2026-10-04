# RFC: Paper-Wide `Question.idx` / `QuestionGroup.startIdx` / `endIdx`

> **Status:** Draft — awaiting sign-off before any code change.
> **Spec:** `langfens-fe-app/docs/be-paper-data-shape.md`
> **Author:** FE/BE bridge.

## Context

FE observation (`be-paper-data-shape.md`):
- `Question.idx` is section-local (or missing) on most questions.
- `QuestionGroup.startIdx` resets to 1 per section.
- `QuestionGroup.endIdx` equals `q.Max(Idx)` per section (not paper-wide).

FE workaround in `do-test/[skill]/[attemptId]/layout.tsx` derives paper-wide ranges from `questions.length`. Spec says: BE ships corrected contract → FE drops workaround in a follow-up PR.

Repository inventory confirms **no existing paper-wide normalizer**. The contract is currently whatever the admin entered + `ProtoHelper`'s "no QuestionGroups" fallback (`StartIdx=1, EndIdx=max(q.Idx)` per section). Seeders (`ReadingSeeder`, `GeneratedReadingSeeder`, `ListeningSeeder`) only emit `ExamQuestion` rows — never `ExamQuestionGroup` rows — so every seeded paper hits that fallback today.

## Goal

Honor the contract `Question.idx` paper-wide 1-based, `QuestionGroup.startIdx/endIdx` paper-wide 1-based, continuous, unique, for every paper delivered through every endpoint that returns `paper.sections[].questionGroups[].questions[]`.

Out of scope: `QuestionGroup.idx` and option `idx` (section-local stays; spec doesn't ask for paper-wide; FE doesn't read `group.idx`). Admin endpoint writes (admin input is preserved).

## Approach

One pure helper, three delivery-site wiring points.

### 1. New helper

There are **five** entry points across three wire shapes; two helper files (one shared, one service-side) cover them. The walking algorithm is implemented once and shared across all overloads as `Compute(exam)` returning paper-wide stamped records; each overload is a thin adapter.

#### 1a. Shared helper (DTO + proto + JsonElement)

**Location:** `services/_shared/Shared.PublicContracts/Contracts/Exam/InternalExamDto/PaperWideNormalizer.cs`

**Why here:** `Shared.PublicContracts` already owns `InternalDeliveryExam` (the init-property record) and is referenced by both `exam-service` and `attempt-service`. The proto and JsonElement overloads live here so that `attempt-service` can normalize legacy rows without pulling in any `exam-service` dependency.

```csharp
namespace Shared.ExamDto.Contracts.Exam.InternalExamDto;

public static class PaperWideNormalizer
{
    /// Renumbers Q.Idx paper-wide 1-based and rewrites Group.StartIdx/EndIdx
    /// to the first/last Q in the group. Sections without groups become one
    /// implicit group spanning the section. Pure; returns a new record.
    public static InternalDeliveryExam Normalize(InternalDeliveryExam exam);

    /// Same op, in place, on the generated proto. Internal Clone() so callers
    /// may pass either live or pre-cloned. Matches ExamGateway.Sanitize pattern.
    public static void NormalizeInPlace(Shared.Grpc.ExamInternal.InternalDeliveryExam proto);

    /// Same invariants over a JsonElement snapshot — used at attempt-service
    /// read-time for legacy PaperJson rows (round-trips through System.Text.Json).
    public static System.Text.Json.JsonElement NormalizeJsonElement(System.Text.Json.JsonElement snapshot);
}
```

#### 1b. Service-side helper (exam-service-internal positional DTO + Dto_Public)

**Location:** `services/exam-service/Application/Common/PaperWideNormalizer.ExamService.cs`

**Why split:** Both types here are private to `exam-service` (`exam_service.Contracts.Exams.InternalExamDto` and `exam_service.Contracts.Exams.Dto_Public`). They cannot live in the shared assembly — that would invert the layering (shared never references a service). Same `Compute`-style core; these overloads are thin adapters reading the local record shapes.

```csharp
namespace exam_service.Application.Common;

public static class PaperWideNormalizer
{
    public static exam_service.Contracts.Exams.InternalExamDto.InternalDeliveryExam
        Normalize(exam_service.Contracts.Exams.InternalExamDto.InternalDeliveryExam exam);

    public static exam_service.Contracts.Exams.Dto_Public.PubLicExamDetailRecord
        Normalize(exam_service.Contracts.Exams.Dto_Public.PubLicExamDetailRecord exam);
}
```

**Invariants built into every overload:**
1. Walk sections in `Section.Idx` order.
2. Within a section, walk groups in `Group.Idx` order (DB has `Idx` on `ExamQuestionGroup`).
3. If a section has no `QuestionGroups`, treat all its questions as one implicit group.
4. Assign `Question.Idx` = paper-wide counter (1-based, continuous, unique).
5. `Group.StartIdx` = paper-wide counter at first question of the group; `Group.EndIdx` = paper-wide counter at last question.
6. Pure: no DB I/O, no answer-key reads, no mutation of skill/type/prompt/etc.
7. **Clone-on-input for the proto overload** — `NormalizeInPlace` calls `exam.Clone()` once internally so callers may pass either a live instance or a pre-cloned one without double-cloning. Matches the `GrpcSnapshotSanitizer` pattern in `services/attempt-service/Features/Helpers/ExamGateway.cs`.
8. Stable for already-paper-wide input (no-op when invariants already hold — verified via length check `Group.EndIdx == Group.StartIdx + count - 1` and `Question.Idx` monotonic per section).
9. Does not touch `Group.Idx` or option `Idx` (out of scope).

### 2. Wire at the delivery sites

| gRPC | `services/exam-service/Application/Common/ProtoHelper.cs:42-58` (QuestionGroups path) and `:69-83` (fallback) | Call **shared** `PaperWideNormalizer.NormalizeInPlace` on the constructed `InternalDeliveryExam` before returning from `MapToProto`. |
| REST internal | `services/exam-service/Features/Exams/InternalEndpoint/InternalExam_Service.cs:114-123` (after the projection is built) | Call **service-side** `PaperWideNormalizer.Normalize(exam_service.Contracts.Exams.InternalExamDto.InternalDeliveryExam)` before `Results.Ok`. |
| REST public | `services/exam-service/Features/Exams/PublicEndpoint/ExamService.cs:128-138` (verify exact line with terminal grep; will be `Results.Ok` of `PubLicExamDetailRecord`) | Call **service-side** `PaperWideNormalizer.Normalize(PubLicExamDetailRecord)` before returning. |
### 3. Read-time safety net at `attempt-service`

Legacy `PaperJson` rows written before the helper existed still carry section-local indices. Two options, decide before code:

- `AttemptService.StartAttempt` (`AttemptService.cs:49-140` — branches at `:70-72` legacy proto and `:93-95` DTO fallback) just before `safeEl = ...RootElement.Clone()`.
- `AttemptService.GetResult` (`AttemptService.cs:712-1065` — branches at `:731-735` proto and `:743-744` DTO) before assignment to `fullSnapshot`.
- `AttemptService.GetAttemptById` (`AttemptService.cs:152-221` — branches at `:171-173` and `:198-200`).
**Recommendation:** **Option B.** The cost is small (one extra JSON walk per response) and it removes the class of "works for new attempts, breaks for old ones" bugs without an admin action. Document the Option B cut-points so future consumers reuse the same one.

### 4. Dependency on `Dto_Public`

`Dto_Public.PublicExamRecord` (and friends) lives in `services/exam-service/Contracts/Exams/Dto.Public.cs`, NOT in `Shared.PublicContracts`. To keep layering clean (shared contracts never references a service), the implementation is split:

- **DTO + proto + JsonElement overloads** live in `services/_shared/Shared.PublicContracts/Contracts/Exam/InternalExamDto/PaperWideNormalizer.cs` (the core, used by both services).
- **`Dto_Public` overload** lives in `services/exam-service/Application/Common/PaperWideNormalizer.Public.cs` as a static partial of `PaperWideNormalizer` or a sibling helper. Same algorithm, different record shape.

Single source of truth for the algorithm is `Compute(...)` returning an in-memory list of `{ sectionIndex, groupStart, groupEnd, paperWideIdx }` tuples; the three `Normalize*` overloads are thin adapters that walk the input and stamp `Idx` / `StartIdx` / `EndIdx`. The `Dto_Public` adapter does the same walk over its records and emits a new `PubLicExamDetailRecord` with replaced values.

Test placement: extend `services/attempt-service.Tests/` (already references its service; add `ProjectReference` to `Shared.PublicContracts`). Test the DTO + JsonElement overloads there. The `Dto_Public` adapter test belongs in a future `exam-service.Tests/` project (none today).

## Risks / edge cases

- **Empty section / empty group** — counter increments past empty section, next group's `StartIdx` = previous `EndIdx + 1`. Verify with one test (paper with an intentionally empty section).
- **Question without a group, in a section that has groups** — current code drops them (DB constraint). If ungrouped questions appear in any seeded paper today, the helper must either (a) drop them (matches current behavior) or (b) move them into a default trailing group. Confirm with FE what they expect.
- **Diacritic / case** — N/A, indices are integers.
- **Seeders** — fix at delivery time means seeder output still has section-local indices; the helper cleans them on the wire. No seeder code change needed; the helper covers everything.

## Verification plan

Add a unit test project (or extend an existing one) covering:

1. **Empty paper** — no questions, no groups. No-op, no exception.
2. **Single section, one group, 3 questions** — output `[1,2,3]`, `startIdx=1, endIdx=3`.
3. **Two sections, one group each** (matches spec worked example) — section 1 `1..7`, section 2 `8..13`.
4. **Section with no `QuestionGroups`** — questions treated as one implicit group spanning the section.
5. **Already paper-wide input** — bit-identical output (no unnecessary rewrite, guard against accidental reordering).
6. **Three sections, mixed group counts** — full paper-wide run.
7. **JsonElement round-trip** — `NormalizeJsonElement` of an already-normalized snapshot returns the same bytes.

Integration smoke (post-code):
- Boot `AppHost`. Start an attempt on the seed paper that has the bug. `attempts:start` response: bottom-bar label is paper-wide (`01–05 / 06–10 / 11–14`), per-question `idx` monotonically increases across sections.
- `getresult/:attemptId` for the same attempt: same paper-wide numbering.

## Out of scope

- `QuestionGroup.idx`, option `Idx` — admin input stays section-local.
- Admin endpoints (`AdminSection_Service`, `AdminQuestion_Service`) — they don't emit paper-shape.
- `QuestionBankService` — flat question list, no sections/groups.
- `Migrations` — DB column types unchanged; values re-derived at delivery time. If we ever want to also rewrite historical DB values for queries that bypass delivery (none today), follow-up PR.

## Open questions for sign-off

1. **Wire at write time only, or also at read time?** Default: both (Option B). Pick.
2. **Empty/empty-group behavior on the wire** — should the helper emit an empty section, or skip the section entirely? Default: emit (parity with current code).
3. **Public DTO overload** — implement `Normalize(Dto_Public.PublicExamRecord)` or have the public endpoint project through the internal DTO? Default: implement sibling overload.
4. **Test project** — extend an existing one or add a new `Shared.PublicContracts.Tests` project? Default: extend existing.
