using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json.Serialization;
using Shared.ExamDto.Contracts.Exam.Enums;

namespace Shared.ExamDto.Contracts.Exam.InternalExamDto;

// Phase 2 note: the records in this class are the legacy "flat" wire shape
// used between attempt-service and exam-service via JSON and gRPC. Phase 2
// added polymorphic SSOT-derived types under
// `Shared.PublicContracts.Generated.QuestionSchema` (see
// `Generated/QuestionSchema.cs`, produced by `nswag.json` from
// `schemas/question-schema/dist/openapi/question-schema.openapi.json`).
// Each per-type `*Payload` / `*Answer` record is the new source of truth for
// the question-level wire contract; the legacy records below are retained
// until attempt-service migrates off the flat shape — see
// `services/attempt-service/Features/Helpers/BuildQuestionIdSet.cs`.
public class InternalExamDto
{
    public record InternalDeliveryExam
    {
        [JsonPropertyName("id")] public Guid Id { get; init; }
        [JsonPropertyName("slug")] public string Slug { get; init; } = string.Empty;
        [JsonPropertyName("title")] public string Title { get; init; } = string.Empty;
        [JsonPropertyName("descriptionMd")] public string? DescriptionMd { get; init; }
        [JsonPropertyName("category")] public string Category { get; init; } = string.Empty;
        [JsonPropertyName("level")] public string Level { get; init; } = string.Empty;
        [JsonPropertyName("durationMin")] public int DurationMin { get; init; }
        [JsonPropertyName("sections")] public IReadOnlyList<InternalDeliverySection> Sections { get; init; } = [];
    }

    public record InternalDeliverySection
    {
        [JsonPropertyName("id")] public Guid Id { get; init; }
        [JsonPropertyName("idx")] public int Idx { get; init; }
        [JsonPropertyName("title")] public string Title { get; init; } = string.Empty;
        [JsonPropertyName("instructionsMd")] public string? InstructionsMd { get; init; }
        [JsonPropertyName("passageMd")] public string? PassageMd { get; init; }
        [JsonPropertyName("audioUrl")] public string? AudioUrl { get; init; }
        [JsonPropertyName("transcriptMd")] public string? TranscriptMd { get; init; }
        [JsonPropertyName("questionGroups")] public IReadOnlyList<InternalDeliveryQuestionGroup> QuestionGroups { get; init; } = [];
    }

    public record InternalDeliveryQuestionGroup
    {
        [JsonPropertyName("id")] public Guid Id { get; init; }
        [JsonPropertyName("idx")] public int Idx { get; init; }
        [JsonPropertyName("startIdx")] public int StartIdx { get; init; }
        [JsonPropertyName("endIdx")] public int EndIdx { get; init; }
        [JsonPropertyName("instructionMd")] public string InstructionMd { get; init; } = string.Empty;
        [JsonPropertyName("questions")] public IReadOnlyList<InternalDeliveryQuestion> Questions { get; init; } = [];
    }

    public record InternalDeliveryQuestion
    {
        [JsonPropertyName("id")] public Guid Id { get; init; }
        [JsonPropertyName("idx")] public int Idx { get; init; }
        [JsonPropertyName("type")] public string Type { get; init; } = string.Empty;
        [JsonPropertyName("skill")] public string Skill { get; init; } = QuestionSkill.Listening;
        [JsonPropertyName("difficulty")] public int Difficulty { get; init; }
        [JsonPropertyName("promptMd")] public string? PromptMd { get; init; }
        [JsonPropertyName("explanationMd")] public string? ExplanationMd { get; init; }
        [JsonPropertyName("options")] public IReadOnlyList<InternalDeliveryOption> Options { get; init; } = [];
        [JsonPropertyName("flowChartNodes")] public IReadOnlyList<InternalFlowChartNode>? FlowChartNodes { get; init; }
            = null;
        [JsonPropertyName("blankAcceptTexts")] public IReadOnlyDictionary<string, string[]?> BlankAcceptTexts { get; init; } = new Dictionary<string, string[]?>();
        [JsonPropertyName("blankAcceptRegex")] public IReadOnlyDictionary<string, string[]?> BlankAcceptRegex { get; init; } = new Dictionary<string, string[]?>();
        // Canonical shape: { "<promptKey>": ["<gradingKey>", "<displayText>"] }
        // — used by MATCHING_HEADING and other matching question types. Index
        // 0 is the value compared against the user's answer; index 1 is the
        // human-readable label shown in the result review.
        [JsonPropertyName("matchPairs")] public IReadOnlyDictionary<string, string[]?> MatchPairs { get; init; } = new Dictionary<string, string[]?>();
        [JsonPropertyName("orderCorrects")] public IReadOnlyList<string> OrderCorrects { get; init; } = Array.Empty<string>();
        [JsonPropertyName("shortAnswerAcceptTexts")] public IReadOnlyList<string> ShortAnswerAcceptTexts { get; init; } = Array.Empty<string>();
        [JsonPropertyName("shortAnswerAcceptRegex")] public IReadOnlyList<string> ShortAnswerAcceptRegex { get; init; } = Array.Empty<string>();
    }

    public record InternalFlowChartNode
    {
        [JsonPropertyName("key")] public string Key { get; init; } = string.Empty;
        [JsonPropertyName("label")] public string Label { get; init; } = string.Empty;
    }

    public record InternalDeliveryOption
    {
        [JsonPropertyName("id")] public Guid Id { get; init; }
        [JsonPropertyName("idx")] public int Idx { get; init; }
        [JsonPropertyName("contentMd")] public string ContentMd { get; init; } = "";
        [JsonPropertyName("isCorrect")] public bool? IsCorrect { get; init; }
    }

    public static class SnapshotSanitizer
    {
        public static InternalDeliveryExam Sanitize(InternalDeliveryExam exam) => exam with
        {
            Sections = exam.Sections.Select(sec => sec with
            {
                QuestionGroups = sec.QuestionGroups.Select(grp => grp with
                {
                    Questions = grp.Questions.Select(q => q with
                    {
                        Options = q.Options.Select(o => o with { IsCorrect = null }).ToList(),
                        BlankAcceptTexts = new Dictionary<string, string[]?>(),
                        BlankAcceptRegex = new Dictionary<string, string[]?>(),
                        MatchPairs = new Dictionary<string, string[]?>(),
                        OrderCorrects = Array.Empty<string>(),
                        ShortAnswerAcceptTexts = Array.Empty<string>(),
                        ShortAnswerAcceptRegex = Array.Empty<string>()
                    }).ToList()
                }).ToList()
            }).ToList()
        };
    }
}
