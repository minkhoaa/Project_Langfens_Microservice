using System.Security.Cryptography;
using course_service.Contracts;
using course_service.Domains.Entities;
using course_service.Features.UserEndpoint;
using course_service.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Course.Enums;

namespace course_service.Features.PublicEndpoint
{
    public interface IPublicEndpointService
    {
        public Task<IResult> GetPublicCourseService(
            string? category,
            string? level,
            string? status,
            CancellationToken token,
            int page = 1,
            int pageSize = 20);

        public Task<IResult> GetCourseBySlug(
            string slug,
            CancellationToken token
        );
        public Task<IResult> GetLessonBySlug(
            string slug,
            CancellationToken token
        );

    }
    public class PublicEndpointService(CourseDbContext context) : IPublicEndpointService
    {
        public async Task<IResult> GetCourseBySlug(string slug, CancellationToken token)
        {
            var course = await context.Courses.AsNoTracking()
                                .Where(a => a.Slug == slug)
                                .Select(a => new CourseDetailDto(
                                    a.Id,
                                    a.Slug,
                                    a.Title,
                                    a.DescriptionMd,
                                    a.Category,
                                    a.Level,
                                    a.Status,
                                    a.Lessons.Select(x =>
                                        new LessonItemDto(
                                            x.Id,
                                            x.Idx,
                                            x.Title,
                                            x.DurationMin
                                        )).ToList()
                                )).ToListAsync(token);
            return course != null ? Results.Ok(new ApiResultDto(true, "Success", course))
                                    : Results.NotFound(new ApiResultDto(false, "Not found", null!));
        }

        public async Task<IResult> GetLessonBySlug(string slug, CancellationToken token)
        {
            var courseId = await context.Courses.AsNoTracking()
                                    .Where(x => x.Slug == slug)
                                    .Select(x => x.Id)
                                    .FirstOrDefaultAsync(token);
            if (courseId == Guid.Empty)
                return Results.NotFound(new ApiResultDto(false, "Not found course", null!));
            var lesson = await context.Lessons.AsNoTracking()
                                .Where(x => x.CourseId == courseId)
                                .Select(x => new LessonItemDto(x.Id, x.Idx, x.Title, x.DurationMin))
                                .ToListAsync(token);
            return lesson != null ? Results.Ok(new ApiResultDto(true, "Success", lesson))
                                    : Results.BadRequest(new ApiResultDto(false, "Not found lesson", null!));
        }


        public async Task<IResult> GetPublicCourseService(
            string? category,
            string? level,
            string? status,
            CancellationToken token,
            int page = 1,
            int pageSize = 20)
        {
            if (!CourseCategories.IsValid(category))
                return Results.BadRequest(new ApiResultDto(false, "Invalid category", null!));
            if (!CourseLevel.IsValid(level))
                return Results.BadRequest(new ApiResultDto(false, "Invalid level", null!));
            if (!CourseStatus.IsValid(status))
                return Results.BadRequest(new ApiResultDto(false, "Invalid status", null!));

            IQueryable<Course> courseList = context.Courses.AsNoTracking();

            // lọc theo trường tồn tại
            if (!string.IsNullOrEmpty(category))
                courseList = courseList.Where(x => x.Category == category);
            if (!string.IsNullOrEmpty(level))
                courseList = courseList.Where(x => x.Level == level);
            if (!string.IsNullOrEmpty(status))
                courseList = courseList.Where(a => a.Status == status);

            page = Math.Max(1, page);
            pageSize = Math.Clamp(pageSize, 1, 100);
            var total = await courseList.CountAsync(token);
            var items = await courseList
                    .OrderBy(x => x.Title)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .Select(x => new CourseListItemDto(x.Id, x.Slug, x.Title, x.Category, x.Level, x.Status))
                    .ToListAsync(token);
            return Results.Ok(new ApiResultDto(true, "Success", items));

        }
    }
}