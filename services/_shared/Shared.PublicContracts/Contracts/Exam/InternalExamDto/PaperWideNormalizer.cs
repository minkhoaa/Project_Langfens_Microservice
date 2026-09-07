using System.IO;
using System.Text.Json;

namespace Shared.ExamDto.Contracts.Exam.InternalExamDto;

/// <summary>
/// Paper-wide index normalizer for the shared init-property DTO and a
/// <see cref="JsonElement"/> snapshot. Implements the contract from
/// <c>docs/be-paper-data-shape.md</c>: every <c>Q.idx</c> becomes a
/// paper-wide 1-based integer, and each <c>Group.startIdx/endIdx</c> points
/// at the first/last question of that group.
///
/// Sections whose <c>QuestionGroups</c> is empty fall back to treating
/// section-level <c>questions[]</c> (legacy positional DTO shape emitted by
/// REST <c>InternalExam_Service.GetByExamIdAsync</c>) as one synthetic group
/// spanning the section. This mirrors
/// <c>exam-service/Application/Common/ProtoHelper.MapToProto</c>'s fallback.
///
/// Pure: no DB I/O, no answer-key reads, no mutation of skill/type/prompt.
/// Does not touch <c>QuestionGroup.Idx</c> or option <c>Idx</c>.
///
/// Two adapters live outside this assembly:
/// <list type="bullet">
///   <item><c>exam-service/Application/Common/PaperWideNormalizer.Proto.cs</c> — gRPC proto (in place).</item>
///   <item><c>exam-service/Application/Common/PaperWideNormalizer.ExamService.cs</c> — positional internal DTO + <c>Dto_Public</c>.</item>
/// </list>
/// </summary>
public static class PaperWideNormalizer
{
    /// <summary>
    /// Renumbers the shared init-property DTO. Returns a new record; the input
    /// is not mutated. Empty papers return as-is.
    /// </summary>
    public static InternalExamDto.InternalDeliveryExam Normalize(InternalExamDto.InternalDeliveryExam exam)
    {
        if (exam.Sections.Count == 0) return exam;

        var paperWide = 1;

        // Order sections by Idx. OrderBy is a stable LINQ projection: since
        // OrderBy cannot mutate a captured `ref`, materialize the ordered list
        // once into an array, then walk it.
        var orderedSections = new InternalExamDto.InternalDeliverySection[exam.Sections.Count];
        var sorted = exam.Sections.ToArray();
        System.Array.Sort(sorted, (a, b) => a.Idx.CompareTo(b.Idx));

        for (int i = 0; i < sorted.Length; i++)
        {
            sorted[i] = StampSection(sorted[i], ref paperWide);
        }

        return exam with { Sections = sorted };
    }

    private static InternalExamDto.InternalDeliverySection StampSection(InternalExamDto.InternalDeliverySection section, ref int paperWide)
    {
        if (section.QuestionGroups.Count == 0) return section;

        var groups = section.QuestionGroups.ToArray();
        System.Array.Sort(groups, (a, b) => a.Idx.CompareTo(b.Idx));

        for (int i = 0; i < groups.Length; i++)
        {
            groups[i] = StampGroup(groups[i], ref paperWide);
        }

        return section with { QuestionGroups = groups };
    }

    private static InternalExamDto.InternalDeliveryQuestionGroup StampGroup(InternalExamDto.InternalDeliveryQuestionGroup group, ref int paperWide)
    {
        if (group.Questions.Count == 0) return group;

        var qs = group.Questions.ToArray();
        System.Array.Sort(qs, (a, b) => a.Idx.CompareTo(b.Idx));

        var firstIdx = paperWide;
        var newQs = new InternalExamDto.InternalDeliveryQuestion[qs.Length];
        for (int i = 0; i < qs.Length; i++)
        {
            newQs[i] = qs[i] with { Idx = paperWide++ };
        }
        var lastIdx = paperWide - 1;

        return group with
        {
            StartIdx = firstIdx,
            EndIdx = lastIdx,
            Questions = newQs,
        };
    }

    /// <summary>
    /// Renumbers a JsonElement snapshot round-tripped through System.Text.Json.
    /// Used by attempt-service read-time safety net where stored PaperJson rows
    /// may still carry section-local indices from before this helper existed.
    /// </summary>
    public static JsonElement NormalizeJsonElement(JsonElement snapshot)
    {
        using var input = JsonDocument.Parse(snapshot.GetRawText());
        using var ms = new MemoryStream();
        using (var writer = new Utf8JsonWriter(ms))
        {
            var paperWide = 1;
            WriteExam(writer, input.RootElement, ref paperWide);
        }
        ms.Position = 0;
        using var output = JsonDocument.Parse(ms.ToArray());
        return output.RootElement.Clone();
    }

    private static void WriteExam(Utf8JsonWriter writer, JsonElement exam, ref int paperWide)
    {
        if (exam.ValueKind != JsonValueKind.Object)
        {
            exam.WriteTo(writer);
            return;
        }

        writer.WriteStartObject();
        foreach (var p in exam.EnumerateObject())
        {
            if (p.NameEquals("sections"))
            {
                writer.WritePropertyName(p.Name);
                WriteSections(writer, p.Value, ref paperWide);
            }
            else
            {
                p.WriteTo(writer);
            }
        }
        writer.WriteEndObject();
    }

    private static void WriteSections(Utf8JsonWriter writer, JsonElement sections, ref int paperWide)
    {
        writer.WriteStartArray();
        foreach (var sec in sections.EnumerateArray())
        {
            var hasGroups = sec.TryGetProperty("questionGroups", out var groupsEl)
                && groupsEl.ValueKind == JsonValueKind.Array
                && groupsEl.GetArrayLength() > 0;
            var hasSectionQuestions = sec.TryGetProperty("questions", out var secQsEl)
                && secQsEl.ValueKind == JsonValueKind.Array
                && secQsEl.GetArrayLength() > 0;

            writer.WriteStartObject();
            if (!hasGroups && hasSectionQuestions)
            {
                writer.WritePropertyName("questionGroups");
                writer.WriteStartArray();
                writer.WriteStartObject();
                int first = paperWide;
                paperWide += secQsEl.GetArrayLength();
                writer.WriteNumber("startIdx", first);
                writer.WriteNumber("endIdx", paperWide - 1);
                writer.WritePropertyName("questions");
                WriteQuestions(writer, secQsEl, ref first);
                writer.WriteEndObject();
                writer.WriteEndArray();
            }
            else
            {
                foreach (var p in sec.EnumerateObject())
                {
                    if (p.NameEquals("questionGroups"))
                    {
                        writer.WritePropertyName(p.Name);
                        WriteGroups(writer, p.Value, ref paperWide);
                    }
                    else
                    {
                        p.WriteTo(writer);
                    }
                }
            }
            writer.WriteEndObject();
        }
        writer.WriteEndArray();
    }

    private static void WriteGroups(Utf8JsonWriter writer, JsonElement groups, ref int paperWide)
    {
        writer.WriteStartArray();
        foreach (var grp in groups.EnumerateArray())
        {
            writer.WriteStartObject();
            int first = paperWide;
            JsonElement? qs = null;

            foreach (var p in grp.EnumerateObject())
            {
                if (p.NameEquals("questions"))
                {
                    qs = p.Value;
                    continue;
                }
                p.WriteTo(writer);
            }

            if (qs is { } qsel && qsel.ValueKind == JsonValueKind.Array && qsel.GetArrayLength() > 0)
            {
                int count = qsel.GetArrayLength();
                paperWide += count;
                writer.WriteNumber("startIdx", first);
                writer.WriteNumber("endIdx", paperWide - 1);
                writer.WritePropertyName("questions");
                WriteQuestions(writer, qsel, ref first);
            }
            else
            {
                writer.WriteNumber("startIdx", paperWide);
                writer.WriteNumber("endIdx", paperWide);
            }
            writer.WriteEndObject();
        }
        writer.WriteEndArray();
    }

    private static void WriteQuestions(Utf8JsonWriter writer, JsonElement qs, ref int first)
    {
        writer.WriteStartArray();
        foreach (var q in qs.EnumerateArray())
        {
            int stampedIdx = first++;
            writer.WriteStartObject();
            foreach (var p in q.EnumerateObject())
            {
                if (p.NameEquals("idx"))
                {
                    writer.WriteNumber("idx", stampedIdx);
                }
                else
                {
                    p.WriteTo(writer);
                }
            }
            writer.WriteEndObject();
        }
        writer.WriteEndArray();
    }
}
