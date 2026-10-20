using System;
using System.Collections.Generic;
using attempt_service.Domain.Entities;
using attempt_service.Features.Helpers;
using Xunit;

namespace attempt_service.Tests.Helpers;

public class MultipleChoiceGraderTests
{
    private readonly MultipleChoiceGrader _grader = new();

    [Fact]
    public void Grade_AllCorrectOptionsSelected_AwardsFullPoints()
    {
        var opt1 = Guid.NewGuid();
        var opt2 = Guid.NewGuid();
        var key = new QuestionKey(
            Guid.NewGuid(),
            "MULTIPLE_CHOICE_MULTIPLE",
            QuestionPoints: 2m,
            CorrectOptionIds: new HashSet<(Guid, string)>
            {
                (opt1, "Option A"),
                (opt2, "Option B")
            });
        var answer = new AttemptAnswer
        {
            SelectedOptionIds = new List<Guid> { opt1, opt2 }
        };

        var result = _grader.Grade(answer, key);

        Assert.True(result.IsCorrect);
        Assert.Equal(2m, result.AwardedPoints);
    }

    [Fact]
    public void Grade_PartialMatchOnMultiPointQuestion_AwardsPartialCredit()
    {
        var opt1 = Guid.NewGuid();
        var opt2 = Guid.NewGuid();
        var key = new QuestionKey(
            Guid.NewGuid(),
            "MULTIPLE_CHOICE_MULTIPLE",
            QuestionPoints: 2m,
            CorrectOptionIds: new HashSet<(Guid, string)>
            {
                (opt1, "Option A"),
                (opt2, "Option B")
            });
        var answer = new AttemptAnswer
        {
            SelectedOptionIds = new List<Guid> { opt1 }
        };

        var result = _grader.Grade(answer, key);

        Assert.False(result.IsCorrect);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.Contains("1/2 correct", result.Feedback);
    }

    [Fact]
    public void Grade_IncorrectOptionsPenalized_DoesNotAwardFullPointsForIndiscriminateSelection()
    {
        var opt1 = Guid.NewGuid();
        var opt2 = Guid.NewGuid();
        var optWrong = Guid.NewGuid();
        var key = new QuestionKey(
            Guid.NewGuid(),
            "MULTIPLE_CHOICE_MULTIPLE",
            QuestionPoints: 2m,
            CorrectOptionIds: new HashSet<(Guid, string)>
            {
                (opt1, "Option A"),
                (opt2, "Option B")
            });
        // Student chose 1 correct and 1 wrong -> net correct = 0
        var answer = new AttemptAnswer
        {
            SelectedOptionIds = new List<Guid> { opt1, optWrong }
        };

        var result = _grader.Grade(answer, key);

        Assert.False(result.IsCorrect);
        Assert.Equal(0m, result.AwardedPoints);
    }

    [Fact]
    public void Grade_EmptySelection_ReturnsZero()
    {
        var opt1 = Guid.NewGuid();
        var key = new QuestionKey(
            Guid.NewGuid(),
            "MULTIPLE_CHOICE_MULTIPLE",
            QuestionPoints: 2m,
            CorrectOptionIds: new HashSet<(Guid, string)> { (opt1, "Option A") });
        var answer = new AttemptAnswer
        {
            SelectedOptionIds = new List<Guid>()
        };

        var result = _grader.Grade(answer, key);

        Assert.False(result.IsCorrect);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.Equal("No answer provided", result.Feedback);
    }

    [Fact]
    public void Grade_NoAnswerKey_ReturnsNeedsManualReview()
    {
        var key = new QuestionKey(Guid.NewGuid(), "MULTIPLE_CHOICE_MULTIPLE", QuestionPoints: 1m, CorrectOptionIds: new HashSet<(Guid, string)>());
        var answer = new AttemptAnswer { SelectedOptionIds = new List<Guid> { Guid.NewGuid() } };
        var result = _grader.Grade(answer, key);

        Assert.True(result.NeedsManualReview);
        Assert.Equal(0m, result.AwardedPoints);
    }
}
