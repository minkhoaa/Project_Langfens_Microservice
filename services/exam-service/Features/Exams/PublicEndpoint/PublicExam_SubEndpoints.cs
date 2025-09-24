using exam_service.Application.Exam;
using Shared.Contracts.Contracts;

namespace exam_service.Features.Exams.PublicEndpoint;

public static class PublicExamSubEndpoints
{
    public static RouteHandlerBuilder GetExamBySlugEndpoint(this RouteGroupBuilder app)
    {
        return app.MapGet("/{slug}", async ( string slug, CancellationToken token, IExamService service) =>
            {
                var res = await service.GetBySlugAsync(slug, token);
                return (res.isSuccess == true) ? Results.Ok(res) : Results.NotFound(res);
            })
            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status400BadRequest);
    }
    public static RouteHandlerBuilder GetAllPublishedExamEndpoint(this RouteGroupBuilder app)
    {
        return app.MapGet("/getallpublishedexam", async (
                string? category,
                string? level,
                int page,
                int pageSize,
                IExamService svc,
                CancellationToken ct
            ) =>
            {
                ApiResultDto result = await svc.ListPublishedAsync(category, level, page, pageSize, ct); 
                return Results.Ok(result);
            })
            .AllowAnonymous().Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound);
    }
}