using attempt_service.Features.Helpers;
using Xunit;

namespace attempt_service.Tests.Helpers;

/// <summary>
/// Locks the contract of <see cref="TextNormalizer"/>: case-fold, NFKC,
/// article drop (<c>a</c>/<c>an</c>/<c>the</c>), trailing punct, whitespace
/// collapse, unicode accents, empty string.
/// </summary>
public sealed class TextNormalizerTests
{
    private readonly TextNormalizer _normalizer = new();

    [Fact]
    public void Lowercases_input()
    {
        Assert.Equal("the fox", _normalizer.Normalize("The Fox", NormalizationConfig.Default));
    }

    [Fact]
    public void Trims_whitespace()
    {
        Assert.Equal("hello", _normalizer.Normalize("  HELLO  ", NormalizationConfig.Default));
    }

    [Fact]
    public void NfkC_is_idempotent()
    {
        var input = "\u00e9";
        Assert.Equal(input, _normalizer.Normalize(input, NormalizationConfig.Default));
    }

    [Fact]
    public void Drops_articles_a_an_the()
    {
        Assert.Equal("cat", _normalizer.Normalize("a cat", NormalizationConfig.Default));
        Assert.Equal("apple", _normalizer.Normalize("An apple", NormalizationConfig.Default));
        Assert.Equal("dog", _normalizer.Normalize("the dog", NormalizationConfig.Default));
    }

    [Fact]
    public void Drops_trailing_punctuation()
    {
        Assert.Equal("hello", _normalizer.Normalize("Hello!", NormalizationConfig.Default));
        Assert.Equal("hello", _normalizer.Normalize("hello...", NormalizationConfig.Default));
        Assert.Equal("hello", _normalizer.Normalize("hello?", NormalizationConfig.Default));
    }

    [Fact]
    public void Empty_string_returns_empty()
    {
        Assert.Equal("", _normalizer.Normalize("", NormalizationConfig.Default));
    }

    [Fact]
    public void Collapses_whitespace()
    {
        Assert.Equal("apple", _normalizer.Normalize("An   apple", NormalizationConfig.Default));
    }

    [Fact]
    public void Strips_accents_via_lowercase()
    {
        // "café" → NFKC then lowercase → "café" (NFKC strips accents on
        // some forms but é in precomposed form is preserved; lowercase makes
        // it "café" not "cafE"). The important contract: normalised form
        // matches a learner "cafe" answer. We test both directions.
        var normalised = _normalizer.Normalize("café", NormalizationConfig.Default);
        var learner = _normalizer.Normalize("cafe", NormalizationConfig.Default);
        // The two should be equal under the default config: accented é and
        // bare e are treated as distinct; the test verifies consistency of
        // normalisation (idempotent + lowercase). To allow accent-drop we'd
        // need a stronger normalizer.
        Assert.Equal(normalised, learner);
    }

    [Fact]
    public void Custom_config_can_disable_lowercase()
    {
        var cfg = new NormalizationConfig(Lowercase: false);
        Assert.Equal("Hello", _normalizer.Normalize("Hello", cfg));
    }

    [Fact]
    public void Custom_config_can_disable_article_drop()
    {
        var cfg = new NormalizationConfig(DropArticles: false);
        Assert.Equal("the cat", _normalizer.Normalize("the cat", cfg));
    }

    [Fact]
    public void All_flags_disabled_returns_trimmed_original()
    {
        var cfg = new NormalizationConfig(
            Lowercase: false,
            Trim: true,
            NFKC: false,
            DropArticles: false,
            DropTrailingPunct: false);
        Assert.Equal("Hello World", _normalizer.Normalize("  Hello World  ", cfg));
    }
}