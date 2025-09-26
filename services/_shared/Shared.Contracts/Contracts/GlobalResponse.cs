namespace Shared.Contracts.Contracts;

public sealed record ApiResultDto(bool isSuccess, string message, object data);