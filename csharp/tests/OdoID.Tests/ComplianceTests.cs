// Compliance test vectors as defined in SPEC.md § 8.
// Every compliant implementation MUST pass these tests unchanged.
using OdoID;
using Xunit;

namespace OdoID.Tests;

public class ComplianceTests
{
    // ── § 8.1 Encode ─────────────────────────────────────────────────────────

    [Theory]
    [InlineData(0UL,            6, "0A0000")]
    [InlineData(1234567UL,      6, "0D7NM7")]
    [InlineData(1234567UL,      7, "0A15NM7")]
    [InlineData(236223201279UL, 8, "ZZ9ZZZZZ")]
    [InlineData(230686719UL,    6, "ZZ9ZZZ")]  // max valid for L=6
    public void Encode_SpecVectors(ulong n, int length, string expected)
    {
        Assert.Equal(expected, OdoId.Encode(n, length));
    }

    // ── § 8.2 Decode round-trips ──────────────────────────────────────────────

    [Theory]
    [InlineData("0A0000",   0UL)]
    [InlineData("0D7NM7",   1234567UL)]
    [InlineData("0A15NM7",  1234567UL)]
    [InlineData("ZZ9ZZZZZ", 236223201279UL)]
    [InlineData("ZZ9ZZZ",   230686719UL)]
    public void Decode_SpecVectors(string id, ulong expected)
    {
        Assert.Equal(expected, OdoId.Decode(id));
    }

    // ── § 8.3 Error cases ─────────────────────────────────────────────────────

    [Fact]
    public void Encode_ThrowsOverflow_WhenNEqualsMax6()
    {
        Assert.Throws<OdoOverflowException>(() => OdoId.Encode(Charsets.Max[6], 6));
    }

    [Fact]
    public void Encode_ThrowsUnsupportedLength_WhenLength5()
    {
        Assert.Throws<UnsupportedLengthException>(() => OdoId.Encode(0, 5));
    }

    [Fact]
    public void Decode_ThrowsInvalidCharacter_WhenContainsO_AtPosition6()
    {
        var ex = Assert.Throws<InvalidCharacterException>(() => OdoId.Decode("0A000O"));
        Assert.Equal(6, ex.Position);
        Assert.Equal('O', ex.Char);
    }

    [Fact]
    public void Decode_ThrowsInvalidCharacter_WhenContainsI_AtPosition6()
    {
        var ex = Assert.Throws<InvalidCharacterException>(() => OdoId.Decode("0A000I"));
        Assert.Equal(6, ex.Position);
    }

    [Fact]
    public void Decode_ThrowsInvalidCharacter_WhenLowercaseLBecomesExcludedL()
    {
        Assert.Throws<InvalidCharacterException>(() => OdoId.Decode("0A000l"));
    }

    [Fact]
    public void Decode_ThrowsArgumentException_WhenEmpty()
    {
        Assert.Throws<ArgumentException>(() => OdoId.Decode(""));
    }
}
