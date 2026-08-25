namespace exam_service.Features.Exams.InternalEndpoint;

public static class InternalExamEndpoint
{
    public static void MapInternalExamEndpoint(this IEndpointRouteBuilder app)
    {
        var internalExam = app.MapGroup("/api");
        internalExam.MapGet("/internal/exams/{id}/delivery", InternalExamHandler.GetByExamIdHandler)
            .RequireAuthorization();
    }
}