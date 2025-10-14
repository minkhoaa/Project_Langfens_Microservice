using course_service.Contracts;

namespace course_service.Features.AdminEndpoint
{
    public static class AdminEndpointHandler
    {
        public static Task<IResult> CreateCourseHandler(
            CreateCourseRequest request,
            CancellationToken token,
            IAdminEndpointService service
            ) => service.CreateCourse(request, token);

        public static Task<IResult> UpdateCourseHandler(
            UpdateCourseRequest request,
            Guid courseId,
            CancellationToken token,
            IAdminEndpointService service
        ) => service.UpdateCourse(request, courseId, token);
        public static Task<IResult> DeleteCourseHandler(
            Guid courseId,
            CancellationToken token,
            IAdminEndpointService service
        ) => service.DeleteCourse(courseId, token);
        public static Task<IResult> CreateLessonHandler(
            CreateLessonRequest request, 
            Guid courseId,
            CancellationToken token,
            IAdminEndpointService service
        ) => service.AddLesson(request, courseId, token);
    }
}