namespace Shared.Contracts.Contracts;

public record ApiResultDto(bool isSuccess, string message, object data);
