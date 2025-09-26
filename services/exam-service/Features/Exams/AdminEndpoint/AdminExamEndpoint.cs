using exam_service.Features.Exams.AdminEndpoint.ExamEndpoint;
using exam_service.Features.Exams.AdminEndpoint.OptionEndpoint;
using exam_service.Features.Exams.AdminEndpoint.QuestionEndpoint;
using exam_service.Features.Exams.AdminEndpoint.SectionEndpoint;

namespace exam_service.Features.Exams.AdminEndpoint;

public static class AdminExamEndpoint
{
    //exam
    public static void MapAdminExamEndpoint(this IEndpointRouteBuilder app)
    {
        var adminGroup = app.MapGroup("/api/admin/exam/");
        adminGroup.MapPost("/addexam", AdminExamHandler.AddExamHandler).AllowAnonymous()
            .Produces(StatusCodes.Status401Unauthorized)
            .Produces(StatusCodes.Status200OK);
        adminGroup.MapPut("/update/{id:int}", AdminExamHandler.UpdateExamHandler).AllowAnonymous()
            .Produces(StatusCodes.Status401Unauthorized)
            .Produces(StatusCodes.Status200OK);
        adminGroup.MapDelete("/delete/{id:int}", AdminExamHandler.DeleteExamHandler).AllowAnonymous()
            .Produces(StatusCodes.Status401Unauthorized)
            .Produces(StatusCodes.Status200OK);
    }

    //section
    public static void MapAdminSectionEndpoint(this IEndpointRouteBuilder app)
    {
        var adminSection = app.MapGroup("/api/admin/section");
        adminSection.MapPost("/add", AdminSectionHandler.AddSectionHandler)
            .AllowAnonymous()
            .Produces(StatusCodes.Status200OK).Produces(StatusCodes.Status400BadRequest);

        adminSection.MapPut("/update/{id:int}", AdminSectionHandler.UpdateSectionHandler)
            .AllowAnonymous();
        adminSection.MapDelete("/delete/{id:int}", AdminSectionHandler.DeleteSectionHandler)
            .AllowAnonymous()
            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status400BadRequest);
    }

    //question
    public static void MapAdminQuestionEndpoint(this IEndpointRouteBuilder app)
    {
        var adminQuestion = app.MapGroup("/api/admin/question/");
        adminQuestion.MapPost("/add", AdminQuestionHandler.AddQuestionHandler).AllowAnonymous();
        adminQuestion.MapPut("/update/{id:int}", AdminQuestionHandler.UpdateQuestionHandler).AllowAnonymous();
        adminQuestion.MapDelete("/delete/{id:int}", AdminQuestionHandler.DeleteQuestionHandler).AllowAnonymous();
    }

    //option
    public static void MapAdminOptionEndpoint(this IEndpointRouteBuilder app)
    {
        var adminOption = app.MapGroup("/api/admin/option/");
        adminOption.MapPost("/add", AdminOptionHandler.AddOptionHandler);
        adminOption.MapPut("/update/{id:int}", AdminOptionHandler.UpdateOptionHandler);
        adminOption.MapDelete("/delete/{id:int}", AdminOptionHandler.DeleteOptionHandler);
    }
}