using attempt_service.Features.Helpers;
using FluentAssertions;

namespace attempt_service.Tests.Helpers;

public class IeltsBandConverterTests
{
    // --- FromAcademicReading ---

    [Fact]
    public void ZeroCorrect_ReturnsBand0()
    {
        IeltsBandConverter.FromAcademicReading(0).Should().Be(0.0m);
    }

    [Fact]
    public void OneCorrect_ReturnsBand1()
    {
        IeltsBandConverter.FromAcademicReading(1).Should().Be(1.0m);
    }

    [Fact]
    public void EightCorrect_ReturnsBand3Point5()
    {
        IeltsBandConverter.FromAcademicReading(8).Should().Be(3.5m);
    }

    [Fact]
    public void TwentyThreeCorrect_ReturnsBand6()
    {
        IeltsBandConverter.FromAcademicReading(23).Should().Be(6.0m);
    }

    [Fact]
    public void ThirtyNineCorrect_ReturnsBand9()
    {
        IeltsBandConverter.FromAcademicReading(39).Should().Be(9.0m);
    }

    [Fact]
    public void FortyCorrect_ReturnsBand9()
    {
        IeltsBandConverter.FromAcademicReading(40).Should().Be(9.0m);
    }

    // --- FromAcademicReadingScaled ---

    [Fact]
    public void Scaled_10of20_EqualsDirect20()
    {
        // 10/20 * 40 = 20 → same as FromAcademicReading(20)
        var scaled = IeltsBandConverter.FromAcademicReadingScaled(10, 20);
        var direct = IeltsBandConverter.FromAcademicReading(20);
        scaled.Should().Be(direct);
    }

    [Fact]
    public void Scaled_0of10_ReturnsZero()
    {
        IeltsBandConverter.FromAcademicReadingScaled(0, 10).Should().Be(0.0m);
    }
}
