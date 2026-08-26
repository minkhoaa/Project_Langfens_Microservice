namespace ExamService.Domains.Entities;

public sealed class Exam
{
    public Guid Id { get; set; }

    public string Slug { get; set; } = "";

    public string Title { get; set; } = "";

    public string? DescriptionMd { get; set; }

    public string Category { get; set; } = "";

    public string Level { get; set; } = "";

    public string Status { get; set; } = "draft";

    public int DurationMin { get; set; }

    public string? ImageUrl { get; set; }

    public DateTimeOffset CreatedAt { get; set; }

    public DateTimeOffset UpdatedAt { get; set; }

    public List<ExamSection> Sections { get; set; } = new();
}