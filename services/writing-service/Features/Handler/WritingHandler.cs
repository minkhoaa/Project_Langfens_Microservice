using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using writing_service.Contracts;
using writing_service.Features.Service;

namespace writing_service.Features.Handler;

public static class WritingHandler
{
    public static Task<IResult> Grade([FromBody] ContentSubmission submission,ClaimsPrincipal user, CancellationToken token,[FromServices] IWritingService service)
    {
        return service.WritingGrader(submission, token, user);
    }
}