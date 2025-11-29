namespace exam_service.Domains.ValueObjects;

public sealed class ExamSettings
{
    public bool ShuffleQuestions { get; set; } = false;
    public bool ShuffleOptions { get; set; } = false;
}