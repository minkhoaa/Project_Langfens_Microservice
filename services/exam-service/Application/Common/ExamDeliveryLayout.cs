using exam_service.Domains.Entities;

namespace exam_service.Application.Common;

/// <summary>Shared HTTP/gRPC membership policy. Explicit membership wins over legacy bounds.</summary>
public static class ExamDeliveryLayout
{
    public static List<ExamQuestionGroup> Groups(ExamSection section)
    {
        var groups = section.QuestionGroups.Where(g => g.SectionId == section.Id)
            .OrderBy(g => g.Idx).ThenBy(g => g.Id).ToList();
        var questions = section.Questions.Where(q => q.SectionId == section.Id)
            .OrderBy(q => q.Idx).ThenBy(q => q.Id).ToList();
        var assigned = groups.ToDictionary(g => g.Id, _ => new List<ExamQuestion>());
        var ungrouped = new List<ExamQuestion>();
        foreach (var question in questions)
        {
            // Only old rows without a GroupId may use legacy index bounds. Ambiguous
            // overlaps remain ungrouped rather than duplicating or guessing ownership.
            var owner = question.GroupId;
            if (owner == null)
            {
                var candidates = groups.Where(g => question.Idx >= g.StartIdx && question.Idx <= g.EndIdx).ToList();
                if (candidates.Count == 1) owner = candidates[0].Id;
            }
            if (owner is Guid id && assigned.TryGetValue(id, out var members)) members.Add(question);
            else ungrouped.Add(question);
        }
        var result = groups.Select(g => new ExamQuestionGroup
        {
            Id = g.Id, SectionId = section.Id, Idx = g.Idx,
            StartIdx = g.StartIdx, EndIdx = g.EndIdx, InstructionMd = g.InstructionMd,
            Questions = assigned[g.Id]
        }).ToList();
        if (ungrouped.Count > 0)
            result.Add(new ExamQuestionGroup
            {
                Id = section.Id, SectionId = section.Id,
                Idx = groups.Count == 0 ? 1 : groups.Max(g => g.Idx) + 1,
                StartIdx = ungrouped[0].Idx, EndIdx = ungrouped[^1].Idx,
                InstructionMd = section.InstructionsMd ?? string.Empty, Questions = ungrouped
            });
        return result;
    }

    // A deterministic bank must not depend on the solution sequence. Sort before
    // mapping; random shuffles can accidentally reproduce that sequence.
    public static List<string> FlowKeys(IEnumerable<string>? keys) => (keys ?? [])
        .Where(k => !string.IsNullOrWhiteSpace(k))
        .Distinct(StringComparer.Ordinal).OrderBy(k => k, StringComparer.Ordinal).ToList();
}
