using System.Text.Json;
using Google.Protobuf.Collections;
using Shared.ExamDto.Contracts.Exam.Enums;
using Shared.ExamDto.Contracts.Exam.InternalExamDto;
using Shared.Grpc.ExamInternal;

namespace attempt_service.Features.Helpers;

public interface IBuildQuestionIdSet
{
    HashSet<Guid> Build(JsonDocument paper);

}
public class BuildQuestionIdSet : IBuildQuestionIdSet
{
    public HashSet<Guid> Build(JsonDocument paper)
    {
        var set = new HashSet<Guid>();
        if (!paper.RootElement.TryGetProperty("sections", out var sections)) return set;
        foreach (var s in sections.EnumerateArray())
        {
            if (!s.TryGetProperty("questions", out var qs)) continue;
            foreach (var q in qs.EnumerateArray())
                if (q.TryGetProperty("id", out var idProp) && idProp.ValueKind == JsonValueKind.String)
                    set.Add(idProp.GetGuid());
        }

        return set;
    }
}
public interface IQuestionIndex
{
    Dictionary<Guid, (Guid SectionId, string Type, HashSet<Guid> OptionIds)> Build(JsonDocument doc);

}
public class QuestionIndex : IQuestionIndex
{
    public Dictionary<Guid, (Guid SectionId, string Type, HashSet<Guid> OptionIds)> Build(JsonDocument doc)
    {
        var map = new Dictionary<Guid, (Guid, string, HashSet<Guid>)>();
        if (!doc.RootElement.TryGetProperty("sections", out var sections)) return map;
        foreach (var s in sections.EnumerateArray())
        {
            var sectionId = s.GetProperty("id").GetGuid();
            if (!s.TryGetProperty("questions", out var qs)) continue;
            foreach (var q in qs.EnumerateArray())
            {
                var qid = q.GetProperty("id").GetGuid();
                var type = q.TryGetProperty("type", out var t) ? t.GetString() ?? "" : "";
                var opts = new HashSet<Guid>();
                if (q.TryGetProperty("options", out var os))
                    foreach (var o in os.EnumerateArray())
                        if (o.TryGetProperty("id", out var oid))
                            opts.Add(oid.GetGuid());
                map[qid] = (sectionId, type, opts);
            }
        }

        return map;
    }
}
public sealed record QMeta(
    Guid SectionId,
    string Type,
    HashSet<(Guid id, string content)> OptionIds
    );
public interface IIndexBuilder
{

    Dictionary<Guid, QMeta> BuildIndexFromProto(InternalDeliveryExam exam);
    Dictionary<Guid, QMeta> BuildIndexFromDto(InternalExamDto.InternalDeliveryExam exam);

}

public class IndexBuilder : IIndexBuilder
{

    public Dictionary<Guid, QMeta> BuildIndexFromProto(InternalDeliveryExam exam)
    {
        var map = new Dictionary<Guid, QMeta>();
        foreach (var section in exam.Sections ?? new RepeatedField<InternalDeliverySection>())
            foreach (var question in section.Questions ?? new RepeatedField<InternalDeliveryQuestion>())
            {
                var optionIds = (question.Options ?? new RepeatedField<InternalDeliveryOption>())
                    .Select(x => (Guid.Parse(x.Id), x.ContentMd ?? string.Empty))
                    .ToHashSet();
                map[Guid.Parse(question.Id)] = new QMeta(
                    Guid.Parse(section.Id),
                    question.Type ?? string.Empty,
                    optionIds
                );
            }
        return map;
    }

    public Dictionary<Guid, QMeta> BuildIndexFromDto(InternalExamDto.InternalDeliveryExam exam)
    {
        var map = new Dictionary<Guid, QMeta>();
        foreach (var section in exam.Sections)
            foreach (var question in section.Questions)
            {
                var optionIds = (question.Options)
                    .Select(x => (x.Id, x.ContentMd))
                    .ToHashSet();
                map[question.Id] = new QMeta(
                    section.Id,
                    question.Type,
                    optionIds
                );
            }

        return map;
    }



}
public sealed record AnswerKeyCompiled(
    Dictionary<Guid, QuestionKey> Keys,
    decimal TotalPoints
);
public interface IAnswerKeyBuilder
{
    AnswerKeyCompiled FromProto(InternalDeliveryExam exam);
    AnswerKeyCompiled FromDto(InternalExamDto.InternalDeliveryExam exam);
}
public class AnswerKeyBuilder(IAnswerValidator answerValidator) : IAnswerKeyBuilder
{

    public AnswerKeyCompiled FromProto(InternalDeliveryExam exam)
    {
        var map = new Dictionary<Guid, QuestionKey>();
        decimal total = 0;
        foreach (var section in exam.Sections ?? new RepeatedField<InternalDeliverySection>())
        {
            foreach (var question in section.Questions ?? new RepeatedField<InternalDeliveryQuestion>())
            {
                var type = question.Type ?? string.Empty;
                HashSet<(Guid id, string content)>? correct = null;
                // Include both single choice and multiple choice types
                if (answerValidator.IsSingleChoice(type) || type == QuestionType.MultipleChoiceMultiple)
                    correct = (question.Options ?? [])
                        .Where(x => x.HasIsCorrect && x.IsCorrect)
                        .Select(x => (Guid.Parse(x.Id), x.ContentMd ?? string.Empty))
                        .ToHashSet();

                var blankTexts = new Dictionary<string, string[]?>(StringComparer.OrdinalIgnoreCase);
                var blankRegex = new Dictionary<string, string[]?>(StringComparer.OrdinalIgnoreCase);
                foreach (var accept in question.CompletionAccepts ?? new RepeatedField<InternalCompletionAccept>())
                {
                    if (string.IsNullOrWhiteSpace(accept.BlankId)) continue;
                    if (accept.AcceptedTexts.Count > 0)
                        blankTexts[accept.BlankId] = accept.AcceptedTexts.ToArray();
                    if (accept.AcceptedRegex.Count > 0)
                        blankRegex[accept.BlankId] = accept.AcceptedRegex.ToArray();
                }

                var matchPairs = new Dictionary<string, string[]?>(StringComparer.OrdinalIgnoreCase);
                foreach (var pair in question.MatchPairs ?? new RepeatedField<InternalMatchPair>())
                {
                    if (string.IsNullOrWhiteSpace(pair.PromptKey)) continue;
                    if (pair.AcceptedValues.Count > 0)
                        matchPairs[pair.PromptKey] = pair.AcceptedValues.ToArray();
                }

                var order = question.OrderCorrects?.ToList() ?? new List<string>();
                var shortTexts = question.ShortAnswerAcceptTexts?.ToList() ?? new List<string>();
                var shortRegex = question.ShortAnswerAcceptRegex?.ToList() ?? new List<string>();

                var points = 1;
                total += points;
                var qid = Guid.Parse(question.Id);
                map[qid] = new QuestionKey(
                    qid,
                    type,
                    points,
                    correct,
                    blankTexts.Count > 0 ? blankTexts : null,
                    blankRegex.Count > 0 ? blankRegex : null,
                    matchPairs.Count > 0 ? matchPairs : null,
                    order.Count > 0 ? order : null,
                    shortTexts.Count > 0 ? shortTexts : null,
                    shortRegex.Count > 0 ? shortRegex : null);
            }
        }
        return new AnswerKeyCompiled(map, total);
    }

    public AnswerKeyCompiled FromDto(InternalExamDto.InternalDeliveryExam exam)
    {
        var keys = new Dictionary<Guid, QuestionKey>();
        decimal total = 0m;
        foreach (var section in exam.Sections ?? [])
        {
            foreach (var question in section.Questions ?? [])
            {
                var type = question.Type ?? string.Empty;
                HashSet<(Guid id, string content)>? correct = null;
                // Include both single choice and multiple choice types
                if (answerValidator.IsSingleChoice(type) || type == QuestionType.MultipleChoiceMultiple)
                    correct = (question.Options ?? [])
                        .Where(x => x.IsCorrect == true)
                        .Select(x => (x.Id, x.ContentMd ?? string.Empty))
                        .ToHashSet();
                var blankTexts = (question.BlankAcceptTexts ?? new Dictionary<string, string[]?>())
                    .Where(x => x.Value is { Length: > 0 })
                    .ToDictionary(x => x.Key, x => x.Value, StringComparer.OrdinalIgnoreCase);
                var blankRegex = (question.BlankAcceptRegex ?? new Dictionary<string, string[]?>())
                    .Where(x => x.Value is { Length: > 0 })
                    .ToDictionary(x => x.Key, x => x.Value, StringComparer.OrdinalIgnoreCase);
                var matchPairs = (question.MatchPairs ?? new Dictionary<string, string[]?>())
                    .Where(x => x.Value is { Length: > 0 })
                    .ToDictionary(x => x.Key, x => x.Value, StringComparer.OrdinalIgnoreCase);
                var order = (question.OrderCorrects ?? Array.Empty<string>()).Where(x => !string.IsNullOrWhiteSpace(x))
                    .ToList();
                var shortTexts = (question.ShortAnswerAcceptTexts ?? Array.Empty<string>())
                    .Where(x => !string.IsNullOrWhiteSpace(x)).ToList();
                var shortRegex = (question.ShortAnswerAcceptRegex ?? Array.Empty<string>())
                    .Where(x => !string.IsNullOrWhiteSpace(x)).ToList();
                var points = 1m;
                total += points;
                keys[question.Id] = new QuestionKey(
                    question.Id,
                    type,
                    points,
                    correct,
                    blankTexts.Count > 0 ? blankTexts : null,
                    blankRegex.Count > 0 ? blankRegex : null,
                    matchPairs.Count > 0 ? matchPairs : null,
                    order.Count > 0 ? order : null,
                    shortTexts.Count > 0 ? shortTexts : null,
                    shortRegex.Count > 0 ? shortRegex : null);

            }
        }
        return new AnswerKeyCompiled(keys, total);
    }

}
