using course_service.Features.AdminEndpoint;
using course_service.Features.PublicEndpoint;
using course_service.Features.UserEndpoint;

namespace course_service.Features
{
    public static class CourseEndpoint
    {
        public static void MapCourseEndpoint(this IEndpointRouteBuilder app)
        {
            app.MapGroup("/api/course");
            app.MapGet("/getpublishedcourse/", PublicEndpointHandler.GetPublicCourseHandler);
            app.MapGet("/getbyslug/{slug}", PublicEndpointHandler.GetCourseBySlugHandler);
            app.MapGet("/getlessonbyslug/{slug}", PublicEndpointHandler.GetLessonBySlugHandler);
            app.MapGet("/{courseId}/{userId}:enroll", UserEndpointHandler.GetEnrolledByCourseIdHandler);
        }
        public static void MapLessonEndpoint(this IEndpointRouteBuilder app)
        {
            app.MapGroup("/api/lesson");
            app.MapPost("/{userId}/{lessonId}:complete", UserEndpointHandler.CompeteCourseHandler);
            app.MapPost("/{userId}/progress", UserEndpointHandler.GetMyProgressHandler);

        }
        public static void MapAdminEndpoint(this IEndpointRouteBuilder app)
        {
            app.MapGroup("/api/admin/course");
            app.MapPost("/create", AdminEndpointHandler.CreateCourseHandler);
            app.MapPut("/update/{courseId}", AdminEndpointHandler.UpdateCourseHandler);
            app.MapDelete("/delete/{courseId}", AdminEndpointHandler.DeleteCourseHandler);
            app.MapPost("/{courseId}/lesson/create", AdminEndpointHandler.CreateLessonHandler);
            
            
        }
    }
}