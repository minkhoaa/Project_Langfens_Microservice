using System.Security.Cryptography;
using System.Threading.RateLimiting;
using course_service.Contracts;
using course_service.Domains.Entities;
using course_service.Infrastructure;
using Google.Protobuf.WellKnownTypes;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Course.Enums;

namespace course_service.Features.AdminEndpoint
{

    public interface IAdminEndpointService
    {
        public Task<IResult> CreateCourse(CreateCourseRequest request, CancellationToken token);
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
    }
}