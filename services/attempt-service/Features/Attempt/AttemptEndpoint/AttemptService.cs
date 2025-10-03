using System.Text.Json;
using attempt_service.Contracts.Attempt;
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

    public Task<IResult> Autosave(int attemptId, int userId, AutosaveRequest req, CancellationToken token)
    {
        throw new NotImplementedException();
    }

    public Task<IResult> Submit(int attemptId, int userId, CancellationToken token)
    {
        throw new NotImplementedException();
    }
}