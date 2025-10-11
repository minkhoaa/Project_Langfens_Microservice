using System.Numerics;
using System.Security.Cryptography;
using System.Text.Json;
using attempt_service.Contracts.Attempt;
using attempt_service.Domain.Entities;
using attempt_service.Domain.Enums;
using attempt_service.Features.Helpers;
using attempt_service.Infrastructure.Persistence;
using Google.Protobuf;
using Google.Protobuf.WellKnownTypes;
using Microsoft.EntityFrameworkCore;
using Microsoft.VisualBasic;
using Npgsql.Replication;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Exam.InternalExamDto;
using Shared.Grpc.ExamInternal;

namespace attempt_service.Features.Attempt.AttemptEndpoint;

public interface IAttemptService
{
    Task<IResult> StartAttempt(AttemptStartRequest request, CancellationToken token, int userId);
    Task<IResult> GetAttemptById(AttemptGetRequest request, CancellationToken token);
    Task<IResult> Autosave(int attemptId, int userId, AutosaveRequest req, CancellationToken token);
    Task<IResult> Submit(int attemptId, int userId, CancellationToken token);
    Task<IResult> GetResult(int attemptId, int userId, CancellationToken token);
    Task<IResult> GetAttemptList(int userId, int page, int pageSize, string? status, int? examId, CancellationToken token);
}

public class AttemptService(
    AttemptDbContext context,
    IExamGateway gateway
) : IAttemptService
{
    public async Task<IResult> StartAttempt(
        AttemptStartRequest request,
        CancellationToken token,
        int userId
    )
    {
        // using GRPC for internal communication
        var existedStartedAttempt = await context.Attempts.AsNoTracking().Where(attempt =>
            attempt.ExamId == request.ExamId
            && attempt.Status == AttemptStatus.Started
            && attempt.UserId == userId).FirstOrDefaultAsync(token);
        if (existedStartedAttempt != null)
        {
            if (existedStartedAttempt.PaperJson is null)
                return Results.BadRequest(
                    new ApiResultDto(false, "Stored snapshot is empty", null!)
                );
            try
            {
                var parser = new JsonParser(JsonParser.Settings.Default!.WithIgnoreUnknownFields(true)!);
                var parsed =
                    parser.Parse<InternalDeliveryExam>(existedStartedAttempt.PaperJson.RootElement.GetRawText());
                var safeJson = JsonFormatter.Default!.Format(GrpcSnapshotSanitizer.Sanitize(parsed!));
                var safeEl = JsonDocument.Parse(safeJson!).RootElement.Clone();
                var deadline = existedStartedAttempt.StartedAt.AddSeconds(existedStartedAttempt.DurationSec);
                var timeLeft = (int)Math.Max(0, (deadline - DateTime.UtcNow).TotalSeconds);
                return Results.Ok(new ApiResultDto(true, "Continue your previous attempt",
                    new AttemptStartResponse(
                        existedStartedAttempt.Id,
                        safeEl,
                        existedStartedAttempt.StartedAt,
                        existedStartedAttempt.DurationSec,
                        timeLeft
                        )
                ));
            }
            catch
            {
                try
                {
                    var dto = existedStartedAttempt.PaperJson.RootElement
                        .Deserialize<InternalExamDto.InternalDeliveryExam>(new JsonSerializerOptions
                        { PropertyNameCaseInsensitive = true });
                    if (dto == null) return Results.NotFound(new ApiResultDto(false, "Not found", null!));
                    using var sanitized =
                        JsonSerializer.SerializeToDocument(dto, new JsonSerializerOptions(JsonSerializerDefaults.Web));
                    var safeEl = sanitized.RootElement.Clone();

                    //time left
                    var deadline = existedStartedAttempt.StartedAt.AddSeconds(existedStartedAttempt.DurationSec);
                    var timeLeft = (int)Math.Max(0, (deadline - DateTime.UtcNow).TotalSeconds);
                    return Results.Ok(new ApiResultDto(true, "Continue your previous attempt",
                        new AttemptStartResponse(
                            existedStartedAttempt.Id,
                            safeEl,
                            existedStartedAttempt.StartedAt,
                            existedStartedAttempt.DurationSec,
                            timeLeft
                            )
                    ));
                }
                catch
                {
                    return Results.Ok(new ApiResultDto(true, "Continue your previous attempt",
                        existedStartedAttempt.PaperJson.RootElement.Clone()));
                }
            }
        }

        var snapShot = await gateway.GetExamSnapshotAsync(request.ExamId, token);
        var json = JsonFormatter.Default!.Format(GrpcSnapshotSanitizer.Sanitize(snapShot));
        using var doc = JsonDocument.Parse(json!);
        var safeElement = doc.RootElement.Clone();
        var attempt = new Domain.Entities.Attempt
        {
            UserId = userId,
            ExamId = request.ExamId,
            Status = AttemptStatus.Started,
            StartedAt = DateTime.UtcNow,
            DurationSec = snapShot.DurationMin * 60,
            PaperJson = JsonDocument.Parse(JsonFormatter.Default.Format(snapShot)!)
        };
        context.Attempts.Add(attempt);
        await context.SaveChangesAsync(token);
        return Results.Ok(new ApiResultDto(
            true, "Success",
            new AttemptStartResponse(attempt.Id, safeElement,
                attempt.StartedAt,
                attempt.DurationSec,
                (int)Math.Max(0, (attempt.StartedAt.AddSeconds(attempt.DurationSec) - DateTime.UtcNow).TotalSeconds)
            )));
    }

    public async Task<IResult> GetAttemptById(
        AttemptGetRequest request,
        CancellationToken token)
    {
        var attempts = await context.Attempts.AsNoTracking()
            .Where(x => x.Id == request.AttemptId && x.UserId == request.UserId)
            .FirstOrDefaultAsync(token);
        // validate attempt
        if (attempts == null)
            return Results.NotFound(new ApiResultDto(false, "Not found", null!));
        if (attempts.PaperJson is null)
            return Results.NotFound(new ApiResultDto(false, "Not found snapshot", null!));
        try
        {
            // Parse snapshot đã lưu -> sanitize -> serialize lại thành JsonDocument
            var parser = new JsonParser(JsonParser.Settings.Default!.WithIgnoreUnknownFields(true)!);
            var parsed = parser.Parse<InternalDeliveryExam>(attempts.PaperJson.RootElement.GetRawText());
            var jsonFormatted = JsonFormatter.Default!.Format(GrpcSnapshotSanitizer.Sanitize(parsed!));
            using var doc = JsonDocument.Parse(jsonFormatted!);
            var safeEl = doc.RootElement.Clone();

            var answer = await context.AttemptAnswers.AsNoTracking()
                .Where(x => x.AttemptId == attempts.Id)
                .Select(x => new AnswerItem(x.QuestionId, x.SectionId, x.SelectedOptionIds, x.TextAnswer))
                .ToListAsync(token);
            var deadline = attempts.StartedAt.AddSeconds(attempts.DurationSec);
            var timeLeftSec = (int)Math.Max(0, (deadline - DateTime.UtcNow).TotalSeconds);
            return Results.Ok(new ApiResultDto(true, "Success", new AttemptGetResponse(
                attempts.Id,
                attempts.Status,
                safeEl,
                answer,
                attempts.StartedAt,
                timeLeftSec
            )));
        }
        catch
        {
            try
            {
                var dto = attempts.PaperJson.RootElement.Deserialize<InternalExamDto.InternalDeliveryExam>(
                    new JsonSerializerOptions { PropertyNameCaseInsensitive = true }
                );
                if (dto == null) return Results.NotFound(new ApiResultDto(false, "NOt found snapshot", null!));
                var sanitized = InternalExamDto.SnapshotSanitizer.Sanitize(dto);
                using var doc = JsonSerializer.SerializeToDocument(sanitized);
                var safeEl = doc.RootElement.Clone();
                var answer = await context.AttemptAnswers.AsNoTracking()
                    .Where(x => x.AttemptId == attempts.Id)
                    .Select(x => new AnswerItem(
                        x.QuestionId,
                        x.SectionId,
                        x.SelectedOptionIds,
                        x.TextAnswer
                    )).ToListAsync(token);
                var deadline = attempts.StartedAt.AddSeconds(attempts.DurationSec);
                var timeLeft = (int)Math.Max(0, (deadline - DateTime.UtcNow).TotalSeconds);
                return Results.Ok(new ApiResultDto(true, "Success", new
                    AttemptGetResponse(attempts.Id, attempts.Status, safeEl, answer, attempts.StartedAt, timeLeft)
                ));
            }
            catch (Exception e)
            {
                return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
            }
        }
    }

    public async Task<IResult> Autosave(
        int attemptId,
        int userId,
        AutosaveRequest req,
        CancellationToken token)
    {
        var attempt = await context.Attempts.FirstOrDefaultAsync(x => x.Id == attemptId && x.UserId == userId,
            cancellationToken: token);
        if (attempt == null)
            return Results.NotFound(new ApiResultDto(false, "Not found existed attempt", null!));
        var deadline = attempt.StartedAt.AddSeconds(attempt.DurationSec);
        var timeLeftSec = (int)Math.Max(0, (deadline - DateTime.UtcNow).TotalSeconds);
        if (timeLeftSec <= 0)
        {
            if (attempt.Status is AttemptStatus.Started or AttemptStatus.InProgress)
            {
                attempt.Status = AttemptStatus.Expired;
                await context.SaveChangesAsync(token);
            }

            return Results.Conflict(new ApiResultDto(false, "Expired", null!));
        }

        if (attempt.Status is AttemptStatus.Submitted or AttemptStatus.Graded)
            return Results.Conflict(new ApiResultDto(false, "Attempt is already submitted", null!));
        if (attempt.PaperJson is null)
            return Results.Problem("Snapshot missing", statusCode: StatusCodes.Status500InternalServerError);

        //parse ra dto tiện cho việc autosave 
        Dictionary<int, IndexBuilder.QMeta> index;
        try
        {
            var parser = new JsonParser(JsonParser.Settings.Default!.WithIgnoreUnknownFields(true)!);
            var proto = parser.Parse<InternalDeliveryExam>(attempt.PaperJson.RootElement.GetRawText()) ??
                        new InternalDeliveryExam();
            index = IndexBuilder.BuildIndexFromProto(proto);
        }
        catch
        {
            var dto = attempt.PaperJson.RootElement.Deserialize<InternalExamDto.InternalDeliveryExam>(
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
            if (dto == null)
                return Results.Problem("Bad snapshot scheme", statusCode: StatusCodes.Status500InternalServerError);
            index = IndexBuilder.BuildIndexFromDto(dto);
        }

        // lay incoming answer
        var incoming = req.Answers ?? new List<AnswerItem>();
        if (incoming.Count == 0)
            return Results.Ok(new ApiResultDto(true, "No changes", null!));
        var rejected = new List<string>();
        // validate incoming answer, check loi
        if (index.Count == 0)
            return Results.Problem("Snapshot index is empty", statusCode: StatusCodes.Status500InternalServerError);
        foreach (var ans in incoming)
        {
            var err = AnswerValidator.Validate(ans, index);
            if (err != null) rejected.Add(err);
        }

        if (rejected.Count > 0)
            return Results.UnprocessableEntity(new ApiResultDto(false, "Invalid payload", rejected));

        // lay list question id cua incoming answer
        var incomingQuestionIds = incoming.Select(x => x.QuestionId).Distinct().ToHashSet();
        // lay thong tin nhung answer da co trong db
        var existedAnswer = await context.AttemptAnswers
            .Where(x => x.AttemptId == attemptId && incomingQuestionIds.Contains(x.QuestionId))
            .ToDictionaryAsync(x => x.QuestionId, token);
        var saved = 0;
        var skipped = 0;
        foreach (var eachIncomingAnswer in incoming)
        {
            // neu chua co trong db, them moi
            var meta = index[eachIncomingAnswer.QuestionId];
            if (!existedAnswer.TryGetValue(eachIncomingAnswer.QuestionId,
                    out var eachExistedAnswer))
            {
                eachExistedAnswer = new AttemptAnswer
                {
                    AttemptId = attemptId,
                    SectionId = meta.SectionId,
                    QuestionId = eachIncomingAnswer.QuestionId
                };
                context.AttemptAnswers.Add(eachExistedAnswer);
                existedAnswer[eachIncomingAnswer.QuestionId] = eachExistedAnswer;
            }

            var changed = false;
            if (eachIncomingAnswer.SelectedOptionIds is not null)
            {
                var newList = eachIncomingAnswer.SelectedOptionIds.Count == 0
                    ? new List<int>()
                    : eachIncomingAnswer.SelectedOptionIds.Distinct().OrderBy(x => x).ToList();
                var oldList = (eachExistedAnswer.SelectedOptionIds
                               ?? new List<int>()).OrderBy(x => x).ToList();
                if (!oldList.SequenceEqual(newList))
                {
                    eachExistedAnswer.SelectedOptionIds = newList;
                    changed = true;
                }
            }

            if (eachIncomingAnswer.TextAnswer is not null)
            {
                if (!string.Equals(eachExistedAnswer.TextAnswer, eachIncomingAnswer.TextAnswer,
                        StringComparison.Ordinal))
                {
                    eachExistedAnswer.TextAnswer = eachIncomingAnswer.TextAnswer;
                    changed = true;
                }
            }

            if (changed)
            {
                eachExistedAnswer.IsCorrect = null!;
                eachExistedAnswer.AwardedPoints = null!;
                eachExistedAnswer.SectionId = meta.SectionId;
                saved++;
            }
            else
            {
                skipped++;
            }
        }

        if (attempt.Status is AttemptStatus.Started)
            attempt.Status = AttemptStatus.InProgress;
        attempt.UpdatedAt = DateTime.UtcNow;
        await context.SaveChangesAsync(token);
        timeLeftSec = (int)Math.Max(0, (deadline - DateTime.UtcNow).TotalSeconds);
        return Results.Ok(new ApiResultDto(true, "Autosaved", new
        {
            savedItem = saved,
            skippedItem = skipped,
            rejected,
            timeLeftSec,
            updateAt = attempt.UpdatedAt
        }));

    }

    public async Task<IResult> Submit(int attemptId, int userId, CancellationToken token)
    {
        var existedAttempt =
            await context.Attempts.FirstOrDefaultAsync(x => x.Id == attemptId && x.UserId == userId, token);
        if (existedAttempt == null)
            return Results.NotFound(new ApiResultDto(false, "Not found existed attempt", null!));
        if (existedAttempt.PaperJson is null)
            return Results.Problem("Snapshot is missing", statusCode: StatusCodes.Status500InternalServerError);
        var deadline = existedAttempt.StartedAt.AddSeconds(existedAttempt.DurationSec);
        var timeLeftSec = (int)Math.Max(0, (deadline - DateTime.UtcNow).TotalSeconds);
        if (timeLeftSec <= 0)
        {
            if (existedAttempt.Status is AttemptStatus.Started or AttemptStatus.InProgress)
            {
                existedAttempt.Status = AttemptStatus.Expired;
                await context.SaveChangesAsync(token);
            }

            return Results.Conflict(new ApiResultDto(false, "Attempt is expired", null!));
        }

        if (existedAttempt.Status is AttemptStatus.Submitted or AttemptStatus.Graded)
        {
            return Results.Ok(new ApiResultDto(true, "Already submitted", new
            {
                attemptId = existedAttempt.Id,
                status = existedAttempt.Status,
                finishedAt = existedAttempt.SubmittedAt
            }));
        }

        // thêm hàm chầm điểm chỗ này 
        InternalDeliveryExam? proto = null;
        InternalExamDto.InternalDeliveryExam? dto = null;
        try
        {
            var parser = new JsonParser(JsonParser.Settings.Default!.WithIgnoreUnknownFields(true)!);
            proto = parser.Parse<InternalDeliveryExam>(existedAttempt.PaperJson.RootElement.GetRawText());

        }
        catch
        {
            dto = existedAttempt.PaperJson.RootElement
                .Deserialize<InternalExamDto.InternalDeliveryExam>(
                    new JsonSerializerOptions() { PropertyNameCaseInsensitive = true });
            if (dto is null)
                return Results.Problem("Bad snapshot",
                    statusCode: StatusCodes.Status500InternalServerError);
        }

        Dictionary<int, IndexBuilder.QMeta> index;
        AnswerKeyBuilder.AnswerKeyCompiled compiled;
        if (proto is not null)
        {
            index = IndexBuilder.BuildIndexFromProto(proto);
            compiled = AnswerKeyBuilder.FromProto(proto);
        }
        else
        {
            index = IndexBuilder.BuildIndexFromDto(dto!);
            compiled = AnswerKeyBuilder.FromDto(dto!);
        }

        if (index.Count == 0 || compiled.Keys.Count == 0)
            return Results.Problem("Snapshot index/keys empty",
                statusCode: StatusCodes.Status500InternalServerError);
        await using var transaction = await context.Database.BeginTransactionAsync(token);
        try
        {
            var answers = await context.AttemptAnswers
                .Where(x => x.AttemptId == attemptId)
                .ToListAsync(token);
            decimal awardedTotal = 0m;
            int correctCount = 0;
            int manualCount = 0;
            foreach (var ans in answers)
            {
                if (!index.TryGetValue(ans.QuestionId, out var meta)) continue;
                if (!compiled.Keys.TryGetValue(ans.QuestionId, out var key)) continue;
                if (!GraderRegistry.ByType.TryGetValue(meta.Type, out var grader))
                {
                    manualCount++;
                    continue;
                }
                var result = grader.Grade(ans, key);
                ans.AwardedPoints = result.AwardedPoints;
                ans.IsCorrect = result.IsCorrect;
                if (result.NeedsManualReview) manualCount++;
                awardedTotal += result.AwardedPoints;
                if (result.IsCorrect ?? false) correctCount++;
            }

            var answeredIds = answers.Select(x => x.QuestionId).ToHashSet();
            foreach (var questionId in compiled.Keys.Keys)
                if (!answeredIds.Contains(questionId))
                    context.AttemptAnswers.Add(new AttemptAnswer
                    {
                        AttemptId = attemptId,
                        QuestionId = questionId,
                        SectionId = index[questionId].SectionId,
                        AwardedPoints = 0,

                        IsCorrect = false
                    });
            existedAttempt.Status = (manualCount == 0) ? AttemptStatus.Graded : AttemptStatus.Submitted;
            existedAttempt.SubmittedAt = DateTime.UtcNow;
            existedAttempt.GradedAt = (manualCount == 0) ? DateTime.UtcNow : existedAttempt.GradedAt;
            existedAttempt.RawScore = awardedTotal;
            await context.SaveChangesAsync(token);
            await transaction.CommitAsync(token);
            deadline = existedAttempt.StartedAt.AddSeconds(existedAttempt.DurationSec);
            timeLeftSec = (int)Math.Max(0, (deadline - DateTime.UtcNow).TotalSeconds);
            var timeUsedSec = (int)(existedAttempt.SubmittedAt!.Value - existedAttempt.StartedAt).TotalSeconds;
            return Results.Ok(new ApiResultDto(true, "Submitted", new
            {
                attemptId = existedAttempt.Id,
                status = existedAttempt.Status,
                finishedAt = existedAttempt.SubmittedAt,
                timeUsedSec,
                timeLeftSec,
                awardedTotal,
                correctCount,
                totalPoints = compiled.TotalPoints,
                needsManualReview = manualCount
            }));
        }
        catch
        {
            await transaction.RollbackAsync(token);
            return Results.Problem("Errors while grading", statusCode: 500);
        }
    }

    public async Task<IResult> GetResult(int attemptId, int userId, CancellationToken token)
    {
        var existedAttempt = await context.Attempts.AsNoTracking()
            .Include(attempt => attempt.Answers)
            .FirstOrDefaultAsync(attempt => attempt.Id == attemptId && attempt.UserId == userId, token);
        if (existedAttempt == null)
            return Results.NotFound(new ApiResultDto(false, "Not found", null!));
        if (existedAttempt.PaperJson is null)
            return Results.NotFound(new ApiResultDto(false, "Snapshot is missing", null!));
        if (existedAttempt.Status is not (AttemptStatus.Submitted or AttemptStatus.Graded))
            return Results.Conflict(new ApiResultDto(false, "Attempt not submitted", null!));

        InternalDeliveryExam? proto = null;
        InternalExamDto.InternalDeliveryExam? dto = null;
        JsonElement fullSnapshot;
        try
        {
            var parser = new JsonParser(JsonParser.Settings.Default!.WithIgnoreUnknownFields(true)!);
            proto = parser.Parse<InternalDeliveryExam>(existedAttempt.PaperJson.RootElement.GetRawText());
            var fullJson = JsonFormatter.Default!.Format(proto!);
            using var fullDoc = JsonDocument.Parse(fullJson!);
            fullSnapshot = fullDoc.RootElement.Clone();
        }
        catch
        {
            dto = existedAttempt.PaperJson.RootElement.Deserialize<InternalExamDto.InternalDeliveryExam>(
                new JsonSerializerOptions() { PropertyNameCaseInsensitive = true });
            if (dto == null)
                return Results.Problem("Snapshot is bad", statusCode: StatusCodes.Status500InternalServerError);
            using var fullDoc = JsonSerializer.SerializeToDocument(dto);
            fullSnapshot = fullDoc.RootElement.Clone();
        }


        // build lại theo question id và thông tin trong snapshot 
        var compiled = proto is not null
            ? AnswerKeyBuilder.FromProto(proto)
            : AnswerKeyBuilder.FromDto(dto!);


        // lấy thông tin, số lượng câu hỏi, câu trả lời 
        var awardedPoints = existedAttempt.Answers.Sum(x => x.AwardedPoints ?? 0);
        var correctCount = existedAttempt.Answers.Count(x => x.IsCorrect == true);
        var totalScore = compiled.TotalPoints;
        var totalQuestion = compiled.Keys.Count;

        var averageScore = compiled.TotalPoints <= 0 ? 0m : Math.Round(awardedPoints / totalScore);

        return Results.Ok(new ApiResultDto(true, "Success",
                new AttemptResultResponse(
                    attemptId,
                    existedAttempt.Status,
                    existedAttempt.SubmittedAt,
                    existedAttempt.GradedAt,
                    existedAttempt.RawScore ?? 0m,
                    averageScore,
                    correctCount,
                    totalQuestion,
                    fullSnapshot,
                    existedAttempt.Answers.Select(x =>
                        new AnswerItem(x.QuestionId, x.SectionId, x.SelectedOptionIds, x.TextAnswer)).ToList())
            )
        );
    }

    public async Task<IResult> GetAttemptList(int userId, int page, int pageSize, string? status, int? examId, CancellationToken token)
    {
        page = page <= 0 ? 1 : page;
        pageSize = pageSize <= 0 ? 10 : Math.Min(pageSize, 100);
        var listAttempt = context.Attempts.AsNoTracking()
                            .Where(x => x.UserId == userId);
        if (!string.IsNullOrEmpty(status))
        {
            var s = status.Trim().ToUpperInvariant();
            var allowed = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            {
                AttemptStatus.Started,
                AttemptStatus.InProgress,
                AttemptStatus.Submitted,
                AttemptStatus.Graded,
                AttemptStatus.Expired,
                AttemptStatus.Cancelled
            };
            if (!allowed.Contains(s))
                return Results.BadRequest(new ApiResultDto(false, $"Invalid status '{status}'", null!));
            listAttempt.Where(x => x.Status == s);
        }
        if (examId.HasValue && examId.Value > 0)
            listAttempt.Where(x => x.ExamId == examId);

        var total = await listAttempt.CountAsync(token);
        var rows = await listAttempt.OrderByDescending(x => x.CreatedAt)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                     .Select(x => new // project tối thiểu, tính TimeLeft sau
                     {
                         x.Id,
                         x.ExamId,
                         x.Status,
                         x.StartedAt,
                         x.SubmittedAt,
                         x.GradedAt,
                         x.DurationSec,
                         x.RawScore,    
                         x.ScaledScore  
                     })
                    .ToListAsync(token);
        var now = DateTime.UtcNow;
        var items = rows.Select(x =>
        {
            int? timeLeft = null;
            if (x.Status is AttemptStatus.Started or AttemptStatus.InProgress)
            {
                var deadline = x.StartedAt.AddSeconds(x.DurationSec);
                timeLeft = (int)Math.Max(0, (deadline - now).TotalSeconds);
            }
            return new AttemptListItem(x.Id, x.ExamId, x.Status, x.StartedAt, x.SubmittedAt, x.ScaledScore);
        }).ToList();

        return Results.Ok(new ApiResultDto(true, "Success", items));

    }
}