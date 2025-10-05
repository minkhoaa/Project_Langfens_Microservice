using attempt_service.Features.Helpers;
using Shared.ExamDto.Contracts.Exam.Enums;

namespace attempt_service.Domain.Enums;

public static class GraderRegistry
{
    public static readonly Dictionary<string, IQuestionGrader> ByType = new(StringComparer.OrdinalIgnoreCase)
    {
        // Chọn 1 đáp án (kể cả T/F/NG, Y/N/NG, có image)
        [QuestionType.MultipleChoiceSingle] = new SingleChoiceGrader(),
        [QuestionType.MultipleChoiceSingleImage] = new SingleChoiceGrader(),
        [QuestionType.TrueFalseNotGiven] = new SingleChoiceGrader(),
        [QuestionType.YesNoNotGiven] = new SingleChoiceGrader(),

        // Hoàn thành/điền
        [QuestionType.SummaryCompletion] = new CompletionGrader(),
        [QuestionType.TableCompletion] = new CompletionGrader(),
        [QuestionType.NoteCompletion] = new CompletionGrader(),

        // Dán nhãn
        [QuestionType.DiagramLabel] = new LabelGrader(),
        [QuestionType.MapLabel] = new LabelGrader(),

        // Ghép tiêu đề
        [QuestionType.MatchingHeading] = new MatchingHeadingGrader(),

        
        // Thứ tự/flow
        [QuestionType.FlowChart] = new FlowChartGrader()
    };

}