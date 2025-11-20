using System.Security.Claims;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Options;
using Shared.ExamDto.Contracts;
using Shared.Security.Claims;
using writing_service.Contracts;
using writing_service.Features.Helper;

namespace writing_service.Features.Service;

public interface IWritingService
{
    Task<IResult> WritingGrader(ContentSubmission submission, CancellationToken token, ClaimsPrincipal user);
}


public class WritingService : IWritingService
{
    private readonly OpenRouterOptions _router;
    private readonly IHttpClientFactory _client;

    public WritingService(IOptions<OpenRouterOptions> router, IHttpClientFactory client)
    {
        _client = client;
        _router = router.Value;
    }
    public async Task<IResult> WritingGrader(ContentSubmission submission, CancellationToken token, ClaimsPrincipal user)
    {
        var userId = Guid.Parse(user.FindFirstValue(CustomClaims.Sub)!);
        Console.Write(userId);
        var res = await WritingGraderHelper(submission, token);
        
        
        return Results.Ok(res);
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
        Console.Write(_router.BaseUrl);
        var jsonRes = JsonSerializer.Deserialize<LlmWritingScoreCompact>(assistantContent);
        if (jsonRes is null) throw new InvalidOperationException("Cannot convert into Object");
        var resp = LlmToResponseHelper.MapToResponse(submission, jsonRes);
        return resp;
    }
    
}