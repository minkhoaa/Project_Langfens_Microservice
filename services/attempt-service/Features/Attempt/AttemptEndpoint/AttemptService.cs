using System.Text.Json;
using attempt_service.Contracts.Attempt;
using attempt_service.Domain.Entities;
using attempt_service.Domain.Enums;
using attempt_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Exam.InternalExamDto;

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
    IHttpClientFactory client) : IAttemptService
{
    private readonly HttpClient _client = client.CreateClient("ExamServiceInternal");
    
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
            var sanitizeFromSnapshot = JsonSerializer.SerializeToDocument(
                InternalExamDto.SnapshotSanitizer.Sanitize(
                    existedStartedAttempt.PaperJson?.RootElement
                        .Deserialize<InternalExamDto.InternalDeliveryExam>()!
                )
            );
            return Results.Ok(new ApiResultDto(
                true, "Continue your previous attempt",
                new AttemptStartResponse(existedStartedAttempt.Id,
                    sanitizeFromSnapshot.RootElement, existedStartedAttempt.StartedAt,
                    existedStartedAttempt.DurationSec)
            ));
        }
        var url = $"/api/internal/exams/{request.ExamId}/delivery?showAnswers=true";
        using var doc = await _client.GetFromJsonAsync<JsonDocument>(url, token);
        if (doc is null || !doc.RootElement.TryGetProperty("data", out var dataEl))
            return Results.BadRequest(new ApiResultDto(false, "Missing data", null!));
        var snapShot = dataEl.Deserialize<InternalExamDto.InternalDeliveryExam>();
        if (snapShot is null) 
            return Results.BadRequest(new ApiResultDto(false, "Invalid data", null!));

        var attempt = new Domain.Entities.Attempt
        {
            UserId = userId,
            ExamId = request.ExamId,
            Status = AttemptStatus.Started,
            StartedAt = DateTime.UtcNow,
            DurationSec = snapShot.DurationMin * 60,
            PaperJson = JsonSerializer.SerializeToDocument(snapShot)
        };
        context.Attempts.Add(attempt);
        await context.SaveChangesAsync(token);
        var sanitizeDoc = JsonSerializer.SerializeToDocument(InternalExamDto.SnapshotSanitizer.Sanitize(snapShot));
        return Results.Ok(new ApiResultDto(
            true, "Success", 
            new AttemptStartResponse(attempt.Id, sanitizeDoc.RootElement,
                attempt.StartedAt, attempt.DurationSec)));
    }

  
}