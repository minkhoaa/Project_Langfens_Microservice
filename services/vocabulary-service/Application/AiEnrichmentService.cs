using System.Text.Json;
using OpenAI.Chat;

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
    private readonly ChatClient? _chatClient;
    private readonly ILogger<AiEnrichmentService> _logger;

    public AiEnrichmentService(ChatClient? chatClient, ILogger<AiEnrichmentService> logger)
    {
        _chatClient = chatClient;
        _logger = logger;
    }

    public async Task<EnrichedWordDto> EnrichWord(string word, CancellationToken token)
    {
        var normalizedWord = word.Trim().ToLowerInvariant();

        // If no ChatClient, return basic info
        if (_chatClient is null)
        {
            _logger.LogWarning("ChatClient not available, returning basic word info");
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
            var messages = new List<ChatMessage>
            {
                new UserChatMessage(prompt)
            };

            var options = new ChatCompletionOptions
            {
                Temperature = 0.3f,
                MaxOutputTokenCount = 500
            };

            var completion = await _chatClient.CompleteChatAsync(messages, options, token);
            var content = completion.Value.Content.FirstOrDefault()?.Text;

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
