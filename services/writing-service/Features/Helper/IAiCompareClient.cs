using writing_service.Contracts;

namespace writing_service.Features.Helper;

public interface IAiCompareClient
{
    Task<AiCompareResponseDto?> CompareAsync(
        string essayText, string topic, string taskType, float studentBand,
        CancellationToken ct = default);
}
