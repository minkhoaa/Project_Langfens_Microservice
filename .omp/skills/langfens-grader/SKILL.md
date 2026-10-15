---
name: langfens-grader
description: Implement and test Langfens IELTS graders using actual IQuestionGrader registrations, string question types, and all-or-nothing scoring invariants.
---

# Langfens question grading workflow

Use for reading/listening scoring and answer-key integration. Reuse global
`dotnet-patterns`, `csharp-testing`, and `tdd-workflow`; delegate substantial
scoring work to `grader-specialist` and review C# changes with `csharp-reviewer`.

## Actual contracts

- `services/attempt-service/Features/Helpers/Grader.cs` defines
  `GradeResult(decimal AwardedPoints, bool? IsCorrect, bool NeedsManualReview, string? Feedback)`
  and `IQuestionGrader.Grade(AttemptAnswer answer, QuestionKey key)`.
- Existing implementations also live under the `Reading/` and `Listening/`
  helper directories; follow the closest established strategy.
- `QuestionGraderRegistration.cs` defines registrations with
  `IEnumerable<string> SupportedTypes` and `IQuestionGrader Create()`.
  There is no `Register(IServiceCollection)` method in that interface.
- `QuestionGraderFactory.cs` resolves these registrations by question-type string.
- `QuestionType.cs` under `services/_shared/Shared.PublicContracts/Contracts/Exam/Enums/`
  contains shared string constants, not an enum to replace.
- `services/attempt-service/Program.cs` registers both concrete grader types and
  their `IQuestionGraderRegistration` implementations as singletons.

## Change sequence

1. Trace the failing consumer behavior and write a deterministic regression test
   under `services/attempt-service.Tests/Helpers/` before changing a grader.
2. Reuse existing normalization, wire format, and answer-key retrieval behavior.
   Scoring is pure and deterministic: awarded points are `0` or `QuestionPoints`.
   Multi-blank responses do not gain partial credit.
3. Change shared constants/DTOs only if the wire contract actually changes;
   migrate all producers/consumers. Generate an exam EF migration only if the
   persisted schema changes, not simply because a grader was added.
4. Implement the existing `Grade` signature, add the matching registration, and
   follow current singleton DI registrations. Do not invent parallel factories.
5. Cover exact/incorrect answers, supported normalization, malformed/missing
   input, multi-blank ordering, and repeated deterministic execution. Do not
   expand accepted spelling variants or scoring policy without user scope.

## Verification

From repository root:

```bash
dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj
```

Use a fully qualified test filter for the initial red/green loop, then run the
affected suite. These unit tests do not need Aspire or PostgreSQL. Cross-service
changes additionally require relevant exam/contract verification; exam database
fixtures can drop schemas and require a disposable test database explicitly.
