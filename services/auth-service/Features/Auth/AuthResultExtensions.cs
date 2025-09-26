using auth_service.Application.Auth;

namespace auth_service.Features.Auth;

public static class AuthResultExtensions
{
    public static IResult ToHttpResult(this AuthOperationResult operation)
    {
        return operation.StatusCode switch
        {
            StatusCodes.Status200OK => Results.Ok(operation.Response),
            StatusCodes.Status201Created => Results.Json(operation.Response, statusCode: StatusCodes.Status201Created),
            StatusCodes.Status400BadRequest => Results.BadRequest(operation.Response),
            StatusCodes.Status404NotFound => Results.NotFound(operation.Response),
            StatusCodes.Status401Unauthorized => Results.Unauthorized(),
            _ => Results.Json(operation.Response, statusCode: operation.StatusCode)
        };
    }
}