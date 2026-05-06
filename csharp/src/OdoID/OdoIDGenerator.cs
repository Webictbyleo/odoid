namespace OdoID;

/// <summary>Configuration for <see cref="OdoIDGenerator"/>.</summary>
public sealed record GeneratorConfig
{
    /// <summary>Logical namespace for this generator. Defaults to <c>"default"</c>.</summary>
    public string Namespace { get; init; } = "default";

    /// <summary>OdoID string length. Must be 6, 7, or 8. Defaults to <c>6</c>.</summary>
    public int Length { get; init; } = 6;

    /// <summary>
    /// Millisecond epoch used as the time origin.
    /// Defaults to <see cref="DateTimeOffset.UtcNow"/> at construction time (0 = use now).
    /// </summary>
    public long Epoch { get; init; } = 0;
}

/// <summary>Value returned by <see cref="OdoIDGenerator.Next"/>.</summary>
public sealed record OdoIDResult(string Id, ulong N, int Length, string Namespace);

/// <summary>
/// A distributed monotonic generator that produces OdoID strings driven by a
/// namespace-scoped, time-seeded pseudo-random integer.
/// <para>
/// The generator guarantees that rapid successive calls within the same millisecond
/// tick produce distinct values via a monotonically incrementing sequence counter.
/// Output is always in [0, Capacity) so <see cref="OdoId.Encode"/> never throws
/// <see cref="OdoOverflowException"/> internally.
/// </para>
/// </summary>
public sealed class OdoIDGenerator
{
    /// <summary>Logical namespace for this generator.</summary>
    public string Namespace { get; }
    /// <summary>Configured OdoID string length.</summary>
    public int Length { get; }
    /// <summary>Maximum exclusive value (= Max[Length]).</summary>
    public ulong Capacity { get; }

    private readonly long _epoch;
    private ulong _sequence;
    private long _lastTick;

    /// <summary>
    /// Creates a new <see cref="OdoIDGenerator"/> from <paramref name="config"/>.
    /// </summary>
    /// <exception cref="UnsupportedLengthException">
    ///   Thrown if <see cref="GeneratorConfig.Length"/> is not 6, 7, or 8.
    /// </exception>
    public OdoIDGenerator(GeneratorConfig? config = null)
    {
        config ??= new GeneratorConfig();
        OdoId.AssertLength(config.Length);

        Namespace = config.Namespace;
        Length = config.Length;
        Capacity = Charsets.Max[Length];
        _epoch = config.Epoch == 0
            ? DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()
            : config.Epoch;
    }

    private long NowMs() => DateTimeOffset.UtcNow.ToUnixTimeMilliseconds() - _epoch;

    /// <summary>
    /// Computes a FNV-1a 32-bit hash of <paramref name="value"/>.
    /// Constants are normative: offset basis = 2166136261, prime = 16777619.
    /// </summary>
    private static ulong Fnv1a32(string value)
    {
        uint h = 2166136261u;
        foreach (char c in value)
        {
            h ^= (byte)c;
            h *= 16777619u;
        }
        return h;
    }

    /// <summary>
    /// Returns the next raw integer <c>n</c> in [0, <see cref="Capacity"/>).
    /// Exposed for testing and low-level use.
    /// </summary>
    public ulong NextN()
    {
        long tick = NowMs();

        if (tick == _lastTick)
            _sequence++;
        else
        {
            _sequence = 0;
            _lastTick = tick;
        }

        // FNV-1a hash of "namespace|tick", then XOR-shift PRNG
        ulong seed = Fnv1a32($"{Namespace}|{tick}");
        seed ^= seed << 13;
        seed ^= seed >> 7;
        seed ^= seed << 17;

        return (seed + _sequence) % Capacity;
    }

    /// <summary>Generates and returns the next OdoID.</summary>
    public OdoIDResult Next()
    {
        ulong n = NextN();
        string id = OdoId.Encode(n, Length);
        return new OdoIDResult(id, n, Length, Namespace);
    }

    /// <summary>Encodes <paramref name="n"/> using this generator's configured length.</summary>
    public string Encode(ulong n) => OdoId.Encode(n, Length);

    /// <summary>Decodes an OdoID string to its originating integer.</summary>
    public ulong Decode(string id) => OdoId.Decode(id);
}
