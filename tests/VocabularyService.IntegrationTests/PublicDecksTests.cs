using LangfensEnglish.Tests.Common.Factories;
using LangfensEnglish.Tests.Common.Fixtures;
using Xunit;

namespace VocabularyService.IntegrationTests;

[Collection(nameof(IntegrationTestCollection))]
public class PublicDecksTests
{
    private const string SkipReason = "Pending data seed for vocabulary service";
    private readonly VocabularyServiceWebAppFactory _factory;

    public PublicDecksTests(VocabularyServiceWebAppFactory factory)
    {
        _factory = factory;
    }

    public static IEnumerable<object[]> BrowseCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(BrowseCases))]
    [Trait("Function", "Browse decks list")]
    [Trait("Case", "01")]
    [Trait("Level", "Integration")]
    public void BrowseDecks_Cases(int caseId)
    {
    }

    public static IEnumerable<object[]> DetailCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(DetailCases))]
    [Trait("Function", "Deck detail")]
    [Trait("Case", "02")]
    [Trait("Level", "Integration")]
    public void DeckDetail_Cases(int caseId)
    {
    }
}
