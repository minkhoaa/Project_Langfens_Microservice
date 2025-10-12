using exam_service.Contracts.Exams;
using Microsoft.AspNetCore.Mvc;

namespace exam_service.Features.Exams.AdminEndpoint.SectionEndpoint;

public static class AdminSectionHandler
{
    public static Task<IResult> AddSectionHandler(
        [FromServices] IAdminSectionService service,
        [FromBody] DtoAdmin.AdminSectionUpsert dto,
        CancellationToken token
    ) => service.AddAsync(dto, token);

    public static Task<IResult> UpdateSectionHandler(
        [FromBody] DtoAdmin.AdminSectionUpdate dto,
        [FromRoute] Guid id,
        CancellationToken token,
        [FromServices] IAdminSectionService service
    ) => service.UpdateAync(dto, id, token);

    public static Task<IResult> DeleteSectionHandler(
        [FromRoute] Guid id,
        CancellationToken token,
        [FromServices] IAdminSectionService service
    ) => service.DeleteAsync(id, token);
}