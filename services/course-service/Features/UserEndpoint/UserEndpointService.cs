using System.Security.Cryptography.Xml;
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
        public Task<IResult> GetEnrollById(
            CancellationToken token,
            Guid courseId,
            Guid userId
        );

        // tạm thời truyền user ID 
        public Task<IResult> CompleteCouse(
            CancellationToken token,
            Guid lessonId,
            Guid userId
        );
    }
    public class UserEndpointService(CourseDbContext context) : IUserEndpointService
    {
        public async Task<IResult> CompleteCouse(CancellationToken token, Guid lessonId, Guid userId)
        {
            var lesson = await context.Lessons.AsNoTracking()
                            .Where(x => x.Id == lessonId)
                            .Select(x => new { x.Id, x.CourseId })
                            .FirstOrDefaultAsync(token);
            if (lesson is null)
                return Results.NotFound(new ApiResultDto(false, "Not found", null!));
            var enrolled = await context.Enrollments.AsNoTracking()
                            .AnyAsync(x => x.UserId == userId
                            && x.CourseId == lesson.CourseId
                            && x.Status == EnrollmentStatus.Active, token
                            );
            if (!enrolled)
                return Results.Forbid();
            var existed = await context.LessonCompletions
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
            return Results.Ok(new ApiResultDto(true, "Success", new CompleteResponse(record.Id, record.CompletedAt)));
        }

        public async Task<IResult> GetEnrollById(
                                CancellationToken token,
                                Guid courseId,
                                Guid userId
                                )
        {
            var existedCourse = await context.Courses.AsNoTracking()
                            .AnyAsync(x => x.Id == courseId, token);
            if (!existedCourse)
                return Results.NotFound(new ApiResultDto(false, "User did not register for this course", null!));
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
            await context.SaveChangesAsync(token);
            return Results.Ok(new ApiResultDto(true, "Success", new EnrollResponse(enrollment.Id, enrollment.Status)));
        }
    }
}