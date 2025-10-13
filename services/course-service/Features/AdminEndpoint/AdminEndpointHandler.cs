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

    }
}