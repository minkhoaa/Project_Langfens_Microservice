namespace speaking_service.Contracts;

public class OpenRouterOptions
{
    public const string SectionName = "OpenRouter";

    public string BaseUrl { get; set; } = "https://openrouter.ai/api/v1";
    public string Model { get; set; } = "openai/gpt-oss-20b:free";
    public string ApiKey { get; set; } = string.Empty;

    // optional metadata for OpenRouter dashboard/leaderboard
    public string? Referer { get; set; } = "https://your-speaking-app.com";
    public string? Title { get; set; } = "Langfens English";
}
