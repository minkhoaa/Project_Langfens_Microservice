namespace exam_service.Application.Common;

using System.Linq;
using Shared.Grpc.ExamInternal;

/// <summary>
/// Paper-wide index normalizer for the gRPC proto
/// (<see cref="InternalDeliveryExam"/>). Sorts sections, groups, and questions
/// by their domain <c>Idx</c>, then renumbers questions to a global
/// monotonically-increasing sequence and sets each group's <c>StartIdx</c>/
/// <c>EndIdx</c> to that range. Mutates the input directly — protobuf's
/// <c>MergeFrom</c> on repeated fields APPENDS rather than replaces, so we
/// cannot use the clone+merge pattern; sorting and renumbering on the live
/// instance avoids duplicating any repeated field.
///
/// Proto sections only have <c>QuestionGroups</c> (no section-level
/// <c>Questions</c>), so the empty-group synthetic fallback lives in
/// <c>ProtoHelper.MapToProto</c> upstream. This adapter assumes groups are
/// already populated.
/// </summary>
public static partial class PaperWideNormalizer
{
    /// <summary>
    /// Renumbers the proto in place. Repeated fields are sorted via
    /// <c>Clear()</c> + <c>AddRange()</c> to avoid protobuf's append
    /// semantics on repeated fields. Idempotent — repeated calls produce the
    /// same final layout.
    /// </summary>
    public static void NormalizeInPlace(InternalDeliveryExam exam)
    {
        var counter = new Counter();

        var sortedSections = exam.Sections.OrderBy(s => s.Idx).ToList();
        exam.Sections.Clear();
        exam.Sections.AddRange(sortedSections);

        foreach (var section in exam.Sections)
        {
            if (section.QuestionGroups.Count == 0) continue;

            var sortedGroups = section.QuestionGroups.OrderBy(g => g.Idx).ToList();
            section.QuestionGroups.Clear();
            section.QuestionGroups.AddRange(sortedGroups);

            foreach (var group in section.QuestionGroups)
            {
                if (group.Questions.Count == 0) continue;

                var sortedQs = group.Questions.OrderBy(q => q.Idx).ToList();
                group.Questions.Clear();
                group.Questions.AddRange(sortedQs);

                var first = counter.Value;
                foreach (var q in group.Questions)
                {
                    q.Idx = counter.Value++;
                }
                group.StartIdx = first;
                group.EndIdx = counter.Value - 1;
            }
        }
    }

    /// <summary>
    /// Mutable cell so we can update a running counter across helpers without
    /// <c>ref</c> in lambda captures.
    /// </summary>
    private sealed class Counter
    {
        public int Value = 1;
    }
}
