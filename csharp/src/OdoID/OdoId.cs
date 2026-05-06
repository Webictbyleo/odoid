namespace OdoID;

/// <summary>
/// Provides encoding and decoding of OdoID strings.
/// </summary>
public static class OdoId
{
    /// <summary>
    /// Encodes a non-negative integer <paramref name="n"/> into an OdoID string
    /// of the given <paramref name="length"/>.
    /// </summary>
    /// <param name="n">The integer to encode. Must satisfy 0 ≤ n &lt; Max[length].</param>
    /// <param name="length">Target string length: 6 (default), 7, or 8.</param>
    /// <returns>The encoded OdoID string (uppercase).</returns>
    /// <exception cref="UnsupportedLengthException">
    ///   Thrown if <paramref name="length"/> is not 6, 7, or 8.
    /// </exception>
    /// <exception cref="OdoOverflowException">
    ///   Thrown if <paramref name="n"/> >= Max[<paramref name="length"/>].
    /// </exception>
    public static string Encode(ulong n, int length = 6)
    {
        AssertLength(length);

        if (n >= Charsets.Max[length])
            throw new OdoOverflowException(n, length);

        Span<char> buf = stackalloc char[length];

        for (int i = length - 1; i >= 0; i--)
        {
            var charset = Charsets.GetCharset(i);
            var radix = (ulong)charset.Length;
            buf[i] = charset[(int)(n % radix)];
            n /= radix;
        }

        return new string(buf);
    }

    /// <summary>
    /// Decodes an OdoID string back to its originating integer.
    /// </summary>
    /// <remarks>
    /// The input is uppercased before lookup, so lowercase letters that are valid
    /// in the charset (e.g. <c>"0a0000"</c>) are accepted. The excluded characters
    /// <c>I</c>, <c>L</c>, and <c>O</c> remain invalid even after uppercasing.
    /// </remarks>
    /// <param name="id">The OdoID string to decode (6, 7, or 8 characters).</param>
    /// <returns>The decoded non-negative integer.</returns>
    /// <exception cref="ArgumentException">
    ///   Thrown if <paramref name="id"/> is null or empty.
    /// </exception>
    /// <exception cref="UnsupportedLengthException">
    ///   Thrown if <paramref name="id"/>.Length is not 6, 7, or 8.
    /// </exception>
    /// <exception cref="InvalidCharacterException">
    ///   Thrown if any character is absent from its positional charset.
    /// </exception>
    public static ulong Decode(string id)
    {
        if (string.IsNullOrEmpty(id))
            throw new ArgumentException("OdoID must be a non-empty string.", nameof(id));

        var upper = id.ToUpperInvariant();
        AssertLength(upper.Length);

        ulong n = 0;

        for (int i = 0; i < upper.Length; i++)
        {
            var charset = Charsets.GetCharset(i);
            var radix = (ulong)charset.Length;
            int v = charset.IndexOf(upper[i]);

            if (v < 0)
                throw new InvalidCharacterException(upper[i], i + 1);

            n = n * radix + (ulong)v;
        }

        return n;
    }

    /// <summary>
    /// Validates that <paramref name="length"/> is a supported OdoID length (6, 7, or 8).
    /// </summary>
    /// <exception cref="UnsupportedLengthException">
    ///   Thrown if <paramref name="length"/> is not 6, 7, or 8.
    /// </exception>
    public static void AssertLength(int length)
    {
        if (length is not (6 or 7 or 8))
            throw new UnsupportedLengthException(length);
    }
}
