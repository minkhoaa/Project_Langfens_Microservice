using System.ComponentModel.DataAnnotations;

namespace exam_service.Domains.Entities;

public sealed class ReadingPaperJob
{
    [Key] public Guid Id { get; set; } = Guid.NewGuid();
    public string Topic { get; set; } = string.Empty;
    public string Status { get; set; } = "Pending";
    public int CompletedSections { get; set; }
    public string SourcesJson { get; set; } = "[]";
    public string SectionsJson { get; set; } = "[]";
    public string Logs { get; set; } = string.Empty;
    public string? Error { get; set; }
    public Guid? ExamId { get; set; }
    public DateTime? LeaseUntil { get; set; }
    public Guid? LeaseOwner { get; set; }
    public int Epoch { get; set; } = 1;
    public int CancelVersion { get; set; } = 0;
    public string EngineVersion { get; set; } = "2.0.0";
    public string SchemaVersion { get; set; } = "2.0.0";
    public string PolicyVersion { get; set; } = "2.0.0";
    public string? ActiveRunId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<ReadingPaperRun> Runs { get; set; } = new List<ReadingPaperRun>();
}
