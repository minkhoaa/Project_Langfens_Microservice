using Shared.ExamDto.Contracts.Exam.Enums;

namespace attempt_service.Features.Helpers
{
    public static class PlacementLevelMapper
    {
        // services/attempt-service/Features/Helpers/PlacementLevelMapper.cs
        public record PlacementScore(
                decimal? ReadingBand,
                decimal? ListeningBand,
                decimal? WritingBand,
                decimal? SpeakingBand
            );
        public record PlacementMapped(
            string Level,
            decimal Band // overall IELTS-like band
        );

        public static PlacementMapped Map(PlacementScore score)
        {
            var bands = new List<decimal>();

            if (score.ReadingBand is { } rb) bands.Add(rb);
            if (score.ListeningBand is { } lb) bands.Add(lb);
            if (score.WritingBand is { } wb) bands.Add(wb);
            if (score.SpeakingBand is { } sb) bands.Add(sb);

            if (bands.Count == 0)
                return new PlacementMapped("A0", 0m); 

            var raw = bands.Average();
            var overall = RoundIelts(raw);
            var level = MapIeltsToCefr(overall);

            return new PlacementMapped(level, overall);
        }

        // Làm tròn theo quy tắc IELTS:
        // < .25  -> xuống band .0
        // .25-.74 -> về .5
        // >= .75  -> lên band .0 tiếp theo
        private static decimal RoundIelts(decimal value)
        {
            var floor = Math.Floor(value);
            var frac = value - floor;

            if (frac < 0.25m) return floor;
            if (frac < 0.75m) return floor + 0.5m;
            return floor + 1.0m;
        }

        private static string MapIeltsToCefr(decimal band) => band switch
        {
            < 3.0m => "A1",
            >= 3.0m and < 4.0m => "A2",
            >= 4.0m and < 5.0m => "B1",
            >= 5.0m and < 6.0m => "B2",
            >= 6.0m and < 7.0m => "C1",
            _ => "C2"
        };

    }
}