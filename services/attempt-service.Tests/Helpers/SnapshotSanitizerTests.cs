using attempt_service.Features.Helpers;
using Shared.Grpc.ExamInternal;
using Xunit;
using Dto = Shared.ExamDto.Contracts.Exam.InternalExamDto.InternalExamDto;

namespace attempt_service.Tests.Helpers;

public class SnapshotSanitizerTests
{
    [Fact]
    public void Grpc_keeps_slot_ids_without_exposing_accepted_values_or_mutating_snapshot()
    {
        var question = new InternalDeliveryQuestion { Id = Guid.NewGuid().ToString() };
        var blank = new InternalCompletionAccept { BlankId = "5" };
        blank.AcceptedTexts.Add("secret");
        blank.AcceptedRegex.Add("secret.*");
        question.CompletionAccepts.Add(blank);
        var pair = new InternalMatchPair { PromptKey = "7" };
        pair.AcceptedValues.Add("B");
        question.MatchPairs.Add(pair);
        question.Options.Add(new InternalDeliveryOption { Id = Guid.NewGuid().ToString(), IsCorrect = true });
        question.OrderCorrects.Add("secret-step");
        question.ShortAnswerAcceptTexts.Add("secret-short");
        var group = new InternalDeliveryQuestionGroup();
        group.Questions.Add(question);
        var section = new InternalDeliverySection();
        section.QuestionGroups.Add(group);
        var exam = new InternalDeliveryExam();
        exam.Sections.Add(section);

        var safe = GrpcSnapshotSanitizer.Sanitize(exam).Sections[0].QuestionGroups[0].Questions[0];

        Assert.Equal("5", Assert.Single(safe.CompletionAccepts).BlankId);
        Assert.Empty(safe.CompletionAccepts[0].AcceptedTexts);
        Assert.Empty(safe.CompletionAccepts[0].AcceptedRegex);
        Assert.Equal("7", Assert.Single(safe.MatchPairs).PromptKey);
        Assert.Empty(safe.MatchPairs[0].AcceptedValues);
        Assert.False(safe.Options[0].HasIsCorrect);
        Assert.Empty(safe.OrderCorrects);
        Assert.Empty(safe.ShortAnswerAcceptTexts);
        Assert.Equal("secret", question.CompletionAccepts[0].AcceptedTexts[0]);
        Assert.Equal("B", question.MatchPairs[0].AcceptedValues[0]);
        Assert.True(question.Options[0].IsCorrect);
    }

    [Fact]
    public void Rest_keeps_non_contiguous_text_regex_and_matching_keys_without_values()
    {
        var question = new Dto.InternalDeliveryQuestion
        {
            BlankAcceptTexts = new Dictionary<string, string[]?> { ["5"] = ["secret"] },
            BlankAcceptRegex = new Dictionary<string, string[]?> { ["10"] = ["secret.*"] },
            MatchPairs = new Dictionary<string, string[]?> { ["7"] = ["B"] },
            Options = [new Dto.InternalDeliveryOption { IsCorrect = true }]
        };
        var exam = new Dto.InternalDeliveryExam
        {
            Sections = [new Dto.InternalDeliverySection
            {
                QuestionGroups = [new Dto.InternalDeliveryQuestionGroup { Questions = [question] }]
            }]
        };

        var safe = Dto.SnapshotSanitizer.Sanitize(exam).Sections[0].QuestionGroups[0].Questions[0];
        Assert.Empty(safe.BlankAcceptTexts["5"]!);
        Assert.Empty(safe.BlankAcceptRegex["10"]!);
        Assert.Empty(safe.MatchPairs["7"]!);
        Assert.Null(safe.Options[0].IsCorrect);
        Assert.Equal("secret", question.BlankAcceptTexts["5"]![0]);
    }
}
