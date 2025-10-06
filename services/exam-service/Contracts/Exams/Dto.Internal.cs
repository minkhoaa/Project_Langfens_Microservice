namespace exam_service.Contracts.Exams;

public class InternalExamDto
{
    public record InternalDeliveryExam(
        int Id,
        string Slug,
        string Title,
        string? DescriptionMd,
        string Category,
        string Level,
        int DurationMin,
        IReadOnlyList<InternalDeliverySection> Sections);

    public record InternalDeliverySection(
        int Idx,
        string Title,
        string? InstructionsMd,
        IReadOnlyList<InternalDeliveryQuestion> Questions);

    public record InternalDeliveryQuestion(
        int Idx,
        string Type,
        string Skill,
        int Difficulty,
        string? PromptMd,
        string? ExplanationMd,
        IReadOnlyList<InternalDeliveryOption> Options);

    public record InternalDeliveryOption(int Id, int Idx, string ContentMd, bool? IsCorrect);

    public static class SnapshotSanitizer
    {
        public static InternalDeliveryExam Sanitize(InternalDeliveryExam exam) => exam with
        {
            Sections = exam.Sections.Select(x => x with
            {
                Questions = x.Questions.Select(a => a with
                {
                    Options = a.Options.Select(q => q with { IsCorrect = false }).ToList()
                }).ToList()
            }).ToList()
        };
    }
}