using course_service.Contracts;
using course_service.Domains.Entities;
using course_service.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Course.Enums;

namespace course_service.Features.UserEndpoint
{
    public interface IUserEndpointService
    {
        public Task<IResult> EnrollCourse(
            CancellationToken token,
            Guid courseId,
            Guid userId
        );

        // tạm thời truyền user ID 
        public Task<IResult> CompleteCourse(
            CancellationToken token,
            Guid lessonId,
            Guid userId
        );
        public Task<IResult> GetMyProgress(
            Guid userId,
            CancellationToken token
        );
    }
    public class UserEndpointService(CourseDbContext context) : IUserEndpointService
    {
        public async Task<IResult> CompleteCourse(CancellationToken token, Guid lessonId, Guid userId)
        {
            var lesson = await context.Lessons.AsNoTracking()
                            .Where(x => x.Id == lessonId)
                            .Select(x => new { x.Id, x.CourseId })
                            .FirstOrDefaultAsync(token);
            if (lesson is null)
                return Results.NotFound(new ApiResultDto(false, "Lesson not found", null!));
            var enrolled = await context.Enrollments.AsNoTracking()
                .AnyAsync(x => x.UserId == userId
                               && x.CourseId == lesson.CourseId
                               && x.Status == EnrollmentStatus.Active, token
                            );
            if (!enrolled)
                return Results.Forbid();
            var existed = await context.LessonCompletions.AsNoTracking()
                .FirstOrDefaultAsync(x => x.UserId == userId && x.LessonId == lessonId, token);
            if (existed != null)
                return Results.Ok(new ApiResultDto(true, "Success",
                    new CompleteResponse(existed.Id, existed.CompletedAt)));
            var record = new LessonCompletion
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                LessonId = lessonId,
                CompletedAt = DateTime.UtcNow,
            };
            context.LessonCompletions.Add(record);
            await context.SaveChangesAsync(token);
            return Results.Ok(new ApiResultDto(true, "Success",
                new CompleteResponse(record.Id, record.CompletedAt)));
        }

        public async Task<IResult> EnrollCourse(
                                CancellationToken token,
                                Guid courseId,
                                Guid userId
                                )
        {
            var existedCourse = await context.Courses.AsNoTracking()
                            .AnyAsync(x => x.Id == courseId, token);
            if (!existedCourse)
                return Results.NotFound(new ApiResultDto(false, "Course not found", null!));
            var enrollment = await context.Enrollments
                            .FirstOrDefaultAsync(x => x.UserId == userId && x.CourseId == courseId, token);
            if (enrollment is null)
            {
                enrollment = new Enrollment
                {
                    Id = Guid.NewGuid(),
                    CourseId = courseId,
                    EnrolledAt = DateTime.UtcNow,
                    UserId = userId,
                    Status = EnrollmentStatus.Active,
                };
                context.Enrollments.Add(enrollment);
            }
            else
            {
                if (enrollment.Status != EnrollmentStatus.Active)
                    enrollment.Status = EnrollmentStatus.Active;
            }
            try
            {
                await context.SaveChangesAsync(token);
            }
            catch (DbUpdateException)
            {
                var again = await context.Enrollments.AsNoTracking()
                    .FirstOrDefaultAsync(x => x.UserId == userId && x.CourseId == courseId, token);
                if (again is not null)
                    return Results.Ok(new
                        ApiResultDto(true, "Success", new EnrollResponse(again.Id, again.Status)));
            }
            return Results.Ok(new ApiResultDto(true, "Success",
                new EnrollResponse(enrollment.Id, enrollment.Status)));
        }

        public async Task<IResult> GetMyProgress(Guid userId, CancellationToken token)
        {
            var existedEnrollmentIds = await context.Enrollments.AsNoTracking()
                                .Where(x => x.UserId == userId && x.Status == EnrollmentStatus.Active)
                                .Select(x => x.CourseId)
                                .Distinct()
                                .ToListAsync(token);
            if (existedEnrollmentIds.Count <= 0)
                return Results.Ok(new ApiResultDto(true, "Ok",
                    new MyProgressDto([])
                ));
            var courseInfo = await context.Courses.AsNoTracking()
                                .Where(x => existedEnrollmentIds.Contains(x.Id))
                                .Select(x => new { x.Id, x.Slug, x.Title })
                                .ToListAsync(token);
            var lessonPerCourse = await context.Lessons.AsNoTracking()
                .Where(x => existedEnrollmentIds.Contains(x.CourseId))
                .GroupBy(x => x.CourseId)
                .Select(x => new
                {
                    CourseId = x.Key,
                    Total = x.Count()
                })
                .ToListAsync(token);
            // số lesson hoàn thành theo khóa 
            var completedPerCourse = await context.LessonCompletions
                .AsNoTracking()
                .Where(x => x.UserId == userId)
                .Join(context.Lessons.AsNoTracking(),
                    comp => comp.LessonId,
                    les => les.Id,
                    (comp, les) => new { les.CourseId })
                .Where(x => existedEnrollmentIds.Contains(x.CourseId))
                .GroupBy(x => x.CourseId)
                .Select(x => new
                {
                    CourseId = x.Key,
                    Completed = x.Count()
                })
                .ToListAsync(token);
            var totalMap = lessonPerCourse.ToDictionary(x => x.CourseId, x => x.Total);
            var doneMap = completedPerCourse.ToDictionary(x => x.CourseId, x => x.Completed);

            var items = courseInfo.Select(x =>
            {
                totalMap.TryGetValue(x.Id, out var total);
                doneMap.TryGetValue(x.Id, out var done);
                var percent = total == 0 ? 0 : Math.Round(done * 100.0 / total, 2);
                return new CourseProgressItem(x.Id, x.Slug, x.Title, total, done, percent);
            })
            .OrderBy(x => x.Title)
            .ToList();
            return Results.Ok(new ApiResultDto(true, "Success", items));
        }
    }
}