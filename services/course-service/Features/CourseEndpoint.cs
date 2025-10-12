namespace course_service.Features
{
    public static class CourseEndpoint
    {
        public static void MapCourseEndpoint(this IEndpointRouteBuilder app)
        {
            app.MapGroup("/api/course");
            
        }
    }
}