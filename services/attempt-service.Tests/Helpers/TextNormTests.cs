using attempt_service.Features.Helpers;
using FluentAssertions;

namespace attempt_service.Tests.Helpers;

public class TextNormTests
{
    [Fact]
    public void TrimsAndLowercases()
    {
        TextNorm.Normalize("  HELLO  ").Should().Be("hello");
    }

    [Fact]
    public void StripsDiacritics()
    {
        // é decomposed → e + combining accent; NonSpacingMark removed → cafe
        TextNorm.Normalize("café").Should().Be("cafe");
    }

    [Fact]
    public void CollapsesMultipleSpaces()
    {
        TextNorm.Normalize("JOHN  GOULD").Should().Be("john gould");
    }

    [Fact]
    public void EmptyString_ReturnsEmpty()
    {
        TextNorm.Normalize("").Should().Be("");
    }

    [Fact]
    public void NullInput_ReturnsEmpty()
    {
        TextNorm.Normalize(null).Should().Be("");
    }
}
