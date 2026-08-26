using System.Text.Json;
using Google.Protobuf;
using Google.Protobuf.WellKnownTypes;
using Shared.Grpc.ExamInternal;

namespace attempt_service.Features.Attempt;

/// <summary>
/// gRPC client wrapper around exam-service's <c>ExamInternal</c> service.
/// Spec §3.4 + §4.7: reads <c>InternalDeliveryQuestionEnvelope</c> (proto field 15)
/// which is the SSOT discriminated-union envelope; legacy flat fields 8-14 are
/// ignored. <c>showAnswers=false</c> arrives as an empty <c>Struct</c> on
/// <c>correct_answer</c>, which this gateway skips.
/// </summary>
public sealed class ExamGateway : IExamGateway
{
    private readonly ExamInternal.ExamInternalClient _grpc;
    private readonly ILogger<ExamGateway> _log;

    private static readonly JsonParser Parser =
        new(JsonParser.Settings.Default.WithIgnoreUnknownFields(true));

    public ExamGateway(ExamInternal.ExamInternalClient grpc, ILogger<ExamGateway> log)
    {
        _grpc = grpc;
        _log = log;
    }

    public async Task<IReadOnlyDictionary<Guid, string>> GetCorrectAnswersAsync(
        Guid examId, bool showAnswers, CancellationToken ct)
    {
        var reply = await _grpc.GetInternalExamAsync(new GetInternalExamRequest
        {
            ExamId = examId.ToString(),
            ShowAnswers = showAnswers,
        }, cancellationToken: ct);

        var dict = new Dictionary<Guid, string>();
        foreach (var section in reply.Sections)
        foreach (var group in section.QuestionGroups)
        foreach (var question in group.Questions)
        {
            // Spec §3.4 + Q3: envelope field 15 is the only populated field.
            var envelope = question.Envelope;
            if (envelope is null) continue;

            var correct = envelope.CorrectAnswer;
            // Empty Struct (showAnswers=false) → skip.
            if (correct is null || correct.Fields.Count == 0) continue;

            var json = JsonFormatter.Default.Format(correct);
            if (Guid.TryParse(question.Id, out var qid))
                dict[qid] = json;
        }
        return dict;
    }

    public async Task<PaperJson> GetPaperJsonAsync(Guid examId, CancellationToken ct)
    {
        var reply = await _grpc.GetInternalExamAsync(new GetInternalExamRequest
        {
            ExamId = examId.ToString(),
            ShowAnswers = false,
        }, cancellationToken: ct);

        // Build PaperJson from envelope.payload; correctAnswer omitted for learner-facing.
        var sections = new List<PaperSection>();
        foreach (var s in reply.Sections)
        {
            var questions = new List<PaperQuestion>();
            foreach (var grp in s.QuestionGroups)
            {
                foreach (var q in grp.Questions)
                {
                    var payloadEl = StructToJsonElement(q.Envelope?.Payload);
                    var correctEl = StructToJsonElement(q.Envelope?.CorrectAnswer);
                    var typeSlug = q.Envelope?.Type ?? q.Type ?? string.Empty;

                    // Skill is denormalized into question.Skill; fall back to payload.skill if flat field absent.
                    string skill = q.Skill;
                    if (string.IsNullOrEmpty(skill)
                        && q.Envelope?.Payload?.Fields.TryGetValue("skill", out var skillVal) == true
                        && skillVal.KindCase == Value.KindOneofCase.StringValue)
                    {
                        skill = skillVal.StringValue;
                    }

                    questions.Add(new PaperQuestion(
                        Id: Guid.Parse(q.Id),
                        Idx: q.Idx,
                        Type: typeSlug,
                        Skill: skill,
                        SectionId: Guid.Parse(s.Id),
                        Payload: payloadEl,
                        CorrectAnswer: correctEl,
                        Rubric: null));
                }
            }
            sections.Add(new PaperSection(
                Id: Guid.Parse(s.Id),
                Idx: s.Idx,
                Title: s.Title,
                Skill: null,
                InstructionsMd: s.InstructionsMd,
                PassageMd: s.PassageMd,
                AudioUrl: s.AudioUrl,
                TranscriptMd: s.TranscriptMd,
                QuestionGroups: Array.Empty<PaperQuestionGroup>(),
                Questions: questions));
        }

        return new PaperJson(
            Id: Guid.Parse(reply.Id),
            Slug: reply.Slug,
            Title: reply.Title,
            DescriptionMd: string.IsNullOrEmpty(reply.DescriptionMd) ? null : reply.DescriptionMd,
            Category: reply.Category,
            Level: reply.Level,
            DurationMin: reply.DurationMin,
            ImageUrl: string.IsNullOrEmpty(reply.ImageUrl) ? null : reply.ImageUrl,
            Skill: null,
            Sections: sections);
    }

    private static JsonElement StructToJsonElement(Struct? s)
    {
        if (s is null || s.Fields.Count == 0)
            return JsonDocument.Parse("null").RootElement.Clone();
        var json = JsonFormatter.Default.Format(s);
        return JsonDocument.Parse(json).RootElement.Clone();
    }
}