using System.Security.AccessControl;
using attempt_service.Features.Helpers;
using Shared.ExamDto.Contracts.Exam.Enums;

namespace attempt_service.Features.Helpers
{

    public interface IQuestionGraderFactory
    {
        IQuestionGrader Resolve(string questionType);
    }
}
public class QuestionGraderFactory : IQuestionGraderFactory
{
    private readonly IReadOnlyDictionary<string, IQuestionGrader> _byType;

    public QuestionGraderFactory(
        SingleChoiceGrader singleChoiceGrader,
        CompletionGrader completionGrader,
        LabelGrader labelGrader,
        MatchingHeadingGrader matchingHeadingGrader,
        FlowChartGrader flowChartGrader,
        ShortAnswerGrader shortAnswerGrader)
    {
        _byType = new Dictionary<string, IQuestionGrader>(StringComparer.OrdinalIgnoreCase)
        {
            // Chọn 1 đáp án (kể cả T/F/NG, Y/N/NG, có image)
            [QuestionType.MultipleChoiceSingle] = singleChoiceGrader,
            [QuestionType.MultipleChoiceSingleImage] = singleChoiceGrader,
            [QuestionType.TrueFalseNotGiven] = singleChoiceGrader,
            [QuestionType.YesNoNotGiven] = singleChoiceGrader,

            // Hoàn thành/điền
            [QuestionType.SummaryCompletion] = completionGrader,
            [QuestionType.TableCompletion] = completionGrader,
            [QuestionType.NoteCompletion] = completionGrader,
            [QuestionType.FormCompletion] = completionGrader,
            [QuestionType.SentenceCompletion] = completionGrader,

            // Dán nhãn
            [QuestionType.DiagramLabel] = labelGrader,
            [QuestionType.MapLabel] = labelGrader,

            // Ghép/matching
            [QuestionType.MatchingHeading] = matchingHeadingGrader,
            [QuestionType.MatchingInformation] = matchingHeadingGrader,
            [QuestionType.MatchingFeatures] = matchingHeadingGrader,
            [QuestionType.MatchingEndings] = matchingHeadingGrader,
            [QuestionType.Classification] = matchingHeadingGrader,

            // Thứ tự/flow / short answer
            [QuestionType.FlowChart] = flowChartGrader,
            [QuestionType.ShortAnswer] = shortAnswerGrader
        };
    }
    public IQuestionGrader Resolve(string questionType)
    {
        if (_byType.TryGetValue(questionType, out var grader))
            return grader;
        throw new NotSupportedException($"Unsupported question type: {questionType}");
    }
}
