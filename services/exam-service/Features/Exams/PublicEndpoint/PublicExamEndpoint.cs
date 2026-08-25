namespace exam_service.Features.Exams.PublicEndpoint;

public static class PublicExamEndpoint
{
    public static void MapPublicExamEndpoints(this IEndpointRouteBuilder app)
    {
        // api public
        var groupPublic = app.MapGroup("/api/public");
        groupPublic.MapGet("/exam/getall", PublicExamHandler.ListPublishedExam).AllowAnonymous();
        groupPublic.MapGet("/exam/getby/{slug}", PublicExamHandler.GetBySlug).AllowAnonymous();
    }
}