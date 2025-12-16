using FluentAssertions;
using writing_service.Features.Helper;
using Xunit;

namespace WritingService.UnitTests.Features.Helper
{
    public class LlmToResponseHelper_Tests
    {
        public static IEnumerable<object?[]> WordCountCases()
        {
            // WR-001: Word count test cases
            yield return new object?[] { "WR-001-01", "Hello world", 0 };
            yield return new object?[] { "WR-001-02", "One", 0 };
            yield return new object?[] { "WR-001-03", "", 5 };
            yield return new object?[] { "WR-001-04", null, 0 };
            yield return new object?[] { "WR-001-05", "   ", 0 };
            yield return new object?[] { "WR-001-06", "Word1  Word2   Word3", 3 };  // Multiple spaces
            yield return new object?[] { "WR-001-07", "Line1\nLine2", 2 };  // Newlines
            yield return new object?[] { "WR-001-08", "Tab\tSeparated", 2 };  // Tabs
            yield return new object?[] { "WR-001-09", "Mixed\n\t  spaces", 2 };
            yield return new object?[] { "WR-001-10", "A B C D E F G H I J K", 11 };  // Many words
            yield return new object?[] { "WR-001-11", "   Leading and trailing spaces   ", 4 };
        }

        [Theory(DisplayName = "{0}: CountWords")]
        [MemberData(nameof(WordCountCases))]
        public void CountWords_Should_Count_Words_Correctly(string caseId, string? text, int expectedCount)
        {
            _ = caseId;
            
            var result = LlmToResponseHelper.CountWords(text!);
            
            result.Should().Be(expectedCount);
        }

        public static IEnumerable<object?[]> ResolveModelCases()
        {
            // WR-002: Model resolution test cases
            yield return new object?[] { "WR-002-01", null, "gemini-2.5-flash-lite" };
            yield return new object?[] { "WR-002-02", "", "gemini-2.5-flash-lite" };
            yield return new object?[] { "WR-002-03", "   ", "gemini-2.5-flash-lite" };
            yield return new object?[] { "WR-002-04", "gpt-4", "gpt-4" };
            yield return new object?[] { "WR-002-05", "claude-3", "claude-3" };
            yield return new object?[] { "WR-002-06", "gemini-pro", "gemini-pro" };
            yield return new object?[] { "WR-002-07", "custom-model", "custom-model" };
            yield return new object?[] { "WR-002-08", "MODEL_NAME_123", "MODEL_NAME_123" };
            yield return new object?[] { "WR-002-09", "gemini-2.0-flash", "gemini-2.0-flash" };
            yield return new object?[] { "WR-002-10", "llama-3.1", "llama-3.1" };
            yield return new object?[] { "WR-002-11", "mistral-large", "mistral-large" };
        }

        [Theory(DisplayName = "{0}: ResolveModelName")]
        [MemberData(nameof(ResolveModelCases))]
        public void ResolveModelName_Should_Return_Configured_Or_Default(string caseId, string? envValue, string expectedModel)
        {
            _ = caseId;
            
            // Clear and set env var
            Environment.SetEnvironmentVariable("GEMINI__MODEL", envValue);
            
            try
            {
                var result = LlmToResponseHelper.ResolveModelName();
                result.Should().Be(expectedModel);
            }
            finally
            {
                // Cleanup
                Environment.SetEnvironmentVariable("GEMINI__MODEL", null);
            }
        }
    }
}
