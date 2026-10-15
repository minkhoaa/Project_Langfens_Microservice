---
name: langfens-grader
description: Implement, register, test, and troubleshoot IELTS question auto-graders in attempt-service and exam-service.
---

# IELTS Question Auto-Grader Workflow

Use this skill when implementing, extending, or fixing auto-graders for IELTS reading and listening questions.

## Architecture

Graders reside in `services/attempt-service/Features/Helpers/` and implement the `IQuestionGrader` interface.

```text
Exam Attempt Submitted
        ↓
AttemptService
        ↓
QuestionGraderFactory
        ↓ resolves by QuestionType enum
IQuestionGrader (e.g. SingleChoiceGrader, CompletionGrader)
        ↓ pure scoring logic
Score & Diagnostic Output
```

## Step-by-Step Implementation Guide

### Step 1: Declare QuestionType Enum
File: `services/_shared/Shared.PublicContracts/Contracts/Exam/Enums/QuestionType.cs`
Add the new question type:
```csharp
public enum QuestionType
{
    SingleChoice = 1,
    MultipleChoice = 2,
    // ...
    NewQuestionType = X
}
```

### Step 2: Implement the Grader
File: `services/attempt-service/Features/Helpers/{Type}Grader.cs`
```csharp
namespace attempt_service.Features.Helpers;

public sealed class NewQuestionTypeGrader : IQuestionGrader
{
    public QuestionType SupportedType => QuestionType.NewQuestionType;

    public GradeResult Grade(QuestionAnswerContext context)
    {
        // 1. Normalize user answer (trim, case-fold, canonical punctuation)
        // 2. Compare against correct answer key from exam context
        // 3. Compute score (full or partial credit)
        // 4. Return GradeResult(isCorrect, score, explanation)
    }
}
```

### Step 3: Register the Grader
File: `services/attempt-service/Features/Helpers/{Type}GraderRegistration.cs`
```csharp
public sealed class NewQuestionTypeGraderRegistration : IQuestionGraderRegistration
{
    public void Register(IServiceCollection services)
    {
        services.AddSingleton<IQuestionGrader, NewQuestionTypeGrader>();
    }
}
```
Wire in `services/attempt-service/Program.cs`:
```csharp
new NewQuestionTypeGraderRegistration().Register(builder.Services);
```

### Step 4: Write Unit Tests (TDD)
File: `services/attempt-service.Tests/Helpers/NewQuestionTypeGraderTests.cs`
- Test exact match (full score)
- Test case/whitespace normalization
- Test partial matches / alternate valid answers
- Test empty, malformed, or boundary input (score 0, no exception)

Run tests:
```bash
dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj --filter "FullyQualifiedName~NewQuestionTypeGrader"
```
