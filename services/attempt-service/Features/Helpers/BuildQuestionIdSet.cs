using System.Text.Json;
using Google.Protobuf.Collections;
using Shared.ExamDto.Contracts.Exam.Enums;
using Shared.ExamDto.Contracts.Exam.InternalExamDto;
using Shared.Grpc.ExamInternal;

namespace attempt_service.Features.Helpers;

public static class BuildQuestionIdSet
{
    public static HashSet<int> Build(JsonDocument paper)
    {
        var set = new HashSet<int>();
        if (!paper.RootElement.TryGetProperty("sections", out var sections)) return set;
        foreach (var s in sections.EnumerateArray())
        {
            if (!s.TryGetProperty("questions", out var qs)) continue;
            foreach (var q in qs.EnumerateArray())
                if (q.TryGetProperty("id", out var idProp))
                    set.Add(idProp.GetInt32());
        }

        return set;
    }
}

public static class QuestionIndex
{
    public static Dictionary<int, (int SectionId, string Type, HashSet<int> OptionIds)> Build(JsonDocument doc)
    {
        var map = new Dictionary<int, (int, string, HashSet<int>)>();
        if (!doc.RootElement.TryGetProperty("sections", out var sections)) return map;
        foreach (var s in sections.EnumerateArray())
        {
            var sectionId = s.GetProperty("id").GetInt32();
            if (!s.TryGetProperty("questions", out var qs)) continue;
            foreach (var q in qs.EnumerateArray())
            {
                var qid = q.GetProperty("id").GetInt32();
                var type = q.TryGetProperty("type", out var t) ? t.GetString() ?? "" : "";
                var opts = new HashSet<int>();
                if (q.TryGetProperty("options", out var os))
                    foreach (var o in os.EnumerateArray())
                        if (o.TryGetProperty("id", out var oid))
                            opts.Add(oid.GetInt32());
                map[qid] = (sectionId, type, opts);
            }
        }

        return map;
    }
}

public static class IndexBuilder
{
    public static Dictionary<int, QMeta> BuildIndexFromProto(InternalDeliveryExam exam)
    {
        var map = new Dictionary<int, QMeta>();
        foreach (var section in exam.Sections ?? new RepeatedField<InternalDeliverySection>())
        foreach (var question in section.Questions ?? new RepeatedField<InternalDeliveryQuestion>())
        {
            var optionIds = (question.Options ?? new RepeatedField<InternalDeliveryOption>())
                .Select(x => x.Id).ToHashSet() ?? [];
            map[question.Id] = new QMeta(section.Id, question.Type ?? string.Empty, optionIds);
        }

        return map;
    }

    public static Dictionary<int, QMeta> BuildIndexFromDto(InternalExamDto.InternalDeliveryExam exam)
    {
        var map = new Dictionary<int, QMeta>();
        foreach (var section in exam.Sections)
        foreach (var question in section.Questions)
        {
            var optionIds = (question.Options ?? []).Select(x => x.Id).ToHashSet() ?? [];
            map[question.Id] = new QMeta(section.Id, question.Type ?? string.Empty, optionIds);
        }

        return map;
    }

    public sealed record QMeta(int SectionId, string Type, HashSet<int> OptionIds);
}

public static class AnswerKeyBuilder
{
    public sealed record AnswerKeyCompiled(
        Dictionary<int, QuestionKey> Keys,
        double TotalPoints
    );
    public static AnswerKeyCompiled FromProto(InternalDeliveryExam exam)
    {
        var map = new Dictionary<int, QuestionKey>();
        double total = 0;
        foreach (var section in exam.Sections ?? new RepeatedField<InternalDeliverySection>())
        {
            foreach (var question in section.Questions ?? new RepeatedField<InternalDeliveryQuestion>())
            {
                var type = question.Type ?? string.Empty;
                HashSet<int>? correct = null;
                if (AnswerValidator.IsSingleChoice(type))
                    correct = (question.Options ?? [])
                        .Where(x => x.IsCorrect == true)
                        .Select(o => o.Id).ToHashSet();

                var points = 1;
                total += points;
                map[question.Id] = new  QuestionKey(
                    question.Id,type,points, correct);
            }
        }
        return new AnswerKeyCompiled(map, total);
    }

    public static AnswerKeyCompiled FromDto(InternalExamDto.InternalDeliveryExam exam)
    {
        var keys = new Dictionary<int, QuestionKey>();
        double total = 0;
        foreach (var section in exam.Sections ?? []) 
        {
            foreach (var question in section.Questions ?? [])
            {
                var type = question.Type ?? string.Empty;
                HashSet<int>? correct = null!;
                if (AnswerValidator.IsSingleChoice(type))
                    correct = (question.Options ?? [])
                        .Where(x => x.IsCorrect == true)
                        .Select(x => x.Id)
                        .ToHashSet();
                int points = 1;
                total += points;
                keys[question.Id] = new QuestionKey(
                    question.Id,type,points, correct);
                
            }
        }

        return new AnswerKeyCompiled(keys, total);
    }

}