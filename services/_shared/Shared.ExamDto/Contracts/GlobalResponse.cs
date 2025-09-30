namespace Shared.ExamDto.Contracts;

public sealed record ApiResultDto(bool isSuccess, string message, object data);