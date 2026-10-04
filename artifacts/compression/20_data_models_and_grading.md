# 20 — Data Models, SM2, Grading Algorithms

> Source-of-truth: `Shared.PublicContracts/Contracts/Exam/Enums/QuestionType.cs`, `services/attempt-service/Features/Helpers/*`, `services/ai-service/app/services/grade_service.py`, `services/vocabulary-service/Features/User/UserService.cs`.

## IELTS question types (19)

`Shared.ExamDto.Contracts.Exam.Enums.QuestionType`:

```
MultipleChoiceSingle        = "MULTIPLE_CHOICE_SINGLE"
MultipleChoiceMultiple      = "MULTIPLE_CHOICE_MULTIPLE"
TrueFalseNotGiven           = "TRUE_FALSE_NOT_GIVEN"
YesNoNotGiven               = "YES_NO_NOT_GIVEN"
MultipleChoiceSingleImage   = "MULTIPLE_CHOICE_SINGLE_IMAGE"

SummaryCompletion           = "SUMMARY_COMPLETION"
TableCompletion             = "TABLE_COMPLETION"
NoteCompletion              = "NOTE_COMPLETION"
FormCompletion              = "FORM_COMPLETION"
SentenceCompletion          = "SENTENCE_COMPLETION"
ShortAnswer                 = "SHORT_ANSWER"

DiagramLabel                = "DIAGRAM_LABEL"
MapLabel                    = "MAP_LABEL"

MatchingHeading             = "MATCHING_HEADING"
MatchingInformation         = "MATCHING_INFORMATION"
MatchingFeatures            = "MATCHING_FEATURES"
MatchingEndings             = "MATCHING_ENDINGS"
Classification              = "CLASSIFICATION"

FlowChart                   = "FLOW_CHART"
```

## Question skills

```
Reading, Listening, Writing, Speaking
```

## Attempt-side grader architecture

`attempt-service/Features/Helpers/QuestionGraderFactory.cs`:

```csharp
public interface IQuestionGrader { /* Grade(question, answer, ctx) */ }
public interface IQuestionGraderRegistration {
    IEnumerable<string> SupportedTypes { get; }
    IQuestionGrader Create();
}
public interface IQuestionGraderFactory {
    IQuestionGrader Resolve(string questionType);
}
public class QuestionGraderFactory(IEnumerable<IQuestionGraderRegistration> registrations) : IQuestionGraderFactory
{
    private readonly IReadOnlyDictionary<string, IQuestionGraderRegistration> _map =
        registrations
            .SelectMany(k => k.SupportedTypes.Select(t => (t, k)))
            .ToDictionary(x => x.t, x => x.k, StringComparer.OrdinalIgnoreCase);

    public IQuestionGrader Resolve(string t) =>
        _map.TryGetValue(t, out var g) ? g.Create() : throw new NotSupportedException($"Unsupported question type: {t}");
}
```

Registered grader mappings:

| Grader | Supported types |
|---|---|
| `SingleChoiceGrader` | `MultipleChoiceSingle`, `MultipleChoiceSingleImage` |
| `MultipleChoiceGrader` | `MultipleChoiceMultiple`, `TrueFalseNotGiven`, `YesNoNotGiven` |
| `CompletionGrader` | `SummaryCompletion`, `TableCompletion`, `NoteCompletion`, `FormCompletion`, `SentenceCompletion` |
| `LabelGrader` | `DiagramLabel`, `MapLabel` |
| `MatchingHeadingGrader` | `MatchingHeading`, `MatchingInformation`, `MatchingFeatures`, `MatchingEndings`, `Classification` |
| `FlowChartGrader` | `FlowChart` |
| `ShortAnswerGrader` | `ShortAnswer` |

Per-question helper pipeline:

- `AnswerKeyBuilder` — assembles answer key from gRPC `InternalDeliveryExam` snapshot (uses `BuildQuestionIdSet`).
- `QuestionIndex` / `IndexBuilder` — fast lookup of question id → answer.
- `AnswerValidator` — generic correctness check.
- `PlacementWorkflow` — orchestrates placement-test scoring end-to-end.
- `PlacementLevelMapper` — score → CEFR/band.
- `IeltsBandConverter` — numeric band ↔ band string.
- `SectionContextLookup` — section metadata for explainer payloads.

### Per-skill helpers

- `Features/Helpers/Reading/ReadingGrader.cs` — Reading-specific auto-grading.
- `Features/Helpers/Reading/ReadingExplainerClient.cs` — HTTP `ai-service /api/v1/reading/explain-item`.
- `Features/Helpers/Listening/ListeningGrader.cs` — Listening-specific auto-grading.
- `Features/Helpers/Listening/ListeningExplainerClient.cs` — HTTP `ai-service /api/v1/listening/explain-item`.
- `Features/Helpers/RagExplainer/SkillRagExplainer.cs` — chooses explainer per skill and composes `RagFeedbackEnvelope`.

## AI-side grading pipeline (`ai-service/app/services/grade_service.py`)

`grade_writing(req: WritingGradeRequest) -> WritingGradeResponse`:

1. **Reference retrieval**: `search_service.search_and_reassemble("writing_samples", req.essay, top_k, filters)` returns `list[ReassembledEssay]`.
2. **Hint extraction**: `_extract_grade_hints(references, task_type)` builds compact metadata hints for the prompt.
3. **Prompt build** (`app/prompts/writing_grade.py` + `writing_grade_criterion.py`):
   - Rubric (Task Response / Coherence & Cohesion / Lexical Resource / Grammatical Range & Accuracy)
   - Task type (`TASK_1` / `TASK_2`)
   - RAG excerpts (`build_reference_excerpts(references, max_refs=3, max_chars_per_ref=600)`)
4. **LLM call**: `await llm_service.generate(prompt, variables, expect_json=True)` → Groq (with MiniMax fallback).
5. **JSON parsing**: defensive extractor.
6. **Band estimation fallback**: `_estimate_band_with_llm(req)` uses a large model (`gpt-oss-120b`); `_estimate_band_from_word_count` + `_length_floor` are length-based ceilings/floors; `_grammar_error_density` is regex-based.
7. **Return**: `WritingGradeResponse` with `OverallBand`, four `CriterionScore`, `Suggestions`, `ImprovedParagraph`.

`grade_speaking(req)` — LLM judge only (no RAG), 4 criteria (Fluency/Lexical/Grammar/Pronunciation).

`compare_service.compare_essay(req)` — essay-vs-reference, used by writing-service.

## SM2 (SuperMemo 2) algorithm

Implemented in `vocabulary-service/Features/User/UserService.cs` (or `Sm2Calculator`):

Per card state: `EasinessFactor (EF, default 2.5, clamped to ≥ 1.3)`, `Repetitions`, `Interval (days)`, `NextReviewDate`.

For quality q ∈ [0..5]:

- q < 3 → fail: reset `Repetitions=0`, `Interval=1`.
- q ≥ 3 → pass:
  - `EF' = max(1.3, EF + (0.1 - (5-q) * (0.08 + (5-q) * 0.02)))`
  - if `Repetitions == 0` → `Interval = 1`
  - if `Repetitions == 1` → `Interval = 6`
  - else → `Interval = round(prev_interval * EF')`
  - `Repetitions += 1`
- `NextReviewDate = today + Interval days`.

(Exact constants in source — `UserService.ReviewCard` / `Sm2Calculator`.)

## RAG collections

```
writing_samples   — IELTS writing exemplars (ingested on ai-service startup)
grammar_knowledge — grammar rules + explanations
reading_samples   — reading items + evidence (loaded but not yet wired into RAG search endpoints — see `Features/Helpers/Reading/ReadingExplainerClient.cs`)
listening_samples — listening items + evidence
speaking_memory   — long-term roleplay memory (writes happen during roleplay turn)
```

Qdrant payload indexes are created in `ingestion_service._ensure_collection` per collection; embedding dimension is `ollama_embed_dimensions=1024` (BGE-M3).

## Internal exam delivery (snapshot)

`Shared.PublicContracts/Contracts/Exam/InternalExamDto/SharedInternalExamDto.cs`:

```csharp
public record InternalDeliveryExam {
    Guid Id;
    string Slug;
    string Title;
    string? DescriptionMd;
    string Category;
    string Level;
    int DurationMin;
    IReadOnlyList<InternalDeliverySection> Sections;
}
public record InternalDeliverySection {
    Guid Id;
    int Idx;
    string Title;
    string? InstructionsMd;
    string? PassageMd;
    string? AudioUrl;
    string? TranscriptMd;
    IReadOnlyList<InternalDeliveryQuestionGroup> QuestionGroups;
}
public record InternalDeliveryQuestionGroup { /* Id, Idx, Title?, InstructionsMd?, Questions[] */ }
public record InternalDeliveryQuestion      { /* Id, Idx, Type, Prompt?, PassageMd?, …, InternalCompletionAccept?, Pairs? */ }
public record InternalDeliveryOption       { /* Id, Idx, Text, ImageUrl?, IsCorrect? */ }
public record InternalFlowChartNode        { /* Id, Label, Order, Kind, Accept? */ }
public static class SnapshotSanitizer       { /* strips Correct/Accepted/Pairs for FE snapshots */ }
```

`PaperWideNormalizer` (in same folder) renumbers `Q.idx` to paper-wide 1-based for both the shared record and `JsonElement` snapshots. Empty `QuestionGroups` falls back to section-level `questions[]` synthetic group (matches `ProtoHelper.MapToProto` fallback in `exam-service`).

## API envelope

```csharp
public sealed record ApiResultDto(bool isSuccess, string message, object data);
```

Used by every service's controllers/handlers as the standard response shape.

## IELTS band → CEFR mapping (placement)

`PlacementLevelMapper` (in `attempt-service/Features/Helpers/PlacementLevelMapper.cs`) maps composite score → CEFR/band. Implementation reads each skill's score and emits an overall recommendation.

## Schema-correctness notes

- `ExamCategory.Exercise` and `ExamCategory.Grammar` exist as separate values for small quizzes / grammar-only exams.
- `FlashCardStatus`, `DeckStatus`, `CourseStatus` are both `Draft`/`Published` (intentionally; validations match).
- `CourseLevel` is the only enum using `static string` (not `const`); it exposes `IsValid(code)` via internal `HashSet`.
- `InternalDeliveryOption.IsCorrect` exists on the EF entity and proto but is **stripped** from FE-facing snapshots via `SnapshotSanitizer`.
