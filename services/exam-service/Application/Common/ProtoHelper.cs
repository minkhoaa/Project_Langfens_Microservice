using System;
using System.Collections.Generic;
using System.Linq;
using Shared.Grpc.ExamInternal;

namespace exam_service.Application.Common;

public static class ProtoHelper
{
    public static InternalDeliveryExam MapToProto(Domains.Entities.Exam exam, bool showAnswers)
    {
        var proto = new InternalDeliveryExam
        {
            Id = exam.Id.ToString(),
            Category = exam.Category,
            DescriptionMd = exam.DescriptionMd ?? string.Empty,
            Level = exam.Level,
            Slug = exam.Slug,
            Title = exam.Title,
            // Nếu proto có DurationMin/DurationSec, nhớ map luôn:
            DurationMin = exam.DurationMin, // ví dụ, tùy schema của bạn
            ImageUrl = exam.ImageUrl ?? string.Empty  // Thumbnail/cover image
        };

        // Duyệt TỪ domain -> TỚI proto
        foreach (var sec in exam.Sections.OrderBy(s => s.Idx))
        {
            var pSec = new InternalDeliverySection
            {
                Id = sec.Id.ToString(),
                InstructionsMd = sec.InstructionsMd ?? string.Empty,
                PassageMd = sec.PassageMd ?? string.Empty,
                AudioUrl = sec.AudioUrl ?? string.Empty,
                TranscriptMd = sec.TranscriptMd ?? string.Empty,
                Idx = sec.Idx,
                Title = sec.Title ?? string.Empty
            };

            // Map QuestionGroups (questions are only inside groups now)
            if (sec.QuestionGroups != null && sec.QuestionGroups.Any())
            {
                foreach (var grp in sec.QuestionGroups.OrderBy(g => g.Idx))
                {
                    var pGrp = new InternalDeliveryQuestionGroup
                    {
                        Id = grp.Id.ToString(),
                        Idx = grp.Idx,
                        StartIdx = grp.StartIdx,
                        EndIdx = grp.EndIdx,
                        InstructionMd = grp.InstructionMd ?? string.Empty
                    };
                    
                    // Get questions for this group from section.Questions by Idx range
                    var groupQuestions = sec.Questions
                        .Where(q => q.Idx >= grp.StartIdx && q.Idx <= grp.EndIdx)
                        .OrderBy(q => q.Idx);
                    
                    foreach (var q in groupQuestions)
                    {
                        var pQ = MapQuestionToProto(q, showAnswers);
                        pGrp.Questions.Add(pQ);
                    }
                    
                    pSec.QuestionGroups.Add(pGrp);
                }
            }
            else
            {
                // Fallback: If no QuestionGroups, create one default group with all questions
                var defaultGrp = new InternalDeliveryQuestionGroup
                {
                    Id = Guid.NewGuid().ToString(),
                    Idx = 1,
                    StartIdx = 1,
                    EndIdx = sec.Questions.Any() ? sec.Questions.Max(q => q.Idx) : 0,
                    InstructionMd = sec.InstructionsMd ?? string.Empty
                };
                
                foreach (var q in sec.Questions.OrderBy(q => q.Idx))
                {
                    var pQ = MapQuestionToProto(q, showAnswers);
                    defaultGrp.Questions.Add(pQ);
                }
                
                if (defaultGrp.Questions.Count > 0)
                {
                    pSec.QuestionGroups.Add(defaultGrp);
                }
            }

            proto.Sections.Add(pSec); // ✅ add vào proto-exam
        }

        return proto;
    }

    private static InternalDeliveryQuestion MapQuestionToProto(Domains.Entities.ExamQuestion q, bool showAnswers)
    {
        var pQ = new InternalDeliveryQuestion
        {
            Id = q.Id.ToString(),
            Idx = q.Idx,
            ExplanationMd = showAnswers ? q.ExplanationMd ?? string.Empty : string.Empty,
            Difficulty = q.Difficulty,
            PromptMd = q.PromptMd ?? string.Empty,
            Skill = q.Skill ?? string.Empty,
            Type = q.Type ?? string.Empty
        };

        var flowChartNodes = BuildFlowChartNodes(q.OrderCorrects);
        if (flowChartNodes.Count > 0)
            pQ.FlowChartNodes.AddRange(flowChartNodes);

        foreach (var opt in q.Options.OrderBy(o => o.Idx))
        {
            var pOpt = new InternalDeliveryOption
            {
                Id = opt.Id.ToString(),
                Idx = opt.Idx,
                ContentMd = opt.ContentMd ?? string.Empty
            };
            if (showAnswers) pOpt.IsCorrect = opt.IsCorrect;
            pQ.Options.Add(pOpt);
        }
        
        if (showAnswers)
        {
            var textMap = q.BlankAcceptTexts ?? new Dictionary<string, string[]?>();
            var regexMap = q.BlankAcceptRegex ?? new Dictionary<string, string[]?>();
            foreach (var blank in textMap.Keys.Union(regexMap.Keys, StringComparer.OrdinalIgnoreCase))
            {
                var accept = new InternalCompletionAccept { BlankId = blank };
                if (textMap.TryGetValue(blank, out var texts) && texts is { Length: > 0 })
                    accept.AcceptedTexts.AddRange(texts);
                if (regexMap.TryGetValue(blank, out var regs) && regs is { Length: > 0 })
                    accept.AcceptedRegex.AddRange(regs);
                if (accept.AcceptedTexts.Count > 0 || accept.AcceptedRegex.Count > 0)
                    pQ.CompletionAccepts.Add(accept);
            }

            foreach (var pair in q.MatchPairs ?? new Dictionary<string, string[]?>())
            {
                if (string.IsNullOrWhiteSpace(pair.Key) || pair.Value is not { Length: > 0 }) continue;
                var mp = new InternalMatchPair { PromptKey = pair.Key };
                mp.AcceptedValues.AddRange(pair.Value);
                pQ.MatchPairs.Add(mp);
            }

            if (q.OrderCorrects is { Count: > 0 })
                pQ.OrderCorrects.AddRange(q.OrderCorrects.Where(x => !string.IsNullOrWhiteSpace(x)));
            if (q.ShortAnswerAcceptTexts is { Count: > 0 })
                pQ.ShortAnswerAcceptTexts.AddRange(q.ShortAnswerAcceptTexts.Where(x => !string.IsNullOrWhiteSpace(x)));
            if (q.ShortAnswerAcceptRegex is { Count: > 0 })
                pQ.ShortAnswerAcceptRegex.AddRange(q.ShortAnswerAcceptRegex.Where(x => !string.IsNullOrWhiteSpace(x)));
        }

        return pQ;
    }

    private static List<FlowChartNode> BuildFlowChartNodes(IReadOnlyCollection<string>? orderCorrects)
    {
        if (orderCorrects is not { Count: > 0 }) return new List<FlowChartNode>();

        var nodes = orderCorrects
            .Where(x => !string.IsNullOrWhiteSpace(x))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .Select(key => new FlowChartNode
            {
                Key = key,
                Label = key.Replace("-", " ").Trim()
            })
            .ToList();

        return nodes.OrderBy(_ => Guid.NewGuid()).ToList();
    }
}
