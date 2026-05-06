namespace OdoID;

/// <summary>
/// OdoID character set definitions.
/// These exact strings MUST be reproduced verbatim in every compliant implementation.
/// </summary>
public static class Charsets
{
    /// <summary>Numeric characters — radix 10.</summary>
    public const string Num = "0123456789";

    /// <summary>Alpha characters (ambiguous chars I, L, O excluded) — radix 22.</summary>
    public const string Alpha = "ABCDEFGHJKMNPQRSTVWXYZ";

    /// <summary>Full hybrid set — NUM concatenated with ALPHA — radix 32.</summary>
    public const string All = Num + Alpha; // "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

    /// <summary>
    /// Maximum exclusive value for each supported length.
    /// Formula: 32 × 22 × 10 × 32^(L-3) = 220 × 32^(L-2)
    /// </summary>
    public static readonly IReadOnlyDictionary<int, ulong> Max = new Dictionary<int, ulong>
    {
        [6] = 230_686_720UL,
        [7] = 7_381_975_040UL,
        [8] = 236_223_201_280UL,
    };

    /// <summary>
    /// Returns the character set for a given 0-based position index.
    /// <list type="table">
    ///   <item><term>0</term><description>ALL (radix 32)</description></item>
    ///   <item><term>1</term><description>ALPHA (radix 22)</description></item>
    ///   <item><term>2</term><description>NUM (radix 10)</description></item>
    ///   <item><term>3+</term><description>ALL (radix 32)</description></item>
    /// </list>
    /// </summary>
    internal static string GetCharset(int position) => position switch
    {
        1 => Alpha,
        2 => Num,
        _ => All,
    };
}
