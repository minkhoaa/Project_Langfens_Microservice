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

    public async Task<IResult> GetAttemptById(AttemptGetRequest request, CancellationToken token)
    {
        var attempts = await context.Attempts.AsNoTracking()
            .Where(x => x.Id == request.AttemptId && x.UserId == request.UserId)
            .FirstOrDefaultAsync(token);

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

    public async Task<IResult> Autosave(int attemptId, int userId, AutosaveRequest req, CancellationToken token)
    {
        var record = await context.Attempts
            .FirstOrDefaultAsync(x => x.Id == attemptId && x.UserId == userId, token);
        if (record is null)
            return Results.NotFound(new ApiResultDto(false, "Not found", null!));
        var deadline = record.StartedAt.AddSeconds(record.DurationSec);
        var timeLeft = (int)Math.Max(0, (deadline - DateTime.UtcNow).TotalSeconds);
        if (timeLeft <= 0)
        {
            if (record.Status is AttemptStatus.Started or AttemptStatus.InProgress)
            {
                record.Status = AttemptStatus.Expired;
                await context.SaveChangesAsync(token);
            }
            return Results.Conflict(new ApiResultDto(false, "Attempt expired", null!));
        }
        if (record.Status == AttemptStatus.Submitted || record.Status == AttemptStatus.Graded)
            return Results.Conflict(new ApiResultDto(false, "Attempt is already submitted", null!));
        if (record.PaperJson is null)
            return Results.Problem("Snapshot missing", statusCode: 500);

        var index = QuestionIndex.Build(record.PaperJson);
        var incoming = req.Answers ?? new List<AnswerItem>();
        if (incoming.Count == 0) return Results.Ok(new ApiResultDto(true, "No changes", null!));
        var rejected = new List<string>();
        foreach (var answerItem in incoming) 
        {
            if (!index.TryGetValue(answerItem.QuestionId, out var meta))
            {
                rejected.Add($"Unknown question {answerItem.QuestionId}");
                continue;
            }

            if (answerItem.SelectedOptionIds is not null)
            {
                if (answerItem.SelectedOptionIds.Any(x => !meta.OptionIds.Contains(x))) 
                    rejected.Add($"Invalid option for Q{answerItem.QuestionId}");
                if (meta.Type == "SINGLE" && answerItem.SelectedOptionIds.Count > 1)
                    rejected.Add($"Too many options for single-choice Q{answerItem.QuestionId}");
            }
        }

        if (rejected.Count > 0) return Results.UnprocessableEntity(new ApiResultDto(false, "Invalid payload", null!));
        var ids = incoming.Select(x => x.QuestionId).Distinct().ToArray();
        var rows = await context.AttemptAnswers
            .Where(x => x.AttemptId == attemptId && ids.Contains(x.QuestionId))
            .ToDictionaryAsync(x=>x.QuestionId, token);
        var saved = 0;
        var skipped = 0;
        foreach (var answer in incoming)
        {
            var meta = index[answer.QuestionId];
            if (!rows.TryGetValue(answer.QuestionId, out var row))
            {
                row = new AttemptAnswer()
                {
                    AttemptId = attemptId,
                    QuestionId = answer.QuestionId,
                    SectionId = meta.SectionId,
                    SelectedOptionIds = null!,
                    TextAnswer = null!
                };
                context.AttemptAnswers.Add(row);
                rows[answer.QuestionId] = row; 
            }

            bool changed = false;
            if (answer.SelectedOptionIds is not null)
            {
                row.SelectedOptionIds = answer.SelectedOptionIds.Count == 0
                    ? new List<int>()
                    : answer.SelectedOptionIds.ToList();
                changed = true;
            }

            if (answer.TextAnswer is not null)
            {
                row.TextAnswer = answer.TextAnswer;
                changed = true;
            }

            if (changed)
            {
                row.IsCorrect = null!;
                row.AwardedPoints = null!;
                saved++;
            }
            else
            {
                skipped++; 
            }
        }

        if (record.Status == AttemptStatus.Started) 
            record.Status = AttemptStatus.InProgress;
        await context.SaveChangesAsync(token);
        timeLeft = (int)Math.Max(0, (deadline - DateTime.UtcNow).TotalSeconds);
        return Results.Ok(new ApiResultDto(true, "Autosaved", new {
            saved,
            skipped,
            rejected = Array.Empty<string>(),
            timeLeftSec = timeLeft
        }));
    }

    public Task<IResult> Submit(int attemptId, int userId, CancellationToken token)
    {
        throw new NotImplementedException();
    }
    
    
    
}

