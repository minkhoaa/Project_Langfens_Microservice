namespace exam_service.Features.Exams.InternalEndpoint;

public static class InternalExamEndpoint
{
    public static void MapInternalExamEndpoint(this IEndpointRouteBuilder app)
    {
        var internalExam = app.MapGroup("/api/internal");
        internalExam.MapGet("/exams/{id:int}/delivery", InternalExamHandler.GetByExamIdHandler);
    }
}