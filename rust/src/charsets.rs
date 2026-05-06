//! OdoID character set definitions.
//!
//! These exact strings MUST be reproduced verbatim in every compliant implementation.

/// Numeric characters — radix 10.
pub const NUM: &str = "0123456789";

/// Alpha characters (ambiguous chars I, L, O excluded) — radix 22.
pub const ALPHA: &str = "ABCDEFGHJKMNPQRSTVWXYZ";

/// Full hybrid set — NUM concatenated with ALPHA — radix 32.
pub const ALL: &str = "0123456789ABCDEFGHJKMNPQRSTVWXYZ";

/// Maximum exclusive value for each supported length.
/// Formula: 32 × 22 × 10 × 32^(L-3) = 220 × 32^(L-2)
pub const MAX: [u64; 9] = [
    0, 0, 0, 0, 0, 0,
    230_686_720,          // length 6
    7_381_975_040,        // length 7
    236_223_201_280,      // length 8
];

/// Returns the character set bytes for 0-based position index `i`.
///
/// | Index | Charset | Radix |
/// |-------|---------|-------|
/// | 0     | ALL     | 32    |
/// | 1     | ALPHA   | 22    |
/// | 2     | NUM     | 10    |
/// | 3+    | ALL     | 32    |
#[inline]
pub(crate) fn get_charset(i: usize) -> &'static [u8] {
    match i {
        1 => ALPHA.as_bytes(),
        2 => NUM.as_bytes(),
        _ => ALL.as_bytes(),
    }
}
