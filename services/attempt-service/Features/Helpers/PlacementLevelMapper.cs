using Shared.ExamDto.Contracts.Exam.Enums;

namespace attempt_service.Features.Helpers
{
    public static class PlacementLevelMapper
    {
        public sealed record PlacementScore(int ReadingCorrect, int ListeningCorrect, decimal? WritingBand);
        public sealed record PlacementLevel(string Level, decimal Band);
        public static PlacementLevel Map(PlacementScore score)
        {
            var total = score.ReadingCorrect + score.ListeningCorrect;
            if (total < 10) return new(ExamLevel.A2, 3.5m);
            if (total < 19) return new(ExamLevel.B1, 5.0m);
            if (total < 26) return new(ExamLevel.B2, 6.0m);
            else return new(ExamLevel.C1, 7.0m);
        }
    }
}