namespace exam_service.Application.Common;

using System.Linq;
using Shared.Grpc.ExamInternal;

/// <summary>
/// Paper-wide index normalizer for the gRPC proto
/// (<see cref="InternalDeliveryExam"/>). Mutates a deep-cloned snapshot of
/// the input and merges back, so the caller's instance is left intact iff
/// they pass a fresh clone — matches
/// <c>attempt-service/Features/Helpers/ExamGateway.GrpcSnapshotSanitizer</c>'s
/// clone-then-mutate pattern. See <c>docs/be-paper-data-shape.md</c> for the
/// contract.
///
/// Proto sections only have <c>QuestionGroups</c> (no section-level
/// <c>Questions</c>), so the empty-group synthetic fallback lives in
/// <c>ProtoHelper.MapToProto</c> upstream. This adapter assumes groups are
/// already populated.
/// </summary>
public static partial class PaperWideNormalizer
{
    /// <summary>
    /// Renumbers the proto in place via an internal <c>Clone()</c> + mutate +
    /// <c>MergeFrom()</c>. Idempotent — works whether the caller passes a
    /// live or pre-cloned instance.
    /// </summary>
    public static void NormalizeInPlace(InternalDeliveryExam exam)
    {
        var draft = exam.Clone();
        var counter = new Counter();

        var sections = draft.Sections.ToList();
        sections.Sort((a, b) => a.Idx.CompareTo(b.Idx));

        foreach (var section in sections)
        {
            if (section.QuestionGroups.Count == 0) continue;

            var groups = section.QuestionGroups.ToList();
            groups.Sort((a, b) => a.Idx.CompareTo(b.Idx));
            foreach (var group in groups)
            {
                if (group.Questions.Count == 0) continue;

                var qs = group.Questions.ToList();
                qs.Sort((a, b) => a.Idx.CompareTo(b.Idx));

                var first = counter.Value;
                foreach (var q in qs)
                {
                    q.Idx = counter.Value++;
                }
                group.StartIdx = first;
                group.EndIdx = counter.Value - 1;
            }
        }

        exam.MergeFrom(draft);
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
