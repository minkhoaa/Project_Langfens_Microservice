using exam_service.Features.Exams.AdminEndpoint.ExamEndpoint;
using exam_service.Features.Exams.AdminEndpoint.QuestionEndpoint;
using exam_service.Features.Exams.AdminEndpoint.SectionEndpoint;

namespace exam_service.Features.Exams.AdminEndpoint;

public static class AdminExamEndpoint
{
    
    //section
    public static void MapAdminSectionEndpoint(this IEndpointRouteBuilder app)
    {
        var adminSection =  app.MapGroup("/api/admin/section");
        adminSection.MapPost("/add", AdminSectionHandler.AddSectionHandler)
            .AllowAnonymous()
            .Produces(StatusCodes.Status200OK).Produces(StatusCodes.Status400BadRequest); 
        
        
        adminSection.MapPut("/update", AdminSectionHandler.UpdateSectionHandler)
            .AllowAnonymous()
            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status400BadRequest);
    } 
    
    //question
    public static void MapAdminQuestionEndpoint(this IEndpointRouteBuilder app)
    {
        var adminQuestion = app.MapGroup("/api/admin/question");
        adminQuestion.MapPost("/add", AdminQuestionHandler.AddQuestionHandler).AllowAnonymous();
        adminQuestion.MapGet("/update", AdminQuestionHandler.UpdateQuestionHandler).AllowAnonymous();
    }
    
    //exam
    public static void MapAdminExamEndpoint(this IEndpointRouteBuilder app)
    {
        var adminGroup = app.MapGroup("/api/admin/exam"); 
        adminGroup.MapPost("/addexam", AdminExamHandler.AddExamHandler).AllowAnonymous()
            .Produces(StatusCodes.Status401Unauthorized)
            .Produces(StatusCodes.Status200OK);
        adminGroup.MapPut("/update", AdminExamHandler.UpdateExamHandler).AllowAnonymous()
            .Produces(StatusCodes.Status401Unauthorized)
            .Produces(StatusCodes.Status200OK);
        adminGroup.MapPut("/update", AdminExamHandler.DeleteExamHandler).AllowAnonymous()
            .Produces(StatusCodes.Status401Unauthorized)
            .Produces(StatusCodes.Status200OK);
    }
    
}