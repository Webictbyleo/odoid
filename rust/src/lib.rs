//! OdoID — Deterministic mixed-radix ID encoding.
//!
//! Maps a non-negative integer to a 6, 7, or 8-character alphanumeric string
//! with a serial-number aesthetic. All ambiguous characters (`I`, `L`, `O`) are
//! excluded from all positions to prevent transcription errors.
//!
//! # Quick start
//!
//! ```
//! use odoid::{encode, decode, OdoIDGenerator, GeneratorConfig};
//!
//! assert_eq!(encode(0,            6).unwrap(), "0A0000");
//! assert_eq!(encode(1234567,      6).unwrap(), "0D7NM7");
//! assert_eq!(encode(1234567,      7).unwrap(), "0A15NM7");
//! assert_eq!(encode(236223201279, 8).unwrap(), "ZZ9ZZZZZ");
//!
//! assert_eq!(decode("0D7NM7").unwrap(), 1234567);
//!
//! let mut g = OdoIDGenerator::new(GeneratorConfig {
//!     namespace: "orders".into(),
//!     length: 7,
//!     ..Default::default()
//! }).unwrap();
//! let result = g.next().unwrap();
//! assert_eq!(result.length, 7);
//! ```

mod charsets;
mod decode;
mod encode;
mod errors;
mod generator;

pub use charsets::{ALPHA, ALL, MAX, NUM};
pub use decode::decode;
pub use encode::encode;
pub use errors::{InvalidCharacterError, OdoError, OverflowError, UnsupportedLengthError};
pub use generator::{GeneratorConfig, OdoIDGenerator, OdoIDResult};
