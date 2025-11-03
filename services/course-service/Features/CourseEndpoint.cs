using course_service.Domains.Entities;
using course_service.Features.AdminEndpoint;
using course_service.Features.PublicEndpoint;
using course_service.Features.UserEndpoint;
using Shared.Security.Scopes;

namespace course_service.Features
{
    public static class CourseEndpoint
    {
        public static void MapCourseEndpoint(this IEndpointRouteBuilder app)
        {
            app.MapGroup("/api/course");
            app.MapGet("/getpublishedcourse/", PublicEndpointHandler.GetPublicCourseHandler).AllowAnonymous();
            app.MapGet("/getbyslug/{slug}", PublicEndpointHandler.GetCourseBySlugHandler).AllowAnonymous();
            app.MapGet("/getlessonbyslug/{slug}", PublicEndpointHandler.GetLessonBySlugHandler).AllowAnonymous();
            app.MapGet("/{courseId}/{userId}:enroll", UserEndpointHandler.GetEnrolledByCourseIdHandler)
                .RequireAuthorization(CourseScope.CourseEnroll);
        }
        public static void MapLessonEndpoint(this IEndpointRouteBuilder app)
        {
            app.MapGroup("/api/lesson");
            app.MapPost("/{userId}/{lessonId}:complete", UserEndpointHandler.CompeteCourseHandler)
                .RequireAuthorization(CourseScope.CourseComplete);
            app.MapPost("/{userId}/progress", UserEndpointHandler.GetMyProgressHandler)
                .RequireAuthorization(CourseScope.CourseRead);

        }
        public static void MapAdminEndpoint(this IEndpointRouteBuilder app)
        {
            app.MapGroup("/api/admin/course").RequireAuthorization(CourseScope.CourseManage);
            app.MapPost("/create", AdminEndpointHandler.CreateCourseHandler);
            app.MapPut("/update/{courseId}", AdminEndpointHandler.UpdateCourseHandler);
            app.MapDelete("/delete/{courseId}", AdminEndpointHandler.DeleteCourseHandler);
            app.MapPost("/{courseId}/lesson/create", AdminEndpointHandler.CreateLessonHandler);
        }
    }
}