using Shared.ExamDto.Contracts.Exam.Enums;

namespace attempt_service.Features.Helpers
{
    public interface IQuestionGraderRegistration
    {
        // design pattern abstract factory
        IEnumerable<string> SupportedTypes { get; }
        IQuestionGrader Create();
    }
    public class SingleChoiceGraderRegistration : IQuestionGraderRegistration
    {
        private readonly IQuestionGrader _instance;
        public SingleChoiceGraderRegistration(SingleChoiceGrader instance)
        {
            _instance = instance;
        }
        public IEnumerable<string> SupportedTypes => new[]
    {
        QuestionType.MultipleChoiceSingle,
        QuestionType.MultipleChoiceSingleImage,
        QuestionType.TrueFalseNotGiven,
        QuestionType.YesNoNotGiven,
    };

        public IQuestionGrader Create() => _instance;
    }
    public class CompletionGraderRegistration : IQuestionGraderRegistration
    {
        private readonly IQuestionGrader _instance;
        public CompletionGraderRegistration(CompletionGrader instance)
        {
            _instance = instance;
        }
        public IEnumerable<string> SupportedTypes =>
        [
            QuestionType.SummaryCompletion,
            QuestionType.TableCompletion,
            QuestionType.NoteCompletion,
            QuestionType.FormCompletion,
            QuestionType.SentenceCompletion
        ];

        public IQuestionGrader Create() => _instance;
    }
    public class LabelGraderRegistration : IQuestionGraderRegistration
    {
        private readonly IQuestionGrader _instance;
        public LabelGraderRegistration(LabelGrader instance)
        {
            _instance = instance;
        }
        public IEnumerable<string> SupportedTypes => new[]
     {
            QuestionType.DiagramLabel,
            QuestionType.MapLabel,
        };

        public IQuestionGrader Create() => _instance;
    }
    public class MatchingHeadingGraderRegistration : IQuestionGraderRegistration
    {
        private readonly IQuestionGrader _instance;
        public MatchingHeadingGraderRegistration(MatchingHeadingGrader instance)
        {
            _instance = instance;
        }
        public IEnumerable<string> SupportedTypes => new[]
     {
            QuestionType.MatchingEndings,
            QuestionType.MatchingFeatures,
            QuestionType.MatchingHeading,
            QuestionType.MatchingInformation,
            QuestionType.Classification,
        };

        public IQuestionGrader Create() => _instance;
    }
    public class FlowChartGraderRegistration : IQuestionGraderRegistration
    {
        private readonly IQuestionGrader _instance;
        public FlowChartGraderRegistration(FlowChartGrader instance)
        {
            _instance = instance;
        }
        public IEnumerable<string> SupportedTypes => new[]
     {
            QuestionType.FlowChart
        };

        public IQuestionGrader Create() => _instance;
    }
    public class ShortAnswerGraderRegistration : IQuestionGraderRegistration
    {
        private readonly IQuestionGrader _instance;
        public ShortAnswerGraderRegistration(ShortAnswerGrader instance)
        {
            _instance = instance;
        }
        public IEnumerable<string> SupportedTypes => new[]
     {
            QuestionType.ShortAnswer
        };

        public IQuestionGrader Create() => _instance;
    }
    
    public class MultipleChoiceGraderRegistration : IQuestionGraderRegistration
    {
        private readonly IQuestionGrader _instance;
        public MultipleChoiceGraderRegistration(MultipleChoiceGrader instance)
        {
            _instance = instance;
        }
        public IEnumerable<string> SupportedTypes => new[]
        {
            QuestionType.MultipleChoiceMultiple
        };

        public IQuestionGrader Create() => _instance;
    }
}