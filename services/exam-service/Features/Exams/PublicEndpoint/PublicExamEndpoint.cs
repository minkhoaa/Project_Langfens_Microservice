namespace exam_service.Features.Exams.PublicEndpoint;

public static class PublicExamEndpoint
{
    public static void MapPublicExamEndpoints(this IEndpointRouteBuilder app)
    {
        // api public
        var groupPublic = app.MapGroup("/api/exam");
        groupPublic.WithTags("Exams");
        groupPublic.GetAllPublishedExamEndpoint();
        groupPublic.GetExamBySlugEndpoint();
    }
}