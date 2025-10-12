using System.Data;
using course_service.Domains.Enums;
using course_service.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Course.Enums;

namespace course_service.Features.PublicEndpoint
{
    public interface IPublicEndpointService
    {
        public Task<IResult> GetPublicCourse(
            string? category,
            string? level,
            string? status,
            CancellationToken token,
            int? page = 1,
            int? pageSize = 20


        );
    }



    public class PublicEndpointService(CourseDbContext context) : IPublicEndpointService
    {
        private readonly CourseDbContext _context = context;



        public async Task<IResult> GetPublicCourse(
            string? category,
            string? level,
            string? status,
            CancellationToken token,
            int? page = 1,
            int? pageSize = 20)
        {
            if (!CourseCategories.IsValid(category))
                return Results.BadRequest(new ApiResultDto(false, "Invalid category", null!));
            if (!CourseLevel.IsValid(level))
                return Results.BadRequest(new ApiResultDto(false, "Invalid level", null!));
            if (!CourseStatus.IsValid(status))
                return Results.BadRequest(new ApiResultDto(false, "Invalid status", null!));

            var courseList = _context.Courses.AsNoTracking();
            // lọc theo trường tồn tại

            if (!string.IsNullOrEmpty(category))
                courseList = courseList.Where(x => x.Category == category);
            if (!string.IsNullOrEmpty(level))
                courseList = courseList.Where(x => x.Level == level);
            if (!string.IsNullOrEmpty(status))
                courseList = courseList.Where(a => a.Status == status);
            return Results.Ok(courseList.ToListAsync(token));


        }
    }
}