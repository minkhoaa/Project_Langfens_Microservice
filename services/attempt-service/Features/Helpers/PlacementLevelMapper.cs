using Shared.ExamDto.Contracts.Exam.Enums;

namespace attempt_service.Features.Helpers
{
    public static class PlacementLevelMapper
    {
        // services/attempt-service/Features/Helpers/PlacementLevelMapper.cs
        public sealed record PlacementScore(decimal ReadingPct, decimal ListeningPct, decimal? WritingBand, decimal? SpeakingBand);
        public sealed record PlacementLevel(string Level, decimal Band);
        public static PlacementLevel Map(PlacementScore score)
        {
            // tính điểm tổng hợp 0..1, ưu tiên Reading/Listening, có Writing thì cộng 20%
            var writingNorm = score.WritingBand.HasValue ? score.WritingBand.Value / 9m : (decimal?)null;
            var composite = writingNorm.HasValue
                ? 0.4m * score.ReadingPct + 0.4m * score.ListeningPct + 0.2m * writingNorm.Value
                : (score.ReadingPct + score.ListeningPct) / 2m;

            if (composite < 0.25m) return new(ExamLevel.A2, 3.5m);
            if (composite < 0.50m) return new(ExamLevel.B1, 5.0m);
            if (composite < 0.70m) return new(ExamLevel.B2, 6.0m);
            if (composite < 0.85m) return new(ExamLevel.C1, 7.0m);
            return new(ExamLevel.C1, 7.5m);
        }

    }
}