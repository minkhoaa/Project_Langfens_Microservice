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
    public Task<IResult> StartAttempt(
        AttemptStartRequest request,
        CancellationToken token,
        int userId
    );
}

public class AttemptService(
    AttemptDbContext context,
    IHttpClientFactory client,
    ExamInternal.ExamInternalClient grpc,
    IExamGateway gateway
    ) : IAttemptService
{
    private readonly HttpClient _client = client.CreateClient("ExamServiceInternal");
    private readonly IExamGateway _gateway = gateway; 
    public async Task<IResult> StartAttempt(
        AttemptStartRequest request,
        CancellationToken token,
        int userId
        )
    {
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
                var parser = new JsonParser(JsonParser.Settings.Default.WithIgnoreUnknownFields(true));
                var parsed =
                    parser.Parse<InternalDeliveryExam>(existedStartedAttempt.PaperJson.RootElement.GetRawText());
                var safeJson = JsonFormatter.Default.Format(GrpcSnapshotSanitizer.Sanitize(parsed!));
                var safeEl = JsonDocument.Parse(safeJson).RootElement.Clone();
                return Results.Ok(new ApiResultDto(true, "Continue your previous attempt",
                    new AttemptStartResponse(existedStartedAttempt.Id, safeEl,
                        existedStartedAttempt.StartedAt, existedStartedAttempt.DurationSec)
                ));
                
            }
            catch 
            {
                try
                {
                    var dto = existedStartedAttempt.PaperJson.RootElement
                        .Deserialize<InternalExamDto.InternalDeliveryExam>();
                    var dtoSafeDoc =
                        JsonSerializer.SerializeToDocument(InternalExamDto.SnapshotSanitizer.Sanitize(dto));
                    var safeEl = dtoSafeDoc.RootElement.Clone();
                    return Results.Ok(new ApiResultDto(true, "Continue your previous attempt",
                        new AttemptStartResponse(existedStartedAttempt.Id, safeEl,
                            existedStartedAttempt.StartedAt, existedStartedAttempt.DurationSec)
                    ));
                }
                catch
                {
                    return Results.Ok(new ApiResultDto(true, "Continue your previous attempt",
                        existedStartedAttempt.PaperJson.RootElement.Clone()));
                }
            }

        }
        // var url = $"/api/internal/exams/{request.ExamId}/delivery?showAnswers=true";
        // using var doc = await _client.GetFromJsonAsync<JsonDocument>(url, token);
        // if (doc is null || !doc.RootElement.TryGetProperty("data", out var dataEl))
        //     return Results.BadRequest(new ApiResultDto(false, "Missing data", null!));
        // var snapShot = dataEl.Deserialize<InternalExamDto.InternalDeliveryExam>();
        // if (snapShot is null) 
        //     return Results.BadRequest(new ApiResultDto(false, "Invalid data", null!));
        var snapShot = await _gateway.GetExamSnapshotAsync(request.ExamId, token);
        var json = JsonFormatter.Default.Format(GrpcSnapshotSanitizer.Sanitize(snapShot));
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
                attempt.StartedAt, attempt.DurationSec)));
    }

  
}