using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace course_service.Contracts
{
    public record CourseListItemDto(Guid Id, string Slug, string Title, string? Category, string? Level, string Status);
}