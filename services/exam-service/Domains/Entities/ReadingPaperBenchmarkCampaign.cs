using System.ComponentModel.DataAnnotations;

namespace exam_service.Domains.Entities;

public sealed class ReadingPaperBenchmarkCampaign
{
    [Key, MaxLength(128)] public string CampaignId { get; set; } = string.Empty;
    [MaxLength(128)] public string AuthorizationId { get; set; } = string.Empty;
    [MaxLength(200)] public string AuthorizedBy { get; set; } = string.Empty;
    [MaxLength(64)] public string CorpusSha256 { get; set; } = string.Empty;
    [MaxLength(64)] public string ConfigSha256 { get; set; } = string.Empty;
    public int BudgetCapCalls { get; set; }
    public int BudgetUsedCalls { get; set; }
    public int BudgetCapTokens { get; set; }
    public int BudgetUsedTokens { get; set; }
    public double BudgetCapWallTimeSeconds { get; set; }
    public double BudgetUsedWallTimeSeconds { get; set; }
    public bool BudgetBreachDetected { get; set; }
    public string? BudgetBreachReason { get; set; }
    [MaxLength(24)] public string Status { get; set; } = "AUTHORIZED";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
