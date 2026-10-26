using System.Text.Json;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper;
using exam_service.Features.ReadingPaper.Contracts;
using Xunit;

namespace exam_service.Tests;
public class Section1AcceptanceContractTests
{
    [Fact]
    public void Canonical_Source_And_Table_Flow_Stimuli_Survive_Normalization()
    {
        using var doc = JsonDocument.Parse("""
        {"sectionId":1,"title":"Offline process study","passage":"The workers used charcoal to heat the furnace. They measured the temperature using a calibrated sensor.",
         "sourceMetadata":{"pmcid":"PMC1234567","title":"Original study","sourceUrl":"https://example.invalid/study","license":"CC BY 4.0","authors":"Test author"},
         "groups":[{"questionType":"TABLE_COMPLETION","instructions":"Complete the table.","questions":[
          {"questionNumber":1,"prompt":"The fuel was [1].","answer":"charcoal","evidenceQuote":"The workers used charcoal to heat the furnace.","explanation":"The experimental sentence explicitly names the fuel used to heat the furnace.","tableContext":"Experimental inputs","rowHeader":"Fuel","colHeader":"Material"}]},
         {"questionType":"FLOW_CHART","instructions":"Complete the flow chart.","questions":[
          {"questionNumber":2,"prompt":"Measure [2] using a calibrated sensor.","answer":"temperature","evidenceQuote":"They measured the temperature using a calibrated sensor.","explanation":"The cited measurement step explicitly states the quantity recorded by the sensor.","flowSteps":["Collect ore","Measure [2] using a calibrated sensor.","Record observations"],"stepIndex":1}]}]}
        """);
        var parsed = CheckpointService.ParseCanonicalV2Section(doc.RootElement)!;
        var sections = ReadingPaperWorker.NormalizeSectionsForValidation([parsed]);
        var retained = JsonSerializer.Serialize(sections);
        Assert.Equal("PMC1234567", sections[0].Source.Pmcid);
        Assert.Equal("https://example.invalid/study", sections[0].Source.Url);
        Assert.Contains("Experimental inputs", retained);
        Assert.Contains("Fuel", retained); Assert.Contains("Material", retained);
        Assert.Contains("Collect ore", retained); Assert.Contains("Record observations", retained);
    }

    [Theory]
    [InlineData(6, "FLOW_CHART", true)]
    [InlineData(6, "TABLE_COMPLETION", false)]
    [InlineData(10, "FLOW_CHART", false)]
    public void Authority_Rejects_Wrong_Family_Or_Incomplete_Stimulus(int number, string family, bool complete)
    {
        var caps = Section1LifecycleTests.Caps();
        var run = new ReadingPaperRun { BudgetProfileJson = caps.SnapshotJson, BudgetProfileSha256 = caps.Sha256 };
        var policy = PinnedExecutionPolicy.CreateForSources("minimax", [new ReadingSource("PMC1234567", "offline", null,
            "https://example.invalid", "CC BY", 800, Metadata: new() { ["acceptancePolicy"] = "acceptance_5_4_4_v1" })]);
        ReadingPaperExecutionSnapshot.Pin(run, policy);
        var payload = JsonSerializer.SerializeToElement(new { questionNumber = number, questionType = family,
            tableContext = complete ? "Study" : "", rowHeader = "Method", colHeader = "Result", flowSteps = new[] {"First", $"Then [{number}]"}, stepIndex = complete ? 1 : -1 });
        var artifact = new ArtifactEnvelope("q", ArtifactType.Question, 1, "run", 1, "2.0.0", "hash", DateTime.UtcNow, "2.0.0", payload, []);
        Assert.Throws<CheckpointValidationException>(() => ReadingPaperAcceptanceContract.Validate(run, artifact));
    }
}
