namespace attempt_service.Features.Helpers;

public interface IGrader
{
    string Slug { get; }
    GradeResult Grade(AnswerEnvelope learner, AnswerEnvelope correct, NormalizationConfig norm);
}

public sealed class UnknownQuestionTypeException(string slug)
    : Exception($"Unknown question type slug: {slug}");