//! OdoID encoding — integer to string.

use crate::charsets::{get_charset, MAX};
use crate::errors::{OdoError, OverflowError, UnsupportedLengthError};

#[inline]
pub fn assert_length(length: usize) -> Result<(), UnsupportedLengthError> {
    if matches!(length, 6 | 7 | 8) {
        Ok(())
    } else {
        Err(UnsupportedLengthError { length })
    }
}

/// Encodes a non-negative integer `n` into an OdoID string of the given `length`.
///
/// `length` must be `6` (default), `7`, or `8`.  
/// `n` must satisfy `0 <= n < MAX[length]`.
///
/// # Errors
/// - [`OdoError::UnsupportedLength`] if `length` is not 6, 7, or 8.
/// - [`OdoError::Overflow`] if `n >= MAX[length]`.
///
/// # Examples
/// ```
/// use odoid::encode;
/// assert_eq!(encode(0, 6).unwrap(),            "0A0000");
/// assert_eq!(encode(1234567, 6).unwrap(),      "0D7NM7");
/// assert_eq!(encode(1234567, 7).unwrap(),      "0A15NM7");
/// assert_eq!(encode(236223201279, 8).unwrap(), "ZZ9ZZZZZ");
/// ```
pub fn encode(n: u64, length: usize) -> Result<String, OdoError> {
    assert_length(length)?;

    if n >= MAX[length] {
        return Err(OdoError::Overflow(OverflowError {
            n,
            length,
            max: MAX[length],
        }));
    }

    let mut buf = vec![0u8; length];
    let mut n = n;

    for i in (0..length).rev() {
        let charset = get_charset(i);
        let base = charset.len() as u64;
        buf[i] = charset[(n % base) as usize];
        n /= base;
    }

    Ok(String::from_utf8(buf).expect("charset bytes are always valid ASCII"))
}
