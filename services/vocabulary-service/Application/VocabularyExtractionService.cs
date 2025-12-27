using System.Text.Json;
using Microsoft.SemanticKernel;
using Microsoft.SemanticKernel.Connectors.OpenAI;

namespace vocabulary_service.Application;

public interface IVocabularyExtractionService
{
    Task<List<ExtractedWordDto>> ExtractFromPassage(string passageText, int maxWords, CancellationToken token);
}

public class ExtractedWordDto
{
    public string Word { get; set; } = "";
    public string Definition { get; set; } = "";
    public string DefinitionVi { get; set; } = "";
    public string Ipa { get; set; } = "";
    public string Level { get; set; } = "";  // B1, B2, C1, C2
    public string Example { get; set; } = "";
}

public class VocabularyExtractionService : IVocabularyExtractionService
{
    private readonly Kernel? _kernel;
    private readonly ILogger<VocabularyExtractionService> _logger;

    public VocabularyExtractionService(Kernel? kernel, ILogger<VocabularyExtractionService> logger)
    {
        _kernel = kernel;
        _logger = logger;
    }

    public async Task<List<ExtractedWordDto>> ExtractFromPassage(string passageText, int maxWords, CancellationToken token)
    {
        if (string.IsNullOrWhiteSpace(passageText))
            return new List<ExtractedWordDto>();

        if (_kernel is null)
        {
            _logger.LogWarning("AI Kernel not available for vocabulary extraction");
            return new List<ExtractedWordDto>();
        }

        var prompt = $@"
Analyze this IELTS reading passage and extract the {maxWords} most important vocabulary words for IELTS learners.

PASSAGE:
{passageText}

For each word, provide:
- word: the vocabulary word
- definition: brief English definition
- definitionVi: Vietnamese meaning
- ipa: IPA pronunciation
- level: CEFR level (B1/B2/C1/C2)
- example: the sentence from the passage containing this word

Return a valid JSON array:
[
  {{
    ""word"": ""example"",
    ""definition"": ""English definition"",
    ""definitionVi"": ""Nghĩa tiếng Việt"",
    ""ipa"": ""/ɪɡˈzæmpəl/"",
    ""level"": ""B2"",
    ""example"": ""sentence from passage""
  }}
]

Selection criteria:
1. Focus on academic/IELTS vocabulary
2. Prefer less common words over basic vocabulary
3. Include words important for understanding the passage
4. Skip proper nouns and numbers

Return ONLY the JSON array, no markdown or explanation.
";

        try
        {
            var settings = new OpenAIPromptExecutionSettings
            {
                Temperature = 0.3,
                MaxTokens = 2000
            };

            var result = await _kernel.InvokePromptAsync(prompt, new KernelArguments(settings), cancellationToken: token);
            var content = result.GetValue<string>();

            if (string.IsNullOrWhiteSpace(content))
            {
                _logger.LogWarning("Azure OpenAI returned empty content for vocabulary extraction");
                return new List<ExtractedWordDto>();
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

            var words = JsonSerializer.Deserialize<List<ExtractedWordDto>>(jsonContent, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            });

            return words ?? new List<ExtractedWordDto>();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error extracting vocabulary from passage");
            return new List<ExtractedWordDto>();
        }
    }
}
