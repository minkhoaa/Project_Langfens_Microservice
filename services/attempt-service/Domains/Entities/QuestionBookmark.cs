namespace attempt_service.Domains.Entities;

public class QuestionBookmark
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid QuestionId { get; set; }
    public Guid? AttemptId { get; set; }
    public string? QuestionContent { get; set; }
    public string? Skill { get; set; }
    public string? QuestionType { get; set; }
    public string? Note { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
