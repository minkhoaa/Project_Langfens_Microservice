namespace attempt_service.Features.Helpers;

public interface ITextNormalizer
{
    string Normalize(string s, NormalizationConfig cfg);
}