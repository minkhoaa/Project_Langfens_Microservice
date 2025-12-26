namespace attempt_service.Features.Analytics;

/// <summary>
/// Response DTO for AI-generated insights
/// </summary>
public record AiInsightsDto(
    string Summary,
    string TrendAnalysis,
    List<string> Recommendations,
    List<FocusAreaDto> FocusAreas,
    DateTime GeneratedAt
);

public record FocusAreaDto(
    string Skill,
    string Area,
    string Reason,
    int Priority
);

/// <summary>
/// Internal DTO for Gemini JSON response
/// </summary>
public class LlmInsightsResponse
{
    public string Summary { get; set; } = "";
    public string TrendAnalysis { get; set; } = "";
    public List<string> Recommendations { get; set; } = new();
    public List<LlmFocusArea> FocusAreas { get; set; } = new();
}

public class LlmFocusArea
{
    public string Skill { get; set; } = "";
    public string Area { get; set; } = "";
    public string Reason { get; set; } = "";
    public int Priority { get; set; }
}
