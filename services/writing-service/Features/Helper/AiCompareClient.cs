using System.Text.Json;
using writing_service.Contracts;

namespace writing_service.Features.Helper;

public class AiCompareClient : IAiCompareClient
{
    private readonly HttpClient _http;
    private readonly ILogger<AiCompareClient> _logger;

    public AiCompareClient(HttpClient http, ILogger<AiCompareClient> logger)
    {
        _http = http;
        _logger = logger;
    }

    public async Task<AiCompareResponseDto?> CompareAsync(
        string essayText, string topic, string taskType, float studentBand,
        CancellationToken ct = default)
    {
        var request = new AiCompareRequestDto(essayText, topic, taskType, studentBand);
        try
        {
            var response = await _http.PostAsJsonAsync("/api/v1/writing/compare", request, ct);
            response.EnsureSuccessStatusCode();
            return await response.Content.ReadFromJsonAsync<AiCompareResponseDto>(ct);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "AI compare call failed for band {Band}", studentBand);
            return null;
        }
    }
}
