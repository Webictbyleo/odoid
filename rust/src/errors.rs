//! Error types for OdoID encoding and decoding.

use std::fmt;

/// Returned when `n >= MAX[length]` for the chosen OdoID length.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct OverflowError {
    pub n: u64,
    pub length: usize,
    pub max: u64,
}

impl fmt::Display for OverflowError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "n={} is out of range for length {}. Valid range: 0 <= n < {}",
            self.n, self.length, self.max
        )
    }
}

impl std::error::Error for OverflowError {}

/// Returned when a length other than 6, 7, or 8 is requested.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct UnsupportedLengthError {
    pub length: usize,
}

impl fmt::Display for UnsupportedLengthError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "unsupported OdoID length: {}. Must be 6, 7, or 8",
            self.length
        )
    }
}

impl std::error::Error for UnsupportedLengthError {}

/// Returned when a character absent from the positional charset is encountered
/// during decoding.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct InvalidCharacterError {
    /// The offending character.
    pub ch: char,
    /// 1-based position of the offending character.
    pub position: usize,
}

impl fmt::Display for InvalidCharacterError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "invalid OdoID character {:?} at position {}",
            self.ch, self.position
        )
    }
}

impl std::error::Error for InvalidCharacterError {}

/// Unified error type returned by [`encode`](crate::encode) and [`decode`](crate::decode).
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum OdoError {
    Overflow(OverflowError),
    UnsupportedLength(UnsupportedLengthError),
    InvalidCharacter(InvalidCharacterError),
    EmptyInput,
}

impl fmt::Display for OdoError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            OdoError::Overflow(e) => e.fmt(f),
            OdoError::UnsupportedLength(e) => e.fmt(f),
            OdoError::InvalidCharacter(e) => e.fmt(f),
            OdoError::EmptyInput => write!(f, "OdoID must be a non-empty string"),
        }
    }
}

impl std::error::Error for OdoError {}

impl From<OverflowError> for OdoError {
    fn from(e: OverflowError) -> Self { OdoError::Overflow(e) }
}
impl From<UnsupportedLengthError> for OdoError {
    fn from(e: UnsupportedLengthError) -> Self { OdoError::UnsupportedLength(e) }
}
impl From<InvalidCharacterError> for OdoError {
    fn from(e: InvalidCharacterError) -> Self { OdoError::InvalidCharacter(e) }
}
