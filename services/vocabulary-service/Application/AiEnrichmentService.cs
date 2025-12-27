using System.Text.Json;
using Microsoft.SemanticKernel;
using Microsoft.SemanticKernel.Connectors.OpenAI;

namespace vocabulary_service.Application;

public interface IAiEnrichmentService
{
    Task<EnrichedWordDto> EnrichWord(string word, CancellationToken token);
}

public class EnrichedWordDto
{
    public string Word { get; set; } = "";
    public string Definition { get; set; } = "";
    public string DefinitionVi { get; set; } = "";
    public string Ipa { get; set; } = "";
    public string PartOfSpeech { get; set; } = "";
    public string Example { get; set; } = "";
    public List<string> Synonyms { get; set; } = new();
    public string Level { get; set; } = "";  // B1, B2, C1, C2
}

public class AiEnrichmentService : IAiEnrichmentService
{
    private readonly Kernel? _kernel;
    private readonly ILogger<AiEnrichmentService> _logger;

    public AiEnrichmentService(Kernel? kernel, ILogger<AiEnrichmentService> logger)
    {
        _kernel = kernel;
        _logger = logger;
    }

    public async Task<EnrichedWordDto> EnrichWord(string word, CancellationToken token)
    {
        var normalizedWord = word.Trim().ToLowerInvariant();

        // If no AI kernel, return basic info
        if (_kernel is null)
        {
            _logger.LogWarning("AI Kernel not available, returning basic word info");
            return new EnrichedWordDto
            {
                Word = normalizedWord,
                Definition = "AI not available",
                DefinitionVi = "AI không khả dụng"
            };
        }

        var prompt = $@"
For the English word ""{normalizedWord}"", provide vocabulary information for IELTS learners.

Return a valid JSON object with this EXACT structure:
{{
  ""word"": ""{normalizedWord}"",
  ""definition"": ""English definition"",
  ""definitionVi"": ""Vietnamese meaning"",
  ""ipa"": ""IPA pronunciation with stress marks"",
  ""partOfSpeech"": ""noun/verb/adjective/adverb/etc"",
  ""example"": ""An example sentence using the word"",
  ""synonyms"": [""synonym1"", ""synonym2""],
  ""level"": ""CEFR level (B1/B2/C1/C2)""
}}

Important:
- definitionVi must be in Vietnamese
- ipa should use proper IPA notation
- example should be natural and suitable for IELTS context
- level should be the estimated CEFR level

Return ONLY the JSON object, no markdown or explanation.
";

        try
        {
            var settings = new OpenAIPromptExecutionSettings
            {
                Temperature = 0.3,
                MaxTokens = 500
            };

            var result = await _kernel.InvokePromptAsync(prompt, new KernelArguments(settings), cancellationToken: token);
            var content = result.GetValue<string>();

            if (string.IsNullOrWhiteSpace(content))
            {
                _logger.LogWarning("Azure OpenAI returned empty content for word: {Word}", normalizedWord);
                return new EnrichedWordDto { Word = normalizedWord, Definition = "Could not enrich" };
            }

            // Clean JSON response
            var jsonContent = content.Trim();
            if (jsonContent.StartsWith("```json"))
                jsonContent = jsonContent[7..];
            if (jsonContent.StartsWith("```"))
                jsonContent = jsonContent[3..];
            if (jsonContent.EndsWith("```"))
                jsonContent = jsonContent[..^3];
            jsonContent = jsonContent.Trim();

            var enriched = JsonSerializer.Deserialize<EnrichedWordDto>(jsonContent, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            });

            return enriched ?? new EnrichedWordDto { Word = normalizedWord, Definition = "Parse error" };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error enriching word: {Word}", normalizedWord);
            return new EnrichedWordDto { Word = normalizedWord, Definition = "Error occurred" };
        }
    }
}
