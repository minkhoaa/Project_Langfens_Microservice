namespace course_service.Features.PublicEndpoint
{
    public static class PublicEndpointHandler
    {
        public static Task<IResult> GetPublicCourseHandler(
            string? category,
            string? level,
            string? status,
            CancellationToken token,
            IPublicEndpointService service,
            int page = 1,
            int pageSize = 20
            ) => service.GetPublicCourseService(category, level, status, token);

        public static Task<IResult> GetCourseBySlugHandler(
            string slug,
            CancellationToken token,
            IPublicEndpointService service
            ) => service.GetCourseBySlug(slug, token);
        public static Task<IResult> GetLessonBySlugHandler(
        string slug,
        CancellationToken token,
        IPublicEndpointService service
        ) => service.GetLessonBySlug(slug, token);
    }

}