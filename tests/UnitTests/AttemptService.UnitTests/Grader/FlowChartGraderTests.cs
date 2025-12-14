using System.Text.Json;
using attempt_service.Domain.Entities;
using attempt_service.Features.Helpers;
using FluentAssertions;
using Shared.ExamDto.Contracts.Exam.Enums;
using Xunit;

namespace AttemptService.UnitTests.Grader;

public class FlowChartGraderTests
{
    [Fact]
    public void Grade_Should_AwardFullPoints_When_SequenceMatchesOrder()
    {
        var grader = new FlowChartGrader();
        var answer = new AttemptAnswer
        {
            TextAnswer = JsonSerializer.Serialize(new[] { "Step-A", "Step-B", "Step-C" })
        };
        var key = new QuestionKey(
            Guid.NewGuid(),
            QuestionType.FlowChart,
            QuestionPoints: 2m,
            OrderCorrects: new List<string> { "step-a", "step-b", "step-c" }
        );

        var result = grader.Grade(answer, key);

        result.AwardedPoints.Should().Be(2m);
        result.IsCorrect.Should().BeTrue();
        result.NeedsManualReview.Should().BeFalse();
    }

    [Fact]
    public void Grade_Should_ReturnZero_When_PayloadMalformed()
    {
        var grader = new FlowChartGrader();
        var answer = new AttemptAnswer
        {
            TextAnswer = "not-json"
        };
        var key = new QuestionKey(
            Guid.NewGuid(),
            QuestionType.FlowChart,
            QuestionPoints: 1m,
            OrderCorrects: new List<string> { "A", "B" }
        );

        var result = grader.Grade(answer, key);

        result.AwardedPoints.Should().Be(0m);
        result.IsCorrect.Should().BeFalse();
        result.Feedback.Should().NotBeNullOrWhiteSpace();
    }
}
