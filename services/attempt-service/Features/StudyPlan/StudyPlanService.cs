using attempt_service.Domain.Entities;
using attempt_service.Domain.Enums;
using attempt_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;

namespace attempt_service.Features.StudyPlan;

public interface IStudyPlanService
{
    Task<IResult> CreateOrUpdateGoal(Guid userId, CreateGoalRequest request, CancellationToken token);
    Task<IResult> GetActiveGoal(Guid userId, CancellationToken token);
    Task<IResult> GetProgress(Guid userId, CancellationToken token);
    Task<IResult> DeleteGoal(Guid userId, Guid goalId, CancellationToken token);
}

public class StudyPlanService(AttemptDbContext context) : IStudyPlanService
{
    public async Task<IResult> CreateOrUpdateGoal(Guid userId, CreateGoalRequest request, CancellationToken token)
    {
        // Validate input
        if (request.TargetBandScore < 5.0m || request.TargetBandScore > 9.0m)
            return Results.BadRequest(new ApiResultDto(false, "Target band score must be between 5.0 and 9.0", null!));
        
        if (request.TargetDate <= DateTime.UtcNow)
            return Results.BadRequest(new ApiResultDto(false, "Target date must be in the future", null!));
        
        if (request.StudyHoursPerDay < 0.5m || request.StudyHoursPerDay > 8.0m)
            return Results.BadRequest(new ApiResultDto(false, "Study hours per day must be between 0.5 and 8.0",null!));

        // Deactivate any existing active goals
        var existingGoals = await context.StudyGoals
            .Where(g => g.UserId == userId && g.IsActive)
            .ToListAsync(token);
        
        foreach (var g in existingGoals)
            g.IsActive = false;

        // Create new goal
        var goal = new StudyGoal
        {
            UserId = userId,
            TargetBandScore = request.TargetBandScore,
            TargetDate = request.TargetDate,
            FocusSkills = request.FocusSkills ?? new List<string> { "READING", "LISTENING" },
            StudyHoursPerDay = request.StudyHoursPerDay,
            IsActive = true
        };

        context.StudyGoals.Add(goal);
        await context.SaveChangesAsync(token);

        // Calculate weekly targets
        var daysRemaining = (int)(request.TargetDate - DateTime.UtcNow).TotalDays;
        var weeklyTargets = CalculateWeeklyTargets(goal, daysRemaining);

        return Results.Ok(new ApiResultDto(true, "Goal created", new CreateGoalResponseDto(
            goal.Id,
            daysRemaining,
            weeklyTargets
        )));
    }

    public async Task<IResult> GetActiveGoal(Guid userId, CancellationToken token)
    {
        var goal = await context.StudyGoals
            .AsNoTracking()
            .FirstOrDefaultAsync(g => g.UserId == userId && g.IsActive, token);

        if (goal == null)
            return Results.NotFound(new ApiResultDto(false, "No active goal found", null!));

        var dto = new StudyGoalDto(
            goal.Id,
            goal.TargetBandScore,
            goal.TargetDate,
            goal.FocusSkills,
            goal.StudyHoursPerDay,
            goal.IsActive,
            goal.CreatedAt
        );

        return Results.Ok(new ApiResultDto(true, "Goal fetched", dto));
    }

    public async Task<IResult> GetProgress(Guid userId, CancellationToken token)
    {
        var goal = await context.StudyGoals
            .AsNoTracking()
            .FirstOrDefaultAsync(g => g.UserId == userId && g.IsActive, token);

        if (goal == null)
            return Results.NotFound(new ApiResultDto(false, "No active goal found", null));

        var attempts = await context.Attempts
            .AsNoTracking()
            .Where(a => a.UserId == userId 
                && a.Status == AttemptStatus.Graded
                && a.SubmittedAt >= goal.CreatedAt
                && a.ScaledScore.HasValue)
            .ToListAsync(token);
        

        var currentProgress = new CurrentProgressDto(
            attempts.Count > 0 ? Math.Round(attempts.Average(a => a.ScaledScore!.Value), 1) : 0,
            attempts.Count,
            attempts.Sum(a => a.DurationSec) / 3600
        );

        // Calculate progress metrics
        var totalDays = (goal.TargetDate - goal.CreatedAt).TotalDays;
        var daysElapsed = (DateTime.UtcNow - goal.CreatedAt).TotalDays;
        var timeProgress = (int)Math.Min(100, daysElapsed / totalDays * 100);

        var scoreProgress = currentProgress.AvgScore > 0 
            ? (int)Math.Min(100, currentProgress.AvgScore / goal.TargetBandScore * 100)
            : 0;

        // Determine status
        string status = DetermineStatus(scoreProgress, timeProgress);

        var progressMetrics = new ProgressMetricsDto(scoreProgress, timeProgress, status);

        var goalDto = new StudyGoalDto(
            goal.Id,
            goal.TargetBandScore,
            goal.TargetDate,
            goal.FocusSkills,
            goal.StudyHoursPerDay,
            goal.IsActive,
            goal.CreatedAt
        );

        return Results.Ok(new ApiResultDto(true, "Progress fetched", new GoalProgressDto(
            goalDto,
            currentProgress,
            progressMetrics
        )));
    }

    public async Task<IResult> DeleteGoal(Guid userId, Guid goalId, CancellationToken token)
    {
        var goal = await context.StudyGoals
            .FirstOrDefaultAsync(g => g.Id == goalId && g.UserId == userId, token);

        if (goal == null)
            return Results.NotFound(new ApiResultDto(false, "Goal not found", null));

        context.StudyGoals.Remove(goal);
        await context.SaveChangesAsync(token);

        return Results.Ok(new ApiResultDto(true, "Goal deleted", null));
    }

    private static WeeklyTargetsDto CalculateWeeklyTargets(StudyGoal goal, int daysRemaining)
    {
        var weeksRemaining = Math.Max(1, daysRemaining / 7);
        
        // Recommend 2-4 tests per week based on study hours
        var testsPerWeek = goal.StudyHoursPerDay switch
        {
            <= 1.0m => 2,
            <= 2.0m => 3,
            <= 4.0m => 4,
            _ => 5
        };

        // Distribute focus across skills
        var focusDistribution = new Dictionary<string, int>();
        var skillCount = goal.FocusSkills.Count > 0 ? goal.FocusSkills.Count : 1;
        var percentPerSkill = 100 / skillCount;
        
        foreach (var skill in goal.FocusSkills)
            focusDistribution[skill] = percentPerSkill;

        return new WeeklyTargetsDto(testsPerWeek, goal.StudyHoursPerDay, focusDistribution);
    }

    private static string DetermineStatus(int scoreProgress, int timeProgress)
    {
        var difference = scoreProgress - timeProgress;
        return difference switch
        {
            >= 10 => "AHEAD",
            <= -10 => "BEHIND",
            _ => "ON_TRACK"
        };
    }
}
