using FluentAssertions;
using speaking_service.Features.Services.Helper;
using Xunit;

namespace SpeakingService.UnitTests.Features.Helper
{
    public class ExtractJsonObject_Tests
    {
        public static IEnumerable<object?[]> ExtractJsonCases()
        {
            // SP-001: Clean JSON
            yield return new object?[] { "SP-001-01", "{\"score\": 7.5}", "{\"score\": 0}", false };
            yield return new object?[] { "SP-001-02", "[1, 2, 3]", "[]", false };
            
            // JSON with leading garbage  
            yield return new object?[] { "SP-001-03", "Here is the result: {\"score\": 8}", "{\"score\": 999}", false };
            yield return new object?[] { "SP-001-04", "```json\n{\"data\": true}\n```", "{\"data\": true}", false };
            
            // Nested JSON
            yield return new object?[] { "SP-001-05", "{\"outer\": {\"inner\": 1}}", "{\"outer\": {\"inner\": 1}}", false };
            
            // JSON with escaped quotes
            yield return new object?[] { "SP-001-06", "{\"text\": \"He said \\\"hello\\\"\"}", "{\"text\": \"He said \\\"hello\\\"\"}", false };
            
            // Array at root
            yield return new object?[] { "SP-001-07", "Result: [{\"a\":1},{\"b\":2}]", "[{\"a\":1},{\"b\":2}]", false };
            
            // No JSON (should throw)
            yield return new object?[] { "SP-001-08", "This is plain text without JSON", null, true };
            yield return new object?[] { "SP-001-09", "No braces here at all", null, true };
            
            // Incomplete JSON starting with { - production trims and returns as-is
            yield return new object?[] { "SP-001-10", "{\"incomplete\": ", "{\"incomplete\":", false };
            
            // Incomplete JSON with prefix - throws because can't find closing brace
            yield return new object?[] { "SP-001-11", "Prefix {\"key\": \"value", null, true };
        }

        [Theory(DisplayName = "{0}: ExtractJsonObject")]
        [MemberData(nameof(ExtractJsonCases))]
        public void Extract_Should_Parse_Json_From_LlmOutput(string caseId, string input, string? expectedJson, bool shouldThrow)
        {
            _ = caseId;
            
            if (shouldThrow)
            {
                var act = () => ExtractJsonObject.Extract(input);
                act.Should().Throw<InvalidOperationException>();
            }
            else
            {
                var result = ExtractJsonObject.Extract(input);
                result.Should().Be(expectedJson);
            }
        }
    }
}
