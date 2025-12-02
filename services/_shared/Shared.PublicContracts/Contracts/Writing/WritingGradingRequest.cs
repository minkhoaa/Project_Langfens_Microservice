namespace Shared.ExamDto.Contracts.Writing
{
    public record WritingGradeRequestMessage(
        string AttemptId,
        string UserId,
        string TaskText,
        string AnswerText
    );

}