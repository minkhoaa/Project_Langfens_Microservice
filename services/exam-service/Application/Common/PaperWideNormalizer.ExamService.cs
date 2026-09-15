namespace exam_service.Application.Common;

using System.Linq;
using exam_service.Contracts.Exams;

/// <summary>
/// Paper-wide index normalizer for the positional records local to
/// <c>exam-service/Contracts/Exams/Dto.Internal.cs</c> and
/// <c>Dto.Public.cs</c>. Implemented in the service's own assembly because
/// <c>Shared.PublicContracts</c> cannot reference <c>exam_service</c> (shared
/// contracts never references a service).
/// </summary>
public static partial class PaperWideNormalizer
{
    /// <summary>
    /// Renumbers the positional internal DTO. Returns a new record (records
    /// are immutable). Behavior mirrors <c>ProtoHelper.MapToProto</c>:
    /// when QuestionGroups is non-empty, only groups are renumbered; when
    /// empty, section-level Questions become one implicit group.
    /// </summary>
    public static InternalExamDto.InternalDeliveryExam Normalize(InternalExamDto.InternalDeliveryExam exam)
    {
        var sections = exam.Sections.ToList();
        sections.Sort((a, b) => a.Idx.CompareTo(b.Idx));

        var counter = new Counter();
        var stamped = new InternalExamDto.InternalDeliverySection[sections.Count];
        for (int i = 0; i < sections.Count; i++)
        {
            stamped[i] = StampSection(sections[i], counter);
        }
        return exam with { Sections = stamped };
    }

    private static InternalExamDto.InternalDeliverySection StampSection(InternalExamDto.InternalDeliverySection section, Counter counter)
    {
        if (section.QuestionGroups is { Count: > 0 } groups)
        {
            var gs = groups.ToList();
            gs.Sort((a, b) => a.Idx.CompareTo(b.Idx));
            var stampedGroups = new InternalExamDto.InternalDeliveryQuestionGroup[gs.Count];
            for (int i = 0; i < gs.Count; i++)
            {
                stampedGroups[i] = StampGroup(gs[i], counter);
            }
            return section with { QuestionGroups = stampedGroups, Questions = Array.Empty<InternalExamDto.InternalDeliveryQuestion>() };
        }

        // No groups → mirror proto fallback: bundle section-level Questions
        // into one implicit group, drop the section-level questions[].
        if (section.Questions is not { Count: > 0 } qs) return section;

        var sortedQs = qs.ToList();
        sortedQs.Sort((a, b) => a.Idx.CompareTo(b.Idx));

        var first = counter.Value;
        var newQs = new InternalExamDto.InternalDeliveryQuestion[sortedQs.Count];
        for (int i = 0; i < sortedQs.Count; i++)
        {
            newQs[i] = sortedQs[i] with { Idx = counter.Value++ };
        }
        var last = counter.Value - 1;

        var implicitGroup = new InternalExamDto.InternalDeliveryQuestionGroup(
            Guid.NewGuid(), 1, first, last, "", newQs);

        return section with
        {
            QuestionGroups = new[] { implicitGroup },
            Questions = Array.Empty<InternalExamDto.InternalDeliveryQuestion>(),
        };
    }

    private static InternalExamDto.InternalDeliveryQuestionGroup StampGroup(InternalExamDto.InternalDeliveryQuestionGroup group, Counter counter)
    {
        if (group.Questions is not { Count: > 0 } qsList) return group;

        var qs = qsList.ToList();
        qs.Sort((a, b) => a.Idx.CompareTo(b.Idx));
        var first = counter.Value;
        var newQs = new InternalExamDto.InternalDeliveryQuestion[qs.Count];
        for (int i = 0; i < qs.Count; i++)
        {
            newQs[i] = qs[i] with { Idx = counter.Value++ };
        }
        var last = counter.Value - 1;

        return group with
        {
            StartIdx = first,
            EndIdx = last,
            Questions = newQs,
        };
    }

    /// <summary>
    /// Renumbers the public exam DTO. Each section can have top-level
    /// <c>Questions</c> plus optional <c>QuestionGroups</c>; behavior mirrors
    /// <see cref="Normalize(InternalExamDto.InternalDeliveryExam)"/>.
    /// </summary>
    public static Dto_Public.PubLicExamDetailRecord Normalize(Dto_Public.PubLicExamDetailRecord exam)
    {
        var sections = exam.sections.ToList();
        sections.Sort((a, b) => a.idx.CompareTo(b.idx));

        var counter = new ExamServiceCounter();
        var stamped = new Dto_Public.PublicSectionRecord[sections.Count];
        for (int i = 0; i < sections.Count; i++)
        {
            stamped[i] = StampPublicSection(sections[i], counter);
        }

        return exam with { sections = stamped };
    }

    private static Dto_Public.PublicSectionRecord StampPublicSection(Dto_Public.PublicSectionRecord section, ExamServiceCounter counter)
    {
        if (section.QuestionGroups is { Count: > 0 } groups)
        {
            var gs = groups.ToList();
            gs.Sort((a, b) => a.Idx.CompareTo(b.Idx));
            var stampedGroups = new List<Dto_Public.PublicQuestionGroupRecord>(gs.Count);
            foreach (var g in gs)
            {
                stampedGroups.Add(StampPublicGroup(g, counter));
            }
            return section with { QuestionGroups = stampedGroups, Questions = new List<Dto_Public.PublicQuestionRecord>() };
        }

        if (section.Questions is not { Count: > 0 } qs) return section;

        var sortedQs = qs.ToList();
        sortedQs.Sort((a, b) => a.Idx.CompareTo(b.Idx));

        var first = counter.Value;
        var newQs = new Dto_Public.PublicQuestionRecord[sortedQs.Count];
        for (int i = 0; i < sortedQs.Count; i++)
        {
            newQs[i] = sortedQs[i] with { Idx = counter.Value++ };
        }
        var last = counter.Value - 1;

        var implicitGroup = new Dto_Public.PublicQuestionGroupRecord(
            Guid.NewGuid(), 1, first, last, "", new List<Dto_Public.PublicQuestionRecord>(newQs));

        return section with
        {
            QuestionGroups = new List<Dto_Public.PublicQuestionGroupRecord> { implicitGroup },
            Questions = new List<Dto_Public.PublicQuestionRecord>(),
        };
    }

    private static Dto_Public.PublicQuestionGroupRecord StampPublicGroup(Dto_Public.PublicQuestionGroupRecord group, ExamServiceCounter counter)
    {
        if (group.Questions is not { Count: > 0 } qsList) return group;

        var qs = qsList.ToList();
        qs.Sort((a, b) => a.Idx.CompareTo(b.Idx));
        var first = counter.Value;
        var newQs = new Dto_Public.PublicQuestionRecord[qs.Count];
        for (int i = 0; i < qs.Count; i++)
        {
            newQs[i] = qs[i] with { Idx = counter.Value++ };
        }
        var last = counter.Value - 1;

        return group with
        {
            StartIdx = first,
            EndIdx = last,
            Questions = new List<Dto_Public.PublicQuestionRecord>(newQs),
        };
    }

    /// <summary>
    /// Shared mutable counter so the helpers above can avoid <c>ref</c> in
    /// lambda captures. Scoped per top-level <c>Normalize</c> call.
    /// Renamed from <c>Counter</c> to avoid collision with the same private
    /// class declared in the partial Proto file.
    /// </summary>
    private sealed class ExamServiceCounter
    {
        public int Value = 1;
    }
}
