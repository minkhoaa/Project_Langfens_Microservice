namespace LangfensEnglish.Tests.Common.Utils;

public static class TestEnvKeys
{
    public const string AuthConnection = "CONNECTIONSTRING__AUTH";
    public const string CourseConnection = "CONNECTIONSTRING__COURSE";
    public const string VocabularyConnection = "CONNECTIONSTRING__VOCABULARY";
    public const string ExamConnection = "CONNECTIONSTRING__EXAM";
    public const string AttemptConnection = "CONNECTIONSTRING__ATTEMPT";
    public const string SpeakingConnection = "CONNECTIONSTRING__SPEAKING";
    public const string WritingConnection = "CONNECTIONSTRING__WRITING";
    public const string RedisConnection = "CONNECTIONSTRING__REDIS";

    public const string JwtIssuer = "JwtSettings__Issuer";
    public const string JwtAudience = "JwtSettings__Audience";
    public const string JwtSignKey = "JwtSettings__SignKey";
    public const string JwtAccessLifetime = "JwtSettings__AccessTokenLifetimeSeconds";
}
