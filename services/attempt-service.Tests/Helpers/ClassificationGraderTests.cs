using attempt_service.Domain.Entities;
using attempt_service.Features.Helpers;
using Shared.ExamDto.Contracts.Exam.Enums;
using Xunit;

namespace attempt_service.Tests.Helpers;

/// <summary>
/// Phase 5: locks routing and grading behaviour for the CLASSIFICATION
/// question type. Classification uses the same scoring logic as the
/// SingleChoiceGrader (exactly one correct option) but is registered
/// to its own grader so SingleChoice covers only radio MCQ variants
/// and MatchingHeading covers only true matching variants.
/// </summary>
public class ClassificationGraderTests
{
    [Fact]
    public void Correct_option_returns_full_points()
    {
        var questionId = Guid.NewGuid();
        var correctId = Guid.NewGuid();
        var key = new QuestionKey(
            QuestionId: questionId,
            QuestionType: QuestionType.Classification,
            QuestionPoints: 1m,
            CorrectOptionIds: new HashSet<(Guid id, string content)>
            {
                (correctId, "A. dopamine research"),
            });

        var answer = new AttemptAnswer
        {
            QuestionId = questionId,
            SelectedOptionIds = new List<Guid> { correctId },
        };

        var grader = new ClassificationGrader();
        var result = grader.Grade(answer, key);

        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Wrong_option_returns_zero_points()
    {
        var questionId = Guid.NewGuid();
        var correctId = Guid.NewGuid();
        var wrongId = Guid.NewGuid();
        var key = new QuestionKey(
            QuestionId: questionId,
            QuestionType: QuestionType.Classification,
            QuestionPoints: 1m,
            CorrectOptionIds: new HashSet<(Guid id, string content)>
            {
                (correctId, "A. dopamine research"),
            });

        var answer = new AttemptAnswer
        {
            QuestionId = questionId,
            SelectedOptionIds = new List<Guid> { wrongId },
        };

        var grader = new ClassificationGrader();
        var result = grader.Grade(answer, key);

        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Factory_resolves_ClassificationGrader_for_CLASSIFICATION_type()
    {
        var registrations = new IQuestionGraderRegistration[]
        {
            new SingleChoiceGraderRegistration(new SingleChoiceGrader()),
            new MultipleChoiceGraderRegistration(new MultipleChoiceGrader()),
            new CompletionGraderRegistration(new CompletionGrader()),
            new LabelGraderRegistration(new LabelGrader()),
            new MatchingHeadingGraderRegistration(new MatchingHeadingGrader()),
            new ClassificationGraderRegistration(new ClassificationGrader()),
            new FlowChartGraderRegistration(new FlowChartGrader()),
            new ShortAnswerGraderRegistration(new ShortAnswerGrader()),
        };

        var factory = new QuestionGraderFactory(registrations);
        var grader = factory.Resolve(QuestionType.Classification);

        Assert.NotNull(grader);
        Assert.IsType<ClassificationGrader>(grader);
    }

    [Fact]
    public void Factory_rejects_unknown_type_with_helpful_message()
    {
        var registrations = new IQuestionGraderRegistration[]
        {
            new SingleChoiceGraderRegistration(new SingleChoiceGrader()),
            new MultipleChoiceGraderRegistration(new MultipleChoiceGrader()),
            new CompletionGraderRegistration(new CompletionGrader()),
            new LabelGraderRegistration(new LabelGrader()),
            new MatchingHeadingGraderRegistration(new MatchingHeadingGrader()),
            new ClassificationGraderRegistration(new ClassificationGrader()),
            new FlowChartGraderRegistration(new FlowChartGrader()),
            new ShortAnswerGraderRegistration(new ShortAnswerGrader()),
        };

        var factory = new QuestionGraderFactory(registrations);

        var ex = Assert.Throws<NotSupportedException>(
            () => factory.Resolve("BOGUS_TYPE"));

        Assert.Contains("Unknown question type", ex.Message);
        Assert.Contains("BOGUS_TYPE", ex.Message);
    }
}