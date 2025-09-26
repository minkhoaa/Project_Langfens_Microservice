using exam_service.Contracts.Exams;
using Microsoft.AspNetCore.Mvc;

namespace exam_service.Features.Exams.AdminEndpoint.ExamEndpoint;

public static class AdminExamHandler
{
    // GIỮ NGUYÊN TÊN METHOD
    public static Task<IResult> AddExamHandler(
        [FromBody] DtoAdmin.AdminExamCreate dto,
        CancellationToken token,
        [FromServices] IAdminExamService service)
        => service.AddAsync(dto, token);

    public static Task<IResult> UpdateExamHandler(
        [FromRoute] int id,
        [FromServices] IAdminExamService service,
        [FromBody] DtoAdmin.AdminExamUpdate update,
        CancellationToken token)
        => service.UpdateAsync(id, update, token);

    public static Task<IResult> DeleteExamHandler(
        [FromRoute] int id,
        [FromServices] IAdminExamService service,
        CancellationToken token)
        => service.DeleteAsync(id, token);
}