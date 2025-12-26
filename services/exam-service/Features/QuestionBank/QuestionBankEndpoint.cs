namespace exam_service.Features.QuestionBank;

public static class QuestionBankEndpoint
{
    public static void MapQuestionBankEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/question-bank")
            .WithTags("Question Bank")
            .AllowAnonymous(); // Public API for question bank

        group.MapGet("/types", Handler.GetQuestionTypes)
            .WithName("GetQuestionTypes")
            .WithDescription("Get list of all question types with counts");

        group.MapGet("/questions", Handler.GetQuestionsByType)
            .WithName("GetQuestionsByType")
            .WithDescription("Get questions filtered by type with pagination");

        group.MapGet("/exams", Handler.GetExamsByQuestionType)
            .WithName("GetExamsByQuestionType")
            .WithDescription("Get exams filtered by question type with pagination");
    }

    private static class Handler
    {
        public static Task<IResult> GetQuestionTypes(
            string? skill,
            CancellationToken token,
            IQuestionBankService service
        ) => service.GetQuestionTypes(skill, token);

        public static Task<IResult> GetQuestionsByType(
            string type,
            string? skill,
            int page = 1,
            int pageSize = 20,
            CancellationToken token = default,
            IQuestionBankService service = default!
        ) => service.GetQuestionsByType(type, skill, page, pageSize, token);

        public static Task<IResult> GetExamsByQuestionType(
            string? type,
            int page = 1,
            int pageSize = 20,
            CancellationToken token = default,
            IQuestionBankService service = default!
        ) => service.GetExamByQuestionTypes(type, page, pageSize, token);
    }
}
