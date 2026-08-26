using System.Text.Json;
using Shared.ExamDto.Contracts.Exam.InternalExamDto;

namespace attempt_service.Features.Helpers;

public sealed class AnswerEnvelopeReader
{
    private static readonly JsonSerializerOptions Opts = new(JsonSerializerDefaults.Web);

    public AnswerEnvelope Read(string rawJson, string slug)
    {
        if (!QuestionSchemaAliases.AnswerByType.TryGetValue(slug, out var type))
            throw new UnknownQuestionTypeException(slug);
        var typed = JsonSerializer.Deserialize(rawJson, type, Opts)
            ?? throw new InvalidOperationException($"null typed record for {slug}");
        return new AnswerEnvelope(slug, rawJson, typed);
    }
}