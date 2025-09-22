

namespace exam_service.Features.Exams.AdminEndpoint;

public static class AdminExamEndpoint
{
    public static void MapAdminExamEndpoint(this IEndpointRouteBuilder app)
    {
        var adminGroup = app.MapGroup("/api/admin/exam"); 
        adminGroup.MapAddExamEndpoint();
        adminGroup.MapUpdateExamEndpoint();
        adminGroup.MapDeleteExamEndpoint();
        
    }
}