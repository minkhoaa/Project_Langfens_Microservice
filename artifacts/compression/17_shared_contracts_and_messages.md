# 17 — Shared Contracts, Messages, gRPC, Security

> Source-of-truth: `services/_shared/Shared.PublicContracts/*`, `services/_shared/Shared.Grpc/*`, `services/_shared/Shared.Security/*`. Verified by direct reads.

## RabbitMQ messages (mass-transit-friendly records)

### Auth → Email

`Shared.ExamDto.Contracts.Auth_Email.UserRegisterdOtp`:

```csharp
public record UserRegisteredSendOtp(string Email, string Otp, long TtlSeconds);
public record UserRegisteredConfirmOtp(string Email, string Otp);
```

### Auth → Gamification

`Shared.PublicContracts.Events.UserCreatedEvent(Guid UserId, string Email, DateTime CreatedAt)`.

### Attempt → Gamification

`Shared.PublicContracts.Events.AttemptCompletedEvent(Guid UserId, Guid AttemptId, string? Skill, int Score)`.

### Course → Gamification

`Shared.PublicContracts.Events.LessonCompletedEvent(Guid UserId, Guid LessonId, Guid CourseId)`.

### Vocabulary → Gamification

`Shared.PublicContracts.Events.CardReviewedEvent(Guid UserId, Guid CardId, int Grade, bool IsCorrect)`.

### Attempt → Writing (grading request)

`Shared.ExamDto.Contracts.Writing.WritingGradeRequestMessage`:

```csharp
public record WritingGradeRequestMessage(
    Guid AttemptId,
    Guid UserId,
    Guid? QuestionId,
    string Type,
    string? TaskText,
    string? AnswerText,
    string TaskType = "TASK_2",
    Guid? SubmissionId = null  // null = Flow B (consumer must create row)
);
```

### Writing → Attempt (grading response, queue `writing-graded-response`)

`Shared.ExamDto.Contracts.Writing.WritingGradeResponseMessage`:

```csharp
public class WritingGradeResponseMessage {
    public Guid AttemptId;
    public Guid UserId;
    public Guid? QuestionId;
    public string? TaskText;
    public string EssayRaw;
    public string EssayNormalized;
    public int WordCount;
    public double OverallBand;
    public CriterionScore TaskResponse;
    public CriterionScore CoherenceAndCohesion;
    public CriterionScore LexicalResource;
    public CriterionScore GrammaticalRangeAndAccuracy;
    public List<string> Suggestions;
    public string ImprovedParagraph;
    public string? ComparativeAnalysisJson;  // populated asynchronously
}
public class CriterionScore { double Band; string Comment; }
```

### Attempt → Speaking (grading request)

`Shared.ExamDto.Contracts.Speaking.SpeakingGradingRequestMessage`:

```csharp
public record SpeakingGradingRequestMessage(
    Guid AttemptId,
    Guid UserId,
    Guid? QuestionId,
    string Skill,
    string? Prompt,
    string AudioUrl,
    string? Format,
    int? Duration,
    long? Bytes,
    string? PublicId
);
```

### Speaking → Attempt (grading response, queue `speaking-graded-response`)

`Shared.ExamDto.Contracts.Speaking.SpeakingGradingResponseMessage`:

```csharp
public class SpeakingGradingResponseMessage {
    public Guid AttemptId;
    public Guid UserId;
    public Guid? QuestionId;
    public string? TaskText;
    public string TranscriptRaw;
    public string TranscriptNormalized;
    public int WordCount;
    public double OverallBand;
    public CriterionScore FluencyAndCoherence;
    public CriterionScore LexicalResource;
    public CriterionScore GrammaticalRangeAndAccuracy;
    public CriterionScore Pronunciation;
    public List<string> Suggestions;
    public string ImprovedAnswer;
}
public class CriterionScore { double Band; string Comment; }
```

### Test ping (dev)

`Shared.ExamDto.Contracts.Auth_Email.TestPing(string Text, DateTimeOffset At)` — consumed by `email-service.TestpingConsumer` on queue `email-testping`.

## gRPC proto (verified by direct read)

`services/_shared/Shared.Grpc/Contracts/exam_internal.proto` (`csharp_namespace = "Shared.Grpc.ExamInternal"`):

```protobuf
syntax = "proto3";
package exam.v1;

message InternalDeliveryExam { ... }
message InternalDeliverySection { ... }
message InternalDeliveryQuestionGroup { ... }
message InternalDeliveryQuestion { ... }
message InternalDeliveryOption { ... }
message InternalCompletionAccept { ... }
message InternalMatchPair { ... }
message FlowChartNode { ... }

message GetInternalExamRequest { ... }
message GetExamListRequest { ... }
message GetExamListResponse { repeated ExamListItem exams = 1; }
message ExamListItem { ... }

service ExamInternal {
  rpc GetInternalExam(GetInternalExamRequest) returns (InternalDeliveryExam);
  rpc GetExamList(GetExamListRequest) returns (GetExamListResponse);
}
```

Implemented by `services/exam-service/Features/Exams/InternalEndpoint/ExamInternalGrpcService.cs`. Consumed by `services/attempt-service` (via `AddGrpcClient<ExamInternal.ExamInternalClient>` with `ExamService__GrpcAddress` env, default `http://exam-service:8081`, and `AppContext.SetSwitch("System.Net.Http.SocketsHttpHandler.Http2UnencryptedSupport", true)` for h2c).

## Security: claims, scopes, roles

`Shared.Security.Claims.CustomClaims`:

```csharp
public const string Sub   = "sub";
public const string Scope = "scope";
public const string Roles = "roles";
```

`Shared.Security.Roles.Roles`:

```csharp
public const string Admin = "ADMIN";
public const string User  = "USER";
```

Scopes:

```csharp
public static class UserScope    { public const string UserReadAny = "user.read:any"; }
public static class EmailScope   { public const string EmailSend = "email.send"; }
public static class AttemptScope { 
    public const string AttemptStart  = "attempt.start";
    public const string AttemptSubmit = "attempt.submit";
    public const string AttemptReadOwn= "attempt.read:own";
    public const string AttemptReadAny= "attempt.read:any";
}
public static class CourseScope  {
    public const string CourseRead    = "course.read";
    public const string CourseEnroll  = "course.enroll";
    public const string CourseComplete= "course.complete";
    public const string CourseManage  = "course.manage";
}
public static class ExamScope    {
    public const string ExamRead    = "exam.read";
    public const string ExamManage  = "exam.manage";
}
public static class VocabScope   {
    public const string VocabRead   = "vocab.read";
    public const string VocabManage = "vocab.manage";
}
public class  WritingScope {
    public const string WritingStart   = "writing.start";
    public const string WritingCreate  = "writing.create";
    public const string WritingViewOwn = "writing.view:own";
    public const string WritingViewAny  = "writing.view:any";
}
public class  SpeakingScope {
    public const string SpeakingStart   = "speaking.start";
    public const string SpeakingCreate  = "speaking.create";
    public const string SpeakingViewOwn = "speaking.view:own";
    public const string SpeakingViewAny  = "speaking.view:any";
}
```

`RoleBasedScopeProvider.CustomRoleOptions` (verbatim from `Shared.Security.Scopes.RoleBasedScopeProvider.cs`):

- `ADMIN` → `UserReadAny`, `CourseRead`, `CourseEnroll`, `CourseComplete`, `CourseManage`, `ExamRead`, `ExamManage`, `AttemptStart`, `AttemptSubmit`, `AttemptReadAny`, `VocabRead`, `VocabManage`, `WritingCreate`, `WritingViewAny`, `SpeakingCreate`, `SpeakingViewAny`.
- `USER` → `CourseRead`, `CourseEnroll`, `CourseComplete`, `ExamRead`, `AttemptStart`, `AttemptSubmit`, `AttemptReadOwn`, `VocabRead`, `WritingViewOwn`, `WritingStart`, `SpeakingViewOwn`, `SpeakingStart`.

`Shared.Security.Helper.AuthExtension.HasAnyScope(this ClaimsPrincipal, params string[] scopes)` — splits the `scope` claim by space.

## Enums (verified)

### `QuestionType` (19 values)

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

### `QuestionSkill`

```
Reading   = "READING"
Listening = "LISTENING"
Writing   = "WRITING"
Speaking  = "SPEAKING"
```

### `ExamCategory`

```
IELTS, TOEIC, VSTEP, PLACEMENT, EXERCISE, GRAMMAR
```

### `ExamLevel` (constants only)

```
A1, A2, B1, B2, C1, C2
```

### `ExamStatus`

```
Draft, Published, Archived
```

### `CourseLevel` (with `IsValid`)

```
A1, A2, B1, B2, C1, C2
```

### `CourseStatus` (with `IsValid`)

```
Draft, Published
```

### `CourseCategories` (with `IsValid`, 22 values)

```
IELTS_GENERAL, IELTS_ACADEMIC, TOEIC, TOEFL, MOCK_TESTS,
SKILL_LISTENING, SKILL_READING, SKILL_WRITING, SKILL_SPEAKING,
GRAMMAR, VOCABULARY, PRONUNCIATION, PHONETICS,
BUSINESS_ENGLISH, ACADEMIC_ENGLISH, GENERAL_ENGLISH, STUDY_SKILLS,
KIDS, TEENS, ADULTS, TEACHER_TRAINING
```

### `EnrollmentStatus` (with `IsValid`)

```
Active, Cancelled, Completed
```

### `DeckCategory` (with `IsValid`)

```
Toeic, Ielts, Vstep
```

### `DeckStatus` (with `IsValid`)

```
Draft, Published
```

### `FlashCardStatus`

```
Draft, Published
```

### `UserDeckStatus`

```
Active, Inactive
```

## Paper-wide index normalizer

`Shared.PublicContracts/Contracts/Exam/InternalExamDto/PaperWideNormalizer.cs`:

- `Normalize(InternalDeliveryExam)` returns a new record with paper-wide 1-based `Q.idx`. Empty papers return as-is. Pure: no DB I/O, no answer-key reads, no mutation of skill/type/prompt. Does not touch `QuestionGroup.Idx` or option `Idx`.
- Empty `QuestionGroups` falls back to a synthetic group spanning section-level `questions[]` (mirrors `exam-service/Application/Common/ProtoHelper.MapToProto`).
- `NormalizeJsonElement(JsonElement)` — same logic for stored PaperJson snapshots, round-tripped through `System.Text.Json`.

Two adapters:

- `exam-service/Application/Common/PaperWideNormalizer.Proto.cs` — gRPC proto.
- `exam-service/Application/Common/PaperWideNormalizer.ExamService.cs` — positional internal DTO + `Dto_Public`.

## `SnapshotSanitizer` (in `SharedInternalExamDto.cs`)

Strips `Correct` / `Accepted` / `Pairs` from snapshots returned to FE.

## API envelope (`GlobalResponse.cs`)

```csharp
public sealed record ApiResultDto(bool isSuccess, string message, object data);
```

Used uniformly across services.

## RAG envelope (`RagFeedbackContracts.cs`)

```csharp
public sealed record RagFeedbackEnvelope(
    string ItemId,
    string Domain,                            // writing | reading | listening | speaking | grammar
    double? OverallBand,
    IReadOnlyList<CriterionScore> Criteria,
    IReadOnlyList<Evidence> Evidence,
    IReadOnlyList<Suggestion> Suggestions,
    string? RawLlmJson = null);
public sealed record CriterionScore(string Name, double Band, string Comment, IReadOnlyList<string>? EvidenceIds = null);
public sealed record Evidence(string Id, string Text, string Source, double Relevance);
public sealed record Suggestion(string Text, string Target);
```

Returned by ai-service `/v1/reading/explain-item` and `/v1/listening/explain-item`; consumed by `attempt-service.Features.Helpers.RagExplainer.SkillRagExplainer`.
