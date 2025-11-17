using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json.Serialization;
using Shared.ExamDto.Contracts.Exam.Enums;

namespace Shared.ExamDto.Contracts.Exam.InternalExamDto;

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
        [JsonPropertyName("audioUrl")] public string? AudioUrl { get; init; }
        [JsonPropertyName("transcriptMd")] public string? TranscriptMd { get; init; }
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
        [JsonPropertyName("blankAcceptTexts")] public IReadOnlyDictionary<string, string[]?> BlankAcceptTexts { get; init; } = new Dictionary<string, string[]?>();
        [JsonPropertyName("blankAcceptRegex")] public IReadOnlyDictionary<string, string[]?> BlankAcceptRegex { get; init; } = new Dictionary<string, string[]?>();
        [JsonPropertyName("matchPairs")] public IReadOnlyDictionary<string, string[]?> MatchPairs { get; init; } = new Dictionary<string, string[]?>();
        [JsonPropertyName("orderCorrects")] public IReadOnlyList<string> OrderCorrects { get; init; } = Array.Empty<string>();
        [JsonPropertyName("shortAnswerAcceptTexts")] public IReadOnlyList<string> ShortAnswerAcceptTexts { get; init; } = Array.Empty<string>();
        [JsonPropertyName("shortAnswerAcceptRegex")] public IReadOnlyList<string> ShortAnswerAcceptRegex { get; init; } = Array.Empty<string>();
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
                Questions = sec.Questions.Select(q => q with
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
        };
    }
}
