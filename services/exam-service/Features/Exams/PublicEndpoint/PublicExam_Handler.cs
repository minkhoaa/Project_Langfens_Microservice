using exam_service.Application.Exam;
using Microsoft.AspNetCore.Mvc;

namespace exam_service.Features.Exams.PublicEndpoint;

public static class PublicExamHandler
{
    public static Task<IResult> GetBySlug(
        [FromRoute] string slug,
        CancellationToken token,
        [FromServices] IExamService service
    )
        => service.GetBySlugAsync(slug, token);

    public static Task<IResult> ListPublishedExam(
        string? category,
        string? level,
        int page,
        int pageSize,
        [FromServices] IExamService svc,
        CancellationToken ct
    ) => svc.ListPublishedAsync(category, level, page, pageSize, ct);
}