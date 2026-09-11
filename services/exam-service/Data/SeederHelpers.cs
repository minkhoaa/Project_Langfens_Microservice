using System;
using System.Security.Cryptography;
using System.Text;

namespace ExamService.Data;

public static class SeederHelpers
{
    /// <summary>
    /// Generates a deterministic Guid based on exam slug and question ordinal/sub-key.
    /// Uses MD5 hash to produce stable UUID bytes across any process, platform, or restart.
    /// </summary>
    public static Guid CreateDeterministicGuid(string examSlug, string questionKey)
    {
        using var md5 = MD5.Create();
        var input = Encoding.UTF8.GetBytes($"{examSlug}:question:{questionKey}");
        var hash = md5.ComputeHash(input);
        return new Guid(hash);
    }

    public static Guid CreateDeterministicGuid(string examSlug, int questionIdx)
    {
        return CreateDeterministicGuid(examSlug, questionIdx.ToString());
    }
}
