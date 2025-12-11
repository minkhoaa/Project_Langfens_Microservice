using System.ComponentModel;
using System.Net.WebSockets;
using System.Text;
using System.Text.Json;
using CloudinaryDotNet;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Shared.ExamDto.Contracts;
using speaking_service.Contracts;
using speaking_service.Domains.Entities;
using speaking_service.Features.Helper;
using speaking_service.Features.Services.Helper;
using speaking_service.Infrastructure.Persistence;

namespace speaking_service.Features.Services.User;


public interface ISpeakingService
{
    Task<IResult> SpeakingSubmit(SpeakingSubmitForm submitForm, CancellationToken token);
    Task<IResult> StartSpeakingExam(Guid examId, CancellationToken token);
    Task<IResult> GetExam(Guid examId, CancellationToken token);
    Task<IResult> GetExams(CancellationToken token);
    Task<IResult> GetHistory(CancellationToken token);
}

public class SpeakingService : ISpeakingService
{
    private readonly SpeakingDbContext _context;
    private readonly IUserContext _user;
    private readonly IWhisperService _whisper;
    private readonly ISpeakingGrader _grader;
    public SpeakingService(SpeakingDbContext context, IUserContext user,
        ISpeakingGrader grader,
        IWhisperService whisper)
    {
        _whisper = whisper;
        _context = context;
        _user = user;
        _grader = grader;

    }

    public async Task<IResult> SpeakingSubmit(SpeakingSubmitForm submitForm, CancellationToken token)
    {

        var transcript = await _whisper.Transcript(submitForm.Speech);
        var userId = _user.UserId;
        var exam = await _context.SpeakingExams.AsNoTracking().Where(x => x.Id == submitForm.ExamId)
            .FirstOrDefaultAsync(token) ?? throw new Exception("Exam is not existed");

        var (res, raw) = await _grader.Grade(new ContentSubmission
        {
            Task = exam.TaskText,
            Transcript = transcript
        }, token);

        var submission = new SpeakingSubmission()
        {
            UserId = userId,
            ExamId = submitForm.ExamId,
            TaskTextSnapshot = exam.TaskText,
            TranscriptRaw = transcript,
            TranscriptNormalized = transcript,
            ExamType = exam.ExamType,
            WordCount = res.WordCount,
            Level = exam.Level,
            TimeSpentSeconds = submitForm.TimeSpentSeconds,
            SubmittedAt = DateTime.UtcNow,
        };
        await _context.SpeakingSubmissions.AddAsync(submission, token);
        res.SubmissionId = submission.Id;
        var evaluation = _grader.MapToEvaluation(res, raw);
        _context.SpeakingEvaluations.Add(evaluation);
        await _context.SaveChangesAsync(token);
        return Results.Ok(new ApiResultDto(true, "Submitted", new { submission.Id, res }));

    }

    public async Task<IResult> StartSpeakingExam(Guid examId, CancellationToken token)
    {
        var userId = _user.UserId;
        var response = await _context.SpeakingExams.AsNoTracking()
                           .Where(x => x.Id == examId)
                           .Select(x =>
                               new StartSpeakingExamResponse(x.Id, x.Title, x.TaskText, x.Tags, x.CreatedAt,
                                   x.CreatedBy, userId))
                           .FirstOrDefaultAsync(token)
                       ?? throw new Exception("Exam id is not existed");
        return Results.Ok(new ApiResultDto(true, "Start successfully", response));
    }

    public async Task<IResult> GetExam(Guid examId, CancellationToken token)
    {
        var exam = await _context.SpeakingExams.AsNoTracking()
            .Where(x => x.Id == examId)
            .Select(x => new SpeakingExamResponse(x.Id, x.Title, x.TaskText, x.ExamType, x.Level, x.Tags,
                x.CreatedAt, x.CreatedBy))
            .FirstOrDefaultAsync(token);

        return exam is null
            ? Results.NotFound(new ApiResultDto(false, "Exam not found", new { examId }))
            : Results.Ok(new ApiResultDto(true, "Fetched exam successfully", exam));
    }

    public async Task<IResult> GetExams(CancellationToken token)
    {
        var exams = await _context.SpeakingExams.AsNoTracking()
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => new SpeakingExamResponse(x.Id, x.Title, x.TaskText, x.ExamType, x.Level, x.Tags,
                x.CreatedAt, x.CreatedBy))
            .ToListAsync(token);

        return Results.Ok(new ApiResultDto(true, "Fetched exams successfully", exams));
    }

    public async Task<IResult> GetHistory(CancellationToken token)
    {
        var userId = _user.UserId;
        var history = await _context.SpeakingSubmissions.AsNoTracking()
            .Where(x => x.UserId == userId)
            .OrderByDescending(x => x.SubmittedAt)
            .Select(x => new SpeakingHistoryItem(
                x.Id,
                x.ExamId,
                x.SpeakingExam != null ? x.SpeakingExam.Title : x.TaskTextSnapshot,
                x.TaskTextSnapshot,
                x.ExamType,
                x.Level,
                x.SpeakingExam != null ? x.SpeakingExam.Tags : null,
                x.TimeSpentSeconds,
                x.SubmittedAt,
                _context.SpeakingEvaluations
                    .Where(e => e.SubmissionId == x.Id)
                    .OrderByDescending(e => e.CreatedAt)
                    .Select(e => e.OverallBand)
                    .FirstOrDefault()
            ))
            .ToListAsync(token);

        return Results.Ok(new ApiResultDto(true, "Fetched speaking history successfully", history));
    }






}
