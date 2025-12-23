using System.Text;
using System.Text.Json;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Writing;
using writing_service.Contracts;
using writing_service.Domains.Entities;
using writing_service.Features.Helper;
using writing_service.Infrastructure.Persistence;

namespace writing_service.Features.Service.User;

public interface IWritingService
{
    Task<IResult> WritingSubmit(WritingSubmissionRequest request, CancellationToken token);
    Task<IResult> StartWritingExam(Guid examId, CancellationToken token);
    Task<IResult> GetExam(Guid examId, CancellationToken token);
    Task<IResult> GetExams(CancellationToken token);
    Task<IResult> GetHistory(CancellationToken token);
    Task<IResult> GetHistoryInDetail(Guid submissionId, Guid? evaluationId, CancellationToken token);

}

public class WritingService : IWritingService
{

    private readonly IUserContext _user;
    private readonly WritingDbContext _context;
    private readonly IWritingGrader _grader;

    public WritingService(
        IUserContext user,
        WritingDbContext context,
        IWritingGrader grader
        )
    {

        _user = user;
        _context = context;
        _grader = grader;
    }
    public async Task<IResult> WritingSubmit(WritingSubmissionRequest request,
        CancellationToken token)
    {
        var userId = _user.UserId;
        var exam = await _context.WritingExams.AsNoTracking().Where(x => x.Id == request.ExamId).FirstOrDefaultAsync(token)
                   ?? throw new Exception("Exam is not existed");

        var (res, raw) = await _grader.Grade(new ContentSubmission { Answer = request.Answer, Task = exam.TaskText }, token);

        var submission = new WritingSubmission
        {
            UserId = userId,
            ExamId = request.ExamId,
            TaskTextSnapshot = exam.TaskText,
            EssayRaw = request.Answer,
            EssayNormalized = request.Answer,
            ExamType = exam.ExamType,
            WordCount = res.WordCount,
            Level = exam.Level,
            TimeSpentSeconds = request.TimeSpentSeconds,
            SubmittedAt = DateTime.UtcNow,
        };
        await _context.WritingSubmissions.AddAsync(submission, token);

        res.SubmissionId = submission.Id;
        var evaluation = _grader.MapToEvaluation(res, raw);
        _context.WritingEvaluations.Add(evaluation);
        await _context.SaveChangesAsync(token);

        return Results.Ok(new ApiResultDto(true, "Submitted", res));
    }

    public async Task<IResult> StartWritingExam(Guid examId, CancellationToken token)
    {
        var userId = _user.UserId;
        var response = await _context.WritingExams.AsNoTracking()
                              .Where(x => x.Id == examId)
                              .Select(x =>
                                  new StartWritingExamResponse(x.Id, x.Title, x.TaskText, x.Tags, x.ModelAnswers, x.CreatedAt,
                                      x.CreatedBy, userId))
                              .FirstOrDefaultAsync(token)
                          ?? throw new Exception("Exam id is not existed");
        return Results.Ok(new ApiResultDto(true, "Start successfully", response));
    }

    public async Task<IResult> GetExam(Guid examId, CancellationToken token)
    {
        var exam = await _context.WritingExams.AsNoTracking()
            .Where(x => x.Id == examId)
            .Select(x => new WritingExamResponse(x.Id, x.Title, x.TaskText, x.ExamType, x.Level, x.Tags,
                x.ModelAnswers, x.CreatedAt, x.CreatedBy))
            .FirstOrDefaultAsync(token);

        return exam is null
            ? Results.NotFound(new ApiResultDto(false, "Exam not found", new { examId }))
            : Results.Ok(new ApiResultDto(true, "Fetched exam successfully", exam));
    }

    public async Task<IResult> GetExams(CancellationToken token)
    {
        var exams = await _context.WritingExams.AsNoTracking()
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => new WritingExamResponse(x.Id, x.Title, x.TaskText, x.ExamType, x.Level, x.Tags,
                x.ModelAnswers, x.CreatedAt, x.CreatedBy))
            .ToListAsync(token);

        return Results.Ok(new ApiResultDto(true, "Fetched exams successfully", exams));
    }

    public async Task<IResult> GetHistory(CancellationToken token)
    {
        var userId = _user.UserId;
        var history = await _context.WritingSubmissions.AsNoTracking()
            .Where(x => x.UserId == userId)
            .OrderByDescending(x => x.SubmittedAt)
            .Select(x => new WritingHistoryItem(
                x.Id,
                x.ExamId,
                x.WritingExam != null ? x.WritingExam.Title : x.TaskTextSnapshot,
                x.TaskTextSnapshot,
                x.ExamType,
                x.Level,
                x.WritingExam != null ? x.WritingExam.Tags : null,
                x.TimeSpentSeconds,
                x.SubmittedAt,
                _context.WritingEvaluations
                    .Where(e => e.SubmissionId == x.Id)
                    .OrderByDescending(e => e.CreatedAt)
                    .Select(e => e.OverallBand)
                    .FirstOrDefault()
            ))
            .ToListAsync(token);

        return Results.Ok(new ApiResultDto(true, "Fetched writing history successfully", history));
    }

    public async Task<IResult> GetHistoryInDetail(Guid submissionId, Guid? evaluationId, CancellationToken token)
    {
        var query = _context.WritingEvaluations.AsNoTracking()
            .Include(k => k.WritingSubmission)
            .Where(k => k.SubmissionId == submissionId);
        if (evaluationId is not null)
            query = query.Where(p => p.Id == evaluationId);
        else
            query = query.OrderByDescending(p => p.CreatedAt);

        var evaluation = await query.FirstOrDefaultAsync(token);
        if (evaluation is null)
            return Results.NotFound(new ApiResultDto(false, "Evaluation not found", new { submissionId, evaluationId }));

        var suggestions = new List<string>();
        if (!string.IsNullOrWhiteSpace(evaluation.SuggestionsJson))
        {
            try
            {
                suggestions = JsonSerializer.Deserialize<List<string>>(evaluation.SuggestionsJson) ?? new List<string>();
            }
            catch (JsonException)
            {
                // If parsing fails, keep suggestions empty.
            }
        }

        var result = new WritingGradeResponse
        {
            SubmissionId = evaluation.SubmissionId,
            TaskText = evaluation.WritingSubmission.TaskTextSnapshot,
            EssayRaw = evaluation.WritingSubmission.EssayRaw,
            EssayNormalized = evaluation.WritingSubmission.EssayNormalized,
            WordCount = evaluation.WritingSubmission.WordCount,
            OverallBand = evaluation.OverallBand,
            TaskResponse = new CriterionScore { Band = evaluation.TaskResponseBand, Comment = evaluation.TaskResponseComment },
            CoherenceAndCohesion = new CriterionScore { Band = evaluation.CoherenceAndCohesionBand, Comment = evaluation.CoherenceAndCohesionComment },
            LexicalResource = new CriterionScore { Band = evaluation.LexicalResourceBand, Comment = evaluation.LexicalResourceComment },
            GrammaticalRangeAndAccuracy = new CriterionScore { Band = evaluation.GrammaticalRangeAndAccuracyBand, Comment = evaluation.GrammaticalRangeAndAccuracyComment },
            Suggestions = suggestions,
            ImprovedParagraph = evaluation.ImprovedParagraph,
            Model = evaluation.Model,
            ModelProvider = evaluation.Provider,
            GradedAt = evaluation.CreatedAt,
            RawLlmJson = evaluation.RawLlmJson
        };

        return Results.Ok(new ApiResultDto(true, "Fetched writing detail successfully", result));
    }
}
