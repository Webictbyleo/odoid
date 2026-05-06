using OdoID;
using Xunit;

namespace OdoID.Tests;

public class DecodeTests
{
    [Theory]
    [InlineData(0UL,       6)]
    [InlineData(1UL,       6)]
    [InlineData(255UL,     6)]
    [InlineData(65535UL,   6)]
    [InlineData(1234567UL, 6)]
    [InlineData(0UL,       7)]
    [InlineData(1234567UL, 7)]
    [InlineData(0UL,       8)]
    [InlineData(1234567UL, 8)]
    public void RoundTrip_DecodeOfEncode_ReturnsOriginal(ulong n, int length)
    {
        var id = OdoId.Encode(n, length);
        Assert.Equal(n, OdoId.Decode(id));
    }

    [Fact]
    public void Decode_AcceptsLowercase()
    {
        Assert.Equal(0UL, OdoId.Decode("0a0000"));
    }

    [Fact]
    public void Decode_LowercaseMatchesUppercase()
    {
        Assert.Equal(OdoId.Decode("0D7NM7"), OdoId.Decode("0d7nm7"));
    }

    [Fact]
    public void Decode_ReturnsUlong()
    {
        var result = OdoId.Decode("0A0000");
        Assert.IsType<ulong>(result);
    }

    [Theory]
    [InlineData('I')]
    [InlineData('L')]
    [InlineData('O')]
    public void Decode_ExcludedCharsThrowInvalidCharacterException(char ch)
    {
        var id = $"0A0{ch}00";
        Assert.Throws<InvalidCharacterException>(() => OdoId.Decode(id));
    }

    [Fact]
    public void Decode_InvalidChar_ReportsCorrectPosition()
    {
        var ex = Assert.Throws<InvalidCharacterException>(() => OdoId.Decode("0A000O"));
        Assert.Equal(6, ex.Position);
        Assert.Equal('O', ex.Char);
    }

    [Fact]
    public void Decode_InvalidCharException_IsArgumentException()
    {
        var ex = Record.Exception(() => OdoId.Decode("0A000O"));
        Assert.IsAssignableFrom<ArgumentException>(ex);
    }

    [Fact]
    public void Decode_SpecialCharThrowsInvalidCharacterException()
    {
        Assert.Throws<InvalidCharacterException>(() => OdoId.Decode("0A00-0"));
    }

    [Theory]
    [InlineData("0A000")]       // length 5
    [InlineData("0A000000000")] // length 11
    public void Decode_UnsupportedLength_ThrowsUnsupportedLengthException(string id)
    {
        Assert.Throws<UnsupportedLengthException>(() => OdoId.Decode(id));
    }

    [Fact]
    public void Decode_EmptyString_ThrowsArgumentException()
    {
        Assert.Throws<ArgumentException>(() => OdoId.Decode(""));
    }

    [Fact]
    public void Decode_Null_ThrowsArgumentException()
    {
        Assert.Throws<ArgumentException>(() => OdoId.Decode(null!));
    }
}
