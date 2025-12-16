// Assuming a clean project setup.
using System.Text.Json;
using attempt_service.Domain.Entities;
using attempt_service.Features.Helpers;
using FluentAssertions;
using Xunit;

namespace AttemptService.UnitTests.Features.Helpers
{
    public class FlowChartGrader_Tests
    {
        private readonly FlowChartGrader _grader = new FlowChartGrader();

        public static IEnumerable<object[]> LcsTestCases()
        {
            // AR-016
            var key = new QuestionKey(Guid.NewGuid(), "FlowChart", 10m, CorrectOptionIds: null, BlankAcceptTexts: null, BlankAcceptRegex: null, MatchPairs: null, OrderCorrects: new List<string> { "A", "B", "C", "D", "E" }, ShortAnswerAcceptTexts: null, ShortAnswerAcceptRegex: null);

            yield return new object[] { key, new List<string> { "A", "B", "C", "D", "E" }, 10m };
            yield return new object[] { key, new List<string> { "X", "Y", "Z" }, 0m };
            yield return new object[] { key, new List<string> { "B", "C", "D" }, 6m };
            yield return new object[] { key, new List<string> { "X", "A", "B", "Y", "C", "D", "Z", "E" }, 10m };
            yield return new object[] { key, new List<string> { "A", "B", "X", "Y" }, 4m };
            yield return new object[] { key, new List<string> { "X", "Y", "D", "E" }, 4m };
            yield return new object[] { key, new List<string>(), 0m };
            yield return new object[] { key, new List<string> { "A", "B", "C", "D", "E" }, 10m };
            yield return new object[] { key, new List<string> { "X", "Y", "Z" }, 0m };
            yield return new object[] { key, new List<string> { "B", "C", "D" }, 6m };
            yield return new object[] { key, new List<string> { "X", "A", "B", "Y", "C", "D", "Z", "E" }, 10m };
            yield return new object[] { key, new List<string> { "A", "B", "X", "Y" }, 4m };
            yield return new object[] { key, new List<string> { "X", "Y", "D", "E" }, 4m };
            yield return new object[] { key, new List<string>(), 0m };
            yield return new object[] { new QuestionKey(Guid.NewGuid(), "FlowChart", 10m, null, null, null, null, new List<string>(), null, null), new List<string> { "A", "B" }, 0m };
            yield return new object[] { new QuestionKey(Guid.NewGuid(), "FlowChart", 10m, null, null, null, null, new List<string> { "node-one", "node-two" }, null, null), new List<string> { "Node One", "Node Two" }, 10m };
            yield return new object[] { new QuestionKey(Guid.NewGuid(), "FlowChart", 10m, null, null, null, null, new List<string> { "A", "B", "A", "C" }, null, null), new List<string> { "A", "B", "C" }, 7.5m };
            yield return new object[] { key, new List<string> { "E", "D", "C", "B", "A" }, 2m }; // LCS is 1, so 1/5 * 10 = 2
        }

        [Theory(DisplayName = "AR-016: LCSC")]
        [MemberData(nameof(LcsTestCases))]
        public void Grade_Should_Correctly_Calculate_LCS_Score(QuestionKey key, List<string> userAnswer, decimal expectedScore)
        {
            // Arrange
            var answer = new AttemptAnswer
            {
                TextAnswer = JsonSerializer.Serialize(userAnswer)
            };

            // Act
            var result = _grader.Grade(answer, key);

            // Assert
            result.AwardedPoints.Should().Be(expectedScore);
        }
    }
}
