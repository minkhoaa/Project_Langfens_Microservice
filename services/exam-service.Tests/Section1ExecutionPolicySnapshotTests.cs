using System.Security.Cryptography;
using System.Text;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper;
using Xunit;

namespace exam_service.Tests;

public class Section1ExecutionPolicySnapshotTests
{
    private static ReadingPaperRun Run()
    {
        var run = new ReadingPaperRun {
            BudgetProfileJson = "{\"caps\":{\"standaloneRunBudgetCapCalls\":75,\"standaloneRunBudgetCapTokens\":380000,\"standaloneRunBudgetCapWallTimeSeconds\":900},\"profileSource\":\"isolated-test\",\"profileVersion\":\"v1\"}"
        };
        run.BudgetProfileSha256 = Convert.ToHexStringLower(SHA256.HashData(Encoding.UTF8.GetBytes(run.BudgetProfileJson)));
        return run;
    }

    [Fact]
    public void Pinning_Policy_Cannot_Legitimize_Corrupt_Resource_Snapshot()
    {
        var run = Run();
        var originalHash = run.BudgetProfileSha256;
        run.BudgetProfileJson = run.BudgetProfileJson.Replace("380000", "999999");
        Assert.Throws<InvalidOperationException>(() => ReadingPaperExecutionSnapshot.Pin(run, PinnedExecutionPolicy.CreateDefault()));
        Assert.Equal(originalHash, run.BudgetProfileSha256);
        Assert.DoesNotContain("executionPolicy", run.BudgetProfileJson);
    }

    [Fact]
    public void Full_Custom_Policy_Is_Pinned_Before_First_Cursor_And_Rehydrates()
    {
        var run = Run();
        var policy = PinnedExecutionPolicy.CreateDefault() with { BlueprintMode = "legacy_preset", Sections = [
            PinnedExecutionPolicy.CreateDefault().Sections[0] with { Groups = [
                new("TRUE_FALSE_NOT_GIVEN", 5), new("TABLE_COMPLETION", 4), new("FLOW_CHART", 4)] }] };
        ReadingPaperExecutionSnapshot.Pin(run, policy);
        Assert.Equal(policy.ComputeHash(), ReadingPaperExecutionSnapshot.Read(run).ComputeHash());
        Assert.True(ReadingPaperCapsProfile.IsValidSnapshot(run.BudgetProfileJson, run.BudgetProfileSha256));
        Assert.True(ReadingPaperCapsProfile.MatchesRunBudget(run.BudgetProfileJson, run.BudgetProfileSha256, false, 75, 380000, 900));
        Assert.Throws<InvalidOperationException>(() => ReadingPaperExecutionSnapshot.Pin(run, PinnedExecutionPolicy.CreateDefault()));
    }

    [Theory]
    [InlineData("missing")]
    [InlineData("hash")]
    [InlineData("policy")]
    [InlineData("outer-hash")]
    public void Missing_Or_Corrupt_Policy_Cannot_Adopt_Current_Defaults(string fault)
    {
        var run = Run();
        if (fault != "missing") ReadingPaperExecutionSnapshot.Pin(run, PinnedExecutionPolicy.CreateDefault());
        if (fault == "hash") run.BudgetProfileJson = run.BudgetProfileJson.Replace("executionPolicyHash\":\"", "executionPolicyHash\":\"bad");
        if (fault == "policy") run.BudgetProfileJson = run.BudgetProfileJson.Replace("\"requireBlindSolver\":true", "\"requireBlindSolver\":false");
        if (fault != "outer-hash") run.BudgetProfileSha256 = Convert.ToHexStringLower(SHA256.HashData(Encoding.UTF8.GetBytes(run.BudgetProfileJson)));
        else run.BudgetProfileSha256 = new string('0', 64);
        Assert.Throws<InvalidOperationException>(() => ReadingPaperExecutionSnapshot.Read(run));
    }
}
