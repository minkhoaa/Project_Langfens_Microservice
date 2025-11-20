using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace writing_service.Domains.Entities;

public class WritingEvaluation
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public Guid Id { get; set; } 

    public Guid SubmissionId { get; set; }

    public double OverallBand { get; set; }

    public double TaskResponseBand { get; set; }
    public string TaskResponseComment { get; set; } = string.Empty;

    public double CoherenceAndCohesionBand { get; set; }
    public string CoherenceAndCohesionComment { get; set; } = string.Empty;

    public double LexicalResourceBand { get; set; }
    public string LexicalResourceComment { get; set; } = string.Empty;

    public double GrammaticalRangeAndAccuracyBand { get; set; }
    public string GrammaticalRangeAndAccuracyComment { get; set; } = string.Empty;

    public string SuggestionsJson { get; set; } = "[]"; // List<string>
    public string ImprovedParagraph { get; set; } = string.Empty;

    // Info model
    public string Model { get; set; } = string.Empty;       // "deepseek/deepseek-chat-v3-0324:free"
    public string Provider { get; set; } = "openrouter";    // hoặc "ollama", "local"
    public string PromptSchemaVersion { get; set; } = "v1"; // phòng sau này đổi schema

    public string RawLlmJson { get; set; } = string.Empty;  // dump nguyên JSON từ model

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public WritingSubmission WritingSubmission { get; set; }
}