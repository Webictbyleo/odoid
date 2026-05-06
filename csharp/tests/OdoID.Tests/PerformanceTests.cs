// Performance tests — SPEC.md § 9.
// Each Encode / Decode call must average ≤ 0.1000 ms over a representative load.
using OdoID;
using System.Diagnostics;
using Xunit;

namespace OdoID.Tests;

public class PerformanceTests
{
    private const double LimitMs = 0.1;
    private const int Warmup = 2_000;
    private const int Iterations = 10_000;

    private static void AssertAvgMs(string label, Action fn)
    {
        for (int i = 0; i < Warmup; i++) fn();

        var sw = Stopwatch.StartNew();
        for (int i = 0; i < Iterations; i++) fn();
        sw.Stop();

        double avgMs = sw.Elapsed.TotalMilliseconds / Iterations;
        Assert.True(avgMs <= LimitMs,
            $"{label}: average {avgMs:F4} ms exceeded spec limit of {LimitMs} ms");
    }

    [Fact]
    public void Encode_Length6_AverageBelowLimit()
    {
        ulong n = 0;
        AssertAvgMs("encode/6", () =>
        {
            n = (n + 1) % Charsets.Max[6];
            OdoId.Encode(n, 6);
        });
    }

    [Fact]
    public void Encode_Length7_AverageBelowLimit()
    {
        ulong n = 0;
        AssertAvgMs("encode/7", () =>
        {
            n = (n + 1) % Charsets.Max[7];
            OdoId.Encode(n, 7);
        });
    }

    [Fact]
    public void Encode_Length8_AverageBelowLimit()
    {
        ulong n = 0;
        AssertAvgMs("encode/8", () =>
        {
            n = (n + 1) % Charsets.Max[8];
            OdoId.Encode(n, 8);
        });
    }

    [Fact]
    public void Decode_Length6_AverageBelowLimit()
    {
        var ids = new[] { "0A0000", "0D7NM7", "ZZ9ZZZ", "1B3C4D", "AB0000" };
        int i = 0;
        AssertAvgMs("decode/6", () => { OdoId.Decode(ids[i++ % ids.Length]); });
    }

    [Fact]
    public void Decode_Length7_AverageBelowLimit()
    {
        var ids = new[] { "0A00000", "0A15NM7", "ZZ9ZZZZ", "1B3C4D5", "AB00000" };
        int i = 0;
        AssertAvgMs("decode/7", () => { OdoId.Decode(ids[i++ % ids.Length]); });
    }

    [Fact]
    public void Decode_Length8_AverageBelowLimit()
    {
        var ids = new[] { "0A000000", "ZZ9ZZZZZ", "1B3C4D5E", "AB000000" };
        int i = 0;
        AssertAvgMs("decode/8", () => { OdoId.Decode(ids[i++ % ids.Length]); });
    }
}
