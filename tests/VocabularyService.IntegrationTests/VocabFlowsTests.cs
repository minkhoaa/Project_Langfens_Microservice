using LangfensEnglish.Tests.Common.Factories;
using LangfensEnglish.Tests.Common.Fixtures;
using Xunit;

namespace VocabularyService.IntegrationTests;

[Collection(nameof(IntegrationTestCollection))]
public class VocabFlowsTests
{
    private const string SkipReason = "Pending authenticated flow and seed";
    private readonly VocabularyServiceWebAppFactory _factory;

    public VocabFlowsTests(VocabularyServiceWebAppFactory factory)
    {
        _factory = factory;
    }

    public static IEnumerable<object[]> SubscribeCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(SubscribeCases))]
    [Trait("Function", "Subscribe to a deck")]
    [Trait("Case", "01")]
    [Trait("Level", "Integration")]
    public void SubscribeDeck_Cases(int caseId)
    {
    }

    public static IEnumerable<object[]> MyDeckCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(MyDeckCases))]
    [Trait("Function", "View my subscribed decks")]
    [Trait("Case", "02")]
    [Trait("Level", "Integration")]
    public void MyDecks_Cases(int caseId)
    {
    }

    public static IEnumerable<object[]> ReviewCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(ReviewCases))]
    [Trait("Function", "Review flashcards")]
    [Trait("Case", "03")]
    [Trait("Level", "Integration")]
    public void ReviewFlashcards_Cases(int caseId)
    {
    }
}
