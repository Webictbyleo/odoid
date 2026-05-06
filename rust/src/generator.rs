//! OdoIDGenerator — distributed monotonic generator.

use std::time::{SystemTime, UNIX_EPOCH};

use crate::charsets::MAX;
use crate::decode::decode;
use crate::encode::{assert_length, encode};
use crate::errors::{OdoError, UnsupportedLengthError};

/// Configuration for [`OdoIDGenerator`].
#[derive(Debug, Clone)]
pub struct GeneratorConfig {
    /// Logical namespace for this generator. Defaults to `"default"`.
    pub namespace: String,
    /// OdoID string length. Must be 6, 7, or 8. Defaults to `6`.
    pub length: usize,
    /// Millisecond epoch used as the time origin. `None` means use now.
    pub epoch: Option<u64>,
}

impl Default for GeneratorConfig {
    fn default() -> Self {
        Self {
            namespace: "default".into(),
            length: 6,
            epoch: None,
        }
    }
}

/// Value returned by [`OdoIDGenerator::next`].
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct OdoIDResult {
    pub id: String,
    pub n: u64,
    pub length: usize,
    pub namespace: String,
}

/// A distributed monotonic generator that produces OdoID strings driven by a
/// namespace-scoped, time-seeded pseudo-random integer.
///
/// The generator guarantees that rapid successive calls within the same
/// millisecond tick produce distinct values via a monotonically incrementing
/// sequence counter. Output is always in `[0, capacity)` so [`encode`] never
/// returns [`OdoError::Overflow`] internally.
pub struct OdoIDGenerator {
    pub namespace: String,
    pub length: usize,
    pub capacity: u64,
    epoch: u64,
    sequence: u64,
    last_tick: u64,
}

fn now_ms() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("system time before UNIX epoch")
        .as_millis() as u64
}

/// FNV-1a 32-bit hash.
/// Constants are normative: offset basis = 2166136261, prime = 16777619.
fn fnv1a32(value: &str) -> u64 {
    let mut h: u32 = 2166136261;
    for byte in value.bytes() {
        h ^= u32::from(byte);
        h = h.wrapping_mul(16777619);
    }
    u64::from(h)
}

impl OdoIDGenerator {
    /// Creates a new [`OdoIDGenerator`] from `config`.
    ///
    /// # Errors
    /// Returns [`UnsupportedLengthError`] if `config.length` is not 6, 7, or 8.
    pub fn new(config: GeneratorConfig) -> Result<Self, UnsupportedLengthError> {
        assert_length(config.length)?;
        let epoch = config.epoch.unwrap_or(0);
        Ok(Self {
            namespace: config.namespace,
            length: config.length,
            capacity: MAX[config.length],
            epoch,
            sequence: 0,
            last_tick: 0,
        })
    }

    fn tick(&self) -> u64 {
        now_ms().saturating_sub(self.epoch)
    }

    /// Returns the next raw integer `n` in `[0, capacity)`.
    /// Exposed for testing and low-level use.
    pub fn next_n(&mut self) -> u64 {
        let tick = self.tick();

        if tick == self.last_tick {
            self.sequence += 1;
        } else {
            self.sequence = 0;
            self.last_tick = tick;
        }

        let key = format!("{}|{}", self.namespace, tick);
        let mut seed = fnv1a32(&key);
        seed ^= seed << 13;
        seed ^= seed >> 7;
        seed ^= seed << 17;

        (seed + self.sequence) % self.capacity
    }

    /// Generates and returns the next OdoID.
    pub fn next(&mut self) -> Result<OdoIDResult, OdoError> {
        let n = self.next_n();
        let id = encode(n, self.length)?;
        Ok(OdoIDResult {
            id,
            n,
            length: self.length,
            namespace: self.namespace.clone(),
        })
    }

    /// Encodes `n` using this generator's configured length.
    pub fn encode(&self, n: u64) -> Result<String, OdoError> {
        encode(n, self.length)
    }

    /// Decodes an OdoID string to its originating integer.
    pub fn decode(&self, id: &str) -> Result<u64, OdoError> {
        decode(id)
    }
}
