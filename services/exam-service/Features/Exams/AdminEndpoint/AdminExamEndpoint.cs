using exam_service.Features.Exams.AdminEndpoint.ExamEndpoint;
using exam_service.Features.Exams.AdminEndpoint.QuestionEndpoint;
using exam_service.Features.Exams.AdminEndpoint.SectionEndpoint;

namespace exam_service.Features.Exams.AdminEndpoint;

public static class AdminEndpoint
{
    //section
    public static void MapAddSectionEndpoint(this IEndpointRouteBuilder app)
    {
        var adminSection =  app.MapGroup("/api/admin/section");
        adminSection.MapAddSectionSubEndpoint();
    } 
    
    //question
    public static void MapAdminQuestionEndpoint(this IEndpointRouteBuilder app)
    {
        var adminQuestion = app.MapGroup("/api/admin/question");
        adminQuestion.MapAddQuestionEndpoint();
    }
    
    //exam
    public static void MapAdminExamEndpoint(this IEndpointRouteBuilder app)
    {
        var adminGroup = app.MapGroup("/api/admin/exam"); 
        adminGroup.MapAddExamEndpoint();
        adminGroup.MapUpdateExamEndpoint();
        adminGroup.MapDeleteExamEndpoint();
        
    }
}