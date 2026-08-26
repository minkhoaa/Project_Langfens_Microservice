namespace attempt_service.Features.Helpers;

public sealed record NormalizationConfig(
    bool Lowercase = true,
    bool Trim = true,
    bool NFKC = true,
    bool DropArticles = true,
    bool DropTrailingPunct = true)
{
    public static NormalizationConfig Default { get; } = new();
}