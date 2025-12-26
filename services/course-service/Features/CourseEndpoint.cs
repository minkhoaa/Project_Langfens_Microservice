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
            app.MapGet("/api/getpublishedcourse/", PublicEndpointHandler.GetPublicCourseHandler).AllowAnonymous();
            app.MapGet("/api/getbyslug/{slug}", PublicEndpointHandler.GetCourseBySlugHandler).AllowAnonymous();
            app.MapGet("/api/getlessonbyslug/{slug}", PublicEndpointHandler.GetLessonBySlugHandler).AllowAnonymous();
            app.MapGet("/api/lesson/{lessonId:guid}", PublicEndpointHandler.GetLessonByIdHandler).AllowAnonymous();
            app.MapGet("/api/{courseId}/{userId}:enroll", UserEndpointHandler.GetEnrolledByCourseIdHandler)
                .RequireAuthorization(CourseScope.CourseEnroll);
        }
        public static void MapLessonEndpoint(this IEndpointRouteBuilder app)
        {
            app.MapPost("/api/{userId}/{lessonId}:complete", UserEndpointHandler.CompeteCourseHandler)
                .RequireAuthorization(CourseScope.CourseComplete);
            app.MapPost("/api/{userId}/progress", UserEndpointHandler.GetMyProgressHandler)
                .RequireAuthorization(CourseScope.CourseRead);
        }
        public static void MapAdminEndpoint(this IEndpointRouteBuilder app)
        {
            app.MapPost("/api/admin/create", AdminEndpointHandler.CreateCourseHandler)
                .RequireAuthorization(CourseScope.CourseManage);
            app.MapPut("/api/admin/update/{courseId}", AdminEndpointHandler.UpdateCourseHandler)
                .RequireAuthorization(CourseScope.CourseManage);
            app.MapDelete("/api/admin/delete/{courseId}", AdminEndpointHandler.DeleteCourseHandler)
                .RequireAuthorization(CourseScope.CourseManage);
            app.MapPost("/api/admin/{courseId}/lesson/create", AdminEndpointHandler.CreateLessonHandler)
                .RequireAuthorization(CourseScope.CourseManage);
        }
    }
}