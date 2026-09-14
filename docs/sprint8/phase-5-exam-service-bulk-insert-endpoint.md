# Phase 5 — exam-service bulk insert endpoint

> **Plan file:** This is Phase 5 of Sprint 8. Read [`README.md`](./README.md) for global constraints, file structure, and execution handoff.

---

## Task 5.1: Add BulkInsertRequest DTO

**Files:**
- Create: `services/exam-service/Contracts/Exams/BulkInsertRequest.cs`

- [ ] **Step 1: Verify Contracts/Exams directory layout**

```bash
ls /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/exam-service/Contracts/Exams/
```

Expected: list including `Dto.Admin.cs` and possibly `Dto.Internal.cs`.

- [ ] **Step 2: Write `BulkInsertRequest.cs`**

```csharp
using System;
using System.Collections.Generic;

namespace exam_service.Contracts.Exams;

/// <summary>
/// Request body for POST /api/admin/question/bulk.
/// Caller-supplied Idx is IGNORED — server derives Idx from position
/// (maxIdx + i + 1) to avoid collisions within the section.
/// </summary>
public record BulkInsertRequest(
    Guid SectionId,
    List<DtoAdmin.AdminQuestionUpsert> Questions
);
```

- [ ] **Step 3: Verify build**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
dotnet build services/exam-service/exam-service.csproj 2>&1 | tail -5
```

Expected: `Build succeeded` with 0 errors.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/exam-service/Contracts/Exams/BulkInsertRequest.cs
git commit -m "feat(exam): add BulkInsertRequest DTO with caller-supplied Idx ignored"
```

---

## Task 5.2: Add BulkInsertAsync to AdminQuestionService

**Files:**
- Modify: `services/exam-service/Features/Exams/AdminEndpoint/QuestionEndpoint/AdminQuestion_Service.cs:33-265`

- [ ] **Step 1: Locate AddAsync pattern**

```bash
grep -n "public async Task<IResult> AddAsync" /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/exam-service/Features/Exams/AdminEndpoint/QuestionEndpoint/AdminQuestion_Service.cs
```

Expected: 1 match at line ~113.

- [ ] **Step 2: Add BulkInsertAsync method**

Append before the closing brace of `AdminQuestionService` class (after `GetBySectionIdAsync` ends at line ~265):

```csharp
    public async Task<IResult> BulkInsertAsync(
        CancellationToken token,
        [FromBody] BulkInsertRequest req)
    {
        var section = await _context.ExamSections.AsNoTracking()
            .FirstOrDefaultAsync(s => s.Id == req.SectionId, token);
        if (section == null)
            return Results.BadRequest(new ApiResultDto(false, "Section not found", null!));

        var created = new List<object>();
        var errors = new List<object>();
        var maxIdx = await _context.ExamQuestions.AsNoTracking()
            .Where(q => q.SectionId == req.SectionId)
            .Select(q => (int?)q.Idx).MaxAsync(token) ?? 0;

        await using var tx = await _context.Database.BeginTransactionAsync(token);
        try
        {
            for (int i = 0; i < req.Questions.Count; i++)
            {
                var dto = req.Questions[i];
                var validationError = ValidatePayload(
                    dto.Type, dto.BlankAcceptTexts, dto.MatchPairs,
                    dto.OrderCorrects, dto.ShortAnswerAcceptTexts);
                if (validationError != null)
                {
                    errors.Add(new { idx = i, message = "Validation failed" });
                    continue;
                }
                var orderCorrects = dto.OrderCorrects?.Where(x => !string.IsNullOrWhiteSpace(x)).ToList();
                var shortTexts = dto.ShortAnswerAcceptTexts?.Where(x => !string.IsNullOrWhiteSpace(x)).ToList();
                var shortRegex = dto.ShortAnswerAcceptRegex?.Where(x => !string.IsNullOrWhiteSpace(x)).ToList();
                var question = new ExamQuestion
                {
                    SectionId = req.SectionId,
                    Idx = maxIdx + i + 1,
                    Type = dto.Type,
                    Skill = dto.Skill,
                    Difficulty = dto.Difficulty,
                    PromptMd = dto.PromptMd,
                    ExplanationMd = dto.ExplanationMd,
                    ImageUrl = dto.ImageUrl,
                    BlankAcceptTexts = dto.BlankAcceptTexts,
                    BlankAcceptRegex = dto.BlankAcceptRegex,
                    MatchPairs = dto.MatchPairs,
                    OrderCorrects = orderCorrects,
                    ShortAnswerAcceptTexts = shortTexts,
                    ShortAnswerAcceptRegex = shortRegex,
                };
                _context.ExamQuestions.Add(question);
                created.Add(new { idx = i });
            }
            await _context.SaveChangesAsync(token);
            await tx.CommitAsync(token);
            return Results.Ok(new ApiResultDto(true, "Bulk insert complete",
                new { created, errors }));
        }
        catch (Exception e)
        {
            await tx.RollbackAsync(token);
            return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
        }
    }
```

- [ ] **Step 3: Verify build**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
dotnet build services/exam-service/exam-service.csproj 2>&1 | tail -5
```

Expected: `Build succeeded` with 0 new CS warnings. (Pre-existing CVE warnings OK.)

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/exam-service/Features/Exams/AdminEndpoint/QuestionEndpoint/AdminQuestion_Service.cs
git commit -m "feat(exam): add BulkInsertAsync with partial-success errors[] semantics"
```

---

## Task 5.3: Add BulkInsertHandler + route registration

**Files:**
- Modify: `services/exam-service/Features/Exams/AdminEndpoint/QuestionEndpoint/AdminQuestion_Handler.cs`
- Modify: `services/exam-service/Features/Exams/AdminEndpoint/AdminExamEndpoint.cs:48-56`

- [ ] **Step 1: Add BulkInsertHandler in `AdminQuestion_Handler.cs`**

Append after `DeleteQuestionHandler`:

```csharp
    public static Task<IResult> BulkInsertHandler(
        [FromServices] IAdminQuestionService service,
        CancellationToken token,
        [FromBody] BulkInsertRequest req
    ) => service.BulkInsertAsync(token, req);
```

- [ ] **Step 2: Add route in `AdminExamEndpoint.cs:48-56`**

After the existing `adminQuestion.MapDelete(...)` line:

```csharp
        adminQuestion.MapPost("/bulk", AdminQuestionHandler.BulkInsertHandler)
            .RequireAuthorization(Roles.Admin);
```

- [ ] **Step 3: Verify build**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
dotnet build services/exam-service/exam-service.csproj 2>&1 | tail -5
```

Expected: `Build succeeded`.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/exam-service/Features/Exams/AdminEndpoint/QuestionEndpoint/AdminQuestion_Handler.cs services/exam-service/Features/Exams/AdminEndpoint/AdminExamEndpoint.cs
git commit -m "feat(exam): register POST /api/admin/question/bulk with admin auth"
```

---

## Task 5.4: Add xUnit tests for bulk insert

**Files:**
- Create: `services/attempt-service.Tests/ExamServiceBulkInsertTests.cs`

- [ ] **Step 1: Verify test project references exam-service**

```bash
grep -E "ProjectReference|exam-service" /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/attempt-service.Tests/attempt-service.Tests.csproj
```

Expected: `ProjectReference` to exam-service OR shared `PublicContracts`. If not, xUnit can't access `BulkInsertRequest` — skip this test or use `InternalsVisibleTo`.

- [ ] **Step 2: Write the test file**

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts.Exam.Enums;
using Xunit;

namespace attempt_service.Tests.ExamService;

/// <summary>
/// xUnit tests for AdminQuestionService.BulkInsertAsync.
/// Note: requires access to internal types — verify InternalsVisibleTo
/// is configured in exam-service.csproj before running.
/// </summary>
public class ExamServiceBulkInsertTests
{
    [Fact]
    public async Task BulkInsert_AllValid_ReturnsCreatedArray()
    {
        // Arrange: create in-memory ExamDbContext with a section
        var options = new DbContextOptionsBuilder<ExamDbContext>()
            .UseInMemoryDatabase(databaseName: $"BulkTest_{Guid.NewGuid()}")
            .Options;
        await using var context = new ExamDbContext(options);
        var sectionId = Guid.NewGuid();
        context.ExamSections.Add(new ExamSection { Id = sectionId, Idx = 1, ExamId = Guid.NewGuid(), Title = "Test" });
        await context.SaveChangesAsync();
        var service = new exam_service.Features.Exams.AdminEndpoint.QuestionEndpoint.AdminQuestionService(context);

        var questions = new List<DtoAdmin.AdminQuestionUpsert>
        {
            new(sectionId, null, QuestionType.MultipleChoiceSingle, "READING", 2, "Q1", null, null, null, null, null, null),
            new(sectionId, null, QuestionType.MultipleChoiceSingle, "READING", 2, "Q2", null, null, null, null, null, null),
            new(sectionId, null, QuestionType.SummaryCompletion, "READING", 2, "Complete [1]", null, new Dictionary<string, string[]?> { { "1", new[] { "answer" } } }, null, null, null),
        };

        // Act
        var result = await service.BulkInsertAsync(CancellationToken.None,
            new BulkInsertRequest(sectionId, questions));

        // Assert
        var okResult = (Microsoft.AspNetCore.Http.HttpResults.Ok<ApiResultDto>)result;
        var data = (dynamic)okResult.Value!.Data!;
        Assert.Equal(3, ((IEnumerable<object>)data.created).Count());
        Assert.Empty((IEnumerable<object>)data.errors);
    }

    [Fact]
    public async Task BulkInsert_OneInvalid_ReturnsPartialSuccess()
    {
        // Arrange
        var options = new DbContextOptionsBuilder<ExamDbContext>()
            .UseInMemoryDatabase(databaseName: $"BulkTest_{Guid.NewGuid()}")
            .Options;
        await using var context = new ExamDbContext(options);
        var sectionId = Guid.NewGuid();
        context.ExamSections.Add(new ExamSection { Id = sectionId, Idx = 1, ExamId = Guid.NewGuid(), Title = "Test" });
        await context.SaveChangesAsync();
        var service = new exam_service.Features.Exams.AdminEndpoint.QuestionEndpoint.AdminQuestionService(context);

        var questions = new List<DtoAdmin.AdminQuestionUpsert>
        {
            new(sectionId, null, QuestionType.MultipleChoiceSingle, "READING", 2, "Q1", null, null, null, null, null, null),
            new(sectionId, null, QuestionType.SummaryCompletion, "READING", 2, "Q2 invalid (no blanks)", null, null, null, null, null, null), // INVALID: missing blankAcceptTexts
            new(sectionId, null, QuestionType.MultipleChoiceSingle, "READING", 2, "Q3", null, null, null, null, null, null),
        };

        // Act
        var result = await service.BulkInsertAsync(CancellationToken.None,
            new BulkInsertRequest(sectionId, questions));

        // Assert
        var okResult = (Microsoft.AspNetCore.Http.HttpResults.Ok<ApiResultDto>)result;
        var data = (dynamic)okResult.Value!.Data!;
        Assert.Equal(2, ((IEnumerable<object>)data.created).Count());
        Assert.Single((IEnumerable<object>)data.errors);
    }

    [Fact]
    public async Task BulkInsert_EmptyQuestions_ReturnsEmptyArrays()
    {
        // Arrange
        var options = new DbContextOptionsBuilder<ExamDbContext>()
            .UseInMemoryDatabase(databaseName: $"BulkTest_{Guid.NewGuid()}")
            .Options;
        await using var context = new ExamDbContext(options);
        var sectionId = Guid.NewGuid();
        context.ExamSections.Add(new ExamSection { Id = sectionId, Idx = 1, ExamId = Guid.NewGuid(), Title = "Test" });
        await context.SaveChangesAsync();
        var service = new exam_service.Features.Exams.AdminEndpoint.QuestionEndpoint.AdminQuestionService(context);

        // Act
        var result = await service.BulkInsertAsync(CancellationToken.None,
            new BulkInsertRequest(sectionId, new List<DtoAdmin.AdminQuestionUpsert>()));

        // Assert
        var okResult = (Microsoft.AspNetCore.Http.HttpResults.Ok<ApiResultDto>)result;
        var data = (dynamic)okResult.Value!.Data!;
        Assert.Empty((IEnumerable<object>)data.created);
        Assert.Empty((IEnumerable<object>)data.errors);
    }
}
```

- [ ] **Step 3: Build + run**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
dotnet build services/attempt-service.Tests/attempt-service.Tests.csproj
dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj --no-build --filter "FullyQualifiedName~ExamServiceBulkInsertTests"
```

Expected: 3 tests passed (73 baseline + 3 new = 76).

If `InMemoryDatabase` provider not available, skip this task and add a TODO comment — covered by manual smoke test in Phase 10.

- [ ] **Step 4: Verify no deprecated warnings**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj --no-build 2>&1 | grep -iE "warning|deprecat" | head -5
```

Expected: no output from new tests.

- [ ] **Step 5: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/attempt-service.Tests/ExamServiceBulkInsertTests.cs
git commit -m "test(exam): add xUnit tests for BulkInsertAsync partial-success semantics"
```

---
