//! OdoID decoding — string to integer.

use crate::charsets::get_charset;
use crate::encode::assert_length;
use crate::errors::{InvalidCharacterError, OdoError};

/// Decodes an OdoID string back to its originating integer.
///
/// The input is uppercased before lookup, so lowercase letters that are valid
/// in the charset (e.g. `"0a0000"`) are accepted. The excluded characters
/// `I`, `L`, and `O` remain invalid even after uppercasing.
///
/// # Errors
/// - [`OdoError::EmptyInput`] if `id` is empty.
/// - [`OdoError::UnsupportedLength`] if `id.len()` is not 6, 7, or 8.
/// - [`OdoError::InvalidCharacter`] if any character is absent from its positional charset.
///
/// # Examples
/// ```
/// use odoid::decode;
/// assert_eq!(decode("0A0000").unwrap(), 0);
/// assert_eq!(decode("0D7NM7").unwrap(), 1234567);
/// assert_eq!(decode("0a0000").unwrap(), 0); // lowercase accepted
/// ```
pub fn decode(id: &str) -> Result<u64, OdoError> {
    if id.is_empty() {
        return Err(OdoError::EmptyInput);
    }

    let upper = id.to_uppercase();
    let length = upper.len();
    assert_length(length)?;

    let bytes = upper.as_bytes();
    let mut n: u64 = 0;

    for (i, &byte) in bytes.iter().enumerate() {
        let charset = get_charset(i);
        let base = charset.len() as u64;

        let v = charset.iter().position(|&c| c == byte).ok_or_else(|| {
            OdoError::InvalidCharacter(InvalidCharacterError {
                ch: byte as char,
                position: i + 1,
            })
        })?;

        n = n * base + v as u64;
    }

    Ok(n)
}
