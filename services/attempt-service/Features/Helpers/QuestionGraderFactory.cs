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
    private readonly IReadOnlyDictionary<string, IQuestionGraderRegistration> _map;

    public QuestionGraderFactory(IEnumerable<IQuestionGraderRegistration> registrations)
    {
        if (registrations == null)
            throw new ArgumentNullException(nameof(registrations));
        _map = registrations.SelectMany(k => k.SupportedTypes.Select(t => (Type: t, Reg: k)))
       .ToDictionary(
                    x => x.Type,
                    x => x.Reg,
                    StringComparer.OrdinalIgnoreCase);
    }
    public IQuestionGrader Resolve(string questionType)
    {
        if (questionType == null)
            throw new ArgumentNullException(nameof(questionType));
        if (!_map.TryGetValue(questionType, out var grader))
            throw new NotSupportedException($"Unsupported question type: {questionType}");
        return grader.Create();
    }
}
