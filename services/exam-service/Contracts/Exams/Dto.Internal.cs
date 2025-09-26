namespace exam_service.Contracts.Exams;

public class DtoInternal
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

    public record InternalDeliveryOption(int Idx, string ContentMd, bool? IsCorrect);
}
