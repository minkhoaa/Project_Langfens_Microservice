using attempt_service.Domain.Entities;
using attempt_service.Domain.Enums;
using attempt_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace attempt_service.Features.Analytics;

public interface IBandPredictorService
{
    Task<IResult> GetPredictedBand(Guid userId, CancellationToken token);
}

public class BandPredictorService(AttemptDbContext context) : IBandPredictorService
{
    private const decimal DecayFactor = 0.05m; // λ for exponential decay
    private const int MinimumAttempts = 1; // Lowered from 3 to make it more accessible

    public async Task<IResult> GetPredictedBand(Guid userId, CancellationToken token)
    {
        // Get placement results with band scores
        var placementResults = await context.PlacementResults
            .AsNoTracking()
            .Include(pr => pr.Attempt)
            .Where(pr => pr.UserId == userId && pr.Band > 0)
            .OrderByDescending(pr => pr.CreatedAt)
            .Take(20)
            .ToListAsync(token);

        if (placementResults.Count < MinimumAttempts)
        {
            return Results.Ok(new
            {
                isSuccess = false,
                message = $"Need at least {MinimumAttempts} placement tests for prediction",
                data = (object?)null
            });
        }

        var now = DateTime.UtcNow;
        var scores = new List<(decimal band, double weight, DateTime date, PlacementResult result)>();

        foreach (var pr in placementResults)
        {
            var daysAgo = (now - pr.CreatedAt).TotalDays;
            var weight = Math.Exp(-(double)DecayFactor * daysAgo);
            scores.Add((pr.Band, weight, pr.CreatedAt, pr));
        }

        // Calculate overall predicted band
        var totalWeight = scores.Sum(s => s.weight);
        var predictedBand = scores.Sum(s => s.band * (decimal)s.weight) / (decimal)totalWeight;

        // Calculate per-skill predictions
        var readingBand = CalculateSkillBand(scores, s => s.result.ReadingCorrect, s => s.result.ReadingTotal);
        var listeningBand = CalculateSkillBand(scores, s => s.result.ListeningCorrect, s => s.result.ListeningTotal);
        var writingBand = CalculateWritingSpeakingBand(scores, s => s.result.WritingBand);
        var speakingBand = CalculateWritingSpeakingBand(scores, s => s.result.SpeakingBand);

        // Calculate confidence
        var variance = CalculateVariance(scores.Select(s => s.band).ToList());
        var latestDate = scores.Max(s => s.date);
        var daysSinceLatest = (now - latestDate).TotalDays;
        var confidence = CalculateConfidence(scores.Count, variance, daysSinceLatest);

        var result = new PredictedBandDto(
            Math.Round(predictedBand, 1),
            confidence,
            readingBand,
            listeningBand,
            writingBand,
            speakingBand,
            scores.Count,
            latestDate
        );

        return Results.Ok(new
        {
            isSuccess = true,
            message = "Predicted band calculated",
            data = result
        });
    }

    private decimal? CalculateSkillBand(
        List<(decimal band, double weight, DateTime date, PlacementResult result)> scores,
        Func<(decimal band, double weight, DateTime date, PlacementResult result), int> getCorrect,
        Func<(decimal band, double weight, DateTime date, PlacementResult result), int> getTotal)
    {
        var skillScores = scores
            .Where(s => getTotal(s) > 0)
            .Select(s => (
                accuracy: (decimal)getCorrect(s) / getTotal(s),
                weight: s.weight
            ))
            .ToList();

        if (!skillScores.Any()) return null;

        var totalWeight = skillScores.Sum(s => s.weight);
        var avgAccuracy = skillScores.Sum(s => s.accuracy * (decimal)s.weight) / (decimal)totalWeight;

        // Convert accuracy to band (simplified mapping)
        return Math.Round(1.0m + (avgAccuracy * 8.0m), 1);
    }

    private decimal? CalculateWritingSpeakingBand(
        List<(decimal band, double weight, DateTime date, PlacementResult result)> scores,
        Func<(decimal band, double weight, DateTime date, PlacementResult result), decimal?> getBand)
    {
        var skillScores = scores
            .Where(s => getBand(s).HasValue && getBand(s).Value > 0)
            .Select(s => (
                band: getBand(s)!.Value,
                weight: s.weight
            ))
            .ToList();

        if (!skillScores.Any()) return null;

        var totalWeight = skillScores.Sum(s => s.weight);
        return Math.Round(skillScores.Sum(s => s.band * (decimal)s.weight) / (decimal)totalWeight, 1);
    }

    private decimal CalculateVariance(List<decimal> values)
    {
        if (values.Count < 2) return 0;

        var mean = values.Average();
        var sumOfSquares = values.Sum(v => (v - mean) * (v - mean));
        return sumOfSquares / values.Count;
    }

    private string CalculateConfidence(int sampleSize, decimal variance, double daysSinceLatest)
    {
        // High confidence: many recent attempts, low variance
        if (sampleSize >= 5 && variance < 0.5m && daysSinceLatest < 7)
            return "High";
        
        // Medium confidence: moderate sample size, reasonable variance
        if (sampleSize >= 3 && variance < 1.0m && daysSinceLatest < 14)
            return "Medium";
        
        // Low confidence: small sample or high variance or old data
        return "Low";
    }
}
