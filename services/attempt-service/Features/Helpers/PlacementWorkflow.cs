using System.Text.Json;
using attempt_service.Domain.Entities;
using attempt_service.Domain.Enums;
using attempt_service.Infrastructure.Persistence;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts.Exam.Enums;
using Shared.ExamDto.Contracts.Speaking;
using Shared.ExamDto.Contracts.Writing;

namespace attempt_service.Features.Helpers
{
    public interface IPlacementWorkflow
    {

        Task OnSubmitAsync(
               Guid attemptId,
               Guid? writingQuestionId,
               string? writingTask,
               string? writingAnswer,
               Guid? speakingQuestionId,
               string? speakingTask,
               string? speakingAnswerJson,
               int listeningCorrect, int listeningTotal,
               int readingCorrect, int readingTotal,
               CancellationToken token);
        Task OnWritingGradedAsync(WritingGradeResponseMessage msg, CancellationToken token);
    }
    public class PlacementWorkflow : IPlacementWorkflow
    {
        private readonly AttemptDbContext _context;
        private readonly IPublishEndpoint _bus;
        private readonly ILogger<PlacementWorkflow> _logger;
        public PlacementWorkflow(AttemptDbContext context, IPublishEndpoint bus, ILogger<PlacementWorkflow> logger)
        {
            _context = context;
            _bus = bus;
            _logger = logger;
        }
        public async Task OnSubmitAsync(
           Guid attemptId,
           Guid? writingQuestionId,
           string? writingTask,
           string? writingAnswer,
           Guid? speakingQuestionId,
           string? speakingTask,
           string? speakingAnswerJson,
           int listeningCorrect, int listeningTotal,
           int readingCorrect, int readingTotal,
           CancellationToken token)
        {
            var attempt = await _context.Attempts.Include(k => k.PlacementResults)
            .FirstOrDefaultAsync(k => k.Id == attemptId, token)
                ?? throw new Exception("Attempt not found");
            var placement = await _context.PlacementResults.FirstOrDefaultAsync(k => k.AttemptId == attemptId, token)
                    ?? new PlacementResult
                    {
                        AttemptId = attemptId,
                        ExamId = attempt.ExamId,
                        UserId = attempt.UserId,
                        CreatedAt = DateTime.UtcNow
                    };

            var readingPct = readingTotal > 0 ? (decimal)readingCorrect / readingTotal : 0m;
            var listeningPct = listeningTotal > 0 ? (decimal)listeningCorrect / listeningTotal : 0m;

            var mapped = PlacementLevelMapper.Map(
                new PlacementLevelMapper.PlacementScore(readingPct, listeningPct, null, null));
            placement.ReadingCorrect = readingCorrect;
            placement.ReadingTotal = readingTotal;
            placement.ListeningCorrect = listeningCorrect;
            placement.ListeningTotal = listeningTotal;
            placement.TotalCorrect = listeningCorrect + readingCorrect;

            placement.WritingBand = null;
            placement.SpeakingBand = null;
            placement.Level = mapped.Level;
            placement.Band = mapped.Band;
            placement.UpdatedAt = DateTime.UtcNow;

            if (_context.Entry(placement).State == EntityState.Detached)
                _context.PlacementResults.Add(placement);
            else _context.PlacementResults.Update(placement);

            await _context.SaveChangesAsync(token);
            var hasWriting =
                    writingQuestionId.HasValue &&
                    !string.IsNullOrWhiteSpace(writingAnswer);
            if (hasWriting)
            {
                var request = new WritingGradeRequestMessage
                (attemptId, attempt.UserId, writingQuestionId, QuestionSkill.Writing, writingTask, writingAnswer);
                _logger.LogInformation(JsonSerializer.Serialize(request), token);

                await _bus.Publish(request, token);
            }
            var hasSpeaking =
                speakingQuestionId.HasValue &&
                !string.IsNullOrWhiteSpace(speakingAnswerJson);
            if (hasSpeaking)
            {
                SpeakingAudioMeta? audioMeta = null;
                try
                {
                    audioMeta = JsonSerializer.Deserialize<SpeakingAudioMeta>(speakingAnswerJson!);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex,
                        "Failed to deserialize speaking answer for attempt {AttemptId}", attemptId);
                }
                if (audioMeta != null && !string.IsNullOrWhiteSpace(audioMeta.AudioUrl))
                {
                    var speakingRequest = new SpeakingGradingRequestMessage(
                        AttemptId: attemptId,
                        UserId: attempt.UserId,
                        QuestionId: speakingQuestionId,
                        Skill: QuestionSkill.Speaking,
                        Prompt: speakingTask,
                        AudioUrl: audioMeta.AudioUrl,
                        Format: audioMeta.Format,
                        Duration: (int)audioMeta.DurationSec!,
                        Bytes: audioMeta.Bytes,
                        PublicId: audioMeta.PublicId
                    );
                    _logger.LogInformation(JsonSerializer.Serialize(speakingRequest), token);
                    await _bus.Publish(speakingRequest, token);
                }
            }
            if (hasWriting || hasSpeaking)
            {
                if (attempt.Status is AttemptStatus.Started or AttemptStatus.InProgress or AttemptStatus.Graded)
                    attempt.Status = AttemptStatus.Submitted;

                await _context.SaveChangesAsync(token);
            }
        }

        public async Task OnWritingGradedAsync(WritingGradeResponseMessage response, CancellationToken token)
        {
            var placement = await _context.PlacementResults
                .FirstOrDefaultAsync(k => k.AttemptId == response.AttemptId, token);

            if (placement == null)
            {
                _logger.LogWarning("PlacementResult not found for attempt {AttemptId}", response.AttemptId);
                return;
            }

            placement.WritingBand = (decimal)response.OverallBand;

            var readingPct = placement.ReadingTotal > 0
                ? (decimal)placement.ReadingCorrect / placement.ReadingTotal
                : 0m;

            var listeningPct = placement.ListeningTotal > 0
                ? (decimal)placement.ListeningCorrect / placement.ListeningTotal
                : 0m;


            var mapped = PlacementLevelMapper.Map(new PlacementLevelMapper.PlacementScore
                (readingPct, listeningPct, placement.WritingBand, placement.SpeakingBand));
            placement.Level = mapped.Level;
            placement.Band = mapped.Band;
            placement.UpdatedAt = DateTime.UtcNow;

            _context.PlacementResults.Update(placement);

            await _context.Attempts
                    .Where(a => a.Id == response.AttemptId)
                    .ExecuteUpdateAsync(p => p
                        .SetProperty(a => a.Status, AttemptStatus.Graded)
                        .SetProperty(a => a.GradedAt, DateTime.UtcNow),
                        token);

            await _context.SaveChangesAsync(token);
        }
    }
}