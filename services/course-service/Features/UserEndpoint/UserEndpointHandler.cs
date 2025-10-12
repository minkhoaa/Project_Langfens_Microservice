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
        ) => service.GetEnrollById(token, courseId, userId);
        public static Task<IResult> CompeteCourseHandler(
            [FromRoute] Guid lessonId,
            [FromRoute] Guid userId,
            CancellationToken token,
            IUserEndpointService service
        ) => service.CompleteCouse(token, lessonId, userId);
    }
}