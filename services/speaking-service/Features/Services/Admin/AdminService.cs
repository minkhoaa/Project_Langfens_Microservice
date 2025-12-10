using System.Data;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;
using speaking_service.Contracts;
using speaking_service.Domains.Entities;
using speaking_service.Features.Services.Helper;
using speaking_service.Infrastructure.Persistence;

namespace speaking_service.Features.Services.Admin;


public interface IAdminService
{
    Task<IResult> CreateExam(CreateSpeakingExamRequest request, CancellationToken token);
    Task<IResult> UpdateExam(Guid examId, UpdateSpeakingExamRequest request, CancellationToken token);
    Task<IResult> DeleteExam(Guid examId, CancellationToken token);
    Task<IResult> GetAllExams(CancellationToken token);
}

public class AdminService : IAdminService
{
    private readonly IUserContext _user;
    private readonly SpeakingDbContext _context;

    public AdminService(
        IUserContext user,
        SpeakingDbContext context
    )
    {
        _user = user;
        _context = context;
    }

    public async Task<IResult> CreateExam(CreateSpeakingExamRequest request, CancellationToken token)
    {
        ValidateExamType(request.ExamType);
        var newExam = new SpeakingExam
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

    public async Task<IResult> UpdateExam(Guid examId, UpdateSpeakingExamRequest request, CancellationToken token)
    {
        ValidateExamType(request.ExamType);
        var exam = await _context.SpeakingExams.FirstOrDefaultAsync(x => x.Id == examId, token);
        if (exam is null)
            return Results.NotFound(new ApiResultDto(false, "Exam not found", new { examId }));

        exam.Title = request.Title;
        exam.TaskText = request.TaskText;
        exam.ExamType = request.ExamType;
        exam.Level = request.Level;
        exam.Tags = request.Tag;

        await _context.SaveChangesAsync(token);
        return Results.Ok(new ApiResultDto(true, "Updated exam successfully", new { exam.Id, exam.Title }));
    }

    public async Task<IResult> GetAllExams(CancellationToken token)
    {
        var exams = await _context.SpeakingExams.AsNoTracking()
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => new SpeakingExamResponse(x.Id, x.Title, x.TaskText, x.ExamType, x.Level, x.Tags,
                x.CreatedAt, x.CreatedBy))
            .ToListAsync(token);

        return Results.Ok(new ApiResultDto(true, "Fetched all speaking exams", exams));
    }

    public async Task<IResult> DeleteExam(Guid examId, CancellationToken token)
    {
        var exam = await _context.SpeakingExams.FirstOrDefaultAsync(x => x.Id == examId, token);
        if (exam is null)
            return Results.NotFound(new ApiResultDto(false, "Exam not found", new { examId }));

        var hasSubmission = await _context.SpeakingSubmissions.AnyAsync(x => x.ExamId == examId, token);
        if (hasSubmission)
            return Results.BadRequest(new ApiResultDto(false, "Cannot delete exam with existing submissions",
                new { examId }));

        _context.SpeakingExams.Remove(exam);
        await _context.SaveChangesAsync(token);

        return Results.Ok(new ApiResultDto(true, "Deleted exam successfully", new { exam.Id }));
    }

    private static void ValidateExamType(SpeakingCategory examType)
    {
        if (!(examType == SpeakingCategory.TOEIC
              || examType == SpeakingCategory.SPEAKING_PART1
              || examType == SpeakingCategory.SPEAKING_PART3
              || examType == SpeakingCategory.SPEAKING_PART2))
            throw new InvalidExpressionException("Exam type is 0, 1 ,2");
    }
}
