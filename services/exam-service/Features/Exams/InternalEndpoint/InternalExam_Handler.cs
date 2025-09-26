using Microsoft.AspNetCore.Mvc;

namespace exam_service.Features.Exams.InternalEndpoint;

public static class InternalExamHandler
{
    public static Task<IResult> GetByExamIdHandler(
        [FromRoute] int id, 
        bool showAnswer,
        CancellationToken token,
        [FromServices] IInternalExamService service
        ) => service.GetByExamIdAsync(id, token, showAnswer);
    
    
}