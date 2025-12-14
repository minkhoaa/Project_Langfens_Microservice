namespace CourseService.UnitTests;

internal static class CourseTestData
{
    public static Course AddCourse(CourseDbContext ctx, string slug, int lessonCount = 0)
    {
        var course = new Course
        {
            Id = Guid.NewGuid(),
            Slug = slug,
            Title = $"Course {slug}",
            Status = CourseStatus.Published,
            Category = CourseCategories.IELTS_ACADEMIC,
            Level = CourseLevel.B1,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        ctx.Courses.Add(course);

        for (var i = 1; i <= lessonCount; i++)
        {
            ctx.Lessons.Add(new Lesson
            {
                Id = Guid.NewGuid(),
                CourseId = course.Id,
                Title = $"Lesson {i}",
                Idx = i,
                DurationMin = 10
            });
        }

        return course;
    }
}
