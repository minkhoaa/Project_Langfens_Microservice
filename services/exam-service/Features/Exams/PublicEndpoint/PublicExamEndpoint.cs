namespace exam_service.Features.Exams.PublicEndpoint;

public static class PublicExamEndpoint
{
    public static void MapPublicExamEndpoints(this IEndpointRouteBuilder app)
    {
        // api public
        var groupPublic = app.MapGroup("/api/public/exam");
        groupPublic.MapGet("/getall", PublicExamHandler.ListPublishedExam);
        groupPublic.MapGet("/getby/{slug:int}", PublicExamHandler.GetBySlug); 
    }
}