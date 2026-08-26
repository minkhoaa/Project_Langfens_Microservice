using ExamService.Application.Common;
using ExamService.Domains.Entities;
using ExamService.Infrastructure.Persistence;
using Google.Protobuf.WellKnownTypes;
using Grpc.Core;
using Microsoft.EntityFrameworkCore;
using Shared.Grpc.ExamInternal;

namespace ExamService.Features.Exams.InternalEndpoint;

/// <summary>
/// gRPC service backing the cross-service contract defined in
/// <c>services/_shared/Shared.Grpc/Contracts/exam_internal.proto</c>.
///
/// Per spec §3.4 (Internal gRPC) + §8 Q3 (proto legacy fields) + §8 Q5 (provenance scrub):
///   • Each question is emitted via the discriminated-union
///     <see cref="InternalDeliveryQuestionEnvelope"/> (proto field 15) carrying
///     <c>{ type, payload: Struct, correct_answer: Struct, rubric: Struct }</c>.
///   • Legacy flat fields (proto fields 8-14: <c>options</c>, <c>completion_accepts</c>,
///     <c>match_pairs</c>, <c>order_corrects</c>, <c>short_answer_accept_texts</c>,
///     <c>short_answer_accept_regex</c>, <c>flow_chart_nodes</c>) are intentionally
///     left empty so the wire format stays byte-compatible with older consumers
///     while <c>attempt-service</c>'s rebuild migrates to the envelope path.
///   • When <c>showAnswers=false</c> (learner), the payload <see cref="Struct"/>
///     omits the <c>provenance</c> key — the SSOT writeOnly field never leaks.
///     <c>correct_answer</c> is set to an empty <see cref="Struct"/> (not null)
///     so proto wire-compat holds.
/// </summary>
public sealed class InternalExamGrpcService(
    ExamDbContext db,
    ILogger<InternalExamGrpcService> logger)
    : ExamInternal.ExamInternalBase
{
    public override async Task<InternalDeliveryExam> GetInternalExam(
        GetInternalExamRequest request,
        ServerCallContext context)
    {
        if (!request.HasExamId || !Guid.TryParse(request.ExamId, out var examId))
        {
            throw new RpcException(new Status(StatusCode.InvalidArgument, "examId must be a uuid"));
        }

        logger.LogDebug("GetInternalExam examId={ExamId} showAnswers={ShowAnswers}", examId, request.ShowAnswers);

        var exam = await db.Exams.AsNoTracking()
            .Where(e => e.Id == examId)
            .Select(e => new
            {
                e.Id,
                e.Slug,
                e.Title,
                e.DescriptionMd,
                e.Category,
                e.Level,
                e.DurationMin,
                e.ImageUrl,
            })
            .FirstOrDefaultAsync(context.CancellationToken);

        if (exam is null)
        {
            throw new RpcException(new Status(StatusCode.NotFound, "exam not found"));
        }

        var sections = await db.Sections.AsNoTracking()
            .Where(s => s.ExamId == examId)
            .OrderBy(s => s.Idx)
            .ToListAsync(context.CancellationToken);

        var sectionIds = sections.Select(s => s.Id).ToList();

        // Pull all question groups + questions for this exam in two bulk queries
        // (no per-section round trips) — sections/groups/questions is small enough
        // for a single exam to live in memory.
        var questionGroups = await db.QuestionGroups.AsNoTracking()
            .Where(g => sectionIds.Contains(g.SectionId))
            .OrderBy(g => g.SectionId)
            .ThenBy(g => g.Idx)
            .ToListAsync(context.CancellationToken);

        var questions = await db.Questions.AsNoTracking()
            .Where(q => sectionIds.Contains(q.SectionId))
            .OrderBy(q => q.SectionId)
            .ThenBy(q => q.Idx)
            .ToListAsync(context.CancellationToken);

        var proto = new InternalDeliveryExam
        {
            Id = exam.Id.ToString(),
            Slug = exam.Slug,
            Title = exam.Title,
            DescriptionMd = exam.DescriptionMd ?? "",
            Category = exam.Category,
            Level = exam.Level,
            DurationMin = exam.DurationMin,
            ImageUrl = exam.ImageUrl ?? "",
        };

        foreach (var section in sections)
        {
            var protoSection = new InternalDeliverySection
            {
                Id = section.Id.ToString(),
                Idx = section.Idx,
                Title = section.Title,
                InstructionsMd = section.InstructionsMd ?? "",
                PassageMd = section.PassageMd ?? "",
                AudioUrl = section.AudioUrl ?? "",
                TranscriptMd = section.TranscriptMd ?? "",
            };

            var sectionGroups = questionGroups
                .Where(g => g.SectionId == section.Id)
                .ToList();

            var ungroupedQuestions = questions
                .Where(q => q.SectionId == section.Id && q.GroupId == null)
                .OrderBy(q => q.Idx)
                .ToList();

            foreach (var group in sectionGroups)
            {
                var protoGroup = new InternalDeliveryQuestionGroup
                {
                    Id = group.Id.ToString(),
                    Idx = group.Idx,
                    StartIdx = group.StartIdx,
                    EndIdx = group.EndIdx,
                    InstructionMd = group.InstructionMd,
                };

                var groupQuestions = questions
                    .Where(q => q.GroupId == group.Id)
                    .OrderBy(q => q.Idx);

                foreach (var q in groupQuestions)
                {
                    protoGroup.Questions.Add(BuildProtoQuestion(q, request.ShowAnswers));
                }

                protoSection.QuestionGroups.Add(protoGroup);
            }
            // Ungrouped questions still belong to the section but live outside any
            // question group. Wrap each in its own synthetic single-question group
            // with an empty `Id` so the proto wire shape stays one-level (questions
            // are always inside a group) while consumers can detect "ungrouped" by
            // the empty GroupId.
            foreach (var q in ungroupedQuestions)
            {
                var protoLooseGroup = new InternalDeliveryQuestionGroup
                {
                    Id = "",
                    Idx = 0,
                    StartIdx = q.Idx,
                    EndIdx = q.Idx,
                    InstructionMd = "",
                };
                protoLooseGroup.Questions.Add(BuildProtoQuestion(q, request.ShowAnswers));
                protoSection.QuestionGroups.Add(protoLooseGroup);
            }

            proto.Sections.Add(protoSection);
        }

        return proto;
    }

    public override async Task<GetExamListResponse> GetExamList(
        GetExamListRequest request,
        ServerCallContext context)
    {
        // Two queries: pull exam metadata, then a single GROUP BY to count
        // questions per exam (avoids N+1 over the exam list).
        var exams = await db.Exams.AsNoTracking()
            .OrderByDescending(e => e.CreatedAt)
            .Take(50)
            .Select(e => new { e.Id, e.Title, e.Category, e.DurationMin })
            .ToListAsync(context.CancellationToken);

        var counts = await db.Sections.AsNoTracking()
            .Where(s => exams.Select(x => x.Id).Contains(s.ExamId))
            .Select(s => new { s.ExamId, QuestionCount = s.Questions.Count })
            .ToListAsync(context.CancellationToken);

        var countByExam = counts
            .GroupBy(c => c.ExamId)
            .ToDictionary(g => g.Key, g => g.Sum(x => x.QuestionCount));

        var response = new GetExamListResponse();
        foreach (var e in exams)
        {
            response.Exams.Add(new ExamListItem
            {
                Id = e.Id.ToString(),
                Title = e.Title,
                Category = e.Category,
                QuestionCount = countByExam.GetValueOrDefault(e.Id),
                DurationMin = e.DurationMin,
            });
        }
        return response;
    }

    /// <summary>
    /// Build a single <see cref="InternalDeliveryQuestion"/> from the persisted
    /// <c>exam_questions</c> row. Only the envelope path is populated; legacy flat
    /// fields stay at proto3 defaults (empty repeated).
    /// </summary>
    private static InternalDeliveryQuestion BuildProtoQuestion(ExamQuestion q, bool showAnswers)
    {
        var payloadType = q.Payload?.RootElement.TryGetProperty("type", out var typeEl) == true
            ? typeEl.GetString() ?? ""
            : "";

        var promptMd = q.Payload?.RootElement.TryGetProperty("promptMd", out var promptEl) == true
            ? promptEl.GetString() ?? ""
            : "";

        var explanationMd = q.Payload?.RootElement.TryGetProperty("explanationMd", out var expEl) == true
            ? expEl.GetString() ?? ""
            : "";

        var difficulty = q.Payload?.RootElement.TryGetProperty("difficulty", out var diffEl) == true
            && diffEl.TryGetInt32(out var diff)
                ? diff
                : 1;

        var protoQuestion = new InternalDeliveryQuestion
        {
            Id = q.Id.ToString(),
            Idx = q.Idx,
            Type = payloadType,
            Skill = q.Skill,
            Difficulty = difficulty,
            PromptMd = promptMd,
            ExplanationMd = explanationMd,
        };

        // Envelope (proto field 15): type, payload Struct, correct_answer Struct, rubric Struct.
        var envelope = new InternalDeliveryQuestionEnvelope
        {
            Type = payloadType,
        };

        // Payload Struct — admin gets the full jsonb verbatim; learner gets it with
        // the writeOnly `provenance` key removed (spec §8 Q5).
        envelope.Payload = q.Payload is null
            ? new Struct()
            : showAnswers
                ? ProtoHelper.JsonToStruct(q.Payload.RootElement.GetRawText())
                : ProtoHelper.JsonToStruct(ProtoHelper.ScrubProvenance(q.Payload.RootElement).GetRawText());

        // CorrectAnswer Struct — admin gets full; learner gets empty Struct (not null)
        // per spec §3.4.
        envelope.CorrectAnswer = (q.CorrectAnswer is null || !showAnswers)
            ? new Struct()
            : ProtoHelper.JsonToStruct(q.CorrectAnswer.RootElement.GetRawText());

        // Rubric — not persisted as a column in the current schema (only Payload +
        // CorrectAnswer jsonb). Always emit empty Struct for now; future task may add
        // a `rubric jsonb` column for writing/speaking items per spec §2.1.
        envelope.Rubric = new Struct();

        protoQuestion.Envelope = envelope;

        // Legacy flat proto fields (8-14) intentionally left empty — see §8 Q3.
        return protoQuestion;
    }
}
