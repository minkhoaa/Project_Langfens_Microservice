using System.Collections.Immutable;
using System.Formats.Asn1;
using System.Text.Json;
using attempt_service.Contracts.Attempt;
using attempt_service.Domain.Entities;
using attempt_service.Domain.Enums;
using attempt_service.Features.Helpers;
using attempt_service.Infrastructure.Persistence;
using Google.Protobuf;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration.Ini;
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
            var dto = attempts.PaperJson.RootElement.Deserialize<InternalExamDto.InternalDeliveryExam>(new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            });
            if (dto == null)
                return Results.NotFound(new ApiResultDto(false, "Not found snapshot", null!)) ;
            var sanitized = InternalExamDto.SnapshotSanitizer.Sanitize(dto);
            using var doc = JsonSerializer.SerializeToDocument(sanitized, new JsonSerializerOptions(JsonSerializerDefaults.Web));
            var safeEl = doc.RootElement.Clone();
            
            
            var answers = await context.AttemptAnswers.AsNoTracking()
                .Where(x => x.AttemptId == attempts.Id)
                .Select(x => new AnswerItem(
                    x.QuestionId,                
                    x.SectionId,
                    x.SelectedOptionIds,
                    x.TextAnswer
                ))
                .ToListAsync(token);
            var deadline = attempts.StartedAt.AddSeconds(attempts.DurationSec);
            var timeLeft = (int)Math.Max(0, (deadline - DateTime.UtcNow).TotalSeconds);
            return Results.Ok(new ApiResultDto(true, "Success", new AttemptGetResponse(
                attempts.Id, attempts.Status, safeEl, answers, attempts.StartedAt, timeLeft
            )));
        }
        catch
        {
            try
            {
                var elements = gateway.GetExamSnapshotAsync(attempts.ExamId, token);
                var answers = context.AttemptAnswers.AsNoTracking().Where(x => x.AttemptId == attempts.Id)
                    .Select(answer =>
                        new AnswerItem(answer.QuestionId, 
                            answer.SectionId, 
                            answer.SelectedOptionIds, 
                            answer.TextAnswer))
                    .ToListAsync(token);
                await Task.WhenAll(elements, answers);
                var parsed = JsonFormatter.Default!.Format(GrpcSnapshotSanitizer.Sanitize(elements.Result));
                using var doc = JsonDocument.Parse(parsed!);
                var safeEle = doc.RootElement.Clone();
                var deadline = attempts.StartedAt.AddSeconds(attempts.DurationSec);
                var timeLeft = (int)Math.Max(0, (deadline - DateTime.UtcNow).TotalSeconds);
                return Results.Ok(new ApiResultDto(true, "Success",
                    
                    new AttemptGetResponse(
                        attempts.Id, attempts.Status, safeEle, answers.Result, attempts.StartedAt, timeLeft
                    )));
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
        var attemptRecord = await context.Attempts
            .FirstOrDefaultAsync(x => x.Id == attemptId && x.UserId == userId, token);
        // validate attempt
        if (attemptRecord is null)
            return Results.NotFound(new ApiResultDto(false, "Not found attempt record", null!));
        var deadLine = attemptRecord.StartedAt.AddSeconds(attemptRecord.DurationSec);
        var timeLeftSecond = (int)Math.Max(0, (deadLine - DateTime.UtcNow).TotalSeconds);
        if (timeLeftSecond <= 0)
        {
            if (attemptRecord.Status is AttemptStatus.Started or AttemptStatus.InProgress)
            {
                attemptRecord.Status = AttemptStatus.Expired;
                await context.SaveChangesAsync(token);
            }
            return Results.Conflict(new ApiResultDto(false, "Expired", null!));
        }

        if (attemptRecord.Status is AttemptStatus.Submitted or AttemptStatus.Graded)
            return Results.Conflict(new ApiResultDto(false, "Already submitted", null!));
        if (attemptRecord.PaperJson is null)
            return Results.NotFound(new ApiResultDto(false, "Snapshot missing", null!));
        
        // lay hashset question id cua snapshot, 
        var snapshotQuestionId = QuestionIndex.Build(attemptRecord.PaperJson);
        
        // lay list answer cua incoming request
        var incomingAnswer = req.Answers ?? new List<AnswerItem>();
        var rejectedAnswer = new List<string>();
        // validate incoming request
        if (incomingAnswer.Count == 0)
            return Results.Ok(new ApiResultDto(true, "No changes", null!));
        
        // check tung item trong answer co vi pham dieu dieu kien khong
        foreach (var item in incomingAnswer)
        {
            if (!snapshotQuestionId.TryGetValue(item.QuestionId, out var value))
            {
                rejectedAnswer.Add($"Unknown question {item.QuestionId}");
                continue;
            }
            if (item.SelectedOptionIds is not null)
            {
                if (item.SelectedOptionIds.Any(x=> !value.OptionIds.Contains(x))) 
                    rejectedAnswer.Add($"Invalid option for Q{item.QuestionId}");
                if (value.Type == "SINGLE" && item.SelectedOptionIds.Count > 1)
                    rejectedAnswer.Add($"Too many options for single-choice Q{item.QuestionId}");
            }
        }

        if (rejectedAnswer.Count > 0)
            return Results.UnprocessableEntity(new ApiResultDto(false, "Invalid payload", rejectedAnswer));
        
        // build list incoming question id
        var incomingQuestionId = incomingAnswer.Select(x => x.QuestionId).Distinct().ToList();
        
        // full info for incoming question id 
        var answerExistedInDatabase = await context.AttemptAnswers
            .Where(x => x.AttemptId == attemptId && incomingQuestionId.Contains(x.QuestionId))
            .ToDictionaryAsync(x => x.QuestionId, token);
        int savedItem = 0, skippedItem = 0;

        foreach (var incomingItem in incomingAnswer)
        {
            var meta = snapshotQuestionId[incomingItem.QuestionId];
            // neu chua ton tai, tao moi
            if (!answerExistedInDatabase.TryGetValue(incomingItem.QuestionId, out var existedAnswer))
            {
                existedAnswer = new AttemptAnswer()
                {
                    AttemptId = attemptId,
                    SectionId = meta.SectionId,
                    AwardedPoints = null,
                    TextAnswer = null,
                    QuestionId = incomingItem.QuestionId
                };
                context.AttemptAnswers.Add(existedAnswer);
                answerExistedInDatabase[incomingItem.QuestionId] = existedAnswer; 
            }
            // apply changes
            var changed = false;
            if (incomingItem.SelectedOptionIds is not null)
            {
                existedAnswer.SelectedOptionIds =
                    incomingItem.SelectedOptionIds.Count == 0
                        ? new List<int>()
                        : incomingItem.SelectedOptionIds.ToList();
                changed = true;
            }
            if (incomingItem.TextAnswer is not null)
            {
                existedAnswer.TextAnswer = incomingItem.TextAnswer;
                changed = true;

            }
            if (changed)
            {
                existedAnswer.IsCorrect = null;
                existedAnswer.SectionId = meta.SectionId;
                existedAnswer.AwardedPoints = null;
                savedItem++;
            }
            else skippedItem++; 
        }
        // set status
        if (attemptRecord.Status == AttemptStatus.Started)
            attemptRecord.Status = AttemptStatus.InProgress;
        attemptRecord.UpdatedAt = DateTime.UtcNow;
        await context.SaveChangesAsync(token);
        timeLeftSecond = (int)Math.Max(0, (deadLine - DateTime.UtcNow).TotalSeconds);
        return Results.Ok(new ApiResultDto(true, "Autosaved",
            new
            {
                savedItem,
                skippedItem,
                rejected = rejectedAnswer,
                timeLeftSec = timeLeftSecond,
                updateAt = attemptRecord.UpdatedAt
            }
        ));
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
            timeUsedSec = existedAttempt.SubmittedAt,
            timeLeftSec
        }));
    }
    
    
    
}

