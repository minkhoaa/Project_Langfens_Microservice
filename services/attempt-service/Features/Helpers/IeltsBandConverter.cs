using System;

namespace attempt_service.Features.Helpers;

public static class IeltsBandConverter
{
    // Approximate Academic Reading conversion based on correct answers (0..40)
    // Note: Real IELTS uses equating; this is a commonly used approximation.
    public static decimal FromAcademicReading(int correctOutOf40)
    {
        var c = Math.Clamp(correctOutOf40, 0, 40);
        return c switch
        {
            >= 39 => 9.0m,
            >= 37 => 8.5m,
            >= 35 => 8.0m,
            >= 33 => 7.5m,
            >= 30 => 7.0m,
            >= 27 => 6.5m,
            >= 23 => 6.0m,
            >= 19 => 5.5m,
            >= 15 => 5.0m,
            >= 13 => 4.5m,
            >= 10 => 4.0m,
            >= 8  => 3.5m,
            >= 6  => 3.0m,
            >= 4  => 2.5m,
            >= 2  => 2.0m,
            >= 1  => 1.0m,
            _ => 0.0m
        };
    }

    public static decimal FromAcademicReadingScaled(int correct, int total)
    {
        if (total <= 0) return 0m;
        var scaled = (int)Math.Round((decimal)correct / total * 40m, MidpointRounding.AwayFromZero);
        return FromAcademicReading(scaled);
    }
}

