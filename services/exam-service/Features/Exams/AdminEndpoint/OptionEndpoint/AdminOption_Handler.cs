using exam_service.Contracts.Exams;
using Microsoft.AspNetCore.Mvc;

namespace exam_service.Features.Exams.AdminEndpoint.OptionEndpoint;

public static class AdminOptionHandler
{
    public static Task<IResult> AddOptionHandler(
        [FromBody] DtoAdmin.AdminOptionUpsert dto,
        CancellationToken token,
        [FromServices] IAdminOptionService service
    ) => service.AddAsync(dto, token);

    public static Task<IResult> UpdateOptionHandler(
        [FromBody] DtoAdmin.AdminOptionUpdate dto,
        CancellationToken token,
        [FromRoute] int id,
        [FromServices] IAdminOptionService service)
        => service.UpdateAsync(id, dto, token);

    public static Task<IResult> DeleteOptionHandler(
        [FromRoute] int id,
        CancellationToken token,
        [FromServices] IAdminOptionService service)
        => service.DeleteAsync(id, token);
}