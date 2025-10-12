using Microsoft.AspNetCore.Mvc;

namespace course_service.Features.UserEndpoint
{
    public static class UserEndpointHandler
    {
        public static Task<IResult> GetEnrolledByCourseIdHandler(
        [FromRoute] Guid courseId,
        [FromRoute] Guid userId,
        CancellationToken token,
        [FromServices] IUserEndpointService service
        ) => service.EnrollCourse(token, courseId, userId);
        public static Task<IResult> CompeteCourseHandler(
            [FromRoute] Guid lessonId,
            [FromRoute] Guid userId,
            CancellationToken token,
            IUserEndpointService service
        ) => service.CompleteCourse(token, lessonId, userId);
        public static Task<IResult> GetMyProgressHandler(
           [FromRoute] Guid userId,
           CancellationToken token,
           IUserEndpointService service
       ) => service.GetMyProgress(userId, token);
    }
}