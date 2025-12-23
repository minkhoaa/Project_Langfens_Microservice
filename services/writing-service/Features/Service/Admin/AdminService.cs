using System.Data;
using Microsoft.EntityFrameworkCore;
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
    Task<IResult> UpdateExam(Guid examId, UpdateExamRequest request, CancellationToken token);
    Task<IResult> DeleteExam(Guid examId, CancellationToken token);
    Task<IResult> GetAllExams(CancellationToken token);
}

public class AdminService : IAdminService
{
    private readonly IUserContext _user;
    private readonly WritingDbContext _context;

    public AdminService(
        IUserContext user,
        WritingDbContext context
    )
    {

        _user = user;
        _context = context;
    }

    public async Task<IResult> CreateExam(CreateExamRequest request, CancellationToken token)
    {
        ValidateExamType(request.ExamType);
        var newExam = new WritingExam
        {
            Title = request.Title,
            TaskText = request.TaskText,
            Slug = request.Slug,
            ExamType = request.ExamType,
            Level = request.Level,
            CreatedAt = DateTime.UtcNow,
            Tags = request.Tag,
            ImageUrl = request.ImageUrl,
            ModelAnswers = request.ModelAnswers,
            CreatedBy = _user.UserId,
            SourceExamId = request.SourceExamId,
            SourceSectionId = request.SourceSectionId
        };
        _context.WritingExams.Add(newExam);
        await _context.SaveChangesAsync(token);
        return Results.Ok(new ApiResultDto(true, "Created exam successfully",
            new { newExam.Id, newExam.Title, newExam.CreatedBy, newExam.SourceExamId, newExam.SourceSectionId }));
    }

    public async Task<IResult> UpdateExam(Guid examId, UpdateExamRequest request, CancellationToken token)
    {
        ValidateExamType(request.ExamType);
        var exam = await _context.WritingExams.FirstOrDefaultAsync(x => x.Id == examId, token);
        if (exam is null)
            return Results.NotFound(new ApiResultDto(false, "Exam not found", new { examId }));

        exam.Title = request.Title;
        exam.Slug = request.Slug;
        exam.TaskText = request.TaskText;
        exam.ExamType = request.ExamType;
        exam.Level = request.Level;
        exam.Tags = request.Tag;
        exam.ModelAnswers = request.ModelAnswers;
        exam.ImageUrl = request.ImageUrl;
        exam.SourceExamId = request.SourceExamId;
        exam.SourceSectionId = request.SourceSectionId;
        await _context.SaveChangesAsync(token);
        return Results.Ok(new ApiResultDto(true, "Updated exam successfully", new { exam.Id, exam.Title, exam.SourceExamId }));
    }

    public async Task<IResult> GetAllExams(CancellationToken token)
    {
        var exams = await _context.WritingExams.AsNoTracking()
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => new WritingExamResponse(x.Id, x.Title, x.Slug, x.TaskText, x.ExamType, x.Level, x.Tags,
                x.ModelAnswers, x.ImageUrl, x.CreatedAt, x.CreatedBy, x.SourceExamId, x.SourceSectionId))
            .ToListAsync(token);

        return Results.Ok(new ApiResultDto(true, "Fetched all writing exams", exams));
    }

    public async Task<IResult> DeleteExam(Guid examId, CancellationToken token)
    {
        var exam = await _context.WritingExams.FirstOrDefaultAsync(x => x.Id == examId, token);
        if (exam is null)
            return Results.NotFound(new ApiResultDto(false, "Exam not found", new { examId }));

        var hasSubmission = await _context.WritingSubmissions.AnyAsync(x => x.ExamId == examId, token);
        if (hasSubmission)
            return Results.BadRequest(new ApiResultDto(false, "Cannot delete exam with existing submissions",
                new { examId }));

        _context.WritingExams.Remove(exam);
        await _context.SaveChangesAsync(token);

        return Results.Ok(new ApiResultDto(true, "Deleted exam successfully", new { exam.Id }));
    }

    private static void ValidateExamType(WritingCategory examType)
    {
        if (!(examType == WritingCategory.TOEIC
              || examType == WritingCategory.WRITING_TASK1
              || examType == WritingCategory.WRITING_TASK2))
            throw new InvalidExpressionException("Exam type is 0, 1 ,2");
    }
}
