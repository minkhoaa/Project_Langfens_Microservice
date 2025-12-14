using attempt_service.Domain.Entities;
using attempt_service.Features.Helpers;
using FluentAssertions;
using Shared.ExamDto.Contracts.Exam.Enums;

namespace AttemptService.UnitTests.Grader;

public class ShortAnswerGraderTests
{
    private readonly ShortAnswerGrader _grader = new();

    [Fact]
    public void Grade_Should_AwardFullPoints_For_Text_Match()
    {
        var answer = new AttemptAnswer { TextAnswer = "Paris" };
        var key = new QuestionKey(
            Guid.NewGuid(),
            QuestionType.ShortAnswer,
            QuestionPoints: 2,
            ShortAnswerAcceptTexts: new[] { "paris" },
            ShortAnswerAcceptRegex: null);

        var result = _grader.Grade(answer, key);

        result.AwardedPoints.Should().Be(2);
        result.IsCorrect.Should().BeTrue();
    }

    [Fact]
    public void Grade_Should_AwardFullPoints_For_Regex_Match()
    {
        var answer = new AttemptAnswer { TextAnswer = "twenty-one" };
        var key = new QuestionKey(
            Guid.NewGuid(),
            QuestionType.ShortAnswer,
            ShortAnswerAcceptTexts: Array.Empty<string>(),
            ShortAnswerAcceptRegex: new[] { "twenty[- ]one" });

        var result = _grader.Grade(answer, key);

        result.AwardedPoints.Should().Be(1);
        result.IsCorrect.Should().BeTrue();
    }

    [Fact]
    public void Grade_Should_Return_Zero_When_No_Match()
    {
        var answer = new AttemptAnswer { TextAnswer = "wrong" };
        var key = new QuestionKey(
            Guid.NewGuid(),
            QuestionType.ShortAnswer,
            QuestionPoints: 3,
            ShortAnswerAcceptTexts: new[] { "correct" },
            ShortAnswerAcceptRegex: Array.Empty<string>());

        var result = _grader.Grade(answer, key);

        result.AwardedPoints.Should().Be(0);
        result.IsCorrect.Should().BeFalse();
    }
}
