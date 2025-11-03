namespace Shared.Security.Scopes;

public static class RoleBasedScopeProvider 
{
    public static readonly Dictionary<string, string[]> CustomRoleOptions = new(StringComparer.OrdinalIgnoreCase) {
        ["ADMIN"]  = new[] {
            CourseScope.CourseRead, CourseScope.CourseEnroll, CourseScope.CourseComplete, CourseScope.CourseManage,
            ExamScope.ExamRead,   ExamScope.ExamManage,
            AttemptScope.AttemptStart, AttemptScope.AttemptSubmit, AttemptScope.AttemptReadAny,
            VocabScope.VocabRead,  VocabScope.VocabManage
        },
        ["USER"]   = new[] {
            CourseScope.CourseRead, CourseScope.CourseEnroll, CourseScope.CourseComplete,
            ExamScope.ExamRead, AttemptScope.AttemptStart, AttemptScope.AttemptSubmit, AttemptScope.AttemptReadOwn,
            VocabScope.VocabRead
        }
    };
    
}