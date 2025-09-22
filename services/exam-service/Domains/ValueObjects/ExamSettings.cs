namespace exam_service.Data.ValueObjects;

public sealed class ExamSettings
{
    public bool ShuffleQuestions { get; set; } = false;
    public bool ShuffleOptions { get; set; } = false;
}