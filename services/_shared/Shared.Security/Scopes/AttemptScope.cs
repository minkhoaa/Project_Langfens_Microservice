namespace Shared.Security.Scopes;

public static class AttemptScope
{
    public const string AttemptStart  = "attempt.start";
    public const string AttemptSubmit = "attempt.submit";
    public const string AttemptReadOwn= "attempt.read:own";
    public const string AttemptReadAny= "attempt.read:any";
}