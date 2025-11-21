using System.Data;
using Microsoft.Extensions.Options;
using Shared.ExamDto.Contracts;
using writing_service.Contracts;
using writing_service.Domains.Entities;
using writing_service.Features.Helper;
using writing_service.Features.Service.User;
using writing_service.Infrastructure.Persistence;

namespace writing_service.Features.Service.Admin;

public interface IAdminService
{
    Task<IResult> CreateExam(CreateExamRequest request, CancellationToken token); 
}

public class AdminService : IAdminService
{
    private readonly OpenRouterOptions _router;
    private readonly IHttpClientFactory _client;
    private readonly IUserContext _user;
    private readonly WritingDbContext _context;

    public AdminService(IOptions<OpenRouterOptions> router, 
        IHttpClientFactory client,
        IUserContext user,
        WritingDbContext context
    )
    {
        _client = client;
        _router = router.Value;
        _user = user;
        _context = context;
    }

    public async Task<IResult> CreateExam(CreateExamRequest request, CancellationToken token)
    {
        if (!(request.ExamType == WritingCategory.TOEIC
              || request.ExamType == WritingCategory.WRITING_TASK1
              || request.ExamType == WritingCategory.WRITING_TASK2))
            throw new InvalidExpressionException("Exam type is 0, 1 ,2"); 
        var newExam = new WritingExam
        {
            Title = request.Title,
            TaskText = request.TaskText,
            ExamType = request.ExamType,
            Level = request.Level,
            CreatedAt = DateTime.UtcNow,
            Tags = request.Tag,
            CreatedBy = request.CreatedBy,
        };
        _context.WritingExams.Add(newExam);
        await _context.SaveChangesAsync(token);
        return Results.Ok(new ApiResultDto(true, "Created exam successfully",
            new { newExam.Id, newExam.Title, newExam.CreatedBy }));
    }
}