using System;
using ExamService.Data;
using Xunit;

namespace attempt_service.Tests.Seeders;

public class ReadingSeederDeterminismTests
{
    [Fact]
    public void CreateDeterministicGuid_ProducesIdenticalGuid_Across100Iterations()
    {
        var firstGuid = SeederHelpers.CreateDeterministicGuid("test-slug", 1);

        for (var i = 0; i < 100; i++)
        {
            var nextGuid = SeederHelpers.CreateDeterministicGuid("test-slug", 1);
            Assert.Equal(firstGuid, nextGuid);
        }
    }

    [Fact]
    public void CreateDeterministicGuid_ProducesDistinctGuids_ForDifferentIndicesOrSlugs()
    {
        var guid1 = SeederHelpers.CreateDeterministicGuid("test-slug", 1);
        var guid2 = SeederHelpers.CreateDeterministicGuid("test-slug", 2);
        var guidDifferentSlug = SeederHelpers.CreateDeterministicGuid("different-slug", 1);

        Assert.NotEqual(guid1, guid2);
        Assert.NotEqual(guid1, guidDifferentSlug);
        Assert.NotEqual(guid2, guidDifferentSlug);
    }

    [Fact]
    public void CreateDeterministicGuid_ReturnsNonEmptyGuid()
    {
        var guid = SeederHelpers.CreateDeterministicGuid("test-slug", 1);

        Assert.NotEqual(Guid.Empty, guid);
    }

    [Fact]
    public void CreateDeterministicGuid_ForReadingExam1_DoesNotMatchLegacy3333Prefix()
    {
        const string readingSlug = "ielts-reading-practice-1";
        var legacyPrefix = "33333333-";

        for (var idx = 1; idx <= 13; idx++)
        {
            var guid = SeederHelpers.CreateDeterministicGuid(readingSlug, idx);
            Assert.DoesNotContain(legacyPrefix, guid.ToString());
        }

        var subKeys = new[] { "11a", "11b", "11c" };
        foreach (var subKey in subKeys)
        {
            var guid = SeederHelpers.CreateDeterministicGuid(readingSlug, subKey);
            Assert.DoesNotContain(legacyPrefix, guid.ToString());
        }
    }
}
