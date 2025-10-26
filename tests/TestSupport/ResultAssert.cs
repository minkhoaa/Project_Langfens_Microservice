using Microsoft.AspNetCore.Http;
using Shared.ExamDto.Contracts;

namespace TestSupport;

public static class ResultAssert
{
    public static (int StatusCode, ApiResultDto Payload) Api(IResult result)
    {
        if (result is null) throw new ArgumentNullException(nameof(result));
        var status = (result as IStatusCodeHttpResult)?.StatusCode ?? StatusCodes.Status200OK;
        if (result is not IValueHttpResult valueResult || valueResult.Value is not ApiResultDto payload)
            throw new InvalidOperationException("Result does not contain ApiResultDto payload");
        return (status, payload);
    }
}
