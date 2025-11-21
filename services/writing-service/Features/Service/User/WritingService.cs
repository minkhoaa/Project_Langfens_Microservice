using System.Formats.Asn1;
using System.Text;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Shared.ExamDto.Contracts;
using writing_service.Contracts;
using writing_service.Domains.Entities;
using writing_service.Features.Helper;
using writing_service.Infrastructure.Persistence;

namespace writing_service.Features.Service.User;

public interface IWritingService
{
    Task<IResult> WritingSubmit(WritingSubmissionRequest request, CancellationToken token);
    Task<IResult> StartWritingExam(Guid examId, CancellationToken token);
    
    
    
    
}

public class WritingService : IWritingService
{
    private readonly OpenRouterOptions _router;
    private readonly IHttpClientFactory _client;
    private readonly IUserContext _user;
    private readonly WritingDbContext _context;

    public WritingService(IOptions<OpenRouterOptions> router, 
        IHttpClientFactory client,
        IUserContext user,
        WritingDbContext context
        )
    {
        _client = client;
        _router = router.Value;
        _user = user;
        _context = context;
    }
    public async Task<IResult> WritingSubmit(WritingSubmissionRequest request,
        CancellationToken token)
    {
        
        var userId = _user.UserId;
        var exam = await _context.WritingExams.AsNoTracking().Where(x => x.Id == request.ExamId).FirstOrDefaultAsync(token)
                   ?? throw new Exception("Exam is not existed");
      
        var res = await WritingGraderHelper(new ContentSubmission{Answer = request.Answer, Task = exam.TaskText}, token);

        var submission = new WritingSubmission
        {
            UserId = userId,
            ExamId = request.ExamId,
            TaskTextSnapshot = exam.TaskText,
            EssayRaw = request.Answer,
            EssayNormalized = request.Answer,
            ExamType = exam.ExamType,
            WordCount = res.WordCount,
            Level = exam.Level,
            TimeSpentSeconds = request.TimeSpentSeconds,
            SubmittedAt = DateTime.UtcNow,
        };
        _context.WritingSubmissions.Add(submission);
        await _context.SaveChangesAsync(token);
        
        return Results.Ok(new ApiResultDto(true, "Submitted", new {submission.Id, res}));
    }

    public async Task<IResult> StartWritingExam(Guid examId, CancellationToken token)
    {
        var userId = _user.UserId;
        var response = await _context.WritingExams.AsNoTracking()
                              .Where(x => x.Id == examId)
                              .Select(x =>
                                  new StartWritingExamResponse(x.Id, x.Title, x.TaskText, x.Tags, x.CreatedAt,
                                      x.CreatedBy, userId))
                              .FirstOrDefaultAsync(token)
                          ?? throw new Exception("Exam id is not existed");
        return Results.Ok(new ApiResultDto(true, "Start successfully", response));
    }

    private async Task<WritingGradeResponse> WritingGraderHelper( ContentSubmission submission ,CancellationToken token)
    {
        var client = _client.CreateClient("openrouter");
        var systemPrompt =
            "IELTS W2 examiner. Score essay 0-9. " +
            "Reply ONLY JSON:{\"ob\":6.5," +
            "\"ta\":{\"b\":6,\"c\":\"...\"}," +
            "\"cc\":{\"b\":6,\"c\":\"...\"}," +
            "\"lr\":{\"b\":7,\"c\":\"...\"}," +
            "\"gr\":{\"b\":6,\"c\":\"...\"}," +
            "\"s\":[\"...\"],\"p\":\"...\"}. " +
            "ob=overall; ta,cc,lr,gr=criteria; s=suggestions; b=band; c=comment; p=improved paragraph.";

        var userContent = $"T:{submission.Task}\nE:{submission.Answer}";
    
        var payload = new
        {
            model = _router.Model,
            messages = new[]
            {
                new { role = "system", content = systemPrompt },
                new { role = "user", content = userContent }
            },
            temperature = 0.2,
            max_tokens = 800
        };
        var json = JsonSerializer.Serialize(payload);
        
        using var content = new StringContent(json, Encoding.UTF8, "application/json");
        var response = await client.PostAsync("chat/completions", content, token);
        if (!response.IsSuccessStatusCode)
        {
            var err = await response.Content.ReadAsStringAsync(token);
            throw new HttpRequestException($"OpenRouter error {(int)response.StatusCode}: {err}");
        }

        var responseText = await response.Content.ReadAsStringAsync(token);
        using var doc = JsonDocument.Parse(responseText);
        var assistantContent = doc.RootElement
            .GetProperty("choices")[0]
            .GetProperty("message")
            .GetProperty("content")
            .GetString();
        
        if (string.IsNullOrWhiteSpace(assistantContent))
            throw new InvalidOperationException("Model returned empty content.");
        var trimmed = assistantContent.Trim();

        // Nếu model trả về dạng ```json ... ```
        if (trimmed.StartsWith("```"))
        {
            var firstNewLine = trimmed.IndexOf('\n');
            if (firstNewLine >= 0)
            {
                trimmed = trimmed[(firstNewLine + 1)..]; // bỏ dòng ```json
                var fenceIndex = trimmed.LastIndexOf("```", StringComparison.Ordinal);
                if (fenceIndex >= 0)
                    trimmed = trimmed[..fenceIndex];
            }
            trimmed = trimmed.Trim();
        }
        if (!(trimmed.StartsWith("{") || trimmed.StartsWith("[")))
        {
            throw new InvalidOperationException(
                $"Model did not return JSON. Starts with: {trimmed[..Math.Min(trimmed.Length, 50)]}");
        }
        LlmWritingScoreCompact jsonRes;
        try
        {
            jsonRes = JsonSerializer.Deserialize<LlmWritingScoreCompact>(trimmed)
                      ?? throw new InvalidOperationException("Cannot convert model JSON into object.");
        }
        catch (JsonException ex)
        {
            throw new InvalidOperationException(
                $"Failed to parse model JSON. Content: {trimmed[..Math.Min(trimmed.Length, 200)]}",
                ex);
        }
        if (jsonRes is null) throw new InvalidOperationException("Cannot convert into Object");
        var resp = LlmToResponseHelper.MapToResponse(submission, jsonRes);
        return resp;
    }
    
}