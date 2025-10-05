using System.Text.Json;
using attempt_service.Contracts.Attempt;
using attempt_service.Domain.Entities;
using attempt_service.Domain.Enums;
using attempt_service.Features.Helpers;
using attempt_service.Infrastructure.Persistence;
using Google.Protobuf;
using Microsoft.AspNetCore.Mvc.Formatters;
using Microsoft.EntityFrameworkCore;
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
}

public class AttemptService(
    AttemptDbContext context,
    IHttpClientFactory client,
    ExamInternal.ExamInternalClient grpc,
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
                    new AttemptStartResponse(existedStartedAttempt.Id, safeEl,
                        existedStartedAttempt.StartedAt, timeLeft)
                ));
            }
            catch
            {
                try
                {
                    var dto = existedStartedAttempt.PaperJson.RootElement
                        .Deserialize<InternalExamDto.InternalDeliveryExam>(new JsonSerializerOptions
                            {PropertyNameCaseInsensitive = true}) ;
                    if (dto == null) return Results.NotFound(new ApiResultDto(false, "Not found", null!));
                    using var sanitized = JsonSerializer.SerializeToDocument(dto, new JsonSerializerOptions(JsonSerializerDefaults.Web));
                    var safeEl = sanitized.RootElement.Clone();
                    
                    //time left
                    var deadline = existedStartedAttempt.StartedAt.AddSeconds(existedStartedAttempt.DurationSec);
                    var timeLeft = (int)Math.Max(0, (deadline - DateTime.UtcNow).TotalSeconds);
                    return Results.Ok(new ApiResultDto(true, "Continue your previous attempt",
                        new AttemptStartResponse(existedStartedAttempt.Id, safeEl,
                            existedStartedAttempt.StartedAt, timeLeft)
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
                attempts.Id, attempts.Status, safeEl, answer, attempts.StartedAt, timeLeftSec
            )));
        }
        catch
        {
            try
            {
                var dto = attempts.PaperJson.RootElement.Deserialize<InternalExamDto.InternalDeliveryExam>(
                    new JsonSerializerOptions {PropertyNameCaseInsensitive = true}
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
        var attempt = await context.Attempts.FirstOrDefaultAsync(x => x.Id == attemptId && x.UserId == userId, cancellationToken: token);
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
        Dictionary<int, BuildIndex.QMeta> index;
        try
        {
            var parser = new JsonParser(JsonParser.Settings.Default!.WithIgnoreUnknownFields(true)!);
            var proto = parser.Parse<InternalDeliveryExam>(attempt.PaperJson.RootElement.GetRawText()) ??
                        new InternalDeliveryExam();
            index = BuildIndex.BuildIndexFromProto(proto);
        }
        catch
        {
            var dto = attempt.PaperJson.RootElement.Deserialize<InternalExamDto.InternalDeliveryExam>(
                new JsonSerializerOptions {PropertyNameCaseInsensitive = true});
            if (dto == null)
                return Results.Problem("Bad snapshot scheme", statusCode: StatusCodes.Status500InternalServerError);
            index = BuildIndex.BuildIndexFromDto(dto);
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
            if (!index.TryGetValue(ans.QuestionId, out var meta))
            {
                rejected.Add($"Unknown question {ans.QuestionId}");
                continue;
            }
            if (ans.SelectedOptionIds is not null)
            {
                if (ans.SelectedOptionIds.Any(x => !meta.OptionIds.Contains(x)))
                    rejected.Add($"Invalid option for Q{ans.QuestionId}");
                if (BuildIndex.IsSingleChoice(meta.Type) && ans.SelectedOptionIds.Count > 1)
                    rejected.Add($"Too many options for single-choice Q{ans.QuestionId}");
            }
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
                eachExistedAnswer = new AttemptAnswer()
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
                    : eachIncomingAnswer.SelectedOptionIds.Distinct().OrderBy(x=>x).ToList();
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

        if (attempt.Status is AttemptStatus.Started )
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
            return Results.Problem("Snapshot is missing", statusCode:StatusCodes.Status500InternalServerError);
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

        existedAttempt.Status = AttemptStatus.Submitted;
        existedAttempt.SubmittedAt = DateTime.UtcNow;
        await context.SaveChangesAsync(token);
        // thêm hàm chầm điểm chỗ này 

        deadline = existedAttempt.StartedAt.AddSeconds(existedAttempt.DurationSec);
        timeLeftSec = (int)Math.Max(0, (deadline - DateTime.UtcNow).TotalSeconds);
        return Results.Ok(new ApiResultDto(true, "Submitted", new
        {
            attemptId = existedAttempt.Id,
            status = existedAttempt.Status,
            finishedAt = existedAttempt.SubmittedAt,
            timeUsedSec = existedAttempt.SubmittedAt - existedAttempt.StartedAt,
            timeLeftSec
        }));
    }
    
    
    
}

