using LangfensEnglish.Tests.Common.Factories;
using LangfensEnglish.Tests.Common.Fixtures;
using Xunit;

namespace VocabularyService.IntegrationTests;

[Collection(nameof(IntegrationTestCollection))]
public class AdminVocabFlowsTests
{
    private const string SkipReason = "Pending admin auth/seed for vocabulary service";
    private readonly VocabularyServiceWebAppFactory _factory;

    public AdminVocabFlowsTests(VocabularyServiceWebAppFactory factory)
    {
        _factory = factory;
    }

    public static IEnumerable<object[]> DeckAdminCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(DeckAdminCases))]
    [Trait("Function", "Admin manage decks & cards")]
    [Trait("Case", "01")]
    [Trait("Level", "Integration")]
    public void AdminDeckManagement_Cases(int caseId)
    {
    }
}
