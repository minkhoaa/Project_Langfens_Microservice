using exam_service.Features.Exams.AdminEndpoint.ExamEndpoint;
using exam_service.Features.Exams.AdminEndpoint.OptionEndpoint;
using exam_service.Features.Exams.AdminEndpoint.QuestionEndpoint;
using exam_service.Features.Exams.AdminEndpoint.SectionEndpoint;
using Shared.Security.Roles;
using Shared.Security.Scopes;

namespace exam_service.Features.Exams.AdminEndpoint;

public static class AdminExamEndpoint
{
    //exam
    public static void MapAdminExamEndpoint(this IEndpointRouteBuilder app)
    {
        var adminGroup = app.MapGroup("/api/admin");
        adminGroup.MapPost("/exam/addexam", AdminExamHandler.AddExamHandler).RequireAuthorization(Roles.Admin)
            .Produces(StatusCodes.Status401Unauthorized)
            .Produces(StatusCodes.Status200OK);
        adminGroup.MapGet("/exam/all", AdminExamHandler.GetAllExamHandler).RequireAuthorization(Roles.Admin)
            .Produces(StatusCodes.Status401Unauthorized)
            .Produces(StatusCodes.Status200OK);
        adminGroup.MapPut("/exam/update/{id}", AdminExamHandler.UpdateExamHandler).RequireAuthorization(Roles.Admin)
            .Produces(StatusCodes.Status401Unauthorized)
            .Produces(StatusCodes.Status200OK);
        adminGroup.MapDelete("/exam/delete/{id}", AdminExamHandler.DeleteExamHandler).RequireAuthorization(Roles.Admin)
            .Produces(StatusCodes.Status401Unauthorized)
            .Produces(StatusCodes.Status200OK);
    }

    //section
    public static void MapAdminSectionEndpoint(this IEndpointRouteBuilder app)
    {
        var adminSection = app.MapGroup("/api/admin").RequireAuthorization(ExamScope.ExamManage);
        adminSection.MapPost("/section/add", AdminSectionHandler.AddSectionHandler)
            .Produces(StatusCodes.Status200OK).Produces(StatusCodes.Status400BadRequest);

        adminSection.MapPut("/section/update/{id}", AdminSectionHandler.UpdateSectionHandler);
        adminSection.MapDelete("/section/delete/{id}", AdminSectionHandler.DeleteSectionHandler)

            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status400BadRequest);
        adminSection.MapGet("/section/by-exam/{examId:guid}", AdminSectionHandler.GetSectionsByExamHandler)
            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status400BadRequest);
    }

    //question
    public static void MapAdminQuestionEndpoint(this IEndpointRouteBuilder app)
    {
        var adminQuestion = app.MapGroup("/api/admin").RequireAuthorization(Roles.Admin);
        adminQuestion.MapPost("/question/add", AdminQuestionHandler.AddQuestionHandler);
        adminQuestion.MapPut("/question/update/{id}", AdminQuestionHandler.UpdateQuestionHandler);
        adminQuestion.MapDelete("/question/delete/{id}", AdminQuestionHandler.DeleteQuestionHandler);
        adminQuestion.MapGet("/question/by-section/{sectionId:guid}", AdminQuestionHandler.GetQuestionsBySectionHandler)
            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status400BadRequest);
    }

    //option
    public static void MapAdminOptionEndpoint(this IEndpointRouteBuilder app)
    {
        var adminOption = app.MapGroup("/api/admin").RequireAuthorization(Roles.Admin);
        adminOption.MapPost("/option/add", AdminOptionHandler.AddOptionHandler);
        adminOption.MapPut("/option/update/{id}", AdminOptionHandler.UpdateOptionHandler);
        adminOption.MapDelete("/option/delete/{id}", AdminOptionHandler.DeleteOptionHandler);
        adminOption.MapGet("/option/by-question/{questionId:guid}", AdminOptionHandler.GetOptionsByQuestionHandler)
            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status400BadRequest);
    }
}
