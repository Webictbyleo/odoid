using OdoID;
using Xunit;

namespace OdoID.Tests;

public class GeneratorTests
{
    [Fact]
    public void DefaultConfig_HasCorrectDefaults()
    {
        var g = new OdoIDGenerator();
        Assert.Equal("default", g.Namespace);
        Assert.Equal(6, g.Length);
    }

    [Fact]
    public void CustomConfig_NamespaceAndLength()
    {
        var g = new OdoIDGenerator(new GeneratorConfig { Namespace = "acme", Length = 8 });
        Assert.Equal("acme", g.Namespace);
        Assert.Equal(8, g.Length);
    }

    [Theory]
    [InlineData(6)]
    [InlineData(7)]
    [InlineData(8)]
    public void Capacity_MatchesMax(int length)
    {
        var g = new OdoIDGenerator(new GeneratorConfig { Length = length });
        Assert.Equal(Charsets.Max[length], g.Capacity);
    }

    [Fact]
    public void UnsupportedLength_ThrowsUnsupportedLengthException()
    {
        Assert.Throws<UnsupportedLengthException>(
            () => new OdoIDGenerator(new GeneratorConfig { Length = 5 }));
    }

    [Fact]
    public void Next_ResultHasCorrectShape()
    {
        var g = new OdoIDGenerator(new GeneratorConfig { Namespace = "test", Length = 6 });
        var r = g.Next();
        Assert.NotEmpty(r.Id);
        Assert.Equal(6, r.Length);
        Assert.Equal("test", r.Namespace);
    }

    [Theory]
    [InlineData(6)]
    [InlineData(7)]
    [InlineData(8)]
    public void Next_IdHasCorrectLength(int length)
    {
        var g = new OdoIDGenerator(new GeneratorConfig { Length = length });
        Assert.Equal(length, g.Next().Id.Length);
    }

    [Fact]
    public void Next_IdIsUppercaseAlphanumeric()
    {
        var g = new OdoIDGenerator(new GeneratorConfig { Length = 8 });
        for (int i = 0; i < 50; i++)
        {
            var id = g.Next().Id;
            Assert.True(id.All(c => char.IsLetterOrDigit(c)), $"ID '{id}' contains non-alphanumeric char");
            Assert.Equal(id.ToUpperInvariant(), id);
        }
    }

    [Fact]
    public void Next_ExcludedCharsNeverInOutput()
    {
        var g = new OdoIDGenerator(new GeneratorConfig { Length = 8 });
        for (int i = 0; i < 50; i++)
        {
            var id = g.Next().Id;
            Assert.DoesNotContain('I', id);
            Assert.DoesNotContain('L', id);
            Assert.DoesNotContain('O', id);
        }
    }

    [Theory]
    [InlineData(6)]
    [InlineData(7)]
    [InlineData(8)]
    public void Next_NIsInValidRange(int length)
    {
        var g = new OdoIDGenerator(new GeneratorConfig { Length = length });
        for (int i = 0; i < 50; i++)
        {
            var n = g.Next().N;
            Assert.InRange(n, 0UL, Charsets.Max[length] - 1);
        }
    }

    [Fact]
    public void Next_NMatchesDecodeOfId()
    {
        var g = new OdoIDGenerator(new GeneratorConfig { Namespace = "verify", Length = 6 });
        for (int i = 0; i < 20; i++)
        {
            var r = g.Next();
            Assert.Equal(r.N, OdoId.Decode(r.Id));
        }
    }

    [Fact]
    public void MonotonicSequencing_SameTickProducesDistinctIds()
    {
        // Future epoch keeps tick at 0 so all calls share the same tick
        long futureEpoch = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds() + 60_000;
        var g = new OdoIDGenerator(new GeneratorConfig
        {
            Namespace = "seq-test",
            Epoch = futureEpoch
        });

        var ids = new HashSet<string>();
        for (int i = 0; i < 20; i++)
            ids.Add(g.Next().Id);

        Assert.Equal(20, ids.Count);
    }

    [Fact]
    public void NamespaceIsolation_DifferentNamespacesProduceDifferentIds()
    {
        long futureEpoch = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds() + 60_000;
        var g1 = new OdoIDGenerator(new GeneratorConfig { Namespace = "ns-a", Length = 8, Epoch = futureEpoch });
        var g2 = new OdoIDGenerator(new GeneratorConfig { Namespace = "ns-b", Length = 8, Epoch = futureEpoch });

        Assert.NotEqual(g1.Next().Id, g2.Next().Id);
    }

    [Fact]
    public void ProxyEncode_UsesGeneratorLength()
    {
        var g = new OdoIDGenerator(new GeneratorConfig { Length = 7 });
        Assert.Equal(7, g.Encode(0UL).Length);
    }

    [Fact]
    public void ProxyDecode_ReturnsCorrectN()
    {
        var g = new OdoIDGenerator(new GeneratorConfig { Length = 6 });
        var r = g.Next();
        Assert.Equal(r.N, g.Decode(r.Id));
    }
}
