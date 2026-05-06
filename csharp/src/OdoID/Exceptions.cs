namespace OdoID;

/// <summary>
/// Thrown when an integer is outside the valid range for the chosen OdoID length.
/// </summary>
public sealed class OdoOverflowException : ArgumentOutOfRangeException
{
    /// <summary>The value that was out of range.</summary>
    public ulong N { get; }
    /// <summary>The requested OdoID length.</summary>
    public int Length { get; }

    /// <inheritdoc />
    public OdoOverflowException(ulong n, int length)
        : base(nameof(n),
               $"n={n} is out of range for length {length}. Valid range: 0 <= n < {Charsets.Max[length]}.")
    {
        N = n;
        Length = length;
    }
}

/// <summary>
/// Thrown when a length other than 6, 7, or 8 is requested.
/// </summary>
public sealed class UnsupportedLengthException : ArgumentOutOfRangeException
{
    /// <inheritdoc />
    public UnsupportedLengthException(int length)
        : base(nameof(length), length,
               $"Unsupported OdoID length: {length}. Must be 6, 7, or 8.")
    { }
}

/// <summary>
/// Thrown when a character absent from the positional charset is encountered during decoding.
/// </summary>
public sealed class InvalidCharacterException : ArgumentException
{
    /// <summary>The offending character.</summary>
    public char Char { get; }
    /// <summary>The 1-based position of the offending character.</summary>
    public int Position { get; }

    /// <inheritdoc />
    public InvalidCharacterException(char ch, int position)
        : base($"Invalid OdoID character '{ch}' at position {position}.")
    {
        Char = ch;
        Position = position;
    }
}
