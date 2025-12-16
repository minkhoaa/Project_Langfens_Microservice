// Assuming a clean project setup for vocabulary-service tests
using vocabulary_service.Application.Helper;
using FluentAssertions;
using Xunit;

namespace VocabularyService.UnitTests.Application.Helper
{
    public class Sm2Scheduler_Tests
    {
        public static IEnumerable<object[]> Sm2TestCases()
        {
            var now = new DateTime(2025, 1, 1, 12, 0, 0, DateTimeKind.Utc);
            
            // VF-001: Quality < 3 (reset)
            yield return new object[] { "q=0, new card", 0, 2.5, 0, 0, now, 0, 1.7, 1 }; // EF drops
            yield return new object[] { "q=1, new card", 0, 2.5, 0, 1, now, 0, 1.96, 1 };
            yield return new object[] { "q=2, new card", 0, 2.5, 0, 2, now, 0, 2.18, 1 };
            yield return new object[] { "q=2, reviewed card", 3, 1.8, 10, 2, now, 0, 1.48, 1 }; // EF stays same, reps reset
            
            // VF-001: Quality >= 3 (promote)
            yield return new object[] { "q=3, first review (reps=0)", 0, 2.5, 0, 3, now, 1, 2.36, 1 }; // First pass, interval=1
            yield return new object[] { "q=4, first review (reps=0)", 0, 2.5, 0, 4, now, 1, 2.5, 1 }; // EF increases? No, 2.5+(0.1-(1)*(0.08+0.02)) = 2.5+0 = 2.5
            yield return new object[] { "q=5, first review (reps=0)", 0, 2.5, 0, 5, now, 1, 2.6, 1 };
            
            yield return new object[] { "q=3, second review (reps=1)", 1, 2.5, 1, 3, now, 2, 2.36, 6 }; // Second pass, interval=6
            yield return new object[] { "q=4, second review (reps=1)", 1, 2.6, 1, 4, now, 2, 2.6, 6 };
            
            yield return new object[] { "q=5, third review (reps=2, EF=2.7)", 2, 2.7, 6, 5, now, 3, 2.8, 17 }; // 6 * 2.8 = 16.8 -> 17
            yield return new object[] { "EF floor", 5, 1.3, 20, 3, now, 6, 1.3, 26 }; // 20 * 1.3 = 26. EF doesn't drop below 1.3
        }

        [Theory(DisplayName = "VF-001: SM2 scheduling - {0}")]
        [MemberData(nameof(Sm2TestCases))]
        public void Sm2Scheduler_Should_Calculate_Next_Review_Correctly(
            string caseName,
            int repetition, double ef, int intervalDays, int grade, DateTime nowUtc,
            int expectedRepetition, double expectedEf, int expectedIntervalDays)
        {
            _ = caseName;
            // Act
            var (newReps, newEf, newInterval, nextDue) = Sm2Scheduler.Apply(repetition, ef, intervalDays, grade, nowUtc);

            // Assert
            newReps.Should().Be(expectedRepetition);
            newEf.Should().BeApproximately(expectedEf, 0.01);
            newInterval.Should().Be(expectedIntervalDays);
            nextDue.Should().Be(nowUtc.Date.AddDays(expectedIntervalDays));
        }
    }
}
