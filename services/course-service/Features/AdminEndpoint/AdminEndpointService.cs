using course_service.Contracts;
using course_service.Domains.Entities;
using course_service.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion.Internal;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Course.Enums;

namespace course_service.Features.AdminEndpoint
{

    public interface IAdminEndpointService
    {
        public Task<IResult> CreateCourse(CreateCourseRequest request, CancellationToken token);
        public Task<IResult> UpdateCourse(UpdateCourseRequest request, Guid courseId , CancellationToken token);
        public Task<IResult> DeleteCourse(Guid courseId, CancellationToken token);
        public Task<IResult> AddLesson(CreateLessonRequest request, Guid courseId, CancellationToken token);
    }
    public class AdminEndpointService(CourseDbContext context) : IAdminEndpointService
    {
        public async Task<IResult> CreateCourse(CreateCourseRequest request, CancellationToken token)
        {
            if (string.IsNullOrWhiteSpace(request.Slug))
                return Results.BadRequest(new ApiResultDto(false, "Slug is missing", null!));
            if (string.IsNullOrWhiteSpace(request.Title))
                return Results.BadRequest(new ApiResultDto(false, "Title is missing", null!));

            var existed = await context.Courses.AsNoTracking()
                            .AnyAsync(x => x.Slug == request.Slug, token);
            if (existed)
                return Results.Conflict(new ApiResultDto(false, "Slug is existed", null!));
            if (request.Category != null && !CourseCategories.IsValid(request.Category))
                return Results.BadRequest(new ApiResultDto(false, "Category is invalid", null!));
            if (request.Level != null && !CourseLevel.IsValid(request.Level))
                return Results.BadRequest(new ApiResultDto(false, "Level is invalid", null!));
            if (request.Status != null && !CourseStatus.IsValid(request.Status))
                return Results.BadRequest(new ApiResultDto(false, "Status is invalid", null!));
           
            var now = DateTime.UtcNow;
            var newCourse = new Course
            {
                Id = Guid.NewGuid(),
                Slug = request.Slug,
                Title = request.Title,
                DescriptionMd = request.DescriptionMd,
                Category = request.Category,
                Level = request.Level,
                Status = request.Status ?? CourseStatus.Draft,
                CreatedAt = now,
                UpdatedAt = now
            };
            context.Courses.Add(newCourse);
            await context.SaveChangesAsync(token);
            return Results.Ok(new ApiResultDto(true, "Created successfully", newCourse));
        }

        public async Task<IResult> UpdateCourse(UpdateCourseRequest request, Guid courseId, CancellationToken token)
        {
            if (string.IsNullOrWhiteSpace(request.Slug))
                return Results.BadRequest(new ApiResultDto(false, "Slug is missing", null!));
            if (string.IsNullOrWhiteSpace(request.Title))
                return Results.BadRequest(new ApiResultDto(false, "Title is missing", null!));

            var existed = await context.Courses.AsNoTracking()
                .AnyAsync(x => x.Slug == request.Slug, token);
            if (existed)
                return Results.Conflict(new ApiResultDto(false, "Slug is existed", null!));
            if (request.Category != null && !CourseCategories.IsValid(request.Category))
                return Results.BadRequest(new ApiResultDto(false, "Category is invalid", null!));
            if (request.Level != null && !CourseLevel.IsValid(request.Level))
                return Results.BadRequest(new ApiResultDto(false, "Level is invalid", null!));
            if (request.Status != null && !CourseStatus.IsValid(request.Status))
                return Results.BadRequest(new ApiResultDto(false, "Status is invalid", null!));

            var existedCourse = await context.Courses
                .FirstOrDefaultAsync(a => a.Id == courseId, token);
            if (existedCourse == null)
                return Results.NotFound(new ApiResultDto(false, "Not found course", null!));
            await using var transaction = await context.Database.BeginTransactionAsync(token);
            try
            {
                existedCourse.Slug = request.Slug;
                existedCourse.Category = request.Category;
                existedCourse.DescriptionMd = request.DescriptionMd;
                existedCourse.Title = request.Title;
                existedCourse.Level = request.Level;
                existedCourse.Status = request.Status ?? existedCourse.Status;
                existedCourse.UpdatedAt = DateTime.UtcNow;
                context.Courses.Update(existedCourse);
                await context.SaveChangesAsync(token);
                await transaction.CommitAsync(token);
                return Results.Ok(new ApiResultDto(true, $"Update {courseId} successfully",
                    new CourseUpdateDto(
                        existedCourse.Id,
                        existedCourse.Slug,
                        existedCourse.Title,
                        existedCourse.DescriptionMd,
                        existedCourse.Category,
                        existedCourse.Level,
                        existedCourse.Status,
                        existedCourse.UpdatedAt
                        )));
            }
            catch (Exception e)
            {
                await transaction.RollbackAsync(token);
                return Results.BadRequest(new ApiResultDto(true, "Error while updating" + e.Message, null!));
            }
        }

        public async Task<IResult> DeleteCourse(Guid courseId, CancellationToken token)
        {
            try
            {
                var affectedRows = await context.Courses
                    .Where(x => x.Id == courseId)
                    .ExecuteDeleteAsync(token);
                return Results.Ok(new ApiResultDto(true, $"Update {affectedRows} row", null!));
            }
            catch (Exception e)
            {
                return Results.BadRequest(new ApiResultDto(true, "Error while deleting " + e.Message, null!));
            }
            
        }

        public async Task<IResult> AddLesson(CreateLessonRequest request, Guid courseId, CancellationToken token)
        {
            if (string.IsNullOrEmpty(request.Title))
                return Results.BadRequest(new ApiResultDto(false, "Title is missing", null!));
            var course = await context.Courses.Include(course => course.Lessons)
                .FirstOrDefaultAsync(x => x.Id == courseId, token);
            if (course == null)
                return Results.BadRequest(new ApiResultDto(false, "Not found course", null!));
            var maxIndex = await context.Lessons.AsNoTracking()
                .Where(l => l.CourseId == courseId)
                .Select(l => (int?)l.Idx)
                .MaxAsync(token) ?? 0;
            int insert = maxIndex + 1;
            var newLesson = new Lesson()
            {
                CourseId = courseId,
                ContentMd = request.ContentMd,
                DurationMin = request.DurationMin,
                Idx = insert
            };
            context.Lessons.Add(newLesson);
            await context.SaveChangesAsync(token);
            return Results.Ok(new ApiResultDto(true, "Create lesson successfully", 
                new LessonCreatedDto(newLesson.Id, newLesson.Idx)));
        }
    }
}