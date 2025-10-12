using exam_service.Contracts.Exams;
using Microsoft.AspNetCore.Mvc;

namespace exam_service.Features.Exams.AdminEndpoint.QuestionEndpoint;

public static class AdminQuestionHandler
{
    public static Task<IResult> AddQuestionHandler(
        [FromServices] IAdminQuestionService service,
        CancellationToken token,
        [FromBody] DtoAdmin.AdminQuestionUpsert dto
    ) => service.AddAsync(token, dto);

    public static Task<IResult> UpdateQuestionHandler(
        [FromServices] IAdminQuestionService service,
        CancellationToken token,
        [FromBody] DtoAdmin.AdminQuestionUpdate dto,
        [FromRoute] Guid id
    ) => service.UpdateAsync(token, dto, id);

    public static Task<IResult> DeleteQuestionHandler(
        [FromServices] IAdminQuestionService service,
        CancellationToken token,
        [FromRoute] Guid id
    ) => service.DeleteAsync(token, id);
}