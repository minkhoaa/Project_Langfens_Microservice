using System.Data;
using Microsoft.Extensions.Options;
using Shared.ExamDto.Contracts;
using speaking_service.Contracts;
using speaking_service.Domains.Entities;
using speaking_service.Features.Services.Helper;
using speaking_service.Infrastructure.Persistence;

namespace speaking_service.Features.Services.Admin;


public interface IAdminService
{
    Task<IResult> CreateExam(CreateSpeakingExamRequest request, CancellationToken token); 
}

public class AdminService : IAdminService
{
    private readonly OpenRouterOptions _router;
    private readonly IHttpClientFactory _client;
    private readonly IUserContext _user;
    private readonly SpeakingDbContext _context;

    public AdminService(IOptions<OpenRouterOptions> router, 
        IHttpClientFactory client,
        IUserContext user,
        SpeakingDbContext context
    )
    {
        _client = client;
        _router = router.Value;
        _user = user;
        _context = context;
    }

    public async Task<IResult> CreateExam(CreateSpeakingExamRequest request, CancellationToken token)
    {
        if (!(request.ExamType == SpeakingCategory.TOEIC
              || request.ExamType == SpeakingCategory.SPEAKING_PART1
              || request.ExamType == SpeakingCategory.SPEAKING_PART3
              || request.ExamType == SpeakingCategory.SPEAKING_PART2))
            throw new InvalidExpressionException("Exam type is 0, 1 ,2"); 
        var newExam = new SpeakingExam()
        {
            Title = request.Title,
            TaskText = request.TaskText,
            ExamType = request.ExamType,
            Level = request.Level,
            CreatedAt = DateTime.UtcNow,
            Tags = request.Tag,
            CreatedBy = request.CreatedBy,
        };
        _context.SpeakingExams.Add(newExam);
        await _context.SaveChangesAsync(token);
        return Results.Ok(new ApiResultDto(true, "Created exam successfully",
            new { newExam.Id, newExam.Title, newExam.CreatedBy }));
    }
}