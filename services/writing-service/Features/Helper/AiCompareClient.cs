using writing_service.Contracts;

namespace writing_service.Features.Helper;

public class AiCompareClient : IAiCompareClient
{
    private readonly HttpClient _http;
    private readonly ILogger<AiCompareClient> _logger;
    private readonly CircuitBreaker _circuitBreaker;

    public AiCompareClient(HttpClient http, ILogger<AiCompareClient> logger, CircuitBreaker circuitBreaker)
    {
        _http = http;
        _logger = logger;
        _circuitBreaker = circuitBreaker;
    }

    public async Task<AiCompareResponseDto?> CompareAsync(
        string essayText, string topic, string taskType, float studentBand,
        CancellationToken ct = default)
    {
        // Check circuit breaker before making the call
        if (!_circuitBreaker.CanExecute())
        {
            _logger.LogWarning("AI compare call rejected - circuit breaker is open for band {Band}", studentBand);
            return null;
        }

        var request = new AiCompareRequestDto(essayText, topic, taskType, studentBand);
        try
        {
            var response = await _http.PostAsJsonAsync("/api/v1/writing/compare", request, ct);
            response.EnsureSuccessStatusCode();
            _circuitBreaker.RecordSuccess();
            return await response.Content.ReadFromJsonAsync<AiCompareResponseDto>(ct);
        }
        catch (Exception ex)
        {
            _circuitBreaker.RecordFailure();
            _logger.LogWarning(ex, "AI compare call failed for band {Band}", studentBand);
            return null;
        }
    }
}
