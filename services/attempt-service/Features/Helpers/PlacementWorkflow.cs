using attempt_service.Contracts.Attempt;
using attempt_service.Domain.Entities;
using attempt_service.Domain.Enums;
using attempt_service.Infrastructure.Persistence;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts.Exam.Enums;
using Shared.ExamDto.Contracts.Writing;

namespace attempt_service.Features.Helpers
{
    public interface IPlacementWorkflow
    {

        Task OnSubmitAsync(Guid attemptId, Guid? writingQuestionId, int listeningCorrect, int readingCorrect, string? writingTask, string? writingAnswer, CancellationToken token);
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
        public async Task OnSubmitAsync(Guid attemptId, Guid? questionId, int listeningCorrect, int readingCorrect,
            string? writingTask, string? writingAnswer, CancellationToken token)
        {
            var attempt = await _context.Attempts.Include(k => k.PlacementResults)
            .FirstOrDefaultAsync(k => k.Id == attemptId)
                ?? throw new Exception("Attempt not found");
            var placement = await _context.PlacementResults.FirstOrDefaultAsync(k => k.AttemptId == attemptId)
                    ?? new PlacementResult
                    {
                        AttemptId = attemptId,
                        ExamId = attempt.ExamId,
                        UserId = attempt.UserId,
                        CreatedAt = DateTime.UtcNow
                    };
            var gradinggResult = PlacementLevelMapper.Map(new PlacementLevelMapper.PlacementScore(listeningCorrect, readingCorrect, null));
            placement.ListeningCorrect = listeningCorrect;
            placement.ListeningCorrect = listeningCorrect;
            placement.ReadingCorrect = readingCorrect;
            placement.WritingBand = null;
            placement.TotalCorrect = listeningCorrect + readingCorrect;
            placement.Level = gradinggResult.Level;
            placement.Band = gradinggResult.Band;
            placement.UpdatedAt = DateTime.UtcNow;
            _context.Update(placement);
            attempt.Status = AttemptStatus.Submitted;
            await _context.SaveChangesAsync(token);
            if (!string.IsNullOrWhiteSpace(writingTask) || !string.IsNullOrEmpty(writingTask))
            {
                var request = new WritingGradeRequestMessage
                (attemptId, attempt.UserId, questionId, QuestionSkill.Writing, writingTask, writingAnswer);
                await _bus.Publish(request);
            }

        }

        public async Task OnWritingGradedAsync(WritingGradeResponseMessage response, CancellationToken token)
        {
            var placement = await _context.PlacementResults.FirstOrDefaultAsync(k => k.AttemptId == response.AttemptId, token);
            if (placement == null)
            {
                _logger.LogWarning("Placement not found");
                if (placement == null)
                {
                    _logger.LogWarning("Placement not found for attempt {AttemptId}", response.AttemptId);
                    return;
                }
            }
            placement.WritingBand = (decimal)response.OverallBand;
            var mapped = PlacementLevelMapper.Map(new PlacementLevelMapper.PlacementScore
                (placement.ListeningCorrect, placement.ReadingCorrect, placement.WritingBand));
            _context.Update(placement);
            await _context.Attempts.Where(k => k != null && k.Id == response.AttemptId)
               .ExecuteUpdateAsync(p => p.SetProperty(k => k.Status, AttemptStatus.Graded), token);
            await _context.SaveChangesAsync(token);
        }
    }
}