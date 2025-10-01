using System.Text.Json.Serialization;
using exam_service.Domains.Enums;

namespace Shared.ExamDto.Contracts.Exam.InternalExamDto;

public class InternalExamDto
{
    public record InternalDeliveryExam
    {
        [JsonPropertyName("id")]           public int Id { get; init; }
        [JsonPropertyName("slug")]         public string Slug { get; init; } = string.Empty;
        [JsonPropertyName("title")]        public string Title { get; init; } = string.Empty;
        [JsonPropertyName("descriptionMd")]public string? DescriptionMd { get; init; }
        [JsonPropertyName("category")]     public string Category { get; init; } = string.Empty;
        [JsonPropertyName("level")]        public string Level { get; init; } = string.Empty;
        [JsonPropertyName("durationMin")]  public int DurationMin { get; init; }
        [JsonPropertyName("sections")]     public IReadOnlyList<InternalDeliverySection> Sections { get; init; } = [];
    }

    public record InternalDeliverySection
    {
        [JsonPropertyName("idx")]           public int Idx { get; init; }
        [JsonPropertyName("title")]         public string Title { get; init; } = string.Empty;
        [JsonPropertyName("instructionsMd")]public string? InstructionsMd { get; init; }
        [JsonPropertyName("questions")]     public IReadOnlyList<InternalDeliveryQuestion> Questions { get; init; } = [];
    }

    public record InternalDeliveryQuestion
    {
        [JsonPropertyName("idx")]           public int Idx { get; init; }
        [JsonPropertyName("type")]          public string Type { get; init; } = string.Empty;
        [JsonPropertyName("skill")]         public string Skill { get; init; } = QuestionSkill.Listening;
        [JsonPropertyName("difficulty")]    public int Difficulty { get; init; }
        [JsonPropertyName("promptMd")]      public string? PromptMd { get; init; }
        [JsonPropertyName("explanationMd")] public string? ExplanationMd { get; init; }
        [JsonPropertyName("options")]       public IReadOnlyList<InternalDeliveryOption> Options { get; init; } = [];
    }

    public record InternalDeliveryOption
    {
        [JsonPropertyName("idx")]        public int Idx { get; init; }
        [JsonPropertyName("contentMd")]  public string ContentMd { get; init; } = "";
        [JsonPropertyName("isCorrect")]  public bool? IsCorrect { get; init; }
    }

    public static class SnapshotSanitizer
    {
        public static InternalDeliveryExam Sanitize(InternalDeliveryExam exam) => exam with
        {
            Sections = exam.Sections.Select(sec => sec with
            {
                Questions = sec.Questions.Select(q => q with
                {
                    Options = q.Options.Select(o => o with { IsCorrect = null }).ToList()
                }).ToList()
            }).ToList()
        };
    }

}
