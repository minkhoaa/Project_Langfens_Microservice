namespace exam_service.Contracts.Exams;

public class DtoInternal
{
    public record DeliveryExam(
        Guid Id,
        string Slug,
        string Title,
        string? DescriptionMd,
        string Category,
        string Level,
        int DurationMin,
        IReadOnlyList<DeliverySection> Sections);

    public record DeliverySection(
        int Idx,
        string Title,
        string? InstructionsMd,
        IReadOnlyList<DeliveryQuestion> Questions);

    public record DeliveryQuestion(
        int Idx,
        string Type,
        string Skill,
        int Difficulty,
        string? PromptMd,
        string? ExplanationMd,
        IReadOnlyList<DeliveryOption> Options);

    public record DeliveryOption(int Idx, string ContentMd, bool? IsCorrect);
}