using OdoID;
using Xunit;

namespace OdoID.Tests;

public class EncodeTests
{
    [Fact]
    public void DefaultLengthIs6()
    {
        Assert.Equal("0A0000", OdoId.Encode(0));
        Assert.Equal(6, OdoId.Encode(0).Length);
    }

    [Theory]
    [InlineData(6)]
    [InlineData(7)]
    [InlineData(8)]
    public void OutputLengthMatchesRequested(int length)
    {
        Assert.Equal(length, OdoId.Encode(0, length).Length);
    }

    [Theory]
    [InlineData(0UL)]
    [InlineData(1UL)]
    [InlineData(100UL)]
    [InlineData(999999UL)]
    [InlineData(1234567UL)]
    public void OutputIsAlwaysUppercase(ulong n)
    {
        var id = OdoId.Encode(n, 6);
        Assert.Equal(id.ToUpperInvariant(), id);
    }

    [Theory]
    [InlineData(0UL)]
    [InlineData(1UL)]
    [InlineData(100UL)]
    [InlineData(1234567UL)]
    public void Position1IsAlwaysAlphaChar(ulong n)
    {
        var id = OdoId.Encode(n, 6);
        Assert.Contains(id[1], Charsets.Alpha);
    }

    [Theory]
    [InlineData(0UL)]
    [InlineData(1UL)]
    [InlineData(100UL)]
    [InlineData(1234567UL)]
    public void Position2IsAlwaysDigit(ulong n)
    {
        var id = OdoId.Encode(n, 6);
        Assert.True(char.IsDigit(id[2]), $"Expected digit at position 2, got '{id[2]}'");
    }

    [Theory]
    [InlineData(0UL)]
    [InlineData(1UL)]
    [InlineData(1000UL)]
    [InlineData(1234567UL)]
    [InlineData(100_000_000UL)]
    public void ExcludedCharsNeverAppearInOutput(ulong n)
    {
        var id = OdoId.Encode(n, 8);
        Assert.DoesNotContain('I', id);
        Assert.DoesNotContain('L', id);
        Assert.DoesNotContain('O', id);
    }

    [Theory]
    [InlineData(6)]
    [InlineData(7)]
    [InlineData(8)]
    public void EncodeZeroIsValid(int length)
    {
        var ex = Record.Exception(() => OdoId.Encode(0, length));
        Assert.Null(ex);
    }

    [Theory]
    [InlineData(6)]
    [InlineData(7)]
    [InlineData(8)]
    public void EncodeMaxMinus1IsValid(int length)
    {
        var ex = Record.Exception(() => OdoId.Encode(Charsets.Max[length] - 1, length));
        Assert.Null(ex);
    }

    [Theory]
    [InlineData(6)]
    [InlineData(7)]
    [InlineData(8)]
    public void EncodeMax_ThrowsOdoOverflowException(int length)
    {
        Assert.Throws<OdoOverflowException>(() => OdoId.Encode(Charsets.Max[length], length));
    }

    [Fact]
    public void OverflowException_MessageContainsViolatingValue()
    {
        var ex = Assert.Throws<OdoOverflowException>(() => OdoId.Encode(Charsets.Max[6], 6));
        Assert.Contains(Charsets.Max[6].ToString(), ex.Message);
    }

    [Fact]
    public void OverflowException_IsArgumentOutOfRangeException()
    {
        var ex = Record.Exception(() => OdoId.Encode(Charsets.Max[6], 6));
        Assert.IsAssignableFrom<ArgumentOutOfRangeException>(ex);
    }

    [Theory]
    [InlineData(0)]
    [InlineData(1)]
    [InlineData(5)]
    [InlineData(9)]
    [InlineData(100)]
    public void UnsupportedLength_ThrowsUnsupportedLengthException(int length)
    {
        Assert.Throws<UnsupportedLengthException>(() => OdoId.Encode(0, length));
    }

    [Fact]
    public void UnsupportedLengthException_IsArgumentOutOfRangeException()
    {
        var ex = Record.Exception(() => OdoId.Encode(0, 5));
        Assert.IsAssignableFrom<ArgumentOutOfRangeException>(ex);
    }
}
