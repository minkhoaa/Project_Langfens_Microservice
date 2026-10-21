using System.Text.Json;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper.Contracts;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace exam_service.Features.ReadingPaper;

public static class ReadingPaperFinalSnapshot
{
    // Matches the canonical paper evaluator registry, not caller-supplied approvals.
    // G12 invariant: eval_paper_structure (2.0.0), eval_paper_cross_section (2.0.0), eval_paper_leakage (2.1.0), eval_paper_monotony (2.0.0)
    public static readonly IReadOnlyDictionary<string, string> RequiredEvaluators = new Dictionary<string, string>
    {
        ["eval_paper_structure"] = "2.0.0",
        ["eval_paper_cross_section"] = "2.0.0",
        ["eval_paper_leakage"] = "2.1.0",
        ["eval_paper_monotony"] = "2.0.0"
    };

    // G12: tolerance window for clock jitter when comparing evaluation EvaluatedAt
    // to the authoritative artifact cutoff (backward-only, forward jitter already handled by file scope).
    public static readonly TimeSpan EvaluationBackwardJitter = TimeSpan.FromSeconds(2);
    public static readonly TimeSpan EvaluationForwardJitter = TimeSpan.FromSeconds(5);

    public static async Task<List<ReadingGeneratedSection>> LoadAsync(
        ExamDbContext db, ReadingPaperRun run, ReadingPaperJob job,
        IReadOnlyList<EvaluationResult>? finalEvaluations, CancellationToken ct)
    {
        var heads = await db.ReadingPaperArtifactHeads.AsNoTracking()
            .Where(h => h.RunId == run.RunId).ToDictionaryAsync(h => h.ArtifactId, ct);
        var artifacts = await db.ReadingPaperArtifacts.AsNoTracking().Where(a => a.RunId == run.RunId).ToListAsync(ct);
        var accepted = artifacts.Where(a => heads.TryGetValue(a.ArtifactId, out var h)
            && h.AcceptedVersion == a.Version && h.AcceptedHash == a.ContentHash)
            .ToDictionary(a => a.ArtifactId, a => Deserialize(a), StringComparer.Ordinal);
        var papers = accepted.Values.Where(a => a.ArtifactType == ArtifactType.ReadingPaper).ToList();
        if (papers.Count != 1)
            throw Invalid("Exactly one authoritative accepted paper is required");
        var paper = papers[0];
        var checkedIds = new HashSet<string>(StringComparer.Ordinal);
        void CheckClosure(ArtifactEnvelope envelope)
        {
            if (!checkedIds.Add(envelope.ArtifactId)) return;
            if (envelope.RunId != run.RunId || envelope.ContentHash != ArtifactEnvelope.ComputeContentHash(envelope.Payload, envelope.ParentRefs))
                throw Invalid("Authoritative envelope identity or hash mismatch");
            if (envelope.ParentRefs.Select(r => r.ArtifactId).Distinct().Count() != envelope.ParentRefs.Count)
                throw Invalid("Duplicate or conflicting parent references");
            foreach (var reference in envelope.ParentRefs)
            {
                if (!accepted.TryGetValue(reference.ArtifactId, out var parent) || parent.ToRef() != reference)
                    throw Invalid($"Missing or stale parent: {reference.ArtifactId}");
                CheckClosure(parent);
            }
        }
        CheckClosure(paper);
        var blueprint = Ref(paper.Payload, "blueprintRef");
        var sectionRefs = Refs(paper.Payload, "sectionRefs");
        var passageRefs = Refs(paper.Payload, "passageRefs");
        var questionRefs = Refs(paper.Payload, "questionRefs");
        if (sectionRefs.Count != 3 || passageRefs.Count != 3 || questionRefs.Count != 40
            || sectionRefs.Any(r => r.ArtifactType != ArtifactType.Section)
            || passageRefs.Any(r => r.ArtifactType != ArtifactType.Passage)
            || questionRefs.Any(r => r.ArtifactType != ArtifactType.Question)
            || blueprint.ArtifactType != ArtifactType.ExamBlueprint)
            throw Invalid("Paper has incomplete or mistyped section/passage/question closure");
        ExactRefs(paper.ParentRefs, new[] { blueprint }.Concat(sectionRefs).Concat(passageRefs).Concat(questionRefs));
        var inlineSections = paper.Payload.GetProperty("sections").EnumerateArray().ToArray();
        var sources = JsonSerializer.Deserialize<List<ReadingSource>>(run.SourceRevisionsJson, ReadingPaperRules.Json) ?? [];
        if (inlineSections.Length != 3 || sources.Count != 3)
            throw Invalid("Final paper must bind three pinned sources and sections");
        var sections = new List<ReadingGeneratedSection>(3);
        var expectedQuestionRefs = new List<ArtifactRef>(40);
        for (var i = 0; i < 3; i++)
        {
            var section = accepted[sectionRefs[i].ArtifactId];
            if (section.Payload.GetProperty("sectionId").GetInt32() != i + 1
                || ArtifactEnvelope.ComputeContentHash(inlineSections[i], section.ParentRefs) != section.ContentHash)
                throw Invalid("Paper section payload differs from its exact authoritative section");
            var passage = Ref(section.Payload, "passageRef");
            var questions = Refs(section.Payload, "questionRefs");
            if (passage != passageRefs[i] || Ref(section.Payload, "blueprintRef") != blueprint
                || questions.Count < 1)
                throw Invalid("Section-local question/passage/blueprint references are inconsistent");
            ExactRefs(section.ParentRefs, new[] { passage, blueprint }.Concat(questions));
            expectedQuestionRefs.AddRange(questions);
            var dto = ReadSection(section.Payload);
            var passagePayload = accepted[passage.ArtifactId].Payload;
            var passageText = String(passagePayload, "text", "passage");
            if (dto.Passage != passageText || dto.Source.Pmcid != sources[i].Pmcid
                || dto.Source.License != sources[i].License || dto.Source.Doi != sources[i].Doi)
                throw Invalid("Section differs from its authoritative passage or pinned source identity");
            var inlineQuestions = dto.Groups.SelectMany(g => g.Questions).ToList();
            for (var q = 0; q < questions.Count; q++)
            {
                var envelope = accepted[questions[q].ArtifactId];
                if (!envelope.ParentRefs.Contains(passage) || !envelope.ParentRefs.Contains(blueprint))
                    throw Invalid("Question does not bind its section's exact passage and blueprint");
                var raw = envelope.Payload;
                if (raw.TryGetProperty("questions", out var items))
                    raw = items.EnumerateArray().Single(item => Number(item) == inlineQuestions[q].Number);
                var question = ReadQuestion(raw, dto.Groups.First(g => g.Questions.Contains(inlineQuestions[q])).Type);
                if (JsonSerializer.Serialize(question, ReadingPaperRules.Json) != JsonSerializer.Serialize(inlineQuestions[q], ReadingPaperRules.Json))
                    throw Invalid("Section question differs from the authoritative question head");
            }
            sections.Add(dto);
        }
        ExactRefs(questionRefs, expectedQuestionRefs);
        var evaluations = finalEvaluations?.ToList() ?? (await db.ReadingPaperEvaluations.AsNoTracking()
            .Where(e => e.RunId == run.RunId && e.TargetArtifactId == paper.ArtifactId && e.TargetVersion == paper.Version)
            .OrderByDescending(e => e.CreatedAt).ToListAsync(ct))
            .Select(e => JsonSerializer.Deserialize<EvaluationResult>(e.PayloadJson, LoopEngineJson.Options)
                ?? throw Invalid("Malformed persisted evaluation")).ToList();
        var cutoff = paper.CreatedAt;
        foreach (var reference in paper.ParentRefs)
            if (heads[reference.ArtifactId].UpdatedAt > cutoff) cutoff = heads[reference.ArtifactId].UpdatedAt;
        var effectiveCutoff = cutoff - EvaluationBackwardJitter;
        foreach (var required in RequiredEvaluators)
        {
            var evaluation = evaluations.FirstOrDefault(e => e.EvaluatorId == required.Key);
            if (evaluation == null || evaluation.EvaluatorVersion != required.Value
                || evaluation.Status != EvaluationStatus.PASS || evaluation.TargetRef != paper.ToRef()
                || evaluation.EvaluatedAt < effectiveCutoff || evaluation.EvaluatedAt > DateTime.UtcNow + EvaluationForwardJitter
                || evaluation.Issues.Any(i => i.Status == IssueStatus.OPEN && (i.Severity is IssueSeverity.CRITICAL or IssueSeverity.MAJOR)))
                throw Invalid($"Required fresh paper evaluation rejected: {required.Key}");
            ExactRefs(evaluation.InputDependencyRefs, paper.ParentRefs);
        }
        ReadingPaperRules.Validate(sections);
        return sections;
    }

    private static ArtifactEnvelope Deserialize(ReadingPaperArtifact artifact) =>
        JsonSerializer.Deserialize<ArtifactEnvelope>(artifact.EnvelopeJson ?? "null", LoopEngineJson.Options)
        ?? throw Invalid("Accepted artifact lacks its canonical envelope");

    public static ArtifactRef Ref(JsonElement element, string name) =>
        JsonSerializer.Deserialize<ArtifactRef>(element.GetProperty(name), LoopEngineJson.Options) ?? throw Invalid("Missing exact reference");
    public static List<ArtifactRef> Refs(JsonElement element, string name) =>
        JsonSerializer.Deserialize<List<ArtifactRef>>(element.GetProperty(name), LoopEngineJson.Options) ?? throw Invalid("Missing exact references");
    private static void ExactRefs(IEnumerable<ArtifactRef> actual, IEnumerable<ArtifactRef> expected)
    {
        var left = actual.ToList();
        var right = expected.ToList();
        if (left.Count != right.Count || left.Distinct().Count() != left.Count || !left.ToHashSet().SetEquals(right))
            throw Invalid("Exact parent/evaluation dependency closure mismatch");
    }

    public static ReadingGeneratedSection ReadSection(JsonElement payload)
    {
        var source = JsonSerializer.Deserialize<ReadingSource>(payload.GetProperty("source"), ReadingPaperRules.Json)
            ?? throw Invalid("Missing section source");
        var groups = payload.GetProperty("groups").EnumerateArray().Select(group =>
        {
            var type = CanonicalType(String(group, "questionType", "type"));
            var questions = group.GetProperty("questions").EnumerateArray().Select(q => ReadQuestion(q, type)).ToList();
            return new ReadingGeneratedGroup(type, String(group, "instructions", "instruction"), questions);
        }).ToList();
        return new ReadingGeneratedSection(String(payload, "title"), String(payload, "passage"), source, groups);
    }

    private static ReadingGeneratedQuestion ReadQuestion(JsonElement payload, string type)
    {
        var number = Number(payload);
        var answer = String(payload, "answer", "correctOption");
        var options = payload.TryGetProperty("options", out var raw) && raw.ValueKind == JsonValueKind.Array
            ? raw.EnumerateArray().Select((o, i) => o.ValueKind == JsonValueKind.String ? o.GetString()!
                : $"{(char)('A' + i)}. {String(o, "text")}").ToList() : [];
        if (type is "TRUE_FALSE_NOT_GIVEN" or "YES_NO_NOT_GIVEN")
        {
            answer = answer.Replace('_', ' ');
            options = type == "TRUE_FALSE_NOT_GIVEN" ? ["TRUE", "FALSE", "NOT GIVEN"] : ["YES", "NO", "NOT GIVEN"];
        }
        else if (type == "MULTIPLE_CHOICE_SINGLE" && answer.Length == 1 && answer[0] is >= 'A' and <= 'D')
            answer = options[answer[0] - 'A'];
        return new ReadingGeneratedQuestion(number, String(payload, "prompt", "statement"), answer,
            options, String(payload, "evidenceQuote"), String(payload, "explanation"));
    }
    private static int Number(JsonElement e) => e.TryGetProperty("questionNumber", out var n) ? n.GetInt32() : e.GetProperty("number").GetInt32();
    private static string String(JsonElement e, params string[] names)
    {
        foreach (var name in names)
            if (e.TryGetProperty(name, out var value) && value.ValueKind == JsonValueKind.String) return value.GetString()!;
        return "";
    }
    private static string CanonicalType(string type) => type.Replace("_", "").Replace("-", "").ToUpperInvariant() switch
    {
        "TRUEFALSENOTGIVEN" => "TRUE_FALSE_NOT_GIVEN",
        "YESNONOTGIVEN" => "YES_NO_NOT_GIVEN",
        "MULTIPLECHOICESINGLE" => "MULTIPLE_CHOICE_SINGLE",
        "MULTIPLECHOICEMULTIPLE" => "MULTIPLE_CHOICE_MULTIPLE",
        "MULTIPLECHOICESINGLEIMAGE" => "MULTIPLE_CHOICE_SINGLE_IMAGE",
        "SENTENCECOMPLETION" => "SENTENCE_COMPLETION",
        "SUMMARYCOMPLETION" => "SUMMARY_COMPLETION",
        "SUMMARYCOMPLETIONBOX" or "SUMMARYBOX" => "SUMMARY_COMPLETION_BOX",
        "SHORTANSWER" => "SHORT_ANSWER",
        "MATCHINGHEADING" or "MATCHINGHEADINGS" => "MATCHING_HEADING",
        "MATCHINGINFORMATION" => "MATCHING_INFORMATION",
        "MATCHINGFEATURES" => "MATCHING_FEATURES",
        "MATCHINGENDINGS" or "MATCHINGSENTENCEENDINGS" => "MATCHING_ENDINGS",
        "TABLECOMPLETION" => "TABLE_COMPLETION",
        "FLOWCHART" or "FLOWCHARTCOMPLETION" => "FLOW_CHART",
        "DIAGRAMLABEL" or "DIAGRAMLABELING" => "DIAGRAM_LABEL",
        "MAPLABEL" => "MAP_LABEL",
        "NOTECOMPLETION" => "NOTE_COMPLETION",
        "FORMCOMPLETION" => "FORM_COMPLETION",
        "CLASSIFICATION" => "CLASSIFICATION",
        "CHOOSINGTITLE" or "CHOOSINGATITLE" => "CHOOSING_TITLE",
        _ => type
    };
    private static CheckpointValidationException Invalid(string message) => new(409, message);
}
