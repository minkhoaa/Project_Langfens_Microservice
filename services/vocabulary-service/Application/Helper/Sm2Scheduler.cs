namespace vocabulary_service.Application.Helper;

public class Sm2Scheduler
{
    public static (int repetition, double ef, int intervalDays, DateTime nextDue) Apply(
        int repetition, double ef, int intervalDays, int grade, DateTime nowUtc)
    {
        var q = 5 - Math.Clamp(grade, 0, 5);
        var newEf = ef + (0.1 - q * (0.08 + q * 0.02));
        if (newEf < 1.3) newEf = 1.3;
        int newReps;
        int newInterval;
        if (grade < 3)
        {
            newReps = 0;
            newInterval = 1; // theo SM-2, có thể dùng 0/1 tuỳ chính sách; chọn 1 để quay lại sớm
        }
        else
        {
            newReps = repetition + 1;
            if (newReps == 1) newInterval = 1;
            else if (newReps == 2) newInterval = 6;
            else newInterval = (int)Math.Round(intervalDays * newEf, MidpointRounding.AwayFromZero);
            if (newInterval < 1) newInterval = 1;
        }


        var nextDue = nowUtc.Date.AddDays(newInterval);
        return (newReps, newEf, newInterval, nextDue);
    }
    
}