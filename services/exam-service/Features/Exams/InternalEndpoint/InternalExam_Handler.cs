using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using Shared.Security.Roles;

namespace exam_service.Features.Exams.InternalEndpoint;

public static class InternalExamHandler
{
    public static Task<IResult> GetByExamIdHandler(
        [FromRoute] Guid id,
        [FromQuery(Name = "showAnswers")] bool showAnswer,
        CancellationToken token,
        ClaimsPrincipal user,
        [FromServices] IInternalExamService service
    ) => service.GetByExamIdAsync(id, token, showAnswer, user);
}
