using System.Text.Json;
using Google.Protobuf;
using Shared.ExamDto.Contracts.Exam.InternalExamDto;
using Shared.Grpc.ExamInternal;

namespace attempt_service.Features.Helpers;

/// <summary>Reads historical REST snapshots and current grouped protobuf JSON without dropping grading keys.</summary>
public sealed record AttemptSnapshot(InternalDeliveryExam? Proto, InternalExamDto.InternalDeliveryExam? Dto);

public static class AttemptSnapshotReader
{
    public static AttemptSnapshot Read(JsonElement snapshot)
    {
        if (snapshot.ValueKind != JsonValueKind.Object || !snapshot.TryGetProperty("sections", out var sections)
            || sections.ValueKind != JsonValueKind.Array)
            throw new JsonException("Snapshot must contain a sections array.");

        Names(snapshot, "sections");
        var protoAliases = snapshot.EnumerateObject().Any(property => property.Name is "image_url" or "duration_min" or "description_md");
        var sectionIds = new HashSet<Guid>();
        var groupIds = new HashSet<Guid>();
        var questionIds = new HashSet<Guid>();
        var optionIds = new HashSet<Guid>();
        var dtoShape = false;
        var protoKeys = false;
        foreach (var section in sections.EnumerateArray())
        {
            var sectionId = Identity(section, sectionIds);
            protoAliases |= section.EnumerateObject().Any(property => property.Name is "question_groups" or "instructions_md" or "passage_md" or "audio_url" or "transcript_md");
            var flat = Array(section, "questions");
            var groups = Array(section, "questionGroups", "question_groups");
            if (flat.GetArrayLength() > 0 && groups.GetArrayLength() > 0)
                throw new JsonException("Snapshot has conflicting section and group question ownership.");
            dtoShape |= flat.GetArrayLength() > 0;
            foreach (var question in flat.EnumerateArray()) CheckQuestion(question, sectionId, null);
            foreach (var group in groups.EnumerateArray())
            {
                var groupId = Identity(group, groupIds);
                foreach (var question in Array(group, "questions").EnumerateArray())
                    CheckQuestion(question, sectionId, groupId);
            }
        }
        // A DTO dictionary cannot stand in for the protobuf array (or vice versa).
        // Unsupported hybrids fail closed rather than silently compiling incomplete keys.
        if (dtoShape && (protoKeys || protoAliases))
            throw new JsonException("Snapshot mixes REST dictionaries with protobuf key arrays.");
        if (dtoShape) return ReadDto(snapshot);

        try
        {
            var parser = new JsonParser(JsonParser.Settings.Default.WithIgnoreUnknownFields(true));
            return new AttemptSnapshot(parser.Parse<InternalDeliveryExam>(snapshot.GetRawText()), null);
        }
        catch (InvalidProtocolBufferException) when (!protoKeys && !protoAliases)
        {
            // Retain legacy REST parsing (including duplicate scalar title fields).
            // Identity/ownership validation already ran and must not be bypassed.
            return ReadDto(snapshot);
        }

        void CheckQuestion(JsonElement question, Guid sectionId, Guid? groupId)
        {
            Identity(question, questionIds);
            Names(question, "blankAcceptTexts", "blankAcceptRegex", "matchPairs", "completionAccepts",
                "orderCorrects", "shortAnswerAcceptTexts", "shortAnswerAcceptRegex", "modelAnswers", "wordList");
            protoAliases |= question.EnumerateObject().Any(property => property.Name is "completion_accepts" or "match_pairs"
                or "order_corrects" or "short_answer_accept_texts" or "short_answer_accept_regex" or "flow_chart_nodes");
            CheckOwner(question, "sectionId", sectionId);
            CheckOwner(question, "groupId", groupId);
            foreach (var option in Array(question, "options").EnumerateArray()) Identity(option, optionIds);
            foreach (var name in new[] { "blankAcceptTexts", "blankAcceptRegex", "modelAnswers", "wordList", "groupId" })
                dtoShape |= question.TryGetProperty(name, out _);
            if (question.TryGetProperty("matchPairs", out var pairs) && pairs.ValueKind == JsonValueKind.Object)
                dtoShape = true;
            if (question.TryGetProperty("completionAccepts", out _) || question.TryGetProperty("completion_accepts", out _)
                || (question.TryGetProperty("matchPairs", out pairs) && pairs.ValueKind == JsonValueKind.Array)
                || question.TryGetProperty("match_pairs", out _))
                protoKeys = true;
            foreach (var name in new[] { "blankAcceptTexts", "blankAcceptRegex", "matchPairs" })
            {
                if (!question.TryGetProperty(name, out var map) || map.ValueKind != JsonValueKind.Object) continue;
                var keys = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                foreach (var pair in map.EnumerateObject())
                    if (!keys.Add(pair.Name)) throw new JsonException("Snapshot has ambiguous grading keys.");
            }
        }
    }

    private static AttemptSnapshot ReadDto(JsonElement snapshot)
    {
        var dto = snapshot.Deserialize<InternalExamDto.InternalDeliveryExam>(new JsonSerializerOptions { PropertyNameCaseInsensitive = true })
                  ?? throw new JsonException("Snapshot DTO is invalid.");
        // Historic nullable key collections mean no key, not permission to skip sanitization.
        dto = dto with
        {
            Sections = dto.Sections.Select(section => section with
            {
                Questions = section.Questions?.Select(Keys).ToArray(),
                QuestionGroups = section.QuestionGroups.Select(group => group with { Questions = group.Questions.Select(Keys).ToArray() }).ToArray()
            }).ToArray()
        };
        return new AttemptSnapshot(null, PaperWideNormalizer.Normalize(dto));
    }

    private static InternalExamDto.InternalDeliveryQuestion Keys(InternalExamDto.InternalDeliveryQuestion question) => question with
    {
        BlankAcceptTexts = question.BlankAcceptTexts ?? new Dictionary<string, string[]?>(),
        BlankAcceptRegex = question.BlankAcceptRegex ?? new Dictionary<string, string[]?>(),
        MatchPairs = question.MatchPairs ?? new Dictionary<string, string[]?>()
    };

    private static Guid Identity(JsonElement value, HashSet<Guid> ids)
    {
        if (value.ValueKind != JsonValueKind.Object) throw new JsonException("Snapshot node is malformed.");
        Names(value, "id");
        if (!value.TryGetProperty("id", out var property)
            || property.ValueKind != JsonValueKind.String || !Guid.TryParse(property.GetString(), out var id)
            || id == Guid.Empty || !ids.Add(id) || value.EnumerateObject().Count(p => p.NameEquals("id")) != 1)
            throw new JsonException("Snapshot has a missing, malformed or duplicate identity.");
        return id;
    }

    private static void CheckOwner(JsonElement value, string name, Guid? expected)
    {
        Names(value, name);
        if (!value.TryGetProperty(name, out var property) || property.ValueKind == JsonValueKind.Null) return;
        if (property.ValueKind != JsonValueKind.String || !Guid.TryParse(property.GetString(), out var owner) || owner == Guid.Empty
            || (expected.HasValue && owner != expected.Value))
            throw new JsonException("Snapshot has conflicting question ownership.");
    }

    // Missing arrays have the historical empty-collection meaning. Explicit nulls,
    // scalars and competing aliases are malformed; protobuf would otherwise ignore some of them.
    private static JsonElement Array(JsonElement value, string name, string? alias = null)
    {
        Names(value, name);
        if (alias is not null) Names(value, alias);
        var present = value.TryGetProperty(name, out var property);
        if (alias is not null && value.TryGetProperty(alias, out var alternate))
        {
            if (present) throw new JsonException("Snapshot has duplicate collection aliases.");
            property = alternate;
            present = true;
        }
        if (!present) return EmptyArray;
        if (property.ValueKind != JsonValueKind.Array || value.EnumerateObject().Count(p => p.NameEquals(name)) > 1)
            throw new JsonException("Snapshot collection is malformed.");
        return property;
    }

    private static void Names(JsonElement value, params string[] names)
    {
        var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var property in value.EnumerateObject())
        {
            var name = names.FirstOrDefault(candidate => candidate.Equals(property.Name, StringComparison.OrdinalIgnoreCase));
            if (name is not null && (property.Name != name || !seen.Add(name)))
                throw new JsonException("Snapshot has ambiguous structural fields.");
        }
    }

    private static readonly JsonElement EmptyArray = JsonSerializer.SerializeToElement(System.Array.Empty<object>());
}
