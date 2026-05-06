/// OdoID character set definitions.
///
/// These exact strings MUST be reproduced verbatim in every compliant
/// implementation to maintain cross-language compatibility.
library;

/// Numeric characters — radix 10.
const String kNum = '0123456789';

/// Alpha characters (ambiguous chars I, L, O excluded) — radix 22.
const String kAlpha = 'ABCDEFGHJKMNPQRSTVWXYZ';

/// Full hybrid set — NUM concatenated with ALPHA — radix 32.
const String kAll = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

/// Maximum exclusive value for each supported length.
///
/// Formula: 32 × 22 × 10 × 32^(L-3) = 220 × 32^(L-2)
const Map<int, int> kMax = {
  6: 230686720,
  7: 7381975040,
  8: 236223201280,
};

/// Returns the charset string for the given 0-based position index.
///
/// | Position | Charset | Radix |
/// |----------|---------|-------|
/// | 0        | ALL     | 32    |
/// | 1        | ALPHA   | 22    |
/// | 2        | NUM     | 10    |
/// | 3+       | ALL     | 32    |
String charsetAt(int position) {
  return switch (position) {
    1 => kAlpha,
    2 => kNum,
    _ => kAll,
  };
}
