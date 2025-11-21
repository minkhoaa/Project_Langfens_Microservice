using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace speaking_service.Domains.Entities;

public class SpeakingEvaluation
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public Guid Id { get; set; }

    public Guid SubmissionId { get; set; }

    public double OverallBand { get; set; }

    public double FluencyAndCoherenceBand { get; set; }
    public string FluencyAndCoherenceComment { get; set; } = string.Empty;

    public double LexicalResourceBand { get; set; }
    public string LexicalResourceComment { get; set; } = string.Empty;

    public double GrammaticalRangeAndAccuracyBand { get; set; }
    public string GrammaticalRangeAndAccuracyComment { get; set; } = string.Empty;

    public double PronunciationBand { get; set; }
    public string PronunciationComment { get; set; } = string.Empty;

    public string SuggestionsJson { get; set; } = "[]";
    public string ImprovedAnswer { get; set; } = string.Empty;

    public string Model { get; set; } = string.Empty;
    public string Provider { get; set; } = "openrouter";
    public string PromptSchemaVersion { get; set; } = "v1";

    public string RawLlmJson { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [JsonIgnore]
    public SpeakingSubmission SpeakingSubmission { get; set; } = null!;
}
