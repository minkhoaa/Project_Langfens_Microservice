using exam_service.Features.Exams.AdminEndpoint.ExamEndpoint;
using exam_service.Features.Exams.AdminEndpoint.OptionEndpoint;
using exam_service.Features.Exams.AdminEndpoint.QuestionEndpoint;
using exam_service.Features.Exams.AdminEndpoint.SectionEndpoint;
using Shared.Security.Scopes;

namespace exam_service.Features.Exams.AdminEndpoint;

public static class AdminExamEndpoint
{
    //exam
    public static void MapAdminExamEndpoint(this IEndpointRouteBuilder app)
    {
        var adminGroup = app.MapGroup("/api/admin/exam/");
        adminGroup.MapPost("/addexam", AdminExamHandler.AddExamHandler).RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status401Unauthorized)
            .Produces(StatusCodes.Status200OK);
        adminGroup.MapPut("/update/{id}", AdminExamHandler.UpdateExamHandler).RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status401Unauthorized)
            .Produces(StatusCodes.Status200OK);
        adminGroup.MapDelete("/delete/{id}", AdminExamHandler.DeleteExamHandler).RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status401Unauthorized)
            .Produces(StatusCodes.Status200OK);
    }

    //section
    public static void MapAdminSectionEndpoint(this IEndpointRouteBuilder app)
    {
        var adminSection = app.MapGroup("/api/admin/section").RequireAuthorization(ExamScope.ExamManage);
        adminSection.MapPost("/add", AdminSectionHandler.AddSectionHandler)
            .Produces(StatusCodes.Status200OK).Produces(StatusCodes.Status400BadRequest);

        adminSection.MapPut("/update/{id}", AdminSectionHandler.UpdateSectionHandler);
        adminSection.MapDelete("/delete/{id}", AdminSectionHandler.DeleteSectionHandler)
         
            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status400BadRequest);
    }

    //question
    public static void MapAdminQuestionEndpoint(this IEndpointRouteBuilder app)
    {
        var adminQuestion = app.MapGroup("/api/admin/question/");
        adminQuestion.MapPost("/add", AdminQuestionHandler.AddQuestionHandler)
            .RequireAuthorization("AdminOnly");
        adminQuestion.MapPut("/update/{id}", AdminQuestionHandler.UpdateQuestionHandler)
            .RequireAuthorization("AdminOnly");
        adminQuestion.MapDelete("/delete/{id}", AdminQuestionHandler.DeleteQuestionHandler)
            .RequireAuthorization("AdminOnly");
    }

    //option
    public static void MapAdminOptionEndpoint(this IEndpointRouteBuilder app)
    {
        var adminOption = app.MapGroup("/api/admin/option/");
        adminOption.MapPost("/add", AdminOptionHandler.AddOptionHandler)
            .RequireAuthorization("AdminOnly");
        adminOption.MapPut("/update/{id}", AdminOptionHandler.UpdateOptionHandler)
            .RequireAuthorization("AdminOnly");
        adminOption.MapDelete("/delete/{id}", AdminOptionHandler.DeleteOptionHandler).
            RequireAuthorization("AdminOnly");
    }
}