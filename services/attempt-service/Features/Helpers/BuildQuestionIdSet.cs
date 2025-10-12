using System.Text.Json;
using Google.Protobuf.Collections;
using Shared.ExamDto.Contracts.Exam.Enums;
using Shared.ExamDto.Contracts.Exam.InternalExamDto;
using Shared.Grpc.ExamInternal;

namespace attempt_service.Features.Helpers;

public static class BuildQuestionIdSet
{
    public static HashSet<Guid> Build(JsonDocument paper)
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

public static class QuestionIndex
{
    public static Dictionary<Guid, (Guid SectionId, string Type, HashSet<Guid> OptionIds)> Build(JsonDocument doc)
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

public static class IndexBuilder
{
    public static Dictionary<Guid, QMeta> BuildIndexFromProto(InternalDeliveryExam exam)
    {
        var map = new Dictionary<Guid, QMeta>();
        foreach (var section in exam.Sections ?? new RepeatedField<InternalDeliverySection>())
        foreach (var question in section.Questions ?? new RepeatedField<InternalDeliveryQuestion>())
        {
            var optionIds = (question.Options ?? new RepeatedField<InternalDeliveryOption>())
                .Select(x => Guid.Parse(x.Id)).ToHashSet() ?? [];
            map[Guid.Parse(question.Id)] = new QMeta(Guid.Parse(section.Id), question.Type ?? string.Empty, optionIds);
        }
        return map;
    }

    public static Dictionary<Guid, QMeta> BuildIndexFromDto(InternalExamDto.InternalDeliveryExam exam)
    {
        var map = new Dictionary<Guid, QMeta>();
        foreach (var section in exam.Sections)
        foreach (var question in section.Questions)
        {
            var optionIds = (question.Options ?? []).Select(x => x.Id).ToHashSet() ?? [];
            map[question.Id] = new QMeta(section.Id, question.Type ?? string.Empty, optionIds);
        }

        return map;
    }

    public sealed record QMeta(Guid SectionId, string Type, HashSet<Guid> OptionIds);
}

public static class AnswerKeyBuilder
{
    public sealed record AnswerKeyCompiled(
        Dictionary<Guid, QuestionKey> Keys,
        decimal TotalPoints
    );
    public static AnswerKeyCompiled FromProto(InternalDeliveryExam exam)
    {
        var map = new Dictionary<Guid, QuestionKey>();
        decimal total = 0;
        foreach (var section in exam.Sections ?? new RepeatedField<InternalDeliverySection>())
        {
            foreach (var question in section.Questions ?? new RepeatedField<InternalDeliveryQuestion>())
            {
                var type = question.Type ?? string.Empty;
                HashSet<Guid>? correct = null;
                if (AnswerValidator.IsSingleChoice(type))
                    correct = (question.Options ?? [])
                        .Where(x => x.HasIsCorrect && x.IsCorrect)
                        .Select(x => Guid.Parse(x.Id))
                        .ToHashSet();

                var points = 1;
                total += points;
                var qid = Guid.Parse(question.Id);
                map[qid] = new  QuestionKey(
                    qid,type,points, correct);
            }
        }
        return new AnswerKeyCompiled(map, total);
    }

    public static AnswerKeyCompiled FromDto(InternalExamDto.InternalDeliveryExam exam)
    {
        var keys = new Dictionary<Guid, QuestionKey>();
        decimal total = 0m;
        foreach (var section in exam.Sections ?? []) 
        {
            foreach (var question in section.Questions ?? [])
            {
                var type = question.Type ?? string.Empty;
                HashSet<Guid>? correct = null!;
                if (AnswerValidator.IsSingleChoice(type))
                    correct = (question.Options ?? [])
                        .Where(x => x.IsCorrect == true)
                        .Select(x => x.Id)
                        .ToHashSet();
                var points = 1m;
                total += points;
                keys[question.Id] = new QuestionKey(
                    question.Id,type,points, correct);
                
            }
        }
        return new AnswerKeyCompiled(keys, total);
    }

}
